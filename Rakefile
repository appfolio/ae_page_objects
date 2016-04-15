# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'fileutils'

require 'rake'
require 'appraisal'

require 'rake/testtask'

require 'pp'


Bundler::GemHelper.install_tasks

def remove_files(glob_pattern)
  puts "Removing '#{glob_pattern}'"
  FileUtils.rm_f Dir[glob_pattern]
end

class SeleniumRunner

  TestConfig = Struct.new(:rails_version, :gemfile)

  def initialize(options = {})
    @options       = options
    @matrix        = read_matrix
  end

  def clean
    remove_files("test/test_apps/**/gemfiles/*.lock")
  end

  def install_all
    @matrix.values.each do |test_configs|
      test_configs.each do |test_config|
        install_config(test_config)
      end
    end
  end

  def install_all_for(rails_version)
    @matrix[rails_version].each do |test_config|
      install_config(test_config)
    end
  end

  def run_all_tests
    # Run tests for newest Rails' versions first
    @matrix.keys.sort.reverse.each do |rails_version|
      run_all_tests_for(rails_version)
    end
  end

  def run_all_tests_for(rails_version)
    rails_versions = @matrix[rails_version]
    if !rails_versions || rails_versions.empty?
      puts "Tests for #{rails_version} can't run on #{RUBY_VERSION}"
      return
    end

    rails_versions.each do |test_config|
      run_test(test_config.gemfile, "test/test_apps/#{rails_version}", "bundle exec rake test:selenium")
    end
  end

private

 def install_config(test_config)
   appraisal = Appraisal::Appraisal.new("name", test_config.gemfile)

   def appraisal.gemfile_path
     @gemfile_path
   end

   appraisal.instance_variable_set(:@gemfile_path, test_config.gemfile)

   if @options[:dry]
     puts "Installing: #{test_config.gemfile}"
   else
     appraisal.install
   end
 end

  # Appraisal::Command almost has what I need: a way to run things without Bundler/Ruby
  # Env variables. The subclassing is to override the initializer to not modify the command.
  class Command < Appraisal::Command
    def initialize(command, gemfile = nil)
      @original_env = {}
      @gemfile = gemfile
      @command = command
    end
  end

  def run_test(gemfile, directory, command)
    puts "---------------------",
         'Test Config',
         "Gemfile: #{gemfile}",
         "Command: '#{command}'",
         "---------------------"

    with_gemfile_symlink(directory, gemfile, "Gemfile") do
      if !@options[:dry]
        Command.new("cd #{directory} && #{command}", gemfile).run
      end
    end
  end

  def with_gemfile_symlink(directory, use_gemfile, app_gemfile)
    run_command("cd #{directory} && ln -sf #{use_gemfile} #{app_gemfile}")
    run_command("cd #{directory} && ln -sf #{use_gemfile}.lock #{app_gemfile}.lock")

    yield

    run_command("cd #{directory} && git checkout -- #{app_gemfile}")
    run_command("rm -f #{directory}/#{app_gemfile}.lock")
  end

  def read_matrix
    file_pattern = "test/test_apps/**/gemfiles/*ruby#{RUBY_VERSION}*.gemfile"

    matrix = {}

    Dir.glob(file_pattern).each do |file|
      matches = file.match(%r{test/test_apps/(\d\.\d)/gemfiles/(.*ruby(\d\.\d\.\d)\.gemfile)})

      gemfile_path  = matches[0]
      rails_version = matches[1]
      gemfile       = matches[2]
      ruby_version  = matches[3]

      matrix[rails_version] ||= []
      matrix[rails_version] << TestConfig.new(rails_version, File.expand_path("../#{gemfile_path}", __FILE__))
    end

    matrix
  end

  def run_command(command)
    puts "Running '#{command}'"

    if ! @options[:dry]
      `#{command}`
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
      system("bundle exec rake -s appraisal test:units")
      raise unless $?.exitstatus == 0
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

  if ! (ENV['RAILS_VERSION'].nil? ^ ENV['UNITS'].nil?)
    ci_install = ["appraisal:install", "test:integration:selenium:install"]
    ci_task    = ['test:integration:units', 'test:integration:selenium']
  elsif ENV['RAILS_VERSION']
    ci_install = "test:integration:selenium:install"
    ci_task    = 'test:integration:selenium'
  elsif ENV['UNITS']
    ci_install = "appraisal:install"
    ci_task    = 'test:integration:units'
  end

  namespace :ci do
    desc "Remove gemfiles in test apps and all lock files"
    task :clean => ["test:integration:selenium:clean"] do
      remove_files("test/test_apps/**/Gemfile.lock")
      remove_files("gemfiles/*.lock")
      remove_files("Gemfile.lock")
    end
    desc "Resolve and install dependencies for unit and integration test"
    task :install => ci_install
  end

  desc "Run the unit and integration test for all appraisals"
  task :ci => ci_task
end

desc 'Default: run the unit and integration tests.'
task :default => ['test:units', 'test:integration:selenium']
