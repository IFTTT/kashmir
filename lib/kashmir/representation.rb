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
        if value.is_a?(Hash)
          representation[@field] = new_hash
        else
          representation[@field] = present_value(value, arguments)
        end
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

      if value.is_a?(Hash)
        return present_hash(value, arguments)
      end

      if value.is_a?(Array)
        return value.map do |element|
          if primitive?(element)
            element
          else
            present_value(element, arguments)
          end
        end
      end

      if value.respond_to?(:represent)
        return value.represent(arguments)
      end
    end

    def present_hash(value, arguments)
      new_hash = {}
      value.each_pair do |key, value|
        args = if arguments.is_a?(Hash)
                 arguments[key.to_sym]
               else
                 arg = arguments.find do |arg|
                   (arg.is_a?(Hash) && arg.has_key?(key.to_sym)) || arg == key.to_sym
                 end
                 if arg.is_a?(Hash)
                   arg = arg[key.to_sym]
                 end

                 arg
               end
        new_hash[key] = primitive?(value) ? value : present_value(value, args || [])
      end
      new_hash
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
