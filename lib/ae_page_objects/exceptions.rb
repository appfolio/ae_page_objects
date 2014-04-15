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

  class PageNotFound < PageLoadError
  end

  class PageNotExpected < PageLoadError
  end

  class CastError     < PageLoadError; end
  class InvalidCast   < CastError; end
  class IncorrectCast < CastError; end
end