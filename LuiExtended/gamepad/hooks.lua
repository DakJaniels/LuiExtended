--- @diagnostic disable: missing-global-doc
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

LUIE.HookGamePadIcons = function ()
    -- Function for Gamepad Skills Hook
    local function SetupAbilityIconFrame(control, isPassive, isActive, isAdvised)
        local iconTexture = control.icon

        local DOUBLE_FRAME_THICKNESS = 9
        local SINGLE_FRAME_THICKNESS = 5
        -- Circle Frame (Passive)
        local circleFrameTexture = control.circleFrame
        if circleFrameTexture then
            if isPassive then
                circleFrameTexture:SetHidden(false)
                local frameOffsetFromIcon
                if isAdvised then
                    frameOffsetFromIcon = DOUBLE_FRAME_THICKNESS
                    circleFrameTexture:SetTexture("EsoUI/Art/SkillsAdvisor/gamepad/gp_passiveDoubleFrame_64.dds")
                else
                    frameOffsetFromIcon = SINGLE_FRAME_THICKNESS
                    circleFrameTexture:SetTexture("EsoUI/Art/Miscellaneous/Gamepad/gp_passiveFrame_64.dds")
                end
                circleFrameTexture:ClearAnchors()
                circleFrameTexture:SetAnchor(TOPLEFT, iconTexture, TOPLEFT, -frameOffsetFromIcon, -frameOffsetFromIcon)
                circleFrameTexture:SetAnchor(BOTTOMRIGHT, iconTexture, BOTTOMRIGHT, frameOffsetFromIcon, frameOffsetFromIcon)
            else
                control.circleFrame:SetHidden(true)
            end
        end

        -- Edge Frame (Active)
        local SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_WIDTH = 128
        local SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_HEIGHT = 16
        local edgeFrameBackdrop = control.edgeFrame
        if isActive then
            edgeFrameBackdrop:SetHidden(false)
            local frameOffsetFromIcon
            if isAdvised then
                frameOffsetFromIcon = DOUBLE_FRAME_THICKNESS
                edgeFrameBackdrop:SetEdgeTexture("EsoUI/Art/SkillsAdvisor/gamepad/edgeDoubleframeGamepadBorder.dds", SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_WIDTH, SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_HEIGHT)
            else
                frameOffsetFromIcon = SINGLE_FRAME_THICKNESS
                edgeFrameBackdrop:SetEdgeTexture("EsoUI/Art/Miscellaneous/Gamepad/edgeframeGamepadBorder.dds", SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_WIDTH, SKILLS_ADVISOR_ACTIVE_DOUBLE_FRAME_HEIGHT)
            end
            edgeFrameBackdrop:ClearAnchors()
            edgeFrameBackdrop:SetAnchor(TOPLEFT, iconTexture, TOPLEFT, -frameOffsetFromIcon, -frameOffsetFromIcon)
            edgeFrameBackdrop:SetAnchor(BOTTOMRIGHT, iconTexture, BOTTOMRIGHT, frameOffsetFromIcon, frameOffsetFromIcon)
        else
            edgeFrameBackdrop:SetHidden(true)
        end
    end

    local function SetBindingTextForSkill(keybindLabel, skillData, overrideSlotIndex, overrideHotbar)
        ZO_Keybindings_UnregisterLabelForBindingUpdate(keybindLabel)
        local hasBinding = false
        local keybindWidth = 0
        -- The spot where the keybind goes is occupied by the decrease button in the respec modes
        if SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode() == SKILL_POINT_ALLOCATION_MODE_PURCHASE_ONLY and skillData:IsActive() then
            local actionSlotIndex = overrideSlotIndex or skillData:GetSlotOnCurrentHotbar()
            if actionSlotIndex then
                local hotbarCategory = overrideHotbar or ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbarCategory()
                local keyboardActionName, gamepadActionName = ACTION_BAR_ASSIGNMENT_MANAGER:GetKeyboardAndGamepadActionNameForSlot(actionSlotIndex, hotbarCategory)
                local HIDE_UNBOUND = false
                ZO_Keybindings_RegisterLabelForBindingUpdate(keybindLabel, keyboardActionName, HIDE_UNBOUND, gamepadActionName)

                keybindWidth = 50     -- width assuming a single keybind
                if ACTION_BAR_ASSIGNMENT_MANAGER:IsUltimateSlot(actionSlotIndex) then
                    keybindWidth = 90 -- double keybind width (RB+LB)
                end

                keybindLabel:SetHidden(false)
                return keybindWidth
            end
        end
        keybindLabel:SetHidden(true)
        -- other controls depend on the keybind width for layout so let's reset its size too
        keybindLabel:SetText("")
        return 0
    end

    local function SetupIndicatorsForSkill(leftIndicator, rightIndicator, skillData, showIncrease, showDecrease, showNew)
        local indicatorRightWidth = 0

        -- If we don't have a left indicator then we aren't going to have a right indicator either, so exit the function
        if not leftIndicator then
            return indicatorRightWidth
        end
        local skillPointAllocator = skillData:GetPointAllocator()
        local skillProgressionData = skillPointAllocator:GetProgressionData()
        local isActive = skillData:IsActive()
        local isNonCraftedActive = isActive and not skillData:IsCraftedAbility()
        local isMorph = isNonCraftedActive and skillProgressionData.IsMorph and skillProgressionData:IsMorph()
        local showSkillStyle = not showDecrease and isActive and skillProgressionData.HasAnyNonHiddenSkillStyles and skillProgressionData:HasAnyNonHiddenSkillStyles()

        local increaseMultiIcon
        local decreaseMultiIcon
        if rightIndicator == nil then
            increaseMultiIcon = leftIndicator
            decreaseMultiIcon = leftIndicator
            leftIndicator:ClearIcons()
        elseif SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeBatchSave() then
            increaseMultiIcon = rightIndicator
            decreaseMultiIcon = leftIndicator
            leftIndicator:ClearIcons()
            rightIndicator:ClearIcons()
        else
            increaseMultiIcon = leftIndicator
            decreaseMultiIcon = rightIndicator
            leftIndicator:ClearIcons()
            rightIndicator:ClearIcons()
        end

        -- Increase (Morph, Purchase, Increase Rank) Icon
        local increaseAction = ZO_SKILL_POINT_ACTION.NONE
        if showIncrease then
            increaseAction = skillPointAllocator:GetIncreaseSkillAction()
        elseif isMorph then
            -- this is used more as an indicator that this skill has been morphed, than an indicator that you _should_ morph it
            increaseAction = ZO_SKILL_POINT_ACTION.MORPH
        end

        if increaseAction ~= ZO_SKILL_POINT_ACTION.NONE then
            increaseMultiIcon:AddIcon(ZO_Skills_GetGamepadSkillPointActionIcon(increaseAction))
        end

        -- Decrease (Unmorph, Sell, Decrease Rank)
        if showDecrease then
            local decreaseAction = skillPointAllocator:GetDecreaseSkillAction()
            if decreaseAction ~= ZO_SKILL_POINT_ACTION.NONE then
                decreaseMultiIcon:AddIcon(ZO_Skills_GetGamepadSkillPointActionIcon(decreaseAction))
            end
            -- Always carve out space for the decrease icon even if it isn't active so the name doesn't dance around as it appears and disappears
            indicatorRightWidth = 40
        elseif showSkillStyle then
            local collectibleData = skillProgressionData:GetSelectedSkillStyleCollectibleData()
            if collectibleData then
                leftIndicator:AddIcon(collectibleData:GetIcon())
            else
                leftIndicator:AddIcon("EsoUI/Art/Progression/Gamepad/gp_skillStyleEmpty.dds")
            end
        end

        -- New Indicator
        if showNew then
            if skillData:HasUpdatedStatus() then
                leftIndicator:AddIcon("EsoUI/Art/Inventory/newItem_icon.dds")
            end
        end

        leftIndicator:Show()
        if rightIndicator then
            rightIndicator:Show()
        end

        return indicatorRightWidth
    end

    local SKILL_ENTRY_LABEL_WIDTH = 289

    -- Hook for Gamepad Skills Menu
    function ZO_GamepadSkillEntryTemplate_Setup(control, skillEntry, selected, activated, displayView)
        -- Some skill entries want to target a specific progression data (such as the morph dialog showing two specific morphs). Otherwise they use the skill progression that matches the current point spending.
        local skillData = skillEntry.skillData or (skillEntry.skillProgressionData and skillEntry.skillProgressionData:GetSkillData()) or (skillEntry.craftedAbilityData and skillEntry.craftedAbilityData:GetSkillData())
        local skillProgressionData = skillEntry.skillProgressionData or skillData:GetPointAllocatorProgressionData()
        local skillPointAllocator = skillData:GetPointAllocator()
        local isUnlocked = skillProgressionData:IsUnlocked()
        local isActive = skillData:IsActive()
        local isNonCraftedActive = isActive and not (skillData.IsCraftedAbility and skillData:IsCraftedAbility())
        local isMorph = isNonCraftedActive and skillProgressionData:IsMorph()
        local isPurchased = skillPointAllocator:IsPurchased()
        local isInSkillBuild = skillProgressionData:IsAdvised()
        local abilityId = skillProgressionData.abilityId

        -- Icon
        local iconTexture = control.icon
        iconTexture:SetTexture(GetAbilityIcon(abilityId) or skillProgressionData:GetIcon())
        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            if isPurchased then
                iconTexture:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                iconTexture:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end
        else
            iconTexture:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        end

        SetupAbilityIconFrame(control, skillData:IsPassive(), isActive, isInSkillBuild)

        -- Label Color
        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            if not skillEntry.isPreview and isPurchased then
                if skillEntry.SetNameColors then
                    skillEntry:SetNameColors(PURCHASED_COLOR, PURCHASED_UNSELECTED_COLOR)
                end
            end
        elseif skillEntry.enabled then
            if skillEntry.SetNameColors then
                skillEntry:SetNameColors(PURCHASED_COLOR, PURCHASED_COLOR)
            end
        end
        if skillEntry.GetNameColor then
            control.label:SetColor(skillEntry:GetNameColor(selected):UnpackRGBA())
        else
            control.label:SetColor(PURCHASED_COLOR:UnpackRGBA())
        end

        -- Lock Icon
        if control.lock then
            control.lock:SetHidden(isUnlocked)
        end

        local labelWidth = SKILL_ENTRY_LABEL_WIDTH

        local showIncrease = (displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE)
        local showDecrease = SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeAllowDecrease() and displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE
        local showNew = (displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE)
        local indicatorWidth = SetupIndicatorsForSkill(control.leftIndicator, control.rightIndicator, skillData, showIncrease, showDecrease, showNew)
        labelWidth = labelWidth - indicatorWidth

        if displayView == ZO_SKILL_ABILITY_DISPLAY_INTERACTIVE then
            -- Current Binding Text
            if control.keybind then
                local keybindWidth = SetBindingTextForSkill(control.keybind, skillData)
                labelWidth = labelWidth - keybindWidth
            end
        end

        -- Size the label to allow space for the keybind and decrease icon
        control.label:SetWidth(labelWidth)
    end

    -- Hook for Gamepad Skills Preview
    function ZO_GamepadSkillEntryPreviewRow_Setup(control, skillData, overrideSlotIndex, overrideHotbar, isReadOnly)
        local skillProgressionData = skillData:GetPointAllocatorProgressionData()
        local skillPointAllocator = skillData:GetPointAllocator()
        local isUnlocked = skillProgressionData:IsUnlocked()
        local isPurchased = overrideHotbar ~= nil or skillPointAllocator:IsPurchased()
        local isActive = skillData:IsActive()
        local isNonCraftedActive = isActive and not skillData:IsCraftedAbility()
        local isMorph = skillData:IsPlayerSkill() and isNonCraftedActive and skillProgressionData:IsMorph()

        -- Icon
        local iconTexture = control.icon
        iconTexture:SetTexture(GetAbilityIcon(skillProgressionData.abilityId) or skillProgressionData:GetIcon())
        if isPurchased then
            iconTexture:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
        else
            iconTexture:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
        end

        SetupAbilityIconFrame(control, skillData:IsPassive(), isActive, skillProgressionData:IsAdvised())

        -- Label
        control.label:SetText(skillProgressionData:GetDetailedGamepadName())
        local color = isPurchased and ZO_SELECTED_TEXT or ZO_DISABLED_TEXT
        control.label:SetColor(color:UnpackRGBA())

        -- Lock Icon
        if control.lock then
            control.lock:SetHidden(isUnlocked)
        end

        -- indicator
        local labelWidth = SKILL_ENTRY_LABEL_WIDTH
        local NO_RIGHT_INDICATOR = nil
        local SHOW_INCREASE = not isReadOnly
        local showDecrease = SKILLS_AND_ACTION_BAR_MANAGER:DoesSkillPointAllocationModeAllowDecrease() and not isReadOnly
        local SHOW_NEW = true
        local indicatorWidth = SetupIndicatorsForSkill(control.leftIndicator, NO_RIGHT_INDICATOR, skillData, SHOW_INCREASE, showDecrease, SHOW_NEW)
        labelWidth = labelWidth - indicatorWidth

        local keybindWidth = SetBindingTextForSkill(control.keybind, skillData, overrideSlotIndex, overrideHotbar)
        labelWidth = labelWidth - keybindWidth

        -- Size the label to allow space for the keybind and decrease icon
        control.label:SetWidth(labelWidth)
    end
end
