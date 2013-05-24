module AePageObjects
  class RadioButton < Element

    def set(value)
      raise ArgumentError, "Invalid value '#{value}' for radio button. Valid values: #{all_values.inspect}" unless all_values.include?(value)
      find(:xpath, all_xpath(value)).set(true)
    end
    
  private
  
    def all_values
      @all_values ||= node.all(:xpath, all_xpath).map do |el| 
        id = el['id'].dup
        id.slice!("#{full_name}_")
        id
      end
    end
    
    def all_xpath(value = nil)
      if value
        XPath::HTML.descendant(:input)[XPath::HTML.attr(:type).equals('radio') & XPath::HTML.attr(:id).contains("#{full_name}_#{value}")]
      else
        XPath::HTML.descendant(:input)[XPath::HTML.attr(:type).equals('radio') & XPath::HTML.attr(:id).contains(full_name)]
      end
    end

  end
end

