class CreatePaymentRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_records do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      # Payment Method Information
      t.string :payment_method, null: false, default: 'card'
      t.string :card_last_four, limit: 4
      t.string :card_brand  # visa, mastercard, amex, etc.
      t.string :card_exp_month, limit: 2
      t.string :card_exp_year, limit: 4

      # Payment Status
      t.string :status, null: false, default: 'pending'
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: 'usd'


      # Timestamps and Metadata
      t.datetime :processed_at
      t.text :failure_reason
      t.json :stripe_metadata

      t.timestamps
    end

    add_index :payment_records, :status
    add_index :payment_records, [:user_id, :created_at]
  end
end