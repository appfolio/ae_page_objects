## Version 3.1.1

### Fixed

* [199](https://github.com/appfolio/ae_page_objects/pull/199)
  * Fixes [142](https://github.com/appfolio/ae_page_objects/issues/142)

## Version 3.1.0

### Changed

* [198](https://github.com/appfolio/ae_page_objects/pull/198) Add Rails 5.0 support for ae_page_objects router
* [197](https://github.com/appfolio/ae_page_objects/pull/197) Fix documentation

## Version 3.0.0

### Changed

* [194](https://github.com/appfolio/ae_page_objects/pull/194) Changed AePageObjects.wait_until semantics and changed ensure loaded interface.

  This change improves `browser.find_document`, `window.change_to`, and all the method like
  `absent?` / `wait_until_absent` on `ElementProxy` by not relaying on
  `Capybara.using_wait_time(0)`. This results in three backward incompatible changes,

  #### AePageObjects.wait_until

  Previously, `AePageObjects.wait_until` was not aware of nested invocations. So that:

     ```ruby
     AePageObjects.wait_until(5) do
       AePageObjects.wait_until(60) do
         false
       end
     end
     ```
  resulting in the outer invocation waiting 5 seconds and the inner invocation waiting 60 seconds.

  Now, `AePageObjects.wait_until` keeps track of nested invocations and only the outer most
  invocation matters,

     ```ruby
     AePageObjects.wait_until(5) do
       AePageObjects.wait_until(60) do
         false
       end
     end
     ```

  resulting in the outer invocation waiting 5 seconds and the inner invocation not waiting at all.

  #### ensure_loaded!

  Previously, one would implement 'load ensuring' by overriding `ensure_loaded!`,

    ```ruby
    class Page < AePageObjects::Document
      private
      def ensure_loaded!
        super
        raise LoadingPageFailed unless title == 'Hi There'
      end
    end
    ```

  Now, one should implement `load ensuring` via the `is_loaded` dsl,

    ```ruby
    class Page < AePageObjects::Document
      is_loaded { title == 'Hi There' }
    end
    ```

  Note, there is no need to remember to call super nor catch Selenium / Capybara exceptions. The
  is_loaded block should return quickly. That means using `#all` / `#first` instead of the other
  Capybara matchers / finders. For example, to check whether the page contains an element with a
  certain id, you want to do,

    ```ruby
    class Page < AePageObjects::Document
      is_loaded { !node.first('#foo').nil? }
    end
    ```

  as opposed to,

    ```ruby
    class Page < AePageObjects::Document
      is_loaded { node.has_selector?('#foo') }
    end
    ```

  Don't worry, the caller of is_loaded blocks will correctly wait / rescue exceptions.

  #### more separation between AePageObjects / Capybara

  Finally, `#find` and `#all` on `AePageObjects::Node` are no longer delegated to `node`. So
  instead of,

    ```ruby
    class Page < AePageObjects::Document
      def produce_halloween_candy
        find('#candy-producer').click
      end
    end
    ```

  you simply grab the node first,

    ```ruby
    class Page < AePageObjects::Document
      def produce_halloween_candy
        node.find('#candy-producer').click
      end
    end
    ```

## Version 2.0.1

### Bugs

* [189](https://github.com/appfolio/ae_page_objects/pull/189) Fixed the behavior of `AePageObjects::Collection` when options are passed within `item_locator`.

  Previously options passed such as `visible` or `text` below would have been ignored:

    ```ruby
    collection :children, item_locator: ['li', { visible: true, text: 'Hello World' }]
    ```

* [191](https://github.com/appfolio/ae_page_objects/pull/191) Fixed performance issue with `AePageObjects::Collection.each`

## Version 2.0.0

### Added

* [179](https://github.com/appfolio/ae_page_objects/pull/179) Add Node#element element factory to create elements off of existing elements.
* [111](https://github.com/appfolio/ae_page_objects/issues/111) Adding wait: option to all polling query methods.

### Changed

* [176](https://github.com/appfolio/ae_page_objects/pull/176) Limit exposed constants to _public_ API.
* [175](https://github.com/appfolio/ae_page_objects/issues/175) Use `BasicRouter` as default. Move Rails support to `ae_page_objects/rails`.
* [107](https://github.com/appfolio/ae_page_objects/issues/107) Replaced `Site` and `Document.site` with `AePageObjects.default_router` and `Document.router`
* [82](https://github.com/appfolio/ae_page_objects/pull/82) Removed Ruby 1.8.7 support
* [119](https://github.com/appfolio/ae_page_objects/issues/119) Remove Support for Rails 2.3

## Version 1.5.0

### Bugs

* [125](https://github.com/appfolio/ae_page_objects/issues/125) ElementProxy presence checks should invalidate cache

### Added

* [81](https://github.com/appfolio/ae_page_objects/issues/81) Support Capybara < 2.8
* [99](https://github.com/appfolio/ae_page_objects/issues/99) Need a replacement for Capybara.wait_until
* [136](https://github.com/appfolio/ae_page_objects/issues/136) stale! should be public

## Version 1.4.1

### Bugs

* [128](https://github.com/appfolio/ae_page_objects/pull/128) Fix method_missing for "class" in ElementProxy
* [116](https://github.com/appfolio/ae_page_objects/pull/116) Do not support block handling in element define method. Fixes [112](https://github.com/appfolio/ae_page_objects/issues/112)

### Added

* [134](https://github.com/appfolio/ae_page_objects/pull/134) Change current_url_without_params to strip anchors as well as parameters
* [121](https://github.com/appfolio/ae_page_objects/pull/121) Add Deprecation Warnings
* [103](https://github.com/appfolio/ae_page_objects/pull/103) Enhance visit to support multiple paths

## Version 1.4.0

### Bugs
* Fix [63](https://github.com/appfolio/ae_page_objects/issues/63) Routing incorrectly matches documents

### Added
* [96](https://github.com/appfolio/ae_page_objects/issues/96) AePageObjects::Waiter.wait_until should detect when time is frozen
* [108](https://github.com/appfolio/ae_page_objects/issues/108) Support Rails 4.1 & 4.2
* Ruby 2.2 support

## Version 1.3.0

### Added

* [86](https://github.com/appfolio/ae_page_objects/pull/86) Added Waiter.wait_until!, ElementProxy#wait_until_visible, ElementProxy#wait_until_hidden

## Version 1.2.1

### Bugs

* Reverted fix for [63](https://github.com/appfolio/ae_page_objects/issues/63) Routing incorrectly matches documents

## Version 1.2.0

### Bugs

* [63](https://github.com/appfolio/ae_page_objects/issues/63) Routing incorrectly matches documents
* [64](https://github.com/appfolio/ae_page_objects/issues/64) browser.find_document should ignore Selenium::WebDriver::Error::NoSuchWindowError
* [65](https://github.com/appfolio/ae_page_objects/issues/65) ElementProxy#not_present? does not wait for element to be absent.

### Added

* [72](https://github.com/appfolio/ae_page_objects/pull/72) & [74](https://github.com/appfolio/ae_page_objects/pull/74) Wrap Capybara exceptions
* [77](https://github.com/appfolio/ae_page_objects/pull/77) Update Waiter.wait_for to accept timeout argument
* [78](https://github.com/appfolio/ae_page_objects/pull/78) Add wait_for_* methods to ElementProxy

### Maintenance

* [75](https://github.com/appfolio/ae_page_objects/pull/75) & [76](https://github.com/appfolio/ae_page_objects/pull/76) Remove Node.new_subclass

## 1.1.3

* Issue [74](https://github.com/appfolio/ae_page_objects/pull/74)

## 1.1.2

* Issue [69](https://github.com/appfolio/ae_page_objects/pull/69)

## 1.1.1

* Test against Rails 4
* Issue [Wrapped Capybara::ElementNotFound error in AePageObjects::LoadingElementFailed](https://github.com/appfolio/ae_page_objects/pull/67)

## 1.1.0

* Multiple window support:
 - window.change_to
 - browser.find_document

## 1.0.2

* Issue [Changed Waiter to not use Timeout #57](https://github.com/appfolio/ae_page_objects/issues/57)

## 1.0.1

* Issue [Load ensuring for documents should poll on the url #53](https://github.com/appfolio/ae_page_objects/issues/53)

## 1.0.0

* Support Capybara 2
* Removed block support from Element.new
* Change ElementProxy visibility methods to wait

## 0.5.2

* A few Collection improvements

## 0.5.0

* introduced Window management
* Collection enhancements:
 - implements Enumerable
 - removed append support
 - accept any type of locator for items
 - return ElementProxy instead of Element for items
 - refactor to make overriding easier

## 0.4.1

* bug fix

## 0.4.0

* added support for Rails 2.3
* renamed Application to Site
* removed argument to Document.initialize
* removed nokogiri dependency

## 0.3.0

* removed activesupport dependency
* added README

## 0.2.0

* removed auto and eager loading support
* set activesupport dependency to (~> 3.0)

## 0.1.3

* fixed bug relating to full_name traversal

## 0.1.2

* fixed nokogiri dependency to ~>1.5.9 for ruby 1.8.7 support
* reinstated multiple autoload paths support

## 0.1.1

* collapsed eagerload and autoload paths into a single path
* reinstated using a root_path based on the path of where Application is subclassed.

## 0.1.0

* initial release

