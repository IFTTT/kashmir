module Kashmir
  module ArRelation

    def represent(representation_definition=[], level=1, skip_cache=false)
      cached_presenters = Kashmir::Caching.bulk_from_cache(representation_definition, self)

      to_load = []
      self.zip(cached_presenters).each do |record, cached_presenter|
        if cached_presenter.nil?
          to_load << record
        end
      end

      if to_load.any?
        if ActiveRecord::VERSION::STRING >= "4.0.2"
          ActiveRecord::Associations::Preloader.new.preload(to_load, representation_definition)
        else
          ActiveRecord::Associations::Preloader.new(to_load, representation_definition).run
        end
      end

      to_load_representations = to_load.map do |subject|
        subject.represent(representation_definition, level, skip_cache) if subject.respond_to?(:represent)
      end

      if rep = to_load.first and rep.is_a?(Kashmir) and rep.cacheable?
        Kashmir::Caching.bulk_write(representation_definition, to_load_representations, to_load, level * 60)
      end

      cached_presenters.compact + to_load_representations
    end

    def represent_with(&block)
      map do |subject|
        subject.represent_with(&block)
      end
    end
  end
end
