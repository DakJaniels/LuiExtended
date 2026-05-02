-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Dynamic positioning / scaling for unit frames (resolution, aspect ratio)   --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

-- Baseline dimensions at 1080p (reference point for scaling)
local BASELINE_DIMENSIONS =
{
    player = { width = 300, height = 30 },
    reticleover = { width = 300, height = 36 },
    companion = { width = 220, height = 30 },
    SmallGroup1 = { width = 220, height = 30 },
    RaidGroup1 = { width = 220, height = 30 },
    PetGroup1 = { width = 220, height = 30 },
    boss1 = { width = 300, height = 36 },
    AvaPlayerTarget = { width = 300, height = 36 },
}

--- Scale a single coordinate pair by resolution and frame-dimension ratios
--- @param coords number[]
--- @param frameType string
--- @param baselineDimensions table
--- @param frameDimensions table
--- @param widthResolutionScale number
--- @param heightResolutionScale number
--- @param aspectRatioScale number
--- @return number[]
local function scaleCoords(coords, frameType, baselineDimensions, frameDimensions, widthResolutionScale, heightResolutionScale, aspectRatioScale)
    local baseline = baselineDimensions[frameType] or baselineDimensions.player
    local current = frameDimensions[frameType] or baseline
    local widthRatio = current.width / baseline.width
    local heightRatio = current.height / baseline.height
    local scaledX = coords[1] * widthResolutionScale * widthRatio
    local scaledY = coords[2] * zo_pow(heightResolutionScale, 1.2) * aspectRatioScale * heightRatio
    return { scaledX, scaledY }
end

--- Dynamically calculate frame positioning based on resolution with dimension compensation
--- Supports ultrawide (21:9), 16:10, and multi-monitor setups
--- @param screenWidth number UI canvas width in UI units
--- @param screenHeight number UI canvas height in UI units
--- @param baseCoords table<string, number[]> Base coordinate tables for 1080p reference
--- @param frameDimensions table<string, {width: number, height: number}> Current frame dimensions from saved variables
--- @return table<string, number[]> coords Calculated position coordinates for each frame type
--- @return {widthResolutionScale: number, heightResolutionScale: number, aspectRatioScale: number, isMultiMonitorLikely: boolean, actualAspectRatio: number} scaleFactors Debug scale factors
function UnitFrames.CalculateDynamicPositioning(screenWidth, screenHeight, baseCoords, frameDimensions)
    local aspectRatio = screenWidth / screenHeight
    local baseline169 = 16 / 9
    local maxAspectRatio = 2.45 -- Cap at ~21:9 (catches 32:9 and multi-monitor setups)

    local widthResolutionScale = screenWidth / 1920
    local heightResolutionScale = screenHeight / 1080
    local aspectRatioScale = aspectRatio / baseline169

    if UnitFrames.SV.AspectRatioOverride and UnitFrames.SV.AspectRatioOverride ~= 0 then
        aspectRatioScale = UnitFrames.SV.AspectRatioOverride
    end

    local isMultiMonitorLikely = aspectRatio > maxAspectRatio
    if isMultiMonitorLikely and (not UnitFrames.SV.AspectRatioOverride or UnitFrames.SV.AspectRatioOverride == 0) then
        local cappedAspectRatio = maxAspectRatio
        local cappedAspectRatioScale = cappedAspectRatio / baseline169
        aspectRatioScale = cappedAspectRatioScale
        widthResolutionScale = heightResolutionScale * (cappedAspectRatio / baseline169)
    end

    local function scale(coords, frameType)
        return scaleCoords(coords, frameType, BASELINE_DIMENSIONS, frameDimensions, widthResolutionScale, heightResolutionScale, aspectRatioScale)
    end

    local scaleFactors =
    {
        widthResolutionScale = widthResolutionScale,
        heightResolutionScale = heightResolutionScale,
        aspectRatioScale = aspectRatioScale,
        isMultiMonitorLikely = isMultiMonitorLikely,
        actualAspectRatio = aspectRatio,
    }

    return
        {
            player = scale(baseCoords.player, "player"),
            playerCenter = scale(baseCoords.playerCenter, "player"),
            reticleover = scale(baseCoords.reticleover, "reticleover"),
            reticleoverCenter = scale(baseCoords.reticleoverCenter, "reticleover"),
            companion = scale(baseCoords.companion, "companion"),
            SmallGroup1 = scale(baseCoords.SmallGroup1, "SmallGroup1"),
            RaidGroup1 = scale(baseCoords.RaidGroup1, "RaidGroup1"),
            PetGroup1 = scale(baseCoords.PetGroup1, "PetGroup1"),
            boss1 = scale(baseCoords.boss1, "boss1"),
            AvaPlayerTarget = scale(baseCoords.AvaPlayerTarget, "AvaPlayerTarget"),
        }, scaleFactors
end
