-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
if not UnitFrames then return end

-- Early return if LibGroupCombatStats is not available
if not LibGroupCombatStats then
    return
end

local UI = LUIE.UI

--- @class GroupCombatStatsManager
local GroupCombatStatsManager = {}
UnitFrames.GroupCombatStats = GroupCombatStatsManager

local lgcs
local isInitialized = false

-- Add combat stat displays to a custom frame
local function AddCombatStatsToFrame(frameData, isRaid)
    if not frameData or not frameData.control then return end

    local Settings = UnitFrames.SV
    if not Settings.GroupCombatStats.enabled then return end

    local backdrop = frameData[COMBAT_MECHANIC_FLAGS_HEALTH].backdrop
    if not backdrop then return end

    -- Create ultimate display if it doesn't exist
    if not frameData.combatStats then
        frameData.combatStats = {}

        -- Ultimate icons (frontbar and backbar) - anchor to right of health bar
        if Settings.GroupCombatStats.showUltimate then
            local iconSize = isRaid and Settings.GroupCombatStats.ultIconRaidSize or Settings.GroupCombatStats.ultIconGroupSize
            local iconInset = 1 -- Inset from backdrop
            local offsetX = isRaid and Settings.GroupCombatStats.ultIconRaidOffsetX or Settings.GroupCombatStats.ultIconGroupOffsetX
            local offsetY = isRaid and Settings.GroupCombatStats.ultIconRaidOffsetY or Settings.GroupCombatStats.ultIconGroupOffsetY

            -- FRONTBAR ULT (ult1)
            frameData.combatStats.ult1Backdrop = UI:Backdrop(frameData.control, nil, { iconSize, iconSize }, nil, { 0, 0, 0, 0.8 }, true)
            frameData.combatStats.ult1Backdrop:SetAnchor(LEFT, backdrop, RIGHT, offsetX, offsetY)
            frameData.combatStats.ult1Backdrop:SetDrawLayer(DL_BACKGROUND)
            frameData.combatStats.ult1Backdrop:SetDrawLevel(13)

            frameData.combatStats.ult1Icon = UI:Texture(frameData.combatStats.ult1Backdrop, { CENTER, CENTER }, { iconSize - 2, iconSize - 2 }, nil, DL_OVERLAY, false)
            frameData.combatStats.ult1Icon:SetDrawLevel(15)
            frameData.combatStats.ult1Icon:SetHidden(true)

            -- BACKBAR ULT (ult2)
            frameData.combatStats.ult2Backdrop = UI:Backdrop(frameData.control, nil, { iconSize, iconSize }, nil, { 0, 0, 0, 0.8 }, true)
            frameData.combatStats.ult2Backdrop:SetAnchor(LEFT, frameData.combatStats.ult1Backdrop, RIGHT, 1, 0)
            frameData.combatStats.ult2Backdrop:SetDrawLayer(DL_BACKGROUND)
            frameData.combatStats.ult2Backdrop:SetDrawLevel(13)

            frameData.combatStats.ult2Icon = UI:Texture(frameData.combatStats.ult2Backdrop, { CENTER, CENTER }, { iconSize - 2, iconSize - 2 }, nil, DL_OVERLAY, false)
            frameData.combatStats.ult2Icon:SetDrawLevel(15)
            frameData.combatStats.ult2Icon:SetHidden(true)
        end

        -- DPS/HPS text label (positioned below health bar on the right side)
        if Settings.GroupCombatStats.showDPS or Settings.GroupCombatStats.showHPS then
            local fontSize = isRaid and 12 or 14
            frameData.combatStats.statsLabel = UI:Label(backdrop, { TOPRIGHT, BOTTOMRIGHT, -2, 2 }, nil, { 0, 4 }, nil, "", false)
            frameData.combatStats.statsLabel:SetDrawLayer(DL_OVERLAY)
            frameData.combatStats.statsLabel:SetDrawLevel(15)
            frameData.combatStats.statsLabel:SetHidden(true)

            -- Apply font
            local fontFace = LUIE.Fonts[Settings.CustomFontFace]
            local fontStyle = Settings.CustomFontStyle
            frameData.combatStats.statsLabel:SetFont(string.format("%s|%d|%s", fontFace, fontSize, fontStyle))
        end
    end
end

-- Update ultimate icon and charge display
local function UpdateUltimateDisplay(unitTag, ultData)
    if not ultData then return end

    local frameData = UnitFrames.CustomFrames[unitTag]
    if not frameData or not frameData.combatStats then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("[LUIE GroupCombatStats] No frameData/combatStats for: " .. tostring(unitTag))
        -- end
        return
    end

    local Settings = UnitFrames.SV
    if not Settings.GroupCombatStats.showUltimate then return end

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
    local frameData = UnitFrames.CustomFrames[unitTag]
    if not frameData or not frameData.combatStats then return end

    local Settings = UnitFrames.SV
    local statsLabel = frameData.combatStats.statsLabel
    if not statsLabel then return end

    local showDPS = Settings.GroupCombatStats.showDPS and dpsData
    local showHPS = Settings.GroupCombatStats.showHPS and hpsData

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

-- Initialize LibGroupCombatStats integration
function GroupCombatStatsManager.Initialize()
    if isInitialized then return end

    local Settings = UnitFrames.SV
    if not Settings.GroupCombatStats.enabled then return end

    -- Determine which stats to request
    local neededStats = {}
    if Settings.GroupCombatStats.showUltimate then
        table.insert(neededStats, "ULT")
    end
    if Settings.GroupCombatStats.showDPS then
        table.insert(neededStats, "DPS")
    end
    if Settings.GroupCombatStats.showHPS then
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
    if Settings.GroupCombatStats.showUltimate then
        lgcs:RegisterForEvent(LibGroupCombatStats.EVENT_GROUP_ULT_UPDATE, function (unitTag, ultData)
            UpdateUltimateDisplay(unitTag, ultData)
        end)
    end

    -- Register for DPS updates
    if Settings.GroupCombatStats.showDPS then
        lgcs:RegisterForEvent(LibGroupCombatStats.EVENT_GROUP_DPS_UPDATE, function (unitTag, dpsData)
            local stats = lgcs:GetUnitStats(unitTag)
            if stats then
                UpdateCombatStatsText(unitTag, dpsData, stats.hps)
            end
        end)
    end

    -- Register for HPS updates
    if Settings.GroupCombatStats.showHPS then
        lgcs:RegisterForEvent(LibGroupCombatStats.EVENT_GROUP_HPS_UPDATE, function (unitTag, hpsData)
            local stats = lgcs:GetUnitStats(unitTag)
            if stats then
                UpdateCombatStatsText(unitTag, stats.dps, hpsData)
            end
        end)
    end

    -- Periodic update to refresh all displays with current data
    EVENT_MANAGER:RegisterForUpdate("LUIE_GroupCombatStats_Update", 1000, function ()
        if not IsUnitGrouped("player") then return end
        if not lgcs then return end

        -- Iterate over all group members by index (like TDAddon does)
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag then
                local stats = lgcs:GetUnitStats(unitTag)
                if stats and UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].combatStats then
                    -- Update ultimate display
                    if Settings.GroupCombatStats.showUltimate and stats.ult then
                        UpdateUltimateDisplay(unitTag, stats.ult)
                    end

                    -- Update DPS/HPS text
                    if Settings.GroupCombatStats.showDPS or Settings.GroupCombatStats.showHPS then
                        UpdateCombatStatsText(unitTag, stats.dps, stats.hps)
                    end
                end
            end
        end
    end)

    isInitialized = true
end

-- Setup combat stat displays on all frames
function GroupCombatStatsManager.SetupFrames()
    local Settings = UnitFrames.SV
    if not Settings.GroupCombatStats.enabled then return end

    -- Setup SmallGroup frames (always exist, whether in group or not)
    for i = 1, 4 do
        local unitTag = "SmallGroup" .. i
        local frameData = UnitFrames.CustomFrames[unitTag]
        if frameData and not frameData.combatStats then
            AddCombatStatsToFrame(frameData, false)
        end
    end

    -- Setup RaidGroup frames
    for i = 1, 12 do
        local unitTag = "RaidGroup" .. i
        local frameData = UnitFrames.CustomFrames[unitTag]
        if frameData and not frameData.combatStats then
            AddCombatStatsToFrame(frameData, true)
        end
    end
end

-- Refresh all combat stat displays (called from settings)
function GroupCombatStatsManager.RefreshAll()
    if not lgcs then return end
    if not IsUnitGrouped("player") then return end

    -- Iterate over all group members by index
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local stats = lgcs:GetUnitStats(unitTag)
            if stats and UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].combatStats then
                if stats.ult then
                    UpdateUltimateDisplay(unitTag, stats.ult)
                end
                if stats.dps or stats.hps then
                    UpdateCombatStatsText(unitTag, stats.dps, stats.hps)
                end
            end
        end
    end
end

-- Hide combat stats for a unit
function GroupCombatStatsManager.HideStats(unitTag)
    local frameData = UnitFrames.CustomFrames[unitTag]
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
