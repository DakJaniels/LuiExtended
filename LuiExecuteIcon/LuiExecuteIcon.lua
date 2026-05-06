-- -----------------------------------------------------------------------------
--  LuiExecuteIcon
--  Standalone execute skull icon for reticle-over target frame.
--  Uses ZO_DeferredInitializingObject so the icon is anchored to the game's
--  target frame (or KhajiitFengShui's if enabled) only after the HUD is shown.
-- -----------------------------------------------------------------------------

local addonManager = GetAddOnManager()

--- @param addOnName string
--- @return boolean
local function IsAddOnEnabled(addOnName)
    if not addonManager:WasAddOnDetected(addOnName) then
        return false
    end
    local numAddOns = addonManager:GetNumAddOns()
    for i = 1, numAddOns do
        local name, _, _, _, _, state = addonManager:GetAddOnInfo(i)
        if name == addOnName and state == ADDON_STATE_ENABLED then
            return true
        end
    end
    return false
end

--- Resolve at runtime (when we anchor) so KhajiitFengShui is loaded if enabled.
--- Use KFS frame only when addon is enabled AND its reticleover frame is enabled in settings.
--- @return string controlName
local function GetTargetFrameName()
    if not IsAddOnEnabled("KhajiitFengShui") then
        return "ZO_TargetUnitFramereticleover"
    end
    local kfs = KhajiitFengShui_UnitFrames_SavedVariables
    if not kfs or not kfs.general or not kfs.general.context or not kfs.general.context.reticleover then
        return "ZO_TargetUnitFramereticleover"
    end
    if not kfs.general.context.reticleover.enabled then
        return "ZO_TargetUnitFramereticleover"
    end
    return "KFS_TargetUnitFramereticleover"
end

local eventManager = GetEventManager()
local ADDON_NAME = "LuiExecuteIcon"
local SV_NAME = "LuiExecuteIconSV"
local SV_VERSION = 1

-- Global namespace for settings callback
LuiExecuteIcon = {}
LuiExecuteIcon.Defaults =
{
    enableSkull = true,
    executeThreshold = 20,
}

--- @class LuiExecuteIconWindow : TopLevelWindow
--- @class LuiExecuteIconWindow_Skull : TextureControl

-- -----------------------------------------------------------------------------
-- LuiExecuteIconManager: deferred init + visibility logic
-- -----------------------------------------------------------------------------
--- @class LuiExecuteIconManager : ZO_DeferredInitializingObject
--- @field control LuiExecuteIconWindow
local LuiExecuteIconManager = ZO_DeferredInitializingObject:Subclass()

---
--- @param control LuiExecuteIconWindow
--- @return LuiExecuteIconManager
function LuiExecuteIconManager:New(control)
    local manager = ZO_Object.New(self)
    manager:Initialize(ZO_HUDFadeSceneFragment:New(control, 0, 0))
    manager.control = control
    return manager
end

function LuiExecuteIconManager:OnDeferredInitialize()
    local targetFrameName = GetTargetFrameName()
    local targetFrame = GetControl(targetFrameName)
    if not targetFrame then return end

    self.control:ClearAnchors()
    self.control:SetAnchor(RIGHT, targetFrame, LEFT, -8, 0)

    self.skullTexture = self.control:GetNamedChild("_Skull")
    if not self.skullTexture then return end

    self.cachedHealth = { 0, 1 }
    self.reticleoverHostile = false

    self.control:RegisterForEvent(EVENT_RETICLE_TARGET_CHANGED, function ()
        self:OnReticleTargetChanged()
    end)

    -- Use ZO_MostRecentEventHandler so power updates are processed correctly
    -- EVENT_POWER_UPDATE sends (eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    local function powerUpdateEquality(existingEventInfo, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
        local existingUnitTag = existingEventInfo[1]
        local existingPowerType = existingEventInfo[3]
        return existingUnitTag == unitTag and existingPowerType == powerType
    end
    local function powerUpdateHandler(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
        self:OnPowerUpdate(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    end
    ZO_MostRecentEventHandler:New(ADDON_NAME .. "Power", EVENT_POWER_UPDATE, powerUpdateEquality, powerUpdateHandler)

    self:OnReticleTargetChanged()
end

function LuiExecuteIconManager:OnShowing()
    self:UpdateVisibility()
end

function LuiExecuteIconManager:UpdateVisibility()
    if not self.control or not self.skullTexture or not LuiExecuteIcon.SV then return end

    local show = false
    if  LuiExecuteIcon.SV.enableSkull
    and DoesUnitExist("reticleover")
    and self.reticleoverHostile
    then
        local current = self.cachedHealth[1]
        local effectiveMax = self.cachedHealth[2]
        if current > 0 and effectiveMax > 0 then
            if 100 * current / effectiveMax <= LuiExecuteIcon.SV.executeThreshold then
                show = true
            end
        end
    end

    if show then
        self.control:SetHidden(false)
        self.skullTexture:SetHidden(false)
    else
        self.skullTexture:SetHidden(true)
        self.control:SetHidden(true)
    end
end

function LuiExecuteIconManager:OnReticleTargetChanged()
    if not DoesUnitExist("reticleover") then
        self.reticleoverHostile = false
        self.cachedHealth[1] = 0
        self.cachedHealth[2] = 1
        self:UpdateVisibility()
        return
    end

    self.reticleoverHostile = (GetUnitReaction("reticleover") == UNIT_REACTION_HOSTILE)
    local powerValue, powerMax, powerEffectiveMax = GetUnitPower("reticleover", COMBAT_MECHANIC_FLAGS_HEALTH)
    self.cachedHealth[1] = powerValue or 0
    self.cachedHealth[2] = (powerEffectiveMax and powerEffectiveMax > 0) and powerEffectiveMax or 1
    self:UpdateVisibility()
end

function LuiExecuteIconManager:OnPowerUpdate(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if unitTag ~= "reticleover" or powerType ~= COMBAT_MECHANIC_FLAGS_HEALTH then return end
    self.cachedHealth[1] = powerValue or 0
    self.cachedHealth[2] = (powerEffectiveMax and powerEffectiveMax > 0) and powerEffectiveMax or 1
    self:UpdateVisibility()
end

-- -----------------------------------------------------------------------------
-- Addon load: SavedVars + create manager + add fragment to HUD
-- -----------------------------------------------------------------------------

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    eventManager:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    LuiExecuteIcon.SV = ZO_SavedVars:NewAccountWide(SV_NAME, SV_VERSION, nil, LuiExecuteIcon.Defaults, GetWorldName())

    local window = GetControl("LuiExecuteIconWindow")
    if not window then return end

    local manager = LuiExecuteIconManager:New(window)
    LuiExecuteIcon.manager = manager

    LuiExecuteIcon.UpdateVisibility = function ()
        if LuiExecuteIcon.manager then
            LuiExecuteIcon.manager:UpdateVisibility()
        end
    end

    local sceneManager = SCENE_MANAGER
    local fragment = manager:GetFragment()
    sceneManager:GetScene("hud"):AddFragment(fragment)
    sceneManager:GetScene("hudui"):AddFragment(fragment)
    sceneManager:GetScene("siegeBar"):AddFragment(fragment)
    sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

    if not ZO_IsConsoleOrGameCoreUI() then
        LuiExecuteIcon.RegisterPCSettings()
    end
    if ZO_IsConsoleOrGameCoreUI() then
        LuiExecuteIcon.RegisterConsoleSettings()
    end
end

eventManager:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
