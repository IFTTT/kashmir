module Kashmir
  module ArRelation

    def represent(representation_definition=[])
      map do |subject|
        subject.represent(representation_definition)
      end
    end

    def represent_with(&block)
      map do |subject|
        subject.represent_with(&block)
      end
    end
  end
end
