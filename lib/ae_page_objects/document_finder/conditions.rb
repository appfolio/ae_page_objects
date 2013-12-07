module AePageObjects
  class DocumentFinder
    class Conditions

      def self.from(conditions, &block)
        if conditions.is_a?(self)
          return conditions
        end

        new(conditions, &block)
      end

      def initialize(conditions = {}, &block_condition)
        @conditions = conditions || {}
        @conditions[:block] = block_condition if block_condition
      end

      def ignore_current?
        !! @conditions[:ignore_current]
      end

      def match?(page)
        @conditions.each do |type, value|
          case type
          when :title then
            return false unless Capybara.current_session.driver.browser.title.include?(value)
          when :url then
            return false unless page.current_url.include?(value)
          when :block then
            return false unless value.call(page)
          end
        end

        true
      end
    end
  end
end
