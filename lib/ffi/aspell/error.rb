# -*- encoding : utf-8 -*-
module FFI
  module Aspell
    ##
    # Error class used by methods such as {FFI::Aspell::Speller#get} and
    # {FFI::Aspell::Speller#set}.
    #
    # @since 13-04-2012
    #
    class ConfigError < StandardError; end
  end # Aspell
end # FFI
