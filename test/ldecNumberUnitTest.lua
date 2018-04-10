--[[ ldecNumberUnitTest.lua
*  Lua wrapper for decNumber -- unit testing
*  created September 7, 2006 by e
*
* Copyright (c) 2006 Doug Currie, Londonderry, NH
* All rights reserved.
* 
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, and/or sell copies of the Software, and to permit persons
to whom the Software is furnished to do so, provided that the above
copyright notice(s) and this permission notice appear in all copies of
the Software and that both the above copyright notice(s) and this
permission notice appear in supporting documentation.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF THIRD PARTY RIGHTS. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
HOLDERS INCLUDED IN THIS NOTICE BE LIABLE FOR ANY CLAIM, OR ANY SPECIAL
INDIRECT OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING
FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION
WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*********************************************************************]]--

require "ldecNumber"
require "lunit" -- http://www.nessie.de/mroth/lunit/  -- using 0.4a pre

-- this test is woefully incomplete!

-- lunit.setprivfenv()
lunit.import "assertions"
lunit.import "checks"

print (decNumber.version)

local comp_funcs = lunit.TestCase("Comparison Functions")

function comp_funcs:test()
    local one = decNumber.tonumber "1"
    local mone = decNumber.tonumber "-1"
    
    assert_equal(false, (one < one))
    assert_equal(false, (one > one))
    assert_equal(true, (one <= one))
    assert_equal(true, (one >= one))
    assert_equal(true, (one == one))
    assert_equal(false, (one ~= one))
    
    assert_equal(false, (mone < mone))
    assert_equal(false, (mone > mone))
    assert_equal(true, (mone <= mone))
    assert_equal(true, (mone >= mone))
    assert_equal(true, (mone == mone))
    assert_equal(false, (mone ~= mone))
    
    assert_equal(true, (mone < one))
    assert_equal(false, (mone > one))
    assert_equal(true, (mone <= one))
    assert_equal(false, (mone >= one))
    assert_equal(false, (mone == one))
    assert_equal(true, (mone ~= one))
    
    assert_equal(false, (one < mone))
    assert_equal(true, (one > mone))
    assert_equal(false, (one <= mone))
    assert_equal(true, (one >= mone))
    assert_equal(false, (one == mone))
    assert_equal(true, (one ~= mone))
end

func_memoize = function(f, t)
  local t = t or {}
  return function(k)
    local v = t[k]
        if v==nil then
          v = f(k)
          t[k] = v
        end
        return v
  end
end

local fib_funcs = lunit.TestCase("Fib Functions")

function fib_funcs:test()
    local one = decNumber.tonumber "1"
    ctx = decNumber.getcontext()
    ctx:setdefault (decNumber.INIT_BASE)
    ctx:setdigits (69)
    local Fib
    Fib = func_memoize(function(n) return Fib(n-1) + Fib(n-2) end, 
            {
            [1] = one,
            [2] = one
            })
    assert_equal (Fib(1),one)
    assert_equal (Fib(2),one)
    assert_equal (Fib(6),decNumber.tonumber "8")
    assert_equal (Fib(7):tostring(),"13")
    assert_equal (tostring(Fib(200)),"280571172992510140037611932413038677189525")
end

local mod_funcs = lunit.TestCase("Floor/Mod Functions")

local function assert_qequal(x,y,...)
    local pass = (x-y):abs() < (decNumber.tonumber "0.0001")
    if not pass then print (x:tostring(),y:tostring()) end
    return test:ok (pass, ...)
end

local function assert_nequal(x,y,...)
    local pass = x:isnan() and y:isnan() or x == y
    if not pass then print (x:tostring(),y:tostring()) end
    return test:ok (pass, ...)
end

function mod_funcs:test()
    local one = decNumber.tonumber "1"
    local zero = decNumber.tonumber "0"
    local a,b,x,y
    ctx = decNumber.getcontext()
    ctx:setdefault (decNumber.INIT_BASE)
    ctx:setdigits (69)
    ctx:setround (decNumber.ROUND_FLOOR)
    -- exceptions
    assert_true (zero:divide(zero):isnan())
    assert_true (zero:divideinteger(zero):isnan())
    assert_true (zero:remainder(zero):isnan())
    assert_true (zero:remaindernear(zero):isnan())
    assert_true (one:divide(zero):isinfinite())
    assert_true (one:divideinteger(zero):isinfinite())
    assert_true (one:remainder(zero):isnan())
    assert_true (one:remaindernear(zero):isnan())
    a = one
    b = one
    assert_equal (a:remainder(b),a - b * a:divideinteger(b))
    assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
    assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
    assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
    for i = 1,100 do
        x = math.random(999999999)
        y = math.random(999999999)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a:remainder(b),a - b * a:divideinteger(b))
        assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
        assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
        assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
        assert_equal (decNumber.mod(a,b),decNumber.tonumber(x%y))
        assert_equal (decNumber.mod(-a,b),decNumber.tonumber((-x)%y))
        assert_equal (decNumber.mod(a,-b),decNumber.tonumber(x%(-y)))
        assert_equal (decNumber.mod(-a,-b),decNumber.tonumber((-x)%(-y)))
    end
    ctx:setround (decNumber.ROUND_CEILING)
    a = one
    b = zero
    assert_nequal (a:remainder(b),a - b * a:divideinteger(b))
    assert_nequal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
    assert_nequal (a:remainder(-b),a + b * a:divideinteger(-b))
    assert_nequal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
    for i = 1,100 do
        x = math.random(999999999)
        y = math.random(999999999)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a:remainder(b),a - b * a:divideinteger(b))
        assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
        assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
        assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
        assert_equal (decNumber.mod(a,b),decNumber.tonumber(x%y))
        assert_equal (decNumber.mod(-a,b),decNumber.tonumber((-x)%y))
        assert_equal (decNumber.mod(a,-b),decNumber.tonumber(x%(-y)))
        assert_equal (decNumber.mod(-a,-b),decNumber.tonumber((-x)%(-y)))
    end
    ctx:setround (decNumber.ROUND_FLOOR)
    a = zero
    b = one
    assert_equal (a:remainder(b),a - b * a:divideinteger(b))
    assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
    assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
    assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
    for i = 1,100 do
        x = math.random(999999999)/2^math.random(99)
        y = math.random(999999999)/2^math.random(99)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a:remainder(b),a - b * a:divideinteger(b))
        assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
        assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
        assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
        assert_qequal (decNumber.mod(a,b),decNumber.tonumber(x%y))
        assert_qequal (decNumber.mod(-a,b),decNumber.tonumber((-x)%y))
        assert_qequal (decNumber.mod(a,-b),decNumber.tonumber(x%(-y)))
        assert_qequal (decNumber.mod(-a,-b),decNumber.tonumber((-x)%(-y)))
    end
    ctx:setround (decNumber.ROUND_CEILING)
    a = zero
    b = zero
    assert_nequal (a:remainder(b),a - b * a:divideinteger(b))
    assert_nequal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
    assert_nequal (a:remainder(-b),a + b * a:divideinteger(-b))
    assert_nequal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
    for i = 1,100 do
        x = math.random(999999999)/2^math.random(99)
        y = math.random(999999999)/2^math.random(99)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a:remainder(b),a - b * a:divideinteger(b))
        assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
        assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
        assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
        assert_qequal (decNumber.mod(a,b),decNumber.tonumber(x%y))
        assert_qequal (decNumber.mod(-a,b),decNumber.tonumber((-x)%y))
        assert_qequal (decNumber.mod(a,-b),decNumber.tonumber(x%(-y)))
        assert_qequal (decNumber.mod(-a,-b),decNumber.tonumber((-x)%(-y)))
    end
end

function mod_funcs:testinfix()
    local one = decNumber.tonumber "1"
    local zero = decNumber.tonumber "0"
    local a,b,x,y
    ctx = decNumber.getcontext()
    ctx:setdefault (decNumber.INIT_BASE)
    ctx:setdigits (69)
    ctx:setround (decNumber.ROUND_FLOOR)
    -- exceptions
    assert_true (zero:divide(zero):isnan())
    assert_true (zero:divideinteger(zero):isnan())
    assert_true (zero:remainder(zero):isnan())
    assert_true (zero:remaindernear(zero):isnan())
    assert_true (one:divide(zero):isinfinite())
    assert_true (one:divideinteger(zero):isinfinite())
    assert_true (one:remainder(zero):isnan())
    assert_true (one:remaindernear(zero):isnan())
    -- special cases
    x = 3
    y = -1
    a = decNumber.tonumber(x)
    b = decNumber.tonumber(y)
    assert_equal (a%b,decNumber.tonumber(x%y))
    x = 3
    y = 1
    a = decNumber.tonumber(x)
    b = decNumber.tonumber(y)
    assert_equal (a%b,decNumber.tonumber(x%y))
    x = -3
    y = 1
    a = decNumber.tonumber(x)
    b = decNumber.tonumber(y)
    assert_equal (a%b,decNumber.tonumber(x%y))
    x = -3
    y = -1
    a = decNumber.tonumber(x)
    b = decNumber.tonumber(y)
    assert_equal (a%b,decNumber.tonumber(x%y))
    -- 
    a = one + one
    b = one
    assert_equal (a:remainder(b),a - b * a:divideinteger(b))
    assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
    assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
    assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
    for i = 1,100 do
        x = (-1^math.random(2)) * math.random(999999999)
        y = (-1^math.random(2)) * math.random(999999999)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a:remainder(b),a - b * a:divideinteger(b))
        assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
        assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
        assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
        assert_equal (a%b,decNumber.tonumber(x%y))
        assert_equal ((-a)%b,decNumber.tonumber((-x)%y))
        assert_equal (a%(-b),decNumber.tonumber(x%(-y)))
        assert_equal ((-a)%(-b),decNumber.tonumber((-x)%(-y)))
    end
    ctx:setround (decNumber.ROUND_CEILING)
    a = one + one
    b = zero
    assert_nequal (a:remainder(b),a - b * a:divideinteger(b))
    assert_nequal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
    assert_nequal (a:remainder(-b),a + b * a:divideinteger(-b))
    assert_nequal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
    for i = 1,100 do
        x = (-1^math.random(2)) * math.random(999999999)
        y = (-1^math.random(2)) * math.random(999999999)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a:remainder(b),a - b * a:divideinteger(b))
        assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
        assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
        assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
        assert_equal (a%b,decNumber.tonumber(x%y))
        assert_equal ((-a)%b,decNumber.tonumber((-x)%y))
        assert_equal (a%(-b),decNumber.tonumber(x%(-y)))
        assert_equal ((-a)%(-b),decNumber.tonumber((-x)%(-y)))
    end
    ctx:setround (decNumber.ROUND_FLOOR)
    a = zero
    b = zero
    assert_nequal (a:remainder(b),a - b * a:divideinteger(b))
    assert_nequal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
    assert_nequal (a:remainder(-b),a + b * a:divideinteger(-b))
    assert_nequal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
    for i = 1,100 do
        x = (-1^math.random(2)) * math.random(999999999)/2^math.random(99)
        y = (-1^math.random(2)) * math.random(999999999)/2^math.random(99)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a:remainder(b),a - b * a:divideinteger(b))
        assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
        assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
        assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
        assert_qequal (a%b,decNumber.tonumber(x%y))
        assert_qequal ((-a)%b,decNumber.tonumber((-x)%y))
        assert_qequal (a%(-b),decNumber.tonumber(x%(-y)))
        assert_qequal ((-a)%(-b),decNumber.tonumber((-x)%(-y)))
    end
    ctx:setround (decNumber.ROUND_CEILING)
    a = zero
    b = one + one
    assert_equal (a:remainder(b),a - b * a:divideinteger(b))
    assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
    assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
    assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
    for i = 1,100 do
        x = (-1^math.random(2)) * math.random(999999999)/2^math.random(99)
        y = (-1^math.random(2)) * math.random(999999999)/2^math.random(99)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a:remainder(b),a - b * a:divideinteger(b))
        assert_equal ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
        assert_equal (a:remainder(-b),a + b * a:divideinteger(-b))
        assert_equal ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
        assert_qequal (a%b,decNumber.tonumber(x%y))
        assert_qequal ((-a)%b,decNumber.tonumber((-x)%y))
        assert_qequal (a%(-b),decNumber.tonumber(x%(-y)))
        assert_qequal ((-a)%(-b),decNumber.tonumber((-x)%(-y)))
    end
end

function mod_funcs:test_floor()
    local ctx = decNumber.getcontext()
    ctx:setdefault(decNumber.INIT_DECIMAL128)
    -- explicit rounding ROUND_FLOOR
    ctx:setround(decNumber.ROUND_FLOOR)
    assert_equal (decNumber.tointegralvalue("17.50"), decNumber.tonumber "17")
    assert_equal (decNumber.tointegralvalue("-17.50"), decNumber.tonumber "-18")
    -- setup args
    local p = decNumber.tonumber "1750"
    local n = decNumber.tonumber "-1750"
    local h = decNumber.tonumber "100"
    -- divideinteger ~= floor, even with ctx:setround(decNumber.ROUND_FLOOR)
    assert_equal (p:divideinteger(h), decNumber.tonumber "17")
    assert_equal (n:divideinteger(h), decNumber.tonumber "-17")
    -- restore rounding to the default
    ctx:setround(decNumber.ROUND_HALF_EVEN)
    -- now test our floor
    assert_equal (p:floor(h), decNumber.tonumber "17")
    assert_equal (n:floor(h), decNumber.tonumber "-18")
    assert_equal (p:floor("10"), decNumber.tonumber "175")
    assert_equal (n:floor("10"), decNumber.tonumber "-175")
    -- identity tests
        for i = 1,100 do
        x = math.random(999999999)
        y = math.random(999999999)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a%b, a - b * a:floor(b))
        assert_equal ((-a)%(b), (-a) - b * (-a):floor(b))
        assert_equal (a%(-b), a + b * a:floor(-b))
        assert_equal ((-a)%(-b), (-a) + b * (-a):floor(-b))
    end
    for i = 1,100 do
        x = (-1^math.random(2)) * math.random(999999999)
        y = (-1^math.random(2)) * math.random(999999999)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a%b, a - b * a:floor(b))
        assert_equal ((-a)%(b), (-a) - b * (-a):floor(b))
        assert_equal (a%(-b), a + b * a:floor(-b))
        assert_equal ((-a)%(-b), (-a) + b * (-a):floor(-b))
    end
    for i = 1,200 do
        x = (-1^math.random(2)) * math.random(999999999)/2^math.random(29)
        y = (-1^math.random(2)) * math.random(999999999)/2^math.random(29)
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_equal (a%b, a - b * a:floor(b))
        assert_equal ((-a)%(b), (-a) - b * (-a):floor(b))
        assert_equal (a%(-b), a + b * a:floor(-b))
        assert_equal ((-a)%(-b), (-a) + b * (-a):floor(-b))
    end
    for x,y in pairs {[0]=1, [1]=0} do
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_nequal (a%b, a - b * a:floor(b))
        assert_nequal ((-a)%(b), (-a) - b * (-a):floor(b))
        assert_nequal (a%(-b), a + b * a:floor(-b))
        assert_nequal ((-a)%(-b), (-a) + b * (-a):floor(-b))
    end
    for x,y in pairs {[0]=0, [1]=1} do
        a = decNumber.tonumber(x)
        b = decNumber.tonumber(y)
        assert_nequal (a%b, a - b * a:floor(b))
        assert_nequal ((-a)%(b), (-a) - b * (-a):floor(b))
        assert_nequal (a%(-b), a + b * a:floor(-b))
        assert_nequal ((-a)%(-b), (-a) + b * (-a):floor(-b))
    end
end

local round_funcs = lunit.TestCase("Rounding")

function round_funcs:test()
-- decNumber.ROUND_CEILING     round towards +infinity
-- decNumber.ROUND_UP          round away from 0
-- decNumber.ROUND_HALF_UP     0.5 rounds up
-- decNumber.ROUND_HALF_EVEN   0.5 rounds to nearest even
-- decNumber.ROUND_HALF_DOWN   0.5 rounds down
-- decNumber.ROUND_DOWN        round towards 0 (truncate)
-- decNumber.ROUND_FLOOR       round towards -infinity    local n = decNumber.tonumber "12.345"
    ctx = decNumber.getcontext()
    ctx:setdefault (decNumber.INIT_BASE)
    ctx:setdigits (5)
    local m = decNumber.tonumber "12.343"
    local n = decNumber.tonumber "12.345"
    local p = decNumber.tonumber "12.347"
    local d = decNumber.tonumber ".01"
    local q = decNumber.tonumber "2"
    ctx:setround(decNumber.ROUND_CEILING)
    assert_equal (m:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-m):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (n:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-n):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (p:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-p):quantize(d),decNumber.tonumber "-12.34")
    ctx:setround(decNumber.ROUND_UP)
    assert_equal (m:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-m):quantize(d),decNumber.tonumber "-12.35")
    assert_equal (n:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-n):quantize(d),decNumber.tonumber "-12.35")
    assert_equal (p:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-p):quantize(d),decNumber.tonumber "-12.35")
    ctx:setround(decNumber.ROUND_HALF_UP)
    assert_equal (m:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-m):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (n:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-n):quantize(d),decNumber.tonumber "-12.35")
    assert_equal (p:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-p):quantize(d),decNumber.tonumber "-12.35")
    ctx:setround(decNumber.ROUND_HALF_EVEN)
    assert_equal (m:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-m):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (n:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-n):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (p:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-p):quantize(d),decNumber.tonumber "-12.35")
    ctx:setround(decNumber.ROUND_HALF_DOWN)
    assert_equal (m:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-m):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (n:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-n):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (p:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-p):quantize(d),decNumber.tonumber "-12.35")
    ctx:setround(decNumber.ROUND_DOWN)
    assert_equal (m:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-m):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (n:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-n):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (p:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-p):quantize(d),decNumber.tonumber "-12.34")
    ctx:setround(decNumber.ROUND_FLOOR)
    assert_equal (m:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-m):quantize(d),decNumber.tonumber "-12.35")
    assert_equal (n:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-n):quantize(d),decNumber.tonumber "-12.35")
    assert_equal (p:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-p):quantize(d),decNumber.tonumber "-12.35")
end

function round_funcs:test_dup()
    ctx = decNumber.getcontext()
    dupc = ctx:duplicate()
    dupc:setdefault (decNumber.INIT_BASE)
    dupc:setdigits (5)
    dupc:setround(decNumber.ROUND_CEILING)
    dupe = dupc:duplicate()
    dupe:setround(decNumber.ROUND_HALF_UP)
    local m = decNumber.tonumber "12.343"
    local n = decNumber.tonumber "12.345"
    local p = decNumber.tonumber "12.347"
    local d = decNumber.tonumber ".01"
    local q = decNumber.tonumber "2"
    dupc:setcontext()
    assert_equal (m:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-m):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (n:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-n):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (p:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-p):quantize(d),decNumber.tonumber "-12.34")
    decNumber.setcontext(dupe)
    assert_equal (m:quantize(d),decNumber.tonumber "12.34")
    assert_equal ((-m):quantize(d),decNumber.tonumber "-12.34")
    assert_equal (n:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-n):quantize(d),decNumber.tonumber "-12.35")
    assert_equal (p:quantize(d),decNumber.tonumber "12.35")
    assert_equal ((-p):quantize(d),decNumber.tonumber "-12.35")
    ctx:setcontext()
end

local rng_funcs = lunit.TestCase("Random Numbers")

function rng_funcs:test()
    local r = decNumber.randomstate(999,777,555)
    local s = decNumber.randomstate(999,777,555)
    local t = decNumber.randomstate()
    local r1,s1,t1 = r(), s(), t()
    local r2,s2,t2 = r(), s(), t()
    assert_equal (r1, s1)
    assert_not_equal (r1,t1)
    assert_equal (r2, s2)
    assert_not_equal (r1,r2)
    assert_not_equal (r2,t2)
    assert_true(r(12,-12) < r(12,1))
    assert_true(t(12,-12) < decNumber.tonumber "1")
    assert_true(t(12,1) > decNumber.tonumber "1")
end

local cls_funcs = lunit.TestCase("Classifier Functions")

function cls_funcs:test()
    local ctx = decNumber.getcontext()
    ctx:setdefault(decNumber.INIT_DECIMAL128)
    local pi = (decNumber.tonumber "1") / 0
    local ni = -pi
    local pn = decNumber.tonumber "12.347"
    local nn = -pn
    local ps = decNumber.tonumber "1e-6144"
    local ns = -ps
    local nz = decNumber.tonumber "-0"
    local pz = -nz
    local nan = decNumber.tonumber "NaN"
    local inv = (decNumber.tonumber "2"):invert()
    assert_equal (pi:classasstring(), "+Infinity")
    assert_equal (ni:classasstring(), "-Infinity")
    assert_equal (pn:classasstring(), "+Normal")
    assert_equal (nn:classasstring(), "-Normal")
    assert_equal (ps:classasstring(), "+Subnormal")
    assert_equal (ns:classasstring(), "-Subnormal")
    assert_equal (pz:classasstring(), "+Zero")
    assert_equal (nz:classasstring(), "-Zero")
    assert_equal (nan:classasstring(), "NaN")
    --assert_equal (inv:classasstring(), "Invalid") -- NaN
    assert_equal (pi:class(), decNumber.CLASS_POS_INF)
    assert_equal (ni:class(), decNumber.CLASS_NEG_INF)
    assert_equal (pn:class(), decNumber.CLASS_POS_NORMAL)
    assert_equal (nn:class(), decNumber.CLASS_NEG_NORMAL)
    assert_equal (ps:class(), decNumber.CLASS_POS_SUBNORMAL)
    assert_equal (ns:class(), decNumber.CLASS_NEG_SUBNORMAL)
    assert_equal (pz:class(), decNumber.CLASS_POS_ZERO)
    assert_equal (nz:class(), decNumber.CLASS_NEG_ZERO)
    assert_equal (nan:class(), decNumber.CLASS_QNAN)
    assert_equal (decNumber.classtostring(pi:class()), "+Infinity")
    assert_equal (decNumber.classtostring(ni:class()), "-Infinity")
    assert_equal (decNumber.classtostring(pn:class()), "+Normal")
    assert_equal (decNumber.classtostring(nn:class()), "-Normal")
    assert_equal (decNumber.classtostring(ps:class()), "+Subnormal")
    assert_equal (decNumber.classtostring(ns:class()), "-Subnormal")
    assert_equal (decNumber.classtostring(pz:class()), "+Zero")
    assert_equal (decNumber.classtostring(nz:class()), "-Zero")
    assert_equal (decNumber.classtostring(nan:class()), "NaN")
    -- predicates
    assert_false (pi:isnormal())
    assert_false (ni:isnormal())
    assert_true  (pn:isnormal())
    assert_true  (nn:isnormal())
    assert_false (pz:isnormal())
    assert_false (nz:isnormal())
    assert_false (ns:isnormal())
    assert_false (ps:isnormal())
    assert_false (nan:isnormal())
    assert_false (pi:issubnormal())
    assert_false (ni:issubnormal())
    assert_false (pn:issubnormal())
    assert_false (nn:issubnormal())
    assert_false (pz:issubnormal())
    assert_false (nz:issubnormal())
    assert_true  (ns:issubnormal())
    assert_true  (ps:issubnormal())
    assert_false (nan:issubnormal())
    assert_false (pi:isfinite())
    assert_false (ni:isfinite())
    assert_true  (pn:isfinite())
    assert_true  (nn:isfinite())
    assert_true  (pz:isfinite())
    assert_true  (nz:isfinite())
    assert_true  (ns:isfinite())
    assert_true  (ps:isfinite())
    assert_false (nan:isfinite())
    assert_true  (pi:isspecial())
    assert_true  (ni:isspecial())
    assert_false (pn:isspecial())
    assert_false (nn:isspecial())
    assert_false (pz:isspecial())
    assert_false (nz:isspecial())
    assert_false (ns:isspecial())
    assert_false (ps:isspecial())
    assert_true  (nan:isspecial())
    assert_true (pi:iscanonical())
    assert_true (ni:iscanonical())
    assert_true (pn:iscanonical())
    assert_true (nn:iscanonical())
    assert_true (pz:iscanonical())
    assert_true (nz:iscanonical())
    assert_true (ns:iscanonical())
    assert_true (ps:iscanonical())
    assert_true (nan:iscanonical())
    -- misc
    assert_equal (pi:radix(), 10)
    assert_equal (ni:radix(), 10)
    assert_equal (pn:radix(), 10)
    assert_equal (nn:radix(), 10)
    assert_equal (ps:radix(), 10)
    assert_equal (ns:radix(), 10)
    assert_equal (pz:radix(), 10)
    assert_equal (nz:radix(), 10)
    assert_equal (nan:radix(), 10)

end

lunit.run()
