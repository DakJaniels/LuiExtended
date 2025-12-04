-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local UI = LUIE.UI
local LuiData = LuiData
local Data = LuiData.Data
local Abilities = Data.Abilities
local Castbar = Data.CastBarTable

--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar

--- @class (partial) CastBar
local CastBar = {}
CastBar.__index = CastBar
ActionBar.CastBar = CastBar

local zo_strformat = zo_strformat
local string_format = string.format
local timeMs = GetFrameTimeMilliseconds
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER

local moduleName = LUIE.name .. "ActionBar" .. "CastBar"

-- Module-local state
local uiTlw = {}
CastBar.uiTlw = uiTlw
ActionBar.uiTlw = CastBar.uiTlw
local castbar = {}
local g_casting = false
local g_castbarWorldMapFix = false
local g_castbarFont

-- Movement detection for cast breaking
local savedPlayerX = 0
local savedPlayerZ = 0
local playerX = 0
local playerZ = 0

-- ===== HELPER FUNCTIONS =====

local function getAbilityName(abilityId, casterUnitTag)
    return GetAbilityName(abilityId, casterUnitTag)
end

local function getAbilityCastInfo(abilityId, overrideActiveRank, overrideCasterUnitTag)
    return GetAbilityCastInfo(abilityId, overrideActiveRank, overrideCasterUnitTag)
end

-- ===== PUBLIC FUNCTIONS =====

-- Stops cast bar
function CastBar.StopCastBar()
    local state = ActionBar.CastBarUnlocked
    castbar.bar.name:SetHidden(true)
    castbar.bar.timer:SetHidden(true)
    castbar:SetHidden(true)
    castbar.remain = nil
    castbar.starts = nil
    castbar.ends = nil
    castbar.currentIcon = nil
    g_casting = false
    eventManager:UnregisterForUpdate(moduleName)

    if state then
        CastBar.GenerateCastbarPreview(state)
    end
end

-- Updates Cast Bar (called every 20ms when active)
---
--- @param currentTimeMs number
function CastBar.OnUpdateCastbar(currentTimeMs)
    local castStarts = castbar.starts
    local castEnds = castbar.ends
    local remain = castbar.remain - currentTimeMs
    if remain <= 0 then
        CastBar.StopCastBar()
    else
        if ActionBar.SV.CastBarTimer then
            castbar.bar.timer:SetText(string_format("%.1f", remain / 1000))
        end
        if castbar.type == 1 then
            castbar.bar.bar:SetValue((currentTimeMs - castStarts) / (castEnds - castStarts))
        else
            castbar.bar.bar:SetValue(1 - ((currentTimeMs - castStarts) / (castEnds - castStarts)))
        end
    end
end

function CastBar.CreateCastBar()
    uiTlw.castBar = UI:TopLevel(nil, nil)

    uiTlw.castBar:SetDimensions(ActionBar.SV.CastBarSizeW + ActionBar.SV.CastBarIconSize + 4, ActionBar.SV.CastBarSizeH)

    uiTlw.castBar.preview = UI:Backdrop(uiTlw.castBar, "fill", nil, nil, nil, true)
    uiTlw.castBar.previewLabel = UI:Label(uiTlw.castBar.preview, { CENTER, CENTER }, nil, nil, "ZoFontGameMedium", "Cast Bar", false)
    -- Update font to use better readable font
    if IsConsoleUI() and LUIE.ConsoleMoverHelper then
        local fontName = "LUIE Default Font"
        if LUIE.Fonts and LUIE.Fonts[fontName] then
            local fontSize = 16
            local fontStyle = "soft-shadow-thick"
            local fontString = ZO_CreateFontString(fontName, fontSize, fontStyle)
            uiTlw.castBar.previewLabel:SetFont(fontString)
        else
            if IsInGamepadPreferredMode() or IsConsoleUI() then
                uiTlw.castBar.previewLabel:SetFont("$(GAMEPAD_MEDIUM_FONT)|16|soft-shadow-thick")
            else
                uiTlw.castBar.previewLabel:SetFont("$(MEDIUM_FONT)|16|soft-shadow-thick")
            end
        end
    end

    local tlwOnMoveStart = function (self)
        eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
            self.preview.anchorLabel:SetText(zo_strformat("<<1>>, <<2>>", self:GetLeft(), self:GetTop()))
        end)
    end
    local tlwOnMoveStop = function (self)
        eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
        ActionBar.SV.CastbarOffsetX = self:GetLeft()
        ActionBar.SV.CastbarOffsetY = self:GetTop()
        ActionBar.SV.CastBarCustomPosition = { self:GetLeft(), self:GetTop() }
    end

    uiTlw.castBar:SetHandler("OnMoveStart", tlwOnMoveStart)
    uiTlw.castBar:SetHandler("OnMoveStop", tlwOnMoveStop)

    uiTlw.castBar.preview.anchorTexture = UI:Texture(uiTlw.castBar.preview, { TOPLEFT, TOPLEFT }, { 16, 16 }, "/esoui/art/reticle/border_topleft.dds", DL_OVERLAY, false)
    uiTlw.castBar.preview.anchorTexture:SetColor(1, 1, 0, 0.9)

    uiTlw.castBar.preview.anchorLabel = UI:Label(uiTlw.castBar.preview, { BOTTOMLEFT, TOPLEFT, 0, -1 }, nil, { 0, 2 }, "ZoFontGameSmall", "xxx, yyy", false)
    uiTlw.castBar.preview.anchorLabel:SetColor(1, 1, 0, 1)
    uiTlw.castBar.preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
    uiTlw.castBar.preview.anchorLabel:SetDrawTier(DT_MEDIUM)
    uiTlw.castBar.preview.anchorLabelBg = UI:Backdrop(uiTlw.castBar.preview.anchorLabel, "fill", nil, { 0, 0, 0, 1 }, { 0, 0, 0, 1 }, false)
    uiTlw.castBar.preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
    uiTlw.castBar.preview.anchorLabelBg:SetDrawTier(DT_LOW)

    local fragment = ZO_HUDFadeSceneFragment:New(uiTlw.castBar, 0, 0)

    sceneManager:GetScene("hud"):AddFragment(fragment)
    sceneManager:GetScene("hudui"):AddFragment(fragment)
    sceneManager:GetScene("siegeBar"):AddFragment(fragment)
    sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

    castbar = UI:Backdrop(uiTlw.castBar, nil, nil, { 0, 0, 0, 0.5 }, { 0, 0, 0, 1 }, false)
    castbar:SetAnchor(LEFT, uiTlw.castBar, LEFT, 0, 0)

    castbar.starts = 0
    castbar.ends = 0
    castbar.remain = 0

    castbar:SetDimensions(ActionBar.SV.CastBarIconSize, ActionBar.SV.CastBarIconSize)

    castbar.back = UI:Texture(castbar, nil, nil, LUIE_MEDIA_ICONS_ICON_BORDER_ICON_BORDER_DDS, DL_BACKGROUND, false)
    castbar.back:SetAnchor(TOPLEFT, castbar, TOPLEFT, 0, 0)
    castbar.back:SetAnchor(BOTTOMRIGHT, castbar, BOTTOMRIGHT, 0, 0)

    castbar.iconbg = UI:Texture(castbar, nil, nil, "/esoui/art/actionbar/abilityinset.dds", DL_CONTROLS, false)
    castbar.iconbg = UI:Backdrop(castbar, nil, nil, { 0, 0, 0, 0.9 }, { 0, 0, 0, 0.9 }, false)
    castbar.iconbg:SetDrawLevel(DL_CONTROLS)
    castbar.iconbg:SetAnchor(TOPLEFT, castbar, TOPLEFT, 3, 3)
    castbar.iconbg:SetAnchor(BOTTOMRIGHT, castbar, BOTTOMRIGHT, -3, -3)

    castbar.icon = UI:Texture(castbar, nil, nil, "/esoui/art/icons/icon_missing.dds", DL_CONTROLS, false)
    castbar.icon:SetAnchor(TOPLEFT, castbar, TOPLEFT, 3, 3)
    castbar.icon:SetAnchor(BOTTOMRIGHT, castbar, BOTTOMRIGHT, -3, -3)

    castbar.bar =
    {
        ["backdrop"] = UI:Backdrop(castbar, nil, { ActionBar.SV.CastBarSizeW, ActionBar.SV.CastBarSizeH }, nil, nil, false),
        ["bar"] = UI:StatusBar(castbar, nil, { ActionBar.SV.CastBarSizeW - 4, ActionBar.SV.CastBarSizeH - 4 }, nil, false),
        ["name"] = UI:Label(castbar, nil, nil, nil, nil, g_castbarFont, false),
        ["timer"] = UI:Label(castbar, nil, nil, nil, nil, g_castbarFont, false),
    }
    castbar.id = 0

    castbar.bar.backdrop:SetEdgeTexture("", 8, 2, 2, 2)
    castbar.bar.backdrop:SetDrawLayer(DL_BACKGROUND)
    castbar.bar.backdrop:SetDrawLevel(DL_CONTROLS)
    castbar.bar.bar:SetMinMax(0, 1)
    castbar.bar.bar:SetGradientColors(0, 47 / 255, 130 / 255, 1, 82 / 255, 215 / 255, 1, 1)
    castbar.bar.backdrop:SetCenterColor((0.1 * ActionBar.SV.CastBarGradientC1[1]), (0.1 * ActionBar.SV.CastBarGradientC1[2]), (0.1 * ActionBar.SV.CastBarGradientC1[3]), 0.75)
    castbar.bar.bar:SetGradientColors(ActionBar.SV.CastBarGradientC1[1], ActionBar.SV.CastBarGradientC1[2], ActionBar.SV.CastBarGradientC1[3], 1, ActionBar.SV.CastBarGradientC2[1], ActionBar.SV.CastBarGradientC2[2], ActionBar.SV.CastBarGradientC2[3], 1)

    castbar.bar.backdrop:ClearAnchors()
    castbar.bar.backdrop:SetAnchor(LEFT, castbar, RIGHT, 4, 0)

    castbar.bar.timer:ClearAnchors()
    castbar.bar.timer:SetAnchor(RIGHT, castbar.bar.backdrop, RIGHT, -4, 0)
    castbar.bar.timer:SetHidden(true)

    castbar.bar.name:ClearAnchors()
    castbar.bar.name:SetAnchor(LEFT, castbar.bar.backdrop, LEFT, 4, 0)
    castbar.bar.name:SetHidden(true)

    castbar.bar.bar:SetTexture(LUIE.StatusbarTextures[ActionBar.SV.CastBarTexture])
    castbar.bar.bar:ClearAnchors()
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)

    castbar.bar.timer:SetText("Timer")
    castbar.bar.name:SetText("Name")

    castbar:SetHidden(true)
end

function CastBar.ResizeCastBar()
    uiTlw.castBar:SetDimensions(ActionBar.SV.CastBarSizeW + ActionBar.SV.CastBarIconSize + 4, ActionBar.SV.CastBarSizeH)
    castbar:ClearAnchors()
    castbar:SetAnchor(LEFT, uiTlw.castBar, LEFT)

    castbar:SetDimensions(ActionBar.SV.CastBarIconSize, ActionBar.SV.CastBarIconSize)
    castbar.bar.backdrop:SetDimensions(ActionBar.SV.CastBarSizeW, ActionBar.SV.CastBarSizeH)
    castbar.bar.bar:SetDimensions(ActionBar.SV.CastBarSizeW - 4, ActionBar.SV.CastBarSizeH - 4)

    castbar.bar.backdrop:ClearAnchors()
    castbar.bar.backdrop:SetAnchor(LEFT, castbar, RIGHT, 4, 0)

    castbar.bar.timer:ClearAnchors()
    castbar.bar.timer:SetAnchor(RIGHT, castbar.bar.backdrop, RIGHT, -4, 0)

    castbar.bar.name:ClearAnchors()
    castbar.bar.name:SetAnchor(LEFT, castbar.bar.backdrop, LEFT, 4, 0)

    castbar.bar.bar:ClearAnchors()
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)

    CastBar.SetCastBarPosition()
end

function CastBar.UpdateCastBar()
    if not castbar.bar or not castbar.bar.name then
        return
    end

    if g_castbarFont then
        castbar.bar.name:SetFont(g_castbarFont)
        castbar.bar.timer:SetFont(g_castbarFont)
    end

    if LUIE.StatusbarTextures and LUIE.StatusbarTextures[ActionBar.SV.CastBarTexture] then
        castbar.bar.bar:SetTexture(LUIE.StatusbarTextures[ActionBar.SV.CastBarTexture])
    end

    if ActionBar.SV.CastBarGradientC1 and ActionBar.SV.CastBarGradientC2 then
        castbar.bar.backdrop:SetCenterColor((0.1 * ActionBar.SV.CastBarGradientC1[1]), (0.1 * ActionBar.SV.CastBarGradientC1[2]), (0.1 * ActionBar.SV.CastBarGradientC1[3]), 0.75)
        castbar.bar.bar:SetGradientColors(ActionBar.SV.CastBarGradientC1[1], ActionBar.SV.CastBarGradientC1[2], ActionBar.SV.CastBarGradientC1[3], 1, ActionBar.SV.CastBarGradientC2[1], ActionBar.SV.CastBarGradientC2[2], ActionBar.SV.CastBarGradientC2[3], 1)
    end
end

function CastBar.ResetCastBarPosition()
    if not ActionBar.Enabled then
        return
    end
    ActionBar.SV.CastbarOffsetX = nil
    ActionBar.SV.CastbarOffsetY = nil
    ActionBar.SV.CastBarCustomPosition = nil
    CastBar.SetCastBarPosition()
    CastBar.SetMovingState(false)
end

function CastBar.SetCastBarPosition()
    if uiTlw.castBar and uiTlw.castBar:GetType() == CT_TOPLEVELCONTROL then
        uiTlw.castBar:ClearAnchors()

        if ActionBar.SV.CastbarOffsetX ~= nil and ActionBar.SV.CastbarOffsetY ~= nil then
            uiTlw.castBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ActionBar.SV.CastbarOffsetX, ActionBar.SV.CastbarOffsetY)
        else
            uiTlw.castBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, 320)
        end
    end

    local savedPos = ActionBar.SV.CastBarCustomPosition
    uiTlw.castBar.preview.anchorLabel:SetText((savedPos ~= nil and #savedPos == 2) and zo_strformat("<<1>>, <<2>>", savedPos[1], savedPos[2]) or "default")
end

---
--- @param state boolean
function CastBar.SetMovingState(state)
    if not ActionBar.Enabled then
        return
    end
    ActionBar.CastBarUnlocked = state

    -- Use console helper if on console
    if IsConsoleUI() and LUIE.ConsoleMoverHelper and uiTlw.castBar and uiTlw.castBar:GetType() == CT_TOPLEVELCONTROL then
        local MoverHelper = LUIE.ConsoleMoverHelper
        local EditModeController = LUIE.EditModeController

        -- Activate edit mode when unlocking on console
        if EditModeController and state then
            if not EditModeController:IsEditModeActive() then
                EditModeController:SetEditModeActive(true, "ActionBar")
            end
        end

        CastBar.GenerateCastbarPreview(state)
        MoverHelper.SetupGamepadHandler(uiTlw.castBar, "default", function (control, left, top)
            ActionBar.SV.CastbarOffsetX = left
            ActionBar.SV.CastbarOffsetY = top
            local savedPos = ActionBar.SV.CastBarCustomPosition
            if savedPos then
                savedPos[1] = left
                savedPos[2] = top
            end
        end)
        MoverHelper.UpdateControlState(uiTlw.castBar, "castBar", state)

        return
    end

    -- PC/Keyboard version
    if uiTlw.castBar and uiTlw.castBar:GetType() == CT_TOPLEVELCONTROL then
        CastBar.GenerateCastbarPreview(state)
        uiTlw.castBar:SetMouseEnabled(state)
        uiTlw.castBar:SetMovable(state)
    end
end

-- Called by CastBar.SetMovingState from the menu as well as by CastBar.OnUpdateCastbar when preview is enabled
---
--- @param state boolean
function CastBar.GenerateCastbarPreview(state)
    local previewIcon = "/esoui/art/icons/icon_missing.dds"
    castbar.icon:SetTexture(previewIcon)
    if ActionBar.SV.CastBarLabel then
        local previewName = "Test"
        castbar.bar.name:SetText(previewName)
        castbar.bar.name:SetHidden(not state)
    end
    if ActionBar.SV.CastBarTimer then
        castbar.bar.timer:SetText(string_format("1.0"))
        castbar.bar.timer:SetHidden(not state)
    end
    castbar.bar.bar:SetValue(1)

    uiTlw.castBar.preview:SetHidden(not state)
    uiTlw.castBar:SetHidden(not state)
    castbar:SetHidden(not state)
end

---
--- @param eventCode number
--- @param durationMs number
function CastBar.SoulGemResurrectionStart(eventCode, durationMs)
    CastBar.StopCastBar()

    local icon = "/esoui/art/icons/achievement_frostvault_death_challenge.dds"
    local name = Abilities.Innate_Soul_Gem_Resurrection
    local duration = durationMs

    local currentTimeMs = timeMs()
    local endTime = currentTimeMs + duration
    local remain = endTime - currentTimeMs

    castbar.remain = endTime
    castbar.starts = currentTimeMs
    castbar.ends = endTime
    castbar.icon:SetTexture(icon)
    castbar.type = 1
    castbar.bar.bar:SetValue(0)

    if ActionBar.SV.CastBarLabel then
        castbar.bar.name:SetText(name)
        castbar.bar.name:SetHidden(false)
    end
    if ActionBar.SV.CastBarTimer then
        castbar.bar.timer:SetText(string_format("%.1f", remain / 1000))
        castbar.bar.timer:SetHidden(false)
    end

    castbar:SetHidden(false)
    g_casting = true
    eventManager:RegisterForUpdate(moduleName, 20, CastBar.OnUpdateCastbar)
end

---
--- @param eventCode number
function CastBar.SoulGemResurrectionEnd(eventCode)
    CastBar.StopCastBar()
end

-- Very basic handler registered to only read CC events on the player
---
--- @param eventCode integer
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function CastBar.OnCombatEventBreakCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if Castbar.IgnoreCastBarStun[abilityId] or Castbar.IgnoreCastBreakingActions[castbar.id] then
        return
    end

    if not Castbar.IsCast[abilityId] then
        CastBar.StopCastBar()
    end
end

-- Listens to EVENT_COMBAT_EVENT
--- @param eventCode integer
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function CastBar.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not ActionBar.SV.CastBarEnable or ((sourceType ~= COMBAT_UNIT_TYPE_PLAYER and not Castbar.CastOverride[abilityId])
        and (targetType ~= COMBAT_UNIT_TYPE_PLAYER or result ~= ACTION_RESULT_EFFECT_FADED)) then
        return
    end

    if Castbar.CastBreakingActions[abilityId] then
        if not Castbar.IgnoreCastBreakingActions[castbar.id] then
            CastBar.StopCastBar()
        end
    end

    local icon = GetAbilityIcon(abilityId)
    local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, getAbilityName(abilityId))
    local name = cachedName

    if not Castbar.IsCast[abilityId] or ActionBar.SV.blacklist[abilityId] or ActionBar.SV.blacklist[name] then
        return
    end

    if Castbar.IsHeavy[abilityId] and not ActionBar.SV.CastBarHeavy then
        return
    end

    local duration
    local channeled, durationValue = getAbilityCastInfo(abilityId)
    local forceChanneled = false

    if Castbar.CastChannelOverride[abilityId] then
        channeled = true
    end

    if channeled then
        duration = Castbar.CastDurationFix[abilityId] or result == ACTION_RESULT_EFFECT_GAINED_DURATION and hitValue or durationValue
    else
        duration = Castbar.CastDurationFix[abilityId] or durationValue
    end

    if result == ACTION_RESULT_BEGIN and not channeled and not Castbar.CastDurationFix[abilityId] then
        CastBar.StopCastBar()
    elseif result == ACTION_RESULT_EFFECT_GAINED_DURATION and channeled then
        CastBar.StopCastBar()
    elseif result == ACTION_RESULT_EFFECT_GAINED and channeled then
        CastBar.StopCastBar()
    elseif result == ACTION_RESULT_EFFECT_FADED and channeled then
        CastBar.StopCastBar()
    end

    if Castbar.CastChannelConvert[abilityId] then
        channeled = true
        forceChanneled = true
        duration = Castbar.CastDurationFix[abilityId] or durationValue
    end

    if Castbar.MultiCast[abilityId] then
        if result == 2200 then
            channeled = false
            duration = durationValue or 0
        elseif result == 2240 then
            CastBar.StopCastBar()
        end
    end

    if abilityId == 39033 or abilityId == 39477 then
        local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(32455)
        name, icon = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
        if abilityId == 39477 then
            name = zo_strformat("<<1>> <<2>>", Abilities.Skill_Remove, name)
        end
    end

    if duration > 0 and not g_casting then
        if (not forceChanneled and (((result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_BEGIN_CHANNEL) and not channeled) or (result == ACTION_RESULT_EFFECT_GAINED and (Castbar.CastDurationFix[abilityId] or channeled)) or (result == ACTION_RESULT_EFFECT_GAINED_DURATION and (Castbar.CastDurationFix[abilityId] or channeled)))) or (forceChanneled and result == ACTION_RESULT_BEGIN) then
            local currentTimeMs = timeMs()
            local endTime = currentTimeMs + duration
            local remain = endTime - currentTimeMs

            castbar.remain = endTime
            castbar.starts = currentTimeMs
            castbar.ends = endTime
            if castbar.currentIcon ~= icon then
                castbar.icon:SetTexture(icon)
                castbar.currentIcon = icon
            end
            castbar.id = abilityId

            if channeled then
                castbar.type = 2
                castbar.bar.bar:SetValue(1)
            else
                castbar.type = 1
                castbar.bar.bar:SetValue(0)
            end
            if ActionBar.SV.CastBarLabel then
                castbar.bar.name:SetText(name)
                castbar.bar.name:SetHidden(false)
            end
            if ActionBar.SV.CastBarTimer then
                castbar.bar.timer:SetText(string_format("%.1f", remain / 1000))
                castbar.bar.timer:SetHidden(false)
            end

            castbar:SetHidden(false)
            g_casting = true
            eventManager:RegisterForUpdate(moduleName, 20, CastBar.OnUpdateCastbar)
        end
    end

    if abilityId == 39507 then
        zo_callLater(function ()
                         Castbar.CastDurationFix[39507] = 19500
                     end, 5000)
    end
end

-- Runs on the `EVENT_GAME_CAMERA_UI_MODE_CHANGED` handler
--- @param eventCode integer
function CastBar.OnGameCameraUIModeChanged(eventCode)
    g_castbarWorldMapFix = true
    eventManager:RegisterForPostEffectsUpdate(moduleName .. "Fix", 500, function ()
        g_castbarWorldMapFix = false
        eventManager:UnregisterForPostEffectsUpdate(moduleName .. "Fix")
    end)
    if Castbar.BreakSiegeOnWindowOpen[castbar.id] then
        CastBar.StopCastBar()
    end
end

-- Runs on the `EVENT_END_SIEGE_CONTROL` handler
--- @param eventCode integer
function CastBar.OnSiegeEnd(eventCode)
    if castbar.id == 12256 then
        CastBar.StopCastBar()
    end
end

-- Runs on the `EVENT_ACTION_SLOT_ABILITY_USED` handler
--- @param eventCode integer
--- @param actionSlotIndex luaindex
function CastBar.OnAbilityUsed(eventCode, actionSlotIndex)
    if actionSlotIndex == 2 then
        CastBar.StopCastBar()
    end
end

-- Main ticker update for cast bar (called from ActionBar.OnUpdate)
function CastBar.OnUpdate(currentTimeMs)
    -- Break castbar when block is used for certain effects
    if not Castbar.IgnoreCastBreakingActions[castbar.id] then
        if IsBlockActive() then
            if not IsPlayerStunned() then
                CastBar.StopCastBar()
            end
        end
    end

    -- Break castbar when movement interrupt is detected
    savedPlayerX = playerX
    savedPlayerZ = playerZ
    playerX, playerZ = GetMapPlayerPosition("player")
    if savedPlayerX == playerX and savedPlayerZ == playerZ then
        return
    else
        if g_castbarWorldMapFix == false then
            if Castbar.BreakCastOnMove[castbar.id] then
                CastBar.StopCastBar()
            end
        end
        if g_castbarWorldMapFix == true then
            g_castbarWorldMapFix = false
        end
    end
end

-- Setup font for cast bar UI elements
function CastBar.SetupFont(castbarFont)
    g_castbarFont = castbarFont
end

-- Initialize cast bar module
function CastBar.Initialize()
    CastBar.CreateCastBar()
    CastBar.UpdateCastBar()
    CastBar.SetCastBarPosition()
end
