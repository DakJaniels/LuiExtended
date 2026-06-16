-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

MiniMap.sessionMapVisible = true

--- @return boolean
function MiniMap.IsPlayerInHouse()
    if GetCurrentZoneHouseId then
        return GetCurrentZoneHouseId() ~= 0
    end
    return false
end

--- @return boolean
function MiniMap.GetContextAllowsMiniMap()
    if not MiniMap.Enabled or not MiniMap.SV then
        return false
    end
    if MiniMap.sessionMapVisible == false then
        return false
    end
    if MiniMap.SV.allowOnGameplayHud == false then
        return false
    end
    if IsUnitInCombat("player") and MiniMap.SV.allowDuringCombat ~= true then
        return false
    end
    if IsMounted() and MiniMap.SV.allowWhileMounted ~= true then
        return false
    end
    if MiniMap.IsPlayerInHouse() and MiniMap.SV.allowInPlayerHousing ~= true then
        return false
    end
    return true
end

function MiniMap.UpdateConditionalVisibility()
    if not MiniMap.Enabled or not MiniMap.view then
        return
    end
    local scene = SCENE_MANAGER:GetCurrentScene()
    if not MiniMap.IsMiniMapHudScene(scene) then
        return
    end
    MiniMap.ApplyFragmentHiddenReasons()
    MiniMap.ApplyCompassMode()
end

function MiniMap.ToggleShowMap()
    if not MiniMap.Enabled then
        return
    end
    MiniMap.sessionMapVisible = not MiniMap.sessionMapVisible
    MiniMap.UpdateConditionalVisibility()
    local message = MiniMap.sessionMapVisible and GetString(LUIE_STRING_MINIMAP_TOGGLE_SHOW_ON) or GetString(LUIE_STRING_MINIMAP_TOGGLE_SHOW_OFF)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
    messageParams:SetText(message)
    messageParams:SetSound(SOUNDS.NONE)
    messageParams:SetLifespanMS(5000)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function MiniMap.ToggleShowInCombatSetting()
    if not MiniMap.SV then
        return
    end
    MiniMap.SV.allowDuringCombat = not MiniMap.SV.allowDuringCombat
    MiniMap.UpdateConditionalVisibility()
end

function MiniMap.ApplyDrawLayerPreference()
    if not MiniMap.view then
        return
    end
    local root = MiniMap.view.root
    if MiniMap.SV and MiniMap.SV.preferElevatedDrawTier == true then
        root:SetDrawLayer(DL_OVERLAY)
        root:SetDrawTier(DT_HIGH)
    else
        root:SetDrawLayer(DL_CONTROLS)
        root:SetDrawTier(DT_MEDIUM)
    end
end

function MiniMap.RegisterVisibilityEvents()
    local anchor = LUIE_MiniMap
    anchor:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, function ()
        MiniMap.UpdateConditionalVisibility()
    end)
    anchor:RegisterForEvent(EVENT_MOUNTED_STATE_CHANGED, function ()
        MiniMap.UpdateConditionalVisibility()
    end)
    anchor:RegisterForEvent(EVENT_HOUSING_PLAYER_INFO_CHANGED, function ()
        MiniMap.UpdateConditionalVisibility()
    end)
end
