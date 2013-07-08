module AePageObjects
  class HashSymbolizer

    def initialize(hash)
      @hash = hash
    end

    def symbolize_keys
      @hash.dup.tap do |hash|
        hash.keys.each do |key|
          hash[(key.to_sym rescue key) || key] = hash.delete(key)
        end
      end
    end
  end
end