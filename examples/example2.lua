-- translated example2.c
-- calculate compound interest
-- Arguments are investment, rate (%), and years

-- run with: lua example2.lua <investment> <rate> <years>

require "ldecNumber"

local ctx = decNumber.getcontext()
ctx:setdefault(decNumber.INIT_BASE)
ctx:settraps(0) -- no traps (this is the default, and only option!)
ctx:setdigits(25)

if not (arg[1] and arg[2] and arg[3])
then
  print "Please supply 3 arguments!"
else

--  local one     = decNumber.tonumber("1")
--  local mtwo    = decNumber.tonumber("-2")
--  local hundred = decNumber.tonumber("100")
  
  local start = decNumber.tonumber(arg[1])
  local rate  = decNumber.tonumber(arg[2])
  local years = decNumber.tonumber(arg[3])

  rate=rate/100
  rate=rate+1
  rate=rate^years
  
  local total=rate*start
  total=total:rescale(-2) -- two digits please

  print (string.format ("%s at %s%% for %s years => %s\n",
                        arg[1], arg[2], arg[3], total:tostring()))

end