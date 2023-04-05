
# frozen_string_literal: true
require 'bundler/setup'
Bundler.require(:default)

desc "Run unit tests"
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/unit/**/*_test.rb'
  test.verbose = true

  if test.respond_to?(:warning=)
    test.warning = false
  end
end

namespace :integration do
  desc "Run unit tests for the appraisal environment"
  task :test do
    system("appraisal rake test")
    raise unless $?.exitstatus == 0
  end

  desc "Install dependencies for the appraisal environment"
  task :install do
    system("appraisal install")
    raise unless $?.exitstatus == 0
  end
end

task default: :test
