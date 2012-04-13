require File.expand_path('../../../helper', __FILE__)

describe 'FFI::Aspell::Speller' do
  it 'Create a new instance of FFI::Aspell::Speller' do
    speller = FFI::Aspell::Speller.new('en')
  end
end
