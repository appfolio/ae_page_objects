module AePageObjects
  class Error < StandardError; end

  class StalePageObject < Error
  end

  class LoadingFailed < Error
  end

  class PathNotResolvable < Error
  end

  class PageLoadError < Error
  end
end