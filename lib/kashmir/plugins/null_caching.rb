require 'kashmir/extensions'

module Kashmir
  module Caching
    class Null

      def from_cache(definitions, instance)
        nil
      end

      def bulk_from_cache(definitions, instances)
        []
      end

      def store_presenter(definitions, representation, instance, black_list=[])
      end

      def presenter_key(definition_name, instance)
        "presenter:#{instance.class}:#{instance.id}:#{definition_name}"
      end

      def get(key)
      end

      def set(key, value)
      end

      def clear(definition, instance)
      end

      def flush!
      end

      def keys
        []
      end
    end
  end
end
