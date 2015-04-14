module Kashmir
  class Representation

    attr_reader :field

    def initialize(field, options)
      @field = field
      @options = options
    end

    def run_for(instance, arguments)
      representation = {}
      instance_vars = instance.instance_variables

      value = read_value(instance, @field)
      if primitive?(value)
        representation[@field] = value
      else
        representation[@field] = present_value(value, arguments)
      end

      representation
    end

    def is_base?
      @options.has_key?(:is_base) and !!@options[:is_base]
    end

    def should_cache?
      if @options.has_key?(:cacheable)
        return !!@options[:cacheable]
      end

      true
    end

    def present_value(value, arguments)
      if value.is_a?(Kashmir)
        return value.represent(arguments)
      end

      if value.is_a?(Array)
        value.map do |element|
          present_value(element, arguments)
        end
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
