# Intro

ldecNumber -- a tarantool (luajit, Lua 5.1) wrapper for the `decNumber` Decimal Arithmetic package.

The wrapper and `decNumber` library are built as a monolithic Lua module.

# Installing


```
tarantoolctl rocks install https://raw.githubusercontent.com/tarantool/ldecnumber/master/ldecnumber-scm-1.rockspec
```


# Simple example

Single user billing system

```
decnumber = require('ldecNumber')

local balance = decnumber.tonumber("0.00")

-- put some money
balance = balance + "0.01"

-- once again a little bit more
balance = balance + "1.25"


-- take some money

balance = balance - "1.12"

-- check balance value is valid

balance:isfinite() --> true
balance:isinfinite() --> false
balance:isnan() --> false

-- send to other system
balance:tostring() --> '0.14'

```

# Documentation

* [doc/decNumber.pdf](doc/decNumber.pdf) -- The decNumber C library (pdf version)
* [doc/ldecNumber.pdf](doc/ldecNumber.pdf) -- A Lua 5.1 wrapper for the decNumber library (pdf version)
* [doc/ldecNumber.html](https://htmlpreview.github.io/?https://github.com/tarantool/ldecnumber/blob/master/doc/ldecNumber.html)
-- A Lua 5.1 wrapper for the decNumber library (html version)

# Links

* http://speleotrove.com/decimal/decnumber.html -- The decNumber C Library

# Copyrights

The Lua wrapper is
Copyright (c) 2006-7 Doug Currie, Londonderry, NH
All rights reserved.

The decNumber C library is
Copyright (c) 1995-2005 International Business Machines Corporation and others
All rights reserved.

The software and documentation is made available under the terms of the 
ICU License (ICU 1.8.1 and later) included in the package as 
decNumber/ICU-license.html.


