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
  end

  def cleanup
    glob_pattern = "#{@gemfiles_path}/**/*.lock"
    puts "Removing '#{glob_pattern}'"

    FileUtils.rm_f Dir[glob_pattern]
  end

  def install_all
    @matrix.values.each do |test_configs|
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
    @matrix.keys.sort.each do |rails_version|
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
    puts 'Test Config',
         "---------------------",
         "Gemfile: #{gemfile}",
         "Command: '#{command}'",
         "---------------------"


    if !@options[:dry]
      with_gemfile_symlink(directory, gemfile, "Gemfile") do
        Command.new("cd #{directory} && #{command}", gemfile).run
      end
    end
  end

  def with_gemfile_symlink(directory, use_gemfile, app_gemfile)
    current_link = run_command("readlink #{directory}/#{app_gemfile}").strip

    run_command("cd #{directory} && ln -sf #{use_gemfile} #{app_gemfile}")
    run_command("cd #{directory} && ln -sf #{use_gemfile}.lock #{app_gemfile}.lock")

    yield

    run_command("cd #{directory} && ln -sf #{current_link} #{app_gemfile}")
    run_command("rm -f #{directory}/#{app_gemfile}.lock")
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

  def run_command(command)
    puts "Running '#{command}'"
    output = `#{command}`
    raise unless $?.exitstatus == 0
    output
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
      rails_version = ENV['RAILS_VERSION']
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
