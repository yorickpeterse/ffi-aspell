# -*- coding: utf-8 -*-

require File.expand_path('../../../helper', __FILE__)

describe 'FFI::Aspell::Speller' do
  it 'Set the language in the constructor' do
    FFI::Aspell::Speller.new.get('lang').should       == 'en_US'
    FFI::Aspell::Speller.new('en').get('lang').should == 'en'
    FFI::Aspell::Speller.new('nl').get('lang').should == 'nl'
  end

  it 'Set options in the constructor' do
    FFI::Aspell::Speller.new.get('personal').should == '.aspell.en_US.pws'

    FFI::Aspell::Speller.new('en', :personal => 'foo') \
      .get(:personal).should == 'foo'
  end

  it 'Raise when setting a non existing option' do
    should.raise(FFI::Aspell::ConfigError) do
      FFI::Aspell::Speller.new.set('foo', 'bar')
    end
  end

  it 'Raise when retrieving a non existing option' do
    should.raise(FFI::Aspell::ConfigError) do
      FFI::Aspell::Speller.new.get('foo')
    end
  end

  it 'Retrieve the default value of an option' do
    FFI::Aspell::Speller.new.get_default('personal') \
      .should == '.aspell.en_US.pws'
  end

  it 'Reset an option to its default value' do
    speller = FFI::Aspell::Speller.new

    speller.set('personal', 'foo')

    speller.get('personal').should == 'foo'

    speller.reset('personal')

    speller.get('personal').should == '.aspell.en_US.pws'
  end

  it 'Validate various English words' do
    speller = FFI::Aspell::Speller.new('en')

    speller.correct?('cookie').should == true
    speller.correct?('werld').should  == false
    speller.correct?('house').should  == true
    speller.correct?('huis').should   == false
  end

  it 'Validate various Dutch words' do
    speller = FFI::Aspell::Speller.new('nl')

    speller.correct?('koekje').should == true
    speller.correct?('werld').should  == false
    speller.correct?('huis').should   == true
  end

  it 'Validate some UTF-8 (Greek) words' do
    speller = FFI::Aspell::Speller.new('el')

    speller.correct?('χταπόδι').should == true
    speller.correct?('οιρανός').should  == false
  end

  it 'Change the language of an existing speller object' do
    speller = FFI::Aspell::Speller.new

    speller.correct?('house').should == true
    speller.correct?('huis').should  == false

    speller.set('lang', 'nl')

    speller.correct?('house').should == true
    speller.correct?('huis').should  == true
  end

  it 'Use an English personal word list' do
    speller = FFI::Aspell::Speller.new('en')

    speller.correct?('github').should == false
    speller.correct?('nodoc').should  == false

    speller.set(:personal, File.join(FIXTURES, 'personal.en.pws'))

    speller.correct?('github').should == true
    speller.correct?('nodoc').should  == true
  end

  it 'Use a Dutch personal word list' do
    speller = FFI::Aspell::Speller.new('nl')

    speller.correct?('github').should == false
    speller.correct?('nodoc').should  == false

    speller.set(:personal, File.join(FIXTURES, 'personal.nl.pws'))

    speller.correct?('github').should == true
    speller.correct?('nodoc').should  == true
  end

  it 'Supports language and options in .open' do
    value = FFI::Aspell::Speller.open('nl', :personal => 'foo') do |speller|
      speller.should.not == nil
      speller.get(:personal).should == 'foo'
      speller.get('lang').should == 'nl'
      42
    end

    value.should == 42
  end

  it 'Reports its closed status' do
    speller = FFI::Aspell::Speller.open
    speller.closed?.should == false
    speller.close
    speller.closed?.should == true

    outer_speller = FFI::Aspell::Speller.open do |speller|
      speller.closed?.should == false
      speller
    end
    outer_speller.closed?.should == true
  end

  it 'Closes when exception occurs in .open block' do
    outer_speller = nil

    should.raise(StandardError) do
      FFI::Aspell::Speller.open do |speller|
        outer_speller = speller
        raise StandardError, 'Test error.'
        speller.correct?('cookie').should == true # Never reached.
      end
    end

    outer_speller.closed?.should == true
  end

  it 'Raise when speller is closed' do
    speller = FFI::Aspell::Speller.new
    speller.close

    should.raise(RuntimeError) do
      speller.close
    end

    should.raise(RuntimeError) do
      speller.correct?('cookie')
    end

    should.raise(RuntimeError) do
      speller.suggestions('cookei')
    end

    should.raise(RuntimeError) do
      speller.suggestion_mode = 'bad-spellers'
    end

    should.raise(RuntimeError) do
      mode = speller.suggestion_mode
    end

    should.raise(RuntimeError) do
      speller.set('personal', 'foo')
    end

    should.raise(RuntimeError) do
      speller.get('lang')
    end

    should.raise(RuntimeError) do
      speller.get_default('lang')
    end

    should.raise(RuntimeError) do
      speller.reset('lang')
    end
  end
end
