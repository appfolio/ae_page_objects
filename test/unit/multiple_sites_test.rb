require 'unit_helper'

class AePageObjects::MultipleSitesTest < Test::Unit::TestCase

  module TestApp1
    module PageObjects
      class Site < AePageObjects::Site
      end
    end
  end

  module TestApp2
    module PageObjects
      class Site < AePageObjects::Site
      end
    end
  end

  def test_initialize_works
    assert_nothing_raised do
      TestApp1::PageObjects::Site.initialize!
      TestApp2::PageObjects::Site.initialize!
    end
  end
end
