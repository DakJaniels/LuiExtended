--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local Data = LuiData.Data
local Effects = Data.Effects

local function GetSlotTrueBoundId(actionSlotIndex, hotbarCategory)
    hotbarCategory = hotbarCategory or GetActiveHotbarCategory()
    local actionId = GetSlotBoundId(actionSlotIndex, hotbarCategory)
    local actionType = GetSlotType(actionSlotIndex, hotbarCategory)
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        actionId = GetAbilityIdForCraftedAbilityId(actionId)
    end
    return actionId
end

LUIE.HookActionButton = function ()
    local FORCE_SUPPRESS_COOLDOWN_SOUND = true

    local function WrapSetupHandler(originalHandler)
        return function (slotObject, slotId)
            originalHandler(slotObject, slotId)

            local hotbarCategory = slotObject:GetHotbarCategory()
            local abilityId = GetSlotTrueBoundId(slotId, hotbarCategory)
            if Effects.BarIdOverride[abilityId] then
                slotObject.icon:SetTexture(Effects.BarIdOverride[abilityId])
            end
        end
    end

    SetupSlotHandlers[ACTION_TYPE_NOTHING] = WrapSetupHandler(SetupSlotHandlers[ACTION_TYPE_NOTHING])
    SetupSlotHandlers[ACTION_TYPE_ABILITY] = WrapSetupHandler(SetupSlotHandlers[ACTION_TYPE_ABILITY])
    SetupSlotHandlers[ACTION_TYPE_ITEM] = WrapSetupHandler(SetupSlotHandlers[ACTION_TYPE_ITEM])
    SetupSlotHandlers[ACTION_TYPE_CRAFTED_ABILITY] = WrapSetupHandler(SetupSlotHandlers[ACTION_TYPE_CRAFTED_ABILITY])
    SetupSlotHandlers[ACTION_TYPE_VENGEANCE_PERK] = WrapSetupHandler(SetupSlotHandlers[ACTION_TYPE_VENGEANCE_PERK])
    SetupSlotHandlers[ACTION_TYPE_CHAMPION_SKILL] = WrapSetupHandler(SetupSlotHandlers[ACTION_TYPE_CHAMPION_SKILL])
    SetupSlotHandlers[ACTION_TYPE_COLLECTIBLE] = WrapSetupHandler(SetupSlotHandlers[ACTION_TYPE_COLLECTIBLE])
    SetupSlotHandlers[ACTION_TYPE_EMOTE] = WrapSetupHandler(SetupSlotHandlers[ACTION_TYPE_EMOTE])
    SetupSlotHandlers[ACTION_TYPE_QUICK_CHAT] = WrapSetupHandler(SetupSlotHandlers[ACTION_TYPE_QUICK_CHAT])
    SetupSlotHandlers[ACTION_TYPE_QUEST_ITEM] = WrapSetupHandler(SetupSlotHandlers[ACTION_TYPE_QUEST_ITEM])

    ActionButton.UpdateActivationHighlight = function (self)
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

    ActionButton.UpdateState = function (self)
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
end
