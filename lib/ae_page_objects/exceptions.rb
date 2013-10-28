module AePageObjects
  class StalePageObject < StandardError
  end

  class LoadingFailed < StandardError
  end

  class PathNotResolvable < StandardError
  end

  class PageNotFound < StandardError
  end
end