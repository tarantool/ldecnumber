-- translated example1.c
-- convert the first two argument words to decNumber,
-- add them together, and display the result

-- run with: lua example1.lua <num1> <num2>

require "ldecNumber"

local DECNUMDIGITS = 34

local ctx = decNumber.getcontext()
ctx:setdefault(decNumber.INIT_BASE)
ctx:settraps(0) -- no traps (this is the default, and only option!)
ctx:setdigits(DECNUMDIGITS)

local r = decNumber.tonumber(arg[1]) + arg[2]
print (string.format ("%s + %s => %s", arg[1], arg[2], r:tostring()))
