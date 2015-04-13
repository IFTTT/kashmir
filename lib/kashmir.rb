require "kashmir/version"
require "kashmir/representation"
require "kashmir/dsl"
require "kashmir/inline_dsl"
require "kashmir/ar"
require "kashmir/caching"

module Kashmir

  def self.included(klass)
    klass.extend ClassMethods

    if klass.ancestors.include?(::ActiveRecord::Base)
      klass.include Kashmir::AR
    end
  end

  def represent(representation_definition=[])
    if cacheable? and cached_presenter = Kashmir::Caching.from_cache(representation_definition, self)
      return cached_presenter
    end

    representation = {}
    representation_definition << :base if self.class.definitions.include?(:base)

    representation_definition.each do |representation_definition|
      key, arguments = parse_definition(representation_definition)

      unless self.class.definitions.keys.include?(key)
        raise "#{self.class.to_s}##{key} is not defined as a representation"
      end

      represented_document = self.class.definitions[key].run_for(self, arguments)
      representation = representation.merge(represented_document)
    end

    Kashmir::Caching.store_presenter(representation_definition, representation, self) if cacheable?

    representation
  end

  def cacheable?
    respond_to?(:id)
  end

  def represent_with(&block)
    definitions = Kashmir::InlineDsl.build(&block).definitions
    represent(definitions)
  end

  def parse_definition(representation_definition)
    if representation_definition.is_a?(Symbol)
      [ representation_definition, [] ]
    elsif representation_definition.is_a?(Hash)
      [ representation_definition.keys.first, representation_definition.values.flatten ]
    end
  end

  module ClassMethods

    def representations(&definitions)
      @definitions = {}
      class_eval(&definitions)
    end

    def base(fields=[])
      rep(:base, fields)
    end

    def rep(title, fields=[])
      representation = if fields.empty?
                         Representation.new(title, [title])
                       else
                         Representation.new(title, fields)
                       end
      definitions[title] = representation
    end

    def definitions
      @definitions ||= {}
    end
  end
end
