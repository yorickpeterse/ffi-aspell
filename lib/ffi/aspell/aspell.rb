require 'open3'
require 'rbconfig'

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
  module Aspell
    extend FFI::Library

    begin
      stdout, stderr, status = ::Open3.capture3("brew", "--prefix")
      homebrew_path  = if status.success?
                        "#{stdout.chomp}/lib"
                      else
                        '/usr/local/homebrew/lib'
                      end
    rescue
      # Homebrew doesn't exist
    end

    ffi_lib ['aspell', 'libaspell.so.15'] if ::RbConfig::CONFIG['host_os'] =~ /linux/
    ffi_lib ["#{homebrew_path}/libaspell.dylib"] if ::RbConfig::CONFIG['host_os'] =~ /darwin/

    ##
    # Structure for storing dictionary information.
    #
    class DictInfo < FFI::Struct
      layout :code, :string
    end

    ##
    # Creates a pointer for a configuration struct.
    #
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

    ##
    # Gets a list of all installed aspell dictionaries.
    # 
    # @method dict_info_list(config)
    # @scope  class
    # @param  [FFI::Pointer] config 
    # @return [FFI::Pointer] list A list of dictionaries which can be used
    # by {FFI::Aspell.dict_info_list_elements}.
    #
    attach_function 'dict_info_list',
      'get_aspell_dict_info_list',
      [:pointer],
      :pointer

    ##
    # Gets all elements from the dictionary list.
    # 
    # @method dict_info_list_elements(list)
    # @scope  class
    # @param  [FFI::Pointer] list A list of dictionaries as returned
    #  by {FFI::Aspell.dict_info_list}.
    # @return [FFI::Pointer] dictionary Returns an enumeration of 
    #  {FFI::Aspell::DictInfo} structs.
    #
    attach_function 'dict_info_list_elements',
      'aspell_dict_info_list_elements',
      [:pointer],
      :pointer

    ##
    # Deletes an enumeration of dictionaries.
    # 
    # @method delete_dict_info_enumeration(enumeration)
    # @scope  class
    # @param  [FFI::Pointer] enumeration An enumeration of dictionaries returned
    #  by {FFI::Aspell.dict_info_list_elements}.
    #
    attach_function 'delete_dict_info_enumeration',
      'delete_aspell_dict_info_enumeration',
      [:pointer],
      :void

    ##
    # Retrieves the next element in the list of dictionaries.
    # 
    # @method dict_info_enumeration_next(elements)
    # @scope  class
    # @param  [FFI::Pointer] elements Pointer to a dictionary enumeration as returned
    #  by {FFI::Aspell.dict_info_list_elements}.
    # @return [DictInfo|NilClass] dictInfo Returns an object of {FFI::Aspell::DictInfo}
    #  information, which contains dictionary information.
    #
    attach_function 'dict_info_enumeration_next',
      'aspell_dict_info_enumeration_next',
      [:pointer],
      DictInfo

  end # Aspell
end # FFI
