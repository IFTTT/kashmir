module Kashmir
  class ActiveRecordRepresentation < Representation

    def present_value(value, arguments)
      if value.is_a?(Kashmir)
        return value.represent(arguments)
      end

      if value.is_a?(Array) || value.is_a?(::ActiveRecord::Relation)
        value.map do |element|
          present_value(element, arguments)
        end
      end
    end
  end
end
