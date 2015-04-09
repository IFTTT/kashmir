require 'test_helper'

describe Kashmir do

  class Recipe < OpenStruct
    include Kashmir

    representations do
      base([:title, :preparation_time])
      rep(:num_steps, [:num_steps])
      rep(:chef)
    end

    def num_steps
      steps.size
    end
  end

  class Chef < OpenStruct
    include Kashmir

    representations do
      base([:name])
    end
  end

  before(:each) do
    @recipe = Recipe.new(title: 'Beef stew', preparation_time: 60)
    @chef = Chef.new(name: 'Netto')
  end

  it 'renders basic attribute representations' do
    assert_equal @recipe.represent, { title: 'Beef stew', preparation_time: 60 }
  end

  it 'renders basic calculated representations' do
    @recipe.steps = ['chop', 'cook']
    assert_equal @recipe.represent([:num_steps]), {
      title: 'Beef stew',
      preparation_time: 60,
      num_steps: 2
    }
  end

  it 'renders nested representations' do
    @recipe.chef = @chef
    representation = @recipe.represent([:chef])
    assert_equal representation[:chef], { name: 'Netto' }
  end
end

describe 'Complex Representations' do
  class BBQRecipe < OpenStruct
    include Kashmir

    representations do
      base([:title])
      rep(:chef)
    end
  end

  class BBQChef < OpenStruct
    include Kashmir

    representations do
      base([:name])
      rep(:restaurant)
    end
  end

  class BBQRestaurant < OpenStruct
    include Kashmir

    representations do
      base([:name])
      rep(:rating)
    end
  end

  before do
    @bbq_joint = BBQRestaurant.new(name: "Netto's BBQ Joint", rating: '5 stars')
    @netto = BBQChef.new(name: 'Netto', restaurant: @bbq_joint)
    @brisket = BBQRecipe.new(title: 'BBQ Brisket', chef: @netto)
  end

  it 'works with base representations' do
    assert_equal @netto.represent,     { name: 'Netto' }
    assert_equal @brisket.represent,   { title: 'BBQ Brisket' }
    assert_equal @bbq_joint.represent, { name: "Netto's BBQ Joint" }
  end

  it 'works with simple nesting' do
    representation = @netto.represent([:restaurant])
    assert_equal representation, {
      name: 'Netto',
      restaurant: { name: "Netto's BBQ Joint" }
    }
  end

  it 'allows clients to customize nested representations' do
    representation = @netto.represent [{ :restaurant => [:rating] }]

    assert_equal representation, {
      name: 'Netto',
      restaurant: { name: "Netto's BBQ Joint", rating: '5 stars' }
    }
  end

  it 'allows clients to create complex representation trees' do
    representation = @brisket.represent([
      :chef => [
        { :restaurant => [ :rating ] }
      ]
    ])

    assert_equal representation, {
      title: 'BBQ Brisket',
      chef: {
        name: 'Netto',
        restaurant: {
          name: "Netto's BBQ Joint",
          rating: '5 stars'
        }
      }
    }
  end
end

describe 'Collections' do

  class Ingredient < OpenStruct
    include Kashmir

    representations do
      rep(:name)
      rep(:quantity)
    end
  end

  class ClassyRecipe < OpenStruct
    include Kashmir

    representations do
      rep(:title)
      rep(:ingredients)
    end
  end

  before(:each) do
    @omelette = ClassyRecipe.new(title: 'Omelette Du Fromage')
    @omelette.ingredients = [
      Ingredient.new(name: 'Egg', quantity: 2),
      Ingredient.new(name: 'Cheese', quantity: 'a lot!')
    ]
  end

  it 'represents collections' do
    nice_omelette = @omelette.represent([:title, { :ingredients => [ :name, :quantity ]}])

    assert_equal nice_omelette, {
      title: 'Omelette Du Fromage',
      ingredients: [
        { name: 'Egg', quantity: 2 },
        { name: 'Cheese', quantity: 'a lot!' }
      ]
    }
  end
end
