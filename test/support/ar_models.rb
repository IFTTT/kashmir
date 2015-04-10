module AR
  class Recipe < ActiveRecord::Base
    include Kashmir

    belongs_to :chef

    representations do
      rep :title
      rep :chef
    end
  end

  class Ingredient < ActiveRecord::Base
  end

  class RecipeIngredient
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

    representations do
      rep :name
      rep :recipes
    end
  end
end
