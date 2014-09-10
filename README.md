# FFI::Aspell

FFI::Aspell is an FFI binding for the Aspell library. It was mainly written as
[Raspell][raspell], a C binding for Aspell, is buggy and no longer maintained by
the main author as of April 2012.

## Requirements

* Ruby 1.9.3 or newer
* Aspell
* Aspell language packs for your used language(s)

For running the tests the following is required:

* Dutch language pack
* Greek language pack

Aspell can be installed as following:

* Arch Linux: `sudo pacman -S aspell`
* Ubuntu: `sudo apt-get install aspell libaspell-dev`
* OS X: `brew install aspell --lang=en`

## Usage

Install the gem:

    gem install ffi-aspell

Load it:

    require 'ffi/aspell'

The primary class is `FFI::Aspell::Speller`, this class can be used to check for
spelling errors and the likes:

    speller = FFI::Aspell::Speller.new('en_US')

    if speller.correct?('cookie')
      puts 'The word "cookie" is correct'
    else
      puts 'The word "cookie" is incorrect'
    end

    speller.close

You can use `Speller.open` to avoid having to call `#close` explicitly:

    FFI::Aspell::Speller.open('en_US') do |speller|
      puts speller.correct?('cookie')
    end

For more information see the YARD documentation.

## License

The code in this repository is licensed under the MIT license. A copy of this
license can be found in the file "LICENSE" in the root directory of this
repository.

[raspell]: https://github.com/evan/raspell
