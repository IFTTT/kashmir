require 'ar_test_helper'
require 'byebug'

# see support/ar_models for model definitions

describe 'ActiveRecord integration' do

  before(:each) do
    @tom = AR::Chef.create(name: 'Tom')

    @pastrami_sandwich = AR::Recipe.create(title: 'Pastrami Sandwich', chef: @tom)
    @belly_burger = AR::Recipe.create(title: 'Belly Burger', chef: @tom)

    @restaurant = AR::Restaurant.create(name: 'Chef Tom Belly Burgers', owner: @tom)
  end

  it 'represents ar objects' do
    ps = @pastrami_sandwich.represent_with do
      prop :title
    end

    assert_equal ps, { title: 'Pastrami Sandwich' }
  end

  describe 'belongs_to' do
    it 'works for basic relations' do
      ps = @pastrami_sandwich.represent_with do
        prop :title
        inline :chef do
          prop :name
        end
      end

      assert_equal ps, {
        title: 'Pastrami Sandwich',
        chef: {
          name: 'Tom'
        }
      }
    end

    it 'works with custom names' do
      r = @restaurant.represent_with do
        prop :name
        inline :owner do
          prop :name
        end
      end

      assert_equal r, {
        name: 'Chef Tom Belly Burgers',
        owner: {
          name: 'Tom'
        }
      }
    end
  end

  describe 'has_many' do
    it 'works for basic relations' do
      t = @tom.represent_with do
        prop :name
        inline :recipes do
          prop :title
        end
      end

      assert_equal t, {
        name: 'Tom',
        recipes: [
          { title: 'Pastrami Sandwich' },
          { title: 'Belly Burger'}
        ]
      }
    end
  end
end
