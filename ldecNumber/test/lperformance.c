/* lperformance.c
*  Lua wrapper for performance counters
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
************************************************************************/

#include "lua.h"
#include "lauxlib.h"

#include <windows.h>

#define PF_NAME "performance"
#define PF_META " performance_MeTA"

const char *pf_meta = PF_META;

typedef struct perftimer
{
    LARGE_INTEGER start;
    LARGE_INTEGER lap;
} perftimer;

static double freq;

typedef unsigned long long ULL;

static perftimer *lpf_check_perf (lua_State *L, int index)
{
    perftimer *pt = (perftimer *)luaL_checkudata (L, index, pf_meta);
    if (pt == NULL) luaL_argerror (L, index, "lperformance bad perftimer");
    return pt; /* leaves perftimer on Lua stack */
}

static int pf_new (lua_State *L)
{
    perftimer *pt = (perftimer *)lua_newuserdata(L, sizeof(perftimer));
    luaL_getmetatable (L, pf_meta);
    lua_setmetatable (L, -2); /* set metatable */
    QueryPerformanceCounter (&pt->start);
    pt->lap = pt->start;
    return 1;  /* leaves perftimer on Lua stack */
}

static int pf_lap (lua_State *L)
{
    perftimer *pf = lpf_check_perf (L, 1);
    lua_Number diff;
    LARGE_INTEGER now;
    QueryPerformanceCounter (&now);
    diff = (lua_Number )((ULL )now.QuadPart - (ULL )pf->lap.QuadPart);
    lua_pushnumber (L, diff/freq);
    pf->lap = now;
    return 1;
}

static int pf_reset (lua_State *L)
{
    perftimer *pf = lpf_check_perf (L, 1);
    QueryPerformanceCounter (&pf->start);
    pf->lap = pf->start;
    return 0;
}

static int pf_total (lua_State *L)
{
    perftimer *pf = lpf_check_perf (L, 1);
    lua_Number diff;
    diff = (lua_Number )((ULL )pf->lap.QuadPart - (ULL )pf->start.QuadPart);
    lua_pushnumber (L, diff/freq);
    return 1;
}

static int pf_freq (lua_State *L)
{
    lua_pushnumber (L, freq);
    return 1;
}

static const luaL_reg pf_meta_lib[] =
{
    {"lap",         pf_lap    },
    {"reset",       pf_reset  },
    {"total",       pf_total  },
/*
    { "__unm",      pf_neg    },
    { "__add",      pf_add    },
    { "__sub",      pf_sub    },
    { "__mul",      pf_mul    },
    { "__div",      pf_div    },
    { "__pow",      pf_pow    },
    { "__eq",       pf_eq     },
    { "__lt",       pf_lt     },
    { "__tostring", pf_string },
*/
    { NULL,         NULL      }
};

static const luaL_reg pf_lib[] =
{
    {"new",         pf_new    },
    {"freq",        pf_freq   },
    { NULL,         NULL      }
};

LUALIB_API int luaopen_lperformance(lua_State *L)
{
    LARGE_INTEGER fli;
    if (QueryPerformanceFrequency(&fli) == 0)
    {
        // service not available
        luaL_error(L, "QueryPerformanceFrequency: not available");
    }
    freq = (lua_Number )fli.QuadPart;
    if (((ULL )freq) != fli.QuadPart)
    {
        luaL_error(L, "QueryPerformanceFrequency: insufficient lua_Number range");
    }
    // create global table and register functions
    luaL_register (L, PF_NAME, pf_lib);
    // create metatable
    lua_pushliteral ( L, "metatable");   /** context metatable */
    luaL_newmetatable (L, pf_meta);
    /* register context metatable functions */
    luaL_register(L, NULL, pf_meta_lib);
    lua_pushstring (L, "__index");
    lua_pushvalue (L, -2); /* push metatable */
    lua_rawset (L, -3);    /* metatable.__index = metatable */
    lua_settable(L,-3);
    return 1;
}
