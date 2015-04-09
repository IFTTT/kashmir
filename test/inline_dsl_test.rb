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
        rep(:award)
      end

      def initialize(first_name, last_name, award)
        @first_name = first_name
        @last_name = last_name
        @award = award
      end

      def full_name
        "#{@first_name} #{@last_name}"
      end
    end

    class Award
      include Kashmir

      representations do
        base([:name, :year])
      end

      def initialize(name, year)
        @name = name
        @year = year
      end
    end
  end

  before do
    @award   = InlineDSLTesting::Award.new('Best Chef', 2015)
    @chef    = InlineDSLTesting::Chef.new('Netto', 'Farah', @award)
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

  describe 'Reduced syntax' do

    describe '#represent_with' do
      it 'works with flat representers' do
        cooked_brisket = @brisket.represent_with do
          prop :title
          prop :num_steps
        end

        assert_equal cooked_brisket, { title: 'BBQ Brisket', num_steps: 2 }
      end

      it 'works with nested representers' do
        cooked_brisket = @brisket.represent_with do
          prop :title
          prop :num_steps

          inline :chef do
            prop :full_name
          end
        end

        assert_equal cooked_brisket, {
          title: 'BBQ Brisket',
          num_steps: 2,
          chef: {
            full_name: 'Netto Farah'
          }
        }
      end
    end

    it 'works with multi level nested representers' do
      cooked_brisket = @brisket.represent_with do
        prop :title
        inline :chef do
          prop :full_name
          inline :award
        end
      end

      assert_equal cooked_brisket, {
        title: 'BBQ Brisket',
        chef: {
          full_name: 'Netto Farah',
          award: {
            name: 'Best Chef', year: 2015
          }
        }
      }
    end
  end
end
