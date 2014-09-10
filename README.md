# FFI::Aspell

FFI::Aspell is an FFI binding for the Aspell library. It was mainly written as
[Raspell][raspell], a C binding for Aspell, is buggy and no longer maintained by
the main author as of April 2012.

## Requirements

* FFI: `gem install ffi`
* Corresponding language packs. Without these the FFI binding will crash.
* Aspell's library
* Dutch and Greek language packs for Aspell (only when testing the code)

## Installing Aspell

* Arch Linux: `sudo pacman -S aspell`
* Ubuntu: `sudo apt-get install aspell libaspell-dev`
* OS X: `brew install aspell --lang=en`

## Usage

Install the gem:

    $ gem install ffi-aspell

Load it:

    require 'ffi/aspell'

The primary class is `FFI::Aspell::Speller`, this class can be used to check for
spelling errors and the like:

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

## Hacking & Contributing

1. Make sure that Aspell and the English, Dutch, and Greek dictionaries for it are
   installed as well
    - Arch Linux: `sudo pacman -S aspell aspell-en aspell-nl aspell-el`
    - Ubuntu: `sudo apt-get install aspell aspell-en aspell-nl aspell-el`
    - OS X: `brew install aspell --with-lang-en --with-lang-nl --with-lang-el`
2. Install the gems: `bundle install`
3. Run the tests to see if everything is working: `rake test`
4. Hack away!

## Coding Standards

* FFI functions go in FFI::Aspell
* Attached function names should resemble the C function names as much as
  possible.
* No more than 80 characters per line of code.
* Git commits should have a <= 50 character summary, optionally followed by a
  blank line and a more in depth description of 80 characters per line.
* Test your code!
* Document code using YARD. You don't need to write an entire book but at least
  give a brief summary of what a method does (not how it does it) and tag the
  parameters and return value.

## License

The code in this repository is licensed under the MIT license. A copy of this
license can be found in the file "LICENSE" in the root directory of this
repository.

[raspell]: https://github.com/evan/raspell
