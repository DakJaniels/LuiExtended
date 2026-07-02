-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local ChatOutput = LUIE.ChatOutput
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local ipairs = ipairs
local pairs = pairs
local type = type
local table = table
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local zo_strformat = zo_strformat

local pendingCrutchAlertsVersionWarning = false

--- Chat is not ready during addon load; queue warning until primaryContainer exists.
function UnitFrames.TryShowPendingCrutchAlertsVersionWarning()
    if not pendingCrutchAlertsVersionWarning then
        return
    end
    if not ZO_GetChatSystem().primaryContainer then
        return
    end
    pendingCrutchAlertsVersionWarning = false
    ChatOutput:Print(GetString(LUIE_STRING_UF_CRUTCH_ALERTS_MIN_VERSION), true)
end

local BOSS_THRESHOLD_MARKER_WIDTH = 2
local BOSS_THRESHOLD_MARKER_COLOR = { 1, 0.85, 0.1, 0.8 }
local BOSS_THRESHOLD_LABEL_COLOR = { 1, 0.95, 0.7, 1 }
-- Fallback stage colors when CrutchAlerts is not loaded (matches CrutchAlerts/main/CrutchAlerts.lua defaultOptions.bossHealthBar)
local THRESHOLD_STAGE_COLORS_FALLBACK =
{
    active = { 0.53, 0.53, 0.53, 0.9 },
    imminent = { 1, 1, 0, 0.67 },
    passed = { 0.53, 0.53, 0.53, 0.4 },
}
local BOSS_THRESHOLD_TOP_LABEL_DIMENSIONS = { 48, 16 }
local BOSS_THRESHOLD_BOTTOM_LABEL_DIMENSIONS = { 120, 16 }
local DEFAULT_BOSS_THRESHOLD_PERCENTS = { 25, 50, 75 }
-- Slash/debug boss preview: dense same-name mechanics (Saint Olms–style) for fade + next-upcoming testing.
local BOSS_THRESHOLD_SLASH_DEBUG_PERCENTS = { 90, 75, 50, 25 }
local BOSS_THRESHOLD_SLASH_DEBUG_MECHANIC = "Big Jump"
local BOSS_THRESHOLD_SLASH_DEBUG_BOSS_NAME = "Saint Olms, Just the (debug)"
local BOSS_THRESHOLD_MECHANIC_FADE_MS = 300
local BOSS_THRESHOLD_MECHANIC_STAGE_FADE_MS = 200
local BOSS_THRESHOLD_MECHANIC_STAGE_FADE_FROM_ALPHA = 0.4

-- -----------------------------------------------------------------------------
-- CrutchAlerts BossHealthBar integration (optional dependency)
-- -----------------------------------------------------------------------------
-- IMPORTANT: Do not reference the global `CrutchAlerts` in hot paths (e.g. power-update repaints).
-- Some dev/debug environments treat reads of missing globals as errors. We therefore cache any
-- needed Crutch handles/options once during `UnitFrames.Initialize()` when the addon is confirmed enabled.
local cachedCrutchBossHealthBar = nil
local cachedCrutchBossHealthBarOptions = nil             -- CrutchAlerts.savedOptions.bossHealthBar (table) or nil
local cachedCrutchGetBossThresholds = nil                -- function or nil
local cachedCrutchRegisterThresholdsChangeListener = nil -- function or nil

-- Extra bottom padding applied to the bosses TLW when threshold mechanics are shown,
-- so the mechanic labels have reserved space and don't overlap nearby UI.
UnitFrames.bossThresholdMechanicPadding = 0

--- Builds a renderable column list from CrutchAlerts BossHealthBar data.
--- Each column is { percent, mechanic, scope = "common"|"multi", bossIndex? }.
--- Returns nil when no usable thresholds (so the default-percents fallback runs).
local function FetchCrutchBossThresholds()
    if not LUIE.OtherAddonCompatability.isCrutchAlertsEnabled then
        return nil
    end

    if not cachedCrutchGetBossThresholds then
        return nil
    end

    -- GetBossThresholds requires a live boss unit (see ApplyBossThresholdMarkersSlashDebugPreview).
    if cachedCrutchBossHealthBar and cachedCrutchBossHealthBar.GetFirstValidBossTag then
        local bossTag = cachedCrutchBossHealthBar.GetFirstValidBossTag()
        if bossTag == "" or bossTag == nil then
            return nil
        end
    else
        local hasBossUnit = false
        for bossRankIndex = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
            if DoesUnitExist("boss" .. bossRankIndex) then
                hasBossUnit = true
                break
            end
        end
        if not hasBossUnit then
            return nil
        end
    end

    local crutchThresholdData = cachedCrutchGetBossThresholds()
    if type(crutchThresholdData) ~= "table" then
        return nil
    end

    local columns = {}

    -- Per-boss multi thresholds: if any bossN sub-table exists, only those are emitted
    -- (mirrors CrutchAlerts BossHealthBar.lua:486-498).
    local hasPerBossThresholdTables = false
    for bossRankIndex = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local perBossThresholdTable = crutchThresholdData["boss" .. bossRankIndex]
        if type(perBossThresholdTable) == "table" then
            hasPerBossThresholdTables = true
            for percent, mechanic in pairs(perBossThresholdTable) do
                if type(percent) == "number" then
                    table_insert(columns,
                                 {
                                     percent = percent,
                                     mechanic = type(mechanic) == "string" and mechanic or "",
                                     scope = "multi",
                                     bossIndex = bossRankIndex,
                                 })
                end
            end
        end
    end

    if not hasPerBossThresholdTables then
        for percent, mechanic in pairs(crutchThresholdData) do
            if type(percent) == "number" then
                table_insert(columns,
                             {
                                 percent = percent,
                                 mechanic = type(mechanic) == "string" and mechanic or "",
                                 scope = "common",
                             })
            end
        end
    end

    if #columns == 0 then
        return nil
    end

    table_sort(columns, function (leftColumn, rightColumn) return leftColumn.percent > rightColumn.percent end)
    return { columns = columns }
end

--- Hides every per-bar (multi-mode) line marker on the given health frame.
local function HideBossThresholdMarkers(healthFrame)
    if not healthFrame or not healthFrame.thresholdMarkers then
        return
    end

    for _, thresholdMarker in ipairs(healthFrame.thresholdMarkers) do
        if thresholdMarker.line then
            thresholdMarker.line:SetHidden(true)
        end
    end
end

local function HideControlPool(controlPool)
    if not controlPool then return end
    for _, pooledControl in ipairs(controlPool) do
        pooledControl:SetHidden(true)
    end
end

local function GetBottomThresholdLabelFadeAnim(label)
    if not label.thresholdFadeAnim then
        label.thresholdFadeAnim = ZO_AlphaAnimation:New(label)
        label.thresholdFadeAnim:SetMinMaxAlpha(0, 1)
    end
    return label.thresholdFadeAnim
end

local function StopBottomThresholdLabelFade(label, preventCallback)
    if label.thresholdFadeAnim then
        local stopOption = preventCallback and ZO_ALPHA_ANIMATION_OPTION_PREVENT_CALLBACK or nil
        label.thresholdFadeAnim:Stop(stopOption)
    end
end

local function HideBottomThresholdLabel(label, animateOut)
    if not label then
        return
    end
    StopBottomThresholdLabelFade(label, true)
    if animateOut and not label:IsHidden() then
        local fadeAnimation = GetBottomThresholdLabelFadeAnim(label)
        fadeAnimation:FadeOut(0, BOSS_THRESHOLD_MECHANIC_FADE_MS / 1000, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, function (control)
            control:SetHidden(true)
            control:SetAlpha(1)
        end)
    else
        label:SetHidden(true)
        label:SetAlpha(1)
    end
end

local function ResetBossThresholdMechanicAnimationState(thresholdStack)
    UnitFrames.bossThresholdMechanicBottomAnimByIdx = nil
    if not thresholdStack or not thresholdStack.bottomLabels then
        return
    end
    for _, label in ipairs(thresholdStack.bottomLabels) do
        StopBottomThresholdLabelFade(label, true)
        label:SetAlpha(1)
        label:SetHidden(true)
    end
end

--- Hides the stack-level container plus every per-bar marker.
local function HideAllBossThresholdMarkers()
    if UnitFrames.CustomFrames then
        for bossRankIndex = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
            local bossFrame = UnitFrames.CustomFrames["boss" .. bossRankIndex]
            if bossFrame and bossFrame[COMBAT_MECHANIC_FLAGS_HEALTH] then
                HideBossThresholdMarkers(bossFrame[COMBAT_MECHANIC_FLAGS_HEALTH])
            end
        end
    end

    local thresholdStack = UnitFrames.bossThresholdStack
    if thresholdStack then
        HideControlPool(thresholdStack.topLabels)
        ResetBossThresholdMechanicAnimationState(thresholdStack)
        HideControlPool(thresholdStack.commonLines)
        if thresholdStack.control then
            thresholdStack.control:SetHidden(true)
        end
    else
        UnitFrames.bossThresholdMechanicBottomAnimByIdx = nil
    end
end

--- Lazily creates the stack-level threshold container parented to the boss tlw.
--- It owns three control pools: top percent labels, bottom rotated mechanic-name labels,
--- and common-mode vertical lines that span the full visible boss stack.
local function GetBossThresholdStack(bossTopLevelWindow)
    local thresholdStack = UnitFrames.bossThresholdStack
    if thresholdStack and thresholdStack.control then
        return thresholdStack
    end

    local container = bossTopLevelWindow:CreateControl("$(parent)BossThresholdStack", CT_CONTROL)
    container:SetMouseEnabled(false)
    container:SetDrawTier(DT_HIGH)
    container:SetDrawLayer(DL_OVERLAY)

    thresholdStack =
    {
        control = container,
        topLabels = {},
        bottomLabels = {},
        commonLines = {},
    }
    UnitFrames.bossThresholdStack = thresholdStack
    return thresholdStack
end

--- Returns (firstFrame, lastFrame) of the visible boss frames so the stack control
--- can re-anchor itself to span exactly the visible bars (matches Crutch's behavior in
--- BossHealthBar.lua:683-755 where the container width follows the highest visible tag).
local function GetVisibleBossSpan()
    if not UnitFrames.CustomFrames then return nil, nil end
    local firstVisibleBossFrame, lastVisibleBossFrame
    for bossRankIndex = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local bossFrame = UnitFrames.CustomFrames["boss" .. bossRankIndex]
        if bossFrame and bossFrame.control and not bossFrame.control:IsHidden() then
            firstVisibleBossFrame = firstVisibleBossFrame or bossFrame
            lastVisibleBossFrame = bossFrame
        end
    end
    return firstVisibleBossFrame, lastVisibleBossFrame
end

local function GetThresholdStageColorsFromCrutch()
    local bossHealthBarOptions = cachedCrutchBossHealthBarOptions
    if bossHealthBarOptions and bossHealthBarOptions.activeColor and bossHealthBarOptions.imminentColor and bossHealthBarOptions.passedColor then
        return bossHealthBarOptions.activeColor, bossHealthBarOptions.imminentColor, bossHealthBarOptions.passedColor
    end
    return THRESHOLD_STAGE_COLORS_FALLBACK.active, THRESHOLD_STAGE_COLORS_FALLBACK.imminent, THRESHOLD_STAGE_COLORS_FALLBACK.passed
end

local function RoundBossThresholdHealthPercent(percentRaw)
    local bossHealthBarOptions = cachedCrutchBossHealthBarOptions
    if bossHealthBarOptions and bossHealthBarOptions.useFloorRounding == false then
        return zo_round(percentRaw)
    end
    return zo_floor(percentRaw)
end

local function GetRoundedBossHealthPercent(bossIndex)
    local unitTag = "boss" .. bossIndex
    local savedHealth = UnitFrames.savedHealth and UnitFrames.savedHealth[unitTag]
    local powerValue, powerMax
    if savedHealth and savedHealth[2] and savedHealth[2] > 0 then
        powerValue, powerMax = savedHealth[1], savedHealth[2]
    elseif DoesUnitExist(unitTag) then
        powerValue, powerMax = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
    else
        return 0
    end
    if not powerMax or powerMax <= 0 then
        return 0
    end
    return RoundBossThresholdHealthPercent(100 * powerValue / powerMax)
end

local function BossHasThresholdHealthData(bossIndex)
    local unitTag = "boss" .. bossIndex
    if DoesUnitExist(unitTag) then
        return true
    end
    local savedHealth = UnitFrames.savedHealth and UnitFrames.savedHealth[unitTag]
    return savedHealth ~= nil and savedHealth[2] ~= nil and savedHealth[2] > 0
end

local function GetHighestVisibleBossRoundedHealthPercent()
    local highestRoundedPercent = 0
    for bossRankIndex = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local bossFrame = UnitFrames.CustomFrames["boss" .. bossRankIndex]
        if bossFrame and bossFrame.control and not bossFrame.control:IsHidden() and BossHasThresholdHealthData(bossRankIndex) then
            local roundedHealthPercent = GetRoundedBossHealthPercent(bossRankIndex)
            if roundedHealthPercent > highestRoundedPercent then
                highestRoundedPercent = roundedHealthPercent
            end
        end
    end
    return highestRoundedPercent
end

local function BossThresholdStageKey(thresholdColumn)
    return string_format("%s:%s:%d", thresholdColumn.scope, tostring(thresholdColumn.bossIndex or 0), thresholdColumn.percent)
end

--- Advances stage state for one threshold column (mirrors Crutch BossHealthBar.lua:330-354).
local function AdvanceBossThresholdStage(thresholdColumn, healthToCheck)
    if not UnitFrames.bossThresholdStageState then
        UnitFrames.bossThresholdStageState = {}
    end
    local stageKey = BossThresholdStageKey(thresholdColumn)
    local state = UnitFrames.bossThresholdStageState[stageKey] or "ACTIVE"
    local thresholdPercent = thresholdColumn.percent
    if state ~= "PASSED" and healthToCheck < thresholdPercent - 1 then
        state = "PASSED"
    elseif state ~= "IMMINENT" and healthToCheck >= thresholdPercent - 1 and healthToCheck <= thresholdPercent + 5 then
        state = "IMMINENT"
    end
    UnitFrames.bossThresholdStageState[stageKey] = state
    return state
end

--- @param columns table
--- @param columnStages table columnIndex -> ACTIVE|IMMINENT|PASSED
--- @return table columnIndex -> true for columns that should show the bottom mechanic label
local function ComputeMechanicHighlightIndices(columns, columnStages)
    local highlights = {}
    if not columns or #columns == 0 then
        return highlights
    end

    local usesPerBossThresholdScope = columns[1].scope == "multi"
    if usesPerBossThresholdScope then
        local bestPercentByBoss = {}
        for columnIndex, thresholdColumn in ipairs(columns) do
            if thresholdColumn.mechanic and thresholdColumn.mechanic ~= "" and columnStages[columnIndex] ~= "PASSED" then
                local bossIndex = thresholdColumn.bossIndex or 0
                local bestEntry = bestPercentByBoss[bossIndex]
                if not bestEntry or thresholdColumn.percent > bestEntry.percent then
                    bestPercentByBoss[bossIndex] = { columnIndex = columnIndex, percent = thresholdColumn.percent }
                end
            end
        end
        for _, bestEntry in pairs(bestPercentByBoss) do
            highlights[bestEntry.columnIndex] = true
        end
    else
        local bestColumnIndex
        local bestThresholdPercent = -1
        for columnIndex, thresholdColumn in ipairs(columns) do
            if thresholdColumn.mechanic and thresholdColumn.mechanic ~= "" and columnStages[columnIndex] ~= "PASSED" then
                if thresholdColumn.percent > bestThresholdPercent then
                    bestThresholdPercent = thresholdColumn.percent
                    bestColumnIndex = columnIndex
                end
            end
        end
        if bestColumnIndex then
            highlights[bestColumnIndex] = true
        end
    end
    return highlights
end

local function PlayBottomMechanicLabelFadeIn(bottomLabel, durationMs, fromAlpha)
    StopBottomThresholdLabelFade(bottomLabel, true)
    local fadeAnimation = GetBottomThresholdLabelFadeAnim(bottomLabel)
    if fromAlpha then
        fadeAnimation:SetMinMaxAlpha(fromAlpha, 1)
        bottomLabel:SetAlpha(fromAlpha)
        fadeAnimation:FadeIn(0, durationMs / 1000, ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA, function (control)
                                 control:SetAlpha(1)
                                 fadeAnimation:SetMinMaxAlpha(0, 1)
                             end, ZO_ALPHA_ANIMATION_OPTION_FORCE_SHOWN)
    else
        fadeAnimation:SetMinMaxAlpha(0, 1)
        fadeAnimation:FadeIn(0, durationMs / 1000, ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA, nil, ZO_ALPHA_ANIMATION_OPTION_FORCE_SHOWN)
    end
end

local function ApplyThresholdStageToBackdrop(backdrop, state)
    local activeStageColor, imminentStageColor, passedStageColor = GetThresholdStageColorsFromCrutch()
    local selectedStageColor = activeStageColor
    if state == "PASSED" then
        selectedStageColor = passedStageColor
    elseif state == "IMMINENT" then
        selectedStageColor = imminentStageColor
    end
    backdrop:SetCenterColor(selectedStageColor[1], selectedStageColor[2], selectedStageColor[3], selectedStageColor[4])
    backdrop:SetEdgeColor(selectedStageColor[1], selectedStageColor[2], selectedStageColor[3], selectedStageColor[4])
end

local function ApplyThresholdStageToLabel(label, state)
    local activeStageColor, imminentStageColor, passedStageColor = GetThresholdStageColorsFromCrutch()
    local selectedStageColor = activeStageColor
    if state == "PASSED" then
        selectedStageColor = passedStageColor
    elseif state == "IMMINENT" then
        selectedStageColor = imminentStageColor
    end
    label:SetColor(selectedStageColor[1], selectedStageColor[2], selectedStageColor[3], selectedStageColor[4])
end

--- @param parent Control
--- @param nameSuffix string|number Unique-per-parent suffix; used to build a stable
--- control name so reused indices don't allocate new names each call (previously
--- a global monotonic serial that climbed forever).
--- @return BackdropControl line
local function CreateThresholdLine(parent, nameSuffix)
    local line = parent:CreateControl("$(parent)ThresholdLine" .. tostring(nameSuffix), CT_BACKDROP)
    line:SetCenterColor(BOSS_THRESHOLD_MARKER_COLOR[1], BOSS_THRESHOLD_MARKER_COLOR[2], BOSS_THRESHOLD_MARKER_COLOR[3], BOSS_THRESHOLD_MARKER_COLOR[4])
    line:SetEdgeColor(BOSS_THRESHOLD_MARKER_COLOR[1], BOSS_THRESHOLD_MARKER_COLOR[2], BOSS_THRESHOLD_MARKER_COLOR[3], BOSS_THRESHOLD_MARKER_COLOR[4])
    line:SetEdgeTexture("", 1, 1, 0, 0)
    line:SetDrawTier(DT_HIGH)
    line:SetDrawLayer(DL_OVERLAY)
    line:SetDrawLevel(6)
    line:SetMouseEnabled(false)
    line:SetHidden(true)
    return line
end

--- @param parent Control
--- @param dimensions table {width, height}
--- @param isBottom boolean
--- @param nameSuffix string|number Stable per-parent suffix; see CreateThresholdLine.
--- @return LabelControl label
local function CreateThresholdLabel(parent, dimensions, isBottom, nameSuffix)
    local labelSuffix = isBottom and "ThresholdLabelBottom" or "ThresholdLabelTop"
    local label = parent:CreateControl("$(parent)" .. labelSuffix .. tostring(nameSuffix), CT_LABEL)
    if ZO_IsConsoleOrGameCoreUI() then
        label:SetFont("$(GAMEPAD_MEDIUM_FONT)|16|soft-shadow-thick")
    else
        label:SetFont("$(BOLD_FONT)|16|soft-shadow-thin")
    end
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(isBottom and TEXT_ALIGN_TOP or TEXT_ALIGN_BOTTOM)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetDimensions(dimensions[1], dimensions[2])
    label:SetText("")
    label:SetHidden(true)
    label:SetDrawTier(DT_HIGH)
    label:SetDrawLayer(DL_TEXT)
    label:SetDrawLevel(7)
    label:SetMouseEnabled(false)
    label:SetColor(BOSS_THRESHOLD_LABEL_COLOR[1], BOSS_THRESHOLD_LABEL_COLOR[2], BOSS_THRESHOLD_LABEL_COLOR[3], BOSS_THRESHOLD_LABEL_COLOR[4])
    return label
end

--- Draws (or reuses) a per-bar line at the given x offset inside one boss's thresholdContainer.
--- Used in multi mode so each boss's threshold line is attributed to that bar only.
local function ApplyMultiLineToFrame(healthFrame, markerLineX, markerHeight, stage)
    if not healthFrame or not healthFrame.thresholdContainer then
        return
    end

    local thresholdContainer = healthFrame.thresholdContainer
    local thresholdMarkers = healthFrame.thresholdMarkers
    if not thresholdMarkers then
        thresholdMarkers = {}
        healthFrame.thresholdMarkers = thresholdMarkers
    end

    local thresholdMarkerEntry
    for _, markerEntry in ipairs(thresholdMarkers) do
        if markerEntry.line and markerEntry.line:IsHidden() then
            thresholdMarkerEntry = markerEntry
            break
        end
    end
    if not thresholdMarkerEntry then
        -- Stable name keyed by parent-local slot (#thresholdMarkers + 1) — no monotonic
        -- global serial, and the name string is reused if we never expand past
        -- this slot again.
        thresholdMarkerEntry = { line = CreateThresholdLine(thresholdContainer, #thresholdMarkers + 1) }
        table_insert(thresholdMarkers, thresholdMarkerEntry)
    end

    local thresholdLine = thresholdMarkerEntry.line
    thresholdLine:ClearAnchors()
    thresholdLine:SetDimensions(BOSS_THRESHOLD_MARKER_WIDTH, markerHeight)
    thresholdLine:SetAnchor(TOPLEFT, thresholdContainer, TOPLEFT, markerLineX, 0)
    thresholdLine:SetAnchor(BOTTOMLEFT, thresholdContainer, BOTTOMLEFT, markerLineX, 0)
    ApplyThresholdStageToBackdrop(thresholdLine, stage)
    thresholdLine:SetHidden(false)
end

--- Renders the full threshold pipeline:
--- - re-anchors the stack container across boss1..lastVisible
--- - top percent labels above the stack, bottom rotated mechanic-name labels below
--- - common-mode lines span the full stack height
--- - multi-mode lines are drawn on the relevant boss bar only
local function ApplyBossThresholdMarkers(thresholdInfo)
    if not UnitFrames.CustomFrames or not UnitFrames.CustomFrames["boss1"] then
        return
    end

    if not thresholdInfo or not thresholdInfo.columns or #thresholdInfo.columns == 0 then
        HideAllBossThresholdMarkers()
        return
    end

    -- Hide per-bar markers up front; we re-show only the multi-mode ones we use this pass.
    for bossRankIndex = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local bossFrame = UnitFrames.CustomFrames["boss" .. bossRankIndex]
        if bossFrame and bossFrame[COMBAT_MECHANIC_FLAGS_HEALTH] then
            HideBossThresholdMarkers(bossFrame[COMBAT_MECHANIC_FLAGS_HEALTH])
        end
    end

    local firstVisibleBossFrame, lastVisibleBossFrame = GetVisibleBossSpan()
    if not firstVisibleBossFrame or not lastVisibleBossFrame or not firstVisibleBossFrame.tlw then
        HideAllBossThresholdMarkers()
        return
    end

    local thresholdStack = GetBossThresholdStack(firstVisibleBossFrame.tlw)
    local container = thresholdStack.control
    container:SetHidden(false)
    container:ClearAnchors()
    container:SetAnchor(TOPLEFT, firstVisibleBossFrame.control, TOPLEFT, 0, 0)
    container:SetAnchor(BOTTOMRIGHT, lastVisibleBossFrame.control, BOTTOMRIGHT, 0, 0)

    local stackHeight = container:GetHeight()
    if stackHeight <= 0 and UnitFrames.SV then
        local visibleBossCount = 0
        for bossRankIndex = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
            local bossFrame = UnitFrames.CustomFrames["boss" .. bossRankIndex]
            if bossFrame and bossFrame.control and not bossFrame.control:IsHidden() then
                visibleBossCount = visibleBossCount + 1
            end
        end
        local barSpacing = UnitFrames.SV.BossBarSpacing or 0
        stackHeight = (UnitFrames.SV.BossBarHeight or 0) * visibleBossCount + barSpacing * zo_max(0, visibleBossCount - 1)
    end

    if stackHeight <= 0 then
        HideAllBossThresholdMarkers()
        return
    end

    local firstBossHealthFrame = firstVisibleBossFrame[COMBAT_MECHANIC_FLAGS_HEALTH]
    local firstBossThresholdContainer = firstBossHealthFrame and firstBossHealthFrame.thresholdContainer
    local barWidth = firstBossThresholdContainer and firstBossThresholdContainer:GetWidth() or 0
    if barWidth <= 0 and UnitFrames.SV then
        barWidth = UnitFrames.SV.BossBarWidth or 0
    end
    if barWidth <= 0 then
        HideAllBossThresholdMarkers()
        return
    end

    local originX = 0
    if firstBossThresholdContainer and container then
        originX = firstBossThresholdContainer:GetLeft() - container:GetLeft()
    end

    local columnSignature = ""
    for _, thresholdColumn in ipairs(thresholdInfo.columns) do
        columnSignature = columnSignature .. thresholdColumn.scope .. ":" .. tostring(thresholdColumn.bossIndex or 0) .. ":" .. thresholdColumn.percent .. ";"
    end
    if UnitFrames.lastBossThresholdColumnSig ~= columnSignature then
        UnitFrames.bossThresholdStageState = {}
        UnitFrames.lastBossThresholdColumnSig = columnSignature
        ResetBossThresholdMechanicAnimationState(thresholdStack)
    end

    local labelOffsetX = (UnitFrames.SV and UnitFrames.SV.BossThresholdLabelOffsetX) or 0
    local rawLabelOffsetY = (UnitFrames.SV and UnitFrames.SV.BossThresholdLabelOffsetY) or -2
    local labelOffsetY = zo_abs(rawLabelOffsetY)

    local maxLineStart = originX + zo_max(0, barWidth - BOSS_THRESHOLD_MARKER_WIDTH)
    local bottomLabelDimensions = BOSS_THRESHOLD_BOTTOM_LABEL_DIMENSIONS

    local highestRoundedHealthPercent = GetHighestVisibleBossRoundedHealthPercent()

    local columnStages = {}
    for columnIndex, thresholdColumn in ipairs(thresholdInfo.columns) do
        local healthToCheck = highestRoundedHealthPercent
        if thresholdColumn.scope == "multi" and thresholdColumn.bossIndex then
            healthToCheck = GetRoundedBossHealthPercent(thresholdColumn.bossIndex)
        end
        columnStages[columnIndex] = AdvanceBossThresholdStage(thresholdColumn, healthToCheck)
    end

    local mechanicHighlights = ComputeMechanicHighlightIndices(thresholdInfo.columns, columnStages)

    if not UnitFrames.bossThresholdMechanicBottomAnimByIdx then
        UnitFrames.bossThresholdMechanicBottomAnimByIdx = {}
    end
    local mechanicAnimationByColumnIndex = UnitFrames.bossThresholdMechanicBottomAnimByIdx

    for columnIndex, thresholdColumn in ipairs(thresholdInfo.columns) do
        local topLabel = thresholdStack.topLabels[columnIndex]
        if not topLabel then
            topLabel = CreateThresholdLabel(container, BOSS_THRESHOLD_TOP_LABEL_DIMENSIONS, false, columnIndex)
            thresholdStack.topLabels[columnIndex] = topLabel
        end

        local bottomLabel = thresholdStack.bottomLabels[columnIndex]
        if not bottomLabel then
            bottomLabel = CreateThresholdLabel(container, bottomLabelDimensions, true, columnIndex)
            thresholdStack.bottomLabels[columnIndex] = bottomLabel
        end

        local commonLine = thresholdStack.commonLines[columnIndex]
        if not commonLine then
            commonLine = CreateThresholdLine(container, columnIndex)
            thresholdStack.commonLines[columnIndex] = commonLine
        end

        local stage = columnStages[columnIndex]

        local normalizedPercent = zo_clamp(thresholdColumn.percent / 100, 0, 1)
        local lineX = zo_clamp(originX + normalizedPercent * barWidth - BOSS_THRESHOLD_MARKER_WIDTH / 2, originX, maxLineStart)
        local markerCenterX = lineX + BOSS_THRESHOLD_MARKER_WIDTH / 2 + labelOffsetX

        topLabel:ClearAnchors()
        topLabel:SetDimensions(BOSS_THRESHOLD_TOP_LABEL_DIMENSIONS[1], BOSS_THRESHOLD_TOP_LABEL_DIMENSIONS[2])
        topLabel:SetAnchor(BOTTOM, container, TOPLEFT, markerCenterX, -labelOffsetY)
        topLabel:SetText(zo_strformat("<<1>>%", thresholdColumn.percent))
        ApplyThresholdStageToLabel(topLabel, stage)
        topLabel:SetHidden(false)

        bottomLabel:ClearAnchors()
        bottomLabel:SetDimensions(bottomLabelDimensions[1], bottomLabelDimensions[2])

        local stageKey = BossThresholdStageKey(thresholdColumn)
        local previousMechanicAnimation = mechanicAnimationByColumnIndex[columnIndex]
        local showMechanic = mechanicHighlights[columnIndex] and thresholdColumn.mechanic and thresholdColumn.mechanic ~= ""
        local bottomFadeAnimation = GetBottomThresholdLabelFadeAnim(bottomLabel)

        if showMechanic then
            bottomLabel:SetAnchor(TOP, container, BOTTOMLEFT, markerCenterX, labelOffsetY)
            bottomLabel:SetText(thresholdColumn.mechanic)
            ApplyThresholdStageToLabel(bottomLabel, stage)
            bottomLabel:SetHidden(false)

            local wasHighlighted = previousMechanicAnimation and previousMechanicAnimation.highlighted
            local stageChanged = wasHighlighted and previousMechanicAnimation.stageKey == stageKey and previousMechanicAnimation.stage ~= stage
            local newlyVisible = not wasHighlighted

            if newlyVisible then
                PlayBottomMechanicLabelFadeIn(bottomLabel, BOSS_THRESHOLD_MECHANIC_FADE_MS, nil)
            elseif stageChanged then
                PlayBottomMechanicLabelFadeIn(bottomLabel, BOSS_THRESHOLD_MECHANIC_STAGE_FADE_MS, BOSS_THRESHOLD_MECHANIC_STAGE_FADE_FROM_ALPHA)
            elseif not bottomFadeAnimation:IsPlaying() then
                bottomLabel:SetAlpha(1)
            end

            mechanicAnimationByColumnIndex[columnIndex] =
            {
                highlighted = true,
                stageKey = stageKey,
                stage = stage,
            }
        else
            if previousMechanicAnimation and previousMechanicAnimation.highlighted then
                if not bottomFadeAnimation:IsPlaying() then
                    HideBottomThresholdLabel(bottomLabel, true)
                end
            elseif not bottomFadeAnimation:IsPlaying() then
                HideBottomThresholdLabel(bottomLabel, false)
            end
            mechanicAnimationByColumnIndex[columnIndex] =
            {
                highlighted = false,
                stageKey = stageKey,
                stage = stage,
            }
        end

        if thresholdColumn.scope == "common" then
            commonLine:ClearAnchors()
            commonLine:SetDimensions(BOSS_THRESHOLD_MARKER_WIDTH, stackHeight)
            commonLine:SetAnchor(TOPLEFT, container, TOPLEFT, lineX, 0)
            commonLine:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, lineX, 0)
            ApplyThresholdStageToBackdrop(commonLine, stage)
            commonLine:SetHidden(false)
        else
            commonLine:SetHidden(true)

            local bossFrame = thresholdColumn.bossIndex and UnitFrames.CustomFrames["boss" .. thresholdColumn.bossIndex] or nil
            if bossFrame and bossFrame[COMBAT_MECHANIC_FLAGS_HEALTH] then
                local bossHealthFrame = bossFrame[COMBAT_MECHANIC_FLAGS_HEALTH]
                local bossBarHeight = bossHealthFrame.thresholdContainer and bossHealthFrame.thresholdContainer:GetHeight() or 0
                if bossBarHeight <= 0 and UnitFrames.SV then
                    bossBarHeight = UnitFrames.SV.BossBarHeight or 0
                end
                local bossThresholdContainer = bossHealthFrame.thresholdContainer
                local bossBarWidth = bossThresholdContainer and bossThresholdContainer:GetWidth() or 0
                if bossBarWidth <= 0 and UnitFrames.SV then
                    bossBarWidth = UnitFrames.SV.BossBarWidth or 0
                end
                local bossBarMaxLineStart = zo_max(0, bossBarWidth - BOSS_THRESHOLD_MARKER_WIDTH)
                local multiBossLineX = zo_clamp(normalizedPercent * bossBarWidth - BOSS_THRESHOLD_MARKER_WIDTH / 2, 0, bossBarMaxLineStart)
                if bossBarHeight > 0 then
                    ApplyMultiLineToFrame(bossHealthFrame, multiBossLineX, bossBarHeight, stage)
                end
            end
        end
    end

    -- Hide unused pool entries past the column count
    local lastUsedColumnIndex = #thresholdInfo.columns
    local poolMaxIndex = zo_max(#thresholdStack.topLabels, #thresholdStack.bottomLabels, #thresholdStack.commonLines)
    for columnIndex = lastUsedColumnIndex + 1, poolMaxIndex do
        if thresholdStack.topLabels[columnIndex] then thresholdStack.topLabels[columnIndex]:SetHidden(true) end
        if thresholdStack.bottomLabels[columnIndex] then
            HideBottomThresholdLabel(thresholdStack.bottomLabels[columnIndex], false)
            mechanicAnimationByColumnIndex[columnIndex] = nil
        end
        if thresholdStack.commonLines[columnIndex] then thresholdStack.commonLines[columnIndex]:SetHidden(true) end
    end
end

function UnitFrames.UpdateBossThresholds()
    if not UnitFrames.CustomFrames or not UnitFrames.CustomFrames["boss1"] then
        UnitFrames.activeBossThresholds = nil
        UnitFrames.lastBossThresholdColumnSig = nil
        UnitFrames.bossThresholdMechanicPadding = 0
        UnitFrames.bossThresholdMechanicBottomAnimByIdx = nil
        return
    end

    if not UnitFrames.SV.BossShowThresholdMarkers then
        UnitFrames.activeBossThresholds = nil
        UnitFrames.lastBossThresholdColumnSig = nil
        UnitFrames.bossThresholdMechanicPadding = 0
        UnitFrames.bossThresholdMechanicBottomAnimByIdx = nil
        ApplyBossThresholdMarkers(nil)
        UnitFrames.CustomFramesApplyLayoutBosses()
        return
    end

    local thresholdInfo = FetchCrutchBossThresholds()
    if not thresholdInfo then
        local columns = {}
        for _, defaultThresholdPercent in ipairs(DEFAULT_BOSS_THRESHOLD_PERCENTS) do
            table_insert(columns, { percent = defaultThresholdPercent, mechanic = "", scope = "common" })
        end
        table_sort(columns, function (leftColumn, rightColumn) return leftColumn.percent > rightColumn.percent end)
        thresholdInfo = { columns = columns }
    end

    UnitFrames.activeBossThresholds = thresholdInfo

    -- If any threshold has a non-empty mechanic label, reserve space below the boss stack.
    local hasMechanicLabel = false
    if thresholdInfo and thresholdInfo.columns then
        for _, thresholdColumn in ipairs(thresholdInfo.columns) do
            if thresholdColumn.mechanic and thresholdColumn.mechanic ~= "" then
                hasMechanicLabel = true
                break
            end
        end
    end
    if hasMechanicLabel then
        local rawLabelOffsetY = (UnitFrames.SV and UnitFrames.SV.BossThresholdLabelOffsetY) or -2
        local labelOffsetY = zo_abs(rawLabelOffsetY)
        UnitFrames.bossThresholdMechanicPadding = labelOffsetY + BOSS_THRESHOLD_BOTTOM_LABEL_DIMENSIONS[2] + 2
    else
        UnitFrames.bossThresholdMechanicPadding = 0
    end

    ApplyBossThresholdMarkers(thresholdInfo)
    UnitFrames.CustomFramesApplyLayoutBosses()
end

local function BuildBossThresholdSlashDebugColumns()
    local columns = {}
    for _, debugThresholdPercent in ipairs(BOSS_THRESHOLD_SLASH_DEBUG_PERCENTS) do
        table_insert(columns,
                     {
                         percent = debugThresholdPercent,
                         mechanic = BOSS_THRESHOLD_SLASH_DEBUG_MECHANIC,
                         scope = "common",
                     })
    end
    table_sort(columns, function (leftColumn, rightColumn) return leftColumn.percent > rightColumn.percent end)
    return { columns = columns }
end

--- Used by UnitFrames slash debug only. Paints threshold markers from built-in percentages;
--- does not call CrutchAlerts (GetBossThresholds requires live boss units).
function UnitFrames.ApplyBossThresholdMarkersSlashDebugPreview()
    if not UnitFrames.CustomFrames or not UnitFrames.CustomFrames["boss1"] then
        return false
    end

    if not UnitFrames.SV.BossShowThresholdMarkers then
        UnitFrames.activeBossThresholds = nil
        UnitFrames.lastBossThresholdColumnSig = nil
        UnitFrames.debugBossThresholdPreviewActive = false
        ApplyBossThresholdMarkers(nil)
        return false
    end

    local thresholdInfo = BuildBossThresholdSlashDebugColumns()
    UnitFrames.debugBossThresholdPreviewActive = true
    UnitFrames.lastBossThresholdColumnSig = nil
    UnitFrames.bossThresholdStageState = {}
    UnitFrames.bossThresholdMechanicBottomAnimByIdx = nil
    UnitFrames.activeBossThresholds = thresholdInfo

    local rawLabelOffsetY = (UnitFrames.SV and UnitFrames.SV.BossThresholdLabelOffsetY) or -2
    local labelOffsetY = zo_abs(rawLabelOffsetY)
    UnitFrames.bossThresholdMechanicPadding = labelOffsetY + BOSS_THRESHOLD_BOTTOM_LABEL_DIMENSIONS[2] + 2

    ApplyBossThresholdMarkers(thresholdInfo)
    UnitFrames.CustomFramesApplyLayoutBosses()
    return true
end

--- Sets simulated boss1 HP (0–100) for slash threshold preview and repaints markers.
--- Resets stage state so HP can be stepped up or down during debug.
function UnitFrames.SetBossThresholdDebugPreviewHealth(percentRounded)
    if not UnitFrames.debugBossThresholdPreviewActive or not UnitFrames.CustomFrames["boss1"] then
        return false
    end

    local percent = zo_clamp(zo_round(percentRounded or 0), 0, 100)
    local unitTag = "boss1"
    local powerMax = 1000000
    local powerValue = zo_floor(powerMax * percent / 100)

    UnitFrames.savedHealth[unitTag] = { powerValue, powerMax, powerMax, 0, 0 }
    UnitFrames.bossThresholdStageState = {}
    UnitFrames.bossThresholdMechanicBottomAnimByIdx = nil

    UnitFrames.UpdateCustomFramePower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, powerValue, powerMax, powerMax, false, nil)
    UnitFrames.RepaintBossThresholdMarkers()
    return true
end

function UnitFrames.ClearBossThresholdDebugPreview()
    if not UnitFrames.debugBossThresholdPreviewActive then
        return
    end
    UnitFrames.debugBossThresholdPreviewActive = false
    UnitFrames.activeBossThresholds = nil
    UnitFrames.lastBossThresholdColumnSig = nil
    UnitFrames.bossThresholdMechanicBottomAnimByIdx = nil
    UnitFrames.bossThresholdMechanicPadding = 0
    ApplyBossThresholdMarkers(nil)
end

--- Re-applies stage colors and marker positions from cached threshold columns (no Crutch API call).
--- Invoked on boss EVENT_POWER_UPDATE so ACTIVE / IMMINENT / PASSED tracks current HP.
function UnitFrames.RepaintBossThresholdMarkers()
    if UnitFrames.SV and UnitFrames.SV.BossShowThresholdMarkers and UnitFrames.activeBossThresholds then
        ApplyBossThresholdMarkers(UnitFrames.activeBossThresholds)
    end
end

--- Re-applies markers from `activeBossThresholds` after boss TLW layout (nil hides).
function UnitFrames.ApplyBossThresholdMarkersFromCache()
    ApplyBossThresholdMarkers(UnitFrames.activeBossThresholds)
end

--- Bosses despawned: drop cached columns and hide stack + per-bar markers.
function UnitFrames.ClearBossThresholdsOnBossDespawn()
    UnitFrames.activeBossThresholds = nil
    UnitFrames.lastBossThresholdColumnSig = nil
    UnitFrames.bossThresholdStageState = nil
    ApplyBossThresholdMarkers(nil)
end

--- Cache CrutchAlerts BossHealthBar handles/options once (optional dependency).
function UnitFrames.InitializeBossThresholdCrutchCache()
    if LUIE.OtherAddonCompatability and LUIE.OtherAddonCompatability.isCrutchAlertsEnabled then
        -- NOTE: CrutchAlerts is an optional dependency; when installed it loads before LUIE.
        -- This branch only runs when the addon manager confirms it is enabled.
        local crutchAlertsAddon = CrutchAlerts
        cachedCrutchBossHealthBar = crutchAlertsAddon and crutchAlertsAddon.BossHealthBar or nil
        cachedCrutchGetBossThresholds = cachedCrutchBossHealthBar and cachedCrutchBossHealthBar.GetBossThresholds or nil
        cachedCrutchRegisterThresholdsChangeListener = cachedCrutchBossHealthBar and cachedCrutchBossHealthBar.RegisterThresholdsChangeListener or nil
        cachedCrutchBossHealthBarOptions = crutchAlertsAddon and crutchAlertsAddon.savedOptions and crutchAlertsAddon.savedOptions.bossHealthBar or nil
    else
        cachedCrutchBossHealthBar = nil
        cachedCrutchGetBossThresholds = nil
        cachedCrutchRegisterThresholdsChangeListener = nil
        cachedCrutchBossHealthBarOptions = nil
    end
end

--- Subscribe to CrutchAlerts threshold-change notifications (custom boss frames block).
function UnitFrames.RegisterBossThresholdCrutchListener()
    if not LUIE.OtherAddonCompatability.isCrutchAlertsEnabled then
        return
    end
    -- See CrutchAlerts/bosshealthbar/BossHealthBarAPI.lua:117-135.
    if cachedCrutchRegisterThresholdsChangeListener then
        --- Listener fired by CrutchAlerts when a threshold override is added/removed
        --- (e.g. Z'Maja stage detection). Re-runs the fetch + render pipeline.
        cachedCrutchRegisterThresholdsChangeListener("LUIE_UnitFrames", function ()
            UnitFrames.UpdateBossThresholds()
        end)
    else
        pendingCrutchAlertsVersionWarning = true
        zo_callLater(UnitFrames.TryShowPendingCrutchAlertsVersionWarning, 0)
    end
end
