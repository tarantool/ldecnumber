--[[ ldecNumberTestDriver.lua
*  Lua wrapper for decNumber
*  created September 3, 2006 by e
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

--[[ Uses dectest (v 2.52 presently) to test ldecnumber.DLL ]]--

require "ldecNumber"
require "bit" --[[ http://luaforge.net/projects/bit/ ]]--

--[[
TO DO
-- octothorpe
]]--

start_time = os.clock ()

MAX_DIGITS = decNumber.MAX_DIGITS -- 69

print (string.format ("Testing %s", decNumber.version))
print (string.format ("Datetime: %s\n", os.date("%Y-%m-%d %H:%M:%S %Z")))

function tokenize_orig (s)
  local t = {}
  for w in string.gmatch(s, "[%c%s]*([%w%p]*)") do
    if w ~= ""
    then
        if string.sub (w,1,2) == "--" then break end -- comment ends line
        if string.sub (w,1,1) == "'" and string.sub (w,-1,-1) == "'"
        then
            w = string.sub (w,2,-2) -- remove quotes
        end
        if string.sub (w,1,1) == '"' and string.sub (w,-1,-1) == '"'
        then
            w = string.sub (w,2,-2) -- remove quotes
        end
        table.insert(t, w)
    end
  end
  return t
end

function tokenize (s)
  local t = {}
  local i = 1
  local z = #s
  local function getquotok (c,b)
    i = i+1 -- quote char c is at index i
    local p = string.find(s,c,i)
    if p == nil then return nil end
    i = p+1
    if string.sub(s,i,i) == c
    then return getquotok (c,b)
    else return string.sub(s,b+1,p-1)
    end
  end
  while i <= z do
    local w
    local b,e
    -- eat whitespace
    b,e = string.find(s,"^[%c%s]*",i)
    if b ~= nil then i = e+1 end
    -- check for comment
    if string.sub (s,i,i+1) == "--" then break end -- comment ends line
    -- get a token
    if string.sub (s,i,i) == "'"
    then w = getquotok("'",i)
    elseif string.sub (s,i,i) == '"'
    then w = getquotok('"',i)
    else
        b,e = string.find(s,"[%w%p]*",i)
        if b == nil then break end -- end of tokens
        w = string.sub(s,b,e)
        i = e+1
    end
    -- TO DO: octothorpe processing
    -- if w ~= "" then table.insert(t, w) end
    table.insert(t, w)
  end
  return t
end

linenum = 0
testsrun = 0
failures = 0
testspuntedo = 0
testspuntedp = 0
halffailures = 0
successes = 0
roundfailures = 0

total_testsrun = 0
total_failures = 0
total_testspuntedo = 0
total_testspuntedp = 0
total_halffailures = 0
total_successes = 0
total_roundfailures = 0

function dotestfile (fname, f)
    local ctx = decNumber.getcontext()
    ctx:setdefault(decNumber.INIT_DECIMAL128)
    ctx:setclamp(0)
    --
    linenum = 0
    testsrun = 0
    failures = 0
    testspuntedo = 0
    testspuntedp = 0
    halffailures = 0
    successes = 0
    roundfailures = 0
    print (string.format ("File: %s", fname))
    for line in io.lines(fname) 
    do
        linenum = linenum + 1
        f ( tokenize (line), linenum )
    end
    local s = ""
    local r = ""
    if halffailures ~= 0
    then
        s = string.format (" (%d of these semi-succeeded)", halffailures )
    end
    if roundfailures ~= 0
    then
        r = string.format (" %d failed(conv),", roundfailures )
    end
    print (string.format ("File: %s: %d tests, %d succeeded, %d failed%s,%s %d skipped(#), %d skipped(prec)\n",
            fname, testsrun, successes, failures, s, r, testspuntedo, testspuntedp))
    total_testsrun = total_testsrun + testsrun
    total_failures = total_failures + failures
    total_testspuntedo = total_testspuntedo + testspuntedo
    total_testspuntedp = total_testspuntedp + testspuntedp
    total_halffailures = total_halffailures + halffailures
    total_successes = total_successes + successes
    total_roundfailures = total_roundfailures + roundfailures
end

function showtoks (t, lnum)
    local id = t[1]
    if id == nil then return end -- comment line
    if string.sub(id,-1,-1) == ":"
    then
        assert (t[3] == nil, "malformed line -- extra directive args")
        print (string.format ("directive %s %s", id, t[2]))
    else
        -- id operation operand1 [operand2] –> result [conditions...]
        local op = t[2]
        local d1 = t[3]
        local d2 = t[4]
        local first_cond = 7
        if d2 == "->"
        then
            d2 = ""
            rt = t[5]
            first_cond = 6
        else
            assert (t[5] == "->", "malformed line -- misplaced ->")
            rt = t[6]
        end
        print (string.format ("test (%s): %s (%s) (%s) = (%s)", id, op, d1, d2, rt))
        for i = first_cond, #t do print (string.format ("cond %s", t[i])) end
    end
end

rounding =
{
    ceiling    = decNumber.ROUND_CEILING,
    down       = decNumber.ROUND_DOWN,
    floor      = decNumber.ROUND_FLOOR,
    half_down  = decNumber.ROUND_HALF_DOWN,
    half_even  = decNumber.ROUND_HALF_EVEN,
    half_up    = decNumber.ROUND_HALF_UP,
    up         = decNumber.ROUND_UP,
    ["05up"]   = decNumber.ROUND_05UP
}

function directive_rounding (v)
    local r = assert( rounding[string.lower(v)], "unknown directive rounding ", v)
    decNumber.getcontext():setround (r)
end

skip_tests_precision = false

function directive_precision (v)
    v = tonumber(v)
    if v > MAX_DIGITS
    then
        print (string.format(
            "--        precision of ldecNumber would be exceeded with %d; using %d",
            v, MAX_DIGITS))
        skip_tests_precision = true
    else
        decNumber.getcontext():setdigits(v)
        if skip_tests_precision
        then
            skip_tests_precision = false
        end
    end
end

skip_tests_extended0 = false

directives = 
{
    precision   = directive_precision,
    rounding    = directive_rounding,
    maxexponent = function (v) decNumber.getcontext():setemax(v) end,
    minexponent = function (v) decNumber.getcontext():setemin(v) end,
    version     = function (v) print (string.format ("Version: %s", v)) end,
    extended    = function (v) skip_tests_extended0 = (v ~= 1) end,
    clamp       = function (v) decNumber.getcontext():setclamp(v) end,
    dectest     = function (v) print (string.format ("Skipping dectest: %s", v)) end
}

function evaldirective (n, v)
    local fun = assert( directives[n], string.format ("unknown directive %s %s", n, v) )
    fun (v)
end

--apply_function = decNumber.plus
apply_function = decNumber.tonumber

operations = 
{
    abs = assert( decNumber.abs ),
    add = assert( decNumber.add ),
    ["and"] = assert( decNumber.land ),
    apply = assert( apply_function ),
    class = assert( decNumber.classasstring ),
    compare = assert( decNumber.compare ),
    comparetotal = assert( decNumber.comparetotal ),
    comparetotmag = assert( decNumber.comparetotalmag ),
    copy = assert( decNumber.copy ),
    copyabs = assert( decNumber.copyabs ),
    copynegate = assert( decNumber.copynegate ),
    copysign = assert( decNumber.copysign ),
    divide = assert( decNumber.divide ),
    divideint = assert( decNumber.divideinteger ),
    exp = assert( decNumber.exp ),
    fma = assert( decNumber.fma ),
    invert = assert( decNumber.invert ),
    ln = assert( decNumber.ln ),
    log10 = assert( decNumber.log10 ),
    logb = assert( decNumber.logb ),
    max = assert( decNumber.max ),
    maxmag = assert( decNumber.maxmag ),
    min = assert( decNumber.min ),
    minmag = assert( decNumber.minmag ),
    minus = assert( decNumber.minus ),
    multiply = assert( decNumber.multiply ),
    nextminus = assert( decNumber.nextminus ),
    nextplus = assert( decNumber.nextplus ),
    nexttoward = assert( decNumber.nexttoward ),
    ["or"] = assert( decNumber.lor ),
    plus = assert( decNumber.plus ),
    power = assert( decNumber.power ),
    quantize = assert( decNumber.quantize ),
    reduce = assert( decNumber.normalize ),
    remainder = assert( decNumber.remainder ),
    remaindernear = assert( decNumber.remaindernear ),
    rescale = assert( decNumber.rescale ),
    rotate = assert( decNumber.rotate ),
    samequantum = assert( decNumber.samequantum ),
    squareroot = assert( decNumber.squareroot ),
    scaleb = assert( decNumber.scaleb ),
    shift = assert( decNumber.shift ),
    subtract = assert( decNumber.subtract ),
    toeng = assert( decNumber.toengstring ),
    tointegral = assert( decNumber.tointegralvalue ),
    tointegralx = assert( decNumber.tointegralexact ),
    tosci = assert( decNumber.tostring ),
    trim = assert( decNumber.trim ),
    xor = assert( decNumber.xor )
}

conditions = 
{
    clamped = assert( decNumber.Clamped ),
    conversion_syntax = assert( decNumber.Conversion_syntax ),
    division_by_zero = assert( decNumber.Division_by_zero ),
    division_impossible = assert( decNumber.Division_impossible ),
    division_undefined = assert( decNumber.Division_undefined ),
    inexact = assert( decNumber.Inexact ),
    insufficient_storage = assert( decNumber.Insufficient_storage ),
    invalid_context = assert( decNumber.Invalid_context ),
    invalid_operation = assert( decNumber.Invalid_operation ),
--    lost_digits = assert( decNumber.Lost_digits ),
    overflow = assert( decNumber.Overflow ),
    rounded = assert( decNumber.Rounded ),
    subnormal = assert( decNumber.Subnormal ),
    underflow = assert( decNumber.Underflow )
}

function make_status_str (c)
    local s = ""
    local sep = ""
    if bit.band(c,decNumber.Clamped) ~= 0 then s = s..sep.."Clamped" sep = "," end
    if bit.band(c,decNumber.Conversion_syntax) ~= 0 then s = s..sep.."Conversion_syntax" sep = "," end
    if bit.band(c,decNumber.Division_by_zero) ~= 0 then s = s..sep.."Division_by_zero" sep = "," end
    if bit.band(c,decNumber.Division_impossible) ~= 0 then s = s..sep.."Division_impossible" sep = "," end
    if bit.band(c,decNumber.Division_undefined) ~= 0 then s = s..sep.."Division_undefined" sep = "," end
    if bit.band(c,decNumber.Inexact) ~= 0 then s = s..sep.."Inexact" sep = "," end
    if bit.band(c,decNumber.Insufficient_storage) ~= 0 then s = s..sep.."Insufficient_storage" sep = "," end
    if bit.band(c,decNumber.Invalid_context) ~= 0 then s = s..sep.."Invalid_context" sep = "," end
    if bit.band(c,decNumber.Invalid_operation) ~= 0 then s = s..sep.."Invalid_operation" sep = "," end
    if bit.band(c,decNumber.Overflow) ~= 0 then s = s..sep.."Overflow" sep = "," end
    if bit.band(c,decNumber.Rounded) ~= 0 then s = s..sep.."Rounded" sep = "," end
    if bit.band(c,decNumber.Subnormal) ~= 0 then s = s..sep.."Subnormal" sep = "," end
    if bit.band(c,decNumber.Underflow) ~= 0 then s = s..sep.."Underflow" sep = "," end
    return s
end

evaltest = function (id, op_, d1_, d2_, d3_, rt_, t, first_cond)
    testsrun = testsrun + 1
    if skip_tests_precision
    then
        print (string.format ("%s xp skipped: precision unavailable", id))
        testspuntedp = testspuntedp + 1
        return
    end
    --if string.sub(d1_,1,1) == "#" or string.sub(d2_,1,1) == "#" or string.sub(rt_,1,1) == "#"
    if string.find(d1_,"#") or string.find(d2_,"#") or string.find(d3_,"#") or string.find(rt_,"#")
    then
        print (string.format ("%s x# skipped: no # tests implemented", id))
        testspuntedo = testspuntedo + 1
        return
    end
    --
    local ctx = decNumber.getcontext()
    ctx:setstatus(0)
    local failed = false
    local rounded = false
    local ss = ""
    --
    local op = assert(operations[string.lower(op_)], string.format ("unknown op %s", op_))
    local d1, d2, d3
    if op ~= decNumber.tostring and op ~= decNumber.toengstring and op ~= apply_function
    then
        -- use full precision for converting operands
        local prec = ctx:getdigits()
        ctx:setdigits(MAX_DIGITS)
        d1 = decNumber.tonumber (d1_)
        if d2_ ~= "" then d2 = decNumber.tonumber (d2_) else d2 = d2_ end
        if d3_ ~= "" then d3 = decNumber.tonumber (d3_) else d3 = d3_ end
        if ctx:getstatus() ~= 0
        then
            ss = make_status_str(ctx:getstatus())
            --local convngmask = decNumber.Rounded
            --local convngmask = bit.bor(decNumber.Rounded,decNumber.Inexact)
            local convngmask = bit.bor(decNumber.Rounded,decNumber.Clamped) -- good
            if bit.band(ctx:getstatus(),convngmask) ~= 0
            then
                rounded = true
            end
        end
        ctx:setdigits(prec)
        ctx:setstatus(0)
    else
        --d1 = decNumber.tonumber (d1_)
        --if d2_ ~= "" then d2 = decNumber.tonumber (d2_) else d2 = d2_ end
        -- let ldn_get do it
        d1 = d1_
        d2 = d2_
        d3 = d3_
    end
    --
    local rg
    if d3_ ~= ""
    then
        rg = op (d1, d2, d3)
    elseif d2_ ~= ""
    then
        rg = op (d1, d2)
    else
        rg = op (d1)
    end
    if rg == nil
    then
        print (string.format ("%s nn (%s) expected %s got nil", id, ss, rt_))
        failed = true
    elseif type(rg) == "string"
    then
        if rg ~= rt_
        then
            failed = true
            print (string.format ("%s ss (%s) expected %s got s %s", id, ss, rt_, rg))
if verbose then
            if type(d1) == "string"
            then print ("s", d1)
            else print ("n", d1:__tostring())
            end
            if type(d2) == "string"
            then print ("s", d2)
            else print ("n", d2:__tostring())
            end
        end
end
    else
        local rg_ = rg:__tostring()
        if rg_ ~= rt_
        then
            failed = true
            print (string.format ("%s ns (%s) expected %s got n %s", id, ss, rt_, rg_))
if verbose then
            if type(d1) == "string"
            then print ("s", d1)
            else print ("n", d1:__tostring())
            end
            if type(d2) == "string"
            then print ("s", d2)
            else print ("n", d2:__tostring())
            end
end
            if not rg:comparetotal(rt):iszero()
            then
                -- print (string.format ("%s nn expected %s got n %s", id, rt_, rg_))
            else
                halffailures = halffailures + 1
            end
        end
    end
    local expected_conds = 0
    local expected_conds_s = ""
    for i = first_cond, #t 
    do 
        -- print (string.format ("cond %s", t[i]))
        local b = assert( conditions[string.lower(t[i])], "unknown condition ", t[i])
        expected_conds = bit.bor(expected_conds, b)
        expected_conds_s = expected_conds_s..t[i].." "
    end
    local c = ctx:getstatus()
    if c ~= expected_conds
    then
        print (string.format("%s cc (%s) conds 0x%x %s expected 0x%x %s",
            id, ss, c, make_status_str(c), expected_conds, expected_conds_s))
        failed = true
    end
    if failed
    then
        if rounded then roundfailures = roundfailures + 1 else failures = failures + 1 end
    else
        successes = successes + 1
    end
end

function evalline (t, lnum)
    local id = t[1]
    if id == nil then return end -- comment line
    if string.sub(id,-1,-1) == ":"
    then
        assert (t[3] == nil, string.format("malformed line %d -- extra directive args",lnum))
        evaldirective ( string.lower( string.sub(id,1,-2) ), t[2] )
    else
        -- id operation operand1 [operand2 [operand3]] –> result [conditions...]
        local op = t[2]
        local d1 = t[3]
        local d2 = t[4]
        local d3 = t[5]
        local first_cond = 8
        if d2 == "->"
        then
            d2 = ""
            rt = t[5]
            first_cond = 6
        elseif d3 == "->"
        then
            d3 = ""
            rt = t[6]
            first_cond = 7
        else
            if t[6] ~= "->"
            then
                print (string.format("**** malformed line %d -- misplaced ->",lnum))
                return
            end
            rt = t[7]
        end
        -- print (string.format ("test (%s): %s (%s) (%s) = (%s)", id, op, d1, d2, rt))
        -- for i = first_cond, #t do print (string.format ("cond %s", t[i])) end
        evaltest (id, op, d1, d2, d3, rt, t, first_cond)
    end
end

-- dotestfile ("dectest/rounding.decTest", showtoks)

dotestfile ("dectest/abs.decTest", evalline)
dotestfile ("dectest/add.decTest", evalline)
dotestfile ("dectest/and.decTest", evalline)
dotestfile ("dectest/base.decTest", evalline)
dotestfile ("dectest/clamp.decTest", evalline)
dotestfile ("dectest/class.decTest", evalline)
dotestfile ("dectest/compare.decTest", evalline)
dotestfile ("dectest/comparetotal.decTest", evalline)
dotestfile ("dectest/comparetotmag.decTest", evalline)
dotestfile ("dectest/copy.decTest", evalline)
dotestfile ("dectest/copyabs.decTest", evalline)
dotestfile ("dectest/copynegate.decTest", evalline)
dotestfile ("dectest/copysign.decTest", evalline)
dotestfile ("dectest/divide.decTest", evalline)
dotestfile ("dectest/divideint.decTest", evalline)
dotestfile ("dectest/exp.decTest", evalline)
dotestfile ("dectest/fma.decTest", evalline)
dotestfile ("dectest/inexact.decTest", evalline)
dotestfile ("dectest/invert.decTest", evalline)
dotestfile ("dectest/ln.decTest", evalline)
dotestfile ("dectest/log10.decTest", evalline)
dotestfile ("dectest/logb.decTest", evalline)
dotestfile ("dectest/max.decTest", evalline)
dotestfile ("dectest/maxmag.decTest", evalline)
dotestfile ("dectest/min.decTest", evalline)
dotestfile ("dectest/minmag.decTest", evalline)
dotestfile ("dectest/minus.decTest", evalline)
dotestfile ("dectest/multiply.decTest", evalline)
dotestfile ("dectest/nextminus.decTest", evalline)
dotestfile ("dectest/nextplus.decTest", evalline)
dotestfile ("dectest/nexttoward.decTest", evalline)
dotestfile ("dectest/or.decTest", evalline)
dotestfile ("dectest/plus.decTest", evalline)
dotestfile ("dectest/power.decTest", evalline)
dotestfile ("dectest/powersqrt.decTest", evalline)
dotestfile ("dectest/quantize.decTest", evalline)
dotestfile ("dectest/randombound32.decTest", evalline)
dotestfile ("dectest/randoms.decTest", evalline)
dotestfile ("dectest/reduce.decTest", evalline)
dotestfile ("dectest/remainder.decTest", evalline)
dotestfile ("dectest/remaindernear.decTest", evalline)
dotestfile ("dectest/rescale.decTest", evalline)
dotestfile ("dectest/rounding.decTest", evalline)
dotestfile ("dectest/rotate.decTest", evalline)
dotestfile ("dectest/samequantum.decTest", evalline)
dotestfile ("dectest/scaleb.decTest", evalline)
dotestfile ("dectest/shift.decTest", evalline)
dotestfile ("dectest/squareroot.decTest", evalline)
dotestfile ("dectest/subtract.decTest", evalline)
dotestfile ("dectest/tointegral.decTest", evalline)
dotestfile ("dectest/tointegralx.decTest", evalline)
dotestfile ("dectest/trim.decTest", evalline)
dotestfile ("dectest/xor.decTest", evalline)
--dotestfile ("dectest/testall.decTest", evalline)
-- no: decSingle.decTest dsEncode.decTest (no format encoders)
dotestfile ("dectest/dsBase.decTest", evalline)
-- no: decDouble.decTest ddEncode.decTest (no format encoders. no signal)
dotestfile ("dectest/ddAbs.decTest", evalline)
dotestfile ("dectest/ddAdd.decTest", evalline)
dotestfile ("dectest/ddAnd.decTest", evalline)
dotestfile ("dectest/ddBase.decTest", evalline)
dotestfile ("dectest/ddCanonical.decTest", evalline)
dotestfile ("dectest/ddClass.decTest", evalline)
dotestfile ("dectest/ddCompare.decTest", evalline)
--dotestfile ("dectest/ddCompareSig.decTest", evalline)
dotestfile ("dectest/ddCompareTotal.decTest", evalline)
dotestfile ("dectest/ddCompareTotalMag.decTest", evalline)
dotestfile ("dectest/ddCopy.decTest", evalline)
dotestfile ("dectest/ddCopyAbs.decTest", evalline)
dotestfile ("dectest/ddCopyNegate.decTest", evalline)
dotestfile ("dectest/ddCopySign.decTest", evalline)
dotestfile ("dectest/ddDivide.decTest", evalline)
dotestfile ("dectest/ddDivideInt.decTest", evalline)
--dotestfile ("dectest/ddEncode.decTest", evalline)
dotestfile ("dectest/ddFMA.decTest", evalline)
dotestfile ("dectest/ddInvert.decTest", evalline)
dotestfile ("dectest/ddLogB.decTest", evalline)
dotestfile ("dectest/ddMax.decTest", evalline)
dotestfile ("dectest/ddMaxMag.decTest", evalline)
dotestfile ("dectest/ddMin.decTest", evalline)
dotestfile ("dectest/ddMinMag.decTest", evalline)
dotestfile ("dectest/ddMinus.decTest", evalline)
dotestfile ("dectest/ddMultiply.decTest", evalline)
dotestfile ("dectest/ddNextMinus.decTest", evalline)
dotestfile ("dectest/ddNextPlus.decTest", evalline)
dotestfile ("dectest/ddNextToward.decTest", evalline)
dotestfile ("dectest/ddOr.decTest", evalline)
dotestfile ("dectest/ddPlus.decTest", evalline)
dotestfile ("dectest/ddQuantize.decTest", evalline)
dotestfile ("dectest/ddReduce.decTest", evalline)
dotestfile ("dectest/ddRemainder.decTest", evalline)
dotestfile ("dectest/ddRemainderNear.decTest", evalline)
dotestfile ("dectest/ddRotate.decTest", evalline)
dotestfile ("dectest/ddSameQuantum.decTest", evalline)
dotestfile ("dectest/ddScaleB.decTest", evalline)
dotestfile ("dectest/ddShift.decTest", evalline)
dotestfile ("dectest/ddSubtract.decTest", evalline)
dotestfile ("dectest/ddToIntegral.decTest", evalline)
dotestfile ("dectest/ddXor.decTest", evalline)
-- no: decQuad.decTest dqEncode.decTest (no format encoders. no signal)
dotestfile ("dectest/dqAbs.decTest", evalline)
dotestfile ("dectest/dqAdd.decTest", evalline)
dotestfile ("dectest/dqAnd.decTest", evalline)
dotestfile ("dectest/dqBase.decTest", evalline)
dotestfile ("dectest/dqCanonical.decTest", evalline)
dotestfile ("dectest/dqClass.decTest", evalline)
dotestfile ("dectest/dqCompare.decTest", evalline)
--dotestfile ("dectest/dqCompareSig.decTest", evalline)
dotestfile ("dectest/dqCompareTotal.decTest", evalline)
dotestfile ("dectest/dqCompareTotalMag.decTest", evalline)
dotestfile ("dectest/dqCopy.decTest", evalline)
dotestfile ("dectest/dqCopyAbs.decTest", evalline)
dotestfile ("dectest/dqCopyNegate.decTest", evalline)
dotestfile ("dectest/dqCopySign.decTest", evalline)
dotestfile ("dectest/dqDivide.decTest", evalline)
dotestfile ("dectest/dqDivideInt.decTest", evalline)
--dotestfile ("dectest/dqEncode.decTest", evalline)
dotestfile ("dectest/dqFMA.decTest", evalline)
dotestfile ("dectest/dqInvert.decTest", evalline)
dotestfile ("dectest/dqLogB.decTest", evalline)
dotestfile ("dectest/dqMax.decTest", evalline)
dotestfile ("dectest/dqMaxMag.decTest", evalline)
dotestfile ("dectest/dqMin.decTest", evalline)
dotestfile ("dectest/dqMinMag.decTest", evalline)
dotestfile ("dectest/dqMinus.decTest", evalline)
dotestfile ("dectest/dqMultiply.decTest", evalline)
dotestfile ("dectest/dqNextMinus.decTest", evalline)
dotestfile ("dectest/dqNextPlus.decTest", evalline)
dotestfile ("dectest/dqNextToward.decTest", evalline)
dotestfile ("dectest/dqOr.decTest", evalline)
dotestfile ("dectest/dqPlus.decTest", evalline)
dotestfile ("dectest/dqQuantize.decTest", evalline)
dotestfile ("dectest/dqReduce.decTest", evalline)
dotestfile ("dectest/dqRemainder.decTest", evalline)
dotestfile ("dectest/dqRemainderNear.decTest", evalline)
dotestfile ("dectest/dqRotate.decTest", evalline)
dotestfile ("dectest/dqSameQuantum.decTest", evalline)
dotestfile ("dectest/dqScaleB.decTest", evalline)
dotestfile ("dectest/dqShift.decTest", evalline)
dotestfile ("dectest/dqSubtract.decTest", evalline)
dotestfile ("dectest/dqToIntegral.decTest", evalline)
dotestfile ("dectest/dqXor.decTest", evalline)

do
    local s = ""
    local r = ""
    if total_halffailures ~= 0
    then
        s = string.format (" (%d of these semi-succeeded)", total_halffailures )
    end
    if total_roundfailures ~= 0
    then
        r = string.format (" %d failed(conv),", total_roundfailures )
    end
    print (string.format ("For all %d tests, %d succeeded, %d failed%s,%s %d skipped(#), %d skipped(prec)\n",
            total_testsrun, total_successes, total_failures, s, r, total_testspuntedo, total_testspuntedp))
end

if decNumber.cachestats ~= nil
then
    hits,misses = decNumber.cachestats()
    print (string.format ("decContext hits: %g, misses %g", hits, misses))
end

total_time = os.clock () - start_time

print (string.format ("time taken: %d seconds", total_time))
