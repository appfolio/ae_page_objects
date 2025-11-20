# frozen_string_literal: true

require 'bundler'
require 'fileutils'

require 'rake'
require 'appraisal'

require 'rake/testtask'

Bundler::GemHelper.install_tasks

def remove_files(glob_pattern)
  puts "Removing '#{glob_pattern}'"
  FileUtils.rm_f Dir[glob_pattern]
end

class SeleniumRunner

  TestConfig = Struct.new(:rails_version, :test_app_root, :gemfile)

  def initialize(options = {})
    @options = options
    @matrix  = read_matrix
  end

  def clean
    remove_files("test/test_apps/**/gemfiles/*.lock")
  end

  def appraise
    Dir.glob("test/test_apps/*/Appraisals").each do |appraisal_file|
      test_app_directory = File.dirname(appraisal_file)

      begin
        run_command("cd #{test_app_directory} && bundle check || bundle install")
        run_command("cd #{test_app_directory} && appraisal generate")
      rescue => e
        puts e.class
        puts e.message
      end
    end
  end

  def install_all
    @matrix.keys.each do |rails_version|
      install_all_for(rails_version)
    end
  end

  def install_all_for(rails_version)
    test_config = @matrix[rails_version].first
    run_command("cd #{test_config.test_app_root} && bundle check || bundle install")
    run_command("cd #{test_config.test_app_root} && appraisal install")
  end

  def run_all_tests
    # Run tests for newest Rails' versions first
    @matrix.keys.sort.reverse.each do |rails_version|
      run_all_tests_for(rails_version)
    end
  end

  def run_all_tests_for(rails_version)
    gemfiles_for_rails_version = @matrix[rails_version]
    if !gemfiles_for_rails_version || gemfiles_for_rails_version.empty?
      puts "Tests for #{rails_version} can't run on #{RUBY_VERSION}"
      return
    end

    gemfiles_for_rails_version.each do |test_config|
      run_test(test_config, "bundle exec rake test:selenium")
    end
  end

  private

  def run_test(test_config, command)
    puts "---------------------",
         'Test Config',
         "Gemfile: #{test_config.gemfile}",
         "Directory: #{test_config.test_app_root}",
         "Command: '#{command}'",
         "---------------------"

    run_command("cd #{test_config.test_app_root} && #{command}", test_config.gemfile)
  end

  def read_matrix
    file_pattern = "test/test_apps/**/gemfiles/*ruby_#{RUBY_VERSION}*.gemfile"

    matrix = {}

    Dir.glob(file_pattern).each do |file|
      matches = file.match(%r{(test/test_apps/(\d\.\d))/gemfiles/(.*ruby_(\d\.\d\.\d)\.gemfile)})

      gemfile_path  = matches[0]
      app_root      = matches[1]
      rails_version = matches[2]

      matrix[rails_version] ||= []
      matrix[rails_version] << TestConfig.new(rails_version, app_root, File.expand_path("../#{gemfile_path}", __FILE__))
    end

    matrix
  end

  def run_command(command, gemfile = nil)
    if gemfile
      command = "BUNDLE_GEMFILE=#{gemfile} #{command}"
    end

    puts "Running '#{command}'"
    return if @options[:dry]

    specific_gemfile_env = Bundler.clean_env

    if gemfile
      specific_gemfile_env['BUNDLE_GEMFILE'] = gemfile
    end

    Bundler.send(:with_env, specific_gemfile_env) do
      system(command)
      raise unless $?.exitstatus == 0
    end
  end
end

def selenium_runner
  SeleniumRunner.new(:dry => ENV['DRY'])
end

namespace :test do
  desc "Run unit test for ae_page_objects"
  Rake::TestTask.new(:units) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/unit/**/*_test.rb'
    test.verbose = true

    if test.respond_to?(:warning=)
      test.warning = false
    end
  end

  namespace :integration do
    desc "Run unit test for ae_page_objects under appraisal environment"
    task :units do
      system("appraisal rake test:units")
      raise unless $?.exitstatus == 0
    end

    namespace :units do
      task :install do
        system("appraisal install")
        raise unless $?.exitstatus == 0
      end
    end

    namespace :selenium do
      desc "Resolve and install dependencies for all test apps"
      task :install do
        rails_version = ENV['RAILS_VERSION']
        if rails_version
          selenium_runner.install_all_for(rails_version)
        else
          selenium_runner.install_all
        end
      end

      desc "Remove gemfiles in test apps"
      task :clean do
        selenium_runner.clean
      end

      desc "Create gemfiles in all test apps for current version of Ruby"
      task :appraise do
        selenium_runner.appraise
      end
    end

    desc "Run selenium tests on all apps."
    task :selenium do
      rails_version = ENV['RAILS_VERSION']
      if rails_version
        selenium_runner.run_all_tests_for(rails_version)
      else
        selenium_runner.run_all_tests
      end
    end
  end

  ci_install = nil
  ci_task    = nil

  if !(ENV['RAILS_VERSION'].nil? ^ ENV['UNITS'].nil?)
    ci_install = ["test:integration:units:install", "test:integration:selenium:install"]
    ci_task    = ['test:integration:units', 'test:integration:selenium']
  elsif ENV['RAILS_VERSION']
    ci_install = "test:integration:selenium:install"
    ci_task    = 'test:integration:selenium'
  elsif ENV['UNITS']
    ci_install = "test:integration:units:install"
    ci_task    = 'test:integration:units'
  end

  namespace :ci do
    desc "Remove all gem lock files"
    task :clean => ["test:integration:selenium:clean"] do
      remove_files("test/test_apps/**/Gemfile.lock")
      remove_files("gemfiles/*.lock")
      remove_files("Gemfile.lock")
    end
    desc "Resolve and install dependencies for unit and integration test"
    task :install do
      Array(ci_install).each do |task|
        Rake::Task[task].invoke
      end
    end
  end

  desc "Run the unit and integration test for all appraisals"
  task :ci do
    Array(ci_task).each do |task|
      Rake::Task[task].invoke
    end
  end
end

desc 'Default: run the unit and integration tests.'
task :default => ['test:units', 'test:integration:selenium']
