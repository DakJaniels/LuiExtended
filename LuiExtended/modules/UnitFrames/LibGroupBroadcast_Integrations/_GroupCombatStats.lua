-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

-- Early return if LibGroupCombatStats is not available
if not LibGroupCombatStats then
    return
end

--- @class GroupCombatStatsManager
local GroupCombatStatsManager = {}
UnitFrames.GroupCombatStats = GroupCombatStatsManager

local Shared = UnitFrames.LibGroupBroadcastShared

local lgcs
local isInitialized = false
local isPlayerInCombat = false

-- Add combat stat displays to a custom frame
local function AddCombatStatsToFrame(frameData, isRaid)
    if not frameData or not frameData.control then return end

    -- Only create for SmallGroup frames, not RaidGroup
    if isRaid then return end

    local Settings = Shared.GetCombatStatsSettings()
    if not Settings or not Settings.enabled then return end

    local backdrop = Shared.GetHealthBackdrop(frameData)
    if not backdrop then return end

    -- Create ultimate display if it doesn't exist
    if not frameData.combatStats then
        frameData.combatStats = {}

        -- Get ultimate icons from XML
        if Settings.showUltimate then
            local iconSize = isRaid and Settings.ultIconRaidSize or Settings.ultIconGroupSize
            local offsetX = isRaid and Settings.ultIconRaidOffsetX or Settings.ultIconGroupOffsetX
            local offsetY = isRaid and Settings.ultIconRaidOffsetY or Settings.ultIconGroupOffsetY

            -- Get the container (already exists in XML)
            local container = frameData.libGroupContainer
            if not container then
                -- Fallback: get from control if not set in frameData
                container = frameData.control and frameData.control:GetNamedChild("_LibGroupContainer") or nil
                if container then
                    frameData.libGroupContainer = container
                else
                    return -- Can't proceed without container
                end
            end

            -- Anchor container to health bar if not already anchored
            local numAnchors = container:GetNumAnchors()
            if numAnchors == 0 then
                container:SetAnchor(LEFT, backdrop, RIGHT, offsetX, offsetY)
            end

            -- Get ult controls from XML
            frameData.combatStats.ult1Backdrop = container:GetNamedChild("_Ult1Backdrop")
            if not frameData.combatStats.ult1Backdrop then
                return -- Can't proceed without ult controls
            end
            frameData.combatStats.ult1Icon = frameData.combatStats.ult1Backdrop:GetNamedChild("_Icon")
            frameData.combatStats.ult2Backdrop = container:GetNamedChild("_Ult2Backdrop")
            if not frameData.combatStats.ult2Backdrop then
                return -- Can't proceed without ult controls
            end
            frameData.combatStats.ult2Icon = frameData.combatStats.ult2Backdrop:GetNamedChild("_Icon")

            -- Set dimensions and anchors based on settings
            frameData.combatStats.ult1Backdrop:SetDimensions(iconSize, iconSize)
            frameData.combatStats.ult1Icon:SetDimensions(iconSize - 2, iconSize - 2)
            frameData.combatStats.ult2Backdrop:SetDimensions(iconSize, iconSize)
            frameData.combatStats.ult2Icon:SetDimensions(iconSize - 2, iconSize - 2)

            -- Anchor within container (order: food/drink -> ult1 -> ult2)
            frameData.combatStats.ult1Backdrop:ClearAnchors()
            if frameData.foodDrinkBuff and frameData.foodDrinkBuff.backdrop then
                frameData.combatStats.ult1Backdrop:SetAnchor(LEFT, frameData.foodDrinkBuff.backdrop, RIGHT, 3, 0)
            else
                frameData.combatStats.ult1Backdrop:SetAnchor(LEFT, container, LEFT, 0, 0)
            end

            frameData.combatStats.ult2Backdrop:ClearAnchors()
            frameData.combatStats.ult2Backdrop:SetAnchor(LEFT, frameData.combatStats.ult1Backdrop, RIGHT, 3, 0)

            -- Set draw properties
            frameData.combatStats.ult1Backdrop:SetDrawLayer(DL_BACKGROUND)
            frameData.combatStats.ult1Backdrop:SetDrawLevel(13)
            frameData.combatStats.ult1Icon:SetDrawLevel(15)

            frameData.combatStats.ult2Backdrop:SetDrawLayer(DL_BACKGROUND)
            frameData.combatStats.ult2Backdrop:SetDrawLevel(13)
            frameData.combatStats.ult2Icon:SetDrawLevel(15)
        end

        -- Get DPS/HPS text label from XML (SmallGroup only)
        if Settings.showDPS or Settings.showHPS then
            local fontSize = 14

            -- Get from health backdrop
            frameData.combatStats.statsLabel = backdrop:GetNamedChild("_StatsLabel")
            if not frameData.combatStats.statsLabel then
                return -- Can't proceed without stats label
            end

            -- Set draw properties
            frameData.combatStats.statsLabel:SetDrawLayer(DL_OVERLAY)
            frameData.combatStats.statsLabel:SetDrawLevel(15)

            -- Apply font
            local rootSettings = Shared.GetSettings()
            local fontFace = LUIE.Fonts[rootSettings.CustomFontFace]
            local fontStyle = rootSettings.CustomFontStyle
            frameData.combatStats.statsLabel:SetFont(LUIE.CreateFontString(fontFace, fontSize, fontStyle))
        end
    end
end

-- Update ultimate icon and charge display
local function UpdateUltimateDisplay(unitTag, ultData)
    if not ultData then return end

    local frameData = Shared.GetFrameData(unitTag)
    if not frameData or not frameData.combatStats then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("[LUIE GroupCombatStats] No frameData/combatStats for: " .. tostring(unitTag))
        -- end
        return
    end

    local Settings = Shared.GetCombatStatsSettings()
    if not Settings or not Settings.showUltimate then return end

    local ultValue = ultData.ultValue or 0

    -- if LUIE.IsDevDebugEnabled() then
    --     LUIE.Debug("[LUIE GroupCombatStats] UpdateUltimate: " .. unitTag .. " value=" .. ultValue .. " ult1ID=" .. (ultData.ult1ID or 0) .. " ult1Cost=" .. (ultData.ult1Cost or 0))
    -- end

    -- Helper to update a single ult icon
    local function updateSingleUlt(ultNum)
        local iconControl = frameData.combatStats["ult" .. ultNum .. "Icon"]
        local backdropControl = frameData.combatStats["ult" .. ultNum .. "Backdrop"]

        if not iconControl or not backdropControl then return end

        local ultAbilityId = ultData["ult" .. ultNum .. "ID"] or 0
        local ultCost = ultData["ult" .. ultNum .. "Cost"] or 0

        -- Show icon if we have a valid ability
        if ultAbilityId and ultAbilityId > 0 then
            local ultTexture = GetAbilityIcon(ultAbilityId)
            if ultTexture and ultTexture ~= "" and ultTexture ~= "/esoui/art/icons/icon_missing.dds" then
                iconControl:SetTexture(ultTexture)
                iconControl:SetHidden(false)
                backdropControl:SetHidden(false)

                -- Visual status indication via backdrop color and icon saturation
                if ultCost > 0 and ultValue >= ultCost then
                    -- Ready - gold tint backdrop, full color icon
                    backdropControl:SetCenterColor(0.3, 0.2, 0, 0.9)
                    iconControl:SetColor(1, 1, 1, 1)
                    iconControl:SetDesaturation(0)
                else
                    -- Not ready - dark backdrop, desaturated dimmed icon
                    backdropControl:SetCenterColor(0, 0, 0, 0.8)
                    iconControl:SetColor(0.6, 0.6, 0.6, 1)
                    iconControl:SetDesaturation(0.8)
                end

                return true
            end
        end

        -- Hide if no valid ult
        iconControl:SetHidden(true)
        backdropControl:SetHidden(true)
        return false
    end

    -- Update both ults
    local ult1Visible = updateSingleUlt(1)
    local ult2Visible = updateSingleUlt(2)

    -- If both ults are the same, hide the second one
    if ult1Visible and ult2Visible then
        local ult1ID = ultData.ult1ID or 0
        local ult2ID = ultData.ult2ID or 0
        if ult1ID == ult2ID then
            frameData.combatStats.ult2Icon:SetHidden(true)
            frameData.combatStats.ult2Backdrop:SetHidden(true)
        end
    end
end

-- Update DPS/HPS text display
local function UpdateCombatStatsText(unitTag, dpsData, hpsData)
    local frameData = Shared.GetFrameData(unitTag)
    if not frameData or not frameData.combatStats then return end

    local Settings = Shared.GetCombatStatsSettings()
    if not Settings then return end

    local statsLabel = frameData.combatStats.statsLabel
    if not statsLabel then return end

    local showDPS = Settings.showDPS and dpsData
    local showHPS = Settings.showHPS and hpsData

    if not showDPS and not showHPS then
        statsLabel:SetHidden(true)
        return
    end

    local textParts = {}

    if showDPS and dpsData.dps and dpsData.dps > 0 then
        -- Format DPS (comes in thousands, e.g., 45.5 = 45.5k DPS)
        local dpsText = string.format("%.1fk", dpsData.dps)
        table.insert(textParts, string.format("|cFF4444%s|r", dpsText)) -- Red for DPS
    end

    if showHPS and hpsData.hps and hpsData.hps > 0 then
        -- Format HPS (comes in thousands)
        local hpsText = string.format("%.1fk", hpsData.hps)
        table.insert(textParts, string.format("|c44FF44%s|r", hpsText)) -- Green for HPS
    end

    if #textParts > 0 then
        statsLabel:SetText(table.concat(textParts, " "))
        statsLabel:SetHidden(false)
    else
        statsLabel:SetHidden(true)
    end
end

-- Hide all DPS/HPS stat labels (called after 6s out of combat)
local function HideAllCombatStatsText()
    Shared.ForEachGroupFrame(function (unitTag, frameData)
        if frameData.combatStats and frameData.combatStats.statsLabel then
            frameData.combatStats.statsLabel:SetHidden(true)
        end
    end)
end

-- Handle combat state changes
local function OnCombatStateChanged(eventCode, inCombat)
    isPlayerInCombat = inCombat

    if inCombat then
        -- Entering combat - cancel any pending hide timer
        EVENT_MANAGER:UnregisterForUpdate("LUIE_GroupCombatStats_HideDelay")
    else
        -- Exiting combat - schedule stats to hide after 6 seconds
        EVENT_MANAGER:RegisterForUpdate("LUIE_GroupCombatStats_HideDelay", 6000, function ()
            HideAllCombatStatsText()
            EVENT_MANAGER:UnregisterForUpdate("LUIE_GroupCombatStats_HideDelay")
        end)
    end
end

-- Initialize LibGroupCombatStats integration
function GroupCombatStatsManager.Initialize()
    if isInitialized then return end

    local Settings = Shared.GetCombatStatsSettings()
    if not Settings or not Settings.enabled then return end

    -- Determine which stats to request
    local neededStats = {}
    if Settings.showUltimate then
        table.insert(neededStats, "ULT")
    end
    if Settings.showDPS then
        table.insert(neededStats, "DPS")
    end
    if Settings.showHPS then
        table.insert(neededStats, "HPS")
    end

    if #neededStats == 0 then
        return -- Nothing enabled
    end

    -- Register with LibGroupCombatStats
    lgcs = LibGroupCombatStats.RegisterAddon("LuiExtended", neededStats)
    if not lgcs then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Error("[LUIE] Failed to register with LibGroupCombatStats")
        -- end
        return
    end

    -- Register for ultimate updates
    if Settings.showUltimate then
        lgcs:RegisterForEvent(LibGroupCombatStats.EVENT_GROUP_ULT_UPDATE, function (unitTag, ultData)
            UpdateUltimateDisplay(unitTag, ultData)
        end)
    end

    -- Register for DPS updates
    if Settings.showDPS then
        lgcs:RegisterForEvent(LibGroupCombatStats.EVENT_GROUP_DPS_UPDATE, function (unitTag, dpsData)
            local stats = lgcs:GetUnitStats(unitTag)
            if stats then
                UpdateCombatStatsText(unitTag, dpsData, stats.hps)
            end
        end)
    end

    -- Register for HPS updates
    if Settings.showHPS then
        lgcs:RegisterForEvent(LibGroupCombatStats.EVENT_GROUP_HPS_UPDATE, function (unitTag, hpsData)
            local stats = lgcs:GetUnitStats(unitTag)
            if stats then
                UpdateCombatStatsText(unitTag, stats.dps, hpsData)
            end
        end)
    end

    -- Register for combat state changes
    EVENT_MANAGER:RegisterForEvent("LUIE_GroupCombatStats_Combat", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)

    -- Periodic update to refresh all displays with current data
    EVENT_MANAGER:RegisterForUpdate("LUIE_GroupCombatStats_Update", 1000, function ()
        if not IsUnitGrouped("player") then return end
        if not lgcs then return end

        local currentSettings = Shared.GetCombatStatsSettings()
        if not currentSettings then return end

        -- Iterate over active group members
        Shared.ForEachActiveGroupMember(function (unitTag, frameData)
            local stats = lgcs:GetUnitStats(unitTag)
            if stats and frameData.combatStats then
                -- Update ultimate display
                if currentSettings.showUltimate and stats.ult then
                    UpdateUltimateDisplay(unitTag, stats.ult)
                end

                -- Update DPS/HPS text
                if currentSettings.showDPS or currentSettings.showHPS then
                    UpdateCombatStatsText(unitTag, stats.dps, stats.hps)
                end
            end
        end)
    end)

    isInitialized = true
end

-- Setup combat stat displays on all frames
function GroupCombatStatsManager.SetupFrames()
    local Settings = Shared.GetCombatStatsSettings()
    if not Settings or not Settings.enabled then return end

    -- Use shared frame setup helper with unhide callback
    Shared.SetupIntegrationFrames("combatStats", AddCombatStatsToFrame, function (frameData)
        -- Unhide container when reusing SmallGroup frames
        if frameData.libGroupContainer then
            frameData.libGroupContainer:SetHidden(false)
        end
        -- Components will be updated by the periodic update loop and event callbacks
    end)
end

-- Refresh all combat stat displays (called from settings)
function GroupCombatStatsManager.RefreshAll()
    if not lgcs then return end
    if not IsUnitGrouped("player") then return end

    -- Iterate over active group members
    Shared.ForEachActiveGroupMember(function (unitTag, frameData)
        local stats = lgcs:GetUnitStats(unitTag)
        if stats and frameData.combatStats then
            if stats.ult then
                UpdateUltimateDisplay(unitTag, stats.ult)
            end
            if stats.dps or stats.hps then
                UpdateCombatStatsText(unitTag, stats.dps, stats.hps)
            end
        end
    end)
end

-- Hide combat stats for a unit
function GroupCombatStatsManager.HideStats(unitTag)
    local frameData = Shared.GetFrameData(unitTag)
    if not frameData or not frameData.combatStats then return end

    -- Hide ult1
    if frameData.combatStats.ult1Icon then
        frameData.combatStats.ult1Icon:SetHidden(true)
    end
    if frameData.combatStats.ult1Backdrop then
        frameData.combatStats.ult1Backdrop:SetHidden(true)
    end

    -- Hide ult2
    if frameData.combatStats.ult2Icon then
        frameData.combatStats.ult2Icon:SetHidden(true)
    end
    if frameData.combatStats.ult2Backdrop then
        frameData.combatStats.ult2Backdrop:SetHidden(true)
    end

    -- Hide stats label
    if frameData.combatStats.statsLabel then
        frameData.combatStats.statsLabel:SetHidden(true)
    end
end
