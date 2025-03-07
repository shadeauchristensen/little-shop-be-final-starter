class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :name, null: false
      t.string :code, null: false
      t.string :discount_type, null: false
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
