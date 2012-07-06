require File.expand_path('../lib/ffi/aspell/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ffi-aspell'
  s.version     = FFI::Aspell::VERSION
  s.date        = '2012-07-07'
  s.authors     = ['Yorick Peterse']
  s.email       = 'yorickpeterse@gmail.com'
  s.summary     = 'FFI bindings for Aspell'
  s.homepage    = 'https://github.com/YorickPeterse/ffi-aspell'
  s.description = s.summary
  s.files       = `git ls-files`.split("\n")
  s.has_rdoc    = 'yard'

  s.add_dependency('ffi', ['>= 1.0.11'])

  s.add_development_dependency('rake', ['>= 0.9.2.2'])
  s.add_development_dependency('yard',['>= 0.7.5'])
  s.add_development_dependency('redcarpet', ['>= 2.1.1'])
  s.add_development_dependency('bacon', ['>= 1.1.0'])
end
