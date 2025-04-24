-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- CombatText namespace
--- @class (partial) LUIE.CombatText
--- @field SV LUIE.CombatText.SV
local CombatText = {}
CombatText.__index = CombatText
--- @class (partial) LUIE.CombatText
LUIE.CombatText = CombatText

local CombatTextConstants = LuiData.Data.CombatTextConstants

local pairs = pairs
local printToChat = LUIE.PrintToChat

local LMP = LibMediaProvider

local moduleName = LUIE.name .. "CombatText"

local panelTitles =
{
    LUIE_CombatText_Outgoing = GetString(LUIE_STRING_CT_PANEL_OUTGOING),
    LUIE_CombatText_Incoming = GetString(LUIE_STRING_CT_PANEL_INCOMING),
    LUIE_CombatText_Point = GetString(LUIE_STRING_CT_PANEL_POINT),
    LUIE_CombatText_Alert = GetString(LUIE_STRING_CT_PANEL_ALERT),
    LUIE_CombatText_Resource = GetString(LUIE_STRING_CT_PANEL_RESOURCE),
}

CombatText.Enabled = false
CombatText.Defaults =
{
    unlocked = false,
    blacklist = {},
    -- Panel Defaults
    panels =
    {
        -- Outgoing
        LUIE_CombatText_Outgoing =
        {
            point = CENTER,
            relativePoint = CENTER,
            offsetX = 450,
            offsetY = -220,
            dimensions = { 400, 100 },
        },
        -- Incoming
        LUIE_CombatText_Incoming =
        {
            point = CENTER,
            relativePoint = CENTER,
            offsetX = -450,
            offsetY = -220,
            dimensions = { 400, 100 },
        },
        -- Alerts
        LUIE_CombatText_Alert =
        {
            point = CENTER,
            relativePoint = CENTER,
            offsetX = 0,
            offsetY = 250,
            dimensions = { 400, 100 },
        },
        -- Points
        LUIE_CombatText_Point =
        {
            point = CENTER,
            relativePoint = CENTER,
            offsetX = 0,
            offsetY = -300,
            dimensions = { 400, 100 },
        },
        -- Resources
        LUIE_CombatText_Resource =
        {
            point = CENTER,
            relativePoint = CENTER,
            offsetX = 0,
            offsetY = 375,
            dimensions = { 400, 100 },
        },
    },
    common =
    {
        transparencyValue = 100,
        overkill = true,
        overheal = true,
        abbreviateNumbers = false,
        useDefaultIcon = false,
        defaultIconOptions = false,
    },
    -- Toggle Defaults
    toggles =
    {
        -- General
        inCombatOnly = false,
        showThrottleTrailer = true,
        throttleCriticals = false,

        -- Incoming
        incoming =
        {
            -- Damage & Healing
            showDamage = true,
            showHealing = true,
            showEnergize = true,
            showUltimateEnergize = true,
            showDrain = true,
            showDot = true,
            showHot = true,

            -- Mitigation
            showMiss = true,
            showImmune = true,
            showParried = true,
            showReflected = true,
            showDamageShield = true,
            showDodged = true,
            showBlocked = true,
            showInterrupted = true,

            -- Crowd Control
            showDisoriented = true,
            showFeared = true,
            showOffBalanced = true,
            showSilenced = true,
            showStunned = true,
            showCharmed = true,
        },

        -- Outgoing
        outgoing =
        {
            -- Damage & Healing
            showDamage = true,
            showHealing = true,
            showEnergize = true,
            showUltimateEnergize = true,
            showDrain = true,
            showDot = true,
            showHot = true,

            -- Mitigation
            showMiss = true,
            showImmune = true,
            showParried = true,
            showReflected = true,
            showDamageShield = true,
            showDodged = true,
            showBlocked = true,
            showInterrupted = true,

            -- Crowd Control
            showDisoriented = true,
            showFeared = true,
            showOffBalanced = true,
            showSilenced = true,
            showStunned = true,
            showCharmed = true,
        },

        -- Combat State
        showInCombat = true,
        showOutCombat = true,
        showDeath = true,

        -- Points
        showPointsAlliance = false,
        showPointsExperience = false,
        showPointsChampion = false,

        -- Resources
        showLowHealth = false,
        showLowStamina = false,
        showLowMagicka = false,
        showUltimate = true,
        showPotionReady = true,
        warningSound = false,

        -- Colors
        criticalDamageOverride = false,
        criticalHealingOverride = false,
        incomingDamageOverride = false,
    },

    -- Other defaults
    healthThreshold = 35,
    magickaThreshold = 35,
    staminaThreshold = 35,

    -- Font defaults
    fontFace = "Univers 67",
    fontStyle = "soft-shadow-thick",
    fontSize = 26,
    fontSizes =
    {
        -- Combat
        damage = 32,
        damagecritical = 32,
        healing = 32,
        healingcritical = 32,
        dot = 26,
        dotcritical = 26,
        hot = 26,
        hotcritical = 26,
        gainLoss = 32,
        mitigation = 32,
        crowdControl = 26,

        -- Combat State, Points & Resources
        combatState = 24,
        death = 32,
        point = 24,
        resource = 32,
        readylabel = 32,
    },

    -- Color defaults
    colors =
    {
        -- Damage & Healing
        damage =
        {
            [DAMAGE_TYPE_NONE] = { 1, 1, 1, 1 },
            [DAMAGE_TYPE_GENERIC] = { 1, 1, 1, 1 },
            [DAMAGE_TYPE_PHYSICAL] = { 200 / 255, 200 / 255, 160 / 255, 1 },
            [DAMAGE_TYPE_FIRE] = { 1, 100 / 255, 20 / 255, 1 },
            [DAMAGE_TYPE_SHOCK] = { 0, 1, 1, 1 },
            [DAMAGE_TYPE_OBLIVION] = { 75 / 255, 0, 150 / 255, 1 },
            [DAMAGE_TYPE_COLD] = { 35 / 255, 70 / 255, 1, 1 },
            [DAMAGE_TYPE_EARTH] = { 100 / 255, 75 / 255, 50 / 255, 1 },
            [DAMAGE_TYPE_MAGIC] = { 1, 1, 0, 1 },
            [DAMAGE_TYPE_DROWN] = { 35 / 255, 70 / 255, 255 / 255, 1 },
            [DAMAGE_TYPE_DISEASE] = { 25 / 255, 85 / 255, 0, 1 },
            [DAMAGE_TYPE_POISON] = { 0, 1, 127 / 255, 1 },
            [DAMAGE_TYPE_BLEED] = { 1, 45 / 255, 45 / 255, 1 },
        },
        healing = { 0, 192 / 255, 0, 1 },
        energizeMagicka = { 0, 192 / 255, 1, 1 },
        energizeStamina = { 192 / 255, 1, 0, 1 },
        energizeUltimate = { 1, 1, 0, 1 },
        drainMagicka = { 0, 192 / 255, 1, 1 },
        drainStamina = { 192 / 255, 1, 0, 1 },
        criticalDamageOverride = { 247 / 255, 244 / 255, 153 / 255, 1 },
        criticalHealingOverride = { 0, 192 / 255, 0, 1 },
        incomingDamageOverride = { 1, 0, 0, 1 },

        -- Mitigation
        miss = { 1, 1, 1, 1 },
        immune = { 1, 0, 0, 1 },
        parried = { 1, 1, 1, 1 },
        reflected = { 1, 160 / 255, 0, 1 },
        damageShield = { 1, 160 / 255, 0, 1 },
        dodged = { 1, 1, 50 / 255, 1 },
        blocked = { 1, 1, 1, 1 },
        interrupted = { 1, 1, 1, 1 },

        -- Crowd Control
        disoriented = { 1, 1, 1, 1 },
        feared = { 1, 1, 1, 1 },
        offBalanced = { 1, 1, 1, 1 },
        silenced = { 1, 1, 1, 1 },
        stunned = { 1, 1, 1, 1 },
        charmed = { 1, 1, 1, 1 },

        -- Combat State
        inCombat = { 1, 1, 1, 1 },
        outCombat = { 1, 1, 1, 1 },
        death = { 1, 0, 0, 1 },

        -- Points
        pointsAlliance = { 0.235294, 0.784314, 0.313725, 1 },   -- RGB(60, 200, 80)
        pointsExperience = { 0.588235, 0.705882, 0.862745, 1 }, -- RGB(150, 180, 220)
        pointsChampion = { 0.784314, 0.784314, 0.627451, 1 },   -- RGB(200, 200, 160)

        -- Resources
        lowHealth = { 0.901961, 0.196078, 0.098039, 1 },   -- RGB(230, 50, 25)
        lowMagicka = { 0.137255, 0.588235, 0.784314, 1 },  -- RGB(35, 150, 200)
        lowStamina = { 0.235294, 0.784314, 0.313725, 1 },  -- RGB(60, 200, 80)
        ultimateReady = { 0.862745, 1, 0.313725, 1 },      -- RGB(220, 255, 80)
        potionReady = { 0.470588, 0.156863, 0.745098, 1 }, -- RGB(120, 40, 190)
    },
    -- Format defaults
    formats =
    {
        -- Damage & Healing
        damage = "%t %a",
        damagecritical = "%t %a!",
        healing = "%t %a",
        healingcritical = "%t %a!",
        energize = "+%a %t",
        ultimateEnergize = "+%a %t",
        drain = "-%a %t",
        dot = "%t %a",
        dotcritical = "%t %a!",
        hot = "%t %a",
        hotcritical = "%t %a!",

        -- Mitigation
        miss = GetString(LUIE_STRING_CT_MISS_DEFAULT),
        immune = GetString(LUIE_STRING_CT_IMMUNE_DEFAULT),
        parried = GetString(LUIE_STRING_CT_PARRIED_DEFAULT),
        reflected = GetString(LUIE_STRING_CT_REFLECTED_DEFAULT),
        damageShield = "(%a) %t",
        dodged = GetString(LUIE_STRING_CT_DODGED_DEFAULT),
        blocked = "*%t %a",
        interrupted = GetString(LUIE_STRING_CT_INTERRUPTED_DEFAULT),

        -- Crowd Control
        disoriented = GetString(LUIE_STRING_LAM_CT_SHARED_DISORIENTED),
        feared = GetString(LUIE_STRING_LAM_CT_SHARED_FEARED),
        offBalanced = GetString(LUIE_STRING_LAM_CT_SHARED_OFF_BALANCE),
        silenced = GetString(LUIE_STRING_LAM_CT_SHARED_SILENCED),
        stunned = GetString(LUIE_STRING_LAM_CT_SHARED_STUNNED),
        charmed = GetString(LUIE_STRING_LAM_CT_SHARED_CHARMED),

        -- Combat State
        inCombat = GetString(LUIE_STRING_CT_COMBAT_IN_DEFAULT),
        outCombat = GetString(LUIE_STRING_CT_COMBAT_OUT_DEFAULT),
        death = GetString(LUIE_STRING_CT_DEATH_DEFAULT),

        -- Points
        pointsAlliance = "%a AP",
        pointsExperience = "%a XP",
        pointsChampion = "%a XP",

        -- Resources
        resourceHealth = "%t! (%a)",
        resourceMagicka = "%t! (%a)",
        resourceStamina = "%t! (%a)",
        ultimateReady = GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY),
        potionReady = GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY),
    },

    -- Animation defaults
    animation =
    {
        animationType = "ellipse",
        animationDuration = 100,
        outgoingIcon = "left",
        incomingIcon = "right",
        outgoing =
        {
            directionType = "down",
            speed = 4000,
        },
        incoming =
        {
            directionType = "down",
            speed = 4000,
        },
    },

    -- Throttle defaults
    throttles =
    {
        damage = 200,
        damagecritical = 200,
        healing = 200,
        healingcritical = 200,
        dot = 200,
        dotcritical = 200,
        hot = 200,
        hotcritical = 200,
    },
}
CombatText.SV = {}

---
--- @param panel userdata
local function SavePosition(panel)
    -- Validate panel
    if not panel or not panel.GetAnchor or not panel.GetDimensions then
        return
    end

    -- Get anchor data
    local anchor = { panel:GetAnchor(0) }
    if not anchor[1] then -- isValidAnchor is false
        return
    end

    -- Get dimensions
    local dimensions = { panel:GetDimensions() }
    if not dimensions[1] or not dimensions[2] then -- Invalid dimensions
        return
    end

    -- Save position and dimensions
    local panelSettings = LUIE.CombatText.SV.panels[panel:GetName()]
    if panelSettings then
        panelSettings.point = anchor[2]
        panelSettings.relativePoint = anchor[4]
        panelSettings.offsetX = anchor[5]
        panelSettings.offsetY = anchor[6]
        panelSettings.dimensions = dimensions
    end
end

-- Bulk list add from menu buttons
function CombatText.AddBulkToCustomList(list, table)
    if table ~= nil then
        for k, v in pairs(table) do
            CombatText.AddToCustomList(list, k)
        end
    end
end

function CombatText.ClearCustomList(list)
    local listRef = list == CombatText.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CT_BLACKLIST) or ""
    for k, v in pairs(list) do
        list[k] = nil
    end
    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
end

-- List Handling (Add) for Prominent Auras & Blacklist
function CombatText.AddToCustomList(list, input)
    local id = tonumber(input)
    local listRef = list == CombatText.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CT_BLACKLIST) or ""
    if id and id > 0 then
        local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(id))
        local name = cachedName -- zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
        if name ~= nil and name ~= "" then
            local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
            list[id] = true
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), icon, id, name, listRef), true)
        else
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, listRef), true)
        end
    else
        if input ~= "" then
            list[input] = true
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
        end
    end
end

-- List Handling (Remove) for Prominent Auras & Blacklist
function CombatText.RemoveFromCustomList(list, input)
    local id = tonumber(input)
    local listRef = list == CombatText.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CT_BLACKLIST) or ""
    if id and id > 0 then
        local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(id))
        local name = cachedName -- zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
        local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
        list[id] = nil
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), icon, id, name, listRef), true)
    else
        if input ~= "" then
            list[input] = nil
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
        end
    end
end

function CombatText.ApplyFont()
    -- Fetch the font name from the LUIE.Fonts table
    local fontName = LUIE.Fonts[LUIE.CombatText.SV.fontFace]

    -- If the font name is not found or is an empty string, log an error message
    if not fontName or fontName == "" then
        LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
        -- Set the font face to a default bold font
        fontName = "Univers 67"
    end

    -- Set the applied font face to the fetched or default font name
    LUIE.CombatText.SV.fontFaceApplied = fontName
end

-- Module initialization
function CombatText.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        CombatText.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "CombatText", CombatText.Defaults)
    else
        CombatText.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "CombatText", CombatText.Defaults)
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    CombatText.Enabled = true

    -- Apply Font
    CombatText.ApplyFont()

    -- Set panels to player configured settings
    local Combattext = GetControl("Combattext")
    for k, s in pairs(LUIE.CombatText.SV.panels) do
        if _G[k] ~= nil then
            _G[k]:ClearAnchors()
            _G[k]:SetAnchor(s.point, Combattext, s.relativePoint, s.offsetX, s.offsetY)
            _G[k]:SetDimensions(unpack(s.dimensions))
            _G[k]:SetHandler("OnMouseUp", SavePosition)
            _G[k .. "_Label"]:SetFont(LUIE.CombatText.SV.fontFaceApplied .. "|26|" .. LUIE.CombatText.SV.fontStyle)
            _G[k .. "_Label"]:SetText(panelTitles[k])
        else
            LUIE.CombatText.SV.panels[k] = nil
        end
    end

    -- Allow mouse resizing of panels
    LUIE_CombatText_Incoming:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)
    LUIE_CombatText_Outgoing:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)

    -- Pool Manager
    local poolManager = LUIE.CombatTextPoolManager:New()
    -- Create a pool for each type
    for _, v in pairs(CombatTextConstants.poolType) do
        poolManager:RegisterPool(v, LUIE.CombatTextPool:New(v))
    end

    -- Event Listeners
    LUIE.CombatTextCombatEventListener:New()
    LUIE.CombatTextPointsAllianceEventListener:New()
    LUIE.CombatTextPointsExperienceEventListener:New()
    LUIE.CombatTextPointsChampionEventListener:New()
    LUIE.CombatTextResourcesPowerEventListener:New()
    LUIE.CombatTextResourcesUltimateEventListener:New()
    LUIE.CombatTextResourcesPotionEventListener:New()
    LUIE.CombatTextDeathListener:New()

    -- Event Viewers
    LUIE.CombatTextCombatCloudEventViewer:New(poolManager, LMP)
    LUIE.CombatTextCombatHybridEventViewer:New(poolManager, LMP)
    LUIE.CombatTextCombatScrollEventViewer:New(poolManager, LMP)
    LUIE.CombatTextCombatEllipseEventViewer:New(poolManager, LMP)
    LUIE.CombatTextCrowdControlEventViewer:New(poolManager, LMP)
    LUIE.CombatTextPointEventViewer:New(poolManager, LMP)
    LUIE.CombatTextResourceEventViewer:New(poolManager, LMP)
    LUIE.CombatTextDeathViewer:New(poolManager, LMP)

    -- Variable adjustment if needed
    if not LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsCT then
        LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsCT = 0
    end
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsCT < 2 then
        -- Set color for bleed damage to red
        CombatText.SV.colors.damage[DAMAGE_TYPE_BLEED] = CombatText.Defaults.colors.damage[DAMAGE_TYPE_BLEED]
    end
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsCT < 3 then
        -- Remove sneak drain from CT blacklist since it is no longer in the game
        if CombatText.SV.blacklist[20301] then
            CombatText.SV.blacklist[20301] = nil
        end
    end
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsCT < 4 then
        for k, v in pairs(LUIESV["Default"][GetDisplayName()]) do
            for j, _ in pairs(v) do
                if j == "LuiExtendedCombatText" then
                    -- Don't want to throw any errors here so make sure these values exist before trying to remove them
                    if LUIESV["Default"][GetDisplayName()][k] and LUIESV["Default"][GetDisplayName()][k][j] then
                        LUIESV["Default"][GetDisplayName()][k][j] = nil
                    end
                end
            end
        end
    end
    -- Increment so this doesn't occur again.
    LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsCT = 4
end

-- -- Set position of panels
-- function CombatText.SetPanelPosition()
--     local Settings = CombatText.SV
--     for k, v in pairs(Settings.panels) do
--         local panel = _G[k]
--         if panel then
--             panel:ClearAnchors()
--             if v.x ~= nil and v.y ~= nil then
--                 local x, y = v.x, v.y
--                 if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_combatText then
--                     x, y = LUIE.ApplyGridSnap(x, y, "combatText")
--                 end
--                 panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
--             else
--                 panel:SetAnchor(v.anchor[1], GuiRoot, v.anchor[2], v.anchor[3], v.anchor[4])
--             end
--         end
--     end
-- end

-- -- Unlock panels for moving
-- --- @param state boolean
-- function CombatText.SetMovingState(state)
--     local Settings = CombatText.SV
--     for k, _ in pairs(Settings.panels) do
--         local panel = _G[k]
--         if panel then
--             panel:SetMouseEnabled(state)
--             panel:SetMovable(state)
--             _G[k .. "_Backdrop"]:SetHidden(not state)
--             _G[k .. "_Label"]:SetHidden(not state)
--             if state then
--                 -- Add grid snapping handler
--                 panel:SetHandler("OnMoveStop", function (self)
--                     local left, top = self:GetLeft(), self:GetTop()
--                     if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_combatText then
--                         left, top = LUIE.ApplyGridSnap(left, top, "combatText")
--                         self:ClearAnchors()
--                         self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
--                     end
--                     Settings.panels[k].x = left
--                     Settings.panels[k].y = top
--                 end)
--             end
--         end
--     end
-- end
