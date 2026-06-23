-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local S = ChatAnnouncements.State
local I = ChatAnnouncements.Internal
local B = ChatAnnouncements.Brackets

local string_format = string.format
local table_insert = table.insert

local eventManager = GetEventManager()

local moduleName = LUIE.name .. "ChatAnnouncements"

--- @param bagId Bag
--- @param slotId integer
--- @param icon string
--- @param stack integer
--- @param itemId integer
--- @param itemType ItemType
--- @param itemLink string
--- @return CAItemStackEntry
function I.MakeStackEntry(bagId, slotId, icon, stack, itemId, itemType, itemLink)
    return
    {
        icon = icon,
        stack = stack,
        itemId = itemId,
        itemType = itemType,
        itemLink = itemLink,
        stolen = IsItemStolen(bagId, slotId),
    }
end

--- @param stacksTable table<integer, CAItemStackEntry>
--- @return table<string, {count: integer, sample: CAItemStackEntry}>
function I.BuildItemCountMap(stacksTable)
    --- @type table<string,{count:integer,sample:{icon:string,stack:integer,itemId:integer,itemType:integer,itemLink:string,stolen:boolean}}>
    local map = {}
    if not stacksTable then
        return map
    end
    for _, item in pairs(stacksTable) do
        if item and item.itemLink and item.itemLink ~= "" then
            local key = item.itemLink
            local stack = tonumber(item.stack) or 0
            local entry = map[key]
            if entry then
                entry.count = entry.count + stack
                if item.stolen then
                    entry.sample.stolen = true
                end
            else
                map[key] = { count = stack, sample = item }
            end
        end
    end
    return map
end

--- @param beforeMap table<string, {count: integer, sample: CAItemStackEntry}>
--- @param afterMap table<string, {count: integer, sample: CAItemStackEntry}>
--- @return {removedCount: integer, sample: CAItemStackEntry}[]
function I.DiffRemoved(beforeMap, afterMap)
    --- @type {removedCount:integer,sample:{icon:string,stack:integer,itemId:integer,itemType:integer,itemLink:string,stolen:boolean}}[]
    local removed = {}
    for itemLink, beforeEntry in pairs(beforeMap) do
        local afterCount = (afterMap[itemLink] and afterMap[itemLink].count) or 0
        local removedCount = (beforeEntry.count or 0) - afterCount
        if removedCount and removedCount > 0 then
            removed[#removed + 1] = { removedCount = removedCount, sample = beforeEntry.sample }
        end
    end
    return removed
end
