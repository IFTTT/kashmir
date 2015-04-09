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
