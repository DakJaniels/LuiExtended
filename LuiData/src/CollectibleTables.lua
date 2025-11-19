-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data

-- Define ID lists for collectibles by category
--- @class (partial) CollectibleTables
local collectibleIds =
{
    -- Banker
    Banker =
    {
        267,   -- Tythis
        397,   -- Cassus
        6376,  -- Ezabi
        8994,  -- Baron
        9743,  -- Factotum
        11097, -- Pyroclast
        12413, -- Eri
        13517, -- Celia
    },

    -- Merchants
    Merchants =
    {
        301,   -- Nuzhimeh
        396,   -- Allaria
        6378,  -- Fezez
        8995,  -- Peddler
        9744,  -- Factotum
        11059, -- Hoarfrost
        12414, -- Xyn
        13066, -- Terilorne
    },

    -- Armory Assistants
    Armory =
    {
        9745,  -- Ghrasharog
        10618, -- Zuqoth
        11876, -- Drinweth
        13518, -- Voko
    },

    -- Deconstruction
    Decon =
    {
        10184, -- Giladil
        10617, -- Aderene
        11877, -- Tzozabrar
        13063, -- Siluruz
    },

    -- Fence
    Fence =
    {
        300, -- Pirharri
    },

    -- Companions
    -- LUI will generate SlashCommands from the lowercase names e.g. Bastian becomes /bastian.
    Companions =
    {
        9245,  -- Bastian
        9353,  -- Mirri
        9911,  -- Ember
        9912,  -- Isobel
        11113, -- Sharp-as-Night
        11114, -- Azandar
        12172, -- Tanlorin
        12173, -- Zerith-var
    },
}

-- Apply formatting to get a clean short name for collectibles
local function GetFormattedCollectibleShortName(id)
    if not id then return nil end

    local name = zo_strformat("<<1>>", GetCollectibleName(id))
    if not name or name == "" then return nil end

    -- Extract shortened name based on common patterns
    local shortName = name:match("^([%w-']+),") or
        name:match("^([%w-']+) the") or
        name:match("^([%w-']+)")

    -- Special case for Sharp-as-Night
    if id == 11113 then return "Sharp-as-Night" end

    return shortName or name
end

--- @class (partial) CollectibleTables
local collectibleTables = {}

-- Convert the ID lists to tables with ID-to-name mappings
for category, ids in pairs(collectibleIds) do
    collectibleTables[category] = setmetatable({},
                                               {
                                                   __index = function (t, k)
                                                       -- Only process numeric keys (collectible IDs)
                                                       if type(k) == "number" then
                                                           -- Check if this ID belongs in this category
                                                           local belongs = false
                                                           for _, id in ipairs(ids) do
                                                               if id == k then
                                                                   belongs = true
                                                                   break
                                                               end
                                                           end

                                                           if belongs then
                                                               local name = GetFormattedCollectibleShortName(k)
                                                               if name then
                                                                   -- Cache the result
                                                                   t[k] = name
                                                                   return name
                                                               end
                                                           end
                                                       end
                                                       return nil
                                                   end
                                               })

    -- Pre-populate with known values to avoid initial delay
    for _, id in ipairs(ids) do
        collectibleTables[category][id] = GetFormattedCollectibleShortName(id)
    end
end

-- Create the All table as a combination of all other tables
collectibleTables.All = setmetatable({},
                                     {
                                         __index = function (t, k)
                                             if type(k) == "number" then
                                                 -- Check all categories
                                                 for category, _ in pairs(collectibleIds) do
                                                     if collectibleTables[category][k] then
                                                         local name = collectibleTables[category][k]
                                                         t[k] = name -- Cache result
                                                         return name
                                                     end
                                                 end

                                                 -- Not found in predefined categories, try direct lookup
                                                 local name = GetFormattedCollectibleShortName(k)
                                                 if name then
                                                     t[k] = name
                                                     return name
                                                 end
                                             end
                                             return nil
                                         end
                                     })

-- Pre-populate All table with known values
for category, ids in pairs(collectibleIds) do
    for _, id in ipairs(ids) do
        collectibleTables.All[id] = collectibleTables[category][id]
    end
end

--- @class (partial) CollectibleTables
Data.CollectibleTables = collectibleTables
