# Category.create!([
#   {
#     name: 'Rezije',
#     parent_id: nil
#   },
#   {
#     name: 'Auto',
#     parent_id: nil
#   },
#   {
#     name: 'Internet, TV',
#     parent_id: nil
#   },
#   {
#     name: 'Buba',
#     parent_id: nil
#   },
#   {
#     name: 'Ostalo',
#     parent_id: nil
#   },
#   {
#     name: 'Stanarina',
#     parent_id: nil
#   }
# ])

# puts 'Parent categories created'

# rezije = Category.find_by(name: 'Rezije')
# auto = Category.find_by(name: 'Auto')
# int_tv = Category.find_by(name: 'Internet, TV')
# buba = Category.find_by(name: 'Buba')
# ostalo = Category.find_by(name: 'Ostalo')

# Category.create!([
#   {
#     name: 'Plin',
#     parent_id: rezije.id
#   },
#   {
#     name: 'Struja',
#     parent_id: rezije.id
#   },
#   {
#     name: 'Holding',
#     parent_id: rezije.id
#   },
#   {
#     name: 'A1',
#     parent_id: int_tv.id
#   },
#   {
#     name: 'Netflix',
#     parent_id: int_tv.id
#   },
#   {
#     name: 'Gorivo',
#     parent_id: auto.id
#   },
#   {
#     name: 'Servis',
#     parent_id: auto.id
#   },
#   {
#     name: 'Tehnicki',
#     parent_id: auto.id
#   },
#   {
#     name: 'Hrana',
#     parent_id: buba.id
#   },
#   {
#     name: 'Igracke',
#     parent_id: buba.id
#   },
#   {
#     name: 'Veterinar',
#     parent_id: buba.id
#   },
#   {
#     name: 'Dostave',
#     parent_id: ostalo.id
#   },
#   {
#     name: 'Ducani',
#     parent_id: ostalo.id
#   },
#   {
#     name: 'Restorani',
#     parent_id: ostalo.id
#   }
# ])

# puts 'Child categories created'

# categories = Category.all.filter { |cat| !cat.sub_categories.any? }

# Area.create!([
#   {
#     name: 'Redovni troskovi'
#   },
#   {
#     name: 'Povremeni troskovi'
#   },
#   {
#     name: 'Godisnji'
#   },
#   {
#     name: 'Random area'
#   }
# ])

# puts 'Areas created'

# areas = Area.all.to_a

# days = (1..28).to_a
# months = (1..12).to_a
# years = (2010..2023).to_a
# amounts = (1..100).to_a + [54.72, 65.5, 3.6, 65.45, 8.47, 9.52, 7.15, 56.2, 5.58, 3.21, 7.40]

# 10_000.times do |i|
#   Expense.create!(
#     description: SecureRandom.hex.first(20),
#     amount: amounts.sample,
#     date: Date.new(years.sample, months.sample, days.sample),
#     category_id: categories.sample.id
#   )
#   puts "#{i}. expense created out of 10,000"
# end

# expenses = Expense.all.to_a

# 5_000.times do |j|
#   ExpensesArea.create!(
#     {
#       expense_id: expenses.sample.id,
#       area_id: areas.sample.id
#     }
#   )
#   puts "#{j}. expense_area created out of 5,000"
# end