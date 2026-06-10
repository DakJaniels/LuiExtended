-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local pairs = pairs
local ChatOutput = LUIE.ChatOutput
local zo_strformat = zo_strformat
local eventManager = GetEventManager()
local ACTION_RESULT_AREA_EFFECT = 669966

local moduleName = LUIE.name .. "CombatInfo"

-- Import CombatInfo namespace (declared in Namespace.lua)
--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo

-- Module-local state

-- ===== HELPER FUNCTIONS =====

local function getAbilityName(abilityId, casterUnitTag)
    return GetAbilityName(abilityId, casterUnitTag)
end

-- ===== CORE FUNCTIONS (stay in main module) =====

-- Set Marker
--- @param removeMarker boolean?
function CombatInfo.SetMarker(removeMarker)
    if removeMarker then
        eventManager:UnregisterForEvent(moduleName .. "Marker", EVENT_PLAYER_ACTIVATED)
        SetFloatingMarkerInfo(MAP_PIN_TYPE_AGGRO, CombatInfo.SV.markerSize, "", "", true, false)
    end
    if CombatInfo.SV.showMarker ~= true then
        return
    end
    local LUIE_MARKER = LUIE_MEDIA_COMBATINFO_FLOATINGICON_REDARROW_DDS
    SetFloatingMarkerInfo(MAP_PIN_TYPE_AGGRO, CombatInfo.SV.markerSize, LUIE_MARKER, "", true, false)
    eventManager:RegisterForEvent(moduleName .. "Marker", EVENT_PLAYER_ACTIVATED, CombatInfo.OnPlayerActivatedMarker)
end

-- Clear and then (maybe) re-register event listeners
function CombatInfo.RegisterCombatInfo()
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, CombatInfo.OnPlayerActivated)
end

function CombatInfo.ClearCustomList(list)
    local listRef = ""
    for k, _ in pairs(list) do
        list[k] = nil
    end
    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
end

function CombatInfo.AddToCustomList(list, input)
    local id = tonumber(input)
    local listRef = ""
    if id and id > 0 then
        local cachedName = zo_strformat(SI_ABILITY_NAME, getAbilityName(id))
        local name = cachedName
        if name ~= nil and name ~= "" then
            local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
            list[id] = true
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), icon, id, name, listRef), true)
        else
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, listRef), true)
        end
    else
        if input ~= "" then
            list[input] = true
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
        end
    end
end

function CombatInfo.RemoveFromCustomList(list, input)
    local id = tonumber(input)
    local listRef = ""
    if id and id > 0 then
        local cachedName = zo_strformat(SI_ABILITY_NAME, getAbilityName(id))
        local name = cachedName
        local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
        list[id] = nil
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), icon, id, name, listRef), true)
    else
        if input ~= "" then
            list[input] = nil
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
        end
    end
end

function CombatInfo.OnPlayerActivatedMarker(eventCode)
    CombatInfo.SetMarker()
end

-- Used to populate abilities icons after the user has logged on
function CombatInfo.OnPlayerActivated(eventCode)
    eventManager:UnregisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED)
end

-- Module initialization
function CombatInfo.Initialize(enabled)
    local isCharacterSpecific = LUIE.IsCharacterSpecificSavedVarsEnabled()
    if isCharacterSpecific then
        CombatInfo.SV = ZO_SavedVars:New(LUIE.ModuleSavedVarNames.CombatInfo, LUIE.SVVer, nil, CombatInfo.Defaults, LUIE.SavedVarsProfile)
    else
        CombatInfo.SV = ZO_SavedVars:NewAccountWide(LUIE.ModuleSavedVarNames.CombatInfo, LUIE.SVVer, nil, CombatInfo.Defaults, LUIE.SavedVarsProfile)
    end

    -- Migrate font styles (string/display/nil -> valid 0-7); run once per account
    if not LUIE.IsMigrationDone("combatinfo_fontstyles_v2") then
        CombatInfo.SV.CastBarFontStyle = LUIE.MigrateFontStyle(CombatInfo.SV.CastBarFontStyle)
        if CombatInfo.SV.alerts and CombatInfo.SV.alerts.toggles then
            CombatInfo.SV.alerts.toggles.alertFontStyle = LUIE.MigrateFontStyle(CombatInfo.SV.alerts.toggles.alertFontStyle)
        end
        LUIE.MarkMigrationDone("combatinfo_fontstyles_v2")
    end

    if not enabled then
        return
    end
    CombatInfo.Enabled = true

    CombatInfo.RegisterCombatInfo()

    CombatInfo.SetMarker()

    CombatInfo.AbilityAlerts.CreateAlertFrame()
    CombatInfo.AbilityAlerts.SetAlertFramePosition()
    CombatInfo.AbilityAlerts.SetAlertColors()

    CombatInfo.CrowdControlTracker.UpdateAOEList()
    CombatInfo.CrowdControlTracker.Initialize()

    CombatInfo.Block.Initialize()

    local coreAw = LUIE.GetCoreAccountWideRawTable()
    if not coreAw.AdjustVarsCI then
        coreAw.AdjustVarsCI = 0
    end
    if coreAw.AdjustVarsCI < 2 then
        CombatInfo.SV.alerts.colors.stunColor = CombatInfo.Defaults.alerts.colors.stunColor
        CombatInfo.SV.alerts.colors.knockbackColor = CombatInfo.Defaults.alerts.colors.knockbackColor
        CombatInfo.SV.alerts.colors.levitateColor = CombatInfo.Defaults.alerts.colors.levitateColor
        CombatInfo.SV.alerts.colors.disorientColor = CombatInfo.Defaults.alerts.colors.disorientColor
        CombatInfo.SV.alerts.colors.fearColor = CombatInfo.Defaults.alerts.colors.fearColor
        CombatInfo.SV.alerts.colors.charmColor = CombatInfo.Defaults.alerts.colors.charmColor
        CombatInfo.SV.alerts.colors.silenceColor = CombatInfo.Defaults.alerts.colors.silenceColor
        CombatInfo.SV.alerts.colors.staggerColor = CombatInfo.Defaults.alerts.colors.staggerColor
        CombatInfo.SV.alerts.colors.unbreakableColor = CombatInfo.Defaults.alerts.colors.unbreakableColor
        CombatInfo.SV.alerts.colors.snareColor = CombatInfo.Defaults.alerts.colors.snareColor
        CombatInfo.SV.alerts.colors.rootColor = CombatInfo.Defaults.alerts.colors.rootColor
        CombatInfo.SV.cct.colors[ACTION_RESULT_STUNNED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_STUNNED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_KNOCKBACK] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_KNOCKBACK]
        CombatInfo.SV.cct.colors[ACTION_RESULT_LEVITATED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_LEVITATED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_DISORIENTED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_DISORIENTED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_FEARED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_FEARED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_CHARMED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_CHARMED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_SILENCED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_SILENCED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_STAGGERED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_STAGGERED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_IMMUNE] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_IMMUNE]
        CombatInfo.SV.cct.colors[ACTION_RESULT_DODGED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_DODGED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_BLOCKED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_BLOCKED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_BLOCKED_DAMAGE] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_BLOCKED_DAMAGE]
        CombatInfo.SV.cct.colors[ACTION_RESULT_AREA_EFFECT] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_AREA_EFFECT]
        CombatInfo.SV.cct.colors.unbreakable = CombatInfo.Defaults.cct.colors.unbreakable
    end
    coreAw.AdjustVarsCI = 2
end

--- Console LibHarvens "reset to defaults": replace saved vars with a deep copy of `CombatInfo.Defaults`, then refresh active UI.
function CombatInfo.ResetToDefaults()
    local sv = CombatInfo.SV
    if not sv then
        return
    end
    for k in pairs(sv) do
        sv[k] = nil
    end
    ZO_DeepTableCopy(CombatInfo.Defaults, sv)
    if not CombatInfo.Enabled then
        return
    end
    CombatInfo.SetMarker()
    CombatInfo.AbilityAlerts.ApplyFontAlert()
    CombatInfo.AbilityAlerts.SetAlertFramePosition()
    CombatInfo.AbilityAlerts.SetAlertColors()
    CombatInfo.AbilityAlerts.ResetAlertSize()
    CombatInfo.CrowdControlTracker.UpdateAOEList()
    CombatInfo.CrowdControlTracker.Initialize()
end
