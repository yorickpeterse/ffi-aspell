require 'ffi'

require File.expand_path('../aspell/error', __FILE__)
require File.expand_path('../aspell/speller', __FILE__)
require File.expand_path('../aspell/version', __FILE__)

module FFI
  ##
  # FFI::Aspell is an FFI binding for the Aspell spell checking library. Basic
  # usage is as following:
  #
  #     require 'ffi/aspell'
  #
  #     speller = FFI::Aspell::Speller.new
  #
  #     speller.correct?('cookie') # => true
  #     speller.correct?('cookei') # => false
  #
  # For more information see {FFI::Aspell::Speller}.
  #
  # @since 13-04-2012
  #
  module Aspell
    extend   FFI::Library
    ffi_lib 'aspell'

    ##
    # Creates a pointer for a configuration struct.
    #
    # @since  24-04-2012
    # @method config_new
    # @scope  class
    # @return [FFI::Pointer]
    #
    attach_function 'config_new',
      'new_aspell_config',
      [],
      :pointer

    ##
    # Removes a config pointer and frees the memory associated with said
    # pointer.
    #
    # @since  05-09-2014
    # @method config_delete(config)
    # @scope  class
    # @param  [FFI::Pointer] config The pointer to remove.
    #
    attach_function 'config_delete',
      'delete_aspell_config',
      [:pointer],
      :void

    ##
    # Retrieves the value of a given configuration item. The value is returned
    # as a string or nil upon failure.
    #
    # @example
    #  config = FFI::Aspell.config_new
    #  value  = FFI::Aspell.config_retrieve(config, 'lang')
    #
    #  puts value # => "en_US"
    #
    # @since  24-04-2012
    # @method config_retrieve(config, key)
    # @scope  class
    # @param  [FFI::Pointer] config A pointer to a configuration struct.
    # @param  [String] key The name of the configuration item to retrieve.
    # @return [String]
    #
    attach_function 'config_retrieve',
      'aspell_config_retrieve',
      [:pointer, :string],
      :string

    ##
    # Retrieves the default value of a configuration item.
    #
    # @since  24-04-2012
    # @method config_retrieve_default(config, key)
    # @scope  class
    # @see    FFI::Aspell.config_retrieve
    #
    attach_function 'config_retrieve_default',
      'aspell_config_get_default',
      [:pointer, :string],
      :string

    ##
    # Sets the new value of the specified configuration item.
    #
    # @example
    #  config = FFI::Aspell.config_new
    #
    #  FFI::Aspell.config_replace(config, 'lang', 'nl')
    #
    # @since  24-04-2012
    # @method config_replace(config, key, value)
    # @scope  class
    # @param  [FFI::Pointer] config Pointer to the configuration struct.
    # @param  [String] key The name of the configuration item to set.
    # @param  [String] value The new value of the configuration item.
    # @return [TrueClass|FalseClass]
    #
    attach_function 'config_replace',
      'aspell_config_replace',
      [:pointer, :string, :string],
      :bool

    ##
    # Sets the value of the specified configuration item back to its default
    # value.
    #
    # @example
    #  config = FFI::Aspell.config_new
    #
    #  FFI::Aspell.config_replace(config, 'lang', 'nl')
    #  FFI::Aspell.config_remove(config, 'lang')
    #
    # @since  24-04-2012
    # @method config_remove(config, key)
    # @scope  class
    # @param  [FFI::Pointer] config Pointer to the configuration struct.
    # @param  [String] key The name of the configuration item to reset.
    # @return [TrueClass|FalseClass]
    #
    attach_function 'config_remove',
      'aspell_config_remove',
      [:pointer, :string],
      :bool

    # Spell checking related functions.

    ##
    # Creates a pointer to a speller struct.
    #
    # @example
    #  config  = FFI::Aspell.config_new
    #  speller = FFI::Aspell.speller_new(config)
    #
    # @since  24-04-2012
    # @method speller_new(config)
    # @scope  class
    # @param  [FFI::Pointer] config The configuration struct to use for the
    #  speller.
    # @return [FFI::Pointer]
    #
    attach_function 'speller_new',
      'new_aspell_speller',
      [:pointer],
      :pointer

    ##
    # Removes a speller pointer and frees the memory associated with said
    # pointer.
    #
    # @since  24-04-2012
    # @method speller_delete(speller)
    # @scope  class
    # @param  [FFI::Pointer] speller The pointer to remove.
    #
    attach_function 'speller_delete',
      'delete_aspell_speller',
      [:pointer],
      :void

    ##
    # Checks if a given word is spelled correctly or not. If the word is valid
    # `true` will be returned, `false` otherwise.
    #
    # @example
    #  config  = FFI::Aspell.config_new
    #  speller = FFI::Aspell.speller_new(config)
    #  word    = 'cookie'
    #  valid   = FFI::Aspell.speller_check(speller, word, word.length)
    #
    #  if valid
    #    puts 'The word "cookie" is valid'
    #  else
    #    puts 'The word "cookie" is invalid'
    #  end
    #
    # @since  24-04-2012
    # @method speller_check(speller, word, length)
    # @scope  class
    # @param  [FFI::Pointer] speller Pointer to a speller struct to use.
    # @param  [String] word The word to check.
    # @param  [Fixnum] length The length of the word.
    # @return [TrueClass|FalseClass]
    #
    attach_function 'speller_check',
      'aspell_speller_check',
      [:pointer, :string, :int],
      :bool

    # Functions for dealing with suggestions.

    ##
    # Returns a pointer that can be used to retrieve a list of suggestions for a
    # given word.
    #
    # @since  24-04-2012
    # @method speller_suggest(speller, word, length)
    # @see    FFI::Aspell.speller_check
    # @return [FFI::Pointer]
    #
    attach_function 'speller_suggest',
      'aspell_speller_suggest',
      [:pointer, :string, :int],
      :pointer

    ##
    # Returns a pointer to a list which can be used by
    # {FFI::Aspell.string_enumeration_next} to retrieve all the suggested words.
    #
    # @since  24-04-2012
    # @method word_list_elements(suggestions)
    # @scope  class
    # @param  [FFI::Pointer] suggestions A pointer with suggestions as returned
    #  by {FFI::Aspell.speller_suggest}
    # @return [FFI::Pointer]
    #
    attach_function 'word_list_elements',
      'aspell_word_list_elements',
      [:pointer],
      :pointer

    ##
    # Removes the pointer returned by {FFI::Aspell.word_list_elements} and frees
    # the associated memory.
    #
    # @since  24-04-2012
    # @method string_enumeration_delete(elements)
    # @scope  class
    # @param  [FFI::Pointer] elements A pointer for a list of elements as
    #  returned by {FFI::Aspell.word_list_elements}.
    #
    attach_function 'string_enumeration_delete',
      'delete_aspell_string_enumeration',
      [:pointer],
      :void

    ##
    # Retrieves the next item in the list of suggestions.
    #
    # @example
    #  speller  = FFI::Aspell.speller_new(FFI::Aspell.config_new)
    #  word     = 'cookie'
    #  list     = FFI::Aspell.speller_suggest(speller, word, word.length)
    #  elements = FFI::Aspell.word_list_elements(list)
    #  words    = []
    #
    #  while word = FFI::Aspell.string_enumeration_next(elements)
    #    words << word
    #  end
    #
    #  FFI::Aspell.string_enumeration_delete(elements)
    #  FFI::Aspell.speller_delete(speller)
    #
    # @since  24-04-2012
    # @method string_enumeration_next(elements)
    # @scope  class
    # @param  [FFI::Pointer] elements Pointer to a list of elements as returned
    #  by {FFI::Aspell.word_list_elements}.
    # @return [String|NilClass]
    #
    attach_function 'string_enumeration_next',
      'aspell_string_enumeration_next',
      [:pointer],
      :string
  end # Aspell
end # FFI
