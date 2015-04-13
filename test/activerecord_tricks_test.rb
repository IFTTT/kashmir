require 'ar_test_helper'

describe 'ActiveRecord performance tricks' do

  before(:all) do
    TestData.create_tom
    TestData.create_netto
  end

  def track_queries
    selects = []
    queries_collector = lambda do |name, start, finish, id, payload|
      selects << payload
    end

    ActiveRecord::Base.connection.clear_query_cache
    ActiveSupport::Notifications.subscribed(queries_collector, 'sql.active_record') do
      yield
    end

    selects
  end

  describe "Query preload to avoid N+1 queries" do

    it 'tries to preload records whenever possible' do
      selects = track_queries do
        AR::Chef.all.each do |chef|
          chef.recipes.to_a
        end
      end
      # SELECT * FROM chefs
      # SELECT "recipes".* FROM "recipes" WHERE "recipes"."chef_id" = ?
      # SELECT "recipes".* FROM "recipes" WHERE "recipes"."chef_id" = ?
      assert_equal 3, selects.size

      selects = track_queries do
        AR::Chef.all.represent([:recipes])
      end
      # SELECT "chefs".* FROM "chefs"
      # SELECT "recipes".* FROM "recipes" WHERE "recipes"."chef_id" IN (1, 2)
      assert_equal 2, selects.size
    end

    it 'preloads queries per each level in the tree' do
      selects = track_queries do
        AR::Chef.all.each do |chef|
          chef.recipes.each do |recipe|
            recipe.ingredients.to_a
          end
        end
      end
      # SELECT "chefs".* FROM "chefs"
      # (2x) SELECT "recipes".* FROM "recipes" WHERE "recipes"."chef_id" = ?
      # (4x) SELECT "ingredients".* FROM "ingredients" INNER JOIN "recipes_ingredients" ...
      assert_equal 7, selects.size

      selects = track_queries do
        AR::Chef.all.represent([ :recipes => [ :ingredients => [:name] ] ])
      end
      # SELECT "chefs".* FROM "chefs"
      # SELECT "recipes".* FROM "recipes" WHERE "recipes"."chef_id" IN (1, 2)
      # SELECT "recipes_ingredients".* FROM "recipes_ingredients" WHERE "recipes_ingredients"."recipe_id" IN (1, 2, 3, 4)
      # SELECT "ingredients".* FROM "ingredients" WHERE "ingredients"."id" IN (1, 2, 3, 4, 5, 6, 7, 8)
      assert_equal 4, selects.size
    end
  end
end
