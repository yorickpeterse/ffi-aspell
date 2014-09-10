require 'bundler/gem_tasks'
require 'digest/sha2'
require 'rake/clean'

GEMSPEC = Gem::Specification.load('ffi-aspell.gemspec')

CLEAN.include('coverage', 'yardoc')

Dir['./task/*.rake'].each do |task|
  import(task)
end

task :default => :test
