#!/usr/bin/env tarantool
require('strict').on()

local decNumber = require('ldecNumber')
local tap = require('tap')

local test = tap.test('ldecNumber tests')
test:plan(9)

test:test('Comparison Functions', function(test)
              test:plan(24)

              local one = decNumber.tonumber "1"
              local mone = decNumber.tonumber "-1"

              test:is(false, (one < one))
              test:is(false, (one > one))
              test:is(true, (one <= one))
              test:is(true, (one >= one))
              test:is(true, (one == one))
              test:is(false, (one ~= one))

              test:is(false, (mone < mone))
              test:is(false, (mone > mone))
              test:is(true, (mone <= mone))
              test:is(true, (mone >= mone))
              test:is(true, (mone == mone))
              test:is(false, (mone ~= mone))

              test:is(true, (mone < one))
              test:is(false, (mone > one))
              test:is(true, (mone <= one))
              test:is(false, (mone >= one))
              test:is(false, (mone == one))
              test:is(true, (mone ~= one))

              test:is(false, (one < mone))
              test:is(true, (one > mone))
              test:is(false, (one <= mone))
              test:is(true, (one >= mone))
              test:is(false, (one == mone))
              test:is(true, (one ~= mone))
end)

local func_memoize = function(f, t)
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


test:test('Fib Functions', function(test)
              test:plan(5)
              local one = decNumber.tonumber "1"
              local ctx = decNumber.getcontext()
              ctx:setdefault (decNumber.INIT_BASE)
              ctx:setdigits (69)
              local Fib
              Fib = func_memoize(function(n) return Fib(n-1) + Fib(n-2) end,
                  {
                      [1] = one,
                      [2] = one
              })
              test:is (Fib(1),one)
              test:is (Fib(2),one)
              test:is (Fib(6),decNumber.tonumber "8")
              test:is (Fib(7):tostring(),"13")
              test:is (tostring(Fib(200)),"280571172992510140037611932413038677189525")
end)

local function assert_qequal(test, x,y,...)
    local pass = (x-y):abs() < (decNumber.tonumber "0.0001")
    if not pass then test:fail(...) end
    return test:ok (pass, ...)
end

local function assert_nequal(test, x,y,...)
    local pass = x:isnan() and y:isnan() or x == y
    if not pass then test:fail(...) end
    return test:ok (pass, ...)
end


test:test('Floor/Mod Functions', function(test)
              test:plan(3224)
              local one = decNumber.tonumber "1"
              local zero = decNumber.tonumber "0"
              local a,b,x,y
              local ctx = decNumber.getcontext()
              ctx:setdefault (decNumber.INIT_BASE)
              ctx:setdigits (69)
              ctx:setround (decNumber.ROUND_FLOOR)
              -- exceptions
              test:ok (zero:divide(zero):isnan())
              test:ok (zero:divideinteger(zero):isnan())
              test:ok (zero:remainder(zero):isnan())
              test:ok (zero:remaindernear(zero):isnan())
              test:ok (one:divide(zero):isinfinite())
              test:ok (one:divideinteger(zero):isinfinite())
              test:ok (one:remainder(zero):isnan())
              test:ok (one:remaindernear(zero):isnan())
              a = one
              b = one
              test:is (a:remainder(b),a - b * a:divideinteger(b))
              test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
              test:is (a:remainder(-b),a + b * a:divideinteger(-b))
              test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
              for i = 1,100 do
                  x = math.random(999999999)
                  y = math.random(999999999)
                  a = decNumber.tonumber(x)
                  b = decNumber.tonumber(y)
                  test:is (a:remainder(b),a - b * a:divideinteger(b))
                  test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
                  test:is (a:remainder(-b),a + b * a:divideinteger(-b))
                  test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
                  test:is (decNumber.mod(a,b),decNumber.tonumber(x%y))
                  test:is (decNumber.mod(-a,b),decNumber.tonumber((-x)%y))
                  test:is (decNumber.mod(a,-b),decNumber.tonumber(x%(-y)))
                  test:is (decNumber.mod(-a,-b),decNumber.tonumber((-x)%(-y)))
              end
              ctx:setround (decNumber.ROUND_CEILING)
              a = one
              b = zero
              assert_nequal (test, a:remainder(b),a - b * a:divideinteger(b))
              assert_nequal (test, (-a):remainder(b),(-a) - b * (-a):divideinteger(b))
              assert_nequal (test, a:remainder(-b),a + b * a:divideinteger(-b))
              assert_nequal (test, (-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
              for i = 1,100 do
                  x = math.random(999999999)
                  y = math.random(999999999)
                  a = decNumber.tonumber(x)
                  b = decNumber.tonumber(y)
                  test:is (a:remainder(b),a - b * a:divideinteger(b))
                  test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
                  test:is (a:remainder(-b),a + b * a:divideinteger(-b))
                  test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
                  test:is (decNumber.mod(a,b),decNumber.tonumber(x%y))
                  test:is (decNumber.mod(-a,b),decNumber.tonumber((-x)%y))
                  test:is (decNumber.mod(a,-b),decNumber.tonumber(x%(-y)))
                  test:is (decNumber.mod(-a,-b),decNumber.tonumber((-x)%(-y)))
              end
              ctx:setround (decNumber.ROUND_FLOOR)
              a = zero
              b = one
              test:is (a:remainder(b),a - b * a:divideinteger(b))
              test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
              test:is (a:remainder(-b),a + b * a:divideinteger(-b))
              test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
              for i = 1,100 do
                  x = math.random(999999999)/2^math.random(99)
                  y = math.random(999999999)/2^math.random(99)
                  a = decNumber.tonumber(x)
                  b = decNumber.tonumber(y)
                  test:is (a:remainder(b),a - b * a:divideinteger(b))
                  test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
                  test:is (a:remainder(-b),a + b * a:divideinteger(-b))
                  test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
                  assert_qequal (test, decNumber.mod(a,b),decNumber.tonumber(x%y))
                  assert_qequal (test, decNumber.mod(-a,b),decNumber.tonumber((-x)%y))
                  assert_qequal (test, decNumber.mod(a,-b),decNumber.tonumber(x%(-y)))
                  assert_qequal (test, decNumber.mod(-a,-b),decNumber.tonumber((-x)%(-y)))
              end
              ctx:setround (decNumber.ROUND_CEILING)
              a = zero
              b = zero
              assert_nequal (test, a:remainder(b),a - b * a:divideinteger(b))
              assert_nequal (test, (-a):remainder(b),(-a) - b * (-a):divideinteger(b))
              assert_nequal (test, a:remainder(-b),a + b * a:divideinteger(-b))
              assert_nequal (test, (-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
              for i = 1,100 do
                  x = math.random(999999999)/2^math.random(99)
                  y = math.random(999999999)/2^math.random(99)
                  a = decNumber.tonumber(x)
                  b = decNumber.tonumber(y)
                  test:is (a:remainder(b),a - b * a:divideinteger(b))
                  test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
                  test:is (a:remainder(-b),a + b * a:divideinteger(-b))
                  test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
                  assert_qequal (test, decNumber.mod(a,b),decNumber.tonumber(x%y))
                  assert_qequal (test, decNumber.mod(-a,b),decNumber.tonumber((-x)%y))
                  assert_qequal (test, decNumber.mod(a,-b),decNumber.tonumber(x%(-y)))
                  assert_qequal (test, decNumber.mod(-a,-b),decNumber.tonumber((-x)%(-y)))
              end
end)

test:test('Floor/Mod Functions Infinite', function(test)
              test:plan(3228)
              local one = decNumber.tonumber "1"
              local zero = decNumber.tonumber "0"
              local a,b,x,y
              local ctx = decNumber.getcontext()
              ctx:setdefault (decNumber.INIT_BASE)
              ctx:setdigits (69)
              ctx:setround (decNumber.ROUND_FLOOR)
              -- exceptions
              test:ok (zero:divide(zero):isnan())
              test:ok (zero:divideinteger(zero):isnan())
              test:ok (zero:remainder(zero):isnan())
              test:ok (zero:remaindernear(zero):isnan())
              test:ok (one:divide(zero):isinfinite())
              test:ok (one:divideinteger(zero):isinfinite())
              test:ok (one:remainder(zero):isnan())
              test:ok (one:remaindernear(zero):isnan())
              -- special cases
              x = 3
              y = -1
              a = decNumber.tonumber(x)
              b = decNumber.tonumber(y)
              test:is (a%b,decNumber.tonumber(x%y))
              x = 3
              y = 1
              a = decNumber.tonumber(x)
              b = decNumber.tonumber(y)
              test:is (a%b,decNumber.tonumber(x%y))
              x = -3
              y = 1
              a = decNumber.tonumber(x)
              b = decNumber.tonumber(y)
              test:is (a%b,decNumber.tonumber(x%y))
              x = -3
              y = -1
              a = decNumber.tonumber(x)
              b = decNumber.tonumber(y)
              test:is (a%b,decNumber.tonumber(x%y))
              --
              a = one + one
              b = one
              test:is (a:remainder(b),a - b * a:divideinteger(b))
              test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
              test:is (a:remainder(-b),a + b * a:divideinteger(-b))
              test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
              for i = 1,100 do
                  x = (-1^math.random(2)) * math.random(999999999)
                  y = (-1^math.random(2)) * math.random(999999999)
                  a = decNumber.tonumber(x)
                  b = decNumber.tonumber(y)
                  test:is (a:remainder(b),a - b * a:divideinteger(b))
                  test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
                  test:is (a:remainder(-b),a + b * a:divideinteger(-b))
                  test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
                  test:is (a%b,decNumber.tonumber(x%y))
                  test:is ((-a)%b,decNumber.tonumber((-x)%y))
                  test:is (a%(-b),decNumber.tonumber(x%(-y)))
                  test:is ((-a)%(-b),decNumber.tonumber((-x)%(-y)))
              end
              ctx:setround (decNumber.ROUND_CEILING)
              a = one + one
              b = zero
              assert_nequal (test, a:remainder(b),a - b * a:divideinteger(b))
              assert_nequal (test, (-a):remainder(b),(-a) - b * (-a):divideinteger(b))
              assert_nequal (test, a:remainder(-b),a + b * a:divideinteger(-b))
              assert_nequal (test, (-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
              for i = 1,100 do
                  x = (-1^math.random(2)) * math.random(999999999)
                  y = (-1^math.random(2)) * math.random(999999999)
                  a = decNumber.tonumber(x)
                  b = decNumber.tonumber(y)
                  test:is (a:remainder(b),a - b * a:divideinteger(b))
                  test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
                  test:is (a:remainder(-b),a + b * a:divideinteger(-b))
                  test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
                  test:is (a%b,decNumber.tonumber(x%y))
                  test:is ((-a)%b,decNumber.tonumber((-x)%y))
                  test:is (a%(-b),decNumber.tonumber(x%(-y)))
                  test:is ((-a)%(-b),decNumber.tonumber((-x)%(-y)))
              end
              ctx:setround (decNumber.ROUND_FLOOR)
              a = zero
              b = zero
              assert_nequal (test, a:remainder(b),a - b * a:divideinteger(b))
              assert_nequal (test, (-a):remainder(b),(-a) - b * (-a):divideinteger(b))
              assert_nequal (test, a:remainder(-b),a + b * a:divideinteger(-b))
              assert_nequal (test, (-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
              for i = 1,100 do
                  x = (-1^math.random(2)) * math.random(999999999)/2^math.random(99)
                  y = (-1^math.random(2)) * math.random(999999999)/2^math.random(99)
                  a = decNumber.tonumber(x)
                  b = decNumber.tonumber(y)
                  test:is (a:remainder(b),a - b * a:divideinteger(b))
                  test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
                  test:is (a:remainder(-b),a + b * a:divideinteger(-b))
                  test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
                  assert_qequal (test, a%b,decNumber.tonumber(x%y))
                  assert_qequal (test, (-a)%b,decNumber.tonumber((-x)%y))
                  assert_qequal (test, a%(-b),decNumber.tonumber(x%(-y)))
                  assert_qequal (test, (-a)%(-b),decNumber.tonumber((-x)%(-y)))
              end
              ctx:setround (decNumber.ROUND_CEILING)
              a = zero
              b = one + one
              test:is (a:remainder(b),a - b * a:divideinteger(b))
              test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
              test:is (a:remainder(-b),a + b * a:divideinteger(-b))
              test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
              for i = 1,100 do
                  x = (-1^math.random(2)) * math.random(999999999)/2^math.random(99)
                  y = (-1^math.random(2)) * math.random(999999999)/2^math.random(99)
                  a = decNumber.tonumber(x)
                  b = decNumber.tonumber(y)
                  test:is (a:remainder(b),a - b * a:divideinteger(b))
                  test:is ((-a):remainder(b),(-a) - b * (-a):divideinteger(b))
                  test:is (a:remainder(-b),a + b * a:divideinteger(-b))
                  test:is ((-a):remainder(-b),(-a) + b * (-a):divideinteger(-b))
                  assert_qequal (test, a%b,decNumber.tonumber(x%y))
                  assert_qequal (test, (-a)%b,decNumber.tonumber((-x)%y))
                  assert_qequal (test, a%(-b),decNumber.tonumber(x%(-y)))
                  assert_qequal (test, (-a)%(-b),decNumber.tonumber((-x)%(-y)))
              end
end)

test:test("Test floor", function (test)
              test:plan(1624)
              local ctx = decNumber.getcontext()
              ctx:setdefault(decNumber.INIT_DECIMAL128)
              -- explicit rounding ROUND_FLOOR
              ctx:setround(decNumber.ROUND_FLOOR)
              test:is (decNumber.tointegralvalue("17.50"), decNumber.tonumber "17")
              test:is (decNumber.tointegralvalue("-17.50"), decNumber.tonumber "-18")
              -- setup args
              local p = decNumber.tonumber "1750"
              local n = decNumber.tonumber "-1750"
              local h = decNumber.tonumber "100"
              -- divideinteger ~= floor, even with ctx:setround(decNumber.ROUND_FLOOR)
              test:is (p:divideinteger(h), decNumber.tonumber "17")
              test:is (n:divideinteger(h), decNumber.tonumber "-17")
              -- restore rounding to the default
              ctx:setround(decNumber.ROUND_HALF_EVEN)
              -- now test our floor
              test:is (p:floor(h), decNumber.tonumber "17")
              test:is (n:floor(h), decNumber.tonumber "-18")
              test:is (p:floor("10"), decNumber.tonumber "175")
              test:is (n:floor("10"), decNumber.tonumber "-175")
              -- identity tests
              for i = 1,100 do
                  local x = math.random(999999999)
                  local y = math.random(999999999)
                  local a = decNumber.tonumber(x)
                  local b = decNumber.tonumber(y)
                  test:is (a%b, a - b * a:floor(b))
                  test:is ((-a)%(b), (-a) - b * (-a):floor(b))
                  test:is (a%(-b), a + b * a:floor(-b))
                  test:is ((-a)%(-b), (-a) + b * (-a):floor(-b))
              end
              for i = 1,100 do
                  local x = (-1^math.random(2)) * math.random(999999999)
                  local y = (-1^math.random(2)) * math.random(999999999)
                  local a = decNumber.tonumber(x)
                  local b = decNumber.tonumber(y)
                  test:is (a%b, a - b * a:floor(b))
                  test:is ((-a)%(b), (-a) - b * (-a):floor(b))
                  test:is (a%(-b), a + b * a:floor(-b))
                  test:is ((-a)%(-b), (-a) + b * (-a):floor(-b))
              end
              for i = 1,200 do
                  local x = (-1^math.random(2)) * math.random(999999999)/2^math.random(29)
                  local y = (-1^math.random(2)) * math.random(999999999)/2^math.random(29)
                  local a = decNumber.tonumber(x)
                  local b = decNumber.tonumber(y)
                  test:is (a%b, a - b * a:floor(b))
                  test:is ((-a)%(b), (-a) - b * (-a):floor(b))
                  test:is (a%(-b), a + b * a:floor(-b))
                  test:is ((-a)%(-b), (-a) + b * (-a):floor(-b))
              end
              for x,y in pairs {[0]=1, [1]=0} do
                  local a = decNumber.tonumber(x)
                  local b = decNumber.tonumber(y)
                  assert_nequal (test, a%b, a - b * a:floor(b))
                  assert_nequal (test, (-a)%(b), (-a) - b * (-a):floor(b))
                  assert_nequal (test, a%(-b), a + b * a:floor(-b))
                  assert_nequal (test, (-a)%(-b), (-a) + b * (-a):floor(-b))
              end
              for x,y in pairs {[0]=0, [1]=1} do
                  local a = decNumber.tonumber(x)
                  local b = decNumber.tonumber(y)
                  assert_nequal (test, a%b, a - b * a:floor(b))
                  assert_nequal (test, (-a)%(b), (-a) - b * (-a):floor(b))
                  assert_nequal (test, a%(-b), a + b * a:floor(-b))
                  assert_nequal (test, (-a)%(-b), (-a) + b * (-a):floor(-b))
              end
end)

test:test("Rounding", function (test)
              test:plan(42)
              -- decNumber.ROUND_CEILING     round towards +infinity
              -- decNumber.ROUND_UP          round away from 0
              -- decNumber.ROUND_HALF_UP     0.5 rounds up
              -- decNumber.ROUND_HALF_EVEN   0.5 rounds to nearest even
              -- decNumber.ROUND_HALF_DOWN   0.5 rounds down
              -- decNumber.ROUND_DOWN        round towards 0 (truncate)
              -- decNumber.ROUND_FLOOR       round towards -infinity    local n = decNumber.tonumber "12.345"
              local ctx = decNumber.getcontext()
              ctx:setdefault (decNumber.INIT_BASE)
              ctx:setdigits (5)
              local m = decNumber.tonumber "12.343"
              local n = decNumber.tonumber "12.345"
              local p = decNumber.tonumber "12.347"
              local d = decNumber.tonumber ".01"
              local q = decNumber.tonumber "2"
              ctx:setround(decNumber.ROUND_CEILING)
              test:is (m:quantize(d),decNumber.tonumber "12.35")
              test:is ((-m):quantize(d),decNumber.tonumber "-12.34")
              test:is (n:quantize(d),decNumber.tonumber "12.35")
              test:is ((-n):quantize(d),decNumber.tonumber "-12.34")
              test:is (p:quantize(d),decNumber.tonumber "12.35")
              test:is ((-p):quantize(d),decNumber.tonumber "-12.34")
              ctx:setround(decNumber.ROUND_UP)
              test:is (m:quantize(d),decNumber.tonumber "12.35")
              test:is ((-m):quantize(d),decNumber.tonumber "-12.35")
              test:is (n:quantize(d),decNumber.tonumber "12.35")
              test:is ((-n):quantize(d),decNumber.tonumber "-12.35")
              test:is (p:quantize(d),decNumber.tonumber "12.35")
              test:is ((-p):quantize(d),decNumber.tonumber "-12.35")
              ctx:setround(decNumber.ROUND_HALF_UP)
              test:is (m:quantize(d),decNumber.tonumber "12.34")
              test:is ((-m):quantize(d),decNumber.tonumber "-12.34")
              test:is (n:quantize(d),decNumber.tonumber "12.35")
              test:is ((-n):quantize(d),decNumber.tonumber "-12.35")
              test:is (p:quantize(d),decNumber.tonumber "12.35")
              test:is ((-p):quantize(d),decNumber.tonumber "-12.35")
              ctx:setround(decNumber.ROUND_HALF_EVEN)
              test:is (m:quantize(d),decNumber.tonumber "12.34")
              test:is ((-m):quantize(d),decNumber.tonumber "-12.34")
              test:is (n:quantize(d),decNumber.tonumber "12.34")
              test:is ((-n):quantize(d),decNumber.tonumber "-12.34")
              test:is (p:quantize(d),decNumber.tonumber "12.35")
              test:is ((-p):quantize(d),decNumber.tonumber "-12.35")
              ctx:setround(decNumber.ROUND_HALF_DOWN)
              test:is (m:quantize(d),decNumber.tonumber "12.34")
              test:is ((-m):quantize(d),decNumber.tonumber "-12.34")
              test:is (n:quantize(d),decNumber.tonumber "12.34")
              test:is ((-n):quantize(d),decNumber.tonumber "-12.34")
              test:is (p:quantize(d),decNumber.tonumber "12.35")
              test:is ((-p):quantize(d),decNumber.tonumber "-12.35")
              ctx:setround(decNumber.ROUND_DOWN)
              test:is (m:quantize(d),decNumber.tonumber "12.34")
              test:is ((-m):quantize(d),decNumber.tonumber "-12.34")
              test:is (n:quantize(d),decNumber.tonumber "12.34")
              test:is ((-n):quantize(d),decNumber.tonumber "-12.34")
              test:is (p:quantize(d),decNumber.tonumber "12.34")
              test:is ((-p):quantize(d),decNumber.tonumber "-12.34")
              ctx:setround(decNumber.ROUND_FLOOR)
              test:is (m:quantize(d),decNumber.tonumber "12.34")
              test:is ((-m):quantize(d),decNumber.tonumber "-12.35")
              test:is (n:quantize(d),decNumber.tonumber "12.34")
              test:is ((-n):quantize(d),decNumber.tonumber "-12.35")
              test:is (p:quantize(d),decNumber.tonumber "12.34")
              test:is ((-p):quantize(d),decNumber.tonumber "-12.35")
end)

test:test("Quanitize", function(test)
              test:plan(12)
              local ctx = decNumber.getcontext()
              local dupc = ctx:duplicate()
              dupc:setdefault (decNumber.INIT_BASE)
              dupc:setdigits (5)
              dupc:setround(decNumber.ROUND_CEILING)
              local dupe = dupc:duplicate()
              dupe:setround(decNumber.ROUND_HALF_UP)
              local m = decNumber.tonumber "12.343"
              local n = decNumber.tonumber "12.345"
              local p = decNumber.tonumber "12.347"
              local d = decNumber.tonumber ".01"
              local q = decNumber.tonumber "2"
              dupc:setcontext()
              test:is (m:quantize(d),decNumber.tonumber "12.35")
              test:is ((-m):quantize(d),decNumber.tonumber "-12.34")
              test:is (n:quantize(d),decNumber.tonumber "12.35")
              test:is ((-n):quantize(d),decNumber.tonumber "-12.34")
              test:is (p:quantize(d),decNumber.tonumber "12.35")
              test:is ((-p):quantize(d),decNumber.tonumber "-12.34")
              decNumber.setcontext(dupe)
              test:is (m:quantize(d),decNumber.tonumber "12.34")
              test:is ((-m):quantize(d),decNumber.tonumber "-12.34")
              test:is (n:quantize(d),decNumber.tonumber "12.35")
              test:is ((-n):quantize(d),decNumber.tonumber "-12.35")
              test:is (p:quantize(d),decNumber.tonumber "12.35")
              test:is ((-p):quantize(d),decNumber.tonumber "-12.35")
              ctx:setcontext()
end)

test:test("Random Numbers", function (test)
              test:plan(8)
              local r = decNumber.randomstate(999,777,555)
              local s = decNumber.randomstate(999,777,555)
              local t = decNumber.randomstate()
              local r1,s1,t1 = r(), s(), t()
              local r2,s2,t2 = r(), s(), t()
              test:is (r1, s1)
              test:isnt (r1,t1)
              test:is (r2, s2)
              test:isnt (r1,r2)
              test:isnt (r2,t2)
              test:ok(r(12,-12) < r(12,1))
              test:ok(t(12,-12) < decNumber.tonumber "1")
              test:ok(t(12,1) > decNumber.tonumber "1")
end)

test:test("Classifier Functions", function(test)
              test:plan(81)
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
              test:is (pi:classasstring(), "+Infinity")
              test:is (ni:classasstring(), "-Infinity")
              test:is (pn:classasstring(), "+Normal")
              test:is (nn:classasstring(), "-Normal")
              test:is (ps:classasstring(), "+Subnormal")
              test:is (ns:classasstring(), "-Subnormal")
              test:is (pz:classasstring(), "+Zero")
              test:is (nz:classasstring(), "-Zero")
              test:is (nan:classasstring(), "NaN")
              --test:is (inv:classasstring(), "Invalid") -- NaN
              test:is (pi:class(), decNumber.CLASS_POS_INF)
              test:is (ni:class(), decNumber.CLASS_NEG_INF)
              test:is (pn:class(), decNumber.CLASS_POS_NORMAL)
              test:is (nn:class(), decNumber.CLASS_NEG_NORMAL)
              test:is (ps:class(), decNumber.CLASS_POS_SUBNORMAL)
              test:is (ns:class(), decNumber.CLASS_NEG_SUBNORMAL)
              test:is (pz:class(), decNumber.CLASS_POS_ZERO)
              test:is (nz:class(), decNumber.CLASS_NEG_ZERO)
              test:is (nan:class(), decNumber.CLASS_QNAN)
              test:is (decNumber.classtostring(pi:class()), "+Infinity")
              test:is (decNumber.classtostring(ni:class()), "-Infinity")
              test:is (decNumber.classtostring(pn:class()), "+Normal")
              test:is (decNumber.classtostring(nn:class()), "-Normal")
              test:is (decNumber.classtostring(ps:class()), "+Subnormal")
              test:is (decNumber.classtostring(ns:class()), "-Subnormal")
              test:is (decNumber.classtostring(pz:class()), "+Zero")
              test:is (decNumber.classtostring(nz:class()), "-Zero")
              test:is (decNumber.classtostring(nan:class()), "NaN")
              -- predicates
              test:ok (false == pi:isnormal())
              test:ok (false == ni:isnormal())
              test:ok  (pn:isnormal())
              test:ok  (nn:isnormal())
              test:ok (false == pz:isnormal())
              test:ok (false == nz:isnormal())
              test:ok (false == ns:isnormal())
              test:ok (false == ps:isnormal())
              test:ok (false == nan:isnormal())
              test:ok (false == pi:issubnormal())
              test:ok (false == ni:issubnormal())
              test:ok (false == pn:issubnormal())
              test:ok (false == nn:issubnormal())
              test:ok (false == pz:issubnormal())
              test:ok (false == nz:issubnormal())
              test:ok  (ns:issubnormal())
              test:ok  (ps:issubnormal())
              test:ok (false == nan:issubnormal())
              test:ok (false == pi:isfinite())
              test:ok (false == ni:isfinite())
              test:ok  (pn:isfinite())
              test:ok  (nn:isfinite())
              test:ok  (pz:isfinite())
              test:ok  (nz:isfinite())
              test:ok  (ns:isfinite())
              test:ok  (ps:isfinite())
              test:ok (false == nan:isfinite())
              test:ok  (pi:isspecial())
              test:ok  (ni:isspecial())
              test:ok (false == pn:isspecial())
              test:ok (false == nn:isspecial())
              test:ok (false == pz:isspecial())
              test:ok (false == nz:isspecial())
              test:ok (false == ns:isspecial())
              test:ok (false == ps:isspecial())
              test:ok  (nan:isspecial())
              test:ok (pi:iscanonical())
              test:ok (ni:iscanonical())
              test:ok (pn:iscanonical())
              test:ok (nn:iscanonical())
              test:ok (pz:iscanonical())
              test:ok (nz:iscanonical())
              test:ok (ns:iscanonical())
              test:ok (ps:iscanonical())
              test:ok (nan:iscanonical())
              -- misc
              test:is (pi:radix(), 10)
              test:is (ni:radix(), 10)
              test:is (pn:radix(), 10)
              test:is (nn:radix(), 10)
              test:is (ps:radix(), 10)
              test:is (ns:radix(), 10)
              test:is (pz:radix(), 10)
              test:is (nz:radix(), 10)
              test:is (nan:radix(), 10)
end)


os.exit(test:check() == true and 0 or -1)
