require 'ar_test_helper'

# see support/ar_models for model definitions

describe 'ActiveRecord integration' do

  before(:each) do
    @pastrami_sandwich = AR::Recipe.create(title: 'Pastrami Sandwich')
  end

  it 'represents ar objects' do
    ps = @pastrami_sandwich.represent_with do
      prop :title
    end
    assert_equal ps, { title: 'Pastrami Sandwich' }
  end
end
