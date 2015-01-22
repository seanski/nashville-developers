require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many :authorizations }
    it { should have_many :skills }
  end
end
