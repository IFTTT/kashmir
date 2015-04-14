module Kashmir
  module Caching
    module Memory

      def from_cache(definitions, instance)
        key = presenter_key(definitions, instance)
        if cached_data = get(key)
          return cached_data
        end
      end

      def bulk_from_cache(definitions, instances)
        keys = instances.map do |instance|
          presenter_key(definitions, instance)
        end

        keys.map do |key|
          get(key)
        end
      end

      def store_presenter(definitions, representation, instance)
        key = presenter_key(definitions, instance)
        set(key, representation)
      end

      def presenter_key(definition_name, instance)
        "presenter:#{instance.class}:#{instance.id}:#{definition_name}"
      end

      def get(key)
        @@cache ||= {}
        if data = @@cache[key]
          JSON.parse(data).deep_symbolize_keys
        end
      end

      def set(key, value)
        @@cache ||= {}
        @@cache[key] = value.to_json
      end

      def clear(definition, instance)
        key = presenter_key(definition, instance)
        @@cache ||= {}
        @@cache.delete(key)
      end

      def flush!
        @@cache = {}
      end

      def keys
        @@cache.keys
      end
    end
  end
end
