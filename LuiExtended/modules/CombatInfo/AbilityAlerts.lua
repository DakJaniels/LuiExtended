-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo
--- @class (partial) AbilityAlerts
local AbilityAlerts = {}
--- @class (partial) AbilityAlerts
CombatInfo.AbilityAlerts = AbilityAlerts
local moduleName = LUIE.name .. "CombatInfo" .. "AbilityAlerts"
AbilityAlerts.name = moduleName

local Effects = LuiData.Data.Effects
local Alerts = LuiData.Data.AlertTable
local AlertsZone = LuiData.Data.AlertZoneOverride
local AlertsMap = LuiData.Data.AlertMapOverride
local AlertsConvert = LuiData.Data.AlertBossNameConvert

local pairs = pairs
local zo_strformat = zo_strformat
local string_format = string.format
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()

local uiTlw = {}  -- GUI
AbilityAlerts.uiTlw = uiTlw
local alertPool   -- Control pool for alert controls
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


local ALERT_POST_CAST_FADE_MS = 1000

function AbilityAlerts.StopAlertFadeAnimation(alert)
    if not alert then
        return
    end
    local fadeAnimation = ZO_AlphaAnimation_GetAnimation(alert)
    if fadeAnimation then
        fadeAnimation:Stop(ZO_ALPHA_ANIMATION_OPTION_PREVENT_CALLBACK)
    end
end

function AbilityAlerts.CompleteAlertFadeOut(poolKey)
    if not alertPool then
        return
    end
    local alert = alertPool:GetActiveObject(poolKey)
    if not alert or not alert.data.duration then
        return
    end
    AbilityAlerts.StopAlertFadeAnimation(alert)
    alert:SetAlpha(0)
    alert:SetHidden(true)
    alert.data = {}
    alert.data.duration = nil
    alert.data.postCast = nil
    alert.data.available = true
    alertPool:ReleaseObject(poolKey)
    AbilityAlerts.RepositionAlerts()
end

function AbilityAlerts.StartAlertFadeOut(poolKey, alert)
    if alert.data.fadeOutStarted then
        return
    end
    alert.data.fadeOutStarted = true
    AbilityAlerts.StopAlertFadeAnimation(alert)
    alert:SetAlpha(1)
    local fadeAnimation = ZO_AlphaAnimation_GetAnimation(alert)
    if not fadeAnimation then
        fadeAnimation = ZO_AlphaAnimation:New(alert)
    end
    fadeAnimation:FadeOut(0, ALERT_POST_CAST_FADE_MS, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, function ()
        AbilityAlerts.CompleteAlertFadeOut(poolKey)
    end)
end

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

local ALERT_ICON_ART_INSET = 2

local function GetAlertDebuffBorderTexture()
    if IsInGamepadPreferredMode() then
        return "EsoUI/Art/ActionBar/Gamepad/gp_abilityFrame_debuff.dds"
    end
    return "EsoUI/Art/ActionBar/abilityFrame_debuff.dds"
end

--- Crops the 64×64 ability frame atlas to the center iconSize region (matches SpellCastBuffs.ApplyAbilityFrameTextureCoords).
local function ApplyAbilityFrameTextureCoords(texture, iconSize)
    if not texture then
        return
    end
    if IsInGamepadPreferredMode() then
        texture:SetTextureCoords(0.1094, 0.8906, 0.1094, 0.8906)
    else
        local inset = (64 - iconSize) / 2 / 64
        local outer = (64 + iconSize) / 2 / 64
        texture:SetTextureCoords(inset, outer, inset, outer)
    end
end

function AbilityAlerts.GetAlertIconSize()
    return CombatInfo.SV.alerts.toggles.alertFontSize + 8
end

function AbilityAlerts.MakeAlertIconHostChromeTransparent(iconHost)
    if not iconHost then
        return
    end
    iconHost:SetCenterColor(0, 0, 0, 0)
    iconHost:SetEdgeColor(0, 0, 0, 0)
end

--- @param alert Control
function AbilityAlerts.ApplyAlertIconLayout(alert)
    if not alert or not alert.icon then
        return
    end

    local iconSize = AbilityAlerts.GetAlertIconSize()
    alert.icon:SetDimensions(iconSize, iconSize)
    AbilityAlerts.MakeAlertIconHostChromeTransparent(alert.icon)

    if alert.icon.back then
        alert.icon.back:ClearAnchors()
        alert.icon.back:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, 0, 0)
        alert.icon.back:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, 0, 0)
        alert.icon.back:SetTexture(GetAlertDebuffBorderTexture())
        ApplyAbilityFrameTextureCoords(alert.icon.back, iconSize)
        alert.icon.back:SetHidden(false)
    end

    local artInset = ALERT_ICON_ART_INSET
    local panelInset = zo_max(1, artInset - 1)

    if alert.icon.iconbg then
        alert.icon.iconbg:ClearAnchors()
        alert.icon.iconbg:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, panelInset, panelInset)
        alert.icon.iconbg:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, -panelInset, -panelInset)
    end

    if alert.icon.icon then
        alert.icon.icon:ClearAnchors()
        alert.icon.icon:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, artInset, artInset)
        alert.icon.icon:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, -artInset, -artInset)
    end

    if alert.icon.cd then
        alert.icon.cd:ClearAnchors()
        alert.icon.cd:SetAnchor(TOPLEFT, alert.icon, TOPLEFT, 0, 0)
        alert.icon.cd:SetAnchor(BOTTOMRIGHT, alert.icon, BOTTOMRIGHT, 0, 0)
        alert.icon.cd:ResetCooldown()
        alert.icon.cd:SetFillColor(0, 0, 0, 0)
        alert.icon.cd:SetHidden(true)
    end
end

--- @param alert Control
--- @param borderColor number[]|nil
function AbilityAlerts.ApplyAlertIconFrameColor(alert, borderColor)
    if not alert or not alert.icon or not alert.icon.back then
        return
    end

    AbilityAlerts.ApplyAlertIconLayout(alert)

    if borderColor and borderColor[4] and borderColor[4] > 0 then
        alert.icon.back:SetColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
    else
        alert.icon.back:SetColor(1, 1, 1, 1)
    end
end

function AbilityAlerts.GetAlertBorderColorForAbility(abilityId, crowdControl)
    if not CombatInfo.SV.alerts.toggles.showCrowdControlBorder then
        return { 0, 0, 0, 0 }
    end
    return AbilityAlerts.CrowdControlColorSetup(crowdControl, true)
end

-- Called from menu when font size/face, etc is changed
function AbilityAlerts.ResetAlertSize()
    local activeCount = alertPool:GetActiveObjectCount()
    local alertHeight = CombatInfo.SV.alerts.toggles.alertFontSize * 2
    local alertSpacing = 4

    for key, alert in pairs(alertPool:GetActiveObjects()) do
        local height = alertHeight
        alert.prefix:SetFont(g_alertFont)
        alert.name:SetFont(g_alertFont)
        alert.modifier:SetFont(g_alertFont)
        alert.mitigation:SetFont(g_alertFont)
        alert.timer:SetFont(g_alertFont)
        local borderColor = AbilityAlerts.GetAlertBorderColorForAbility(alert.data.id, alert.data.id and Alerts[alert.data.id] and Alerts[alert.data.id].cc or nil)
        AbilityAlerts.ApplyAlertIconFrameColor(alert, borderColor)
        alert:SetDimensions(alert.prefix:GetTextWidth() + alert.name:GetTextWidth() + alert.modifier:GetTextWidth() + 6 + alert.icon:GetWidth() + 6 + alert.mitigation:GetTextWidth() + alert.timer:GetTextWidth(), height)

        -- Reposition alerts with new spacing
        local alertIndex = 0
        for k, a in pairs(alertPool:GetActiveObjects()) do
            if a == alert then
                alertIndex = alertIndex
                break
            end
            alertIndex = alertIndex + 1
        end
        alert:ClearAnchors()
        alert:SetAnchor(TOP, uiTlw.alertFrame, TOP, 0, alertIndex * (alertHeight + alertSpacing))
    end

    -- Resize the alert frame
    local totalHeight = activeCount * (alertHeight + alertSpacing) - (activeCount > 0 and alertSpacing or 0)
    uiTlw.alertFrame:SetDimensions(500, totalHeight > 0 and totalHeight or alertHeight)
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

-- Event handler for OnMoveStart
function AbilityAlerts.OnMoveStart(control)
    eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
        control.preview.anchorLabel:SetText(zo_strformat("<<1>>, <<2>>", control:GetLeft(), control:GetTop()))
    end)
end

-- Event handler for OnMoveStop
function AbilityAlerts.OnMoveStop(control)
    eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
    CombatInfo.SV.AlertFrameOffsetX = control:GetLeft()
    CombatInfo.SV.AlertFrameOffsetY = control:GetTop()
    CombatInfo.SV.AlertFrameCustomPosition = { control:GetLeft(), control:GetTop() }
end

-- Create Alert Frame - setup XML-created controls and control pool
function AbilityAlerts.CreateAlertFrame()
    -- Apply font for alerts
    AbilityAlerts.ApplyFontAlert()

    -- Reference the XML-created top level control
    uiTlw.alertFrame = windowManager:GetControlByName("LUIE_AlertFrame") --- @type LUIE_AlertFrame

    -- Setup references to preview elements
    uiTlw.alertFrame.preview = uiTlw.alertFrame:GetNamedChild("_Preview")                             --- @type LUIE_AlertFrame_Preview
    uiTlw.alertFrame.preview.anchorLabel = uiTlw.alertFrame.preview:GetNamedChild("_AnchorLabel")     --- @type LUIE_AlertFrame_Preview_AnchorLabel
    uiTlw.alertFrame.preview.anchorLabelBg = uiTlw.alertFrame.preview:GetNamedChild("_AnchorLabelBg") --- @type LUIE_AlertFrame_Preview_AnchorLabelBg
    uiTlw.alertFrame.preview.anchorTexture = uiTlw.alertFrame.preview:GetNamedChild("_AnchorTexture") --- @type LUIE_AlertFrame_Preview_AnchorTexture
    LUIE.RefreshMoverOverlayFonts()

    -- Create control pool for alert controls
    alertPool = ZO_ControlPool:New("LUIE_AlertTemplate", uiTlw.alertFrame)

    -- Set custom factory behavior to initialize fonts and other properties
    alertPool:SetCustomFactoryBehavior(function (alert)
        -- Reference XML-created child controls
        alert.prefix = alert:GetNamedChild("_Prefix")
        alert.name = alert:GetNamedChild("_Name")
        alert.modifier = alert:GetNamedChild("_Modifier")
        alert.icon = alert:GetNamedChild("_Icon")
        alert.icon.back = alert.icon:GetNamedChild("_Back")
        alert.icon.iconbg = alert.icon:GetNamedChild("_IconBg")
        alert.icon.cd = alert.icon:GetNamedChild("_Cd")
        alert.icon.icon = alert.icon:GetNamedChild("_Icon")
        alert.mitigation = alert:GetNamedChild("_Mitigation")
        alert.timer = alert:GetNamedChild("_Timer")

        -- Apply fonts
        alert.prefix:SetFont(g_alertFont)
        alert.name:SetFont(g_alertFont)
        alert.modifier:SetFont(g_alertFont)
        alert.mitigation:SetFont(g_alertFont)
        alert.timer:SetFont(g_alertFont)

        -- Set initial dimensions for icon
        AbilityAlerts.ApplyAlertIconFrameColor(alert, { 0, 0, 0, 0 })

        ZO_AlphaAnimation:New(alert)

        -- Initialize data structure
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
            ["fadeOutStarted"] = false,
        }
    end)

    alertPool:SetCustomResetBehavior(function (alert)
        AbilityAlerts.StopAlertFadeAnimation(alert)
        alert:SetAlpha(1)
    end)

    uiTlw.alertFrame:SetDimensions(500, (CombatInfo.SV.alerts.toggles.alertFontSize * 2) + 4)

    local fragment = ZO_HUDFadeSceneFragment:New(uiTlw.alertFrame, 0, 0)
    AbilityAlerts.alertFragment = fragment

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

    -- When unlocked on console, add alert frame to settings scene so preview is visible while addon settings are open
    if ZO_IsConsoleOrGameCoreUI() and AbilityAlerts.alertFragment then
        local settingsScene = sceneManager:GetScene("LibHarvensAddonSettingsScene")
        if state then
            settingsScene:AddFragment(AbilityAlerts.alertFragment)
        else
            settingsScene:RemoveFragment(AbilityAlerts.alertFragment)
        end
    end

    -- PC/Keyboard version
    if uiTlw.alertFrame and uiTlw.alertFrame:GetType() == CT_TOPLEVELCONTROL then
        AbilityAlerts.GenerateAlertFramePreview(state)
        uiTlw.alertFrame:SetMouseEnabled(state)
        uiTlw.alertFrame:SetMovable(state)
    end
end

-- Called by AbilityAlerts.SetMovingState from the menu as well as by AbilityAlerts.OnUpdateCastbar when preview is enabled
function AbilityAlerts.GenerateAlertFramePreview(state)
    if state then
        -- Acquire 3 controls from the pool for preview and position them
        local alertHeight = CombatInfo.SV.alerts.toggles.alertFontSize * 2
        local alertSpacing = 4

        for i = 1, 3 do
            local alert, alertKey = alertPool:AcquireObject()
            alert.prefix:SetText("")
            alert.name:SetText("NAME TEST")
            alert.name:SetColor(unpack(CombatInfo.SV.alerts.colors.alertShared))
            alert.modifier:SetText("")
            alert.icon.icon:SetTexture("/esoui/art/icons/icon_missing.dds")
            AbilityAlerts.ApplyAlertIconFrameColor(alert, { 0, 0, 0, 0 })
            alert.mitigation:SetText("MITIGATION TEST")
            alert.timer:SetText(CombatInfo.SV.alerts.toggles.alertTimer and " 1.0" or "")
            alert:SetHidden(false)

            -- Position the preview controls
            alert:ClearAnchors()
            alert:SetAnchor(TOP, uiTlw.alertFrame, TOP, 0, (i - 1) * (alertHeight + alertSpacing))

            AbilityAlerts.RealignAlerts(alertKey)
        end

        -- Resize frame for preview
        local totalHeight = 3 * (alertHeight + alertSpacing) - alertSpacing
        uiTlw.alertFrame:SetDimensions(500, totalHeight)
    else
        -- Release all active controls when exiting preview mode
        alertPool:ReleaseAllObjects()
        uiTlw.alertFrame:SetDimensions(500, CombatInfo.SV.alerts.toggles.alertFontSize * 2)
    end

    uiTlw.alertFrame.preview:SetHidden(not state)
    uiTlw.alertFrame:SetHidden(not state)
end

-- Update ticker for Alerts
function AbilityAlerts.AlertUpdate(currentTime)
    for key, alert in pairs(alertPool:GetActiveObjects()) do
        if alert.data.duration then
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
            if postCast <= -1000 then
                -- Fallback if fade animation did not run (e.g. reload mid-fade).
                AbilityAlerts.CompleteAlertFadeOut(key)
            elseif remain <= 0 then
                -- alert:SetHidden(true)
                -- alert.data = { }
                if postCast <= 0 then
                    AbilityAlerts.StartAlertFadeOut(key, alert)
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

    for key, alert in pairs(alertPool:GetActiveObjects()) do
        if alert.data.sourceUnitId then
            targetName = zo_strformat("<<C:1>>", targetName)

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
                AbilityAlerts.StopAlertFadeAnimation(alert)
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
                alert.data.fadeOutStarted = false
                alert.data.showDuration = false
                alert.prefix:SetText(alert.data.textPrefix)
                alert.name:SetText(alert.data.textName)
                alert.name:SetColor(unpack(CombatInfo.SV.alerts.colors.alertShared))
                alert.modifier:SetText(alert.data.textModifier)
                alert.mitigation:SetText("")
                alert.timer:SetText("")
                alert:SetHidden(false)

                AbilityAlerts.RealignAlerts(key)
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

-- Play alert sound from Alerts[abilityId].sound when that sound type is enabled in settings.
function AbilityAlerts.PlayAlertSound(abilityId)
    local Settings = CombatInfo.SV.alerts
    local alertEntry = Alerts[abilityId]
    if not alertEntry or not alertEntry.sound then
        return
    end
    local soundType = alertEntry.sound

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

function AbilityAlerts.SetupSingleAlertFrame(abilityId, textPrefix, textModifier, textName, textMitigation, abilityIcon, currentTime, endTime, showDuration, crowdControl, sourceUnitId, postCast, alwaysShowInterrupt, neverShowInterrupt, effectOnlyInterrupt, mitigationParts)
    local borderColor = AbilityAlerts.GetAlertBorderColorForAbility(abilityId, crowdControl)
    local labelColor
    if CombatInfo.SV.alerts.toggles.ccLabelColor then
        labelColor = AbilityAlerts.CrowdControlColorSetup(crowdControl, false)
    else
        labelColor = CombatInfo.SV.alerts.colors.alertShared
    end

    -- Acquire an alert control from the pool
    local alert, alertKey = alertPool:AcquireObject()

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
    alert.data.fadeOutStarted = false
    AbilityAlerts.StopAlertFadeAnimation(alert)
    alert:SetAlpha(1)
    alert.data.available = false
    AbilityAlerts.ApplyAlertIconFrameColor(alert, borderColor)

    -- Position the alert control (stack them vertically from the top)
    alert:ClearAnchors()
    local alertHeight = CombatInfo.SV.alerts.toggles.alertFontSize * 2
    local alertSpacing = 4
    local verticalOffset = (alertPool:GetActiveObjectCount() - 1) * (alertHeight + alertSpacing)
    alert:SetAnchor(TOP, uiTlw.alertFrame, TOP, 0, verticalOffset)

    -- Resize the alert frame to accommodate all alerts
    local totalHeight = alertPool:GetActiveObjectCount() * (alertHeight + alertSpacing) - alertSpacing
    uiTlw.alertFrame:SetDimensions(500, totalHeight)

    AbilityAlerts.RealignAlerts(alertKey)
end

function AbilityAlerts.RealignAlerts(alertKey)
    local height = (CombatInfo.SV.alerts.toggles.alertFontSize * 2)
    local alert = alertPool:GetActiveObject(alertKey)
    if alert then
        alert:SetDimensions(alert.prefix:GetTextWidth() + alert.name:GetTextWidth() + alert.modifier:GetTextWidth() + 6 + alert.icon:GetWidth() + 6 + alert.mitigation:GetTextWidth() + alert.timer:GetTextWidth(), height)
    end
end

function AbilityAlerts.RepositionAlerts()
    local alertHeight = CombatInfo.SV.alerts.toggles.alertFontSize * 2
    local alertSpacing = 4
    local index = 0

    for key, alert in pairs(alertPool:GetActiveObjects()) do
        alert:ClearAnchors()
        alert:SetAnchor(TOP, uiTlw.alertFrame, TOP, 0, index * (alertHeight + alertSpacing))
        index = index + 1
    end

    -- Resize the alert frame
    local activeCount = alertPool:GetActiveObjectCount()
    local totalHeight = activeCount * (alertHeight + alertSpacing) - (activeCount > 0 and alertSpacing or 0)
    uiTlw.alertFrame:SetDimensions(500, totalHeight > 0 and totalHeight or alertHeight)
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
    local abilityName = zo_strformat("<<C:1>>", GetAbilityName(abilityId))
    local abilityIcon = GetAbilityIcon(abilityId)
    unitName = zo_strformat("<<C:1>>", unitName)
    local savedName = unitName

    -- Override unitName here if we utilize a fakeName / bossName
    if not Alerts[abilityId].summon and not Alerts[abilityId].destroy then
        if Alerts[abilityId].fakeName then
            unitName = Alerts[abilityId].fakeName
        end
    end
    if Alerts[abilityId].bossName and DoesUnitExist("boss1") then
        unitName = zo_strformat("<<C:1>>", GetUnitName("boss1"))
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
            unitName = zo_strformat("<<C:1>>", GetUnitName("boss1"))
        end
    end

    -- Override by location name if it exists or map id here
    if AlertsZone[abilityId] then
        local index = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        if AlertsZone[abilityId][zoneName] then
            unitName = AlertsZone[abilityId][zoneName]
            if LUIE.IsDevDebugEnabled() then
                LUIE:Log("Debug", [[Zone Name Override:
    Location: %s
    Unit Name: %s
    Ability ID: %d]], zoneName, unitName, abilityId)
            end
        elseif AlertsZone[abilityId][index] then
            unitName = AlertsZone[abilityId][index]
            if LUIE.IsDevDebugEnabled() then
                LUIE:Log("Debug", [[Zone ID Override:
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
                LUIE:Log("Debug", [[Map Name Override:
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
                local bossName = DoesUnitExist("boss" .. i) and zo_strformat("<<C:1>>", GetUnitName("boss" .. i)) or ""
                if bossName == Alerts[abilityId].bossMatch[x] then
                    unitName = Alerts[abilityId].bossMatch[x]
                    if LUIE.IsDevDebugEnabled() then
                        LUIE:Log("Debug", [[Boss Name Match:
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
            local bossName = DoesUnitExist("boss" .. i) and zo_strformat("<<C:1>>", GetUnitName("boss" .. i)) or ""
            if AlertsConvert[abilityId][bossName] then
                unitName = AlertsConvert[abilityId][bossName]
                if LUIE.IsDevDebugEnabled() then
                    LUIE:Log("Debug", [[Boss Add Conversion:
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
                LUIE:Log("Debug", [[Name Override Prevented:
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
    for key, alert in pairs(alertPool:GetActiveObjects()) do
        if alert.data.sourceUnitId then
            if alert.data.id == abilityId then
                local currentTime = GetFrameTimeMilliseconds()
                local remain = alert.data.duration - currentTime

                -- DEBUG
                -- d("EFFECT INTERRUPTED")
                -- d("Current Duration: " .. remain)

                if (alert.data.sourceUnitId == unitId and (not alert.data.showDuration == false or alert.data.alwaysShowInterrupt)) and remain > 0 and (not alert.data.neverShowInterrupt or deathResults[resultType]) then
                    AbilityAlerts.StopAlertFadeAnimation(alert)
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
                    alert.data.fadeOutStarted = false
                    alert.data.showDuration = false
                    alert.prefix:SetText(alert.data.textPrefix)
                    alert.name:SetText(alert.data.textName)
                    alert.name:SetColor(unpack(CombatInfo.SV.alerts.colors.alertShared))
                    alert.modifier:SetText(alert.data.textModifier)

                    alert.mitigation:SetText("")
                    alert.timer:SetText("")
                    alert:SetHidden(false)
                    alert:SetAlpha(1)

                    AbilityAlerts.RealignAlerts(key)
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

local ALERT_HIT_VALUE_LIGHT_ATTACK_MS = 75

--- Combat log hitValue filters (optional AlertTableItem minHitValue / maxHitValue / hitValueEquals).
function AbilityAlerts.ShouldShowAlertForHitValue(abilityId, hitValue)
    if type(hitValue) ~= "number" then
        return true
    end
    if hitValue <= ALERT_HIT_VALUE_LIGHT_ATTACK_MS then
        return false
    end
    local entry = Alerts[abilityId]
    if not entry then
        return true
    end
    if entry.minHitValue and hitValue < entry.minHitValue then
        return false
    end
    if entry.maxHitValue and hitValue > entry.maxHitValue then
        return false
    end
    if entry.hitValueEquals and hitValue ~= entry.hitValueEquals then
        return false
    end
    return true
end

function AbilityAlerts.OnCombatIn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not Alerts[abilityId] then
        return
    end

    local Settings = CombatInfo.SV.alerts
    abilityName = zo_strformat("<<C:1>>", GetAbilityName(abilityId))
    local abilityIcon = GetAbilityIcon(abilityId)

    local sourceNameCheck = zo_strformat("<<C:1>>", sourceName)

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
                if not AbilityAlerts.ShouldShowAlertForHitValue(abilityId, hitValue) then
                    return
                end
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
                if not AbilityAlerts.ShouldShowAlertForHitValue(abilityId, hitValue) then
                    return
                end
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
    return StringOnlyGSUB(inputFormat, "%%.", function (x)
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
    AbilityAlerts.PlayAlertSound(abilityId)
end

-- Updates local variables with new font
function AbilityAlerts.ApplyFontAlert()
    if not CombatInfo.Enabled then
        return
    end

    -- Setup Alerts Font
    local alertFontStyle = CombatInfo.SV.alerts.toggles.alertFontStyle
    local alertFontSize = (CombatInfo.SV.alerts.toggles.alertFontSize and CombatInfo.SV.alerts.toggles.alertFontSize > 0) and CombatInfo.SV.alerts.toggles.alertFontSize or 16

    g_alertFont = LUIE.Font.Resolve(CombatInfo.SV.alerts.toggles.alertFontFace, alertFontSize, alertFontStyle)
end
