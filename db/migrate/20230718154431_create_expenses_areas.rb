class CreateExpensesAreas < ActiveRecord::Migration[7.0]
  def change
    create_table :expenses_areas do |t|
      t.references :expense, null: false, foreign_key: true
      t.references :area, null: false, foreign_key: true

      t.timestamps
    end
  end
end
