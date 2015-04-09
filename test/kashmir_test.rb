require 'test_helper'

describe Kashmir do

  class Recipe
    include Kashmir

    representations do
      base([:title])
    end

    def initialize(title)
      @title = title 
    end
  end

  it 'renders basic attribute representations' do
    recipe = Recipe.new('Beef stew')
    assert_equal recipe.represent, { title: 'Beef stew' }
  end
end
