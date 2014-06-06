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

