-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
local GridOverlay = LUIE.GridOverlay

local function ApplyCustomShieldBarLayoutRefresh()
    UnitFrames.CustomFramesApplyAllLayouts(
        {
            includeRaid = false,
            includeBosses = false,
            includeCompanionPetUpdates = false,
        })
end

function UnitFrames.OnCustomShieldBarSettingsChanged(applyLayout)
    UnitFrames.CustomFramesApplyShieldBarMode()
    if applyLayout then
        ApplyCustomShieldBarLayoutRefresh()
    end
    UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
    UnitFrames.CustomFramesApplyColorsMenuCompanionFrameOnly()
    UnitFrames.CustomFramesApplyColorsMenuPetFramesOnly()
    UnitFrames.RefreshCustomFrameShields()
end

function UnitFrames.MenuUpdatePlayerFrameOptions(option)
    if UnitFrames.CustomFrames["reticleover"] then
        local reticleover = UnitFrames.CustomFrames["reticleover"]
        if option == 1 then
            reticleover.buffs:ClearAnchors()
            reticleover.debuffs:ClearAnchors()
            reticleover.buffs:SetAnchor(TOP, reticleover.buffAnchor, BOTTOM, 0, 2)
            reticleover.debuffs:SetAnchor(BOTTOM, reticleover.topInfo, TOP, 0, -2)
        else
            reticleover.buffs:ClearAnchors()
            reticleover.debuffs:ClearAnchors()
            reticleover.buffs:SetAnchor(BOTTOM, reticleover.topInfo, TOP, 0, -2)
            reticleover.debuffs:SetAnchor(TOP, reticleover.buffAnchor, BOTTOM, 0, 2)
        end
    end
    UnitFrames.CustomFramesSetPositions()
    UnitFrames.CustomFramesSetupAlternative()
    UnitFrames.CustomFramesApplyAllLayouts({ playerTriadOnly = true })
end

local LUIE_COMPASS_BOSS_BAR_HIDDEN_REASON = "LUIE_CustomBossFrames"

function UnitFrames.ResetCompassBarMenu()
    local useCompassBossBar = UnitFrames.GetEffectiveDefaultFramesMode("Boss") == UnitFrames.DEFAULT_FRAMES_MODE_KEEP_DEFAULT
    COMPASS_FRAME:SetBossBarHiddenForReason(LUIE_COMPASS_BOSS_BAR_HIDDEN_REASON, not useCompassBossBar)
    if useCompassBossBar then
        for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
            local unitTag = "boss" .. i
            if DoesUnitExist(unitTag) then
                COMPASS_FRAME:SetBossBarActive(true)
            end
        end
    else
        COMPASS_FRAME:SetBossBarActive(false)
    end
end

--- While reposition mode is on, disable mouse on group/raid member controls so the movable TLW receives drags.
local sceneManager = SCENE_MANAGER
--- @type LUIE.CustomFramesShared
local CustomFramesShared = LUIE.CustomFramesShared

--- Custom frame TLWs use ZO_HUDFadeSceneFragment on the same scenes as default UNIT_FRAMES_FRAGMENT.
--- @return boolean
local function CustomFramesIsHudGameplaySceneActive()
    local scene = sceneManager:GetCurrentScene()
    if not scene or scene:GetState() ~= SCENE_SHOWN then
        return false
    end
    return CustomFramesShared.IsCustomFrameHudScene(scene)
end

--- Raid tiles the TLW with mouse-enabled children; small group leaves gaps but this keeps behavior consistent.
--- @param enabled boolean True to restore mouse (normal play), false during frame moving.
local function CustomFramesSetGroupMemberMouseEnabledForMoving(enabled)
    local manager = UnitFrames.CustomFramesManager
    manager:ForEachFrameInBucket("smallGroup", function (_, frame)
        if frame.control then
            frame.control:SetMouseEnabled(enabled)
            if frame.topInfo then
                frame.topInfo:SetMouseEnabled(enabled)
            end
        end
    end)
    manager:ForEachFrameInBucket("raid", function (_, frame)
        if frame.control then
            frame.control:SetMouseEnabled(enabled)
        end
    end)
end

-- Unlock CustomFrames for moving. Called from Settings Menu.
function UnitFrames.CustomFramesSetMovingState(state)
    UnitFrames.CustomFramesMovingState = state

    local accountWideSettings = LUIE.GetCoreAccountWideRawTable()
    local gridEnabled = accountWideSettings and accountWideSettings.snapToGrid_unitFrames
    local gridSize = (accountWideSettings and accountWideSettings.snapToGridSize_default) or 15
    GridOverlay.Refresh("unitFrames", state and gridEnabled, gridSize)

    -- PC/Keyboard version
    -- Unlock individual frames
    CustomFramesShared.ForEachMovableAnchorFrame(function (_, _, tlw)
        if tlw.preview then
            tlw.preview:SetHidden(not state) -- player frame does not have 'preview' control
        end
        if state then
            local left, top = tlw:GetLeft(), tlw:GetTop()
            tlw:ClearAnchors()
            tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
            tlw:SetHidden(false)
        elseif not CustomFramesIsHudGameplaySceneActive() then
            -- Unlock forces visible on GuiRoot; hide again when not on a HUD gameplay scene (e.g. gameMenuInGame).
            tlw:SetHidden(true)
        end
        tlw:SetMouseEnabled(state)
        tlw:SetMovable(state)

        --- @param self LUIE_PositionableTopLevelWindow
        local function OnMoveStop(self)
            local left, top = self:GetLeft(), self:GetTop()
            left, top = LUIE.ApplyGridSnap(left, top, "unitFrames")
            self:ClearAnchors()
            self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
            UnitFrames.SV[self.customPositionAttr] = { left, top }
        end
        tlw:SetHandler("OnMoveStop", OnMoveStop)
    end)

    -- Unlock buffs for Player (preview control is created in SpellCastBuffs module)
    if UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"].tlw then
        if UnitFrames.CustomFrames["player"].buffs.preview then
            UnitFrames.CustomFrames["player"].buffs.preview:SetHidden(not state)
        end
        if UnitFrames.CustomFrames["player"].debuffs.preview then
            UnitFrames.CustomFrames["player"].debuffs.preview:SetHidden(not state)
        end
    end

    -- Unlock buffs and debuffs for Target (preview controls are created in LTE and SpellCastBuffs modules)
    if UnitFrames.CustomFrames["reticleover"] and UnitFrames.CustomFrames["reticleover"].tlw then
        if UnitFrames.CustomFrames["reticleover"].buffs.preview then
            UnitFrames.CustomFrames["reticleover"].buffs.preview:SetHidden(not state)
        end
        if UnitFrames.CustomFrames["reticleover"].debuffs.preview then
            UnitFrames.CustomFrames["reticleover"].debuffs.preview:SetHidden(not state)
        end
        -- Make this hack so target window is not going to be hidden:
        -- Target Frame will now always display old information
        UnitFrames.CustomFrames["reticleover"].canHide = not state
    end

    CustomFramesSetGroupMemberMouseEnabledForMoving(not state)

    if not state then
        UnitFrames.CustomFramesSetPositions()
    end
end

-- Apply colors to custom frame subsets for LAM (avoids repainting unrelated unit tag tables).
--- @param sections { all?: boolean, healthFamily?: boolean, playerMagickaStamina?: boolean, companion?: boolean, pet?: boolean, groupRaid?: boolean }|nil
local function CustomFramesApplyColorsInternal(sections)
    local health =
    {
        UnitFrames.SV.CustomColourHealth[1],
        UnitFrames.SV.CustomColourHealth[2],
        UnitFrames.SV.CustomColourHealth[3],
        UnitFrames.SV.CustomColourHealth[4],
    }
    local shield =
    {
        UnitFrames.SV.CustomColourShield[1],
        UnitFrames.SV.CustomColourShield[2],
        UnitFrames.SV.CustomColourShield[3],
        UnitFrames.SV.CustomColourShield[4],
    }
    local trauma =
    {
        UnitFrames.SV.CustomColourTrauma[1],
        UnitFrames.SV.CustomColourTrauma[2],
        UnitFrames.SV.CustomColourTrauma[3],
        UnitFrames.SV.CustomColourTrauma[4],
    }
    local magicka =
    {
        UnitFrames.SV.CustomColourMagicka[1],
        UnitFrames.SV.CustomColourMagicka[2],
        UnitFrames.SV.CustomColourMagicka[3],
        UnitFrames.SV.CustomColourMagicka[4],
    }
    local stamina =
    {
        UnitFrames.SV.CustomColourStamina[1],
        UnitFrames.SV.CustomColourStamina[2],
        UnitFrames.SV.CustomColourStamina[3],
        UnitFrames.SV.CustomColourStamina[4],
    }

    local dps =
    {
        UnitFrames.SV.CustomColourDPS[1],
        UnitFrames.SV.CustomColourDPS[2],
        UnitFrames.SV.CustomColourDPS[3],
        UnitFrames.SV.CustomColourDPS[4],
    }
    local healer =
    {
        UnitFrames.SV.CustomColourHealer[1],
        UnitFrames.SV.CustomColourHealer[2],
        UnitFrames.SV.CustomColourHealer[3],
        UnitFrames.SV.CustomColourHealer[4],
    }
    local tank =
    {
        UnitFrames.SV.CustomColourTank[1],
        UnitFrames.SV.CustomColourTank[2],
        UnitFrames.SV.CustomColourTank[3],
        UnitFrames.SV.CustomColourTank[4],
    }
    local invalid = { 75 / 255, 75 / 255, 75 / 255, 0.9 }

    local class1 =
    {
        UnitFrames.SV.CustomColourDragonknight[1],
        UnitFrames.SV.CustomColourDragonknight[2],
        UnitFrames.SV.CustomColourDragonknight[3],
        UnitFrames.SV.CustomColourDragonknight[4],
    } -- Dragonkight
    local class2 =
    {
        UnitFrames.SV.CustomColourSorcerer[1],
        UnitFrames.SV.CustomColourSorcerer[2],
        UnitFrames.SV.CustomColourSorcerer[3],
        UnitFrames.SV.CustomColourSorcerer[4],
    } -- Sorcerer
    local class3 =
    {
        UnitFrames.SV.CustomColourNightblade[1],
        UnitFrames.SV.CustomColourNightblade[2],
        UnitFrames.SV.CustomColourNightblade[3],
        UnitFrames.SV.CustomColourNightblade[4],
    } -- Nightblade
    local class4 =
    {
        UnitFrames.SV.CustomColourWarden[1],
        UnitFrames.SV.CustomColourWarden[2],
        UnitFrames.SV.CustomColourWarden[3],
        UnitFrames.SV.CustomColourWarden[4],
    } -- Warden
    local class5 =
    {
        UnitFrames.SV.CustomColourNecromancer[1],
        UnitFrames.SV.CustomColourNecromancer[2],
        UnitFrames.SV.CustomColourNecromancer[3],
        UnitFrames.SV.CustomColourNecromancer[4],
    } -- Necromancer
    local class6 =
    {
        UnitFrames.SV.CustomColourTemplar[1],
        UnitFrames.SV.CustomColourTemplar[2],
        UnitFrames.SV.CustomColourTemplar[3],
        UnitFrames.SV.CustomColourTemplar[4],
    } -- Templar
    local class117 =
    {
        UnitFrames.SV.CustomColourArcanist[1],
        UnitFrames.SV.CustomColourArcanist[2],
        UnitFrames.SV.CustomColourArcanist[3],
        UnitFrames.SV.CustomColourArcanist[4],
    }                                                                                                                                                           -- Arcanist

    local petcolor = { UnitFrames.SV.CustomColourPet[1], UnitFrames.SV.CustomColourPet[2], UnitFrames.SV.CustomColourPet[3], UnitFrames.SV.CustomColourPet[4] } -- Player Pet
    local companioncolor =
    {
        UnitFrames.SV.CustomColourCompanionFrame[1],
        UnitFrames.SV.CustomColourCompanionFrame[2],
        UnitFrames.SV.CustomColourCompanionFrame[3],
        UnitFrames.SV.CustomColourCompanionFrame[4],
    } -- Companion

    local health_bg =
    {
        0.1 * UnitFrames.SV.CustomColourHealth[1],
        0.1 * UnitFrames.SV.CustomColourHealth[2],
        0.1 * UnitFrames.SV.CustomColourHealth[3],
        UnitFrames.SV.CustomColourHealth[4],
    }
    local shield_bg =
    {
        0.1 * UnitFrames.SV.CustomColourShield[1],
        0.1 * UnitFrames.SV.CustomColourShield[2],
        0.1 * UnitFrames.SV.CustomColourShield[3],
        UnitFrames.SV.CustomColourShield[4],
    }
    local magicka_bg =
    {
        0.1 * UnitFrames.SV.CustomColourMagicka[1],
        0.1 * UnitFrames.SV.CustomColourMagicka[2],
        0.1 * UnitFrames.SV.CustomColourMagicka[3],
        UnitFrames.SV.CustomColourMagicka[4],
    }
    local stamina_bg =
    {
        0.1 * UnitFrames.SV.CustomColourStamina[1],
        0.1 * UnitFrames.SV.CustomColourStamina[2],
        0.1 * UnitFrames.SV.CustomColourStamina[3],
        UnitFrames.SV.CustomColourStamina[4],
    }

    local dps_bg =
    {
        0.1 * UnitFrames.SV.CustomColourDPS[1],
        0.1 * UnitFrames.SV.CustomColourDPS[2],
        0.1 * UnitFrames.SV.CustomColourDPS[3],
        UnitFrames.SV.CustomColourDPS[4],
    }
    local healer_bg =
    {
        0.1 * UnitFrames.SV.CustomColourHealer[1],
        0.1 * UnitFrames.SV.CustomColourHealer[2],
        0.1 * UnitFrames.SV.CustomColourHealer[3],
        UnitFrames.SV.CustomColourHealer[4],
    }
    local tank_bg =
    {
        0.1 * UnitFrames.SV.CustomColourTank[1],
        0.1 * UnitFrames.SV.CustomColourTank[2],
        0.1 * UnitFrames.SV.CustomColourTank[3],
        UnitFrames.SV.CustomColourTank[4],
    }
    local invalid_bg = { 0.1 * invalid[1], 0.1 * invalid[2], 0.1 * invalid[3], invalid[4] }

    local class1_bg =
    {
        0.1 * UnitFrames.SV.CustomColourDragonknight[1],
        0.1 * UnitFrames.SV.CustomColourDragonknight[2],
        0.1 * UnitFrames.SV.CustomColourDragonknight[3],
        UnitFrames.SV.CustomColourDragonknight[4],
    } -- Dragonkight
    local class2_bg =
    {
        0.1 * UnitFrames.SV.CustomColourSorcerer[1],
        0.1 * UnitFrames.SV.CustomColourSorcerer[2],
        0.1 * UnitFrames.SV.CustomColourSorcerer[3],
        UnitFrames.SV.CustomColourSorcerer[4],
    } -- Sorcerer
    local class3_bg =
    {
        0.1 * UnitFrames.SV.CustomColourNightblade[1],
        0.1 * UnitFrames.SV.CustomColourNightblade[2],
        0.1 * UnitFrames.SV.CustomColourNightblade[3],
        UnitFrames.SV.CustomColourNightblade[4],
    } -- Nightblade
    local class4_bg =
    {
        0.1 * UnitFrames.SV.CustomColourWarden[1],
        0.1 * UnitFrames.SV.CustomColourWarden[2],
        0.1 * UnitFrames.SV.CustomColourWarden[3],
        UnitFrames.SV.CustomColourWarden[4],
    } -- Warden
    local class5_bg =
    {
        0.1 * UnitFrames.SV.CustomColourNecromancer[1],
        0.1 * UnitFrames.SV.CustomColourNecromancer[2],
        0.1 * UnitFrames.SV.CustomColourNecromancer[3],
        UnitFrames.SV.CustomColourNecromancer[4],
    } -- Necromancer
    local class6_bg =
    {
        0.1 * UnitFrames.SV.CustomColourTemplar[1],
        0.1 * UnitFrames.SV.CustomColourTemplar[2],
        0.1 * UnitFrames.SV.CustomColourTemplar[3],
        UnitFrames.SV.CustomColourTemplar[4],
    } -- Templar
    local class117_bg =
    {
        0.1 * UnitFrames.SV.CustomColourArcanist[1],
        0.1 * UnitFrames.SV.CustomColourArcanist[2],
        0.1 * UnitFrames.SV.CustomColourArcanist[3],
        UnitFrames.SV.CustomColourArcanist[4],
    } -- Arcanist

    local petcolor_bg =
    {
        0.1 * UnitFrames.SV.CustomColourPet[1],
        0.1 * UnitFrames.SV.CustomColourPet[2],
        0.1 * UnitFrames.SV.CustomColourPet[3],
        UnitFrames.SV.CustomColourPet[4],
    } -- Player Pet
    local companioncolor_bg =
    {
        0.1 * UnitFrames.SV.CustomColourCompanionFrame[1],
        0.1 * UnitFrames.SV.CustomColourCompanionFrame[2],
        0.1 * UnitFrames.SV.CustomColourCompanionFrame[3],
        UnitFrames.SV.CustomColourCompanionFrame[4],
    } -- Companion
    local invulnerablecolor =
    {
        UnitFrames.SV.CustomColourInvulnerable[1],
        UnitFrames.SV.CustomColourInvulnerable[2],
        UnitFrames.SV.CustomColourInvulnerable[3],
        UnitFrames.SV.CustomColourInvulnerable[4],
    } -- Invulnerable
    local invulnerablecolor_inlay =
    {
        UnitFrames.SV.CustomColourInvulnerable[1],
        UnitFrames.SV.CustomColourInvulnerable[2],
        UnitFrames.SV.CustomColourInvulnerable[3],
        UnitFrames.SV.CustomColourInvulnerable[4],
    }

    local isBattleground = IsActiveWorldBattleground()

    local function ApplyHealthBarHalos(healthBar, barColor)
        if healthBar and healthBar.backdrop and barColor then
            UnitFrames.ApplyBarBackdropHaloColors(healthBar.backdrop, barColor, barColor[4], 0.1)
        end
    end

    local runAll = sections == nil or sections.all == true
    local applyHealthFamily = runAll or sections.healthFamily == true
    local applyCompanionBlock = runAll or sections.companion == true
    local applyPetLoop = runAll or sections.pet == true
    local applyGroupRaidLoop = runAll or sections.groupRaid == true
    local applyPlayerMagickaStamina = runAll or sections.playerMagickaStamina == true

    local function GetShieldBarFillAlpha(baseName)
        local separateAlpha = UnitFrames.SV.CustomShieldBarSeparate
            and baseName ~= "boss"
            and baseName ~= "RaidGroup"
        if separateAlpha then
            return UnitFrames.SV.CustomColourShield[4] or (UnitFrames.SV.ShieldAlpha / 100) or 1
        end
        return UnitFrames.SV.ShieldAlpha / 100
    end

    if applyHealthFamily then
        for _, baseName in pairs({ "player", "reticleover", "boss", "AvaPlayerTarget" }) do
            shield[4] = GetShieldBarFillAlpha(baseName)
            for i = 0, 7 do
                local unitTag = (i == 0) and baseName or (baseName .. i)
                if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
                    local unitFrame = UnitFrames.CustomFrames[unitTag]
                    local thb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop
                    thb.bar:SetColor(unpack(health))
                    thb.backdrop:SetCenterColor(unpack(health_bg))
                    ApplyHealthBarHalos(thb, health)
                    thb.shield:SetColor(unpack(shield))
                    thb.trauma:SetColor(unpack(trauma))
                    if thb.invulnerable then
                        thb.invulnerable:SetColor(unpack(invulnerablecolor))
                    end
                    if thb.invulnerableInlay then
                        thb.invulnerableInlay:SetColor(unpack(invulnerablecolor_inlay))
                    end
                    if thb.shieldbackdrop then
                        thb.shieldbackdrop:SetCenterColor(unpack(shield_bg))
                    end
                end
            end
        end
    end

    local petClass = GetUnitClassId("player")

    -- Player Companion Frame Color
    if applyCompanionBlock and UnitFrames.CustomFrames["companion"] and UnitFrames.CustomFrames["companion"].tlw then
        local unitFrame = UnitFrames.CustomFrames["companion"]
        local shb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop
        shield[4] = GetShieldBarFillAlpha("companion")
        if UnitFrames.SV.CompanionUseClassColor then
            local class_color
            local class_bg
            if petClass == 1 then
                class_color = class1
                class_bg = class1_bg
            elseif petClass == 2 then
                class_color = class2
                class_bg = class2_bg
            elseif petClass == 3 then
                class_color = class3
                class_bg = class3_bg
            elseif petClass == 4 then
                class_color = class4
                class_bg = class4_bg
            elseif petClass == 5 then
                class_color = class5
                class_bg = class5_bg
            elseif petClass == 6 then
                class_color = class6
                class_bg = class6_bg
            elseif petClass == 117 then
                class_color = class117
                class_bg = class117_bg
            else -- Fallback option just in case
                class_color = petcolor
                class_bg = petcolor_bg
            end
            shb.bar:SetColor(unpack(class_color))
            shb.backdrop:SetCenterColor(unpack(class_bg))
            ApplyHealthBarHalos(shb, class_color)
        else
            shb.bar:SetColor(unpack(petcolor))
            shb.backdrop:SetCenterColor(unpack(petcolor_bg))
            ApplyHealthBarHalos(shb, petcolor)
        end
        shb.shield:SetColor(unpack(shield))
        shb.trauma:SetColor(unpack(trauma))
        if shb.shieldbackdrop then
            shb.shieldbackdrop:SetCenterColor(unpack(shield_bg))
        end
    end

    -- Player Pet Frame Color
    if applyPetLoop then
        for i = 1, 7 do
            local unitTag = "PetGroup" .. i
            if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
                local unitFrame = UnitFrames.CustomFrames[unitTag]
                local shb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop
                shield[4] = GetShieldBarFillAlpha("PetGroup")
                if UnitFrames.SV.PetUseClassColor then
                    local class_color
                    local class_bg
                    if petClass == 1 then
                        class_color = class1
                        class_bg = class1_bg
                    elseif petClass == 2 then
                        class_color = class2
                        class_bg = class2_bg
                    elseif petClass == 3 then
                        class_color = class3
                        class_bg = class3_bg
                    elseif petClass == 4 then
                        class_color = class4
                        class_bg = class4_bg
                    elseif petClass == 5 then
                        class_color = class5
                        class_bg = class5_bg
                    elseif petClass == 6 then
                        class_color = class6
                        class_bg = class6_bg
                    elseif petClass == 117 then
                        class_color = class117
                        class_bg = class117_bg
                    else -- Fallback option just in case
                        class_color = petcolor
                        class_bg = petcolor_bg
                    end
                    shb.bar:SetColor(unpack(class_color))
                    shb.backdrop:SetCenterColor(unpack(class_bg))
                    ApplyHealthBarHalos(shb, class_color)
                else
                    shb.bar:SetColor(unpack(companioncolor))
                    shb.backdrop:SetCenterColor(unpack(companioncolor_bg))
                    ApplyHealthBarHalos(shb, companioncolor)
                end
                shb.shield:SetColor(unpack(shield))
                shb.trauma:SetColor(unpack(trauma))
                if shb.shieldbackdrop then
                    shb.shieldbackdrop:SetCenterColor(unpack(shield_bg))
                end
            end
        end
    end

    local groupSize = GetGroupSize()

    -- Variables to adjust frame when player frame is hidden in group
    local increment = false   -- Once we reach a value set by Increment Marker (group tag of the player), we need to increment all further tags by +1 in order to get the correct color for them.
    local incrementMarker = 0 -- Marker -- Once we reach this value in iteration, we have to add +1 to default unitTag index for all other units.
    if applyGroupRaidLoop then
        for _, baseName in pairs({ "SmallGroup", "RaidGroup" }) do
            shield[4] = GetShieldBarFillAlpha(baseName)

            -- Extra loop if player is excluded in Small Group Frames
            if UnitFrames.SV.GroupExcludePlayer and not (baseName == "RaidGroup") then
                -- Force increment groupTag by +1 for determining class/role if player frame is removed from display
                for i = 1, groupSize do
                    if i > 4 then
                        break
                    end
                    local defaultUnitTag = GetGroupUnitTagByIndex(i)
                    if AreUnitsEqual(defaultUnitTag, "player") then
                        incrementMarker = i
                    end
                end
            end

            for i = 1, groupSize do
                local unitTag = baseName .. i
                if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
                    if i == incrementMarker then
                        increment = true
                    end
                    local defaultUnitTag
                    -- Set default frame reference to +1 if Player Frame is hidden and we reach that index, otherwise, proceed as normal
                    if increment then
                        defaultUnitTag = GetGroupUnitTagByIndex(i + 1)
                        if i + 1 > 4 and baseName == "SmallGroup" then
                            break
                        end -- Bail out if we're at the end of the small group list
                    else
                        defaultUnitTag = GetGroupUnitTagByIndex(i)
                    end

                    -- Also update control for Right Click Menu
                    UnitFrames.CustomFrames[unitTag].control.defaultUnitTag = defaultUnitTag
                    if UnitFrames.CustomFrames[unitTag].topInfo then
                        UnitFrames.CustomFrames[unitTag].topInfo.defaultUnitTag = defaultUnitTag
                    end

                    local class = GetUnitClassId(defaultUnitTag)
                    local role = isBattleground and LFG_ROLE_DPS or GetGroupMemberSelectedRole(defaultUnitTag)

                    local unitFrame = UnitFrames.CustomFrames[unitTag]
                    local thb = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH] -- not a backdrop

                    local group = groupSize <= 4
                    local raid = groupSize > 4
                    if not UnitFrames.SV.CustomFramesGroup then
                        raid = true
                        group = false
                    end

                    if (group and UnitFrames.SV.ColorRoleGroup) or (raid and UnitFrames.SV.ColorRoleRaid) then
                        if role == LFG_ROLE_DPS then
                            thb.bar:SetColor(unpack(dps))
                            thb.backdrop:SetCenterColor(unpack(dps_bg))
                            ApplyHealthBarHalos(thb, dps)
                        elseif role == LFG_ROLE_HEAL then
                            thb.bar:SetColor(unpack(healer))
                            thb.backdrop:SetCenterColor(unpack(healer_bg))
                            ApplyHealthBarHalos(thb, healer)
                        elseif role == LFG_ROLE_TANK then
                            thb.bar:SetColor(unpack(tank))
                            thb.backdrop:SetCenterColor(unpack(tank_bg))
                            ApplyHealthBarHalos(thb, tank)
                        else
                            thb.bar:SetColor(unpack(invalid)) -- do not use health as fallback because it might look like tank
                            thb.backdrop:SetCenterColor(unpack(invalid_bg))
                            ApplyHealthBarHalos(thb, invalid)
                        end
                    elseif (group and UnitFrames.SV.ColorClassGroup) or (raid and UnitFrames.SV.ColorClassRaid) and class ~= 0 then
                        local class_color
                        local class_bg
                        if class == 1 then
                            class_color = class1
                            class_bg = class1_bg
                        elseif class == 2 then
                            class_color = class2
                            class_bg = class2_bg
                        elseif class == 3 then
                            class_color = class3
                            class_bg = class3_bg
                        elseif class == 4 then
                            class_color = class4
                            class_bg = class4_bg
                        elseif class == 5 then
                            class_color = class5
                            class_bg = class5_bg
                        elseif class == 6 then
                            class_color = class6
                            class_bg = class6_bg
                        elseif class == 117 then
                            class_color = class117
                            class_bg = class117_bg
                        else -- Fallback option just in case
                            class_color = invalid
                            class_bg = invalid_bg
                        end
                        thb.bar:SetColor(unpack(class_color))
                        thb.backdrop:SetCenterColor(unpack(class_bg))
                        ApplyHealthBarHalos(thb, class_color)
                    else
                        thb.bar:SetColor(unpack(health))
                        thb.backdrop:SetCenterColor(unpack(health_bg))
                        ApplyHealthBarHalos(thb, health)
                    end
                    thb.shield:SetColor(unpack(shield))
                    thb.trauma:SetColor(unpack(trauma))
                    if thb.shieldbackdrop then
                        thb.shieldbackdrop:SetCenterColor(unpack(shield_bg))
                    end
                end
            end
        end
    end

    -- Player frame also requires setting of magicka and stamina bars
    if applyPlayerMagickaStamina and UnitFrames.CustomFrames["player"] and UnitFrames.CustomFrames["player"].tlw then
        local playerFrame = UnitFrames.CustomFrames["player"]
        local magickaFrame = playerFrame[COMBAT_MECHANIC_FLAGS_MAGICKA]
        magickaFrame.bar:SetColor(unpack(magicka))
        magickaFrame.backdrop:SetCenterColor(unpack(magicka_bg))
        UnitFrames.ApplyBarBackdropHaloColors(magickaFrame.backdrop, magicka, magicka[4], 0.1)
        local staminaFrame = playerFrame[COMBAT_MECHANIC_FLAGS_STAMINA]
        staminaFrame.bar:SetColor(unpack(stamina))
        staminaFrame.backdrop:SetCenterColor(unpack(stamina_bg))
        UnitFrames.ApplyBarBackdropHaloColors(staminaFrame.backdrop, stamina, stamina[4], 0.1)
    end
end

-- Full runtime/init color pass (all sections).
function UnitFrames.CustomFramesApplyColors()
    CustomFramesApplyColorsInternal({ all = true })
end

-- LAM: player/reticleover/boss/Ava health bar paint + shield/trauma/invulnerable on those units; includes SmallGroup/Raid shield alpha path.
function UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
    CustomFramesApplyColorsInternal({ healthFamily = true, groupRaid = true })
end

function UnitFrames.CustomFramesApplyColorsMenuPlayerMagickaStaminaOnly()
    CustomFramesApplyColorsInternal({ playerMagickaStamina = true })
end

function UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
    CustomFramesApplyColorsInternal({ groupRaid = true })
end

function UnitFrames.CustomFramesApplyColorsMenuCompanionFrameOnly()
    CustomFramesApplyColorsInternal({ companion = true })
end

function UnitFrames.CustomFramesApplyColorsMenuPetFramesOnly()
    CustomFramesApplyColorsInternal({ pet = true })
end

function UnitFrames.CustomFramesApplyReactionColorForMenu()
    if not UnitFrames.CustomFrames["reticleover"] then
        return
    end
    local isTargetPlayer = DoesUnitExist("reticleover") and IsUnitPlayer("reticleover")
    UnitFrames.CustomFramesApplyReactionColor(isTargetPlayer)
end

-- Reload Names from Menu function call
--- @param unhidePlayer boolean|nil Show player TLW after layout.
--- @param group boolean|nil
--- @param raid boolean|nil
--- @param unhideReticle boolean|nil Show reticleover custom frame after layout; if nil, defaults to unhidePlayer.
--- @param unhideAva boolean|nil Show AvAPlayerTarget after layout; if nil, defaults to unhideReticle.
function UnitFrames.CustomFramesReloadControlsMenu(unhidePlayer, group, raid, unhideReticle, unhideAva)
    if unhideReticle == nil then
        unhideReticle = unhidePlayer
    end
    if unhideAva == nil then
        unhideAva = unhideReticle
    end
    UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames["player"])
    UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames["player"])
    UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames["player"])

    UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames["reticleover"])
    UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames["reticleover"])
    UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames["reticleover"])

    for i = 1, 12 do
        local unitTag = "group" .. i
        UnitFrames.UpdateStaticControls(UnitFrames.DefaultFrames[unitTag])
        UnitFrames.UpdateStaticControls(UnitFrames.CustomFrames[unitTag])
        UnitFrames.UpdateStaticControls(UnitFrames.AvaCustFrames[unitTag])
    end

    UnitFrames.CustomFramesApplyAllLayouts(
        {
            unhidePlayer = unhidePlayer,
            unhideReticle = unhideReticle,
            unhideAva = unhideAva,
            group = group,
            raid = raid,
            includeRaid = true,
            includeCompanion = false,
            includePet = false,
            includeBosses = false,
        })
end

function UnitFrames.CustomFramesReloadExecuteMenu()
    UnitFrames.targetThreshold = UnitFrames.SV.ExecutePercentage

    if UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.targetThreshold
    end
    if UnitFrames.CustomFrames["reticleover"] and UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.targetThreshold
    end
    if UnitFrames.AvaCustFrames["reticleover"] and UnitFrames.AvaCustFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.AvaCustFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.targetThreshold
    end

    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. i
        if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].threshold = UnitFrames.targetThreshold
        end
    end
end
