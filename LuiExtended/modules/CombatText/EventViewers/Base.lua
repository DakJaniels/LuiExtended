-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class CombatTextEventViewer : ZO_InitializingObject
local CombatTextEventViewer = ZO_InitializingObject:Subclass()
local CombatText = LUIE.CombatText
local string_format = string.format
local Effects = LuiData.Data.Effects
local CombatTextConstants = LuiData.Data.CombatTextConstants

local callbackManager = LUIE.callbackObject

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

function CombatTextEventViewer:New(poolManager, LMP)
    local obj = setmetatable({}, self)
    self.poolManager = poolManager
    self.LMP = LMP
    return obj
end

function CombatTextEventViewer:ShouldUseDefaultIcon(abilityId)
    if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].cc then
        if CombatText.SV.common.defaultIconOptions == 1 then
            -- All Crowd Control
            return true
        elseif CombatText.SV.common.defaultIconOptions == 2 then
            -- NPC CC Only - return true if NOT a player ability
            return not Effects.EffectOverride[abilityId].isPlayerAbility
        elseif CombatText.SV.common.defaultIconOptions == 3 then
            -- Player CC Only
            return Effects.EffectOverride[abilityId].isPlayerAbility
        end
    end
    return false
end

-- Icon lookup table for crowd control types
CombatTextEventViewer.ccIconTable =
{
    [LUIE_CC_TYPE_STUN] = LUIE_CC_ICON_STUN,
    [LUIE_CC_TYPE_KNOCKDOWN] = LUIE_CC_ICON_STUN,
    [LUIE_CC_TYPE_KNOCKBACK] = LUIE_CC_ICON_KNOCKBACK,
    [LUIE_CC_TYPE_PULL] = LUIE_CC_ICON_PULL,
    [LUIE_CC_TYPE_DISORIENT] = LUIE_CC_ICON_DISORIENT,
    [LUIE_CC_TYPE_FEAR] = LUIE_CC_ICON_FEAR,
    [LUIE_CC_TYPE_CHARM] = LUIE_CC_ICON_CHARM,
    [LUIE_CC_TYPE_STAGGER] = LUIE_CC_ICON_SILENCE,
    [LUIE_CC_TYPE_SILENCE] = LUIE_CC_ICON_SILENCE,
    [LUIE_CC_TYPE_SNARE] = LUIE_CC_ICON_SNARE,
    [LUIE_CC_TYPE_ROOT] = LUIE_CC_ICON_ROOT,
}

--- Gets the default icon for a specific crowd control type
--- @param ccType number The crowd control type constant
--- @return string|nil @The icon path for the CC type or nil if not found
function CombatTextEventViewer:GetDefaultIcon(ccType)
    return self.ccIconTable[ccType]
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
        local iconPath = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].icon or GetAbilityIcon(abilityId)

        if Effects.EffectOverrideByName[abilityId] then
            sourceName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
            if Effects.EffectOverrideByName[abilityId][sourceName] and Effects.EffectOverrideByName[abilityId][sourceName].icon then
                iconPath = Effects.EffectOverrideByName[abilityId][sourceName].icon
            end
        end

        if Effects.ZoneDataOverride[abilityId] then
            local index = GetZoneId(GetCurrentMapZoneIndex())
            local zoneName = GetPlayerLocationName()
            if Effects.ZoneDataOverride[abilityId][index] then
                if Effects.ZoneDataOverride[abilityId][index].icon then
                    iconPath = Effects.ZoneDataOverride[abilityId][index].icon
                end
            end
            if Effects.ZoneDataOverride[abilityId][zoneName] then
                if Effects.ZoneDataOverride[abilityId][zoneName].icon then
                    iconPath = Effects.ZoneDataOverride[abilityId][zoneName].icon
                end
            end
        end

        -- Override name, icon, or hide based on Map Name
        if Effects.MapDataOverride[abilityId] then
            local mapName = GetMapName()
            if Effects.MapDataOverride[abilityId][mapName] then
                if Effects.MapDataOverride[abilityId][mapName].icon then
                    iconPath = Effects.MapDataOverride[abilityId][mapName].icon
                end
            end
        end

        -- Override icon with default if enabled
        if Settings.common.useDefaultIcon and self:ShouldUseDefaultIcon(abilityId) == true then
            iconPath = self:GetDefaultIcon(Effects.EffectOverride[abilityId].cc)
        end

        if iconPath and iconPath ~= "" then
            local S = LUIE.CombatText.SV
            local iconSide
            if combatType == CombatTextConstants.combatType.INCOMING then
                iconSide = Settings.animation.incomingIcon
            elseif combatType == CombatTextConstants.combatType.OUTGOING then
                iconSide = Settings.animation.outgoingIcon
            else
                iconSide = "none"
            end

            if iconSide == "none" then
                control.icon:SetAnchor(CENTER, control, CENTER, 0, 0)
                control.label:SetAnchor(CENTER, control.icon, CENTER, 0, 0)
                control:SetDimensions(width, height)
            else
                if iconSide == "left" then
                    control.icon:SetAnchor(LEFT, control, LEFT, 0, 0)
                    control.label:SetAnchor(LEFT, control.icon, RIGHT, 8, 0)
                elseif iconSide == "right" then
                    control.icon:SetAnchor(RIGHT, control, RIGHT, 0, 0)
                    control.label:SetAnchor(RIGHT, control.icon, LEFT, -8, 0)
                end
                control.icon:SetTexture(iconPath)
                control.icon:SetDimensions(height, height)
                control.icon:SetHidden(false)
                control:SetDimensions(width + height + 8, height)
            end
        else
            control.icon:SetAnchor(CENTER, control, CENTER, 0, 0)
            control.label:SetAnchor(CENTER, control.icon, CENTER, 0, 0)
            control:SetDimensions(width, height)
        end
    else
        control.icon:SetAnchor(CENTER, control, CENTER, 0, 0)
        control.label:SetAnchor(CENTER, control.icon, CENTER, 0, 0)
        control:SetDimensions(width, height)
    end
    control.icon:SetAlpha(Settings.common.transparencyValue / 100)
end

function CombatTextEventViewer:RegisterCallback(eventType, func)
    callbackManager:RegisterCallback(eventType, function (...)
        func(...)
    end)
end

function CombatTextEventViewer:PrepareLabel(label, fontSize, color, text)
    local Settings = LUIE.CombatText.SV
    label:SetText(text)
    label:SetColor(unpack(color))
    label:SetFont(string_format("%s|%d|%s", Settings.fontFaceApplied, fontSize, Settings.fontStyle))
    label:SetAlpha(Settings.common.transparencyValue / 100)
end

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

LUIE.CombatTextEventViewer = CombatTextEventViewer
