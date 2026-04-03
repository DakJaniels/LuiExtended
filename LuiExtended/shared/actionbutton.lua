--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local Data = LuiData.Data
local Effects = Data.Effects

local ACTION_BUTTON_BGS = { ability = "EsoUI/Art/ActionBar/abilityInset.dds", item = "EsoUI/Art/ActionBar/quickslotBG.dds" }
local ACTION_BUTTON_BORDERS = { normal = "EsoUI/Art/ActionBar/abilityFrame64_up.dds", mouseDown = "EsoUI/Art/ActionBar/abilityFrame64_down.dds" }
local FORCE_SUPPRESS_COOLDOWN_SOUND = true
local BOUNCE_DURATION_MS = 500

local function GetSlotTrueBoundId(actionSlotIndex, hotbarCategory)
    hotbarCategory = hotbarCategory or GetActiveHotbarCategory()
    local actionId = GetSlotBoundId(actionSlotIndex, hotbarCategory)
    local actionType = GetSlotType(actionSlotIndex, hotbarCategory)
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        actionId = GetAbilityIdForCraftedAbilityId(actionId)
    end
    return actionId
end

local function SetupActionSlot(slotObject, slotId)
    local slotIcon = GetSlotTexture(slotId, slotObject:GetHotbarCategory())

    -- Added function - Replace icons if needed
    local abilityId = GetSlotTrueBoundId(slotId, slotObject:GetHotbarCategory())
    if Effects.BarIdOverride[abilityId] and not Effects.IsAbilityProc[abilityId] and not Effects.BaseForAbilityProc[abilityId] then
        slotIcon = Effects.BarIdOverride[abilityId]
    end

    slotObject:SetEnabled(true)
    local isGamepad = IsInGamepadPreferredMode()
    ZO_ActionSlot_SetupSlot(slotObject.icon, slotObject.button, slotIcon, isGamepad and "" or ACTION_BUTTON_BORDERS.normal, isGamepad and "" or ACTION_BUTTON_BORDERS.mouseDown, slotObject.cooldownIcon)
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

function LUIE.HookActionButton()
    SetupSlotHandlers =
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

    ActionButton["UpdateActivationHighlight"] = function (self)
        local slotNum = self:GetSlot()
        local hotbarCategory = self:GetHotbarCategory()
        local slotType = GetSlotType(slotNum, hotbarCategory)
        local slotIsEmpty = (slotType == ACTION_TYPE_NOTHING)
        local abilityId = GetSlotTrueBoundId(slotNum, hotbarCategory)

        local showHighlight = not slotIsEmpty and (ActionSlotHasActivationHighlight(slotNum, hotbarCategory) or Effects.IsAbilityActiveGlow[abilityId] == true) and not self.useFailure and not self.showingCooldown
        local isShowingHighlight = self.activationHighlight:IsControlHidden() == false

        if showHighlight ~= isShowingHighlight then
            self.activationHighlight:SetHidden(not showHighlight)

            if showHighlight then
                local _, _, activationAnimationTexture = GetSlotTexture(slotNum, hotbarCategory)
                self.activationHighlight:SetTexture(activationAnimationTexture)

                local anim = self.activationHighlight.animation
                if not anim then
                    anim = CreateSimpleAnimation(ANIMATION_TEXTURE, self.activationHighlight)
                    anim:SetImageData(64, 1)
                    anim:SetFramerate(30)
                    anim:GetTimeline():SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)

                    self.activationHighlight.animation = anim
                end

                anim:GetTimeline():PlayFromStart()
            else
                local anim = self.activationHighlight.animation
                if anim then
                    anim:GetTimeline():Stop()
                end
            end
        end
    end

    ActionButton["UpdateState"] = function (self)
        local slotNum = self:GetSlot()
        local hotbarCategory = self:GetHotbarCategory()
        local slotType = GetSlotType(slotNum, hotbarCategory)
        local slotIsEmpty = (slotType == ACTION_TYPE_NOTHING)
        local abilityId = GetSlotTrueBoundId(slotNum, hotbarCategory)

        self.button.actionId = GetSlotTrueBoundId(slotNum, hotbarCategory)

        self:UpdateUseFailure()

        local isToggled = IsSlotToggled(slotNum, hotbarCategory) == true or Effects.IsAbilityActiveHighlight[abilityId] == true
        self.status:SetHidden(slotIsEmpty or not isToggled)

        self:UpdateActivationHighlight()
        self:UpdateCooldown(FORCE_SUPPRESS_COOLDOWN_SOUND)
    end

    -- ActionButton["ApplyStyle"] = function (self, template)
    --     WINDOW_MANAGER:ApplyTemplateToControl(self.slot, template)

    --     local isGamepad = IsInGamepadPreferredMode()
    --     self.button:SetNormalTexture(isGamepad and "" or ACTION_BUTTON_BORDERS.normal)
    --     self.button:SetPressedTexture(isGamepad and "" or ACTION_BUTTON_BORDERS.mouseDown)
    --     self.countText:SetFont(isGamepad and "ZoFontGamepadBold27" or "ZoFontGameShadow")
    --     self:ApplySwapAnimationStyle()

    --     if ZO_ActionBar_IsUltimateSlot(self:GetSlot(), self:GetHotbarCategory()) then
    --         local decoration = self.slot:GetNamedChild("Decoration")
    --         if decoration then
    --             decoration:SetHidden(isGamepad)
    --         end
    --     end

    --     if self.showingCooldown then
    --         self.cooldown:SetHidden(isGamepad)

    --         if isGamepad then
    --             local slotNum = self:GetSlot()
    --             local hotbarCategory = self:GetHotbarCategory()
    --             local remain = GetSlotCooldownInfo(slotNum, hotbarCategory)
    --             self:PlayAbilityUsedBounce(BOUNCE_DURATION_MS + remain)

    --             if not self.itemQtyFailure then
    --                 self.icon:SetDesaturation(0)
    --             end
    --         else
    --             self:ResetBounceAnimation()
    --         end
    --     else
    --         self:ResetBounceAnimation()
    --     end

    --     self:SetCooldownEdgeState(self.showingCooldown)
    --     self:UpdateUsable()
    -- end
end
