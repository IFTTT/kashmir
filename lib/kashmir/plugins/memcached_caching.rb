module Kashmir
  module Caching
    class Memcached

      attr_reader :client

      def initialize(client, default_ttl = 3600)
        @client = client
        @default_ttl = default_ttl
      end

      def from_cache(definitions, instance)
        key = presenter_key(definitions, instance)
        if cached_data = get(key)
          return cached_data
        end
      end

      def bulk_from_cache(definitions, instances)
        keys = instances.map do |instance|
          presenter_key(definitions, instance) if instance.respond_to?(:id)
        end.compact


        # TODO improve this
        # Creates a hash with all the keys (sorted by the array sort order)
        # and points everything to null
        # ex: [a, b, c] -> { a: nil, b: nil, c: nil }
        results = Hash[keys.map {|x| [x, nil]}]

        # Get results from memcached
        # This will ONLY return cache hits as a Hash
        # ex: { a: cached_a, b: cached_b } note that C is not here
        from_cache = client.get_multi(keys)

        # This assigns each one of the cached values to its keys
        # preserving cache misses (that still point to nil)
        from_cache.each_pair do |key, value|
          results[key] = JSON.parse(value, symbolize_names: true)
        end

        # returns the cached results in the same order as requested.
        # this will also return nil values for cache misses
        results.values
      end

      def bulk_write(definitions, representations, instances, ttl)
        client.multi do
          instances.each_with_index do |instance, index|
            key = presenter_key(definitions, instance)
            set(key, representations[index], ttl)
          end
        end
      end

      def store_presenter(definitions, representation, instance, ttl=0)
        key = presenter_key(definitions, instance)
        set(key, representation, ttl)
      end

      def presenter_key(definition_name, instance)
        "#{instance.class}:#{instance.id}:#{definition_name}"
      end

      def get(key)
        if data = client.get(key)
          JSON.parse(data, symbolize_names: true)
        end
      end

      def set(key, value, ttl=nil)
        client.set(key, value.to_json, ttl || @default_ttl)
      end

      def clear(definition, instance)
        key = presenter_key(definition, instance)
        client.delete(key)
      end
    end
  end
end
