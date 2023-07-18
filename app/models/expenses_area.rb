class ExpensesArea < ApplicationRecord
  belongs_to :expense
  belongs_to :area
end
