require File.expand_path('../../../helper', __FILE__)

# Basic set of specs to verify if FFI was able to create all the required
# functions.
describe 'FFI::Aspell' do
  it 'All required C functions should exist' do
    FFI::Aspell.respond_to?(:config_new).should         == true
    FFI::Aspell.respond_to?(:config_retrieve).should    == true
    FFI::Aspell.respond_to?(:config_get_default).should == true
    FFI::Aspell.respond_to?(:config_replace).should     == true
    FFI::Aspell.respond_to?(:config_remove).should      == true
    FFI::Aspell.respond_to?(:speller_new).should        == true
    FFI::Aspell.respond_to?(:speller_check).should      == true
  end
end
