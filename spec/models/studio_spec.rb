require 'rails_helper'

RSpec.describe Studio, type: :model do
  # ensure Todo model has a 1:m relationship with the Item model
  # it { should have_many(:items).dependent(:destroy) }
  # it { should belong_to(:todo) }
  it { should validate_presence_of(:name) }
end
