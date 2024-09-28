--[========================================================================[--

    Lua pattern matching library (minus string.gsub) ported to Lua.

    Copyright © 1994–2018 Lua.org, PUC-Rio.
    Copyright © 2019 Pedro Gimeno Fortea.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    --]========================================================================]
--

local LUA_MAXCAPTURES = 32

local CAP_UNFINISHED = -1
local CAP_POSITION = -2


local L_ESC = 37 -- 37='%'
-- only used for string.find(x, y, z, true)
-- local SPECIALS = '^$*+?.([%-'

local function LUA_QL(x)
    return "'" .. x .. "'"
end

local function check_capture(ms, l)
    l = l - 48 -- 48='0'
    if l < 1 or l > ms.level or ms.capture[l].len == CAP_UNFINISHED then
        return error("invalid capture index")
    end
    return l
end

local function capture_to_close(ms)
    local level = ms.level
    while level > 0 do
        if ms.capture[level].len == CAP_UNFINISHED then
            return level
        end
        level = level - 1
    end
    return error("invalid pattern capture")
end

local function classend(pat, p)
    local cc = pat:byte(p)
    p = p + 1
    if cc == L_ESC then
        if (pat:byte(p) or 0) == 0 then
            return error("malformed pattern (ends with " .. LUA_QL('%') .. ")")
        end
        return p + 1
    end
    if cc == 91 then              -- 91='['
        if pat:byte(p) == 94 then -- 94='^'
            p = p + 1
        end
        repeat -- look for a `]'
            cc = pat:byte(p) or 0
            p = p + 1
            if cc == 0 then
                return error("malformed pattern (missing " .. LUA_QL(']') .. ")")
            end
            if cc == L_ESC then
                if (pat:byte(p) or 0) ~= 0 then
                    p = p + 1
                end
            end
        until pat:byte(p) == 93 -- 93=']'
        return p + 1
    end
    return p
end

local function match_class(c, cl)
    local u = cl - cl % 64 + cl % 32                      -- upper case
    local negate = cl == u                                -- true if uppercase
    local res
    if u == 65 then                                       -- 65='A'
        res = c >= 65 and c <= 90 or c >= 97 and c <= 122 -- 65='A', 90='Z', 97='a', 122='z'
    elseif u == 67 then                                   -- 67='C'
        res = c < 32 or c == 127
    elseif u == 68 then                                   -- 68='D'
        res = c >= 48 and c <= 57                         -- 48='0', 57='9'
    elseif u == 76 then                                   -- 76='L'
        res = c >= 97 and c <= 122                        -- 97='a', 122='z'
    elseif u == 80 then                                   -- 80='P'
        res = c >= 33 and c <= 47 or c >= 58 and c <= 64
            or c >= 91 and c <= 96 or c >= 123 and c <= 126
    elseif u == 83 then                                   -- 83='S'
        res = c == 9 or c >= 10 and c <= 13 or c == 32    -- 9=HT, 10=LF, 13=CR, 32=' '
    elseif u == 85 then                                   -- 85='U'
        res = c >= 65 and c <= 90
    elseif u == 87 then                                   -- 87='W'
        res = c >= 65 and c <= 90 or c >= 97 and c <= 122 -- 65='A', 90='Z', 97='a', 122='z'
            or c >= 48 and c <= 57                        -- 48='0', 57='9'
    elseif u == 88 then                                   -- 88='X'
        res = c >= 65 and c <= 70 or c >= 97 and c <= 102 -- 65='A', 70='F', 97='a', 102='f'
            or c >= 48 and c <= 57                        -- 48='0', 57='9'
    elseif u == 90 then
        res = c == 0
    else
        return c == cl
    end
    return negate ~= res
end

local function matchbracketclass(c, pat, p, ec)
    local sig = true
    p = p + 1
    if pat:byte(p) == 94 then -- 94='^'
        sig = false
        p = p + 1
    end
    while p < ec do
        local cc = pat:byte(p)
        if cc == L_ESC then
            p = p + 1
            if match_class(c, pat:byte(p)) then
                return sig
            end
        elseif pat:byte(p + 1) == 45 and p + 2 < ec then -- 45='-'
            p = p + 2
            if cc <= c and c <= pat:byte(p) then
                return sig
            end
        elseif cc == c then
            return sig
        end
        p = p + 1
    end
    return not sig
end

local function singlematch(c, pat, p, ep)
    local cc = pat:byte(p)
    if cc == 46 then -- 46='.'
        return true
    end
    if cc == L_ESC then
        return match_class(c, pat:byte(p + 1))
    end
    if cc == 91 then -- 91='['
        return matchbracketclass(c, pat, p, ep - 1)
    end
    return cc == c
end

local match

local function matchbalance(ms, str, s, pat, p)
    local b = pat:byte(p)
    local e = pat:byte(p + 1)
    if (b or 0) == 0 or (e or 0) == 0 then
        return error("unbalanced pattern")
    end
    if str:byte(s) ~= b then
        return false
    end
    local cont = 1
    s = s + 1
    while s < ms.src_end do
        local cc = str:byte(s)
        if cc == e then
            cont = cont - 1
            if cont == 0 then
                return s + 1
            end
        elseif cc == b then
            cont = cont + 1
        end
        s = s + 1
    end
    return false
end

local function max_expand(ms, str, s, pat, p, ep)
    local i = 0 -- counts maximum expand for item
    while s + i < ms.src_end and singlematch(str:byte(s + i), pat, p, ep) do
        i = i + 1
    end
    while i >= 0 do
        local res = match(ms, str, s + i, pat, ep + 1)
        if res then return res end
        i = i - 1 -- else it didn't match; reduce 1 repetition to try again
    end
    return false
end

local function min_expand(ms, str, s, pat, p, ep)
    repeat
        local res = match(ms, str, s, pat, ep + 1)
        if res then
            return res
        end
        if s >= ms.src_end or not singlematch(str:byte(s), pat, p, ep) then
            return false
        end
        s = s + 1
    until false
end

local function start_capture(ms, str, s, pat, p, what)
    local level = ms.level + 1
    if level > LUA_MAXCAPTURES then
        return error("too many captures")
    end
    if not ms.capture[level] then
        ms.capture[level] = {}
    end
    ms.capture[level].init = s
    ms.capture[level].len = what
    ms.level = level
    local res = match(ms, str, s, pat, p)
    if not res then
        ms.level = ms.level - 1
    end
    return res
end

local function end_capture(ms, str, s, pat, p)
    local l = capture_to_close(ms)
    ms.capture[l].len = s - ms.capture[l].init
    local res = match(ms, str, s, pat, p)
    if not res then
        ms.capture[l].len = CAP_UNFINISHED
    end
    return res
end

local function substrcomp(str, start1, start2, len)
    for i = start1, start1 + len - 1 do
        if str:byte(i) ~= str:byte(i + (start2 - start1)) then
            return false
        end
    end
    return true
end

local function match_capture(ms, str, s, l)
    l = check_capture(ms, l)
    local len = ms.capture[l].len
    if ms.src_end - s >= len and substrcomp(str, ms.capture[l].init, s, len) then
        return s + len
    end
    return false
end

-- this is local already, don't add 'local' or it will fail
match = function(ms, str, s, pat, p)
    local cc = pat:byte(p) or 0
    if cc == 40 then                  -- 40='('
        -- start capture
        if pat:byte(p + 1) == 41 then -- 41=')'
            -- position capture
            return start_capture(ms, str, s, pat, p + 2, CAP_POSITION)
        end
        return start_capture(ms, str, s, pat, p + 1, CAP_UNFINISHED)
    end
    if cc == 41 then -- 41=')'
        -- end capture
        return end_capture(ms, str, s, pat, p + 1)
    end
    if cc == L_ESC then
        cc = pat:byte(p + 1)
        if cc == 98 then -- 98='b'
            -- balanced string
            s = matchbalance(ms, str, s, pat, p + 2)
            if not s then
                return false
            end
            return match(ms, str, s, pat, p + 4)
        end
        if cc == 102 then -- 102='f'
            -- frontier
            p = p + 2
            if pat:byte(p) ~= 91 then -- 91='['
                return error("missing " .. LUA_QL('[') .. " after "
                    .. LUA_QL('%f') .. " in pattern")
            end
            local ep = classend(pat, p)
            local previous = str:byte(s - 1) or 0
            if matchbracketclass(previous, pat, p, ep - 1)
                or not matchbracketclass(str:byte(s) or 0, pat, p, ep - 1)
            then
                return false
            end
            return match(ms, str, s, pat, ep)
        end
        if cc >= 48 and cc <= 57 then -- 48='0', 57='9'
            -- capture results (%0-%9)?
            s = match_capture(ms, str, s, cc)
            if not s then
                return false
            end
            return match(ms, str, s, pat, p + 2)
        end
        cc = -1     -- don't match anything else until default
    end
    if cc == 0 then -- end of pattern
        return s
    end
    if cc == 36 then                        -- 36='$'
        if (pat:byte(p + 1) or 0) == 0 then -- is the `$' the last char in pattern?
            return s == ms.src_end and s    -- check end of string
        end
        -- else fall through to default
    end

    -- default
    local ep = classend(pat, p)
    local m = s < ms.src_end and singlematch(str:byte(s), pat, p, ep)
    cc = pat:byte(ep) or 0
    if cc == 63 then
        if m then
            local res = match(ms, str, s + 1, pat, ep + 1)
            if res then
                return res
            end
        end
        return match(ms, str, s, pat, ep + 1)
    end
    if cc == 42 then -- 42='*'
        -- 0 or more repetitions
        return max_expand(ms, str, s, pat, p, ep)
    end
    if cc == 43 then -- 43='+'
        -- 1 or more repetitions
        return m and max_expand(ms, str, s + 1, pat, p, ep)
    end
    if cc == 45 then -- 45='-'
        -- 0 or more repetitions (minimum)
        return min_expand(ms, str, s, pat, p, ep)
    end
    return m and match(ms, str, s + 1, pat, ep)
end

-- lmemfind not implemented - only used for string.find(x, y, z, true)

local function push_onecapture(ms, i, str, s, e)
    if i > ms.level then
        if i ~= 1 then
            return error("invalid capture index")
        end
        ms.captures[#ms.captures + 1] = str:sub(s, e - 1)
    else
        local l = ms.capture[i].len
        if l == CAP_UNFINISHED then
            return error("unfinished capture")
        end
        if l == CAP_POSITION then
            ms.captures[#ms.captures + 1] = ms.capture[i].init
        else
            ms.captures[#ms.captures + 1] = str:sub(ms.capture[i].init, ms.capture[i].init + l - 1)
        end
    end
end

local function push_captures(ms, str, s, e)
    local nlevels = ms.level
    if nlevels == 0 and s then
        nlevels = 1
    end
    for i = 1, nlevels do
        push_onecapture(ms, i, str, s, e)
    end
end

local function posrelat(pos, len)
    if pos < 0 then pos = pos + len + 1 end
    return pos >= 1 and pos or 1
end

local string_find = string.find

local SPECIALS = {
    [("^"):byte(1)] = true,
    [("$"):byte(1)] = true,
    [("*"):byte(1)] = true,
    [("+"):byte(1)] = true,
    [("?"):byte(1)] = true,
    [("."):byte(1)] = true,
    [("("):byte(1)] = true,
    [("["):byte(1)] = true,
    [("%"):byte(1)] = true,
    [("-"):byte(1)] = true,
    [0] = true
}

local function specials_free(s)
    for i = 1, #s do
        if SPECIALS[s:byte(i)] then
            if s:byte(i) == 0 then
                return true -- stop at first NUL
            end
            return false
        end
    end
    return true
end

local function str_find_aux(find, str, pat, init, explicit)
    local l1 = #str
    init = posrelat(init or 1, l1)
    if init < 1 then
        init = 1
    elseif init > l1 + 1 then
        init = l1 + 1
    end
    if find and (explicit or specials_free(pat)) then -- explicit request?
        -- do a plain search
        return string_find(str, pat, init, true)
    end
    local p = 1
    local anchor = false
    if pat:byte(1) == 94 then -- 94='^'
        p = p + 1
        anchor = true
    end
    local s1 = init
    local ms = { captures = {}, capture = {}, src_end = l1 + 1 }
    repeat
        ms.level = 0
        local res = match(ms, str, s1, pat, p)
        if res then
            if find then
                push_captures(ms, str, false, 0)
                return s1, res - 1, unpack(ms.captures)
            end
            push_captures(ms, str, s1, res)
            return unpack(ms.captures)
        end
        s1 = s1 + 1
    until anchor or s1 > ms.src_end
    return nil
end

local function str_find(str, pat, init, explicit)
    return str_find_aux(true, str, pat, init, explicit)
end

local function str_match(str, pat, init)
    return str_find_aux(false, str, pat, init)
end

local function gmatch(str, pat)
    local init = 1
    local ms = { captures = {}, capture = {}, src_init = str, src_end = #str + 1 }
    local function gmatch_aux()
        for i = 1, #ms.captures do ms.captures[i] = nil end
        for src = init, ms.src_end do
            ms.level = 0
            local e = match(ms, str, src, pat, 1)
            if e then
                local newstart = e
                if e == src then newstart = newstart + 1 end -- empty match? go at least one position
                init = newstart
                push_captures(ms, str, src, e)
                return unpack(ms.captures)
            end
        end
    end
    return gmatch_aux
end


return { find = str_find, match = str_match, gmatch = gmatch }
