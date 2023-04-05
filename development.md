# Development

This page documents how to make changes to AePageObjects including running the test suite.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Tests](#tests)
  - [Coverage](#coverage)
  - [Dependencies](#dependencies)
  - [Implementation](#implementation)
    - [Appraisals](#appraisals)
  - [Unit tests](#unit-tests)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Tests

The aim of the AePageObjects test suite is to verify the correctness of internal code via _unit tests_.

## Coverage

Unit tests run against every version of Capybara _at most once_ and against both the minimum and maximum Ruby version _at least once_.

## Dependencies

AePageObjects is tested across various versions of Capybara and Ruby. The currently supported versions of Capybara and Ruby are listed
in the gemspec.

The test suite runs against a range of Ruby versions, specified in `.circle/config.yml`.

## Implementation

Tests are run using rake tasks defined in the Rakefile. The rake tasks use [Appraisals](https://github.com/thoughtbot/appraisal)
for running integration tests across versions of dependencies. The test suite run by CircleCI is defined in `.circleci/config.yml`,
which specifies various ENV variables that the tasks defined in Rakefile use to select tests to run.

### Appraisals

The Appraisals file is used for running integration tests across Ruby and Capybara versions.

## Unit tests

The unit tests are stored in the _test/unit_ directory. To run the unit tests:

```
bundle install
rake test
```

This will run the unit tests for the current version of Ruby using the Capybara version from the `Gemfile.lock` file.
