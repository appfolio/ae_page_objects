require 'selenium_helper'

class PageObjectIntegrationTest < Selenium::TestCase
  
  def test_load_ensuring
    visit("/authors/new")
    
    assert_raises AePageObjects::LoadingFailed do
      TestApp::PageObjects::Books::NewPage.new
    end
  end
  
  def test_simple_form
    new_page = TestApp::PageObjects::Books::NewPage.visit
    assert_equal "", new_page.title.value
    assert_equal "", new_page.index.pages.value

    new_page.title.set "Tushar's Dilemma"
    new_page.index.pages.set "132"
 
    assert_equal "Tushar's Dilemma", new_page.title.value
    assert_equal "132", new_page.index.pages.value
  rescue => e
    puts e.backtrace.join("\n")
    raise e      
  end
  
  def test_complex_form
    new_author_page = TestApp::PageObjects::Authors::NewPage.visit
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
  rescue => e
    puts e.backtrace.join("\n")
    raise e      
  end
  
  def test_element_proxy
    author = TestApp::PageObjects::Authors::NewPage.visit
    assert author.rating.star.present?
    
    author.rating.hide_star
    assert author.rating.star.present?
    assert_false author.rating.star.visible?
    
    author.rating.show_star
    assert author.rating.star.present?
    assert author.rating.star.visible?
    
    author.rating.remove_star
    assert_false author.rating.star.present?
    assert_false author.rating.star.visible?
  rescue => e
    puts e.backtrace.join("\n")
    raise e      
  end
  
  def test_element_proxy__not_present
    author = TestApp::PageObjects::Authors::NewPage.visit
    assert_false author.missing.present?
    assert author.missing.not_present?
  rescue => e
    puts e.backtrace.join("\n")
    raise e      
  end
  
  def test_element_proxy__nested
    author = TestApp::PageObjects::Authors::NewPage.visit
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
  rescue => e
    puts e.backtrace.join("\n")
    raise e      
  end
end
