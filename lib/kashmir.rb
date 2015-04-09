require "kashmir/version"
require "kashmir/representation"
require "kashmir/dsl"
require "kashmir/inline_dsl"

module Kashmir

  def self.included(klass)
    klass.extend ClassMethods
  end

  def represent(representation_definition=[])
    representation = {}
    representation_definition << :base if self.class.definitions.include?(:base)

    representation_definition.each do |representation_definition|
      key, arguments = parse_definition(representation_definition)

      represented_document = self.class.definitions[key].run_for(self, arguments)
      representation = representation.merge(represented_document)
    end

    representation
  end

  def parse_definition(representation_definition)
    if representation_definition.is_a?(Symbol)
      [ representation_definition, [] ]
    elsif representation_definition.is_a?(Hash)
      [ representation_definition.keys.first, representation_definition.values.flatten ]
    end
  end

  module ClassMethods

    def representations(&definitions)
      class_eval(&definitions)
    end

    def base(fields=[])
      rep(:base, fields)
    end

    def rep(title, fields=[])
      representation = if fields.empty?
                         Representation.new(title, [title])
                       else
                         Representation.new(title, fields)
                       end
      definitions[title] = representation
    end

    def definitions
      @definitions ||= {}
      @definitions
    end
  end
end
