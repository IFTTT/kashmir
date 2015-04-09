require "kashmir/version"

module Kashmir

  def self.included(klass)
    klass.extend ClassMethods
  end


  def represent(field_groups=[])
    representation = {}

    self.class.definitions[:base].each do |field|
      representation[field] = instance_variable_get("@#{field}")
    end

    representation
  end

  module ClassMethods

    def representations(&definitions)
      class_eval(&definitions)
    end

    def base(fields=[])
      @@_definitions ||= {}
      @@_definitions[:base] = fields
    end

    def definitions
      @@_definitions
    end
  end
end
