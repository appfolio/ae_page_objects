module AePageObjects
  class WaitTimeManager
    def initialize(min_time, max_time)
      @wait_time = min_time
      @max_time = max_time
    end

    def using_wait_time
      start_time = AePageObjects.time_keeper.now
      @wait_time = [@wait_time, @max_time].min
      Capybara.using_wait_time(@wait_time) do
        yield
      end
    ensure
      if AePageObjects.time_keeper.now - start_time > @wait_time
        @wait_time *= 2
      end
    end
  end
end
