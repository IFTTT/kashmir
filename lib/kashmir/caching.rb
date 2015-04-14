require 'kashmir/plugins/memory_caching'
#require 'kashmir/plugins/memcached_caching'

module Kashmir
  module Caching
    extend Kashmir::Caching::Memory
    #extend Kashmir::Caching::Memcached
  end
end
