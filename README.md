# Kashmir

Kashmir is a DSL built to allow developers to describe representations of Ruby objects.
Kashmir will turn these Ruby objects into hashes that represent the dependency tree you just described.

`Kashmir::ActiveRecord` will also optimize and try to balance `ActiveRecord` queries so your application hits the database as little as possible.

`Kashmir::Caching` builds a dependency tree for complex object representations and caches each level of this tree separately. Kashmir will do so by creating cache views of each level as well as caching a complete tree.
The caching engine is smart enough to fill holes in the cache tree with fresh data from your data store.

Combine `Kashmir::Caching` + `Kashmir::ActiveRecord` for extra awesomeness.

### Example:

For example, a `Person` with `name` and `age` attributes:
```ruby
  class Person
    include Kashmir
    
    def initialize(name, age)
      @name = name
      @age = age
    end
    
    representations do
      rep :name
      rep :age
    end
  end
```
could be represented as:
```
{ name: 'Netto Farah', age: 26 }
```

Representing an object is as simple as:

1. Add `include Kashmir` to the target class.
2. Whitelist all the fields you want to include in a representation.

```ruby
# Add fields and methods you want to be visible to Kashmir
representations do
  rep(:name)
  rep(:age)
end
```

3. Instantiate an object and `#represent` it.
```ruby
# Pass in an array with all the fields you want included
Person.new('Netto Farah', 26).represent([:name, :age]) 
 => {:name=>"Netto Farah", :age=>"26"} 
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kashmir'
```

And then execute:

    $ bundle

## Usage
Kashmir is better described with examples.

### Basic Representations

#### Describing an Object
Only whitelisted fields can be represented by Kashmir.
This is done so sensitive fields (like passwords) cannot be accidentally exposed to clients.

``` ruby
class Recipe < OpenStruct
  include Kashmir

  representations do
    rep(:title)
    rep(:preparation_time)
  end
end
```

Instantiate a `Recipe`:
```ruby
recipe = Recipe.new(title: 'Beef Stew', preparation_time: 60)
```

Kashmir automatically adds a `#represent` method to every instance of `Recipe`.
`#represent` takes an `Array` with all the fields you want as part of your representation.

```ruby
recipe.represent([:title, :preparation_time])
=> { title: 'Beef Stew', preparation_time: 60 }
```
#### Calculated Fields
You can represent any instance variable or method (basically anything that returns `true` for `respond_to?`).
``` ruby
class Recipe < OpenStruct
  include Kashmir

  representations do
    rep(:title)
    rep(:num_steps)
  end
  
  def num_steps
    steps.size
  end
end
```

```ruby
Recipe.new(title: 'Beef Stew', steps: ['chop', 'cook']).represent([:title, :num_steps])
=> { title: 'Beef Stew', num_steps: 2 }
```

### Nested Representations
You can nest Kashmir objects to represent complex relationships between your objects.
```ruby
class Recipe < OpenStruct
  include Kashmir

  representations do
    rep(:title)
    rep(:chef)
  end
end

class Chef < OpenStruct
  include Kashmir

  representations do
    base([:name])
  end
end
```

When you create a representation, nest hashes to create nested representations.
```ruby
netto = Chef.new(name: 'Netto Farah')
beef_stew = Recipe.new(title: 'Beef Stew', chef: netto)

beef_stew.represent([:title, { :chef => [ :name ] }])
=> {
  :title => "Beef Stew",
  :chef => {
    :name => 'Netto Farah'
  }
}
```
Not happy with this syntax? Check out `Kashmir::DSL` or `Kashmir::InlineDSL` for prettier code.

#### Base Representations
Are you tired of repeating the same fields over and over?
You can create a base representation of your objects, so Kashmir returns basic fields automatically.
```ruby
class Recipe
  include Kashmir
  
  representations do
    base [:title, :preparation_time]
    rep :num_steps
    rep :chef
  end
end
```
`base(...)` takes an array with the fields you want to return on every representation of a given class.

```ruby
brisket = Recipe.new(title: 'BBQ Brisket', preparation_time: 'a long time')
brisket.represent()
=> { :title => 'BBQ Brisket', :preparation_time => 'a long time' }
```

### Complex Representations
You can nest as many Kashmir objects as you want.
```ruby
class Recipe < OpenStruct
  include Kashmir

  representations do
    base [:title]
    rep :chef
  end
end

class Chef < OpenStruct
  include Kashmir

  representations do
    base :name
    rep :restaurant
  end
end

class Restaurant < OpenStruct
  include Kashmir

  representations do
    base [:name]
    rep :rating
  end
end
```

```ruby
bbq_joint = Restaurant.new(name: "Netto's BBQ Joint", rating: '5 Stars')
netto = Chef.new(name: 'Netto', restaurant: bbq_joint)
brisket = Recipe.new(title: 'BBQ Brisket', chef: netto)

brisket.represent([
  :chef => [
    { :restaurant => [ :rating ] }
  ]
])

=> {
  title: 'BBQ Brisket',
  chef: {
    name: 'Netto',
    restaurant: {
      name: "Netto's BBQ Joint",
      rating: '5 Stars'
    }
  }
}

```


### Collections
Arrays of Kashmir objects work the same way as any other Kashmir representations.
Kashmir will augment `Array` with `#represent` that will represent every item in the array.

```ruby
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
```
```ruby
omelette = ClassyRecipe.new(title: 'Omelette Du Fromage')
omelette.ingredients = [
  Ingredient.new(name: 'Egg', quantity: 2),
  Ingredient.new(name: 'Cheese', quantity: 'a lot!')
]
```
Just describe your `Array` representations like any regular nested representation.
```ruby
omelette.represent([:title, { 
    :ingredients => [ :name, :quantity ]
  }
])
```
```ruby
=> {
  title: 'Omelette Du Fromage',
  ingredients: [
    { name: 'Egg', quantity: 2 },
    { name: 'Cheese', quantity: 'a lot!' }
  ]
}
```
### `Kashmir::Dsl`
Passing arrays and hashes around can be very tedious and lead to duplication.
`Kashmir::Dsl` allows you to create your own representers/decorators so you can keep your logic in one place and make way more expressive.

```ruby
class Recipe < OpenStruct
  include Kashmir

  representations do
    rep(:title)
    rep(:num_steps)
  end
end

class RecipeRepresenter
  include Kashmir::Dsl

  prop :title
  prop :num_steps
end
```

All you need to do is include `Kashmir::Dsl` in any ruby class. Every call to `prop(field_name)` will translate directly into just adding an extra field in the representation array.


In this case, `RecipeRepresenter` will translate directly to `[:title, :num_steps]`.

```ruby
brisket = Recipe.new(title: 'BBQ Brisket', num_steps: 2)
brisket.represent(RecipePresenter)

=>  { title: 'BBQ Brisket', num_steps: 2 }
```
#### Embedded Representers
It is also possible to define nested representers with `embed(:property_name, RepresenterClass)`.

```ruby
class RecipeWithChefRepresenter
  include Kashmir::Dsl

  prop :title
  embed :chef, ChefRepresenter
end

class ChefRepresenter
  include Kashmir::Dsl
  
  prop :full_name
end
```
Kashmir will inline these classes and return a raw Kashmir description.
```ruby
RecipeWithChefRepresenter.definitions == [ :title, { :chef => [ :full_name ] }]
=> true
```
Representing the objects will work just as before.
```ruby
chef = Chef.new(first_name: 'Netto', last_name: 'Farah')
brisket = Recipe.new(title: 'BBQ Brisket', chef: chef)

brisket.represent(RecipeWithChefRepresenter)
 
=> {
  title: 'BBQ Brisket',
  chef: {
    full_name: 'Netto Farah'
  }
}
```
#### Inline Representers
You don't necessarily need to define a class for every nested representation.
```ruby
class RecipeWithInlineChefRepresenter
  include Kashmir::Dsl

  prop :title

  inline :chef do
    prop :full_name
  end
end
```
Using `inline(:property_name, &block)` will work the same way as `embed`. Except that you can now define short representations using ruby blocks. Leading us to our next topic.

### `Kashmir::InlineDsl`
`Kashmir::InlineDsl` sits right in between raw representations and Representers. It reads much better than arrays of hashes and provides the expressiveness of `Kashmir::Dsl` without all the ceremony.

It works with every feature from `Kashmir::Dsl` and allows you to define quick inline descriptions for your `Kashmir` objects.

```ruby
class Recipe < OpenStruct
  include Kashmir

  representations do
    rep(:title)
    rep(:num_steps)
  end
end
```
Just call `#represent_with(&block)` on any `Kashmir` object and use the `Kashmir::Dsl` syntax.
```ruby
brisket = Recipe.new(title: 'BBQ Brisket', num_steps: 2)

brisket.represent_with do
  prop :title
  prop :num_steps
end

=> { title: 'BBQ Brisket', num_steps: 2 }
```

#### Nested Inline Representations
You can nest inline representations using `inline(:field, &block)` the same way we did with `Kashmir::Dsl`.

```ruby
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
```
```ruby
omelette = ClassyRecipe.new(title: 'Omelette Du Fromage')
omelette.ingredients = [
  Ingredient.new(name: 'Egg', quantity: 2),
  Ingredient.new(name: 'Cheese', quantity: 'a lot!')
]
```
Just call `#represent_with(&block)` and start nesting other inline representations.
```ruby
omelette.represent_with do
  prop :title
  inline :ingredients do
    prop :name
    prop :quantity
  end
end

=> {
  title: 'Omelette Du Fromage',
  ingredients: [
    { name: 'Egg', quantity: 2 },
    { name: 'Cheese', quantity: 'a lot!' }
  ]
}
```

Inline representations can become lengthy and confusing over time.
If you find yourself nesting more than two levels or including more than 3 or 4 fields per level consider creating Representers with `Kashmir::Dsl`.

### `Kashmir::ActiveRecord`
Kashmir works just as well with ActiveRecord. `ActiveRecord::Relation`s can be used as Kashmir representations just as any other classes.

Kashmir will attempt to preload every `ActiveRecord::Relation` defined as representations automatically by using `ActiveRecord::Associations::Preloader`. This will guarantee that you don't run into N+1 queries while representing collections and dependent objects.

Here's an example of how Kashmir will attempt to optimize database queries:

```ruby
ActiveRecord::Schema.define do
  create_table :recipes, force: true do |t|
    t.column :title, :string
    t.column :num_steps, :integer
    t.column :chef_id, :integer
  end
  
  create_table :chefs, force: true do |t|
    t.column :name, :string
  end
end
```
```ruby
module AR
  class Recipe < ActiveRecord::Base
    include Kashmir

    belongs_to :chef

    representations do
      rep :title
      rep :chef
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
```

```ruby
AR::Chef.all.each do |chef|
  chef.recipes.to_a
end
```
will generate
```sql
SELECT * FROM chefs
SELECT "recipes".* FROM "recipes" WHERE "recipes"."chef_id" = ?
SELECT "recipes".* FROM "recipes" WHERE "recipes"."chef_id" = ?
```

With Kashmir:
```ruby
AR::Chef.all.represent([:recipes])
```
```sql
SELECT "chefs".* FROM "chefs"
SELECT "recipes".* FROM "recipes" WHERE "recipes"."chef_id" IN (1, 2)
```

For more examples, check out: https://github.com/IFTTT/kashmir/blob/master/test/activerecord_tricks_test.rb

### `Kashmir::Caching` (Experimental)
Caching is the best feature in Kashmir.
The `Kashmir::Caching` module will cache every level of the dependency tree Kashmir generates when representing an object.

![Dependency Tree](https://raw.githubusercontent.com/IFTTT/kashmir/screenshots/screenshots/kashmir.png?token=AAQhYDZTL7oXvpg_XICV4Hs_oDsbOXaLks5VuQVKwA%3D%3D "Dependency Tree")

As you can see in the image above, Kashmir will build a dependency tree of the representation.
If you have Caching on, Kashmir will:

- Build a cache key for each individual object (green)
- Wrap complex dependencies into their on cache key (blue and pink)
- Wrap the whole representation into one unique cache key (red)

Each layer gets its own cache keys which can be expired at different times.
Kashmir will also be able to fill in blanks in the dependency tree and fetch missing objects individually.

Caching is turned off by default, but you can use one of the two available implementations.

- [In Memory Caching] https://github.com/IFTTT/kashmir/blob/master/lib/kashmir/plugins/memory_caching.rb
- [Memcached] https://github.com/IFTTT/kashmir/blob/master/lib/kashmir/plugins/memcached_caching.rb

You can also build your own custom caching engine by following the `NullCaching` protocol available at:
https://github.com/IFTTT/kashmir/blob/master/lib/kashmir/plugins/null_caching.rb

#### Enabling `Kashmir::Caching`
##### In Memory
```ruby
Kashmir.init(
  cache_client: Kashmir::Caching::Memory.new
)
```

##### With Memcached
```ruby
require 'kashmir/plugins/memcached_caching'

client = Dalli::Client.new(url, namespace: 'kashmir', compress: true)
default_ttl = 5.minutes

Kashmir.init(
  cache_client: Kashmir::Caching::Memcached.new(client, default_ttl)
)
```

For more advanced examples, check out: https://github.com/IFTTT/kashmir/blob/master/test/caching_test.rb

## Contributing

1. Fork it ( https://github.com/[my-github-username]/kashmir/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


