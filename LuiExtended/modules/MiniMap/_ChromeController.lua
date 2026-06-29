-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local MINIMAP_COMPASS_OVERRIDE_DEFAULT = 0
local MINIMAP_COMPASS_OVERRIDE_HIDE = 1
local MINIMAP_COMPASS_OVERRIDE_SHOW = 2

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
        _G[COMPASS_CONTROLS[controlIndex]]:SetHidden(compassControlsHidden)
    end
end

function MiniMap.ApplyCompassMode()
    local settings = MiniMap.SV
    local mode = settings.compassOverride or MINIMAP_COMPASS_OVERRIDE_DEFAULT
    if mode == MINIMAP_COMPASS_OVERRIDE_DEFAULT then
        if MiniMap.compassChromeOverrideActive then
            SetCompassControlsHidden(false)
            MiniMap.compassChromeOverrideActive = false
        end
        return
    end

    MiniMap.compassChromeOverrideActive = true
    local minimapContextAllowsCompassChrome = MiniMap.GetContextAllowsMiniMap()
    local compassControlsHidden = minimapContextAllowsCompassChrome and mode ~= MINIMAP_COMPASS_OVERRIDE_SHOW
    SetCompassControlsHidden(compassControlsHidden)
end

--- @param rootWidth number
--- @param rootHeight number
--- @param widthDriven boolean|nil When nil (e.g. settings toggle), use max(width, height).
--- @return number
function MiniMap.GetSquareRootSizeFromDimensions(rootWidth, rootHeight, widthDriven)
    local size
    if widthDriven == nil then
        size = zo_max(rootWidth, rootHeight)
    elseif widthDriven then
        size = rootWidth
    else
        size = rootHeight
    end
    return zo_max(size, 100)
end

--- @param widthDriven boolean|nil Driven resize axis from OnRootResizeStart; nil uses max for one-shot normalize.
function MiniMap.ApplySquareAspect(widthDriven)
    if not MiniMap.view then
        return
    end
    if MiniMap.SV.keepSquareAspect ~= true then
        return
    end
    local root = MiniMap.view.root
    local size = MiniMap.GetSquareRootSizeFromDimensions(root:GetWidth(), root:GetHeight(), widthDriven)
    root:SetDimensions(size, size)
    MiniMap.SV.width = size
    MiniMap.SV.height = size
    MiniMap.view:OnResizePersist()
end

--- @param settings MiniMapDefaults
function MiniMap.SnapFrameLayoutToPositionGrid(settings)
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
end

--- @param settings MiniMapDefaults
function MiniMap.ApplyPositionGridSnap(settings)
    if not settings then
        return
    end
    MiniMap.SnapFrameLayoutToPositionGrid(settings)
    MiniMap.ApplyFrameLayoutFromSavedSettings(true)
end

function MiniMap.ApplyZoneNameFont()
    if not MiniMap.view then
        return
    end
    local settings = MiniMap.SV
    local defaults = MiniMap.Defaults
    local faceKey = settings.zoneNameFontFace or defaults.zoneNameFontFace
    local fontSize = (settings.zoneNameFontSize and settings.zoneNameFontSize > 0) and settings.zoneNameFontSize or defaults.zoneNameFontSize
    local fontStyle = settings.zoneNameFontStyle or defaults.zoneNameFontStyle
    MiniMap.view.zone:SetFont(LUIE.Font.Resolve(faceKey, fontSize, fontStyle))
end

--- @param skipPositionGridSnap boolean|nil
function MiniMap.ApplyFrameLayoutFromSavedSettings(skipPositionGridSnap)
    if not MiniMap.view then
        return
    end
    local settings = MiniMap.SV
    if skipPositionGridSnap ~= true and settings.positionGridDivisor and settings.positionGridDivisor > 1 then
        MiniMap.SnapFrameLayoutToPositionGrid(settings)
    end
    settings.width = zo_max(settings.width or MiniMap.Defaults.width, 100)
    settings.height = zo_max(settings.height or MiniMap.Defaults.height, 100)
    MiniMap.view:ApplySavedLayout(settings)
    MiniMap.view:ApplyRootClientLayout(settings)
    if settings.keepSquareAspect == true then
        MiniMap.ApplySquareAspect(nil)
    end
    MiniMap.ApplyChromeStacking()
    local mapController = MiniMap.mapController
    if mapController and mapController:IsReady() then
        mapController:ClampZoomToLimits()
    end
end

function MiniMap.ApplyChromeFromSettings()
    if not MiniMap.view then
        return
    end
    MiniMap.ApplyDrawLayerPreference()
    MiniMap.view.background:SetAlpha(MiniMap.SV.borderOpacity)
    MiniMap.view:ApplyPlayerIconDimensions()
    MiniMap.ApplyCompassMode()
end
