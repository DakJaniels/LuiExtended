--- @diagnostic disable: inject-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs : ZO_Object
local SpellCastBuffs = ZO_Object:Subclass()
--- @class (partial) LUIE.SpellCastBuffs
LUIE.SpellCastBuffs = SpellCastBuffs

SpellCastBuffs.moduleName = LUIE.name .. "SpellCastBuffs"

SpellCastBuffs.Enabled = false
SpellCastBuffs.BuffsMovingState = false
SpellCastBuffs.Defaults =
{
    ColorCosmetic = true,
    ColorUnbreakable = true,
    ColorCC = false,
    colors =
    {
        buff = { 0, 1, 0, 1 },
        debuff = { 1, 0, 0, 1 },
        prioritybuff = { 1, 1, 0, 1 },
        prioritydebuff = { 1, 1, 0, 1 },
        unbreakable = { 224 / 255, 224 / 255, 1, 1 },
        cosmetic = { 0, 100 / 255, 0, 1 },
        nocc = { 0, 0, 0, 1 },
        stun = { 1, 0, 0, 1 },
        knockback = { 1, 0, 0, 1 },
        levitate = { 1, 0, 0, 1 },
        disorient = { 0, 127 / 255, 1, 1 },
        fear = { 143 / 255, 9 / 255, 236 / 255, 1 },
        charm = { 64 / 255, 255 / 255, 32 / 255, 1 },
        silence = { 0, 1, 1, 1 },
        stagger = { 1, 127 / 255, 0, 1 },
        snare = { 1, 242 / 255, 32 / 255, 1 },
        root = { 1, 165 / 255, 0, 1 },
    },
    IconSize = 40,
    LabelPosition = 0,
    BuffFontFace = "LUIE Default Font",
    BuffFontStyle = FONT_STYLE_OUTLINE,
    BuffFontSize = 16,
    BuffShowLabel = true,
    AlignmentBuffsPlayer = "Centered",
    SortBuffsPlayer = "Left to Right",
    AlignmentDebuffsPlayer = "Centered",
    SortDebuffsPlayer = "Left to Right",
    AlignmentBuffsTarget = "Centered",
    SortBuffsTarget = "Left to Right",
    AlignmentDebuffsTarget = "Centered",
    SortDebuffsTarget = "Left to Right",
    AlignmentLongHorz = "Centered",
    SortLongHorz = "Left to Right",
    AlignmentLongVert = "Top",
    SortLongVert = "Top to Bottom",
    AlignmentPromBuffsHorz = "Centered",
    SortPromBuffsHorz = "Left to Right",
    AlignmentPromBuffsVert = "Bottom",
    SortPromBuffsVert = "Bottom to Top",
    AlignmentPromDebuffsHorz = "Centered",
    SortPromDebuffsHorz = "Left to Right",
    AlignmentPromDebuffsVert = "Bottom",
    SortPromDebuffsVert = "Bottom to Top",
    StackPlayerBuffs = "Down",
    StackPlayerDebuffs = "Up",
    StackTargetBuffs = "Down",
    StackTargetDebuffs = "Up",
    WidthPlayerBuffs = 1920,
    WidthPlayerDebuffs = 1920,
    WidthTargetBuffs = 1920,
    WidthTargetDebuffs = 1920,
    GlowIcons = false,
    RemainingText = true,
    RemainingTextColoured = false,
    RemainingTextMillis = true,
    RemainingCooldown = true,
    FadeOutIcons = false,
    lockPositionToUnitFrames = true,
    LongTermEffects_Player = true,
    LongTermEffects_Target = true,
    ShortTermEffects_Player = true,
    ShortTermEffects_Target = true,
    IgnoreMundusPlayer = false,
    IgnoreMundusTarget = false,
    IgnoreVampPlayer = false,
    IgnoreVampTarget = false,
    IgnoreLycanPlayer = false,
    IgnoreLycanTarget = false,
    IgnoreDiseasePlayer = false,
    IgnoreDiseaseTarget = false,
    IgnoreBitePlayer = false,
    IgnoreBiteTarget = false,
    IgnoreCyrodiilPlayer = false,
    IgnoreCyrodiilTarget = false,
    IgnoreBattleSpiritPlayer = false,
    IgnoreBattleSpiritTarget = false,
    IgnoreEsoPlusPlayer = true,
    IgnoreEsoPlusTarget = true,
    IgnoreSoulSummonsPlayer = false,
    IgnoreSoulSummonsTarget = false,
    IgnoreSetICDPlayer = false,
    IgnoreAbilityICDPlayer = false,
    IgnoreFoodPlayer = false,
    IgnoreFoodTarget = false,
    IgnoreExperiencePlayer = false,
    IgnoreExperienceTarget = false,
    IgnoreAllianceXPPlayer = false,
    IgnoreAllianceXPTarget = false,
    IgnoreDisguise = false,
    IgnoreCostume = true,
    IgnoreHat = true,
    IgnoreSkin = true,
    IgnorePolymorph = true,
    IgnoreAssistant = true,
    IgnorePet = true,
    PetDetail = true,
    IgnoreMountPlayer = false,
    IgnoreMountTarget = false,
    MountDetail = true,
    LongTermEffectsSeparate = true,
    LongTermEffectsSeparateAlignment = 2,
    ShowBlockPlayer = true,
    ShowBlockTarget = true,
    StealthStatePlayer = true,
    StealthStateTarget = true,
    DisguiseStatePlayer = true,
    DisguiseStateTarget = true,
    -- ShowSprint                          = true,
    -- ShowGallop                          = true,
    ShowResurrectionImmunity = true,
    ShowRecall = true,
    ShowWerewolf = true,
    HideOakenSoul = false,
    HidePlayerBuffs = false,
    HidePlayerDebuffs = false,
    HideTargetBuffs = false,
    HideTargetDebuffs = false,
    HideGroundEffects = false,
    ExtraBuffs = true,
    ExtraExpanded = false,
    ShowDebugCombat = false,
    ShowDebugEffect = false,
    ShowDebugFilter = false,
    ShowDebugAbilityId = false,
    HideReduce = true,
    GroundDamageAura = true,
    ProminentLabel = true,
    ProminentLabelFontFace = "LUIE Default Font",
    ProminentLabelFontStyle = FONT_STYLE_OUTLINE,
    ProminentLabelFontSize = 16,
    ProminentProgress = true,
    ProminentProgressTexture = "Plain",
    ProminentProgressBuffC1 = { 0, 1, 0, 1 },
    ProminentProgressBuffC2 = { 0, 0.4, 0, 1 },
    ProminentProgressDebuffC1 = { 1, 0, 0, 1 },
    ProminentProgressDebuffC2 = { 0.4, 0, 0, 1 },
    ProminentProgressBuffPriorityC1 = { 1, 1, 0, 1 },
    ProminentProgressBuffPriorityC2 = { 0.6, 0.6, 0, 1 },
    ProminentProgressDebuffPriorityC1 = { 1, 1, 0, 1 },
    ProminentProgressDebuffPriorityC2 = { 0.6, 0.6, 0, 1 },
    ProminentBuffContainerAlignment = 2,
    ProminentDebuffContainerAlignment = 2,
    ProminentBuffLabelDirection = "Left",
    ProminentDebuffLabelDirection = "Right",
    PriorityBuffTable = {},
    PriorityDebuffTable = {},
    PromBuffTable = {},
    PromDebuffTable = {},
    BlacklistTable = {},
    WhitelistTable = {},
    ListMode = "blacklist", -- or "whitelist"
    TooltipEnable = true,
    TooltipCustom = false,
    TooltipSticky = 0,
    TooltipAbilityId = false,
    TooltipBuffType = false,
    UseDefaultIcon = false,
    DefaultIconOptions = 1,
    ShowSharedEffects = true,
    ShowSharedMajorMinor = true,
}

if not SpellCastBuffs.SV then
    SpellCastBuffs.SV = {}
end

--- @alias SpellCastBuffsContext string
--- | `"player1"`
--- | `"player2"`
--- | `"reticleover1"`
--- | `"reticleover2"`
--- | `"ground"`
--- | `"saved"`
--- | `"promd_player"`
--- | `"promb_player"`
--- | `"promd_target"`
--- | `"promb_target"`
--- | `"target1"`
--- | `"target2"`
--- | `"targetb"`
--- | `"targetd"`

-- Saved Effects
SpellCastBuffs.EffectsList =
{
    player1 = {},
    player2 = {},
    reticleover1 = {},
    reticleover2 = {},
    ground = {},
    saved = {},
    promb_ground = {},
    promb_target = {},
    promb_player = {},
    promd_ground = {},
    promd_target = {},
    promd_player = {}
}


SpellCastBuffs.hidePlayerEffects = {}       -- Table of Effects to hide on Player - generated on load or updated from Menu
SpellCastBuffs.hideTargetEffects = {}       -- Table of Effects to hide on Target - generated on load or updated from Menu
SpellCastBuffs.debuffDisplayOverrideId = {} -- Table of Effects (by id) that should show on the target regardless of who applied them.

SpellCastBuffs.windowTitles =
{
    playerb = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS),
    playerd = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS),
    player1 = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS),
    player2 = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS),
    player_long = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS),
    targetb = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS),
    targetd = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS),
    target1 = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS),
    target2 = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS),
    prominentbuffs = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS),
    prominentdebuffs = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS),
}

local uiTlw = {} -- GUI

-- Routing for Auras
SpellCastBuffs.containerRouting = {}

SpellCastBuffs.alignmentDirection = {}    -- Holds alignment direction for all containers
SpellCastBuffs.sortDirection = {}         -- Holds sorting direction for all containers

SpellCastBuffs.playerActive = false       -- Player Active State
SpellCastBuffs.playerDead = false         -- Player Dead State
SpellCastBuffs.playerResurrectStage = nil -- Player resurrection sequence state

SpellCastBuffs.buffsFont = ""             -- Buff font
SpellCastBuffs.prominentFont = ""         -- Prominent buffs label font
SpellCastBuffs.padding = 0                -- Padding between icons
SpellCastBuffs.protectAbilityRemoval = {} -- AbilityId's set to a timestamp here to prevent removal of ground effects when refreshing ground auras from causing the aura to fade.
SpellCastBuffs.ignoreAbilityId = {}       -- Ignored abilityId's on EVENT_COMBAT_EVENT, some events fire twice and we need to ignore every other one.

-- Add buff containers into LUIE namespace
SpellCastBuffs.BuffContainers = uiTlw

-- Stealth Varaiables
-- Handles long term Disguise Item Icon (appears when wearing a disguise even if not in a disguised state)
SpellCastBuffs.currentDisguise = 0

-- Werewolf Varaiables
SpellCastBuffs.werewolfName = ""   -- Name for current Werewolf Transformation morph
SpellCastBuffs.werewolfIcon = ""   -- Icon for current Werewolf Transformation morph
SpellCastBuffs.werewolfId = 0      -- AbilityId for Werewolf Transformation morph
SpellCastBuffs.werewolfCounter = 0 -- Counter for Werewolf transformation events
SpellCastBuffs.werewolfQuest = 0   -- Counter for Werewolf transformation events (Quest)

-- Counter variable for ACTION_RESULT_EFFECT_GAINED / ACTION_RESULT_EFFECT_FADED tracking for some buffs that are broken
-- Handles buffs that rather than refreshing on reapplication create an individual instance and therefore have GAINED/FADED events every single time the effect ticks.
SpellCastBuffs.InternalStackCounter = {}

local GridOverlay = LUIE.GridOverlay

local LuiData = LuiData
local Data = LuiData.Data
local Abilities = Data.Abilities
local AlertTable = Data.AlertTable
local Tooltips = Data.Tooltips
local DebugAuras = Data.DebugAuras
local DebugResults = Data.DebugResults
local Effects = Data.Effects
local EffectOverride = Effects.EffectOverride

local zo_strformat = zo_strformat
local zo_iconFormat = zo_iconFormat


-- API function localizations
local GetAbilityIcon = GetAbilityIcon
local GetAbilityName = GetAbilityName
local GetAbilityDuration = GetAbilityDuration
local GetAbilityCastInfo = GetAbilityCastInfo
local string_format = string.format
local PrintToChat = LUIE.PrintToChat

local table_insert = table.insert
local table_sort = table.sort
-- local displayName = GetDisplayName()
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER

local moduleName = SpellCastBuffs.moduleName



--- @param abilityId integer
--- @return boolean
function SpellCastBuffs:ShouldUseDefaultIcon(abilityId)
    local effect = Effects.EffectOverride[abilityId]

    -- Check if effect exists and has either cc or ccMergedType (with HideReduce enabled)
    if not effect or (not effect.cc and not (self.SV.HideReduce and effect.ccMergedType)) then
        return false
    end

    -- Option 1: Always use default icon for all cc effects
    if self.SV.DefaultIconOptions == 1 then
        return true

        -- Options 2 and 3: Use default icon only for player ability cc effects
    elseif self.SV.DefaultIconOptions == 2 or self.SV.DefaultIconOptions == 3 then
        return effect.isPlayerAbility
    end

    return false
end

function SpellCastBuffs:GetDefaultIcon(ccType)
    -- Mapping of action results to icons.
    local iconMap =
    {
        [ACTION_RESULT_STUNNED] = LUIE_CC_ICON_STUN,
        [ACTION_RESULT_KNOCKBACK] = LUIE_CC_ICON_KNOCKBACK,
        [ACTION_RESULT_LEVITATED] = LUIE_CC_ICON_PULL,
        [ACTION_RESULT_FEARED] = LUIE_CC_ICON_FEAR,
        [ACTION_RESULT_CHARMED] = LUIE_CC_ICON_CHARM,
        [ACTION_RESULT_DISORIENTED] = LUIE_CC_ICON_DISORIENT,
        [ACTION_RESULT_SILENCED] = LUIE_CC_ICON_SILENCE,
        [ACTION_RESULT_ROOTED] = LUIE_CC_ICON_ROOT,
        [ACTION_RESULT_SNARED] = LUIE_CC_ICON_SNARE,
        -- Group immune-type results
        [ACTION_RESULT_IMMUNE] = LUIE_CC_ICON_IMMUNE,
        [ACTION_RESULT_DODGED] = LUIE_CC_ICON_IMMUNE,
        [ACTION_RESULT_BLOCKED] = LUIE_CC_ICON_IMMUNE,
        [ACTION_RESULT_BLOCKED_DAMAGE] = LUIE_CC_ICON_IMMUNE,
    }

    return iconMap[ccType]
end

-- Specifically for clearing a player buff, removes this buff from player1, promd_player, and promb_player containers
function SpellCastBuffs:ClearPlayerBuff(abilityId)
    local context = { "player1", "promd_player", "promb_player" }
    for _, v in pairs(context) do
        self.EffectsList[v][abilityId] = nil
    end
end

-- Initialize preview labels for all frames
local function InitializePreviewLabels(self)
    local frames =
    {
        { frame = self.BuffContainers.playerb,          name = "playerb"          },
        { frame = self.BuffContainers.playerd,          name = "playerd"          },
        { frame = self.BuffContainers.targetb,          name = "targetb"          },
        { frame = self.BuffContainers.targetd,          name = "targetd"          },
        { frame = self.BuffContainers.player_long,      name = "player_long"      },
        { frame = self.BuffContainers.prominentbuffs,   name = "prominentbuffs"   },
        { frame = self.BuffContainers.prominentdebuffs, name = "prominentdebuffs" }
    }

    for _, f in ipairs(frames) do
        if f.frame then
            -- Get preview controls from XML (created in XML for performance)
            if not f.frame.preview then
                f.frame.preview = f.frame:GetNamedChild("Preview")
            end

            if f.frame.preview then
                -- Get anchor controls from XML
                if not f.frame.preview.anchorTexture then
                    f.frame.preview.anchorTexture = f.frame.preview:GetNamedChild("AnchorTexture")
                    if f.frame.preview.anchorTexture then
                        f.frame.preview.anchorTexture:SetColor(1, 1, 0, 0.9)
                    end
                end

                if not f.frame.preview.anchorLabel then
                    f.frame.preview.anchorLabel = f.frame.preview:GetNamedChild("AnchorLabel")
                    if f.frame.preview.anchorLabel then
                        f.frame.preview.anchorLabel:SetColor(1, 1, 0, 1)
                        -- Update font to use better readable font
                        if IsConsoleUI() and LUIE.ConsoleMoverHelper then
                            local fontName = "LUIE Default Font"
                            if LUIE.Fonts and LUIE.Fonts[fontName] then
                                local fontSize = 14
                                local fontStyle = "soft-shadow-thick"
                                local fontString = ZO_CreateFontString(fontName, fontSize, fontStyle)
                                f.frame.preview.anchorLabel:SetFont(fontString)
                            else
                                if IsInGamepadPreferredMode() or IsConsoleUI() then
                                    f.frame.preview.anchorLabel:SetFont("$(GAMEPAD_MEDIUM_FONT)|14|soft-shadow-thick")
                                else
                                    f.frame.preview.anchorLabel:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thick")
                                end
                            end
                        end
                    end
                end

                if not f.frame.preview.anchorLabelBg then
                    f.frame.preview.anchorLabelBg = f.frame.preview:GetNamedChild("AnchorLabelBg")
                end
            end
        end
    end
end

-- Initialize method
function SpellCastBuffs:Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        self.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "SpellCastBuffs", SpellCastBuffs.Defaults)
    else
        self.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "SpellCastBuffs", SpellCastBuffs.Defaults)
    end

    -- Migrate old string-based font styles to numeric constants (run once)
    if not LUIE.IsMigrationDone("spellcastbuffs_fontstyles") then
        self.SV.BuffFontStyle = LUIE.MigrateFontStyle(self.SV.BuffFontStyle)
        self.SV.ProminentLabelFontStyle = LUIE.MigrateFontStyle(self.SV.ProminentLabelFontStyle)
        LUIE.MarkMigrationDone("spellcastbuffs_fontstyles")
    end

    -- Correct read values
    if self.SV.IconSize < 30 or self.SV.IconSize > 60 then
        self.SV.IconSize = SpellCastBuffs.Defaults.IconSize
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    self.Enabled = true

    -- Before we start creating controls, update icons font
    self:ApplyFont()

    -- Create the master control pool for buff icons
    -- ZO_ControlPool uses XML templates (see frontend/SpellCastBuffs.xml)
    self.controlPool = ZO_ControlPool:New("LUIE_SpellCastBuffIcon")

    -- Create controls
    -- Create temporary table to store references to scenes locally
    local fragments = {}

    -- We will not create TopLevelWindows when buff frames are locked to Custom Unit Frames
    if self.SV.lockPositionToUnitFrames and LUIE.UnitFrames.CustomFrames.player and LUIE.UnitFrames.CustomFrames.player.buffs and LUIE.UnitFrames.CustomFrames.player.debuffs then
        self.BuffContainers.player1 = LUIE.UnitFrames.CustomFrames.player.buffs
        self.BuffContainers.player2 = LUIE.UnitFrames.CustomFrames.player.debuffs
        self.containerRouting.player1 = "player1"
        self.containerRouting.player2 = "player2"
    else
        -- Use named TopLevelControl from XML for player buffs (OnMoveStop handler set in XML)
        self.BuffContainers.playerb = LUIE_SpellCastBuffs_PlayerBuffs

        -- Use named TopLevelControl from XML for player debuffs (OnMoveStop handler set in XML)
        self.BuffContainers.playerd = LUIE_SpellCastBuffs_PlayerDebuffs
        self.containerRouting.player1 = "playerb"
        self.containerRouting.player2 = "playerd"

        local fragment1 = ZO_HUDFadeSceneFragment:New(self.BuffContainers.playerb, 0, 0)
        local fragment2 = ZO_HUDFadeSceneFragment:New(self.BuffContainers.playerd, 0, 0)
        table_insert(fragments, fragment1)
        table_insert(fragments, fragment2)
    end

    -- Create TopLevelWindows for buff frames when NOT locked to Custom Unit Frames
    if self.SV.lockPositionToUnitFrames and LUIE.UnitFrames.CustomFrames.reticleover and LUIE.UnitFrames.CustomFrames.reticleover.buffs and LUIE.UnitFrames.CustomFrames.reticleover.debuffs then
        self.BuffContainers.target1 = LUIE.UnitFrames.CustomFrames.reticleover.buffs
        self.BuffContainers.target2 = LUIE.UnitFrames.CustomFrames.reticleover.debuffs
        self.containerRouting.reticleover1 = "target1"
        self.containerRouting.reticleover2 = "target2"
        self.containerRouting.ground = "target2"
    else
        -- Use named TopLevelControl from XML for target buffs (OnMoveStop handler set in XML)
        self.BuffContainers.targetb = LUIE_SpellCastBuffs_TargetBuffs

        -- Use named TopLevelControl from XML for target debuffs (OnMoveStop handler set in XML)
        self.BuffContainers.targetd = LUIE_SpellCastBuffs_TargetDebuffs
        self.containerRouting.reticleover1 = "targetb"
        self.containerRouting.reticleover2 = "targetd"
        self.containerRouting.ground = "targetd"

        local fragment1 = ZO_HUDFadeSceneFragment:New(self.BuffContainers.targetb, 0, 0)
        local fragment2 = ZO_HUDFadeSceneFragment:New(self.BuffContainers.targetd, 0, 0)
        table_insert(fragments, fragment1)
        table_insert(fragments, fragment2)
    end

    -- Create TopLevelWindows for Prominent Buffs (from XML, OnMoveStop handlers set in XML)
    self.BuffContainers.prominentbuffs = LUIE_SpellCastBuffs_ProminentBuffs
    self.BuffContainers.prominentdebuffs = LUIE_SpellCastBuffs_ProminentDebuffs

    if self.SV.ProminentBuffContainerAlignment == 1 then
        self.BuffContainers.prominentbuffs.alignVertical = false
    elseif self.SV.ProminentBuffContainerAlignment == 2 then
        self.BuffContainers.prominentbuffs.alignVertical = true
    end
    if self.SV.ProminentDebuffContainerAlignment == 1 then
        self.BuffContainers.prominentdebuffs.alignVertical = false
    elseif self.SV.ProminentDebuffContainerAlignment == 2 then
        self.BuffContainers.prominentdebuffs.alignVertical = true
    end

    self.containerRouting.promb_ground = "prominentbuffs"
    self.containerRouting.promb_target = "prominentbuffs"
    self.containerRouting.promb_player = "prominentbuffs"
    self.containerRouting.promd_ground = "prominentdebuffs"
    self.containerRouting.promd_target = "prominentdebuffs"
    self.containerRouting.promd_player = "prominentdebuffs"

    local fragmentP1 = ZO_HUDFadeSceneFragment:New(self.BuffContainers.prominentbuffs, 0, 0)
    local fragmentP2 = ZO_HUDFadeSceneFragment:New(self.BuffContainers.prominentdebuffs, 0, 0)
    table_insert(fragments, fragmentP1)
    table_insert(fragments, fragmentP2)

    -- Separate container for players long term buffs (from XML, OnMoveStop handler set in XML)
    self.BuffContainers.player_long = LUIE_SpellCastBuffs_PlayerLong

    if self.SV.LongTermEffectsSeparateAlignment == 1 then
        self.BuffContainers.player_long.alignVertical = false
    elseif self.SV.LongTermEffectsSeparateAlignment == 2 then
        self.BuffContainers.player_long.alignVertical = true
    end

    self.BuffContainers.player_long.skipUpdate = 0
    self.containerRouting.player_long = "player_long"

    local fragment = ZO_HUDFadeSceneFragment:New(self.BuffContainers.player_long, 0, 0)
    fragments[#fragments + 1] = fragment

    -- Loop over table of fragments to add them to relevant UI Scenes
    for _, v in pairs(fragments) do
        sceneManager:GetScene("hud"):AddFragment(v)
        sceneManager:GetScene("hudui"):AddFragment(v)
        sceneManager:GetScene("siegeBar"):AddFragment(v)
        sceneManager:GetScene("siegeBarUI"):AddFragment(v)
    end

    -- Set Buff Container Positions
    self:SetTlwPosition()

    -- Loop over created controls to...
    for _, v in pairs(self.containerRouting) do
        -- Draw Priority is set in XML (layer, tier, level)
        -- Get preview controls from XML (created in XML for performance)
        if self.BuffContainers[v].preview == nil then
            self.BuffContainers[v].preview = self.BuffContainers[v]:GetNamedChild("Preview")
            if self.BuffContainers[v].preview then
                self.BuffContainers[v].previewLabel = self.BuffContainers[v].preview:GetNamedChild("PreviewLabel")
                -- Set initial preview label text
                if self.BuffContainers[v].previewLabel then
                    local windowTitles =
                    {
                        playerb = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS),
                        playerd = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS),
                        player1 = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS),
                        player2 = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS),
                        player_long = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS),
                        targetb = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS),
                        targetd = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS),
                        target1 = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS),
                        target2 = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS),
                        prominentbuffs = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS),
                        prominentdebuffs = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS),
                    }
                    self.BuffContainers[v].previewLabel:SetText((windowTitles[v] or "") .. (self.SV.lockPositionToUnitFrames and (v ~= "player_long" and v ~= "prominentbuffs" and v ~= "prominentdebuffs") and " (locked)" or ""))
                end
            end

            -- Get iconHolder from XML (created in XML for containers that need it)
            -- We need this container only for icons that are aligned in one row/column automatically.
            -- Thus we do not create containers for player and target buffs/debuffs on custom frames
            if v ~= "player1" and v ~= "player2" and v ~= "target1" and v ~= "target2" and v ~= "playerb" and v ~= "playerd" and v ~= "targetb" and v ~= "targetd" then
                self.BuffContainers[v].iconHolder = self.BuffContainers[v]:GetNamedChild("IconHolder")
            end
            -- Create metapool for this container (replaces icons array)
            self.BuffContainers[v].metaPool = self:CreateMetaPool(v, self.BuffContainers[v])

            -- add this top level window to global controls list, so it can be hidden
            if self.BuffContainers[v]:GetType() == CT_TOPLEVELCONTROL then
                LUIE.Components[moduleName .. v] = self.BuffContainers[v]
            end
        end
    end

    self:Reset()
    self:UpdateContextHideList()
    self:UpdateDisplayOverrideIdList()

    self:_RegisterEvents()

    -- Variable adjustment if needed
    if not LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsSCB then
        LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsSCB = 0
    end
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsSCB < 2 then
        -- Set buff cc type colors
        self.SV.colors.buff = SpellCastBuffs.Defaults.colors.buff
        self.SV.colors.debuff = SpellCastBuffs.Defaults.colors.debuff
        self.SV.colors.prioritybuff = SpellCastBuffs.Defaults.colors.prioritybuff
        self.SV.colors.prioritydebuff = SpellCastBuffs.Defaults.colors.prioritydebuff
        self.SV.colors.unbreakable = SpellCastBuffs.Defaults.colors.unbreakable
        self.SV.colors.cosmetic = SpellCastBuffs.Defaults.colors.cosmetic
        self.SV.colors.nocc = SpellCastBuffs.Defaults.colors.nocc
        self.SV.colors.stun = SpellCastBuffs.Defaults.colors.stun
        self.SV.colors.knockback = SpellCastBuffs.Defaults.colors.knockback
        self.SV.colors.levitate = SpellCastBuffs.Defaults.colors.levitate
        self.SV.colors.disorient = SpellCastBuffs.Defaults.colors.disorient
        self.SV.colors.fear = SpellCastBuffs.Defaults.colors.fear
        self.SV.colors.silence = SpellCastBuffs.Defaults.colors.silence
        self.SV.colors.stagger = SpellCastBuffs.Defaults.colors.stagger
        self.SV.colors.snare = SpellCastBuffs.Defaults.colors.snare
        self.SV.colors.root = SpellCastBuffs.Defaults.colors.root
    end
    -- Increment so this doesn't occur again.
    LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsSCB = 2

    -- Initialize preview labels for all frames
    InitializePreviewLabels(self)
end

function SpellCastBuffs:_RegisterEvents()
    -- Register events
    eventManager:RegisterForUpdate(moduleName, 100, function (...) self:OnUpdate(...) end)

    -- Target Events
    eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, function (...) self:OnTargetChange(...) end)
    eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, function (...) self:OnReticleTargetChanged(...) end)
    eventManager:RegisterForEvent(moduleName .. "Disposition", EVENT_DISPOSITION_UPDATE, function (...) self:OnDispositionUpdate(...) end)
    eventManager:AddFilterForEvent(moduleName .. "Disposition", EVENT_DISPOSITION_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- Buff Events
    eventManager:RegisterForEvent(moduleName .. "Player", EVENT_EFFECT_CHANGED, function (...)
        self:OnEffectChanged(...)
    end)
    eventManager:RegisterForEvent(moduleName .. "Target", EVENT_EFFECT_CHANGED, function (...)
        self:OnEffectChanged(...)
    end)
    eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    eventManager:AddFilterForEvent(moduleName .. "Target", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- GROUND & MINE EFFECTS - add a filtered event for each AbilityId
    for k, v in pairs(Effects.EffectGroundDisplay) do
        eventManager:RegisterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, function (...)
            self:OnEffectChangedGround(...)
        end)
        eventManager:AddFilterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_ABILITY_ID, k)
    end
    for k, v in pairs(Effects.LinkedGroundMine) do
        eventManager:RegisterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, function (...)
            self:OnEffectChangedGround(...)
        end)
        eventManager:AddFilterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_ABILITY_ID, k)
    end

    -- Combat Events
    eventManager:RegisterForEvent(moduleName .. "Event1", EVENT_COMBAT_EVENT, function (...)
        self:OnCombatEventIn(...)
    end)
    eventManager:RegisterForEvent(moduleName .. "Event2", EVENT_COMBAT_EVENT, function (...)
        self:OnCombatEventOut(...)
    end)
    eventManager:RegisterForEvent(moduleName .. "Event3", EVENT_COMBAT_EVENT, function (...)
        self:OnCombatEventOut(...)
    end)
    eventManager:AddFilterForEvent(moduleName .. "Event1", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)     -- Target -> Player
    eventManager:AddFilterForEvent(moduleName .. "Event2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)     -- Player -> Target
    eventManager:AddFilterForEvent(moduleName .. "Event3", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET, REGISTER_FILTER_IS_ERROR, false) -- Player Pet -> Target
    for k, v in pairs(Effects.AddNameOnEvent) do
        eventManager:RegisterForEvent(moduleName .. "Event4" .. tostring(k), EVENT_COMBAT_EVENT, function (...)
            self:OnCombatAddNameEvent(...)
        end)
        eventManager:AddFilterForEvent(moduleName .. "Event4" .. tostring(k), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
    end
    eventManager:RegisterForEvent(moduleName, EVENT_BOSSES_CHANGED, function (...) self:AddNameOnBossEngaged(...) end)

    -- Stealth Events
    eventManager:RegisterForEvent(moduleName .. "Player", EVENT_STEALTH_STATE_CHANGED, function (...) self:StealthStateChanged(...) end)
    eventManager:RegisterForEvent(moduleName .. "Reticleover", EVENT_STEALTH_STATE_CHANGED, function (...) self:StealthStateChanged(...) end)
    eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    eventManager:AddFilterForEvent(moduleName .. "Reticleover", EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- Disguise Events
    eventManager:RegisterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, function (...) self:DisguiseStateChanged(...) end)
    eventManager:RegisterForEvent(moduleName .. "Reticleover", EVENT_DISGUISE_STATE_CHANGED, function (...) self:DisguiseStateChanged(...) end)
    eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    eventManager:AddFilterForEvent(moduleName .. "Reticleover", EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- Artificial Effects Handling
    eventManager:RegisterForEvent(moduleName, EVENT_ARTIFICIAL_EFFECT_ADDED, function (...)
        self:ArtificialEffectUpdate(...)
    end)
    eventManager:RegisterForEvent(moduleName, EVENT_ARTIFICIAL_EFFECT_REMOVED, function (...)
        self:ArtificialEffectUpdate(...)
    end)

    -- Activate/Deactivate Player, Player Dead/Alive, Vibration, and Unit Death
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, function (...) self:OnPlayerActivated(...) end)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_DEACTIVATED, function (...) self:OnPlayerDeactivated(...) end)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ALIVE, function (...) self:OnPlayerAlive(...) end)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_DEAD, function (...) self:OnPlayerDead(...) end)
    eventManager:RegisterForEvent(moduleName, EVENT_VIBRATION, function (...) self:OnVibration(...) end)
    eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, function (...) self:OnDeath(...) end)

    -- Mount Events
    eventManager:RegisterForEvent(moduleName, EVENT_MOUNTED_STATE_CHANGED, function (...) self:MountStatus(...) end)
    eventManager:RegisterForEvent(moduleName, EVENT_COLLECTIBLE_USE_RESULT, function (...) self:CollectibleUsed(...) end)

    -- Inventory Events
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function (...) self:DisguiseItem(...) end)
    eventManager:AddFilterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

    -- Duel (For resolving Target Battle Spirit Status)
    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_STARTED, function (...) self:DuelStart(...) end)
    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_FINISHED, function (...) self:DuelEnd(...) end)

    -- Register event to update icons/names/tooltips for some abilities where we pull information from the currently learned morph
    eventManager:RegisterForEvent(moduleName, EVENT_SKILLS_FULL_UPDATE, function (eventId)
        -- Mages Guild
        Effects.EffectOverride[40465].tooltip = zo_strformat(GetString(LUIE_STRING_SKILL_SCALDING_RUNE_TP), ((GetAbilityDuration(40468) or 0) / 1000) + GetNumPassiveSkillRanks(GetSkillLineIndicesFromSkillLineId(44), select(2, GetSkillLineIndicesFromSkillLineId(44)), 8))
    end)

    -- Werewolf
    self:RegisterWerewolfEvents()

    -- Debug
    self:RegisterDebugEvents()
end

function SpellCastBuffs:RegisterWerewolfEvents()
    eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
    eventManager:UnregisterForUpdate(moduleName .. "WerewolfTicker")
    eventManager:UnregisterForEvent(moduleName, EVENT_WEREWOLF_STATE_CHANGED)
    if self.SV.ShowWerewolf then
        eventManager:RegisterForEvent(moduleName, EVENT_WEREWOLF_STATE_CHANGED, function (...) self:WerewolfState(...) end)
        if IsPlayerInWerewolfForm() then
            self:WerewolfState(nil, true, true)
        end
    end
end

function SpellCastBuffs:RegisterDebugEvents()
    -- Unregister existing events
    eventManager:UnregisterForEvent(moduleName .. "DebugCombat", EVENT_COMBAT_EVENT)
    -- Register standard debug events if enabled
    if self.SV.ShowDebugCombat then
        eventManager:RegisterForEvent(moduleName .. "DebugCombat", EVENT_COMBAT_EVENT, function (eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            self:EventCombatDebug(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        end)
    end
    eventManager:UnregisterForEvent(moduleName .. "DebugEffect", EVENT_EFFECT_CHANGED)
    if self.SV.ShowDebugEffect then
        eventManager:RegisterForEvent(moduleName .. "DebugEffect", EVENT_EFFECT_CHANGED, function (eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
            self:EventEffectDebug(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        end)
    end

    -- Author-specific debug events
    if LUIE.IsDevDebugEnabled() then
        eventManager:UnregisterForEvent(moduleName .. "AuthorDebugCombat", EVENT_COMBAT_EVENT)
        if self.SV.ShowDebugCombat then
            eventManager:RegisterForEvent(moduleName .. "AuthorDebugCombat", EVENT_COMBAT_EVENT, function (eventId, ...)
                self:AuthorCombatDebug(eventId, ...)
            end)
        end
        eventManager:UnregisterForEvent(moduleName .. "AuthorDebugEffect", EVENT_EFFECT_CHANGED)
        if self.SV.ShowDebugEffect then
            eventManager:RegisterForEvent(moduleName .. "AuthorDebugEffect", EVENT_EFFECT_CHANGED, function (eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
                self:AuthorEffectDebug(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
            end)
        end
    end
end

function SpellCastBuffs:ResetContainerOrientation()
    ---
    --- @param control TopLevelWindow|table
    local prominentbuffs_OnMoveStop = function (control)
        if control.alignVertical then
            self.SV.prominentbVOffsetX = control:GetLeft()
            self.SV.prominentbVOffsetY = control:GetTop()
        else
            self.SV.prominentbHOffsetX = control:GetLeft()
            self.SV.prominentbHOffsetY = control:GetTop()
        end
    end
    -- Create TopLevelWindows for Prominent Buffs
    self.BuffContainers.prominentbuffs:SetHandler("OnMoveStop", prominentbuffs_OnMoveStop)
    ---
    --- @param control TopLevelWindow|table
    local prominentdebuffs_OnMoveStop = function (control)
        if control.alignVertical then
            self.SV.prominentdVOffsetX = control:GetLeft()
            self.SV.prominentdVOffsetY = control:GetTop()
        else
            self.SV.prominentdHOffsetX = control:GetLeft()
            self.SV.prominentdHOffsetY = control:GetTop()
        end
    end
    self.BuffContainers.prominentdebuffs:SetHandler("OnMoveStop", prominentdebuffs_OnMoveStop)

    if self.SV.ProminentBuffContainerAlignment == 1 then
        self.BuffContainers.prominentbuffs.alignVertical = false
    elseif self.SV.ProminentBuffContainerAlignment == 2 then
        self.BuffContainers.prominentbuffs.alignVertical = true
    end
    if self.SV.ProminentDebuffContainerAlignment == 1 then
        self.BuffContainers.prominentdebuffs.alignVertical = false
    elseif self.SV.ProminentDebuffContainerAlignment == 2 then
        self.BuffContainers.prominentdebuffs.alignVertical = true
    end

    self.containerRouting.promb_ground = "prominentbuffs"
    self.containerRouting.promb_target = "prominentbuffs"
    self.containerRouting.promb_player = "prominentbuffs"
    self.containerRouting.promd_ground = "prominentdebuffs"
    self.containerRouting.promd_target = "prominentdebuffs"
    self.containerRouting.promd_player = "prominentdebuffs"

    ---
    --- @param control TopLevelWindow|table
    local player_long_OnMoveStop = function (control)
        if control.alignVertical then
            self.SV.playerVOffsetX = control:GetLeft()
            self.SV.playerVOffsetY = control:GetTop()
        else
            self.SV.playerHOffsetX = control:GetLeft()
            self.SV.playerHOffsetY = control:GetTop()
        end
    end
    -- Separate container for players long term buffs
    self.BuffContainers.player_long:SetHandler("OnMoveStop", player_long_OnMoveStop)

    if self.SV.LongTermEffectsSeparateAlignment == 1 then
        self.BuffContainers.player_long.alignVertical = false
    elseif self.SV.LongTermEffectsSeparateAlignment == 2 then
        self.BuffContainers.player_long.alignVertical = true
    end

    self.BuffContainers.player_long.skipUpdate = 0
    self.containerRouting.player_long = "player_long"

    -- Set Buff Container Positions
    self:SetTlwPosition()
end

-- Set self.alignmentDirection table to equal the values from our SV Table & converts string values to proper alignment values. Called from Settings Menu & on Initialize
function SpellCastBuffs:SetupContainerAlignment()
    self.alignmentDirection = {}

    self.alignmentDirection.player1 = self.SV.AlignmentBuffsPlayer   -- No icon holder for anchored buffs/debuffs - This value gets passed to self:updateIcons()
    self.alignmentDirection.playerb = self.SV.AlignmentBuffsPlayer   -- No icon holder for anchored buffs/debuffs - This value gets passed to self:updateIcons()
    self.alignmentDirection.player2 = self.SV.AlignmentDebuffsPlayer -- No icon holder for anchored buffs/debuffs - This value gets passed to self:updateIcons()
    self.alignmentDirection.playerd = self.SV.AlignmentDebuffsPlayer -- No icon holder for anchored buffs/debuffs - This value gets passed to self:updateIcons()
    self.alignmentDirection.target1 = self.SV.AlignmentBuffsTarget   -- No icon holder for anchored buffs/debuffs - This value gets passed to self:updateIcons()
    self.alignmentDirection.targetb = self.SV.AlignmentBuffsTarget   -- No icon holder for anchored buffs/debuffs - This value gets passed to self:updateIcons()
    self.alignmentDirection.target2 = self.SV.AlignmentDebuffsTarget -- No icon holder for anchored buffs/debuffs - This value gets passed to self:updateIcons()
    self.alignmentDirection.targetd = self.SV.AlignmentDebuffsTarget -- No icon holder for anchored buffs/debuffs - This value gets passed to self:updateIcons()

    -- Set Long Term Effects Alignment
    if self.SV.LongTermEffectsSeparateAlignment == 1 then
        -- Horizontal
        self.alignmentDirection.player_long = self.SV.AlignmentLongHorz
    elseif self.SV.LongTermEffectsSeparateAlignment == 2 then
        -- Vertical
        self.alignmentDirection.player_long = self.SV.AlignmentLongVert
    end

    -- Set Prominent Buffs Alignment
    if self.SV.ProminentBuffContainerAlignment == 1 then
        -- Horizontal
        self.alignmentDirection.prominentbuffs = self.SV.AlignmentPromBuffsHorz
    elseif self.SV.ProminentBuffContainerAlignment == 2 then
        -- Vertical
        self.alignmentDirection.prominentbuffs = self.SV.AlignmentPromBuffsVert
    end

    -- Set Prominent Debuffs Alignment
    if self.SV.ProminentDebuffContainerAlignment == 1 then
        -- Horizontal
        self.alignmentDirection.prominentdebuffs = self.SV.AlignmentPromDebuffsHorz
    elseif self.SV.ProminentDebuffContainerAlignment == 2 then
        -- Vertical
        self.alignmentDirection.prominentdebuffs = self.SV.AlignmentPromDebuffsVert
    end

    for k, v in pairs(self.alignmentDirection) do
        if v == "Left" then
            self.alignmentDirection[k] = LEFT
        elseif v == "Right" then
            self.alignmentDirection[k] = RIGHT
        elseif v == "Centered" then
            self.alignmentDirection[k] = CENTER
        elseif v == "Top" then
            self.alignmentDirection[k] = TOP
        elseif v == "Bottom" then
            self.alignmentDirection[k] = BOTTOM
        else
            self.alignmentDirection[k] = CENTER -- Fallback
        end
    end

    for k, v in pairs(self.containerRouting) do
        if self.BuffContainers[v].iconHolder and self.alignmentDirection[v] then
            self.BuffContainers[v].iconHolder:ClearAnchors()
            self.BuffContainers[v].iconHolder:SetAnchor(self.alignmentDirection[v])
        end
    end
end

-- Set self.sortDirection table to equal the values from our SV table. Called from Settings Menu & on Initialize
function SpellCastBuffs:SetupContainerSort()
    -- Clear the sort direction table
    self.sortDirection = {}

    -- Set sort order for player/target containers
    self.sortDirection.player1 = self.SV.SortBuffsPlayer
    self.sortDirection.playerb = self.SV.SortBuffsPlayer
    self.sortDirection.player2 = self.SV.SortDebuffsPlayer
    self.sortDirection.playerd = self.SV.SortDebuffsPlayer
    self.sortDirection.target1 = self.SV.SortBuffsTarget
    self.sortDirection.targetb = self.SV.SortBuffsTarget
    self.sortDirection.target2 = self.SV.SortDebuffsTarget
    self.sortDirection.targetd = self.SV.SortDebuffsTarget

    -- Set Long Term Effects Sort Order
    if self.SV.LongTermEffectsSeparateAlignment == 1 then
        -- Horizontal
        self.sortDirection.player_long = self.SV.SortLongHorz
    elseif self.SV.LongTermEffectsSeparateAlignment == 2 then
        -- Vertical
        self.sortDirection.player_long = self.SV.SortLongVert
    end

    -- Set Prominent Buffs Sort Order
    if self.SV.ProminentBuffContainerAlignment == 1 then
        -- Horizontal
        self.sortDirection.prominentbuffs = self.SV.SortPromBuffsHorz
    elseif self.SV.ProminentBuffContainerAlignment == 2 then
        -- Vertical
        self.sortDirection.prominentbuffs = self.SV.SortPromBuffsVert
    end

    -- Set Prominent Debuffs Sort Order
    if self.SV.ProminentDebuffContainerAlignment == 1 then
        -- Horizontal
        self.sortDirection.prominentdebuffs = self.SV.SortPromDebuffsHorz
    elseif self.SV.ProminentDebuffContainerAlignment == 2 then
        -- Vertical
        self.sortDirection.prominentdebuffs = self.SV.SortPromDebuffsVert
    end
end

-- Reset position of windows. Called from Settings Menu.
function SpellCastBuffs:ResetTlwPosition()
    if not self.Enabled then
        return
    end
    self.SV.playerbOffsetX = nil
    self.SV.playerbOffsetY = nil
    self.SV.playerdOffsetX = nil
    self.SV.playerdOffsetY = nil
    self.SV.targetbOffsetX = nil
    self.SV.targetbOffsetY = nil
    self.SV.targetdOffsetX = nil
    self.SV.targetdOffsetY = nil
    self.SV.playerVOffsetX = nil
    self.SV.playerVOffsetY = nil
    self.SV.playerHOffsetX = nil
    self.SV.playerHOffsetY = nil
    self.SV.prominentbVOffsetX = nil
    self.SV.prominentbVOffsetY = nil
    self.SV.prominentbHOffsetX = nil
    self.SV.prominentbHOffsetY = nil
    self.SV.prominentdVOffsetX = nil
    self.SV.prominentdVOffsetY = nil
    self.SV.prominentdHOffsetX = nil
    self.SV.prominentdHOffsetY = nil
    self:SetTlwPosition()
end

-- Set position of windows. Called from .Initialize() and .ResetTlwPosition()
function SpellCastBuffs:SetTlwPosition()
    -- If icons are locked to custom frames, i.e. self.BuffContainers[] is a CT_CONTROL of LUIE.UnitFrames.CustomFrames.player we do not have to do anything here. so just bail out
    -- Otherwise set position of self.BuffContainers[] which are CT_TOPLEVELCONTROLs to saved or default positions
    if self.BuffContainers.playerb and self.BuffContainers.playerb:GetType() == CT_TOPLEVELCONTROL then
        self.BuffContainers.playerb:ClearAnchors()
        if (self.SV.lockPositionToUnitFrames == nil or not self.SV.lockPositionToUnitFrames) and self.SV.playerbOffsetX ~= nil and self.SV.playerbOffsetY ~= nil then
            local x, y = self.SV.playerbOffsetX, self.SV.playerbOffsetY
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                x, y = LUIE.ApplyGridSnap(x, y, "buffs")
            end
            self.BuffContainers.playerb:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        else
            self.BuffContainers.playerb:SetAnchor(BOTTOM, ZO_PlayerAttributeHealth, TOP, 0, -10)
        end
    end

    if self.BuffContainers.playerd and self.BuffContainers.playerd:GetType() == CT_TOPLEVELCONTROL then
        self.BuffContainers.playerd:ClearAnchors()
        if (self.SV.lockPositionToUnitFrames == nil or not self.SV.lockPositionToUnitFrames) and self.SV.playerdOffsetX ~= nil and self.SV.playerdOffsetY ~= nil then
            local x, y = self.SV.playerdOffsetX, self.SV.playerdOffsetY
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                x, y = LUIE.ApplyGridSnap(x, y, "buffs")
            end
            self.BuffContainers.playerd:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        else
            self.BuffContainers.playerd:SetAnchor(BOTTOM, ZO_PlayerAttributeHealth, TOP, 0, -60)
        end
    end

    if self.BuffContainers.targetb and self.BuffContainers.targetb:GetType() == CT_TOPLEVELCONTROL then
        self.BuffContainers.targetb:ClearAnchors()
        if (self.SV.lockPositionToUnitFrames == nil or not self.SV.lockPositionToUnitFrames) and self.SV.targetbOffsetX ~= nil and self.SV.targetbOffsetY ~= nil then
            local x, y = self.SV.targetbOffsetX, self.SV.targetbOffsetY
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                x, y = LUIE.ApplyGridSnap(x, y, "buffs")
            end
            self.BuffContainers.targetb:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        else
            self.BuffContainers.targetb:SetAnchor(TOP, ZO_TargetUnitFramereticleover, BOTTOM, 0, 60)
        end
    end

    if self.BuffContainers.targetd and self.BuffContainers.targetd:GetType() == CT_TOPLEVELCONTROL then
        self.BuffContainers.targetd:ClearAnchors()
        if (self.SV.lockPositionToUnitFrames == nil or not self.SV.lockPositionToUnitFrames) and self.SV.targetdOffsetX ~= nil and self.SV.targetdOffsetY ~= nil then
            local x, y = self.SV.targetdOffsetX, self.SV.targetdOffsetY
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                x, y = LUIE.ApplyGridSnap(x, y, "buffs")
            end
            self.BuffContainers.targetd:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        else
            self.BuffContainers.targetd:SetAnchor(TOP, ZO_TargetUnitFramereticleover, BOTTOM, 0, 110)
        end
    end

    if self.BuffContainers.player_long then
        self.BuffContainers.player_long:ClearAnchors()
        if self.BuffContainers.player_long.alignVertical then
            if self.SV.playerVOffsetX ~= nil and self.SV.playerVOffsetY ~= nil then
                local x, y = self.SV.playerVOffsetX, self.SV.playerVOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                self.BuffContainers.player_long:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                self.BuffContainers.player_long:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -3, -75)
            end
        else
            if self.SV.playerHOffsetX ~= nil and self.SV.playerHOffsetY ~= nil then
                local x, y = self.SV.playerHOffsetX, self.SV.playerHOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                self.BuffContainers.player_long:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                self.BuffContainers.player_long:SetAnchor(BOTTOM, ZO_PlayerAttributeHealth, TOP, 0, -70)
            end
        end
    end

    -- Setup Prominent Buffs Position
    if self.BuffContainers.prominentbuffs then
        self.BuffContainers.prominentbuffs:ClearAnchors()
        if self.BuffContainers.prominentbuffs.alignVertical then
            if self.SV.prominentbVOffsetX ~= nil and self.SV.prominentbVOffsetY ~= nil then
                local x, y = self.SV.prominentbVOffsetX, self.SV.prominentbVOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                self.BuffContainers.prominentbuffs:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                self.BuffContainers.prominentbuffs:SetAnchor(CENTER, GuiRoot, CENTER, -340, -100)
            end
        else
            if self.SV.prominentbHOffsetX ~= nil and self.SV.prominentbHOffsetY ~= nil then
                local x, y = self.SV.prominentbHOffsetX, self.SV.prominentbHOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                self.BuffContainers.prominentbuffs:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                self.BuffContainers.prominentbuffs:SetAnchor(CENTER, GuiRoot, CENTER, -340, -100)
            end
        end
    end

    if self.BuffContainers.prominentdebuffs then
        self.BuffContainers.prominentdebuffs:ClearAnchors()
        if self.BuffContainers.prominentdebuffs.alignVertical then
            if self.SV.prominentdVOffsetX ~= nil and self.SV.prominentdVOffsetY ~= nil then
                local x, y = self.SV.prominentdVOffsetX, self.SV.prominentdVOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                self.BuffContainers.prominentdebuffs:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                self.BuffContainers.prominentdebuffs:SetAnchor(CENTER, GuiRoot, CENTER, 340, -100)
            end
        else
            if self.SV.prominentdHOffsetX ~= nil and self.SV.prominentdHOffsetY ~= nil then
                local x, y = self.SV.prominentdHOffsetX, self.SV.prominentdHOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                self.BuffContainers.prominentdebuffs:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                self.BuffContainers.prominentdebuffs:SetAnchor(CENTER, GuiRoot, CENTER, 340, -100)
            end
        end
    end
end

-- Unlock windows for moving. Called from Settings Menu.
function SpellCastBuffs:SetMovingState(state)
    if not self.Enabled then
        return
    end

    self.BuffsMovingState = state

    local accountWideSettings = LUIESV["Default"][GetDisplayName()]["$AccountWide"]
    local gridEnabled = accountWideSettings and accountWideSettings.snapToGrid_buffs
    local gridSize = (accountWideSettings and accountWideSettings.snapToGridSize_buffs) or 15
    GridOverlay.Refresh("buffs", state and gridEnabled, gridSize)

    -- Use console helper if on console
    if IsConsoleUI() and LUIE.ConsoleMoverHelper then
        local MoverHelper = LUIE.ConsoleMoverHelper
        local EditModeController = LUIE.EditModeController

        -- Activate edit mode when unlocking on console
        if EditModeController and state then
            if not EditModeController:IsEditModeActive() then
                EditModeController:SetEditModeActive(true, "SpellCastBuffs")
            end
        end

        -- Helper function to set up a buff container
        local function SetupBuffContainer(container, identifier, saveCallback)
            if container and container:GetType() == CT_TOPLEVELCONTROL then
                MoverHelper.SetupGamepadHandler(container, "buffs", saveCallback)
                MoverHelper.UpdateControlState(container, identifier, state)
            end
        end

        -- Set up each buff container
        if self.SV.lockPositionToUnitFrames == nil or not self.SV.lockPositionToUnitFrames then
            SetupBuffContainer(self.BuffContainers.playerb, "buff_playerb", function (control, left, top)
                self.SV.playerbOffsetX = left
                self.SV.playerbOffsetY = top
            end)

            SetupBuffContainer(self.BuffContainers.playerd, "buff_playerd", function (control, left, top)
                self.SV.playerdOffsetX = left
                self.SV.playerdOffsetY = top
            end)

            SetupBuffContainer(self.BuffContainers.targetb, "buff_targetb", function (control, left, top)
                self.SV.targetbOffsetX = left
                self.SV.targetbOffsetY = top
            end)

            SetupBuffContainer(self.BuffContainers.targetd, "buff_targetd", function (control, left, top)
                self.SV.targetdOffsetX = left
                self.SV.targetdOffsetY = top
            end)
        end

        SetupBuffContainer(self.BuffContainers.player_long, "buff_player_long", function (control, left, top)
            if control.alignVertical then
                self.SV.playerVOffsetX = left
                self.SV.playerVOffsetY = top
            else
                self.SV.playerHOffsetX = left
                self.SV.playerHOffsetY = top
            end
        end)

        SetupBuffContainer(self.BuffContainers.prominentbuffs, "buff_prominentbuffs", function (control, left, top)
            if control.alignVertical then
                self.SV.prominentbVOffsetX = left
                self.SV.prominentbVOffsetY = top
            else
                self.SV.prominentbHOffsetX = left
                self.SV.prominentbHOffsetY = top
            end
        end)

        SetupBuffContainer(self.BuffContainers.prominentdebuffs, "buff_prominentdebuffs", function (control, left, top)
            if control.alignVertical then
                self.SV.prominentdVOffsetX = left
                self.SV.prominentdVOffsetY = top
            else
                self.SV.prominentdHOffsetX = left
                self.SV.prominentdHOffsetY = top
            end
        end)

        -- Show/hide preview
        for _, v in pairs(self.containerRouting) do
            if self.BuffContainers[v] and self.BuffContainers[v].preview then
                self.BuffContainers[v].preview:SetHidden(not state)
            end
        end

        return
    end

    -- PC/Keyboard version
    -- Helper function to update position label
    local function UpdatePositionLabel(control, label)
        if state and label then
            local left, top = control:GetLeft(), control:GetTop()
            label:SetText(string.format("%d, %d", left, top))
            label:SetHidden(false)
            -- Anchor label to inside top-left of the frame
            label:ClearAnchors()
            label:SetAnchor(TOPLEFT, control.preview, TOPLEFT, 2, 2)
        elseif label then
            label:SetHidden(true)
        end
    end

    -- Set moving state
    if self.BuffContainers.playerb and self.BuffContainers.playerb:GetType() == CT_TOPLEVELCONTROL and (self.SV.lockPositionToUnitFrames == nil or not self.SV.lockPositionToUnitFrames) then
        self.BuffContainers.playerb:SetMouseEnabled(state)
        self.BuffContainers.playerb:SetMovable(state)
        UpdatePositionLabel(self.BuffContainers.playerb, self.BuffContainers.playerb.preview.anchorLabel)

        -- Grid snapping is handled by XML handler
    end

    if self.BuffContainers.playerd and self.BuffContainers.playerd:GetType() == CT_TOPLEVELCONTROL and (self.SV.lockPositionToUnitFrames == nil or not self.SV.lockPositionToUnitFrames) then
        self.BuffContainers.playerd:SetMouseEnabled(state)
        self.BuffContainers.playerd:SetMovable(state)
        UpdatePositionLabel(self.BuffContainers.playerd, self.BuffContainers.playerd.preview.anchorLabel)

        -- Grid snapping is handled by XML handler
    end

    if self.BuffContainers.targetb and self.BuffContainers.targetb:GetType() == CT_TOPLEVELCONTROL and (self.SV.lockPositionToUnitFrames == nil or not self.SV.lockPositionToUnitFrames) then
        self.BuffContainers.targetb:SetMouseEnabled(state)
        self.BuffContainers.targetb:SetMovable(state)
        UpdatePositionLabel(self.BuffContainers.targetb, self.BuffContainers.targetb.preview.anchorLabel)

        -- Grid snapping is handled by XML handler
    end

    if self.BuffContainers.targetd and self.BuffContainers.targetd:GetType() == CT_TOPLEVELCONTROL and (self.SV.lockPositionToUnitFrames == nil or not self.SV.lockPositionToUnitFrames) then
        self.BuffContainers.targetd:SetMouseEnabled(state)
        self.BuffContainers.targetd:SetMovable(state)
        UpdatePositionLabel(self.BuffContainers.targetd, self.BuffContainers.targetd.preview.anchorLabel)

        -- Grid snapping is handled by XML handler
    end

    if self.BuffContainers.player_long then
        self.BuffContainers.player_long:SetMouseEnabled(state)
        self.BuffContainers.player_long:SetMovable(state)
        UpdatePositionLabel(self.BuffContainers.player_long, self.BuffContainers.player_long.preview.anchorLabel)

        -- Grid snapping is handled by XML handler
    end

    if self.BuffContainers.prominentbuffs then
        self.BuffContainers.prominentbuffs:SetMouseEnabled(state)
        self.BuffContainers.prominentbuffs:SetMovable(state)
        UpdatePositionLabel(self.BuffContainers.prominentbuffs, self.BuffContainers.prominentbuffs.preview.anchorLabel)

        -- Grid snapping is handled by XML handler
    end

    if self.BuffContainers.prominentdebuffs then
        self.BuffContainers.prominentdebuffs:SetMouseEnabled(state)
        self.BuffContainers.prominentdebuffs:SetMovable(state)
        UpdatePositionLabel(self.BuffContainers.prominentdebuffs, self.BuffContainers.prominentdebuffs.preview.anchorLabel)

        -- Grid snapping is handled by XML handler
    end

    -- Show/hide preview
    for _, v in pairs(self.containerRouting) do
        if self.BuffContainers[v] and self.BuffContainers[v].preview then
            self.BuffContainers[v].preview:SetHidden(not state)
        end
    end

    -- Now create or remove test-effects icons
    if state then
        self:MenuPreview()
    else
        self:Reset()
    end
end

-- Reset all buff containers
function SpellCastBuffs:Reset()
    if not self.Enabled then
        return
    end

    -- Update padding between icons
    self.padding = zo_floor(0.5 + self.SV.IconSize / 13)

    -- Set size of top level window
    -- Player
    if self.BuffContainers.playerb and self.BuffContainers.playerb:GetType() == CT_TOPLEVELCONTROL then
        self.BuffContainers.playerb:SetDimensions(self.SV.WidthPlayerBuffs, self.SV.IconSize + 6)
        self.BuffContainers.playerd:SetDimensions(self.SV.WidthPlayerDebuffs, self.SV.IconSize + 6)
        self.BuffContainers.playerb.maxIcons = zo_max(1, zo_floor((self.BuffContainers.playerb:GetWidth() - 4 * self.padding) / (self.SV.IconSize + self.padding)))
        self.BuffContainers.playerd.maxIcons = zo_max(1, zo_floor((self.BuffContainers.playerd:GetWidth() - 4 * self.padding) / (self.SV.IconSize + self.padding)))
    else
        self.BuffContainers.player2:SetHeight(self.SV.IconSize)
        self.BuffContainers.player2.firstAnchor = { TOPLEFT, TOP }
        self.BuffContainers.player2.maxIcons = zo_max(1, zo_floor((self.BuffContainers.player2:GetWidth() - 4 * self.padding) / (self.SV.IconSize + self.padding)))

        self.BuffContainers.player1:SetHeight(self.SV.IconSize)
        self.BuffContainers.player1.firstAnchor = { TOPLEFT, TOP }
        self.BuffContainers.player1.maxIcons = zo_max(1, zo_floor((self.BuffContainers.player1:GetWidth() - 4 * self.padding) / (self.SV.IconSize + self.padding)))
    end

    -- Target
    if self.BuffContainers.targetb and self.BuffContainers.targetb:GetType() == CT_TOPLEVELCONTROL then
        self.BuffContainers.targetb:SetDimensions(self.SV.WidthTargetBuffs, self.SV.IconSize + 6)
        self.BuffContainers.targetd:SetDimensions(self.SV.WidthTargetDebuffs, self.SV.IconSize + 6)
        self.BuffContainers.targetb.maxIcons = zo_max(1, zo_floor((self.BuffContainers.targetb:GetWidth() - 4 * self.padding) / (self.SV.IconSize + self.padding)))
        self.BuffContainers.targetd.maxIcons = zo_max(1, zo_floor((self.BuffContainers.targetd:GetWidth() - 4 * self.padding) / (self.SV.IconSize + self.padding)))
    else
        self.BuffContainers.target2:SetHeight(self.SV.IconSize)
        self.BuffContainers.target2.firstAnchor = { TOPLEFT, TOP }
        self.BuffContainers.target2.maxIcons = zo_max(1, zo_floor((self.BuffContainers.target2:GetWidth() - 4 * self.padding) / (self.SV.IconSize + self.padding)))

        self.BuffContainers.target1:SetHeight(self.SV.IconSize)
        self.BuffContainers.target1.firstAnchor = { TOPLEFT, TOP }
        self.BuffContainers.target1.maxIcons = zo_max(1, zo_floor((self.BuffContainers.target1:GetWidth() - 4 * self.padding) / (self.SV.IconSize + self.padding)))
    end

    -- Player long buffs
    if self.BuffContainers.player_long then
        if self.BuffContainers.player_long.alignVertical then
            self.BuffContainers.player_long:SetDimensions(self.SV.IconSize + 6, 400)
        else
            self.BuffContainers.player_long:SetDimensions(500, self.SV.IconSize + 6)
        end
    end

    -- Prominent buffs & debuffs
    if self.BuffContainers.prominentbuffs then
        if self.BuffContainers.prominentbuffs.alignVertical then
            self.BuffContainers.prominentbuffs:SetDimensions(self.SV.IconSize + 6, 400)
        else
            self.BuffContainers.prominentbuffs:SetDimensions(500, self.SV.IconSize + 6)
        end
        if self.BuffContainers.prominentdebuffs.alignVertical then
            self.BuffContainers.prominentdebuffs:SetDimensions(self.SV.IconSize + 6, 400)
        else
            self.BuffContainers.prominentdebuffs:SetDimensions(500, self.SV.IconSize + 6)
        end
    end

    -- Set Alignment and Sort Direction
    self:SetupContainerAlignment()
    self:SetupContainerSort()

    -- Icons are now managed by metapools, so no need to reset individual icons here
    -- The metapool will handle control lifecycle automatically

    if self.playerActive then
        self:ReloadEffects("player")
    end
end

-- Apply original visual layout for a single icon (without anchoring)
-- This mirrors the non-anchoring part of ResetSingleIcon and is used for pooled controls.
local function ApplyIconVisuals(self, container, buff, effect)
    local buffSize = self.SV.IconSize
    local frameSize = 2 * buffSize + 4

    buff:SetHidden(true)
    buff:SetDimensions(buffSize, buffSize)

    if buff.back then
        buff.back:ClearAnchors()
        buff.back:SetAnchor(TOPLEFT, buff, TOPLEFT)
        buff.back:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT)
        buff.back:SetHidden(false) -- Always show basic border
    end

    if buff.frame then
        buff.frame:SetDimensions(frameSize, frameSize)
        buff.frame:SetHidden(not self.SV.GlowIcons) -- Show colored glow only when enabled
    end

    if buff.label then
        buff.label:ClearAnchors()
        buff.label:SetAnchor(TOPLEFT, buff, LEFT, -self.padding, -self.SV.LabelPosition)
        buff.label:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, self.padding, -2)
        buff.label:SetHidden(not self.SV.RemainingText)
    end

    if buff.stack then
        buff.stack:ClearAnchors()
        buff.stack:SetAnchor(CENTER, buff, BOTTOMLEFT, 0, 0)
        buff.stack:SetAnchor(CENTER, buff, TOPRIGHT, -self.padding * 3, self.padding * 3)
        buff.stack:SetHidden(true)
    end

    if buff.name ~= nil then
        if (container == "prominentbuffs" and self.SV.ProminentBuffContainerAlignment == 2)
        or (container == "prominentdebuffs" and self.SV.ProminentDebuffContainerAlignment == 2) then
            -- Vertical
            buff.name:SetHidden(not self.SV.ProminentLabel)
        else
            buff.name:SetHidden(true)
        end
    end

    if buff.bar ~= nil then
        if (container == "prominentbuffs" and self.SV.ProminentBuffContainerAlignment == 2)
        or (container == "prominentdebuffs" and self.SV.ProminentDebuffContainerAlignment == 2) then
            -- Vertical
            buff.bar.backdrop:SetHidden(not self.SV.ProminentProgress)
            buff.bar.bar:SetHidden(not self.SV.ProminentProgress)
        else
            buff.bar.backdrop:SetHidden(true)
            buff.bar.bar:SetHidden(true)
        end
    end

    -- Determine if this effect is permanent (won't animate cooldown)
    local isPermanent = false
    if effect then
        isPermanent = (effect.dur == 0) or (effect.ends == nil) or effect.toggle or effect.groundLabel
    end

    -- Hide IconBG and Cooldown for player_long or permanent effects (no animated cooldown needed)
    if container == "player_long" or isPermanent then
        if buff.iconbg then
            buff.iconbg:SetHidden(true)
        end
        if buff.cd then
            buff.cd:SetHidden(true)
        end
    else
        if buff.cd ~= nil then
            buff.cd:SetHidden(not self.SV.RemainingCooldown)
            if buff.iconbg then
                -- We do not need black icon background when there is no Cooldown control present
                buff.iconbg:SetHidden(not self.SV.RemainingCooldown)
            end
        end
    end

    if buff.abilityId ~= nil then
        buff.abilityId:ClearAnchors()
        buff.abilityId:SetAnchor(CENTER, buff, CENTER, 0, 0)
        buff.abilityId:SetHidden(not self.SV.ShowDebugAbilityId)
    end

    -- Calculate inset: use 1 for permanent effects (no cooldown space), 3 for temporary with cooldown, 1 otherwise
    local inset = 1
    if not isPermanent and container ~= "player_long" then
        inset = (self.SV.RemainingCooldown and buff.cd ~= nil) and 3 or 1
    end

    -- Frame (glow border) - centered and larger than icon (original behavior)
    if buff.frame then
        buff.frame:ClearAnchors()
        buff.frame:SetAnchor(CENTER, buff, CENTER, 0, 0)
        buff.frame:SetDimensions(frameSize, frameSize)
    end

    if buff.drop then
        buff.drop:ClearAnchors()
        buff.drop:SetAnchor(TOPLEFT, buff, TOPLEFT, inset, inset)
        buff.drop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -inset, -inset)
    end

    if buff.icon then
        buff.icon:ClearAnchors()
        buff.icon:SetAnchor(TOPLEFT, buff, TOPLEFT, inset, inset)
        buff.icon:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -inset, -inset)
    end

    -- Anchor cooldown with small offset (1,1) - slightly smaller than control, larger than icon when inset=3
    if buff.cd then
        buff.cd:ClearAnchors()
        buff.cd:SetAnchor(TOPLEFT, buff, TOPLEFT, 1, 1)
        buff.cd:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -1, -1)
    end

    if buff.iconbg ~= nil then
        buff.iconbg:ClearAnchors()
        buff.iconbg:SetAnchor(TOPLEFT, buff, TOPLEFT, inset, inset)
        buff.iconbg:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -inset, -inset)
    end

    -- Prominent label + bar alignment (no anchoring to other icons here)
    if container == "prominentbuffs" and buff.name and buff.bar then
        if self.SV.ProminentBuffLabelDirection == "Left" then
            buff.name:ClearAnchors()
            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)
            buff.name:SetAnchor(RIGHT, buff.bar.backdrop, TOPRIGHT, -2, -4)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[self.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
        else
            buff.name:ClearAnchors()
            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)
            buff.name:SetAnchor(LEFT, buff.bar.backdrop, TOPLEFT, 2, -4)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[self.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
        end
    end

    if container == "prominentdebuffs" and buff.name and buff.bar then
        if self.SV.ProminentDebuffLabelDirection == "Right" then
            buff.name:ClearAnchors()
            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)
            buff.name:SetAnchor(LEFT, buff.bar.backdrop, TOPLEFT, 2, -4)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[self.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
        else
            buff.name:ClearAnchors()
            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)
            buff.name:SetAnchor(RIGHT, buff.bar.backdrop, TOPRIGHT, -2, -4)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[self.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
        end
    end
end

-- Right Click Cancel Buff function
function SpellCastBuffs:_Buff_OnMouseUp(control, button, upInside)
    if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
        ClearMenu()

        -- Cache values since control may be reused/hidden by object pooling
        local id, name = control.effectId, control.effectName
        local buffSlot = control.buffSlot

        -- Blacklist
        local blacklist = self.SV.BlacklistTable
        local isBlacklisted = blacklist[id] or blacklist[name]
        AddMenuItem(isBlacklisted and "Remove from Blacklist" or "Add to Blacklist", function ()
            if isBlacklisted then
                SpellCastBuffs:RemoveFromCustomList(blacklist, id)
                SpellCastBuffs:RemoveFromCustomList(blacklist, name)
            else
                SpellCastBuffs:AddToCustomList(blacklist, id)
                SpellCastBuffs:AddToCustomList(blacklist, name)
            end
        end)

        -- Prominent Buffs
        local promBuffs = self.SV.PromBuffTable
        local isPromBuff = promBuffs[id] or promBuffs[name]
        AddMenuItem(isPromBuff and "Remove from Prominent Buffs" or "Add to Prominent Buffs", function ()
            if isPromBuff then
                SpellCastBuffs:RemoveFromCustomList(promBuffs, id)
                SpellCastBuffs:RemoveFromCustomList(promBuffs, name)
            else
                SpellCastBuffs:AddToCustomList(promBuffs, id)
                SpellCastBuffs:AddToCustomList(promBuffs, name)
            end
        end)

        -- Prominent Debuffs
        local promDebuffs = self.SV.PromDebuffTable
        local isPromDebuff = promDebuffs[id] or promDebuffs[name]
        AddMenuItem(isPromDebuff and "Remove from Prominent Debuffs" or "Add to Prominent Debuffs", function ()
            if isPromDebuff then
                SpellCastBuffs:RemoveFromCustomList(promDebuffs, id)
                SpellCastBuffs:RemoveFromCustomList(promDebuffs, name)
            else
                SpellCastBuffs:AddToCustomList(promDebuffs, id)
                SpellCastBuffs:AddToCustomList(promDebuffs, name)
            end
        end)

        -- Cancel Buff (if possible)
        if buffSlot then
            AddMenuItem("Cancel Buff", function ()
                CancelBuff(buffSlot)
            end)
        end

        -- Don't pass control as owner - prevents OnEffectivelyHidden handler
        -- that would close menu when pooled control gets repositioned/hidden
        ShowMenu(nil)
    end
end

local function ClearStickyTooltip()
    ClearTooltip(GameTooltip)
    eventManager:UnregisterForUpdate(moduleName .. "StickyTooltip")
end

local buffTypes =
{
    [LUIE_BUFF_TYPE_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_BUFF),
    [LUIE_BUFF_TYPE_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_DEBUFF),
    [LUIE_BUFF_TYPE_UB_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_UB_BUFF),
    [LUIE_BUFF_TYPE_UB_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_UB_DEBUFF),
    [LUIE_BUFF_TYPE_GROUND_BUFF_TRACKER] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_BUFF_TRACKER),
    [LUIE_BUFF_TYPE_GROUND_DEBUFF_TRACKER] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_DEBUFF_TRACKER),
    [LUIE_BUFF_TYPE_GROUND_AOE_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_AOE_BUFF),
    [LUIE_BUFF_TYPE_GROUND_AOE_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_AOE_DEBUFF),
    [LUIE_BUFF_TYPE_ENVIRONMENT_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_ENVIRONMENT_BUFF),
    [LUIE_BUFF_TYPE_ENVIRONMENT_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_ENVIRONMENT_DEBUFF),
    [LUIE_BUFF_TYPE_NONE] = GetString(LUIE_STRING_BUFF_TYPE_NONE),
}

function SpellCastBuffs:TooltipBottomLine(control, detailsLine, artificial)
    -- Add bottom divider and info if present:
    if self.SV.TooltipAbilityId or self.SV.TooltipBuffType then
        ZO_Tooltip_AddDivider(GameTooltip)
        GameTooltip:SetVerticalPadding(4)
        GameTooltip:AddLine("", "", ZO_NORMAL_TEXT:UnpackRGB())
        -- Add Ability ID Line
        if self.SV.TooltipAbilityId then
            local labelAbilityId = control.effectId or "None"
            local isArtificial = labelAbilityId == "Fake" and true or artificial
            if isArtificial then
                labelAbilityId = "Artificial"
            end
            GameTooltip:AddHeaderLine("Ability ID", "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_LEFT, ZO_NORMAL_TEXT:UnpackRGB())
            GameTooltip:AddHeaderLine(labelAbilityId, "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
            detailsLine = detailsLine + 1
        end

        -- Add Buff Type Line
        if self.SV.TooltipBuffType then
            local buffType = control.buffType or LUIE_BUFF_TYPE_NONE
            local effectId = control.effectId
            if effectId and Effects.EffectOverride[effectId] and Effects.EffectOverride[effectId].unbreakable then
                buffType = buffType + 2
            end

            -- Setup tooltips for player aoe trackers
            if effectId and Effects.EffectGroundDisplay[effectId] then
                buffType = buffType + 4
            end

            -- Setup tooltips for ground buff/debuff effects
            if effectId and (Effects.AddGroundDamageAura[effectId] or (Effects.EffectOverride[effectId] and Effects.EffectOverride[effectId].groundLabel)) then
                buffType = buffType + 6
            end

            -- Setup tooltips for Fake Player Offline Auras
            if effectId and Effects.FakePlayerOfflineAura[effectId] then
                if Effects.FakePlayerOfflineAura[effectId].ground then
                    buffType = 6
                else
                    buffType = 5
                end
            end

            GameTooltip:AddHeaderLine("Type", "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_LEFT, ZO_NORMAL_TEXT:UnpackRGB())
            GameTooltip:AddHeaderLine(buffTypes[buffType], "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
            detailsLine = detailsLine + 1
        end
    end
end

-- OnMouseEnter for Buff Tooltips
function SpellCastBuffs:_Buff_OnMouseEnter(control)
    eventManager:UnregisterForUpdate(moduleName .. "StickyTooltip")

    InitializeTooltip(GameTooltip, control, BOTTOM, 0, -5, TOP)
    -- Setup Text
    local tooltipText = ""
    local detailsLine
    local colorText = ZO_NORMAL_TEXT
    local tooltipTitle = zo_strformat(SI_ABILITY_TOOLTIP_NAME, control.effectName)
    if control.isArtificial then
        tooltipText = GetArtificialEffectTooltipText(control.effectId)
        GameTooltip:AddLine(tooltipTitle, "ZoFontHeader2", 1, 1, 1, nil)
        detailsLine = 3
        if self.SV.TooltipEnable then
            GameTooltip:SetVerticalPadding(1)
            ZO_Tooltip_AddDivider(GameTooltip)
            GameTooltip:SetVerticalPadding(5)
            GameTooltip:AddLine(tooltipText, "", colorText:UnpackRGBA())
            detailsLine = 5
        end
        self:TooltipBottomLine(control, detailsLine, true)
    else
        if not self.SV.TooltipEnable then
            GameTooltip:AddLine(tooltipTitle, "ZoFontHeader2", 1, 1, 1, nil)
            detailsLine = 3
            self:TooltipBottomLine(control, detailsLine)
            return
        end

        if control.tooltip then
            tooltipText = control.tooltip
        else
            local duration
            if type(control.effectId) == "number" then
                duration = control.duration / 1000
                local value2
                local value3
                if Effects.EffectOverride[control.effectId] then
                    if Effects.EffectOverride[control.effectId].tooltipValue2 then
                        value2 = Effects.EffectOverride[control.effectId].tooltipValue2
                    elseif Effects.EffectOverride[control.effectId].tooltipValue2Mod then
                        value2 = zo_floor(duration + Effects.EffectOverride[control.effectId].tooltipValue2Mod + 0.5)
                    elseif Effects.EffectOverride[control.effectId].tooltipValue2Id then
                        value2 = zo_floor((GetAbilityDuration(Effects.EffectOverride[control.effectId].tooltipValue2Id, nil, "player" or nil) or 0) + 0.5) / 1000
                    else
                        value2 = 0
                    end
                else
                    value2 = 0
                end
                if Effects.EffectOverride[control.effectId] and Effects.EffectOverride[control.effectId].tooltipValue3 then
                    value3 = Effects.EffectOverride[control.effectId].tooltipValue3
                else
                    value3 = 0
                end
                duration = zo_floor((duration * 10) + 0.5) / 10

                tooltipText = (Effects.EffectOverride[control.effectId] and Effects.EffectOverride[control.effectId].tooltip) and zo_strformat(Effects.EffectOverride[control.effectId].tooltip, duration, value2, value3) or ""

                -- If there is a special tooltip to use for targets only, then set this now
                local containerContext = control.container
                if containerContext == "target1" or containerContext == "target2" or containerContext == "targetb" or containerContext == "targetd" or containerContext == "promb_target" or containerContext == "promd_target" then
                    if Effects.EffectOverride[control.effectId] and Effects.EffectOverride[control.effectId].tooltipOther then
                        tooltipText = zo_strformat(Effects.EffectOverride[control.effectId].tooltipOther, duration, value2, value3)
                    end
                end

                -- Use separate Veteran difficulty tooltip if applicable.
                if LUIE.ResolveVeteranDifficulty() == true and Effects.EffectOverride[control.effectId] and Effects.EffectOverride[control.effectId].tooltipVet then
                    tooltipText = zo_strformat(Effects.EffectOverride[control.effectId].tooltipVet, duration, value2, value3)
                end
                -- Use separate Ground tooltip if applicable (only applies to buffs not debuffs)
                if Effects.EffectGroundDisplay[control.effectId] and Effects.EffectGroundDisplay[control.effectId].tooltip and control.buffType == BUFF_EFFECT_TYPE_BUFF then
                    tooltipText = zo_strformat(Effects.EffectGroundDisplay[control.effectId].tooltip, duration, value2, value3)
                end

                -- Display Default Tooltip Description if no custom tooltip is present
                if tooltipText == "" or tooltipText == nil then
                    if GetAbilityEffectDescription(control.buffSlot) ~= "" then
                        tooltipText = GetAbilityEffectDescription(control.buffSlot)
                    end
                end

                -- Display Default Description if no internal effect description is present
                if tooltipText == "" or tooltipText == nil then
                    if GetAbilityDescription(control.effectId, nil, "player" or nil) ~= "" then
                        tooltipText = GetAbilityDescription(control.effectId, nil, "player" or nil)
                    end
                end

                -- Dynamic Tooltip if present
                if Effects.EffectOverride[control.effectId] and Effects.EffectOverride[control.effectId].dynamicTooltip then
                    tooltipText = LUIE.DynamicTooltip(control.effectId) or tooltipText -- Fallback to original tooltipText if nil
                end
            else
                duration = 0
            end
        end

        if Effects.TooltipUseDefault[control.effectId] then
            if GetAbilityEffectDescription(control.buffSlot) ~= "" then
                tooltipText = GetAbilityEffectDescription(control.buffSlot)
                tooltipText = LUIE.UpdateMundusTooltipSyntax(control.effectId, tooltipText)
            end
        end

        -- Set the Tooltip to be default if custom tooltips aren't enabled
        if not self.SV.TooltipCustom then
            tooltipText = GetAbilityEffectDescription(control.buffSlot)
            tooltipText = StringOnlyGSUB(tooltipText, "\n$", "") -- Remove blank end line
        end

        local thirdLine
        local duration = control.duration / 1000

        if Effects.EffectOverride[control.effectId] and Effects.EffectOverride[control.effectId].duration then
            duration = duration + Effects.EffectOverride[control.effectId].duration
        end

        -- if Effects.TooltipNameOverride[control.effectName] then
        --     thirdLine = zo_strformat(Effects.TooltipNameOverride[control.effectName], duration)
        -- end
        -- if Effects.TooltipNameOverride[control.effectId] then
        --     thirdLine = zo_strformat(Effects.TooltipNameOverride[control.effectId], duration)
        -- end

        -- Have to trim trailing spaces on the end of tooltips
        if tooltipText ~= "" then
            tooltipText = string.match(tooltipText, ".*%S")
        end
        if thirdLine ~= "" and thirdLine ~= nil then
            colorText = control.buffType == BUFF_EFFECT_TYPE_DEBUFF and ZO_ERROR_COLOR or ZO_SUCCEEDED_TEXT
        end

        detailsLine = 5

        GameTooltip:AddLine(tooltipTitle, "ZoFontHeader2", 1, 1, 1, nil)
        if tooltipText ~= "" and tooltipText ~= nil then
            GameTooltip:SetVerticalPadding(1)
            ZO_Tooltip_AddDivider(GameTooltip)
            GameTooltip:SetVerticalPadding(5)
            GameTooltip:AddLine(tooltipText, "", colorText:UnpackRGBA())
        end
        if thirdLine ~= "" and thirdLine ~= nil then
            if tooltipText == "" or tooltipText == nil then
                GameTooltip:SetVerticalPadding(1)
                ZO_Tooltip_AddDivider(GameTooltip)
                GameTooltip:SetVerticalPadding(5)
            end
            detailsLine = 7
            GameTooltip:AddLine(thirdLine, "", ZO_NORMAL_TEXT:UnpackRGB())
        end

        self:TooltipBottomLine(control, detailsLine)

        -- Tooltip Debug
        -- GameTooltip:SetAbilityId(117391)

        -- Debug show default Tooltip on my account
        -- if LUIE.PlayerDisplayName == "@ArtOfShred" or LUIE.PlayerDisplayName == "@ArtOfShredPTS" --[[or LUIE.PlayerDisplayName == '@dack_janiels']] then
        if LUIE.IsDevDebugEnabled() then
            GameTooltip:AddLine("Default Tooltip Below:", "", colorText:UnpackRGBA())

            local newtooltipText

            if GetAbilityEffectDescription(control.buffSlot) ~= "" then
                newtooltipText = GetAbilityEffectDescription(control.buffSlot)
            end
            if newtooltipText ~= "" and newtooltipText ~= nil then
                GameTooltip:SetVerticalPadding(1)
                ZO_Tooltip_AddDivider(GameTooltip)
                GameTooltip:SetVerticalPadding(5)
                GameTooltip:AddLine(newtooltipText, "", colorText:UnpackRGBA())
            end
        end
    end
end

-- OnMouseExit for Buff Tooltips
function SpellCastBuffs:_Buff_OnMouseExit(control)
    if self.SV.TooltipSticky > 0 then
        eventManager:RegisterForUpdate(moduleName .. "StickyTooltip", self.SV.TooltipSticky, ClearStickyTooltip)
    else
        ClearTooltip(GameTooltip)
    end
end

-- Updates local variable with new font and resets all existing icons
function SpellCastBuffs:ApplyFont()
    if not self.Enabled then
        return
    end

    -- Font setup for standard Buffs & Debuffs
    local fontName = LUIE.Fonts[self.SV.BuffFontFace]
    if not fontName or fontName == "" then
        LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
        fontName = "LUIE Default Font"
    end
    local fontStyle = self.SV.BuffFontStyle
    local fontSize = (self.SV.BuffFontSize and self.SV.BuffFontSize > 0) and self.SV.BuffFontSize or 17
    self.buffsFont = ZO_CreateFontString(fontName, fontSize, fontStyle)

    -- Font Setup for Prominent Buffs & Debuffs
    local prominentName = LUIE.Fonts[self.SV.ProminentLabelFontFace]
    if not prominentName or prominentName == "" then
        LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
        prominentName = "LUIE Default Font"
    end
    local prominentStyle = self.SV.ProminentLabelFontStyle
    local prominentSize = (self.SV.ProminentLabelFontSize and self.SV.ProminentLabelFontSize > 0) and self.SV.ProminentLabelFontSize or 17
    self.prominentFont = ZO_CreateFontString(prominentName, prominentSize, prominentStyle)

    -- And reset sizes of already existing icons
    for _, container in pairs(self.containerRouting) do
        local containerData = self.BuffContainers[container]
        if containerData and containerData.metaPool then
            local activeObjects = containerData.metaPool:GetActiveObjects()
            for _, buffControl in pairs(activeObjects) do
                -- Set label font
                if buffControl.label then
                    buffControl.label:SetFont(self.buffsFont)
                end
                -- Set prominent buff label font
                if buffControl.name then
                    buffControl.name:SetFont(self.prominentFont)
                end
            end
        end
    end
end

-- Constants for artificial effect types
local ARTIFICIAL_EFFECTS =
{
    ESO_PLUS = 0,
    BATTLE_SPIRIT = 1,
    BATTLE_SPIRIT_IC = 2,
    BG_DESERTER = 3
}

-- Configuration for special effect durations
local EFFECT_DURATIONS =
{
    [ARTIFICIAL_EFFECTS.BG_DESERTER] =
    {
        duration = 300000,
        effectType = BUFF_EFFECT_TYPE_BUFF
    }
}

-- Handles Battle Spirit effect ID conversion and tooltip assignment
local function handleBattleSpiritEffectId(activeEffectId)
    local tooltip = nil
    local artificial = true
    local effectId = activeEffectId

    -- Handle different effect types
    if activeEffectId == ARTIFICIAL_EFFECTS.ESO_PLUS then
        tooltip = Tooltips.Innate_ESO_Plus
    elseif activeEffectId == ARTIFICIAL_EFFECTS.BATTLE_SPIRIT then
        tooltip = Tooltips.Innate_Battle_Spirit
        effectId = 999014
        artificial = false
    elseif activeEffectId == ARTIFICIAL_EFFECTS.BATTLE_SPIRIT_IC then
        tooltip = Tooltips.Innate_Battle_Spirit_Imperial_City
        effectId = 999014
        artificial = false
    end

    return effectId, tooltip, artificial
end

-- Creates effect data structure
local function createEffectData(self, effectId, displayName, iconFile, effectType, startTime, endTime, duration, tooltip, artificial)
    return
    {
        target = self:DetermineTarget("player1"),
        type = effectType,
        id = effectId,
        name = displayName,
        icon = iconFile,
        tooltip = tooltip,
        dur = duration,
        starts = startTime,
        ends = endTime,
        forced = "long",
        restart = true,
        iconNum = 0,
        artificial = artificial,
    }
end

-- Handles BG deserter specific logic
local function handleBGDeserterEffect(startTime)
    local duration = EFFECT_DURATIONS[ARTIFICIAL_EFFECTS.BG_DESERTER].duration
    local endTime = startTime + (GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_BATTLEGROUND_DESERTED_QUEUE) * 1000)
    return duration, endTime, EFFECT_DURATIONS[ARTIFICIAL_EFFECTS.BG_DESERTER].effectType
end

-- Main function for handling artificial effects
function SpellCastBuffs:ArtificialEffectUpdate(eventCode, effectId)
    -- Early exit if player buffs are hidden
    if self.SV.HidePlayerBuffs then
        return
    end

    -- Handle effect removal if effectId is provided
    if effectId then
        local removeEffect = effectId
        if effectId == ARTIFICIAL_EFFECTS.BATTLE_SPIRIT or effectId == ARTIFICIAL_EFFECTS.BATTLE_SPIRIT_IC then
            removeEffect = 999014
        end
        local context = self:DetermineContextSimple("player1", removeEffect, GetDisplayName())
        self.EffectsList[context][removeEffect] = nil
    end

    -- Process active artificial effects
    for activeEffectId in ZO_GetNextActiveArtificialEffectIdIter do
        -- Skip if effect should be ignored based on settings
        if (activeEffectId == ARTIFICIAL_EFFECTS.ESO_PLUS and self.SV.IgnoreEsoPlusPlayer) or
        ((activeEffectId == ARTIFICIAL_EFFECTS.BATTLE_SPIRIT or activeEffectId == ARTIFICIAL_EFFECTS.BATTLE_SPIRIT_IC) and
            self.SV.IgnoreBattleSpiritPlayer) then
            return
        end

        -- Get effect info
        local displayName, iconFile, effectType, _, startTime = GetArtificialEffectInfo(activeEffectId)
        local duration = 0
        local endTime = nil

        -- Handle BG deserter specific case
        if activeEffectId == ARTIFICIAL_EFFECTS.BG_DESERTER then
            duration, endTime, effectType = handleBGDeserterEffect(startTime)
        end

        local tooltip, artificial
        -- Process effects and get tooltips
        effectId, tooltip, artificial = handleBattleSpiritEffectId(activeEffectId)

        -- Create and store effect
        local context = self:DetermineContextSimple("player1", effectId, displayName)
        self.EffectsList[context][effectId] = createEffectData(self, effectId, displayName, iconFile, effectType, startTime, endTime, duration, tooltip, artificial)
    end
end

-- EVENT_BOSSES_CHANGED handler
function SpellCastBuffs:AddNameOnBossEngaged(eventCode)
    -- Clear any names we've added this way
    for k, _ in pairs(Effects.AddNameOnBossEngaged) do
        for name, _ in pairs(Effects.AddNameOnBossEngaged[k]) do
            if Effects.AddNameAura[name] then
                Effects.AddNameAura[name] = nil
            end
        end
    end

    -- Check for bosses and add name auras when engaged.
    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. i
        local bossName = DoesUnitExist(unitTag) and zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName(unitTag)) or ""
        if Effects.AddNameOnBossEngaged[bossName] then
            for k, v in pairs(Effects.AddNameOnBossEngaged[bossName]) do
                Effects.AddNameAura[k] = {}
                Effects.AddNameAura[k][1] = {}
                Effects.AddNameAura[k][1].id = v
            end
        end
    end

    -- Reload Effects on current target
    if not self.SV.HideTargetBuffs then
        self:AddNameAura()
    end
end

-- Called from EVENT_PLAYER_ACTIVATED
function SpellCastBuffs:AddZoneBuffs()
    local zoneId = GetZoneId(GetCurrentMapZoneIndex())
    if Effects.ZoneBuffs[zoneId] then
        local abilityId = Effects.ZoneBuffs[zoneId]
        local abilityName = GetAbilityName(abilityId)
        local abilityIcon = GetAbilityIcon(abilityId)
        local beginTime = GetFrameTimeMilliseconds()
        local stack
        local groundLabel
        local toggle

        local context = self:DetermineContextSimple("player1", abilityId, abilityName)
        self.EffectsList.player1[abilityId] =
        {
            target = self:DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = abilityIcon,
            dur = 0,
            starts = beginTime,
            ends = nil,
            forced = "long",
            restart = true,
            iconNum = 0,
            unbreakable = 0,
            stack = stack,
            groundLabel = groundLabel,
            toggle = toggle,
        }
    end
end

-- Runs on the EVENT_UNIT_DEATH_STATE_CHANGED listener.
-- This handler fires every time a valid unitTag dies or is resurrected
function SpellCastBuffs:OnDeath(eventCode, unitTag, isDead)
    -- Wipe buffs
    if isDead then
        if unitTag == "player" then
            -- Clear all player/ground/prominent containers
            local context = { "player1", "player2", "ground", "promb_ground", "promd_ground", "promb_player", "promd_player" }
            for _, v in pairs(context) do
                local effectsTable = self.EffectsList[v]
                if effectsTable then
                    ZO_ClearTable(effectsTable)
                end
            end

            -- If werewolf is active, reset the icon so it's not removed (otherwise it flashes off for about a second until the trailer function picks up on the fact that no power drain has occurred.
            if self.SV.ShowWerewolf and IsPlayerInWerewolfForm() then
                self:WerewolfState(nil, true, true)
            end
        else
            -- TODO: Do we need to clear prominent target containers here? (Don't think so)
            for effectType = BUFF_EFFECT_TYPE_BUFF, BUFF_EFFECT_TYPE_DEBUFF do
                local key = unitTag .. effectType
                local effectsTable = self.EffectsList[key]
                if effectsTable then
                    ZO_ClearTable(effectsTable)
                end
            end
        end
    end
end

-- Runs on the EVENT_DISPOSITION_UPDATE listener.
-- This handler fires when the disposition of a reticleover unitTag changes. We filter for only this case.
function SpellCastBuffs:OnDispositionUpdate(eventCode, unitTag)
    if not self.SV.HideTargetBuffs then
        self:AddNameAura()
    end
end

-- Runs on the EVENT_TARGET_CHANGE listener.
-- This handler fires every time someone target changes.
-- This function is needed in case the player teleports via Way Shrine
function SpellCastBuffs:OnTargetChange(eventCode, unitTag)
    if unitTag ~= "player" then
        return
    end
    self:OnReticleTargetChanged(eventCode)
end

-- Runs on the EVENT_RETICLE_TARGET_CHANGED listener.
-- This handler fires every time the player's reticle target changes
function SpellCastBuffs:OnReticleTargetChanged(eventCode)
    self:ReloadEffects("reticleover")
end

-- Called by self:ReloadEffects - Displays recall cooldown
function SpellCastBuffs:ShowRecallCooldown()
    local recallRemain, _ = GetRecallCooldown()
    if recallRemain > 0 then
        local currentTimeMs = GetFrameTimeMilliseconds()
        local abilityId = 999016
        local abilityName = Abilities.Innate_Recall_Penalty
        local context = self:DetermineContextSimple("player1", abilityId, abilityName)
        self.EffectsList[context][abilityName] =
        {
            target = self:DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_RECALL_COOLDOWN_DDS,
            dur = 600000,
            starts = currentTimeMs,
            ends = currentTimeMs + recallRemain,
            forced = "long",
            restart = true,
            iconNum = 0,
            -- unbreakable=1 -- TODO: Maybe re-enable this? It makes prominent show as unbreakable blue since its a buff technically
        }
    end
end

-- Called by EVENT_RETICLE_TARGET_CHANGED listener - Saves active FAKE debuffs on enemies and moves them back and forth between the active container or hidden.
function SpellCastBuffs:RestoreSavedFakeEffects()
    -- Restore Ground Effects
    for _, effectsList in pairs({ self.EffectsList.ground, self.EffectsList.saved }) do
        -- local container = self.containerRouting[context]
        for k, v in pairs(effectsList) do
            if v.savedName ~= nil then
                local unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("reticleover"))
                if unitName == v.savedName then
                    if self.EffectsList.saved[k] then
                        self.EffectsList.ground[k] = self.EffectsList.saved[k]
                        self.EffectsList.ground[k].iconNum = 0
                        self.EffectsList.saved[k] = nil
                    end
                else
                    if self.EffectsList.ground[k] then
                        self.EffectsList.saved[k] = self.EffectsList.ground[k]
                        self.EffectsList.ground[k] = nil
                    end
                end
            end
        end
    end
end

-- Called by EVENT_RETICLE_TARGET_CHANGED listener - Displays fake buffs based off unitName (primarily for displaying Boss Immunities)
function SpellCastBuffs:AddNameAura()
    local unitName = GetUnitName("reticleover")
    -- We need to check to make sure the mob is not dead, and also check to make sure the unitTag is not the player (just in case someones name exactly matches that of a boss NPC)
    if Effects.AddNameAura[unitName] and GetUnitReaction("reticleover") == UNIT_REACTION_HOSTILE and not IsUnitPlayer("reticleover") and not IsUnitDead("reticleover") then
        for k, v in pairs(Effects.AddNameAura[unitName]) do
            local abilityName = GetAbilityName(v.id)
            local abilityIcon = GetAbilityIcon(v.id)

            -- Bail out if this ability is blacklisted
            if self.SV.BlacklistTable[v.id] or self.SV.BlacklistTable[abilityName] then
                return
            end

            local stack = v.stack or 0

            local zone = v.zone
            if zone then
                local flag = false
                for i, j in pairs(zone) do
                    if GetZoneId(GetCurrentMapZoneIndex()) == i then
                        flag = true
                    end
                end
                if not flag then
                    return
                end
            end

            local buffType = v.debuff or BUFF_EFFECT_TYPE_BUFF
            local context = v.debuff and "reticleover2" or "reticleover1"
            local abilityId = v.debuff
            context = self:DetermineContext(context, abilityId, abilityName)
            self.EffectsList[context]["Name Specific Buff" .. k] =
            {
                target = self:DetermineTarget(context),
                type = buffType,
                id = v.id,
                name = abilityName,
                icon = abilityIcon,
                dur = 0,
                starts = 1,
                ends = nil,
                forced = "short",
                restart = true,
                iconNum = 0,
                stack = stack,
            }
        end
    end
end

-- Called by menu to preview icon positions. Simply iterates through all containers other than player_long and adds dummy test buffs into them.
function SpellCastBuffs:MenuPreview()
    local currentTimeMs = GetFrameTimeMilliseconds()
    local routing = { "player1", "reticleover1", "promb_player", "player2", "reticleover2", "promd_player" }
    local testEffectDurationList = { 22, 44, 55, 300, 1800000 }
    local abilityId = 999000
    local icon = "/esoui/art/icons/icon_missing.dds"

    for i = 1, 5 do
        for c = 1, 6 do
            local context = routing[c]
            local type = c < 4 and 1 or 2
            local name = ("Test Effect: " .. i)
            local duration = testEffectDurationList[i]
            self.EffectsList[context][abilityId] =
            {
                target = self:DetermineTarget(context),
                type = type,
                id = 16415,
                name = name,
                icon = icon,
                dur = duration * 1000,
                starts = currentTimeMs,
                ends = currentTimeMs + (duration * 1000),
                forced = "short",
                restart = true,
                iconNum = 0,
            }
            abilityId = abilityId + 1
        end
    end
end

-- Runs on EVENT_PLAYER_ACTIVATED listener
function SpellCastBuffs:OnPlayerActivated(eventCode)
    self.playerActive = true
    self.playerResurrectStage = nil

    -- Reload Effects
    self:ReloadEffects("player")
    self:AddNameOnBossEngaged()

    -- Load Zone Specific Buffs
    if not self.SV.HidePlayerBuffs then
        self:AddZoneBuffs()
    end

    -- Resolve Duel Target
    self:DuelStart()

    -- Resolve Mounted icon
    if not self.SV.IgnoreMountPlayer and IsMounted() then
        zo_callLater(function ()
                         self:MountStatus(nil, true)
                     end, 50)
    end

    -- Resolve Disguise Icon
    if not self.SV.IgnoreDisguise then
        zo_callLater(function ()
                         self:DisguiseItem(nil, BAG_WORN, 10, nil, nil, nil, nil, nil, nil, nil, nil)
                     end, 50)
    end

    -- Resolve Assistant Icon
    if not self.SV.IgnorePet or not self.SV.IgnoreAssistant then
        zo_callLater(function ()
                         self:CollectibleBuff()
                     end, 50)
    end

    -- Resolve Werewolf
    if self.SV.ShowWerewolf and IsPlayerInWerewolfForm() then
        self:WerewolfState(nil, true, true)
    end

    -- Sets the player to dead if reloading UI or loading in while dead.
    if IsUnitDead("player") then
        self.playerDead = true
    end
end

-- Runs on the EVENT_PLAYER_DEACTIVATED listener
function SpellCastBuffs:OnPlayerDeactivated(eventCode)
    self.playerActive = false
    self.playerResurrectStage = nil
end

-- Runs on the EVENT_PLAYER_ALIVE listener
function SpellCastBuffs:OnPlayerAlive(eventCode)
    --[[-- If player clicks "Resurrect at Wayshrine", then player is first deactivated, then he is transferred to new position, then he becomes alive (this event) then player is activated again.
    To register resurrection we need to work in this function if player is already active. --]]
    --
    if not self.playerActive or not self.playerDead then
        return
    end

    self.playerDead = false

    -- This is a good place to reload player buffs, as they were wiped on death
    self:ReloadEffects("player")

    -- Start Resurrection Sequence
    self.playerResurrectStage = 1
    --[[If it was self resurrection, then there will be 4 EVENT_VIBRATION:
    First - 600ms, Second - 0ms to switch first one off, Third - 350ms, Fourth - 0ms to switch third one off.
    So now we'll listen in the vibration event and progress self.playerResurrectStage with first 2 events and then on correct third event we'll create a buff. --]]
end

-- Runs on the EVENT_PLAYER_DEAD listener
function SpellCastBuffs:OnPlayerDead(eventCode)
    if not self.playerActive then
        return
    end
    self.playerDead = true
end

-- Runs on the EVENT_VIBRATION listener (detects player resurrection stage)
function SpellCastBuffs:OnVibration(eventCode, duration, coarseMotor, fineMotor, leftTriggerMotor, rightTriggerMotor)
    if not self.playerResurrectStage then
        return
    end
    if self.SV.HidePlayerBuffs then
        return
    end
    if self.playerResurrectStage == 1 and duration == 600 then
        self.playerResurrectStage = 2
    elseif self.playerResurrectStage == 2 and duration == 0 then
        self.playerResurrectStage = 3
    elseif self.playerResurrectStage == 3 and duration == 350 and self.SV.ShowResurrectionImmunity then
        -- We got correct sequence, so let us create a buff and reset the self.playerResurrectStage
        self.playerResurrectStage = nil
        local currentTimeMs = GetFrameTimeMilliseconds()
        local abilityId = 14646
        local abilityName = Abilities.Innate_Resurrection_Immunity
        local context = self:DetermineContextSimple("player1", abilityId, abilityName)
        self.EffectsList[context][abilityId] =
        {
            target = self:DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_RESURRECTION_IMMUNITY_DDS,
            dur = 10000,
            starts = currentTimeMs,
            ends = currentTimeMs + 10000,
            restart = true,
            iconNum = 0,
        }
    else
        -- This event does not seem to have anything to do with player self-resurrection
        self.playerResurrectStage = nil
    end
end

-- Helper function to get CC color
--- @param self table
--- @param ccType integer
--- @return table
local function getCCColor(self, ccType)
    local ccColors =
    {
        [LUIE_CC_TYPE_STUN] = self.SV.colors.stun,
        [LUIE_CC_TYPE_KNOCKDOWN] = self.SV.colors.stun,
        [LUIE_CC_TYPE_KNOCKBACK] = self.SV.colors.knockback,
        [LUIE_CC_TYPE_PULL] = self.SV.colors.levitate,
        [LUIE_CC_TYPE_DISORIENT] = self.SV.colors.disorient,
        [LUIE_CC_TYPE_FEAR] = self.SV.colors.fear,
        [LUIE_CC_TYPE_SILENCE] = self.SV.colors.silence,
        [LUIE_CC_TYPE_STAGGER] = self.SV.colors.stagger,
        [LUIE_CC_TYPE_SNARE] = self.SV.colors.snare,
        [LUIE_CC_TYPE_ROOT] = self.SV.colors.root,
    }
    return ccColors[ccType] or self.SV.colors.nocc
end

-- Helper function to determine if effect is priority
--- @param self table
--- @param contextType string
--- @param id integer
--- @param abilityName string
--- @return boolean
local function isPriorityEffect(self, contextType, id, abilityName)
    local priorityTable = (contextType == "buff") and self.SV.PriorityBuffTable or self.SV.PriorityDebuffTable
    return priorityTable[id] or priorityTable[abilityName]
end

-- Determine fill color based on buff type and conditions
--- @param self table
--- @param contextType string
--- @param id integer
--- @param abilityName string
--- @param unbreakable integer
--- @return table
local function determineFillColor(self, contextType, id, abilityName, unbreakable)
    local priority = isPriorityEffect(self, contextType, id, abilityName)

    if contextType == "buff" then
        if priority then
            return self.SV.colors.prioritybuff
        elseif unbreakable == 1 and self.SV.ColorCosmetic then
            return self.SV.colors.cosmetic
        end
        return self.SV.colors.buff
    end

    -- debuff
    if priority then
        return self.SV.colors.prioritydebuff
    elseif unbreakable == 1 and self.SV.ColorUnbreakable then
        return self.SV.colors.unbreakable
    elseif self.SV.ColorCC and Effects.EffectOverride[id] and Effects.EffectOverride[id].cc then
        return getCCColor(self, Effects.EffectOverride[id].cc)
    end
    return self.SV.colors.debuff
end

-- Helper function to set progress bar colors
--- @param self table
--- @param buff table
--- @param isDebuff boolean
--- @param isPriority boolean
local function setProgressBarColors(self, buff, isDebuff, isPriority)
    local colors, gradientColors

    if isDebuff then
        colors = isPriority and self.SV.ProminentProgressDebuffPriorityC2 or self.SV.ProminentProgressDebuffC2
        gradientColors = isPriority and self.SV.ProminentProgressDebuffPriorityC1 or self.SV.ProminentProgressDebuffC1
    else
        colors = isPriority and self.SV.ProminentProgressBuffPriorityC2 or self.SV.ProminentProgressBuffC2
        gradientColors = isPriority and self.SV.ProminentProgressBuffPriorityC1 or self.SV.ProminentProgressBuffC1
    end

    buff.bar.backdrop:SetCenterColor(0.1 * colors[1], 0.1 * colors[2], 0.1 * colors[3], 0.75)
    buff.bar.bar:SetGradientColors(colors[1], colors[2], colors[3], 1, gradientColors[1], gradientColors[2], gradientColors[3], 1)
end

--- @param self table
--- @param buff table
--- @param buffType integer
--- @param unbreakable integer
--- @param id integer
local function SetSingleIconBuffType(self, buff, buffType, unbreakable, id)
    local contextType = (buffType == BUFF_EFFECT_TYPE_BUFF) and "buff" or "debuff"
    local abilityName = GetAbilityName(id)
    local fillColor = determineFillColor(self, contextType, id, abilityName, unbreakable)
    local labelColor = (contextType == "buff") and self.SV.colors.buff or self.SV.colors.debuff
    local textColor = self.SV.RemainingTextColoured and labelColor or { 1, 1, 1, 1 }

    buff.frame:SetTexture("/esoui/art/actionbar/" .. contextType .. "_frame.dds")
    buff.label:SetColor(textColor[1], textColor[2], textColor[3], textColor[4])
    buff.stack:SetColor(textColor[1], textColor[2], textColor[3], textColor[4])
    buff.drop:SetHidden(false)

    if buff.cd then
        buff.cd:SetFillColor(fillColor[1], fillColor[2], fillColor[3], fillColor[4])
    end

    if buff.bar then
        local priority = isPriorityEffect(self, contextType, id, abilityName)
        setProgressBarColors(self, buff, buffType == BUFF_EFFECT_TYPE_DEBUFF, priority)
    end
end

-- Create a metapool for a container (similar to ZOS's CreateMetaPool)
-- @param container string Container name
-- @param containerControl Control The container control
-- @return ZO_MetaPool The created metapool
function SpellCastBuffs:CreateMetaPool(container, containerControl)
    local metaPool = ZO_MetaPool:New(self.controlPool)
    metaPool.container = containerControl
    metaPool.containerName = container

    -- Custom acquire behavior - minimal setup only
    -- Called by ZO_MetaPool:AcquireObject() after acquiring from source pool
    local function OnAcquired(control)
        control:ClearAnchors()
        control:SetParent(containerControl)
        -- All anchoring will be handled in updateIcons() to avoid cycles when reusing controls
    end

    -- Custom reset behavior (following ZOS pattern - minimal cleanup)
    -- Called by ZO_MetaPool:ReleaseAllObjects() or :ReleaseObject() before releasing to source pool
    -- Note: ZO_ControlPool's internal reset already calls SetHidden(true) and ClearAnchors()
    local function OnReset(control)
        -- Reset cooldown (matching ZOS pattern)
        if control.cd then
            control.cd:ResetCooldown()
            control.cd:SetHidden(true)
        end

        -- Clear all custom data references to prevent memory leaks
        control.data = nil
        control.effectSlotId = nil
        control.effectId = nil
        control.effectName = nil
        control.buffType = nil
        control.buffSlot = nil
        control.tooltip = nil
        control.duration = nil
        control.container = nil
        control.isArtificial = nil
        control.effectType = nil
    end

    metaPool:SetCustomAcquireBehavior(OnAcquired)
    metaPool:SetCustomResetBehavior(OnReset)

    return metaPool
end

-- Quadratic easing out - decelerating to zero velocity (For buff fade)
--- @param t number
--- @param b number
--- @param c number
--- @param d number
--- @return number
local function EaseOutQuad(t, b, c, d)
    -- protect against 1 / 0
    if t == 0 then
        t = 0.0001
    end
    if d == 0 then
        d = 0.0001
    end

    t = t / d
    return -c * t * (t - 2) + b
end

-- Helper to get sort iteration parameters
local function getSortIteration(self, container, count)
    local sortDir = self.sortDirection[container]
    if sortDir == "Right to Left" or sortDir == "Top to Bottom" then
        return count, 1, -1
    end
    return 1, count, 1
end

-- Find control matching effect data in active objects
local function findControlForEffect(activeObjects, effect)
    for _, control in pairs(activeObjects) do
        if control.data == effect then
            return control
        end
    end
    return nil
end

--- @param self table
--- @param currentTimeMs number
--- @param sortedList table
--- @param container string
local function updateBar(self, currentTimeMs, sortedList, container)
    local containerData = self.BuffContainers[container]
    local activeObjects = containerData.metaPool:GetActiveObjects()
    local istart, iend, istep = getSortIteration(self, container, #sortedList)

    for i = istart, iend, istep do
        local effect = sortedList[i]
        local buff = findControlForEffect(activeObjects, effect)

        if buff and buff.bar and buff.bar.bar then
            local remain = effect.ends and (effect.ends - currentTimeMs)
            local auraStarts = effect.starts
            local auraEnds = effect.ends

            -- Modify recall penalty to show forced max duration
            if effect.id == 999016 then
                auraStarts = auraEnds - 600000
            end

            if auraStarts and auraEnds and remain and remain > 0 and not effect.groundLabel then
                buff.bar.bar:SetValue(1 - ((currentTimeMs - auraStarts) / (auraEnds - auraStarts)))
            elseif effect.werewolf then
                buff.bar.bar:SetValue(effect.werewolf)
            else
                buff.bar.bar:SetValue(1)
            end
        end
    end
end

-- Setup icon visual properties
--- @param self table
--- @param buffControl Control The buff icon control
--- @param effect table The effect data
local function SetupIcon(self, buffControl, effect)
    if buffControl.icon then
        buffControl.icon:SetTexture(effect.icon)
    end

    if buffControl.stack then
        if effect.stack and effect.stack > 0 then
            buffControl.stack:SetText(string_format("%s", effect.stack))
            buffControl.stack:SetHidden(false)
        else
            buffControl.stack:SetHidden(true)
        end
    end

    if buffControl.drop then
        buffControl.drop:SetHidden(not effect.backdrop)
    end
end

-- Initialize buff control child references
local function setupBuffChildReferences(buff)
    if not buff.back then
        buff.back = buff:GetNamedChild("Back")
        buff.frame = buff:GetNamedChild("Frame")
        buff.iconbg = buff:GetNamedChild("IconBG")
        buff.drop = buff:GetNamedChild("Drop")
        buff.icon = buff:GetNamedChild("Icon")
        buff.cd = buff:GetNamedChild("Cooldown")
        buff.label = buff:GetNamedChild("Label")
        buff.abilityId = buff:GetNamedChild("AbilityId")
        buff.stack = buff:GetNamedChild("Stack")
    end
end

-- Setup prominent buff elements and anchoring
local function setupProminentBuff(self, buff, container, effect)
    if (container ~= "prominentbuffs" and container ~= "prominentdebuffs") or buff.name then
        return
    end

    buff.effectType = effect.type
    buff.name = buff:GetNamedChild("Name")
    if buff.name then
        buff.name:SetFont(self.prominentFont)
    end

    local barBackdrop = buff:GetNamedChild("BarBackdrop")
    local bar = buff:GetNamedChild("Bar")
    if barBackdrop and bar then
        buff.bar = { backdrop = barBackdrop, bar = bar }
        buff.bar.backdrop:SetEdgeTexture("", 2, 2, 2, 2)
        buff.bar.backdrop:SetDimensions(154, 16)
        buff.bar.bar:SetDimensions(150, 12)
        buff.bar.bar:SetMinMax(0, 1)
    end
end

-- Configure prominent buff bar visibility and anchors
local function configureProminentBuffBar(self, buff, container)
    if not buff.name or not buff.bar then
        return
    end

    local isVertical = (container == "prominentbuffs" and self.SV.ProminentBuffContainerAlignment == 2) or
        (container == "prominentdebuffs" and self.SV.ProminentDebuffContainerAlignment == 2)

    if not isVertical then
        buff.name:SetHidden(true)
        buff.bar.backdrop:SetHidden(true)
        buff.bar.bar:SetHidden(true)
        return
    end

    buff.name:SetHidden(not self.SV.ProminentLabel)
    buff.bar.backdrop:SetHidden(not self.SV.ProminentProgress)
    buff.bar.bar:SetHidden(not self.SV.ProminentProgress)

    -- Determine label direction
    local labelLeft = (container == "prominentbuffs" and self.SV.ProminentBuffLabelDirection == "Left") or
        (container == "prominentdebuffs" and self.SV.ProminentDebuffLabelDirection ~= "Right")

    buff.name:ClearAnchors()
    buff.bar.backdrop:ClearAnchors()

    if labelLeft then
        buff.name:SetAnchor(RIGHT, buff.bar.backdrop, TOPRIGHT, -2, -4)
        buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)
        buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
    else
        buff.name:SetAnchor(LEFT, buff.bar.backdrop, TOPLEFT, 2, -4)
        buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)
        buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
    end

    if buff.bar.bar then
        buff.bar.bar:SetTexture(LUIE.StatusbarTextures[self.SV.ProminentProgressTexture])
        buff.bar.bar:ClearAnchors()
        buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
    end
end

-- Get row increment direction for manual anchoring
local function getRowIncrement(self, container)
    if container == "player1" or container == "target1" then
        return 1
    elseif container == "player2" or container == "target2" then
        return -1
    elseif container == "playerb" then
        return self.SV.StackPlayerBuffs == "Down" and 1 or -1
    elseif container == "playerd" then
        return self.SV.StackPlayerDebuffs == "Down" and 1 or -1
    elseif container == "targetb" then
        return self.SV.StackTargetBuffs == "Down" and 1 or -1
    elseif container == "targetd" then
        return self.SV.StackTargetDebuffs == "Down" and 1 or -1
    end
    return 0
end

-- Anchor buff icon based on container settings
local function anchorBuffIcon(self, buff, index, prevControl, containerData, container, row, iconSize, iconsNum)
    buff:ClearAnchors()

    if containerData.iconHolder then
        -- Automatic anchoring for containers with iconHolder
        if index == 1 then
            if containerData.alignVertical then
                buff:SetAnchor(BOTTOM, containerData.iconHolder, BOTTOM, 0, 0)
            else
                buff:SetAnchor(LEFT, containerData.iconHolder, LEFT, 0, 0)
            end
        elseif prevControl then
            if containerData.alignVertical then
                buff:SetAnchor(BOTTOM, prevControl, TOP, 0, -self.padding)
            else
                buff:SetAnchor(LEFT, prevControl, RIGHT, self.padding, 0)
            end
        end
    elseif prevControl then
        -- Manual alignment - anchor to previous control
        if containerData.alignVertical then
            buff:SetAnchor(BOTTOM, prevControl, TOP, 0, -self.padding)
        else
            buff:SetAnchor(LEFT, prevControl, RIGHT, self.padding, 0)
        end
    end
end

-- Anchor first icon in row for manual alignment
local function anchorFirstIconInRow(self, buff, containerData, alignmentDir, iconSize, iconsNum, row, maxIcons)
    buff:ClearAnchors()

    local anchor, leftPadding

    if alignmentDir == LEFT then
        anchor = TOPLEFT
        leftPadding = self.padding
    elseif alignmentDir == RIGHT then
        anchor = TOPRIGHT
        leftPadding = -zo_min(maxIcons, iconsNum - maxIcons * row) * iconSize - self.padding
    else
        anchor = TOP
        leftPadding = -0.5 * (zo_min(maxIcons, iconsNum - maxIcons * row) * iconSize - self.padding)
    end

    buff:SetAnchor(TOPLEFT, containerData, anchor, leftPadding, row * iconSize)
end

-- Setup buff cooldown animation
local function setupBuffCooldown(buff, effect, remain)
    if not effect.restart or not buff.cd or buff.cd:GetDuration() ~= 0 then
        return
    end

    local cooldownDuration = (effect.id == 999016) and 600000 or effect.dur

    if not remain or not cooldownDuration or cooldownDuration == 0 or effect.fakeDuration then
        buff.cd:StartCooldown(0, 0, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)
    else
        buff.cd:StartCooldown(remain, cooldownDuration, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
    end

    effect.restart = false
end

--- @param self table
--- @param currentTimeMs number
--- @param sortedList table
--- @param container string
local function updateIcons(self, currentTimeMs, sortedList, container)
    local containerData = self.BuffContainers[container]
    local metaPool = containerData.metaPool

    -- Skip update for player long buffs container (throttled to 1/3 frequency)
    if containerData.skipUpdate then
        containerData.skipUpdate = containerData.skipUpdate + 1
        if containerData.skipUpdate > 1 then
            containerData.skipUpdate = 0
        else
            return
        end
    end

    local iconsNum = #sortedList
    if iconsNum == 0 then
        metaPool:ReleaseAllObjects()
        return
    end

    -- Build map of current effects to determine which controls to keep
    local currentEffectSlots = {}
    for i = 1, iconsNum do
        local effect = sortedList[i]
        local effectSlotId = effect.buffSlot or ("slot_" .. effect.id)
        currentEffectSlots[effectSlotId] = effect
    end

    -- Release controls for effects that are no longer active
    local toRelease = {}
    for key, control in pairs(metaPool:GetActiveObjects()) do
        if control.effectSlotId and not currentEffectSlots[control.effectSlotId] then
            table.insert(toRelease, key)
        end
    end
    for _, key in ipairs(toRelease) do
        metaPool:ReleaseObject(key)
    end

    local istart, iend, istep = getSortIteration(self, container, iconsNum)
    local iconSize = self.SV.IconSize + self.padding

    -- Set iconHolder dimensions for automatic alignment
    if containerData.iconHolder then
        if containerData.alignVertical then
            containerData.iconHolder:SetDimensions(0, iconSize * iconsNum - self.padding)
        else
            containerData.iconHolder:SetDimensions(iconSize * iconsNum - self.padding, 0)
        end
    end

    -- Variables for manual alignment
    local row = 0
    local next_row_break = 1
    local maxIcons = containerData.maxIcons
    local alignmentDir = self.alignmentDirection[container]

    local index = 0
    local prevControl = nil
    local usedControls = {}

    for i = istart, iend, istep do
        local effect = sortedList[i]
        index = index + 1

        -- Find or acquire control for this effect
        local effectSlotId = effect.buffSlot or ("slot_" .. effect.id)
        local buff = nil

        for key, control in pairs(metaPool:GetActiveObjects()) do
            if control.effectSlotId == effectSlotId and not usedControls[control] then
                buff = control
                break
            end
        end

        if not buff then
            buff = metaPool:AcquireObject()
            buff.effectSlotId = effectSlotId
            effect.restart = true
        end

        usedControls[buff] = true
        buff.data = effect

        -- Setup child references and fonts
        setupBuffChildReferences(buff)

        if buff.label then buff.label:SetFont(self.buffsFont) end
        if buff.stack then buff.stack:SetFont(self.buffsFont) end
        if buff.abilityId then buff.abilityId:SetFont(self.buffsFont) end

        ApplyIconVisuals(self, container, buff, effect)

        -- Setup prominent buff elements
        setupProminentBuff(self, buff, container, effect)
        configureProminentBuffBar(self, buff, container)

        local remain = effect.ends and (effect.ends - currentTimeMs)

        -- Anchoring
        if not containerData.iconHolder and index == next_row_break then
            anchorFirstIconInRow(self, buff, containerData, alignmentDir, iconSize, iconsNum, row, maxIcons)
            if maxIcons then
                row = row + getRowIncrement(self, container)
                next_row_break = next_row_break + maxIcons
            end
        else
            anchorBuffIcon(self, buff, index, prevControl, containerData, container, row, iconSize, iconsNum)
        end

        prevControl = buff
        effect.iconNum = index

        -- Apply visual state
        SetSingleIconBuffType(self, buff, effect.type, effect.unbreakable, effect.id)

        -- Setup tooltip data
        buff.effectId = effect.id
        buff.effectName = effect.name
        buff.buffType = effect.type
        buff.buffSlot = effect.buffSlot
        buff.tooltip = effect.tooltip
        buff.duration = effect.dur or 0
        buff.container = container

        SetupIcon(self, buff, effect)

        buff:SetAlpha(1)
        buff:SetHidden(false)

        if buff.abilityId and effect.id then
            buff.abilityId:SetText(effect.id)
        end

        if buff.name then
            if not effect._cachedName then
                effect._cachedName = zo_strformat("<<C:1>>", effect.name)
            end
            buff.name:SetText(effect._cachedName)
        end

        -- Setup cooldown
        setupBuffCooldown(buff, effect, remain)

        -- Set initial label text for non-duration effects
        if not remain or effect.fakeDuration then
            if effect.toggle then
                buff.label:SetText("T")
            elseif effect.groundLabel then
                buff.label:SetText("G")
            else
                buff.label:SetText(nil)
            end
        end
    end
end



-- Update duration for a single buff control
--- @param self table
--- @param buffControl Control The buff icon control
--- @param currentTimeMs number Current time in milliseconds
--- @param container string Container name
local function UpdateDuration(self, buffControl, currentTimeMs, container)
    local effect = buffControl.data
    if not effect then
        return
    end

    local remain = (effect.ends ~= nil) and zo_max(effect.ends - currentTimeMs, 0) or nil
    local showDuration = remain ~= nil and effect.dur ~= nil and effect.dur > 0 and not effect.fakeDuration

    -- Update duration label visibility
    if buffControl.label then
        buffControl.label:SetHidden(not showDuration)
    end

    if showDuration then
        local remainSeconds = remain / 1000

        -- Update duration label text
        if buffControl.label then
            local cachedText = effect._cachedText
            local newText

            if remain > 86400000 then
                newText = string_format("%d d", zo_floor(remain / 86400000))
            elseif remain > 6000000 then
                newText = string_format("%dh", zo_floor(remain / 3600000))
            elseif remain > 600000 then
                newText = string_format("%dm", zo_floor(remain / 60000))
            elseif remain > 60000 or container == "player_long" then
                local m = zo_floor(remain / 60000)
                local s = zo_floor(remainSeconds - 60 * m)
                newText = string_format("%d:%.2d", m, s)
            else
                newText = string_format(self.SV.RemainingTextMillis and "%.1f" or "%.1d", remainSeconds)
            end

            -- Only update text if it changed
            if cachedText ~= newText then
                buffControl.label:SetText(newText)
                effect._cachedText = newText
            end
        end

        -- Handle fade out for expiring icons
        if self.SV.FadeOutIcons and remain < 2000 then
            buffControl:SetAlpha(EaseOutQuad(remain, 0, 1, 2000))
        end
    end
end

-- Update durations and cooldowns for active icons
-- This runs separately from updateIcons to update time-sensitive elements without releasing objects
--- @param self table
--- @param currentTimeMs number
--- @param container string
local function UpdateTime(self, currentTimeMs, container)
    local containerData = self.BuffContainers[container]
    local metaPool = containerData.metaPool
    local activeObjects = metaPool:GetActiveObjects()

    for _, buffControl in pairs(activeObjects) do
        UpdateDuration(self, buffControl, currentTimeMs, container)
    end
end

-- Helper function to sort buffs
local function buffSort(x, y)
    local xDuration = (x.ends == nil or x.dur == 0 or x.groundLabel or x.toggle) and 0 or x.dur
    local yDuration = (y.ends == nil or y.dur == 0 or y.groundLabel or y.toggle) and 0 or y.dur

    if x.toggle or y.toggle then
        if xDuration == 0 and yDuration == 0 then
            if x.toggle and y.toggle then
                return x.name < y.name
            elseif x.toggle then
                return xDuration == 0
            end
        else
            return xDuration == 0
        end
    elseif xDuration == 0 and yDuration == 0 then
        return x.name < y.name
    elseif xDuration ~= 0 and yDuration ~= 0 then
        return (x.starts == y.starts) and (x.name < y.name) or (x.ends > y.ends)
    end
    return xDuration == 0
end

-- Add effect to sorted buffer list
local function addToSortedList(buffsSorted, sortedCounts, container, effect)
    sortedCounts[container] = sortedCounts[container] + 1
    buffsSorted[container][sortedCounts[container]] = effect
end

-- Determine if effect should be shown based on settings and type
local function shouldShowEffect(self, effect, container)
    if effect.target == "prominent" then
        return true, container
    end

    local isShortTerm = effect.type == BUFF_EFFECT_TYPE_DEBUFF or effect.forced == "short" or
        not (effect.forced == "long" or effect.ends == nil or effect.dur == 0)

    if isShortTerm then
        if effect.target == "reticleover" then
            return self.SV.ShortTermEffects_Target, container
        elseif effect.target == "player" then
            return self.SV.ShortTermEffects_Player, container
        end
    else
        -- Long-term effects
        if effect.target == "reticleover" then
            return self.SV.LongTermEffects_Target, container
        elseif effect.target == "player" and self.SV.LongTermEffects_Player then
            local usePlayerLong = self.SV.LongTermEffectsSeparate and
                container ~= "prominentbuffs" and container ~= "prominentdebuffs"
            return true, usePlayerLong and "player_long" or container
        end
    end

    return false, nil
end

-- Runs OnUpdate - 100 ms buffer
--- @param currentTimeMs number
function SpellCastBuffs:OnUpdate(currentTimeMs)
    local containerRouting = self.containerRouting
    local EffectsList = self.EffectsList

    local buffsSorted = {}
    local sortedCounts = {}
    local isProminent = {}

    -- Initialize containers
    for _, container in pairs(containerRouting) do
        buffsSorted[container] = {}
        sortedCounts[container] = 0
        if container == "prominentbuffs" or container == "prominentdebuffs" then
            isProminent[container] = true
        end
    end
    buffsSorted.player_long = {}
    sortedCounts.player_long = 0

    -- Filter expired events and build array for sorting
    for context, effectsList in pairs(EffectsList) do
        local container = containerRouting[context]
        for k, v in pairs(effectsList) do
            if v.ends and v.dur > 0 and v.ends < currentTimeMs then
                effectsList[k] = nil
            elseif container and v.starts < currentTimeMs then
                local show, targetContainer = shouldShowEffect(self, v, container)
                if show then
                    addToSortedList(buffsSorted, sortedCounts, targetContainer, v)
                end
            end
        end
    end

    -- Sort and update all containers
    for _, container in pairs(containerRouting) do
        table_sort(buffsSorted[container], buffSort)
        updateIcons(self, currentTimeMs, buffsSorted[container], container)
    end

    -- Update prominent buff bars
    for container in pairs(isProminent) do
        updateBar(self, currentTimeMs, buffsSorted[container], container)
    end

    -- Update player_long if it has effects
    if sortedCounts.player_long > 0 then
        table_sort(buffsSorted.player_long, buffSort)
        updateIcons(self, currentTimeMs, buffsSorted.player_long, "player_long")
    end

    -- Update time displays for all containers (includes player_long)
    for _, container in pairs(containerRouting) do
        UpdateTime(self, currentTimeMs, container)
    end

    -- Display Block buff for player if enabled
    if self.SV.ShowBlockPlayer and not self.SV.HidePlayerBuffs then
        if IsBlockActive() and not IsPlayerStunned() then
            local abilityId = 974
            local context = self:DetermineContextSimple("player1", abilityId, Abilities.Innate_Brace)
            EffectsList[context][abilityId] =
            {
                target = self:DetermineTarget(context),
                type = 1,
                id = abilityId,
                name = Abilities.Innate_Brace,
                icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_BLOCK_DDS,
                dur = 0,
                starts = currentTimeMs,
                ends = nil,
                restart = true,
                iconNum = 0,
                forced = "short",
                toggle = true,
            }
        else
            self:ClearPlayerBuff(974)
        end
    end
end

-- Function to pull Werewolf Cast Bar / Buff Aura Icon based off the players morph choice
local function SetWerewolfIcon(self)
    local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(32455)
    local abilityInfo = { GetSkillAbilityInfo(skillType, skillIndex, abilityIndex) }
    self.werewolfName, self.werewolfIcon = abilityInfo[1], abilityInfo[2]
    self.werewolfId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, false)
end

function SpellCastBuffs:DisplayWerewolfIcon()
    SetWerewolfIcon(self)
    local contextTarget = "player1"
    local context = self:DetermineContextSimple(contextTarget, self.werewolfId, self.werewolfName)
    local power = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_WEREWOLF)
    self.EffectsList[context]["Werewolf Indicator"] =
    {
        target = "player",
        type = 1,
        id = self.werewolfId,
        name = self.werewolfName,
        icon = self.werewolfIcon,
        dur = 0,
        starts = 1,
        ends = nil, -- ends=nil : last buff in sorting
        forced = "short",
        restart = true,
        iconNum = 0,
        werewolf = power / 1000,
    }
end

function SpellCastBuffs:HideWerewolfIcon()
    local contextTarget = "player1"
    local context = self:DetermineContextSimple(contextTarget, self.werewolfId, self.werewolfName)
    self.EffectsList[context]["Werewolf Indicator"] = nil
end

-- Get Werewolf State for Werewolf Buff Tracker
function SpellCastBuffs:WerewolfState(eventCode, werewolf, onActivation)
    if werewolf and not self.SV.HidePlayerBuffs then
        for i = 1, 6 do
            local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_WORLD, i)
            local name, discovered, skillLineId = skillLineData:GetName(), skillLineData:IsAvailable(), skillLineData:GetId()
            if skillLineId == 50 and discovered then
                self.werewolfCounter = self.werewolfCounter + 1
                if self.werewolfCounter == 3 or onActivation then
                    self:DisplayWerewolfIcon()
                    eventManager:RegisterForEvent(moduleName, EVENT_POWER_UPDATE, function (...) self:OnPowerUpdate(...) end)
                    eventManager:AddFilterForEvent(moduleName, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_WEREWOLF, REGISTER_FILTER_UNIT_TAG, "player")
                    self.werewolfCounter = 0
                end
                return
            end
        end

        self.werewolfQuest = self.werewolfQuest + 1
        -- If we didn't return from the above statement this must be quest based werewolf transformation - so just display an unlimited duration passive as the counter.
        if self.werewolfQuest == 2 or onActivation then
            self.werewolfCounter = 0
        end
    else
        self:HideWerewolfIcon()
        eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
        eventManager:UnregisterForUpdate(moduleName .. "WerewolfTicker")
        self.werewolfCounter = 0
        -- Delay resetting this value - as the quest werewolf transform event causes werewolf true, false, true in succession.
        zo_callLater(function ()
                         self.werewolfQuest = 0
                     end, 5000)
    end
end

-- EVENT_POWER_UPDATE handler for Werewolf Buff Tracker
function SpellCastBuffs:OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if powerValue > 0 then
        self:DisplayWerewolfIcon()
    else
        self:HideWerewolfIcon()
    end

    -- Remove indicator if power reaches 0 - Needed for when the player is in WW form but dead/reincarnating
    if powerValue == 0 then
        self:HideWerewolfIcon()
        eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
        eventManager:UnregisterForUpdate(moduleName .. "WerewolfTicker")
        self.werewolfCounter = 0
        -- Delay resetting this value - as the quest werewolf transform event causes werewolf true, false, true in succession.
        zo_callLater(function ()
                         self.werewolfQuest = 0
                     end, 5000)
    end
end

-- TODO: Update id's here with fake ids probably, to set different icons etc for Prominent add/remove

-- Called by SpellCastBuffs.DisguiseItem()
function SpellCastBuffs:SetDisguiseItem()
    local abilityId = 999020
    -- Remove buff first
    self:ClearPlayerBuff(abilityId)

    -- If we don't have a disguise equipped, have a Monk's Disguise (already has buff icon) or Guild Tabard then bail out
    if self.currentDisguise == 0 or self.currentDisguise == 79332 or self.currentDisguise == 55262 then
        return
    end

    local name = GetItemName(BAG_WORN, EQUIP_SLOT_COSTUME)
    local abilityName = Abilities.Innate_Disguise
    local icon = Effects.DisguiseIcons[self.currentDisguise].icon
    local idTooltip = Effects.DisguiseIcons[self.currentDisguise].id or ""
    local tooltip = Effects.EffectOverride[idTooltip] and Effects.EffectOverride[idTooltip].tooltip or Tooltips.Disguise_Generic
    -- Determine Context
    local context = self:DetermineContextSimple("player1", abilityId, abilityName)
    -- Create Buff
    self.EffectsList[context][abilityId] =
    {
        target = self:DetermineTarget(context),
        type = 1,
        id = abilityId,
        name = name,
        icon = icon,
        tooltip = tooltip,
        dur = 0,
        starts = 1,
        ends = nil, -- ends=nil : last buff in sorting
        forced = "long",
        restart = true,
        iconNum = 0,
    }
end

-- Called on item slot change for Disguise.
--- - **EVENT_INVENTORY_SINGLE_SLOT_UPDATE **
---
--- @param eventId integer
--- @param bagId Bag
--- @param slotIndex integer
--- @param isNewItem boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param inventoryUpdateReason integer
--- @param stackCountChange integer
--- @param triggeredByCharacterName string?
--- @param triggeredByDisplayName string?
--- @param isLastUpdateForMessage boolean
--- @param bonusDropSource BonusDropSource
function SpellCastBuffs:DisguiseItem(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    -- If slotIndex isn't the disguise/tabard slot then return
    if slotIndex ~= EQUIP_SLOT_COSTUME or self.SV.IgnoreDisguise or self.SV.HidePlayerBuffs then
        return
    end

    -- Set current disguise
    self.currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0

    -- Set the icon for the disguise to display
    self:SetDisguiseItem()
end

-- Handles disguise changes for player/reticleover
--- - **EVENT_DISGUISE_STATE_CHANGED **
---
--- @param eventId integer
--- @param unitTag string
--- @param disguiseState DisguiseState
function SpellCastBuffs:DisguiseStateChanged(eventId, unitTag, disguiseState)
    -- Bail out if we don't have disguise or unitTag buffs enabled
    if unitTag == "player" and (not self.SV.DisguiseStatePlayer or self.SV.HidePlayerBuffs) then
        return
    elseif unitTag == "reticleover" and (not self.SV.DisguiseStatePlayer or self.SV.HideTargetBuffs) then
        return
    end

    -- Bail out if for some reason we have no value for disguiseState
    if disguiseState == nil then
        return
    end

    local abilityId = 50602
    local abilityName = Abilities.Innate_Disguised
    -- Determine Context
    local context = unitTag .. "1"
    context = self:DetermineContextSimple(context, abilityId, abilityName)

    -- Remove buff first
    self.EffectsList[context][abilityId] = nil

    -- Add disguise icon if we are in any state of disguise
    if disguiseState == DISGUISE_STATE_DISGUISED or disguiseState == DISGUISE_STATE_DANGER or disguiseState == DISGUISE_STATE_SUSPICIOUS or disguiseState == DISGUISE_STATE_DISCOVERED then
        self.EffectsList[context][abilityId] =
        {
            target = self:DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_DISGUISED_DDS,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "short",
            restart = true,
            iconNum = 0,
        }
    end
end

local function RemoveSneak(self, context)
    local abilityId = 20299
    local abilityName = Abilities.Innate_Sneak
    local contexta = self:DetermineContextSimple(context, abilityId, abilityName)
    self.EffectsList[contexta][abilityId] = nil
end

local function RemoveHidden(self, context)
    local abilityId = 20309
    local abilityName = Abilities.Innate_Hidden
    local contextb = self:DetermineContextSimple(context, abilityId, abilityName)
    self.EffectsList[contextb][abilityId] = nil
end

-- Handles stealth state changes for player/reticleover
--- - **EVENT_STEALTH_STATE_CHANGED **
---
--- @param eventId integer
--- @param unitTag string
--- @param stealthState StealthState
function SpellCastBuffs:StealthStateChanged(eventId, unitTag, stealthState)
    -- Bail out if we don't have stealth or unitTag buffs enabled
    if unitTag == "player" and (not self.SV.StealthStatePlayer or self.SV.HidePlayerBuffs) then
        return
    elseif unitTag == "reticleover" and (not self.SV.StealthStateTarget or self.SV.HideTargetBuffs) then
        return
    end

    -- Bail out if for some reason we have no value for stealthState
    if stealthState == nil then
        return
    end

    -- Determine Context
    local context = unitTag .. "1"
    -- Remove buffs first
    RemoveSneak(self, context)
    RemoveHidden(self, context)

    -- Add hidden icon if we are hidden
    if stealthState == STEALTH_STATE_HIDDEN or stealthState == STEALTH_STATE_HIDDEN_ALMOST_DETECTED then
        local abilityId = 20299
        local abilityName = Abilities.Innate_Sneak
        context = self:DetermineContextSimple(context, abilityId, abilityName)
        self.EffectsList[context][abilityId] =
        {
            target = self:DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_HIDDEN_DDS,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "short",
            restart = true,
            iconNum = 0,
        }
        -- Add invisible icon if we are invisible
    elseif stealthState == STEALTH_STATE_STEALTH or stealthState == STEALTH_STATE_STEALTH_ALMOST_DETECTED then
        local abilityId = 20309
        local abilityName = Abilities.Innate_Hidden
        context = self:DetermineContextSimple(context, abilityId, abilityName)
        self.EffectsList[context][abilityId] =
        {
            target = self:DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_INVISIBLE_DDS,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "short",
            restart = true,
            iconNum = 0,
        }
    end
end

-- Used to clear existing .effectsList.unitTag and to request game API to fill it again
---
--- @param unitTag string
function SpellCastBuffs:ReloadEffects(unitTag)
    -- Bail if this isn't reticleover or player
    if unitTag ~= "player" and unitTag ~= "reticleover" then
        return
    end

    -- Clear existing base containers
    for effectType = BUFF_EFFECT_TYPE_ITERATION_BEGIN, BUFF_EFFECT_TYPE_ITERATION_END do
        local key = unitTag .. effectType
        local effectsTable = self.EffectsList[key]
        if effectsTable then
            ZO_ClearTable(effectsTable)
        else
            self.EffectsList[key] = {}
        end
    end
    -- Clear prominent containers
    if unitTag == "player" then
        local context = { "promb_player", "promb_ground", "promd_player", "promd_ground" }
        for _, v in pairs(context) do
            local effectsTable = self.EffectsList[v]
            if effectsTable then
                ZO_ClearTable(effectsTable)
            else
                self.EffectsList[v] = {}
            end
        end
    else
        local context = { "promb_target", "promd_target" }
        for _, v in pairs(context) do
            local effectsTable = self.EffectsList[v]
            if effectsTable then
                ZO_ClearTable(effectsTable)
            else
                self.EffectsList[v] = {}
            end
        end
    end

    -- Stop doing anything else if we moused off a target
    if GetUnitName(unitTag) == "" then
        return
    end

    -- Bail out if the target is dead
    if IsUnitDead(unitTag) then
        return
    end

    -- Get unitName to pass to OnEffectChanged
    local unitName = GetRawUnitName(unitTag)
    -- Fill it again
    for i = 1, GetNumBuffs(unitTag) do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)
        -- Fudge this value to send to SpellCastBuffs.OnEffectChanged if this is a debuff
        if castByPlayer == true then
            --- @diagnostic disable-next-line: cast-local-type
            castByPlayer = COMBAT_UNIT_TYPE_PLAYER
        else
            --- @diagnostic disable-next-line: cast-local-type
            castByPlayer = COMBAT_UNIT_TYPE_OTHER
        end
        self:OnEffectChanged(0, EFFECT_RESULT_UPDATED, buffSlot, buffName, unitTag, timeStarted, timeEnding, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, unitName, 0, --[[unitId]] abilityId, castByPlayer)
    end
    -- Display Disguise State (note that this function handles filtering player/target buffs if hidden)
    self:DisguiseStateChanged(nil, unitTag, GetUnitDisguiseState(unitTag))
    -- Display Stealth State (note that this function handles filtering player/target buffs if hidden)
    self:StealthStateChanged(nil, unitTag, GetUnitStealthState(unitTag))

    -- Player Specific
    if unitTag == "player" and not self.SV.HidePlayerBuffs then
        -- Display Assistant/Non-Combat Pet/Mount Icon
        self:CollectibleBuff()
        self:MountStatus("", true)
        -- Display Disguise Icon (if disguised)
        if not self.SV.IgnoreDisguise then
            self:SetDisguiseItem()
        end
        -- Update Artificial Effects
        self:ArtificialEffectUpdate()
        -- Display Recall Cooldown
        if self.SV.ShowRecall and not self.SV.HidePlayerDebuffs then
            self:ShowRecallCooldown()
        end
        -- Reload werewolf effects
        if self.SV.ShowWerewolf and IsPlayerInWerewolfForm() then
            self:WerewolfState(nil, true, true)
        end
    end

    -- Target Specific
    if unitTag == "reticleover" and not self.SV.HideTargetBuffs then
        -- Handle FAKE DEBUFFS between targets
        self:RestoreSavedFakeEffects()
        -- Add Name Auras
        self:AddNameAura()
        -- Display Battle Spirit
        self:LoadBattleSpiritTarget()
    end
end

-- Runs on the EVENT_EFFECT_CHANGED listener.
--- @param eventId integer
--- @param changeType EffectResult
--- @param effectSlot integer
--- @param effectName string
--- @param unitTag string
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param iconName string
--- @param deprecatedBuffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param unitName string
--- @param unitId integer
--- @param abilityId integer
--- @param sourceType CombatUnitType
function SpellCastBuffs:OnEffectChangedGround(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if self.SV.HideGroundEffects then
        return
    end

    -- Ensure all necessary contexts are initialized
    for context, _ in pairs(self.containerRouting) do
        if not self.EffectsList[context] then
            self.EffectsList[context] = {}
        end
    end

    -- Mines with multiple auras have to be linked into one id for the purpose of tracking stacks
    if Effects.LinkedGroundMine[abilityId] then
        abilityId = Effects.LinkedGroundMine[abilityId]
    end

    -- Bail out if this ability is blacklisted
    if self.SV.BlacklistTable[abilityId] or self.SV.BlacklistTable[effectName] then
        return
    end

    -- Create fake ground aura
    local groundType = {}
    groundType[1] =
    {
        info = Effects.EffectGroundDisplay[abilityId].buff,
        context = "player1",
        promB = "promb_player",
        promD = "promd_player",
        type = BUFF_EFFECT_TYPE_BUFF,
    }
    groundType[2] =
    {
        info = Effects.EffectGroundDisplay[abilityId].debuff,
        context = "player2",
        promB = "promb_target",
        promD = "promd_target",
        type = BUFF_EFFECT_TYPE_DEBUFF,
    }
    groundType[3] =
    {
        info = Effects.EffectGroundDisplay[abilityId].ground,
        context = "ground",
        promB = "promb_ground",
        promD = "promd_ground",
        type = BUFF_EFFECT_TYPE_DEBUFF,
    }

    if changeType == EFFECT_RESULT_FADED then
        if Effects.EffectGroundDisplay[abilityId] and Effects.EffectGroundDisplay[abilityId].noRemove then
            return
        end -- Ignore some abilities
        local currentTimeMs = GetFrameTimeMilliseconds()
        if not self.protectAbilityRemoval[abilityId] or self.protectAbilityRemoval[abilityId] < currentTimeMs then
            for i = 1, 3 do
                if groundType[i].info == true then
                    -- Set container context
                    local context
                    if self.SV.PromDebuffTable[abilityId] or self.SV.PromDebuffTable[effectName] then
                        context = groundType[i].promD
                    elseif self.SV.PromBuffTable[abilityId] or self.SV.PromBuffTable[effectName] then
                        context = groundType[i].promB
                    else
                        context = groundType[i].context
                    end
                    if Effects.IsGroundMineAura[abilityId] or Effects.IsGroundMineStack[abilityId] then
                        -- Check to make sure aura exists in case of reloadUI
                        if self.EffectsList[context][abilityId] then
                            self.EffectsList[context][abilityId].stack = self.EffectsList[context][abilityId].stack - Effects.EffectGroundDisplay[abilityId].stackRemove
                            if self.EffectsList[context][abilityId].stack == 0 then
                                self.EffectsList[context][abilityId] = nil
                            end
                        end
                    else
                        self.EffectsList[context][abilityId] = nil
                    end
                end
            end
        end
    elseif changeType == EFFECT_RESULT_GAINED then
        local currentTimeMs = GetFrameTimeMilliseconds()
        self.protectAbilityRemoval[abilityId] = currentTimeMs + 150

        local duration = endTime - beginTime
        local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false
        local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false
        iconName = Effects.EffectGroundDisplay[abilityId].icon or iconName
        effectName = Effects.EffectGroundDisplay[abilityId].name or effectName

        for i = 1, 3 do
            if groundType[i].info == true then
                -- Set container context
                local context
                if self.SV.PromDebuffTable[abilityId] or self.SV.PromDebuffTable[effectName] then
                    context = groundType[i].promD
                elseif self.SV.PromBuffTable[abilityId] or self.SV.PromBuffTable[effectName] then
                    context = groundType[i].promB
                else
                    context = groundType[i].context
                end
                if Effects.IsGroundMineAura[abilityId] then
                    stackCount = Effects.EffectGroundDisplay[abilityId].stackReset
                    if Effects.HideGroundMineStacks[abilityId] then
                        stackCount = 0
                    end
                elseif Effects.IsGroundMineStack[abilityId] then
                    if self.EffectsList[context][abilityId] then
                        stackCount = self.EffectsList[context][abilityId].stack + Effects.EffectGroundDisplay[abilityId].stackRemove
                    else
                        stackCount = 1
                    end
                    if stackCount > Effects.EffectGroundDisplay[abilityId].stackReset then
                        stackCount = Effects.EffectGroundDisplay[abilityId].stackReset
                    end
                end

                self.EffectsList[context][abilityId] =
                {
                    target = self:DetermineTarget(context),
                    type = groundType[i].type,
                    id = abilityId,
                    name = effectName,
                    icon = iconName,
                    dur = 1000 * duration,
                    starts = 1000 * beginTime,
                    ends = (duration > 0) and (1000 * endTime) or nil,
                    forced = nil,
                    restart = true,
                    iconNum = 0,
                    unbreakable = 0,
                    stack = stackCount,
                    buffSlot = effectSlot,
                    groundLabel = groundLabel,
                    toggle = toggle,
                }
            end
        end
    end
end

--- @type table<number, string>
local oakensoul = Effects.IsOakenSoul

--- @return boolean
local function OakensoulEquipped()
    if GetItemLinkItemId(GetItemLink(BAG_WORN, 11, LINK_STYLE_DEFAULT)) == 187658 or GetItemLinkItemId(GetItemLink(BAG_WORN, 12, LINK_STYLE_DEFAULT)) == 187658 then
        return true
    end
    return false
end

--- @param buffId number
--- @return boolean
local function IsOakensoul(buffId)
    if OakensoulEquipped() then
        for id in pairs(oakensoul) do
            if buffId == id then
                return true
            end
        end
    end
    return false
end

-- Runs on the EVENT_EFFECT_CHANGED listener.
-- This handler fires every long-term effect added or removed
--- @param eventId integer
--- @param changeType EffectResult
--- @param effectSlot integer
--- @param effectName string
--- @param unitTag string
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param iconName string
--- @param deprecatedBuffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param unitName string
--- @param unitId integer
--- @param abilityId integer
--- @param sourceType CombatUnitType
function SpellCastBuffs:OnEffectChanged(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    -- Change the effect type / name before we determine if we want to filter anything else.
    if Effects.EffectOverride[abilityId] then
        effectName = Effects.EffectOverride[abilityId].name or effectName
        effectType = Effects.EffectOverride[abilityId].type or effectType
        -- Bail out now if we hide ground snares and other effects because we are showing Damaging Auras (Only do this for the player, we don't want effects on targets to stop showing up).
        if Effects.EffectOverride[abilityId].hideGround and self.SV.GroundDamageAura and unitTag == "player" then
            return
        end
    end

    -- Bail out if the abilityId is on the Blacklist Table
    if self.SV.BlacklistTable[abilityId] then
        return
    end

    -- Bail out if this is an effect from Oakensoul
    if (self.SV.HideOakenSoul == true) and IsOakensoul(abilityId) and unitTag == "player" then
        return
    end

    -- Hide effects if chosen in the options menu
    if self.hidePlayerEffects[abilityId] and unitTag == "player" then
        return
    end

    if self.hideTargetEffects[abilityId] and unitTag == "reticleover" then
        return
    end

    -- If the source of the buff isn't the player or the buff is not on the AbilityId or AbilityName override list then we don't display it
    if unitTag ~= "player" then
        if effectType == BUFF_EFFECT_TYPE_DEBUFF and not (sourceType == COMBAT_UNIT_TYPE_PLAYER) and not (self.debuffDisplayOverrideId[abilityId] or Effects.DebuffDisplayOverrideName[effectName]) then
            return
        end
    end

    -- Ignore Siphoner on non-player targets
    if abilityId == 92428 and unitTag == "reticleover" and not IsUnitPlayer("reticleover") then
        return
    end

    -- If this effect isn't a prominent buff or debuff and we have certain buffs set to hidden - then hide those.
    if not (self.SV.PromDebuffTable[abilityId] or self.SV.PromDebuffTable[effectName] or self.SV.PromBuffTable[abilityId] or self.SV.PromBuffTable[effectName]) then
        if self.SV.HidePlayerBuffs and effectType == BUFF_EFFECT_TYPE_BUFF and unitTag == "player" then
            return
        end
        if self.SV.HidePlayerDebuffs and effectType == BUFF_EFFECT_TYPE_DEBUFF and unitTag == "player" then
            return
        end
        if self.SV.HideTargetBuffs and effectType == BUFF_EFFECT_TYPE_BUFF and unitTag ~= "player" then
            return
        end
        if self.SV.HideTargetDebuffs and effectType == BUFF_EFFECT_TYPE_DEBUFF and unitTag ~= "player" then
            return
        end
    end

    -- If this is a set ICD then don't display if we have Set ICD's disabled.
    if Effects.IsSetICD[abilityId] and self.SV.IgnoreSetICDPlayer then
        return
    end
    -- If this is an ability ICD then don't display if we have Ability ICD's disabled.
    if Effects.IsAbilityICD[abilityId] and self.SV.IgnoreAbilityICDPlayer then
        return
    end

    local unbreakable = 0

    -- Set Override data from Effects.lua
    if Effects.EffectOverride[abilityId] then
        if Effects.EffectOverride[abilityId].hide == true then
            return
        end
        if Effects.EffectOverride[abilityId].hideReduce == true and self.SV.HideReduce then
            return
        end
        if Effects.EffectOverride[abilityId].isDisguise and self.SV.IgnoreDisguise then
            -- For Monk's Disguise / other buff based Disguise hiding.
            return
        end
        iconName = Effects.EffectOverride[abilityId].icon or iconName
        unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
        stackCount = Effects.EffectOverride[abilityId].stack or stackCount
        -- Destroy other effects of the same type if we don't want to show duplicates at all.
        if Effects.EffectOverride[abilityId].noDuplicate then
            for context, effectsList in pairs(self.EffectsList) do
                for k, v in pairs(effectsList) do
                    -- Only remove the lower duration effects that were cast previously or simultaneously.
                    if v.id == abilityId and v.ends <= (1000 * endTime) then
                        self.EffectsList[context][k] = nil
                    end
                end
            end
        end
        -- Bail out if this effect should only appear on Refresh
        if Effects.EffectOverride[abilityId].refreshOnly then
            if changeType ~= EFFECT_RESULT_UPDATED and changeType ~= EFFECT_RESULT_FULL_REFRESH and changeType ~= EFFECT_RESULT_FADED then
                return
            end
        end
    end

    -- Bail out if the effectName is hidden in the Blacklist Table
    if self.SV.BlacklistTable[effectName] then
        return
    end

    -- Override name, icon, or hide based on MapZoneIndex
    if Effects.ZoneDataOverride[abilityId] then
        local index = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        if Effects.ZoneDataOverride[abilityId][index] then
            if Effects.ZoneDataOverride[abilityId][index].icon then
                iconName = Effects.ZoneDataOverride[abilityId][index].icon
            end
            if Effects.ZoneDataOverride[abilityId][index].name then
                effectName = Effects.ZoneDataOverride[abilityId][index].name
            end
            if Effects.ZoneDataOverride[abilityId][index].hide then
                return
            end
        end
        if Effects.ZoneDataOverride[abilityId][zoneName] then
            if Effects.ZoneDataOverride[abilityId][zoneName].icon then
                iconName = Effects.ZoneDataOverride[abilityId][zoneName].icon
            end
            if Effects.ZoneDataOverride[abilityId][zoneName].name then
                effectName = Effects.ZoneDataOverride[abilityId][zoneName].name
            end
            if Effects.ZoneDataOverride[abilityId][zoneName].hide then
                return
            end
        end
    end

    -- Override name, icon, or hide based on Map Name
    if Effects.MapDataOverride[abilityId] then
        local mapName = GetMapName()
        if Effects.MapDataOverride[abilityId][mapName] then
            if Effects.MapDataOverride[abilityId][mapName].icon then
                iconName = Effects.MapDataOverride[abilityId][mapName].icon
            end
            if Effects.MapDataOverride[abilityId][mapName].name then
                effectName = Effects.MapDataOverride[abilityId][mapName].name
            end
            if Effects.MapDataOverride[abilityId][mapName].hide then
                return
            end
        end
    end

    -- Override name or icon based off unitName
    if Effects.EffectOverrideByName[abilityId] then
        unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, unitName)
        if Effects.EffectOverrideByName[abilityId][unitName] then
            if Effects.EffectOverrideByName[abilityId][unitName].hide then
                return
            end
            iconName = Effects.EffectOverrideByName[abilityId][unitName].icon or iconName
            effectName = Effects.EffectOverrideByName[abilityId][unitName].name or effectName
        end
    end

    -- Override icon with default if enabled
    if self.SV.UseDefaultIcon and self:ShouldUseDefaultIcon(abilityId) == true then
        iconName = self:GetDefaultIcon(Effects.EffectOverride[abilityId].cc)
    end

    local forcedType = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].forcedContainer or nil
    local savedEffectSlot = effectSlot
    effectSlot = Effects.EffectMergeId[abilityId] or Effects.EffectMergeName[effectName] or effectSlot

    -- Where the new icon will go into
    local context = unitTag .. effectType

    -- Override for Off-Balance Immunity to show it as a prominent debuff for tracking.
    if abilityId == 134599 or abilityId == 120014 then
        if context == "reticleover1" or context == "reticleover2" then
            if self.SV.PromDebuffTable[abilityId] or self.SV.PromDebuffTable[effectName] then
                context = "promd_target"
            end
        elseif context == "player1" then
            if self.SV.PromBuffTable[abilityId] or self.SV.PromBuffTable[effectName] then
                context = "promb_player"
            end
        end
    else
        -- Special handling for Bound Armaments - only show in prominent buffs if stack count >= 4
        if abilityId == 203447 and stackCount < 4 then
            -- Force context to be non-prominent if stacks are too low
            if context == "promb_player" then
                context = "player1"
            end
        end
        context = self:DetermineContext(context, abilityId, effectName, sourceType)
    end

    -- Exit here if there is no container to hold this effect
    if not self.containerRouting[context] then
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        -- delete Effect
        self.EffectsList[context][effectSlot] = nil
        if Effects.EffectCreateSkillAura[abilityId] and Effects.EffectCreateSkillAura[abilityId].removeOnEnd then
            local id = Effects.EffectCreateSkillAura[abilityId].abilityId

            local name = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
            local fakeEffectType = Effects.EffectOverride[id] and Effects.EffectOverride[id].type or effectType
            if not (self.SV.BlacklistTable[name] or self.SV.BlacklistTable[id]) then
                local simulatedContext = unitTag .. fakeEffectType
                simulatedContext = self:DetermineContext(simulatedContext, id, name, sourceType)
                self.EffectsList[simulatedContext][Effects.EffectCreateSkillAura[abilityId].abilityId] = nil
            end
        end

        -- Create Effect
    else
        local duration = endTime - beginTime
        local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false
        local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false

        if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].duration then
            if Effects.EffectOverride[abilityId].duration == 0 then
                duration = 0
            else
                duration = duration - Effects.EffectOverride[abilityId].duration
            end
            endTime = endTime - Effects.EffectOverride[abilityId].duration
        end

        if Effects.EffectPullDuration[abilityId] then
            local matchId = Effects.EffectPullDuration[abilityId]
            for i = 1, GetNumBuffs(unitTag) do
                local unitBuffInfo = { GetUnitBuffInfo(unitTag, i) }
                local timeStarted = unitBuffInfo[2]
                local timeEnding = unitBuffInfo[3]
                abilityId = unitBuffInfo[11]
                if abilityId == matchId then
                    duration = timeEnding - timeStarted
                    beginTime = timeStarted
                    endTime = timeEnding
                end
            end
        end

        -- EffectCreateSkillAura
        if Effects.EffectCreateSkillAura[abilityId] then
            if not Effects.EffectCreateSkillAura[abilityId].requiredStack or (Effects.EffectCreateSkillAura[abilityId].requiredStack and stackCount == Effects.EffectCreateSkillAura[abilityId].requiredStack) then
                local id = Effects.EffectCreateSkillAura[abilityId].abilityId
                local name = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
                local fakeEffectType = Effects.EffectOverride[id] and Effects.EffectOverride[id].type or effectType
                local fakeUnbreakable = Effects.EffectOverride[id] and Effects.EffectOverride[id].unbreakable or 0
                if not (self.SV.BlacklistTable[name] or self.SV.BlacklistTable[id]) then
                    local simulatedContext = unitTag .. fakeEffectType
                    simulatedContext = self:DetermineContext(simulatedContext, id, name, sourceType)

                    -- Create Buff
                    local icon = Effects.EffectCreateSkillAura[abilityId].icon or GetAbilityIcon(id)
                    self.EffectsList[simulatedContext][Effects.EffectCreateSkillAura[abilityId].abilityId] =
                    {
                        target = self:DetermineTarget(simulatedContext),
                        type = fakeEffectType,
                        id = id,
                        name = name,
                        icon = icon,
                        dur = 1000 * duration,
                        starts = 1000 * beginTime,
                        ends = (duration > 0) and (1000 * endTime) or nil,
                        forced = forcedType,
                        restart = true,
                        iconNum = 0,
                        stack = 0,
                        unbreakable = fakeUnbreakable,
                        groundLabel = groundLabel,
                        toggle = toggle,
                    }
                end
            end
        end

        -- If this effect doesn't properly display stacks - then add them.
        if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].displayStacks then
            for _, effectsList in pairs(self.EffectsList) do
                for _, v in pairs(effectsList) do
                    -- Add stacks
                    if v.id == abilityId then
                        stackCount = v.stack + 1
                        -- Stop stacks from going over a certain amount.
                        if stackCount > Effects.EffectOverride[abilityId].maxStacks then
                            stackCount = Effects.EffectOverride[abilityId].maxStacks
                        end
                    end
                end
            end
        end

        -- Limit stacks for certain abilities.
        if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackMax then
            if stackCount > Effects.EffectOverride[abilityId].stackMax then
                stackCount = Effects.EffectOverride[abilityId].stackMax
            end
        end

        -- Buffs are created based on their effectSlot, this allows multiple buffs/debuffs of the same type to appear.
        self.EffectsList[context][effectSlot] =
        {
            target = self:DetermineTarget(context),
            type = effectType,
            id = abilityId,
            name = effectName,
            icon = iconName,
            dur = 1000 * duration,
            starts = 1000 * beginTime,
            ends = (duration > 0) and (1000 * endTime) or nil,
            forced = forcedType,
            restart = true,
            iconNum = 0,
            stack = stackCount,
            unbreakable = unbreakable,
            buffSlot = savedEffectSlot,
            groundLabel = groundLabel,
            toggle = toggle,
        }
    end
end

-- Combat Event (Source = Player)
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
function SpellCastBuffs:OnCombatEventOut(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    -- If the ability is blacklisted
    if self.SV.BlacklistTable[abilityId] or self.SV.BlacklistTable[abilityName] then
        return
    end

    if not (Effects.FakePlayerOfflineAura[abilityId] or Effects.FakePlayerDebuffs[abilityId] or Effects.FakeStagger[abilityId] or Effects.IsGroundMineDamage[abilityId]) then
        return
    end

    -- Handling for Trap Beast
    if Effects.IsGroundMineDamage[abilityId] and sourceType == COMBAT_UNIT_TYPE_PLAYER then
        if result == ACTION_RESULT_BLOCKED or result == ACTION_RESULT_BLOCKED_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DAMAGE_SHIELDED or result == ACTION_RESULT_IMMUNE or result == ACTION_RESULT_MISS or result == ACTION_RESULT_PARTIAL_RESIST or result == ACTION_RESULT_REFLECTED or result == ACTION_RESULT_RESIST or result == ACTION_RESULT_WRECKING_DAMAGE or result == ACTION_RESULT_DODGED then
            local compareId
            if abilityId == 35754 then
                compareId = 35750
            elseif abilityId == 40389 then
                compareId = 40382
            elseif abilityId == 40376 then
                compareId = 40372
            end
            if compareId then
                -- Remove mine buff if damage is triggered
                local context = "player1" -- Default context

                -- Check if the compareId exists in FakePlayerOfflineAura before accessing its properties
                if Effects.FakePlayerOfflineAura[compareId] and Effects.FakePlayerOfflineAura[compareId].ground then
                    context = "ground"
                end

                -- Check for prominent buff/debuff settings
                if self.SV.PromDebuffTable[compareId] then
                    context = "promd_player"
                elseif self.SV.PromBuffTable[compareId] then
                    context = "promb_player"
                end

                -- Remove the effect from the appropriate context
                self.EffectsList[context][compareId] = nil
            end
        end
    end

    -- If the action result isn't a starting/ending event then we ignore it.
    if result ~= ACTION_RESULT_BEGIN and result ~= ACTION_RESULT_EFFECT_GAINED and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION and result ~= ACTION_RESULT_EFFECT_FADED then
        return
    end

    local unbreakable
    local stack
    local iconName
    local effectName
    local duration
    local effectType
    local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false

    if Effects.EffectOverride[abilityId] then
        if Effects.EffectOverride[abilityId].hideReduce and self.SV.HideReduce then
            return
        end
        unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
        stack = Effects.EffectOverride[abilityId].stack or 0
    else
        unbreakable = 0
        stack = 0
    end

    -- Fake offline auras created by the player
    if Effects.FakePlayerOfflineAura[abilityId] and sourceType == COMBAT_UNIT_TYPE_PLAYER then
        -- Bail out if we ignore begin events
        if Effects.FakePlayerOfflineAura[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakePlayerOfflineAura[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakePlayerOfflineAura[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if self.SV.HidePlayerBuffs and not (self.SV.PromDebuffTable[abilityId] or self.SV.PromDebuffTable[effectName] or self.SV.PromBuffTable[abilityId] or self.SV.PromBuffTable[effectName] or Effects.FakePlayerOfflineAura[abilityId].ground) then
            return
        end

        -- Prominent Support
        local context
        if Effects.FakePlayerOfflineAura[abilityId].ground then
            context = "ground"
        else
            context = "player1"
        end
        if self.SV.PromDebuffTable[abilityId] or self.SV.PromDebuffTable[effectName] then
            context = "promd_player"
        elseif self.SV.PromBuffTable[abilityId] or self.SV.PromBuffTable[effectName] then
            context = "promb_player"
        end

        if self.EffectsList[context][abilityId] and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackAdd then
            -- Before removing old effect, if this effect is currently present and stack is set to increment on event, then add to stack counter
            stack = self.EffectsList[context][abilityId].stack + Effects.EffectOverride[abilityId].stackAdd
        end

        self.EffectsList[context][abilityId] = nil

        local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false

        iconName = Effects.FakePlayerOfflineAura[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakePlayerOfflineAura[abilityId].name or GetAbilityName(abilityId)
        duration = Effects.FakePlayerOfflineAura[abilityId].duration
        if duration == "GET" then
            duration = GetAbilityDuration(abilityId) or 0
        end
        local finalId = Effects.FakePlayerOfflineAura[abilityId].shiftId or abilityId
        if Effects.FakePlayerOfflineAura[abilityId].shiftId then
            iconName = Effects.FakePlayerOfflineAura and Effects.FakePlayerOfflineAura[finalId].icon or GetAbilityIcon(finalId)
            effectName = Effects.FakePlayerOfflineAura and Effects.FakePlayerOfflineAura[finalId].name or GetAbilityName(finalId)
        end
        local forcedType = Effects.FakePlayerOfflineAura[abilityId].long and "long" or "short"
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        -- Pull unbreakable info from Shift Id if present
        unbreakable = Effects.EffectOverride[finalId].unbreakable or unbreakable
        if source == LUIE.PlayerNameFormatted then
            -- If the "buff" is flagged as a debuff, then display it here instead
            if Effects.FakePlayerOfflineAura[abilityId].ground == true then
                self.EffectsList[context][finalId] =
                {
                    target = self:DetermineTarget(context),
                    type = BUFF_EFFECT_TYPE_DEBUFF,
                    id = finalId,
                    name = effectName,
                    icon = iconName,
                    dur = duration,
                    starts = beginTime,
                    ends = (duration > 0) and endTime or nil,
                    forced = "short",
                    restart = true,
                    iconNum = 0,
                    unbreakable = unbreakable,
                    stack = stack,
                    groundLabel = groundLabel,
                    toggle = toggle,
                }
                -- Otherwise, display as a normal buff
            else
                self.EffectsList[context][finalId] =
                {
                    target = self:DetermineTarget(context),
                    type = 1,
                    id = finalId,
                    name = effectName,
                    icon = iconName,
                    dur = duration,
                    starts = beginTime,
                    ends = (duration > 0) and endTime or nil,
                    forced = forcedType,
                    restart = true,
                    iconNum = 0,
                    unbreakable = unbreakable,
                    stack = stack,
                    groundLabel = groundLabel,
                    toggle = toggle,
                }
            end
        end
    end

    -- Creates fake debuff icons for debuffs without an aura - These refresh on reapplication/removal (Applied on target by player)
    if Effects.FakePlayerDebuffs[abilityId] and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER) then
        -- Bail out if we ignore begin events
        if Effects.FakePlayerDebuffs[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakePlayerDebuffs[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakePlayerDebuffs[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if self.SV.HideTargetDebuffs then
            return
        end
        if not DoesUnitExist("reticleover") then
            return
        end
        -- if GetUnitReaction("reticleover") ~= UNIT_REACTION_HOSTILE then return end
        local displayName = GetDisplayName()
        local unitTag = displayName
        if IsUnitDead(unitTag) then
            return
        end
        iconName = Effects.FakePlayerDebuffs[abilityId].icon or GetAbilityIcon(abilityId)

        -- Override icon with default if enabled
        if self.SV.UseDefaultIcon and self:ShouldUseDefaultIcon(abilityId) == true then
            iconName = self:GetDefaultIcon(Effects.EffectOverride[abilityId].cc)
        end

        effectName = Effects.FakePlayerDebuffs[abilityId].name or GetAbilityName(abilityId)
        local context = "reticleover2" -- NOTE: TODO - No prominent support here and probably won't add
        duration = Effects.FakePlayerDebuffs[abilityId].duration
        local overrideDuration = Effects.FakePlayerDebuffs[abilityId].overrideDuration
        effectType = BUFF_EFFECT_TYPE_DEBUFF
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        local unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("reticleover"))
        -- if unitName ~= target then return end
        if source == LUIE.PlayerNameFormatted and target ~= nil then
            if self.SV.HideTargetDebuffs then
                return
            end
            if unitName == target then
                self.EffectsList.ground[abilityId] =
                {
                    target = self:DetermineTarget(context),
                    type = effectType,
                    id = abilityId,
                    name = effectName,
                    icon = iconName,
                    dur = duration,
                    starts = beginTime,
                    ends = (duration > 0) and endTime or nil,
                    forced = "short",
                    restart = true,
                    iconNum = 0,
                    unbreakable = unbreakable,
                    savedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName),
                    fakeDuration = overrideDuration,
                    groundLabel = groundLabel,
                }
            else
                self.EffectsList.saved[abilityId] =
                {
                    target = self:DetermineTarget(context),
                    type = effectType,
                    id = abilityId,
                    name = effectName,
                    icon = iconName,
                    dur = duration,
                    starts = beginTime,
                    ends = (duration > 0) and endTime or nil,
                    forced = "short",
                    restart = true,
                    iconNum = 0,
                    unbreakable = unbreakable,
                    savedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName),
                    fakeDuration = overrideDuration,
                    groundLabel = groundLabel,
                }
            end
        end
    end

    -- Simulates fake debuff icons for stagger effects - works for both (target -> player) and (player -> target) - DOES NOT REFRESH - Only expiration condition is the timer
    if Effects.FakeStagger[abilityId] then
        -- Bail out if we ignore begin events
        if Effects.FakeStagger[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakeStagger[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakeStagger[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if self.SV.HideTargetDebuffs then
            return
        end
        iconName = Effects.FakeStagger[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakeStagger[abilityId].name or GetAbilityName(abilityId)
        local context = "reticleover2" -- NOTE: TODO - No prominent support here and probably won't add
        duration = Effects.FakeStagger[abilityId].duration
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        local unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("reticleover"))
        if source == LUIE.PlayerNameFormatted and target ~= nil then
            if self.SV.HideTargetDebuffs then
                return
            end
            if unitName == target then
                self.EffectsList.ground[abilityId] =
                {
                    target = self:DetermineTarget(context),
                    type = BUFF_EFFECT_TYPE_DEBUFF,
                    id = abilityId,
                    name = effectName,
                    icon = iconName,
                    dur = duration,
                    starts = beginTime,
                    ends = (duration > 0) and endTime or nil,
                    forced = "short",
                    restart = true,
                    iconNum = 0,
                    unbreakable = unbreakable,
                    savedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName),
                    groundLabel = groundLabel,
                }
            else
                self.EffectsList.saved[abilityId] =
                {
                    target = self:DetermineTarget(context),
                    type = BUFF_EFFECT_TYPE_DEBUFF,
                    id = abilityId,
                    name = effectName,
                    icon = iconName,
                    dur = duration,
                    starts = beginTime,
                    ends = (duration > 0) and endTime or nil,
                    forced = "short",
                    restart = true,
                    iconNum = 0,
                    unbreakable = unbreakable,
                    savedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName),
                    groundLabel = groundLabel,
                }
            end
        end
    end
end

-- Combat Event (Target = Player)
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
function SpellCastBuffs:OnCombatEventIn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not (Effects.FakeExternalBuffs[abilityId] or Effects.FakeExternalDebuffs[abilityId] or Effects.FakePlayerBuffs[abilityId] or Effects.FakeStagger[abilityId] or Effects.AddGroundDamageAura[abilityId]) then
        return
    end

    -- If the ability is blacklisted
    if self.SV.BlacklistTable[abilityId] or self.SV.BlacklistTable[abilityName] then
        return
    end

    -- Create ground auras for damaging effects if toggled on
    if self.SV.GroundDamageAura and Effects.AddGroundDamageAura[abilityId] then
        -- Return if this isn't damage or healing, or blocked, dodged, or shielded.
        if result ~= ACTION_RESULT_DAMAGE and result ~= ACTION_RESULT_DAMAGE_SHIELDED and result ~= ACTION_RESULT_DODGED and result ~= ACTION_RESULT_CRITICAL_DAMAGE and result ~= ACTION_RESULT_CRITICAL_HEAL and result ~= ACTION_RESULT_HEAL and result ~= ACTION_RESULT_BLOCKED and result ~= ACTION_RESULT_BLOCKED_DAMAGE and result ~= ACTION_RESULT_HOT_TICK and result ~= ACTION_RESULT_HOT_TICK_CRITICAL and result ~= ACTION_RESULT_DOT_TICK and result ~= ACTION_RESULT_DOT_TICK_CRITICAL and not Effects.AddGroundDamageAura[abilityId].exception then
            return
        end

        -- Only allow exceptions through if flagged as such
        if Effects.AddGroundDamageAura[abilityId].exception and result ~= Effects.AddGroundDamageAura[abilityId].exception then
            return
        end

        local stack
        local iconName = GetAbilityIcon(abilityId)
        local effectName
        local unbreakable
        local duration = Effects.AddGroundDamageAura[abilityId].duration
        local effectType = Effects.AddGroundDamageAura[abilityId].type
        local buffSlot
        local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false
        local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false

        if Effects.EffectOverride[abilityId] then
            effectName = Effects.EffectOverride[abilityId].name or abilityName
            unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
            stack = Effects.EffectOverride[abilityId].stack or 0
        else
            effectName = abilityName
            unbreakable = 0
            stack = 0
        end

        -- Override name, icon, or hide based on MapZoneIndex
        if Effects.ZoneDataOverride[abilityId] then
            local index = GetZoneId(GetCurrentMapZoneIndex())
            local zoneName = GetPlayerLocationName()
            if Effects.ZoneDataOverride[abilityId][index] then
                if Effects.ZoneDataOverride[abilityId][index].icon then
                    iconName = Effects.ZoneDataOverride[abilityId][index].icon
                end
                if Effects.ZoneDataOverride[abilityId][index].name then
                    effectName = Effects.ZoneDataOverride[abilityId][index].name
                end
                if Effects.ZoneDataOverride[abilityId][index].hide then
                    return
                end
            end
            if Effects.ZoneDataOverride[abilityId][zoneName] then
                if Effects.ZoneDataOverride[abilityId][zoneName].icon then
                    iconName = Effects.ZoneDataOverride[abilityId][zoneName].icon
                end
                if Effects.ZoneDataOverride[abilityId][zoneName].name then
                    effectName = Effects.ZoneDataOverride[abilityId][zoneName].name
                end
                if Effects.ZoneDataOverride[abilityId][zoneName].hide then
                    return
                end
            end
        end

        -- Override name, icon, or hide based on Map Name
        if Effects.MapDataOverride[abilityId] then
            local mapName = GetMapName()
            if Effects.MapDataOverride[abilityId][mapName] then
                if Effects.MapDataOverride[abilityId][mapName].icon then
                    iconName = Effects.MapDataOverride[abilityId][mapName].icon
                end
                if Effects.MapDataOverride[abilityId][mapName].name then
                    effectName = Effects.MapDataOverride[abilityId][mapName].name
                end
                if Effects.MapDataOverride[abilityId][mapName].hide then
                    return
                end
            end
        end

        -- Override name or icon based off unitName
        if Effects.EffectOverrideByName[abilityId] then
            local unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
            if Effects.EffectOverrideByName[abilityId][unitName] then
                if Effects.EffectOverrideByName[abilityId][unitName].hide then
                    if Effects.EffectOverrideByName[abilityId][unitName].zone then
                        local zones = Effects.EffectOverrideByName[abilityId][unitName].zone
                        local index = GetZoneId(GetCurrentMapZoneIndex())
                        for k, v in pairs(zones) do
                            -- d(k)
                            -- d(index)
                            if k == index then
                                return
                            end
                        end
                    else
                        return
                    end
                end
                iconName = Effects.EffectOverrideByName[abilityId][unitName].icon or iconName
                effectName = Effects.EffectOverrideByName[abilityId][unitName].name or effectName
            end
        end

        if Effects.AddGroundDamageAura[abilityId].merge then
            buffSlot = "GroundDamageAura" .. tostring(Effects.AddGroundDamageAura[abilityId].merge)
        else
            buffSlot = abilityId
        end

        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local context = "player" .. effectType

        -- Stack Resolution
        if self.EffectsList[context][buffSlot] and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackAdd then
            if Effects.EffectOverride[abilityId].stackMax then
                if not (self.EffectsList[context][buffSlot].stack == Effects.EffectOverride[abilityId].stackMax) then
                    stack = self.EffectsList[context][buffSlot].stack + Effects.EffectOverride[abilityId].stackAdd
                else
                    stack = self.EffectsList[context][buffSlot].stack
                end
            else
                stack = self.EffectsList[context][buffSlot].stack + Effects.EffectOverride[abilityId].stackAdd
            end
        end

        -- TODO: May need to update this to support prominent
        self.EffectsList[context][buffSlot] =
        {
            target = self:DetermineTarget(context),
            type = effectType,
            id = abilityId,
            name = effectName,
            icon = iconName,
            dur = duration,
            starts = beginTime,
            ends = (duration > 0) and endTime or nil,
            forced = "short",
            restart = true,
            iconNum = 0,
            unbreakable = unbreakable,
            fakeDuration = true,
            groundLabel = groundLabel,
            toggle = toggle,
            stack = stack,
        }
    end

    -- Special handling for Crystallized Shield + Morphs
    if abilityId == 86135 or abilityId == 86139 or abilityId == 86143 then
        if result == ACTION_RESULT_DAMAGE_SHIELDED then
            local context = "player1"
            local effectName = Effects.EffectOverrideByName[abilityId]
            context = self:DetermineContext(context, abilityId, effectName)

            if self.EffectsList[context][abilityId] then
                self.EffectsList[context][abilityId].stack = self.EffectsList[context][abilityId].stack - 1
                if self.EffectsList[context][abilityId].stack == 0 then
                    self.EffectsList[context][abilityId] = nil
                end
            end
        end
    end

    -- If the action result isn't a starting/ending event then we ignore it.
    if result ~= ACTION_RESULT_BEGIN and result ~= ACTION_RESULT_EFFECT_GAINED and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION and result ~= ACTION_RESULT_EFFECT_FADED then
        return
    end

    -- Toggled on when we need to ignore double events from some ids
    if self.ignoreAbilityId[abilityId] then
        self.ignoreAbilityId[abilityId] = nil
        return
    end

    local unbreakable
    local stack
    local internalStack
    local iconName
    local effectName
    local duration
    local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false

    if Effects.EffectOverride[abilityId] then
        if Effects.EffectOverride[abilityId].hideReduce and self.SV.HideReduce then
            return
        end
        unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
        stack = Effects.EffectOverride[abilityId].stack or 0
        internalStack = Effects.EffectOverride[abilityId].internalStack or nil
    else
        unbreakable = 0
        stack = 0
        internalStack = nil
    end

    -- Creates fake buff icons for buffs without an aura - These refresh on reapplication/removal (Applied on player by target)
    if Effects.FakeExternalBuffs[abilityId] and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER) then
        -- Bail out if we ignore begin events
        if Effects.FakeExternalBuffs[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakeExternalBuffs[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakeExternalBuffs[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if self.SV.HidePlayerBuffs then
            return
        end

        iconName = Effects.FakeExternalBuffs[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakeExternalBuffs[abilityId].name or GetAbilityName(abilityId)
        local context = self:DetermineContextSimple("player1", abilityId, effectName)
        self.EffectsList[context][abilityId] = nil
        local overrideDuration = Effects.FakeExternalBuffs[abilityId].overrideDuration
        duration = Effects.FakeExternalBuffs[abilityId].duration
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        if source ~= "" and target == LUIE.PlayerNameFormatted then
            self.EffectsList[context][abilityId] =
            {
                target = self:DetermineTarget(context),
                type = 1,
                id = abilityId,
                name = effectName,
                icon = iconName,
                dur = duration,
                starts = beginTime,
                ends = (duration > 0) and endTime or nil,
                forced = "short",
                restart = true,
                iconNum = 0,
                unbreakable = unbreakable,
                fakeDuration = overrideDuration,
                groundLabel = groundLabel,
            }
        end
    end

    -- Creates fake debuff icons for debuffs without an aura - These refresh on reapplication/removal (Applied on player by target)
    if Effects.FakeExternalDebuffs[abilityId] and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER) then
        -- Bail out if we ignore begin events
        if Effects.FakeExternalDebuffs[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakeExternalDebuffs[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakeExternalDebuffs[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if self.SV.HidePlayerDebuffs then
            return
        end
        -- Bail out if we hide ground snares/etc to replace them with auras for damage
        if self.SV.GroundDamageAura and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].hideGround then
            return
        end

        local context = "player2"

        -- Stack handling
        if self.EffectsList[context][abilityId] and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackAdd then
            -- Before removing old effect, if this effect is currently present and stack is set to increment on event, then add to stack counter
            if Effects.EffectOverride[abilityId].stackMax then
                if not (self.EffectsList[context][abilityId].stack == Effects.EffectOverride[abilityId].stackMax) then
                    stack = self.EffectsList[context][abilityId].stack + Effects.EffectOverride[abilityId].stackAdd
                else
                    stack = self.EffectsList[context][abilityId].stack
                end
            else
                stack = self.EffectsList[context][abilityId].stack + Effects.EffectOverride[abilityId].stackAdd
            end
        end

        if internalStack then
            if not self.InternalStackCounter[abilityId] then
                self.InternalStackCounter[abilityId] = 0
            end -- Create stack if it doesn't exist
            if result == ACTION_RESULT_EFFECT_FADED then
                self.InternalStackCounter[abilityId] = self.InternalStackCounter[abilityId] - 1
            elseif result == ACTION_RESULT_EFFECT_GAINED_DURATION then
                self.InternalStackCounter[abilityId] = self.InternalStackCounter[abilityId] + 1
            end
            if self.EffectsList[context][abilityId] then
                if self.InternalStackCounter[abilityId] <= 0 then
                    self.EffectsList[context][abilityId] = nil
                    self.InternalStackCounter[abilityId] = nil
                end
            end
        else
            self.EffectsList[context][abilityId] = nil
        end

        iconName = Effects.FakeExternalDebuffs[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakeExternalDebuffs[abilityId].name or GetAbilityName(abilityId)
        duration = Effects.FakeExternalDebuffs[abilityId].duration
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)

        if Effects.ZoneDataOverride[abilityId] then
            local index = GetZoneId(GetCurrentMapZoneIndex())
            local zoneName = GetPlayerLocationName()
            if Effects.ZoneDataOverride[abilityId][index] then
                if Effects.ZoneDataOverride[abilityId][index].icon then
                    iconName = Effects.ZoneDataOverride[abilityId][index].icon
                end
                if Effects.ZoneDataOverride[abilityId][index].name then
                    effectName = Effects.ZoneDataOverride[abilityId][index].name
                end
                if Effects.ZoneDataOverride[abilityId][index].hide then
                    return
                end
            end
            if Effects.ZoneDataOverride[abilityId][zoneName] then
                if Effects.ZoneDataOverride[abilityId][zoneName].icon then
                    iconName = Effects.ZoneDataOverride[abilityId][zoneName].icon
                end
                if Effects.ZoneDataOverride[abilityId][zoneName].name then
                    effectName = Effects.ZoneDataOverride[abilityId][zoneName].name
                end
                if Effects.ZoneDataOverride[abilityId][zoneName].hide then
                    return
                end
            end
        end

        -- Override name, icon, or hide based on Map Name
        if Effects.MapDataOverride[abilityId] then
            local mapName = GetMapName()
            if Effects.MapDataOverride[abilityId][mapName] then
                if Effects.MapDataOverride[abilityId][mapName].icon then
                    iconName = Effects.MapDataOverride[abilityId][mapName].icon
                end
                if Effects.MapDataOverride[abilityId][mapName].name then
                    effectName = Effects.MapDataOverride[abilityId][mapName].name
                end
                if Effects.MapDataOverride[abilityId][mapName].hide then
                    return
                end
            end
        end

        -- Override icon with default if enabled
        if self.SV.UseDefaultIcon and self:ShouldUseDefaultIcon(abilityId) == true then
            iconName = self:GetDefaultIcon(Effects.EffectOverride[abilityId].cc)
        end

        -- TODO: Temp - converts icon for Helljoint, might be other abilities that need this in the future
        if abilityId == 14523 then
            if source == "Jackal" then
                iconName = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_JACKAL_HELLJOINT_DDS
            end
        end

        if source ~= "" and target == LUIE.PlayerNameFormatted then
            self.EffectsList[context][abilityId] =
            {
                target = self:DetermineTarget(context),
                type = BUFF_EFFECT_TYPE_DEBUFF,
                id = abilityId,
                name = effectName,
                icon = iconName,
                dur = duration,
                starts = beginTime,
                ends = (duration > 0) and endTime or nil,
                forced = "short",
                restart = true,
                iconNum = 0,
                unbreakable = unbreakable,
                groundLabel = groundLabel,
                stack = stack,
            }
        end
    end

    -- Creates fake buff icons for buffs without an aura - These refresh on reapplication/removal (Applied on player by player)
    if Effects.FakePlayerBuffs[abilityId] and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER) then
        -- Bail out if we ignore begin events
        if Effects.FakePlayerBuffs[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakePlayerBuffs[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakePlayerBuffs[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if self.SV.HidePlayerBuffs and not (self.SV.PromDebuffTable[abilityId] or self.SV.PromDebuffTable[effectName] or self.SV.PromBuffTable[abilityId] or self.SV.PromBuffTable[effectName]) then
            return
        end
        if Effects.FakePlayerBuffs[abilityId].onlyExtra and not self.SV.ExtraBuffs then
            return
        end
        if Effects.FakePlayerBuffs[abilityId].onlyExtended and not (self.SV.ExtraBuffs and self.SV.ExtraExpanded) then
            return
        end

        -- If this is a fake set ICD then don't display if we have Set ICD's disabled.
        if Effects.IsSetICD[abilityId] and self.SV.IgnoreSetICDPlayer then
            return
        end
        -- If this is an ability ICD then don't display if we have Ability ICD's disabled.
        if Effects.IsAbilityICD[abilityId] and self.SV.IgnoreAbilityICDPlayer then
            return
        end

        -- Prominent Support
        local effectType = Effects.FakePlayerBuffs[abilityId].debuff and BUFF_EFFECT_TYPE_DEBUFF or BUFF_EFFECT_TYPE_BUFF -- TODO: Expand this for below instead of calling again
        local context = "player" .. effectType

        if self.EffectsList[context][abilityId] and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackAdd then
            -- Before removing old effect, if this effect is currently present and stack is set to increment on event, then add to stack counter
            stack = self.EffectsList[context][abilityId].stack + Effects.EffectOverride[abilityId].stackAdd
        end
        if abilityId == 26406 then
            self.ignoreAbilityId[abilityId] = true
        end

        local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false

        iconName = Effects.FakePlayerBuffs[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakePlayerBuffs[abilityId].name or GetAbilityName(abilityId)
        duration = Effects.FakePlayerBuffs[abilityId].duration
        if duration == "GET" then
            duration = GetAbilityDuration(abilityId) or 0
        end
        local finalId = Effects.FakePlayerBuffs[abilityId].shiftId or abilityId
        if Effects.FakePlayerBuffs[abilityId].shiftId then
            iconName = Effects.FakePlayerBuffs[finalId] and Effects.FakePlayerBuffs[finalId].icon or GetAbilityIcon(finalId)
            effectName = Effects.FakePlayerBuffs[finalId] and Effects.FakePlayerBuffs[finalId].name or GetAbilityName(finalId)
        end
        -- TODO: Do we want to enable self debuffs from this to show as prominent (ICD for sets for example?)
        context = self:DetermineContextSimple(context, finalId, effectName)
        self.EffectsList[context][finalId] = nil
        local forcedType = Effects.FakePlayerBuffs[abilityId].long and "long" or "short"
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        -- Pull unbreakable info from Shift Id if present
        unbreakable = (Effects.EffectOverride[finalId] and Effects.EffectOverride[finalId].unbreakable) or unbreakable
        if source == LUIE.PlayerNameFormatted and target == LUIE.PlayerNameFormatted then
            self.EffectsList[context][finalId] =
            {
                target = self:DetermineTarget(context),
                type = effectType,
                id = finalId,
                name = effectName,
                icon = iconName,
                dur = duration,
                starts = beginTime,
                ends = (duration > 0) and endTime or nil,
                forced = forcedType,
                restart = true,
                iconNum = 0,
                unbreakable = unbreakable,
                stack = stack,
                groundLabel = groundLabel,
                toggle = toggle,
            }
        end
    end

    -- Simulates fake debuff icons for stagger effects - works for both (target -> player) and (player -> target) - DOES NOT REFRESH - Only expiration condition is the timer
    if Effects.FakeStagger[abilityId] then
        -- Bail out if we ignore begin events
        if Effects.FakeStagger[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakeStagger[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakeStagger[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if self.SV.HidePlayerDebuffs then
            return
        end
        iconName = Effects.FakeStagger[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakeStagger[abilityId].name or GetAbilityName(abilityId)
        duration = Effects.FakeStagger[abilityId].duration
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        local unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("reticleover"))
        local context = "player2"
        if source ~= "" and target == LUIE.PlayerNameFormatted then
            self.EffectsList[context][abilityId] =
            {
                target = self:DetermineTarget(context),
                type = BUFF_EFFECT_TYPE_DEBUFF,
                id = abilityId,
                name = effectName,
                icon = iconName,
                dur = duration,
                starts = beginTime,
                ends = (duration > 0) and endTime or nil,
                forced = "short",
                restart = true,
                iconNum = 0,
                unbreakable = unbreakable,
                groundLabel = groundLabel,
            }
        end
    end
end

--[[
 * Runs on the EVENT_COMBAT_EVENT listener.
 * This handler fires every time ANY combat activity happens. Very-very often.
 * We use it to remove mines from active target debuffs
 * As well as create fake buffs/debuffs for events with no active effect present.
 ]]
--


-- Combat Event - Add Name Aura to Target
--- - **EVENT_COMBAT_EVENT **
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
function SpellCastBuffs:OnCombatAddNameEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Get the name of the target to apply the buff to
    local name = Effects.AddNameOnEvent[abilityId].name
    local id = Effects.AddNameOnEvent[abilityId].id
    -- Bail out if we have no name
    if not name then
        return
    end

    -- NOTE: We may eventually need to iterate here, for the time being though we can just relatively reliably put this in slot 2 since slot 1 should be CC Immunity.
    -- NOTE: We may eventually add a function handler to do other things, like make certain abilities change their CC types etc like the example below.
    if Effects.AddNameAura[name] then
        if result == ACTION_RESULT_EFFECT_GAINED then
            -- Get stack value if its saved.
            local stack = Effects.AddNameAura[name][2] and Effects.AddNameAura[name][2].stack
            Effects.AddNameAura[name][2] = {}
            Effects.AddNameAura[name][2].id = id
            if Effects.AddStackOnEvent[abilityId] then
                if stack then
                    Effects.AddNameAura[name][2].stack = stack + 1
                else
                    Effects.AddNameAura[name][2].stack = Effects.AddStackOnEvent[abilityId]
                end
            end
            -- Specific to Crypt of Hearts I (Ignite Colossus)
            if id == 46680 then
                AlertTable[22527].cc = LUIE_CC_TYPE_UNBREAKABLE
                AlertTable[22527].block = nil
                AlertTable[22527].dodge = nil
                AlertTable[22527].avoid = true
            end
        elseif result == ACTION_RESULT_EFFECT_FADED then
            -- Check to make sure the current added aura here is the same id. If something else overrides the previous one we don't need to worry about removing the previous one.
            if Effects.AddNameAura[name] and Effects.AddNameAura[name][2] and Effects.AddNameAura[name][2].id == id then
                Effects.AddNameAura[name][2] = nil
                -- Specific to Crypt of Hearts I (Ignite Colossus)
                if id == 46680 then
                    AlertTable[22527].cc = nil
                    AlertTable[22527].block = true
                    AlertTable[22527].dodge = true
                    AlertTable[22527].avoid = false
                end
            end
        end

        -- Reload Effects on current target
        if not self.SV.HideTargetBuffs then
            self:AddNameAura()
        end
    end
end

-- g_currentDuelTarget is now an instance property

-- EVENT_DUEL_STARTED handler for creating Battle Spirit Icon on Target
--- @param eventId integer|nil
function SpellCastBuffs:DuelStart(eventId)
    local duelState, characterName = GetDuelInfo()
    if duelState == 3 and not self.SV.HideTargetBuffs and not self.SV.IgnoreBattleSpiritTarget then
        self.g_currentDuelTarget = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, characterName)
        self:ReloadEffects("reticleover")
    end
end

-- EVENT_DUEL_FINISHED handler for removing Battle Spirit Icon on Target
--- @param eventId integer
--- @param duelResult DuelResult
--- @param wasLocalPlayersResult boolean
--- @param opponentCharacterName string
--- @param opponentDisplayName string
--- @param opponentAlliance Alliance
--- @param opponentGender Gender
--- @param opponentClassId integer
--- @param opponentRaceId integer
function SpellCastBuffs:DuelEnd(eventId, duelResult, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName, opponentAlliance, opponentGender, opponentClassId, opponentRaceId)
    self.g_currentDuelTarget = nil
    self:ReloadEffects("reticleover")
end

-- Called by SpellCastBuffs.ReloadEffects(unitTag) from the EVENT_RETICLE_TARGET_CHANGED handler
function SpellCastBuffs:LoadBattleSpiritTarget()
    -- Return if we don't have Battle Spirit enabled for Target
    if self.SV.IgnoreBattleSpiritTarget then
        return
    end

    -- Create Battle Spirit Buff if we are in a PVP zone or this is our current Duel Target
    if (LUIE.ResolvePVPZone() and IsUnitPlayer("reticleover") and (GetUnitReaction("reticleover") == UNIT_REACTION_PLAYER_ALLY)) or GetUnitName("reticleover") == self.g_currentDuelTarget then
        local abilityId = 999014
        local tooltip
        -- Imperial City version of battle spirit doesn't extend the range of our abilities, unlike the variant used for Cyrodiil, Duels, and BGs.
        if IsInImperialCity() then
            tooltip = Tooltips.Innate_Battle_Spirit_Imperial_City
        else
            tooltip = Tooltips.Innate_Battle_Spirit
        end
        self.EffectsList["reticleover1"][abilityId] =
        {
            type = 1,
            id = abilityId,
            name = Abilities.Skill_Battle_Spirit,
            icon = "/esoui/art/icons/artificialeffect_battle-spirit.dds",
            tooltip = tooltip,
            dur = 0,
            starts = 1,
            ends = nil,
            forced = "short",
            restart = true,
            iconNum = 0,
        }
    end
end

local chatSystem = ZO_GetChatSystem()

-- Bulk list add from menu buttons
function SpellCastBuffs:AddBulkToCustomList(list, table)
    if table ~= nil then
        for k, v in pairs(table) do
            self:AddToCustomList(list, k)
        end
    end
end

function SpellCastBuffs:ClearCustomList(list)
    local listRef =
        list == self.SV.PromBuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS) or
        list == self.SV.PromDebuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS) or
        list == self.SV.PriorityBuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS) or
        list == self.SV.PriorityDebuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS) or
        list == self.SV.BlacklistTable and GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST) or
        list == self.SV.GroupTrackedBuffs and GetString(LUIE_STRING_CUSTOM_LIST_GROUP_BUFFS) or
        list == self.SV.GroupTrackedDebuffs and GetString(LUIE_STRING_CUSTOM_LIST_GROUP_DEBUFFS)
    for k, v in pairs(list) do
        list[k] = nil
    end
    chatSystem:Maximize()
    chatSystem.primaryContainer:FadeIn()
    PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
    self:ReloadEffects("player")
end

-- List Handling (Add) for Prominent Auras & Blacklist
function SpellCastBuffs:AddToCustomList(list, input)
    local id = tonumber(input)
    local listRef =
        list == self.SV.PromBuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS) or
        list == self.SV.PromDebuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS) or
        list == self.SV.PriorityBuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS) or
        list == self.SV.PriorityDebuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS) or
        list == self.SV.BlacklistTable and GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST) or
        list == self.SV.GroupTrackedBuffs and GetString(LUIE_STRING_CUSTOM_LIST_GROUP_BUFFS) or
        list == self.SV.GroupTrackedDebuffs and GetString(LUIE_STRING_CUSTOM_LIST_GROUP_DEBUFFS)
    if id and id > 0 then
        local name = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
        if name ~= nil and name ~= "" then
            local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
            list[id] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), icon, id, name, listRef), true)
        else
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, listRef), true)
        end
    else
        if input ~= "" then
            list[input] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
        end
    end
    self:ReloadEffects("player")
end

-- List Handling (Remove) for Prominent Auras & Blacklist
function SpellCastBuffs:RemoveFromCustomList(list, input)
    local id = tonumber(input)
    local listRef =
        list == self.SV.PromBuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS) or
        list == self.SV.PromDebuffTable and GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS) or
        list == self.SV.PriorityBuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS) or
        list == self.SV.PriorityDebuffTable and GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS) or
        list == self.SV.BlacklistTable and GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST) or
        list == self.SV.GroupTrackedBuffs and GetString(LUIE_STRING_CUSTOM_LIST_GROUP_BUFFS)
    if id and id > 0 then
        local name = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
        local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
        list[id] = nil
        chatSystem:Maximize()
        chatSystem.primaryContainer:FadeIn()
        PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), icon, id, name, listRef), true)
    else
        if input ~= "" then
            list[input] = nil
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
        end
    end
    self:ReloadEffects("player")
end

-- Helper to get current list and check if buff is in list
function SpellCastBuffs:GetCurrentList()
    if self.SV.ListMode == "whitelist" then
        return self.SV.WhitelistTable
    else
        return self.SV.BlacklistTable
    end
end

---
--- @param abilityId integer
--- @param abilityName string
--- @return table<integer|string> list
function SpellCastBuffs:IsBuffListed(abilityId, abilityName)
    local list = self:GetCurrentList()
    return list[abilityId] or list[abilityName]
end

-- Called from the menu and on initialize to build the table of hidden effects.
function SpellCastBuffs:UpdateContextHideList()
    ZO_ClearTable(self.hidePlayerEffects)
    ZO_ClearTable(self.hideTargetEffects)

    -- Hide Warden Crystallized Shield & morphs from effects on the player (we use fake buffs to track this so that the stack count can be displayed)
    self.hidePlayerEffects[86135] = true
    self.hidePlayerEffects[86139] = true
    self.hidePlayerEffects[86143] = true

    if self.SV.IgnoreMundusPlayer then
        for k, v in pairs(Effects.IsBoon) do
            self.hidePlayerEffects[k] = v
        end
    end
    if self.SV.IgnoreMundusTarget then
        for k, v in pairs(Effects.IsBoon) do
            self.hideTargetEffects[k] = v
        end
    end
    if self.SV.IgnoreVampPlayer then
        for k, v in pairs(Effects.IsVamp) do
            self.hidePlayerEffects[k] = v
        end
    end
    if self.SV.IgnoreVampTarget then
        for k, v in pairs(Effects.IsVamp) do
            self.hideTargetEffects[k] = v
        end
    end
    if self.SV.IgnoreLycanPlayer then
        for k, v in pairs(Effects.IsLycan) do
            self.hidePlayerEffects[k] = v
        end
    end
    if self.SV.IgnoreLycanTarget then
        for k, v in pairs(Effects.IsLycan) do
            self.hideTargetEffects[k] = v
        end
    end
    if self.SV.IgnoreDiseasePlayer then
        for k, v in pairs(Effects.IsVampLycanDisease) do
            self.hidePlayerEffects[k] = v
        end
    end
    if self.SV.IgnoreDiseaseTarget then
        for k, v in pairs(Effects.IsVampLycanDisease) do
            self.hideTargetEffects[k] = v
        end
    end
    if self.SV.IgnoreBitePlayer then
        for k, v in pairs(Effects.IsVampLycanBite) do
            self.hidePlayerEffects[k] = v
        end
    end
    if self.SV.IgnoreBiteTarget then
        for k, v in pairs(Effects.IsVampLycanBite) do
            self.hideTargetEffects[k] = v
        end
    end
    if self.SV.IgnoreCyrodiilPlayer then
        for k, v in pairs(Effects.IsCyrodiil) do
            self.hidePlayerEffects[k] = v
        end
    end
    if self.SV.IgnoreCyrodiilTarget then
        for k, v in pairs(Effects.IsCyrodiil) do
            self.hideTargetEffects[k] = v
        end
    end
    if self.SV.IgnoreEsoPlusPlayer then
        self.hidePlayerEffects[63601] = true
    end
    if self.SV.IgnoreEsoPlusTarget then
        self.hideTargetEffects[63601] = true
    end
    if self.SV.IgnoreSoulSummonsPlayer then
        for k, v in pairs(Effects.IsSoulSummons) do
            self.hidePlayerEffects[k] = v
        end
    end
    if self.SV.IgnoreSoulSummonsTarget then
        for k, v in pairs(Effects.IsSoulSummons) do
            self.hideTargetEffects[k] = v
        end
    end
    if self.SV.IgnoreFoodPlayer then
        for k, v in pairs(Effects.IsFoodBuff) do
            self.hidePlayerEffects[k] = v
        end
        for k, v in pairs(Effects.IsDrinkBuff) do
            self.hidePlayerEffects[k] = v
        end
    end
    if self.SV.IgnoreFoodTarget then
        for k, v in pairs(Effects.IsFoodBuff) do
            self.hideTargetEffects[k] = v
        end
        for k, v in pairs(Effects.IsDrinkBuff) do
            self.hideTargetEffects[k] = v
        end
    end
    if self.SV.IgnoreExperiencePlayer then
        for k, v in pairs(Effects.IsExperienceBuff) do
            self.hidePlayerEffects[k] = v
        end
    end
    if self.SV.IgnoreExperienceTarget then
        for k, v in pairs(Effects.IsExperienceBuff) do
            self.hideTargetEffects[k] = v
        end
    end
    if self.SV.IgnoreAllianceXPPlayer then
        for k, v in pairs(Effects.IsAllianceXPBuff) do
            self.hidePlayerEffects[k] = v
        end
    end
    if self.SV.IgnoreAllianceXPTarget then
        for k, v in pairs(Effects.IsAllianceXPBuff) do
            self.hideTargetEffects[k] = v
        end
    end
    if not self.SV.ShowBlockPlayer then
        for k, v in pairs(Effects.IsBlock) do
            self.hidePlayerEffects[k] = v
        end
    end
    if not self.SV.ShowBlockTarget then
        for k, v in pairs(Effects.IsBlock) do
            self.hideTargetEffects[k] = v
        end
    end
end

-- Called from the menu and on initialize to build the table of effects we should show regardless of source (by id).
function SpellCastBuffs:UpdateDisplayOverrideIdList()
    -- Clear the list
    ZO_ClearTable(self.debuffDisplayOverrideId)

    -- Add effects from table if enabled
    if self.SV.ShowSharedEffects then
        for k, v in pairs(Effects.DebuffDisplayOverrideId) do
            self.debuffDisplayOverrideId[k] = v
        end
    end

    -- Always show NPC self applied debuffs
    for k, v in pairs(Effects.DebuffDisplayOverrideIdAlways) do
        self.debuffDisplayOverrideId[k] = v
    end

    -- Major/Minor
    if self.SV.ShowSharedMajorMinor then
        for k, v in pairs(Effects.DebuffDisplayOverrideMajorMinor) do
            self.debuffDisplayOverrideId[k] = v
        end
    end
end

---
--- Determines the container context for prominent effects based on the current context, ability, and caster.
--- @param context SpellCastBuffsContext The current context identifier (e.g., "player1", "reticleover2").
--- @param abilityId number|nil The ability ID to check for prominence (can be nil).
--- @param abilityName string|nil The ability name to check for prominence (can be nil).
--- @param castByPlayer number|nil The unit type of the caster (e.g., COMBAT_UNIT_TYPE_PLAYER, can be nil).
--- @return string context The resolved context string (e.g., "promd_player", "promb_target", or original context).
function SpellCastBuffs:DetermineContext(context, abilityId, abilityName, castByPlayer)
    if self.SV.PromDebuffTable[abilityId] or self.SV.PromDebuffTable[abilityName] then
        if context == "player1" then
            context = "promd_player"
        elseif context == "reticleover2" and castByPlayer == COMBAT_UNIT_TYPE_PLAYER then
            context = "promd_target"
        end
    elseif self.SV.PromBuffTable[abilityId] or self.SV.PromBuffTable[abilityName] then
        if context == "player1" then
            context = "promb_player"
        elseif context == "reticleover2" and castByPlayer == COMBAT_UNIT_TYPE_PLAYER then
            context = "promb_target"
        end
    end
    return context
end

---
--- Determines the container context for prominent effects for player-only effects.
--- Used for effects that will never be a debuff cast by the player (e.g., disguise/stealth state, collectible buffs).
--- @param context SpellCastBuffsContext The current context identifier (should be "player1").
--- @param abilityId number|nil The ability ID to check for prominence (can be nil).
--- @param abilityName string|nil The ability name to check for prominence (can be nil).
--- @return string context The resolved context string (e.g., "promd_player", "promb_player", or original context).
function SpellCastBuffs:DetermineContextSimple(context, abilityId, abilityName)
    if context == "player1" then
        if self.SV.PromDebuffTable[abilityId] or self.SV.PromDebuffTable[abilityName] then
            context = "promd_player"
        elseif self.SV.PromBuffTable[abilityId] or self.SV.PromBuffTable[abilityName] then
            context = "promb_player"
        end
    end
    return context
end

---
--- Determines the target type for buff sorting based on the context string.
--- @param context SpellCastBuffsContext The context identifier (e.g., "player1", "reticleover1", "ground").
--- @return string|"player"|"reticleover"|"prominent" target The resolved target type: "player", "reticleover", or "prominent".
function SpellCastBuffs:DetermineTarget(context)
    if context == "player1" or context == "player2" then
        return "player"
    elseif context == "reticleover1" or context == "reticleover2" or context == "ground" or context == "saved" then
        return "reticleover"
    else
        return "prominent"
    end
end

local AssistantIcons = Effects.AssistantIcons

-- Called by SpellCastBuffs.MountStatus to display mount icon
function SpellCastBuffs:DisplayMountIcon()
    --[[
        -- Target support is not implemented

        -- Bail out if somehow a non-player/target unitTag gets passed here
        if unitTag ~= "player" and unitTag ~= "reticleover" then
            return
        end

        -- Bail out if we have target mount hidden (we check for target buffs being disabled in the reticleover function that calls this function)
        if unitTag == "reticleover" and self.SV.IgnoreMountTarget then
            return
        end
    ]]
    --

    -- Check mounted state
    local name = GetRawUnitName("player")
    local mountedState = GetTargetMountedStateInfo(name)

    if mountedState == MOUNTED_STATE_MOUNT_RIDER or mountedState == MOUNTED_STATE_MOUNT_PASSENGER then
        local description
        local icon
        if mountedState == MOUNTED_STATE_MOUNT_RIDER then
            if self.SV.MountDetail then
                -- Get detailed collectible information for the player
                local collectible = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
                local nickname = GetCollectibleNickname(collectible)
                name, description, icon = GetCollectibleInfo(collectible)

                -- Add the nickname into the name if present
                if nickname ~= "" and nickname ~= nil then
                    name = zo_strformat(GetString(SI_COLLECTIBLE_NAME_WITH_NICKNAME_FORMATTER), name, nickname)
                end
            else
                name = Abilities.Innate_Mounted
                description = Tooltips.Innate_Mounted
                icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_MOUNTED_DDS
            end
        elseif mountedState == MOUNTED_STATE_MOUNT_PASSENGER then
            name = Abilities.Innate_Mounted_Passenger
            description = Tooltips.Innate_Mounted_Passenger
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_MOUNTED_DDS
        end

        local abilityId = 999017
        local abilityName = Abilities.Innate_Mounted
        local context = self:DetermineContextSimple("player1", abilityId, abilityName)
        self.EffectsList[context][abilityId] =
        {
            target = self:DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = name,
            icon = icon,
            backdrop = true,
            tooltip = description,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "long",
            restart = true,
            iconNum = 0,
        }
    end
end

--- - Handler to create Mount Buff icon for player.
--- - **EVENT_MOUNTED_STATE_CHANGED **
---
--- @param eventId integer
--- @param mounted boolean
function SpellCastBuffs:MountStatus(eventId, mounted)
    -- Clear current mount icon
    local abilityId = 999017
    self:ClearPlayerBuff(abilityId)
    -- Display mount icon if settings are enabled
    if mounted and not (self.SV.IgnoreMountPlayer or self.SV.HidePlayerBuffs) then
        self:DisplayMountIcon()
    end
end

--- - Waits 100 ms + latency for the delay in activating collectibles before checking
--- - **EVENT_COLLECTIBLE_USE_RESULT **
---
--- @param eventId integer
--- @param result CollectibleUsageBlockReason
--- @param isAttemptingActivation boolean
function SpellCastBuffs:CollectibleUsed(eventId, result, isAttemptingActivation)
    local latency = GetLatency()
    latency = latency + 100
    zo_callLater(function () self:CollectibleBuff() end, latency)
end

-- Handles delayed call from SpellCastBuffs.CollectibleUsed()
function SpellCastBuffs:CollectibleBuff()
    -- Remove Icon First
    local ids = { 999018, 999019 }
    for _, v in pairs(ids) do
        self:ClearPlayerBuff(v)
    end

    -- Bail out if Player Buffs are hidden
    if self.SV.HidePlayerBuffs then
        return
    end

    -- Bail out if we are in a PVP Zone
    if LUIE.ResolvePVPZone() then
        return
    end

    -- Bail out if we are in a house
    local currentHouse = GetCurrentZoneHouseId()
    if currentHouse ~= nil and currentHouse > 0 then
        return
    end

    -- Pets
    if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, GAMEPLAY_ACTOR_CATEGORY_PLAYER) > 0 and not self.SV.IgnorePet then
        local collectible = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        local name
        local description
        local icon
        if self.SV.PetDetail then
            -- Get detailed collectible information for the player
            local nickname = GetCollectibleNickname(collectible)
            name, description, icon = GetCollectibleInfo(collectible)

            -- Add the nickname into the name if present
            if nickname ~= "" and nickname ~= nil then
                name = zo_strformat(GetString(SI_COLLECTIBLE_NAME_WITH_NICKNAME_FORMATTER), name, nickname)
            end
        else
            name = Abilities.Innate_Vanity_Pet
            description = Tooltips.Innate_Vanity_Pet
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_PET_DDS
        end

        local abilityId = 999018
        local abilityName = Abilities.Innate_Vanity_Pet
        local context = self:DetermineContextSimple("player1", abilityId, abilityName)
        self.EffectsList[context][abilityId] =
        {
            target = self:DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = name,
            icon = icon,
            backdrop = true,
            tooltip = description,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "long",
            restart = true,
            iconNum = 0,
        }
    end

    -- Assistants
    if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER) > 0 and not self.SV.IgnoreAssistant then
        local collectible = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        local name, description = GetCollectibleInfo(collectible)
        local iconAssistant = AssistantIcons[name] or ""

        local abilityId = 999019
        local abilityName = Abilities.Innate_Assistant
        local context = self:DetermineContextSimple("player1", abilityId, abilityName)
        self.EffectsList[context][abilityId] =
        {
            target = self:DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = name,
            icon = iconAssistant,
            tooltip = description,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "long",
            restart = true,
            iconNum = 0,
        }
    end
end

-- Debug Display for Combat Events
--- @param eventId integer
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
function SpellCastBuffs:EventCombatDebug(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Don't display if this aura is already added to the filter
    if DebugAuras[abilityId] and self.SV.ShowDebugFilter then return end

    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
    local nameFormatted = zo_strformat("<<C:1>>", GetAbilityName(abilityId))

    local source = zo_strformat("<<C:1>>", sourceName)
    local target = zo_strformat("<<C:1>>", targetName)
    local ability = zo_strformat("<<C:1>>", nameFormatted)
    local duration
    duration = GetAbilityDuration(abilityId)
    if duration == nil then
        duration = "0"
    end
    local channeled, durationValue = GetAbilityCastInfo(abilityId, nil, sourceType)
    local showacasttime = ""
    local showachantime = ""
    if channeled then
        showachantime = (" [Chan] " .. durationValue)
    elseif durationValue and durationValue > 0 then
        showacasttime = (" [Cast] " .. durationValue)
    end
    if source == LUIE.PlayerNameFormatted then
        source = "Player"
    end
    if target == LUIE.PlayerNameFormatted then
        target = "Player"
    end
    if sourceName == "" and targetName == "" then
        source = "NIL"
        target = "NIL"
    end

    local formattedResult = DebugResults[result]

    local finalString = (iconFormatted .. " [" .. abilityId .. "] " .. ability .. ": [S] " .. source .. " --> [T] " .. target .. " [D] " .. duration .. showachantime .. showacasttime .. " [R] " .. formattedResult)
    PrintToChat(finalString, true)
end

-- Debug Display for Effect Events
--- @param eventId integer
--- @param changeType EffectResult
--- @param effectSlot integer
--- @param effectName string
--- @param unitTag string
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param iconName string
--- @param deprecatedBuffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param unitName string
--- @param unitId integer
--- @param abilityId integer
--- @param sourceType CombatUnitType
function SpellCastBuffs:EventEffectDebug(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if DebugAuras[abilityId] and self.SV.ShowDebugFilter then
        return
    end

    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
    local nameFormatted = zo_strformat("<<C:1>>", GetAbilityName(abilityId))

    if unitName == "Offline" then
        unitName = "GROUND?"
    end
    unitName = zo_strformat("<<C:1>>", unitName)
    if unitName == LUIE.PlayerNameFormatted then
        unitName = "Player"
    end
    unitName = unitName .. " (" .. unitTag .. ")"

    local finalString
    if EffectOverride[abilityId] and EffectOverride[abilityId].hide then
        finalString = (iconFormatted .. "|c00E200 [" .. abilityId .. "] " .. nameFormatted .. ": HIDDEN LUI" .. ": [Tag] " .. unitName .. "|r")
        -- Use CHAT_ROUTER to bypass some other addons modifying this string
        CHAT_ROUTER:AddSystemMessage(finalString)
        return
    end

    local duration = (endTime - beginTime) * 1000

    local refreshOnly = ""
    if EffectOverride[abilityId] and EffectOverride[abilityId].refreshOnly then
        refreshOnly = " |c00E200(Hidden)|r "
    end

    if changeType == 1 then
        finalString = ("|c00E200Gained:|r " .. refreshOnly .. iconFormatted .. " [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName .. " [Dur] " .. duration)
    elseif changeType == 2 then
        finalString = ("|c00E200Faded:|r " .. iconFormatted .. " [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName)
    else
        finalString = ("|c00E200Refreshed:|r " .. iconFormatted .. " (" .. changeType .. ") [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName .. " [Dur] " .. duration)
    end
    PrintToChat(finalString, true)
end

if not LUIE.IsDevDebugEnabled() then
    return
else
    -- LUIE utility functions
    local AddSystemMessage = LUIE.AddSystemMessage

    -- -----------------------------------------------------------------------------
    -- Core Lua function localizations
    -- -----------------------------------------------------------------------------

    local pairs = pairs
    local zo_round = zo_round
    local tostring = tostring

    local DoesAbilityExist = DoesAbilityExist
    local GetZoneId = GetZoneId
    local GetCurrentMapZoneIndex = GetCurrentMapZoneIndex
    local GetPlayerLocationName = GetPlayerLocationName
    local GetCurrentMapId = GetCurrentMapId
    local GetCurrentMapIndex = GetCurrentMapIndex
    local GetMapInfoById = GetMapInfoById
    local GetMapPlayerPosition = GetMapPlayerPosition
    local GetMapName = GetMapName
    local SetMapToPlayerLocation = SetMapToPlayerLocation
    local SetMapToMapListIndex = SetMapToMapListIndex
    local MapZoomOut = MapZoomOut


    --- Formats GPS coordinates for display
    --- @param number number The raw coordinate value
    --- @return number Rounded coordinate value
    local function FormatGPSCoords(number)
        return zo_round(number * 100000)
    end

    --- Formats coordinates for display with proper formatting
    --- @param number number The raw coordinate value
    --- @return string Formatted coordinate string
    local function FormatCoords(number)
        return ("%05.02f"):format(FormatGPSCoords(number) / 100)
    end

    -- Account specific DEBUG for ArtOfShred (These are only registered to give me some additional debug options)
    function SpellCastBuffs:AuthorCombatDebug(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
        local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
        local nameFormatted = zo_strformat("<<C:1>>", GetAbilityName(abilityId))

        local source
        local target
        if sourceName == "" and targetName == "" then
            source = "NIL"
            target = "NIL"
        end
        source = zo_strformat("<<C:1>>", sourceName)
        target = zo_strformat("<<C:1>>", targetName)
        if source == LUIE.PlayerNameFormatted then
            source = "Player"
        end
        if target == LUIE.PlayerNameFormatted then
            target = "Player"
        end

        local formattedResult = DebugResults[result]

        if EffectOverride[abilityId] and EffectOverride[abilityId].hide then
            local finalString = (iconFormatted .. "[" .. abilityId .. "] " .. nameFormatted .. ": HIDDEN LUI" .. ": [S] " .. source .. " --> [T] " .. target .. " [R] " .. formattedResult)
            for k, cc in ipairs(chatSystem.containers) do
                local chatContainer = cc
                local chatWindow = cc.windows[2]
                if chatWindow == nil then chatWindow = cc.windows[1] end
                chatContainer:AddEventMessageToWindow(chatWindow, finalString, CHAT_CATEGORY_SYSTEM)
            end
        end
    end

    -- Account specific DEBUG for ArtOfShred (These are only registered to give me some additional debug options)
    function SpellCastBuffs:AuthorEffectDebug(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer)
        local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
        local nameFormatted = zo_strformat("<<C:1>>", GetAbilityName(abilityId))

        unitName = zo_strformat("<<C:1>>", unitName)
        if unitName == LUIE.PlayerNameFormatted then
            unitName = "Player"
        end
        unitName = unitName .. " (" .. unitTag .. ")"

        local refreshOnly = ""
        if EffectOverride[abilityId] and EffectOverride[abilityId].refreshOnly then
            refreshOnly = " |c00E200(Refresh Only - Hidden)|r "
        end

        if EffectOverride[abilityId] and EffectOverride[abilityId].hide then
            local finalString = (iconFormatted .. refreshOnly .. "|c00E200 [" .. abilityId .. "] " .. nameFormatted .. ": HIDDEN LUI" .. ": [Tag] " .. unitName .. "|r")
            for k, cc in ipairs(chatSystem.containers) do
                local chatContainer = cc
                local chatWindow = cc.windows[2]
                if chatWindow == nil then chatWindow = cc.windows[1] end
                chatContainer:AddEventMessageToWindow(chatWindow, finalString, CHAT_CATEGORY_SYSTEM)
            end
        end
    end

    -- -----------------------------------------------------------------------------
    -- Map and Zone Information
    -- -----------------------------------------------------------------------------

    --- @class ZoneMapInfo
    --- @field zoneid integer
    --- @field locName string
    --- @field mapid integer
    --- @field mapindex luaindex|nil
    --- @field name string
    --- @field mapType UIMapType
    --- @field mapContentType MapContentType
    --- @field zoneIndex luaindex
    --- @field description string
    --- @field mapX number
    --- @field mapY number
    --- @field zoneX number
    --- @field zoneY number
    --- @field worldX number
    --- @field worldY number
    --- @field mapName string
    --- @field zoneName string
    --- @field floorInfo table Floor information if available
    --- @field poiInfo table POI information if available
    --- @field fastTravelInfo table Fast travel information if available
    --- @field zoneFlags table Various boolean flags about the current zone
    --- @field keyInfo table Map key information if available
    --- @field cadwellInfo table Cadwell's Almanac information if available
    --- @field scaleLevelConstraints {
    --- max: integer,
    --- min: integer,
    --- type: ScaleLevelConstraintType,
    --- }

    --- Collects and returns zone and map information
    --- @return ZoneMapInfo Information about current zone and map
    local function CollectZoneMapInfo()
        -- Set map to player location and handle callback
        if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
            LUIE:FireCallbacks("OnWorldMapChanged")
        end

        -- Get basic zone and map info
        local zoneIdx = GetCurrentMapZoneIndex()
        local zoneid = GetZoneId(zoneIdx)
        local locName = GetPlayerLocationName()
        local mapid = GetCurrentMapId()
        local mapindex = GetCurrentMapIndex() or GetMapIndexByZoneId(zoneid) or zoneIdx
        local name, mapType, mapContentType, zoneIndex, description = GetMapInfoById(mapid)

        -- Get coordinates at different map levels
        local mapX, mapY = GetMapPlayerPosition("player")
        local zoneX, zoneY = mapX, mapY
        local worldX, worldY = mapX, mapY
        local mapName = GetMapName()
        local zoneName = mapName

        -- Handle dungeon/subzone cases
        if mapContentType == MAP_CONTENT_DUNGEON or mapType == MAPTYPE_SUBZONE then
            MapZoomOut()
            zoneName = GetMapName()
            zoneX, zoneY = GetMapPlayerPosition("player")
        end

        -- Get world coordinates (except for Coldharbour)
        if not (mapindex == 24 or GetCurrentMapIndex() == 24) then
            SetMapToMapListIndex(1) -- Tamriel
            worldX, worldY = GetMapPlayerPosition("player")
        end

        -- Get floor information if available
        local floorInfo = {}
        local currentFloor, numFloors = GetMapFloorInfo()
        if numFloors > 0 then
            floorInfo =
            {
                currentFloor = currentFloor,
                numFloors = numFloors
            }
        end

        -- Get POI info
        local poiInfo = {}
        local numPOIs = GetNumPOIs(zoneIndex)
        if numPOIs > 0 then
            poiInfo.count = numPOIs
            poiInfo.items = {}

            for i = 1, numPOIs do
                local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, i)
                local poiType = GetPOIType(zoneIndex, i)
                local poiX, poiY, poiPinType, icon, isShown, isLocked, isDiscovered, isNearby = GetPOIMapInfo(zoneIndex, i)

                poiInfo.items[i] =
                {
                    name = objectiveName,
                    level = objectiveLevel,
                    type = poiType,
                    x = poiX,
                    y = poiY,
                    isDiscovered = isDiscovered,
                    isNearby = isNearby
                }
            end
        end

        -- Get fast travel information
        local fastTravelInfo = {}
        local numFastTravel = GetNumFastTravelNodes()
        if numFastTravel > 0 then
            fastTravelInfo.count = numFastTravel
            fastTravelInfo.items = {}

            for i = 1, numFastTravel do
                local known, nodeName, nodeX, nodeY, icon, glowIcon, poiType, isShown, isLocked = GetFastTravelNodeInfo(i)
                if isShown then
                    local cooldownRemain, cooldownDuration = GetRecallCooldown()
                    local recallCost = GetRecallCost(i)
                    local recallCurrency = GetRecallCurrency(i)

                    fastTravelInfo.items[#fastTravelInfo.items + 1] =
                    {
                        name = nodeName,
                        known = known,
                        x = nodeX,
                        y = nodeY,
                        cooldown = { remain = cooldownRemain, duration = cooldownDuration },
                        cost = recallCost,
                        currency = recallCurrency
                    }
                end
            end
        end

        -- Zone flags.
        local zoneFlags =
        {
            isInCyrodiil = IsInCyrodiil(),
            isInImperialCity = IsInImperialCity(),
            isInAvAZone = IsInAvAZone(),
            isInOutlawZone = IsInOutlawZone(),
            isInJusticeZone = IsInJusticeEnabledZone(),
            allowsTeleport = CanLeaveCurrentLocationViaTeleport(),
            allowsScaling = DoesCurrentZoneAllowScalingByLevel(),
            hasTelvarBehavior = DoesCurrentZoneHaveTelvarStoneBehavior(),
            allowsBattleLevelScaling = DoesCurrentZoneAllowBattleLevelScaling(),
            isInAvAWorld = IsPlayerInAvAWorld(),
            isInBattleground = IsActiveWorldBattleground(),
            isGroupOwnable = IsActiveWorldGroupOwnable(),
            isStarterWorld = IsActiveWorldStarterWorld()
        }

        -- Get map key information
        local keyInfo = {}
        local numKeySections = GetNumMapKeySections()
        if numKeySections > 0 then
            keyInfo.sections = {}
            for i = 1, numKeySections do
                local sectionName = GetMapKeySectionName(i)
                local numSymbols = GetNumMapKeySectionSymbols(i)

                local symbols = {}
                for j = 1, numSymbols do
                    local symbolName, symbolIcon, symbolTooltip = GetMapKeySectionSymbolInfo(i, j)
                    symbols[j] =
                    {
                        name = symbolName,
                        icon = symbolIcon,
                        tooltip = symbolTooltip
                    }
                end

                keyInfo.sections[i] =
                {
                    name = sectionName,
                    symbols = symbols
                }
            end
        end

        -- Get Cadwell's Almanac information if available
        local cadwellInfo = {}
        local cadwellLevel = GetCadwellProgressionLevel()
        if cadwellLevel > 0 then
            cadwellInfo.level = cadwellLevel
            cadwellInfo.zones = {}

            local numZones = GetNumZonesForCadwellProgressionLevel(cadwellLevel)
            for i = 1, numZones do
                local cadwellZoneName, zoneDesc, zoneOrder = GetCadwellZoneInfo(cadwellLevel, i)
                cadwellInfo.zones[i] =
                {
                    name = cadwellZoneName,
                    description = zoneDesc,
                    order = zoneOrder
                }
            end
        end

        -- Get level scaling constraints
        local scaleLevelType, minScaleLevel, maxScaleLevel = GetCurrentZoneLevelScalingConstraints()

        -- Reset map to player location
        if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
            LUIE:FireCallbacks("OnWorldMapChanged")
        end

        -- Return collected information
        return
        {
            zoneid = zoneid,
            locName = locName,
            mapid = mapid,
            mapindex = mapindex,
            name = name,
            mapType = mapType,
            mapContentType = mapContentType,
            zoneIndex = zoneIndex,
            description = description,
            mapX = mapX,
            mapY = mapY,
            zoneX = zoneX,
            zoneY = zoneY,
            worldX = worldX,
            worldY = worldY,
            mapName = mapName,
            zoneName = zoneName,
            floorInfo = floorInfo,
            poiInfo = poiInfo,
            fastTravelInfo = fastTravelInfo,
            zoneFlags = zoneFlags,
            keyInfo = keyInfo,
            cadwellInfo = cadwellInfo,
            scaleLevelConstraints =
            {
                type = scaleLevelType,
                min = minScaleLevel,
                max = maxScaleLevel
            }
        }
    end

    -- -----------------------------------------------------------------------------
    -- Slash Command Handlers
    -- -----------------------------------------------------------------------------

    --- Toggles the ability debug filter on/off.
    --- When enabled, shows additional debug information for abilities.
    function SpellCastBuffs.TempSlashFilter()
        SpellCastBuffs.SV.ShowDebugFilter = not SpellCastBuffs.SV.ShowDebugFilter
        AddSystemMessage(string_format("LUIE --- Ability Debug Filter %s ---", SpellCastBuffs.SV.ShowDebugFilter and "Enabled" or "Disabled"))
    end

    --- Toggles ground damage aura visualization on/off.
    --- When enabled, shows visual effects for ground-based damage areas.
    --- Reloads player effects after toggling.
    function SpellCastBuffs:TempSlashGround()
        self.SV.GroundDamageAura = not self.SV.GroundDamageAura
        AddSystemMessage(string_format("LUIE --- Ground Damage Auras %s ---", self.SV.GroundDamageAura and "Enabled" or "Disabled"))
        self:ReloadEffects("player")
    end

    --- Outputs current zone and map information to chat.
    --- Retrieves and displays:
    --- - Zone ID and location name
    --- - Map ID and index
    --- - Map name, type, content type
    --- - Zone index and description
    --- - GPS coordinates for player
    function SpellCastBuffs:TempSlashZoneCheck()
        local info = CollectZoneMapInfo()

        local displayInfo =
        {
            { "--------------------"                                                                                                                             },
            { "ZONE & MAP INFO:"                                                                                                                                 },
            { "--------------------"                                                                                                                             },
            { "Zone Id:",            info.zoneid                                                                                                                 },
            { "Location Name:",      info.locName                                                                                                                },
            { "--------------------"                                                                                                                             },
            { "Map Id:",             info.mapid                                                                                                                  },
            { "Map Index:",          info.mapindex or "nil"                                                                                                      },
            { "--------------------"                                                                                                                             },
            { "GPS Coordinates:"                                                                                                                                 },
            { "Map:",                string_format("%s: %s" .. LUIE_TINY_X_FORMATTER .. "%s", info.mapName, FormatCoords(info.mapX), FormatCoords(info.mapY))    },
            { "Zone:",               string_format("%s: %s" .. LUIE_TINY_X_FORMATTER .. "%s", info.zoneName, FormatCoords(info.zoneX), FormatCoords(info.zoneY)) },
            { "World:",              string_format("Tamriel: %s" .. LUIE_TINY_X_FORMATTER .. "%s", FormatCoords(info.worldX), FormatCoords(info.worldY))         },
            { "--------------------"                                                                                                                             },
            { "Map Name:",           info.name                                                                                                                   },
            { "Map Type:",           info.mapType                                                                                                                },
            { "Map Content Type:",   info.mapContentType                                                                                                         },
            { "Zone Index:",         info.zoneIndex                                                                                                              },
            { "Description:",        info.description                                                                                                            },
        }

        -- Floor information
        if info.floorInfo.numFloors and info.floorInfo.numFloors > 0 then
            table.insert(displayInfo, { "--------------------" })
            table.insert(displayInfo, { "Floor Information:" })
            table.insert(displayInfo, { "Current Floor:", info.floorInfo.currentFloor })
            table.insert(displayInfo, { "Total Floors:", info.floorInfo.numFloors })
        end

        -- Zone flags
        table.insert(displayInfo, { "--------------------" })
        table.insert(displayInfo, { "Zone Flags:" })
        local flagsStr = ""
        if info.zoneFlags.isInCyrodiil then flagsStr = flagsStr .. "Cyrodiil, " end
        if info.zoneFlags.isInImperialCity then flagsStr = flagsStr .. "Imperial City, " end
        if info.zoneFlags.isInAvAZone then flagsStr = flagsStr .. "AvA Zone, " end
        if info.zoneFlags.isInOutlawZone then flagsStr = flagsStr .. "Outlaw Zone, " end
        if info.zoneFlags.isInJusticeZone then flagsStr = flagsStr .. "Justice Zone, " end
        if info.zoneFlags.hasTelvarBehavior then flagsStr = flagsStr .. "Telvar Stone, " end
        if info.zoneFlags.isInBattleground then flagsStr = flagsStr .. "Battleground, " end
        if info.zoneFlags.isStarterWorld then flagsStr = flagsStr .. "Starter World, " end
        if flagsStr == "" then flagsStr = "None" else flagsStr = string.sub(flagsStr, 1, -3) end
        table.insert(displayInfo, { "Active Flags:", flagsStr })

        -- Level scaling
        table.insert(displayInfo, { "--------------------" })
        table.insert(displayInfo, { "Level Scaling:" })
        table.insert(displayInfo, { "Scale Type:", info.scaleLevelConstraints.type })
        table.insert(displayInfo, { "Min Level:", info.scaleLevelConstraints.min })
        table.insert(displayInfo, { "Max Level:", info.scaleLevelConstraints.max })

        -- POI information
        if info.poiInfo.count and info.poiInfo.count > 0 then
            AddSystemMessage("--------------------")
            AddSystemMessage("DETAILED POI INFORMATION:")
            AddSystemMessage("--------------------")

            for i, poi in ipairs(info.poiInfo.items) do
                if i <= 5 then -- Limit to first 5 POIs to avoid spam
                    AddSystemMessage(string_format("POI %d: %s (Type: %d, Discovered: %s)", i, poi.name, poi.type, poi.isDiscovered and "Yes" or "No"))
                end
            end

            if #info.poiInfo.items > 5 then
                AddSystemMessage(string_format("... and %d more POIs", #info.poiInfo.items - 5))
            end
        end

        -- Fast travel information
        if info.fastTravelInfo.count and info.fastTravelInfo.count > 0 then
            table.insert(displayInfo, { "--------------------" })
            table.insert(displayInfo, { "Fast Travel Points:", info.fastTravelInfo.count .. " total nodes" })
            table.insert(displayInfo, { "Available:", #info.fastTravelInfo.items .. " in current map" })

            if #info.fastTravelInfo.items > 0 then
                -- Show the nearest wayshrine
                local nearestName = info.fastTravelInfo.items[1].name
                local nearestDist = 999999

                for _, node in ipairs(info.fastTravelInfo.items) do
                    local dist = math.sqrt((node.x - info.mapX) ^ 2 + (node.y - info.mapY) ^ 2)
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestName = node.name
                    end
                end

                table.insert(displayInfo, { "Nearest Wayshrine:", nearestName })
            end
        end

        -- Cadwell's Almanac information
        if info.cadwellInfo.level and info.cadwellInfo.level > 0 then
            table.insert(displayInfo, { "--------------------" })
            table.insert(displayInfo, { "Cadwell's Almanac:" })
            table.insert(displayInfo, { "Progress Level:", info.cadwellInfo.level })
            if info.cadwellInfo.zones and #info.cadwellInfo.zones > 0 then
                table.insert(displayInfo, { "Zones in Current Level:", #info.cadwellInfo.zones })
            end
        end

        table.insert(displayInfo, { "--------------------" })

        for _, v in ipairs(displayInfo) do
            AddSystemMessage(#v == 1 and v[1] or string_format("%s %s", v[1], v[2]))
        end
    end

    --- Checks for removed abilities by iterating through LuiData.Data.DebugAuras and checking if each ability still exists.
    --- Outputs a list of ability IDs that no longer exist in the game to chat.
    function SpellCastBuffs:TempSlashCheckRemovedAbilities()
        AddSystemMessage("Removed AbilityIds:")
        for abilityId in pairs(DebugAuras) do
            if not DoesAbilityExist(abilityId) then
                AddSystemMessage(tostring(abilityId))
            end
        end
    end

    -- Add a new command for full zone info output
    function SpellCastBuffs:TempSlashZoneCheckFull()
        local info = CollectZoneMapInfo()

        -- Display basic info first
        self:TempSlashZoneCheck()

        -- Display POI details
        if info.poiInfo.count and info.poiInfo.count > 0 then
            AddSystemMessage("--------------------")
            AddSystemMessage("DETAILED POI INFORMATION:")
            AddSystemMessage("--------------------")

            for i, poi in ipairs(info.poiInfo.items) do
                if i <= 5 then -- Limit to first 5 POIs to avoid spam
                    AddSystemMessage(string_format("POI %d: %s (Type: %d, Discovered: %s)", i, poi.name, poi.type, poi.isDiscovered and "Yes" or "No"))
                end
            end

            if #info.poiInfo.items > 5 then
                AddSystemMessage(string_format("... and %d more POIs", #info.poiInfo.items - 5))
            end
        end

        -- Display wayshrine details
        if info.fastTravelInfo.count and info.fastTravelInfo.count > 0 then
            AddSystemMessage("--------------------")
            AddSystemMessage("DETAILED WAYSHRINE INFORMATION:")
            AddSystemMessage("--------------------")

            for i, node in ipairs(info.fastTravelInfo.items) do
                if i <= 5 then -- Limit to first 5 wayshrines
                    AddSystemMessage(string_format("Wayshrine %d: %s (Known: %s, Cost: %d)", i, node.name, node.known and "Yes" or "No", node.cost))
                end
            end

            if #info.fastTravelInfo.items > 5 then
                AddSystemMessage(string_format("... and %d more wayshrines", #info.fastTravelInfo.items - 5))
            end
        end

        -- Display key section info
        if info.keyInfo.sections and #info.keyInfo.sections > 0 then
            AddSystemMessage("--------------------")
            AddSystemMessage("MAP KEY INFORMATION:")
            AddSystemMessage("--------------------")

            for i, section in ipairs(info.keyInfo.sections) do
                AddSystemMessage(string_format("Section: %s (%d symbols)", section.name, #section.symbols))
            end
        end

        AddSystemMessage("--------------------")
    end

    -- -----------------------------------------------------------------------------
    -- Slash Commands Registration
    -- -----------------------------------------------------------------------------

    -- Slash command mapping
    local DEBUG_COMMANDS =
    {
        ["/filter"] = SpellCastBuffs.TempSlashFilter,
        ["/ground"] = SpellCastBuffs.TempSlashGround,
        ["/zonecheck"] = SpellCastBuffs.TempSlashZoneCheck,
        ["/zonecheckfull"] = SpellCastBuffs.TempSlashZoneCheckFull,
        ["/abilitydump"] = SpellCastBuffs.TempSlashCheckRemovedAbilities,
    }

    --- Initializes debug slash commands
    --- These commands are only available when developer debug mode is enabled
    if LUIE.IsDevDebugEnabled() then
        for command, handler in pairs(DEBUG_COMMANDS) do
            SLASH_COMMANDS[command] = handler
        end
    end
end


-- -----------------------------------------------------------------------------
-- XML Handlers
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- TopLevelControl OnMoveStop handlers (with grid snapping support)
-- -----------------------------------------------------------------------------

---
--- @param self LUIE_SpellCastBuffs_PlayerBuffs
function LUIE_SpellCastBuffs_PlayerBuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    SpellCastBuffs.SV.playerbOffsetX = left
    SpellCastBuffs.SV.playerbOffsetY = top
end

---
--- @param self LUIE_SpellCastBuffs_PlayerDebuffs
function LUIE_SpellCastBuffs_PlayerDebuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    SpellCastBuffs.SV.playerdOffsetX = left
    SpellCastBuffs.SV.playerdOffsetY = top
end

---
--- @param self LUIE_SpellCastBuffs_TargetBuffs
function LUIE_SpellCastBuffs_TargetBuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    SpellCastBuffs.SV.targetbOffsetX = left
    SpellCastBuffs.SV.targetbOffsetY = top
end

---
--- @param self LUIE_SpellCastBuffs_TargetDebuffs
function LUIE_SpellCastBuffs_TargetDebuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    SpellCastBuffs.SV.targetdOffsetX = left
    SpellCastBuffs.SV.targetdOffsetY = top
end

---
--- @param self LUIE_SpellCastBuffs_ProminentBuffs
function LUIE_SpellCastBuffs_ProminentBuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    if self.alignVertical then
        SpellCastBuffs.SV.prominentbVOffsetX = left
        SpellCastBuffs.SV.prominentbVOffsetY = top
    else
        SpellCastBuffs.SV.prominentbHOffsetX = left
        SpellCastBuffs.SV.prominentbHOffsetY = top
    end
end

---
--- @param self LUIE_SpellCastBuffs_ProminentDebuffs
function LUIE_SpellCastBuffs_ProminentDebuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    if self.alignVertical then
        SpellCastBuffs.SV.prominentdVOffsetX = left
        SpellCastBuffs.SV.prominentdVOffsetY = top
    else
        SpellCastBuffs.SV.prominentdHOffsetX = left
        SpellCastBuffs.SV.prominentdHOffsetY = top
    end
end

---
--- @param self LUIE_SpellCastBuffs_PlayerLong
function LUIE_SpellCastBuffs_PlayerLong_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    if self.alignVertical then
        SpellCastBuffs.SV.playerVOffsetX = left
        SpellCastBuffs.SV.playerVOffsetY = top
    else
        SpellCastBuffs.SV.playerHOffsetX = left
        SpellCastBuffs.SV.playerHOffsetY = top
    end
end

-- -----------------------------------------------------------------------------
-- Buff icon mouse event handlers (for virtual template)
-- -----------------------------------------------------------------------------

---
--- @param self LUIE_SpellCastBuffIcon
function LUIE_SpellCastBuffIcon_OnMouseEnter(self)
    SpellCastBuffs:_Buff_OnMouseEnter(self)
end

---
--- @param self LUIE_SpellCastBuffIcon
function LUIE_SpellCastBuffIcon_OnMouseExit(self)
    SpellCastBuffs:_Buff_OnMouseExit(self)
end

---
--- @param control LUIE_SpellCastBuffIcon
--- @param button MouseButtonIndex
--- @param upInside boolean
--- @param ctrl boolean
--- @param alt boolean
--- @param shift boolean
--- @param command boolean
function LUIE_SpellCastBuffIcon_OnMouseUp(control, button, upInside, ctrl, alt, shift, command)
    SpellCastBuffs:_Buff_OnMouseUp(control, button, upInside)
end

-- -----------------------------------------------------------------------------
-- TopLevelControl OnMoveStart handler (shared by all containers)
-- -----------------------------------------------------------------------------

---
--- @param self TopLevelWindow
function LUIE_SpellCastBuffs_OnMoveStart(self)
    eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
        if self.preview and self.preview.anchorLabel then
            self.preview.anchorLabel:SetText(string.format("%d, %d", self:GetLeft(), self:GetTop()))
        end
    end)
end
