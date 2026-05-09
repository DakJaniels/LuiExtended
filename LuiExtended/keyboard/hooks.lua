--- @diagnostic disable: missing-global-doc
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

function LUIE.HookKeyboardIcons()
    -- Variables for Skill Window Hook
    local INCREASE_BUTTON_TEXTURES =
    {
        PLUS =
        {
            normal = "EsoUI/Art/Progression/addPoints_up.dds",
            mouseDown = "EsoUI/Art/Progression/addPoints_down.dds",
            mouseover = "EsoUI/Art/Progression/addPoints_over.dds",
            disabled = "EsoUI/Art/Progression/addPoints_disabled.dds",
        },
        MORPH =
        {
            normal = "EsoUI/Art/Progression/morph_up.dds",
            mouseDown = "EsoUI/Art/Progression/morph_down.dds",
            mouseover = "EsoUI/Art/Progression/morph_over.dds",
            disabled = "EsoUI/Art/Progression/morph_disabled.dds",
        },
        REMORPH =
        {
            normal = "EsoUI/Art/Progression/remorph_up.dds",
            mouseDown = "EsoUI/Art/Progression/remorph_down.dds",
            mouseover = "EsoUI/Art/Progression/remorph_over.dds",
            disabled = "EsoUI/Art/Progression/remorph_disabled.dds",
        },
    }

    -- Local function for Skill Window Hook
    local function ApplyButtonTextures(button, textures)
        button:SetNormalTexture(textures.normal)
        button:SetPressedTexture(textures.mouseDown)
        button:SetMouseOverTexture(textures.mouseover)
        button:SetDisabledTexture(textures.disabled)
    end

    -- Hook Skills Window (Keyboard)
    function ZO_Skills_AbilityEntry_Setup(control, skillData)
        local skillPointAllocator = skillData:GetPointAllocator()
        local skillProgressionData = skillPointAllocator:GetProgressionData()

        local isPassive = skillData:IsPassive()
        local isActive = not isPassive
        local isPurchased = skillPointAllocator:IsPurchased()
        local isUnlocked = skillProgressionData:IsUnlocked()

        local lastSkillProgressionData = control.skillProgressionData
        control.skillProgressionData = skillProgressionData
        control.slot.skillProgressionData = skillProgressionData
        control.slot.skillData = skillData

        -- slot
        local id = skillProgressionData:GetAbilityId()
        local customIcon = GetAbilityIcon and GetAbilityIcon(id)
        if customIcon then
            control.slotIcon:SetTexture(customIcon)
        else
            control.slotIcon:SetTexture(skillProgressionData:GetIcon())
        end
        ZO_Skills_SetKeyboardAbilityButtonTextures(control.slot)
        ZO_ActionSlot_SetUnusable(control.slotIcon, not isPurchased)
        control.slot:SetEnabled(isPurchased and isActive)
        control.slotLock:SetHidden(isUnlocked)

        local hasSlotStatusUpdated = skillData:HasUpdatedStatusByType(ZO_SKILL_DATA_NEW_STATE.MORPHABLE) or skillData:HasUpdatedStatusByType(ZO_SKILL_DATA_NEW_STATE.CRAFTED_ABILITY)
        control.slot.statusIcon:SetHidden(not hasSlotStatusUpdated)

        if skillProgressionData:IsActive() and skillProgressionData:HasAnyNonHiddenSkillStyles() then
            local collectibleData = skillProgressionData:GetSelectedSkillStyleCollectibleData()
            if collectibleData then
                control.skillStyleControl.selectedStyleButton.icon:SetTexture(collectibleData:GetIcon())
            end
        end

        -- xp bar
        local showXPBar = skillProgressionData:HasRankData() and not IsCurrentCampaignVengeanceRuleset()
        if showXPBar then
            local currentRank = skillProgressionData:GetCurrentRank()
            local startXP, endXP = skillProgressionData:GetRankXPExtents(currentRank)
            local currentXP = skillProgressionData:GetCurrentXP()
            local dontWrap = lastSkillProgressionData ~= skillProgressionData

            control.xpBar:SetHidden(false)
            ZO_SkillInfoXPBar_SetValue(control.xpBar, currentRank, startXP, endXP, currentXP, dontWrap)
        else
            local NO_LEVEL = nil
            local START_XP = 0
            local END_XP = 1
            local NO_XP = 0
            local DONT_WRAP = true

            control.xpBar:SetHidden(true)
            ZO_SkillInfoXPBar_SetValue(control.xpBar, NO_LEVEL, START_XP, END_XP, NO_XP, DONT_WRAP)
        end

        -- name
        local detailedName = skillProgressionData:GetDetailedName()
        local abilityID = skillProgressionData.abilityId
        detailedName = StringOnlyGSUB(detailedName, "With", "with")               -- Easiest way to fix the capitalization of the skill "Bond With Nature"
        detailedName = StringOnlyGSUB(detailedName, "Blessing Of", "Blessing of") -- Easiest way to fix the capitalization of the skill "Blessing of Restoration"
        if LUIE.IsDevDebugEnabled() then
            control.nameLabel:SetText(string.format("(%d) %s", abilityID, detailedName))
        else
            control.nameLabel:SetText(detailedName)
        end
        local offsetY = showXPBar and -10 or 0
        control.nameLabel:SetAnchor(LEFT, control.slot, RIGHT, 10, offsetY)

        if isPurchased then
            control.nameLabel:SetColor(PURCHASED_COLOR:UnpackRGBA())
        else
            if isUnlocked then
                control.nameLabel:SetColor(UNPURCHASED_COLOR:UnpackRGBA())
            else
                control.nameLabel:SetColor(LOCKED_COLOR:UnpackRGBA())
            end
        end

        -- increase/decrease buttons
        local increaseButton = control.increaseButton
        local decreaseButton = control.decreaseButton
        local hideIncreaseButton = true
        local hideDecreaseButton = true
        local canPurchase = skillPointAllocator:CanPurchase()
        local canIncreaseRank = skillPointAllocator:CanIncreaseRank()
        local canMorph = skillPointAllocator:CanMorph()
        local skillPointAllocationMode = SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
        if skillPointAllocationMode == SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY then
            local increaseTextures = nil
            if canMorph then
                increaseTextures = INCREASE_BUTTON_TEXTURES.MORPH
            elseif canPurchase or canIncreaseRank then
                increaseTextures = INCREASE_BUTTON_TEXTURES.PLUS
            end

            if increaseTextures then
                ApplyButtonTextures(increaseButton, increaseTextures)
                if GetActionBarLockedReason() == ACTION_BAR_LOCKED_REASON_COMBAT then
                    increaseButton:SetState(BSTATE_DISABLED)
                else
                    increaseButton:SetState(BSTATE_NORMAL)
                end
                hideIncreaseButton = false
            end
        else
            if skillData:CanPointAllocationsBeAltered(skillPointAllocationMode) then
                hideIncreaseButton = false
                hideDecreaseButton = false

                if isPassive or not isPurchased or not skillData:IsAtMorph() then
                    ApplyButtonTextures(increaseButton, INCREASE_BUTTON_TEXTURES.PLUS)
                else
                    if skillProgressionData:IsMorph() then
                        ApplyButtonTextures(increaseButton, INCREASE_BUTTON_TEXTURES.REMORPH)
                    else
                        ApplyButtonTextures(increaseButton, INCREASE_BUTTON_TEXTURES.MORPH)
                    end
                end

                if canMorph or canPurchase or canIncreaseRank then
                    increaseButton:SetState(BSTATE_NORMAL)
                else
                    increaseButton:SetState(BSTATE_DISABLED)
                end

                if skillPointAllocator:CanSell() or skillPointAllocator:CanDecreaseRank() or skillPointAllocator:CanUnmorph() then
                    decreaseButton:SetState(BSTATE_NORMAL)
                else
                    decreaseButton:SetState(BSTATE_DISABLED)
                end
            end
        end

        increaseButton:SetHidden(hideIncreaseButton)
        decreaseButton:SetHidden(hideDecreaseButton)

        -- Don't show skill style functionality if in respec mode (decrease button showing)
        local skillStyleControl = control.skillStyleControl
        if hideDecreaseButton then
            skillStyleControl:ClearAnchors()
            if hideIncreaseButton then
                skillStyleControl:SetAnchor(RIGHT, control.slot, LEFT, -12)
            else
                skillStyleControl:SetAnchor(RIGHT, increaseButton, LEFT)
            end

            if isActive and skillProgressionData:HasAnyNonHiddenSkillStyles() then
                skillStyleControl:SetHidden(false)
                if skillProgressionData:IsSkillStyleSelected() then
                    skillStyleControl.defaultStyleButton:SetHidden(true)
                    skillStyleControl.selectedStyleButton:SetHidden(false)
                else
                    skillStyleControl.defaultStyleButton:SetHidden(false)
                    skillStyleControl.selectedStyleButton:SetHidden(true)
                end
                skillStyleControl.statusIcon:SetHidden(not skillData:HasUpdatedStatusByType(ZO_SKILL_DATA_NEW_STATE.STYLE_COLLECTIBLE))
            else
                skillStyleControl:SetHidden(true)
            end
        else
            skillStyleControl:SetHidden(true)
        end
    end

    -- Overwrite default Skill Confirm Learn Menu for Skills with Custom Icons (Keyboard)
    local function InitializeKeyboardConfirmDialog()
        local confirmDialogControl = ZO_SkillsConfirmDialog
        confirmDialogControl.abilityName = confirmDialogControl:GetNamedChild("AbilityName")
        confirmDialogControl.ability = confirmDialogControl:GetNamedChild("Ability")
        confirmDialogControl.ability.icon = confirmDialogControl.ability:GetNamedChild("Icon")
        confirmDialogControl.warning = confirmDialogControl:GetNamedChild("Warning")
        local advisementLabel = confirmDialogControl:GetNamedChild("Advisement")
        advisementLabel:SetText(GetString(SI_SKILLS_ADVISOR_PURCHASE_ADVISED))
        advisementLabel:SetColor(ZO_SKILLS_ADVISOR_ADVISED_COLOR:UnpackRGBA())
        confirmDialogControl.advisementLabel = advisementLabel

        local function SetupPurchaseAbilityConfirmDialog(dialog, skillProgressionData)
            local skillData = skillProgressionData:GetSkillData()
            if skillData:GetPointAllocator():CanPurchase() then
                local dialogAbility = dialog.ability
                local id = skillProgressionData:GetAbilityId()
                dialog.abilityName:SetText(skillProgressionData:GetFormattedName())

                dialogAbility.skillProgressionData = skillProgressionData
                dialogAbility.icon:SetTexture(GetAbilityIcon(id))
                ZO_Skills_SetKeyboardAbilityButtonTextures(dialogAbility)

                dialog.warning:SetText(zo_strformat(SI_SKILLS_IMPROVEMENT_COST, skillData:GetSkillPointCostMultiplier()))

                local hideAdvisement = (not ZO_SKILLS_ADVISOR_SINGLETON:CanUseSkillsAdvisor()) or ZO_SKILLS_ADVISOR_SINGLETON:IsAdvancedModeSelected() or (not skillProgressionData:IsAdvised())
                dialog.advisementLabel:SetHidden(hideAdvisement)
            end
        end

        ZO_Dialogs_RegisterCustomDialog("PURCHASE_ABILITY_CONFIRM",
                                        {
                                            customControl = confirmDialogControl,
                                            setup = SetupPurchaseAbilityConfirmDialog,
                                            title =
                                            {
                                                text = SI_SKILLS_CONFIRM_PURCHASE_ABILITY,
                                            },
                                            buttons =
                                            {
                                                [1] =
                                                {
                                                    control = confirmDialogControl:GetNamedChild("Confirm"),
                                                    text = SI_SKILLS_UNLOCK_CONFIRM,
                                                    callback = function (dialog)
                                                        local skillProgressionData = dialog.data
                                                        local skillPointAllocator = skillProgressionData:GetSkillData():GetPointAllocator()
                                                        skillPointAllocator:Purchase()
                                                    end,
                                                },

                                                [2] =
                                                {
                                                    control = confirmDialogControl:GetNamedChild("Cancel"),
                                                    text = SI_CANCEL,
                                                },
                                            },
                                        })
    end

    -- Overwrite default Upgrade menu for Skills with Custom Icons (Keyboard)
    local function InitializeKeyboardUpgradeDialog()
        local upgradeDialogControl = ZO_SkillsUpgradeDialog
        upgradeDialogControl.desc = upgradeDialogControl:GetNamedChild("Description")

        upgradeDialogControl.baseAbility = upgradeDialogControl:GetNamedChild("BaseAbility")
        upgradeDialogControl.baseAbility.icon = upgradeDialogControl.baseAbility:GetNamedChild("Icon")

        upgradeDialogControl.upgradeAbility = upgradeDialogControl:GetNamedChild("UpgradeAbility")
        upgradeDialogControl.upgradeAbility.icon = upgradeDialogControl.upgradeAbility:GetNamedChild("Icon")

        upgradeDialogControl.warning = upgradeDialogControl:GetNamedChild("Warning")

        local advisementLabel = upgradeDialogControl:GetNamedChild("Advisement")
        advisementLabel:SetText(GetString(SI_SKILLS_ADVISOR_PURCHASE_ADVISED))
        advisementLabel:SetColor(ZO_SKILLS_ADVISOR_ADVISED_COLOR:UnpackRGBA())

        local function SetupUpgradeAbilityDialog(dialog, skillData)
            -- Only passives upgrade
            assert(skillData:IsPassive())

            local skillPointAllocator = skillData:GetPointAllocator()
            if skillPointAllocator:CanIncreaseRank() then
                local rank = skillPointAllocator:GetSkillProgressionKey()
                local skillProgressionData = skillData:GetRankData(rank)
                local nextSkillProgressionData = skillData:GetRankData(rank + 1)

                dialog.desc:SetText(zo_strformat(SI_SKILLS_UPGRADE_DESCRIPTION, skillProgressionData:GetName()))

                local baseAbility = dialog.baseAbility
                local id = skillProgressionData:GetAbilityId()
                baseAbility.skillProgressionData = skillProgressionData
                baseAbility.icon:SetTexture(GetAbilityIcon(id))
                ZO_Skills_SetKeyboardAbilityButtonTextures(baseAbility)

                local upgradeAbility = dialog.upgradeAbility
                local idUpgrade = nextSkillProgressionData:GetAbilityId()
                upgradeAbility.skillProgressionData = nextSkillProgressionData
                upgradeAbility.icon:SetTexture(GetAbilityIcon(idUpgrade))
                ZO_Skills_SetKeyboardAbilityButtonTextures(upgradeAbility)

                dialog.warning:SetText(zo_strformat(SI_SKILLS_IMPROVEMENT_COST, skillData:GetSkillPointCostMultiplier()))

                local hideAdvisement = (not ZO_SKILLS_ADVISOR_SINGLETON:CanUseSkillsAdvisor()) or ZO_SKILLS_ADVISOR_SINGLETON:IsAdvancedModeSelected() or (not skillProgressionData:IsAdvised())
                advisementLabel:SetHidden(hideAdvisement)
            end
        end

        ZO_Dialogs_RegisterCustomDialog("UPGRADE_ABILITY_CONFIRM",
                                        {
                                            customControl = upgradeDialogControl,
                                            setup = SetupUpgradeAbilityDialog,
                                            title =
                                            {
                                                text = SI_SKILLS_UPGRADE_ABILITY,
                                            },
                                            buttons =
                                            {
                                                [1] =
                                                {
                                                    control = upgradeDialogControl:GetNamedChild("Confirm"),
                                                    text = SI_SKILLS_UPGRADE_CONFIRM,
                                                    callback = function (dialog)
                                                        local skillData = dialog.data
                                                        local skillPointAllocator = skillData:GetPointAllocator()
                                                        skillPointAllocator:IncreaseRank()
                                                    end,
                                                },
                                                [2] =
                                                {
                                                    control = upgradeDialogControl:GetNamedChild("Cancel"),
                                                    text = SI_CANCEL,
                                                },
                                            },
                                        })
    end

    InitializeKeyboardConfirmDialog()
    InitializeKeyboardUpgradeDialog()
end
