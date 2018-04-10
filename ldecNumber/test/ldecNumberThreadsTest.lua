--[[ ldecNumberThreadsTest.lua
*  Lua wrapper for decNumber -- thread context testing
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
-- require "lunit" -- http://www.nessie.de/mroth/lunit/  -- using 0.4a pre
-- for now, visual inspection is necessary

-- the test is to be sure each thread has an independent context
-- each thread uses a different rounding mode

ctx = decNumber.getcontext()
ctx:setdefault (decNumber.INIT_DECIMAL128)
ctx:setdigits (69)

local t1 = function ()
    local n1 = decNumber.tonumber(335)
    local n2 = decNumber.tonumber(10)
    return function ()
        local ctx = decNumber.getcontext()
        ctx:setdefault (decNumber.INIT_DECIMAL32)
        ctx:setround(decNumber.ROUND_HALF_DOWN)
        while (true)
        do
            print (string.format ("t1 %s / %s = %s",
                    n1:tostring(), n2:tostring(), (n1/n2):tointegralvalue():tostring()))
            n1 = n1 + 10
            coroutine.yield()
        end
    end
end

local t2 = function ()
    local n1 = decNumber.tonumber(335)
    local n2 = decNumber.tonumber(10)
    return function ()
        local ctx = decNumber.getcontext()
        ctx:setdefault (decNumber.INIT_DECIMAL32)
        ctx:setround(decNumber.ROUND_HALF_EVEN)
        while (true)
        do
            print (string.format ("t2 %s / %s = %s",
                    n1:tostring(), n2:tostring(), (n1/n2):tointegralvalue():tostring()))
            n1 = n1 + 10
            coroutine.yield()
        end
    end
end

local c1 = coroutine.create(t1())
local c2 = coroutine.create(t2())

print (coroutine.status(c1))
print (coroutine.status(c1))

print (coroutine.resume(c1))
print (coroutine.resume(c2))


for i = 1,30
do
    if (math.random() > 0.5)
    then coroutine.resume (c1)
    else coroutine.resume (c2)
    end
end

