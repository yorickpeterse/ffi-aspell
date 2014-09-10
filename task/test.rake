desc 'Runs the tests'
task :test do
  sh 'rspec spec --order random'
end
