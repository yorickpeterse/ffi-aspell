require 'bundler/gem_tasks'
require 'rake/clean'

CLEAN.include('coverage', 'yardoc')

Dir['./task/*.rake'].each do |task|
  import(task)
end

task :default => :test
