--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local Data = LuiData.Data
local Effects = Data.Effects

LUIE.HookActionButton = function ()
    -- Hook Action Slots
    local ACTION_BUTTON_BGS = { ability = "EsoUI/Art/ActionBar/abilityInset.dds", item = "EsoUI/Art/ActionBar/quickslotBG.dds" }
    local ACTION_BUTTON_BORDERS = { normal = "EsoUI/Art/ActionBar/abilityFrame64_up.dds", mouseDown = "EsoUI/Art/ActionBar/abilityFrame64_down.dds" }

    local function SetupActionSlot(slotObject, slotId)
        -- Get slot information
        local hotbarCategory = slotObject:GetHotbarCategory()
        local slotIcon = GetSlotTexture(slotId, hotbarCategory)
        local abilityId = GetSlotBoundId(slotId, hotbarCategory)
        local actionType = GetSlotType(slotId, hotbarCategory)

        -- Handle crafted abilities
        if actionType == ACTION_TYPE_CRAFTED_ABILITY then
            abilityId = GetAbilityIdForCraftedAbilityId(abilityId)
        end

        -- Check for icon override based on ability ID
        if Effects.BarIdOverride[abilityId] then
            slotIcon = Effects.BarIdOverride[abilityId]
        end

        -- Enable and setup the slot with appropriate borders based on platform
        slotObject:SetEnabled(true)
        local isGamepad = IsInGamepadPreferredMode()
        local normalBorder = isGamepad and "" or ACTION_BUTTON_BORDERS.normal
        local mouseDownBorder = isGamepad and "" or ACTION_BUTTON_BORDERS.mouseDown

        ZO_ActionSlot_SetupSlot(slotObject.icon, slotObject.button, slotIcon, normalBorder, mouseDownBorder, slotObject.cooldownIcon)
        slotObject:UpdateState()
    end

    local function SetupActionSlotWithBg(slotObject, slotId)
        SetupActionSlot(slotObject, slotId)
        slotObject.bg:SetTexture(ACTION_BUTTON_BGS.ability)
    end

    local function SetupAbilitySlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)

        if ZO_ActionBar_IsUltimateSlot(slotId, slotObject:GetHotbarCategory()) then
            slotObject:RefreshUltimateNumberVisibility()
        else
            slotObject:ClearCount()
        end
    end

    local function SetupItemSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:SetupCount()
    end

    local function SetupCollectibleActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:ClearCount()
    end

    local function SetupQuestItemActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:SetupCount()
    end

    local function SetupEmoteActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:ClearCount()
    end

    local function SetupQuickChatActionSlot(slotObject, slotId)
        SetupActionSlotWithBg(slotObject, slotId)
        slotObject:ClearCount()
    end

    local function SetupEmptyActionSlot(slotObject, slotId)
        slotObject:Clear()
    end

    local SetupSlotHandlers =
    {
        [ACTION_TYPE_ABILITY]         = SetupAbilitySlot,
        [ACTION_TYPE_ITEM]            = SetupItemSlot,
        [ACTION_TYPE_CRAFTED_ABILITY] = SetupAbilitySlot,
        [ACTION_TYPE_COLLECTIBLE]     = SetupCollectibleActionSlot,
        [ACTION_TYPE_QUEST_ITEM]      = SetupQuestItemActionSlot,
        [ACTION_TYPE_EMOTE]           = SetupEmoteActionSlot,
        [ACTION_TYPE_QUICK_CHAT]      = SetupQuickChatActionSlot,
        [ACTION_TYPE_NOTHING]         = SetupEmptyActionSlot,
    }

    -- Hook to make Activation Highlight Effect play indefinitely instead of animation only once
    function ActionButton:UpdateActivationHighlight()
        local slotnum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or self.slot.hotbarCategory
        local slotType = GetSlotType(slotnum, hotbarCategory)
        local slotIsEmpty = (slotType == ACTION_TYPE_NOTHING)

        -- Get ability ID and handle crafted abilities
        local abilityId = GetSlotBoundId(slotnum, hotbarCategory)
        local actionType = GetSlotType(slotnum, hotbarCategory)
        if actionType == ACTION_TYPE_CRAFTED_ABILITY then
            abilityId = GetAbilityIdForCraftedAbilityId(abilityId)
        end

        -- Determine if highlight should be shown
        local showHighlight = not slotIsEmpty and
            (ActionSlotHasActivationHighlight(slotnum, hotbarCategory) or
                Effects.IsAbilityActiveGlow[abilityId]) and
            not self.useFailure and
            not self.showingCooldown

        local isShowingHighlight = not self.activationHighlight:IsHidden()

        -- Only update if the highlight state has changed
        if showHighlight ~= isShowingHighlight then
            self.activationHighlight:SetHidden(not showHighlight)

            if showHighlight then
                -- Set the highlight texture and create animation if needed
                local _, _, activationAnimationTexture = GetSlotTexture(slotnum, hotbarCategory)
                self.activationHighlight:SetTexture(activationAnimationTexture)

                local anim = self.activationHighlight.animation
                if not anim then
                    -- Create animation if it doesn't exist
                    anim = CreateSimpleAnimation(ANIMATION_TEXTURE, self.activationHighlight)
                    anim:SetImageData(64, 1)
                    anim:SetFramerate(30)
                    anim:GetTimeline():SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)

                    self.activationHighlight.animation = anim
                end

                anim:GetTimeline():PlayFromStart()
            else
                -- Stop animation if we're hiding the highlight
                local anim = self.activationHighlight.animation
                if anim then
                    anim:GetTimeline():Stop()
                end
            end
        end
    end

    -- Hook to add AVA Guard Ability + Morphs into Toggle Highlights
    function ActionButton:UpdateState()
        local slotnum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or self.slot.hotbarCategory
        local slotType = GetSlotType(slotnum, hotbarCategory)
        local slotIsEmpty = (slotType == ACTION_TYPE_NOTHING)

        -- Check AbilityId for if this should be a fake activation highlight
        local abilityId = GetSlotBoundId(slotnum, hotbarCategory)
        self.button.actionId = abilityId

        -- Process action type differently for crafted abilities
        local actionType = GetSlotType(slotnum, hotbarCategory)
        if actionType == ACTION_TYPE_CRAFTED_ABILITY then
            abilityId = GetAbilityIdForCraftedAbilityId(abilityId)
            self.button.actionId = abilityId
        end

        self:UpdateUseFailure()

        local hidden = true

        -- Add toggle highlight for abilities that need it (Guard + morphs)
        if IsSlotToggled(slotnum, hotbarCategory) or Effects.IsAbilityActiveHighlight[abilityId] then
            hidden = false
        end

        -- If LUIE Bar Highlight is enabled, hide certain "Toggle effects" (aka Blood Frenzy + morphs)
        if IsSlotToggled(slotnum, hotbarCategory) and
        Effects.RemoveAbilityActiveHighlight[abilityId] and
        LUIE.CombatInfo.SV.ShowToggled then
            hidden = true
        end

        self.status:SetHidden(hidden)

        self:UpdateActivationHighlight()
        self:UpdateCooldown(true)
    end

    function ActionButton:HandleSlotChanged(hotbarCategory)
        -- Update hotbar category references
        -- We no longer use self.button.hotbarCategory, but are keeping it around for addon compatibility
        self.slot.hotbarCategory = hotbarCategory
        self.button.hotbarCategory = hotbarCategory

        -- Get slot information
        local slotId = self:GetSlot()
        local slotType = GetSlotType(slotId, hotbarCategory)

        -- Get and call the appropriate handler for this slot type
        local setupSlotHandler = SetupSlotHandlers[slotType]
        if assert(setupSlotHandler, "update slot handlers") then
            setupSlotHandler(self, slotId)
        end

        -- Reset cooldown and update state
        self:SetShowCooldown(false)
        self:UpdateState()

        -- Update tooltip if mouse is over this button
        local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
        if mouseOverControl == self.button then
            ZO_AbilitySlot_OnMouseEnter(self.button)
        end
    end
end
