require "kashmir/version"

module Kashmir

  def self.included(klass)
    klass.extend ClassMethods
  end


  def represent(representation_titles=[])
    representation = {}
    representation_titles << :base

    representation_titles.each do |representation_title|
      represented_definition = self.class.definitions[representation_title].run_for(self)
      representation = representation.merge(represented_definition)
    end

    representation
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

    def run_for(instance)
      representation = {}
      instance_vars = instance.instance_variables

      @fields.each do |field|
        value = read_value(instance, field)
        if primitive?(value)
          representation[field] = value
        else
          representation[field] = present_value(value)
        end
      end

      representation
    end

    def present_value(value)
      if value.is_a?(Kashmir)
        value.represent
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
