require 'kashmir/extensions'

module Kashmir
  module Caching
    class Memory

      def from_cache(definitions, instance)
        key = presenter_key(definitions, instance)
        if cached_data = get(key)
          return cached_data
        end
      end

      def bulk_from_cache(definitions, instances)
        keys = instances.map do |instance|
          presenter_key(definitions, instance) if instance.respond_to?(:id)
        end

        keys.map do |key|
          get(key)
        end
      end

      def store_presenter(definitions, representation, instance, ttl=0)
        key = presenter_key(definitions, instance)
        set(key, representation)
      end

      def bulk_write(definitions, representations, objects, ttl)
        objects.each_with_index do |instance, index|
          store_presenter(definitions, representations[index], instance, ttl)
        end
      end

      def presenter_key(definition_name, instance)
        "presenter:#{instance.class}:#{instance.id}:#{definition_name}"
      end

      def get(key)
        @@cache ||= {}
        if data = @@cache[key]
          SymbolizeHelper.symbolize_recursive JSON.parse(data)
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
