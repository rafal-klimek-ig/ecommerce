class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true,
                      numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :unit_price, presence: true,
                        numericality: { greater_than: 0 }

  validate :product_availability
  validate :sufficient_stock

  before_validation :set_prices, on: :create

  scope :by_product, ->(product) { where(product: product) }

  def total_price
    unit_price * quantity
  end

  def formatted_unit_price
    "$#{'%.2f' % unit_price}"
  end

  def formatted_total_price
    "$#{'%.2f' % total_price}"
  end

  private

  def set_prices
    if product.present?
      self.unit_price = product.price
    end
  end

  def product_availability
    return unless product

    unless product.active?
      errors.add(:product, "is not available")
    end
  end

  def sufficient_stock
    return unless product && quantity

    unless product.available_stock?(quantity)
      errors.add(:quantity, "exceeds available stock (#{product.stock_quantity} available)")
    end
  end
end
