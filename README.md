# Kashmir

Kashmir is a DSL built to allow developers to describe representations of their ruby objects.
Kashmir will turn these ruby objects into `Hash`es that represent the dependency tree you just described.

`Kashmir::ActiveRecord` will also optimize and try to balance `ActiveRecord` queries, so your application hits the database as little as possible.

`Kashmir::Caching` builds a dependency tree for complex object representations and caches each level of this tree separately. Kashmir will do so by creating cache views of each one of these layers, but also caching a complete tree.
The caching engine is smart enough to fill out holes in the cache tree with fresh data from your database or another sort of data store.

Combine `Kashmir::Caching` + `Kashmir::ActiveRecord` for extra awesomeness.

### Example:

For example, a `Person` with a `name` and `age`:
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
1. add `include Kashmir` to the target class
2. whitelist all the fields you may want in a representation.
```ruby
# add all the fields, methods you want to be visible to Kashmir
representations do
  rep(:name) # this exposes the property name to Kashmir
  rep(:age)
end
```
3. Instantiate an object and `#represent` it.
```ruby
# you can pass in an array with all the fields you want to be represented
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

### Basic representations

#### Describing an object
Only whitelisted fields can be represented by Kashmir.
This is done so secret fields don't get exposed to clients, such as passwords and salts.

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
recipe = Recipe.new(title: 'Beef stew', preparation_time: 60)
```

Kashmir automatically adds a `#represent` method to every instance of `Recipe` now.
`#represent` will take an `Array` with all the fields you want as part of your representation.

```ruby
recipe.represent([:title, :preparation_time])
=> { title: 'Beef stew', preparation_time: 60 }
```
#### Calculated fields
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
Recipe.new(title: 'Beef stew', steps: ['chop', 'cook']).represent([:title, :num_steps])
=> { title: 'Beef stew', num_steps: 2 }
```

### Nested representations
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

Nested representations can be described as hashes inside your array of fields.
You can then pass in another array with all the properties you want to present in the nested object.
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

#### Base representations
Tired of repeating the same fields over and over?
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
bbq_joint = Restaurant.new(name: "Netto's BBQ Joint", rating: '5 stars')
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
      rating: '5 stars'
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
#### Embed Representers
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

#### Nested inline representations
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
TODO: write description
### `Kashmir::Caching`
TODO: write description

## Contributing

1. Fork it ( https://github.com/[my-github-username]/kashmir/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

