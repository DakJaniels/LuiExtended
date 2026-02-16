-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE
local LuiData = LuiData
local LuiData_Data = LuiData.Data
--- @class (partial) LuiExtended.CombatTextEventViewer : ZO_InitializingObject
local CombatTextEventViewer = ZO_InitializingObject:Subclass()

--- @class (partial) LuiExtended.CombatTextEventViewer
LUIE.CombatTextEventViewer = CombatTextEventViewer

local CombatText = LUIE.CombatText
local Effects = LuiData_Data.Effects
local CombatTextConstants = LuiData_Data.CombatTextConstants
local Effects_EffectOverride = Effects.EffectOverride
local Effects_EffectOverrideByName = Effects.EffectOverrideByName
local Effects_ZoneDataOverride = Effects.ZoneDataOverride
local Effects_MapDataOverride = Effects.MapDataOverride

local callbackManager = CALLBACK_MANAGER

CombatTextEventViewer.resourceNames = setmetatable({},
                                                   {
                                                       __index = function (t, k)
                                                           t[k] = GetString("SI_COMBATMECHANICTYPE", k)
                                                           return t[k]
                                                       end,
                                                   })
CombatTextEventViewer.damageTypes = setmetatable({},
                                                 {
                                                     __index = function (t, k)
                                                         t[k] = GetString("SI_DAMAGETYPE", k)
                                                         return t[k]
                                                     end,
                                                 })
-- Memory optimization: Cache ability icons to avoid repeated API calls
CombatTextEventViewer.abilityIconCache = setmetatable({},
                                                      {
                                                          __index = function (t, abilityId)
                                                              t[abilityId] = GetAbilityIcon(abilityId)
                                                              return t[abilityId]
                                                          end,
                                                      })
-- Memory optimization: Cache formatted source names
CombatTextEventViewer.sourceNameCache = setmetatable({},
                                                     {
                                                         __index = function (t, sourceName)
                                                             t[sourceName] = zo_strformat("<<C:1>>", sourceName)
                                                             return t[sourceName]
                                                         end,
                                                     })
---
--- @param poolManager LuiExtended.CombatTextPoolManager
function CombatTextEventViewer:Initialize(poolManager)
    self.poolManager = poolManager
end

-- Memory optimization: Lookup table for throttle times instead of if-elseif chains
function CombatTextEventViewer:GetThrottleTime(Settings, isDamage, isDamageCritical, isDot, isDotCritical, isHealing, isHealingCritical, isHot, isHotCritical)
    if isDamage then
        return Settings.throttles.damage
    elseif isDamageCritical then
        return Settings.throttles.damagecritical
    elseif isDot then
        return Settings.throttles.dot
    elseif isDotCritical then
        return Settings.throttles.dotcritical
    elseif isHealing then
        return Settings.throttles.healing
    elseif isHealingCritical then
        return Settings.throttles.healingcritical
    elseif isHot then
        return Settings.throttles.hot
    elseif isHotCritical then
        return Settings.throttles.hotcritical
    else
        return 0
    end
end

function CombatTextEventViewer:ShouldUseDefaultIcon(abilityId)
    if Effects_EffectOverride[abilityId] and Effects_EffectOverride[abilityId].cc then
        if CombatText.SV.common.defaultIconOptions == 1 then
            return true
        elseif CombatText.SV.common.defaultIconOptions == 2 then
            return Effects_EffectOverride[abilityId].isPlayerAbility and true or false
        elseif CombatText.SV.common.defaultIconOptions == 3 then
            return Effects_EffectOverride[abilityId].isPlayerAbility and true or false
        end
    end
end

function CombatTextEventViewer:GetDefaultIcon(ccType)
    if ccType == LUIE_CC_TYPE_STUN then
        return LUIE_CC_ICON_STUN
    elseif ccType == LUIE_CC_TYPE_KNOCKDOWN then
        return LUIE_CC_ICON_STUN
    elseif ccType == LUIE_CC_TYPE_KNOCKBACK then
        return LUIE_CC_ICON_KNOCKBACK
    elseif ccType == LUIE_CC_TYPE_PULL then
        return LUIE_CC_ICON_PULL
    elseif ccType == LUIE_CC_TYPE_DISORIENT then
        return LUIE_CC_ICON_DISORIENT
    elseif ccType == LUIE_CC_TYPE_FEAR then
        return LUIE_CC_ICON_FEAR
    elseif ccType == LUIE_CC_TYPE_CHARM then
        return LUIE_CC_ICON_CHARM
    elseif ccType == LUIE_CC_TYPE_STAGGER then
        return LUIE_CC_ICON_SILENCE
    elseif ccType == LUIE_CC_TYPE_SILENCE then
        return LUIE_CC_ICON_SILENCE
    elseif ccType == LUIE_CC_TYPE_SNARE then
        return LUIE_CC_ICON_SNARE
    elseif ccType == LUIE_CC_TYPE_ROOT then
        return LUIE_CC_ICON_ROOT
    end
end

function CombatTextEventViewer:FormatString(inputFormat, params)
    return (zo_strgsub(inputFormat, "%%.", function (x)
        if x == "%t" then
            return params.text or ""
        elseif x == "%a" then
            return params.value or ""
        elseif x == "%r" then
            return self.resourceNames[params.powerType] or ""
        elseif x == "%d" then
            return self.damageTypes[params.damageType]
        else
            return x
        end
    end))
end

function CombatTextEventViewer:FormatAlertString(inputFormat, params)
    return (zo_strgsub(inputFormat, "%%.", function (x)
        if x == "%n" then
            return params.source or ""
        elseif x == "%t" then
            return params.ability or ""
        elseif x == "%i" then
            return params.icon or ""
        else
            return x
        end
    end))
end

function CombatTextEventViewer:GetTextAttributes(powerType, damageType, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    local Settings = LUIE.CombatText.SV

    local textFormat = Settings.formats.damage
    local fontSize = Settings.fontSizes.damage
    local textColor = Settings.colors.damage[damageType]

    if isDodged then
        textFormat = Settings.formats.dodged
        fontSize = Settings.fontSizes.mitigation
        textColor = Settings.colors.dodged
    elseif isMiss then
        textFormat = Settings.formats.miss
        fontSize = Settings.fontSizes.mitigation
        textColor = Settings.colors.miss
    elseif isImmune then
        textFormat = Settings.formats.immune
        fontSize = Settings.fontSizes.mitigation
        textColor = Settings.colors.immune
    elseif isReflected then
        textFormat = Settings.formats.reflected
        fontSize = Settings.fontSizes.mitigation
        textColor = Settings.colors.reflected
    elseif isDamageShield then
        textFormat = Settings.formats.damageShield
        fontSize = Settings.fontSizes.mitigation
        textColor = Settings.colors.damageShield
    elseif isParried then
        textFormat = Settings.formats.parried
        fontSize = Settings.fontSizes.mitigation
        textColor = Settings.colors.parried
    elseif isBlocked then
        textFormat = Settings.formats.blocked
        fontSize = Settings.fontSizes.mitigation
        textColor = Settings.colors.blocked
    elseif isInterrupted then
        textFormat = Settings.formats.interrupted
        fontSize = Settings.fontSizes.mitigation
        textColor = Settings.colors.interrupted
    elseif isDamageCritical then
        textFormat = Settings.formats.damagecritical
        fontSize = Settings.fontSizes.damagecritical
        if Settings.toggles.criticalDamageOverride then
            textColor = Settings.colors.criticalDamageOverride
        end
    elseif isHealing then
        textFormat = Settings.formats.healing
        fontSize = Settings.fontSizes.healing
        textColor = Settings.colors.healing
    elseif isHealingCritical then
        textFormat = Settings.formats.healingcritical
        fontSize = Settings.fontSizes.healingcritical
        if Settings.toggles.criticalHealingOverride then
            textColor = Settings.colors.criticalHealingOverride
        else
            textColor = Settings.colors.healing
        end
    elseif isEnergize then
        fontSize = Settings.fontSizes.gainLoss
        if powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE then
            textFormat = Settings.formats.ultimateEnergize
            textColor = Settings.colors.energizeUltimate
        else
            textFormat = Settings.formats.energize
            if powerType == COMBAT_MECHANIC_FLAGS_MAGICKA then
                textColor = Settings.colors.energizeMagicka
            elseif powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
                textColor = Settings.colors.energizeStamina
            end
        end
    elseif isDrain then
        textFormat = Settings.formats.drain
        fontSize = Settings.fontSizes.gainLoss
        if powerType == COMBAT_MECHANIC_FLAGS_MAGICKA then
            textColor = Settings.colors.energizeMagicka
        elseif powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
            textColor = Settings.colors.energizeStamina
        end
    elseif isDot then
        textFormat = Settings.formats.dot
        fontSize = Settings.fontSizes.dot
    elseif isDotCritical then
        textFormat = Settings.formats.dotcritical
        fontSize = Settings.fontSizes.dotcritical
        if Settings.toggles.criticalDamageOverride then
            textColor = Settings.colors.criticalDamageOverride
        end
    elseif isHot then
        textFormat = Settings.formats.hot
        fontSize = Settings.fontSizes.hot
        textColor = Settings.colors.healing
    elseif isHotCritical then
        textFormat = Settings.formats.hotcritical
        fontSize = Settings.fontSizes.hotcritical
        if Settings.toggles.criticalHealingOverride then
            textColor = Settings.colors.criticalHealingOverride
        else
            textColor = Settings.colors.healing
        end
    end

    return textFormat, fontSize, textColor
end

function CombatTextEventViewer:ControlLayout(control, abilityId, combatType, sourceName)
    local Settings = LUIE.CombatText.SV
    local width, height = control.label:GetTextDimensions()

    if abilityId then
        -- Determine iconSide first to avoid calculating iconPath if not needed
        local iconSide
        if combatType == CombatTextConstants.combatType.INCOMING then
            iconSide = Settings.animation.incomingIcon
        elseif combatType == CombatTextConstants.combatType.OUTGOING then
            iconSide = Settings.animation.outgoingIcon
        else
            iconSide = "none"
        end

        -- Only calculate iconPath if we're actually going to show the icon
        local iconPath = nil
        if iconSide ~= "none" then
            iconPath = Effects_EffectOverride[abilityId] and Effects_EffectOverride[abilityId].icon or self.abilityIconCache[abilityId]

            if Effects_EffectOverrideByName[abilityId] then
                sourceName = self.sourceNameCache[sourceName]
                if Effects_EffectOverrideByName[abilityId][sourceName] and Effects_EffectOverrideByName[abilityId][sourceName].icon then
                    iconPath = Effects_EffectOverrideByName[abilityId][sourceName].icon
                end
            end

            if Effects_ZoneDataOverride[abilityId] then
                local index = GetZoneId(GetCurrentMapZoneIndex())
                local zoneName = GetPlayerLocationName()
                if Effects_ZoneDataOverride[abilityId][index] then
                    if Effects_ZoneDataOverride[abilityId][index].icon then
                        iconPath = Effects_ZoneDataOverride[abilityId][index].icon
                    end
                end
                if Effects_ZoneDataOverride[abilityId][zoneName] then
                    if Effects_ZoneDataOverride[abilityId][zoneName].icon then
                        iconPath = Effects_ZoneDataOverride[abilityId][zoneName].icon
                    end
                end
            end

            -- Override name, icon, or hide based on Map Name
            if Effects_MapDataOverride[abilityId] then
                local mapName = GetMapName()
                if Effects_MapDataOverride[abilityId][mapName] then
                    if Effects_MapDataOverride[abilityId][mapName].icon then
                        iconPath = Effects_MapDataOverride[abilityId][mapName].icon
                    end
                end
            end

            -- Override icon with default if enabled
            if Settings.common.useDefaultIcon and self:ShouldUseDefaultIcon(abilityId) == true then
                iconPath = self:GetDefaultIcon(Effects_EffectOverride[abilityId].cc)
            end
        end

        if iconPath and iconPath ~= "" and iconSide ~= "none" then
            if iconSide == "left" then
                control.icon:SetAnchor(LEFT, control, LEFT, 0, 0)
                control.label:SetAnchor(LEFT, control.icon, RIGHT, 8, 0)
            elseif iconSide == "right" then
                control.icon:SetAnchor(RIGHT, control, RIGHT, 0, 0)
                control.label:SetAnchor(RIGHT, control.icon, LEFT, -8, 0)
            end
            -- Only update texture if it changed to avoid redundant SetTexture calls
            if control.icon._lastTexture ~= iconPath then
                control.icon:SetTexture(iconPath)
                control.icon._lastTexture = iconPath
            end
            control.icon:SetDimensions(height, height)
            control.icon:SetHidden(false)
            control:SetDimensions(width + height + 8, height)
        else
            control.icon:SetAnchor(CENTER, control, CENTER, 0, 0)
            control.label:SetAnchor(CENTER, control.icon, CENTER, 0, 0)
            control:SetDimensions(width, height)
            -- Clear texture cache when icon is hidden
            if control.icon._lastTexture then
                control.icon._lastTexture = nil
            end
        end
    else
        control.icon:SetAnchor(CENTER, control, CENTER, 0, 0)
        control.label:SetAnchor(CENTER, control.icon, CENTER, 0, 0)
        control:SetDimensions(width, height)
        -- Clear texture cache when icon is hidden
        if control.icon._lastTexture then
            control.icon._lastTexture = nil
        end
    end
    control.icon:SetAlpha(Settings.common.transparencyValue / 100)
end

function CombatTextEventViewer:RegisterCallback(eventType, func)
    local callbackWrapper = function (...)
        func(...)
    end
    callbackManager:RegisterCallback(eventType, callbackWrapper)
    -- Store callback reference for unregistration
    if not self.callbackRefs then
        self.callbackRefs = {}
    end
    if not self.callbackRefs[eventType] then
        self.callbackRefs[eventType] = {}
    end
    table.insert(self.callbackRefs[eventType], callbackWrapper)
end

---
--- @param label LabelControl
--- @param fontSize integer
--- @param color {r: number, g: number, b: number, a?: number}
--- @param text string
function CombatTextEventViewer:PrepareLabel(label, fontSize, color, text)
    local Settings = LUIE.CombatText.SV
    label:SetText(text)
    label:SetColor(unpack(color))
    local fontString = LUIE.CreateFontString(Settings.fontFaceApplied, fontSize, Settings.fontStyle)
    label:SetFont(fontString)
    label:SetAlpha(Settings.common.transparencyValue / 100)
end

---
--- @param control Control
--- @param activeControls {[integer]:Control}
--- @return boolean
function CombatTextEventViewer:IsOverlapping(control, activeControls)
    local p = 5 -- Substract some padding

    local left, top, right, bottom = control:GetScreenRect()
    local p1, p2 = { x = left + p, y = top + p }, { x = right - p, y = bottom - p }

    for _, c in pairs(activeControls) do
        left, top, right, bottom = c:GetScreenRect()
        local p3, p4 = { x = left + p, y = top + p }, { x = right - p, y = bottom - p }

        if p2.y >= p3.y and p1.y <= p4.y and p2.x >= p3.x and p1.x <= p4.x then
            return true
        end
    end

    return false
end
