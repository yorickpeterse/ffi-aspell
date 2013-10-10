# -*- encoding : utf-8 -*-
require 'bacon'
require File.expand_path('../../lib/ffi/aspell', __FILE__)

Bacon.extend(Bacon::TapOutput)
Bacon.summary_on_exit

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
