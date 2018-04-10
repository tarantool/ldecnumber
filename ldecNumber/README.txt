ldecNumber -- a Lua 5.1 wrapper for the decNumber Decimal Arithmetic package.

January 15, 2007

The Lua wrapper is
Copyright (c) 2006-7 Doug Currie, Londonderry, NH
All rights reserved.

The decNumber C library is
Copyright (c) 1995-2005 International Business Machines Corporation and others
All rights reserved.

The software and documentation is made available under the terms of the 
ICU License (ICU 1.8.1 and later) included in the package as 
decNumber/ICU-license.html.

See: version.h for version info.

User documentation is provided in the doc directory.
See:
doc/ldecNumber.pdf
doc/decnumber.pdf

Building the Lua module...

The wrapper and decNumber library are built as a monolithic Lua module.

Thanks to Asko Kauppi the Makefile provided is written for multiple platforms,
and tested with MinGW/MSYS on WindowsXP, OS X, and with a Subversion repository.

Basically, the Makefile compiles and links (with Lua) three files: 
  decNumber/decContext.c and .o
  decNumber/decNumber.c and .o
  ldecNumber.c and .o
There are no extenal dependencies other than Lua 5.1(.1)

The Makefile produces a shared library (.so, .DLL) that should be installed 
in Lua's loadable C module search path (package.cpath).

Makefile targets...

make

build the loadable C module ldecNumber.{DLL|so}

make install

copy the loadable C module to $(LUACMOD)

make test

runs the tests; be sure to "make install" first!

make vcheck

update version.h from a Subversion repository -- you will not need to build 
this target; a version.h is included in the distribution

make testall

does a "make test" followed by the Windows-only performance test

make clean

the usual

make dist

probably only useful as documentation for how I build the distribution

-=-
