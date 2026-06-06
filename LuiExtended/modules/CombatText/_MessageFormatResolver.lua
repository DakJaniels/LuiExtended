-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- Combat Text user-editable format strings in SavedVariables.
--- SV keeps English default.lua text when not customized; runtime and LAM resolve via GetString.

--- @class (partial) LuiExtended.CombatText
local CombatText = LUIE.CombatText

--- @type table<string, integer|string>
CombatText.FormatStringIds =
{
    miss = LUIE_STRING_CT_MISS_DEFAULT,
    immune = LUIE_STRING_CT_IMMUNE_DEFAULT,
    parried = LUIE_STRING_CT_PARRIED_DEFAULT,
    reflected = LUIE_STRING_CT_REFLECTED_DEFAULT,
    dodged = LUIE_STRING_CT_DODGED_DEFAULT,
    interrupted = LUIE_STRING_CT_INTERRUPTED_DEFAULT,
    disoriented = LUIE_STRING_LAM_CT_SHARED_DISORIENTED,
    feared = LUIE_STRING_LAM_CT_SHARED_FEARED,
    offBalanced = LUIE_STRING_LAM_CT_SHARED_OFF_BALANCE,
    silenced = LUIE_STRING_LAM_CT_SHARED_SILENCED,
    stunned = LUIE_STRING_LAM_CT_SHARED_STUNNED,
    charmed = LUIE_STRING_LAM_CT_SHARED_CHARMED,
    inCombat = LUIE_STRING_CT_COMBAT_IN_DEFAULT,
    outCombat = LUIE_STRING_CT_COMBAT_OUT_DEFAULT,
    death = LUIE_STRING_CT_DEATH_DEFAULT,
    ultimateReady = LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY,
    potionReady = LUIE_STRING_LAM_CT_SHARED_POTION_READY,
}

--- @param stored string|nil
--- @param stringId integer|string
--- @return boolean
local function isDefaultStoredFormat(stored, stringId)
    if stored == nil or stored == "" then
        return true
    end
    local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
    if canonicalEnglish and stored == canonicalEnglish then
        return true
    end
    local localized = GetString(stringId)
    if localized and stored == localized then
        return true
    end
    return false
end

--- @param stored string|nil
--- @param stringId integer|string
--- @return string
local function resolveStoredFormat(stored, stringId)
    if isDefaultStoredFormat(stored, stringId) then
        return GetString(stringId)
    end
    return stored or GetString(stringId)
end

--- Sets CombatText.Defaults.formats localized fields to English canonical (ZO_SavedVars merge sentinel).
function CombatText.RefreshMessageFormatDefaultsTable()
    local defaults = CombatText.Defaults
    if not defaults or not defaults.formats then
        return
    end
    local formatIds = CombatText.FormatStringIds
    if not formatIds then
        return
    end
    for key, stringId in pairs(formatIds) do
        local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
        if canonicalEnglish then
            defaults.formats[key] = canonicalEnglish
        end
    end
end

--- Rewrites legacy localized defaults in SV back to English canonical (not customized).
function CombatText.NormalizeStoredMessageFormats()
    local sv = CombatText.SV
    if not sv or not sv.formats then
        return
    end
    local formatIds = CombatText.FormatStringIds
    if not formatIds then
        return
    end
    for key, stringId in pairs(formatIds) do
        local stored = sv.formats[key]
        local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
        if canonicalEnglish and isDefaultStoredFormat(stored, stringId) and stored ~= canonicalEnglish then
            sv.formats[key] = canonicalEnglish
        end
    end
end

--- @param formatKey string
--- @return string
function CombatText.GetFormat(formatKey)
    local sv = CombatText.SV
    if not sv or not sv.formats then
        return ""
    end
    local stringId = CombatText.FormatStringIds and CombatText.FormatStringIds[formatKey]
    if not stringId then
        return sv.formats[formatKey] or ""
    end
    return resolveStoredFormat(sv.formats[formatKey], stringId)
end

--- @param formatKey string
--- @param value string
function CombatText.SetFormat(formatKey, value)
    local sv = CombatText.SV
    if not sv or not sv.formats then
        return
    end
    local stringId = CombatText.FormatStringIds and CombatText.FormatStringIds[formatKey]
    if stringId and isDefaultStoredFormat(value, stringId) then
        sv.formats[formatKey] = LUIE_GetRegisteredDefaultString(stringId) or value
    else
        sv.formats[formatKey] = value
    end
end
