module Kashmir
  class ActiveRecordRepresentation < Representation

    def present_value(value, arguments, level=0, skip_cache=false)
      if value.is_a?(Kashmir) || value.is_a?(Kashmir::ArRelation)
        return value.represent(arguments, level, skip_cache)
      end

      if value.respond_to?(:represent)
        value.represent(arguments, level, skip_cache)
      end
    end
  end
end
