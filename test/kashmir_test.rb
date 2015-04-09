require 'test_helper'

describe Kashmir do

  class Recipe
    include Kashmir

    representations do
      base([:title, :preparation_time])
      rep(:num_steps, [:num_steps])
      rep(:chef)
    end

    def initialize(title, preparation_time, steps=[], chef=nil)
      @title = title 
      @preparation_time = preparation_time
      @steps = steps
      @chef = chef
    end

    def num_steps
      @steps.size
    end
  end

  class Chef
    include Kashmir

    representations do
      base([:name])
    end

    def initialize(name)
      @name = name
    end
  end

  it 'renders basic attribute representations' do
    recipe = Recipe.new('Beef stew', 60)
    assert_equal recipe.represent, { title: 'Beef stew', preparation_time: 60 }
  end

  it 'renders basic calculated representations' do
    recipe = Recipe.new('Beef stew', 60, ['chop', 'cook'])

    assert_equal recipe.represent([:num_steps]), { 
      title: 'Beef stew', 
      preparation_time: 60, 
      num_steps: 2 
    }
  end

  it 'renders nested representations' do
    chef = Chef.new('Netto')
    recipe = Recipe.new('Beef Stew', 60, [], chef)

    representation = recipe.represent([:chef])
    assert_equal representation[:chef], { name: 'Netto' }
  end
end

describe 'Complex Representations' do
  class BBQRecipe
    include Kashmir

    representations do
      base([:title])
      rep(:chef)
    end

    def initialize(title, chef)
      @title = title
      @chef = chef
    end
  end

  class BBQChef
    include Kashmir

    representations do
      base([:name])
      rep(:restaurant)
    end

    def initialize(name, restaurant)
      @name = name
      @restaurant = restaurant
    end
  end

  class BBQRestaurant
    include Kashmir

    representations do
      base([:name])
      rep(:rating)
    end

    def initialize(name, rating)
      @name = name
      @rating = rating
    end
  end

  before do
    @bbq_joint = BBQRestaurant.new("Netto's BBQ Joint", '5 stars')
    @netto = BBQChef.new('Netto', @bbq_joint)
    @brisket = BBQRecipe.new('BBQ Brisket', @netto)
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
