class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :postal_code
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :status, default: 'pending'
      t.string :stripe_payment_intent_id
      t.text :notes

      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, :stripe_payment_intent_id
  end
end
