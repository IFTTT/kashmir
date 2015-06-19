require "kashmir/version"
require "kashmir/representation"
require "kashmir/dsl"
require "kashmir/inline_dsl"
require "kashmir/plugins/ar"
require "kashmir/caching"
require "kashmir/representable"

module Kashmir

  def self.included(klass)
    klass.extend Representable::ClassMethods
    klass.include Representable

    if klass.ancestors.include?(::ActiveRecord::Base)
      klass.include Kashmir::AR
    end
  end

  def self.init(options={})
    if client = options[:cache_client]
      @@caching = client
    end
  end

  def self.caching
    @@caching ||= Kashmir::Caching::Null.new
  end
end
