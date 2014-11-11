module FFI
  module Aspell
    ##
    # The Speller class is used for spell checking individual words as well as
    # generating a list of suggestions.
    #
    # ## Usage
    #
    # First you'll have to create a new instance:
    #
    #     speller = FFI::Aspell::Speller.new
    #
    # When creating a new instance you can specify the language as well as a set
    # of arbitrary Aspell options (e.g. the personal wordlist file). The
    # language can be set in the first parameter, other options are set as a
    # hash in the second parameter:
    #
    #     speller = FFI::Aspell::Speller.new('nl', :personal => 'aspell.nl.pws')
    #
    # Unlike Raspell the keys of the hash used for additional options can be
    # both strings and symbols.
    #
    # Once an instance has been created you can change the options, check the
    # spelling of a word or retrieve a list of suggestions.
    #
    # ### Options
    #
    # There are four methods for dealing with Aspell options:
    #
    # * {FFI::Aspell::Speller#set}
    # * {FFI::Aspell::Speller#get}
    # * {FFI::Aspell::Speller#get_default}
    # * {FFI::Aspell::Speller#reset}
    #
    # There are also two extra methods which can be used to set the suggestion
    # mode, both these methods are simply shortcuts and use the `#set()` method
    # for actually setting the values:
    #
    #     speller.suggestion_mode = 'fast'
    #
    #     if speller.suggestion_mode == 'fast'
    #       # ...
    #     end
    #
    # Setting an option:
    #
    #     speller.set('lang', 'en_US')
    #
    # Retrieving an option:
    #
    #     speller.get('lang')
    #
    # Resetting an option:
    #
    #     speller.reset('lang')
    #
    # ### Checking a Word
    #
    # Checking the spelling of a word is done using
    # {FFI::Aspell::Speller#correct?}. This method takes a string containing the
    # word to verify and returns `true` if the word is spelled correctly and
    # `false` otherwise:
    #
    #     speller.correct?('cookie') # => true
    #     speller.correct?('cookei') # => false
    #
    # ### Suggestions
    #
    # Suggestions can be generated using {FFI::Aspell::Speller.suggestions}.
    # This method returns an array containing all the possible suggestions based
    # on the suggestion mode that is being used:
    #
    #     speller.suggestions('cookei') # => ["cookie", ...]
    #
    # ### Cleaning up
    #
    # When you're finished with the `Speller` object, you can let the finalizer
    # automatically free resources, otherwise, call {#close} to explicitly free
    # the underlying resources:
    #
    #     speller = FFI::Aspell::Speller.new
    #     speller.correct?('cookie') # => true
    #     speller.close
    #
    # Alternatively, you can use the block form of {.open} to automatically
    # free the resources:
    #
    #     FFI::Aspell::Speller.open do |speller|
    #       puts speller.correct?('cookie') # => prints "true"
    #     end
    #
    # {.open} takes the same parameters as {Speller#initialize Speller.new}.
    #
    # For more information see the documentation of the individual methods in
    # this class.
    #
    class Speller
      ##
      # Array containing the possible suggestion modes to use.
      #
      # @return [Array]
      #
      SUGGESTION_MODES = ['ultra', 'fast', 'normal', 'bad-spellers']

      ##
      # Creates a new instance of the class. If a block is given, the instance
      # is yielded and automatically closed when exiting the block.
      #
      # @yield  If a block is given, the speller instance is yielded.
      #
      # @yieldparam [Speller] speller The created speller. {Speller#close} is
      #  automatically called when exiting the block.
      #
      # @return [Speller]
      #
      # @see [#initialize]
      #
      def self.open(*args)
        speller = self.new(*args)

        if block_given?
          begin
            yield speller
          ensure
            speller.close
          end
        end

        return speller
      end

      ##
      # Returns a proc for a finalizer, used for cleaning up native resources.
      #
      # @param  [FFI::Pointer] config
      # @param  [FFI::Pointer] speller
      # @return [Proc]
      #
      def self.finalizer(config, speller)
        return proc {
          Aspell.config_delete(config)
          Aspell.speller_delete(speller)
        }
      end

      ##
      # Creates a new instance of the class, sets the language as well as the
      # options specified in the `options` hash.
      #
      # @param [String] language The language to use.
      #
      # @param [Hash] options A hash containing extra configuration options,
      #  such as the "personal" option to set.
      #
      def initialize(language = nil, options = {})
        @config = Aspell.config_new

        options['lang'] = language if language

        options.each { |k, v| set(k, v) }

        update_speller
      end

      ##
      # Closes the speller and frees underlying resources. Calling this is not
      # absolutely required as the resources will eventually be freed by the
      # finalizer.
      #
      # @raise [RuntimeError] Raised if the speller is closed.
      #
      def close
        check_closed

        # Remove finalizer since we're manually freeing resources.
        ObjectSpace.undefine_finalizer(self)

        Aspell.config_delete(@config)

        @config = nil

        Aspell.speller_delete(@speller)

        @speller = nil
      end

      ##
      # Checks if the speller is closed or not.
      #
      # @return [TrueClass|FalseClass]
      #
      def closed?
        return @config.nil?
      end

      ##
      # Checks if a dictionary is available or not
      #
      # @return [TrueClass|FalseClass]
      #
      def dictionary_available?(dictionary)
        return available_dictionaries.include?(dictionary)
      end

      ##
      # Checks if the given word is correct or not.
      #
      # @param  [String] word The word to check.
      # @raise  [RuntimeError] Raised if the speller is closed.
      # @return [TrueClass|FalseClass]
      #
      def correct?(word)
        check_closed

        unless word.is_a?(String)
          raise(TypeError, "Expected String but got #{word.class} instead")
        end

        correct = Aspell.speller_check(
          @speller,
          handle_input(word.to_s),
          word.bytesize
        )

        return correct
      end

      ##
      # Returns an array containing words suggested as an alternative to the
      # specified word.
      #
      # @param  [String] word The word for which to generate a suggestion list.
      # @raise  [RuntimeError] Raised if the speller is closed.
      # @return [Array]
      #
      def suggestions(word)
        check_closed

        unless word.is_a?(String)
          raise(TypeError, "Expected String but got #{word.class} instead")
        end

        list = Aspell.speller_suggest(
          @speller,
          handle_input(word),
          word.bytesize
        )

        suggestions = []
        elements    = Aspell.word_list_elements(list)

        while word = Aspell.string_enumeration_next(elements)
          suggestions << handle_output(word)
        end

        Aspell.string_enumeration_delete(elements)

        return suggestions
      end

      ##
      # Sets the suggestion mode for {FFI::Aspell::Speller#suggestions}.
      #
      # @param [String] mode The suggestion mode to use.
      # @raise [RuntimeError] Raised if the speller is closed.
      #
      def suggestion_mode=(mode)
        check_closed

        set('sug-mode', mode)
      end

      ##
      # Returns the suggestion mode that's currently used.
      #
      # @raise  [RuntimeError] Raised if the speller is closed.
      # @return [String]
      #
      def suggestion_mode
        check_closed

        return get('sug-mode')
      end

      ##
      # Sets a configuration option.
      #
      # @param [#to_s] key The configuration key to set.
      # @param [#to_s] value The value of the configuration key.
      # @raise [RuntimeError] Raised if the speller is closed.
      # @raise [FFI::Aspell::ConfigError] Raised when the configuration value
      #  could not be set or when an incorrect suggestion mode was given.
      #
      def set(key, value)
        check_closed

        if key == 'sug-mode' and !SUGGESTION_MODES.include?(value)
          raise(ConfigError, "The suggestion mode #{value} is invalid")
        end

        unless Aspell.config_replace(@config, key.to_s, value.to_s)
          raise(ConfigError, "Failed to set the configuration item #{key}")
        end

        update_speller
      end

      ##
      # Retrieves the value of the specified configuration item.
      #
      # @param  [#to_s] key The configuration key to retrieve.
      # @return [String]
      # @raise  [RuntimeError] Raised if the speller is closed.
      # @raise  [FFI::Aspell::ConfigError] Raised when the configuration item
      #  does not exist.
      #
      def get(key)
        check_closed

        value = Aspell.config_retrieve(@config, key.to_s)

        if value
          return value
        else
          raise(ConfigError, "The configuration item #{key} does not exist")
        end
      end

      ##
      # Retrieves the default value for the given configuration key.
      #
      # @param  [#to_s] key The name of the configuration key.
      # @return [String]
      # @raise  [RuntimeError] Raised if the speller is closed.
      # @raise  [FFI::Aspell::ConfigError] Raised when the configuration item
      #  does not exist.
      #
      def get_default(key)
        check_closed

        value = Aspell.config_retrieve_default(@config, key.to_s)

        if value
          return value
        else
          raise(ConfigError, "The configuration item #{key} does not exist")
        end
      end

      ##
      # Resets a configuration item to its default value.
      #
      # @param [#to_s] key The name of the configuration item to reset.
      # @raise [RuntimeError] Raised if the speller is closed.
      # @raise [FFI::Aspell::ConfigError] Raised when the configuration item
      #  could not be reset.
      #
      def reset(key)
        check_closed

        unless Aspell.config_remove(@config, key.to_s)
          raise(
            ConfigError,
            "The configuration item #{key} could not be reset, most likely " \
              "it doesn't exist"
          )
        end

        update_speller
      end

      private

      ##
      # Converts word to encoding expected in aspell
      # from current ruby encoding
      #
      # @param  [String] word The word to convert
      # @return [String] word
      #
      def handle_input(word)
        enc = get('encoding')

        return word.encode(enc)
      end

      ##
      # Converts word from aspell encoding to what ruby expects
      #
      # @param  [String] word The word to convert
      # @return [String] word
      #
      def handle_output(word)
        enc = get('encoding')

        return word.force_encoding(enc).encode
      end

      ##
      # Raises error if speller is closed.
      #
      # @raise  [RuntimeError] Raised if the speller is closed.
      # @return [nil]
      #
      def check_closed
        if closed?
          raise(RuntimeError, 'This Speller object has already been closed')
        end
      end

      ## 
      # Raises error if used dictionary is not installed.
      #
      # @raise [ArgumentError] Raised if dictionary does not exist.
      # @return [nil]
      # 
      def check_dictionary
        dictionary = get('lang')
        if !dictionary_available?(dictionary)
          raise(ArgumentError, "The used dictionary #{dictionary.inspect} is not available")
        end
      end

      ##
      # Updates the internal speller object to use the current config.
      #
      def update_speller
        ObjectSpace.undefine_finalizer(self)

        Aspell.speller_delete(@speller)

        @speller = Aspell.speller_new(@config)

        ObjectSpace.define_finalizer(
          self,
          self.class.finalizer(@config, @speller)
        )

        check_dictionary
      end

      ## 
      # Get all availbale aspell dictionary codes
      #
      # @return [Array]
      #
      def available_dictionaries
        list = Aspell.dict_info_list(@config)
        elements = Aspell.dict_info_list_elements(list)
        dicts = []

        while element = Aspell.dict_info_enumeration_next(elements)
          break if element == FFI::Pointer::NULL          
          dict_info = Aspell::DictInfo.new(element)
          dicts << handle_output(dict_info[:code])
        end

        Aspell.delete_dict_info_enumeration(elements)
        
        return dicts
      end

    end # Speller
  end # Aspell
end # FFI
