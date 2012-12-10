module AfCruft
  def assert_sets_equal(expected, actual)
    missing = expected.reject{|value| actual.include?(value)}
    missing.map! do |o| 
      if expected.respond_to? :index
        "#{expected.index(o)} - #{o.inspect}"
      else
        o.inspect
      end
    end
    
    extra = actual.reject{|value| expected.include?(value)}
    extra.map! do |o| 
      if actual.respond_to? :index
        "#{actual.index(o)} - #{o.inspect}"
      else
        o.inspect
      end
    end
    
    errors = []
    errors << "The following items were expected, but not found: #{missing.inspect}" unless missing.empty?
    errors << "The following items were found, but not expected: #{extra.inspect}" unless extra.empty?
    flunk errors.join("\n") unless errors.empty?

    if expected.respond_to? :uniq
      expected.uniq.each do |item|
        expected_number = expected.inject(0) {|result, i| i == item ? result + 1 : result}
        actual_number = actual.inject(0) {|result, i| i == item ? result + 1 : result}
        flunk "Item #{item.inspect} was expected #{expected_number} time#{expected_number != 1 ? "s" : ""}, but was found #{actual_number} time#{actual_number != 1 ? "s" : ""}" if expected_number != actual_number
      end
    end
  end
  
  def assert_false(thingy, message = nil)
    assert_equal false, thingy, message
  end

  def assert_include(obj, included)
    unless obj.include?(included)
      flunk "Expected #{obj.inspect} to include #{included.inspect}, but was not found."
    end
  end
end