require 'selenium_helper'
require 'set'

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

  def test_load_ensuring__waits_for_page
    ActiveRecord::Base.transaction do
      Author.create!(:last_name => 'a')
    end

    index = PageObjects::Authors::IndexPage.visit

    author = index.authors.find do |author|
      author.last_name.text == 'a'
    end.delayed_show!
    assert_equal "a", author.last_name.text
  end
  
  def test_simple_form
    new_page = PageObjects::Books::NewPage.visit
    assert_equal "", new_page.title.value
    assert_equal "", new_page.index.pages.value

    new_page.title.set "Tushar's Dilemma"
    new_page.index.pages.set "132"
 
    assert_equal "Tushar's Dilemma", new_page.title.value
    assert_equal "132", new_page.index.pages.value

    show_page = new_page.save!
    assert_equal "Tushar's Dilemma", show_page.title.text
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

  def test_some_collection_enumerables
    ActiveRecord::Base.transaction do
      Author.create!(:last_name => 'a')
      Author.create!(:last_name => 'm')
      Author.create!(:last_name => 'u')
      Author.create!(:last_name => 't')
      Author.create!(:last_name => 'z')
      Author.create!(:last_name => '7')
    end

    index = PageObjects::Authors::IndexPage.visit

    assert_equal 8, index.authors.size
    assert_nil index.authors.find { |author|
      author.last_name.text == 'q'
    }

    assert_not_nil index.authors.find { |author|
      author.last_name.text == 'a'
    }

    authors = index.authors.select { |author|
      'amutz'.include?(author.last_name.text)
    }

    assert_equal Array, authors.class
    assert_equal 'amtuz', authors.map(&:last_name).map(&:text).join('')

    assert_equal 1, index.authors.count { |author|
      author.last_name.text == '7'
    }
  end
  
  def test_document_tracking
    author = PageObjects::Authors::NewPage.visit
    assert_false author.stale?
    
    visit("/books/new")
    assert_false author.stale?
    
    book = PageObjects::Books::NewPage.new
    assert author.stale?
    assert_false book.stale?
    
    author = PageObjects::Authors::NewPage.visit
    assert_false author.stale?
    assert book.stale?

    book = PageObjects::Books::NewPage.visit
    assert author.stale?
    assert_false book.stale?
    
    author = PageObjects::Authors::NewPage.visit
    assert_false author.stale?
    assert book.stale?
    
    visit("/authors/new")
    assert_false author.stale?
    assert book.stale?
    
    assert_raises AePageObjects::LoadingFailed do
      PageObjects::Books::NewPage.new
    end
    
    assert_false author.stale?
    assert book.stale?
  end

  def test_document_tracking__multiple_windows
    window1_authors = PageObjects::Authors::IndexPage.visit
    window1 = window1_authors.window
    assert_windows(window1, :current => window1)

    window1_authors_robert_row = window1_authors.authors.first
    assert_equal "Robert", window1_authors_robert_row.first_name.text

    window1_authors_robert_row.show_in_new_window

    Capybara.current_session.driver.within_window(author_path(authors(:robert)))
    window2_author_robert = PageObjects::Authors::ShowPage.new

    window2 = window2_author_robert.window
    assert_windows(window1, window2, :current => window2)

    window2_authors = PageObjects::Authors::IndexPage.visit
    assert_equal window2, window2_authors.window

    assert window2_author_robert.stale?

    window1.switch_to

    window1_author_robert = window1_authors_robert_row.show!
    assert_equal window1, window1_author_robert.window
    assert window1_authors.stale?

    window2.switch_to

    window2_authors_robert_row = window2_authors.authors.first.show!
    assert_equal window2, window2_authors_robert_row.window
    assert window2_authors.stale?
    assert_false window1_author_robert.stale?

    window2.close
    assert window2_author_robert.stale?
    assert_equal nil, window2.current_document
    assert_windows(window1, :current => window1)

    assert_false window1_author_robert.stale?
    assert_equal window1_author_robert, window1.current_document

    # close a window without an explicit switch
    window1_authors = PageObjects::Authors::IndexPage.visit
    window1_authors_robert_row = window1_authors.authors.first
    window1_authors_robert_row.show_in_new_window

    Capybara.current_session.driver.within_window(author_path(authors(:robert)))
    window3_author_robert = PageObjects::Authors::ShowPage.new
    window3 = window3_author_robert.window

    assert_windows(window1, window3, :current => window3)

    window1.close
    assert window1_authors.stale?
    assert_equal nil, window1.current_document
    assert_windows(window3, :current => window3)

    assert_false window3_author_robert.stale?
    assert_equal window3_author_robert, window3.current_document

    # attempt to close the last window
    window3.close
    assert_windows(window3, :current => window3)
  end

  def test_finding_windows
    window1_authors = PageObjects::Authors::IndexPage.visit
    window1 = window1_authors.window

    window1_authors_robert_row = window1_authors.authors.first
    assert_equal "Robert", window1_authors_robert_row.first_name.text

    window1_authors_robert_row.show_in_new_window

    window2_author_robert = PageObjects::Authors::ShowPage.find
    assert_equal "Robert", window2_author_robert.first_name.text
    window2 = window2_author_robert.window

    assert_windows(window1, window2, :current => window2)

    window1.switch_to

    window1_authors = PageObjects::Authors::IndexPage.visit
    window1_authors_paul_row = window1_authors.authors[1]
    assert_equal "Paul", window1_authors_paul_row.first_name.text

    window1_authors_paul_row.show_in_new_window

    window3_author_paul = PageObjects::Authors::ShowPage.find do
      first_name.text == "Paul"
    end

    window3 = window3_author_paul.window
    assert_windows(window1, window2, window3, :current => window3)

    assert_raises AePageObjects::PageNotFound do
      Capybara.using_wait_time(3) do
        PageObjects::Authors::ShowPage.find do
          first_name.text == "Enri"
        end
      end
    end

    assert_windows(window1, window2, window3, :current => window3)

    index_page = PageObjects::Authors::IndexPage.find
    assert_equal window1, index_page.window
  end

private

  def assert_windows(*windows)
    options = windows.extract_options!

    assert_equal windows.size, windows.uniq.to_set.size
    assert_equal windows.to_set, AePageObjects::Window.registry.values.to_set
    assert_equal windows.to_set, AePageObjects::Window.all.to_set

    if options[:current]
      assert_equal options[:current], AePageObjects::Window.current
    end
  end
end
