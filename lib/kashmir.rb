require "kashmir/version"

module Kashmir

  def self.included(klass)
    klass.extend ClassMethods
  end


  def represent(representation_definition=[])
    representation = {}
    representation_definition << :base

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

  class Representation

    def initialize(title, fields)
      @title = title
      @fields = fields
    end

    def run_for(instance, arguments)
      representation = {}
      instance_vars = instance.instance_variables

      @fields.each do |field|
        value = read_value(instance, field)
        if primitive?(value)
          representation[field] = value
        else
          representation[field] = present_value(value, arguments)
        end
      end

      representation
    end

    def present_value(value, arguments)
      if value.is_a?(Kashmir)
        value.represent(arguments)
      end
    end

    def read_value(instance, field)
      if instance.respond_to?(field)
        instance.send(field)
      else
        instance.instance_variable_get("@#{field}")
      end
    end

    def primitive?(field_value)
      [Fixnum, String, Date, Time, TrueClass, FalseClass, Symbol].include?(field_value.class)
    end
  end
end
