require 'test_helper'
require 'minitest/around'

require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

require 'support/schema'
require 'support/ar_models'
require 'support/factories'


class Minitest::Test
  def around(&block)
    ActiveRecord::Base.transaction do
      block.call
      raise ActiveRecord::Rollback
    end
  end
end

def track_queries
  selects = []
  queries_collector = lambda do |name, start, finish, id, payload|
    selects << payload
  end

  ActiveRecord::Base.connection.clear_query_cache
  ActiveSupport::Notifications.subscribed(queries_collector, 'sql.active_record') do
    yield
  end

  selects.map { |sel| sel[:sql] }
end

# grabbed this from: https://gist.github.com/bkimble/1365005
def all_keys
  require 'net/telnet'

  rows = []

  localhost = Net::Telnet::new("Host" => "localhost", "Port" => 11211, "Timeout" => 3)
  matches   = localhost.cmd("String" => "stats items", "Match" => /^END/).scan(/STAT items:(\d+):number (\d+)/)

  slabs = matches.inject([]) { |items, item| items << Hash[*['id','items'].zip(item).flatten]; items }

  slabs.each do |slab|
    localhost.cmd("String" => "stats cachedump #{slab['id']} #{slab['items']}", "Match" => /^END/) do |c|
      matches = c.scan(/^ITEM (.+?) \[(\d+) b; (\d+) s\]$/).each do |key_data|
        cache_key = key_data.first
        rows << cache_key
      end
    end
  end

  localhost.close
  rows
end
