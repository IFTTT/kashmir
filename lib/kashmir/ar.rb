require "active_record"
require "kashmir/active_record_representation"
require "kashmir/ar_relation"

module ActiveRecord
# = Active Record Relation
  class Relation
    include Kashmir::ArRelation
  end
end

module Kashmir
  module AR

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods

      def rep(title, fields=[])
        if reflection_names.include?(title)
          return activerecord_rep(title, fields)
        end

        super
      end

      def reflection_names
        if self.respond_to?(:reflections)
          return reflections.keys.map(&:to_sym)
        end

        []
      end

      def activerecord_rep(title, fields)
        representation = if fields.empty?
                           ActiveRecordRepresentation.new(title, [title])
                         else
                           ActiveRecordRepresentation.new(title, fields)
                         end
        definitions[title] = representation
      end
    end
  end
end
