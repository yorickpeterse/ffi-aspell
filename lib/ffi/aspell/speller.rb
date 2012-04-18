module FFI
  module Aspell
    ##
    # The Speller class is used for spell checking individual words as well as
    # generating a list of suggestions.
    #
    # TODO: currently this class creates a new speller object every time
    # {FFI::Aspell::Speller#correct?} and similar methods are called. I'm not
    # entirely sure if this is needed, if not it should be modified.
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
      #
      def initialize(language = nil, options = {})
        @config = Aspell.config_new

        options['lang'] = language if language

        options.each { |k, v| set(k, v) }
      end

      ##
      # Checks if the given word is correct or not.
      #
      # @since  13-04-2012
      # @param  [String] word The word to check.
      # @return [TrueClass|FalseClass]
      #
      def correct?(word)
        unless word.respond_to?(:to_s)
          raise(TypeError, 'Words should respond to #to_s()')
        end

        speller = Aspell.speller_new(@config)
        correct = Aspell.speller_check(speller, word.to_s, word.length)

        Aspell.speller_delete(speller)

        return correct
      end

      ##
      # Returns an array containing words suggested as an alternative to the
      # specified word.
      #
      # @since  13-04-2012
      # @param  [#to_s] word The word for which to generate a suggestion list.
      # @return [Array]
      #
      def suggestions(word)
        speller     = Aspell.speller_new(@config)
        list        = Aspell.speller_suggest(speller, word, word.length)
        suggestions = []
        elements    = Aspell.word_list_elements(list)

        while word = Aspell.string_enumeration_next(elements)
          suggestions << word
        end

        Aspell.string_enumeration_delete(elements)
        Aspell.speller_delete(speller)

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
      end
    end # Speller
  end # Aspell
end # FFI
