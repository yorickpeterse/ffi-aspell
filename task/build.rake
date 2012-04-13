namespace :build do
  desc 'Builds a new Gem'
  task :gem do
    root    = File.expand_path('../../', __FILE__)
    gemspec = Gem::Specification.load(File.join(root, 'ffi-aspell.gemspec'))
    name    = "#{gemspec.name}-#{gemspec.version.version}.gem"
    path    = File.join(root, name)
    pkg     = File.join(root, 'pkg', name)

    # Build and install the gem
    sh('gem', 'build', File.join(root, 'ffi-aspell.gemspec'))
    sh('mv' , path, pkg)
    sh('gem', 'install', pkg)
  end
end
