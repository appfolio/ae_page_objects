unless AePageObjects.respond_to?(:browser)
  raise "Deprecation warnings out of date."
end

module AePageObjects
  class Window
    class << self
      def all
        warn "[DEPRECATION WARNING]: AePageObjects::Window.all is deprecated. Use AePageObjects.browser.windows()"
        AePageObjects.browser.windows
      end

      def close_all
        warn "[DEPRECATION WARNING]: AePageObjects::Window.close_all is deprecated. Use AePageObjects.browser.windows.close_all()"
        all.close_all
      end
    end

    def url
      Capybara.current_session.current_url.sub(/^https?:\/\/[^\/]*/, '')
    end

    def url_without_params
      url.sub(/\?.*/, '')
    end
  end
end
