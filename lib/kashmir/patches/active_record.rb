# We have to reopen Preloader to allow for it
# to accept any random attribute name as a preloadable association.
#
# This allows us to send any arbitrary Hash to Preloader, without
# requiring it to be an ActiveRecord relation in advance.
#

module ArV4Patch
  def grouped_records(association, records_41 = records)
    super(association, records_41.select { |record| record.class.reflect_on_association(association) })
  end
end

module ArV3Patch
  def self.included(klass)
    klass.instance_eval do
      remove_method :records_by_reflection
    end
  end

  def records_by_reflection(association)
    grouped = records.group_by do |record|
      reflection = record.class.reflections[association]

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

module ActiveRecord
  module Associations
    class Preloader
      if Gem::Version.new(ActiveRecord::VERSION::STRING) >= Gem::Version.new("4.0.2")
        prepend ::ArV4Patch
      else
        include ::ArV3Patch
      end
    end
  end
end
