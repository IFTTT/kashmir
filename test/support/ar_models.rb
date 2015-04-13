module AR
  class Recipe < ActiveRecord::Base
    include Kashmir

    belongs_to :chef
    has_many :recipes_ingredients
    has_many :ingredients, through: :recipes_ingredients

    representations do
      rep :title
      rep :chef
      rep :ingredients
    end
  end

  class Ingredient < ActiveRecord::Base
    include Kashmir

    representations do
      rep :name
      rep :quantity
    end
  end

  class RecipesIngredient < ActiveRecord::Base
    belongs_to :recipe
    belongs_to :ingredient
  end

  class Restaurant < ActiveRecord::Base
    include Kashmir

    belongs_to :owner, class_name: 'Chef'

    representations do
      rep :name
      rep :owner
    end
  end

  class Chef < ActiveRecord::Base
    include Kashmir

    has_many :recipes
    has_many :ingredients, through: :recipes

    representations do
      rep :name
      rep :recipes
      rep :ingredients
    end
  end
end

