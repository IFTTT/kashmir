require 'test_helper'

describe Kashmir::InlineDsl do

  module InlineDSLTesting
    class Recipe
      include Kashmir

      representations do
        rep(:num_steps)
        rep(:title)
        rep(:chef)
      end

      def initialize(title, num_steps, chef)
        @title = title 
        @num_steps = num_steps
        @chef = chef
      end
    end

    class Chef
      include Kashmir

      representations do
        rep(:full_name)
      end

      def initialize(first_name, last_name)
        @first_name = first_name 
        @last_name = last_name
      end

      def full_name
        "#{@first_name} #{@last_name}" 
      end
    end
  end

  before do
    @chef    = InlineDSLTesting::Chef.new('Netto', 'Farah')
    @brisket = InlineDSLTesting::Recipe.new('BBQ Brisket', 2, @chef)
  end

  it 'creates an inline representer' do
    inline_representer = Kashmir::InlineDsl.build do
      prop :num_steps
      prop :title
    end

    assert_equal inline_representer.definitions, [:num_steps, :title]

    cooked_brisket = @brisket.represent(inline_representer.definitions)
    assert_equal cooked_brisket, { title: 'BBQ Brisket', num_steps: 2 }
  end
end
