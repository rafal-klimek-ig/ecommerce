class PaymentRecord < ApplicationRecord
    belongs_to :order
    belongs_to :user

    # enum status: {
    #   pending: 'pending',
    #   processing: 'processing',
    #   succeeded: 'succeeded',
    #   failed: 'failed',
    #   canceled: 'canceled',
    #   refunded: 'refunded',
    #   partially_refunded: 'partially_refunded'
    # }

    # enum payment_method: {
    #   card: 'card',
    # }

    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :currency, presence: true
    validates :status, presence: true
    validates :payment_method, presence: true

    validates :card_last_four, presence: true, length: { is: 4 }, if: :card_payment?
    validates :card_brand, presence: true, if: :card_payment?
    validates :card_exp_month, presence: true,
              format: { with: /\A(0[1-9]|1[0-2])\z/ }, if: :card_payment?
    validates :card_exp_year, presence: true,
              format: { with: /\A\d{4}\z/ }, if: :card_payment?

    scope :successful, -> { where(status: 'succeeded') }
    scope :failed, -> { where(status: 'failed') }
    scope :recent, -> { order(created_at: :desc) }
    scope :by_user, ->(user) { where(user: user) }

    # Callbacks
    before_save :set_processed_at, if: :status_changed_to_succeeded?

    def card_payment?
      payment_method == 'card'
    end

    def successful?
      succeeded?
    end

    def failed?
      status == 'failed'
    end

    def refundable?
      succeeded? && !refunded? && !partially_refunded?
    end

    def formatted_amount
      "$#{'%.2f' % amount}"
    end

    def masked_card_number
      return nil unless card_last_four.present?
      "**** **** **** #{card_last_four}"
    end

    def card_display
      return nil unless card_payment? && card_brand.present? && card_last_four.present?
      "#{card_brand.titleize} ending in #{card_last_four}"
    end

    def billing_full_name
      [billing_first_name, billing_last_name].compact.join(' ')
    end

    def stripe_payment_url
      return nil unless stripe_payment_intent_id.present?
      "https://dashboard.stripe.com/payments/#{stripe_payment_intent_id}"
    end

    private

    def status_changed_to_succeeded?
      status_changed? && succeeded?
    end

    def set_processed_at
      self.processed_at = Time.current
    end
  end