require 'selenium_helper'
require 'set'


class WindowResizeTest < Selenium::TestCase

  def test_window_resize_to_with_both_width_and_height
    current_window = PageObjects::Books::NewPage.visit.window
    size = current_window.size

    expected_width = size.width - 10
    expected_height = size.height - 5

    current_window.resize_to(expected_width, expected_height)

    size = current_window.size

    assert_equal expected_width, size.width
    assert_equal expected_height, size.height
  end

  def test_window_resize_to_with_only_width
    current_window = PageObjects::Books::NewPage.visit.window
    size = current_window.size

    expected_width = size.width - 10
    expected_height = size.height

    current_window.resize_to(expected_width)

    size = current_window.size

    assert_equal expected_width, size.width
    assert_equal expected_height, size.height
  end

  def test_window_resize_to_with_only_height
    current_window = PageObjects::Books::NewPage.visit.window
    size = current_window.size

    expected_width = size.width
    expected_height = size.height - 5

    current_window.resize_to(nil, expected_height)

    size = current_window.size

    assert_equal expected_width, size.width
    assert_equal expected_height, size.height
  end

  def test_window_resize_to_with_multiple_windows
    ActiveRecord::Base.transaction do
      Author.create!(:first_name => 'Andrew', :last_name => "Putz")
    end

    authors_page = PageObjects::Authors::IndexPage.visit
    authors_window = authors_page.window
    authors_window_size = authors_window.size

    robert_page = authors_page.authors[0].show_in_new_window_with_name!("Robert")
    robert_window = robert_page.window
    robert_window_size = robert_window.size

    new_width = robert_window_size.width - 10
    new_height = robert_window_size.height - 5

    robert_window.resize_to(new_width, new_height)

    expected_width = new_width
    expected_height = new_height
    acutal_size = robert_window.size

    assert_equal expected_width, acutal_size.width
    assert_equal expected_height, acutal_size.height

    expected_width = authors_window_size.width
    expected_height = authors_window_size.height
    acutal_size = authors_window.size

    assert_equal expected_width, acutal_size.width
    assert_equal expected_height, acutal_size.height
  end

  def test_with_window_size
    current_window = PageObjects::Books::NewPage.visit.window
    original_size = current_window.size

    new_width = original_size.width - 10
    new_height = original_size.height - 5

    current_window.with_window_size(new_width, new_height) do
      actual_size = current_window.size

      assert_equal new_width, actual_size.width
      assert_equal new_height, actual_size.height
    end

    actual_size = current_window.size

    assert_equal original_size.width, actual_size.width
    assert_equal original_size.height, actual_size.height
  end
end
