# -*- coding: utf-8; mode: ruby -*-

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/unit/test*.rb',
                          'test/unit/services/test*.rb']
end

desc 'Run tests'
task default: :test

# task test: :rubocop

task :style do
  sh 'rubocop'
end
