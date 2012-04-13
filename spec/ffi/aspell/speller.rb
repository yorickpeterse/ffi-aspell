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
end
