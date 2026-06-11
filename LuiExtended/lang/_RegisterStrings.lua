-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

local pairs = pairs

local registeredDefaultStringValues = {}

--- Register addon string IDs from a locale file.
--- @param strings table<string, string>
--- @param isTranslation boolean|nil When true, applies SafeAddString for the active client language.
function LUIE_RegisterStrings(strings, isTranslation)
    for stringId, stringValue in pairs(strings) do
        if isTranslation then
            local numericStringId = _G[stringId]
            if numericStringId ~= nil then
                SafeAddString(numericStringId, stringValue, 2)
            end
        else
            registeredDefaultStringValues[stringId] = stringValue
            ZO_CreateStringId(stringId, stringValue)
            SafeAddVersion(stringId, 1)
            local numericStringId = _G[stringId]
            if type(numericStringId) == "number" then
                registeredDefaultStringValues[numericStringId] = stringValue
            end
        end
    end
end

--- Returns the literal default.lua string for a registered LUIE string id (English canonical text).
--- @param stringId integer|string
--- @return string|nil
function LUIE_GetRegisteredDefaultString(stringId)
    return registeredDefaultStringValues[stringId]
end
