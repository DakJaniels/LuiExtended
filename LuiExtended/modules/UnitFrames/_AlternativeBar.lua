-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local moduleName = UnitFrames.moduleName
local eventManager = GetEventManager()

local XP_BAR_COLORS = ZO_XP_BAR_GRADIENT_COLORS[2]
local CP_BAR_COLORS = ZO_CP_BAR_GRADIENT_COLORS

local g_PendingUpdateChampionXP = { flag = false, delay = 5000, name = moduleName .. "PendingChampionXP" }

local TOOLTIP_POWER_NAMESPACE_WEREWOLF = moduleName .. "TooltipPowerWerewolf"
local TOOLTIP_POWER_NAMESPACE_MOUNT = moduleName .. "TooltipPowerMount"
local TOOLTIP_POWER_NAMESPACE_SIEGE = moduleName .. "TooltipPowerSiege"

function UnitFrames.AltBar_OnMouseEnterXP(control)
    local isChampion = IsUnitChampion("player")
    local level
    local current
    local levelSize
    local label
    local isMax = false
    if isChampion then
        level = GetPlayerChampionPointsEarned()
        current = GetPlayerChampionXP()
        levelSize = GetNumChampionXPInChampionPoint(level)
        if levelSize == nil then
            levelSize = current
            isMax = true
        end
        label = GetString(SI_EXPERIENCE_CHAMPION_LABEL)
    else
        level = GetUnitLevel("player")
        current = GetUnitXP("player")
        levelSize = GetUnitXPMax("player")
        label = GetString(SI_EXPERIENCE_LEVEL_LABEL)
    end
    local percentageXP = zo_floor(current / levelSize * 100)
    local enlightenedPool = GetEnlightenedPool()
    local enlightenedValue = enlightenedPool > 0 and ZO_CommaDelimitNumber(4 * enlightenedPool)

    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -10)

    SetTooltipText(InformationTooltip, zo_strformat(SI_LEVEL_DISPLAY, label, level))
    if isMax then
        InformationTooltip:AddLine(GetString(SI_EXPERIENCE_LIMIT_REACHED))
    else
        InformationTooltip:AddLine(zo_strformat(SI_EXPERIENCE_CURRENT_MAX_PERCENT, ZO_CommaDelimitNumber(current), ZO_CommaDelimitNumber(levelSize), percentageXP))
        if enlightenedPool > 0 then
            InformationTooltip:AddLine(zo_strformat(SI_EXPERIENCE_CHAMPION_ENLIGHTENED_TOOLTIP, enlightenedValue), nil, ZO_SUCCEEDED_TEXT:UnpackRGB())
        end
    end
end

function UnitFrames.AltBar_OnMouseEnterWerewolf(control)
    local function UpdateWerewolfPower()
        local currentPower, maxPower = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
        local percentagePower = zo_floor(currentPower / maxPower * 100)

        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -10)
        SetTooltipText(InformationTooltip, zo_strformat(SI_MONSTERSOCIALCLASS45))
        InformationTooltip:AddLine(zo_strformat(LUIE_STRING_UF_WEREWOLF_POWER, currentPower, maxPower, percentagePower))
    end
    UpdateWerewolfPower()

    eventManager:RegisterForEvent(TOOLTIP_POWER_NAMESPACE_WEREWOLF, EVENT_POWER_UPDATE, UpdateWerewolfPower)
    eventManager:AddFilterForEvent(TOOLTIP_POWER_NAMESPACE_WEREWOLF, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_WEREWOLF, REGISTER_FILTER_UNIT_TAG, "player")
end

function UnitFrames.AltBar_OnMouseEnterMounted(control)
    local function UpdateMountPower()
        local currentPower, maxPower = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA)
        local percentagePower = zo_floor(currentPower / maxPower * 100)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -10)

        SetTooltipText(InformationTooltip, zo_strformat(LUIE_STRING_SKILL_MOUNTED))
        InformationTooltip:AddLine(zo_strformat(LUIE_STRING_UF_MOUNT_POWER, currentPower, maxPower, percentagePower))
    end
    UpdateMountPower()

    eventManager:RegisterForEvent(TOOLTIP_POWER_NAMESPACE_MOUNT, EVENT_POWER_UPDATE, UpdateMountPower)
    eventManager:AddFilterForEvent(TOOLTIP_POWER_NAMESPACE_MOUNT, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA, REGISTER_FILTER_UNIT_TAG, "player")
end

function UnitFrames.AltBar_OnMouseEnterSiege(control)
    local function UpdateSiegePower()
        local currentPower, maxPower = GetUnitPower("controlledsiege", COMBAT_MECHANIC_FLAGS_HEALTH)
        local percentagePower = zo_floor(currentPower / maxPower * 100)
        local siegeName = GetUnitName("controlledsiege")
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -10)

        SetTooltipText(InformationTooltip, zo_strformat("<<C:1>>", siegeName))
        InformationTooltip:AddLine(zo_strformat(LUIE_STRING_UF_SIEGE_POWER, ZO_CommaDelimitNumber(currentPower), ZO_CommaDelimitNumber(maxPower), percentagePower))
    end
    UpdateSiegePower()

    eventManager:RegisterForEvent(TOOLTIP_POWER_NAMESPACE_SIEGE, EVENT_POWER_UPDATE, UpdateSiegePower)
    eventManager:AddFilterForEvent(TOOLTIP_POWER_NAMESPACE_SIEGE, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH, REGISTER_FILTER_UNIT_TAG, "controlledsiege")
end

function UnitFrames.AltBar_OnMouseExit(control)
    ClearTooltip(InformationTooltip)
    eventManager:UnregisterForEvent(TOOLTIP_POWER_NAMESPACE_WEREWOLF, EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(TOOLTIP_POWER_NAMESPACE_MOUNT, EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(TOOLTIP_POWER_NAMESPACE_SIEGE, EVENT_POWER_UPDATE)
end

local function CustomFramesClearAltBarReferences(player)
    player[COMBAT_MECHANIC_FLAGS_WEREWOLF] = nil
    UnitFrames.CustomFrames["controlledsiege"][COMBAT_MECHANIC_FLAGS_HEALTH] = nil
    player[COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = nil
    player.ChampionXP = nil
    player.Experience = nil
    UnitFrames.ClearPowerUpdateSnapshot("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
    UnitFrames.ClearPowerUpdateSnapshot("player", COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA)
    UnitFrames.ClearPowerUpdateSnapshot("controlledsiege", COMBAT_MECHANIC_FLAGS_HEALTH)
end

local function CustomFramesApplyAltBarPowerUpdate(unitTag, powerType)
    UnitFrames.ClearPowerUpdateSnapshot(unitTag, powerType)
    local powerValue, powerMax, powerEffectiveMax = GetUnitPower(unitTag, powerType)
    UnitFrames.UpdateCustomFramePower(unitTag, powerType, powerValue, powerMax, powerEffectiveMax, false, true)
end

local function CustomFramesSetupAltBarInteraction(alt, mouseEnterHandler, showEnlightenment)
    alt.bar:SetMouseEnabled(mouseEnterHandler ~= nil)
    if mouseEnterHandler then
        alt.bar:SetHandler("OnMouseEnter", mouseEnterHandler)
        alt.bar:SetHandler("OnMouseExit", UnitFrames.AltBar_OnMouseExit)
    end
    alt.enlightenment:SetHidden(not showEnlightenment)
end

local function CustomFramesGetAltBarPositioningMode(preferRight)
    if UnitFrames.SV.PlayerFrameOptions ~= 1 then
        if preferRight then
            return UnitFrames.SV.ReverseResourceBars and "left" or "right"
        else
            return UnitFrames.SV.ReverseResourceBars and "right" or "left"
        end
    end
    return "recenter"
end

local function CustomFramesPositionAltBar(player, alt, altW, padding, botInfoAnchorPoint, botInfoAnchorTarget, altAnchorPoint, altXOffset, iconAnchorPoint, iconXOffset)
    player.botInfo:SetAnchor(TOP, botInfoAnchorTarget, botInfoAnchorPoint, 0, 2)
    alt.backdrop:ClearAnchors()
    alt.backdrop:SetAnchor(altAnchorPoint or CENTER, player.botInfo, altAnchorPoint or CENTER, altXOffset or (padding * 0.5 + 1), 0)
    alt.backdrop:SetWidth(altW)
    alt.icon:ClearAnchors()
    alt.icon:SetAnchor(iconAnchorPoint, alt.backdrop, iconAnchorPoint == RIGHT and LEFT or RIGHT, iconXOffset or (iconAnchorPoint == RIGHT and -2 or 2), 0)
end

-- Priority: Werewolf -> Siege -> Mount -> ChampionXP / Experience
--- @param isWerewolf boolean|nil
--- @param isSiege boolean|nil
--- @param isMounted boolean|nil
function UnitFrames.CustomFramesSetupAlternative(isWerewolf, isSiege, isMounted)
    if not UnitFrames.CustomFrames["player"] then
        return
    end

    -- Nil axes query live; explicit false from event handlers must not use `x or query()`.
    if isWerewolf == nil then
        isWerewolf = IsPlayerInWerewolfForm()
    end
    if isSiege == nil then
        isSiege = IsPlayerControllingSiegeWeapon() or IsPlayerEscortingRam()
    end
    if isMounted == nil then
        isMounted = IsMounted()
    end

    local player = UnitFrames.CustomFrames["player"]
    local alt = player.alternative

    local mode, icon, center, color, positionMode

    if UnitFrames.SV.PlayerEnableAltbarMSW and isWerewolf then
        mode = "werewolf"
        icon = [[/esoui/art/armory/buildicons/buildicon_45.dds]]
        center = { 0.05, 0, 0, 0.9 }
        color = { 0.8, 0, 0, 0.9 }
        positionMode = CustomFramesGetAltBarPositioningMode(false)

        CustomFramesClearAltBarReferences(player)
        player[COMBAT_MECHANIC_FLAGS_WEREWOLF] = alt

        CustomFramesApplyAltBarPowerUpdate("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
        CustomFramesSetupAltBarInteraction(alt, UnitFrames.AltBar_OnMouseEnterWerewolf, false)
    elseif UnitFrames.SV.PlayerEnableAltbarMSW and isSiege then
        mode = "siege"
        icon = [[/esoui/art/armory/buildicons/buildicon_37.dds]]
        center = { 0.05, 0, 0, 0.9 }
        color = { 0.8, 0, 0, 0.9 }
        positionMode = "recenter"

        CustomFramesClearAltBarReferences(player)
        UnitFrames.CustomFrames["controlledsiege"][COMBAT_MECHANIC_FLAGS_HEALTH] = alt

        CustomFramesApplyAltBarPowerUpdate("controlledsiege", COMBAT_MECHANIC_FLAGS_HEALTH)
        CustomFramesSetupAltBarInteraction(alt, UnitFrames.AltBar_OnMouseEnterSiege, false)
    elseif UnitFrames.SV.PlayerEnableAltbarMSW and isMounted then
        mode = "mount"
        icon = [[/esoui/art/icons/servicemappins/servicepin_stable.dds]]
        center =
        {
            0.1 * UnitFrames.SV.CustomColourStamina[1],
            0.1 * UnitFrames.SV.CustomColourStamina[2],
            0.1 * UnitFrames.SV.CustomColourStamina[3],
            0.9
        }
        color =
        {
            UnitFrames.SV.CustomColourStamina[1],
            UnitFrames.SV.CustomColourStamina[2],
            UnitFrames.SV.CustomColourStamina[3],
            0.9
        }
        positionMode = CustomFramesGetAltBarPositioningMode(true)

        CustomFramesClearAltBarReferences(player)
        player[COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA] = alt

        CustomFramesApplyAltBarPowerUpdate("player", COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA)
        CustomFramesSetupAltBarInteraction(alt, UnitFrames.AltBar_OnMouseEnterMounted, false)
    elseif UnitFrames.SV.PlayerEnableAltbarXP and (player.isLevelCap or player.isChampion) then
        mode = "championXP"
        positionMode = "recenter"

        CustomFramesClearAltBarReferences(player)
        player.ChampionXP = alt --[[@as LUIE_Player_Health|LUIE_Player_Resource]]

        UnitFrames.OnChampionPointGained()

        local enlightenedPool = 4 * GetEnlightenedPool()
        local xp = GetPlayerChampionXP()
        local maxBar = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned()) or xp
        local enlightenedBar = zo_min(enlightenedPool + xp, maxBar)

        player.ChampionXP.enlightenment:SetMinMax(0, maxBar)
        player.ChampionXP.enlightenment:SetValue(enlightenedBar)
        player.ChampionXP.bar:SetMinMax(0, maxBar)
        player.ChampionXP.bar:SetValue(xp)

        CustomFramesSetupAltBarInteraction(alt, UnitFrames.AltBar_OnMouseEnterXP, true)
    elseif UnitFrames.SV.PlayerEnableAltbarXP then
        mode = "experience"
        if IsInGamepadPreferredMode() then
            icon = ZO_GetGamepadDungeonDifficultyIcon(DUNGEON_DIFFICULTY_NORMAL)
        else
            icon = ZO_GetKeyboardDungeonDifficultyIcon(DUNGEON_DIFFICULTY_NORMAL)
        end
        center = { 0, 0.1, 0.1, 0.9 }
        color = { XP_BAR_COLORS.r, XP_BAR_COLORS.g, XP_BAR_COLORS.b, 0.9 }
        positionMode = "recenter"

        CustomFramesClearAltBarReferences(player)
        player.Experience = alt --[[@as LUIE_Player_Health|LUIE_Player_Resource]]

        local championXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned()) or GetPlayerChampionXP()
        player.Experience.bar:SetMinMax(0, player.isChampion and championXP or GetUnitXPMax("player"))
        player.Experience.bar:SetValue(player.isChampion and GetPlayerChampionXP() or GetUnitXP("player"))

        CustomFramesSetupAltBarInteraction(alt, UnitFrames.AltBar_OnMouseEnterXP, false)
    else
        mode = "hidden"
        CustomFramesClearAltBarReferences(player)
        CustomFramesSetupAltBarInteraction(alt, nil, false)
    end

    if center then
        alt.backdrop:SetCenterColor(unpack(center))
    end
    if color then
        alt.bar:SetColor(unpack(color))
    end
    if icon then
        alt.icon:SetTexture(icon)
    end

    local isHidden = mode == "hidden"
    player.botInfo:SetHidden(isHidden)
    player.buffAnchor:SetHidden(isHidden)

    player.buffs:ClearAnchors()
    local buffAnchor = isHidden and player.control or player.buffAnchor
    local buffYOffset = 5
    if UnitFrames.SV.PlayerFrameOptions == 3 and not (UnitFrames.SV.HideBarMagicka and UnitFrames.SV.HideBarStamina) then
        buffYOffset = buffYOffset + UnitFrames.SV.PlayerBarHeightStamina + UnitFrames.SV.PlayerBarSpacing
    end
    player.buffs:SetAnchor(TOP, buffAnchor, BOTTOM, 0, buffYOffset)

    if isHidden then
        return
    end

    local altW = zo_ceil(UnitFrames.SV.PlayerBarWidth * 2 / 3)
    local padding = alt.icon:GetWidth()
    local phb = player[COMBAT_MECHANIC_FLAGS_HEALTH]
    local pmb = player[COMBAT_MECHANIC_FLAGS_MAGICKA]
    local psb = player[COMBAT_MECHANIC_FLAGS_STAMINA]

    if positionMode == "right" then
        if UnitFrames.SV.HideBarStamina or UnitFrames.SV.HideBarMagicka then
            CustomFramesPositionAltBar(player, alt, altW, padding, BOTTOM, phb.backdrop, CENTER, padding * 0.5 + 1, RIGHT, -2)
        else
            local anchorTarget = UnitFrames.SV.ReverseResourceBars and pmb.backdrop or psb.backdrop
            CustomFramesPositionAltBar(player, alt, altW, padding, BOTTOM, anchorTarget, LEFT, padding + 5, RIGHT, -2)
        end
    elseif positionMode == "left" then
        if UnitFrames.SV.HideBarStamina or UnitFrames.SV.HideBarMagicka then
            CustomFramesPositionAltBar(player, alt, altW, padding, BOTTOM, phb.backdrop, CENTER, padding * 0.5 + 1, RIGHT, -2)
        else
            local anchorTarget = UnitFrames.SV.ReverseResourceBars and psb.backdrop or pmb.backdrop
            CustomFramesPositionAltBar(player, alt, altW, padding, BOTTOM, anchorTarget, RIGHT, -padding - 5, LEFT, 2)
        end
    elseif positionMode == "recenter" then
        if UnitFrames.SV.PlayerFrameOptions == 3 then
            local anchorTarget = nil
            local anchorPoint = BOTTOM
            if not (UnitFrames.SV.HideBarStamina and UnitFrames.SV.HideBarMagicka) then
                if UnitFrames.SV.HideBarStamina and not UnitFrames.SV.HideBarMagicka then
                    anchorTarget = pmb.backdrop
                    anchorPoint = UnitFrames.SV.ReverseResourceBars and BOTTOMLEFT or BOTTOMRIGHT
                elseif not UnitFrames.SV.HideBarStamina then
                    anchorTarget = psb.backdrop
                    anchorPoint = UnitFrames.SV.ReverseResourceBars and BOTTOMRIGHT or BOTTOMLEFT
                end
            end
            CustomFramesPositionAltBar(player, alt, altW, padding, anchorPoint, anchorTarget, CENTER, padding * 0.5 + 1, RIGHT, -2)
        else
            CustomFramesPositionAltBar(player, alt, altW, padding, BOTTOM, nil, CENTER, padding * 0.5 + 1, RIGHT, -2)
        end
    end
end

-- Runs on EVENT_CHAMPION_POINT_GAINED listener.
function UnitFrames.OnChampionPointGained(eventCode)
    if UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"].ChampionXP then
        local championPoints = GetPlayerChampionPointsEarned()
        local attribute
        if championPoints == 3600 then
            attribute = GetChampionPointPoolForRank(championPoints)
        else
            attribute = GetChampionPointPoolForRank(championPoints + 1)
        end
        local color = (UnitFrames.SV.PlayerChampionColour and CP_BAR_COLORS[attribute]) and CP_BAR_COLORS[attribute][2] or XP_BAR_COLORS
        local color2 = (UnitFrames.SV.PlayerChampionColour and CP_BAR_COLORS[attribute]) and CP_BAR_COLORS[attribute][1] or XP_BAR_COLORS
        UnitFrames.CustomFrames["player"].ChampionXP.backdrop:SetCenterColor(0.1 * color.r, 0.1 * color.g, 0.1 * color.b, 0.9)
        UnitFrames.CustomFrames["player"].ChampionXP.enlightenment:SetColor(color2.r, color2.g, color2.b, 0.40)
        UnitFrames.CustomFrames["player"].ChampionXP.bar:SetColor(color.r, color.g, color.b, 0.9)
        local disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataByType(attribute)
        local icon = disciplineData and disciplineData:GetHUDIcon()
        UnitFrames.CustomFrames["player"].ChampionXP.icon:SetTexture(icon)
    end
end

-- Runs on the EVENT_EXPERIENCE_UPDATE listener.
function UnitFrames.OnXPUpdate(eventCode, unitTag, currentExp, maxExp, reason)
    if unitTag ~= "player" or not UnitFrames.CustomFrames["player"] then
        return
    end
    if UnitFrames.CustomFrames["player"].isChampion then
        if not g_PendingUpdateChampionXP.flag then
            g_PendingUpdateChampionXP.flag = true
            eventManager:RegisterForUpdate(g_PendingUpdateChampionXP.name, g_PendingUpdateChampionXP.delay, UnitFrames.UpdateChampionXP)
        end
    elseif UnitFrames.CustomFrames["player"].Experience then
        UnitFrames.CustomFrames["player"].Experience.bar:SetValue(currentExp)
    end
end

function UnitFrames.UpdateChampionXP()
    eventManager:UnregisterForUpdate(g_PendingUpdateChampionXP.name)

    if UnitFrames.CustomFrames["player"] then
        if UnitFrames.CustomFrames["player"].Experience then
            UnitFrames.CustomFrames["player"].Experience.bar:SetValue(GetUnitChampionPoints("player"))
        elseif UnitFrames.CustomFrames["player"].ChampionXP then
            local enlightenedPool = 4 * GetEnlightenedPool()
            local xp = GetPlayerChampionXP()
            local maxBar = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned())
            if maxBar == nil then
                maxBar = xp
            end
            local enlightenedBar = enlightenedPool + xp
            if enlightenedBar > maxBar then
                enlightenedBar = maxBar
            end

            UnitFrames.CustomFrames["player"].ChampionXP.bar:SetValue(xp)
            UnitFrames.CustomFrames["player"].ChampionXP.enlightenment:SetValue(enlightenedBar)
        end
    end
    g_PendingUpdateChampionXP.flag = false
end

function UnitFrames.AlternativeBarApplyTextures(altFrame, texture, isRoundTexture)
    if not altFrame then return end
    UnitFrames.ApplyCustomFrameTextureToBackdrop(altFrame.backdrop, texture, isRoundTexture)
    altFrame.bar:SetTexture(texture)
    altFrame.enlightenment:SetTexture(texture)
end

-- Runs on the EVENT_WEREWOLF_STATE_CHANGED listener.
function UnitFrames.OnWerewolf(eventCode, werewolf)
    UnitFrames.CustomFramesSetupAlternative(werewolf, nil, nil)
end

-- Runs on the EVENT_BEGIN_SIEGE_CONTROL, EVENT_END_SIEGE_CONTROL, EVENT_LEAVE_RAM_ESCORT listeners.
function UnitFrames.OnSiege(eventCode)
    UnitFrames.CustomFramesSetupAlternative(nil, nil, nil)
end

-- Runs on the EVENT_MOUNTED_STATE_CHANGED listener.
function UnitFrames.OnMount(eventCode, mounted)
    UnitFrames.CustomFramesSetupAlternative(nil, nil, mounted)
end

function UnitFrames.AlternativeBarRegisterEvents()
    eventManager:RegisterForEvent(moduleName, EVENT_WEREWOLF_STATE_CHANGED, UnitFrames.OnWerewolf)
    eventManager:RegisterForEvent(moduleName, EVENT_BEGIN_SIEGE_CONTROL, UnitFrames.OnSiege)
    eventManager:RegisterForEvent(moduleName, EVENT_END_SIEGE_CONTROL, UnitFrames.OnSiege)
    eventManager:RegisterForEvent(moduleName, EVENT_LEAVE_RAM_ESCORT, UnitFrames.OnSiege)
    eventManager:RegisterForEvent(moduleName, EVENT_MOUNTED_STATE_CHANGED, UnitFrames.OnMount)
    eventManager:RegisterForEvent(moduleName, EVENT_EXPERIENCE_UPDATE, UnitFrames.OnXPUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_CHAMPION_POINT_GAINED, UnitFrames.OnChampionPointGained)
end
