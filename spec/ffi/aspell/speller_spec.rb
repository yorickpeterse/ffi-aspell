# encoding: utf-8

require 'spec_helper'

describe FFI::Aspell::Speller do
  context '.open' do
    it 'returns a Speller object when used without a block' do
      speller = described_class.open

      speller.is_a?(described_class).should == true
    end

    it 'yields a Speller object when a block is given' do
      described_class.open do |sp|
        sp.is_a?(described_class).should == true
      end
    end

    it 'closes a speller automatically when using a block' do
      speller = described_class.open { |_| }

      speller.closed?.should == true
    end
  end

  describe '#initialize' do
    it 'sets the language of the speller' do
      speller = described_class.new('en')

      speller.get('lang').should == 'en'
    end

    it 'accepts dashes and underscores in the language name' do
      -> { described_class.new('en_GB') }.should_not raise_error
      -> { described_class.new('en-GB') }.should_not raise_error
    end
  end

  describe '#close' do
    it 'closes a speller' do
      speller = described_class.new

      speller.close

      speller.closed?.should == true
    end

    it 'raises RuntimeError if a speller is already closed' do
      speller = described_class.new

      speller.close

      -> { speller.close }.should raise_error(RuntimeError)
    end
  end

  describe '#closed?' do
    it 'returns false when a speller is not closed' do
      speller = described_class.new

      speller.closed?.should == false
    end

    it 'returns true when a speller is closed' do
      speller = described_class.new

      speller.close

      speller.closed?.should == true
    end
  end

  describe '#correct?' do
    it 'raises when the input is a non String object' do
      speller = described_class.new

      -> { speller.correct?(10) }.should raise_error(TypeError)
    end

    it 'raises RuntimeError when the speller is closed' do
      speller = described_class.new

      speller.close

      -> { speller.correct?('foo') }.should raise_error(RuntimeError)
    end

    context 'using an English speller' do
      before do
        @speller = described_class.new('en')
      end

      it 'returns true if a word is spelled correctly' do
        @speller.correct?('cookie').should == true
      end

      it 'returns false if a word is spelled incorrectly' do
        @speller.correct?('cookei').should == false
      end

      it 'allows usage of a custom word lost' do
        @speller.set(:personal, File.join(FIXTURES, 'personal.en.pws'))

        @speller.correct?('github').should == true
      end
    end

    context 'using a Dutch speller' do
      before do
        @speller = described_class.new('nl')
      end

      it 'returns true if a word is spelled correctly' do
        @speller.correct?('huis').should == true
      end

      it 'returns false if a world is spelled incorrectly' do
        @speller.correct?('werld').should == false
      end
    end

    context 'using a Greek speller' do
      before do
        @speller = described_class.new('el')
      end

      it 'returns true if a word is spelled correctly' do
        @speller.correct?('χταπόδι').should == true
      end

      it 'returns false if a word is spelled incorrectly' do
        @speller.correct?('οιρανός').should  == false
      end
    end
  end

  describe '#suggestions' do
    it 'returns a list of suggestions when using an English speller' do
      speller     = described_class.new('en')
      suggestions = speller.suggestions('cookei')

      suggestions.include?('cookie').should == true
      suggestions.include?('cooked').should == true
    end

    it 'returns a list of suggestions when using a Greek speller' do
      speller     = described_class.new('el')
      suggestions = speller.suggestions('χταπίδι')

      suggestions.include?('χταπόδι').should == true
      suggestions.include?('απίδι').should   == true
    end

    it 'returns a list of suggestions using the "bad-spellers" mode' do
      speller = described_class.new
      normal  = speller.suggestions('cookei').length

      speller.suggestion_mode = 'bad-spellers'

      # The bad-spellers mode should return more suggestions.
      speller.suggestions('cookei').length.should > normal
    end

    it 'raises TypeError when using a non String input' do
      speller = described_class.new

      -> { speller.suggestions(10) }.should raise_error(TypeError)
    end

    it 'raises RuntimeError if the speller is closed' do
      speller = described_class.new

      speller.close

      -> { speller.suggestions('foo') }.should raise_error(RuntimeError)
    end
  end

  describe '#suggestion_mode=' do
    before do
      @speller = described_class.new
    end

    it 'sets the suggestion mode' do
      @speller.suggestion_mode = 'bad-spellers'

      @speller.suggestion_mode.should == 'bad-spellers'
    end

    it 'raises RuntimeError if the speller is closed' do
      @speller.close

      block = -> { @speller.suggestion_mode = 'bad-spellers' }

      block.should raise_error(RuntimeError)
    end
  end

  describe '#set' do
    before do
      @speller = described_class.new
    end

    it 'raises RuntimeError if the speller is closed' do
      @speller.close

      -> { @speller.set('lang', 'en') }.should raise_error(RuntimeError)
    end

    it 'raises ConfigError for an invalid suggestion mode' do
      -> { @speller.set('sug-mode', 'foobar') }.
        should raise_error(FFI::Aspell::ConfigError)
    end

    it 'sets the language of the speller' do
      @speller.set('lang', 'nl')

      @speller.get('lang').should == 'nl'
    end
  end

  describe '#get' do
    before do
      @speller = described_class.new('en')
    end

    it 'returns the language of a speller' do
      @speller.get('lang').should == 'en'
    end

    it 'raises RuntimeError if the speller is closed' do
      @speller.close

      -> { @speller.get('lang') }.should raise_error(RuntimeError)
    end

    it 'raises ConfigError for invalid configuration items' do
      -> { @speller.get('foo') }.should raise_error(FFI::Aspell::ConfigError)
    end
  end

  describe '#get_default' do
    before do
      @speller = described_class.new
    end

    it 'raises RuntimeError if the speller is closed' do
      @speller.close

      -> { @speller.get_default('lang') }.should raise_error(RuntimeError)
    end

    it 'returns a default configuration value' do
      @speller.get_default('personal').should == '.aspell.en_US.pws'
    end

    it 'raises ConfigError for invalid configuration items' do
      block = -> { @speller.get_default('foo') }

      block.should raise_error(FFI::Aspell::ConfigError)
    end
  end

  describe '#invalid_dictionary' do
    it 'raises ArgumentError if the used dictionary does not exist' do
      -> { described_class.new('qwer') }.should raise_error(ArgumentError)
    end

    it 'raises ArgumentError if the changed dictionary does not exist' do
      speller = described_class.new('en')
      -> { speller.set('lang', 'qwer') }.should raise_error(ArgumentError)
    end
  end

  describe '#reset' do
    before do
      @speller = described_class.new
    end

    it 'raises RuntimeError if the speller is closed' do
      @speller.close

      -> { @speller.reset('foo') }.should raise_error(RuntimeError)
    end

    it 'raises ConfigError when resetting an invalid option' do
      -> { @speller.reset('foo') }.should raise_error(FFI::Aspell::ConfigError)
    end
  end
end
