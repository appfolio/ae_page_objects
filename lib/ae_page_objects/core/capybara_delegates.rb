module AePageObjects
  module CapybaraDelegates

    def driver
      Capybara.current_session.driver
    end

    def browser
      driver.browser
    end

    def execute_script(*args)
      driver.execute_script(*args)
    end

    def evaluate_script(*args)
      driver.evaluate_script(*args)
    end

    def accept_alert
      browser.switch_to.alert.accept
    end
  end
end