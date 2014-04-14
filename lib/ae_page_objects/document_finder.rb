module AePageObjects
  class DocumentFinder
    autoload :Conditions,            'ae_page_objects/document_finder/conditions'
    autoload :DocumentWindowScanner, 'ae_page_objects/document_finder/document_window_scanner'

    def initialize(windows_list, document_class)
      @windows_list    = windows_list
      @original_window = windows_list.current_window
      @document_class  = document_class
    end

    def find(conditions = {}, &conditions_block)
      conditions = Conditions.from(conditions, &conditions_block)

      result = Waiter.wait_for do
        DocumentWindowScanner.new(@document_class, @original_window, @windows_list.opened_windows, conditions).find
      end

      return result if result

      @original_window.switch_to

      all_windows = @windows_list.opened_windows.map do |window|
        name = window.current_document && window.current_document.to_s || "<none>"
        {:window_handle => window.handle, :document => name }
      end

      raise PageNotFound, "Couldn't find page #{@document_class.name} in any of the open windows: #{all_windows.inspect}"
    end
  end
end
