# app/mailers/order_mailer.rb

class OrderMailer < ApplicationMailer
  default from: 'orders@ecomstore.com'

  def confirmation_email(order)
    @order = order
    @user = order.user
    @order_items = order.order_items.includes(:product)
    @payment_record = order.payment_records.last

    # Calculate totals for email
    @subtotal = @order_items.sum(&:total_price)
    @shipping_cost = @subtotal >= 50 ? 0 : 9.99
    @tax_amount = @subtotal * 0.08
    @total_amount = @subtotal + @shipping_cost + @tax_amount

    mail(
      to: @order.user.email,
      subject: "Order Confirmation ##{@order.id.to_s.rjust(6, '0')} - EcomStore"
    )
  end

  def shipping_notification(order)
    @order = order
    @user = order.user
    @order_items = order.order_items.includes(:product)

    mail(
      to: @order.email,
      subject: "Your Order ##{@order.id.to_s.rjust(6, '0')} Has Shipped! - EcomStore"
    )
  end
end
