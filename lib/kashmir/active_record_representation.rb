module Kashmir
  class ActiveRecordRepresentation < Representation

    def present_value(value, arguments)
      if value.is_a?(Kashmir) || value.is_a?(Kashmir::ArRelation)
        return value.represent(arguments)
      end
    end
  end
end
