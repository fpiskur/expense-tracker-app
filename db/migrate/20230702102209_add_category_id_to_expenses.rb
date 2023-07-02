class AddCategoryIdToExpenses < ActiveRecord::Migration[7.0]
  def change
    add_reference :expenses, :category, index: true
    add_foreign_key :expenses, :categories
  end
end
