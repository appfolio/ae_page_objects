require 'rubygems'
require 'bundler'
require 'rake'
require 'appraisal'

require 'rake/testtask'

Bundler::GemHelper.install_tasks

namespace :test do
  Rake::TestTask.new(:units) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/unit/**/*_test.rb'
    test.verbose = true
  end
  
  namespace :integration do
    task :units do
      system("bundle exec rake -s appraisal test:units")
    end
    
    desc "Run selenium tests on all apps."
    task :selenium do 
      if app_version = ENV['APP_VERSION'] 
        run_test_in "test/test_apps/#{app_version}", 'test:selenium'
      else
        for_each_directory_of('test/test_apps/[0-9]*/**/Rakefile') do |directory|
          run_test_in directory, 'test:selenium'
        end
      end
    end
  end
end

def run_test_in(directory, *tasks)
  env = "TEST=../../#{ENV['TEST']} " if ENV['TEST']
  puts '', directory, ''
  with_pruned_env('BUNDLE_GEMFILE') do
    system("cd #{directory} && #{env} bundle exec rake #{tasks.join(' ')}")
  end
end

def for_each_directory_of(path, &block)
  Dir[path].sort.each do |rakefile|
    directory = File.dirname(rakefile)
    block.call(directory)
  end
end

def with_pruned_env(key_to_withhold, &block)
  withholding = ENV.delete(key_to_withhold)
  tap{ |r| r = yield; ENV[key_to_withhold] = withholding }
end


desc 'Default: run the unit and integration tests.'
task :default => ['test:integration:units', 'test:integration:selenium']
