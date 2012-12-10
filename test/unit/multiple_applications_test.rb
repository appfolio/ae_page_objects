require 'unit_helper'

class AePageObjects::MultipleApplicationsTest < ActiveSupport::TestCase
  
  module TestApp1
    module AePageObjects
      class Application < ::AePageObjects::Application
      end
    end
  end
  
  module TestApp2
    module AePageObjects
      class Application < ::AePageObjects::Application
      end
    end
  end
  
  def test_initialize_works
    assert_nothing_raised do
      TestApp1::AePageObjects::Application.initialize!
      TestApp2::AePageObjects::Application.initialize!
    end
  end
end