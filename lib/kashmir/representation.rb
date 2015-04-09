module Kashmir
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
