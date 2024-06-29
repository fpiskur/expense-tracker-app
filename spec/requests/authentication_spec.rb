# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) { create(:user) }
  it 'should redirect to login page' do
    get root_path
    expect(response).to redirect_to new_user_session_path
  end

  it 'should respond with the requested page for logged in user' do
    sign_in user
    get root_path
    expect(response.status).to eq(200)
  end
end
