require 'ae_page_objects'

module PageObjects
  module Authors
    extend ActiveSupport::Autoload

    autoload :IndexPage
    autoload :NewPage
    autoload :ShowPage
  end

  module Books
    extend ActiveSupport::Autoload

    autoload :EditPage
    autoload :HasBookForm
    autoload :NewPage
    autoload :ShowPage
  end
end
