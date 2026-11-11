-- -----------------------------------------------------------------------------
--  LuiExtended - Suppress vanilla ZO BuffDebuff when game buff UI is disabled
--  and LUIE opt-in is enabled (see LUIE.ApplyZOBuffDebuffSuppression).
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local eventManager = GetEventManager()
local zoBuffDebuffSettingListenerRegistered = false

function LUIE.GetLAMSuppressZOBuffDebuffWhenHiddenTooltip()
    return zo_strformat(
        GetString(LUIE_STRING_LAM_SUPPRESS_ZO_BUFFDEBUFF_WHEN_HIDDEN_TP),
        GetString(SI_BUFFS_OPTIONS_SECTION_TITLE),
        GetString(SI_BUFFS_OPTIONS_ALL_ENABLED),
        GetString(SI_BUFFDEBUFFENABLEDCHOICE0))
end

function LUIE.ShouldSuppressZOBuffDebuff()
    if not LUIE.SV or not LUIE.SV.SuppressZOBuffDebuffWhenHidden then
        return false
    end
    return tonumber(GetSetting(SETTING_TYPE_BUFFS, BUFFS_SETTING_ALL_ENABLED)) == BUFF_DEBUFF_ENABLED_CHOICE_DONT_SHOW
end

-- ZO_BuffDebuff_ContainerObject:Initialize registers MarkDirty with control:RegisterForEvent.
-- Player uses EVENT_PLAYER_ACTIVATED. Target uses EVENT_RETICLE_TARGET_CHANGED.
local CONTAINER_MARK_DIRTY_EVENTS =
{
    EVENT_PLAYER_ACTIVATED,
    EVENT_RETICLE_TARGET_CHANGED,
    EVENT_EFFECTS_FULL_UPDATE,
    EVENT_EFFECT_CHANGED,
    EVENT_ARTIFICIAL_EFFECT_ADDED,
    EVENT_ARTIFICIAL_EFFECT_REMOVED,
    EVENT_PLAYER_COMBAT_STATE,
}

function LUIE.SuppressZOBuffDebuffContainerControl(control)
    for eventIndex = 1, #CONTAINER_MARK_DIRTY_EVENTS do
        control:UnregisterForEvent(CONTAINER_MARK_DIRTY_EVENTS[eventIndex])
    end
    control:SetHandler("OnUpdate", nil)
    control:SetHidden(true)
end

function LUIE.ApplyZOBuffDebuffSuppression()
    if not LUIE.ShouldSuppressZOBuffDebuff() then
        return
    end

    local containerObjectsByUnitTag = BUFF_DEBUFF.containerObjectsByUnitTag
    for _, containerObject in pairs(containerObjectsByUnitTag) do
        LUIE.SuppressZOBuffDebuffContainerControl(containerObject:GetControl())
    end

    local topLevelControl = BUFF_DEBUFF.control
    topLevelControl:UnregisterForEvent(EVENT_INTERFACE_SETTING_CHANGED)
    topLevelControl:UnregisterForEvent(EVENT_ADD_ONS_LOADED)
    topLevelControl:SetHidden(true)
end

local function OnGameBuffSettingChanged(_eventId_, _settingSystemType_, settingId)
    if settingId ~= BUFFS_SETTING_ALL_ENABLED then
        return
    end
    LUIE.ApplyZOBuffDebuffSuppression()
end

function LUIE.RegisterZOBuffDebuffSuppressionSettingListener()
    if zoBuffDebuffSettingListenerRegistered then
        return
    end
    zoBuffDebuffSettingListenerRegistered = true

    local listenerNamespace = LUIE.name .. "ZOBuffDebuffSetting"
    eventManager:RegisterForEvent(listenerNamespace, EVENT_INTERFACE_SETTING_CHANGED, OnGameBuffSettingChanged)
    eventManager:AddFilterForEvent(listenerNamespace, EVENT_INTERFACE_SETTING_CHANGED, REGISTER_FILTER_SETTING_SYSTEM_TYPE, SETTING_TYPE_BUFFS)
end
