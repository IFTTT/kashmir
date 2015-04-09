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

    def rep(title, fields)
      definitions[title] = Representation.new(title, fields)
    end

    def definitions
      @@_definitions ||= {}
      @@_definitions
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
        value = if instance.respond_to?(field)
                  instance.send(field)
                else
                  instance.instance_variable_get("@#{field}")
                end

        representation[field] = value
      end

      representation
    end
  end
end
