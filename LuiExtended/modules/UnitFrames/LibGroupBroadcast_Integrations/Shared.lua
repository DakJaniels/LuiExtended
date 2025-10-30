-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
if not UnitFrames then return end

--- @class LibGroupBroadcastShared
local Shared = {}
UnitFrames.LibGroupBroadcastShared = Shared

-- ============================================================================
-- SETTINGS GETTERS
-- ============================================================================

--- Get the main UnitFrames saved variables/settings
--- @return table Settings UnitFrames.SV
function Shared.GetSettings()
    return UnitFrames.SV
end

--- Get GroupCombatStats settings
--- @return table|nil GroupCombatStats settings or nil if not available
function Shared.GetCombatStatsSettings()
    local settings = UnitFrames.SV
    return settings and settings.GroupCombatStats
end

--- Get GroupPotionCooldowns settings
--- @return table|nil GroupPotionCooldowns settings or nil if not available
function Shared.GetPotionCooldownSettings()
    local settings = UnitFrames.SV
    return settings and settings.GroupPotionCooldowns
end

--- Get GroupResources settings
--- @return table|nil GroupResources settings or nil if not available
function Shared.GetResourceSettings()
    local settings = UnitFrames.SV
    return settings and settings.GroupResources
end

-- ============================================================================
-- FRAME DATA GETTERS
-- ============================================================================

--- Get frame data for a unit tag
--- @param unitTag string The unit tag (e.g., "SmallGroup1", "RaidGroup5")
--- @return table|nil frameData The frame data table or nil if not found
function Shared.GetFrameData(unitTag)
    if not unitTag then return nil end
    return UnitFrames.CustomFrames[unitTag]
end

--- Get frame data with validation (checks control exists)
--- @param unitTag string The unit tag
--- @return table|nil frameData The validated frame data or nil if invalid
function Shared.GetValidatedFrameData(unitTag)
    local frameData = Shared.GetFrameData(unitTag)
    if not frameData or not frameData.control then
        return nil
    end
    return frameData
end

--- Get health backdrop from frame data
--- @param frameData table The frame data table
--- @return table|nil backdrop The health backdrop control or nil if not found
function Shared.GetHealthBackdrop(frameData)
    if not frameData then return nil end
    local healthData = frameData[COMBAT_MECHANIC_FLAGS_HEALTH]
    return healthData and healthData.backdrop
end

-- ============================================================================
-- ITERATION HELPERS
-- ============================================================================

--- Iterate over all SmallGroup frame unit tags (1-4)
--- @param callback function Function called with (unitTag, frameData) for each frame
function Shared.ForEachSmallGroupFrame(callback)
    if not callback then return end
    for i = 1, 4 do
        local unitTag = "SmallGroup" .. i
        local frameData = Shared.GetFrameData(unitTag)
        if frameData then
            callback(unitTag, frameData)
        end
    end
end

--- Iterate over all RaidGroup frame unit tags (1-12)
--- @param callback function Function called with (unitTag, frameData) for each frame
function Shared.ForEachRaidGroupFrame(callback)
    if not callback then return end
    for i = 1, 12 do
        local unitTag = "RaidGroup" .. i
        local frameData = Shared.GetFrameData(unitTag)
        if frameData then
            callback(unitTag, frameData)
        end
    end
end

--- Iterate over all group/raid frames (SmallGroup 1-4, RaidGroup 1-12)
--- @param callback function Function called with (unitTag, frameData, isRaid) for each frame
function Shared.ForEachGroupFrame(callback)
    if not callback then return end
    Shared.ForEachSmallGroupFrame(function(unitTag, frameData)
        callback(unitTag, frameData, false)
    end)
    Shared.ForEachRaidGroupFrame(function(unitTag, frameData)
        callback(unitTag, frameData, true)
    end)
end

-- ============================================================================
-- VALIDATION HELPERS
-- ============================================================================

--- Check if frame data has a specific component
--- @param frameData table The frame data table
--- @param componentName string The component name to check (e.g., "combatStats", "potionCooldown")
--- @return boolean hasComponent True if component exists
function Shared.HasComponent(frameData, componentName)
    return frameData and frameData[componentName] ~= nil
end

--- Validate that frame data exists and has required components
--- @param frameData table The frame data table
--- @param requiredComponents table List of required component names
--- @return boolean isValid True if all required components exist
function Shared.ValidateFrameComponents(frameData, requiredComponents)
    if not frameData then return false end
    for _, componentName in ipairs(requiredComponents) do
        if not Shared.HasComponent(frameData, componentName) then
            return false
        end
    end
    return true
end

