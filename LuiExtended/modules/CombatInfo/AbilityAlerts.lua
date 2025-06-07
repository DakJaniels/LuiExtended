-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo
--- @class (partial) AbilityAlerts
local AbilityAlerts = CombatInfo.AbilityAlerts

local UI = LUIE.UI
local Effects = LuiData.Data.Effects
local Alerts = LuiData.Data.AlertTable
local AlertsZone = LuiData.Data.AlertZoneOverride
local AlertsMap = LuiData.Data.AlertMapOverride
local AlertsConvert = LuiData.Data.AlertBossNameConvert

local pairs = pairs
local printToChat = LUIE.PrintToChat
local zo_strformat = zo_strformat
local string_format = string.format
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()

local moduleName = LUIE.name .. "CombatInfo"

local uiTlw = {}  -- GUI
local refireDelay = {}
local g_alertFont -- Font for Alerts
local g_inDuel    -- Tracker for whether the player is in a duel or not

local alertTypes =
{
    UNMIT = "LUIE_ALERT_TYPE_UNMIT",
    DESTROY = "LUIE_ALERT_TYPE_DESTROY",
    POWER = "LUIE_ALERT_TYPE_POWER",
    SUMMON = "LUIE_ALERT_TYPE_SUMMON",
    SHARED = "LUIE_ALERT_TYPE_SHARED",
}

local ZO_EaseOutQuadratic = ZO_EaseOutQuadratic

-- Set Alert Colors
function AbilityAlerts.SetAlertColors()
    local colors = CombatInfo.SV.alerts.colors
    AbilityAlerts.AlertColors =
    {
        alertColorBlock = ZO_ColorDef:New(unpack(colors.alertBlockA)):ToHex(),
        alertColorDodge = ZO_ColorDef:New(unpack(colors.alertDodgeA)):ToHex(),
        alertColorAvoid = ZO_ColorDef:New(unpack(colors.alertAvoidB)):ToHex(),
        alertColorInterrupt = ZO_ColorDef:New(unpack(colors.alertInterruptC)):ToHex(),
        alertColorUnmit = ZO_ColorDef:New(unpack(colors.alertUnmit)):ToHex(),
        alertColorPower = ZO_ColorDef:New(unpack(colors.alertPower)):ToHex(),
        alertColorDestroy = ZO_ColorDef:New(unpack(colors.alertDestroy)):ToHex(),
        alertColorSummon = ZO_ColorDef:New(unpack(colors.alertSummon)):ToHex(),
    }
end

-- Called from menu when font size/face, etc is changed
function AbilityAlerts.ResetAlertSize()
    for i = 1, 3 do
        local height = (CombatInfo.SV.alerts.toggles.alertFontSize * 2)
        local alert = _G["LUIE_Alert" .. i]
        alert.prefix:SetFont(g_alertFont)
        alert.name:SetFont(g_alertFont)
        alert.modifier:SetFont(g_alertFont)
        alert.mitigation:SetFont(g_alertFont)
        alert.timer:SetFont(g_alertFont)
        alert.icon:SetDimensions(CombatInfo.SV.alerts.toggles.alertFontSize + 8, CombatInfo.SV.alerts.toggles.alertFontSize + 8)
        alert.icon.iconbg:ClearAnchors()
        alert.icon.iconbg:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, 3, 3)
        alert.icon.iconbg:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, -3, -3)
        alert.icon.cd:ClearAnchors()
        alert.icon.cd:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, 1, 1)
        alert.icon.cd:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, -1, -1)
        alert.icon.icon:ClearAnchors()
        alert.icon.icon:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, 3, 3)
        alert.icon.icon:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, -3, -3)
        alert:SetDimensions(alert.prefix:GetTextWidth() + alert.name:GetTextWidth() + alert.modifier:GetTextWidth() + 6 + alert.icon:GetWidth() + 6 + alert.mitigation:GetTextWidth() + alert.timer:GetTextWidth(), height)
    end

    uiTlw.alertFrame:SetDimensions(500, (CombatInfo.SV.alerts.toggles.alertFontSize * 2) + 4)
end

local ccResults =
{
    [ACTION_RESULT_STAGGERED] = true,
    [ACTION_RESULT_STUNNED] = true,
    [ACTION_RESULT_KNOCKBACK] = true,
    [ACTION_RESULT_LEVITATED] = true,
    [ACTION_RESULT_FEARED] = true,
    [ACTION_RESULT_CHARMED] = true,
    [ACTION_RESULT_DISORIENTED] = true,
    [ACTION_RESULT_INTERRUPT] = true,
    [ACTION_RESULT_KILLING_BLOW] = true,
    [ACTION_RESULT_DIED] = true,
    [ACTION_RESULT_DIED_XP] = true,
}

local deathResults =
{
    [ACTION_RESULT_KILLING_BLOW] = true,
    [ACTION_RESULT_DIED] = true,
    [ACTION_RESULT_DIED_XP] = true,
}

function AbilityAlerts.ShouldUseDefaultIcon(abilityId)
    if Alerts[abilityId] and Alerts[abilityId].cc then
        return true
    end
end

local CC_ICON_MAP =
{
    [LUIE_CC_TYPE_STUN] = LUIE_CC_ICON_STUN,
    [LUIE_CC_TYPE_KNOCKDOWN] = LUIE_CC_ICON_STUN,
    [LUIE_CC_TYPE_KNOCKBACK] = LUIE_CC_ICON_KNOCKBACK,
    [LUIE_CC_TYPE_PULL] = LUIE_CC_ICON_PULL,
    [LUIE_CC_TYPE_DISORIENT] = LUIE_CC_ICON_DISORIENT,
    [LUIE_CC_TYPE_FEAR] = LUIE_CC_ICON_FEAR,
    [LUIE_CC_TYPE_CHARM] = LUIE_CC_ICON_CHARM,
    [LUIE_CC_TYPE_STAGGER] = LUIE_CC_ICON_STAGGER,
    [LUIE_CC_TYPE_SILENCE] = LUIE_CC_ICON_SILENCE,
    [LUIE_CC_TYPE_SNARE] = LUIE_CC_ICON_SNARE,
    [LUIE_CC_TYPE_ROOT] = LUIE_CC_ICON_ROOT,
}

function AbilityAlerts.GetDefaultIcon(ccType)
    return CC_ICON_MAP[ccType]
end

-- Create Alert Frame - basic setup for now
function AbilityAlerts.CreateAlertFrame()
    -- Apply font for alerts
    AbilityAlerts.ApplyFontAlert()

    -- Create Top Level Controls
    uiTlw.alertFrame = UI:TopLevel(nil, nil)

    -- Create 3 alert labels
    local anchor = { CENTER, CENTER, 0, 0, uiTlw.alertFrame }
    local height = (CombatInfo.SV.alerts.toggles.alertFontSize * 2)
    for i = 1, 3 do
        local alert = UI:Control(uiTlw.alertFrame, anchor, { nil, height }, false, "LUIE_Alert" .. i)

        alert.data =
        {
            ["available"] = true,
            ["textPrefix"] = "",
            ["textName"] = "TEST NAME",
            ["textModifier"] = "",
            ["textMitigation"] = "TEST MITIGATION MESSAGE",
            ["duration"] = nil,
            ["showDuration"] = false,
            ["ccType"] = nil,
            ["sourceUnitId"] = nil,
            ["alwaysShowInterrupt"] = nil,
            ["neverShowInterrupt"] = nil,
            ["effectOnlyInterrupt"] = nil,
            ["mitigationParts"] = nil,
        }

        alert.prefix = UI:Label(alert, nil, nil, nil, g_alertFont, alert.data.textPrefix, false)
        alert.name = UI:Label(alert, nil, nil, nil, g_alertFont, alert.data.textName, false)
        alert.modifier = UI:Label(alert, nil, nil, nil, g_alertFont, alert.data.textModifier, false)
        alert.prefix:SetAnchor(LEFT, alert, LEFT, 0, 0)
        alert.name:SetAnchor(LEFT, alert.prefix, RIGHT, 0, 0)
        alert.modifier:SetAnchor(LEFT, alert.name, RIGHT, 0, 0)

        alert.icon = UI:Backdrop(alert.name, nil, nil, { 0, 0, 0, 0.5 }, { 0, 0, 0, 1 }, false)
        alert.icon:SetDimensions(CombatInfo.SV.alerts.toggles.alertFontSize + 8, CombatInfo.SV.alerts.toggles.alertFontSize + 8)
        alert.icon:SetAnchor(LEFT, alert.modifier, RIGHT, 6, 0)

        alert.icon.back = UI:Texture(alert.icon, nil, nil, "LuiExtended/media/icons/icon_border/icon_border.dds", DL_BACKGROUND, false)
        alert.icon.back:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, 0, 0)
        alert.icon.back:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, 0, 0)

        alert.icon.iconbg = UI:Texture(alert.icon, nil, nil, "EsoUI/Art/ActionBar/abilityInset.dds", DL_CONTROLS, false)
        alert.icon.iconbg = UI:Backdrop(alert.icon, nil, nil, { 0, 0, 0, 0.9 }, { 0, 0, 0, 0.9 }, false)
        alert.icon.iconbg:SetDrawLevel(DL_CONTROLS)
        alert.icon.iconbg:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, 3, 3)
        alert.icon.iconbg:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, -3, -3)

        alert.icon.cd = windowManager:CreateControl(nil, alert.icon, CT_COOLDOWN)
        alert.icon.cd:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, 1, 1)
        alert.icon.cd:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, -1, -1)
        alert.icon.cd:SetFillColor(0, 0, 0, 0)
        alert.icon.cd:StartCooldown(0, 0, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)
        alert.icon.cd:SetDrawLayer(DL_BACKGROUND)

        alert.icon.icon = UI:Texture(alert.icon, nil, nil, "/esoui/art/icons/icon_missing.dds", DL_CONTROLS, false)
        alert.icon.icon:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, 3, 3)
        alert.icon.icon:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, -3, -3)

        alert.mitigation = UI:Label(alert.icon, nil, nil, nil, g_alertFont, alert.data.textMitigation, false)
        alert.mitigation:SetAnchor(LEFT, alert.icon, RIGHT, 6, 0)

        alert.timer = UI:Label(alert.icon, nil, nil, nil, g_alertFont, alert.data.duration, false)
        alert.timer:SetAnchor(LEFT, alert.mitigation, RIGHT, 0, 0)

        alert:SetDimensions(alert.prefix:GetTextWidth() + alert.name:GetTextWidth() + alert.modifier:GetTextWidth() + 6 + alert.icon:GetWidth() + 6 + alert.mitigation:GetTextWidth() + alert.timer:GetTextWidth(), height)
        alert:SetHidden(true)

        anchor = { TOP, BOTTOM, 0, 0, alert }
    end

    uiTlw.alertFrame:SetDimensions(500, height + 4)

    -- Setup Preview
    uiTlw.alertFrame.preview = LUIE.UI:Backdrop(uiTlw.alertFrame, "fill", nil, nil, nil, true)

    -- Callback used to hide anchor coords preview label on movement start
    local tlwOnMoveStart = function (self)
        eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
            self.preview.anchorLabel:SetText(zo_strformat("<<1>>, <<2>>", self:GetLeft(), self:GetTop()))
        end)
    end

    -- Callback used to save new position of frames
    local tlwOnMoveStop = function (self)
        eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
        CombatInfo.SV.AlertFrameOffsetX = self:GetLeft()
        CombatInfo.SV.AlertFrameOffsetY = self:GetTop()
        CombatInfo.SV.AlertFrameCustomPosition = { self:GetLeft(), self:GetTop() }
    end

    uiTlw.alertFrame:SetHandler("OnMoveStart", tlwOnMoveStart)
    uiTlw.alertFrame:SetHandler("OnMoveStop", tlwOnMoveStop)

    uiTlw.alertFrame.preview.anchorTexture = UI:Texture(uiTlw.alertFrame.preview, { TOPLEFT, TOPLEFT }, { 16, 16 }, "/esoui/art/reticle/border_topleft.dds", DL_OVERLAY, false)
    uiTlw.alertFrame.preview.anchorTexture:SetColor(1, 1, 0, 0.9)

    uiTlw.alertFrame.preview.anchorLabel = UI:Label(uiTlw.alertFrame.preview, { BOTTOMLEFT, TOPLEFT, 0, -1 }, nil, { 0, 2 }, "ZoFontGameSmall", "xxx, yyy", false)
    uiTlw.alertFrame.preview.anchorLabel:SetColor(1, 1, 0, 1)
    uiTlw.alertFrame.preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
    uiTlw.alertFrame.preview.anchorLabel:SetDrawTier(DT_MEDIUM)
    uiTlw.alertFrame.preview.anchorLabelBg = UI:Backdrop(uiTlw.alertFrame.preview.anchorLabel, "fill", nil, { 0, 0, 0, 1 }, { 0, 0, 0, 1 }, false)
    uiTlw.alertFrame.preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
    uiTlw.alertFrame.preview.anchorLabelBg:SetDrawTier(DT_LOW)

    local fragment = ZO_HUDFadeSceneFragment:New(uiTlw.alertFrame, 0, 0)

    sceneManager:GetScene("hud"):AddFragment(fragment)
    sceneManager:GetScene("hudui"):AddFragment(fragment)
    sceneManager:GetScene("siegeBar"):AddFragment(fragment)
    sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

    -- Register Events
    eventManager:RegisterForEvent(moduleName .. "Combat", EVENT_COMBAT_EVENT, AbilityAlerts.OnCombatIn)
    eventManager:AddFilterForEvent(moduleName .. "Combat", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    eventManager:RegisterForEvent(moduleName .. "Effect", EVENT_EFFECT_CHANGED, AbilityAlerts.AlertEffectChanged)

    for abilityId, data in pairs(Alerts) do
        if data.eventdetect == true then
            eventManager:RegisterForEvent(moduleName .. abilityId, EVENT_COMBAT_EVENT, AbilityAlerts.OnCombatAlert)
            eventManager:AddFilterForEvent(moduleName .. abilityId, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_IS_ERROR, false)
        end
    end

    for result, _ in pairs(ccResults) do
        eventManager:RegisterForEvent(moduleName .. result, EVENT_COMBAT_EVENT, AbilityAlerts.AlertInterrupt)
        eventManager:AddFilterForEvent(moduleName .. result, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, result, REGISTER_FILTER_IS_ERROR, false)
    end

    eventManager:RegisterForUpdate(moduleName .. "AlertUpdate", 100, AbilityAlerts.AlertUpdate)

    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_STARTED, AbilityAlerts.OnDuelStarted)
    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_FINISHED, AbilityAlerts.OnDuelFinished)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, AbilityAlerts.OnPlayerActivated)
end

--- @param eventId integer
function AbilityAlerts.OnDuelStarted(eventId)
    g_inDuel = true
end

--- @param eventId integer
--- @param duelResult DuelResult
--- @param wasLocalPlayersResult boolean
--- @param opponentCharacterName string
--- @param opponentDisplayName string
--- @param opponentAlliance Alliance
--- @param opponentGender Gender
--- @param opponentClassId integer
--- @param opponentRaceId integer
function AbilityAlerts.OnDuelFinished(eventId, duelResult, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName, opponentAlliance, opponentGender, opponentClassId, opponentRaceId)
    g_inDuel = false
end

--- @param eventId integer
--- @param initial boolean
function AbilityAlerts.OnPlayerActivated(eventId, initial)
    local duelState = GetDuelInfo()
    if duelState == DUEL_STATE_DUELING then
        g_inDuel = true
    end
    eventManager:UnregisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED)
end

function AbilityAlerts.ResetAlertFramePosition()
    if not CombatInfo.Enabled then
        return
    end
    CombatInfo.SV.AlertFrameOffsetX = nil
    CombatInfo.SV.AlertFrameOffsetY = nil
    CombatInfo.SV.AlertFrameCustomPosition = nil
    AbilityAlerts.SetAlertFramePosition()
    AbilityAlerts.SetMovingStateAlert(false)
end

function AbilityAlerts.SetAlertFramePosition()
    if uiTlw.alertFrame and uiTlw.alertFrame:GetType() == CT_TOPLEVELCONTROL then
        uiTlw.alertFrame:ClearAnchors()

        if CombatInfo.SV.AlertFrameOffsetX ~= nil and CombatInfo.SV.AlertFrameOffsetY ~= nil then
            uiTlw.alertFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CombatInfo.SV.AlertFrameOffsetX, CombatInfo.SV.AlertFrameOffsetY)
        else
            uiTlw.alertFrame:SetAnchor(CENTER, GuiRoot, CENTER, 0, -250)
        end
    end

    local savedPos = CombatInfo.SV.AlertFrameCustomPosition
    uiTlw.alertFrame.preview.anchorLabel:SetText((savedPos ~= nil and #savedPos == 2) and zo_strformat("<<1>>, <<2>>", savedPos[1], savedPos[2]) or "default")
end

function AbilityAlerts.SetMovingStateAlert(state)
    if not CombatInfo.Enabled then
        return
    end
    AbilityAlerts.AlertFrameUnlocked = state
    if uiTlw.alertFrame and uiTlw.alertFrame:GetType() == CT_TOPLEVELCONTROL then
        AbilityAlerts.GenerateAlertFramePreview(state)
        uiTlw.alertFrame:SetMouseEnabled(state)
        uiTlw.alertFrame:SetMovable(state)
    end
end

-- Called by AbilityAlerts.SetMovingState from the menu as well as by AbilityAlerts.OnUpdateCastbar when preview is enabled
function AbilityAlerts.GenerateAlertFramePreview(state)
    for i = 1, 3 do
        local alert = _G["LUIE_Alert" .. i]
        alert.prefix:SetText("")
        alert.name:SetText("NAME TEST")
        alert.name:SetColor(unpack(CombatInfo.SV.alerts.colors.alertShared))
        alert.modifier:SetText("")
        alert.icon.icon:SetTexture("/esoui/art/icons/icon_missing.dds")
        alert.icon.cd:SetFillColor(0, 0, 0, 0)
        alert.icon.cd:StartCooldown(0, 0, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)
        alert.mitigation:SetText("MITIGATION TEST")
        alert.timer:SetText(CombatInfo.SV.alerts.toggles.alertTimer and " 1.0" or "")
        alert:SetHidden(not state)
    end

    for i = 1, 3 do
        AbilityAlerts.RealignAlerts(i)
    end

    uiTlw.alertFrame.preview:SetHidden(not state)
    uiTlw.alertFrame:SetHidden(not state)
end

-- Update ticker for Alerts
function AbilityAlerts.AlertUpdate(currentTime)
    for i = 1, 3 do
        local alert = _G["LUIE_Alert" .. i]
        if alert.data.duration then
            --[[
            if i > 1 and _G["LUIE_Alert" .. i - 1].data.available == true then
                _G["LUIE_Alert" .. i - 1].data.duration = alert.data.duration
                _G["LUIE_Alert" .. i - 1].data.showDuration = alert.data.showDuration
                _G["LUIE_Alert" .. i - 1].data.textMitigation = alert.data.textMitigation
                _G["LUIE_Alert" .. i - 1].data.available = false
                _G["LUIE_Alert" .. i - 1]:SetHidden(false)
                alert.data.available = true
                alert:SetHidden(true)
                alert.data.textMitigation = nil
                alert.data.duration = nil
                alert.data.showDuration = nil
                i = i - 1
            end
            ]]
            --

            local remain = alert.data.duration - currentTime
            local postCast = alert.data.postCast + remain

            -- DEBUG
            --[[
            if remain <= 100 and remain > 0 then
                d(remain)
            end
            if remain <= 0 and remain > -100 then
                d(remain)
            end
            ]]
            --

            if alert.data.showDuration then
                alert.timer:SetText(alert.data.showDuration and string_format(" %.1f", remain / 1000) or "")
                alert.timer:SetColor(unpack(CombatInfo.SV.alerts.colors.alertTimer))
            end
            if postCast <= -1100 then
                alert:SetAlpha(1)
                alert:SetHidden(true)
                alert.data = {}
                alert.data.duration = nil
                alert.data.postCast = nil
                alert.data.available = true
            elseif remain <= 0 then
                -- alert:SetHidden(true)
                -- alert.data = { }
                if postCast <= 0 then
                    local duration = 1000 - (postCast * -1)
                    local progress = duration / 1000
                    alert:SetAlpha(ZO_EaseOutQuadratic(progress))
                end
                alert.timer:SetText("")
                -- Rebuild mitigation text without trailing dash
                if alert.data.textMitigation and alert.data.mitigationParts then
                    local spacer = "-"
                    local mitigationText = table.concat(alert.data.mitigationParts, " " .. spacer .. " ")
                    alert.mitigation:SetText(" " .. spacer .. " " .. mitigationText)
                end
            end
        end
    end
end

function AbilityAlerts.AlertInterrupt(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET or targetType == COMBAT_UNIT_TYPE_GROUP then
        return
    end
    if Effects.BlockAndBashCC[abilityId] then
        return
    end

    for i = 1, 3 do
        local alert = _G["LUIE_Alert" .. i]
        if alert.data.sourceUnitId then
            targetName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)

            -- DEBUG
            -- d("NORMAL INTERRUPT DETECTED")
            -- d("abilityId: " .. abilityId)
            -- d("Source Unit Id: " .. alert.data.sourceUnitId)
            -- d("targetUnitId: " .. targetUnitId)
            -- d("targetName: " .. targetName)

            local currentTime = GetFrameTimeMilliseconds()
            local remain = alert.data.duration - currentTime

            -- If the source isn't a UnitId and the targetName is also nil then bail
            if alert.data.sourceUnitId == "" and targetName == "" then
                return
            end

            if (alert.data.sourceUnitId == targetUnitId or alert.data.sourceUnitId == targetName) and (not alert.data.showDuration == false or alert.data.alwaysShowInterrupt) and remain > 0 and (not alert.data.neverShowInterrupt or deathResults[result]) and not alert.data.effectOnlyInterrupt then
                alert.data = {}
                alert.data.available = true
                alert.data.id = ""
                alert.data.textMitigation = ""
                alert.data.textPrefix = ""
                alert.data.textName = "INTERRUPTED!"
                alert.data.textModifier = ""
                alert.data.sourceUnitId = ""
                alert.icon:SetHidden(true)
                alert.data.duration = currentTime + 1500
                alert.data.postCast = 0
                alert.data.showDuration = false
                alert.prefix:SetText(alert.data.textPrefix)
                alert.name:SetText(alert.data.textName)
                alert.name:SetColor(unpack(CombatInfo.SV.alerts.colors.alertShared))
                alert.modifier:SetText(alert.data.textModifier)
                alert.mitigation:SetText("")
                alert.timer:SetText("")
                alert:SetHidden(false)

                AbilityAlerts.RealignAlerts(i)
            end
        end
    end
end

local CC_COLOR_MAP =
{
    [LUIE_CC_TYPE_STUN] = function (sv)
        return sv.alerts.colors.stunColor
    end,
    [LUIE_CC_TYPE_KNOCKDOWN] = function (sv)
        return sv.alerts.colors.stunColor
    end,
    [LUIE_CC_TYPE_KNOCKBACK] = function (sv)
        return sv.alerts.colors.knockbackColor
    end,
    [LUIE_CC_TYPE_PULL] = function (sv)
        return sv.alerts.colors.levitateColor
    end,
    [LUIE_CC_TYPE_DISORIENT] = function (sv)
        return sv.alerts.colors.disorientColor
    end,
    [LUIE_CC_TYPE_FEAR] = function (sv)
        return sv.alerts.colors.fearColor
    end,
    [LUIE_CC_TYPE_CHARM] = function (sv)
        return sv.alerts.colors.charmColor
    end,
    [LUIE_CC_TYPE_SILENCE] = function (sv)
        return sv.alerts.colors.silenceColor
    end,
    [LUIE_CC_TYPE_STAGGER] = function (sv)
        return sv.alerts.colors.staggerColor
    end,
    [LUIE_CC_TYPE_UNBREAKABLE] = function (sv)
        return sv.alerts.colors.unbreakableColor
    end,
    [LUIE_CC_TYPE_SNARE] = function (sv)
        return sv.alerts.colors.snareColor
    end,
    [LUIE_CC_TYPE_ROOT] = function (sv)
        return sv.alerts.colors.rootColor
    end,
}

function AbilityAlerts.CrowdControlColorSetup(crowdControl, isBorder)
    if CC_COLOR_MAP[crowdControl] then
        return CC_COLOR_MAP[crowdControl](CombatInfo.SV)
    end

    -- Default fallback
    return isBorder and { 0, 0, 0, 0 } or CombatInfo.SV.alerts.colors.alertShared
end

-- Called from Menu to preview sounds
function AbilityAlerts.PreviewAlertSound(value)
    local Settings = CombatInfo.SV.alerts
    for i = 1, Settings.toggles.soundVolume do
        PlaySound(LUIE.Sounds[value])
    end
end

-- Sound type to settings mapping
local SOUND_TYPE_SETTINGS =
{
    [LUIE_ALERT_SOUND_TYPE_ST] = { toggle = "sound_stEnable", sound = "sound_st" },
    [LUIE_ALERT_SOUND_TYPE_ST_CC] = { toggle = "sound_st_ccEnable", sound = "sound_st_cc" },
    [LUIE_ALERT_SOUND_TYPE_AOE] = { toggle = "sound_aoeEnable", sound = "sound_aoe" },
    [LUIE_ALERT_SOUND_TYPE_AOE_CC] = { toggle = "sound_aoe_ccEnable", sound = "sound_aoe_cc" },
    [LUIE_ALERT_SOUND_TYPE_POWER_ATTACK] = { toggle = "sound_powerattackEnable", sound = "sound_powerattack" },
    [LUIE_ALERT_SOUND_TYPE_RADIAL_AVOID] = { toggle = "sound_radialEnable", sound = "sound_radial" },
    [LUIE_ALERT_SOUND_TYPE_TRAVELER] = { toggle = "sound_travelEnable", sound = "sound_travel" },
    [LUIE_ALERT_SOUND_TYPE_TRAVELER_CC] = { toggle = "sound_travel_ccEnable", sound = "sound_travel_cc" },
    [LUIE_ALERT_SOUND_TYPE_GROUND] = { toggle = "sound_groundEnable", sound = "sound_ground" },
    [LUIE_ALERT_SOUND_TYPE_METEOR] = { toggle = "sound_meteorEnable", sound = "sound_meteor" },
    [LUIE_ALERT_SOUND_TYPE_UNMIT] = { toggle = "sound_unmit_stEnable", sound = "sound_unmit_st" },
    [LUIE_ALERT_SOUND_TYPE_UNMIT_AOE] = { toggle = "sound_unmit_aoeEnable", sound = "sound_unmit_aoe" },
    [LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE] = { toggle = "sound_power_damageEnable", sound = "sound_power_damage" },
    [LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE] = { toggle = "sound_power_buffEnable", sound = "sound_power_buff" },
    [LUIE_ALERT_SOUND_TYPE_SUMMON] = { toggle = "sound_summonEnable", sound = "sound_summon" },
    [LUIE_ALERT_SOUND_TYPE_DESTROY] = { toggle = "sound_destroyEnable", sound = "sound_destroy" },
    [LUIE_ALERT_SOUND_TYPE_HEAL] = { toggle = "sound_healEnable", sound = "sound_heal" },
}

-- Play a sound if the option is enabled and priority is set.
function AbilityAlerts.PlayAlertSound(abilityId, ...)
    local Settings = CombatInfo.SV.alerts
    local soundType = Alerts[abilityId].sound

    if not soundType then
        return
    end

    local soundSettings = SOUND_TYPE_SETTINGS[soundType]
    if not soundSettings then
        return
    end

    -- Check if sound is enabled and get the sound to play
    local isPlay = Settings.toggles[soundSettings.toggle] and Settings.sounds[soundSettings.sound]
    if not isPlay then
        return
    end

    -- Play the sound the configured number of times
    for i = 1, Settings.toggles.soundVolume do
        PlaySound(LUIE.Sounds[isPlay])
    end
end

local drawLocation = 1
function AbilityAlerts.SetupSingleAlertFrame(abilityId, textPrefix, textModifier, textName, textMitigation, abilityIcon, currentTime, endTime, showDuration, crowdControl, sourceUnitId, postCast, alwaysShowInterrupt, neverShowInterrupt, effectOnlyInterrupt, mitigationParts)
    local labelColor
    local borderColor

    if CombatInfo.SV.alerts.toggles.showCrowdControlBorder then
        borderColor = AbilityAlerts.CrowdControlColorSetup(crowdControl, true)
    else
        borderColor = { 0, 0, 0, 0 }
    end
    if CombatInfo.SV.alerts.toggles.ccLabelColor then
        labelColor = AbilityAlerts.CrowdControlColorSetup(crowdControl, false)
    else
        labelColor = CombatInfo.SV.alerts.colors.alertShared
    end

    for i = 1, 3 do
        local alert = _G["LUIE_Alert" .. i]
        if alert.data.available then
            alert.data.id = abilityId
            alert.data.textMitigation = textMitigation
            alert.data.mitigationParts = mitigationParts
            alert.data.textPrefix = textPrefix or ""
            alert.data.textName = textName
            alert.data.textModifier = textModifier or ""
            alert.data.sourceUnitId = sourceUnitId
            alert.icon.icon:SetTexture(abilityIcon)
            alert.data.duration = endTime
            alert.data.postCast = postCast
            local remain = endTime - currentTime
            alert.data.showDuration = CombatInfo.SV.alerts.toggles.alertTimer and showDuration or false
            alert.data.alwaysShowInterrupt = alwaysShowInterrupt
            alert.data.neverShowInterrupt = neverShowInterrupt
            alert.data.effectOnlyInterrupt = effectOnlyInterrupt
            alert.prefix:SetText(alert.data.textPrefix)
            alert.prefix:SetColor(unpack(CombatInfo.SV.alerts.colors.alertShared))
            alert.name:SetText(alert.data.textName)
            alert.name:SetColor(unpack(labelColor))
            alert.modifier:SetText(alert.data.textModifier)
            alert.modifier:SetColor(unpack(CombatInfo.SV.alerts.colors.alertShared))
            alert.mitigation:SetText(textMitigation)
            alert.timer:SetText(alert.data.showDuration and string_format(" %.1f", remain / 1000) or "")
            alert.timer:SetColor(unpack(CombatInfo.SV.alerts.colors.alertTimer))
            alert.icon:SetHidden(false)
            alert:SetHidden(false)
            alert:SetAlpha(1)
            alert.data.available = false
            alert.icon.cd:SetFillColor(unpack(borderColor))
            -- alert.icon.cd:SetHidden(not crowdControl)
            drawLocation = 1 -- As long as this text is filling an available spot, we reset the draw over location to slot 1. If all slots are filled then the draw over code below will cycle and handle abilities.
            AbilityAlerts.RealignAlerts(i)
            return
        end
    end
    -- If no alert frame is available, then draw over in the first spot
    local alert = _G["LUIE_Alert" .. drawLocation]
    alert.data.id = abilityId
    alert.data.textMitigation = textMitigation
    alert.data.mitigationParts = mitigationParts
    alert.data.textPrefix = textPrefix or ""
    alert.data.textName = textName
    alert.data.textModifier = textModifier or ""
    alert.data.sourceUnitId = sourceUnitId
    alert.icon.icon:SetTexture(abilityIcon)
    alert.data.duration = endTime
    alert.data.postCast = postCast
    local remain = endTime - currentTime
    alert.data.showDuration = CombatInfo.SV.alerts.toggles.alertTimer and showDuration or false
    alert.data.alwaysShowInterrupt = alwaysShowInterrupt
    alert.data.neverShowInterrupt = neverShowInterrupt
    alert.data.effectOnlyInterrupt = effectOnlyInterrupt
    alert.prefix:SetText(alert.data.textPrefix)
    alert.prefix:SetColor(unpack(CombatInfo.SV.alerts.colors.alertShared))
    alert.name:SetText(alert.data.textName)
    alert.name:SetColor(unpack(labelColor))
    alert.modifier:SetText(alert.data.textModifier)
    alert.modifier:SetColor(unpack(CombatInfo.SV.alerts.colors.alertShared))
    alert.mitigation:SetText(textMitigation)
    alert.timer:SetText(alert.data.showDuration and string_format(" %.1f", remain / 1000) or "")
    alert.timer:SetColor(unpack(CombatInfo.SV.alerts.colors.alertTimer))
    alert.icon:SetHidden(false)
    alert:SetHidden(false)
    alert:SetAlpha(1)
    alert.data.available = false
    alert.icon.cd:SetFillColor(unpack(borderColor))
    -- alert.icon.cd:SetHidden(not crowdControl)
    drawLocation = drawLocation + 1
    if drawLocation > 3 then
        drawLocation = 1
    end
    AbilityAlerts.RealignAlerts(drawLocation)
end

function AbilityAlerts.RealignAlerts(alertNumber)
    local height = (CombatInfo.SV.alerts.toggles.alertFontSize * 2)
    local alert = _G["LUIE_Alert" .. alertNumber]
    alert:SetDimensions(alert.prefix:GetTextWidth() + alert.name:GetTextWidth() + alert.modifier:GetTextWidth() + 6 + alert.icon:GetWidth() + 6 + alert.mitigation:GetTextWidth() + alert.timer:GetTextWidth(), height)
end

function AbilityAlerts.ProcessAlert(abilityId, unitName, sourceUnitId)
    local Settings = CombatInfo.SV.alerts

    -- Just in case
    if not Alerts[abilityId] then
        return
    end
    -- Ignore this event if we are on refire delay (whether from delay input in the table or from a "bad" event processing)
    if refireDelay[abilityId] then
        return
    end
    -- Ignore this event if we're dueling
    if g_inDuel then
        return
    end

    -- Set CC Type if applicable
    local crowdControl
    if Alerts[abilityId].cc then
        crowdControl = Alerts[abilityId].cc
    end

    -- Get menu setting for filtering and bail out here depending on that setting
    local option = Settings.toggles.alertOptions
    -- Bail out if we only have CC selected and this is not CC
    if option == 2 and crowdControl ~= LUIE_CC_TYPE_STUN and crowdControl ~= LUIE_CC_TYPE_KNOCKDOWN and crowdControl ~= LUIE_CC_TYPE_KNOCKBACK and crowdControl ~= LUIE_CC_TYPE_PULL and crowdControl ~= LUIE_CC_TYPE_DISORIENT and crowdControl ~= LUIE_CC_TYPE_FEAR and crowdControl ~= LUIE_CC_TYPE_CHARM and crowdControl ~= LUIE_CC_TYPE_STAGGER and crowdControl ~= LUIE_CC_TYPE_UNBREAKABLE then
        return
    end
    -- Bail out if we only have unbreakable selected and this is not unbreakable
    if option == 3 and crowdControl ~= LUIE_CC_TYPE_UNBREAKABLE then
        return
    end

    -- Setup refire delay
    if Alerts[abilityId].refire then
        refireDelay[abilityId] = true
        zo_callLater(function ()
                         refireDelay[abilityId] = nil
                     end, Alerts[abilityId].refire) -- buffer by X time
    end

    -- Auto refire for auras to stop events when both reticleover and the unit exist
    if Alerts[abilityId].auradetect then
        refireDelay[abilityId] = true
        local refireTime
        if Alerts[abilityId].refire then
            refireTime = Alerts[abilityId].refire
        else
            refireTime = 250
        end
        zo_callLater(function ()
                         refireDelay[abilityId] = nil
                     end, refireTime) -- buffer by X time
    end

    -- Get Ability Name & Icon
    local abilityName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(abilityId))
    local abilityIcon = GetAbilityIcon(abilityId)
    unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, unitName)
    local savedName = unitName

    -- Override unitName here if we utilize a fakeName / bossName
    if not Alerts[abilityId].summon and not Alerts[abilityId].destroy then
        if Alerts[abilityId].fakeName then
            unitName = Alerts[abilityId].fakeName
        end
    end
    if Alerts[abilityId].bossName and DoesUnitExist("boss1") then
        unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("boss1"))
    end

    -- Handle effects that override by UnitName
    if Effects.EffectOverrideByName[abilityId] then
        if Effects.EffectOverrideByName[abilityId][unitName] then
            if Effects.EffectOverrideByName[abilityId][unitName].icon then
                abilityIcon = Effects.EffectOverrideByName[abilityId][unitName].icon
            end
            if Effects.EffectOverrideByName[abilityId][unitName].name then
                abilityName = Effects.EffectOverrideByName[abilityId][unitName].name
            end
        end
    end

    -- Handle effects that override by ZoneId
    if Effects.ZoneDataOverride[abilityId] then
        local index = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        if Effects.ZoneDataOverride[abilityId][index] then
            if Effects.ZoneDataOverride[abilityId][index].name then
                abilityName = Effects.ZoneDataOverride[abilityId][index].name
            end
            if Effects.ZoneDataOverride[abilityId][index].icon then
                abilityIcon = Effects.ZoneDataOverride[abilityId][index].icon
            end
        end
        if Effects.ZoneDataOverride[abilityId][zoneName] then
            if Effects.ZoneDataOverride[abilityId][zoneName].name then
                abilityName = Effects.ZoneDataOverride[abilityId][zoneName].name
            end
            if Effects.ZoneDataOverride[abilityId][zoneName].icon then
                abilityIcon = Effects.ZoneDataOverride[abilityId][zoneName].icon
            end
        end
    end

    -- Override name, icon, or hide based on Map Name
    if Effects.MapDataOverride[abilityId] then
        local mapName = GetMapName()
        if Effects.MapDataOverride[abilityId][mapName] then
            if Effects.MapDataOverride[abilityId][mapName].icon then
                abilityIcon = Effects.MapDataOverride[abilityId][mapName].icon
            end
            if Effects.MapDataOverride[abilityId][mapName].name then
                abilityName = Effects.MapDataOverride[abilityId][mapName].name
            end
        end
    end

    -- Override icon with default if enabled
    if Settings.toggles.useDefaultIcon and AbilityAlerts.ShouldUseDefaultIcon(abilityId) == true then
        abilityIcon = AbilityAlerts.GetDefaultIcon(Alerts[abilityId].cc)
    end

    -- Override unitName here if we utilize a fakeName / bossName
    if Alerts[abilityId].summon or Alerts[abilityId].destroy then
        if Alerts[abilityId].fakeName then
            unitName = Alerts[abilityId].fakeName
        end
        if Alerts[abilityId].bossName and DoesUnitExist("boss1") then
            unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("boss1"))
        end
    end

    -- Override by location name if it exists or map id here
    if AlertsZone[abilityId] then
        local index = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        if AlertsZone[abilityId][zoneName] then
            unitName = AlertsZone[abilityId][zoneName]
            if LUIE.IsDevDebugEnabled() then
                LUIE.Debug([[Zone Name Override:
    Location: %s
    Unit Name: %s
    Ability ID: %d]], zoneName, unitName, abilityId)
            end
        elseif AlertsZone[abilityId][index] then
            unitName = AlertsZone[abilityId][index]
            if LUIE.IsDevDebugEnabled() then
                LUIE.Debug([[Zone ID Override:
    Zone ID: %d
    Unit Name: %s
    Ability ID: %d]], index, unitName, abilityId)
            end
        end
    end

    -- Override by map name
    if AlertsMap[abilityId] then
        local mapName = GetMapName()
        if AlertsMap[abilityId][mapName] then
            unitName = AlertsMap[abilityId][mapName]
            if LUIE.IsDevDebugEnabled() then
                LUIE.Debug([[Map Name Override:
    Map: %s
    Unit Name: %s
    Ability ID: %d]], mapName, unitName, abilityId)
            end
        end
    end

    -- Match boss names
    if Alerts[abilityId].bossMatch then
        for x = 1, #Alerts[abilityId].bossMatch do
            for i = 1, 4 do
                local bossName = DoesUnitExist("boss" .. i) and zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("boss" .. i)) or ""
                if bossName == Alerts[abilityId].bossMatch[x] then
                    unitName = Alerts[abilityId].bossMatch[x]
                    if LUIE.IsDevDebugEnabled() then
                        LUIE.Debug([[Boss Name Match:
    Boss Name: %s
    Boss Index: %d
    Match Index: %d
    Ability ID: %d]], bossName, i, x, abilityId)
                    end
                end
            end
        end
    end

    if AlertsConvert[abilityId] then
        for i = 1, 4 do
            local bossName = DoesUnitExist("boss" .. i) and zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("boss" .. i)) or ""
            if AlertsConvert[abilityId][bossName] then
                unitName = AlertsConvert[abilityId][bossName]
                if LUIE.IsDevDebugEnabled() then
                    LUIE.Debug([[Boss Add Conversion:
    Original Boss: %s
    Converted Name: %s
    Boss Index: %d
    Ability ID: %d]], bossName, unitName, i, abilityId)
                end
            end
        end
    end

    -- No forced name override check
    if Alerts[abilityId].noForcedNameOverride then
        if savedName ~= "" and savedName ~= nil then
            unitName = savedName
            if LUIE.IsDevDebugEnabled() then
                LUIE.Debug([[Name Override Prevented:
    Original Name: %s
    Ability ID: %d
    Override Type: noForcedNameOverride]], savedName, abilityId)
            end
        end
    end

    if Alerts[abilityId].hideIfNoSource then
        if unitName == "" or unitName == nil then
            return
        end
    end

    local notTheTarget
    if Alerts[abilityId].durationOnlyIfTarget and sourceUnitId == 0 then
        notTheTarget = true
    end

    local modifier = ""
    if Settings.toggles.modifierEnable then
        if sourceUnitId ~= nil and sourceUnitId ~= 0 and not Alerts[abilityId].auradetect and not Alerts[abilityId].noDirect then
            modifier = Settings.toggles.mitigationModifierOnYou
        end
        if Alerts[abilityId].spreadOut then
            modifier = Settings.toggles.mitigationModifierSpreadOut
        end
    end

    if sourceUnitId == 0 then
        sourceUnitId = unitName
    end

    local alwaysShowInterrupt
    local neverShowInterrupt
    local effectOnlyInterrupt
    if Alerts[abilityId].alwaysShowInterrupt then
        alwaysShowInterrupt = true
    end
    if Alerts[abilityId].neverShowInterrupt then
        neverShowInterrupt = true
    end
    if Alerts[abilityId].effectOnlyInterrupt then
        effectOnlyInterrupt = true
    end

    local block
    local blockstagger
    local dodge
    local avoid
    local interrupt
    local shouldusecc
    local power
    local destroy
    local summon
    local unmit
    local duration
    local hiddenDuration
    local postCast

    if Settings.toggles.showAlertMitigate == true then
        if Alerts[abilityId].block == true then
            if Alerts[abilityId].bs then
                blockstagger = true
            else
                block = true
            end
        end
        if Alerts[abilityId].dodge == true then
            dodge = true
        end
        if Alerts[abilityId].avoid == true then
            avoid = true
        end
        if Alerts[abilityId].interrupt == true then
            interrupt = true
        end
        if Alerts[abilityId].shouldusecc == true then
            shouldusecc = true
        end
    end

    if Alerts[abilityId].unmit and Settings.toggles.showAlertUnmit == true then
        unmit = true
    end
    if Alerts[abilityId].power and Settings.toggles.showAlertPower == true then
        power = true
    end
    if Alerts[abilityId].destroy and Settings.toggles.showAlertDestroy == true then
        destroy = true
    end
    if Alerts[abilityId].summon and Settings.toggles.showAlertSummon == true then
        summon = true
    end
    if Alerts[abilityId].duration and not notTheTarget then
        duration = Alerts[abilityId].duration
    end
    if Alerts[abilityId].hiddenDuration then
        hiddenDuration = Alerts[abilityId].hiddenDuration
    end
    if Alerts[abilityId].postCast then
        postCast = Alerts[abilityId].postCast
    else
        postCast = 0
    end

    if not (power == true or destroy == true or summon == true or unmit == true) then
        AbilityAlerts.OnEvent(alertTypes.SHARED, abilityId, abilityName, abilityIcon, unitName, sourceUnitId, postCast, alwaysShowInterrupt, neverShowInterrupt, effectOnlyInterrupt, duration, hiddenDuration, crowdControl, modifier, block, blockstagger, dodge, avoid, interrupt, shouldusecc)
    elseif power == true or destroy == true or summon == true or unmit == true then
        if unmit then
            AbilityAlerts.OnEvent(alertTypes.UNMIT, abilityId, abilityName, abilityIcon, unitName, sourceUnitId, postCast, alwaysShowInterrupt, neverShowInterrupt, effectOnlyInterrupt, duration, hiddenDuration, crowdControl, modifier)
        end
        if power then
            AbilityAlerts.OnEvent(alertTypes.POWER, abilityId, abilityName, abilityIcon, unitName, sourceUnitId, postCast, alwaysShowInterrupt, neverShowInterrupt, effectOnlyInterrupt, duration, hiddenDuration, crowdControl, modifier)
        end
        if destroy then
            AbilityAlerts.OnEvent(alertTypes.DESTROY, abilityId, abilityName, abilityIcon, unitName, sourceUnitId, postCast, alwaysShowInterrupt, neverShowInterrupt, effectOnlyInterrupt, duration, hiddenDuration, crowdControl, modifier)
        end
        if summon then
            AbilityAlerts.OnEvent(alertTypes.SUMMON, abilityId, abilityName, abilityIcon, unitName, sourceUnitId, postCast, alwaysShowInterrupt, neverShowInterrupt, effectOnlyInterrupt, duration, hiddenDuration, crowdControl, modifier)
        end
    end
end

local function CheckInterruptEvent(unitId, abilityId, resultType)
    for i = 1, 3 do
        local alert = _G["LUIE_Alert" .. i]
        if alert.data.sourceUnitId then
            if alert.data.id == abilityId then
                local currentTime = GetFrameTimeMilliseconds()
                local remain = alert.data.duration - currentTime

                -- DEBUG
                -- d("EFFECT INTERRUPTED")
                -- d("Current Duration: " .. remain)

                if (alert.data.sourceUnitId == unitId and (not alert.data.showDuration == false or alert.data.alwaysShowInterrupt)) and remain > 0 and (not alert.data.neverShowInterrupt or deathResults[resultType]) then
                    alert.data = {}
                    alert.data.available = true
                    alert.data.id = ""
                    alert.data.textMitigation = ""
                    alert.data.textPrefix = ""
                    alert.data.textName = "INTERRUPTED!"
                    alert.data.textModifier = ""
                    alert.data.sourceUnitId = ""
                    alert.icon:SetHidden(true)
                    alert.data.duration = currentTime + 1500
                    alert.data.postCast = 0
                    alert.data.showDuration = false
                    alert.prefix:SetText(alert.data.textPrefix)
                    alert.name:SetText(alert.data.textName)
                    alert.name:SetColor(unpack(CombatInfo.SV.alerts.colors.alertShared))
                    alert.modifier:SetText(alert.data.textModifier)

                    alert.mitigation:SetText("")
                    alert.timer:SetText("")
                    alert:SetHidden(false)

                    AbilityAlerts.RealignAlerts(i)
                end
            end
        end
    end
end

function AbilityAlerts.AlertEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer)
    -- Bail out if we're not in combat (reduce spam for nearby)
    if not IsUnitInCombat("player") then
        return
    end
    if not Alerts[abilityId] then
        return
    end

    local Settings = CombatInfo.SV.alerts

    if Settings.toggles.alertEnable and (Settings.toggles.mitigationAura or IsUnitInDungeon("player")) and Alerts[abilityId] and Alerts[abilityId].auradetect then
        if changeType == EFFECT_RESULT_FADED then
            zo_callLater(function ()
                             CheckInterruptEvent(unitId, abilityId)
                         end, 100)
            return
        end

        -- Don't duplicate events if unitTag is player and in a group.
        if Alerts[abilityId].noSelf and unitName == LUIE.PlayerNameRaw then
            return
        end

        if changeType == EFFECT_RESULT_UPDATED and Alerts[abilityId].ignoreRefresh then
            return
        end

        zo_callLater(function ()
                         AbilityAlerts.ProcessAlert(abilityId, unitName, unitId)
                     end, 50)
    end
end

function AbilityAlerts.OnCombatIn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not Alerts[abilityId] then
        return
    end

    local Settings = CombatInfo.SV.alerts
    abilityName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(abilityId))
    local abilityIcon = GetAbilityIcon(abilityId)

    local sourceNameCheck = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)

    -- Handle effects that override by UnitName
    if Effects.EffectOverrideByName[abilityId] then
        if Effects.EffectOverrideByName[abilityId][sourceNameCheck] then
            if Effects.EffectOverrideByName[abilityId][sourceNameCheck].icon then
                abilityIcon = Effects.EffectOverrideByName[abilityId][sourceNameCheck].icon
            end
            if Effects.EffectOverrideByName[abilityId][sourceNameCheck].name then
                abilityName = Effects.EffectOverrideByName[abilityId][sourceNameCheck].name
            end
        end
    end

    -- Handle effects that override by ZoneId
    if Effects.ZoneDataOverride[abilityId] then
        local index = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        if Effects.ZoneDataOverride[abilityId][index] then
            if Effects.ZoneDataOverride[abilityId][index].name then
                abilityName = Effects.ZoneDataOverride[abilityId][index].name
            end
            if Effects.ZoneDataOverride[abilityId][index].icon then
                abilityIcon = Effects.ZoneDataOverride[abilityId][index].icon
            end
        end
        if Effects.ZoneDataOverride[abilityId][zoneName] then
            if Effects.ZoneDataOverride[abilityId][zoneName].name then
                abilityName = Effects.ZoneDataOverride[abilityId][zoneName].name
            end
            if Effects.ZoneDataOverride[abilityId][zoneName].icon then
                abilityIcon = Effects.ZoneDataOverride[abilityId][zoneName].icon
            end
        end
    end

    -- Override icon with default if enabled
    if Settings.toggles.useDefaultIcon and AbilityAlerts.ShouldUseDefaultIcon(abilityId) == true then
        abilityIcon = AbilityAlerts.GetDefaultIcon(Alerts[abilityId].cc)
    end

    -- NEW ALERTS
    if Settings.toggles.alertEnable then
        if sourceName ~= nil and sourceName ~= "" then
            -- Filter when only a certain event type should fire this
            if Alerts[abilityId].result and result ~= Alerts[abilityId].result then
                return
            end
            if Alerts[abilityId].eventdetect or Alerts[abilityId].auradetect then
                return
            end -- Don't create a duplicate warning if event/aura detection already handles this.
            if Alerts[abilityId].noSelf and targetName == LUIE.PlayerNameRaw then
                return
            end -- Don't create alert for self in cases where this is true.

            -- Return if any results occur which we absolutely don't want to display alerts for & stop spam when enemy is out of line of sight, etc and trying to cast
            if result == ACTION_RESULT_EFFECT_FADED or result == ACTION_RESULT_ABILITY_ON_COOLDOWN or result == ACTION_RESULT_BAD_TARGET or result == ACTION_RESULT_BUSY or result == ACTION_RESULT_FAILED or result == ACTION_RESULT_INVALID or result == ACTION_RESULT_CANT_SEE_TARGET or result == ACTION_RESULT_TARGET_DEAD or result == ACTION_RESULT_TARGET_OUT_OF_RANGE or result == ACTION_RESULT_TARGET_TOO_CLOSE or result == ACTION_RESULT_TARGET_NOT_IN_VIEW then
                refireDelay[abilityId] = true
                zo_callLater(function ()
                                 refireDelay[abilityId] = nil
                             end, 1000) -- buffer by X time
                return
            end

            if Alerts[abilityId].block or Alerts[abilityId].dodge or Alerts[abilityId].avoid or Alerts[abilityId].interrupt or Alerts[abilityId].shouldusecc or Alerts[abilityId].unmit or Alerts[abilityId].power or Alerts[abilityId].destroy or Alerts[abilityId].summon then
                -- Filter by priority
                if (Settings.toggles.mitigationDungeon and not IsUnitInDungeon("player")) or not Settings.toggles.mitigationDungeon then
                    if Alerts[abilityId].priority == 3 and not Settings.toggles.mitigationRank3 then
                        return
                    end
                    if Alerts[abilityId].priority == 2 and not Settings.toggles.mitigationRank2 then
                        return
                    end
                    if Alerts[abilityId].priority == 1 and not Settings.toggles.mitigationRank1 then
                        return
                    end
                end

                zo_callLater(function ()
                                 AbilityAlerts.ProcessAlert(abilityId, sourceName, sourceUnitId)
                             end, 50)
            end
        end
    end
end

function AbilityAlerts.OnCombatAlert(eventCode, resultType, isError, abilityName, abilityGraphic, abilityAction_slotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    -- Bail out if we're not in combat (reduce spam for nearby)
    if not IsUnitInCombat("player") then
        return
    end

    local Settings = CombatInfo.SV.alerts

    -- NEW ALERTS
    if Settings.toggles.alertEnable and (Settings.toggles.mitigationAura or sourceUnitId ~= 0 or IsUnitInDungeon("player")) then
        if not refireDelay[abilityId] then
            -- Filter when only a certain event type should fire this
            if Alerts[abilityId].result and resultType ~= Alerts[abilityId].result then
                return
            end
            if Alerts[abilityId].auradetect then
                return
            end -- Don't create a duplicate warning if aura detection already handles this.
            if Alerts[abilityId].noSelf and targetName == LUIE.PlayerNameRaw then
                return
            end -- Don't create alert for self in cases where this is true.

            -- Return if any results occur which we absolutely don't want to display alerts for & stop spam when enemy is out of line of sight, etc and trying to cast
            if resultType == ACTION_RESULT_EFFECT_FADED or resultType == ACTION_RESULT_ABILITY_ON_COOLDOWN or resultType == ACTION_RESULT_BAD_TARGET or resultType == ACTION_RESULT_BUSY or resultType == ACTION_RESULT_FAILED or resultType == ACTION_RESULT_INVALID or resultType == ACTION_RESULT_CANT_SEE_TARGET or resultType == ACTION_RESULT_TARGET_DEAD or resultType == ACTION_RESULT_TARGET_OUT_OF_RANGE or resultType == ACTION_RESULT_TARGET_TOO_CLOSE or resultType == ACTION_RESULT_TARGET_NOT_IN_VIEW then
                refireDelay[abilityId] = true
                zo_callLater(function ()
                                 refireDelay[abilityId] = nil
                             end, 1000) -- buffer by X time
                return
            end

            if Alerts[abilityId].block or Alerts[abilityId].dodge or Alerts[abilityId].avoid or Alerts[abilityId].interrupt or Alerts[abilityId].shouldusecc or Alerts[abilityId].unmit or Alerts[abilityId].power or Alerts[abilityId].destroy or Alerts[abilityId].summon then
                -- Filter by priority
                if (Settings.toggles.mitigationDungeon and not IsUnitInDungeon("player")) or not Settings.toggles.mitigationDungeon then
                    if Alerts[abilityId].priority == 3 and not Settings.toggles.mitigationRank3 then
                        return
                    end
                    if Alerts[abilityId].priority == 2 and not Settings.toggles.mitigationRank2 then
                        return
                    end
                    if Alerts[abilityId].priority == 1 and not Settings.toggles.mitigationRank1 then
                        return
                    end
                end

                zo_callLater(function ()
                                 AbilityAlerts.ProcessAlert(abilityId, sourceName, sourceUnitId)
                             end, 50)
            end
        end
    end
end

function AbilityAlerts.FormatAlertString(inputFormat, params)
    return zo_strgsub(inputFormat, "%%.", function (x)
        if x == "%n" then
            return params.source or ""
        elseif x == "%t" then
            return params.ability or ""
        else
            return x
        end
    end)
end

local function generateMitigationString(Settings, avoid, block, dodge, blockstagger, interrupt, shouldusecc, spacer)
    local stringBlock = ""
    local stringDodge = ""
    local stringAvoid = ""
    local stringInterrupt = ""

    if avoid then
        local color = AbilityAlerts.AlertColors.alertColorAvoid
        stringAvoid = zo_strformat("|c<<1>><<2>>|r", color, Settings.formats.alertAvoid)
    else
        stringAvoid = ""
    end

    if block then
        local color = AbilityAlerts.AlertColors.alertColorBlock
        stringBlock = zo_strformat("|c<<1>><<2>>|r", color, Settings.formats.alertBlock)
    end

    if dodge then
        local color = AbilityAlerts.AlertColors.alertColorDodge
        stringDodge = zo_strformat("|c<<1>><<2>>|r", color, Settings.formats.alertDodge)
    else
        stringDodge = ""
    end

    if blockstagger then
        local color = AbilityAlerts.AlertColors.alertColorBlock
        stringBlock = zo_strformat("|c<<1>><<2>>|r", color, Settings.formats.alertBlockStagger)
    end

    if interrupt then
        local color = AbilityAlerts.AlertColors.alertColorInterrupt
        stringInterrupt = zo_strformat("|c<<1>><<2>>|r", color, Settings.formats.alertInterrupt)
    elseif shouldusecc then
        local color = AbilityAlerts.AlertColors.alertColorInterrupt
        stringInterrupt = zo_strformat("|c<<1>><<2>>|r", color, Settings.formats.alertShouldUseCC)
    else
        stringInterrupt = ""
    end

    if not block and not blockstagger then
        stringBlock = ""
    end

    return stringBlock, stringDodge, stringAvoid, stringInterrupt
end

-- VIEWER
function AbilityAlerts.OnEvent(alertType, abilityId, abilityName, abilityIcon, sourceName, sourceUnitId, postCast, alwaysShowInterrupt, neverShowInterrupt, effectOnlyInterrupt, duration, hiddenDuration, crowdControl, modifier, block, blockstagger, dodge, avoid, interrupt, shouldusecc)
    local Settings = CombatInfo.SV.alerts
    local labelColor = Settings.colors.alertShared
    local prefix
    local textPrefix
    local textName
    local textModifier
    local textMitigation
    local mitigationParts = nil

    if alertType == alertTypes.SHARED then
        local spacer = "-"
        local stringBlock
        local stringDodge
        local stringAvoid
        local stringInterrupt
        local color = AbilityAlerts.AlertColors.alertColorBlock

        -- Set only one of these to true for priority color formatting.
        -- PRIORITY: INTERRUPT > BLOCK STAGGER > DODGE > BLOCK > AVOID
        if blockstagger then
            block = false
        end

        if Settings.toggles.showMitigation then
            stringBlock, stringDodge, stringAvoid, stringInterrupt = generateMitigationString(Settings, avoid, block, dodge, blockstagger, interrupt, shouldusecc, spacer)
        end

        local name = Settings.toggles.mitigationAbilityName

        if modifier ~= "" then
            modifier = (" " .. modifier)
        end

        prefix = (sourceName ~= "" and sourceName ~= nil and sourceName ~= "Offline") and Settings.toggles.mitigationEnemyName or ""

        if prefix ~= "" then
            name = (" " .. name)
        end

        textPrefix = AbilityAlerts.FormatAlertString(prefix, { source = sourceName, ability = abilityName })
        textName = AbilityAlerts.FormatAlertString(name, { source = sourceName, ability = abilityName })
        textModifier = modifier

        -- Build mitigation string with proper spacing
        if Settings.toggles.showMitigation then
            local mitigationPartsTable = {}
            if stringBlock ~= "" then table.insert(mitigationPartsTable, stringBlock) end
            if stringDodge ~= "" then table.insert(mitigationPartsTable, stringDodge) end
            if stringAvoid ~= "" then table.insert(mitigationPartsTable, stringAvoid) end
            if stringInterrupt ~= "" then table.insert(mitigationPartsTable, stringInterrupt) end

            if #mitigationPartsTable > 0 then
                local mitigationText = table.concat(mitigationPartsTable, " " .. spacer .. " ")
                -- Store the base mitigation text without trailing dash for later use
                local baseMitigationText = " " .. spacer .. " " .. mitigationText
                -- Only add the trailing dash if there will be a timer shown
                textMitigation = baseMitigationText .. (duration and " " .. spacer or "")
                -- Store the mitigation parts for later use
                mitigationParts = mitigationPartsTable
            else
                textMitigation = ""
            end
        else
            textMitigation = ""
        end
        -- UNMIT
    elseif alertType == alertTypes.UNMIT then
        local name = Settings.toggles.mitigationAbilityName

        if modifier ~= "" then
            modifier = (" " .. modifier)
        end

        local color = AbilityAlerts.AlertColors.alertColorUnmit
        prefix = (sourceName ~= "" and sourceName ~= nil and sourceName ~= "Offline") and Settings.toggles.mitigationEnemyName or ""

        if prefix ~= "" then
            name = (" " .. name)
        end

        textPrefix = AbilityAlerts.FormatAlertString(prefix, { source = sourceName, ability = abilityName })
        textName = AbilityAlerts.FormatAlertString(name, { source = sourceName, ability = abilityName })
        textModifier = modifier
        textMitigation = zo_strformat("|c<<1>><<2>>|r", color, Settings.formats.alertUnmit)
        -- POWER
    elseif alertType == alertTypes.POWER then
        local color = AbilityAlerts.AlertColors.alertColorPower
        prefix = (sourceName ~= "" and sourceName ~= nil and sourceName ~= "Offline") and Settings.toggles.mitigationPowerPrefixN2 or Settings.toggles.mitigationPowerPrefix2
        textName = AbilityAlerts.FormatAlertString(prefix, { source = sourceName, ability = abilityName })
        textMitigation = zo_strformat("|c<<1>><<2>>|r", color, Settings.formats.alertPower)
        -- DESTROY
    elseif alertType == alertTypes.DESTROY then
        local color = AbilityAlerts.AlertColors.alertColorDestroy
        prefix = (sourceName ~= "" and sourceName ~= nil and sourceName ~= "Offline") and Settings.toggles.mitigationDestroyPrefixN2 or Settings.toggles.mitigationDestroyPrefix2
        textName = AbilityAlerts.FormatAlertString(prefix, { source = sourceName, ability = abilityName })
        textMitigation = zo_strformat("|c<<1>><<2>>|r", color, Settings.formats.alertDestroy)
        -- SUMMON
    elseif alertType == alertTypes.SUMMON then
        local color = AbilityAlerts.AlertColors.alertColorSummon
        prefix = (sourceName ~= "" and sourceName ~= nil and sourceName ~= "Offline") and Settings.toggles.mitigationSummonPrefixN2 or Settings.toggles.mitigationSummonPrefix2
        textName = AbilityAlerts.FormatAlertString(prefix, { source = sourceName, ability = abilityName })
        textMitigation = zo_strformat("|c<<1>><<2>>|r", color, Settings.formats.alertSummon)
    end

    local showDuration = duration and true or false

    if not duration then
        if hiddenDuration then
            duration = hiddenDuration
        else
            duration = 4000
        end
    end

    local currentTime = GetFrameTimeMilliseconds()
    local endTime = currentTime + duration

    AbilityAlerts.SetupSingleAlertFrame(abilityId, textPrefix, textModifier, textName, textMitigation, abilityIcon, currentTime, endTime, showDuration, crowdControl, sourceUnitId, postCast, alwaysShowInterrupt, neverShowInterrupt, effectOnlyInterrupt, mitigationParts)
    AbilityAlerts.PlayAlertSound(abilityId, alertType)
end

-- Updates local variables with new font
function AbilityAlerts.ApplyFontAlert()
    if not CombatInfo.Enabled then
        return
    end

    -- Setup Alerts Font
    local alertFontName = LUIE.Fonts[CombatInfo.SV.alerts.toggles.alertFontFace]
    if not alertFontName or alertFontName == "" then
        LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
        alertFontName = "Univers 67"
    end

    local alertFontStyle = (CombatInfo.SV.alerts.toggles.alertFontStyle and CombatInfo.SV.alerts.toggles.alertFontStyle ~= "") and CombatInfo.SV.alerts.toggles.alertFontStyle or "soft-shadow-thin"
    local alertFontSize = (CombatInfo.SV.alerts.toggles.alertFontSize and CombatInfo.SV.alerts.toggles.alertFontSize > 0) and CombatInfo.SV.alerts.toggles.alertFontSize or 16

    g_alertFont = alertFontName .. "|" .. alertFontSize .. "|" .. alertFontStyle
end
