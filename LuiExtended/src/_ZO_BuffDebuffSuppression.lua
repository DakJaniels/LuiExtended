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

function LUIE.SuppressZOBuffDebuffContainerControl(control)
    if control == nil then
        return
    end
    local controlName = control:GetName()
    if controlName and controlName ~= "" then
        eventManager:UnregisterForAllEvents(controlName)
    end
    control:SetHandler("OnUpdate", nil)
    control:SetHidden(true)
end

function LUIE.ApplyZOBuffDebuffSuppression()
    if not LUIE.ShouldSuppressZOBuffDebuff() then
        return
    end
    if BUFF_DEBUFF == nil then
        return
    end

    local containerObjectsByUnitTag = BUFF_DEBUFF.containerObjectsByUnitTag
    if containerObjectsByUnitTag then
        for _, containerObject in pairs(containerObjectsByUnitTag) do
            if containerObject and containerObject.GetControl then
                LUIE.SuppressZOBuffDebuffContainerControl(containerObject:GetControl())
            end
        end
    end

    local topLevelControl = BUFF_DEBUFF.control
    if topLevelControl then
        local topLevelName = topLevelControl:GetName()
        if topLevelName and topLevelName ~= "" then
            eventManager:UnregisterForAllEvents(topLevelName)
        end
        topLevelControl:SetHidden(true)
    end
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
