# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'fileutils'

require 'rake'
require 'appraisal'

require 'rake/testtask'

require 'pp'


Bundler::GemHelper.install_tasks

class SeleniumRunner

  TestConfig = Struct.new(:rails_version, :gemfile)

  SELENIUM_GEMFILES_PATH = File.expand_path("../selenium_gemfiles", __FILE__)

  def initialize(options = {})
    @options       = options
    @gemfiles_path = SELENIUM_GEMFILES_PATH
    @matrix        = read_matrix

    puts "Test Matrix:"
    pp @matrix
  end

  def cleanup
    FileUtils.rm_f Dir["#{@gemfiles_path}/**/*.lock"]
  end

  def install_all
    @matrix.each do |rails_version, test_configs|
      test_configs.each do |test_config|
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
    end
  end

  def run_all_tests
    @matrix.keys.each do |rails_version|
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
      run_test_in test_config.gemfile, "test/test_apps/#{rails_version}"
    end
  end

private

  def run_test_in(gemfile, directory)
    env = ["BUNDLE_GEMFILE=#{gemfile}"]
    env << "TEST=../../#{ENV['TEST']} " if ENV['TEST']
    run_in(directory, "#{env.join(" ")} bundle exec rake test:selenium")
  end

  def run_in(directory, command)
    puts '', directory, ' ', command
    with_pruned_env('BUNDLE_GEMFILE') do
      return if @options[:dry]
      system("cd #{directory} && #{command}")
      raise unless $?.exitstatus == 0
    end
  end

  def with_pruned_env(key_to_withhold, &block)
    withholding = ENV.delete(key_to_withhold)
    tap{ |r| r = yield; ENV[key_to_withhold] = withholding }
  end

  def read_matrix
    file_pattern = "#{@gemfiles_path}/**/*ruby#{RUBY_VERSION}*.gemfile"

    matrix = {}

    Dir.glob(file_pattern).each do |file|
      matches = file.match(/#{@gemfiles_path}\/rails(\d\.\d)\/(.*ruby(\d\.\d\.\d)\.gemfile)/)

      gemfile_path  = matches[0]
      rails_version = matches[1]
      gemfile       = matches[2]
      ruby_version  = matches[3]

      matrix[rails_version] ||= []
      matrix[rails_version] << TestConfig.new(rails_version, gemfile_path)
    end

    matrix
  end
end

def selenium_runner
  SeleniumRunner.new(:dry => ENV['DRY'])
end

namespace :test do
  Rake::TestTask.new(:units) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/unit/**/*_test.rb'
    test.verbose = true
  end

  namespace :integration do
    task :units do
      system("bundle exec rake -s appraisal test:units")
      raise unless $?.exitstatus == 0
    end

    namespace :selenium do
      task :install do
        selenium_runner.install_all
      end

      task :cleanup do
        selenium_runner.cleanup
      end
    end

    desc "Run selenium tests on all apps."
    task :selenium do
      rails_version = ENV['APP_VERSION']
      if rails_version
        selenium_runner.run_all_tests_for(rails_version)
      else
        selenium_runner.run_all_tests
      end
    end
  end

  task :ci => ['test:integration:units', 'test:integration:selenium']
end

desc 'Default: run the unit and integration tests.'
task :default => ['test:units', 'test:integration:selenium']
