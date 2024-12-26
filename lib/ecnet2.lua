
---------------------------------------------------------
----------------Auto generated code block----------------
---------------------------------------------------------

do
    local searchers = package.searchers or package.loaders
    local origin_seacher = searchers[2]
    searchers[2] = function(path)
        local files =
        {
------------------------
-- Modules part begin --
------------------------

["ecnet2.class"] = function()
--------------------
-- Module: 'ecnet2.class'
--------------------
--[[
Copyright 2018-2023 SquidDev

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software without
   specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

--- A tiny "class" implementation.
--
-- This does not support inheritance, operators, or anything complex - it's
-- just a way of enabling method calls.

local expect = require "cc.expect".expect

local function tostring_instance(self) return self.__name .. "<>" end
local function tostring_class(self) return "Class<" .. self.__name .. ">" end

local class_mt = {
  __tostring = tostring_class,
  __name = "class",
  __call = function(self, ...)
    local tbl = setmetatable({}, self.__index)
    tbl:initialise(...)
    return tbl
  end,
}

return function(name)
  expect(1, name, "string")

  local class = setmetatable({
    __name = name,
    __tostring = tostring_instance,
  }, class_mt)

  class.__index = class
  return class
end

end,

["ccryptolib.internal.util"] = function()
--------------------
-- Module: 'ccryptolib.internal.util'
--------------------
local function lassert(val, err, level)
    if not val then error(err, level + 1) end
    return val
end

--- Converts a little-endian array from one power-of-two base to another.
--- @param a number[] The array to convert, in little-endian.
--- @param base1 number The base to convert from. Must be a power of 2.
--- @param base2 number The base to convert to. Must be a power of 2.
--- @return number[]
local function rebaseLE(a, base1, base2) -- TODO Write contract properly.
    local out = {}
    local outlen = 1
    local acc = 0
    local mul = 1
    for i = 1, #a do
        acc = acc + a[i] * mul
        mul = mul * base1
        while mul >= base2 do
            local rem = acc % base2
            acc = (acc - rem) / base2
            mul = mul / base2
            out[outlen] = rem
            outlen = outlen + 1
        end
    end
    if mul > 0 then
        out[outlen] = acc
    end
    return out
end

--- Decodes bits with X25519/Ed25519 exponent clamping.
--- @param str string The 32-byte encoded exponent.
--- @return number[] bits The decoded clamped bits.
local function bits(str)
    -- Decode.
    local bytes = {str:byte(1, 32)}
    local out = {}
    for i = 1, 32 do
        local byte = bytes[i]
        for j = -7, 0 do
            local bit = byte % 2
            out[8 * i + j] = bit
            byte = (byte - bit) / 2
        end
    end

    -- Clamp.
    out[1] = 0
    out[2] = 0
    out[3] = 0
    out[255] = 1
    out[256] = 0

    return out
end

--- Decodes bits with X25519/Ed25519 exponent clamping and division by 8.
--- @param str string The 32-byte encoded exponent.
--- @return number[] bits The decoded clamped bits, divided by 8.
local function bits8(str)
    return {unpack(bits(str), 4)}
end

return {
    lassert = lassert,
    rebaseLE = rebaseLE,
    bits = bits,
    bits8 = bits8,
}

end,

["ccryptolib.internal.packing"] = function()
--------------------
-- Module: 'ccryptolib.internal.packing'
--------------------
--- High-performance binary packing of integers.
---
--- Remark (and warning):
--- For performance reasons, **the generated functions do not check types,
--- lengths, nor ranges**. You must ensure that the passed arguments are
--- well-formed and respect the format string yourself.

local fmt = string.format

local function mkPack(words, BE)
    local out = "local C=string.char return function(_,"
    local nb = 0
    for i = 1, #words do
        out = out .. fmt("n%d,", i)
        nb = nb + words[i]
    end
    out = out:sub(1, -2) .. ")local "
    for i = 1, nb do
        out = out .. fmt("b%d,", i)
    end
    out = out:sub(1, -2) .. " "
    local bi = 1
    for i = 1, #words do
        for _ = 1, words[i] - 1 do
            out = out .. fmt("b%d=n%d%%2^8 n%d=(n%d-b%d)*2^-8 ", bi, i, i, i, bi)
            bi = bi + 1
        end
        bi = bi + 1
    end
    out = out .. "return C("
    bi = 1
    if not BE then
        for i = 1, #words do
            for _ = 1, words[i] - 1 do
                out = out .. fmt("b%d,", bi)
                bi = bi + 1
            end
            out = out .. fmt("n%d%%2^8,", i)
            bi = bi + 1
        end
    else
        for i = 1, #words do
            out = out .. fmt("n%d%%2^8,", i)
            bi = bi + words[i] - 2
            for _ = 1, words[i] - 1 do
                out = out .. fmt("b%d,", bi)
                bi = bi - 1
            end
            bi = bi + words[i] + 1
        end
    end
    out = out:sub(1, -2) .. ")end"
    return load(out)()
end

local function mkUnpack(words, BE)
    local out = "local B=string.byte return function(_,s,i)local "
    local bi = 1
    if not BE then
        for i = 1, #words do
            for _ = 1, words[i] do
                out = out .. fmt("b%d,", bi)
                bi = bi + 1
            end
        end
    else
        for i = 1, #words do
            bi = bi + words[i] - 1
            for _ = 1, words[i] do
                out = out .. fmt("b%d,", bi)
                bi = bi - 1
            end
            bi = bi + words[i] + 1
        end
    end
    out = out:sub(1, -2) .. fmt("=B(s,i,i+%d)return ", bi - 2)
    bi = 1
    for i = 1, #words do
        out = out .. fmt("b%d", bi)
        bi = bi + 1
        for j = 2, words[i] do
            out = out .. fmt("+b%d*2^%d", bi, 8 * j - 8)
            bi = bi + 1
        end
        out = out .. ","
    end
    out = out .. fmt("i+%d end", bi - 1)
    return load(out)()
end

-- Check whether string.pack is implemented in a high-speed language.
if not string.pack or pcall(string.dump, string.pack) then
    local function compile(fmt, fn)
        local e = assert(fmt:match("^([><])I[I%d]+$"), "invalid format string")
        local w = {}
        for i in fmt:gmatch("I([%d]+)") do
            local n = tonumber(i) or 4
            assert(n > 0 and n <= 16, "integral size out of limits")
            w[#w + 1] = n
        end
        return fn(w, e == ">")
    end

    local packCache = {}
    local unpackCache = {}

    -- I CAN'T EVEN WITH THIS EXTENSION, WHY CAN'T IT HANDLE MORE THAN A SINGLE
    -- LINE OF RETURN DESCRIPTION? LOOK AT IT!!! THE COMMENT GOES OVER THERE ------------------------------------------------------------------> look! ↓ ↓ ↓

    --- (string.pack is nil) Compiles a binary packing function.
    ---
    --- Errors if the format string is invalid or has an invalid integral size,
    --- or if the compiled function turns out too large.
    ---
    --- @param fmt string A string matched by `^([><])I[I%d]+$`.
    --- @return fun(_ignored: any, ...: any): string pack A function that behaves like an unsafe version of `string.pack` for the given format string.
    --- @return string fmt
    local function compilePack(fmt)
        if not packCache[fmt] then
            packCache[fmt] = compile(fmt, mkPack)
        end
        return packCache[fmt], fmt
    end

    --- (string.pack is nil) Compiles a binary unpacking function.
    ---
    --- Errors if the format string is invalid or has an invalid integral size,
    --- or if the compiled function turns out too large.
    ---
    --- @param fmt string A string matched by `^([><])I[I%d]+$`.
    --- @return fun(_ignored: any, str: string, pos: number) unpack A function that behaves like an unsafe version of `string.unpack` for the given format string. Note that the third argument isn't optional.
    --- @return string fmt
    local function compileUnpack(fmt)
        if not unpackCache[fmt] then
            unpackCache[fmt] = compile(fmt, mkUnpack)
        end
        return unpackCache[fmt], fmt
    end

    return {
        compilePack = compilePack,
        compileUnpack = compileUnpack,
    }
else
    --- (string.pack isn't nil) It's string.pack! It returns string.pack!
    --- @param fmt string
    --- @return fun(fmt: string, ...: any): string pack string.pack!
    --- @return string fmt
    local function compilePack(fmt) return string.pack, fmt end

    --- (string.pack isn't nil) It's string.unpack! It returns string.unpack!
    --- @param fmt string
    --- @return fun(fmt: string, str: string, pos: number) unpack string.unpack!
    --- @return string fmt
    local function compileUnpack(fmt) return string.unpack, fmt end

    return {
        compilePack = compilePack,
        compileUnpack = compileUnpack,
    }
end

end,

["ccryptolib.chacha20"] = function()
--------------------
-- Module: 'ccryptolib.chacha20'
--------------------
--- The ChaCha20 stream cipher.

local expect  = require "cc.expect".expect
local lassert = require "ccryptolib.internal.util".lassert
local packing = require "ccryptolib.internal.packing"

local bxor = bit32.bxor
local rol = bit32.lrotate
local u8x4, fmt8x4 = packing.compileUnpack("<I4I4I4I4I4I4I4I4")
local u3x4, fmt3x4 = packing.compileUnpack("<I4I4I4")
local p16x4, fmt16x4 = packing.compilePack("<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4")
local u16x4 = packing.compileUnpack(fmt16x4)

--- Encrypts/Decrypts data using ChaCha20.
--- @param key string A 32-byte random key.
--- @param nonce string A 12-byte per-message unique nonce.
--- @param message string A plaintext or ciphertext.
--- @param rounds number? The number of ChaCha20 rounds to use. Defaults to 20.
--- @param offset number? The block offset to generate the keystream at. Defaults to 1.
--- @return string out The resulting ciphertext or plaintext.
local function crypt(key, nonce, message, rounds, offset)
    expect(1, key, "string")
    lassert(#key == 32, "key length must be 32", 2)
    expect(2, nonce, "string")
    lassert(#nonce == 12, "nonce length must be 12", 2)
    expect(3, message, "string")
    rounds = expect(4, rounds, "number", "nil") or 20
    lassert(rounds % 2 == 0, "round number must be even", 2)
    lassert(rounds >= 8, "round number must be no smaller than 8", 2)
    lassert(rounds <= 20, "round number must be no larger than 20", 2)
    offset = expect(5, offset, "number", "nil") or 1
    lassert(offset % 1 == 0, "offset must be an integer", 2)
    lassert(offset >= 0, "offset must be nonnegative", 2)
    lassert(#message + 64 * offset <= 2 ^ 38, "offset too large", 2)

    -- Build the state block.
    local i0, i1, i2, i3 = 0x61707865, 0x3320646e, 0x79622d32, 0x6b206574
    local k0, k1, k2, k3, k4, k5, k6, k7 = u8x4(fmt8x4, key, 1)
    local cr, n0, n1, n2 = offset, u3x4(fmt3x4, nonce, 1)

    -- Pad the message.
    local padded = message .. ("\0"):rep(-#message % 64)

    -- Expand and combine.
    local out = {}
    local idx = 1
    for i = 1, #padded / 64 do
        -- Copy the block.
        local s00, s01, s02, s03 = i0, i1, i2, i3
        local s04, s05, s06, s07 = k0, k1, k2, k3
        local s08, s09, s10, s11 = k4, k5, k6, k7
        local s12, s13, s14, s15 = cr, n0, n1, n2

        -- Iterate.
        for _ = 1, rounds, 2 do
            s00 = s00 + s04 s12 = rol(bxor(s12, s00), 16)
            s08 = s08 + s12 s04 = rol(bxor(s04, s08), 12)
            s00 = s00 + s04 s12 = rol(bxor(s12, s00), 8)
            s08 = s08 + s12 s04 = rol(bxor(s04, s08), 7)

            s01 = s01 + s05 s13 = rol(bxor(s13, s01), 16)
            s09 = s09 + s13 s05 = rol(bxor(s05, s09), 12)
            s01 = s01 + s05 s13 = rol(bxor(s13, s01), 8)
            s09 = s09 + s13 s05 = rol(bxor(s05, s09), 7)

            s02 = s02 + s06 s14 = rol(bxor(s14, s02), 16)
            s10 = s10 + s14 s06 = rol(bxor(s06, s10), 12)
            s02 = s02 + s06 s14 = rol(bxor(s14, s02), 8)
            s10 = s10 + s14 s06 = rol(bxor(s06, s10), 7)

            s03 = s03 + s07 s15 = rol(bxor(s15, s03), 16)
            s11 = s11 + s15 s07 = rol(bxor(s07, s11), 12)
            s03 = s03 + s07 s15 = rol(bxor(s15, s03), 8)
            s11 = s11 + s15 s07 = rol(bxor(s07, s11), 7)

            s00 = s00 + s05 s15 = rol(bxor(s15, s00), 16)
            s10 = s10 + s15 s05 = rol(bxor(s05, s10), 12)
            s00 = s00 + s05 s15 = rol(bxor(s15, s00), 8)
            s10 = s10 + s15 s05 = rol(bxor(s05, s10), 7)

            s01 = s01 + s06 s12 = rol(bxor(s12, s01), 16)
            s11 = s11 + s12 s06 = rol(bxor(s06, s11), 12)
            s01 = s01 + s06 s12 = rol(bxor(s12, s01), 8)
            s11 = s11 + s12 s06 = rol(bxor(s06, s11), 7)

            s02 = s02 + s07 s13 = rol(bxor(s13, s02), 16)
            s08 = s08 + s13 s07 = rol(bxor(s07, s08), 12)
            s02 = s02 + s07 s13 = rol(bxor(s13, s02), 8)
            s08 = s08 + s13 s07 = rol(bxor(s07, s08), 7)

            s03 = s03 + s04 s14 = rol(bxor(s14, s03), 16)
            s09 = s09 + s14 s04 = rol(bxor(s04, s09), 12)
            s03 = s03 + s04 s14 = rol(bxor(s14, s03), 8)
            s09 = s09 + s14 s04 = rol(bxor(s04, s09), 7)
        end

        -- Decode message block.
        local m00, m01, m02, m03, m04, m05, m06, m07
        local m08, m09, m10, m11, m12, m13, m14, m15

        m00, m01, m02, m03, m04, m05, m06, m07,
        m08, m09, m10, m11, m12, m13, m14, m15, idx =
            u16x4(fmt16x4, padded, idx)

        -- Feed-forward and combine.
        out[i] = p16x4(fmt16x4,
            bxor(m00, s00 + i0), bxor(m01, s01 + i1),
            bxor(m02, s02 + i2), bxor(m03, s03 + i3),
            bxor(m04, s04 + k0), bxor(m05, s05 + k1),
            bxor(m06, s06 + k2), bxor(m07, s07 + k3),
            bxor(m08, s08 + k4), bxor(m09, s09 + k5),
            bxor(m10, s10 + k6), bxor(m11, s11 + k7),
            bxor(m12, s12 + cr), bxor(m13, s13 + n0),
            bxor(m14, s14 + n1), bxor(m15, s15 + n2)
        )

        -- Increment counter.
        cr = cr + 1
    end

    return table.concat(out):sub(1, #message)
end

return {
    crypt = crypt,
}

end,

["ccryptolib.poly1305"] = function()
--------------------
-- Module: 'ccryptolib.poly1305'
--------------------
--- The Poly1305 one-time authenticator.

local expect  = require "cc.expect".expect
local lassert = require "ccryptolib.internal.util".lassert
local packing = require "ccryptolib.internal.packing"

local u4x4, fmt4x4 = packing.compileUnpack("<I4I4I4I4")
local p4x4 = packing.compilePack(fmt4x4)

--- Computes a Poly1305 message authentication code.
--- @param key string A 32-byte single-use random key.
--- @param message string The message to authenticate.
--- @return string tag The 16-byte authentication tag.
local function mac(key, message)
    expect(1, key, "string")
    lassert(#key == 32, "key length must be 32", 2)
    expect(2, message, "string")

    -- Pad message.
    local pbplen = #message - 15
    if #message % 16 ~= 0 or #message == 0 then
        message = message .. "\1"
        message = message .. ("\0"):rep(-#message % 16)
    end

    -- Decode r.
    local R0, R1, R2, R3 = u4x4(fmt4x4, key, 1)

    -- Clamp and shift.
    R0 = R0 % 2 ^ 28
    R1 = (R1 - R1 % 4) % 2 ^ 28 * 2 ^ 32
    R2 = (R2 - R2 % 4) % 2 ^ 28 * 2 ^ 64
    R3 = (R3 - R3 % 4) % 2 ^ 28 * 2 ^ 96

    -- Split.
    local r0 = R0 % 2 ^ 18   local r1 = R0 - r0
    local r2 = R1 % 2 ^ 50   local r3 = R1 - r2
    local r4 = R2 % 2 ^ 82   local r5 = R2 - r4
    local r6 = R3 % 2 ^ 112  local r7 = R3 - r6

    -- Generate scaled key.
    local S1 = 5 / 2 ^ 130 * R1
    local S2 = 5 / 2 ^ 130 * R2
    local S3 = 5 / 2 ^ 130 * R3

    -- Split.
    local s2 = S1 % 2 ^ -80  local s3 = S1 - s2
    local s4 = S2 % 2 ^ -48  local s5 = S2 - s4
    local s6 = S3 % 2 ^ -16  local s7 = S3 - s6

    local h0, h1, h2, h3, h4, h5, h6, h7 = 0, 0, 0, 0, 0, 0, 0, 0

    for i = 1, #message, 16 do
        -- Decode message block.
        local m0, m1, m2, m3 = u4x4(fmt4x4, message, i)

        -- Shift message and add.
        local x0 = h0 + h1 + m0
        local x2 = h2 + h3 + m1 * 2 ^ 32
        local x4 = h4 + h5 + m2 * 2 ^ 64
        local x6 = h6 + h7 + m3 * 2 ^ 96

        -- Apply per-block padding when applicable.
        if i <= pbplen then x6 = x6 + 2 ^ 128 end

        -- Multiply
        h0 = x0 * r0 + x2 * s6 + x4 * s4 + x6 * s2
        h1 = x0 * r1 + x2 * s7 + x4 * s5 + x6 * s3
        h2 = x0 * r2 + x2 * r0 + x4 * s6 + x6 * s4
        h3 = x0 * r3 + x2 * r1 + x4 * s7 + x6 * s5
        h4 = x0 * r4 + x2 * r2 + x4 * r0 + x6 * s6
        h5 = x0 * r5 + x2 * r3 + x4 * r1 + x6 * s7
        h6 = x0 * r6 + x2 * r4 + x4 * r2 + x6 * r0
        h7 = x0 * r7 + x2 * r5 + x4 * r3 + x6 * r1

        -- Carry.
        local y0 = h0 + 3 * 2 ^ 69  - 3 * 2 ^ 69   h0 = h0 - y0  h1 = h1 + y0
        local y1 = h1 + 3 * 2 ^ 83  - 3 * 2 ^ 83   h1 = h1 - y1  h2 = h2 + y1
        local y2 = h2 + 3 * 2 ^ 101 - 3 * 2 ^ 101  h2 = h2 - y2  h3 = h3 + y2
        local y3 = h3 + 3 * 2 ^ 115 - 3 * 2 ^ 115  h3 = h3 - y3  h4 = h4 + y3
        local y4 = h4 + 3 * 2 ^ 133 - 3 * 2 ^ 133  h4 = h4 - y4  h5 = h5 + y4
        local y5 = h5 + 3 * 2 ^ 147 - 3 * 2 ^ 147  h5 = h5 - y5  h6 = h6 + y5
        local y6 = h6 + 3 * 2 ^ 163 - 3 * 2 ^ 163  h6 = h6 - y6  h7 = h7 + y6
        local y7 = h7 + 3 * 2 ^ 181 - 3 * 2 ^ 181  h7 = h7 - y7

        -- Reduce carry overflow into first limb.
        h0 = h0 + 5 / 2 ^ 130 * y7
    end

    -- Carry canonically.
    local c0 = h0 % 2 ^ 16   h1 = h0 - c0 + h1
    local c1 = h1 % 2 ^ 32   h2 = h1 - c1 + h2
    local c2 = h2 % 2 ^ 48   h3 = h2 - c2 + h3
    local c3 = h3 % 2 ^ 64   h4 = h3 - c3 + h4
    local c4 = h4 % 2 ^ 80   h5 = h4 - c4 + h5
    local c5 = h5 % 2 ^ 96   h6 = h5 - c5 + h6
    local c6 = h6 % 2 ^ 112  h7 = h6 - c6 + h7
    local c7 = h7 % 2 ^ 130

    -- Reduce carry overflow.
    h0 = c0 + 5 / 2 ^ 130 * (h7 - c7)
    c0 = h0 % 2 ^ 16
    c1 = h0 - c0 + c1

    -- Canonicalize.
    if      c7 == 0x3ffff * 2 ^ 112
        and c6 == 0xffff * 2 ^ 96
        and c5 == 0xffff * 2 ^ 80
        and c4 == 0xffff * 2 ^ 64
        and c3 == 0xffff * 2 ^ 48
        and c2 == 0xffff * 2 ^ 32
        and c1 == 0xffff * 2 ^ 16
        and c0 >= 0xfffb
    then
        c7, c6, c5, c4, c3, c2, c1, c0 = 0, 0, 0, 0, 0, 0, 0, c0 - 0xfffb
    end

    -- Decode s.
    local s0, s1, s2, s3 = u4x4(fmt4x4, key, 17)

    -- Add.
    local t0 =           s0          + c0 + c1  local u0 = t0 % 2 ^ 32
    local t1 = t0 - u0 + s1 * 2 ^ 32 + c2 + c3  local u1 = t1 % 2 ^ 64
    local t2 = t1 - u1 + s2 * 2 ^ 64 + c4 + c5  local u2 = t2 % 2 ^ 96
    local t3 = t2 - u2 + s3 * 2 ^ 96 + c6 + c7  local u3 = t3 % 2 ^ 128

    -- Encode.
    return p4x4(fmt4x4, u0, u1 / 2 ^ 32, u2 / 2 ^ 64, u3 / 2 ^ 96)
end

return {
    mac = mac,
}

end,

["ccryptolib.aead"] = function()
--------------------
-- Module: 'ccryptolib.aead'
--------------------
--- The ChaCha20Poly1305AEAD authenticated encryption with associated data (AEAD) construction.

local expect   = require "cc.expect".expect
local lassert = require "ccryptolib.internal.util".lassert
local packing  = require "ccryptolib.internal.packing"
local chacha20 = require "ccryptolib.chacha20"
local poly1305 = require "ccryptolib.poly1305"

local p8x1, fmt8x1 = packing.compilePack("<I8")
local u4x4, fmt4x4 = packing.compileUnpack("<I4I4I4I4")
local bxor = bit32.bxor

--- Encrypts a message.
--- @param key string A 32-byte random key.
--- @param nonce string A 12-byte per-message unique nonce.
--- @param message string The message to be encrypted.
--- @param aad string aad Arbitrary associated data to also authenticate.
--- @param rounds number? The number of ChaCha20 rounds to use. Defaults to 20.
--- @return string ctx The ciphertext.
--- @return string tag The 16-byte authentication tag.
local function encrypt(key, nonce, message, aad, rounds)
    expect(1, key, "string")
    lassert(#key == 32, "key length must be 32", 2)
    expect(2, nonce, "string")
    lassert(#nonce == 12, "nonce length must be 12", 2)
    expect(3, message, "string")
    expect(4, aad, "string")
    rounds = expect(5, rounds, "number", "nil") or 20
    lassert(rounds % 2 == 0, "round number must be even", 2)
    lassert(rounds >= 8, "round number must be no smaller than 8", 2)
    lassert(rounds <= 20, "round number must be no larger than 20", 2)

    -- Generate auth key and encrypt.
    local msgLong = ("\0"):rep(64) .. message
    local ctxLong = chacha20.crypt(key, nonce, msgLong, rounds, 0)
    local authKey = ctxLong:sub(1, 32)
    local ciphertext = ctxLong:sub(65)

    -- Authenticate.
    local pad1 = ("\0"):rep(-#aad % 16)
    local pad2 = ("\0"):rep(-#ciphertext % 16)
    local aadLen = p8x1("<I8", #aad)
    local ctxLen = p8x1("<I8", #ciphertext)
    local combined = aad .. pad1 .. ciphertext .. pad2 .. aadLen .. ctxLen
    local tag = poly1305.mac(authKey, combined)

    return ciphertext, tag
end

--- Decrypts a message.
--- @param key string The key used on encryption.
--- @param nonce string The nonce used on encryption.
--- @param tag string The authentication tag returned on encryption.
--- @param ciphertext string The ciphertext to be decrypted.
--- @param aad string The arbitrary associated data used on encryption.
--- @param rounds number The number of rounds used on encryption.
--- @return string? msg The decrypted plaintext. Or nil on auth failure.
local function decrypt(key, nonce, tag, ciphertext, aad, rounds)
    expect(1, key, "string")
    lassert(#key == 32, "key length must be 32", 2)
    expect(2, nonce, "string")
    lassert(#nonce == 12, "nonce length must be 12", 2)
    expect(3, tag, "string")
    lassert(#tag == 16, "tag length must be 16", 2)
    expect(4, ciphertext, "string")
    expect(5, aad, "string")
    rounds = expect(6, rounds, "number", "nil") or 20
    lassert(rounds % 2 == 0, "round number must be even", 2)
    lassert(rounds >= 8, "round number must be no smaller than 8", 2)
    lassert(rounds <= 20, "round number must be no larger than 20", 2)

    -- Generate auth key.
    local authKey = chacha20.crypt(key, nonce, ("\0"):rep(32), rounds, 0)

    -- Check tag.
    local pad1 = ("\0"):rep(-#aad % 16)
    local pad2 = ("\0"):rep(-#ciphertext % 16)
    local aadLen = p8x1(fmt8x1, #aad)
    local ctxLen = p8x1(fmt8x1, #ciphertext)
    local combined = aad .. pad1 .. ciphertext .. pad2 .. aadLen .. ctxLen
    local t1, t2, t3, t4 = u4x4(fmt4x4, tag, 1)
    local u1, u2, u3, u4 = u4x4(fmt4x4, poly1305.mac(authKey, combined), 1)
    local eq = bxor(t1, u1) + bxor(t2, u2) + bxor(t3, u3) + bxor(t4, u4)
    if eq ~= 0 then return nil end

    -- Decrypt
    return chacha20.crypt(key, nonce, ciphertext, rounds)
end

return {
    encrypt = encrypt,
    decrypt = decrypt,
}

end,

["ecnet2.CipherState"] = function()
--------------------
-- Module: 'ecnet2.CipherState'
--------------------
local class = require "ecnet2.class"
local aead = require "ccryptolib.aead"
local chacha = require "ccryptolib.chacha20"

--- A symmetric encryption cipher state, containing a key and a numeric nonce.
--- @class ecnet2.CipherState
--- @field private k string? The current key.
--- @field private n number The current nonce.
local CipherState = class "ecnet2.CipherState"

--- @param key string? A 32-byte key to initialize the state with.
function CipherState:initialise(key)
    self.k = key
    self.n = 0
end

--- Whether the state has a key or not.
--- @return boolean
function CipherState:hasKey()
    return self.k ~= nil
end

--- Sets the nonce to the given value.
--- @param nonce number
function CipherState:setNonce(nonce)
    self.n = nonce
end

--- Rekeys the cipher.
function CipherState:rekey()
    self.k = chacha.crypt(self.k, ("<I12"):pack(2 ^ 64 - 1), ("\0"):rep(32), 8)
end

--- Computes the cipher descriptor.
--- @return string
function CipherState:descriptor()
    local c = chacha.crypt(self.k, ("<I12"):pack(2 ^ 64 - 1), ("\0"):rep(64), 8)
    return c:sub(33)
end

--- Encrypts a message. Returns the plaintext itself when no key is set.
--- @param ad string Associated data to authenticate.
--- @param plaintext string The plaintext to encrypt
--- @return string ciphertext The encrypted text.
function CipherState:encryptWithAd(ad, plaintext)
    if self:hasKey() then
        local nonce = ("<I12"):pack(self.n)
        local ctx, tag = aead.encrypt(self.k, nonce, plaintext, ad, 8)
        self.n = self.n + 1
        return ctx .. tag
    else
        return plaintext
    end
end

--- Decrypts a message.
--- @param ad string Associated data to authenticate.
--- @param ciphertext string The ciphertext to decrypt.
--- @return string? plaintext The decrypted plaintext, or nil on failure.
function CipherState:decryptWithAd(ad, ciphertext)
    if self:hasKey() then
        if #ciphertext < 16 then return end
        local ctx, tag = ciphertext:sub(1, -17), ciphertext:sub(-16)
        local nonce = ("<I12"):pack(self.n)
        -- On decryption failure, increment nonce and return nil.
        local plaintext = aead.decrypt(self.k, nonce, tag, ctx, ad, 8)
        self.n = self.n + 1
        return plaintext
    else
        return ciphertext
    end
end

return CipherState

end,

["ecnet2.constants"] = function()
--------------------
-- Module: 'ecnet2.constants'
--------------------
return {
    CHANNEL = 33635,
    IDENTITY_PATH = "/.ecnet2",
}

end,

["ecnet2.ecnetd"] = function()
--------------------
-- Module: 'ecnet2.ecnetd'
--------------------
local constants = require "ecnet2.constants"

--- The global daemon state.

local handlers = setmetatable({}, { __mode = "v" })

--- @param message string
local function enqueue(message, side, ch, dist)
    if type(message) ~= "string" then return end
    if #message >= 2 ^ 16 then return end
    if #message < 32 then return end
    local descriptor = message:sub(1, 32)
    local etc = message:sub(33)
    local handler = handlers[descriptor]
    if handler then return handler(etc, side) end
end

local function daemon()
    while true do
        local _, side, ch, _, msg, dist = coroutine.yield("modem_message")
        if ch == constants.CHANNEL then enqueue(msg, side, ch, dist) end
    end
end

local function addHandler(name, fun)
    handlers[name] = fun
end

local function removeHandler(name)
    handlers[name] = nil
end

--- @class ecnet2.EcnetdState
--- @field daemon fun()
--- @field addHandler fun(name: string, fun: function)
--- @field removeHandler fun(name: string)
return {
    daemon = daemon,
    addHandler = addHandler,
    removeHandler = removeHandler,
}

end,

["ecnet2.addressEncoder"] = function()
--------------------
-- Module: 'ecnet2.addressEncoder'
--------------------
local expect = require "cc.expect"

local band = bit32.band

local alphabet = {}
local ralphabet = {}
do
    local s = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
    for i, ch in (s):gmatch("()(.)") do
        alphabet[i - 1] = ch
        ralphabet[ch] = i - 1
    end
end

--- Encodes a public key to an address.
--- @param publicKey string The 32-byte public key.
--- @return string address The encoded address.
local function encode(publicKey)
    expect(1, publicKey, "string")
    assert(#publicKey == 32, "invalid public key")
    publicKey = publicKey .. "\0"
    local out = ""
    for block in (publicKey):gmatch("...") do
        local val = (">I3"):unpack(block)
        local mul = 2 ^ -18
        for _ = 0, 18, 6 do
            out = out .. alphabet[band(val * mul, 63)]
            mul = mul * 64
        end
    end
    return out:sub(1, 43) .. "="
end

--- Decodes an address to a public key.
--- @param address string The address to decode.
--- @return string? publicKey The decoded public key, or nil on failure.
local function parse(address)
    if type(address) ~= "string" then return end
    if #address ~= 44 then return end
    if not address:match("^[A-Za-z0-9%-_]*=$") then return end
    address = address:sub(1, 43) .. "A"
    local bytes = ""
    for block in address:gmatch("....") do
        local val = 0
        for i = 1, 4 do val = val * 64 + ralphabet[block:sub(i, i)] end
        bytes = bytes .. (">I3"):pack(val)
    end
    return bytes:sub(1, 32)
end

return {
    encode = encode,
    parse = parse,
}

end,

["ecnet2.modems"] = function()
--------------------
-- Module: 'ecnet2.modems'
--------------------
local expect = require "cc.expect"
local constants = require "ecnet2.constants"

--- Opens a modem with the given peripheral name for exchanging messages.
--- @param modem string
local function open(modem)
    expect.expect(1, modem, "string")
    assert(peripheral.getType(modem) == "modem", "no such modem: " .. modem)
    peripheral.call(modem, "open", constants.CHANNEL)
end

--- Closes a modem with the given peripheral name, or all modems if not given.
--- @param modem string?
local function close(modem)
    expect.expect(1, modem, "string", "nil")
    if modem then
        assert(peripheral.getType(modem) == "modem", "no such modem: " .. modem)
        return peripheral.call(modem, "close", constants.CHANNEL)
    else
        peripheral.find("modem", close)
    end
end

--- Returns whether a modem is currently open, or any modem if not given.
--- @param modem string?
--- @return boolean
local function isOpen(modem)
    expect.expect(1, modem, "string", "nil")
    if modem then
        if peripheral.getType(modem) ~= "modem" then return false end
        return peripheral.call(modem, "isOpen", constants.CHANNEL)
    else
        return not not peripheral.find("modem", isOpen)
    end
end

--- Transmits a packet on all open modems.
--- @param side string
--- @param packet string
--- @return boolean
local function transmit(side, packet)
    return pcall(
        peripheral.call,
        side,
        "transmit",
        constants.CHANNEL,
        constants.CHANNEL,
        packet
    )
end

return {
    open = open,
    close = close,
    isOpen = isOpen,
    transmit = transmit,
}

end,

["ccryptolib.blake3"] = function()
--------------------
-- Module: 'ccryptolib.blake3'
--------------------
--- The BLAKE3 cryptographic hash function.

local expect = require "cc.expect".expect
local lassert = require "ccryptolib.internal.util".lassert
local packing = require "ccryptolib.internal.packing"

local unpack = unpack or table.unpack
local bxor = bit32.bxor
local rol = bit32.lrotate
local p16x4, fmt16x4 = packing.compilePack("<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4")
local u16x4 = packing.compileUnpack(fmt16x4)
local u8x4, fmt8x4 = packing.compileUnpack("<I4I4I4I4I4I4I4I4")

local CHUNK_START = 0x01
local CHUNK_END = 0x02
local PARENT = 0x04
local ROOT = 0x08
local KEYED_HASH = 0x10
local DERIVE_KEY_CONTEXT = 0x20
local DERIVE_KEY_MATERIAL = 0x40

local IV = {
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
}

local function compress(h, msg, t, v14, v15, full)
    local h00, h01, h02, h03, h04, h05, h06, h07 = unpack(h)
    local v00, v01, v02, v03 = h00, h01, h02, h03
    local v04, v05, v06, v07 = h04, h05, h06, h07
    local v08, v09, v10, v11 = 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a
    local v12 = t % 2 ^ 32
    local v13 = (t - v12) * 2 ^ -32

    local m00, m01, m02, m03, m04, m05, m06, m07,
          m08, m09, m10, m11, m12, m13, m14, m15 = unpack(msg)

    local tmp
    for i = 1, 7 do
        v00 = v00 + v04 + m00 v12 = rol(bxor(v12, v00), 16)
        v08 = v08 + v12       v04 = rol(bxor(v04, v08), 20)
        v00 = v00 + v04 + m01 v12 = rol(bxor(v12, v00), 24)
        v08 = v08 + v12       v04 = rol(bxor(v04, v08), 25)

        v01 = v01 + v05 + m02 v13 = rol(bxor(v13, v01), 16)
        v09 = v09 + v13       v05 = rol(bxor(v05, v09), 20)
        v01 = v01 + v05 + m03 v13 = rol(bxor(v13, v01), 24)
        v09 = v09 + v13       v05 = rol(bxor(v05, v09), 25)

        v02 = v02 + v06 + m04 v14 = rol(bxor(v14, v02), 16)
        v10 = v10 + v14       v06 = rol(bxor(v06, v10), 20)
        v02 = v02 + v06 + m05 v14 = rol(bxor(v14, v02), 24)
        v10 = v10 + v14       v06 = rol(bxor(v06, v10), 25)

        v03 = v03 + v07 + m06 v15 = rol(bxor(v15, v03), 16)
        v11 = v11 + v15       v07 = rol(bxor(v07, v11), 20)
        v03 = v03 + v07 + m07 v15 = rol(bxor(v15, v03), 24)
        v11 = v11 + v15       v07 = rol(bxor(v07, v11), 25)

        v00 = v00 + v05 + m08 v15 = rol(bxor(v15, v00), 16)
        v10 = v10 + v15       v05 = rol(bxor(v05, v10), 20)
        v00 = v00 + v05 + m09 v15 = rol(bxor(v15, v00), 24)
        v10 = v10 + v15       v05 = rol(bxor(v05, v10), 25)

        v01 = v01 + v06 + m10 v12 = rol(bxor(v12, v01), 16)
        v11 = v11 + v12       v06 = rol(bxor(v06, v11), 20)
        v01 = v01 + v06 + m11 v12 = rol(bxor(v12, v01), 24)
        v11 = v11 + v12       v06 = rol(bxor(v06, v11), 25)

        v02 = v02 + v07 + m12 v13 = rol(bxor(v13, v02), 16)
        v08 = v08 + v13       v07 = rol(bxor(v07, v08), 20)
        v02 = v02 + v07 + m13 v13 = rol(bxor(v13, v02), 24)
        v08 = v08 + v13       v07 = rol(bxor(v07, v08), 25)

        v03 = v03 + v04 + m14 v14 = rol(bxor(v14, v03), 16)
        v09 = v09 + v14       v04 = rol(bxor(v04, v09), 20)
        v03 = v03 + v04 + m15 v14 = rol(bxor(v14, v03), 24)
        v09 = v09 + v14       v04 = rol(bxor(v04, v09), 25)

        if i ~= 7 then
            tmp = m02
            m02 = m03
            m03 = m10
            m10 = m12
            m12 = m09
            m09 = m11
            m11 = m05
            m05 = m00
            m00 = tmp

            tmp = m06
            m06 = m04
            m04 = m07
            m07 = m13
            m13 = m14
            m14 = m15
            m15 = m08
            m08 = m01
            m01 = tmp
        end
    end

    if full then
        return {
            bxor(v00, v08), bxor(v01, v09), bxor(v02, v10), bxor(v03, v11),
            bxor(v04, v12), bxor(v05, v13), bxor(v06, v14), bxor(v07, v15),
            bxor(v08, h00), bxor(v09, h01), bxor(v10, h02), bxor(v11, h03),
            bxor(v12, h04), bxor(v13, h05), bxor(v14, h06), bxor(v15, h07),
        }
    else
        return {
            bxor(v00, v08), bxor(v01, v09), bxor(v02, v10), bxor(v03, v11),
            bxor(v04, v12), bxor(v05, v13), bxor(v06, v14), bxor(v07, v15),
        }
    end
end

local function merge(cvl, cvr)
    for i = 1, 8 do cvl[i + 8] = cvr[i] end
    return cvl
end

local function blake3(iv, flags, msg, len)
    -- Set up the state.
    local stateCvs = {}
    local stateCv = iv
    local stateT = 0
    local stateN = 0
    local stateStart = CHUNK_START
    local stateEnd = 0

    -- Digest complete blocks.
    for i = 1, #msg - 64, 64 do
        -- Compress the block.
        local block = {u16x4(fmt16x4, msg, i)}
        local stateFlags = flags + stateStart + stateEnd
        stateCv = compress(stateCv, block, stateT, 64, stateFlags)
        stateStart = 0
        stateN = stateN + 1

        if stateN == 15 then
            -- Last block in chunk.
            stateEnd = CHUNK_END
        elseif stateN == 16 then
            -- Chunk complete, merge.
            local mergeCv = stateCv
            local mergeAmt = stateT + 1
            while mergeAmt % 2 == 0 do
                local block = merge(table.remove(stateCvs), mergeCv)
                mergeCv = compress(iv, block, 0, 64, flags + PARENT)
                mergeAmt = mergeAmt / 2
            end

            -- Push back.
            table.insert(stateCvs, mergeCv)

            -- Update state back to next chunk.
            stateCv = iv
            stateT = stateT + 1
            stateN = 0
            stateStart = CHUNK_START
            stateEnd = 0
        end
    end

    -- Pad the last message block.
    local lastLen = #msg == 0 and 0 or (#msg - 1) % 64 + 1
    local padded = msg:sub(-lastLen) .. ("\0"):rep(64)
    local last = {u16x4(fmt16x4, padded, 1)}

    -- Prepare output expansion state.
    local outCv, outBlock, outLen, outFlags
    if stateT > 0 then
        -- Root is a parent, digest last block now and merge parents.
        local stateFlags = flags + stateStart + CHUNK_END
        local mergeCv = compress(stateCv, last, stateT, lastLen, stateFlags)
        for i = #stateCvs, 2, -1 do
            local block = merge(stateCvs[i], mergeCv)
            mergeCv = compress(iv, block, 0, 64, flags + PARENT)
        end

        -- Set output state.
        outCv = iv
        outBlock = merge(stateCvs[1], mergeCv)
        outLen = 64
        outFlags = flags + ROOT + PARENT
    else
        -- Root block is in the first chunk, set output state.
        outCv = stateCv
        outBlock = last
        outLen = lastLen
        outFlags = flags + stateStart + CHUNK_END + ROOT
    end

    -- Expand output.
    local out = {}
    for i = 0, len / 64 do
        local md = compress(outCv, outBlock, i, outLen, outFlags, true)
        out[i + 1] = p16x4(fmt16x4, unpack(md))
    end

    return table.concat(out):sub(1, len)
end

--- Hashes data using BLAKE3.
--- @param message string The input message.
--- @param len number? The desired hash length, in bytes. Defaults to 32.
--- @return string hash The hash.
local function digest(message, len)
    expect(1, message, "string")
    len = expect(2, len, "number", "nil") or 32
    lassert(len % 1 == 0, "desired output length must be an integer", 2)
    lassert(len >= 1, "desired output length must be positive", 2)
    return blake3(IV, 0, message, len)
end

--- Performs a keyed hash.
--- @param key string A 32-byte random key.
--- @param message string The input message.
--- @param len number? The desired hash length, in bytes. Defaults to 32.
--- @return string hash The keyed hash.
local function digestKeyed(key, message, len)
    expect(1, key, "string")
    lassert(#key == 32, "key length must be 32", 2)
    expect(2, message, "string")
    len = expect(3, len, "number", "nil") or 32
    lassert(len % 1 == 0, "desired output length must be an integer", 2)
    lassert(len >= 1, "desired output length must be positive", 2)
    return blake3({u8x4(fmt8x4, key, 1)}, KEYED_HASH, message, len)
end

--- Makes a context-based key derivation function (KDF).
--- @param context string The context for the KDF.
--- @return fun(material: string, len: number?): string kdf The KDF.
local function deriveKey(context)
    expect(1, context, "string")
    local iv = {u8x4(fmt8x4, blake3(IV, DERIVE_KEY_CONTEXT, context, 32), 1)}

    --- Derives a key.
    --- @param material string The keying material.
    --- @param len number? The desired hash length, in bytes. Defaults to 32.
    return function(material, len)
        expect(1, material, "string")
        len = expect(2, len, "number", "nil") or 32
        lassert(len % 1 == 0, "desired output length must be an integer", 2)
        lassert(len >= 1, "desired output length must be positive", 2)
        return blake3(iv, DERIVE_KEY_MATERIAL, material, len)
    end
end

return {
    digest = digest,
    digestKeyed = digestKeyed,
    deriveKey = deriveKey,
}

end,

["ccryptolib.random"] = function()
--------------------
-- Module: 'ccryptolib.random'
--------------------
local expect   = require "cc.expect".expect
local blake3   = require "ccryptolib.blake3"
local chacha20 = require "ccryptolib.chacha20"
local util     = require "ccryptolib.internal.util"

local lassert = util.lassert

-- Extract local context.
local ctx = {
    "ccryptolib 2023-04-11T19:43Z random.lua initialization context",
    os.epoch("utc"),
    os.day(),
    os.time(),
    math.random(0, 2 ^ 24 - 1),
    math.random(0, 2 ^ 24 - 1),
    tostring({}),
    tostring({}),
}

local state = blake3.digest(table.concat(ctx, "|"))
local initialized = false

--- Mixes entropy into the generator, and marks it as initialized.
--- @param seed string The seed data.
local function init(seed)
    expect(1, seed, "string")
    state = blake3.digestKeyed(state, seed)
    initialized = true
end

--- Returns whether the generator has been initialized or not.
--- @return boolean
local function isInit()
    return initialized
end

--- Initializes the generator using VM instruction timing noise.
---
--- This function counts how many instructions the VM can execute within a single
--- millisecond, and mixes the lower bits of these values into the generator state.
--- The current implementation collects data for 512 ms and takes the lower 8 bits from
--- each count.
--- 
--- Compared to fetching entropy from a trusted web source, this approach is riskier but
--- more convenient. The factors that influence instruction timing suggest that this
--- seed is unpredictable for other players, but this assumption might turn out to be
--- untrue.
local function initWithTiming()
    assert(os.epoch("utc") ~= 0)

    local f = assert(load("local e=os.epoch return{" .. ("e'utc',"):rep(256) .. "}"))

    do -- Warmup.
        local t = f()
        while t[256] - t[1] > 1 do t = f() end
    end

    -- Fill up the buffer.
    local buf = {}
    for i = 1, 512 do
        local t = f()
        while t[256] == t[1] do t = f() end
        for j = 1, 256 do
            if t[j] ~= t[1] then
                buf[i] = j - 1
                break
            end
        end
    end

    -- Perform a histogram check to catch faulty os.epoch implementations.
    local hist = {}
    for i = 0, 255 do hist[i] = 0 end
    for i = 1, #buf do hist[buf[i]] = hist[buf[i]] + 1 end
    for i = 0, 255 do assert(hist[i] < 20) end

    init(string.char(table.unpack(buf)))
end

--- Mixes extra entropy into the generator state.
--- @param data string The additional entropy to mix.
local function mix(data)
    expect(1, data, "string")
    state = blake3.digestKeyed(state, data)
end

--- Generates random bytes.
--- @param len number The desired output length.
--- @return string bytes 
local function random(len)
    expect(1, len, "number")
    lassert(initialized, "attempt to use an uninitialized random generator", 2)
    local msg = ("\0"):rep(math.max(len, 0) + 32)
    local nonce = ("\0"):rep(12)
    local out = chacha20.crypt(state, nonce, msg, 8, 0)
    state = out:sub(1, 32)
    return out:sub(33)
end

return {
    init = init,
    isInit = isInit,
    initWithTiming = initWithTiming,
    mix = mix,
    random = random,
}

end,

["ecnet2.uid"] = function()
--------------------
-- Module: 'ecnet2.uid'
--------------------
--- Unique string ID generator.
-- It's just a random string concatenated to a counter. IDs are unique but not
-- uniformly random. Multiple instances of the generator are safe to use and
-- will be unique in relation to each other.

local random = require "ccryptolib.random"

local counter, suffix

--- Returns a unique ID
--- @return string uid A 32-byte unique string id.
return function()
    if not suffix or counter >= 2 ^ 32 then
        suffix = random.random(28)
        counter = 0
    end
    counter = counter + 1
    return ("<I4"):pack(counter) .. suffix
end

end,

["ecnet2.Connection"] = function()
--------------------
-- Module: 'ecnet2.Connection'
--------------------
local class = require "ecnet2.class"
local ecnetd = require "ecnet2.ecnetd"
local addressEncoder = require "ecnet2.addressEncoder"
local modems = require "ecnet2.modems"
local uid = require "ecnet2.uid"

--- An encrypted tunnel operating over a modem.
--- @class ecnet2.Connection
--- @field _state ecnet2.HandshakeState The current handshake state.
--- @field _protocol ecnet2.Protocol The connection's protocol.
--- @field _side string The modem name this connection is routing through.
--- @field _handler function The packet handler function.
--- @field id string The connection's ID, used in `ecnet2_message` events.
local Connection = class "ecnet2.Connection"

--- @param state ecnet2.HandshakeState
--- @param protocol ecnet2.Protocol
--- @param side string
function Connection:initialise(state, protocol, side)
    self.id = uid()
    self._protocol = protocol
    self._side = side
    self._handler = function(m, _, c, d) return self:_handle(m, _, c, d) end
    self._state = state
    if state.d then ecnetd.addHandler(state.d, self._handler) end
end

--- @param newState ecnet2.HandshakeState
function Connection:_setState(newState)
    if self._state.d then ecnetd.removeHandler(self._state.d) end
    if newState.d then ecnetd.addHandler(newState.d, self._handler) end
    self._state = newState
end

--- Handles an incoming packet, modifying the state.
--- @param packet string
--- @param _ string
--- @param ch integer
--- @param dist number
function Connection:_handle(packet, _, ch, dist)
    local newState, msg = self._state.resolve(packet)
    self:_setState(newState)
    if not msg then return end
    local deserialize = self._protocol._interface.deserialize
    local ok, message = pcall(deserialize, msg)
    if ok then
        local addr = addressEncoder.encode(self._state.pk)
        os.queueEvent("ecnet2_message", self.id, addr, message, ch, dist)
    end
end

--- Sends a message.
---
--- Throws `"can't send on an incomplete connection"` until at least one
--- message has been received.
---
--- @param message any The message object.
function Connection:send(message)
    local str = self._protocol._interface.serialize(message)
    assert(type(str) == "string", "serializer returned non-string")
    assert(self._state.maxlen, "can't send on an incomplete connection")
    assert(#str <= self._state.maxlen, "serialized message is too large")
    local newState, data = self._state.send(str)
    self:_setState(newState)
    if data then modems.transmit(self._side, data) end
end

--- Yields until a message is received. Returns the sender and contents, or nil
--- on timeout.
--- @param timeout number?
--- @return string? sender
--- @return any message
function Connection:receive(timeout)
    local timer = -1
    if timeout then timer = os.startTimer(timeout) end
    while true do
        local event, p1, p2, p3 = os.pullEvent()
        if event == "timer" and p1 == timer then
            return
        elseif event == "ecnet2_message" and p1 == self.id then
            os.cancelTimer(timer)
            return p2, p3
        end
    end
end

return Connection

end,

["ccryptolib.internal.mp"] = function()
--------------------
-- Module: 'ccryptolib.internal.mp'
--------------------
--- Multi-precision arithmetic on 264-bit integers.

local unpack = unpack or table.unpack

--- A little-endian big integer of width 11 in (-2⁵²..2⁵²).
--- @class MpSW11L52

--- A little-endian big integer of width 11 in (-2²⁴, 2²⁴).
--- @class MpSW11L24: MpSW11L52

--- A little-endian big integer of width 11 in [0..2²⁴).
--- @class MpUW11L24: MpSW11L24

--- Carries a number in base 2²⁴ into a signed limb form.
--- @param a MpSW11L52
--- @return MpSW11L24 low The carried low limbs.
--- @return number carry The overflowed carry.
local function carryWeak(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10 = unpack(a)

    local h00 = a00 + 3 * 2 ^ 75 - 3 * 2 ^ 75 a01 = a01 + h00 * 2 ^ -24
    local h01 = a01 + 3 * 2 ^ 75 - 3 * 2 ^ 75 a02 = a02 + h01 * 2 ^ -24
    local h02 = a02 + 3 * 2 ^ 75 - 3 * 2 ^ 75 a03 = a03 + h02 * 2 ^ -24
    local h03 = a03 + 3 * 2 ^ 75 - 3 * 2 ^ 75 a04 = a04 + h03 * 2 ^ -24
    local h04 = a04 + 3 * 2 ^ 75 - 3 * 2 ^ 75 a05 = a05 + h04 * 2 ^ -24
    local h05 = a05 + 3 * 2 ^ 75 - 3 * 2 ^ 75 a06 = a06 + h05 * 2 ^ -24
    local h06 = a06 + 3 * 2 ^ 75 - 3 * 2 ^ 75 a07 = a07 + h06 * 2 ^ -24
    local h07 = a07 + 3 * 2 ^ 75 - 3 * 2 ^ 75 a08 = a08 + h07 * 2 ^ -24
    local h08 = a08 + 3 * 2 ^ 75 - 3 * 2 ^ 75 a09 = a09 + h08 * 2 ^ -24
    local h09 = a09 + 3 * 2 ^ 75 - 3 * 2 ^ 75 a10 = a10 + h09 * 2 ^ -24
    local h10 = a10 + 3 * 2 ^ 75 - 3 * 2 ^ 75

    return {
        a00 - h00,
        a01 - h01,
        a02 - h02,
        a03 - h03,
        a04 - h04,
        a05 - h05,
        a06 - h06,
        a07 - h07,
        a08 - h08,
        a09 - h09,
        a10 - h10,
    }, h10 * 2 ^ -24
end

--- Carries a number in base 2²⁴.
--- @param a MpSW11L52
--- @return MpUW11L24 low The low 11 limbs of the output.
--- @return number carry The overflow carry.
local function carry(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10 = unpack(a)

    local l00 = a00 % 2 ^ 24 a01 = a01 + (a00 - l00) * 2 ^ -24
    local l01 = a01 % 2 ^ 24 a02 = a02 + (a01 - l01) * 2 ^ -24
    local l02 = a02 % 2 ^ 24 a03 = a03 + (a02 - l02) * 2 ^ -24
    local l03 = a03 % 2 ^ 24 a04 = a04 + (a03 - l03) * 2 ^ -24
    local l04 = a04 % 2 ^ 24 a05 = a05 + (a04 - l04) * 2 ^ -24
    local l05 = a05 % 2 ^ 24 a06 = a06 + (a05 - l05) * 2 ^ -24
    local l06 = a06 % 2 ^ 24 a07 = a07 + (a06 - l06) * 2 ^ -24
    local l07 = a07 % 2 ^ 24 a08 = a08 + (a07 - l07) * 2 ^ -24
    local l08 = a08 % 2 ^ 24 a09 = a09 + (a08 - l08) * 2 ^ -24
    local l09 = a09 % 2 ^ 24 a10 = a10 + (a09 - l09) * 2 ^ -24
    local l10 = a10 % 2 ^ 24
    local h10 = (a10 - l10) * 2 ^ -24

    return {l00, l01, l02, l03, l04, l05, l06, l07, l08, l09, l10}, h10
end

--- Adds two numbers.
--- @param a MpSW11L24
--- @param b MpSW11L24
--- @return MpSW11L52 c a + b
local function add(a, b)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10 = unpack(a)
    local b00, b01, b02, b03, b04, b05, b06, b07, b08, b09, b10 = unpack(b)

    return {
        a00 + b00,
        a01 + b01,
        a02 + b02,
        a03 + b03,
        a04 + b04,
        a05 + b05,
        a06 + b06,
        a07 + b07,
        a08 + b08,
        a09 + b09,
        a10 + b10,
    }
end

--- Subtracts a number from another.
--- @param a MpSW11L24
--- @param b MpSW11L24
--- @return MpSW11L52 c a - b
local function sub(a, b)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10 = unpack(a)
    local b00, b01, b02, b03, b04, b05, b06, b07, b08, b09, b10 = unpack(b)

    return {
        a00 - b00,
        a01 - b01,
        a02 - b02,
        a03 - b03,
        a04 - b04,
        a05 - b05,
        a06 - b06,
        a07 - b07,
        a08 - b08,
        a09 - b09,
        a10 - b10,
    }
end

--- Computes the lower half of a product between two numbers.
--- @param a MpUW11L24
--- @param b MpUW11L24
--- @return MpUW11L24 c a × b (mod 2²⁶⁴)
--- @return number carry ⌊a × b ÷ 2²⁶⁴⌋
local function lmul(a, b)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10 = unpack(a)
    local b00, b01, b02, b03, b04, b05, b06, b07, b08, b09, b10 = unpack(b)

    return carry {
        a00 * b00,
        a01 * b00 + a00 * b01,
        a02 * b00 + a01 * b01 + a00 * b02,
        a03 * b00 + a02 * b01 + a01 * b02 + a00 * b03,
        a04 * b00 + a03 * b01 + a02 * b02 + a01 * b03 + a00 * b04,
        a05 * b00 + a04 * b01 + a03 * b02 + a02 * b03 + a01 * b04 + a00 * b05,
        a06 * b00 + a05 * b01 + a04 * b02 + a03 * b03 + a02 * b04 + a01 * b05 + a00 * b06,
        a07 * b00 + a06 * b01 + a05 * b02 + a04 * b03 + a03 * b04 + a02 * b05 + a01 * b06 + a00 * b07,
        a08 * b00 + a07 * b01 + a06 * b02 + a05 * b03 + a04 * b04 + a03 * b05 + a02 * b06 + a01 * b07 + a00 * b08,
        a09 * b00 + a08 * b01 + a07 * b02 + a06 * b03 + a05 * b04 + a04 * b05 + a03 * b06 + a02 * b07 + a01 * b08 + a00 * b09,
        a10 * b00 + a09 * b01 + a08 * b02 + a07 * b03 + a06 * b04 + a05 * b05 + a04 * b06 + a03 * b07 + a02 * b08 + a01 * b09 + a00 * b10,
    }
end

--- Computes the a product between two numbers.
--- @param a MpUW11L24
--- @param b MpUW11L24
--- @return MpUW11L24 low The low 11 limbs of a × b.
--- @return MpUW11L24 high The high 11 limbs of a × b.
local function mul(a, b)
    local low, of = lmul(a, b)

    local _, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10 = unpack(a)
    local _, b01, b02, b03, b04, b05, b06, b07, b08, b09, b10 = unpack(b)

    -- The carry is always 0.
    return low, (carry {
        of + a10 * b01 + a09 * b02 + a08 * b03 + a07 * b04 + a06 * b05 + a05 * b06 + a04 * b07 + a03 * b08 + a02 * b09 + a01 * b10,
        a10 * b02 + a09 * b03 + a08 * b04 + a07 * b05 + a06 * b06 + a05 * b07 + a04 * b08 + a03 * b09 + a02 * b10,
        a10 * b03 + a09 * b04 + a08 * b05 + a07 * b06 + a06 * b07 + a05 * b08 + a04 * b09 + a03 * b10,
        a10 * b04 + a09 * b05 + a08 * b06 + a07 * b07 + a06 * b08 + a05 * b09 + a04 * b10,
        a10 * b05 + a09 * b06 + a08 * b07 + a07 * b08 + a06 * b09 + a05 * b10,
        a10 * b06 + a09 * b07 + a08 * b08 + a07 * b09 + a06 * b10,
        a10 * b07 + a09 * b08 + a08 * b09 + a07 * b10,
        a10 * b08 + a09 * b09 + a08 * b10,
        a10 * b09 + a09 * b10,
        a10 * b10,
        0
    })
end

--- Computes a double-width sum of two numbers.
--- @param a0 MpUW11L24 The low 11 limbs of a.
--- @param a1 MpUW11L24 The high 11 limbs of a.
--- @param b0 MpUW11L24 The low 11 limbs of b.
--- @param b1 MpUW11L24 The high 11 limbs of b.
--- @return MpUW11L24 c0 The low 11 limbs of a + b.
--- @return MpUW11L24 c1 The high 11 limbs of a + b.
--- @return number The carry.
local function dwadd(a0, a1, b0, b1)
    local low, c = carry(add(a0, b0))
    local high = add(a1, b1)
    high[1] = high[1] + c
    return low, carry(high)
end

--- Computes half of a number.
--- @param a MpSW11L24 The number to halve, must be even.
--- @return MpSW11L24 c a ÷ 2
local function half(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10 = unpack(a)

    return (carryWeak {
        a00 * 0.5 + a01 * 2 ^ 23,
        a02 * 2 ^ 23,
        a03 * 2 ^ 23,
        a04 * 2 ^ 23,
        a05 * 2 ^ 23,
        a06 * 2 ^ 23,
        a07 * 2 ^ 23,
        a08 * 2 ^ 23,
        a09 * 2 ^ 23,
        a10 * 2 ^ 23,
        0,
    })
end

--- Computes a third of a number.
--- @param a MpSW11L24 The number to divide, must be a multiple of 3.
--- @return MpSW11L24 c a ÷ 3
local function third(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10 = unpack(a)

    local d00 = a00 * 0xaaaaaa
    local d01 = a01 * 0xaaaaaa + d00
    local d02 = a02 * 0xaaaaaa + d01
    local d03 = a03 * 0xaaaaaa + d02
    local d04 = a04 * 0xaaaaaa + d03
    local d05 = a05 * 0xaaaaaa + d04
    local d06 = a06 * 0xaaaaaa + d05
    local d07 = a07 * 0xaaaaaa + d06
    local d08 = a08 * 0xaaaaaa + d07
    local d09 = a09 * 0xaaaaaa + d08
    local d10 = a10 * 0xaaaaaa + d09

    -- We compute the modular division mod 2²⁶⁴. The carry isn't 0 but it isn't
    -- part of a ÷ 3 either.
    return (carryWeak {
        a00 + d00,
        a01 + d01,
        a02 + d02,
        a03 + d03,
        a04 + d04,
        a05 + d05,
        a06 + d06,
        a07 + d07,
        a08 + d08,
        a09 + d09,
        a10 + d10,
    })
end

--- Computes a number modulo 2.
--- @param a MpSW11L24
--- @return number c a mod 2.
local function mod2(a)
    return a[1] % 2
end

--- Computes a number modulo 3.
--- @param a MpSW11L24
--- @return number c a mod 3.
local function mod3(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10 = unpack(a)
    return (a00 + a01 + a02 + a03 + a04 + a05 + a06 + a07 + a08 + a09 + a10) % 3
end

--- Computes a double representing the most-significant bits of a number.
--- @param a MpSW11L52
--- @return number c A floating-point approximation for the value of a.
local function approx(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10 = unpack(a)
    return a00
         + a01 * 2 ^ 24
         + a02 * 2 ^ 48
         + a03 * 2 ^ 72
         + a04 * 2 ^ 96
         + a05 * 2 ^ 120
         + a06 * 2 ^ 144
         + a07 * 2 ^ 168
         + a08 * 2 ^ 192
         + a09 * 2 ^ 216
         + a10 * 2 ^ 240
end

--- Compares two numbers for ordering.
--- @param a MpSW11L24
--- @param b MpSW11L24
--- @return number ord Some number with ord < 0 iff a < b and ord = 0 iff a = b.
local function cmp(a, b)
    return approx(sub(a, b))
end

local function num(a)
    return {a, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end

return {
    carry = carry,
    carryWeak = carryWeak,
    add = add,
    sub = sub,
    dwadd = dwadd,
    lmul = lmul,
    mul = mul,
    half = half,
    third = third,
    mod2 = mod2,
    mod3 = mod3,
    approx = approx,
    cmp = cmp,
    num = num,
}

end,

["ccryptolib.internal.fq"] = function()
--------------------
-- Module: 'ccryptolib.internal.fq'
--------------------
--- Arithmetic on Curve25519's scalar field.

local mp = require "ccryptolib.internal.mp"
local util = require "ccryptolib.internal.util"
local packing = require "ccryptolib.internal.packing"

local unpack = unpack or table.unpack
local pfq, fmtfq = packing.compilePack("<I3I3I3I3I3I3I3I3I3I3I2")
local ufq = packing.compileUnpack(fmtfq)
local ufql, fmtfql = packing.compileUnpack("<I3I3I3I3I3I3I3I3I3I3I3")
local ufqh, fmtfqh = packing.compileUnpack("<I3I3I3I3I3I3I3I3I3I3I1")

--- The scalar field's order, q = 2²⁵² + 27742317777372353535851937790883648493.
local Q = {
    16110573,
    06494812,
    14047250,
    10680220,
    14612958,
    00000020,
    00000000,
    00000000,
    00000000,
    00000000,
    00004096,
}

--- The first Montgomery precomputed constant, -q⁻¹ mod 2²⁶⁴.
local T0 = {
    05537307,
    01942290,
    16765621,
    16628356,
    10618610,
    07072433,
    03735459,
    01369940,
    15276086,
    13038191,
    13409718,
}

--- The second Montgomery precomputed constant, 2⁵²⁸ mod q.
local T1 = {
    11711996,
    01747860,
    08326961,
    03814718,
    01859974,
    13327461,
    16105061,
    07590423,
    04050668,
    08138906,
    00000283,
}

local T8 = {
    5110253,
    3039345,
    2503500,
    11779568,
    15416472,
    16766550,
    16777215,
    16777215,
    16777215,
    16777215,
    4095,
}

local ZERO = mp.num(0)

--- Reduces a number modulo q.
--
-- @tparam {number...} a A number a < 2q as 11 limbs in [0..2²⁵).
-- @treturn {number...} a mod q as 11 limbs in [0..2²⁴).
--
local function reduce(a)
    local c = mp.sub(a, Q)

    -- Return carry(a) if a < q.
    if mp.approx(c) < 0 then return (mp.carry(a)) end

    -- c >= q means c - q >= 0.
    -- Since q < 2²⁸⁸, c < 2q means c - q < q < 2²⁸⁸.
    -- c's limbs fit in (-2²⁶..2²⁶), since subtraction adds at most one bit.
    return (mp.carry(c)) -- cc < q implies that the carry number is 0.
end

--- Adds two scalars mod q.
--
-- If the two operands are in Montgomery form, returns the correct result also
-- in Montgomery form, since (2²⁶⁴ × a) + (2²⁶⁴ × b) ≡ 2²⁶⁴ × (a + b) (mod q).
--
-- @tparam {number...} a A number a < q as 11 limbs in [0..2²⁴).
-- @tparam {number...} b A number b < q as 11 limbs in [0..2²⁴).
-- @treturn {number...} a + b mod q as 11 limbs in [0..2²⁴).
--
local function add(a, b)
    return reduce(mp.add(a, b))
end

--- Negates a scalar mod q.
--
-- @tparam {number...} a A number a < q as 11 limbs in [0..2²⁴).
-- @treturn {number...} -a mod q as 11 limbs in [0..2²⁴).
--
local function neg(a)
    return reduce(mp.sub(Q, a))
end

--- Subtracts scalars mod q.
--
-- If the two operands are in Montgomery form, returns the correct result also
-- in Montgomery form, since (2²⁶⁴ × a) - (2²⁶⁴ × b) ≡ 2²⁶⁴ × (a - b) (mod q).
--
-- @tparam {number...} a A number a < q as 11 limbs in [0..2²⁴).
-- @tparam {number...} b A number b < q as 11 limbs in [0..2²⁴).
-- @treturn {number...} a - b mod q as 11 limbs in [0..2²⁴).
--
local function sub(a, b)
    return add(a, neg(b))
end

--- Given two scalars a and b, computes 2⁻²⁶⁴ × a × b mod q.
--
-- @tparam {number...} a A number a as 11 limbs in [0..2²⁴).
-- @tparam {number...} b A number b < q as 11 limbs in [0..2²⁴).
-- @treturn {number...} 2⁻²⁶⁴ × a × b mod q as 11 limbs in [0..2²⁴).
--
local function mul(a, b)
    local t0, t1 = mp.mul(a, b)
    local mq0, mq1 = mp.mul(mp.lmul(t0, T0), Q)
    local _, s1 = mp.dwadd(t0, t1, mq0, mq1)
    return reduce(s1)
end

--- Converts a scalar into Montgomery form.
--
-- @tparam {number...} a A number a as 11 limbs in [0..2²⁴).
-- @treturn {number...} 2²⁶⁴ × a mod q as 11 limbs in [0..2²⁴).
--
local function montgomery(a)
    -- 0 ≤ a < 2²⁶⁴ and 0 ≤ T1 < q.
    return mul(a, T1)
end

--- Converts a scalar from Montgomery form.
--
-- @tparam {number...} a A number a < q as 11 limbs in [0..2²⁴).
-- @treturn {number...} 2⁻²⁶⁴ × a mod q as 11 limbs in [0..2²⁴).
--
local function demontgomery(a)
    -- It's REDC all over again except b is 1.
    local mq0, mq1 = mp.mul(mp.lmul(a, T0), Q)
    local _, s1 = mp.dwadd(a, ZERO, mq0, mq1)
    return reduce(s1)
end

--- Encodes a scalar.
--
-- @tparam {number...} a A number 2²⁶⁴ × a mod q as 11 limbs in [0..2²⁴).
-- @treturn string The 32-byte string encoding of a.
--
local function encode(a)
    return pfq(fmtfq, unpack(demontgomery(a)))
end

--- Decodes a scalar.
--
-- @tparam string str A 32-byte string encoding some little-endian number a.
-- @treturn {number...} 2²⁶⁴ × a mod q as 11 limbs in [0..2²⁴).
--
local function decode(str)
    local dec = {ufq(fmtfq, str, 1)} dec[12] = nil
    return montgomery(dec)
end

--- Decodes a scalar from a "wide" string.
--
-- @tparam string str A 64-byte string encoding some little-endian number a.
-- @treturn {number...} 2²⁶⁴ × a mod q as 11 limbs in [0..2²⁴).
--
local function decodeWide(str)
    local low = {ufql(fmtfql, str, 1)} low[12] = nil
    local high = {ufqh(fmtfqh, str, 34)} high[12] = nil
    return add(montgomery(low), montgomery(montgomery(high)))
end

--- Decodes a scalar using the X25519/Ed25519 bit clamping scheme.
--
-- @tparam string str A 32-byte string encoding some little-endian number a.
-- @treturn {number...} 2²⁶⁴ × clamp(a) mod q as 11 limbs in [0..2²⁴).
--
local function decodeClamped(str)
    -- Decode.
    local words = {ufq(fmtfq, str, 1)} words[12] = nil

    -- Clamp.
    words[1] = bit32.band(words[1], 0xfffff8)
    words[11] = bit32.band(words[11], 0x7fff)
    words[11] = bit32.bor(words[11], 0x4000)

    return montgomery(words)
end

--- Divides a scalar by 8.
--
-- @tparam {number...} 2²⁶⁴ × a mod q as 11 limbs in [0..2²⁴).
-- @treturn {number...} 2²⁶⁵ × a ÷ 8 mod q as 11 limbs in [0..2²⁴).
local function eighth(a)
    return mul(a, T8)
end

--- Returns a scalar in binary.
--
-- @tparam {number...} a A number a < q as 11 limbs in [0..2²⁴).
-- @treturn {number...} 2⁻²⁶⁴ × a mod q as 253 bits.
--
local function bits(a)
    local out = util.rebaseLE(demontgomery(a), 2 ^ 24, 2)
    for i = 254, 289 do out[i] = nil end
    return out
end

--- Makes a PRAC ruleset from a pair of scalars.
--
-- For more information see section 3.3 of Speeding up subgroup cryptosystems:
-- Martijn Stam. Speeding up subgroup cryptosystems. PhD thesis, Technische
-- Universiteit Eindhoven, 2003. https://dx.doi.org/10.6100/IR564670.
--
-- @tparam {number...} a A scalar 2²⁶⁴ × a mod q as 11 limbs in [0..2²⁴).
-- @tparam {number...} b A scalar 2²⁶⁴ × b mod q as 11 limbs in [0..2²⁴).
-- @treturn {{number...}, {number...}} The generated ruleset.
--
local function makeRuleset(a, b)
    -- The numbers in raw multiprecision tables.
    local dt = demontgomery(a) -- (-2²⁴..2²⁴)
    local et = demontgomery(b) -- (-2²⁴..2²⁴)
    local ft = mp.sub(dt, et)  -- (-2²⁵..2²⁵)

    -- Residue classes of (d, e) modulo 2.
    local d2 = mp.mod2(dt)
    local e2 = mp.mod2(et)

    -- Residue classes of (d, e) modulo 3.
    local d3 = mp.mod3(dt)
    local e3 = mp.mod3(et)

    -- (e, d - e) in limited-precision floating-point numbers.
    local ef = mp.approx(et)
    local ff = mp.approx(ft)

    -- Lookup table for inversions and halvings modulo 3.
    local lut3 = {[0] = 0, 2, 1}

    local rules = {}
    while ff ~= 0 do
        if ff < 0 then
            -- M0. d < e
            rules[#rules + 1] = 0
            -- (d, e) ← (e, d)
            dt, et = et, dt
            d2, e2 = e2, d2
            d3, e3 = e3, d3
            ef = mp.approx(et)
            ft = mp.sub(dt, et)
            ff = -ff
        elseif 4 * ff < ef and d3 == lut3[e3] then
            -- M1. e < d ≤ 5/4 e, d ≡ -e (mod 3)
            rules[#rules + 1] = 1
            -- (d, e) ← ((2d - e)/3, (2e - d)/3)
            dt, et = mp.third(mp.add(dt, ft)), mp.third(mp.sub(et, ft))
            d2, e2 = e2, d2
            d3, e3 = mp.mod3(dt), mp.mod3(et)
            ef = mp.approx(et)
        elseif 4 * ff < ef and d2 == e2 and d3 == e3 then
            -- M2. e < d ≤ 5/4 e, d ≡ e (mod 6)
            rules[#rules + 1] = 2
            -- (d, e) ← ((d - e)/2, e)
            dt = mp.half(ft)
            d2 = mp.mod2(dt)
            d3 = lut3[(d3 - e3) % 3]
            ft = mp.sub(dt, et)
            ff = mp.approx(ft)
        elseif ff < 3 * ef then
            -- M3. d ≤ 4e
            rules[#rules + 1] = 3
            -- (d, e) ← (d - e, e)
            dt = mp.carryWeak(ft)
            d2 = (d2 - e2) % 2
            d3 = (d3 - e3) % 3
            ft = mp.sub(dt, et)
            ff = mp.approx(ft)
        elseif d2 == e2 then
            -- M4. d ≡ e (mod 2)
            rules[#rules + 1] = 2
            -- (d, e) ← ((d - e)/2, e)
            dt = mp.half(ft)
            d2 = mp.mod2(dt)
            d3 = lut3[(d3 - e3) % 3]
            ft = mp.sub(dt, et)
            ff = mp.approx(ft)
        elseif d2 == 0 then
            -- M5. d ≡ 0 (mod 2)
            rules[#rules + 1] = 5
            -- (d, e) ← (d/2, e)
            dt = mp.half(dt)
            d2 = mp.mod2(dt)
            d3 = lut3[d3]
            ft = mp.sub(dt, et)
            ff = mp.approx(ft)
        elseif d3 == 0 then
            -- M6. d ≡ 0 (mod 3)
            rules[#rules + 1] = 6
            -- (d, e) ← (d/3 - e, e)
            dt = mp.carryWeak(mp.sub(mp.third(dt), et))
            d2 = (d2 - e2) % 2
            d3 = mp.mod3(dt)
            ft = mp.sub(dt, et)
            ff = mp.approx(ft)
        elseif d3 == lut3[e3] then
            -- M7. d ≡ -e (mod 3)
            rules[#rules + 1] = 7
            -- (d, e) ← ((d - 2e)/3, e)
            dt = mp.third(mp.sub(ft, et))
            d3 = mp.mod3(dt)
            ft = mp.sub(dt, et)
            ff = mp.approx(ft)
        elseif d3 == e3 then
            -- M8. d ≡ e (mod 3)
            rules[#rules + 1] = 8
            -- (d, e) ← ((d - e)/3, e)
            dt = mp.third(ft)
            d2 = (d2 - e2) % 2
            d3 = mp.mod3(dt)
            ft = mp.sub(dt, et)
            ff = mp.approx(ft)
        else
            -- M9. e ≡ 0 (mod 2)
            rules[#rules + 1] = 9
            -- (d, e) ← (d, e/2)
            et = mp.half(et)
            e2 = mp.mod2(et)
            e3 = lut3[e3]
            ef = mp.approx(et)
            ft = mp.sub(dt, et)
            ff = mp.approx(ft)
        end
    end

    local ubits = util.rebaseLE(dt, 2 ^ 24, 2)
    while ubits[#ubits] == 0 do ubits[#ubits] = nil end

    return {ubits, rules}
end

return {
    add = add,
    sub = sub,
    mul = mul,
    encode = encode,
    decode = decode,
    decodeWide = decodeWide,
    decodeClamped = decodeClamped,
    eighth = eighth,
    bits = bits,
    makeRuleset = makeRuleset,
}

end,

["ccryptolib.internal.fp"] = function()
--------------------
-- Module: 'ccryptolib.internal.fp'
--------------------
--- Arithmetic on Curve25519's base field.

local packing = require "ccryptolib.internal.packing"

local unpack = unpack or table.unpack
local ufp, fmtfp = packing.compileUnpack("<I3I3I2I3I3I2I3I3I2I3I3I2")

--- @class Fq An element of the field of integers modulo 2²⁵⁵ - 19.

--- @class FpR2: Fq An Fp element with limbs inside twice the standard range.

--- @class FpR1: FpR2 An Fp element with limbs inside the standard range. See
--- the Curve25519 polynomial representation for more info around this.

--- The modular square root of -1.
--- @type FpR1
local I = {
    0958640 * 2 ^ 0,
    0826664 * 2 ^ 22,
    1613251 * 2 ^ 43,
    1041528 * 2 ^ 64,
    0013673 * 2 ^ 85,
    0387171 * 2 ^ 107,
    1824679 * 2 ^ 128,
    0313839 * 2 ^ 149,
    0709440 * 2 ^ 170,
    0122635 * 2 ^ 192,
    0262782 * 2 ^ 213,
    0712905 * 2 ^ 234,
}

--- Converts a Lua number to an element.
--- @param n number A number n in [0..2²²).
--- @return FpR1 out The number as an element.
local function num(n)
    return {n, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
end

--- Negates an element.
--- @param a FpR1
--- @return FpR1 out -a.
local function neg(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11 = unpack(a)
    return {
        -a00,
        -a01,
        -a02,
        -a03,
        -a04,
        -a05,
        -a06,
        -a07,
        -a08,
        -a09,
        -a10,
        -a11,
    }
end

--- Adds two elements.
--- @param a FpR1
--- @param b FpR1
--- @return FpR2 out a + b.
local function add(a, b)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11 = unpack(a)
    local b00, b01, b02, b03, b04, b05, b06, b07, b08, b09, b10, b11 = unpack(b)
    return {
        a00 + b00,
        a01 + b01,
        a02 + b02,
        a03 + b03,
        a04 + b04,
        a05 + b05,
        a06 + b06,
        a07 + b07,
        a08 + b08,
        a09 + b09,
        a10 + b10,
        a11 + b11,
    }
end

--- Subtracts an element from another.
--- @param a FpR1
--- @param b FpR1
--- @return FpR2 out a - b.
local function sub(a, b)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11 = unpack(a)
    local b00, b01, b02, b03, b04, b05, b06, b07, b08, b09, b10, b11 = unpack(b)
    return {
        a00 - b00,
        a01 - b01,
        a02 - b02,
        a03 - b03,
        a04 - b04,
        a05 - b05,
        a06 - b06,
        a07 - b07,
        a08 - b08,
        a09 - b09,
        a10 - b10,
        a11 - b11,
    }
end

--- Carries an element. Also performs a small reduction modulo p.
--- @param a FpR2 The element to carry.
--- @return FpR1 out The same element as a but in a tighter range.
local function carry(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11 = unpack(a)
    local c00, c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11

    c11 = a11 + 3 * 2 ^ 306 - 3 * 2 ^ 306  a00 = a00 + 19 / 2 ^ 255 * c11

    c00 = a00 + 3 * 2 ^ 73  - 3 * 2 ^ 73   a01 = a01 + c00
    c01 = a01 + 3 * 2 ^ 94  - 3 * 2 ^ 94   a02 = a02 + c01
    c02 = a02 + 3 * 2 ^ 115 - 3 * 2 ^ 115  a03 = a03 + c02
    c03 = a03 + 3 * 2 ^ 136 - 3 * 2 ^ 136  a04 = a04 + c03
    c04 = a04 + 3 * 2 ^ 158 - 3 * 2 ^ 158  a05 = a05 + c04
    c05 = a05 + 3 * 2 ^ 179 - 3 * 2 ^ 179  a06 = a06 + c05
    c06 = a06 + 3 * 2 ^ 200 - 3 * 2 ^ 200  a07 = a07 + c06
    c07 = a07 + 3 * 2 ^ 221 - 3 * 2 ^ 221  a08 = a08 + c07
    c08 = a08 + 3 * 2 ^ 243 - 3 * 2 ^ 243  a09 = a09 + c08
    c09 = a09 + 3 * 2 ^ 264 - 3 * 2 ^ 264  a10 = a10 + c09
    c10 = a10 + 3 * 2 ^ 285 - 3 * 2 ^ 285  a11 = a11 - c11 + c10

    c11 = a11 + 3 * 2 ^ 306 - 3 * 2 ^ 306

    return {
        a00 - c00 + 19 / 2 ^ 255 * c11,
        a01 - c01,
        a02 - c02,
        a03 - c03,
        a04 - c04,
        a05 - c05,
        a06 - c06,
        a07 - c07,
        a08 - c08,
        a09 - c09,
        a10 - c10,
        a11 - c11,
    }
end

--- Returns the canoncal representative of a modp number.
---
--- Some elements can be represented by two different arrays of floats. This
--- returns the canonical element of the represented equivalence class. We
--- define an element as canonical if it's the smallest nonnegative number in
--- its class.
---
--- @param a FpR2
--- @return FpR1 out A canonical element a' ≡ a (mod p).
local function canonicalize(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11 = unpack(a)
    local c00, c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11

    -- Perform an euclidean reduction.
    -- TODO Range check.
    c00 = a00 % 2 ^ 22   a01 = a00 - c00 + a01
    c01 = a01 % 2 ^ 43   a02 = a01 - c01 + a02
    c02 = a02 % 2 ^ 64   a03 = a02 - c02 + a03
    c03 = a03 % 2 ^ 85   a04 = a03 - c03 + a04
    c04 = a04 % 2 ^ 107  a05 = a04 - c04 + a05
    c05 = a05 % 2 ^ 128  a06 = a05 - c05 + a06
    c06 = a06 % 2 ^ 149  a07 = a06 - c06 + a07
    c07 = a07 % 2 ^ 170  a08 = a07 - c07 + a08
    c08 = a08 % 2 ^ 192  a09 = a08 - c08 + a09
    c09 = a09 % 2 ^ 213  a10 = a09 - c09 + a10
    c10 = a10 % 2 ^ 234  a11 = a10 - c10 + a11
    c11 = a11 % 2 ^ 255  c00 = c00 + 19 / 2 ^ 255 * (a11 - c11)

    -- Canonicalize.
    if      c11 / 2 ^ 234 == 2 ^ 21 - 1
        and c10 / 2 ^ 213 == 2 ^ 21 - 1
        and c09 / 2 ^ 192 == 2 ^ 21 - 1
        and c08 / 2 ^ 170 == 2 ^ 22 - 1
        and c07 / 2 ^ 149 == 2 ^ 21 - 1
        and c06 / 2 ^ 128 == 2 ^ 21 - 1
        and c05 / 2 ^ 107 == 2 ^ 21 - 1
        and c04 / 2 ^ 85  == 2 ^ 22 - 1
        and c03 / 2 ^ 64  == 2 ^ 21 - 1
        and c02 / 2 ^ 43  == 2 ^ 21 - 1
        and c01 / 2 ^ 22  == 2 ^ 21 - 1
        and c00 >= 2 ^ 22 - 19
    then
        return {19 - 2 ^ 22 + c00, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    else
        return {c00, c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11}
    end
end

--- Returns whether two elements are the same.
--- @param a FpR1
--- @param b FpR1
--- @return boolean eq Whether a ≡ b (mod p).
local function eq(a, b)
    local c = canonicalize(sub(a, b))
    for i = 1, 12 do if c[i] ~= 0 then return false end end
    return true
end

--- Multiplies two elements.
--- @param a FpR2
--- @param b FpR2
--- @return FpR1 c An element such that c ≡ a × b (mod p).
local function mul(a, b)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11 = unpack(a)
    local b00, b01, b02, b03, b04, b05, b06, b07, b08, b09, b10, b11 = unpack(b)
    local c00, c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11

    -- Multiply high half into c00..c11.
    c00 = a11 * b01
        + a10 * b02
        + a09 * b03
        + a08 * b04
        + a07 * b05
        + a06 * b06
        + a05 * b07
        + a04 * b08
        + a03 * b09
        + a02 * b10
        + a01 * b11
    c01 = a11 * b02
        + a10 * b03
        + a09 * b04
        + a08 * b05
        + a07 * b06
        + a06 * b07
        + a05 * b08
        + a04 * b09
        + a03 * b10
        + a02 * b11
    c02 = a11 * b03
        + a10 * b04
        + a09 * b05
        + a08 * b06
        + a07 * b07
        + a06 * b08
        + a05 * b09
        + a04 * b10
        + a03 * b11
    c03 = a11 * b04
        + a10 * b05
        + a09 * b06
        + a08 * b07
        + a07 * b08
        + a06 * b09
        + a05 * b10
        + a04 * b11
    c04 = a11 * b05
        + a10 * b06
        + a09 * b07
        + a08 * b08
        + a07 * b09
        + a06 * b10
        + a05 * b11
    c05 = a11 * b06
        + a10 * b07
        + a09 * b08
        + a08 * b09
        + a07 * b10
        + a06 * b11
    c06 = a11 * b07
        + a10 * b08
        + a09 * b09
        + a08 * b10
        + a07 * b11
    c07 = a11 * b08
        + a10 * b09
        + a09 * b10
        + a08 * b11
    c08 = a11 * b09
        + a10 * b10
        + a09 * b11
    c09 = a11 * b10
        + a10 * b11
    c10 = a11 * b11

    -- Multiply low half with reduction into c00..c11.
    c00 = c00 * (19 / 2 ^ 255)
        + a00 * b00
    c01 = c01 * (19 / 2 ^ 255)
        + a01 * b00
        + a00 * b01
    c02 = c02 * (19 / 2 ^ 255)
        + a02 * b00
        + a01 * b01
        + a00 * b02
    c03 = c03 * (19 / 2 ^ 255)
        + a03 * b00
        + a02 * b01
        + a01 * b02
        + a00 * b03
    c04 = c04 * (19 / 2 ^ 255)
        + a04 * b00
        + a03 * b01
        + a02 * b02
        + a01 * b03
        + a00 * b04
    c05 = c05 * (19 / 2 ^ 255)
        + a05 * b00
        + a04 * b01
        + a03 * b02
        + a02 * b03
        + a01 * b04
        + a00 * b05
    c06 = c06 * (19 / 2 ^ 255)
        + a06 * b00
        + a05 * b01
        + a04 * b02
        + a03 * b03
        + a02 * b04
        + a01 * b05
        + a00 * b06
    c07 = c07 * (19 / 2 ^ 255)
        + a07 * b00
        + a06 * b01
        + a05 * b02
        + a04 * b03
        + a03 * b04
        + a02 * b05
        + a01 * b06
        + a00 * b07
    c08 = c08 * (19 / 2 ^ 255)
        + a08 * b00
        + a07 * b01
        + a06 * b02
        + a05 * b03
        + a04 * b04
        + a03 * b05
        + a02 * b06
        + a01 * b07
        + a00 * b08
    c09 = c09 * (19 / 2 ^ 255)
        + a09 * b00
        + a08 * b01
        + a07 * b02
        + a06 * b03
        + a05 * b04
        + a04 * b05
        + a03 * b06
        + a02 * b07
        + a01 * b08
        + a00 * b09
    c10 = c10 * (19 / 2 ^ 255)
        + a10 * b00
        + a09 * b01
        + a08 * b02
        + a07 * b03
        + a06 * b04
        + a05 * b05
        + a04 * b06
        + a03 * b07
        + a02 * b08
        + a01 * b09
        + a00 * b10
    c11 = a11 * b00
        + a10 * b01
        + a09 * b02
        + a08 * b03
        + a07 * b04
        + a06 * b05
        + a05 * b06
        + a04 * b07
        + a03 * b08
        + a02 * b09
        + a01 * b10
        + a00 * b11

    -- Carry and reduce.
    a10 = c10 + 3 * 2 ^ 285 - 3 * 2 ^ 285  c11 = c11 + a10
    a11 = c11 + 3 * 2 ^ 306 - 3 * 2 ^ 306  c00 = c00 + 19 / 2 ^ 255 * a11

    a00 = c00 + 3 * 2 ^ 73  - 3 * 2 ^ 73   c01 = c01 + a00
    a01 = c01 + 3 * 2 ^ 94  - 3 * 2 ^ 94   c02 = c02 + a01
    a02 = c02 + 3 * 2 ^ 115 - 3 * 2 ^ 115  c03 = c03 + a02
    a03 = c03 + 3 * 2 ^ 136 - 3 * 2 ^ 136  c04 = c04 + a03
    a04 = c04 + 3 * 2 ^ 158 - 3 * 2 ^ 158  c05 = c05 + a04
    a05 = c05 + 3 * 2 ^ 179 - 3 * 2 ^ 179  c06 = c06 + a05
    a06 = c06 + 3 * 2 ^ 200 - 3 * 2 ^ 200  c07 = c07 + a06
    a07 = c07 + 3 * 2 ^ 221 - 3 * 2 ^ 221  c08 = c08 + a07
    a08 = c08 + 3 * 2 ^ 243 - 3 * 2 ^ 243  c09 = c09 + a08
    a09 = c09 + 3 * 2 ^ 264 - 3 * 2 ^ 264  c10 = c10 - a10 + a09
    a10 = c10 + 3 * 2 ^ 285 - 3 * 2 ^ 285  c11 = c11 - a11 + a10

    a11 = c11 + 3 * 2 ^ 306 - 3 * 2 ^ 306

    return {
        c00 - a00 + 19 / 2 ^ 255 * a11,
        c01 - a01,
        c02 - a02,
        c03 - a03,
        c04 - a04,
        c05 - a05,
        c06 - a06,
        c07 - a07,
        c08 - a08,
        c09 - a09,
        c10 - a10,
        c11 - a11,
    }
end

--- Squares an element.
--- @param a FpR2
--- @return FpR1 b An element such that b ≡ a² (mod p).
local function square(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11 = unpack(a)
    local d00, d01, d02, d03, d04, d05, d06, d07, d08, d09, d10
    local c00, c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11

    -- Compute 2a.
    d00 = a00 + a00
    d01 = a01 + a01
    d02 = a02 + a02
    d03 = a03 + a03
    d04 = a04 + a04
    d05 = a05 + a05
    d06 = a06 + a06
    d07 = a07 + a07
    d08 = a08 + a08
    d09 = a09 + a09
    d10 = a10 + a10

    -- Multiply high half into c00..c11.
    c00 = a11 * d01
        + a10 * d02
        + a09 * d03
        + a08 * d04
        + a07 * d05
        + a06 * a06
    c01 = a11 * d02
        + a10 * d03
        + a09 * d04
        + a08 * d05
        + a07 * d06
    c02 = a11 * d03
        + a10 * d04
        + a09 * d05
        + a08 * d06
        + a07 * a07
    c03 = a11 * d04
        + a10 * d05
        + a09 * d06
        + a08 * d07
    c04 = a11 * d05
        + a10 * d06
        + a09 * d07
        + a08 * a08
    c05 = a11 * d06
        + a10 * d07
        + a09 * d08
    c06 = a11 * d07
        + a10 * d08
        + a09 * a09
    c07 = a11 * d08
        + a10 * d09
    c08 = a11 * d09
        + a10 * a10
    c09 = a11 * d10
    c10 = a11 * a11

    -- Multiply low half with reduction into c00..c11.
    c00 = c00 * (19 / 2 ^ 255)
        + a00 * a00
    c01 = c01 * (19 / 2 ^ 255)
        + a01 * d00
    c02 = c02 * (19 / 2 ^ 255)
        + a02 * d00
        + a01 * a01
    c03 = c03 * (19 / 2 ^ 255)
        + a03 * d00
        + a02 * d01
    c04 = c04 * (19 / 2 ^ 255)
        + a04 * d00
        + a03 * d01
        + a02 * a02
    c05 = c05 * (19 / 2 ^ 255)
        + a05 * d00
        + a04 * d01
        + a03 * d02
    c06 = c06 * (19 / 2 ^ 255)
        + a06 * d00
        + a05 * d01
        + a04 * d02
        + a03 * a03
    c07 = c07 * (19 / 2 ^ 255)
        + a07 * d00
        + a06 * d01
        + a05 * d02
        + a04 * d03
    c08 = c08 * (19 / 2 ^ 255)
        + a08 * d00
        + a07 * d01
        + a06 * d02
        + a05 * d03
        + a04 * a04
    c09 = c09 * (19 / 2 ^ 255)
        + a09 * d00
        + a08 * d01
        + a07 * d02
        + a06 * d03
        + a05 * d04
    c10 = c10 * (19 / 2 ^ 255)
        + a10 * d00
        + a09 * d01
        + a08 * d02
        + a07 * d03
        + a06 * d04
        + a05 * a05
    c11 = a11 * d00
        + a10 * d01
        + a09 * d02
        + a08 * d03
        + a07 * d04
        + a06 * d05

    -- Carry and reduce.
    a10 = c10 + 3 * 2 ^ 285 - 3 * 2 ^ 285  c11 = c11 + a10
    a11 = c11 + 3 * 2 ^ 306 - 3 * 2 ^ 306  c00 = c00 + 19 / 2 ^ 255 * a11

    a00 = c00 + 3 * 2 ^ 73  - 3 * 2 ^ 73   c01 = c01 + a00
    a01 = c01 + 3 * 2 ^ 94  - 3 * 2 ^ 94   c02 = c02 + a01
    a02 = c02 + 3 * 2 ^ 115 - 3 * 2 ^ 115  c03 = c03 + a02
    a03 = c03 + 3 * 2 ^ 136 - 3 * 2 ^ 136  c04 = c04 + a03
    a04 = c04 + 3 * 2 ^ 158 - 3 * 2 ^ 158  c05 = c05 + a04
    a05 = c05 + 3 * 2 ^ 179 - 3 * 2 ^ 179  c06 = c06 + a05
    a06 = c06 + 3 * 2 ^ 200 - 3 * 2 ^ 200  c07 = c07 + a06
    a07 = c07 + 3 * 2 ^ 221 - 3 * 2 ^ 221  c08 = c08 + a07
    a08 = c08 + 3 * 2 ^ 243 - 3 * 2 ^ 243  c09 = c09 + a08
    a09 = c09 + 3 * 2 ^ 264 - 3 * 2 ^ 264  c10 = c10 - a10 + a09
    a10 = c10 + 3 * 2 ^ 285 - 3 * 2 ^ 285  c11 = c11 - a11 + a10

    a11 = c11 + 3 * 2 ^ 306 - 3 * 2 ^ 306

    return {
        c00 - a00 + 19 / 2 ^ 255 * a11,
        c01 - a01,
        c02 - a02,
        c03 - a03,
        c04 - a04,
        c05 - a05,
        c06 - a06,
        c07 - a07,
        c08 - a08,
        c09 - a09,
        c10 - a10,
        c11 - a11,
    }
end

--- Multiplies an element by a number.
--- @param a FpR2
--- @param k number A number in [0..2²²).
--- @return FpR1 c An element such that c ≡ a × k (mod p).
local function kmul(a, k)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11 = unpack(a)
    local c00, c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11

    -- TODO Range check.
    a00 = a00 * k
    a01 = a01 * k
    a02 = a02 * k
    a03 = a03 * k
    a04 = a04 * k
    a05 = a05 * k
    a06 = a06 * k
    a07 = a07 * k
    a08 = a08 * k
    a09 = a09 * k
    a10 = a10 * k
    a11 = a11 * k

    c11 = a11 + 3 * 2 ^ 306 - 3 * 2 ^ 306  a00 = a00 + 19 / 2 ^ 255 * c11

    c00 = a00 + 3 * 2 ^ 73  - 3 * 2 ^ 73   a01 = a01 + c00
    c01 = a01 + 3 * 2 ^ 94  - 3 * 2 ^ 94   a02 = a02 + c01
    c02 = a02 + 3 * 2 ^ 115 - 3 * 2 ^ 115  a03 = a03 + c02
    c03 = a03 + 3 * 2 ^ 136 - 3 * 2 ^ 136  a04 = a04 + c03
    c04 = a04 + 3 * 2 ^ 158 - 3 * 2 ^ 158  a05 = a05 + c04
    c05 = a05 + 3 * 2 ^ 179 - 3 * 2 ^ 179  a06 = a06 + c05
    c06 = a06 + 3 * 2 ^ 200 - 3 * 2 ^ 200  a07 = a07 + c06
    c07 = a07 + 3 * 2 ^ 221 - 3 * 2 ^ 221  a08 = a08 + c07
    c08 = a08 + 3 * 2 ^ 243 - 3 * 2 ^ 243  a09 = a09 + c08
    c09 = a09 + 3 * 2 ^ 264 - 3 * 2 ^ 264  a10 = a10 + c09
    c10 = a10 + 3 * 2 ^ 285 - 3 * 2 ^ 285  a11 = a11 - c11 + c10

    c11 = a11 + 3 * 2 ^ 306 - 3 * 2 ^ 306

    return {
        a00 - c00 + 19 / 2 ^ 255 * c11,
        a01 - c01,
        a02 - c02,
        a03 - c03,
        a04 - c04,
        a05 - c05,
        a06 - c06,
        a07 - c07,
        a08 - c08,
        a09 - c09,
        a10 - c10,
        a11 - c11
    }
end

--- Squares an element n times.
--- @param a FpR2
--- @param n number The number of times to square a.
--- @return FpR1 c A number c such that c ≡ a ^ 2 ^ n (mod p).
local function nsquare(a, n)
    for _ = 1, n do a = square(a) end
    return a
end

--- Computes the inverse of an element.
---
--- Performance: 11 multiplications and 252 squarings.
---
--- @param a FpR2
--- @return FpR1 c An element such that c ≡ a⁻¹ (mod p), or 0 if c doesn't exist.
local function invert(a)
    local a2 = square(a)
    local a9 = mul(a, nsquare(a2, 2))
    local a11 = mul(a9, a2)

    local x5 = mul(square(a11), a9)
    local x10 = mul(nsquare(x5, 5), x5)
    local x20 = mul(nsquare(x10, 10), x10)
    local x40 = mul(nsquare(x20, 20), x20)
    local x50 = mul(nsquare(x40, 10), x10)
    local x100 = mul(nsquare(x50, 50), x50)
    local x200 = mul(nsquare(x100, 100), x100)
    local x250 = mul(nsquare(x200, 50), x50)

    return mul(nsquare(x250, 5), a11)
end

--- Returns an element x that satisfies vx² = u.
---
--- Note that when v = 0, the returned element can take any value.
---
--- @param u FpR2
--- @param v FpR2
--- @return FpR1? x An element such that vx² ≡ u (mod p), if it exists.
local function sqrtDiv(u, v)
    u = carry(u)

    local v2 = square(v)
    local v3 = mul(v, v2)
    local v6 = square(v3)
    local v7 = mul(v, v6)
    local uv7 = mul(u, v7)

    local x2 = mul(square(uv7), uv7)
    local x4 = mul(nsquare(x2, 2), x2)
    local x8 = mul(nsquare(x4, 4), x4)
    local x16 = mul(nsquare(x8, 8), x8)
    local x18 = mul(nsquare(x16, 2), x2)
    local x32 = mul(nsquare(x16, 16), x16)
    local x50 = mul(nsquare(x32, 18), x18)
    local x100 = mul(nsquare(x50, 50), x50)
    local x200 = mul(nsquare(x100, 100), x100)
    local x250 = mul(nsquare(x200, 50), x50)
    local pr = mul(nsquare(x250, 2), uv7)

    local uv3 = mul(u, v3)
    local b = mul(uv3, pr)
    local b2 = square(b)
    local vb2 = mul(v, b2)

    if not eq(vb2, u) then
        -- Found sqrt(-u/v), multiply by i.
        b = mul(b, I)
        b2 = square(b)
        vb2 = mul(v, b2)
    end

    if eq(vb2, u) then
        return b
    else
        return nil
    end
end

--- @class String32: string A string with length equal to 32 bytes.

--- Encodes an element in little-endian.
--- @param a FpR1
--- @return String32 out The 32-byte canonical encoding of a.
local function encode(a)
    a = canonicalize(a)
    local a00, a01, a02, a03, a04, a05, a06, a07, a08, a09, a10, a11 = unpack(a)

    local bytes = {}
    local acc = a00

    local function putBytes(n)
        for _ = 1, n do
            local byte = acc % 256
            bytes[#bytes + 1] = byte
            acc = (acc - byte) / 256
        end
    end

    putBytes(2) acc = acc + a01 / 2 ^ 16
    putBytes(3) acc = acc + a02 / 2 ^ 40
    putBytes(3) acc = acc + a03 / 2 ^ 64
    putBytes(2) acc = acc + a04 / 2 ^ 80
    putBytes(3) acc = acc + a05 / 2 ^ 104
    putBytes(3) acc = acc + a06 / 2 ^ 128
    putBytes(2) acc = acc + a07 / 2 ^ 144
    putBytes(3) acc = acc + a08 / 2 ^ 168
    putBytes(3) acc = acc + a09 / 2 ^ 192
    putBytes(2) acc = acc + a10 / 2 ^ 208
    putBytes(3) acc = acc + a11 / 2 ^ 232
    putBytes(3)

    return string.char(unpack(bytes)) --[[@as String32, putBytes sums to 32]]
end

--- Decodes an element in little-endian.
--- @param b String32 A 32-byte string, the most-significant bit is discarded.
--- @return FpR1 out The decoded element. It may not be canonical.
local function decode(b)
    local w00, w01, w02, w03, w04, w05, w06, w07, w08, w09, w10, w11 =
        ufp(fmtfp, b, 1)

    w11 = w11 % 2 ^ 15

    return carry {
        w00,
        w01 * 2 ^ 24,
        w02 * 2 ^ 48,
        w03 * 2 ^ 64,
        w04 * 2 ^ 88,
        w05 * 2 ^ 112,
        w06 * 2 ^ 128,
        w07 * 2 ^ 152,
        w08 * 2 ^ 176,
        w09 * 2 ^ 192,
        w10 * 2 ^ 216,
        w11 * 2 ^ 240,
    }
end

--- Checks if the given element is equal to 0.
--- @param a FpR2
--- @return boolean eqz Whether a ≡ 0 (mod p).
local function eqz(a)
    local c = canonicalize(a)
    local c00, c01, c02, c03, c04, c05, c06, c07, c08, c09, c10, c11 = unpack(c)
    return c00 + c01 + c02 + c03 + c04 + c05 + c06 + c07 + c08 + c09 + c10 + c11
        == 0
end

return {
    num = num,
    neg = neg,
    add = add,
    sub = sub,
    kmul = kmul,
    mul = mul,
    canonicalize = canonicalize,
    square = square,
    carry = carry,
    invert = invert,
    sqrtDiv = sqrtDiv,
    encode = encode,
    decode = decode,
    eqz = eqz,
}

end,

["ccryptolib.internal.edwards25519"] = function()
--------------------
-- Module: 'ccryptolib.internal.edwards25519'
--------------------
--- Point arithmetic on the Edwards25519 Edwards curve.

local fp = require "ccryptolib.internal.fp"

local unpack = unpack or table.unpack

--- @class EdPoint A point on Edwards25519, in extended coordinates.
--- @field [1] number[] The X coordinate.
--- @field [2] number[] The Y coordinate.
--- @field [3] number[] The Z coordinate.
--- @field [4] number[] The T coordinate.

--- @class NsPoint A point on Edwards25519, in Niels' coordinates.
--- @field [1] number[] Preprocessed Y + X.
--- @field [2] number[] Preprocessed Y - X.
--- @field [3] number[] Preprocessed 2Z.
--- @field [4] number[] Preprocessed 2DT.

local D = fp.mul(fp.num(-121665), fp.invert(fp.num(121666)))
local K = fp.kmul(D, 2)

--- @type EdPoint
local O = {fp.num(0), fp.num(1), fp.num(1), fp.num(0)}
local G = nil

--- Doubles a point.
--- @param P1 EdPoint The point to double.
--- @return EdPoint P2 P1 + P1.
local function double(P1)
    -- Unsoundness: fp.sub(g, e), and fp.sub(d, i) break fp.sub's contract since
    -- it doesn't accept an fp2. Although not ideal, in practice this doesn't
    -- matter since fp.carry handles the larger sum.
    local P1x, P1y, P1z = unpack(P1)
    local a = fp.square(P1x)
    local b = fp.square(P1y)
    local c = fp.square(P1z)
    local d = fp.add(c, c)
    local e = fp.add(a, b)
    local f = fp.add(P1x, P1y)
    local g = fp.square(f)
    local h = fp.carry(fp.sub(g, e))
    local i = fp.sub(b, a)
    local j = fp.carry(fp.sub(d, i))
    local P3x = fp.mul(h, j)
    local P3y = fp.mul(i, e)
    local P3z = fp.mul(j, i)
    local P3t = fp.mul(h, e)
    return {P3x, P3y, P3z, P3t}
end

--- Adds two points.
--- @param P1 EdPoint The first summand point.
--- @param N2 NsPoint The second summand point.
--- @return EdPoint P3 P1 + P2, where N2 = niels(P2).
local function add(P1, N2)
    local P1x, P1y, P1z, P1t = unpack(P1)
    local N1p, N1m, N1z, N1t = unpack(N2)
    local a = fp.sub(P1y, P1x)
    local b = fp.mul(a, N1m)
    local c = fp.add(P1y, P1x)
    local d = fp.mul(c, N1p)
    local e = fp.mul(P1t, N1t)
    local f = fp.mul(P1z, N1z)
    local g = fp.sub(d, b)
    local h = fp.sub(f, e)
    local i = fp.add(f, e)
    local j = fp.add(d, b)
    local P3x = fp.mul(g, h)
    local P3y = fp.mul(i, j)
    local P3z = fp.mul(h, i)
    local P3t = fp.mul(g, j)
    return {P3x, P3y, P3z, P3t}
end

--- Subtracts one point from another.
--- @param P1 EdPoint The first summand point.
--- @param N2 NsPoint The second summand point.
--- @return EdPoint P3 P1 - P2, where N2 = niels(P2).
local function sub(P1, N2)
    local P1x, P1y, P1z, P1t = unpack(P1)
    local N1p, N1m, N1z, N1t = unpack(N2)
    local a = fp.sub(P1y, P1x)
    local b = fp.mul(a, N1p)
    local c = fp.add(P1y, P1x)
    local d = fp.mul(c, N1m)
    local e = fp.mul(P1t, N1t)
    local f = fp.mul(P1z, N1z)
    local g = fp.sub(d, b)
    local h = fp.add(f, e)
    local i = fp.sub(f, e)
    local j = fp.add(d, b)
    local P3x = fp.mul(g, h)
    local P3y = fp.mul(i, j)
    local P3z = fp.mul(h, i)
    local P3t = fp.mul(g, j)
    return {P3x, P3y, P3z, P3t}
end

--- Computes the Niels representation of a point.
--- @param P1 EdPoint The input point.
--- @return NsPoint N1 Niels' precomputation applied to P1.
local function niels(P1)
    local P1x, P1y, P1z, P1t = unpack(P1)
    local N3p = fp.add(P1y, P1x)
    local N3m = fp.sub(P1y, P1x)
    local N3z = fp.add(P1z, P1z)
    local N3t = fp.mul(P1t, K)
    return {N3p, N3m, N3z, N3t}
end

--- Scales a point.
--- @param P1 EdPoint The input point.
--- @return EdPoint P2 The same point as P1, but with Z = 1.
local function scale(P1)
    local P1x, P1y, P1z = unpack(P1)
    local zInv = fp.invert(P1z)
    local P3x = fp.mul(P1x, zInv)
    local P3y = fp.mul(P1y, zInv)
    local P3z = fp.num(1)
    local P3t = fp.mul(P3x, P3y)
    return {P3x, P3y, P3z, P3t}
end

--- Encodes a scaled point.
--- @param P1 EdPoint The scaled point to encode.
--- @return string out P1 encoded as a 32-byte string.
local function encode(P1)
    P1 = scale(P1)
    local P1x, P1y = unpack(P1)
    local y = fp.encode(P1y)
    local xBit = fp.canonicalize(P1x)[1] % 2
    return y:sub(1, -2) .. string.char(y:byte(-1) + xBit * 128)
end

--- Decodes a point.
--- @param str String32 A 32-byte encoded point.
--- @return EdPoint? P1 The decoded point, or nil if it isn't on the curve.
local function decode(str)
    local P3y = fp.decode(str)
    local a = fp.square(P3y)
    local b = fp.sub(a, fp.num(1))
    local c = fp.mul(a, D)
    local d = fp.add(c, fp.num(1))
    local P3x = fp.sqrtDiv(b, d)
    if not P3x then return nil end
    local xBit = fp.canonicalize(P3x)[1] % 2
    if xBit ~= bit32.extract(str:byte(-1), 7) then
        P3x = fp.carry(fp.neg(P3x))
    end
    local P3z = fp.num(1)
    local P3t = fp.mul(P3x, P3y)
    return {P3x, P3y, P3z, P3t}
end

G = decode("Xfffffffffffffffffffffffffffffff") --[[@as EdPoint, G is valid]]

--- Transforms little-endian bits into a signed radix-2^w form.
--- @param bits number[]
--- @param w number Log2 of the radix, must be at least 1.
--- @return number[]
local function signedRadixW(bits, w)
    -- TODO Find a more elegant way of doing this.
    local wPow = 2 ^ w
    local wPowh = wPow / 2
    local out = {}
    local acc = 0
    local mul = 1
    for i = 1, #bits do
        acc = acc + bits[i] * mul
        mul = mul * 2
        while i == #bits and acc > 0 or mul > wPow do
            local rem = acc % wPow
            if rem >= wPowh then rem = rem - wPow end
            acc = (acc - rem) / wPow
            mul = mul / wPow
            out[#out + 1] = rem
        end
    end
    return out
end

--- Computes a multiplication table for radix-2^w form multiplication.
--- @param P EdPoint The base point.
--- @param w number Log2 of the radix, must be at least 1.
--- @return NsPoint[][]
local function radixWTable(P, w)
    local out = {}
    for i = 1, math.ceil(256 / w) do
        local row = {niels(P)}
        for j = 2, 2 ^ w / 2 do
            P = add(P, row[1])
            row[j] = niels(P)
        end
        out[i] = row
        P = double(P)
    end
    return out
end

--- The radix logarithm of the precomputed table for G.
local G_W = 5

--- The precomputed multiplication table for G.
local G_TABLE = radixWTable(G, G_W)

--- Transforms little-endian bits into a signed radix-2^w non-adjacent form.
---
--- The returned array contains a 0 whenever a single doubling is needed, or an
--- odd integer when an addition with a multiple of the base is needed.
---
--- @param bits number[]
--- @param w number Log2 of the radix, must be at least 1.
--- @return number[]
local function wNaf(bits, w)
    -- TODO Find a more elegant way of doing this.
    local wPow = 2 ^ w
    local wPowh = wPow / 2
    local out = {}
    local acc = 0
    local mul = 1
    for i = 1, #bits do
        acc = acc + bits[i] * mul
        mul = mul * 2
        while i == #bits and acc > 0 or mul > wPow do
            if acc % 2 == 0 then
                acc = acc / 2
                mul = mul / 2
                out[#out + 1] = 0
            else
                local rem = acc % wPow
                if rem >= wPowh then rem = rem - wPow end
                acc = acc - rem
                out[#out + 1] = rem
            end
        end
    end
    while out[#out] == 0 do out[#out] = nil end
    return out
end

--- Computes a multiplication table for wNAF form multiplication.
--- @param P EdPoint The base point.
--- @param w number Log2 of the radix, must be at least 1.
--- @return NsPoint[]
local function WNAFTable(P, w)
    local dP = double(P)
    local out = {niels(P)}
    for i = 3, 2 ^ w, 2 do
        out[i] = niels(add(dP, out[i - 2]))
    end
    return out
end

--- Performs a scalar multiplication by the base point G.
--- @param bits number[] The scalar multiplicand little-endian bits.
--- @return EdPoint
local function mulG(bits)
    local sw = signedRadixW(bits, G_W)
    local R = O
    for i = 1, #sw do
        local b = sw[i]
        if b > 0 then
            R = add(R, G_TABLE[i][b])
        elseif b < 0 then
            R = sub(R, G_TABLE[i][-b])
        end
    end
    return R
end

--- Performs a scalar multiplication operation.
--- @param P EdPoint The base point.
--- @param bits number[] The scalar multiplicand little-endian bits.
--- @return EdPoint
local function mul(P, bits)
    local naf = wNaf(bits, 5)
    local tbl = WNAFTable(P, 5)
    local R = O
    for i = #naf, 1, -1 do
        local b = naf[i]
        if b == 0 then
            R = double(R)
        elseif b > 0 then
            R = add(R, tbl[b])
        else
            R = sub(R, tbl[-b])
        end
    end
    return R
end

return {
    double = double,
    add = add,
    sub = sub,
    niels = niels,
    scale = scale,
    encode = encode,
    decode = decode,
    mulG = mulG,
    mul = mul,
}

end,

["ccryptolib.internal.curve25519"] = function()
--------------------
-- Module: 'ccryptolib.internal.curve25519'
--------------------
--- Point arithmetic on the Curve25519 Montgomery curve.

local fp = require "ccryptolib.internal.fp"
local ed = require "ccryptolib.internal.edwards25519"
local random = require "ccryptolib.random"

--- @class MtPoint A point class on Curve25519, in XZ coordinates.
--- @field [1] number[] The X coordinate.
--- @field [2] number[] The Z coordinate.

--- Doubles a point.
--- @param P1 MtPoint The point to double.
--- @return MtPoint P2 P1 + P1.
local function double(P1)
    local x1, z1 = P1[1], P1[2]
    local a = fp.add(x1, z1)
    local aa = fp.square(a)
    local b = fp.sub(x1, z1)
    local bb = fp.square(b)
    local c = fp.sub(aa, bb)
    local x3 = fp.mul(aa, bb)
    local z3 = fp.mul(c, fp.add(bb, fp.kmul(c, 121666)))
    return {x3, z3}
end

--- Computes differential addition on two points.
--- @param DP MtPoint P1 - P2.
--- @param P1 MtPoint The first point to add.
--- @param P2 MtPoint The second point to add.
--- @return MtPoint P3 P1 + P2.
local function dadd(DP, P1, P2)
    local dx, dz = DP[1], DP[2]
    local x1, z1 = P1[1], P1[2]
    local x2, z2 = P2[1], P2[2]
    local a = fp.add(x1, z1)
    local b = fp.sub(x1, z1)
    local c = fp.add(x2, z2)
    local d = fp.sub(x2, z2)
    local da = fp.mul(d, a)
    local cb = fp.mul(c, b)
    local x3 = fp.mul(dz, fp.square(fp.add(da, cb)))
    local z3 = fp.mul(dx, fp.square(fp.sub(da, cb)))
    return {x3, z3}
end

--- Performs a step on the Montgomery ladder.
--- @param DP MtPoint P1 - P2.
--- @param P1 MtPoint The first point.
--- @param P2 MtPoint The second point.
--- @return MtPoint P3 2A
--- @return MtPoint P4 A + B
local function step(DP, P1, P2)
    local dx, dz = DP[1], DP[2]
    local x1, z1 = P1[1], P1[2]
    local x2, z2 = P2[1], P2[2]
    local a = fp.add(x1, z1)
    local aa = fp.square(a)
    local b = fp.sub(x1, z1)
    local bb = fp.square(b)
    local e = fp.sub(aa, bb)
    local c = fp.add(x2, z2)
    local d = fp.sub(x2, z2)
    local da = fp.mul(d, a)
    local cb = fp.mul(c, b)
    local x4 = fp.mul(dz, fp.square(fp.add(da, cb)))
    local z4 = fp.mul(dx, fp.square(fp.sub(da, cb)))
    local x3 = fp.mul(aa, bb)
    local z3 = fp.mul(e, fp.add(bb, fp.kmul(e, 121666)))
    return {x3, z3}, {x4, z4}
end

local function ladder(DP, bits)
    local P = {fp.num(1), fp.num(0)}
    local Q = DP

    for i = #bits, 1, -1 do
        if bits[i] == 0 then
            P, Q = step(DP, P, Q)
        else
            Q, P = step(DP, Q, P)
        end
    end

    return P
end

--- Performs a scalar multiplication operation with multiplication by 8.
--- @param P MtPoint The base point.
--- @param bits number[] The scalar multiplier, in little-endian bits.
--- @return MtPoint product The product, multiplied by 8.
local function ladder8(P, bits)
    -- Randomize.
    local rf = fp.decode(random.random(32) --[[@as String32, length is given]])
    P = {fp.mul(P[1], rf), fp.mul(P[2], rf)}

    -- Multiply.
    return double(double(double(ladder(P, bits))))
end

--- Scales a point's coordinates.
--- @param P MtPoint The input point.
--- @return MtPoint Q The same point P, but with Z = 1.
local function scale(P)
    return {fp.mul(P[1], fp.invert(P[2])), fp.num(1)}
end

--- Encodes a scaled point.
--- @param P MtPoint The scaled point to encode.
--- @return string encoded P, encoded into a 32-byte string.
local function encode(P)
    return fp.encode(P[1])
end

--- Decodes a point.
--- @param str String32 A 32-byte encoded point.
--- @return MtPoint pt The decoded point.
local function decode(str)
    return {fp.decode(str), fp.num(1)}
end

--- Decodes an Edwards25519 encoded point into Curve25519, ignoring the sign.
---
--- There is a single exception: The identity point (0, 1), which gets mapped
--- into the 2-torsion point (0, 0), which isn't the identity of Curve25519.
---
--- @param str String32 A 32-byte encoded Edwards25519 point.
--- @return MtPoint pt The decoded point, mapped into Curve25519.
local function decodeEd(str)
    local y = fp.decode(str)
    local n = fp.carry(fp.add(fp.num(1), y))
    local d = fp.carry(fp.sub(fp.num(1), y))
    if fp.eqz(d) then
        return {fp.num(0), fp.num(1)}
    else
        return {n, d}
    end
end

--- Performs a scalar multiplication by the base point G.
--- @param bits number[] The scalar multiplier, in little-endian bits.
--- @return MtPoint product The product point.
local function mulG(bits)
    -- Multiply by G on Edwards25519.
    local P = ed.mulG(bits)

    -- Use the birational map to get the point on Curve25519.
    -- Never fails since G is in the large group, and the exponent is clamped.
    local Py, Pz = P[2], P[3]
    local Rx = fp.carry(fp.add(Py, Pz))
    local Rz = fp.carry(fp.sub(Pz, Py))

    return {Rx, Rz}
end

--- Computes a twofold product from a ruleset.
---
--- Returns nil if any of the results would be equal to the identity.
---
--- @param P MtPoint The base point.
--- @param ruleset __TYPE_TODO The ruleset generated by scalars m, n.
--- @return MtPoint? A [8m]P.
--- @return MtPoint? B [8n]P.
--- @return MtPoint? C [8m]P - [8n]P.
local function prac(P, ruleset)
    -- Randomize.
    local rf = fp.decode(random.random(32) --[[@as String32, length is given]])
    local A = {fp.mul(P[1], rf), fp.mul(P[2], rf)}

    -- Start the base at [8]P.
    local A = double(double(double(A)))

    -- Throw away small order points.
    if fp.eqz(A[2]) then return end

    -- Now e = d = gcd(m, n).
    -- Update A from [8]P to [8 * gcd(m, n)]P.
    A = ladder(A, ruleset[1])

    -- Reject rulesets where m = n.
    local rules = ruleset[2]
    if #rules == 0 then return end

    -- Evaluate the first rule.
    -- Since e = d, this means A - B = C = O. Differential addition fails when
    -- C = O, so we need to treat this case specially.
    -- Note that rules 0 and 1 never happen last, since the algorithm would stop
    -- one step earlier if they did:
    -- - If after rule 0 we had e = d, then (d, e) → (e, d) would also mean that
    --   e = d, so it stops one step earlier.
    -- - If after rule 1 we had e = d, then (d, e) → ((2d - e)/3, (2e - d)/3)
    --   would mean that (2d - e)/3 = (2e - d)/3, thus 2d - e = 2e - d, thus
    --   3d = 3e, thus d = e, so it stops one step earlier.
    local B, C
    local rule = rules[#rules]
    if rule == 2 then
        -- (A, B, C) ← (2A + B, B, 2A) = (3A, A, 2A)
        local A2 = double(A)
        A, B, C = dadd(A, A2, A), A, A2
    elseif rule == 3 or rule == 5 then
        -- (A, B, C) ← (A + B, B, A) = (2A, A, A)
        -- or (A, B, C) ← (2A, B, 2A - B) = (2A, A, A)
        A, B, C = double(A), A, A
    elseif rule == 6 then
        -- (A, B, C) ← (3A + 3B, B, 3A + 2B) = (6A, A, 5A)
        local A2 = double(A)
        local A3 = dadd(A, A2, A)
        A, B, C = double(A3), A, dadd(A, A3, A2)
    elseif rule == 7 then
        -- (A, B, C) ← (3A + 2B, B, 3A + B) = (5A, A, 4A)
        local A2 = double(A)
        local A3 = dadd(A, A2, A)
        local A4 = double(A2)
        A, B, C = dadd(A3, A4, A), A, A4
    elseif rule == 8 then
        -- (A, B, C) ← (3A + B, B, 3A) = (4A, A, 3A)
        local A2 = double(A)
        local A3 = dadd(A, A2, A)
        A, B, C = double(A2), A, A3
    else
        -- (A, B, C) ← (A, 2B, A - 2B) = (A, 2A, A)
        A, B, C = A, double(A), A
    end

    -- Evaluate the other rules.
    -- Let's assume addition is undefined here, this happens when A - B = O.
    -- Since A = [d]P and B = [e]P, A = B happens when:
    -- (1) P is on the large order base group and d ≡ e (mod q).
    -- (2) P is on the large order twist group and d ≡ e (mod q').
    -- (3) P is on a small order group.
    -- Case (3) never happens since we throw small order points away above.
    -- Since 0 ≤ {d, e} < q < q', a modular equivalence here means an integer
    -- equivalence. Therefore d = e.
    -- However, the ruleset stops when d = e, therefore the algorithm must have
    -- stopped earlier than when it did. Contradiction.
    -- Therefore, addition is always defined.
    -- Furthermore, the PRAC invariants mean that this product is the same as
    -- if the points were multiplied separately.
    for i = #rules - 1, 1, -1 do
        local rule = rules[i]
        if rule == 0 then
            -- (A, B, C) ← (B, A, B - A)
            A, B = B, A
        elseif rule == 1 then
            -- (A, B, C) ← (2A + B, A + 2B, A - B)
            local AB = dadd(C, A, B)
            A, B = dadd(B, AB, A), dadd(A, AB, B)
        elseif rule == 2 then
            -- (A, B, C) ← (2A + B, B, 2A)
            A, C = dadd(B, dadd(C, A, B), A), double(A)
        elseif rule == 3 then
            -- (A, B, C) ← (A + B, B, A)
            A, C = dadd(C, A, B), A
        elseif rule == 5 then
            -- (A, B, C) ← (2A, B, 2A - B)
            A, C = double(A), dadd(B, A, C)
        elseif rule == 6 then
            -- (A, B, C) ← (3A + 3B, B, 3A + 2B)
            local AB = dadd(C, A, B)
            local AABB = double(AB)
            A, C = dadd(AB, AABB, AB), dadd(dadd(A, AB, B), AABB, A)
        elseif rule == 7 then
            -- (A, B, C) ← (3A + 2B, B, 3A + B)
            local AB = dadd(C, A, B)
            local AAB = dadd(B, AB, A)
            A, C = dadd(A, AAB, AB), dadd(AB, AAB, A)
        elseif rule == 8 then
            -- (A, B, C) ← (3A + B, B, 3A)
            local AA = double(A)
            A, C = dadd(C, AA, dadd(C, A, B)), dadd(A, AA, A)
        else
            -- (A, B, C) ← (A, 2B, A - 2B)
            B, C = double(B), dadd(A, C, B)
        end
    end

    return A, B, C
end

return {
    G = {fp.num(9), fp.num(1)},
    dadd = dadd,
    scale = scale,
    encode = encode,
    decode = decode,
    decodeEd = decodeEd,
    ladder8 = ladder8,
    mulG = mulG,
    prac = prac,
}

end,

["ccryptolib.internal.sha512"] = function()
--------------------
-- Module: 'ccryptolib.internal.sha512'
--------------------
--- The SHA512 cryptographic hash function.

local expect  = require "cc.expect".expect
local packing = require "ccryptolib.internal.packing"

local shl = bit32.lshift
local shr = bit32.rshift
local bxor = bit32.bxor
local bnot = bit32.bnot
local band = bit32.band
local p1x16, fmt1x16 = packing.compilePack(">I16")
local p16x4, fmt16x4 = packing.compilePack(">I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4")
local u32x4, fmt32x4 = packing.compileUnpack(">I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4")

local function carry64(a1, a0)
    local r0 = a0 % 2 ^ 32
    a1 = a1 + (a0 - r0) / 2 ^ 32
    return a1 % 2 ^ 32, r0
end

local K = {
    0x428a2f98, 0xd728ae22, 0x71374491, 0x23ef65cd, 0xb5c0fbcf, 0xec4d3b2f,
    0xe9b5dba5, 0x8189dbbc, 0x3956c25b, 0xf348b538, 0x59f111f1, 0xb605d019,
    0x923f82a4, 0xaf194f9b, 0xab1c5ed5, 0xda6d8118, 0xd807aa98, 0xa3030242,
    0x12835b01, 0x45706fbe, 0x243185be, 0x4ee4b28c, 0x550c7dc3, 0xd5ffb4e2,
    0x72be5d74, 0xf27b896f, 0x80deb1fe, 0x3b1696b1, 0x9bdc06a7, 0x25c71235,
    0xc19bf174, 0xcf692694, 0xe49b69c1, 0x9ef14ad2, 0xefbe4786, 0x384f25e3,
    0x0fc19dc6, 0x8b8cd5b5, 0x240ca1cc, 0x77ac9c65, 0x2de92c6f, 0x592b0275,
    0x4a7484aa, 0x6ea6e483, 0x5cb0a9dc, 0xbd41fbd4, 0x76f988da, 0x831153b5,
    0x983e5152, 0xee66dfab, 0xa831c66d, 0x2db43210, 0xb00327c8, 0x98fb213f,
    0xbf597fc7, 0xbeef0ee4, 0xc6e00bf3, 0x3da88fc2, 0xd5a79147, 0x930aa725,
    0x06ca6351, 0xe003826f, 0x14292967, 0x0a0e6e70, 0x27b70a85, 0x46d22ffc,
    0x2e1b2138, 0x5c26c926, 0x4d2c6dfc, 0x5ac42aed, 0x53380d13, 0x9d95b3df,
    0x650a7354, 0x8baf63de, 0x766a0abb, 0x3c77b2a8, 0x81c2c92e, 0x47edaee6,
    0x92722c85, 0x1482353b, 0xa2bfe8a1, 0x4cf10364, 0xa81a664b, 0xbc423001,
    0xc24b8b70, 0xd0f89791, 0xc76c51a3, 0x0654be30, 0xd192e819, 0xd6ef5218,
    0xd6990624, 0x5565a910, 0xf40e3585, 0x5771202a, 0x106aa070, 0x32bbd1b8,
    0x19a4c116, 0xb8d2d0c8, 0x1e376c08, 0x5141ab53, 0x2748774c, 0xdf8eeb99,
    0x34b0bcb5, 0xe19b48a8, 0x391c0cb3, 0xc5c95a63, 0x4ed8aa4a, 0xe3418acb,
    0x5b9cca4f, 0x7763e373, 0x682e6ff3, 0xd6b2b8a3, 0x748f82ee, 0x5defb2fc,
    0x78a5636f, 0x43172f60, 0x84c87814, 0xa1f0ab72, 0x8cc70208, 0x1a6439ec,
    0x90befffa, 0x23631e28, 0xa4506ceb, 0xde82bde9, 0xbef9a3f7, 0xb2c67915,
    0xc67178f2, 0xe372532b, 0xca273ece, 0xea26619c, 0xd186b8c7, 0x21c0c207,
    0xeada7dd6, 0xcde0eb1e, 0xf57d4f7f, 0xee6ed178, 0x06f067aa, 0x72176fba,
    0x0a637dc5, 0xa2c898a6, 0x113f9804, 0xbef90dae, 0x1b710b35, 0x131c471b,
    0x28db77f5, 0x23047d84, 0x32caab7b, 0x40c72493, 0x3c9ebe0a, 0x15c9bebc,
    0x431d67c4, 0x9c100d4c, 0x4cc5d4be, 0xcb3e42b6, 0x597f299c, 0xfc657e2a,
    0x5fcb6fab, 0x3ad6faec, 0x6c44198c, 0x4a475817,
}

--- Hashes data bytes using SHA512.
--- @param data string The input data.
--- @return string hash The 64-byte hash value.
local function digest(data)
    expect(1, data, "string")

    -- Pad input.
    local bitlen = #data * 8
    local padlen = -(#data + 17) % 128
    data = data .. "\x80" .. ("\0"):rep(padlen) .. p1x16(fmt1x16, bitlen)

    -- Initialize state.
    local h01, h00 = 0x6a09e667, 0xf3bcc908
    local h11, h10 = 0xbb67ae85, 0x84caa73b
    local h21, h20 = 0x3c6ef372, 0xfe94f82b
    local h31, h30 = 0xa54ff53a, 0x5f1d36f1
    local h41, h40 = 0x510e527f, 0xade682d1
    local h51, h50 = 0x9b05688c, 0x2b3e6c1f
    local h61, h60 = 0x1f83d9ab, 0xfb41bd6b
    local h71, h70 = 0x5be0cd19, 0x137e2179

    -- Digest.
    for i = 1, #data, 128 do
        local w = {u32x4(fmt32x4, data, i)}

        -- Message schedule.
        for j = 33, 160, 2 do
            local wf1, wf0 = w[j - 30], w[j - 29]
            local t1 = shr(wf1, 1) + shl(wf0, 31)
            local t0 = shr(wf0, 1) + shl(wf1, 31)
            local u1 = shr(wf1, 8) + shl(wf0, 24)
            local u0 = shr(wf0, 8) + shl(wf1, 24)
            local v1 = shr(wf1, 7)
            local v0 = shr(wf0, 7) + shl(wf1, 25)

            local w21, w20 = w[j - 4], w[j - 3]
            local w1 = shr(w21, 19) + shl(w20, 13)
            local w0 = shr(w20, 19) + shl(w21, 13)
            local x0 = shr(w21, 29) + shl(w20, 3)
            local x1 = shr(w20, 29) + shl(w21, 3)
            local y1 = shr(w21, 6)
            local y0 = shr(w20, 6) + shl(w21, 26)

            local r1, r0 =
                w[j - 32] + bxor(t1, u1, v1) + w[j - 14] + bxor(w1, x1, y1),
                w[j - 31] + bxor(t0, u0, v0) + w[j - 13] + bxor(w0, x0, y0)

            w[j], w[j + 1] = carry64(r1, r0)
        end

        -- Block function.
        local a1, a0 = h01, h00
        local b1, b0 = h11, h10
        local c1, c0 = h21, h20
        local d1, d0 = h31, h30
        local e1, e0 = h41, h40
        local f1, f0 = h51, h50
        local g1, g0 = h61, h60
        local h1, h0 = h71, h70
        for j = 1, 160, 2 do
            local t1 = shr(e1, 14) + shl(e0, 18)
            local t0 = shr(e0, 14) + shl(e1, 18)
            local u1 = shr(e1, 18) + shl(e0, 14)
            local u0 = shr(e0, 18) + shl(e1, 14)
            local v0 = shr(e1, 9) + shl(e0, 23)
            local v1 = shr(e0, 9) + shl(e1, 23)
            local s11 = bxor(t1, u1, v1)
            local s10 = bxor(t0, u0, v0)

            local ch1 = bxor(band(e1, f1), band(bnot(e1), g1))
            local ch0 = bxor(band(e0, f0), band(bnot(e0), g0))

            local temp11 = h1 + s11 + ch1 + K[j] + w[j]
            local temp10 = h0 + s10 + ch0 + K[j + 1] + w[j + 1]

            local w1 = shr(a1, 28) + shl(a0, 4)
            local w0 = shr(a0, 28) + shl(a1, 4)
            local x0 = shr(a1, 2) + shl(a0, 30)
            local x1 = shr(a0, 2) + shl(a1, 30)
            local y0 = shr(a1, 7) + shl(a0, 25)
            local y1 = shr(a0, 7) + shl(a1, 25)
            local s01 = bxor(w1, x1, y1)
            local s00 = bxor(w0, x0, y0)

            local maj1 = bxor(band(a1, b1), band(a1, c1), band(b1, c1))
            local maj0 = bxor(band(a0, b0), band(a0, c0), band(b0, c0))

            local temp21 = s01 + maj1
            local temp20 = s00 + maj0

            h1 = g1  h0 = g0
            g1 = f1  g0 = f0
            f1 = e1  f0 = e0
            e1, e0 = carry64(d1 + temp11, d0 + temp10)
            d1 = c1  d0 = c0
            c1 = b1  c0 = b0
            b1 = a1  b0 = a0
            a1, a0 = carry64(temp11 + temp21, temp10 + temp20)
        end

        h01, h00 = carry64(h01 + a1, h00 + a0)
        h11, h10 = carry64(h11 + b1, h10 + b0)
        h21, h20 = carry64(h21 + c1, h20 + c0)
        h31, h30 = carry64(h31 + d1, h30 + d0)
        h41, h40 = carry64(h41 + e1, h40 + e0)
        h51, h50 = carry64(h51 + f1, h50 + f0)
        h61, h60 = carry64(h61 + g1, h60 + g0)
        h71, h70 = carry64(h71 + h1, h70 + h0)
    end

    return p16x4(fmt16x4,
        h01, h00, h11, h10, h21, h20, h31, h30,
        h41, h40, h51, h50, h61, h60, h71, h70
    )
end

return {
    digest = digest,
}

end,

["ccryptolib.x25519c"] = function()
--------------------
-- Module: 'ccryptolib.x25519c'
--------------------
local expect = require "cc.expect".expect
local lassert = require "ccryptolib.internal.util".lassert
local fq     = require "ccryptolib.internal.fq"
local fp     = require "ccryptolib.internal.fp"
local c25    = require "ccryptolib.internal.curve25519"
local sha512 = require "ccryptolib.internal.sha512"
local random = require "ccryptolib.random"

--- Masks an exchange secret key.
--- @param sk string A random 32-byte Curve25519 secret key.
--- @return string msk A masked secret key.
local function mask(sk)
    expect(1, sk, "string")
    lassert(#sk == 32, "secret key length must be 32", 2)
    local mask = random.random(32)
    local x = fq.decodeClamped(sk)
    local r = fq.decodeClamped(mask)
    local xr = fq.sub(x, r)
    return fq.encode(xr) .. mask
end

--- Masks a signature secret key.
--- @param sk string A random 32-byte Edwards25519 secret key.
--- @return string msk A masked secret key.
local function maskS(sk)
    expect(1, sk, "string")
    lassert(#sk == 32, "secret key length must be 32", 2)
    return mask(sha512.digest(sk):sub(1, 32))
end

--- Rerandomizes the masking on a masked key.
--- @param msk string A masked secret key.
--- @return string msk The same secret key, but with another mask.
local function remask(msk)
    expect(1, msk, "string")
    lassert(#msk == 64, "masked secret key length must be 64", 2)
    local newMask = random.random(32)
    local xr = fq.decode(msk:sub(1, 32))
    local r = fq.decodeClamped(msk:sub(33))
    local s = fq.decodeClamped(newMask)
    local xs = fq.add(xr, fq.sub(r, s))
    return fq.encode(xs) .. newMask
end

--- Returns the ephemeral exchange secret key of this masked key.
--- This is the second secret key in the "double key exchange" in @{exchange},
--- the first being the key that has been masked. The ephemeral key changes
--- every time @{remask} is called.
--- @param msk string A masked secret key.
--- @return string esk The ephemeral half of the masked secret key.
local function ephemeralSk(msk)
    expect(1, msk, "string")
    lassert(#msk == 64, "masked secret key length must be 64", 2)
    return msk:sub(33)
end

local function exchangeOnPoint(sk, P)
    local xr = fq.decode(sk:sub(1, 32))
    local r = fq.decodeClamped(sk:sub(33))
    local rP, xrP, dP = c25.prac(P, fq.makeRuleset(fq.eighth(r), fq.eighth(xr)))

    -- Return early if P has small order or if r = xr. (1)
    if not rP then
        local out = fp.encode(fp.num(0))
        return out, out
    end

    local xP = c25.dadd(dP, rP, xrP)

    -- Extract coordinates for scaling.
    local Px, Pz = P[1], P[2]
    local xPx, xPz = xP[1], xP[2]
    local rPx, rPz = rP[1], rP[2]

    -- Ensure all Z coordinates are squares.
    Px, Pz = fp.mul(Px, Pz), fp.square(Pz)
    xPx, xPz = fp.mul(xPx, xPz), fp.square(xPz)
    rPx, rPz = fp.mul(rPx, rPz), fp.square(rPz)

    -- We're splitting the secret x into (x - r (mod q), r). The multiplication
    -- adds them back together, but this only works if P's order is q, which is
    -- not the case on the twist.
    -- As a result, we need to check if P is on the twist and return 0 so as to
    -- not leak part of x. We do this by checking the curve equation against P.
    -- The projective equation for curve25519 is Y²Z = X(X² + AXZ + Z²). Since Z
    -- is a square, checking validity means checking the right-hand side to be a
    -- square.
    local Px2 = fp.square(Px)
    local Pz2 = fp.square(Pz)
    local Pxz = fp.mul(Px, Pz)
    local APxz = fp.kmul(Pxz, 486662)
    local rhs = fp.mul(Px, fp.add(Px2, fp.carry(fp.add(APxz, Pz2))))

    -- Find the square root of 1 / (rhs * xPz * rPz).
    -- Neither rPz, xPz, nor rhs are 0:
    -- - If rhs was 0, then P would be low order, which would return at (1).
    -- - Since P isn't low order, clamping prevents the ladder from returning O.
    -- Since we've just squared both xPz and rPz, the root will exist iff rhs is
    -- a square. This checks the curve equation, so we're done.
    local root = fp.sqrtDiv(fp.num(1), fp.mul(fp.mul(xPz, rPz), rhs))
    if not root then
        local out = fp.encode(fp.num(0))
        return out, out
    end

    -- Get the inverses of both Z values.
    local xPzrPzInv = fp.mul(fp.square(root), rhs)
    local xPzInv = fp.mul(xPzrPzInv, rPz)
    local rPzInv = fp.mul(xPzrPzInv, xPz)

    -- Finish scaling and encode the output.
    return fp.encode(fp.mul(xPx, xPzInv)), fp.encode(fp.mul(rPx, rPzInv))
end

--- Returns the X25519 public key of this masked key.
--- @param msk string A masked secret key.
local function publicKey(msk)
    expect(1, msk, "string")
    lassert(#msk == 64, "masked secret key length must be 64", 2)
    return (exchangeOnPoint(msk, c25.G))
end

--- Performs a double key exchange.
---
--- Returns 0 if the input public key has small order or if it isn't in the base
--- curve. This is different from standard X25519, which performs the exchange
--- even on the twist.
---
--- May incorrectly return 0 with negligible chance if the mask happens to match
--- the masked key. I haven't checked if clamping prevents that from happening.
---
--- @param sk string A masked secret key.
--- @param pk string An X25519 public key.
--- @return string sss The shared secret between the public key and the static half of the masked key.
--- @return string sse The shared secret betwen the public key and the ephemeral half of the masked key.
local function exchange(sk, pk)
    expect(1, sk, "string")
    lassert(#sk == 64, "masked secret key length must be 64", 2)
    expect(2, pk, "string")
    lassert(#pk == 32, "public key length must be 32", 2) --- @cast pk String32
    return exchangeOnPoint(sk, c25.decode(pk))
end

return {
    mask = mask,
    remask = remask,
    publicKey = publicKey,
    ephemeralSk = ephemeralSk,
    exchange = exchange,
}

end,

["ccryptolib.x25519"] = function()
--------------------
-- Module: 'ccryptolib.x25519'
--------------------
--- The X25519 key exchange scheme.

local expect = require "cc.expect".expect
local lassert = require "ccryptolib.internal.util".lassert
local util = require "ccryptolib.internal.util"
local c25 = require "ccryptolib.internal.curve25519"

--- Computes the public key from a secret key.
--- @param sk string A random 32-byte secret key.
--- @return string pk The matching public key.
local function publicKey(sk)
    expect(1, sk, "string")
    assert(#sk == 32, "secret key length must be 32")
    return c25.encode(c25.scale(c25.mulG(util.bits(sk))))
end

--- Performs the key exchange.
--- @param sk string A Curve25519 secret key.
--- @param pk string A public key, usually derived from someone else's secret key.
--- @return string ss The 32-byte shared secret between both keys.
local function exchange(sk, pk)
    expect(1, sk, "string")
    lassert(#sk == 32, "secret key length must be 32", 2)
    expect(2, pk, "string")
    lassert(#pk == 32, "public key length must be 32", 2) --- @cast pk String32
    return c25.encode(c25.scale(c25.ladder8(c25.decode(pk), util.bits8(sk))))
end

return {
    publicKey = publicKey,
    exchange = exchange,
}

end,

["ecnet2.SymmetricState"] = function()
--------------------
-- Module: 'ecnet2.SymmetricState'
--------------------
local class = require "ecnet2.class"
local blake3 = require "ccryptolib.blake3"
local CipherState = require "ecnet2.CipherState"

--- A symmetric state containing keys and a handshake transcript hash.
--- @class ecnet2.SymmetricState
--- @field private h string The current handshake transcript hash.
--- @field private ck string The current chaining key for deriving other keys.
--- @field private cs ecnet2.CipherState The current encryption CipherState.
local SymmetricState = class "ecnet2.SymmetricState"

-- We modify Noise so much that it's meaningless to use their naming standard.
local PROTOCOL_NAME = blake3.digest
    "ecnet2 2023-01-03 04:16 UTC network handshake protocol"

local DESCRIPTOR_KDF = blake3.deriveKey
    "ecnet2 2023-01-05 00:00 UTC handshake descriptor context"

function SymmetricState:initialise()
    self.h = PROTOCOL_NAME
    self.ck = PROTOCOL_NAME
    self.cs = CipherState(nil)
end

--- Mixes keying material into the key and the transcript hash.
--- @param material string
function SymmetricState:mixKeyAndHash(material)
    local tk = blake3.digestKeyed(self.ck, material, 96)
    self.ck = tk:sub(1, 32)
    self:mixHash(tk:sub(33, 64))
    self.cs = CipherState(tk:sub(65))
end

--- Mixes keying material into the key.
--- @param material string
function SymmetricState:mixKey(material)
    local tk = blake3.digestKeyed(self.ck, material, 64)
    self.ck = tk:sub(1, 32)
    self.cs = CipherState(tk:sub(33))
end

--- Mixes data into the transcript hash.
--- @param data string
--- @return string data The input data.
function SymmetricState:mixHash(data)
    self.h = blake3.digest(self.h .. data)
    return data
end

--- Returns the current transcript hash.
--- @return string hash The handshake transcript hash.
function SymmetricState:getHandshakeHash()
    return self.h
end

--- Encrypts data and adds it to the transcript.
--- @param plaintext string The plaintext to encrypt.
--- @return string ciphertext The encrypted plaintext 
function SymmetricState:encryptAndHash(plaintext)
    local ciphertext = self.cs:encryptWithAd(self.h, plaintext)
    return self:mixHash(ciphertext)
end

--- Adds data to the transcript and tries to decrypt it.
--- @param ciphertext string The ciphertext to decrypt.
--- @return string? plaintext The decrypted plaintext, or nil on failure.
function SymmetricState:decryptAndHash(ciphertext)
    local plaintext = self.cs:decryptWithAd(self.h, ciphertext)
    self:mixHash(ciphertext)
    return plaintext
end

--- Returns the current descriptor for the state.
--- @return string descriptor The descriptor.
function SymmetricState:descriptor()
    return DESCRIPTOR_KDF(self.ck .. self.h)
end

--- Splits the state into two cipher states, finishing the handshake.
--- @return ecnet2.CipherState, ecnet2.CipherState
function SymmetricState:split()
    local tk = blake3.digestKeyed(self.ck, "", 64)
    return CipherState(tk:sub(1, 32)), CipherState(tk:sub(33))
end

return SymmetricState

end,

["ecnet2.HandshakeState"] = function()
--------------------
-- Module: 'ecnet2.HandshakeState'
--------------------
local x25519c = require "ccryptolib.x25519c"
local x25519 = require "ccryptolib.x25519"
local SymmetricState = require "ecnet2.SymmetricState"

--- A handshake state.
--- @class ecnet2.HandshakeState
--- The other party's public key, if known.
--- @field pk string?
--- A descriptor to filter when receiving.
--- @field d string?
--- A function to call for resolving incoming messages. The argument shouldn't
--- include the descriptor. Returns the next state to use, and the decrypted
--- message or nil on failure.
--- @field resolve (fun(data: string): ecnet2.HandshakeState, string?)?
--- The largest length, in bytes, that send() will accept.
--- @field maxlen number
--- A function to call for sending messages. Returns the next state to use and
--- the raw data to send over the network.
--- @field send (fun(msg: string): ecnet2.HandshakeState, string?)?

--- Returns a dummy state that does nothing. Used for aborting handshakes.
--- @return ecnet2.HandshakeState
local function close()
    return {
        maxlen = math.huge,
        send = function()
            return close(), nil
        end,
    }
end

--- Pads a message to partially hide its length.
--- @param msg string The input message.
--- @param prefixlen number The size of a prefix that will be added afterwards.
--- @param minlen number The minimum length to pad the message into.
local function pad(msg, prefixlen, minlen)
    local l = math.max(#msg + prefixlen + 2, minlen)
    local e = math.floor(math.log(l, 2))
    local s = math.floor(math.log(e, 2)) + 1
    local w = l + -l % 2 ^ (e - s)
    local p = math.min(w, 2 ^ 16) - #msg - prefixlen - 2
    return msg .. "\x80" .. ("\0"):rep(p)
end

--- Unpads a padded message.
--- @param msg string? The padded message, or nil for failure propagation.
--- @return string? unpadded The unpadded message, or nil on failure.
local function unpad(msg)
    if not msg then return end
    for i = #msg, 1, -1 do
        local b = msg:byte(i)
        if b == 0 then
        elseif b == 0x80 then
            return msg:sub(1, i - 1)
        else
            return
        end
    end
end

--- Creates the transport state.
--- @param pk string The remote party's public key.
--- @param localCs ecnet2.CipherState The local party's cipher state.
--- @param remoteCs ecnet2.CipherState The remote party's cipher state.
--- @return ecnet2.HandshakeState
local function Transport(pk, localCs, remoteCs)
    local out = {}

    out.pk = pk
    out.d = localCs:descriptor()
    out.maxlen = 2 ^ 16 - 1 - 32 - 1 - 1 - 16

    function out.resolve(data)
        if #data < 16 then return close() end
        local m = unpad(localCs:decryptWithAd("", data))
        localCs:rekey()
        if not m then return close() end
        return Transport(pk, localCs, remoteCs), m
    end

    function out.send(msg)
        local d = remoteCs:descriptor()
        local ctx = remoteCs:encryptWithAd("", pad(msg, 32 + 16, 192))
        remoteCs:rekey()
        return Transport(pk, localCs, remoteCs), d .. ctx
    end

    return out
end

--- Creates the responder state for message C (-> s, se).
--- @param msk string The responder's masked secret key.
--- @param symmetricState ecnet2.SymmetricState The handshake's symmetric state.
--- @return ecnet2.HandshakeState
local function rC(msk, symmetricState)
    local out = {}

    out.d = symmetricState:descriptor()

    function out.resolve(data)
        if #data < 64 then return close() end

        local pk = symmetricState:decryptAndHash(data:sub(1, 48))
        if not pk then return close() end

        symmetricState:mixKey(x25519.exchange(x25519c.ephemeralSk(msk), pk))

        local xm = unpad(symmetricState:decryptAndHash(data:sub(49)))
        if not xm then return close() end
        local ok, m = pcall(string.unpack, "<s2", xm)
        if not ok then return close() end

        local iCs, rCs = symmetricState:split()
        return Transport(pk, rCs, iCs), m
    end

    return out
end

--- Creates the initiator state for message C (-> s, se).
--- @param iPk string The initiator's static public key.
--- @param rPk string The responder's static public key.
--- @param se string The static-ephemeral shared secret for this handshake.
--- @param symmetricState ecnet2.SymmetricState The handshake's symmetric state.
--- @return ecnet2.HandshakeState
local function iC(iPk, rPk, se, symmetricState)
    local out = {}

    out.maxlen = 2 ^ 15 - 1
    out.pk = rPk

    function out.send(msg)
        local d = symmetricState:descriptor()

        local pkCtx = symmetricState:encryptAndHash(iPk)

        symmetricState:mixKey(se)
        local xmsg = ("<s2"):pack(msg)
        local ctx = symmetricState:encryptAndHash(pad(xmsg, 32 + 48 + 16, 192))
        local iCs, rCs = symmetricState:split()
        return Transport(rPk, iCs, rCs), d .. pkCtx .. ctx
    end

    return out
end

--- Creates the initiator state for message B (<- e, ee)
--- @param msk string The initiator's masked secret key.
--- @param iPk string The initiator's static public key.
--- @param rPk string The responder's static public key.
--- @param symmetricState ecnet2.SymmetricState The handshake's symmetric state.
--- @return ecnet2.HandshakeState
local function iB(msk, iPk, rPk, symmetricState)
    local out = {}

    out.d = symmetricState:descriptor()

    function out.resolve(data)
        if #data < 64 then return close() end

        local e = symmetricState:decryptAndHash(data:sub(1, 48))
        if not e then return close() end

        local se, ee = x25519c.exchange(msk, e)
        symmetricState:mixKey(ee)

        local xm = unpad(symmetricState:decryptAndHash(data:sub(49)))
        if not xm then return close() end
        local ok, msg = pcall(string.unpack, "<s2", xm)
        if not ok then return close() end

        return iC(iPk, rPk, se, symmetricState), msg
    end

    return out
end

--- Creates the responder state for message B (<- e, ee).
--- @param msk string The responder's masked secret key.
--- @param ee string The ephemeral-ephemeral shared secret for this handshake.
--- @param symmetricState ecnet2.SymmetricState The handshake's symmetric state.
--- @return ecnet2.HandshakeState
local function rB(msk, ee, symmetricState)
    local out = {}

    out.maxlen = 2 ^ 15 - 1

    function out.send(msg)
        local d = symmetricState:descriptor()

        local e = x25519.publicKey(x25519c.ephemeralSk(msk))
        local eCtx = symmetricState:encryptAndHash(e)

        symmetricState:mixKey(ee)
        local xmsg = ("<s2"):pack(msg)
        local ctx = symmetricState:encryptAndHash(pad(xmsg, 32 + 48 + 16, 192))

        return rC(msk, symmetricState), d .. eCtx .. ctx
    end

    return out
end

--- Initializes a handshake as the responder, resolving message A (-> e, es).
--- @param msk string The responder's masked secret key.
--- @param rPk string The responder's static public key.
--- @param prologue string The handshake prologue.
--- @param introPsk string A pre-shared key resolved in the introduction.
--- @param data string The incoming network message, without the intro prefix.
--- @return ecnet2.HandshakeState
local function rA(msk, rPk, prologue, introPsk, data)
    if #data < 64 then return close() end

    msk = x25519c.remask(msk)

    local symmetricState = SymmetricState()
    symmetricState:mixHash(prologue)
    symmetricState:mixHash(rPk)
    symmetricState:mixKeyAndHash(introPsk)

    local eCtx = data:sub(1, 48)
    local e = symmetricState:decryptAndHash(eCtx)
    if not e then return close() end

    local es, ee = x25519c.exchange(msk, e)
    symmetricState:mixKey(es)

    local m = unpad(symmetricState:decryptAndHash(data:sub(49)))
    if not m then return close() end

    return rB(msk, ee, symmetricState)
end

--- Returns a unique tag for a given (valid) connection request packet.
--- @param data string The incoming network message, without the intro prefix.
--- @return string tag A unique tag for this request.
local function getTag(data)
    if #data < 64 then return "" end
    return data:sub(33, 48)
end

--- Initializes a handshake as the initiator, sending message A (-> e, es).
--- @param msk string The initiator's masked secret key.
--- @param iPk string The initiator's static public key.
--- @param rPk string The responder's static public key.
--- @param prologue string The handshake prologue.
--- @param introPsk string A pre-shared key resolved in the introduction.
--- @return ecnet2.HandshakeState
--- @return string data The raw data to send over the network.
local function iA(msk, iPk, rPk, prologue, introPsk)
    msk = x25519c.remask(msk)

    local symmetricState = SymmetricState()
    symmetricState:mixHash(prologue)
    symmetricState:mixHash(rPk)
    symmetricState:mixKeyAndHash(introPsk)

    local esk = x25519c.ephemeralSk(msk)
    local eCtx = symmetricState:encryptAndHash(x25519.publicKey(esk))

    symmetricState:mixKey(x25519.exchange(esk, rPk))
    local ctx = symmetricState:encryptAndHash(pad("", 32 + 48 + 16, 192))

    return iB(msk, iPk, rPk, symmetricState), eCtx .. ctx
end

return {
    iA = iA,
    rA = rA,
    getTag = getTag,
    close = close,
}

end,

["ecnet2.Listener"] = function()
--------------------
-- Module: 'ecnet2.Listener'
--------------------
local class = require "ecnet2.class"
local uid = require "ecnet2.uid"
local blake3 = require "ccryptolib.blake3"
local ecnetd = require "ecnet2.ecnetd"
local modems = require "ecnet2.modems"
local HandshakeState = require "ecnet2.HandshakeState"
local Connection = require "ecnet2.Connection"

--- A listener for incoming connection requests.
--- @class ecnet2.Listener
--- @field _protocol ecnet2.Protocol The listener's protocol.
--- @field _psk string The PSK for incoming connections in this listener.
--- @field _handler function The packet handler function.
--- @field _processed table<string, ecnet2.Connection> Processed connections.
--- @field id string The connection's ID, used in `ecnet2_message` events.
local Listener = class "ecnet2.Listener"

--- @param protocol ecnet2.Protocol
function Listener:initialise(protocol)
    self.id = uid()
    self._psk = blake3.digest(protocol._identity._pk .. protocol._hash)
    self._protocol = protocol
    self._processed = setmetatable({}, { __mode = "v" })
    self._handler = function(m, s, c, d) return self:_handle(m, s, c, d) end
    local descriptor = blake3.digest(self._psk)
    ecnetd.addHandler(descriptor, self._handler)
end

--- Handles an incoming packet.
--- @param packet string
--- @param side string
--- @param ch integer
--- @param dist number
function Listener:_handle(packet, side, ch, dist)
    local request = { _lid = self.id, _nid = side, _packet = packet }
    os.queueEvent("ecnet2_request", self.id, request, side, ch, dist)
end

--- Accepts a request and builds a connection. Waits for the next request if
--- none are provided.
---
--- Throws `"invalid listener for this request"` if the supplied request isn't
--- meant for this listener.
---
--- Returns a dummy connection if the request is malformed, or if the request
--- has already been accepted.
---
--- @param reply any
--- @param request table?
--- @return ecnet2.Connection
function Listener:accept(reply, request)
    -- Wait for the request if not given.
    while not request do
        local _, id, req = os.pullEvent("ecnet2_request")
        if id == self.id then request = req end
    end

    -- If the tag has already been processed, return a dummy connection. 
    local tag = HandshakeState.getTag(request._packet)
    if self._processed[tag] then
        return Connection(HandshakeState.close(), self._protocol, request._nid)
    end

    assert(request._lid == self.id, "invalid listener for this request")

    local msk = self._protocol._identity._msk
    local pk = self._protocol._identity._pk
    local state = HandshakeState.rA(msk, pk, "", self._psk, request._packet)

    local str = self._protocol._interface.serialize(reply)
    assert(type(str) == "string", "serializer returned non-string")
    assert(#str <= state.maxlen, "serialized message is too large")
    local newState, packet = state.send(str)
    if packet then modems.transmit(request._nid, packet) end

    local connection = Connection(newState, self._protocol, request._nid)
    self._processed[tag] = connection
    return connection
end

return Listener

end,

["ecnet2.Protocol"] = function()
--------------------
-- Module: 'ecnet2.Protocol'
--------------------
local class = require "ecnet2.class"
local expect = require "cc.expect"
local HandshakeState = require "ecnet2.HandshakeState"
local addressEncoder = require "ecnet2.addressEncoder"
local blake3 = require "ccryptolib.blake3"
local Connection = require "ecnet2.Connection"
local Listener = require "ecnet2.Listener"
local modems = require "ecnet2.modems"

--- A namespace for interpreting messages received over connections.
--- @class ecnet2.Protocol
--- @field _interface ecnet2.IProtocol The underlying interface.
--- @field _identity ecnet2.Identity The protocol's identity.
--- @field _hash string The protocol name hash.
local Protocol = class "ecnet2.Protocol"

--- The interface for describing a new protocol.
--- @class ecnet2.IProtocol
--- @field name string The protocol's name.
--- @field serialize fun(obj: any): string The serializer for messages.
--- @field deserialize fun(str: string): any The deserializer for messages.

--- @param interface ecnet2.IProtocol
--- @param identity ecnet2.Identity The protocol's identity.
function Protocol:initialise(interface, identity)
    expect.field(interface, "name", "string")
    expect.field(interface, "serialize", "function")
    expect.field(interface, "deserialize", "function")
    self._interface = interface
    self._identity = identity
    self._hash = blake3.digest(interface.name)
end

--- Creates a new connection using this protocol and a modem side.
--- @param address string The responder's address.
--- @param modem string The modem name to connect through.
--- @return ecnet2.Connection
function Protocol:connect(address, modem)
    expect.expect(1, address, "string")
    expect.expect(2, modem, "string")
    assert(modems.isOpen(modem), "modem isn't open: " .. modem)
    local rpk = assert(addressEncoder.parse(address), "invalid address")
    local psk = blake3.digest(rpk .. self._hash)
    local descriptor = blake3.digest(psk)
    local msk = self._identity._msk
    local lpk = self._identity._pk
    local state, data = HandshakeState.iA(msk, lpk, rpk, "", psk)
    modems.transmit(modem, descriptor .. data)
    return Connection(state, self, modem)
end

--- Creates a listener for this protocol on all open modems.
--- @return ecnet2.Listener
function Protocol:listen()
    return Listener(self)
end

return Protocol

end,

["ecnet2.Identity"] = function()
--------------------
-- Module: 'ecnet2.Identity'
--------------------
local class = require "ecnet2.class"
local random = require "ccryptolib.random"
local blake3 = require "ccryptolib.blake3"
local x25519 = require "ccryptolib.x25519"
local x25519c = require "ccryptolib.x25519c"
local addressEncoder = require "ecnet2.addressEncoder"
local Protocol = require "ecnet2.Protocol"

local ID_PATH = "id.bin"
local ID_DEL_PATH = "id.bin.del"
local ID_BACKUP_PATH = "id.bin.bak"
local ADDRESS_PATH = "address.txt"

local NOISE_SIZE = 512

--- @return string
local function mkNoise()
    local body = random.random(NOISE_SIZE - 32)
    local checksum = blake3.digest(body)
    return checksum .. body
end

--- @param noise string?
--- @return string?
local function mkKeyFromNoise(noise)
    if not noise then return end
    local checksum = blake3.digest(noise:sub(33))
    if noise:sub(1, 32) ~= checksum then return end
    return blake3.digest(noise)
end

--- @class ecnet2.Identity Identifies a peer to other connected devices.
--- @field _msk string The masked secret key for the identity.
--- @field _pk string The public key for the identity.
--- @field address string The address for connecting to this device
local Identity = class "ecnet2.Identity"

--- @param path string
function Identity:initialise(path)
    local idPath = fs.combine(path, ID_PATH)
    local idDelPath = fs.combine(path, ID_DEL_PATH)
    local idBackupPath = fs.combine(path, ID_BACKUP_PATH)
    local addressPath = fs.combine(path, ADDRESS_PATH)

    --#region critical section on the directory
    fs.makeDir(path)
    if fs.exists(idDelPath) then
        fs.delete(path)
        fs.makeDir(path)
    end

    local noise
    if fs.exists(idPath) then
        local f = assert(fs.open(idPath, "rb"))
        noise = f.readAll()
        f.close()
    else
        noise = mkNoise()
        local f = assert(fs.open(idDelPath, "wb"))
        f.write(noise)
        f.close()
        fs.copy(idDelPath, idBackupPath)
        fs.move(idDelPath, idPath)
    end

    local sk = assert(mkKeyFromNoise(noise), "identity file is corrupted")
    local pk = x25519.publicKey(sk)
    local addr = addressEncoder.encode(pk)
    local f = assert(fs.open(addressPath, "wb"))
    f.write(addr)
    f.close()
    --#endregion

    self._msk = x25519c.mask(sk)
    self._pk = pk
    self.address = addr
end

--- Creates a protocol from a given interface on this identity.
--- @return ecnet2.Protocol
function Identity:Protocol(interface)
    return Protocol(interface, self)
end

return Identity

end,

["ccryptolib.sha256"] = function()
--------------------
-- Module: 'ccryptolib.sha256'
--------------------
--- The SHA256 cryptographic hash function.

local expect  = require "cc.expect".expect
local lassert = require "ccryptolib.internal.util".lassert
local packing = require "ccryptolib.internal.packing"

local rol = bit32.lrotate
local shr = bit32.rshift
local bxor = bit32.bxor
local bnot = bit32.bnot
local band = bit32.band
local unpack = unpack or table.unpack
local p1x8, fmt1x8 = packing.compilePack(">I8")
local p16x4, fmt16x4 = packing.compilePack(">I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4")
local u16x4 = packing.compileUnpack(fmt16x4)
local p8x4, fmt8x4 = packing.compilePack(">I4I4I4I4I4I4I4I4")
local u8x4 = packing.compileUnpack(fmt8x4)

local function primes(n, exp)
    local out = {}
    local p = 2
    for i = 1, n do
        out[i] = bxor(p ^ exp % 1 * 2 ^ 32)
        repeat p = p + 1 until 2 ^ p % p == 2
    end
    return out
end

local K = primes(64, 1 / 3)

local h0 = primes(8, 1 / 2)

local function compress(h, w)
    local h0, h1, h2, h3, h4, h5, h6, h7 = unpack(h)
    local K = K

    -- Message schedule.
    for j = 17, 64 do
        local wf = w[j - 15]
        local w2 = w[j - 2]
        local s0 = bxor(rol(wf, 25), rol(wf, 14), shr(wf, 3))
        local s1 = bxor(rol(w2, 15), rol(w2, 13), shr(w2, 10))
        w[j] = w[j - 16] + s0 + w[j - 7] + s1
    end

    -- Block.
    local a, b, c, d, e, f, g, h = h0, h1, h2, h3, h4, h5, h6, h7
    for j = 1, 64 do
        local s1 = bxor(rol(e, 26), rol(e, 21), rol(e, 7))
        local ch = bxor(band(e, f), band(bnot(e), g))
        local temp1 = h + s1 + ch + K[j] + w[j]
        local s0 = bxor(rol(a, 30), rol(a, 19), rol(a, 10))
        local maj = bxor(band(a, b), band(a, c), band(b, c))
        local temp2 = s0 + maj

        h = g
        g = f
        f = e
        e = d + temp1
        d = c
        c = b
        b = a
        a = temp1 + temp2
    end

    return {
        (h0 + a) % 2 ^ 32,
        (h1 + b) % 2 ^ 32,
        (h2 + c) % 2 ^ 32,
        (h3 + d) % 2 ^ 32,
        (h4 + e) % 2 ^ 32,
        (h5 + f) % 2 ^ 32,
        (h6 + g) % 2 ^ 32,
        (h7 + h) % 2 ^ 32,
    }
end

--- Hashes data using SHA256.
--- @param data string Input bytes.
--- @return string hash The 32-byte hash value.
local function digest(data)
    expect(1, data, "string")

    -- Pad input.
    local bitlen = #data * 8
    local padlen = -(#data + 9) % 64
    data = data .. "\x80" .. ("\0"):rep(padlen) .. p1x8(fmt1x8, bitlen)

    -- Digest.
    local h = h0
    for i = 1, #data, 64 do
        h = compress(h, {u16x4(fmt16x4, data, i)})
    end

    return p8x4(fmt8x4, unpack(h))
end

-- Reports once every ~10ms on a standard CCEmuX emulator.
local PBKDF2_CB_ITERATIONS = 50

--- Hashes a password using PBKDF2-HMAC-SHA256.
--- @param password string The password to hash.
--- @param salt string The password's salt.
--- @param iter number The number of iterations to perform.
--- @param progress fun(iter: number)? An optional function to periodically call with the current iteration number as argument.
--- @return string dk The 32-byte derived key.
local function pbkdf2(password, salt, iter, progress)
    expect(1, password, "string")
    expect(2, salt, "string")
    expect(3, iter, "number")
    lassert(iter % 1 == 0, "iteration number must be an integer", 2)
    lassert(iter > 0, "iteration number must be positive", 2)
    expect(4, progress, "function", "nil")

    -- Pad password.
    if #password > 64 then password = digest(password) end
    password = {u16x4(fmt16x4, password .. ("\0"):rep(64), 1)}

    -- Compute password blocks.
    local ikp = {}
    local okp = {}
    for i = 1, 16 do
        ikp[i] = bxor(password[i], 0x36363636)
        okp[i] = bxor(password[i], 0x5c5c5c5c)
    end

    local hikp = compress(h0, ikp)
    local hokp = compress(h0, okp)

    -- 96-byte padding.
    local pad96 = {2 ^ 31, 0, 0, 0, 0, 0, 0, 0x300}

    -- First iteration.
    local pre = p16x4(fmt16x4, unpack(ikp))
    local hs = {u8x4(fmt8x4, digest(pre .. salt .. "\0\0\0\1"), 1)}
    for i = 1, 8 do hs[i + 8] = pad96[i] end
    hs = compress(hokp, hs)

    -- Second iteration onwards.
    local out = {unpack(hs)}
    for i = 2, iter do
        for j = 1, 8 do hs[j + 8] = pad96[j] end
        hs = compress(hikp, hs)
        for j = 1, 8 do hs[j + 8] = pad96[j] end
        hs = compress(hokp, hs)
        for j = 1, 8 do out[j] = bxor(out[j], hs[j]) end
        if progress and i % PBKDF2_CB_ITERATIONS == 0 then progress(i) end
    end

    return p8x4(fmt8x4, unpack(out))
end

return {
    digest = digest,
    pbkdf2 = pbkdf2,
}

end,

["ecnet2.init"] = function()
--------------------
-- Module: 'ecnet2.init'
--------------------
local constants = require "ecnet2.constants"
local Identity = require "ecnet2.Identity"
local modems = require "ecnet2.modems"
local ecnetd = require "ecnet2.ecnetd"
local expect = require "cc.expect"

local module = {}

--- @type ecnet2.Identity?
local identity

local function fetchIdentity()
    if not identity then identity = Identity(constants.IDENTITY_PATH) end
    return identity
end

--- Loads or creates an identity file in the given path.
--- @param path string The path to load or create the identity at.
--- @return ecnet2.Identity
function module.Identity(path)
    return Identity(expect(1, path, "string"))
end

--- Returns the address for this device.
--- @deprecated Use `ecnet2.Identity("/.ecnet2").address` instead.
--- @return string address The address.
function module.address()
    return fetchIdentity().address
end

module.open = modems.open
module.close = modems.close
module.isOpen = modems.isOpen

module.daemon = ecnetd.daemon

--- Creates a protocol from a given interface.
--- @deprecated Use `ecnet2.Identity("/.ecnet2"):Protocol(...)` instead.
--- @param interface ecnet2.IProtocol A table describing the protocol.
--- @return ecnet2.Protocol protocol The resulting protocol.
function module.Protocol(interface)
    return fetchIdentity():Protocol(interface)
end

return module

end,

----------------------
-- Modules part end --
----------------------
        }
        if files[path] then
            return files[path]
        else
            return origin_seacher(path)
        end
    end
end
---------------------------------------------------------
----------------Auto generated code block----------------
---------------------------------------------------------
local constants = require "ecnet2.constants"
local Identity = require "ecnet2.Identity"
local modems = require "ecnet2.modems"
local ecnetd = require "ecnet2.ecnetd"
local expect = require "cc.expect"

local module = {}

--- @type ecnet2.Identity?
local identity

local function fetchIdentity()
    if not identity then identity = Identity(constants.IDENTITY_PATH) end
    return identity
end

--- Loads or creates an identity file in the given path.
--- @param path string The path to load or create the identity at.
--- @return ecnet2.Identity
function module.Identity(path)
    return Identity(expect(1, path, "string"))
end

--- Returns the address for this device.
--- @deprecated Use `ecnet2.Identity("/.ecnet2").address` instead.
--- @return string address The address.
function module.address()
    return fetchIdentity().address
end

module.open = modems.open
module.close = modems.close
module.isOpen = modems.isOpen

module.daemon = ecnetd.daemon

--- Creates a protocol from a given interface.
--- @deprecated Use `ecnet2.Identity("/.ecnet2"):Protocol(...)` instead.
--- @param interface ecnet2.IProtocol A table describing the protocol.
--- @return ecnet2.Protocol protocol The resulting protocol.
function module.Protocol(interface)
    return fetchIdentity():Protocol(interface)
end

return module