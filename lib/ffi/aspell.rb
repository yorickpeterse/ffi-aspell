require 'ffi'

$:.unshift(File.expand_path('../', __FILE__))

require 'aspell/error'
require 'aspell/speller'

module FFI
  ##
  # FFI::Aspell is an FFI binding for the Aspell spell checking library.
  #
  # @since 13-04-2012
  #
  module Aspell
    extend   FFI::Library
    ffi_lib 'aspell'

    # Configuration functions.
    attach_function 'config_new',
      'new_aspell_config',
      [],
      :pointer

    # TODO: find a way to use this in FFI::Aspell::Speller as it can reduce the
    # total memory usage by a few MB.
    attach_function 'config_delete',
      'delete_aspell_config',
      [:pointer],
      :void

    attach_function 'config_retrieve',
      'aspell_config_retrieve',
      [:pointer, :string],
      :string

    attach_function 'config_retrieve_default',
      'aspell_config_get_default',
      [:pointer, :string],
      :string

    attach_function 'config_replace',
      'aspell_config_replace',
      [:pointer, :string, :string],
      :bool

    attach_function 'config_remove',
      'aspell_config_remove',
      [:pointer, :string],
      :bool

    # Spell checking related functions.
    attach_function 'speller_new',
      'new_aspell_speller',
      [:pointer],
      :pointer

    attach_function 'speller_delete',
      'delete_aspell_speller',
      [:pointer],
      :void

    attach_function 'speller_check',
      'aspell_speller_check',
      [:pointer, :string, :int],
      :bool

    # Functions for dealing with suggestions.
    attach_function 'speller_suggest',
      'aspell_speller_suggest',
      [:pointer, :string, :int],
      :pointer

    attach_function 'word_list_elements',
      'aspell_word_list_elements',
      [:pointer],
      :pointer

    attach_function 'string_enumeration_delete',
      'delete_aspell_string_enumeration',
      [:pointer],
      :void

    attach_function 'string_enumeration_next',
      'aspell_string_enumeration_next',
      [:pointer],
      :string
  end # Aspell
end # FFI
