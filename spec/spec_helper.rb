require 'rspec'
require_relative '../lib/ffi/aspell'

FIXTURES = File.expand_path('../fixtures', __FILE__)

##
# Used to change default internal encoding for certain tests.
# Ruby uses default_internal (amongst others) when presenting
# strings and when calling encode! without argument.
# Rails explicitly sets it to UTF-8 on bootup
#
# @param [String] enc The encoding to switch to
#
def with_internal_encoding(enc)
  if defined?(Encoding)
    old_enc = Encoding.default_internal

    Encoding.default_internal = enc

    yield

    Encoding.default_internal = old_enc
  end
end

RSpec.configure do |config|
  config.color = true

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
