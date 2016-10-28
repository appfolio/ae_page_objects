# AePageObjects

_Page Objects for Capybara_

[![Gem Version](https://badge.fury.io/rb/ae_page_objects.png)](http://badge.fury.io/rb/ae_page_objects)
[![Build Status](https://api.travis-ci.org/appfolio/ae_page_objects.png?branch=master)](http://travis-ci.org/appfolio/ae_page_objects)
[![Code Climate](https://codeclimate.com/github/appfolio/ae_page_objects.png)](https://codeclimate.com/github/appfolio/ae_page_objects)

AePageObjects provides a powerful and customizable implementation of the Page Object pattern built on top of Capybara to
be used in automated acceptance test suites.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Overview](#overview)
- [Setup](#setup)
  - [Rails](#rails)
  - [Non Rails](#non-rails)
- [Object Model](#object-model)
- [Documents](#documents)
  - [Creating a Document](#creating-a-document)
  - [Adding a Path](#adding-a-path)
  - [Navigation](#navigation)
  - [Load Ensuring](#load-ensuring)
  - [Customizing Load Ensuring](#customizing-load-ensuring)
  - [Windows](#windows)
  - [Multiple Windows](#multiple-windows)
  - [Conventions](#conventions)
    - [Variable Results](#variable-results)
- [Elements](#elements)
  - [Defining Elements](#defining-elements)
  - [Creating elements on the fly](#creating-elements-on-the-fly)
  - [Nested Elements](#nested-elements)
    - [Extending Nested Elements](#extending-nested-elements)
  - [Custom Elements](#custom-elements)
  - [Forms](#forms)
  - [Collections](#collections)
    - [Custom Collections](#custom-collections)
  - [Staling](#staling)
  - [Load Ensuring](#load-ensuring-1)
  - [Checking presence](#checking-presence)
  - [Waiting for presence](#waiting-for-presence)
  - [Checking visibility](#checking-visibility)
  - [Waiting for visibility](#waiting-for-visibility)
  - [Locators](#locators)
    - [Default Locator](#default-locator)
- [Router](#router)
  - [Configuration](#configuration)
    - [Router interface](#router-interface)
    - [Configure default router](#configure-default-router)
    - [Configure router per document](#configure-router-per-document)
  - [Sharing routers across groups of documents](#sharing-routers-across-groups-of-documents)
- [Development](#development)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Overview

Describe the pages of your site by writing Ruby classes.

```ruby
class LoginPage < AePageObjects::Document

  # use Rails URL helpers
  path :new_user_session

  form_for :user do
    element :email
    element :password
  end

  def login!(username, password)
    email.set username
    password.set password

    node.click_on("Log In")

    window.change_to(AuthorsIndexPage)
  end
end

class AuthorsIndexPage < AePageObjects::Document
  path :authors

  collection :authors,
             is:           Table,
             locator:      "table",
             item_locator: "tr" do

    element :first_name, locator: '.first_name'
    element :last_name,  locator: '.last_name'

    def show!
      node.click_link("Show")

      window.change_to(AuthorsShowPage)
    end
  end
end

class AuthorsShowPage < AePageObjects::Document
  path :author

  element :first_name
  element :last_name
end
```

Use the page objects in a test

```ruby
def test_logging_in_goes_to_authors
  login_page = LoginPage.visit
  authors_page = login_page.login_as!('admin', 'password')

  assert_equal AuthorsIndexPage, authors_page.class
end

def test_authors_are_sorted_by_last_name
  Author.create!(first_name: 'Bob', last_name: 'Smith')
  Author.create!(first_name: 'Sponge', last_name: 'Bob')

  authors_page = LoginPage.visit.login_as!('admin', 'password')

  authors = authors_page.authors
  assert_equal 2, authors.size

  sponge_bob = authors.first
  assert_equal "Sponge", sponge_bob.first_name.text
  assert_equal "Bob", sponge_bob.last_name.text

  bob_smith = authors.last
  assert_equal "Bob", bob_smith.first_name.text
  assert_equal "Smith", bob_smith.last_name.text
end

def test_can_navigate_to_author_from_index
  Author.create!(first_name: 'Sponge', last_name: 'Bob')

  authors_page = LoginPage.visit.login_as!('admin', 'password')

  sponge_bob = authors_page.authors.first
  sponge_bob_page = sponge_bob.view!

  assert_equal "Sponge", sponge_bob_page.first_name.text
  assert_equal "Bob", sponge_bob_page.last_name.text
end

def test_can_navigate_to_author_after_logging_in
  sponge_bob = Author.create!(first_name: 'Sponge', last_name: 'Bob')

  LoginPage.visit.login_as!('admin', 'password')

  sponge_bob_page = AuthorsShowPage.visit(sponge_bob)

  assert_equal "Sponge", sponge_bob_page.first_name.text
  assert_equal "Bob", sponge_bob_page.last_name.text
end

```

## Setup

AePageObjects is built to work with any Ruby project using Capybara. To install, add ae_page_objects to your Gemfile:

```ruby
gem 'ae_page_objects'
```

### Rails

AePageObjects is built to work with Rails (versions 3.X-4.X) out of the box. To use with Rails,
add this line to your test helper:

```ruby
require 'ae_page_objects/rails'
```

### Non Rails

AePageObjects works in non-Rails environments out of the box. However, you'll probably want to configure a custom Router.
See [Router](#router) for information.

## Object Model
AePageObjects mirrors the internal design of Capybara's Node hierarchy, whereby:

```
AePageObjects                   Capybara
--------------------            --------------------
Node                            Node::Base
Element < Node                  Node::Element < Node::Base
Document < Node                 Node::Document < Node::Base
```

`AePageObjects::Node` holds a reference (`node`) to the underlying `Capybara::Node::Base`. For
`AePageObjects::Document` the underlying Capybara node is a `Capybara::Node::Document` and for
`AePageObjects::Element` the underlying Capybara node is a `Capybara::Node::Element`. Additionally,
just like in Capybara, every `AePageObjects::Element` has a reference to its parent node. Below is a
UML-ish model detailing the relationships.


```
                 AePageObjects                .                      Capybara

                                              .
                .----------.
                |          |         node     .
      ,---------|   Node   |<>---------------------------------------------.
      |         |          |                  .                            |
      |         `----------'                                          .----------.
      |          ^       ^                    .                       |          |
      |          |       |                                  ,---------|   Node   |
      |          |       |                    .             |         |          |
parent|          |       |                                  |         `----------'
      |          |       |                    .             |          ^       ^
      |          |       |                                  |          |       |
      |    .---------.  .----------.          .             |          |       |
      |    |         |  |          |                  parent|          |       |
      `--<>| Element |  | Document |          .             |          |       |
           |         |  |          |                        |          |       |
           `---------'  `----------'          .             |    .---------.  .----------.
                                                            |    |         |  |          |
                                              .             `--<>| Element |  | Document |
                                                                 |         |  |          |
                                              .                  `---------'  `----------'
```

## Documents

In AePageObjects web pages are represented by `AePageObjects::Document`. This section describes how to create and use
documents.

### Creating a Document

To create a Document, simply subclass `AePageObjects::Document`:

```ruby
class LoginPage < AePageObjects::Document
end
```

### Adding a Path

Most pages on your site will be reachable via a URL. With AePageObjects you can specify the path to your page via the
`path` method:

```ruby
class LoginPage < AePageObjects::Document
  path :new_user_session
end
```

The type of arguments that `path` can take depends on the configured router. For Rails projects, `path` will accept
strings and Rails URL helper names. See [Router](#router) for more details.


### Navigation

Once a path is specified on a document, you can use the document to direct the browser to the page via the `visit`
class method:

```ruby
login_page = LoginPage.visit
```

`visit` navigates the browser to the page and then returns an instance of the document representing the page.

If a  page can be visited by multiple paths. You can use  the `:via` option to specify which path to use. For example:

```ruby
class LoginPage < AePageObjects::Document
  path :new_session
  path :access_autologin
end

# navigates to /session/new
login_page = LoginPage.visit

# navigates to "/autologin/access?token=#{token}"
login_page = LoginPage.visit(token: token, via: :access_autologin)
```

The `visit` method will pass down arguments to the configured router (excluding `via:`). In Rails projects, this means
you can pass in the same arguments you would pass to Rails URL helpers.

### Load Ensuring

When instantiating a `AePageObjects::Document`, AePageObjects verifies that the `AePageObjects::Document` matches the
current page in the web browser. This process is called "load ensuring". For documents, the default load ensuring
mechanism verifies that the page in the browser matches the path of the document. For example, given:

```ruby
class LoginPage < AePageObjects::Document
  path :new_user_session
end
```

If the browser is currently at `http://yoursite.com/users/sign_in`, the following will work:

```ruby
login_page = LoginPage.new
```

However, if the browser is not at that URL, say `http://yoursite.com/dashboard/statistics`, then instantiating the page object
will fail:

```ruby
login_page = LoginPage.new
AePageObjects::LoadingPageFailed: LoginPage cannot be loaded with url '/dashboard/statistics'
  test/selenium/login_test.rb:16:in `new'
```

Sometimes pages can be loaded from multiple paths. `path` can be called multiple times to specify additional paths:

```ruby
class LoginPage < AePageObjects::Document
  path :new_user_session
  path :login
  path '/new_user/login'
end
```

Load ensuring will allow the document to be instantiated if the browser's URL matches any of these paths. The `visit`
method described in [Navigation](#navigation) will always use the value passed to the first call to `path`.

### Customizing Load Ensuring

Sometimes your page's DOM loads quick, but there is significant time spent after the DOM has been loaded in JavaScript
before your page is actually usable. AePageObjects' load ensuring can be used to wait for the page to be ready before
returning control to the users of the page being loaded.

There are two options:

- You can override the `loaded_locator` method to return a locator ([Locators](#locators)) that will be looked for after the URL check is made:

```ruby
class LoginPage < AePageObjects::Document
  path :new_user_session
  path :login
  path '/new_user/login'

private
  def loaded_locator
    [:css, ".something .somewhere", {visible: true}]
  end
end
```

- You can use `is_loaded` to implement any type of checks:

```ruby
class LoginPage < AePageObjects::Document
  path :new_user_session
  path :login
  path '/new_user/login'

  is_loaded { current_url =~ /\?debug\=true/ }
end
```

The `is_loaded` block is meant to return quickly. This means that you should use `#all` and `#first`
instead of the other Capybara::Node::Matchers or Capybara::Node::Finders. All the methods provided
by AePageObjects::ElementProxy are safe as well. All the necessary waiting / rescuing is handled by
the caller of the block.

### Windows

Every document exists within a browser window. The `window` attribute of a `AePageObject::Document` provides access to
the window hosting the document.

### Multiple Windows
_only works when using Selenium::WebDriver_

Sometimes websites launch documents in new windows or tabs. To find a document in another window use `browser.find_document`:

```ruby
  def show_report!(report_name)
    node.click_on("Show #{report_name}")

    browser.find_document(ReportPage)
  end
```

`browser.find_document` can be parameterized with a block to refine the search criteria:

```ruby
  def show_report!(report_name)
    node.click_on("Show #{report_name}")

    browser.find_document(ReportPage) do |report|
      report.filters.date.text == Time.now.to_date
    end
  end
```

### Conventions

A few conventions have evolved to aid in writing maintainable page objects and test code using page objects. Methods
causing the browser to navigate to a new page should:

1. Be ! methods
2. Return a handle to the resulting page by either:
 - calling `window.change_to`, OR
 - calling `browser.find_document`

```ruby
class LoginPage < AePageObjects::Document
  path :new_user_session

  def login!(username, password)
    email.set username
    password.set password

    node.click_on("Log In")

    window.change_to(AuthorsIndexPage)
  end
end

class AuthorsIndexPage < AePageObjects::Document
  def show_report!(report_name)
    node.click_on("Show #{report_name}")

    browser.find_document(ReportPage)
  end
end
```

Some test code using these page objects:

```ruby
def test_logging_in_goes_to_authors
  login_page = LoginPage.visit

  authors_page = login_page.login_as!('admin', 'password')
  assert_equal AuthorsIndexPage, authors_page.class

  books_page = authors_page.show_report!("Book Report")
  assert_equal ReportPage, books_page.class
end
```

Keeping the conventions in mind while reading the above test code should make it clear to the reader that the login_as!
method will be navigating the browser to a new page within the current window; any references to the previous page will
be invalid. Accessing the login_page reference after the browser has changed pages will result in an
`AePageObjects::StalePageObject` error:


```ruby
def test_logging_in_goes_to_authors
  login_page = LoginPage.visit
  authors_page = login_page.login_as!('admin', 'password')

  login_page.email.text

  # above line raises:
  # AePageObjects::StalePageObject: Can't access stale page object '#<LoginPage:0x11c604268>'
end
```

The same is true for the show_report!() method: the report page will open up in a new window, and the caller needs to
use the returned handle to this page.

#### Variable Results

Oftentimes the page that results from a form submission is based on the data entered into the form. This makes following
convention #2 difficult. Additionally, the test code that is entering data into the form has the knowledge to know which
page should result. Both `window.change_to` and `browser.find_document` handle this case by accepting the set of all
possible pages that can result:


```ruby
def login!(username, password)
  email.set username
  password.set password

  node.click_on("Log In")

  window.change_to(AuthorsIndexPage, LoginPage, DashboardPage)
end

def show_report!(report_name)
  node.click_on("Show #{report_name}")

  browser.find_document(ReportPage, DashboardPage)
end

```

In both cases (`window.change_to` or `browser.find_document`) will return a handle to a document matching the parameter
 set: `window.change_to` will only look in the current window while `browser.find_document` will look across all open
 windows. The first parameter to these methods is considered the default page.

Code calling the login!() method can inspect the resultant page before proceeding:

```ruby
result = LoginPage.visit.login!("username", "invalid password")
assert result.is_a?(AuthorsIndexPage)

author_page = result
author_page.first_name.set "New Name"
...
```

Alternatively, the calling code can use `as_a`:

```ruby
author_page = LoginPage.visit.login!("username", "invalid password").as_a(AuthorsIndexPage)
author_page.first_name.set "New Name"
...
```

`as_a` will fail with `AePageObjects::DocumentLoadError` if the page in the browser is not of the specified type.

When `as_a` is not used, an internal implicit cast is made to the default page which ensures that the page is of the
default document type (the first document specified through the parameters of `window.change_to` or
`browser.find_document`). If the check fails, a `AePageObjects::DocumentLoadError` will raise.


## Elements

Elements in AePageObjects represent the DOM elements on a page and are subclasses of `AePageObject::Element`. Just like
in Capybara, all elements have a reference to their parent element. The parent of the topmost element in the element tree
is `AePageObject::Document`.

### Defining Elements

AePageObjects provides a concise DSL for defining elements on a document. Elements defined on a document express the static
structure of your page.

For example:


```ruby
class AuthorsShowPage < AePageObjects::Document
  element :first_name
  element :last_name
end
```

The above use of `element` defines two elements on the page (first_name, and last_name). The elements can be accessed
on an instance of AuthorsShowPage:

```ruby
author_page = AuthorsShowPage.new
author_page.first_name #-> #<AePageObjects::Element:0x11cec0280>@name:<first_name>>
author_page.last_name  #-> #<AePageObjects::Element:0x11cec0346>@name:<last_name>>
```

The methods defined by `element` return instances of `AePageObjects::Element`. When calling these methods AePageObjects
will initialize instances of `AePageObjects::Element` with the underlying `Capybara::Node::Element` matching the element.
How AePageObjects goes about finding the underlying `Capybara::Node::Element` is described by a locator ([Locators](#locators)).

By default AePageObjects will look for DOM elements with ids matching the element's names (so, #first_name and #last_name in
this case). Using the `element` method you can specify a different name to be used for locating the element:

```ruby
class AuthorsShowPage < AePageObjects::Document
  element :first_name
  element :last_name, name: 'sur_name'
end
```

With the definition above, accessing `last_name` will cause AePageObjects to look for an element with id 'sur_name' instead
of 'last_name'.

If you need more control of how the element is located on the page you can specify a locator:

```ruby
class AuthorsShowPage < AePageObjects::Document
  element :first_name
  element :last_name, locator: [:css, '.last_name', {visible: true}]
end
```

See [Locators](#locators) for a discussion of locators.

### Creating elements on the fly

In addition to defining elements to express the static structure of a page, you can also create elements on the fly by
calling the `element` method on a node:

```ruby
some_modal = some_page.element('.dialog')
close_button = some_modal.element('.x-close')
```

`element` will return a new `AePageObjects::Element` object with a `parent` pointer to the object `element` was called
on.

This is useful for designing the page object interface for things like modals which cannot be interacted with until
they are triggered by some action (e.g. a button click). Instead of declaring the modal as a static element of the
Document, you would define a method that corresponds to the action that opens the modal, and this method would yield
the dynamically created element. For example, instead of writing something like:

```ruby
class ShowPage < AePageObjects::Document
  element :share_modal, is: ShareModal # bad because the `share_modal` element
  # can always be accessed, even when the real modal cannot be interacted with

  def share_image(&block)
    node.click_button('Share')
    share_modal.wait_until_visible
    block.call(share_modal)
    share_modal.wait_until_hidden
  end
end
```

you'd write:

```ruby
class ShowPage < AePageObjects::Document
  def share_image(&block)
    node.click_button('Share')
    share_modal = element(locator: '#share_modal', is: ShareModal)
    share_modal.wait_until_visible
    block.call(share_modal)
    share_modal.wait_until_hidden
  end
end
```

which only exposes the `share_image` method on instances of ShowPage (it does not expose a `share_modal` method). Thus,
users can only access a `share_modal` element in the block this method yields to, which is the only time the modal can
*actually* be interacted with.

### Nested Elements

The `element` method can take a block to define nested elements:

```ruby
class AuthorsShowPage < AePageObjects::Document
  element :address do
    element :street
    element :city
  end
end
```

The above definition describes a DOM structure like the following:

```html
<div id="address">
  <div id="address_street"></div>
  <div id="address_city"></div>
</div>
```

All instances of `AePageObjects::Element` have a reference to the parent node ([Elements](#elements)). In addition to
`name` all elements have a `full_name` which is determined by walking the parent reference list all the way up to the
 document and joining the names of the elements along the way with underscore. For example:

```ruby
author_page = AuthorsShowPage.new
author_page.address.full_name         #-> 'address'
author_page.address.name              #-> 'address'

author_page.address.street.full_name  #-> 'address_street'
author_page.address.street.name       #-> 'street'

author_page.address.city.full_name    #-> 'address_city'
author_page.address.city.name         #-> 'city'
```

The ids used for the nested elements (street and city) include the name of the containing element (address). Just like
in the previous examples, you can change the names for any of the elements to match your HTML. For example, this:

```ruby
class AuthorsShowPage < AePageObjects::Document
  element :address, name: 'primary_address' do
    element :street, name: 'street1'
    element :city
  end
end
```

...which results in:

```ruby
author_page = AuthorsShowPage.new
author_page.address.full_name         #-> 'primary_address'
author_page.address.name              #-> 'primary_address'

author_page.address.street.full_name  #-> 'primary_address_street1'
author_page.address.street.name       #-> 'street1'

author_page.address.city.full_name    #-> 'primary_address_city'
author_page.address.city.name         #-> 'city'
```

...and will look for a DOM structure like:

```html
<div id="primary_address">
  <div id="primary_address_street1"></div>
  <div id="primary_address_city"></div>
</div>
```

Notice that the id used to find each element matches the `full_name` of the element. This is because the default locator
uses the `full_name` (see [Default Locator](#default-locator)).

Elements can be nested recursively forever...

```ruby
class AuthorsShowPage < AePageObjects::Document
  element :contact_info do
    element :name
    element :phone_number

    element :address, name: 'primary_address' do
      element :street, name: 'street1'
      element :city
    end
  end
end
```

#### Extending Nested Elements

You can add custom behavior to nested elements by manipulating the nested element's class directly from within the block.
The block passed to `element` is instance_eval'd within the context of a one-off subclass of `AePageObjects::Element`.
Anything you can do to a class, you can do inside of this block.

```ruby
module Toggleable
  def toggle(times)
    times.times do
      hide
      show
    end
  end
end

class AuthorsShowPage < AePageObjects::Document
  element :address do
    include Toggleable

    element :street
    element :city

    def hide
      node.find('.hide-button').click
    end

    def show
      node.find('.show-button').click
    end
  end
end

author_page = AuthorsShowPage.new

# toggle the address
author_page.address.hide()
author_page.address.show()

author_page.address.toggle(7)
```

### Custom Elements

Consider:

```ruby
class AuthorsShowPage < AePageObjects::Document
  element :contact_info do
    element :name
    element :phone_number

    element :address do
      element :street
      element :city
    end
  end
end

class BusinessShowPage < AePageObjects::Document
  element :address do
    element :street
    element :city
  end
end
```

The `address` element in each of these pages uses the exact same structure. Specifying the `:is` option to the element
DSL can be used to reuse common element types. The above rewritten using `:is`:

```ruby
class Address < AePageObjects::Element
  element :street
  element :city
end

class AuthorsShowPage < AePageObjects::Document
  element :contact_info do
    element :name
    element :phone_number

    element :address, is: Address
  end
end

class BusinessShowPage < AePageObjects::Document
  element :address, is: Address
end
```

This is particularly useful when crafting page objects to interact with Rails' partials.

Additionally, `:is` can be used for creating custom element types:

```ruby
class ThreePartDate < AePageObjects::Element
  element :month
  element :day
  element :year

  def value
    Date.new(year.value, month.value, day.value)
  end
end

class AuthorsShowPage < AePageObjects::Document
  element :birth_date, is: ThreePartDate
end

author_page = AuthorsShowPage.new
author_page.birth_date.value # -> "1988-04-01"
```

### Forms

`AePageObjects::Form` is a special type of `AePageObjects::Element` for working with forms. The `form_for` DSL method
can be used to define a form and is a special case of the `element` DSL method.

```ruby
class AuthorsNewPage < AePageObjects::Document
  form_for :author do
    element :first_name
    element :last_name
  end
end
```
...which results in:

```ruby
new_author_page = AuthorsNewPage.new
new_author_page.author                      #-> #<AePageObjects::Form:0x11cec0280>@name:<author>>
new_author_page.author.name                 #-> 'author'
new_author_page.author.full_name            #-> 'author'

new_author_page.first_name                  #-> #<AePageObjects::Element:0x11cec0567>@name:<first_name>>
new_author_page.author.first_name           #-> #<AePageObjects::Element:0x11cec1537>@name:<first_name>>
new_author_page.author.first_name.name      #-> 'first_name'
new_author_page.author.first_name.full_name #-> 'author_first_name'

new_author_page.last_name                   #-> #<AePageObjects::Element:0x11cec0876>@name:<last_name>>
new_author_page.author.last_name            #-> #<AePageObjects::Element:0x11cec3452>@name:<last_name>>
new_author_page.author.last_name.name       #-> 'last_name'
new_author_page.author.last_name.full_name  #-> 'author_last_name'
```

Notice: the nested elements (first_name and last_name) are accessible on the new_author_page.

The above expects a DOM structure like:

```html
<form id="author">
  <input id="author_first_name" />
  <input id="author_last_name" />
</form>
```

### Collections

AePageObject::Collection is used to describe repeated structured data on the page.

```ruby
class AuthorsNewPage < AePageObjects::Document
  form_for :author do
    collection :addresses do
      element :street
      element :city
    end
  end
end
```

...and will look for a DOM structure like:

```html
<div id="addresses">
  <div class="address">
    <input id="author_addresses_0_street" name="addresses[0][street]" />
    <input id="author_addresses_0_city" name="addresses[0][city]" />
  </div>
  <div class="address">
    <input id="author_addresses_1_street" name="addresses[1][street]" />
    <input id="author_addresses_1_city" name="addresses[1][city]" />
  </div>
</div>
```

...which results in:

```ruby
new_author_page = AuthorsNewPage.new
new_author_page.addresses                   #-> #<AePageObjects::Collection:0x11cec0567>@name:<addresses>>
new_author_page.addresses.size              #-> 2
new_author_page.addresses.first.street      #-> #<AePageObjects::Element:0x11cec0567>@name:<street>>
new_author_page.addresses.first.street.full_name #-> 'author_addresses_0_street'
new_author_page.addresses.last.street.full_name #-> 'author_addresses_1_street'
```

The block passed to `collection` is a bit different than the block passed to `element`. With `element` the block defines
nested elements. With `collection` the block defines the structure of each item in the collection. In place of the block
you can pass `:contains`. The following is equivalent to the above:

```ruby
class Address < AePageObjects::Element
  element :street
  element :city
end

class AuthorsNewPage < AePageObjects::Document
  form_for :author do
    collection :addresses, contains: Address
  end
end
```


#### Custom Collections

Sometimes, we'll want a collection that supports more methods
than what the [default implementation](./lib/ae_page_objects/elements/collection.rb)
supports. An easy way to handle this use case is to create a new
class that inherits from `AePageObjects::Collection`:

```ruby
class Address < AePageObjects::Element
  element :street
  element :city
end

class AddressList < AePageObjects::Collection
  def delete_last
    last.click('.delete-button')
  end
end
```

Then, in the page object, use `:is` to specify the collection type:

```ruby
class AuthorsNewPage < AePageObjects::Document
  form_for :author do
    collection :addresses, is: AddressList, contains: Address
  end
end
```

This custom collection is also declared to contain items of the custom
`Address` element subclass. `collection` supports every combination of
`:is`, `:contains`, and the block. See the source for more examples.

### Staling

Sometimes an element only exists on a page temporarily. In such cases, it's a good practice to stale the instance of the
element when it can no longer be interacted with:

```ruby
class AlertBox < AePageObjects::Element
  def ok!
    click_on("Ok")
    stale!
  end

  def close!
    click_on("X")
    stale!
  end
end

class AuthorsShowPage < AePageObjects::Document
  element :alert, is: AlertBox
  element :delete_button, locator: '.delete'
end

def test_logging_in_goes_to_authors
  authors_page = AuthorsShowPage.visit
  authors_page.delete_button.click

  alert_box = authors_page.alert
  alert_box.ok!

  alert_box.close!

  # above line raises:
  # AePageObjects::StalePageObject: Can't access stale page object '#<AlertBox:0x11c604268>'
end
```

### Load Ensuring

The load ensuring mechanism for elements is the same as for documents ([Load Ensuring](#load-ensuring)) just without the URL check.

### Checking presence

Use ```present?``` and ```absent?``` to check the presence of an element on the page:

```ruby
class AuthorsShowPage < AePageObjects::Document
  element :delete_button, locator: '.delete'
end

def test_delete_button_presence
  authors_page = AuthorsShowPage.visit

  assert authors_page.delete_button.present?
  assert ! authors_page.delete_button.absent?
end
```

### Waiting for presence

Use ```wait_until_present``` and ```wait_until_absent``` to wait on an element's presence or absence within the page:

```ruby
class AuthorsShowPage < AePageObjects::Document
  def view_headshots(&block)
    node.click_link("View Headshots")

    viewer = element(locator: '#head-shots', is: HeadshotViewer)
    viewer.wait_until_present(10) # wait 10 seconds

    yield viewer

    viewer.wait_until_absent
  end
end

def test_headshots
  authors_page = AuthorsShowPage.visit
  authors_page.view_headshots do |viewer|
    assert_equal 0, viewer.shots.size
  end
end
```

### Checking visibility

Use ```visible?``` and ```hidden?``` to check whether an element is present and visible on the page:

```ruby
class AuthorsShowPage < AePageObjects::Document
  element :delete_button, locator: '.delete'
end

def test_delete_button_visibility
  authors_page = AuthorsShowPage.visit

  assert authors_page.delete_button.visible?
  assert ! authors_page.delete_button.hidden?
end
```

### Waiting for visibility

Use ```wait_until_visible``` and ```wait_until_hidden``` to wait on an element's visibility:

```ruby
class AuthorsShowPage < AePageObjects::Document
  element :survey
end

def test_survey
  authors_page = AuthorsShowPage.visit

  survey = authors_page.survey
  survey.wait_until_visible
  survey.dismiss!
  survey.wait_until_hidden
end
```

### Locators

Locators in AePageObjects are used to find elements on a page and are expressions of how to locate an element from within
the context of an existing node. Anything that `Capybara::Node::Base::find` supports as arguments can be used as a locator:

```ruby
[:css, '.somecss #selector']                      #-> calls <capybara-node>.find(:css, '.somecss #selector')
'.somecss #selector'                              #-> calls <capybara-node>.find('.somecss #selector')
[:xpath, '//div/tr']                              #-> calls <capybara-node>.find(:xpath, '//div/tr')
['.somecss #selector', {visible: true}]        #-> calls <capybara-node>.find('.somecss #selector', visible: true)
```

`Capybara::Node::Base::find` finds elements from within the context of the element `find` is called on. The same is true
for AePageObjects locators. For example, given this DOM structure:

```html
<div id="div1">
  <div class="highlight"></div>
</div>
<div id="div2">
  <div class="highlight"></div>
</div>
```

..and this locator:

```ruby
[:css, '.highlight']
```

The node found depends on the context of the existing node. If this locator is used within the context of `div#div1` then
the element at `div#div1 .highlight` will be found. If this locator is used within the context of `div#div2` then the
element at `div#div2 .highlight` will be found.

In addition to the valid argument types to `Capybara::Node::Base::find`, locators can also be procs:

```ruby
proc { [:css, ".somecss ##{self.name}", {visible: true}] }
```

Locators that are procs are instance_eval'd within the context of the existing `AePageObject::Node`.

For example:

```ruby
class AuthorsShowPage < AePageObjects::Document
  element :first_name, locator: proc { [:xpath, "//*[contains(@id, '#{name}')]"] }
end

author_page = AuthorsShowPage.new
author_page.first_name            #-> calls <capybara-node>.find(:xpath, "//*[contains(@id, 'first_name')]")
```

#### Default Locator
By default, all instances of `AePageObjects::Element` will use the following locator:


```ruby
proc { "##{__full_name__}" }
```

## Router

The router reads the path specifications on documents and navigates the browser appropriately
(see [Document Navigation](#navigation) for details).

When using in a Rails project, the default router understands Rails' named routes. Consider:

```ruby
class LoginPage < AePageObjects::Document
  path :new_session
end

LoginPage.visit
```

In the above example, `visit` will use the router to determine the URL to use to navigate the browser. The router will
invoke `new_session_path` on the router of the Rails application to determine the URL.

### Configuration

The router can be changed either globally or on a per document basis.

#### Router interface

Routers must implement the following interface:

```ruby
class MyFavRouter
  # returns true if the path specification recognizes the url
  def path_recognizes_url?(path, url)
  end

  # returns a string representing the url
  def generate_path(path, *args)
  end
end
```

The `path` parameter holds the document path specification (`new_session` in the above example). The `url` argument is
the current URL of the browser window. The `args` parameter holds the arguments passed to `visit`.

#### Configure default router

To change the router globally set `AePageObjects.default_router` to an object that implements the router interface:

```ruby
AePageObjects.default_router = MyFavRouter.new
```

#### Configure router per document

To change the router on a per document basis set the `router` property on the document class directly:

```ruby
LoginPage.router = MyFavRouter.new
```

### Sharing routers across groups of documents

In complex applications, it may be necessary to use multiple routers for different groups of documents.
To accomplish this, group document classes under base classes and set the router on the base class.

For example:

```ruby
class AdminDocument < AePageObjects::Document
  self.router = AdminRouter.new
end

class AdminSettingsPage < AdminDocument
  path :admin_settings
end

class ReportDocument < AePageObjects::Document
  self.router = ReportingRouter.new
end

class UsageReportPage < ReportDocument
  path :usage_report
end

class LoginPage < AePageObjects::Document
  path :new_session
end
```

`AdminSettingsPage.visit` will use `AdminRouter`.
`UsageReportPage.visit` will use `ReportingRouter`.
`LoginPage.visit` will use `AePageObjects.default_router`.

## Development

To set up a development environment and run the basic unit tests:

```
bundle install
bundle exec rake
```

See the [Development documentation](development.md) for more detailed information.

