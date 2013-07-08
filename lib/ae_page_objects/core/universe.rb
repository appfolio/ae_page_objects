module AePageObjects
  module Universe
    def self.included(target)
      target.class_eval do
        class << self
          attr_accessor :page_objects_application_class
        end
      end
    end
  end
end