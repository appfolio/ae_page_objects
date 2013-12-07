module AePageObjects
  class DocumentFinder
    class Conditions
      def initialize(conditions, block_condition)
        @conditions = conditions || {}
        @conditions[:block] = block_condition if block_condition
      end

      def match?(page, is_current)
        @conditions.each do |type, value|
          case type
          when :title then
            return false unless Capybara.current_session.driver.browser.title.include?(value)
          when :url then
            return false unless page.current_url.include?(value)
          when :block then
            return false unless value.call(page)
          when :ignore_current
            return false if is_current && value
          end
        end

        true
      end
    end
  end
end
