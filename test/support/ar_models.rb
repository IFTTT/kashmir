module AR
  class Recipe < ActiveRecord::Base
    include Kashmir

    representations do
      rep :title
    end
  end

  class Ingredient < ActiveRecord::Base
  end

  class RecipeIngredient
  end

  class Chef < ActiveRecord::Base
  end
end
