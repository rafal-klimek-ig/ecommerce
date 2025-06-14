class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :cancel]
  before_action :find_or_create_current_order, only: [:add_item, :cart, :create]

  def index
    @orders = current_user.orders
                         .where.not(status: 'pending')
                         .includes(order_items: :product)
                         .order(created_at: :desc)

    if params[:status].present?
      @orders = @orders.where(status: params[:status])
    end

    @orders = @orders.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.json { render json: @orders }
    end
  end


  def show
  end

  def checkout
    @order = current_order

    if @order.nil? || @order.order_items.empty?
      redirect_to products_path, alert: 'Your cart is empty.'
      return
    end

    # Validate all items are still available
    unavailable_items = []
    @order.order_items.includes(:product).each do |item|
      unless item.product.active? && item.product.available_stock?(item.quantity)
        unavailable_items << item.product.name
      end
    end

    if unavailable_items.any?
      flash[:alert] = "Some items are no longer available: #{unavailable_items.join(', ')}. Please review your cart."
      redirect_to cart_path
      return
    end

    @subtotal = @order.order_items.sum(&:total_price)
    @shipping_cost = @subtotal >= 50 ? 0 : 9.99
    @total_amount = @subtotal + @shipping_cost
  end

  def remove_item
    @order_item = OrderItem.joins(:order)
                          .where(orders: { user: current_user, status: 'pending' })
                          .find(params[:order_item_id])

    product_name = @order_item.product.name
    order = @order_item.order
    @order_item.destroy

    # Recalculate order total if there are remaining items
    if order.order_items.any?
      order.save!
    else
      # If no items left, optionally delete the empty order
      # order.destroy  # Uncomment if you want to delete empty orders
    end

    flash[:notice] = "#{product_name} removed from cart."
    redirect_to cart_path
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Item not found in your cart."
    redirect_to cart_path
  end

  def update_item
    @order_item = OrderItem.joins(:order)
                          .where(orders: { user: current_user, status: 'pending' })
                          .find(params[:order_item_id])

    new_quantity = params[:quantity].to_i
    product = @order_item.product

    if new_quantity <= 0
      # Remove item if quantity is 0 or negative
      product_name = product.name
      @order_item.destroy
      flash[:notice] = "#{product_name} removed from cart."
    elsif product.available_stock?(new_quantity)
      # Update quantity if stock is available
      @order_item.update!(quantity: new_quantity)
      flash[:notice] = "Cart updated successfully."
    else
      # Handle insufficient stock
      max_available = product.stock_quantity
      if max_available > 0
        @order_item.update!(quantity: max_available)
        flash[:alert] = "Only #{max_available} items available. Quantity adjusted to maximum."
      else
        @order_item.destroy
        flash[:alert] = "#{product.name} is now out of stock and was removed from cart."
      end
    end

    # Recalculate order total
    order = @order_item.order
    if order.order_items.any?
      order.save!
    else
      # If no items left, optionally delete the empty order
      # order.destroy  # Uncomment if you want to delete empty orders
    end

    redirect_to cart_path
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Item not found in your cart."
    redirect_to cart_path
  end

  def cart
    @order = @current_order
    @order_items = @order&.order_items&.includes(:product) || []

    render 'cart'
  end

  def add_item
    @product = Product.find(params[:product_id])
    quantity = params[:quantity]&.to_i || 1

    unless @product.active? && @product.available_stock?(quantity)
      redirect_back_or_to products_path, alert: 'Product is not available or insufficient stock.'
      return
    end

    @order_item = @current_order.order_items.find_by(product: @product)

    if @order_item
      new_quantity = @order_item.quantity + quantity

      if @product.available_stock?(new_quantity)
        @order_item.update!(quantity: new_quantity)
        flash[:notice] = "Updated #{@product.name} quantity in cart."
      else
        flash[:alert] = "Cannot add more items. Only #{@product.stock_quantity} available."
      end
    else
      @append_new_item = true
      @order_item = @current_order.order_items.create!(
        product: @product,
        quantity: quantity,
        unit_price: @product.price
      )
      flash[:notice] = "#{@product.name} added to cart!"
    end

    @current_order.save!
    @order_items = @current_order.order_items

    respond_to do |format|
      format.html { redirect_back(fallback_location: products_path) }
      format.turbo_stream do
        puts(:asdqwe)
        turbo_stream.replace("cart_badge",
                              partial: "shared/cart_badge")
      end
      format.json { render json: { success: true, message: flash[:notice] } }
    end
  end

  def create
    @order = @current_order
    if @current_order.order_items.empty?
      redirect_to orders_path, alert: 'Your cart is empty.'
      return
    end

    unless @current_order.status == Order::OrderStatus::PENDING
      redirect_to orders_path, alert: 'This order cannot be finished.'
      return
    end

    # Calculate totals
    subtotal = @current_order.order_items.sum(&:total_price)
    shipping_cost = subtotal >= 50 ? 0 : 9.99
    total_amount = subtotal + shipping_cost

    # Update order with form data
    @current_order.assign_attributes(order_params)
    @current_order.total_amount = total_amount
    @current_order.status = 'paid'

    if @current_order.valid? && payment_params_valid?
      begin
        # Save the order first
        @current_order.save!

        # Create payment record
        create_payment_record(total_amount)

        # Reduce inventory for all items
        @current_order.order_items.each do |item|
          product = item.product
          product.update!(stock_quantity: product.stock_quantity - item.quantity)
        end

        redirect_to @current_order, notice: 'Order was successfully placed!'
      rescue => e
        Rails.logger.error "Order creation error: #{e.message}"
        @current_order.status = 'pending'
        flash.now[:alert] = 'There was an error processing your order. Please try again.'
        redirect_to '/checkout', status: :unprocessable_entity
      end
    else
      @current_order.status = 'pending'
      flash.now[:alert] = 'Please check your order details and payment information.'
      redirect_to '/checkout', status: :unprocessable_entity
    end
  end

  def cancel
    if @order.can_be_cancelled?
      @order.update!(status: 'cancelled')
      redirect_to orders_path, notice: 'Order was cancelled.'
    else
      redirect_to @order, alert: 'This order cannot be cancelled.'
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def find_or_create_current_order
    @current_order = current_user.orders.find_by(status: 'pending')

    unless @current_order
      @current_order = current_user.orders.create!(
        status: 'pending',
        address_line_1: '',
        city: '',
        state: '',
        postal_code: '',
        total_amount: 0
      )
    end
  end

  def redirect_back_or_to(path)
    redirect_back(fallback_location: path)
  end

  def create_payment_record(total_amount)
    card_number = payment_params[:card_number].gsub(/\s/, '')
    card_expiry = payment_params[:card_expiry]
    exp_month, exp_year = card_expiry.split('/')

    PaymentRecord.create!(
      order: @current_order,
      user: current_user,
      payment_method: 'card',
      amount: total_amount,
      currency: 'usd',
      status: 'succeeded',
      processed_at: Time.current,
      card_last_four: card_number.last(4),
      card_brand: detect_card_brand(card_number),
      card_exp_month: exp_month.rjust(2, '0'),
      card_exp_year: "20#{exp_year}"
    )
  end

  def detect_card_brand(card_number)
    case card_number
    when /^4/ then 'visa'
    when /^5[1-5]/, /^222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720/ then 'mastercard'
    else 'unknown'
    end
  end

  def payment_params_valid?
    card_number = payment_params[:card_number]&.gsub(/\s/, '')
    card_expiry = payment_params[:card_expiry]
    card_cvv = payment_params[:card_cvv]
    cardholder_name = payment_params[:cardholder_name]

    errors = []

    if card_number.blank? || card_number.length < 13 || card_number.length > 19
      errors << "Card number is invalid"
    end

    if card_expiry.blank? || !card_expiry.match(/\A\d{2}\/\d{2}\z/)
      errors << "Expiry date is invalid"
    elsif card_expiry.present?
      month, year = card_expiry.split('/')
      if month.to_i < 1 || month.to_i > 12
        errors << "Expiry month is invalid"
      end

      current_year = Date.current.year % 100
      current_month = Date.current.month
      if year.to_i < current_year || (year.to_i == current_year && month.to_i < current_month)
        errors << "Card has expired"
      end
    end

    if card_cvv.blank? || card_cvv.length < 3 || card_cvv.length > 4
      errors << "Security code is invalid"
    end

    if cardholder_name.blank?
      errors << "Cardholder name is required"
    end

    if errors.any?
      @current_order.errors.add(:base, errors.join(', '))
      return false
    end

    true
  end

  def base_create_params
    params.require(:order).permit(
      :address_line_1, :address_line_2, :city, :postal_code, :notes,
      :card_number, :cardholder_name, :card_expiry, :card_cvv
    )
  end

  def order_params
    # base_create_params[
    #   :address_line_1, :address_line_2, :city, :postal_code, :notes
    # ]
    params.require(:order).permit(
      :address_line_1, :address_line_2, :city, :postal_code, :notes
    )
  end

  def payment_params
    params.require(:order).permit(
      :card_number, :cardholder_name, :card_expiry, :card_cvv
    )
  end
end
