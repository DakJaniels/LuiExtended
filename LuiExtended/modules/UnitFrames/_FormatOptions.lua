-- -----------------------------------------------------------------------------
-- Unit frame label format options (canonical English tokens for runtime GSUB).
-- -----------------------------------------------------------------------------

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

UnitFrames.FORMAT_DEFAULT = "Current + Shield - Trauma (Percentage%)"
UnitFrames.FORMAT_PT_ONE = "Current + Shield - Trauma / Max"
UnitFrames.FORMAT_PT_TWO = "Percentage%"
UnitFrames.FORMAT_GROUP_ONE = "Current + Shield - Trauma / Max"
UnitFrames.FORMAT_GROUP_TWO = "Percentage%"
UnitFrames.FORMAT_RAID = "Current (Percentage%)"
UnitFrames.FORMAT_BOSS = "Percentage%"
UnitFrames.FORMAT_PET = "Current (Percentage%)"
UnitFrames.FORMAT_COMPANION = "Current (Percentage%)"
UnitFrames.FORMAT_CENTER_LABEL = "Current + Shield - Trauma / Max (Percentage%)"

UnitFrames.FORMAT_SV_KEYS =
{
    "Format",
    "CustomFormatOnePlayer",
    "CustomFormatTwoPlayer",
    "CustomFormatOneTarget",
    "CustomFormatTwoTarget",
    "CustomFormatOneGroup",
    "CustomFormatTwoGroup",
    "CustomFormatRaid",
    "CustomFormatBoss",
    "CustomFormatPet",
    "CustomFormatCompanion",
    "CustomFormatCenterLabel",
}

UnitFrames.FORMAT_OPTION_DEFINITIONS =
{
    { canonical = "Nothing",                                       stringId = LUIE_STRING_LAM_UF_FORMAT_NOTHING                              },
    { canonical = "Current",                                       stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT                              },
    { canonical = "Current + Shield",                              stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD                       },
    { canonical = "Current - Trauma",                              stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_TRAUMA                       },
    { canonical = "Current + Shield - Trauma",                     stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_TRAUMA                },
    { canonical = "Max",                                           stringId = LUIE_STRING_LAM_UF_FORMAT_MAX                                  },
    { canonical = "Percentage%",                                   stringId = LUIE_STRING_LAM_UF_FORMAT_PERCENTAGE                           },
    { canonical = "Current / Max",                                 stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_MAX                          },
    { canonical = "Current + Shield / Max",                        stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_MAX                   },
    { canonical = "Current - Trauma / Max",                        stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_TRAUMA_MAX                   },
    { canonical = "Current + Shield - Trauma / Max",               stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_TRAUMA_MAX            },
    { canonical = "Current / Max (Percentage%)",                   stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_MAX_PERCENTAGE               },
    { canonical = "Current + Shield / Max (Percentage%)",          stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_MAX_PERCENTAGE        },
    { canonical = "Current - Trauma / Max (Percentage%)",          stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_TRAUMA_MAX_PERCENTAGE        },
    { canonical = "Current + Shield - Trauma / Max (Percentage%)", stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_TRAUMA_MAX_PERCENTAGE },
    { canonical = "Current (Percentage%)",                         stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_PERCENTAGE                   },
    { canonical = "Current + Shield (Percentage%)",                stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_PERCENTAGE            },
    { canonical = "Current - Trauma (Percentage%)",                stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_TRAUMA_PERCENTAGE            },
    { canonical = "Current + Shield - Trauma (Percentage%)",       stringId = LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_TRAUMA_PERCENTAGE     },
}

-- Saved values that used localized display text instead of canonical tokens (pre-choicesValues).
local FORMAT_LEGACY_ALIASES =
{
    ["Nichts"] = "Nothing",
    ["Aktuell"] = "Current",
    ["Aktuell + Schild"] = "Current + Shield",
    ["Aktuell - Trauma"] = "Current - Trauma",
    ["Aktuell + Schild - Trauma"] = "Current + Shield - Trauma",
    ["Prozent%"] = "Percentage%",
    ["Aktuell / Max"] = "Current / Max",
    ["Aktuell + Schild / Max"] = "Current + Shield / Max",
    ["Aktuell - Trauma / Max"] = "Current - Trauma / Max",
    ["Aktuell + Schild - Trauma / Max"] = "Current + Shield - Trauma / Max",
    ["Aktuell / Max (Prozent%)"] = "Current / Max (Percentage%)",
    ["Aktuell + Schild / Max (Prozent%)"] = "Current + Shield / Max (Percentage%)",
    ["Aktuell - Trauma / Max (Prozent%)"] = "Current - Trauma / Max (Percentage%)",
    ["Aktuell + Schild - Trauma / Max (Prozent%)"] = "Current + Shield - Trauma / Max (Percentage%)",
    ["Aktuell (Prozent%)"] = "Current (Percentage%)",
    ["Aktuell + Schild (Prozent%)"] = "Current + Shield (Percentage%)",
    ["Aktuell - Trauma (Prozent%)"] = "Current - Trauma (Percentage%)",
    ["Aktuell + Schild - Trauma (Prozent%)"] = "Current + Shield - Trauma (Percentage%)",
    ["%"] = "Percentage%",
    ["Aktuell (%)"] = "Current (Percentage%)",
    ["Aktuell + Schild (%)"] = "Current + Shield (Percentage%)",
    ["Aktuell - Trauma (%)"] = "Current - Trauma (Percentage%)",
    ["Aktuell + Schild - Trauma (%)"] = "Current + Shield - Trauma (Percentage%)",
    ["Aktuell / Max (%)"] = "Current / Max (Percentage%)",
    ["Aktuell + Schild / Max (%)"] = "Current + Shield / Max (Percentage%)",
    ["Aktuell - Trauma / Max (%)"] = "Current - Trauma / Max (Percentage%)",
    ["Aktuell + Schild - Trauma / Max (%)"] = "Current + Shield - Trauma / Max (Percentage%)",
}

local formatLabelToCanonical

local function BuildFormatLabelLookup()
    formatLabelToCanonical = {}
    for _, def in ipairs(UnitFrames.FORMAT_OPTION_DEFINITIONS) do
        formatLabelToCanonical[def.canonical] = def.canonical
        formatLabelToCanonical[GetString(def.stringId)] = def.canonical
    end
    for alias, canonical in pairs(FORMAT_LEGACY_ALIASES) do
        formatLabelToCanonical[alias] = canonical
    end
end

--- @param value string|nil
--- @return string|nil canonical
function UnitFrames.NormalizeFormatOption(value)
    if value == nil or value == "" then
        return value
    end
    if not formatLabelToCanonical then
        BuildFormatLabelLookup()
    end
    return formatLabelToCanonical[value] or value
end

function UnitFrames.GetFormatOptionMenus()
    local choices, values = {}, {}
    for i, def in ipairs(UnitFrames.FORMAT_OPTION_DEFINITIONS) do
        choices[i] = GetString(def.stringId)
        values[i] = def.canonical
    end
    return choices, values
end

function UnitFrames.GetFormatOptionLHASItems()
    local items = {}
    for i, def in ipairs(UnitFrames.FORMAT_OPTION_DEFINITIONS) do
        items[i] =
        {
            name = GetString(def.stringId),
            data = def.canonical,
        }
    end
    return items
end

--- One-time: store English canonical tokens in saved variables (runtime GSUB expects them).
function UnitFrames.MigrateCanonicalFormatStrings()
    if LUIE.IsMigrationDone("unitframes_canonical_format_strings") then
        return
    end
    local sv = UnitFrames.SV
    for _, key in ipairs(UnitFrames.FORMAT_SV_KEYS) do
        if sv[key] ~= nil then
            sv[key] = UnitFrames.NormalizeFormatOption(sv[key])
        end
    end
    LUIE.MarkMigrationDone("unitframes_canonical_format_strings")
end
