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
      redirect_to current_order_path
      return
    end

    # Pre-fill address with user information if available
    # if @order.address_line_1.blank? && current_user
    #   @order.assign_attributes(
    #     email: current_user.email,
    #     first_name: current_user.first_name,
    #     last_name: current_user.last_name
    #   )
    # end

    # Calculate totals for display
    @subtotal = @order.order_items.sum(&:total_price)
    @shipping_cost = @subtotal >= 50 ? 0 : 9.99
    @tax_amount = @subtotal * 0.08
    @total_amount = @subtotal + @shipping_cost + @tax_amount
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
    redirect_to current_order_path
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Item not found in your cart."
    redirect_to current_order_path
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

    redirect_to current_order_path
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Item not found in your cart."
    redirect_to current_order_path
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
      @current_order.order_items.create!(
        product: @product,
        quantity: quantity,
        unit_price: @product.price
      )
      flash[:notice] = "#{@product.name} added to cart!"
    end

    @current_order.save!

    respond_to do |format|
      format.html { redirect_to products_path }
      format.json { render json: { success: true, message: flash[:notice] } }
    end
  end

  def create
    @order = @current_order || current_user.orders.build

    if @order.order_items.empty?
      10.times { puts @order.id }
      redirect_to cart_path, alert: 'Your cart is empty qwe.'
      return
    end

    @order.assign_attributes(order_params)

    if @order.save
      # NOTE: [RK] Add stripe payments
      redirect_to @order, notice: 'Order was successfully created.'
    else
      render 'cart', status: :unprocessable_entity
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

  def order_params
    params.require(:order).permit(
      :address_line_1, :address_line_2, :city, :state, :postal_code,
      :notes
    )
  end
end
