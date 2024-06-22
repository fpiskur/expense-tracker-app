# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  context 'Validations' do
    subject { described_class.new(name: 'New Category') }

    let(:parent_category) { create(:category, name: 'Parent Category') }
    let(:another_parent_category) { create(:category, name: 'Another Parent Category') }

    before do
      create(:category, name: subject.name, parent_category: parent_category)
    end

    it 'is valid with valid arguments & no parent' do
      expect(subject).to be_valid
    end

    it 'is valid with valid arguments & parent category' do
      subject.parent_category = another_parent_category
      expect(subject).to be_valid
    end

    it 'is not valid without the name' do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it 'is not valid without a unique name within parent scope' do
      subject.parent_category = parent_category
      expect(subject).not_to be_valid
    end

    it 'is not valid without a unique name within root scope' do
      subject.name = parent_category.name
      expect(subject).not_to be_valid
    end
  end

  context 'Scopes' do
    before do
      2.times do
        create(:category)
      end
    end

    it 'returns correct result for .parent_categories scope' do
      expect(described_class.parent_categories.count).to eq(2)
    end
  end
end
