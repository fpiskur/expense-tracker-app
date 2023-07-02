class CreateExpenses < ActiveRecord::Migration[7.0]
  def change
    create_table :expenses do |t|
      t.integer :amount
      t.string :description
      t.date :date

      t.timestamps
    end
  end
end
