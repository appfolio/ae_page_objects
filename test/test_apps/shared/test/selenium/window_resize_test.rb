require 'selenium_helper'

class WindowResizeTest < Selenium::TestCase

  def test_resize_window_with_both_width_and_height
    current_window = PageObjects::Books::NewPage.visit.window
    window_dimension = current_window.dimension

    new_width = window_dimension.width - 10
    new_height = window_dimension.height - 5

    original_dimension = current_window.resize_to(:width => new_width, :height => new_height)

    assert_equal window_dimension.width, original_dimension.width
    assert_equal window_dimension.height, original_dimension.height

    window_dimension = current_window.dimension

    assert_equal new_width, window_dimension.width
    assert_equal new_height, window_dimension.height
  end

  def test_resize_window_with_only_width
    current_window = PageObjects::Books::NewPage.visit.window
    window_dimension = current_window.dimension

    new_width = window_dimension.width - 10

    original_dimension = current_window.resize_to(:width => new_width)

    assert_equal window_dimension.width, original_dimension.width
    assert_equal window_dimension.height, original_dimension.height

    window_dimension = current_window.dimension

    assert_equal new_width, window_dimension.width
    assert_equal original_dimension.height, window_dimension.height
  end

  def test_resize_window_with_only_height
    current_window = PageObjects::Books::NewPage.visit.window
    window_dimension = current_window.dimension

    new_height = window_dimension.height - 5

    original_dimension = current_window.resize_to(:height => new_height)

    assert_equal window_dimension.width, original_dimension.width
    assert_equal window_dimension.height, original_dimension.height

    window_dimension = current_window.dimension

    assert_equal original_dimension.width, window_dimension.width
    assert_equal new_height, window_dimension.height
  end

  def test_resize_when_multiple_windows_are_open
    ActiveRecord::Base.transaction do
      Author.create!(:first_name => 'Andrew', :last_name => "Putz")
    end

    authors_page = PageObjects::Authors::IndexPage.visit
    authors_window = authors_page.window
    authors_original_dimension = authors_window.dimension

    robert_page = authors_page.authors[0].show_in_new_window_with_name!("Robert")
    robert_window = robert_page.window
    robert_original_dimension = robert_window.dimension

    robert_new_width = robert_original_dimension.width - 10
    robert_new_height = robert_original_dimension.height - 5

    robert_window.resize_to(:width => robert_new_width, :height => robert_new_height)

    robert_current_dimension = robert_window.dimension

    assert_equal robert_new_width, robert_current_dimension.width
    assert_equal robert_new_height, robert_current_dimension.height

    authors_current_dimension = authors_window.dimension

    assert_equal authors_original_dimension.width, authors_current_dimension.width
    assert_equal authors_original_dimension.height, authors_current_dimension.height
  end

  def test_with_dimension
    current_window = PageObjects::Books::NewPage.visit.window
    original_dimension = current_window.dimension

    new_width = original_dimension.width - 10
    new_height = original_dimension.height - 5

    current_window.with_dimension(:width => new_width, :height => new_height) do
      current_dimension = current_window.dimension

      assert_equal new_width, current_dimension.width
      assert_equal new_height, current_dimension.height
    end

    current_dimension = current_window.dimension

    assert_equal original_dimension.width, current_dimension.width
    assert_equal original_dimension.height, current_dimension.height
  end
end
