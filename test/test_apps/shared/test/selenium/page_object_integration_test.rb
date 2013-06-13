require 'selenium_helper'

class PageObjectIntegrationTest < Selenium::TestCase

  def test_site_setup
    assert PageObjects < AePageObjects::Universe
    assert_equal PageObjects, PageObjects::Site.universe
    assert_equal PageObjects::Site.instance, PageObjects::Authors::NewPage.send(:site)
    assert_equal PageObjects::Site, PageObjects.page_objects_site_class
  end

  def test_load_ensuring
    visit("/books/new")
    
    exception = assert_raises AePageObjects::LoadingFailed do
      PageObjects::Authors::NewPage.new
    end

    assert_equal "PageObjects::Authors::NewPage cannot be loaded with url '/books/new'", exception.message

    visit("/authors/new")

    assert_nothing_raised do
      PageObjects::Authors::NewPage.new
    end
  end
  
  def test_simple_form
    new_page = PageObjects::Books::NewPage.visit
    assert_equal "", new_page.title.value
    assert_equal "", new_page.index.pages.value

    new_page.title.set "Tushar's Dilemma"
    new_page.index.pages.set "132"
 
    assert_equal "Tushar's Dilemma", new_page.title.value
    assert_equal "132", new_page.index.pages.value
  end
  
  def test_complex_form
    new_author_page = PageObjects::Authors::NewPage.visit
    assert_equal "", new_author_page.first_name.value
    assert_equal "", new_author_page.last_name.value
    assert_equal "", new_author_page.books.first.title.value
    assert_equal "", new_author_page.books.last.title.value

    new_author_page.first_name.set "Michael"
    new_author_page.last_name.set "Pollan"
    new_author_page.books.first.title.set "In Defense of Food"
    new_author_page.books.last.title.set "The Omnivore's Dilemma"
 
    assert_equal "Michael", new_author_page.first_name.value
    assert_equal "Pollan", new_author_page.last_name.value
    assert_equal "In Defense of Food", new_author_page.books.first.title.value
    assert_equal "The Omnivore's Dilemma", new_author_page.books.last.title.value
  end
  
  def test_element_proxy
    author = PageObjects::Authors::NewPage.visit

    Capybara.using_wait_time(1) do
      assert author.rating.star.present?
      assert author.rating.star.visible?
      assert_false author.rating.star.not_present?
      assert_false author.rating.star.not_visible?

      author.rating.hide_star
      assert author.rating.star.present?
      assert_false author.rating.star.visible?
      assert_false author.rating.star.not_present?
      assert author.rating.star.not_visible?

      author.rating.show_star
      assert author.rating.star.present?
      assert author.rating.star.visible?
      assert_false author.rating.star.not_present?
      assert_false author.rating.star.not_visible?

      author.rating.remove_star
      assert_false author.rating.star.present?
      assert_false author.rating.star.visible?
      assert author.rating.star.not_present?
      assert author.rating.star.not_visible?
    end
  end
  
  def test_element_proxy__not_present
    author = PageObjects::Authors::NewPage.visit
    assert_false author.missing.present?
    assert author.missing.not_present?
  end
  
  def test_element_proxy__nested
    author = PageObjects::Authors::NewPage.visit
    Capybara.using_wait_time(1) do
      assert author.nested_rating.star.present?

      author.nested_rating.hide_star
      assert author.nested_rating.star.present?
      assert_false author.nested_rating.star.visible?

      author.nested_rating.show_star
      assert author.nested_rating.star.present?
      assert author.nested_rating.star.visible?

      author.nested_rating.remove_star
      assert_false author.nested_rating.star.present?
      assert_false author.nested_rating.star.visible?
    end
  end
  
  def test_document_tracking
    author = TestApp::PageObjects::Authors::NewPage.visit
    assert_false author.stale?
    
    visit("/books/new")
    assert_false author.stale?
    
    book = TestApp::PageObjects::Books::NewPage.new
    assert author.stale?
    assert_false book.stale?
    
    author = TestApp::PageObjects::Authors::NewPage.visit
    assert_false author.stale?
    assert book.stale?

    book = TestApp::PageObjects::Books::NewPage.visit
    assert author.stale?
    assert_false book.stale?
    
    author = TestApp::PageObjects::Authors::NewPage.visit
    assert_false author.stale?
    assert book.stale?
    
    visit("/authors/new")
    assert_false author.stale?
    assert book.stale?
    
    assert_raises AePageObjects::LoadingFailed do
      TestApp::PageObjects::Books::NewPage.new
    end
    
    assert_false author.stale?
    assert book.stale?
  end
end
