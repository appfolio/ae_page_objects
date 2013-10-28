module AePageObjects
  class Error < StandardError; end

  class StalePageObject < Error
  end

  class LoadingFailed < Error
  end

  class PathNotResolvable < Error
  end

  class PageNotFound < Error
  end

  class InvalidCast < Error
  end
end