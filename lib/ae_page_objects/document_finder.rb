module AePageObjects
  class DocumentFinder
    autoload :Conditions,            'ae_page_objects/document_finder/conditions'
    autoload :DocumentWindowScanner, 'ae_page_objects/document_finder/document_window_scanner'

    def initialize(document_class)
      @document_class  = document_class
      @original_window = AePageObjects::Window.current
    end

    def find(conditions = {}, &conditions_block)
      conditions = Conditions.from(conditions, &conditions_block)

      result = Waiter.wait_for do
        DocumentWindowScanner.new(@document_class, @original_window, AePageObjects::Window.all, conditions).find
      end

      return result if result

      @original_window.switch_to

      all_windows = AePageObjects::Window.all.map do |window|
        name = window.current_document && window.current_document.to_s || "<none>"
        {:window_handle => window.handle, :document => name }
      end

      raise PageNotFound, "Couldn't find page #{@document_class.name} in any of the open windows: #{all_windows.inspect}"
    end
  end
end
