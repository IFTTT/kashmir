require 'kashmir/plugins/memory_caching'
require 'kashmir/plugins/null_caching'
require 'kashmir/plugins/memcached_caching'

module Kashmir
  module Caching
    extend Kashmir::Caching::Null
  end
end
