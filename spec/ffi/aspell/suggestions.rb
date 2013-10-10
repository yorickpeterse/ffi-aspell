# -*- encoding : utf-8 -*-

require File.expand_path('../../../helper', __FILE__)

describe 'FFI::Aspell::Speller#suggestions' do
  it 'Return a list of word suggestions using the default mode' do
    speller     = FFI::Aspell::Speller.new
    suggestions = speller.suggestions('cookei')

    suggestions.include?('coke').should   == true
    suggestions.include?('cookie').should == true
    suggestions.include?('cooked').should == true
  end

  it 'Return a list of UTF-8 words' do
    with_internal_encoding('UTF-8') do
      speller     = FFI::Aspell::Speller.new('el')
      suggestions = speller.suggestions('χταπίδι')

      suggestions.include?('χταπόδι').should  == true
      suggestions.include?('απίδι').should    == true
    end
  end

  it 'Return a list of word suggestions using the "bad-spellers" mode' do
    speller = FFI::Aspell::Speller.new

    # Get the amount of suggestions for the normal mode. The "bad-spellers" mode
    # should result in a lot more possible suggestions.
    normal_length = speller.suggestions('cookei').length

    speller.suggestion_mode = 'bad-spellers'
    suggestions             = speller.suggestions('cookei')

    suggestions.include?('coke').should   == true
    suggestions.include?('cookie').should == true
    suggestions.include?('cooked').should == true

    suggestions.length.should > normal_length
  end

  it 'Raise an error when an invalid suggestion mode is used' do
    speller = FFI::Aspell::Speller.new

    should.raise(FFI::Aspell::ConfigError) do
      speller.suggestion_mode = 'does-not-exist'
    end

    speller.suggestion_mode.should == 'normal'

    should.not.raise(FFI::Aspell::ConfigError) do
      speller.suggestion_mode = 'ultra'
    end

    speller.suggestion_mode.should == 'ultra'
  end
end
