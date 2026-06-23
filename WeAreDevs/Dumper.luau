local Decoder = {}

Decoder.output = {
    strings = {},
    rawTables = {}
}

-- Extract quoted byte-escaped strings like "\069\117..."
local function extractEncodedStrings(source)
    local results = {}

    for match in source:gmatch('"(.-)"') do
        if match:find("\\%d%d%d") then
            table.insert(results, match)
        end
    end

    return results
end

-- Convert \xxx byte strings into readable text
local function decodeBytes(str)
    return (str:gsub("\\(%d%d%d)", function(code)
        return string.char(tonumber(code))
    end))
end

-- Extract F table from WeAreDevs blob
local function extractFTable(source)
    local F = {}

    local inside = source:match("local F%s*=%s*{(.-)}")
    if not inside then return F end

    for item in inside:gmatch('"([^"]+)"') do
        table.insert(F, item)
    end

    return F
end

-- Try to decode readable keywords inside strings
local function extractKeywords(text)
    local keywords = {}

    for word in text:gmatch("[a-zA-Z_][a-zA-Z0-9_%.:]+") do
        table.insert(keywords, word)
    end

    return keywords
end

function Decoder:run(source)
    -- Step 1: extract raw encoded strings
    local encoded = extractEncodedStrings(source)

    for _, v in ipairs(encoded) do
        local decoded = decodeBytes(v)
        table.insert(self.output.strings, decoded)

        -- Step 2: pull readable keywords
        for _, k in ipairs(extractKeywords(decoded)) do
            table.insert(self.output.rawTables, k)
        end
    end
end

function Decoder:print()
    print("=== STATIC WEAREDEVS DECODED OUTPUT ===")

    print("\n--- STRINGS ---")
    for i, v in ipairs(self.output.strings) do
        print(i, v)
    end

    print("\n--- KEYWORDS ---")
    for i, v in ipairs(self.output.rawTables) do
        print(i, v)
    end

    print("=== END ===")
end

return Decoder
