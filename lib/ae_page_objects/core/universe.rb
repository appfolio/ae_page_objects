module AePageObjects
  module Universe
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :page_objects_application_class
      end
    end
  end
end