module FFI
  module Aspell
    ##
    # The Speller class is used for spell checking individual words as well as
    # generating a list of suggestions.
    #
    # @since 13-04-2012
    #
    class Speller
      ##
      # Creates a new instance of the class, sets the language as well as the
      # options specified in the `options` hash.
      #
      # @since 13-04-2012
      # @param [String] language The language to use.
      # @param [Hash] options A hash containing extra configuration options,
      #  such as the "personal" option to set.
      #
      def initialize(language, options = {})

      end

      ##
      # Checks if the given word is correct or not.
      #
      # @since  13-04-2012
      # @param  [String] word The word to check.
      # @return [TrueClass|FalseClass]
      #
      def correct?(word)

      end

      ##
      # Sets a configuration option.
      #
      # @since 13-04-2012
      # @param [#to_s] key The configuration key to set.
      # @param [#to_s] value The value of the configuration key.
      # @raise [FFI::Aspell::ConfigError] Raised when the configuration value
      #  could not be set.
      #
      def set(key, value)

      end

      ##
      # Retrieves the value of the specified configuration item.
      #
      # @since  13-04-2012
      # @param  [String] key The configuration key to retrieve.
      # @return [String]
      # @raise  [FFI::Aspell::ConfigError] Raised when the configuration item
      #  does not exist.
      #
      def get(key)

      end
    end # Speller
  end # Aspell
end # FFI
