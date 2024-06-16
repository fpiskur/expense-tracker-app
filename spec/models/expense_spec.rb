# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Expense, type: :model do
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
