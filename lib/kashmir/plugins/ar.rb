require "active_record"
require "kashmir/plugins/active_record_representation"
require "kashmir/plugins/ar_relation"
require "kashmir/patches/active_record"

module ActiveRecord
# = Active Record Relation
  class Relation
    include Kashmir::ArRelation
  end
end

# TODO: extract kashmir array module
class Array
  include Kashmir::ArRelation
end

module Kashmir
  module AR

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods

      def rep(field, options={})
        if reflection_names.include?(field)
          return activerecord_rep(field, options)
        end

        super
      end

      def reflection_names
        if self.respond_to?(:reflections)
          return reflections.keys.map(&:to_sym)
        end

        []
      end

      def activerecord_rep(field, options)
        representation = ActiveRecordRepresentation.new(field, options)
        definitions[field] = representation
      end
    end
  end
end
