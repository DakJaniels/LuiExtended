-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local COMPASS_MODE_UNTOUCHED = 0
local COMPASS_MODE_HIDDEN = 1
local COMPASS_MODE_SHOWN = 2

local COMPASS_CONTROLS =
{
    "ZO_CompassCenterOverPinLabel",
    "ZO_CompassContainer",
    "ZO_CompassFrameLeft",
    "ZO_CompassFrameCenter",
    "ZO_CompassFrameRight",
}

local function SetCompassControlsHidden(compassControlsHidden)
    for controlIndex = 1, #COMPASS_CONTROLS do
        local compassControl = _G[COMPASS_CONTROLS[controlIndex]]
        if compassControl then
            compassControl:SetHidden(compassControlsHidden)
        end
    end
end

function MiniMap.ApplyCompassMode()
    local settings = MiniMap.SV or MiniMap.Defaults
    local mode = settings.compassMode or COMPASS_MODE_UNTOUCHED
    if mode == COMPASS_MODE_UNTOUCHED then
        if MiniMap.compassChromeOverrideActive then
            SetCompassControlsHidden(false)
            MiniMap.compassChromeOverrideActive = false
        end
        return
    end

    MiniMap.compassChromeOverrideActive = true
    local minimapContextAllowsCompassChrome = MiniMap.GetContextAllowsMiniMap()
    local compassControlsHidden = minimapContextAllowsCompassChrome and mode ~= COMPASS_MODE_SHOWN
    SetCompassControlsHidden(compassControlsHidden)
end

function MiniMap.ApplySquareAspect()
    if not MiniMap.view or not MiniMap.SV then
        return
    end
    if MiniMap.SV.keepSquareAspect ~= true then
        return
    end
    local root = MiniMap.view.root
    local size = zo_max(root:GetWidth(), root:GetHeight())
    root:SetDimensions(size, size)
    MiniMap.SV.width = size
    MiniMap.SV.height = size
    MiniMap.view:OnResizePersist()
end

--- @param settings MiniMapDefaults
function MiniMap.ApplyPositionGridSnap(settings)
    if not MiniMap.view or not settings.positionGridDivisor or settings.positionGridDivisor <= 1 then
        return
    end
    local divisor = settings.positionGridDivisor
    local root = MiniMap.view.root
    local width = zo_round(root:GetWidth() / divisor) * divisor
    local height = zo_round(root:GetHeight() / divisor) * divisor
    local offsetX = zo_round(settings.offsetX / divisor) * divisor
    local offsetY = zo_round(settings.offsetY / divisor) * divisor
    settings.width = zo_max(width, 100)
    settings.height = zo_max(height, 100)
    settings.offsetX = offsetX
    settings.offsetY = offsetY
    MiniMap.view:ApplySavedLayout(settings)
end

function MiniMap.ApplyChromeFromSettings()
    if not MiniMap.view or not MiniMap.SV then
        return
    end
    MiniMap.ApplyDrawLayerPreference()
    if MiniMap.view.background and MiniMap.SV.borderOpacity then
        MiniMap.view.background:SetAlpha(MiniMap.SV.borderOpacity)
    end
    MiniMap.view:ApplyPlayerIconDimensions()
    MiniMap.ApplyCompassMode()
end
