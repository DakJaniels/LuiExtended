-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local UI = LUIE.UI
local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
--- @type Effects
local Effects = Data.Effects
local Abilities = Data.Abilities
local Tooltips = Data.Tooltips
local string_format = string.format
local printToChat = LUIE.PrintToChat
local zo_strformat = zo_strformat
local table_insert = table.insert
local table_sort = table.sort
-- local displayName = GetDisplayName()
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()

local moduleName = SpellCastBuffs.moduleName


--[[
 * Runs on the EVENT_COMBAT_EVENT listener.
 * This handler fires every time ANY combat activity happens. Very-very often.
 * We use it to remove mines from active target debuffs
 * As well as create fake buffs/debuffs for events with no active effect present.
 ]]
--


-- Combat Event - Add Name Aura to Target
--- - **EVENT_COMBAT_EVENT **
---
--- @param eventCode integer
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function SpellCastBuffs.OnCombatAddNameEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Get the name of the target to apply the buff to
    local name = Effects.AddNameOnEvent[abilityId].name
    local id = Effects.AddNameOnEvent[abilityId].id
    -- Bail out if we have no name
    if not name then
        return
    end

    -- NOTE: We may eventually need to iterate here, for the time being though we can just relatively reliably put this in slot 2 since slot 1 should be CC Immunity.
    -- NOTE: We may eventually add a function handler to do other things, like make certain abilities change their CC types etc like the example below.
    if Effects.AddNameAura[name] then
        if result == ACTION_RESULT_EFFECT_GAINED then
            -- Get stack value if its saved.
            local stack = Effects.AddNameAura[name][2] and Effects.AddNameAura[name][2].stack
            Effects.AddNameAura[name][2] = {}
            Effects.AddNameAura[name][2].id = id
            if Effects.AddStackOnEvent[abilityId] then
                if stack then
                    Effects.AddNameAura[name][2].stack = stack + 1
                else
                    Effects.AddNameAura[name][2].stack = Effects.AddStackOnEvent[abilityId]
                end
            end
            -- Specific to Crypt of Hearts I (Ignite Colossus)
            if id == 46680 then
                LuiData.Data.AlertTable[22527].cc = LUIE_CC_TYPE_UNBREAKABLE
                LuiData.Data.AlertTable[22527].block = nil
                LuiData.Data.AlertTable[22527].dodge = nil
                LuiData.Data.AlertTable[22527].avoid = true
            end
        elseif result == ACTION_RESULT_EFFECT_FADED then
            -- Check to make sure the current added aura here is the same id. If something else overrides the previous one we don't need to worry about removing the previous one.
            if Effects.AddNameAura[name] and Effects.AddNameAura[name][2] and Effects.AddNameAura[name][2].id == id then
                Effects.AddNameAura[name][2] = nil
                -- Specific to Crypt of Hearts I (Ignite Colossus)
                if id == 46680 then
                    LuiData.Data.AlertTable[22527].cc = nil
                    LuiData.Data.AlertTable[22527].block = true
                    LuiData.Data.AlertTable[22527].dodge = true
                    LuiData.Data.AlertTable[22527].avoid = false
                end
            end
        end

        -- Reload Effects on current target
        if not SpellCastBuffs.SV.HideTargetBuffs then
            SpellCastBuffs.AddNameAura()
        end
    end
end
