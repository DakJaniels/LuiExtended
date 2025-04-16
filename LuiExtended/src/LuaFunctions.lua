-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- -----------------------------------------------------------------------------
local select = select
local gmt = getmetatable
local error = error
local type = type
local table = table
local table_concat = table.concat
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local string = string
local string_find = string.find
local string_format = string.format
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep

-- type checking functions
local checkinteger -- forward declararation
local function argcheck(cond, i, f, extra)
    if not cond then
        error("bad argument #" .. i .. " to '" .. f .. "' (" .. extra .. ")", 0)
    end
end

do
    local maxint = 1
    local minint

    while maxint + 1 > maxint and 2 * maxint > maxint do
        maxint = maxint * 2
    end
    if 2 * maxint <= maxint then
        maxint = 2 * maxint - 1
        minint = -maxint - 1
    else
        maxint = maxint
        minint = -maxint
    end
    function checkinteger(x, i, f)
        local t = type(x)
        if t ~= "number" then
            error("bad argument #" .. i .. " to '" .. f ..
                "' (number expected, got " .. t .. ")", 0)
        elseif x > maxint or x < minint or x % 1 ~= 0 then
            error("bad argument #" .. i .. " to '" .. f ..
                "' (number has no integer representation)", 0)
        else
            return x
        end
    end

    --- @param list table
    --- @param sep? string
    --- @param i?   integer
    --- @param j?   integer
    --- @return string
    --- @nodiscard
    local function luie_table_concat(list, sep, i, j)
        local mt = gmt(list)
        if type(mt) == "table" and type(mt.__len) == "function" then
            local src = list
            list, i, j = {}, i or 1, j or mt.__len(src)
            for k = i, j do
                list[k] = src[k]
            end
        end
        return table_concat(list, sep, i, j)
    end
    --- @overload fun(list: table, value: any)
    --- @param list table
    --- @param ... any
    local function luie_table_insert(list, ...)
        local mt = gmt(list)
        local has_mt = type(mt) == "table"
        local has_len = has_mt and type(mt.__len) == "function"
        if has_mt and (has_len or mt.__index or mt.__newindex) then
            local e = (has_len and mt.__len(list) or #list) + 1
            local nargs, pos, value = select("#", ...), ...
            if nargs == 1 then
                pos, value = e, pos
            elseif nargs == 2 then
                pos = checkinteger(pos, "2", "table.insert")
                argcheck(1 <= pos and pos <= e, "2", "table.insert",
                    "position out of bounds")
            else
                error("wrong number of arguments to 'insert'", 0)
            end
            for i = e - 1, pos, -1 do
                list[i + 1] = list[i]
            end
            list[pos] = value
        else
            return table_insert(list, ...)
        end
    end
    --- @param a1  table
    --- @param f   integer
    --- @param e   integer
    --- @param t   integer
    --- @param a2? table
    --- @return table a2
    local function luie_table_move(a1, f, e, t, a2)
        a2 = a2 or a1
        f = checkinteger(f, "2", "table.move")
        argcheck(f > 0, "2", "table.move",
            "initial position must be positive")
        e = checkinteger(e, "3", "table.move")
        t = checkinteger(t, "4", "table.move")
        if e >= f then
            local m, n, d = 0, e - f, 1
            if t > f then m, n, d = n, m, -1 end
            for i = m, n, d do
                a2[t + i] = a1[f + i]
            end
        end
        return a2
    end
    --- @param list table
    --- @param pos? integer
    --- @return any
    local function luie_table_remove(list, pos)
        local mt = gmt(list)
        local has_mt = type(mt) == "table"
        local has_len = has_mt and type(mt.__len) == "function"
        if has_mt and (has_len or mt.__index or mt.__newindex) then
            local e = (has_len and mt.__len(list) or #list)
            pos = pos ~= nil and checkinteger(pos, "2", "table.remove") or e
            if pos ~= e then
                argcheck(1 <= pos and pos <= e + 1, "2", "table.remove",
                    "position out of bounds")
            end
            local result = list[pos]
            while pos < e do
                list[pos] = list[pos + 1]
                pos = pos + 1
            end
            list[pos] = nil
            return result
        else
            return table_remove(list, pos)
        end
    end

    local function pivot(list, cmp, a, b)
        local m = b - a
        if m > 2 then
            local c = a + (m - m % 2) / 2
            local x, y, z = list[a], list[b], list[c]
            if not cmp(x, y) then
                x, y, a, b = y, x, b, a
            end
            if not cmp(y, z) then
                y, b = z, c
            end
            if not cmp(x, y) then
                y, b = x, a
            end
            return b, y
        else
            return b, list[b]
        end
    end

    local function lt_cmp(a, b)
        return a < b
    end

    local function qsort(list, cmp, b, e)
        if b < e then
            local i, j, k, val = b, e, pivot(list, cmp, b, e)
            while i < j do
                while i < j and cmp(list[i], val) do
                    i = i + 1
                end
                while i < j and not cmp(list[j], val) do
                    j = j - 1
                end
                if i < j then
                    list[i], list[j] = list[j], list[i]
                    if i == k then k = j end -- update pivot position
                    i, j = i + 1, j - 1
                end
            end
            if i ~= k and not cmp(list[i], val) then
                list[i], list[k] = val, list[i]
                k = i -- update pivot position
            end
            qsort(list, cmp, b, i == k and i - 1 or i)
            return qsort(list, cmp, i + 1, e)
        end
    end
    --- @generic T
    --- @param list T[]
    --- @param cmp? fun(a: T, b: T):boolean
    local function luie_table_sort(list, cmp)
        local mt = gmt(list)
        local has_mt = type(mt) == "table"
        local has_len = has_mt and type(mt.__len) == "function"
        if has_len then
            cmp = cmp or lt_cmp
            local len = mt.__len(list)
            return qsort(list, cmp, 1, len)
        else
            return table_sort(list, cmp)
        end
    end


    local function unpack_helper(list, i, j, ...)
        if j < i then
            return ...
        else
            return unpack_helper(list, i, j - 1, list[j], ...)
        end
    end
    --- @generic T1, T2, T3, T4, T5, T6, T7, T8, T9, T10
    --- @param list {
    --- [1]?: T1,
    --- [2]?: T2,
    --- [3]?: T3,
    --- [4]?: T4,
    --- [5]?: T5,
    --- [6]?: T6,
    --- [7]?: T7,
    --- [8]?: T8,
    --- [9]?: T9,
    --- [10]?: T10,
    --- }
    --- @param i?   integer
    --- @param j?   integer
    --- @return T1, T2, T3, T4, T5, T6, T7, T8, T9, T10
    --- @nodiscard
    local function luie_table_unpack(list, i, j)
        local mt = gmt(list)
        local has_mt = type(mt) == "table"
        local has_len = has_mt and type(mt.__len) == "function"
        if has_mt and (has_len or mt.__index) then
            i, j = i or 1, j or (has_len and mt.__len(list)) or #list
            return unpack_helper(list, i, j)
        else
            return unpack(list, i, j)
        end
    end
    LUIE.table =
    {
        concat = luie_table_concat,
        insert = luie_table_insert,
        move = luie_table_move,
        remove = luie_table_remove,
        sort = luie_table_sort,
        unpack = luie_table_unpack,
    }
end

do
    local function fix_pattern(pattern)
        return (string_gsub(pattern, "%z", "%%z"))
    end
    --- @param s       string|number
    --- @param pattern string|number
    --- @param ...   integer
    --- @return integer|nil start
    --- @return integer|nil end
    --- @return any|nil ... captured
    --- @nodiscard
    local function luie_string_find(s, pattern, ...)
        return string_find(s, fix_pattern(pattern), ...)
    end
    --- @param s       string|number
    --- @param pattern string|number
    --- @return fun():string, ...
    --- @nodiscard
    local function luie_string_gmatch(s, pattern)
        return string_gmatch(s, fix_pattern(pattern))
    end
    --- @param s       string|number
    --- @param pattern string|number
    --- @param ...    string|number|table|function
    --- @return string
    --- @return integer count
    local function luie_string_gsub(s, pattern, ...)
        return string_gsub(s, fix_pattern(pattern), ...)
    end
    --- @param s       string|number
    --- @param pattern string|number
    --- @param ...   integer|nil
    --- @return any ...
    --- @nodiscard
    local function luie_string_match(s, pattern, ...)
        return string_match(s, fix_pattern(pattern), ...)
    end
    --- @param s    string|number
    --- @param n    integer
    --- @param sep string
    --- @return string
    --- @nodiscard
    local function luie_string_rep(s, n, sep)
        if sep ~= nil and sep ~= "" and n >= 2 then
            return s .. string_rep(sep .. s, n - 1)
        else
            return string_rep(s, n)
        end
    end

    local addqt =
    {
        ["\n"] = "\\\n",
        ["\\"] = "\\\\",
        ["\""] = "\\\""
    }

    local function addquoted(c, d)
        return (addqt[c] or string_format(d ~= "" and "\\%03d" or "\\%d", c:byte())) .. d
    end

    --- @param fmt string|number
    --- @param ... any
    --- @return string
    --- @nodiscard
    local function luie_string_format(fmt, ...)
        local args, n = { ... }, select("#", ...)
        local i = 0
        local function adjust_fmt(lead, mods, kind)
            if #lead % 2 == 0 then
                i = i + 1
                if kind == "s" then
                    args[i] = _G.tostring(args[i])
                elseif kind == "q" then
                    args[i] = '"' .. string_gsub(args[i], "([%z%c\\\"\n])(%d?)", addquoted) .. '"'
                    return lead .. "%" .. mods .. "s"
                end
            end
        end
        fmt = string_gsub(fmt, "(%%*)%%([%d%.%-%+%# ]*)(%a)", adjust_fmt)
        local formattedString = string_format(fmt, unpack(args, 1, n))
        return formattedString
    end

    local g_strArgs = {}
    --- @param formatString string|number
    --- @param ... any
    --- @return string
    --- @nodiscard
    local function luie_strformat(formatString, ...)
        assert(formatString ~= nil, "no format string passed to zo_strformat")
        ZO_ClearNumericallyIndexedTable(g_strArgs)

        for i = 1, select("#", ...) do
            local currentArg = select(i, ...)
            local currentArgType = type(currentArg)
            if currentArgType == "number" then
                local str = ""
                local numFmt = "d"
                local num, frac = zo_decimalsplit(currentArg)

                local width = 0
                local digits = 1
                local unsigned = false
                if ESO_NumberFormats[formatString] ~= nil and ESO_NumberFormats[formatString][i] ~= nil then
                    width = ESO_NumberFormats[formatString][i].width or width
                    digits = ESO_NumberFormats[formatString][i].digits or digits
                    unsigned = ESO_NumberFormats[formatString][i].unsigned or unsigned
                end

                if width > 0 then
                    str = luie_string_format("0%d", width)
                end

                if frac ~= 0 then
                    numFmt = "f"
                    str = str .. luie_string_format(".%d", digits)
                elseif unsigned == true then
                    numFmt = "u"
                end

                str = luie_string_format("%%%s%s", str, numFmt)

                g_strArgs[i] = luie_string_format(str, currentArg)
            elseif currentArgType == "string" then
                g_strArgs[i] = currentArg
            else
                assert(false, luie_string_format("Argument %d with invalid type passed to zo_strformat: %s", i, currentArgType))
                g_strArgs[i] = ""
            end
        end

        if type(formatString) == "number" then
            formatString = GetString(formatString)
        end

        return LocalizeString(formatString, unpack(g_strArgs))
    end

    LUIE.string =
    {
        find = luie_string_find,
        gmatch = luie_string_gmatch,
        gsub = luie_string_gsub,
        match = luie_string_match,
        rep = luie_string_rep,
        format = luie_string_format,
        localestrformat = luie_strformat
    }
end
