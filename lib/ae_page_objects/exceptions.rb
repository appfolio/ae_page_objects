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

  class CastError     < Error; end
  class InvalidCast   < CastError; end
  class IncorrectCast < CastError; end
end