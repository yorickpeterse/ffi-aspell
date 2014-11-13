# Changelog

## 1.0.2 - 2014-11-13

The Speller class now checks if a dictionary is installed upon initialization or
when updating a speller (instead of just crashing). See
<https://github.com/YorickPeterse/ffi-aspell/pull/20> for more information.

## 1.0.1 - 2014-11-05

An alternative library name for Aspell was added so that this Gem now works on
Ubuntu systems.

## 1.0.0 - 2014-09-10

The first stable release of the Gem (at least according to semver). This release
contains a bunch of under the hood changes, a new project structure and a new
test suite.

The biggest change is that thanks to Chris Schmich
(<https://github.com/schmich>) ffi-aspell no longer leaks certain native
resources. A finalizer is used to clean up these resources but you can
explicitly free them by calling `close` on a speller object. See the following
issues/pull-requests for more information:

* <https://github.com/YorickPeterse/ffi-aspell/pull/15>
* <https://github.com/YorickPeterse/ffi-aspell/pull/16>
* <https://github.com/YorickPeterse/ffi-aspell/pull/17>

Another big change, and one of the reasons for the major version increase, is
the removal of support for Ruby 1.8.7. To be exact, ffi-aspell now requires Ruby
1.9.3 or newer. This simplifies some of the internal encoding handling and just
generally makes my life easier.
