module Kashmir
  module ArRelation

    def represent(representation_definition=[])
      ActiveRecord::Associations::Preloader.new.preload(self, representation_definition)

      map do |subject|
        subject.represent(representation_definition)
      end
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