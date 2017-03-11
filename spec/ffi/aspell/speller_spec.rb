# encoding: utf-8

require 'spec_helper'

describe FFI::Aspell::Speller do
  context '.open' do
    it 'returns a Speller object when used without a block' do
      speller = described_class.open

      expect(speller.is_a?(described_class)).to eq(true)
    end

    it 'yields a Speller object when a block is given' do
      described_class.open do |sp|
        expect(sp.is_a?(described_class)).to eq(true)
      end
    end

    it 'closes a speller automatically when using a block' do
      speller = described_class.open { |_| }

      expect(speller.closed?).to eq(true)
    end
  end

  describe '#initialize' do
    it 'sets the language of the speller' do
      speller = described_class.new('en')

      expect(speller.get('lang')).to eq('en')
    end

    it 'accepts dashes and underscores in the language name' do
      expect { described_class.new('en_GB') }.not_to raise_error
      expect { described_class.new('en-GB') }.not_to raise_error
    end
  end

  describe '#close' do
    it 'closes a speller' do
      speller = described_class.new

      speller.close

      expect(speller.closed?).to eq(true)
    end

    it 'raises RuntimeError if a speller is already closed' do
      speller = described_class.new

      speller.close

      expect { speller.close }.to raise_error(RuntimeError)
    end
  end

  describe '#closed?' do
    it 'returns false when a speller is not closed' do
      speller = described_class.new

      expect(speller.closed?).to eq(false)
    end

    it 'returns true when a speller is closed' do
      speller = described_class.new

      speller.close

      expect(speller.closed?).to eq(true)
    end
  end

  describe '#correct?' do
    it 'raises when the input is a non String object' do
      speller = described_class.new

      expect { speller.correct?(10) }.to raise_error(TypeError)
    end

    it 'raises RuntimeError when the speller is closed' do
      speller = described_class.new

      speller.close

      expect { speller.correct?('foo') }.to raise_error(RuntimeError)
    end

    context 'using an English speller' do
      before do
        @speller = described_class.new('en')
      end

      it 'returns true if a word is spelled correctly' do
        expect(@speller.correct?('cookie')).to eq(true)
      end

      it 'returns false if a word is spelled incorrectly' do
        expect(@speller.correct?('cookei')).to eq(false)
      end

      it 'allows usage of a custom word lost' do
        @speller.set(:personal, File.join(FIXTURES, 'personal.en.pws'))

        expect(@speller.correct?('github')).to eq(true)
      end
    end

    context 'using a Dutch speller' do
      before do
        @speller = described_class.new('nl')
      end

      it 'returns true if a word is spelled correctly' do
        expect(@speller.correct?('huis')).to eq(true)
      end

      it 'returns false if a world is spelled incorrectly' do
        expect(@speller.correct?('werld')).to eq(false)
      end
    end

    context 'using a Greek speller' do
      before do
        @speller = described_class.new('el')
      end

      it 'returns true if a word is spelled correctly' do
        expect(@speller.correct?('χταπόδι')).to eq(true)
      end

      it 'returns false if a word is spelled incorrectly' do
        expect(@speller.correct?('οιρανός')).to  eq(false)
      end
    end
  end

  describe '#suggestions' do
    it 'returns a list of suggestions when using an English speller' do
      speller     = described_class.new('en')
      suggestions = speller.suggestions('cookei')

      expect(suggestions.include?('cookie')).to eq(true)
      expect(suggestions.include?('cooked')).to eq(true)
    end

    it 'returns a list of suggestions when using a Greek speller' do
      speller     = described_class.new('el')
      suggestions = speller.suggestions('χταπίδι')

      expect(suggestions.include?('χταπόδι')).to eq(true)
      expect(suggestions.include?('απίδι')).to   eq(true)
    end

    it 'returns a list of suggestions using the "bad-spellers" mode' do
      speller = described_class.new
      normal  = speller.suggestions('cookei').length

      speller.suggestion_mode = 'bad-spellers'

      # The bad-spellers mode should return more suggestions.
      expect(speller.suggestions('cookei').length).to be > normal
    end

    it 'raises TypeError when using a non String input' do
      speller = described_class.new

      expect { speller.suggestions(10) }.to raise_error(TypeError)
    end

    it 'raises RuntimeError if the speller is closed' do
      speller = described_class.new

      speller.close

      expect { speller.suggestions('foo') }.to raise_error(RuntimeError)
    end
  end

  describe '#suggestion_mode=' do
    before do
      @speller = described_class.new
    end

    it 'sets the suggestion mode' do
      @speller.suggestion_mode = 'bad-spellers'

      expect(@speller.suggestion_mode).to eq('bad-spellers')
    end

    it 'raises RuntimeError if the speller is closed' do
      @speller.close

      block = -> { @speller.suggestion_mode = 'bad-spellers' }

      expect(block).to raise_error(RuntimeError)
    end
  end

  describe '#set' do
    before do
      @speller = described_class.new
    end

    it 'raises RuntimeError if the speller is closed' do
      @speller.close

      expect { @speller.set('lang', 'en') }.to raise_error(RuntimeError)
    end

    it 'raises ConfigError for an invalid suggestion mode' do
      expect { @speller.set('sug-mode', 'foobar') }.
        to raise_error(FFI::Aspell::ConfigError)
    end

    it 'sets the language of the speller' do
      @speller.set('lang', 'nl')

      expect(@speller.get('lang')).to eq('nl')
    end
  end

  describe '#get' do
    before do
      @speller = described_class.new('en')
    end

    it 'returns the language of a speller' do
      expect(@speller.get('lang')).to eq('en')
    end

    it 'raises RuntimeError if the speller is closed' do
      @speller.close

      expect { @speller.get('lang') }.to raise_error(RuntimeError)
    end

    it 'raises ConfigError for invalid configuration items' do
      expect { @speller.get('foo') }.to raise_error(FFI::Aspell::ConfigError)
    end
  end

  describe '#get_default' do
    before do
      @speller = described_class.new
    end

    it 'raises RuntimeError if the speller is closed' do
      @speller.close

      expect { @speller.get_default('lang') }.to raise_error(RuntimeError)
    end

    it 'returns a default configuration value' do
      expect(@speller.get_default('personal')).to eq('.aspell.en_US.pws')
    end

    it 'raises ConfigError for invalid configuration items' do
      block = -> { @speller.get_default('foo') }

      expect(block).to raise_error(FFI::Aspell::ConfigError)
    end
  end

  describe '#invalid_dictionary' do
    it 'raises ArgumentError if the used dictionary does not exist' do
      expect { described_class.new('qwer') }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError if the changed dictionary does not exist' do
      speller = described_class.new('en')
      expect { speller.set('lang', 'qwer') }.to raise_error(ArgumentError)
    end
  end

  describe '#reset' do
    before do
      @speller = described_class.new
    end

    it 'resets keys back to their default value' do
      @speller.set('lang', 'nl')

      expect(@speller.get('lang')).to eq('nl')

      @speller.reset('lang')

      expect(@speller.get('lang')).to eq('en_US')
    end

    it 'raises RuntimeError if the speller is closed' do
      @speller.close

      expect { @speller.reset('foo') }.to raise_error(RuntimeError)
    end

    it 'raises ConfigError when resetting an invalid option' do
      expect { @speller.reset('foo') }.to raise_error(FFI::Aspell::ConfigError)
    end
  end
end
