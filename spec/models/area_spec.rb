# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Area, type: :model do
  context 'Validations' do
    subject { described_class.new(name: 'New Area') }

    it 'is valid with valid arguments' do
      expect(subject).to be_valid
    end

    it 'is not valid without a name' do
      subject.name = nil
      expect(subject).not_to be_valid
    end
  end
end
