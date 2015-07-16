# We have to reopen Preloader to allow for it
# to accept any random attribute name as a preloadable association.
#
# This allows us to send any abirtrary Hash to Preloader.
# Not only keys that we know are ActiveRecord relations in advance.
#

module ArV4Patch

  def self.included(klass)
    klass.instance_eval do
      remove_method :grouped_records
    end
  end

  def grouped_records(association, records)
    h = {}
    records.each do |record|
      next unless record

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
      if ActiveRecord::VERSION::STRING >= "4.0.2"
        include ::ArV4Patch
      else
        include ::ArV3Patch
      end
    end
  end
end
