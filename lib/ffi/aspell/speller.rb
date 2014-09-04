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
    # When you're finished with the `Speller` object, call {#close} to free
    # underlying resources:
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
    # @since 13-04-2012
    #
    class Speller
      ##
      # Array containing the possible suggestion modes to use.
      #
      # @since 18-04-2012
      #
      SUGGESTION_MODES = ['ultra', 'fast', 'normal', 'bad-spellers']

      ##
      # Creates a new instance of the class, sets the language as well as the
      # options specified in the `options` hash.
      #
      # @since 13-04-2012
      # @param [String] language The language to use.
      # @param [Hash] options A hash containing extra configuration options,
      #  such as the "personal" option to set.
      # @see #close #close
      # @see .open Speller.open
      #
      def initialize(language = nil, options = {})
        @config = Aspell.config_new

        options['lang'] = language if language

        options.each { |k, v| set(k, v) }

        update_speller
      end

      ##
      # Creates a new instance of the class, sets the language as well as the
      # options specified in the `options` hash. If a block is given, the
      # instance is yielded and automatically closed when exiting the block.
      #
      # @since 03-09-2014
      # @param [String] language The language to use.
      # @param [Hash] options A hash containing extra configuration options,
      #  such as the "personal" option to set.
      # @yield If a block is given, the speller instance is yielded.
      # @yieldparam [Speller] speller The created speller. {Speller#close} is
      #  automatically called when exiting the block.
      # @return [Speller] If no block is given, the speller instance is
      #  returned. It must be manually closed with {#close}.
      # @return [Object] If a block is given, the value of the block is returned.
      # @see #close #close
      # @see #initialize Speller.new
      #
      def self.open(language = nil, options = {})
        speller = self.new(language, options)

        if block_given?
          begin
            return yield speller
          ensure
            speller.close
          end
        else
          return speller
        end
      end

      ##
      # Closes the speller and frees underlying resources.
      #
      # @since 03-09-2014
      # @raise [RuntimeError] If the speller is already closed.
      # @return [nil]
      # @see #initialize Speller.new
      # @see .open Speller.open
      # @see #closed? #closed?
      #
      def close
        if closed?
          raise(RuntimeError, 'Speller has already been closed.')
        end

        # Remove finalizer since we're manually freeing resources.
        ObjectSpace.undefine_finalizer(self)
        Aspell.speller_delete(@speller)
        @speller = nil
      end

      ##
      # Checks if the speller is closed or not.
      #
      # @since 03-09-2014
      # @return [TrueClass|FalseClass]
      # @see #close #close
      #
      def closed?
        @speller.nil?
      end

      ##
      # Checks if the given word is correct or not.
      #
      # @since  13-04-2012
      # @param  [String] word The word to check.
      # @return [TrueClass|FalseClass]
      #
      def correct?(word)
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
      # @since  13-04-2012
      # @param  [String] word The word for which to generate a suggestion list.
      # @return [Array]
      #
      def suggestions(word)
        unless word.is_a?(String)
          raise(TypeError, "Expected String but got #{word.class} instead")
        end

        list        = Aspell.speller_suggest(
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
      # @since 13-04-2012
      # @param [String] mode The suggestion mode to use.
      #
      def suggestion_mode=(mode)
        set('sug-mode', mode)
      end

      ##
      # Returns the suggestion mode that's currently used.
      #
      # @since  13-04-2012
      # @return [String]
      #
      def suggestion_mode
        return get('sug-mode')
      end

      ##
      # Sets a configuration option.
      #
      # @since 13-04-2012
      # @param [#to_s] key The configuration key to set.
      # @param [#to_s] value The value of the configuration key.
      # @raise [FFI::Aspell::ConfigError] Raised when the configuration value
      #  could not be set or when an incorrect suggestion mode was given.
      #
      def set(key, value)
        unless key.respond_to?(:to_s)
          raise(TypeError, 'Configuration keys should respond to #to_s()')
        end

        unless value.respond_to?(:to_s)
          raise(TypeError, 'Configuration values should respond to #to_s()')
        end

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
      # @since  13-04-2012
      # @param  [#to_s] key The configuration key to retrieve.
      # @return [String]
      # @raise  [FFI::Aspell::ConfigError] Raised when the configuration item
      #  does not exist.
      #
      def get(key)
        unless key.respond_to?(:to_s)
          raise(TypeError, 'Configuration keys should respond to #to_s()')
        end

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
      # @since  13-04-2012
      # @param  [#to_s] key The name of the configuration key.
      # @return [String]
      # @raise  [FFI::Aspell::ConfigError] Raised when the configuration item
      #  does not exist.
      #
      def get_default(key)
        unless key.respond_to?(:to_s)
          raise(TypeError, 'Configuration keys should respond to #to_s()')
        end

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
      # @since 13-04-2012
      # @param [#to_s] key The name of the configuration item to reset.
      # @raise [FFI::Aspell::ConfigError] Raised when the configuration item
      #  could not be reset.
      #
      def reset(key)
        unless key.respond_to?(:to_s)
          raise(TypeError, 'Configuration keys should respond to #to_s()')
        end

        unless Aspell.config_remove(@config, key.to_s)
          raise(
            ConfigError,
            "The configuration item #{key} could not be reset, most likely " \
              "it doesn't exist"
          )
        end

        update_speller
      end

      ##
      # Converts word to encoding expected in aspell
      # from current ruby encoding
      #
      # @param [String] word The word to convert
      # @return [String] word
      #
      def handle_input(word)
        if defined?(Encoding)
          enc = get('encoding')
          word.encode!(enc)
        end

        word
      end
      private :handle_input

      ##
      # Converts word from aspell encoding to what ruby expects
      #
      # @param [String] word The word to convert
      # @return [String] word
      #
      def handle_output(word)
        if defined?(Encoding)
          enc = get('encoding')
          word.force_encoding(enc).encode!
        end

        word
      end
      private :handle_output

      ##
      # Updates the internal speller object to use the current config.
      #
      def update_speller
        # Remove finalizer since we're manually freeing resources.
        ObjectSpace.undefine_finalizer(self)

        Aspell.speller_delete(@speller)
        @speller = Aspell.speller_new(@config)

        ObjectSpace.define_finalizer(self, self.class.finalizer(@speller))
      end
      private :update_speller

      ##
      # Frees underlying resources.
      #
      # @api private
      # @param [Speller] speller The speller to free.
      # @return [Proc]
      #
      def self.finalizer(speller)
        proc { Aspell.speller_delete(speller) }
      end

    end # Speller
  end # Aspell
end # FFI
