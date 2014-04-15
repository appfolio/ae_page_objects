module AePageObjects
  class PageLoader
    class SameWindow < PageLoader
      private
      def page_not_loaded(document_class)
        raise IncorrectCast, "Failed instantiating a #{document_class.name} from #{permitted_types_dump}"
      end

      def load_page_with_condition(condition)
        condition.load_page
      end
    end
  end
end
