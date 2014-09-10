desc 'Creates a Git tag for the current version'
task :tag do
  version = FFI::Aspell::VERSION

  sh %Q{git tag -a -m "Version #{version}" #{version}}
end
