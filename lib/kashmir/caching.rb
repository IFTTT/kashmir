require 'kashmir/plugins/memory_caching'
require 'kashmir/plugins/null_caching'
require 'kashmir/plugins/memcached_caching'
require 'colorize'

module Kashmir
  module Caching

    def from_cache(representation_definition, object)
      log("#{"read".blue}: #{log_key(object, representation_definition)}", :debug)

      cached_representation = Kashmir.caching.from_cache(representation_definition, object)

      if cached_representation
        log("#{"hit".green}: #{log_key(object, representation_definition)}")
      else
        log("#{"miss".red}: #{log_key(object, representation_definition)}")
      end

      cached_representation
    end

    def store_presenter(representation_definition, representation, object)
      log("#{"write".blue}: #{log_key(object, representation_definition)}", :debug)
      Kashmir.caching.store_presenter(representation_definition, representation, object)
    end

    def log_key(object, representation_definition)
      "#{object.class.name}-#{object.id}-#{representation_definition}"
    end

    def log(message, level=:info)
      Kashmir.logger.send(level, ("\n#{"Kashmir::Caching".magenta} #{message}\n"))
    end

    module_function :from_cache, :store_presenter, :log_key, :log
  end
end
