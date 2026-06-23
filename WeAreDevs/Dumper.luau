local dump = {}

dump.strings = {}
dump.seen = {}

local function safeStore(v)
    if type(v) ~= "string" then return end
    if dump.seen[v] then return end
    dump.seen[v] = true
    table.insert(dump.strings, v)
end

-- Hook common decode entry points (pcall-safe)
local oldGsub = string.gsub
string.gsub = function(...)
    local a, b, c = ...
    safeStore(a)
    safeStore(b)
    return oldGsub(...)
end

local oldSub = string.sub
string.sub = function(...)
    local a, b, c = ...
    safeStore(a)
    return oldSub(...)
end

local oldConcat = table.concat
table.concat = function(...)
    local t = ...
    if type(t) == "table" then
        for _, v in next, t do
            safeStore(v)
        end
    end
    return oldConcat(...)
end

-- Hook metatable access (VM uses this heavily)
local oldGetmt = getmetatable
getmetatable = function(obj)
    local mt = oldGetmt(obj)
    safeStore(tostring(obj))
    return mt
end

-- Capture environment indexing (very important for VM dumps)
local env = getfenv and getfenv() or _G

setmetatable(env, {
    __index = function(self, key)
        safeStore(tostring(key))
        return rawget(self, key)
    end
})

-- Run target (replace THIS with your obfuscated script)
local function run(target)
    local success, err = pcall(target)
    if not success then
        warn("VM error:", err)
    end
end

-- EXPORT DUMP
function dump:print()
    print("=== WEAREDEVS DUMP START ===")
    for i, v in ipairs(self.strings) do
        print(i, v)
    end
    print("=== WEAREDEVS DUMP END ===")
end

return dump
