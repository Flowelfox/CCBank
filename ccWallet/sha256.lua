local sha256 = {}

local bit32 = require("bit32")

local function rightRotate(value, bits)
    return bit32.bor(bit32.rshift(value, bits), bit32.lshift(value, 32 - bits))
end

local function toBits(num)
    local t = {}
    for i = 1, 32 do
        t[i] = num % 2
        num = math.floor(num / 2)
    end
    return t
end

local function fromBits(bits)
    local num = 0
    for i = 1, 32 do
        num = num + bits[i] * 2^(i-1)
    end
    return num
end

local function preprocess(message)
    local bitLen = #message * 8
    message = message .. "\128"
    while (#message * 8 + 64) % 512 ~= 0 do
        message = message .. "\0"
    end
    for i = 1, 8 do
        message = message .. string.char(bit32.band(bit32.rshift(bitLen, 8 * (8 - i)), 0xFF))
    end
    return message
end

local function parseMessage(message)
    local M = {}
    for i = 1, #message, 64 do
        local chunk = {}
        for j = 0, 15 do
            chunk[j] = 0
            for k = 1, 4 do
                chunk[j] = chunk[j] * 256 + message:byte(i + j * 4 + k - 1)
            end
        end
        table.insert(M, chunk)
    end
    return M
end

local function sha256Transform(chunk, H)
    local K = {
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    }

    local W = {}
    for i = 0, 15 do
        W[i] = chunk[i]
    end
    for i = 16, 63 do
        local s0 = bit32.bxor(rightRotate(W[i-15], 7), rightRotate(W[i-15], 18), bit32.rshift(W[i-15], 3))
        local s1 = bit32.bxor(rightRotate(W[i-2], 17), rightRotate(W[i-2], 19), bit32.rshift(W[i-2], 10))
        W[i] = bit32.band(W[i-16] + s0 + W[i-7] + s1, 0xFFFFFFFF)
    end

    local a, b, c, d, e, f, g, h = table.unpack(H)

    for i = 0, 63 do
        local S1 = bit32.bxor(rightRotate(e, 6), rightRotate(e, 11), rightRotate(e, 25))
        local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g))
        local temp1 = bit32.band(h + S1 + ch + K[i+1] + W[i], 0xFFFFFFFF)
        local S0 = bit32.bxor(rightRotate(a, 2), rightRotate(a, 13), rightRotate(a, 22))
        local maj = bit32.bxor(bit32.band(a, b), bit32.band(a, c), bit32.band(b, c))
        local temp2 = bit32.band(S0 + maj, 0xFFFFFFFF)

        h = g
        g = f
        f = e
        e = bit32.band(d + temp1, 0xFFFFFFFF)
        d = c
        c = b
        b = a
        a = bit32.band(temp1 + temp2, 0xFFFFFFFF)
    end

    H[1] = bit32.band(H[1] + a, 0xFFFFFFFF)
    H[2] = bit32.band(H[2] + b, 0xFFFFFFFF)
    H[3] = bit32.band(H[3] + c, 0xFFFFFFFF)
    H[4] = bit32.band(H[4] + d, 0xFFFFFFFF)
    H[5] = bit32.band(H[5] + e, 0xFFFFFFFF)
    H[6] = bit32.band(H[6] + f, 0xFFFFFFFF)
    H[7] = bit32.band(H[7] + g, 0xFFFFFFFF)
    H[8] = bit32.band(H[8] + h, 0xFFFFFFFF)
end

function sha256.hash(message)
    local H = {
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    }

    message = preprocess(message)
    local M = parseMessage(message)

    for i = 1, #M do
        sha256Transform(M[i], H)
    end

    local hash = ""
    for i = 1, 8 do
        hash = hash .. string.format("%08x", H[i])
    end

    return hash
end

return sha256