-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local UI = LUIE.UI
local GridOverlay = LUIE.GridOverlay
local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
--- @type Effects
local Effects = Data.Effects
local Abilities = Data.Abilities
local Tooltips = Data.Tooltips
local string_format = string.format
local printToChat = LUIE.PrintToChat
local zo_strformat = zo_strformat
local table_insert = table.insert
local table_sort = table.sort
-- local displayName = GetDisplayName()
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()

local moduleName = SpellCastBuffs.moduleName



--- @param abilityId integer
--- @return boolean
function SpellCastBuffs.ShouldUseDefaultIcon(abilityId)
    local effect = Effects.EffectOverride[abilityId]

    -- Check if effect exists and has either cc or ccMergedType (with HideReduce enabled)
    if not effect or (not effect.cc and not (SpellCastBuffs.SV.HideReduce and effect.ccMergedType)) then
        return false
    end

    -- Option 1: Always use default icon for all cc effects
    if SpellCastBuffs.SV.DefaultIconOptions == 1 then
        return true

        -- Options 2 and 3: Use default icon only for player ability cc effects
    elseif SpellCastBuffs.SV.DefaultIconOptions == 2 or SpellCastBuffs.SV.DefaultIconOptions == 3 then
        return effect.isPlayerAbility
    end

    return false
end

function SpellCastBuffs.GetDefaultIcon(ccType)
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
function SpellCastBuffs.ClearPlayerBuff(abilityId)
    local context = { "player1", "promd_player", "promb_player" }
    for _, v in pairs(context) do
        SpellCastBuffs.EffectsList[v][abilityId] = nil
    end
end

-- Initialize preview labels for all frames
local function InitializePreviewLabels()
    -- Callback to update coordinates while moving
    local function OnMoveStart(self)
        eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
            if self.preview and self.preview.anchorLabel then
                self.preview.anchorLabel:SetText(string.format("%d, %d", self:GetLeft(), self:GetTop()))
            end
        end)
    end

    -- Callback to stop updating coordinates when movement ends
    local function OnMoveStop(self)
        eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
    end

    local frames =
    {
        { frame = SpellCastBuffs.BuffContainers.playerb,          name = "playerb"          },
        { frame = SpellCastBuffs.BuffContainers.playerd,          name = "playerd"          },
        { frame = SpellCastBuffs.BuffContainers.targetb,          name = "targetb"          },
        { frame = SpellCastBuffs.BuffContainers.targetd,          name = "targetd"          },
        { frame = SpellCastBuffs.BuffContainers.player_long,      name = "player_long"      },
        { frame = SpellCastBuffs.BuffContainers.prominentbuffs,   name = "prominentbuffs"   },
        { frame = SpellCastBuffs.BuffContainers.prominentdebuffs, name = "prominentdebuffs" }
    }

    for _, f in ipairs(frames) do
        if f.frame then
            -- Create preview container if it doesn't exist
            if not f.frame.preview then
                f.frame.preview = UI:Control(f.frame, "fill", nil, false)
            end

            -- Create texture and label for anchor preview
            if not f.frame.preview.anchorTexture then
                f.frame.preview.anchorTexture = UI:Texture(f.frame.preview, { TOPLEFT, TOPLEFT }, { 16, 16 }, "/esoui/art/reticle/border_topleft.dds", DL_OVERLAY, false)
                f.frame.preview.anchorTexture:SetColor(1, 1, 0, 0.9)
            end

            if not f.frame.preview.anchorLabel then
                f.frame.preview.anchorLabel = UI:Label(f.frame.preview, { BOTTOMLEFT, TOPLEFT, 0, -1 }, nil, { 0, 2 }, "ZoFontGameSmall", "xxx, yyy", false)
                f.frame.preview.anchorLabel:SetColor(1, 1, 0, 1)
                f.frame.preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
                f.frame.preview.anchorLabel:SetDrawTier(DT_MEDIUM)
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

            if not f.frame.preview.anchorLabelBg then
                f.frame.preview.anchorLabelBg = UI:Backdrop(f.frame.preview.anchorLabel, "fill", nil, { 0, 0, 0, 1 }, { 0, 0, 0, 1 }, false)
                f.frame.preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
                f.frame.preview.anchorLabelBg:SetDrawTier(DT_LOW)
            end

            -- Add movement handlers
            f.frame:SetHandler("OnMoveStart", OnMoveStart)
            f.frame:SetHandler("OnMoveStop", OnMoveStop)
        end
    end
end

-- Initialization
function SpellCastBuffs.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        SpellCastBuffs.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "SpellCastBuffs", SpellCastBuffs.Defaults)
    else
        SpellCastBuffs.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "SpellCastBuffs", SpellCastBuffs.Defaults)
    end

    -- Migrate old string-based font styles to numeric constants (run once)
    if not LUIE.IsMigrationDone("spellcastbuffs_fontstyles") then
        SpellCastBuffs.SV.BuffFontStyle = LUIE.MigrateFontStyle(SpellCastBuffs.SV.BuffFontStyle)
        SpellCastBuffs.SV.ProminentLabelFontStyle = LUIE.MigrateFontStyle(SpellCastBuffs.SV.ProminentLabelFontStyle)
        LUIE.MarkMigrationDone("spellcastbuffs_fontstyles")
    end

    -- Correct read values
    if SpellCastBuffs.SV.IconSize < 30 or SpellCastBuffs.SV.IconSize > 60 then
        SpellCastBuffs.SV.IconSize = SpellCastBuffs.Defaults.IconSize
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    SpellCastBuffs.Enabled = true

    -- Before we start creating controls, update icons font
    SpellCastBuffs.ApplyFont()

    -- Create controls
    -- Create temporary table to store references to scenes locally
    local fragments = {}

    -- We will not create TopLevelWindows when buff frames are locked to Custom Unit Frames
    if SpellCastBuffs.SV.lockPositionToUnitFrames and LUIE.UnitFrames.CustomFrames.player and LUIE.UnitFrames.CustomFrames.player.buffs and LUIE.UnitFrames.CustomFrames.player.debuffs then
        SpellCastBuffs.BuffContainers.player1 = LUIE.UnitFrames.CustomFrames.player.buffs
        SpellCastBuffs.BuffContainers.player2 = LUIE.UnitFrames.CustomFrames.player.debuffs
        SpellCastBuffs.containerRouting.player1 = "player1"
        SpellCastBuffs.containerRouting.player2 = "player2"
    else
        SpellCastBuffs.BuffContainers.playerb = UI:TopLevel(nil, nil)
        local playerb_OnMoveStop = function (self)
            SpellCastBuffs.SV.playerbOffsetX = self:GetLeft()
            SpellCastBuffs.SV.playerbOffsetY = self:GetTop()
        end
        SpellCastBuffs.BuffContainers.playerb:SetHandler("OnMoveStop", playerb_OnMoveStop)
        SpellCastBuffs.BuffContainers.playerd = UI:TopLevel(nil, nil)
        local playerd_OnMoveStop = function (self)
            SpellCastBuffs.SV.playerdOffsetX = self:GetLeft()
            SpellCastBuffs.SV.playerdOffsetY = self:GetTop()
        end
        SpellCastBuffs.BuffContainers.playerd:SetHandler("OnMoveStop", playerd_OnMoveStop)
        SpellCastBuffs.containerRouting.player1 = "playerb"
        SpellCastBuffs.containerRouting.player2 = "playerd"

        local fragment1 = ZO_HUDFadeSceneFragment:New(SpellCastBuffs.BuffContainers.playerb, 0, 0)
        local fragment2 = ZO_HUDFadeSceneFragment:New(SpellCastBuffs.BuffContainers.playerd, 0, 0)
        table_insert(fragments, fragment1)
        table_insert(fragments, fragment2)
    end

    -- Create TopLevelWindows for buff frames when NOT locked to Custom Unit Frames
    if SpellCastBuffs.SV.lockPositionToUnitFrames and LUIE.UnitFrames.CustomFrames.reticleover and LUIE.UnitFrames.CustomFrames.reticleover.buffs and LUIE.UnitFrames.CustomFrames.reticleover.debuffs then
        SpellCastBuffs.BuffContainers.target1 = LUIE.UnitFrames.CustomFrames.reticleover.buffs
        SpellCastBuffs.BuffContainers.target2 = LUIE.UnitFrames.CustomFrames.reticleover.debuffs
        SpellCastBuffs.containerRouting.reticleover1 = "target1"
        SpellCastBuffs.containerRouting.reticleover2 = "target2"
        SpellCastBuffs.containerRouting.ground = "target2"
    else
        SpellCastBuffs.BuffContainers.targetb = UI:TopLevel(nil, nil)
        local targetb_OnMoveStop = function (self)
            SpellCastBuffs.SV.targetbOffsetX = self:GetLeft()
            SpellCastBuffs.SV.targetbOffsetY = self:GetTop()
        end
        SpellCastBuffs.BuffContainers.targetb:SetHandler("OnMoveStop", targetb_OnMoveStop)
        SpellCastBuffs.BuffContainers.targetd = UI:TopLevel(nil, nil)
        local targetd_OnMoveStop = function (self)
            SpellCastBuffs.SV.targetdOffsetX = self:GetLeft()
            SpellCastBuffs.SV.targetdOffsetY = self:GetTop()
        end
        SpellCastBuffs.BuffContainers.targetd:SetHandler("OnMoveStop", targetd_OnMoveStop)
        SpellCastBuffs.containerRouting.reticleover1 = "targetb"
        SpellCastBuffs.containerRouting.reticleover2 = "targetd"
        SpellCastBuffs.containerRouting.ground = "targetd"

        local fragment1 = ZO_HUDFadeSceneFragment:New(SpellCastBuffs.BuffContainers.targetb, 0, 0)
        local fragment2 = ZO_HUDFadeSceneFragment:New(SpellCastBuffs.BuffContainers.targetd, 0, 0)
        table_insert(fragments, fragment1)
        table_insert(fragments, fragment2)
    end

    -- Create TopLevelWindows for Prominent Buffs
    SpellCastBuffs.BuffContainers.prominentbuffs = UI:TopLevel(nil, nil)
    SpellCastBuffs.BuffContainers.prominentbuffs:SetHandler("OnMoveStop", function (self)
        if self.alignVertical then
            SpellCastBuffs.SV.prominentbVOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentbVOffsetY = self:GetTop()
        else
            SpellCastBuffs.SV.prominentbHOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentbHOffsetY = self:GetTop()
        end
    end)
    SpellCastBuffs.BuffContainers.prominentdebuffs = UI:TopLevel(nil, nil)
    SpellCastBuffs.BuffContainers.prominentdebuffs:SetHandler("OnMoveStop", function (self)
        if self.alignVertical then
            SpellCastBuffs.SV.prominentdVOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentdVOffsetY = self:GetTop()
        else
            SpellCastBuffs.SV.prominentdHOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentdHOffsetY = self:GetTop()
        end
    end)

    if SpellCastBuffs.SV.ProminentBuffContainerAlignment == 1 then
        SpellCastBuffs.BuffContainers.prominentbuffs.alignVertical = false
    elseif SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2 then
        SpellCastBuffs.BuffContainers.prominentbuffs.alignVertical = true
    end
    if SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 1 then
        SpellCastBuffs.BuffContainers.prominentdebuffs.alignVertical = false
    elseif SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2 then
        SpellCastBuffs.BuffContainers.prominentdebuffs.alignVertical = true
    end

    SpellCastBuffs.containerRouting.promb_ground = "prominentbuffs"
    SpellCastBuffs.containerRouting.promb_target = "prominentbuffs"
    SpellCastBuffs.containerRouting.promb_player = "prominentbuffs"
    SpellCastBuffs.containerRouting.promd_ground = "prominentdebuffs"
    SpellCastBuffs.containerRouting.promd_target = "prominentdebuffs"
    SpellCastBuffs.containerRouting.promd_player = "prominentdebuffs"

    local fragmentP1 = ZO_HUDFadeSceneFragment:New(SpellCastBuffs.BuffContainers.prominentbuffs, 0, 0)
    local fragmentP2 = ZO_HUDFadeSceneFragment:New(SpellCastBuffs.BuffContainers.prominentdebuffs, 0, 0)
    table_insert(fragments, fragmentP1)
    table_insert(fragments, fragmentP2)

    -- Separate container for players long term buffs
    SpellCastBuffs.BuffContainers.player_long = UI:TopLevel(nil, nil)
    SpellCastBuffs.BuffContainers.player_long:SetHandler("OnMoveStop", function (self)
        local left = self:GetLeft()
        local top = self:GetTop()
        if self.alignVertical then
            SpellCastBuffs.SV.playerVOffsetX = left
            SpellCastBuffs.SV.playerVOffsetY = top
        else
            SpellCastBuffs.SV.playerHOffsetX = left
            SpellCastBuffs.SV.playerHOffsetY = top
        end
    end)

    if SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 1 then
        SpellCastBuffs.BuffContainers.player_long.alignVertical = false
    elseif SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 2 then
        SpellCastBuffs.BuffContainers.player_long.alignVertical = true
    end

    SpellCastBuffs.BuffContainers.player_long.skipUpdate = 0
    SpellCastBuffs.containerRouting.player_long = "player_long"

    local fragment = ZO_HUDFadeSceneFragment:New(SpellCastBuffs.BuffContainers.player_long, 0, 0)
    fragments[#fragments + 1] = fragment

    -- Loop over table of fragments to add them to relevant UI Scenes
    for _, v in pairs(fragments) do
        sceneManager:GetScene("hud"):AddFragment(v)
        sceneManager:GetScene("hudui"):AddFragment(v)
        sceneManager:GetScene("siegeBar"):AddFragment(v)
        sceneManager:GetScene("siegeBarUI"):AddFragment(v)
    end

    -- Set Buff Container Positions
    SpellCastBuffs.SetTlwPosition()

    -- Loop over created controls to...
    for _, v in pairs(SpellCastBuffs.containerRouting) do
        -- Set Draw Priority
        SpellCastBuffs.BuffContainers[v]:SetDrawLayer(DL_BACKGROUND)
        SpellCastBuffs.BuffContainers[v]:SetDrawTier(DT_LOW)
        SpellCastBuffs.BuffContainers[v]:SetDrawLevel(DL_CONTROLS)
        if SpellCastBuffs.BuffContainers[v].preview == nil then
            -- Create background areas for preview position purposes
            -- SpellCastBuffs.BuffContainers[v].preview = UI:Backdrop( SpellCastBuffs.BuffContainers[v], "fill", nil, nil, nil, true )
            SpellCastBuffs.BuffContainers[v].preview = UI:Texture(SpellCastBuffs.BuffContainers[v], "fill", nil, "/esoui/art/miscellaneous/inset_bg.dds", DL_BACKGROUND, true)
            SpellCastBuffs.BuffContainers[v].previewLabel = UI:Label(SpellCastBuffs.BuffContainers[v].preview, { CENTER, CENTER }, nil, nil, "ZoFontGameMedium", SpellCastBuffs.windowTitles[v] .. (SpellCastBuffs.SV.lockPositionToUnitFrames and (v ~= "player_long" and v ~= "prominentbuffs" and v ~= "prominentdebuffs") and " (locked)" or ""), false)

            -- Create control that will hold the icons
            SpellCastBuffs.BuffContainers[v].prevIconsCount = 0
            -- We need this container only for icons that are aligned in one row/column automatically.
            -- Thus we do not create containers for player and target buffs/debuffs on custom frames
            if v ~= "player1" and v ~= "player2" and v ~= "target1" and v ~= "target2" and v ~= "playerb" and v ~= "playerd" and v ~= "targetb" and v ~= "targetd" then
                SpellCastBuffs.BuffContainers[v].iconHolder = UI:Control(SpellCastBuffs.BuffContainers[v], nil, nil, false)
            end
            -- Create table to store created contols for icons
            SpellCastBuffs.BuffContainers[v].icons = {}

            -- add this top level window to global controls list, so it can be hidden
            if SpellCastBuffs.BuffContainers[v]:GetType() == CT_TOPLEVELCONTROL then
                LUIE.Components[moduleName .. v] = SpellCastBuffs.BuffContainers[v]
            end
        end
    end

    SpellCastBuffs.Reset()
    SpellCastBuffs.UpdateContextHideList()
    SpellCastBuffs.UpdateDisplayOverrideIdList()

    -- Register events
    eventManager:RegisterForUpdate(moduleName, 100, SpellCastBuffs.OnUpdate)

    -- Target Events
    eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, SpellCastBuffs.OnTargetChange)
    eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, SpellCastBuffs.OnReticleTargetChanged)
    eventManager:RegisterForEvent(moduleName .. "Disposition", EVENT_DISPOSITION_UPDATE, SpellCastBuffs.OnDispositionUpdate)
    eventManager:AddFilterForEvent(moduleName .. "Disposition", EVENT_DISPOSITION_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- Buff Events
    eventManager:RegisterForEvent(moduleName .. "Player", EVENT_EFFECT_CHANGED, SpellCastBuffs.OnEffectChanged)
    eventManager:RegisterForEvent(moduleName .. "Target", EVENT_EFFECT_CHANGED, SpellCastBuffs.OnEffectChanged)
    eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    eventManager:AddFilterForEvent(moduleName .. "Target", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- GROUND & MINE EFFECTS - add a filtered event for each AbilityId
    for k, v in pairs(Effects.EffectGroundDisplay) do
        eventManager:RegisterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, SpellCastBuffs.OnEffectChangedGround)
        eventManager:AddFilterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_ABILITY_ID, k)
    end
    for k, v in pairs(Effects.LinkedGroundMine) do
        eventManager:RegisterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, SpellCastBuffs.OnEffectChangedGround)
        eventManager:AddFilterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_ABILITY_ID, k)
    end

    -- Combat Events
    eventManager:RegisterForEvent(moduleName .. "Event1", EVENT_COMBAT_EVENT, SpellCastBuffs.OnCombatEventIn)
    eventManager:RegisterForEvent(moduleName .. "Event2", EVENT_COMBAT_EVENT, SpellCastBuffs.OnCombatEventOut)
    eventManager:RegisterForEvent(moduleName .. "Event3", EVENT_COMBAT_EVENT, SpellCastBuffs.OnCombatEventOut)
    eventManager:AddFilterForEvent(moduleName .. "Event1", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)     -- Target -> Player
    eventManager:AddFilterForEvent(moduleName .. "Event2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)     -- Player -> Target
    eventManager:AddFilterForEvent(moduleName .. "Event3", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET, REGISTER_FILTER_IS_ERROR, false) -- Player Pet -> Target
    for k, v in pairs(Effects.AddNameOnEvent) do
        eventManager:RegisterForEvent(moduleName .. "Event4" .. tostring(k), EVENT_COMBAT_EVENT, SpellCastBuffs.OnCombatAddNameEvent)
        eventManager:AddFilterForEvent(moduleName .. "Event4" .. tostring(k), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
    end
    eventManager:RegisterForEvent(moduleName, EVENT_BOSSES_CHANGED, SpellCastBuffs.AddNameOnBossEngaged)

    -- Stealth Events
    eventManager:RegisterForEvent(moduleName .. "Player", EVENT_STEALTH_STATE_CHANGED, SpellCastBuffs.StealthStateChanged)
    eventManager:RegisterForEvent(moduleName .. "Reticleover", EVENT_STEALTH_STATE_CHANGED, SpellCastBuffs.StealthStateChanged)
    eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    eventManager:AddFilterForEvent(moduleName .. "Reticleover", EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- Disguise Events
    eventManager:RegisterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, SpellCastBuffs.DisguiseStateChanged)
    eventManager:RegisterForEvent(moduleName .. "Reticleover", EVENT_DISGUISE_STATE_CHANGED, SpellCastBuffs.DisguiseStateChanged)
    eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    eventManager:AddFilterForEvent(moduleName .. "Reticleover", EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- Artificial Effects Handling
    eventManager:RegisterForEvent(moduleName, EVENT_ARTIFICIAL_EFFECT_ADDED, SpellCastBuffs.ArtificialEffectUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_ARTIFICIAL_EFFECT_REMOVED, SpellCastBuffs.ArtificialEffectUpdate)

    -- Activate/Deactivate Player, Player Dead/Alive, Vibration, and Unit Death
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, SpellCastBuffs.OnPlayerActivated)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_DEACTIVATED, SpellCastBuffs.OnPlayerDeactivated)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ALIVE, SpellCastBuffs.OnPlayerAlive)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_DEAD, SpellCastBuffs.OnPlayerDead)
    eventManager:RegisterForEvent(moduleName, EVENT_VIBRATION, SpellCastBuffs.OnVibration)
    eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, SpellCastBuffs.OnDeath)

    -- Mount Events
    eventManager:RegisterForEvent(moduleName, EVENT_MOUNTED_STATE_CHANGED, SpellCastBuffs.MountStatus)
    eventManager:RegisterForEvent(moduleName, EVENT_COLLECTIBLE_USE_RESULT, SpellCastBuffs.CollectibleUsed)

    -- Inventory Events
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SpellCastBuffs.DisguiseItem)
    eventManager:AddFilterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

    -- Duel (For resolving Target Battle Spirit Status)
    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_STARTED, SpellCastBuffs.DuelStart)
    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_FINISHED, SpellCastBuffs.DuelEnd)

    -- Register event to update icons/names/tooltips for some abilities where we pull information from the currently learned morph
    eventManager:RegisterForEvent(moduleName, EVENT_SKILLS_FULL_UPDATE, function (eventId)
        -- Mages Guild
        Effects.EffectOverride[40465].tooltip = zo_strformat(GetString(LUIE_STRING_SKILL_SCALDING_RUNE_TP), ((GetAbilityDuration(40468) or 0) / 1000) + GetNumPassiveSkillRanks(GetSkillLineIndicesFromSkillLineId(44), select(2, GetSkillLineIndicesFromSkillLineId(44)), 8))
    end)

    -- Werewolf
    SpellCastBuffs.RegisterWerewolfEvents()

    -- Debug
    SpellCastBuffs.RegisterDebugEvents()

    -- Variable adjustment if needed
    if not LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsSCB then
        LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsSCB = 0
    end
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsSCB < 2 then
        -- Set buff cc type colors
        SpellCastBuffs.SV.colors.buff = SpellCastBuffs.Defaults.colors.buff
        SpellCastBuffs.SV.colors.debuff = SpellCastBuffs.Defaults.colors.debuff
        SpellCastBuffs.SV.colors.prioritybuff = SpellCastBuffs.Defaults.colors.prioritybuff
        SpellCastBuffs.SV.colors.prioritydebuff = SpellCastBuffs.Defaults.colors.prioritydebuff
        SpellCastBuffs.SV.colors.unbreakable = SpellCastBuffs.Defaults.colors.unbreakable
        SpellCastBuffs.SV.colors.cosmetic = SpellCastBuffs.Defaults.colors.cosmetic
        SpellCastBuffs.SV.colors.nocc = SpellCastBuffs.Defaults.colors.nocc
        SpellCastBuffs.SV.colors.stun = SpellCastBuffs.Defaults.colors.stun
        SpellCastBuffs.SV.colors.knockback = SpellCastBuffs.Defaults.colors.knockback
        SpellCastBuffs.SV.colors.levitate = SpellCastBuffs.Defaults.colors.levitate
        SpellCastBuffs.SV.colors.disorient = SpellCastBuffs.Defaults.colors.disorient
        SpellCastBuffs.SV.colors.fear = SpellCastBuffs.Defaults.colors.fear
        SpellCastBuffs.SV.colors.silence = SpellCastBuffs.Defaults.colors.silence
        SpellCastBuffs.SV.colors.stagger = SpellCastBuffs.Defaults.colors.stagger
        SpellCastBuffs.SV.colors.snare = SpellCastBuffs.Defaults.colors.snare
        SpellCastBuffs.SV.colors.root = SpellCastBuffs.Defaults.colors.root
    end
    -- Increment so this doesn't occur again.
    LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsSCB = 2

    -- Initialize preview labels for all frames
    InitializePreviewLabels()
end

function SpellCastBuffs.RegisterWerewolfEvents()
    eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
    eventManager:UnregisterForUpdate(moduleName .. "WerewolfTicker")
    eventManager:UnregisterForEvent(moduleName, EVENT_WEREWOLF_STATE_CHANGED)
    if SpellCastBuffs.SV.ShowWerewolf then
        eventManager:RegisterForEvent(moduleName, EVENT_WEREWOLF_STATE_CHANGED, SpellCastBuffs.WerewolfState)
        if IsPlayerInWerewolfForm() then
            SpellCastBuffs.WerewolfState(nil, true, true)
        end
    end
end

function SpellCastBuffs.RegisterDebugEvents()
    -- Unregister existing events
    eventManager:UnregisterForEvent(moduleName .. "DebugCombat", EVENT_COMBAT_EVENT)
    -- Register standard debug events if enabled
    if SpellCastBuffs.SV.ShowDebugCombat then
        eventManager:RegisterForEvent(moduleName .. "DebugCombat", EVENT_COMBAT_EVENT, function (eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            SpellCastBuffs.EventCombatDebug(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        end)
    end
    eventManager:UnregisterForEvent(moduleName .. "DebugEffect", EVENT_EFFECT_CHANGED)
    if SpellCastBuffs.SV.ShowDebugEffect then
        eventManager:RegisterForEvent(moduleName .. "DebugEffect", EVENT_EFFECT_CHANGED, function (eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
            SpellCastBuffs.EventEffectDebug(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        end)
    end

    -- Author-specific debug events
    if LUIE.IsDevDebugEnabled() then
        eventManager:UnregisterForEvent(moduleName .. "AuthorDebugCombat", EVENT_COMBAT_EVENT)
        if SpellCastBuffs.SV.ShowDebugCombat then
            eventManager:RegisterForEvent(moduleName .. "AuthorDebugCombat", EVENT_COMBAT_EVENT, function (eventId, ...)
                SpellCastBuffs.AuthorCombatDebug(eventId, ...)
            end)
        end
        eventManager:UnregisterForEvent(moduleName .. "AuthorDebugEffect", EVENT_EFFECT_CHANGED)
        if SpellCastBuffs.SV.ShowDebugEffect then
            eventManager:RegisterForEvent(moduleName .. "AuthorDebugEffect", EVENT_EFFECT_CHANGED, function (eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
                SpellCastBuffs.AuthorEffectDebug(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
            end)
        end
    end
end

function SpellCastBuffs.ResetContainerOrientation()
    ---
    --- @param self TopLevelWindow|table
    local prominentbuffs_OnMoveStop = function (self)
        if self.alignVertical then
            SpellCastBuffs.SV.prominentbVOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentbVOffsetY = self:GetTop()
        else
            SpellCastBuffs.SV.prominentbHOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentbHOffsetY = self:GetTop()
        end
    end
    -- Create TopLevelWindows for Prominent Buffs
    SpellCastBuffs.BuffContainers.prominentbuffs:SetHandler("OnMoveStop", prominentbuffs_OnMoveStop)
    ---
    --- @param self TopLevelWindow|table
    local prominentdebuffs_OnMoveStop = function (self)
        if self.alignVertical then
            SpellCastBuffs.SV.prominentdVOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentdVOffsetY = self:GetTop()
        else
            SpellCastBuffs.SV.prominentdHOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentdHOffsetY = self:GetTop()
        end
    end
    SpellCastBuffs.BuffContainers.prominentdebuffs:SetHandler("OnMoveStop", prominentdebuffs_OnMoveStop)

    if SpellCastBuffs.SV.ProminentBuffContainerAlignment == 1 then
        SpellCastBuffs.BuffContainers.prominentbuffs.alignVertical = false
    elseif SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2 then
        SpellCastBuffs.BuffContainers.prominentbuffs.alignVertical = true
    end
    if SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 1 then
        SpellCastBuffs.BuffContainers.prominentdebuffs.alignVertical = false
    elseif SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2 then
        SpellCastBuffs.BuffContainers.prominentdebuffs.alignVertical = true
    end

    SpellCastBuffs.containerRouting.promb_ground = "prominentbuffs"
    SpellCastBuffs.containerRouting.promb_target = "prominentbuffs"
    SpellCastBuffs.containerRouting.promb_player = "prominentbuffs"
    SpellCastBuffs.containerRouting.promd_ground = "prominentdebuffs"
    SpellCastBuffs.containerRouting.promd_target = "prominentdebuffs"
    SpellCastBuffs.containerRouting.promd_player = "prominentdebuffs"

    ---
    --- @param self TopLevelWindow|table
    local player_long_OnMoveStop = function (self)
        if self.alignVertical then
            SpellCastBuffs.SV.playerVOffsetX = self:GetLeft()
            SpellCastBuffs.SV.playerVOffsetY = self:GetTop()
        else
            SpellCastBuffs.SV.playerHOffsetX = self:GetLeft()
            SpellCastBuffs.SV.playerHOffsetY = self:GetTop()
        end
    end
    -- Separate container for players long term buffs
    SpellCastBuffs.BuffContainers.player_long:SetHandler("OnMoveStop", player_long_OnMoveStop)

    if SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 1 then
        SpellCastBuffs.BuffContainers.player_long.alignVertical = false
    elseif SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 2 then
        SpellCastBuffs.BuffContainers.player_long.alignVertical = true
    end

    SpellCastBuffs.BuffContainers.player_long.skipUpdate = 0
    SpellCastBuffs.containerRouting.player_long = "player_long"

    -- Set Buff Container Positions
    SpellCastBuffs.SetTlwPosition()
end

-- Set SpellCastBuffs.alignmentDirection table to equal the values from our SV Table & converts string values to proper alignment values. Called from Settings Menu & on Initialize
function SpellCastBuffs.SetupContainerAlignment()
    SpellCastBuffs.alignmentDirection = {}

    SpellCastBuffs.alignmentDirection.player1 = SpellCastBuffs.SV.AlignmentBuffsPlayer   -- No icon holder for anchored buffs/debuffs - This value gets passed to SpellCastBuffs.updateIcons()
    SpellCastBuffs.alignmentDirection.playerb = SpellCastBuffs.SV.AlignmentBuffsPlayer   -- No icon holder for anchored buffs/debuffs - This value gets passed to SpellCastBuffs.updateIcons()
    SpellCastBuffs.alignmentDirection.player2 = SpellCastBuffs.SV.AlignmentDebuffsPlayer -- No icon holder for anchored buffs/debuffs - This value gets passed to SpellCastBuffs.updateIcons()
    SpellCastBuffs.alignmentDirection.playerd = SpellCastBuffs.SV.AlignmentDebuffsPlayer -- No icon holder for anchored buffs/debuffs - This value gets passed to SpellCastBuffs.updateIcons()
    SpellCastBuffs.alignmentDirection.target1 = SpellCastBuffs.SV.AlignmentBuffsTarget   -- No icon holder for anchored buffs/debuffs - This value gets passed to SpellCastBuffs.updateIcons()
    SpellCastBuffs.alignmentDirection.targetb = SpellCastBuffs.SV.AlignmentBuffsTarget   -- No icon holder for anchored buffs/debuffs - This value gets passed to SpellCastBuffs.updateIcons()
    SpellCastBuffs.alignmentDirection.target2 = SpellCastBuffs.SV.AlignmentDebuffsTarget -- No icon holder for anchored buffs/debuffs - This value gets passed to SpellCastBuffs.updateIcons()
    SpellCastBuffs.alignmentDirection.targetd = SpellCastBuffs.SV.AlignmentDebuffsTarget -- No icon holder for anchored buffs/debuffs - This value gets passed to SpellCastBuffs.updateIcons()

    -- Set Long Term Effects Alignment
    if SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 1 then
        -- Horizontal
        SpellCastBuffs.alignmentDirection.player_long = SpellCastBuffs.SV.AlignmentLongHorz
    elseif SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 2 then
        -- Vertical
        SpellCastBuffs.alignmentDirection.player_long = SpellCastBuffs.SV.AlignmentLongVert
    end

    -- Set Prominent Buffs Alignment
    if SpellCastBuffs.SV.ProminentBuffContainerAlignment == 1 then
        -- Horizontal
        SpellCastBuffs.alignmentDirection.prominentbuffs = SpellCastBuffs.SV.AlignmentPromBuffsHorz
    elseif SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2 then
        -- Vertical
        SpellCastBuffs.alignmentDirection.prominentbuffs = SpellCastBuffs.SV.AlignmentPromBuffsVert
    end

    -- Set Prominent Debuffs Alignment
    if SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 1 then
        -- Horizontal
        SpellCastBuffs.alignmentDirection.prominentdebuffs = SpellCastBuffs.SV.AlignmentPromDebuffsHorz
    elseif SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2 then
        -- Vertical
        SpellCastBuffs.alignmentDirection.prominentdebuffs = SpellCastBuffs.SV.AlignmentPromDebuffsVert
    end

    for k, v in pairs(SpellCastBuffs.alignmentDirection) do
        if v == "Left" then
            SpellCastBuffs.alignmentDirection[k] = LEFT
        elseif v == "Right" then
            SpellCastBuffs.alignmentDirection[k] = RIGHT
        elseif v == "Centered" then
            SpellCastBuffs.alignmentDirection[k] = CENTER
        elseif v == "Top" then
            SpellCastBuffs.alignmentDirection[k] = TOP
        elseif v == "Bottom" then
            SpellCastBuffs.alignmentDirection[k] = BOTTOM
        else
            SpellCastBuffs.alignmentDirection[k] = CENTER -- Fallback
        end
    end

    for k, v in pairs(SpellCastBuffs.containerRouting) do
        if SpellCastBuffs.BuffContainers[v].iconHolder and SpellCastBuffs.alignmentDirection[v] then
            SpellCastBuffs.BuffContainers[v].iconHolder:ClearAnchors()
            SpellCastBuffs.BuffContainers[v].iconHolder:SetAnchor(SpellCastBuffs.alignmentDirection[v])
        end
    end
end

-- Set SpellCastBuffs.sortDirection table to equal the values from our SV table. Called from Settings Menu & on Initialize
function SpellCastBuffs.SetupContainerSort()
    -- Clear the sort direction table
    SpellCastBuffs.sortDirection = {}

    -- Set sort order for player/target containers
    SpellCastBuffs.sortDirection.player1 = SpellCastBuffs.SV.SortBuffsPlayer
    SpellCastBuffs.sortDirection.playerb = SpellCastBuffs.SV.SortBuffsPlayer
    SpellCastBuffs.sortDirection.player2 = SpellCastBuffs.SV.SortDebuffsPlayer
    SpellCastBuffs.sortDirection.playerd = SpellCastBuffs.SV.SortDebuffsPlayer
    SpellCastBuffs.sortDirection.target1 = SpellCastBuffs.SV.SortBuffsTarget
    SpellCastBuffs.sortDirection.targetb = SpellCastBuffs.SV.SortBuffsTarget
    SpellCastBuffs.sortDirection.target2 = SpellCastBuffs.SV.SortDebuffsTarget
    SpellCastBuffs.sortDirection.targetd = SpellCastBuffs.SV.SortDebuffsTarget

    -- Set Long Term Effects Sort Order
    if SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 1 then
        -- Horizontal
        SpellCastBuffs.sortDirection.player_long = SpellCastBuffs.SV.SortLongHorz
    elseif SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 2 then
        -- Vertical
        SpellCastBuffs.sortDirection.player_long = SpellCastBuffs.SV.SortLongVert
    end

    -- Set Prominent Buffs Sort Order
    if SpellCastBuffs.SV.ProminentBuffContainerAlignment == 1 then
        -- Horizontal
        SpellCastBuffs.sortDirection.prominentbuffs = SpellCastBuffs.SV.SortPromBuffsHorz
    elseif SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2 then
        -- Vertical
        SpellCastBuffs.sortDirection.prominentbuffs = SpellCastBuffs.SV.SortPromBuffsVert
    end

    -- Set Prominent Debuffs Sort Order
    if SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 1 then
        -- Horizontal
        SpellCastBuffs.sortDirection.prominentdebuffs = SpellCastBuffs.SV.SortPromDebuffsHorz
    elseif SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2 then
        -- Vertical
        SpellCastBuffs.sortDirection.prominentdebuffs = SpellCastBuffs.SV.SortPromDebuffsVert
    end
end

-- Reset position of windows. Called from Settings Menu.
function SpellCastBuffs.ResetTlwPosition()
    if not SpellCastBuffs.Enabled then
        return
    end
    SpellCastBuffs.SV.playerbOffsetX = nil
    SpellCastBuffs.SV.playerbOffsetY = nil
    SpellCastBuffs.SV.playerdOffsetX = nil
    SpellCastBuffs.SV.playerdOffsetY = nil
    SpellCastBuffs.SV.targetbOffsetX = nil
    SpellCastBuffs.SV.targetbOffsetY = nil
    SpellCastBuffs.SV.targetdOffsetX = nil
    SpellCastBuffs.SV.targetdOffsetY = nil
    SpellCastBuffs.SV.playerVOffsetX = nil
    SpellCastBuffs.SV.playerVOffsetY = nil
    SpellCastBuffs.SV.playerHOffsetX = nil
    SpellCastBuffs.SV.playerHOffsetY = nil
    SpellCastBuffs.SV.prominentbVOffsetX = nil
    SpellCastBuffs.SV.prominentbVOffsetY = nil
    SpellCastBuffs.SV.prominentbHOffsetX = nil
    SpellCastBuffs.SV.prominentbHOffsetY = nil
    SpellCastBuffs.SV.prominentdVOffsetX = nil
    SpellCastBuffs.SV.prominentdVOffsetY = nil
    SpellCastBuffs.SV.prominentdHOffsetX = nil
    SpellCastBuffs.SV.prominentdHOffsetY = nil
    SpellCastBuffs.SetTlwPosition()
end

-- Set position of windows. Called from .Initialize() and .ResetTlwPosition()
function SpellCastBuffs.SetTlwPosition()
    -- If icons are locked to custom frames, i.e. SpellCastBuffs.BuffContainers[] is a CT_CONTROL of LUIE.UnitFrames.CustomFrames.player we do not have to do anything here. so just bail out
    -- Otherwise set position of SpellCastBuffs.BuffContainers[] which are CT_TOPLEVELCONTROLs to saved or default positions
    if SpellCastBuffs.BuffContainers.playerb and SpellCastBuffs.BuffContainers.playerb:GetType() == CT_TOPLEVELCONTROL then
        SpellCastBuffs.BuffContainers.playerb:ClearAnchors()
        if (SpellCastBuffs.SV.lockPositionToUnitFrames == nil or not SpellCastBuffs.SV.lockPositionToUnitFrames) and SpellCastBuffs.SV.playerbOffsetX ~= nil and SpellCastBuffs.SV.playerbOffsetY ~= nil then
            local x, y = SpellCastBuffs.SV.playerbOffsetX, SpellCastBuffs.SV.playerbOffsetY
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                x, y = LUIE.ApplyGridSnap(x, y, "buffs")
            end
            SpellCastBuffs.BuffContainers.playerb:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        else
            SpellCastBuffs.BuffContainers.playerb:SetAnchor(BOTTOM, ZO_PlayerAttributeHealth, TOP, 0, -10)
        end
    end

    if SpellCastBuffs.BuffContainers.playerd and SpellCastBuffs.BuffContainers.playerd:GetType() == CT_TOPLEVELCONTROL then
        SpellCastBuffs.BuffContainers.playerd:ClearAnchors()
        if (SpellCastBuffs.SV.lockPositionToUnitFrames == nil or not SpellCastBuffs.SV.lockPositionToUnitFrames) and SpellCastBuffs.SV.playerdOffsetX ~= nil and SpellCastBuffs.SV.playerdOffsetY ~= nil then
            local x, y = SpellCastBuffs.SV.playerdOffsetX, SpellCastBuffs.SV.playerdOffsetY
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                x, y = LUIE.ApplyGridSnap(x, y, "buffs")
            end
            SpellCastBuffs.BuffContainers.playerd:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        else
            SpellCastBuffs.BuffContainers.playerd:SetAnchor(BOTTOM, ZO_PlayerAttributeHealth, TOP, 0, -60)
        end
    end

    if SpellCastBuffs.BuffContainers.targetb and SpellCastBuffs.BuffContainers.targetb:GetType() == CT_TOPLEVELCONTROL then
        SpellCastBuffs.BuffContainers.targetb:ClearAnchors()
        if (SpellCastBuffs.SV.lockPositionToUnitFrames == nil or not SpellCastBuffs.SV.lockPositionToUnitFrames) and SpellCastBuffs.SV.targetbOffsetX ~= nil and SpellCastBuffs.SV.targetbOffsetY ~= nil then
            local x, y = SpellCastBuffs.SV.targetbOffsetX, SpellCastBuffs.SV.targetbOffsetY
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                x, y = LUIE.ApplyGridSnap(x, y, "buffs")
            end
            SpellCastBuffs.BuffContainers.targetb:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        else
            SpellCastBuffs.BuffContainers.targetb:SetAnchor(TOP, ZO_TargetUnitFramereticleover, BOTTOM, 0, 60)
        end
    end

    if SpellCastBuffs.BuffContainers.targetd and SpellCastBuffs.BuffContainers.targetd:GetType() == CT_TOPLEVELCONTROL then
        SpellCastBuffs.BuffContainers.targetd:ClearAnchors()
        if (SpellCastBuffs.SV.lockPositionToUnitFrames == nil or not SpellCastBuffs.SV.lockPositionToUnitFrames) and SpellCastBuffs.SV.targetdOffsetX ~= nil and SpellCastBuffs.SV.targetdOffsetY ~= nil then
            local x, y = SpellCastBuffs.SV.targetdOffsetX, SpellCastBuffs.SV.targetdOffsetY
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                x, y = LUIE.ApplyGridSnap(x, y, "buffs")
            end
            SpellCastBuffs.BuffContainers.targetd:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        else
            SpellCastBuffs.BuffContainers.targetd:SetAnchor(TOP, ZO_TargetUnitFramereticleover, BOTTOM, 0, 110)
        end
    end

    if SpellCastBuffs.BuffContainers.player_long then
        SpellCastBuffs.BuffContainers.player_long:ClearAnchors()
        if SpellCastBuffs.BuffContainers.player_long.alignVertical then
            if SpellCastBuffs.SV.playerVOffsetX ~= nil and SpellCastBuffs.SV.playerVOffsetY ~= nil then
                local x, y = SpellCastBuffs.SV.playerVOffsetX, SpellCastBuffs.SV.playerVOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                SpellCastBuffs.BuffContainers.player_long:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                SpellCastBuffs.BuffContainers.player_long:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -3, -75)
            end
        else
            if SpellCastBuffs.SV.playerHOffsetX ~= nil and SpellCastBuffs.SV.playerHOffsetY ~= nil then
                local x, y = SpellCastBuffs.SV.playerHOffsetX, SpellCastBuffs.SV.playerHOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                SpellCastBuffs.BuffContainers.player_long:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                SpellCastBuffs.BuffContainers.player_long:SetAnchor(BOTTOM, ZO_PlayerAttributeHealth, TOP, 0, -70)
            end
        end
    end

    -- Setup Prominent Buffs Position
    if SpellCastBuffs.BuffContainers.prominentbuffs then
        SpellCastBuffs.BuffContainers.prominentbuffs:ClearAnchors()
        if SpellCastBuffs.BuffContainers.prominentbuffs.alignVertical then
            if SpellCastBuffs.SV.prominentbVOffsetX ~= nil and SpellCastBuffs.SV.prominentbVOffsetY ~= nil then
                local x, y = SpellCastBuffs.SV.prominentbVOffsetX, SpellCastBuffs.SV.prominentbVOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                SpellCastBuffs.BuffContainers.prominentbuffs:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                SpellCastBuffs.BuffContainers.prominentbuffs:SetAnchor(CENTER, GuiRoot, CENTER, -340, -100)
            end
        else
            if SpellCastBuffs.SV.prominentbHOffsetX ~= nil and SpellCastBuffs.SV.prominentbHOffsetY ~= nil then
                local x, y = SpellCastBuffs.SV.prominentbHOffsetX, SpellCastBuffs.SV.prominentbHOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                SpellCastBuffs.BuffContainers.prominentbuffs:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                SpellCastBuffs.BuffContainers.prominentbuffs:SetAnchor(CENTER, GuiRoot, CENTER, -340, -100)
            end
        end
    end

    if SpellCastBuffs.BuffContainers.prominentdebuffs then
        SpellCastBuffs.BuffContainers.prominentdebuffs:ClearAnchors()
        if SpellCastBuffs.BuffContainers.prominentdebuffs.alignVertical then
            if SpellCastBuffs.SV.prominentdVOffsetX ~= nil and SpellCastBuffs.SV.prominentdVOffsetY ~= nil then
                local x, y = SpellCastBuffs.SV.prominentdVOffsetX, SpellCastBuffs.SV.prominentdVOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                SpellCastBuffs.BuffContainers.prominentdebuffs:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                SpellCastBuffs.BuffContainers.prominentdebuffs:SetAnchor(CENTER, GuiRoot, CENTER, 340, -100)
            end
        else
            if SpellCastBuffs.SV.prominentdHOffsetX ~= nil and SpellCastBuffs.SV.prominentdHOffsetY ~= nil then
                local x, y = SpellCastBuffs.SV.prominentdHOffsetX, SpellCastBuffs.SV.prominentdHOffsetY
                if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                    x, y = LUIE.ApplyGridSnap(x, y, "buffs")
                end
                SpellCastBuffs.BuffContainers.prominentdebuffs:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            else
                SpellCastBuffs.BuffContainers.prominentdebuffs:SetAnchor(CENTER, GuiRoot, CENTER, 340, -100)
            end
        end
    end
end

-- Unlock windows for moving. Called from Settings Menu.
function SpellCastBuffs.SetMovingState(state)
    if not SpellCastBuffs.Enabled then
        return
    end

    SpellCastBuffs.BuffsMovingState = state

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
        if SpellCastBuffs.SV.lockPositionToUnitFrames == nil or not SpellCastBuffs.SV.lockPositionToUnitFrames then
            SetupBuffContainer(SpellCastBuffs.BuffContainers.playerb, "buff_playerb", function (control, left, top)
                SpellCastBuffs.SV.playerbOffsetX = left
                SpellCastBuffs.SV.playerbOffsetY = top
            end)

            SetupBuffContainer(SpellCastBuffs.BuffContainers.playerd, "buff_playerd", function (control, left, top)
                SpellCastBuffs.SV.playerdOffsetX = left
                SpellCastBuffs.SV.playerdOffsetY = top
            end)

            SetupBuffContainer(SpellCastBuffs.BuffContainers.targetb, "buff_targetb", function (control, left, top)
                SpellCastBuffs.SV.targetbOffsetX = left
                SpellCastBuffs.SV.targetbOffsetY = top
            end)

            SetupBuffContainer(SpellCastBuffs.BuffContainers.targetd, "buff_targetd", function (control, left, top)
                SpellCastBuffs.SV.targetdOffsetX = left
                SpellCastBuffs.SV.targetdOffsetY = top
            end)
        end

        SetupBuffContainer(SpellCastBuffs.BuffContainers.player_long, "buff_player_long", function (control, left, top)
            if control.alignVertical then
                SpellCastBuffs.SV.playerVOffsetX = left
                SpellCastBuffs.SV.playerVOffsetY = top
            else
                SpellCastBuffs.SV.playerHOffsetX = left
                SpellCastBuffs.SV.playerHOffsetY = top
            end
        end)

        SetupBuffContainer(SpellCastBuffs.BuffContainers.prominentbuffs, "buff_prominentbuffs", function (control, left, top)
            if control.alignVertical then
                SpellCastBuffs.SV.prominentbVOffsetX = left
                SpellCastBuffs.SV.prominentbVOffsetY = top
            else
                SpellCastBuffs.SV.prominentbHOffsetX = left
                SpellCastBuffs.SV.prominentbHOffsetY = top
            end
        end)

        SetupBuffContainer(SpellCastBuffs.BuffContainers.prominentdebuffs, "buff_prominentdebuffs", function (control, left, top)
            if control.alignVertical then
                SpellCastBuffs.SV.prominentdVOffsetX = left
                SpellCastBuffs.SV.prominentdVOffsetY = top
            else
                SpellCastBuffs.SV.prominentdHOffsetX = left
                SpellCastBuffs.SV.prominentdHOffsetY = top
            end
        end)

        -- Show/hide preview
        for _, v in pairs(SpellCastBuffs.containerRouting) do
            if SpellCastBuffs.BuffContainers[v] and SpellCastBuffs.BuffContainers[v].preview then
                SpellCastBuffs.BuffContainers[v].preview:SetHidden(not state)
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
    if SpellCastBuffs.BuffContainers.playerb and SpellCastBuffs.BuffContainers.playerb:GetType() == CT_TOPLEVELCONTROL and (SpellCastBuffs.SV.lockPositionToUnitFrames == nil or not SpellCastBuffs.SV.lockPositionToUnitFrames) then
        SpellCastBuffs.BuffContainers.playerb:SetMouseEnabled(state)
        SpellCastBuffs.BuffContainers.playerb:SetMovable(state)
        UpdatePositionLabel(SpellCastBuffs.BuffContainers.playerb, SpellCastBuffs.BuffContainers.playerb.preview.anchorLabel)

        -- Add grid snapping handler
        SpellCastBuffs.BuffContainers.playerb:SetHandler("OnMoveStop", function (self)
            local left, top = self:GetLeft(), self:GetTop()
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                left, top = LUIE.ApplyGridSnap(left, top, "buffs")
                self:ClearAnchors()
                self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
            end
            SpellCastBuffs.SV.playerbOffsetX = left
            SpellCastBuffs.SV.playerbOffsetY = top
        end)
    end

    if SpellCastBuffs.BuffContainers.playerd and SpellCastBuffs.BuffContainers.playerd:GetType() == CT_TOPLEVELCONTROL and (SpellCastBuffs.SV.lockPositionToUnitFrames == nil or not SpellCastBuffs.SV.lockPositionToUnitFrames) then
        SpellCastBuffs.BuffContainers.playerd:SetMouseEnabled(state)
        SpellCastBuffs.BuffContainers.playerd:SetMovable(state)
        UpdatePositionLabel(SpellCastBuffs.BuffContainers.playerd, SpellCastBuffs.BuffContainers.playerd.preview.anchorLabel)

        -- Add grid snapping handler
        SpellCastBuffs.BuffContainers.playerd:SetHandler("OnMoveStop", function (self)
            local left, top = self:GetLeft(), self:GetTop()
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                left, top = LUIE.ApplyGridSnap(left, top, "buffs")
                self:ClearAnchors()
                self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
            end
            SpellCastBuffs.SV.playerdOffsetX = left
            SpellCastBuffs.SV.playerdOffsetY = top
        end)
    end

    if SpellCastBuffs.BuffContainers.targetb and SpellCastBuffs.BuffContainers.targetb:GetType() == CT_TOPLEVELCONTROL and (SpellCastBuffs.SV.lockPositionToUnitFrames == nil or not SpellCastBuffs.SV.lockPositionToUnitFrames) then
        SpellCastBuffs.BuffContainers.targetb:SetMouseEnabled(state)
        SpellCastBuffs.BuffContainers.targetb:SetMovable(state)
        UpdatePositionLabel(SpellCastBuffs.BuffContainers.targetb, SpellCastBuffs.BuffContainers.targetb.preview.anchorLabel)

        -- Add grid snapping handler
        SpellCastBuffs.BuffContainers.targetb:SetHandler("OnMoveStop", function (self)
            local left, top = self:GetLeft(), self:GetTop()
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                left, top = LUIE.ApplyGridSnap(left, top, "buffs")
                self:ClearAnchors()
                self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
            end
            SpellCastBuffs.SV.targetbOffsetX = left
            SpellCastBuffs.SV.targetbOffsetY = top
        end)
    end

    if SpellCastBuffs.BuffContainers.targetd and SpellCastBuffs.BuffContainers.targetd:GetType() == CT_TOPLEVELCONTROL and (SpellCastBuffs.SV.lockPositionToUnitFrames == nil or not SpellCastBuffs.SV.lockPositionToUnitFrames) then
        SpellCastBuffs.BuffContainers.targetd:SetMouseEnabled(state)
        SpellCastBuffs.BuffContainers.targetd:SetMovable(state)
        UpdatePositionLabel(SpellCastBuffs.BuffContainers.targetd, SpellCastBuffs.BuffContainers.targetd.preview.anchorLabel)

        -- Add grid snapping handler
        SpellCastBuffs.BuffContainers.targetd:SetHandler("OnMoveStop", function (self)
            local left, top = self:GetLeft(), self:GetTop()
            if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
                left, top = LUIE.ApplyGridSnap(left, top, "buffs")
                self:ClearAnchors()
                self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
            end
            SpellCastBuffs.SV.targetdOffsetX = left
            SpellCastBuffs.SV.targetdOffsetY = top
        end)
    end

    if SpellCastBuffs.BuffContainers.player_long then
        SpellCastBuffs.BuffContainers.player_long:SetMouseEnabled(state)
        SpellCastBuffs.BuffContainers.player_long:SetMovable(state)
        UpdatePositionLabel(SpellCastBuffs.BuffContainers.player_long, SpellCastBuffs.BuffContainers.player_long.preview.anchorLabel)

        -- Add grid snapping handler
        SpellCastBuffs.BuffContainers.player_long:SetHandler("OnMoveStop", function (self)
            local left, top = self:GetLeft(), self:GetTop()
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
        end)
    end

    if SpellCastBuffs.BuffContainers.prominentbuffs then
        SpellCastBuffs.BuffContainers.prominentbuffs:SetMouseEnabled(state)
        SpellCastBuffs.BuffContainers.prominentbuffs:SetMovable(state)
        UpdatePositionLabel(SpellCastBuffs.BuffContainers.prominentbuffs, SpellCastBuffs.BuffContainers.prominentbuffs.preview.anchorLabel)

        -- Add grid snapping handler
        SpellCastBuffs.BuffContainers.prominentbuffs:SetHandler("OnMoveStop", function (self)
            local left, top = self:GetLeft(), self:GetTop()
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
        end)
    end

    if SpellCastBuffs.BuffContainers.prominentdebuffs then
        SpellCastBuffs.BuffContainers.prominentdebuffs:SetMouseEnabled(state)
        SpellCastBuffs.BuffContainers.prominentdebuffs:SetMovable(state)
        UpdatePositionLabel(SpellCastBuffs.BuffContainers.prominentdebuffs, SpellCastBuffs.BuffContainers.prominentdebuffs.preview.anchorLabel)

        -- Add grid snapping handler
        SpellCastBuffs.BuffContainers.prominentdebuffs:SetHandler("OnMoveStop", function (self)
            local left, top = self:GetLeft(), self:GetTop()
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
        end)
    end

    -- Show/hide preview
    for _, v in pairs(SpellCastBuffs.containerRouting) do
        SpellCastBuffs.BuffContainers[v].preview:SetHidden(not state)
    end

    -- Now create or remove test-effects icons
    if state then
        SpellCastBuffs.MenuPreview()
    else
        SpellCastBuffs.Reset()
    end
end

-- Reset all buff containers
function SpellCastBuffs.Reset()
    if not SpellCastBuffs.Enabled then
        return
    end

    -- Update padding between icons
    SpellCastBuffs.padding = zo_floor(0.5 + SpellCastBuffs.SV.IconSize / 13)

    -- Set size of top level window
    -- Player
    if SpellCastBuffs.BuffContainers.playerb and SpellCastBuffs.BuffContainers.playerb:GetType() == CT_TOPLEVELCONTROL then
        SpellCastBuffs.BuffContainers.playerb:SetDimensions(SpellCastBuffs.SV.WidthPlayerBuffs, SpellCastBuffs.SV.IconSize + 6)
        SpellCastBuffs.BuffContainers.playerd:SetDimensions(SpellCastBuffs.SV.WidthPlayerDebuffs, SpellCastBuffs.SV.IconSize + 6)
        SpellCastBuffs.BuffContainers.playerb.maxIcons = zo_max(1, zo_floor((SpellCastBuffs.BuffContainers.playerb:GetWidth() - 4 * SpellCastBuffs.padding) / (SpellCastBuffs.SV.IconSize + SpellCastBuffs.padding)))
        SpellCastBuffs.BuffContainers.playerd.maxIcons = zo_max(1, zo_floor((SpellCastBuffs.BuffContainers.playerd:GetWidth() - 4 * SpellCastBuffs.padding) / (SpellCastBuffs.SV.IconSize + SpellCastBuffs.padding)))
    else
        SpellCastBuffs.BuffContainers.player2:SetHeight(SpellCastBuffs.SV.IconSize)
        SpellCastBuffs.BuffContainers.player2.firstAnchor = { TOPLEFT, TOP }
        SpellCastBuffs.BuffContainers.player2.maxIcons = zo_max(1, zo_floor((SpellCastBuffs.BuffContainers.player2:GetWidth() - 4 * SpellCastBuffs.padding) / (SpellCastBuffs.SV.IconSize + SpellCastBuffs.padding)))

        SpellCastBuffs.BuffContainers.player1:SetHeight(SpellCastBuffs.SV.IconSize)
        SpellCastBuffs.BuffContainers.player1.firstAnchor = { TOPLEFT, TOP }
        SpellCastBuffs.BuffContainers.player1.maxIcons = zo_max(1, zo_floor((SpellCastBuffs.BuffContainers.player1:GetWidth() - 4 * SpellCastBuffs.padding) / (SpellCastBuffs.SV.IconSize + SpellCastBuffs.padding)))
    end

    -- Target
    if SpellCastBuffs.BuffContainers.targetb and SpellCastBuffs.BuffContainers.targetb:GetType() == CT_TOPLEVELCONTROL then
        SpellCastBuffs.BuffContainers.targetb:SetDimensions(SpellCastBuffs.SV.WidthTargetBuffs, SpellCastBuffs.SV.IconSize + 6)
        SpellCastBuffs.BuffContainers.targetd:SetDimensions(SpellCastBuffs.SV.WidthTargetDebuffs, SpellCastBuffs.SV.IconSize + 6)
        SpellCastBuffs.BuffContainers.targetb.maxIcons = zo_max(1, zo_floor((SpellCastBuffs.BuffContainers.targetb:GetWidth() - 4 * SpellCastBuffs.padding) / (SpellCastBuffs.SV.IconSize + SpellCastBuffs.padding)))
        SpellCastBuffs.BuffContainers.targetd.maxIcons = zo_max(1, zo_floor((SpellCastBuffs.BuffContainers.targetd:GetWidth() - 4 * SpellCastBuffs.padding) / (SpellCastBuffs.SV.IconSize + SpellCastBuffs.padding)))
    else
        SpellCastBuffs.BuffContainers.target2:SetHeight(SpellCastBuffs.SV.IconSize)
        SpellCastBuffs.BuffContainers.target2.firstAnchor = { TOPLEFT, TOP }
        SpellCastBuffs.BuffContainers.target2.maxIcons = zo_max(1, zo_floor((SpellCastBuffs.BuffContainers.target2:GetWidth() - 4 * SpellCastBuffs.padding) / (SpellCastBuffs.SV.IconSize + SpellCastBuffs.padding)))

        SpellCastBuffs.BuffContainers.target1:SetHeight(SpellCastBuffs.SV.IconSize)
        SpellCastBuffs.BuffContainers.target1.firstAnchor = { TOPLEFT, TOP }
        SpellCastBuffs.BuffContainers.target1.maxIcons = zo_max(1, zo_floor((SpellCastBuffs.BuffContainers.target1:GetWidth() - 4 * SpellCastBuffs.padding) / (SpellCastBuffs.SV.IconSize + SpellCastBuffs.padding)))
    end

    -- Player long buffs
    if SpellCastBuffs.BuffContainers.player_long then
        if SpellCastBuffs.BuffContainers.player_long.alignVertical then
            SpellCastBuffs.BuffContainers.player_long:SetDimensions(SpellCastBuffs.SV.IconSize + 6, 400)
        else
            SpellCastBuffs.BuffContainers.player_long:SetDimensions(500, SpellCastBuffs.SV.IconSize + 6)
        end
    end

    -- Prominent buffs & debuffs
    if SpellCastBuffs.BuffContainers.prominentbuffs then
        if SpellCastBuffs.BuffContainers.prominentbuffs.alignVertical then
            SpellCastBuffs.BuffContainers.prominentbuffs:SetDimensions(SpellCastBuffs.SV.IconSize + 6, 400)
        else
            SpellCastBuffs.BuffContainers.prominentbuffs:SetDimensions(500, SpellCastBuffs.SV.IconSize + 6)
        end
        if SpellCastBuffs.BuffContainers.prominentdebuffs.alignVertical then
            SpellCastBuffs.BuffContainers.prominentdebuffs:SetDimensions(SpellCastBuffs.SV.IconSize + 6, 400)
        else
            SpellCastBuffs.BuffContainers.prominentdebuffs:SetDimensions(500, SpellCastBuffs.SV.IconSize + 6)
        end
    end

    -- Set Alignment and Sort Direction
    SpellCastBuffs.SetupContainerAlignment()
    SpellCastBuffs.SetupContainerSort()

    local needs_reset = {}
    -- And reset sizes of already existing icons
    for _, container in pairs(SpellCastBuffs.containerRouting) do
        needs_reset[container] = true
    end
    for _, container in pairs(SpellCastBuffs.containerRouting) do
        if needs_reset[container] then
            for i = 1, #SpellCastBuffs.BuffContainers[container].icons do
                SpellCastBuffs.ResetSingleIcon(container, SpellCastBuffs.BuffContainers[container].icons[i], SpellCastBuffs.BuffContainers[container].icons[i - 1])
            end
        end
        needs_reset[container] = false
    end

    if SpellCastBuffs.playerActive then
        SpellCastBuffs.ReloadEffects("player")
    end
end

-- Reset only a single icon
function SpellCastBuffs.ResetSingleIcon(container, buff, AnchorItem)
    local buffSize = SpellCastBuffs.SV.IconSize
    local frameSize = 2 * buffSize + 4

    buff:SetHidden(true)
    -- buff:SetAlpha( 1 )
    buff:SetDimensions(buffSize, buffSize)
    buff.frame:SetDimensions(frameSize, frameSize)
    buff.back:SetHidden(SpellCastBuffs.SV.GlowIcons)
    buff.frame:SetHidden(not SpellCastBuffs.SV.GlowIcons)
    buff.label:SetAnchor(TOPLEFT, buff, LEFT, -SpellCastBuffs.padding, -SpellCastBuffs.SV.LabelPosition)
    buff.label:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, SpellCastBuffs.padding, -2)
    buff.label:SetHidden(not SpellCastBuffs.SV.RemainingText)
    buff.stack:SetAnchor(CENTER, buff, BOTTOMLEFT, 0, 0)
    buff.stack:SetAnchor(CENTER, buff, TOPRIGHT, -SpellCastBuffs.padding * 3, SpellCastBuffs.padding * 3)
    buff.stack:SetHidden(true)

    if buff.name ~= nil then
        if (container == "prominentbuffs" and SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2) or (container == "prominentdebuffs" and SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2) then
            -- Vertical
            buff.name:SetHidden(not SpellCastBuffs.SV.ProminentLabel)
        else
            buff.name:SetHidden(true)
        end
    end

    if buff.bar ~= nil then
        if (container == "prominentbuffs" and SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2) or (container == "prominentdebuffs" and SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2) then
            -- Vertical
            buff.bar.backdrop:SetHidden(not SpellCastBuffs.SV.ProminentProgress)
            buff.bar.bar:SetHidden(not SpellCastBuffs.SV.ProminentProgress)
        else
            buff.bar.backdrop:SetHidden(true)
            buff.bar.bar:SetHidden(true)
        end
    end

    if buff.cd ~= nil then
        buff.cd:SetHidden(not SpellCastBuffs.SV.RemainingCooldown)
        -- We do not need black icon background when there is no Cooldown control present
        buff.iconbg:SetHidden(not SpellCastBuffs.SV.RemainingCooldown)
    end

    if buff.abilityId ~= nil then
        buff.abilityId:SetHidden(not SpellCastBuffs.SV.ShowDebugAbilityId)
    end

    local inset = (SpellCastBuffs.SV.RemainingCooldown and buff.cd ~= nil) and 3 or 1

    buff.drop:ClearAnchors()
    buff.drop:SetAnchor(TOPLEFT, buff, TOPLEFT, inset, inset)
    buff.drop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -inset, -inset)

    buff.icon:ClearAnchors()
    buff.icon:SetAnchor(TOPLEFT, buff, TOPLEFT, inset, inset)
    buff.icon:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -inset, -inset)
    if buff.iconbg ~= nil then
        buff.iconbg:ClearAnchors()
        buff.iconbg:SetAnchor(TOPLEFT, buff, TOPLEFT, inset, inset)
        buff.iconbg:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -inset, -inset)
    end

    if container == "prominentbuffs" then
        if SpellCastBuffs.SV.ProminentBuffLabelDirection == "Left" then
            buff.name:ClearAnchors()
            buff.name:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, -(SpellCastBuffs.SV.IconSize * 0.25) + 2)
            buff.name:SetAnchor(TOPRIGHT, buff, TOPLEFT, -4, -(SpellCastBuffs.SV.IconSize * 0.25) + 2)

            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)
            buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[SpellCastBuffs.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
        else
            buff.name:ClearAnchors()
            buff.name:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, -(SpellCastBuffs.SV.IconSize * 0.25) + 2)
            buff.name:SetAnchor(TOPLEFT, buff, TOPRIGHT, 4, -(SpellCastBuffs.SV.IconSize * 0.25) + 2)

            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)
            buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[SpellCastBuffs.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
        end
    end

    if container == "prominentdebuffs" then
        if SpellCastBuffs.SV.ProminentDebuffLabelDirection == "Right" then
            buff.name:ClearAnchors()
            buff.name:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, -(SpellCastBuffs.SV.IconSize * 0.25) + 2)
            buff.name:SetAnchor(TOPLEFT, buff, TOPRIGHT, 4, -(SpellCastBuffs.SV.IconSize * 0.25) + 2)

            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)
            buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[SpellCastBuffs.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
        else
            buff.name:ClearAnchors()
            buff.name:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, -(SpellCastBuffs.SV.IconSize * 0.25) + 2)
            buff.name:SetAnchor(TOPRIGHT, buff, TOPLEFT, -4, -(SpellCastBuffs.SV.IconSize * 0.25) + 2)

            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)
            buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[SpellCastBuffs.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
        end
    end

    -- Position all items except first one to the right of it's neighbor
    -- First icon is positioned automatically if the container is present
    buff:ClearAnchors()
    if AnchorItem == nil then
        -- First Icon is positioned only when the container is present,
        if SpellCastBuffs.BuffContainers[container].iconHolder then
            if SpellCastBuffs.BuffContainers[container].alignVertical then
                buff:SetAnchor(BOTTOM, SpellCastBuffs.BuffContainers[container].iconHolder, BOTTOM, 0, 0)
            else
                buff:SetAnchor(LEFT, SpellCastBuffs.BuffContainers[container].iconHolder, LEFT, 0, 0)
            end
        end

        -- For container without holder we will reanchor first icon all the time
        -- Rest icons go one after another.
    else
        if SpellCastBuffs.BuffContainers[container].alignVertical then
            buff:SetAnchor(BOTTOM, AnchorItem, TOP, 0, -SpellCastBuffs.padding)
        else
            buff:SetAnchor(LEFT, AnchorItem, RIGHT, SpellCastBuffs.padding, 0)
        end
    end
end

-- Right Click Cancel Buff function
function SpellCastBuffs.Buff_OnMouseUp(self, button, upInside)
    if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
        ClearMenu()
        local id, name = self.effectId, self.effectName

        -- Blacklist
        local blacklist = SpellCastBuffs.SV.BlacklistTable
        local isBlacklisted = blacklist[id] or blacklist[name]
        AddMenuItem(isBlacklisted and "Remove from Blacklist" or "Add to Blacklist", function ()
            if isBlacklisted then
                SpellCastBuffs.RemoveFromCustomList(blacklist, id)
                SpellCastBuffs.RemoveFromCustomList(blacklist, name)
            else
                SpellCastBuffs.AddToCustomList(blacklist, id)
                SpellCastBuffs.AddToCustomList(blacklist, name)
            end
        end)

        -- Prominent Buffs
        local promBuffs = SpellCastBuffs.SV.PromBuffTable
        local isPromBuff = promBuffs[id] or promBuffs[name]
        AddMenuItem(isPromBuff and "Remove from Prominent Buffs" or "Add to Prominent Buffs", function ()
            if isPromBuff then
                SpellCastBuffs.RemoveFromCustomList(promBuffs, id)
                SpellCastBuffs.RemoveFromCustomList(promBuffs, name)
            else
                SpellCastBuffs.AddToCustomList(promBuffs, id)
                SpellCastBuffs.AddToCustomList(promBuffs, name)
            end
        end)

        -- Prominent Debuffs
        local promDebuffs = SpellCastBuffs.SV.PromDebuffTable
        local isPromDebuff = promDebuffs[id] or promDebuffs[name]
        AddMenuItem(isPromDebuff and "Remove from Prominent Debuffs" or "Add to Prominent Debuffs", function ()
            if isPromDebuff then
                SpellCastBuffs.RemoveFromCustomList(promDebuffs, id)
                SpellCastBuffs.RemoveFromCustomList(promDebuffs, name)
            else
                SpellCastBuffs.AddToCustomList(promDebuffs, id)
                SpellCastBuffs.AddToCustomList(promDebuffs, name)
            end
        end)

        -- Cancel Buff (if possible)
        if self.buffSlot then
            AddMenuItem("Cancel Buff", function ()
                CancelBuff(self.buffSlot)
            end)
        end
        ShowMenu(self)
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

function SpellCastBuffs.TooltipBottomLine(control, detailsLine, artificial)
    -- Add bottom divider and info if present:
    if SpellCastBuffs.SV.TooltipAbilityId or SpellCastBuffs.SV.TooltipBuffType then
        ZO_Tooltip_AddDivider(GameTooltip)
        GameTooltip:SetVerticalPadding(4)
        GameTooltip:AddLine("", "", ZO_NORMAL_TEXT:UnpackRGB())
        -- Add Ability ID Line
        if SpellCastBuffs.SV.TooltipAbilityId then
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
        if SpellCastBuffs.SV.TooltipBuffType then
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
function SpellCastBuffs.Buff_OnMouseEnter(control)
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
        if SpellCastBuffs.SV.TooltipEnable then
            GameTooltip:SetVerticalPadding(1)
            ZO_Tooltip_AddDivider(GameTooltip)
            GameTooltip:SetVerticalPadding(5)
            GameTooltip:AddLine(tooltipText, "", colorText:UnpackRGBA())
            detailsLine = 5
        end
        SpellCastBuffs.TooltipBottomLine(control, detailsLine, true)
    else
        if not SpellCastBuffs.SV.TooltipEnable then
            GameTooltip:AddLine(tooltipTitle, "ZoFontHeader2", 1, 1, 1, nil)
            detailsLine = 3
            SpellCastBuffs.TooltipBottomLine(control, detailsLine)
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
        if not LUIE.SpellCastBuffs.SV.TooltipCustom then
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

        SpellCastBuffs.TooltipBottomLine(control, detailsLine)

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
function SpellCastBuffs.Buff_OnMouseExit(control)
    if SpellCastBuffs.SV.TooltipSticky > 0 then
        eventManager:RegisterForUpdate(moduleName .. "StickyTooltip", SpellCastBuffs.SV.TooltipSticky, ClearStickyTooltip)
    else
        ClearTooltip(GameTooltip)
    end
end

-- Updates local variable with new font and resets all existing icons
function SpellCastBuffs.ApplyFont()
    if not SpellCastBuffs.Enabled then
        return
    end

    -- Font setup for standard Buffs & Debuffs
    local fontName = LUIE.Fonts[SpellCastBuffs.SV.BuffFontFace]
    if not fontName or fontName == "" then
        LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
        fontName = "LUIE Default Font"
    end
    local fontStyle = SpellCastBuffs.SV.BuffFontStyle
    local fontSize = (SpellCastBuffs.SV.BuffFontSize and SpellCastBuffs.SV.BuffFontSize > 0) and SpellCastBuffs.SV.BuffFontSize or 17
    SpellCastBuffs.buffsFont = ZO_CreateFontString(fontName, fontSize, fontStyle)

    -- Font Setup for Prominent Buffs & Debuffs
    local prominentName = LUIE.Fonts[SpellCastBuffs.SV.ProminentLabelFontFace]
    if not prominentName or prominentName == "" then
        LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
        prominentName = "LUIE Default Font"
    end
    local prominentStyle = SpellCastBuffs.SV.ProminentLabelFontStyle
    local prominentSize = (SpellCastBuffs.SV.ProminentLabelFontSize and SpellCastBuffs.SV.ProminentLabelFontSize > 0) and SpellCastBuffs.SV.ProminentLabelFontSize or 17
    SpellCastBuffs.prominentFont = ZO_CreateFontString(prominentName, prominentSize, prominentStyle)

    local needs_reset = {}
    -- And reset sizes of already existing icons
    for _, container in pairs(SpellCastBuffs.containerRouting) do
        needs_reset[container] = true
    end
    for _, container in pairs(SpellCastBuffs.containerRouting) do
        if needs_reset[container] then
            for i = 1, #SpellCastBuffs.BuffContainers[container].icons do
                -- Set label font
                SpellCastBuffs.BuffContainers[container].icons[i].label:SetFont(SpellCastBuffs.buffsFont)
                -- Set prominent buff label font
                if SpellCastBuffs.BuffContainers[container].icons[i].name then
                    SpellCastBuffs.BuffContainers[container].icons[i].name:SetFont(SpellCastBuffs.prominentFont)
                end
            end
        end
        needs_reset[container] = false
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

-- Handles removal of artificial effects
local function handleEffectRemoval(effectId)
    local removeEffect = effectId
    if effectId == ARTIFICIAL_EFFECTS.BATTLE_SPIRIT or effectId == ARTIFICIAL_EFFECTS.BATTLE_SPIRIT_IC then
        removeEffect = 999014
    end

    local displayName = GetDisplayName()
    local context = SpellCastBuffs.DetermineContextSimple("player1", removeEffect, displayName)
    SpellCastBuffs.EffectsList[context][removeEffect] = nil
end

-- Creates effect data structure
local function createEffectData(effectId, displayName, iconFile, effectType, startTime, endTime, duration, tooltip, artificial)
    return
    {
        target = SpellCastBuffs.DetermineTarget("player1"),
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
function SpellCastBuffs.ArtificialEffectUpdate(eventCode, effectId)
    -- Early exit if player buffs are hidden
    if SpellCastBuffs.SV.HidePlayerBuffs then
        return
    end

    -- Handle effect removal if effectId is provided
    if effectId then
        handleEffectRemoval(effectId)
    end

    -- Process active artificial effects
    for activeEffectId in ZO_GetNextActiveArtificialEffectIdIter do
        -- Skip if effect should be ignored based on settings
        if (activeEffectId == ARTIFICIAL_EFFECTS.ESO_PLUS and SpellCastBuffs.SV.IgnoreEsoPlusPlayer) or
        ((activeEffectId == ARTIFICIAL_EFFECTS.BATTLE_SPIRIT or activeEffectId == ARTIFICIAL_EFFECTS.BATTLE_SPIRIT_IC) and
            SpellCastBuffs.SV.IgnoreBattleSpiritPlayer) then
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
        local context = SpellCastBuffs.DetermineContextSimple("player1", effectId, displayName)
        SpellCastBuffs.EffectsList[context][effectId] = createEffectData(
            effectId, displayName, iconFile, effectType, startTime,
            endTime, duration, tooltip, artificial
        )
    end
end

-- EVENT_BOSSES_CHANGED handler
function SpellCastBuffs.AddNameOnBossEngaged(eventCode)
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
    if not SpellCastBuffs.SV.HideTargetBuffs then
        SpellCastBuffs.AddNameAura()
    end
end

-- Called from EVENT_PLAYER_ACTIVATED
function SpellCastBuffs.AddZoneBuffs()
    local zoneId = GetZoneId(GetCurrentMapZoneIndex())
    if Effects.ZoneBuffs[zoneId] then
        local abilityId = Effects.ZoneBuffs[zoneId]
        local abilityName = GetAbilityName(abilityId)
        local abilityIcon = GetAbilityIcon(abilityId)
        local beginTime = GetFrameTimeMilliseconds()
        local stack
        local groundLabel
        local toggle

        local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
        SpellCastBuffs.EffectsList.player1[abilityId] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
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
function SpellCastBuffs.OnDeath(eventCode, unitTag, isDead)
    -- Wipe buffs
    if isDead then
        if unitTag == "player" then
            -- Clear all player/ground/prominent containers
            local context = { "player1", "player2", "ground", "promb_ground", "promd_ground", "promb_player", "promd_player" }
            for _, v in pairs(context) do
                SpellCastBuffs.EffectsList[v] = {}
            end

            -- If werewolf is active, reset the icon so it's not removed (otherwise it flashes off for about a second until the trailer function picks up on the fact that no power drain has occurred.
            if SpellCastBuffs.SV.ShowWerewolf and IsPlayerInWerewolfForm() then
                SpellCastBuffs.WerewolfState(nil, true, true)
            end
        else
            -- TODO: Do we need to clear prominent target containers here? (Don't think so)
            for effectType = BUFF_EFFECT_TYPE_BUFF, BUFF_EFFECT_TYPE_DEBUFF do
                SpellCastBuffs.EffectsList[unitTag .. effectType] = {}
            end
        end
    end
end

-- Runs on the EVENT_DISPOSITION_UPDATE listener.
-- This handler fires when the disposition of a reticleover unitTag changes. We filter for only this case.
function SpellCastBuffs.OnDispositionUpdate(eventCode, unitTag)
    if not SpellCastBuffs.SV.HideTargetBuffs then
        SpellCastBuffs.AddNameAura()
    end
end

-- Runs on the EVENT_TARGET_CHANGE listener.
-- This handler fires every time someone target changes.
-- This function is needed in case the player teleports via Way Shrine
function SpellCastBuffs.OnTargetChange(eventCode, unitTag)
    if unitTag ~= "player" then
        return
    end
    SpellCastBuffs.OnReticleTargetChanged(eventCode)
end

-- Runs on the EVENT_RETICLE_TARGET_CHANGED listener.
-- This handler fires every time the player's reticle target changes
function SpellCastBuffs.OnReticleTargetChanged(eventCode)
    SpellCastBuffs.ReloadEffects("reticleover")
end

-- Called by SpellCastBuffs.ReloadEffects - Displays recall cooldown
function SpellCastBuffs.ShowRecallCooldown()
    local recallRemain, _ = GetRecallCooldown()
    if recallRemain > 0 then
        local currentTimeMs = GetFrameTimeMilliseconds()
        local abilityId = 999016
        local abilityName = Abilities.Innate_Recall_Penalty
        local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
        SpellCastBuffs.EffectsList[context][abilityName] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
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
function SpellCastBuffs.RestoreSavedFakeEffects()
    -- Restore Ground Effects
    for _, effectsList in pairs({ SpellCastBuffs.EffectsList.ground, SpellCastBuffs.EffectsList.saved }) do
        -- local container = SpellCastBuffs.containerRouting[context]
        for k, v in pairs(effectsList) do
            if v.savedName ~= nil then
                local unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("reticleover"))
                if unitName == v.savedName then
                    if SpellCastBuffs.EffectsList.saved[k] then
                        SpellCastBuffs.EffectsList.ground[k] = SpellCastBuffs.EffectsList.saved[k]
                        SpellCastBuffs.EffectsList.ground[k].iconNum = 0
                        SpellCastBuffs.EffectsList.saved[k] = nil
                    end
                else
                    if SpellCastBuffs.EffectsList.ground[k] then
                        SpellCastBuffs.EffectsList.saved[k] = SpellCastBuffs.EffectsList.ground[k]
                        SpellCastBuffs.EffectsList.ground[k] = nil
                    end
                end
            end
        end
    end
end

-- Called by EVENT_RETICLE_TARGET_CHANGED listener - Displays fake buffs based off unitName (primarily for displaying Boss Immunities)
function SpellCastBuffs.AddNameAura()
    local unitName = GetUnitName("reticleover")
    -- We need to check to make sure the mob is not dead, and also check to make sure the unitTag is not the player (just in case someones name exactly matches that of a boss NPC)
    if Effects.AddNameAura[unitName] and GetUnitReaction("reticleover") == UNIT_REACTION_HOSTILE and not IsUnitPlayer("reticleover") and not IsUnitDead("reticleover") then
        for k, v in pairs(Effects.AddNameAura[unitName]) do
            local abilityName = GetAbilityName(v.id)
            local abilityIcon = GetAbilityIcon(v.id)

            -- Bail out if this ability is blacklisted
            if SpellCastBuffs.SV.BlacklistTable[v.id] or SpellCastBuffs.SV.BlacklistTable[abilityName] then
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
            context = SpellCastBuffs.DetermineContext(context, abilityId, abilityName)
            SpellCastBuffs.EffectsList[context]["Name Specific Buff" .. k] =
            {
                target = SpellCastBuffs.DetermineTarget(context),
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
function SpellCastBuffs.MenuPreview()
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
            SpellCastBuffs.EffectsList[context][abilityId] =
            {
                target = SpellCastBuffs.DetermineTarget(context),
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
function SpellCastBuffs.OnPlayerActivated(eventCode)
    SpellCastBuffs.playerActive = true
    SpellCastBuffs.playerResurrectStage = nil

    -- Reload Effects
    SpellCastBuffs.ReloadEffects("player")
    SpellCastBuffs.AddNameOnBossEngaged()

    -- Load Zone Specific Buffs
    if not SpellCastBuffs.SV.HidePlayerBuffs then
        SpellCastBuffs.AddZoneBuffs()
    end

    -- Resolve Duel Target
    SpellCastBuffs.DuelStart()

    -- Resolve Mounted icon
    if not SpellCastBuffs.SV.IgnoreMountPlayer and IsMounted() then
        zo_callLater(function ()
                         SpellCastBuffs.MountStatus(nil, true)
                     end, 50)
    end

    -- Resolve Disguise Icon
    if not SpellCastBuffs.SV.IgnoreDisguise then
        zo_callLater(function ()
                         SpellCastBuffs.DisguiseItem(nil, BAG_WORN, 10, nil, nil, nil, nil, nil, nil, nil, nil)
                     end, 50)
    end

    -- Resolve Assistant Icon
    if not SpellCastBuffs.SV.IgnorePet or not SpellCastBuffs.SV.IgnoreAssistant then
        zo_callLater(function ()
                         SpellCastBuffs.CollectibleBuff()
                     end, 50)
    end

    -- Resolve Werewolf
    if SpellCastBuffs.SV.ShowWerewolf and IsPlayerInWerewolfForm() then
        SpellCastBuffs.WerewolfState(nil, true, true)
    end

    -- Sets the player to dead if reloading UI or loading in while dead.
    if IsUnitDead("player") then
        SpellCastBuffs.playerDead = true
    end
end

-- Runs on the EVENT_PLAYER_DEACTIVATED listener
function SpellCastBuffs.OnPlayerDeactivated(eventCode)
    SpellCastBuffs.playerActive = false
    SpellCastBuffs.playerResurrectStage = nil
end

-- Runs on the EVENT_PLAYER_ALIVE listener
function SpellCastBuffs.OnPlayerAlive(eventCode)
    --[[-- If player clicks "Resurrect at Wayshrine", then player is first deactivated, then he is transferred to new position, then he becomes alive (this event) then player is activated again.
    To register resurrection we need to work in this function if player is already active. --]]
    --
    if not SpellCastBuffs.playerActive or not SpellCastBuffs.playerDead then
        return
    end

    SpellCastBuffs.playerDead = false

    -- This is a good place to reload player buffs, as they were wiped on death
    SpellCastBuffs.ReloadEffects("player")

    -- Start Resurrection Sequence
    SpellCastBuffs.playerResurrectStage = 1
    --[[If it was self resurrection, then there will be 4 EVENT_VIBRATION:
    First - 600ms, Second - 0ms to switch first one off, Third - 350ms, Fourth - 0ms to switch third one off.
    So now we'll listen in the vibration event and progress SpellCastBuffs.playerResurrectStage with first 2 events and then on correct third event we'll create a buff. --]]
end

-- Runs on the EVENT_PLAYER_DEAD listener
function SpellCastBuffs.OnPlayerDead(eventCode)
    if not SpellCastBuffs.playerActive then
        return
    end
    SpellCastBuffs.playerDead = true
end

-- Runs on the EVENT_VIBRATION listener (detects player resurrection stage)
function SpellCastBuffs.OnVibration(eventCode, duration, coarseMotor, fineMotor, leftTriggerMotor, rightTriggerMotor)
    if not SpellCastBuffs.playerResurrectStage then
        return
    end
    if SpellCastBuffs.SV.HidePlayerBuffs then
        return
    end
    if SpellCastBuffs.playerResurrectStage == 1 and duration == 600 then
        SpellCastBuffs.playerResurrectStage = 2
    elseif SpellCastBuffs.playerResurrectStage == 2 and duration == 0 then
        SpellCastBuffs.playerResurrectStage = 3
    elseif SpellCastBuffs.playerResurrectStage == 3 and duration == 350 and SpellCastBuffs.SV.ShowResurrectionImmunity then
        -- We got correct sequence, so let us create a buff and reset the SpellCastBuffs.playerResurrectStage
        SpellCastBuffs.playerResurrectStage = nil
        local currentTimeMs = GetFrameTimeMilliseconds()
        local abilityId = 14646
        local abilityName = Abilities.Innate_Resurrection_Immunity
        local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
        SpellCastBuffs.EffectsList[context][abilityId] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
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
        SpellCastBuffs.playerResurrectStage = nil
    end
end
