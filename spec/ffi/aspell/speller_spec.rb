# encoding: utf-8

require 'spec_helper'

describe FFI::Aspell::Speller do
  context '.open' do
    example 'return a Speller object when used without a block' do
      speller = described_class.open

      speller.is_a?(described_class).should == true
    end

    example 'yield a Speller object when a block is given' do
      described_class.open do |sp|
        sp.is_a?(described_class).should == true
      end
    end

    example 'close a speller automatically when using a block' do
      speller = described_class.open { |_| }

      speller.closed?.should == true
    end
  end

  context '#initialize' do
    example 'set the language of the speller' do
      speller = described_class.new('en')

      speller.get('lang').should == 'en'
    end
  end

  context '#close' do
    example 'close a speller' do
      speller = described_class.new

      speller.close

      speller.closed?.should == true
    end

    example 'raise RuntimeError if a speller is already closed' do
      speller = described_class.new

      speller.close

      -> { speller.close }.should raise_error(RuntimeError)
    end
  end

  context '#closed?' do
    example 'return false when a speller is not closed' do
      speller = described_class.new

      speller.closed?.should == false
    end

    example 'return true when a speller is closed' do
      speller = described_class.new

      speller.close

      speller.closed?.should == true
    end
  end

  context '#correct?' do
    example 'raise when the input is a non String object' do
      speller = described_class.new

      -> { speller.correct?(10) }.should raise_error(TypeError)
    end

    example 'raise RuntimeError when the speller is closed' do
      speller = described_class.new

      speller.close

      -> { speller.correct?('foo') }.should raise_error
    end

    context 'using an English speller' do
      before do
        @speller = described_class.new('en')
      end

      example 'return true if a word is spelled correctly' do
        @speller.correct?('cookie').should == true
      end

      example 'return false if a word is spelled incorrectly' do
        @speller.correct?('cookei').should == false
      end

      example 'use a custom word list' do
        @speller.set(:personal, File.join(FIXTURES, 'personal.en.pws'))

        @speller.correct?('github').should == true
      end
    end

    context 'using a Dutch speller' do
      before do
        @speller = described_class.new('nl')
      end

      example 'return true if a word is spelled correctly' do
        @speller.correct?('huis').should == true
      end

      example 'return false if a world is spelled incorrectly' do
        @speller.correct?('werld').should == false
      end
    end

    context 'using a Greek speller' do
      before do
        @speller = described_class.new('el')
      end

      example 'return true if a word is spelled correctly' do
        @speller.correct?('χταπόδι').should == true
      end

      example 'return false if a word is spelled incorrectly' do
        @speller.correct?('οιρανός').should  == false
      end
    end
  end

  context '#suggestions' do
    example 'return a list of suggestions when using an English speller' do
      speller     = described_class.new('en')
      suggestions = speller.suggestions('cookei')

      suggestions.include?('cookie').should == true
      suggestions.include?('cooked').should == true
    end

    example 'return a list of suggestions when using a Greek speller' do
      speller     = described_class.new('el')
      suggestions = speller.suggestions('χταπίδι')

      suggestions.include?('χταπόδι').should == true
      suggestions.include?('απίδι').should   == true
    end

    example 'return a list of suggestions using the "bad-spellers" mode' do
      speller = described_class.new
      normal  = speller.suggestions('cookei').length

      speller.suggestion_mode = 'bad-spellers'

      # The bad-spellers mode should return more suggestions.
      speller.suggestions('cookei').length.should > normal
    end

    example 'raise TypeError when using a non String input' do
      speller = described_class.new

      -> { speller.suggestions(10) }.should raise_error(TypeError)
    end

    example 'raise RuntimeError if the speller is closed' do
      speller = described_class.new

      speller.close

      -> { speller.suggestions('foo') }.should raise_error
    end
  end

  context '#suggestion_mode=' do
    before do
      @speller = described_class.new
    end

    example 'set the suggestion mode' do
      @speller.suggestion_mode = 'bad-spellers'

      @speller.suggestion_mode.should == 'bad-spellers'
    end

    example 'raise RuntimeError if the speller is closed' do
      @speller.close

      block = -> { @speller.suggestion_mode = 'bad-spellers' }

      block.should raise_error
    end
  end

  context '#set' do
    before do
      @speller = described_class.new
    end

    example 'raise RuntimeError if the speller is closed' do
      @speller.close

      -> { @speller.set('lang', 'en') }.should raise_error
    end

    example 'raise ConfigError for an invalid suggestion mode' do
      -> { @speller.set('sug-mode', 'foobar') }.should raise_error
    end

    example 'set the language of the speller' do
      @speller.set('lang', 'nl')

      @speller.get('lang').should == 'nl'
    end
  end

  context '#get' do
    before do
      @speller = described_class.new('en')
    end

    example 'return the language of a speller' do
      @speller.get('lang').should == 'en'
    end

    example 'raise RuntimeError if the speller is closed' do
      @speller.close

      -> { @speller.get('lang') }.should raise_error
    end

    example 'raise ConfigError for invalid configuration items' do
      -> { @speller.get('foo') }.should raise_error(FFI::Aspell::ConfigError)
    end
  end

  context '#get_default' do
    before do
      @speller = described_class.new
    end

    example 'raise RuntimeError if the speller is closed' do
      @speller.close

      -> { @speller.get_default('lang') }.should raise_error
    end

    example 'return a default configuration value' do
      @speller.get_default('personal').should == '.aspell.en_US.pws'
    end

    example 'raise ConfigError for invalid configuration items' do
      block = -> { @speller.get_default('foo') }

      block.should raise_error(FFI::Aspell::ConfigError)
    end
  end

  context '#invalid_dictionary' do  
    example 'raise RuntimeError if the used dictionary does not exist' do
      -> { described_class.new('qwer') }.should raise_error
    end

    example 'raise RuntimeError if the changed dictionary does not exist' do
      speller = described_class.new('en')
      -> { speller.set('lang', 'qwer') }.should raise_error
    end
  end

  context '#reset' do
    before do
      @speller = described_class.new
    end

    example 'raise RuntimeError if the speller is closed' do
      @speller.close

      -> { @speller.reset('foo') }.should raise_error
    end

    example 'raise ConfigError when resetting an invalid option' do
      -> { @speller.reset('foo') }.should raise_error(FFI::Aspell::ConfigError)
    end
  end
end
