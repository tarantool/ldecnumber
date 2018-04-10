-- translated example3.c
-- calculate compound interest, passive checking
-- Arguments are investment, rate (%), and years

-- run with: lua example2.lua <investment> <rate> <years>

require "ldecNumber"
require "bit" --[[ http://luaforge.net/projects/bit/ ]]--

local Errors = bit.bor(
decNumber.Division_by_zero,
decNumber.Conversion_syntax,
decNumber.Division_impossible,
decNumber.Division_undefined,
decNumber.Insufficient_storage,
decNumber.Invalid_context,
decNumber.Invalid_operation,
decNumber.Underflow,
decNumber.Overflow
)

local ctx = decNumber.getcontext()
ctx:setdefault(decNumber.INIT_BASE)
ctx:settraps(0) -- no traps (this is the default, and only option!)
ctx:setdigits(25)

if not (arg[1] and arg[2] and arg[3])
then
  print "Please supply 3 arguments!"
else

-- this would be a good idea if these values were going to be used 
-- more than once, e.g., in a loop...
--  local one     = decNumber.tonumber("1")
--  local mtwo    = decNumber.tonumber("-2")
--  local hundred = decNumber.tonumber("100")
  
  local start = decNumber.tonumber(arg[1])
  local rate  = decNumber.tonumber(arg[2])
  local years = decNumber.tonumber(arg[3])

  if bit.band(ctx:getstatus(),Errors) ~= 0
  then
    print (string.format ("An input argument word was invalid [%s]\n",
                            ctx:getstatusstring()))
    return
  end

  local total=((rate/100+1)^years)*start
  total=total:rescale(-2) -- two digits please

  if bit.band(ctx:getstatus(),Errors) ~= 0
  then
    -- keep only errors...
    ctx:setstatus(bit.band(ctx:getstatus(),Errors))
    print (string.format ("Result could not be calculated [%s]\n",
                            ctx:getstatusstring()))
    return
  end

  print (string.format ("%s at %s%% for %s years => %s\n",
                        arg[1], arg[2], arg[3], total:tostring()))

end