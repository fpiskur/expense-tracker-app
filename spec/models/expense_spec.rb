# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expense, type: :model do
  context 'Validations' do
    subject do
      described_class.new(
        amount: 30,
        date: '2024-05-05',
        description: 'Burek',
        category: child_category
      )
    end

    let(:parent_category) { create(:category) }
    let(:child_category) { create(:category, parent_id: parent_category.id) }

    it 'is not valid without the amount' do
      subject.amount = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without the date' do
      subject.date = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without the description' do
      subject.description = nil
      expect(subject).to_not be_valid
    end

    it 'is not valid without the category' do
      subject.category = nil
      expect(subject).to_not be_valid
    end

    it 'is valid with valid arguments' do
      expect(subject).to be_valid
    end

    it "is not valid if parent category is selected instead of it's child" do
      subject.category = parent_category
      expect(subject).to_not be_valid
    end
  end

  context '.get_expenses_by_period' do
    before do
      create(:expense, date: '2024-02-05')
      create(:expense, date: '2024-03-05')
      create(:expense, date: '2024-03-08')
      create(:expense, date: '2024-03-12')
      create(:expense, date: '2024-04-12')
      create(:expense, date: '2025-04-12')
    end

    it 'returns the correct result for month period' do
      result = described_class.get_expenses_by_period('month', month: 3, year: 2024)
      expect(result.count).to eq 3
    end

    it 'returns the correct result for year period' do
      result = described_class.get_expenses_by_period('year', year: 2024)
      expect(result.count).to eq 5
    end

    it 'returns the results in the correct order for "ordered" option' do
      result = described_class.get_expenses_by_period('year', year: 2024, ordered: true)
      expect(result).to eq result.order(date: :desc, created_at: :desc)
    end
  end

  context '.get_expenses_by_area' do
    let(:first_area) { create(:area, name: 'First Area') }
    let(:second_area) { create(:area, name: 'Second Area') }

    before do
      create(:expense, amount: 10, date: '2024-01-23', area_ids: [first_area.id])
      create(:expense, amount: 20, date: '2024-01-25', area_ids: [first_area.id])
      create(:expense, amount: 5, date: '2024-02-12', area_ids: [first_area.id])
      create(:expense, amount: 45, date: '2024-03-04', area_ids: [first_area.id])
      create(:expense, amount: 25, date: '2024-03-14', area_ids: [first_area.id])

      create(:expense, amount: 25, date: '2024-01-03', area_ids: [second_area.id])
      create(:expense, amount: 35, date: '2024-01-23', area_ids: [second_area.id])
      create(:expense, amount: 100, date: '2024-05-11', area_ids: [second_area.id])
      create(:expense, amount: 10, date: '2024-05-16', area_ids: [second_area.id])
      create(:expense, amount: 15, date: '2024-08-20', area_ids: [second_area.id])

      create(:expense, amount: 300, date: '2025-06-23', area_ids: [second_area.id])
    end

    it 'returns the correct result for month' do
      result = described_class.get_expenses_by_area(month: 1, year: 2024)
      expect(result.keys).to eq([first_area.name, second_area.name])
      expect(result[first_area.name]).to eq(30)
      expect(result[second_area.name]).to eq(60)
    end

    it 'returns the correct result for year' do
      result = described_class.get_expenses_by_area(year: 2024)
      expect(result.keys).to eq([first_area.name, second_area.name])
      expect(result[first_area.name]).to eq(105)
      expect(result[second_area.name]).to eq(185)
    end

    it 'returns the correct result for all-time' do
      result = described_class.get_expenses_by_area
      expect(result.keys).to eq([first_area.name, second_area.name])
      expect(result[first_area.name]).to eq(105)
      expect(result[second_area.name]).to eq(485)
    end
  end

  context '.get_total_for_period' do
    let(:first_area) { create(:area, name: 'First Area') }
    let(:second_area) { create(:area, name: 'Second Area') }

    before do
      create(:expense, amount: 10, date: '2024-01-23', area_ids: [first_area.id])
      create(:expense, amount: 20, date: '2024-01-25', area_ids: [first_area.id])
      create(:expense, amount: 5, date: '2024-02-12', area_ids: [first_area.id])

      create(:expense, amount: 25, date: '2024-01-03', area_ids: [second_area.id])
      create(:expense, amount: 35, date: '2024-01-23', area_ids: [second_area.id])
      create(:expense, amount: 100, date: '2024-05-11', area_ids: [second_area.id])

      create(:expense, amount: 300, date: '2025-06-23', area_ids: [second_area.id])
    end

    it 'returns the correct result for month' do
      result = described_class.get_total_for_period(month: 1, year: 2024)
      expect(result).to eq(90)
    end

    it 'returns the correct result for year' do
      result = described_class.get_total_for_period(year: 2024)
      expect(result).to eq(195)
    end

    it 'returns the correct result for all-time' do
      result = described_class.get_total_for_period
      expect(result).to eq(495)
    end
  end

  context '.oldest_date' do
    it 'retutns the oldest date'
  end

  context '.newest_date' do
    it 'returns the newest date'
  end
end
