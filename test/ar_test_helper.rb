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

