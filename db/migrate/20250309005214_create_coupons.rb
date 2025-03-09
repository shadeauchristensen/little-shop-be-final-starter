class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.references :merchant, null: false, foreign_key: true
      t.string :name
      t.string :code
      t.string :discount_type
      t.decimal :discount_value
      t.boolean :active

      t.timestamps
    end
  end
end
