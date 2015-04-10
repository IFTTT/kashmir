require 'ar_test_helper'

describe 'ActiveRecord performance tricks' do

  before(:each) do
    @tom = AR::Chef.create(name: 'Tom')

    @pastrami_sandwich = AR::Recipe.create(title: 'Pastrami Sandwich', chef: @tom)
    @pastrami_sandwich.ingredients.create(name: 'Pastrami', quantity: 'a lot')
    @pastrami_sandwich.ingredients.create(name: 'Cheese', quantity: '1 slice')

    @belly_burger = AR::Recipe.create(title: 'Belly Burger', chef: @tom)
    @belly_burger.ingredients.create(name: 'Pork Belly', quantity: 'plenty')
    @belly_burger.ingredients.create(name: 'Green Apple', quantity: '2 slices')

    @restaurant = AR::Restaurant.create(name: 'Chef Tom Belly Burgers', owner: @tom)

    @netto = AR::Chef.create(name: 'Netto')
    @turkey_sandwich = AR::Recipe.create(title: 'Turkey Sandwich', chef: @netto)
    @turkey_sandwich.ingredients.create(name: 'Turkey', quantity: 'a lot')
    @turkey_sandwich.ingredients.create(name: 'Cheese', quantity: '1 slice')

    @cheese_burger = AR::Recipe.create(title: 'Cheese Burger', chef: @netto)
    @cheese_burger.ingredients.create(name: 'Patty', quantity: '1')
    @cheese_burger.ingredients.create(name: 'Cheese', quantity: '2 slices')

    @selects = []
  end

  def loop_through_chefs(chefs)
    AR::Chef.where(id: chefs.map(&:id)).each do |chef|
      chef.recipes.each do |rec|
        rec.ingredients.each do |ing|
          ing.name
        end
      end
    end
  end

  def queries_collector
    lambda do |name, start, finish, id, payload|
      @selects << payload
    end
  end

  def clear_query_cache
    @selects = []
    ActiveRecord::Base.connection.clear_query_cache
  end

  def track_queries
    clear_query_cache
    ActiveSupport::Notifications.subscribed(queries_collector, 'sql.active_record') do
      yield
    end
  end

  it 'tries to preload records whenever possible' do
    track_queries do
      loop_through_chefs [@tom, @netto]
    end
    assert_equal 7, @selects.size

    track_queries do
      AR::Chef.where(id: @tom.id..@netto.id).represent([:recipes => [ :ingredients => [:name] ]])
    end

    assert_equal 4, @selects.size
  end
end
