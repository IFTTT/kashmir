module Kashmir
  module Representable

    def represent(representation_definition=[], level=0, skip_cache=false)
      if !skip_cache && cacheable? and cached_presenter = Kashmir::Caching.from_cache(representation_definition, self)
        return cached_presenter
      end

      representation = {}

      (representation_definition + base_representation).each do |representation_definition|
        key, arguments = parse_definition(representation_definition)

        unless self.class.definitions.keys.include?(key)
          raise "#{self.class.to_s}##{key} is not defined as a representation"
        end

        represented_document = self.class.definitions[key].run_for(self, arguments, level)
        representation = representation.merge(represented_document)
      end

      if !skip_cache
        cache!(representation_definition.dup, representation.dup, level)
      end

      representation
    end

    def cache!(representation_definition, representation, level=0)
      return unless cacheable?

      (cache_black_list & representation_definition).each do |field_name|
        representation_definition = representation_definition - [ field_name ]
        representation.delete(field_name)
      end

      Kashmir::Caching.store_presenter(representation_definition, representation, self, level * 60)
    end

    def cache_black_list
      self.class.definitions.values.reject(&:should_cache?).map(&:field)
    end

    def cacheable?
      respond_to?(:id)
    end

    def base_representation
      self.class.definitions.values.select(&:is_base?).map(&:field)
    end

    def represent_with(&block)
      definitions = Kashmir::InlineDsl.build(&block).definitions
      represent(definitions)
    end

    def parse_definition(representation_definition)
      if representation_definition.is_a?(Symbol)
        [ representation_definition, [] ]
      elsif representation_definition.is_a?(Hash)
        [ representation_definition.keys.first, representation_definition.values.flatten ]
      end
    end

    module ClassMethods

      def representations(&definitions)
        @definitions = {}
        class_eval(&definitions)
      end

      def base(fields)
        fields.each do |field|
          rep(field, { is_base: true })
        end
      end

      def rep(field, options={})
        representation = Representation.new(field, options)
        definitions[field] = representation
      end

      def definitions
        @definitions ||= {}
      end
    end
  end
end
