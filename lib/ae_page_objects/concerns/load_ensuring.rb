module AePageObjects
  class LoadingFailed < StandardError
  end
  
  module Concerns
    module LoadEnsuring
      extend ActiveSupport::Concern
    
      def initialize(*args)
        super
        ensure_loaded!
      end
  
    private

      def loaded_locator
      end
    
      def ensure_loaded!
        if locator = loaded_locator
          find(*eval_locator(locator)) 
        end
      
        self
      rescue Capybara::ElementNotFound => e
        raise LoadingFailed, e.message 
      end
    end
  end
end
