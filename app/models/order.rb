class Order < ApplicationRecord
  class OrderStatus
    include ::Ruby::Enum

    define :PENDING, 'pending'
    define :PAID, 'paid'
    define :PROCESSING, 'processing'
    define :SHIPPED, 'shipped'
    define :DELIVERED, 'delivered'
    define :CANCELLED, 'cancelled'
    define :REFUNDED, 'refunded'

    # Mapping for external payment processor statuses (e.g., Stripe)
    STRIPE_STATUS_MAPPING = {
      'requires_payment_method' => OrderStatus::PENDING,
      'requires_confirmation' => OrderStatus::PENDING,
      'requires_action' => OrderStatus::PENDING,
      'processing' => OrderStatus::PROCESSING,
      'succeeded' => OrderStatus::PAID,
      'canceled' => OrderStatus::CANCELLED
    }.freeze

    # Valid status transitions
    STATUS_TRANSITIONS = {
      OrderStatus::PENDING => [OrderStatus::PAID, OrderStatus::CANCELLED],
      OrderStatus::PAID => [OrderStatus::PROCESSING, OrderStatus::CANCELLED, OrderStatus::REFUNDED],
      OrderStatus::PROCESSING => [OrderStatus::SHIPPED, OrderStatus::CANCELLED],
      OrderStatus::SHIPPED => [OrderStatus::DELIVERED],
      OrderStatus::DELIVERED => [OrderStatus::REFUNDED],
      OrderStatus::CANCELLED => [],
      OrderStatus::REFUNDED => []
    }.freeze

    class << self
      def from_stripe(status)
        STRIPE_STATUS_MAPPING[status]
      end

      def can_transition?(from_status, to_status)
        STATUS_TRANSITIONS[from_status]&.include?(to_status) || false
      end

      def cancellable_statuses
        [PENDING, PAID, PROCESSING]
      end

      def refundable_statuses
        [PAID, PROCESSING, SHIPPED, DELIVERED]
      end

      def active_statuses
        [PENDING, PAID, PROCESSING, SHIPPED]
      end

      def completed_statuses
        [DELIVERED, CANCELLED, REFUNDED]
      end

      def predelivery_statuses
        [PENDING, CANCELLED]
      end
    end
  end

  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_many :payment_records, dependent: :destroy

  validates :address_line_1, presence: true, length: { minimum: 5, maximum: 100 },
            unless: -> { status.in?(OrderStatus.predelivery_statuses) }
  validates :city, presence: true, length: { minimum: 2, maximum: 50 },
            unless: -> { status.in?(OrderStatus.predelivery_statuses) }
  validates :postal_code, presence: true, length: { minimum: 3, maximum: 20 },
            unless: -> { status.in?(OrderStatus.predelivery_statuses) }
  validates :total_amount, presence: true,
                          numericality: { greater_than: 0 },
                          unless: -> { status.in?(OrderStatus.predelivery_statuses) }
  validates :status, presence: true,
                    inclusion: { in: OrderStatus.values }

  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(created_at: :desc) }

  before_validation :calculate_total_amount, on: [:create, :update]

  def full_address
    address_parts = [address_line_1, address_line_2, city, state, postal_code]
    address_parts.compact.join(', ')
  end

  def formatted_total
    "$#{'%.2f' % total_amount}"
  end

  def can_be_cancelled?
    OrderStatus.cancellable_statuses.include?(status)
  end

  def item_count
    order_items.sum(:quantity)
  end

  private

  def calculate_total_amount
    self.total_amount = order_items.sum(&:total_price)
  end
end
