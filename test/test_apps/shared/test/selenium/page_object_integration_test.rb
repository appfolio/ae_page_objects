require 'selenium_helper'
require 'set'

class PageObjectIntegrationTest < Selenium::TestCase

  def test_load_ensuring
    visit("/books/new")

    exception = assert_raises AePageObjects::LoadingPageFailed do
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
      Author.create!(last_name: 'a')
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

  def test_document_proxy
    new_page = PageObjects::Books::NewPage.visit
    new_page.index.pages.set "132"

    result_page = new_page.save!
    assert_equal true,  result_page.is_a?(AePageObjects::DocumentProxy)
    assert_equal true,  result_page.is_a?(PageObjects::Books::NewPage)
    assert_equal false, result_page.is_a?(PageObjects::Authors::NewPage)

    # test an explicit cast
    new_page = result_page.as_a(PageObjects::Books::NewPage)
    assert_includes new_page.form.error_messages, "Title can't be blank"

    new_page.title.set "Hello World"

    # test an implicit cast
    show_page = new_page.save!
    assert_equal PageObjects::Books::ShowPage, show_page.class
    assert_equal "Hello World", show_page.title.text

    # test invalid cast
    edit_page = show_page.edit!

    result_page = edit_page.save!

    assert_raises AePageObjects::CastError do
      result_page.as_a(PageObjects::Authors::NewPage)
    end

    # test an incorrect cast
    assert_raises AePageObjects::CastError do
      result_page.as_a(PageObjects::Books::EditPage)
    end
  end

  def test_window_change_to
    visit("/books/new")

    result_page = AePageObjects.browser.current_window.change_to(PageObjects::Authors::NewPage,
                                                                 PageObjects::Books::NewPage)

    assert_equal true, result_page.is_a?(PageObjects::Books::NewPage)

    # implicit access attempts to use default document class
    raised = assert_raises AePageObjects::CastError do
      result_page.rating
    end

    assert_equal "PageObjects::Authors::NewPage expected, but PageObjects::Books::NewPage loaded", raised.message

    books_new_page = result_page.as_a(PageObjects::Books::NewPage)

    assert_equal PageObjects::Books::NewPage, books_new_page.class
  end

  def test_window_change_to__multiple_pages
    book = Book.create!(title: 'Brave New World', author: Author.create!(last_name: 'Huxley'))

    visit("/books/#{book.id}")
    result_page = AePageObjects.browser.current_window.change_to(PageObjects::Books::NewPage,
                                                                 PageObjects::Books::ShowPage)
    assert_equal true, result_page.is_a?(PageObjects::Books::ShowPage)

    result_page = AePageObjects.browser.current_window.change_to(PageObjects::Books::ShowPage,
                                                                 PageObjects::Books::NewPage)
    assert_equal true, result_page.is_a?(PageObjects::Books::ShowPage)

    assert_nothing_raised do
      AePageObjects.browser.current_window.change_to(PageObjects::Books::ShowPage)
    end

    assert_raises AePageObjects::DocumentLoadError do
      AePageObjects.browser.current_window.change_to(PageObjects::Books::NewPage)
    end

    visit("/books/new")
    result_page = AePageObjects.browser.current_window.change_to(PageObjects::Books::NewPage,
                                                                 PageObjects::Books::ShowPage)
    assert_equal true, result_page.is_a?(PageObjects::Books::NewPage)

    result_page = AePageObjects.browser.current_window.change_to(PageObjects::Books::ShowPage,
                                                                 PageObjects::Books::NewPage)
    assert_equal true, result_page.is_a?(PageObjects::Books::NewPage)

    assert_nothing_raised do
      AePageObjects.browser.current_window.change_to(PageObjects::Books::NewPage)
    end

    assert_raises AePageObjects::DocumentLoadError do
      AePageObjects.browser.current_window.change_to(PageObjects::Books::ShowPage)
    end
  end

  def test_multiple_paths_visit
    book = Book.create!(title: 'Brave New World', author: Author.create!(last_name: 'Huxley'))

    book_show_page = PageObjects::Books::ShowPage.visit(book)
    assert_equal true, book_show_page.is_a?(PageObjects::Books::ShowPage)

    book_show_page = PageObjects::Books::ShowPage.visit(id: book.id, via: :view_book)
    assert_equal true, book_show_page.is_a?(PageObjects::Books::ShowPage)

    book_show_page = PageObjects::Books::ShowPage.visit(via: "/books/#{book.id}")
    assert_equal true, book_show_page.is_a?(PageObjects::Books::ShowPage)
  end

  def test_element_proxy
    author = PageObjects::Authors::NewPage.visit

    assert author.rating.star.present?
    assert author.rating.star.visible?
    refute author.rating.star.absent?
    refute author.rating.star.hidden?

    assert_nothing_raised do
      author.rating.star.wait_until_present(0)
    end

    assert_raises AePageObjects::ElementNotAbsent do
      author.rating.star.wait_until_absent(1)
    end

    Capybara.using_wait_time(1) do
      author.rating.hide_star
      assert author.rating.star.present?
      refute author.rating.star.visible?
      refute author.rating.star.absent?
      assert author.rating.star.hidden?

      author.rating.show_star
      assert author.rating.star.present?
      assert author.rating.star.visible?
      refute author.rating.star.absent?
      refute author.rating.star.hidden?

      author.rating.remove_star
      refute author.rating.star.present?
      refute author.rating.star.visible?
      assert author.rating.star.absent?
      assert author.rating.star.hidden?
    end
  end

  def test_element_proxy__present_absent_present
    author = PageObjects::Authors::NewPage.visit

    star = author.rating.star
    assert star.present?

    author.rating.remove_star

    # use existing object
    assert star.absent?

    # use new object
    assert author.rating.star.absent?

    author.rating.add_star

    # use existing object
    assert star.present?

    # use new object
    assert author.rating.star.present?
  end

  def test_element_proxy__not_present
    author = PageObjects::Authors::NewPage.visit
    refute author.missing.present?
    assert author.missing.absent?

    assert_nothing_raised do
      author.missing.wait_until_absent(0)
    end

    assert_raises AePageObjects::ElementNotPresent do
      author.missing.wait_until_present(2)
    end
  end

  def test_element_proxy__nested
    author = PageObjects::Authors::NewPage.visit
    Capybara.using_wait_time(0.1) do
      assert author.nested_rating.star.present?

      author.nested_rating.hide_star
      assert author.nested_rating.star.present?
      refute author.nested_rating.star.visible?

      author.nested_rating.show_star
      assert author.nested_rating.star.present?
      assert author.nested_rating.star.visible?

      author.nested_rating.remove_star
      refute author.nested_rating.star.present?
      refute author.nested_rating.star.visible?
    end
  end

  def test_some_collection_enumerables
    Author.delete_all
    index = PageObjects::Authors::IndexPage.visit

    assert_equal 0, index.authors.size

    ActiveRecord::Base.transaction do
      Author.create!(last_name: 'a')
      Author.create!(last_name: 'm')
      Author.create!(last_name: 'u')
      Author.create!(last_name: 't')
      Author.create!(last_name: 'z')
      Author.create!(last_name: '7')
    end

    index = PageObjects::Authors::IndexPage.visit

    assert_equal 6, index.authors.size
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
    refute author.stale?

    visit("/books/new")
    refute author.stale?

    book = PageObjects::Books::NewPage.new
    assert author.stale?
    refute book.stale?

    author = PageObjects::Authors::NewPage.visit
    refute author.stale?
    assert book.stale?

    book = PageObjects::Books::NewPage.visit
    assert author.stale?
    refute book.stale?

    author = PageObjects::Authors::NewPage.visit
    refute author.stale?
    assert book.stale?

    visit("/authors/new")
    refute author.stale?
    assert book.stale?

    assert_raises AePageObjects::LoadingPageFailed do
      PageObjects::Books::NewPage.new
    end

    refute author.stale?
    assert book.stale?
  end

  def test_document_tracking__multiple_windows
    window1_authors = PageObjects::Authors::IndexPage.visit
    window1 = window1_authors.window
    assert_windows(window1, current: window1)

    window1_authors_robert_row = window1_authors.authors.first
    assert_equal "Robert", window1_authors_robert_row.first_name.text

    window1_authors_robert_row.show_in_new_window

    switch_to_window_with_url(author_path(authors(:robert)))

    window2_author_robert = PageObjects::Authors::ShowPage.new

    window2 = window2_author_robert.window
    assert_windows(window1, window2, current: window2)

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
    refute window1_author_robert.stale?

    window2.close
    assert window2_author_robert.stale?
    assert_nil window2.current_document
    assert_windows(window1, current: window1)

    refute window1_author_robert.stale?
    assert_equal window1_author_robert, window1.current_document

    # close a window without an explicit switch
    window1_authors = PageObjects::Authors::IndexPage.visit
    window1_authors_robert_row = window1_authors.authors.first
    window1_authors_robert_row.show_in_new_window

    switch_to_window_with_url(author_path(authors(:robert)))
    window3_author_robert = PageObjects::Authors::ShowPage.new
    window3 = window3_author_robert.window

    assert_windows(window1, window3, current: window3)

    window1.close
    assert window1_authors.stale?
    assert_nil window1.current_document
    assert_windows(window3, current: window3)

    refute window3_author_robert.stale?
    assert_equal window3_author_robert, window3.current_document

    # attempt to close the last window
    window3.close
    assert_windows(window3, current: window3)
  end

  def test_finding_windows
    window1_authors = PageObjects::Authors::IndexPage.visit
    window1 = window1_authors.window

    window1_authors_robert_row = window1_authors.authors.first
    assert_equal "Robert", window1_authors_robert_row.first_name.text

    window1_authors_robert_row.show_in_new_window

    window2_author_robert = AePageObjects.browser.find_document(PageObjects::Authors::ShowPage)
    assert_equal "Robert", window2_author_robert.first_name.text
    window2 = window2_author_robert.window

    assert_windows(window1, window2, current: window2)

    window1.switch_to

    window1_authors = PageObjects::Authors::IndexPage.visit
    window1_authors_paul_row = window1_authors.authors[1]
    assert_equal "Paul", window1_authors_paul_row.first_name.text

    window1_authors_paul_row.show_in_new_window

    window3_author_paul = AePageObjects.browser.find_document(PageObjects::Authors::ShowPage) do |author|
      author.first_name.text == "Paul"
    end

    window3 = window3_author_paul.window
    assert_windows(window1, window2, window3, current: window3)

    assert_raises AePageObjects::DocumentLoadError do
      Capybara.using_wait_time(3) do
        AePageObjects.browser.find_document(PageObjects::Authors::ShowPage) do |author|
          author.first_name.text == "Enri"
        end
      end
    end

    assert_windows(window1, window2, window3, current: window3)

    index_page = AePageObjects.browser.find_document(PageObjects::Authors::IndexPage)
    assert_equal window1, index_page.window
  end

  def test_finding_windows__using_find_document_in_page_objects
    window1_authors = PageObjects::Authors::IndexPage.visit
    window1 = window1_authors.window

    window1_authors_robert_row = window1_authors.authors.first
    assert_equal "Robert", window1_authors_robert_row.first_name.text

    window2_author_robert = window1_authors_robert_row.show_in_new_window!

    assert_equal "Robert", window2_author_robert.first_name.text
    window2 = window2_author_robert.window

    assert_windows(window1, window2, current: window2)

    window1.switch_to

    window1_authors = PageObjects::Authors::IndexPage.visit
    window1_authors_paul_row = window1_authors.authors[1]
    assert_equal "Paul", window1_authors_paul_row.first_name.text

    window3_author_paul = window1_authors_paul_row.show_in_new_window_with_name!("Paul")

    window3 = window3_author_paul.window
    assert_windows(window1, window2, window3, current: window3)

    window3_authors = PageObjects::Authors::IndexPage.visit
    window3_authors_paul_row = window1_authors.authors[1]
    assert_equal "Paul", window3_authors_paul_row.first_name.text

    assert_raises AePageObjects::DocumentLoadError do
      Capybara.using_wait_time(3) do
        window3_authors_paul_row.show_in_new_window_with_name!("Enri")
      end
    end
  end

  def test_find_document_iterates_over_all_windows__element_not_found
    ActiveRecord::Base.transaction do
      Author.create!(first_name: 'Andrew', last_name: "Putz")
    end

    authors = PageObjects::Authors::IndexPage.visit
    window1 = authors.window

    # open 3 more windows

    robert = authors.authors[0].show_in_new_window_with_name!("Robert")
    window2 = robert.window

    window1.switch_to

    andrew = authors.authors[1].show_in_new_window_with_name!("Andrew")
    window3 = andrew.window

    window1.switch_to

    default_wait_time = 7

    # Setup 4th window to delay displaying last_name
    AuthorsController.last_name_display_delay_ms = (default_wait_time - 2) * 1000

    paul = authors.authors[2].show_in_new_window_with_name!("Paul")
    window4 = paul.window

    AuthorsController.last_name_display_delay_ms = nil

    # Look for the last name in window 4.
    window_visit_registry = {}
    found = Capybara.using_wait_time(default_wait_time) do
      AePageObjects.browser.find_document(PageObjects::Authors::ShowPage) do |author|
        # track counts to verify windows are flipped through
        window_visit_registry[author.window.handle] ||= 0
        window_visit_registry[author.window.handle] += 1

        author.last_name.text == "Robertson"
      end
    end

    assert_equal window4.handle, found.window.handle

    # Firefox opens new tabs adjacent to the current tab so the order of windows is going to be:
    #   window1, window4, window3, window2.
    # Since the document we're looking for is in window4, we should have
    # visited all the windows one less time than the number of times we visited the 4th window
    assert_equal window_visit_registry[window4.handle] - 1, window_visit_registry[window2.handle]
    assert_equal window_visit_registry[window4.handle] - 1, window_visit_registry[window3.handle]

    # we should have iterated over the windows more than once.
    assert_operator window_visit_registry[window4.handle], :>, 1

    assert_windows(window1, window2, window3, window4, current: window4)
  end

  def test_find_document_iterates_over_all_windows__window_loading_lags
    ActiveRecord::Base.transaction do
      Author.create!(first_name: 'Andrew', last_name: "Putz")
    end

    authors = PageObjects::Authors::IndexPage.visit
    window1 = authors.window

    robert = authors.authors[0].show_in_new_window_with_name!("Robert")
    window2 = robert.window

    window1.switch_to

    andrew = authors.authors[1].show_in_new_window_with_name!("Andrew")
    window3 = andrew.window

    opened_windows = [window1, window2]

    windows = AePageObjects.browser.windows

    call = 0
    windows.singleton_class.send(:define_method, :opened) do
      call += 1

      if call == 1
        opened_windows
      else
        super()
      end
    end

    window1.switch_to

    # Look for the last name in window 4.
    window_visit_registry = {}
    found = AePageObjects.browser.find_document(PageObjects::Authors::ShowPage) do |author|
      # track counts to verify windows are flipped through
      window_visit_registry[author.window.handle] ||= 0
      window_visit_registry[author.window.handle] += 1

      author.last_name.text == "Putz"
    end

    assert_equal window3, found.window

    # window1 has IndexPage, so the block above isn't called
    assert_nil window_visit_registry[window1.handle]
    assert_equal 1, window_visit_registry[window2.handle]
    assert_equal 1, window_visit_registry[window3.handle]

    assert_windows(window1, window2, window3, current: window3)
  ensure
    windows = AePageObjects.browser.windows
    windows.singleton_class.send(:remove_method, :opened)
  end

  def test_find_document__ignores_stale_windows
    Author.create!(first_name: 'Andrew', last_name: "Putz")

    authors = PageObjects::Authors::IndexPage.visit
    window1 = authors.window

    robert = authors.authors[0].show_in_new_window_with_name!("Robert")
    window2 = robert.window

    window1.switch_to

    andrew = authors.authors[1].show_in_new_window_with_name!("Andrew")
    window3 = andrew.window

    assert_windows(window1, window2, window3, current: window3)

    window3.switch_to

    andrew.close_via_js!

    # walk the windows
    assert_nothing_raised do
      AePageObjects.browser.find_document(PageObjects::Authors::IndexPage)
      AePageObjects.browser.find_document(PageObjects::Authors::ShowPage) do |author|
        author.first_name.text == "Robert"
      end
      AePageObjects.browser.find_document(PageObjects::Authors::IndexPage)
    end

    assert_windows(window1, window2, current: window1)
  end

  def test_element_reload_ancestors
    new_author_page = PageObjects::Authors::NewPage.visit
    new_author_page.first_name.set "Michael"

    # Cache the nested `books` collection
    books = new_author_page.books
    books.at(0).title.set 'something else'

    # Reload the page. The cached node in the `books` collection is now obsolete
    Capybara.current_session.driver.execute_script('location.reload(true)')
    AePageObjects.wait_until { new_author_page.first_name.value.blank? }

    # After reload the correct element should be found
    assert_nothing_raised do
      assert_equal '', books.at(0).title.value
    end
  end

private

  def assert_windows(*windows)
    options = windows.extract_options!

    assert_equal windows.size, windows.uniq.to_set.size
    assert_equal windows.to_set, AePageObjects.browser.windows.instance_variable_get(:@windows).values.to_set
    assert_equal windows.to_set, AePageObjects.browser.windows.opened.to_set

    if options[:current]
      assert_equal options[:current], AePageObjects.browser.windows.current_window
    end
  end

  def switch_to_window_with_url(path)
    if Gem::Requirement.new("< 2.3.0").satisfied_by?(Gem::Version.new(Capybara::VERSION))
      Capybara.current_session.driver.within_window(path)
    else
      Capybara.current_session.switch_to_window do
        Capybara.current_session.current_url =~ /#{path}$/
      end
    end
  end
end
