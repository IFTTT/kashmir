require 'test_helper'

describe Kashmir do

  module DSLTesting
    class Recipe < OpenStruct
      include Kashmir

      representations do
        rep(:num_steps)
        rep(:title)
        rep(:chef)
        rep(:ingredients)
      end
    end

    class Chef < OpenStruct
      include Kashmir

      representations do
        rep(:full_name)
      end

      def full_name
        "#{first_name} #{last_name}"
      end
    end

    class SimpleRecipeRepresenter
      include Kashmir::Dsl

      prop :num_steps
      prop :title
    end

    class ChefRepresenter
      include Kashmir::Dsl

      prop :full_name
    end

    class RecipeWithChefRepresenter
      include Kashmir::Dsl

      prop :title
      embed :chef, ChefRepresenter
    end
  end

  before do
    @chef    = DSLTesting::Chef.new(first_name: 'Netto', last_name: 'Farah')
    @brisket = DSLTesting::Recipe.new(title: 'BBQ Brisket', num_steps: 2, chef: @chef)
  end

  it 'translates to representation definitions' do
    definitions = DSLTesting::SimpleRecipeRepresenter.definitions
    assert_equal definitions, [:num_steps, :title]
  end

  it 'generates the same representations as hardcoded definitions' do
    cooked_brisket = @brisket.represent([:num_steps, :title])
    assert_equal cooked_brisket, { title: 'BBQ Brisket', num_steps: 2 }
    assert_equal cooked_brisket, @brisket.represent(DSLTesting::SimpleRecipeRepresenter.definitions)
  end

  it 'generates nested representations' do
    brisket_with_chef = @brisket.represent([:title, { :chef => [:full_name] }])
    assert_equal brisket_with_chef, {
      title: 'BBQ Brisket',
      chef: {
        full_name: 'Netto Farah'
      }
    }

    assert_equal brisket_with_chef, @brisket.represent(DSLTesting::RecipeWithChefRepresenter.definitions)
  end

  describe 'Nested inline representations' do

    module DSLTesting
      class RecipeWithInlineChefRepresenter
        include Kashmir::Dsl

        prop :title

        inline :chef do
          prop :full_name
        end
      end

      class Ingredient < OpenStruct
        include Kashmir

        representations do
          rep(:name)
          rep(:quantity)
        end
      end
    end

    it 'generates nested representations' do
      brisket_with_chef = @brisket.represent([:title, { :chef => [:full_name] }])
      assert_equal brisket_with_chef, {
        title: 'BBQ Brisket',
        chef: {
          full_name: 'Netto Farah'
        }
      }

      assert_equal brisket_with_chef, @brisket.represent(DSLTesting::RecipeWithInlineChefRepresenter.definitions)
    end
  end

  describe 'Collections' do
    module DSLTesting
      class RecipeWithIngredientsRepresenter
        include Kashmir::Dsl

        prop :title

        inline :ingredients do
          prop :name
          prop :quantity
        end
      end
    end

    it 'generates nested collections' do
      @brisket.ingredients = [
        DSLTesting::Ingredient.new(name: 'Beef', quantity: '8oz'),
        DSLTesting::Ingredient.new(name: 'BBQ Sauce', quantity: 'plenty!'),
      ]

      cooked_brisket = {
        title: 'BBQ Brisket',
        ingredients: [
          { name: 'Beef', quantity: '8oz' },
          { name: 'BBQ Sauce', quantity: 'plenty!' }
        ]
      }

      assert_equal cooked_brisket, @brisket.represent(DSLTesting::RecipeWithIngredientsRepresenter.definitions)
    end
  end
end
