require File.expand_path('../lib/ffi/aspell/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ffi-aspell'
  s.version     = FFI::Aspell::VERSION
  s.authors     = ['Yorick Peterse']
  s.email       = 'yorickpeterse@gmail.com'
  s.summary     = 'FFI bindings for Aspell'
  s.homepage    = 'https://github.com/yorickpeterse/ffi-aspell'
  s.description = s.summary
  s.has_rdoc    = 'yard'

  s.files = Dir.glob([
    'doc/**/*',
    'lib/**/*',
    'LICENSE',
    'README',
    '.yardopts'
  ]).select { |path| File.file?(path) }

  s.add_dependency 'ffi'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'bacon'
end
