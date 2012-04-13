desc 'Runs all the tests using Bacon'
task :test do
  Dir['./spec/ffi/aspell/**/*.rb'].each { |spec| require(spec) }
end
