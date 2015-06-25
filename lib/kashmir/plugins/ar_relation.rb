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
        ActiveRecord::Associations::Preloader.new(to_load, representation_definition).run
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


# MonkeyPatch ALERT
# For Rails 4
#module ActiveRecord
  #module Associations
    #class Preloader
      #def grouped_records(association, records)
        #h = {}
        #records.each do |record|
          #next unless record

          ## We have to reopen Preloader to allow for it
          ## to accept any random attribute name as a preloadable association.
          ##
          ## This allows us to send any abirtrary Hash to Preloader.
          ## Not only keys that we know are ActiveRecord relations in advance.
          ##
          #unless record.class._reflect_on_association(association)
            #next
          #end

          #assoc = record.association(association)
          #klasses = h[assoc.reflection] ||= {}
          #(klasses[assoc.klass] ||= []) << record
        #end
        #h
      #end
    #end
  #end
#end

# For Rails 3
module ActiveRecord
  module Associations
    class Preloader
      def records_by_reflection(association)
        grouped = records.group_by do |record|
          reflection = record.class.reflections[association]

          ## We have to reopen Preloader to allow for it
          ## to accept any random attribute name as a preloadable association.
          ##
          ## This allows us to send any abirtrary Hash to Preloader.
          ## Not only keys that we know are ActiveRecord relations in advance.
          ##
          unless reflection
            next
          end

          reflection
        end

        ## This takes out the unexisting relations
        grouped.delete(nil)
        grouped
      end
    end
  end
end
