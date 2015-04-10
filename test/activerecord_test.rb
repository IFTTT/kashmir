require 'ar_test_helper'

# see support/ar_models for model definitions

describe 'ActiveRecord integration' do

  before(:each) do
    @tom = AR::Chef.create(name: 'Tom')

    @pastrami_sandwich = AR::Recipe.create(title: 'Pastrami Sandwich', chef: @tom)

    @pastrami_sandwich.ingredients.create(name: 'Pastrami', quantity: 'a lot')
    @pastrami_sandwich.ingredients.create(name: 'Cheese', quantity: '1 slice')

    @belly_burger = AR::Recipe.create(title: 'Belly Burger', chef: @tom)
    @belly_burger.ingredients.create(name: 'Pork Belly', quantity: 'plenty')
    @belly_burger.ingredients.create(name: 'Green Apple', quantity: '2 slices')

    @restaurant = AR::Restaurant.create(name: 'Chef Tom Belly Burgers', owner: @tom)
  end

  it 'represents ar objects' do
    ps = @pastrami_sandwich.represent_with do
      prop :title
    end

    assert_equal ps, { title: 'Pastrami Sandwich' }
  end

  describe 'ActiveRecord::Relation' do
    it 'represents relations' do
      recipes = AR::Recipe.all.represent_with do
        prop :title
      end

      assert_equal recipes, [
        { title: 'Pastrami Sandwich' },
        { title: 'Belly Burger' }
      ]
    end

    it 'represents nested relations' do
      recipes = AR::Recipe.all.represent_with do
        prop :title
        inline :ingredients do
          prop :name
        end
      end

      assert_equal recipes, [
        {
          title: 'Pastrami Sandwich',
          ingredients: [ { name: 'Pastrami' }, { name: 'Cheese' } ]
        },
        {
          title: 'Belly Burger',
          ingredients: [ {name: 'Pork Belly'}, { name: 'Green Apple' } ]
        }
      ]
    end
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
    it 'works for basic associations' do
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

    it 'works with :through associations' do
      tom_with_ingredients = @tom.reload.represent_with do
        prop :name
        inline :ingredients do
          prop :name
          prop :quantity
        end
      end

      assert_equal tom_with_ingredients, {
        name: 'Tom',
        ingredients: [
          { name: 'Pastrami'    , quantity: 'a lot'    },
          { name: 'Cheese'      , quantity: '1 slice'  },
          { name: 'Pork Belly'  , quantity: 'plenty'   },
          { name: 'Green Apple' , quantity: '2 slices' }
        ]
      }
    end
  end
end
