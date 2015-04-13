module Kashmir
  module ArRelation

    def represent(representation_definition=[])
      cached_presenters = Kashmir::Caching.bulk_from_cache(representation_definition, self)

      to_load = []
      self.zip(cached_presenters).each do |record, cached_presenter|
        if cached_presenter.nil?
          to_load << record
        end
      end

      if to_load.any?
        ActiveRecord::Associations::Preloader.new.preload(to_load, representation_definition)
      end

      to_load.map! do |subject|
        subject.represent(representation_definition)
      end

      cached_presenters.compact + to_load
    end

    def represent_with(&block)
      map do |subject|
        subject.represent_with(&block)
      end
    end
  end
end


# MonkeyPatch ALERT
#
module ActiveRecord
  module Associations
    class Preloader
      def grouped_records(association, records)
        h = {}
        records.each do |record|
          next unless record

          # We have to reopen Preloader to allow for it
          # to accept any random attribute name as a preloadable association.
          #
          # This allows us to send any abirtrary Hash to Preloader.
          # Not only keys that we know are ActiveRecord relations in advance.
          #
          unless record.class._reflect_on_association(association)
            next
          end

          assoc = record.association(association)
          klasses = h[assoc.reflection] ||= {}
          (klasses[assoc.klass] ||= []) << record
        end
        h
      end
    end
  end
end
