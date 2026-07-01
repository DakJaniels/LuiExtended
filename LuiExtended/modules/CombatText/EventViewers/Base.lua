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

--- Combat text event flags for damage, healing, and mitigation states
--- @class CombatTextEventFlags
--- @field isDamage? boolean Direct damage event
--- @field isDamageCritical? boolean Critical direct damage event
--- @field isDot? boolean Damage over time event
--- @field isDotCritical? boolean Critical damage over time event
--- @field isHealing? boolean Direct healing event
--- @field isHealingCritical? boolean Critical direct healing event
--- @field isHot? boolean Healing over time event
--- @field isHotCritical? boolean Critical healing over time event
--- @field isEnergize? boolean Resource gain event
--- @field isDrain? boolean Resource drain event
--- @field isMiss? boolean Attack missed
--- @field isImmune? boolean Target is immune
--- @field isParried? boolean Attack was parried
--- @field isReflected? boolean Attack was reflected
--- @field isDamageShield? boolean Absorbed by damage shield
--- @field isDodged? boolean Attack was dodged
--- @field isBlocked? boolean Attack was blocked
--- @field isInterrupted? boolean Action was interrupted

local CombatText = LUIE.CombatText
local Effects = LuiData_Data.Effects
local CombatTextConstants = LuiData_Data.CombatTextConstants
local Effects_EffectOverride = Effects.EffectOverride
local Effects_EffectOverrideByName = Effects.EffectOverrideByName
local Effects_ZoneDataOverride = Effects.ZoneDataOverride
local Effects_MapDataOverride = Effects.MapDataOverride

CombatTextEventViewer.resourceNames = setmetatable({},
                                                   {
                                                       __index = function (t, k)
                                                           t[k] = GetString("SI_COMBATMECHANICFLAGS", k)
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
-- Weak values: icon strings can be collected when nothing else references them
CombatTextEventViewer.abilityIconCache = setmetatable({},
                                                      {
                                                          __mode = "v",
                                                          __index = function (t, abilityId)
                                                              local icon = GetAbilityIcon(abilityId)
                                                              t[abilityId] = icon
                                                              return icon
                                                          end,
                                                      })
--- Initialize event viewer with pool manager and event listener<br>
--- The event listener provides callback registration for combat events
--- @param poolManager LuiExtended.CombatTextPoolManager Pool manager for control/animation reuse
--- @param eventListener LuiExtended.CombatTextEventListener Event listener with callback support
function CombatTextEventViewer:Initialize(poolManager, eventListener)
    self.poolManager = poolManager
    self.eventListener = eventListener
end

-- Memory optimization: Lookup table for throttle times instead of if-elseif chains
-- Throttle flag mapping: ordered by priority (checked in sequence)
CombatTextEventViewer.THROTTLE_FLAGS =
{
    { flag = "isDamageCritical",  key = "damagecritical"  },
    { flag = "isDamage",          key = "damage"          },
    { flag = "isDotCritical",     key = "dotcritical"     },
    { flag = "isDot",             key = "dot"             },
    { flag = "isHealingCritical", key = "healingcritical" },
    { flag = "isHealing",         key = "healing"         },
    { flag = "isHotCritical",     key = "hotcritical"     },
    { flag = "isHot",             key = "hot"             },
}

-- Crit throttle keys are not exposed in settings; use the matching non-crit slider.
CombatTextEventViewer.THROTTLE_KEY_FALLBACK =
{
    damagecritical = "damage",
    dotcritical = "dot",
    healingcritical = "healing",
    hotcritical = "hot",
}

--- Get the throttle time in milliseconds for the given combat event flags
--- Checks flags in priority order and returns the first matching throttle setting
--- @param Settings table Combat text saved variables settings
--- @param flags CombatTextEventFlags Event state flags
--- @return number throttleTime Time in milliseconds to throttle this event type (0 if no throttle)
function CombatTextEventViewer:GetThrottleTime(Settings, flags)
    for _, mapping in ipairs(self.THROTTLE_FLAGS) do
        if flags[mapping.flag] then
            local key = mapping.key
            local fallbackKey = self.THROTTLE_KEY_FALLBACK[key]
            if fallbackKey then
                return Settings.throttles[fallbackKey] or 0
            end
            return Settings.throttles[key] or 0
        end
    end
    return 0
end

--- Determine if this ability should use the default CC icon instead of the ability icon
--- @param abilityId integer The ability ID to check
--- @return boolean shouldUse True if default CC icon should be used based on settings
function CombatTextEventViewer:ShouldUseDefaultIcon(abilityId)
    local effectData = Effects_EffectOverride[abilityId]
    if not effectData or not effectData.cc then
        return false
    end

    local option = CombatText.SV.common.defaultIconOptions
    if option == 1 then
        return true
    elseif option == 2 or option == 3 then
        return effectData.isPlayerAbility or false
    end

    return false
end

-- CC type to icon lookup table
CombatTextEventViewer.CC_ICON_MAP =
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

--- Get the default icon path for a given crowd control type
--- @param ccType integer The LUIE_CC_TYPE constant
--- @return string? iconPath The icon texture path, or nil if not found
function CombatTextEventViewer:GetDefaultIcon(ccType)
    return self.CC_ICON_MAP[ccType]
end

-- Token replacement maps for different format types
CombatTextEventViewer.FORMAT_TOKENS =
{
    default =
    {
        ["%t"] = function (self, params) return params.text or "" end,
        ["%a"] = function (self, params) return params.value or "" end,
        ["%r"] = function (self, params) return self.resourceNames[params.powerType] or "" end,
        ["%d"] = function (self, params) return self.damageTypes[params.damageType] end,
    },
    alert =
    {
        ["%n"] = function (self, params) return params.source or "" end,
        ["%t"] = function (self, params) return params.ability or "" end,
        ["%i"] = function (self, params) return params.icon or "" end,
    },
}

--- Unified format function with token map selection<br>
--- Replaces format tokens in the input string with values from params using the specified token map
--- @param inputFormat string Format string containing tokens (e.g., "%t dealt %a damage")
--- @param params table Parameters containing replacement values
--- @param tokenMap table<string, fun(self: LuiExtended.CombatTextEventViewer, params: table): string> Token-to-function mapping
--- @return string formatted The formatted string with tokens replaced
function CombatTextEventViewer:FormatStringWithTokens(inputFormat, params, tokenMap)
    return (zo_strgsub(inputFormat, "%%.", function (x)
        local handler = tokenMap[x]
        if handler then
            return handler(self, params)
        end
        return x
    end))
end

--- Format a standard combat text string<br>
--- Tokens: %t=text/ability, %a=value/amount, %r=resource type, %d=damage type
--- @param inputFormat string Format string with tokens
--- @param params table Parameters: {text?, value?, powerType?, damageType?}
--- @return string formatted The formatted string
function CombatTextEventViewer:FormatString(inputFormat, params)
    return self:FormatStringWithTokens(inputFormat, params, self.FORMAT_TOKENS.default)
end

--- Format an alert string<br>
--- Tokens: %n=source name, %t=ability name, %i=icon path
--- @param inputFormat string Format string with tokens
--- @param params table Parameters: {source?, ability?, icon?}
--- @return string formatted The formatted string
function CombatTextEventViewer:FormatAlertString(inputFormat, params)
    return self:FormatStringWithTokens(inputFormat, params, self.FORMAT_TOKENS.alert)
end

-- Text attribute configuration: ordered by priority
CombatTextEventViewer.TEXT_ATTRIBUTE_CONFIG =
{
    -- Mitigation effects (highest priority)
    { flag = "isDodged",       format = "dodged",       fontSize = "mitigation", color = "dodged"       },
    { flag = "isMiss",         format = "miss",         fontSize = "mitigation", color = "miss"         },
    { flag = "isImmune",       format = "immune",       fontSize = "mitigation", color = "immune"       },
    { flag = "isReflected",    format = "reflected",    fontSize = "mitigation", color = "reflected"    },
    { flag = "isDamageShield", format = "damageShield", fontSize = "mitigation", color = "damageShield" },
    { flag = "isParried",      format = "parried",      fontSize = "mitigation", color = "parried"      },
    { flag = "isBlocked",      format = "blocked",      fontSize = "mitigation", color = "blocked"      },
    { flag = "isInterrupted",  format = "interrupted",  fontSize = "mitigation", color = "interrupted"  },

    -- Critical damage/heal effects
    {
        flag = "isDamageCritical",
        format = "damagecritical",
        fontSize = "damagecritical",
        colorFunc = function (Settings, damageType)
            return Settings.toggles.criticalDamageOverride and Settings.colors.criticalDamageOverride
                or Settings.colors.damage[damageType]
        end
    },
    {
        flag = "isHealingCritical",
        format = "healingcritical",
        fontSize = "healingcritical",
        colorFunc = function (Settings)
            return Settings.toggles.criticalHealingOverride and Settings.colors.criticalHealingOverride
                or Settings.colors.healing
        end
    },

    -- Resource management
    {
        flag = "isEnergize",
        fontSize = "gainLoss",
        formatFunc = function (powerType)
            return powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE and "ultimateEnergize" or "energize"
        end,
        colorFunc = function (Settings, _, powerType)
            if powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE then
                return Settings.colors.energizeUltimate
            elseif powerType == COMBAT_MECHANIC_FLAGS_MAGICKA then
                return Settings.colors.energizeMagicka
            elseif powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
                return Settings.colors.energizeStamina
            end
        end
    },
    {
        flag = "isDrain",
        format = "drain",
        fontSize = "gainLoss",
        colorFunc = function (Settings, _, powerType)
            if powerType == COMBAT_MECHANIC_FLAGS_MAGICKA then
                return Settings.colors.energizeMagicka
            elseif powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
                return Settings.colors.energizeStamina
            elseif powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE then
                return Settings.colors.energizeUltimate
            elseif powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
                return Settings.colors.healing
            end
            return Settings.colors.energizeMagicka
        end
    },

    -- Standard healing/damage
    { flag = "isHealing", format = "healing", fontSize = "healing", color = "healing" },

    -- DoT/HoT effects
    { flag = "isDot",     format = "dot",     fontSize = "dot"                        },
    {
        flag = "isDotCritical",
        format = "dotcritical",
        fontSize = "dotcritical",
        colorFunc = function (Settings, damageType)
            return Settings.toggles.criticalDamageOverride and Settings.colors.criticalDamageOverride
                or Settings.colors.damage[damageType]
        end
    },
    { flag = "isHot", format = "hot", fontSize = "hot", color = "healing" },
    {
        flag = "isHotCritical",
        format = "hotcritical",
        fontSize = "hotcritical",
        colorFunc = function (Settings)
            return Settings.toggles.criticalHealingOverride and Settings.colors.criticalHealingOverride
                or Settings.colors.healing
        end
    },
}

--- Get text formatting attributes (format, size, color) based on combat event flags<br>
--- Uses priority-ordered configuration table to determine appropriate text styling
--- @param powerType integer? Combat mechanic flags for resource type (COMBAT_MECHANIC_FLAGS_*)
--- @param damageType integer? Damage type constant (DAMAGE_TYPE_*)
--- @param flags CombatTextEventFlags Event state flags
--- @return string textFormat Format string from settings
--- @return number fontSize Font size in points
--- @return table textColor RGB color table {r, g, b, a?}
function CombatTextEventViewer:GetTextAttributes(powerType, damageType, flags)
    local Settings = LUIE.CombatText.SV

    -- Default values
    local textFormat = CombatText.GetFormat("damage")
    local fontSize = Settings.fontSizes.damage
    local textColor = Settings.colors.damage[damageType]

    -- Check each configuration rule in priority order
    for _, config in ipairs(self.TEXT_ATTRIBUTE_CONFIG) do
        if flags[config.flag] then
            -- Determine format
            if config.formatFunc then
                textFormat = CombatText.GetFormat(config.formatFunc(powerType))
            elseif config.format then
                textFormat = CombatText.GetFormat(config.format)
            end

            -- Determine font size
            if config.fontSize then
                fontSize = Settings.fontSizes[config.fontSize]
            end

            -- Determine color
            if config.colorFunc then
                textColor = config.colorFunc(Settings, damageType, powerType) or textColor
            elseif config.color then
                textColor = Settings.colors[config.color]
            end

            break -- First match wins
        end
    end

    return textFormat, fontSize, textColor
end

--- Apply contextual icon overrides based on zone/map/source<br>
--- Resolves icon path in priority order: base ability --> source name --> zone --> map --> default CC icon
--- @param abilityId integer The ability ID
--- @param sourceName string The source/caster name
--- @return string? iconPath The resolved icon texture path, or nil if not found
function CombatTextEventViewer:GetResolvedIconPath(abilityId, sourceName)
    local iconPath = Effects_EffectOverride[abilityId] and Effects_EffectOverride[abilityId].icon
        or self.abilityIconCache[abilityId]

    -- Override by source name
    if Effects_EffectOverrideByName[abilityId] then
        sourceName = zo_strformat("<<C:1>>", sourceName)
        local nameOverride = Effects_EffectOverrideByName[abilityId][sourceName]
        if nameOverride and nameOverride.icon then
            iconPath = nameOverride.icon
        end
    end

    -- Override by zone
    if Effects_ZoneDataOverride[abilityId] then
        local zoneId = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()

        local zoneOverride = Effects_ZoneDataOverride[abilityId][zoneId]
            or Effects_ZoneDataOverride[abilityId][zoneName]
        if zoneOverride and zoneOverride.icon then
            iconPath = zoneOverride.icon
        end
    end

    -- Override by map
    if Effects_MapDataOverride[abilityId] then
        local mapName = GetMapName()
        local mapOverride = Effects_MapDataOverride[abilityId][mapName]
        if mapOverride and mapOverride.icon then
            iconPath = mapOverride.icon
        end
    end

    -- Override with default CC icon if enabled
    local Settings = LUIE.CombatText.SV
    if Settings.common.useDefaultIcon and self:ShouldUseDefaultIcon(abilityId) then
        iconPath = self:GetDefaultIcon(Effects_EffectOverride[abilityId].cc)
    end

    return iconPath
end

--- Determine which side to show the icon on based on combat type
--- @param combatType integer CombatTextConstants.combatType (INCOMING or OUTGOING)
--- @return string iconSide "left", "right", or "none"
function CombatTextEventViewer:GetIconSide(combatType)
    local Settings = LUIE.CombatText.SV
    if combatType == CombatTextConstants.combatType.INCOMING then
        return Settings.animation.incomingIcon
    elseif combatType == CombatTextConstants.combatType.OUTGOING then
        return Settings.animation.outgoingIcon
    end
    return "none"
end

local COMBAT_TEXT_ICON_ART_INSET = 2
local COMBAT_TEXT_ICON_CHROME_WHITE = { 1, 1, 1, 1 }

--- ZOS Skills ability slots (SkillsComponents_Keyboard.lua / SkillsComponents_Gamepad.lua) — neutral frames, not abilityFrame_buff/debuff.
local function GetCombatTextActiveIconFrameTexture()
    if IsInGamepadPreferredMode() then
        return "EsoUI/Art/ActionBar/Gamepad/gp_abilityFrame64.dds"
    end
    return "EsoUI/Art/ActionBar/abilityFrame64_up.dds"
end

local function GetCombatTextPassiveIconFrameTexture()
    if IsInGamepadPreferredMode() then
        return "EsoUI/Art/Miscellaneous/Gamepad/gp_passiveFrame_64.dds"
    end
    return "EsoUI/Art/ActionBar/passiveAbilityFrame_round_up.dds"
end

--- Round Skills frame when the combat id is the passive skill or LuiData links it via tooltipMorphId (e.g. Wildfire Embers DoT → 259224).
--- @param abilityId integer|nil
--- @return boolean
function CombatTextEventViewer:ShouldUsePassiveSkillIconFrame(abilityId)
    if not abilityId then
        return false
    end
    if IsAbilityPassive(abilityId) then
        return true
    end
    local effectOverride = Effects_EffectOverride[abilityId]
    local morphAbilityId = effectOverride and effectOverride.tooltipMorphId
    if morphAbilityId and IsAbilityPassive(morphAbilityId) then
        return true
    end
    return false
end

--- @param abilityId integer|nil
--- @return string
function CombatTextEventViewer:GetCombatTextIconFrameTexture(abilityId)
    if self:ShouldUsePassiveSkillIconFrame(abilityId) then
        return GetCombatTextPassiveIconFrameTexture()
    end
    return GetCombatTextActiveIconFrameTexture()
end

--- @param texturePath string?
--- @return string|nil
local function NormalizeCombatTextIconTextureKey(texturePath)
    if not texturePath or texturePath == "" then
        return nil
    end
    local key = zo_strlower(texturePath)
    key = key:gsub("\\", "/")
    if zo_strsub(key, 1, 1) == "/" then
        key = zo_strsub(key, 2)
    end
    return key
end

--- @param texturePath string|nil
--- @return number[]|nil
local function GetIconFrameColorSampleForTexturePath(texturePath)
    if ZO_IsConsoleOrGameCoreUI() then
        return nil
    end
    local sampleKey = NormalizeCombatTextIconTextureKey(texturePath)
    if not sampleKey then
        return nil
    end
    return LuiData_Data.IconFrameColorSamples[sampleKey]
end

--- @param iconTexturePath string|nil
--- @param abilityId integer|nil
--- @return table {r,g,b,a}
function CombatTextEventViewer:GetCombatTextIconFrameColor(iconTexturePath, abilityId)
    if ZO_IsConsoleOrGameCoreUI() or not LUIE.CombatText.SV.animation.colorIconFrame then
        return COMBAT_TEXT_ICON_CHROME_WHITE
    end

    local sampledColor = GetIconFrameColorSampleForTexturePath(iconTexturePath)
    if sampledColor then
        return sampledColor
    end

    if abilityId then
        sampledColor = GetIconFrameColorSampleForTexturePath(self.abilityIconCache[abilityId])
        if sampledColor then
            return sampledColor
        end

        local effectOverride = Effects_EffectOverride[abilityId]
        if effectOverride then
            sampledColor = GetIconFrameColorSampleForTexturePath(effectOverride.icon)
            if sampledColor then
                return sampledColor
            end
            if effectOverride.tooltipMorphId then
                sampledColor = GetIconFrameColorSampleForTexturePath(GetAbilityIcon(effectOverride.tooltipMorphId))
                if sampledColor then
                    return sampledColor
                end
            end
        end
    end

    return COMBAT_TEXT_ICON_CHROME_WHITE
end

---@class iconHostFrameControl : Control
---@field iconHost TextureControl
---@field iconFrame TextureControl
---@field icon TextureControl
---@field label LabelControl

--- @param control iconHostFrameControl
--- @param abilityId integer|nil
--- @param iconSize number
--- @param showFrame boolean
--- @param iconTintColor table|nil
--- @param iconTexturePath string|nil
function CombatTextEventViewer:ApplyCombatTextIconChrome(control, abilityId, iconSize, showFrame, iconTintColor, iconTexturePath)
    if not control.iconHost or not control.icon then
        return
    end

    control.iconHost:SetDimensions(iconSize, iconSize)
    control.iconHost:SetHidden(false)

    if showFrame and control.iconFrame then
        control.iconFrame:ClearAnchors()
        control.iconFrame:SetAnchor(TOPLEFT, control.iconHost, TOPLEFT, 0, 0)
        control.iconFrame:SetAnchor(BOTTOMRIGHT, control.iconHost, BOTTOMRIGHT, 0, 0)
        control.iconFrame:SetTexture(self:GetCombatTextIconFrameTexture(abilityId))
        local frameColor = self:GetCombatTextIconFrameColor(iconTexturePath, abilityId)
        control.iconFrame:SetColor(frameColor[1], frameColor[2], frameColor[3], frameColor[4])
        control.iconFrame:SetHidden(false)

        control.icon:ClearAnchors()
        control.icon:SetAnchor(TOPLEFT, control.iconHost, TOPLEFT, COMBAT_TEXT_ICON_ART_INSET, COMBAT_TEXT_ICON_ART_INSET)
        control.icon:SetAnchor(BOTTOMRIGHT, control.iconHost, BOTTOMRIGHT, -COMBAT_TEXT_ICON_ART_INSET, -COMBAT_TEXT_ICON_ART_INSET)
    else
        if control.iconFrame then
            control.iconFrame:SetHidden(true)
        end
        control.icon:ClearAnchors()
        control.icon:SetAnchor(TOPLEFT, control.iconHost, TOPLEFT, 0, 0)
        control.icon:SetAnchor(BOTTOMRIGHT, control.iconHost, BOTTOMRIGHT, 0, 0)
    end
end

--- Position icon and label based on icon side<br>
--- Sets anchors, dimensions, and texture. Uses texture caching to avoid redundant SetTexture calls
--- @param control iconHostFrameControl The combat text control containing icon and label
--- @param iconSide string "left", "right", or "none"
--- @param iconPath string? The icon texture path
--- @param width number Label text width in pixels
--- @param height number Label text height in pixels
--- @param abilityId integer|nil
--- @param iconTintColor table|nil
function CombatTextEventViewer:PositionIconAndLabel(control, iconSide, iconPath, width, height, abilityId, iconTintColor)
    if iconPath and iconPath ~= "" and iconSide ~= "none" then
        local Settings = LUIE.CombatText.SV
        -- Set anchors based on side
        if iconSide == "left" then
            control.iconHost:SetAnchor(LEFT, control, LEFT, 0, 0)
            control.label:SetAnchor(LEFT, control.iconHost, RIGHT, 8, 0)
        elseif iconSide == "right" then
            control.iconHost:SetAnchor(RIGHT, control, RIGHT, 0, 0)
            control.label:SetAnchor(RIGHT, control.iconHost, LEFT, -8, 0)
        end

        -- Only update texture if changed (performance optimization)
        if control.icon._lastTexture ~= iconPath then
            control.icon:SetTexture(iconPath)
            control.icon._lastTexture = iconPath
        end

        self:ApplyCombatTextIconChrome(control, abilityId, height, Settings.animation.showIconFrame, iconTintColor, iconPath)
        control.icon:SetHidden(false)
        control:SetDimensions(width + height + 8, height)
    else
        -- No icon: center everything
        self:HideIcon(control, width, height)
    end
end

--- Hide icon and center label<br>
--- Clears texture cache and resets control dimensions
--- @param control iconHostFrameControl The combat text control
--- @param width number Label text width in pixels
--- @param height number Label text height in pixels
function CombatTextEventViewer:HideIcon(control, width, height)
    if control.iconHost then
        control.iconHost:SetHidden(true)
    end
    if control.iconFrame then
        control.iconFrame:SetHidden(true)
    end
    control.icon:SetHidden(true)
    control.label:SetAnchor(CENTER, control, CENTER, 0, 0)
    control:SetDimensions(width, height)

    -- Clear texture cache
    if control.icon._lastTexture then
        control.icon._lastTexture = nil
    end
end

--- Layout combat text control with optional ability icon<br>
--- Resolves icon, determines positioning, and applies layout
--- @param control iconHostFrameControl The combat text control to layout
--- @param abilityId integer? The ability ID (nil for no icon)
--- @param combatType integer? CombatTextConstants.combatType
--- @param sourceName string? The source/caster name
--- @param iconTintColor table|nil {r,g,b,a} label color for optional frame tint
function CombatTextEventViewer:ControlLayout(control, abilityId, combatType, sourceName, iconTintColor)
    local Settings = LUIE.CombatText.SV
    control.label:Clean()
    local width, height = control.label:GetTextDimensions()

    if abilityId then
        local iconSide = self:GetIconSide(combatType)

        -- Only calculate icon path if we're showing an icon
        local iconPath = nil
        if iconSide ~= "none" then
            iconPath = self:GetResolvedIconPath(abilityId, sourceName)
        end

        self:PositionIconAndLabel(control, iconSide, iconPath, width, height, abilityId, iconTintColor)
    else
        self:HideIcon(control, width, height)
    end

    local textAlpha = LUIE.CombatText.GetTextAlpha()
    if control.iconHost then
        control.iconHost:SetAlpha(textAlpha)
    else
        control.icon:SetAlpha(textAlpha)
    end
end

--- Register a callback for a combat text event<br>
--- Uses the event listener's instance-based callback system.
--- Tracks the (eventType, func) pair on the viewer so `Destroy` can unregister it
--- when the viewer is swapped (e.g. user changes animation type in settings).
--- @param eventType string The event type identifier
--- @param func function The callback function to register
function CombatTextEventViewer:RegisterCallback(eventType, func)
    if not self.eventListener then
        d("[LUIE] ERROR: EventViewer has no eventListener reference!")
        return
    end
    self.eventListener:RegisterCallback(eventType, func)

    if not self._registeredCallbacks then
        self._registeredCallbacks = {}
    end
    self._registeredCallbacks[#self._registeredCallbacks + 1] = { eventType = eventType, func = func }
end

--- Unregister all callbacks this viewer registered on its event listener and
--- drop the listener reference. Must be called before discarding the viewer
--- (e.g. in `CombatText.CreateCombatEventViewer` before assigning a new viewer)
--- to prevent the old closure (which captures `self`) from being retained by
--- the listener's `callbackRegistry`.
function CombatTextEventViewer:Destroy()
    if self._registeredCallbacks and self.eventListener then
        for i = 1, #self._registeredCallbacks do
            local entry = self._registeredCallbacks[i]
            self.eventListener:UnregisterCallback(entry.eventType, entry.func)
        end
    end
    self._registeredCallbacks = nil
    self.eventListener = nil
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
    -- Named fonts apply directly (no composition); custom slug faces compose per size,
    -- memoized per size so heavy combat does not allocate a font string per event.
    if LUIE.CombatText.fontIsNamed then
        label:SetFont(Settings.fontFaceApplied)
    else
        local fontStringCache = LUIE.CombatText.fontStringCache
        if not fontStringCache then
            fontStringCache = {}
            LUIE.CombatText.fontStringCache = fontStringCache
        end
        local fontString = fontStringCache[fontSize]
        if not fontString then
            fontString = LUIE.CreateFontString(Settings.fontFaceApplied, fontSize, Settings.fontStyle)
            fontStringCache[fontSize] = fontString
        end
        label:SetFont(fontString)
    end
    label:SetAlpha(LUIE.CombatText.GetTextAlpha())
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
