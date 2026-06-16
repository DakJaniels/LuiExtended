-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

--- Tamriel in-game day length in real seconds (GetTimeStamp modulo; ESO standard 20955).
local MINIMAP_IN_GAME_SECONDS_PER_DAY = 20955
local MINIMAP_CLOCK_TICKER_SECONDS = 5

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

--- @param settings MiniMapDefaults
--- @return integer
local function GetRealClockFormatPrecision(settings)
    if settings.clockUse24Hour then
        return TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR
    end
    return TIME_FORMAT_PRECISION_TWELVE_HOUR
end

--- @param settings MiniMapDefaults
--- @return string
local function FormatRealClockSegment(settings)
    local clockPrecision = GetRealClockFormatPrecision(settings)
    return select(1, FormatTimeSeconds(
        GetSecondsSinceMidnight(),
        TIME_FORMAT_STYLE_CLOCK_TIME,
        clockPrecision,
        TIME_FORMAT_DIRECTION_NONE
    ))
end

--- @param settings MiniMapDefaults
--- @return string
local function FormatInGameClockSegment(settings)
    local clockPrecision = GetRealClockFormatPrecision(settings)
    local realWorldTimestampSeconds = GetTimeStamp()
    local inGameClockSecondsInDay = (realWorldTimestampSeconds % MINIMAP_IN_GAME_SECONDS_PER_DAY) * 86400 / MINIMAP_IN_GAME_SECONDS_PER_DAY
    return select(1, FormatTimeSeconds(
        inGameClockSecondsInDay,
        TIME_FORMAT_STYLE_CLOCK_TIME,
        clockPrecision,
        TIME_FORMAT_DIRECTION_NONE
    ))
end

--- @return string
function MiniMap.GetClockDisplayText()
    local settings = MiniMap.SV or MiniMap.Defaults
    local mode = settings.clockMode or 0
    if mode == 0 then
        return ""
    end
    local segments = {}
    if mode == 1 or mode == 3 then
        segments[#segments + 1] = FormatRealClockSegment(settings)
    end
    if mode == 2 or mode == 3 then
        segments[#segments + 1] = FormatInGameClockSegment(settings)
    end
    return table.concat(segments, "  ")
end

--- @return number delaySeconds
function MiniMap.GetClockTickerDelaySeconds()
    return MINIMAP_CLOCK_TICKER_SECONDS
end

function MiniMap.UpdateClockLabel()
    if not MiniMap.view or not MiniMap.view.clockLabel then
        return
    end
    local text = MiniMap.GetClockDisplayText()
    MiniMap.view.clockLabel:SetHidden(text == "")
    MiniMap.view.clockLabel:SetText(text)
end

function MiniMap.OnClockTickerUpdate()
    local now = GetFrameTimeSeconds()
    if MiniMap.clockNextUpdateSeconds and now < MiniMap.clockNextUpdateSeconds then
        return
    end
    MiniMap.UpdateClockLabel()
    MiniMap.clockNextUpdateSeconds = now + MiniMap.GetClockTickerDelaySeconds()
end

function MiniMap.StartClockTicker()
    if MiniMap.clockTickerActive then
        return
    end
    MiniMap.clockTickerActive = true
    MiniMap.clockNextUpdateSeconds = 0
    EVENT_MANAGER:RegisterForUpdate(MiniMap.moduleName .. "Clock", 0, function ()
        MiniMap.OnClockTickerUpdate()
    end)
    MiniMap.OnClockTickerUpdate()
end

function MiniMap.StopClockTicker()
    if not MiniMap.clockTickerActive then
        return
    end
    EVENT_MANAGER:UnregisterForUpdate(MiniMap.moduleName .. "Clock")
    MiniMap.clockTickerActive = false
    MiniMap.clockNextUpdateSeconds = nil
end

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
    if (MiniMap.SV.clockMode or 0) > 0 then
        MiniMap.StartClockTicker()
    else
        MiniMap.StopClockTicker()
        MiniMap.UpdateClockLabel()
    end
    MiniMap.ApplyCompassMode()
end
