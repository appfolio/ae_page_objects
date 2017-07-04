# Development

This page documents how to make changes to AePageObjects including running the test suite.
 
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Tests](#tests)
  - [Coverage](#coverage)
  - [Dependencies](#dependencies)
    - [Supported Capybara versions](#supported-capybara-versions)
    - [Supported Ruby versions](#supported-ruby-versions)
    - [Supported Rails versions](#supported-rails-versions)
  - [Implementation](#implementation)
    - [Appraisals](#appraisals)
  - [Unit tests](#unit-tests)
  - [Integration tests](#integration-tests)
    - [Capybara](#capybara)
      - [Units](#units)
      - [Integration](#integration)
    - [Ruby](#ruby)
    - [Rails](#rails)
  - [CI](#ci)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Tests

The aim of the AePageObjects test suite is to verify both the correctness of internal code and the correctness of
the integration with external code.

Generally, internal correctness is verified via _unit tests_ and correctness with external code is verified via _integration tests_.

## Coverage

Unit tests run against every version of Capybara _at most once_ and against both the minimum and maximum Ruby version _at least once_.

Integration tests run against every version of Rails at least once and every version of Capybara at least once. 

## Dependencies

AePageObjects is tested across various versions of Capybara, Ruby, and Rails. 

### Supported Capybara versions

AePageObjects aims to support all recent versions of Capybara. The currently supported versions of Capybara are listed
in the gemspec.
 
### Supported Ruby versions

AePageObjects supports the same minimum Ruby version as Capybara, which is currently 1.9.3. The minimum Ruby version
is specified in the gemspec.

The test suite tests against the minimum version and a designated maximum version, specified in `.travis.yml`. The test
suite also runs against `ruby-head`, though failures are ignored.

### Supported Rails versions

The `ae_page_objects/rails` fork sets the AePageObjects default router to `AePageObjects::ApplicationRouter` which uses
the built-in Rails router for resolving path declarations.

The router support is tested against various Rails versions matching versioned directories in _test/test_apps_.


## Implementation
 
Tests are run using rake tasks defined in the Rakefile. The rake tasks use [Appraisals](https://github.com/thoughtbot/appraisal)
for running integration tests across versions of dependencies. The test suite run by Travis CI is defined in `.travis.yml`,
which specifies various ENV variables that the tasks defined in Rakefile use to select tests to run.

### Appraisals

The top level Appraisals file is used for running integration tests across Ruby and Capybara versions. The Appraisals
files in the _test/test_apps_ directories are used for running integration tests across Capybara and Rails versions.


## Unit tests

The unit tests are stored in the _test/unit_ directory. To run the unit tests:
 
```
bundle install
rake test:units
```

This will run the unit tests for the current version of Ruby using the Capybara version from the Gemfile.lock file. 

## Integration tests

The integration test suite verifies correctness of the integration of AePageObjects across various versions of Capybara, Ruby, and Rails.

There are 2 types of integration tests:

1. Ruby-only unit tests that run against different versions.
2. Selenium tests that make use of page objects written via AePageObjects and run against a Rails application.
 
### Capybara

#### Units

Various versions of Capybara are tested against using the top level Appraisals file which contains an entry for every supported
version of Capybara.

To run the unit tests against all versions of Capybara using the current Ruby version:

```
rake test:integration:units:install
rake test:integration:units
```

The tests run by the above commands generally stub/mock out Capybara. Running these tests against multiple versions of Capybara verifies 
that the stub/mock setup within the tests works across Capybara versions.

#### Integration

Integration tests using page objects written via AePageObjects run against all versions of Capybara as well. These tests run using a Rails
application, using the most recent version of Rails possible that supports the Ruby version that the version of Capybara under test supports.

Today, all Capybara integration tests are run in the Rails 4.2 application using Ruby 2.2.5. To run these tests:

```
RAILS_VERSION=4.2 rake test:integration:selenium:install
RAILS_VERSION=4.2 rake test:integration:selenium
```


### Ruby

To run the unit tests against different versions of Ruby switch to a different version of Ruby (e.g. a la [rvm](https://rvm.io/))
and run:

```
bundle install
rake test:units
```

### Rails

`AePageObjects::ApplicationRouter` is tested against various versions of Rails in the _test/test_apps_ directory (currently 3.0 to 5.0).
These tests use the most recent Ruby and Capybara versions possible for the version of Rails.
 
To run the integration tests against a specific version of Rails: 

```
RAILS_VERSION=4.0 rake test:integration:selenium:install
RAILS_VERSION=4.0 rake test:integration:selenium
```

## CI

The test suite is run on Travis CI via the `.travis.yml` config, which uses the `test:ci` and `test:ci:install` rake tasks. To run these
locally using the current Ruby version:

```
rake test:ci:install
rake test:ci
```

These rake tasks make use of ENV variables to select which tests to run. The `test:ci` tasks use the ENV variables to select and invoke one of
the rake tasks mentioned in the sections above. See the end of the Rakefile for the logic that determines which rake tasks the `test:ci` tasks map to.
