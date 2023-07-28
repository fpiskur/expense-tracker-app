class ChangeExpenseAmountToFloat < ActiveRecord::Migration[7.0]
  def change
    change_column :expenses, :amount, :decimal, precision: 9, scale: 2
  end
end
