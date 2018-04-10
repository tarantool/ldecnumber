
require "ldecNumber"

require "ldislin"

local sigma = arg[1] or 12
local trials = arg[2] or 100000

local use_qbars = false

local floor = math.floor

print (decNumber.version)

print (dislin.version)

local function D (s) return decNumber.tonumber (s) end

local D1 = D"1"
local D2 = D"2"
local Dm2 = D"-2"

local r = decNumber.randomstate()

local function gaussian (sigma)
  local x1 = r(12) * D2 - D1
  local x2 = r(12) * D2 - D1
  local r2 = x1 * x1 + x2 * x2
  if r2:iszero() or r2 > D1
  then return gaussian (sigma) -- loop
  else
    local m = (Dm2 * r2:ln() / r2):squareroot() * sigma
    return x1 * m, x2 * m
  end
end

local t = {}

if use_qbars then

for i = 1,trials do
    local x1, x2 = gaussian(sigma)
    local function tally (x) 
        local n = tonumber(x:floor(D1):tostring()) + (sigma*5)
        t[n] = (t[n] or 0) + 1
    end
    tally (x1)
    tally (x2)
end

for i = 1,#t do
    t[i] = (t[i] or 0)
    print (t[i])
end

dislin.metafl ('cons')
dislin.disini ()
dislin.labdig (0,'bars')
dislin.labpos ('inside','bars')
dislin.qplbar (t,#t)

else

for i = 1,trials do
    local x1, x2 = gaussian(sigma)
    local function tally (x) 
        local n = tonumber(x:floor(D1):tostring())
        table.insert (t,n)
    end
    tally (x1)
    tally (x2)
end

local x,y,n = dislin.histog (t, #t)

dislin.metafl ('cons')
dislin.disini ()
--dislin.polcrv ('STEP')
dislin.polcrv ('BARS')
dislin.qplot (x,y,n)

end
