-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local FontsList = {}
local LMP = LibMediaProvider
if LMP then
    -- Add LUIE fonts first
    for f, _ in pairs(LUIE.Fonts) do
        table.insert(FontsList, f)
    end
    -- Add LMP fonts
    for _, font in ipairs(LMP:List(LMP.MediaType.FONT)) do
        -- Only add if not already in list
        if not LUIE.Fonts[font] then
            table.insert(FontsList, font)
        end
    end
end

-- Get sounds from LibMediaProvider
local SoundsList = {}
if LMP then
    -- Add LUIE sounds first
    for sound, _ in pairs(LUIE.Sounds) do
        table.insert(SoundsList, sound)
    end
    -- Add LMP sounds
    for _, sound in ipairs(LMP:List(LMP.MediaType.SOUND)) do
        -- Only add if not already in list
        if not LUIE.Sounds[sound] then
            table.insert(SoundsList, sound)
        end
    end
end

-- Get statusbar textures from LibMediaProvider
local StatusbarTexturesList = {}
if LMP then
    -- Add LUIE textures first
    for key, _ in pairs(LUIE.StatusbarTextures) do
        table.insert(StatusbarTexturesList, key)
    end
    -- Add LMP statusbar textures
    for _, texture in ipairs(LMP:List(LMP.MediaType.STATUSBAR)) do
        -- Only add if not already in list
        if not LUIE.StatusbarTextures[texture] then
            table.insert(StatusbarTexturesList, texture)
        end
    end
end

--- @class (partial) LUIE.CombatText
local CombatText = LUIE.CombatText
local CombatTextConstants = LUIE.Data.CombatTextConstants
local BlacklistPresets = LUIE.Data.CombatTextBlacklistPresets

local type, pairs = type, pairs
local table_insert = table.insert
local zo_strformat = zo_strformat

local globalIconOptions = { "All Crowd Control", "NPC CC Only", "Player CC Only" }
local globalIconOptionsKeys = { ["All Crowd Control"] = 1, ["NPC CC Only"] = 2, ["Player CC Only"] = 3 }

local callbackManager = LUIE.callbackObject

local Blacklist, BlacklistValues = {}, {}

-- Create a list of abilityId's / abilityName's to use for Blacklist
local function GenerateCustomList(input)
    local options, values = {}, {}
    local counter = 0
    for id in pairs(input) do
        counter = counter + 1
        -- If the input is a numeric value then we can pull this abilityId's info.
        if type(id) == "number" then
            options[counter] = zo_iconFormat(GetAbilityIcon(id), 16, 16) .. " [" .. id .. "] " .. zo_strformat("<<C:1>>", GetAbilityName(id))
            -- If the input is not numeric then add this as a name only.
        else
            options[counter] = id
        end
        values[counter] = id
    end
    return options, values
end

local dialogs =
{
    [1] =
    { -- Clear Blacklist
        identifier = "LUIE_CLEAR_CT_BLACKLIST",
        title = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG), GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER)),
        callback = function (dialog)
            CombatText.ClearCustomList(CombatText.SV.blacklist)
            LUIE_BlacklistCT:UpdateChoices(GenerateCustomList(CombatText.SV.blacklist))
        end,
    },
}

local function loadDialogButtons()
    for i = 1, #dialogs do
        local dialog = dialogs[i]
        LUIE.RegisterDialogueButton(dialog.identifier, dialog.title, dialog.text, dialog.callback)
    end
end

function CombatText.CreateSettings()
    -- Load LibAddonMenu
    local LAM = LibAddonMenu2
    if LAM == nil then
        return
    end

    local Defaults = CombatText.Defaults
    local Settings = CombatText.SV

    -- Load Dialog Buttons
    loadDialogButtons()

    local panelDataCombatText =
    {
        type = "panel",
        name = zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_CT)),
        displayName = zo_strformat("<<1>> <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_CT)),
        author = LUIE.author .. "\n",
        version = LUIE.version,
        website = LUIE.website,
        feedback = LUIE.feedback,
        translation = LUIE.translation,
        donation = LUIE.donation,
        slashCommand = "/luict",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsDataCombatText = {}

    -- Combat Text Description
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "description",
        text = GetString(LUIE_STRING_LAM_CT_DESCRIPTION),
    }

    -- ReloadUI Button
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        func = function ()
            ReloadUI("ingame")
        end,
        width = "full",
    }

    -- Unlock Panels
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "checkbox",
        width = "half",
        name = GetString(LUIE_STRING_LAM_CT_UNLOCK),
        tooltip = GetString(LUIE_STRING_LAM_CT_UNLOCK_TP),
        default = Defaults.unlocked,
        getFunc = function ()
            return Settings.unlocked
        end,
        setFunc = function ()
            Settings.unlocked = not Settings.unlocked
            for k, _ in pairs(Settings.panels) do
                _G[k]:SetMouseEnabled(Settings.unlocked)
                _G[k]:SetMovable(Settings.unlocked)
                _G[k .. "_Backdrop"]:SetHidden(not Settings.unlocked)
                _G[k .. "_Label"]:SetHidden(not Settings.unlocked)
            end
        end,
    }

    -- Combat Text - Common Options
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_COMMON_HEADER),
        controls =
        {
            {
                -- In Combat Only
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CT_IC_ONLY),
                tooltip = GetString(LUIE_STRING_LAM_CT_IC_ONLY_TP),
                getFunc = function ()
                    return Settings.toggles.inCombatOnly
                end,
                setFunc = function (v)
                    Settings.toggles.inCombatOnly = v
                end,
                default = Defaults.toggles.inCombatOnly,
            },
            {
                -- Transparency
                type = "slider",
                name = GetString(LUIE_STRING_LAM_CT_TRANSPARENCY),
                tooltip = GetString(LUIE_STRING_LAM_CT_TRANSPARENCY_TP),
                min = 0,
                max = 100,
                getFunc = function ()
                    return Settings.common.transparencyValue
                end,
                setFunc = function (v)
                    Settings.common.transparencyValue = v
                end,
                default = Defaults.common.transparencyValue,
            },

            {
                -- overkill
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CT_OVERKILL),
                tooltip = GetString(LUIE_STRING_LAM_CT_OVERKILL_TP),
                getFunc = function ()
                    return Settings.common.overkill
                end,
                setFunc = function (v)
                    Settings.common.overkill = v
                end,
                default = Defaults.common.overkill,
            },

            {
                -- overhealing
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CT_OVERHEAL),
                tooltip = GetString(LUIE_STRING_LAM_CT_OVERHEAL_TP),
                getFunc = function ()
                    return Settings.common.overheal
                end,
                setFunc = function (v)
                    Settings.common.overheal = v
                end,
                default = Defaults.common.overheal,
            },

            {
                -- Abbreviate Numbers
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CT_ABBREVIATE),
                tooltip = GetString(LUIE_STRING_LAM_CT_ABBREVIATE_TP),
                getFunc = function ()
                    return Settings.common.abbreviateNumbers
                end,
                setFunc = function (v)
                    Settings.common.abbreviateNumbers = v
                end,
                default = Defaults.common.abbreviateNumbers,
            },

            {
                -- Use Generic Icon for CC Type
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON),
                tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_TP),
                getFunc = function ()
                    return Settings.common.useDefaultIcon
                end,
                setFunc = function (newValue)
                    Settings.common.useDefaultIcon = newValue
                end,
                default = Defaults.common.useDefaultIcon,
            },
            {
                -- Generic Icon Options
                type = "dropdown",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS)),
                tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS_TP),
                choices = globalIconOptions,
                getFunc = function ()
                    return globalIconOptions[Settings.common.defaultIconOptions]
                end,
                setFunc = function (value)
                    Settings.common.defaultIconOptions = globalIconOptionsKeys[value]
                end,
                width = "full",
                disabled = function ()
                    return not Settings.common.useDefaultIcon
                end,
                default = Defaults.common.defaultIconOptions,
            },
        },
    }

    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER),
        controls =
        {
            {
                -- Combat Text Blacklist Description
                type = "description",
                text = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT),
            },
            -- Blacklist Button - Sets
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SETS),
                tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SETS_TP),
                func = function ()
                    CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Sets)
                    LUIE_BlacklistCT:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                width = "half",
            },
            -- Blacklist Button - Sorcerer
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SORCERER),
                tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SORCERER_TP),
                func = function ()
                    CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Sorcerer)
                    LUIE_BlacklistCT:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                width = "half",
            },
            -- Blacklist Button - Templar
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_TEMPLAR),
                tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_TEMPLAR_TP),
                func = function ()
                    CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Templar)
                    LUIE_BlacklistCT:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                width = "half",
            },
            -- Blacklist Button - Warden
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_WARDEN),
                tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_WARDEN_TP),
                func = function ()
                    CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Warden)
                    LUIE_BlacklistCT:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                width = "half",
            },
            -- Blacklist Button - Necromancer
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_NECROMANCER),
                tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_NECROMANCER_TP),
                func = function ()
                    CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Necromancer)
                    LUIE_BlacklistCT:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                width = "half",
            },

            {
                -- Clear Blacklist
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
                tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
                func = function ()
                    ZO_Dialogs_ShowDialog("LUIE_CLEAR_CT_BLACKLIST")
                end,
                width = "half",
            },
            {
                -- Combat Text Blacklist (Add)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
                getFunc = function () end,
                setFunc = function (value)
                    CombatText.AddToCustomList(Settings.blacklist, value)
                    LUIE_BlacklistCT:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
            },
            {
                -- Combat Text Blacklist (Remove)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST_TP),
                choices = Blacklist,
                choicesValues = BlacklistValues,
                scrollable = true,
                sort = "name-up",
                getFunc = function ()
                    LUIE_BlacklistCT:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                setFunc = function (value)
                    CombatText.RemoveFromCustomList(Settings.blacklist, value)
                    LUIE_BlacklistCT:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                reference = "LUIE_BlacklistCT",
            },
        },
    }

    -- Combat Text - Damage & Healing Options
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_DAMAGE_AND_HEALING), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        controls =
        {
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE),
                width = "full",
            },
            {
                -- Damage (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_DAMAGE_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showDamage
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showDamage = v
                end,
                default = Defaults.toggles.incoming.showDamage,
            },
            {
                -- Damage (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_DAMAGE_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showDamage
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showDamage = v
                end,
                default = Defaults.toggles.outgoing.showDamage,
            },
            {
                -- Damage Format
                type = "editbox",
                width = "half",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DAMAGE_TP),
                getFunc = function ()
                    return Settings.formats.damage
                end,
                setFunc = function (v)
                    Settings.formats.damage = v
                end,
                isMultiline = false,
                default = Defaults.formats.damage,
            },
            {
                -- Damage Critical Format
                type = "editbox",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DAMAGE_CRITICAL_TP),
                getFunc = function ()
                    return Settings.formats.damagecritical
                end,
                setFunc = function (v)
                    Settings.formats.damagecritical = v
                end,
                isMultiline = false,
                default = Defaults.formats.damagecritical,
            },
            {
                -- Damage Font Size
                type = "slider",
                width = "half",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DAMAGE_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.damage
                end,
                setFunc = function (size)
                    Settings.fontSizes.damage = size
                end,
                default = Defaults.fontSizes.damage,
            },
            {
                -- Damage Critical Font Size
                type = "slider",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DAMAGE_CRITICAL_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.damagecritical
                end,
                setFunc = function (size)
                    Settings.fontSizes.damagecritical = size
                end,
                default = Defaults.fontSizes.damagecritical,
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_DOT),
                width = "full",
            },
            {
                -- Damage over Time (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_DOT_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showDot
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showDot = v
                end,
                default = Defaults.toggles.incoming.showDot,
            },
            {
                -- Damage over Time (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_DOT_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showDot
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showDot = v
                end,
                default = Defaults.toggles.outgoing.showDot,
            },
            {
                -- Damage over Time Format
                type = "editbox",
                width = "half",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DOT_TP),
                getFunc = function ()
                    return Settings.formats.dot
                end,
                setFunc = function (v)
                    Settings.formats.dot = v
                end,
                isMultiline = false,
                default = Defaults.formats.dot,
            },
            {
                -- Damage over Time Critical Format
                type = "editbox",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DOT_CRITICAL_TP),
                getFunc = function ()
                    return Settings.formats.dotcritical
                end,
                setFunc = function (v)
                    Settings.formats.dotcritical = v
                end,
                isMultiline = false,
                default = Defaults.formats.dotcritical,
            },
            {
                -- Damage over Time Font Size
                type = "slider",
                width = "half",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DOT_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.dot
                end,
                setFunc = function (size)
                    Settings.fontSizes.dot = size
                end,
                default = Defaults.fontSizes.dot,
            },
            {
                -- Damage over Time Critical Font Size
                type = "slider",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DOT_CRITICAL_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.dotcritical
                end,
                setFunc = function (size)
                    Settings.fontSizes.dotcritical = size
                end,
                default = Defaults.fontSizes.dotcritical,
            },
            {
                -- Damage Color Options
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_HEADER_DAMAGE_COLOR),
                width = "full",
            },
            {
                -- None
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_NONE),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_NONE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[0])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[0] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[0][1],
                    g = Defaults.colors.damage[0][2],
                    b = Defaults.colors.damage[0][3],
                },
            },
            {
                -- Generic
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_GENERIC),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_GENERIC_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[1])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[1] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[1][1],
                    g = Defaults.colors.damage[1][2],
                    b = Defaults.colors.damage[1][3],
                },
            },
            {
                -- Physical
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_PHYSICAL),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_PHYSICAL_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[2])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[2] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[2][1],
                    g = Defaults.colors.damage[2][2],
                    b = Defaults.colors.damage[2][3],
                },
            },
            {
                -- Bleed
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_BLEED),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_BLEED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[12])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[12] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[12][1],
                    g = Defaults.colors.damage[12][2],
                    b = Defaults.colors.damage[12][3],
                },
            },
            {
                -- Fire
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_FIRE),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_FIRE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[3])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[3] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[3][1],
                    g = Defaults.colors.damage[3][2],
                    b = Defaults.colors.damage[3][3],
                },
            },
            {
                -- Shock
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_SHOCK),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_SHOCK_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[4])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[4] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[4][1],
                    g = Defaults.colors.damage[4][2],
                    b = Defaults.colors.damage[4][3],
                },
            },
            {
                -- Oblivion
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OBLIVION),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OBLIVION_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[5])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[5] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[5][1],
                    g = Defaults.colors.damage[5][2],
                    b = Defaults.colors.damage[5][3],
                },
            },
            {
                -- Cold
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_COLD),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_COLD_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[6])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[6] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[6][1],
                    g = Defaults.colors.damage[6][2],
                    b = Defaults.colors.damage[6][3],
                },
            },
            {
                -- Eearth
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_EARTH),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_EARTH_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[7])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[7] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[7][1],
                    g = Defaults.colors.damage[7][2],
                    b = Defaults.colors.damage[7][3],
                },
            },
            {
                -- Magic
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_MAGIC),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_MAGIC_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[8])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[8] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[8][1],
                    g = Defaults.colors.damage[8][2],
                    b = Defaults.colors.damage[8][3],
                },
            },
            {
                -- Drown
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DROWN),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DROWN_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[9])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[9] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[9][1],
                    g = Defaults.colors.damage[9][2],
                    b = Defaults.colors.damage[9][3],
                },
            },
            {
                -- Disease
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DISEASE),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DISEASE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[10])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[10] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[10][1],
                    g = Defaults.colors.damage[10][2],
                    b = Defaults.colors.damage[10][3],
                },
            },
            {
                -- Poison
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_POISON),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_POISON_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damage[11])
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damage[11] = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damage[11][1],
                    g = Defaults.colors.damage[11][2],
                    b = Defaults.colors.damage[11][3],
                },
            },
            {
                -- Checkbox Critical Damage Override
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OVERRIDE),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OVERRIDE_TP),
                getFunc = function ()
                    return Settings.toggles.criticalDamageOverride
                end,
                setFunc = function (v)
                    Settings.toggles.criticalDamageOverride = v
                end,
                default = Defaults.toggles.criticalDamageOverride,
            },
            {
                -- Color Critical Damage Override
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_DAMAGE_COLOR)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_DAMAGE_COLOR_TP),
                getFunc = function ()
                    return unpack(Settings.colors.criticalDamageOverride)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.criticalDamageOverride = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.criticalDamageOverride[1],
                    g = Defaults.colors.criticalDamageOverride[2],
                    b = Defaults.colors.criticalDamageOverride[3],
                },
            },
            {
                -- Checkbox Incoming Damage Override
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_OVERRIDE),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_OVERRIDE_TP),
                getFunc = function ()
                    return Settings.toggles.incomingDamageOverride
                end,
                setFunc = function (v)
                    Settings.toggles.incomingDamageOverride = v
                end,
                default = Defaults.toggles.incomingDamageOverride,
            },
            {
                -- Color Incoming Damage Override
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_COLOR)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_COLOR_TP),
                getFunc = function ()
                    return unpack(Settings.colors.incomingDamageOverride)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.incomingDamageOverride = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.incomingDamageOverride[1],
                    g = Defaults.colors.incomingDamageOverride[2],
                    b = Defaults.colors.incomingDamageOverride[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_HEALING),
                width = "full",
            },
            {
                -- Healing (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HEALING), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_HEALING_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showHealing
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showHealing = v
                end,
                default = Defaults.toggles.incoming.showHealing,
            },
            {
                -- Healing (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HEALING), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_HEALING_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showHealing
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showHealing = v
                end,
                default = Defaults.toggles.outgoing.showHealing,
            },
            {
                -- Healing Format
                type = "editbox",
                width = "half",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HEALING_TP),
                getFunc = function ()
                    return Settings.formats.healing
                end,
                setFunc = function (v)
                    Settings.formats.healing = v
                end,
                isMultiline = false,
                default = Defaults.formats.healing,
            },
            {
                -- Healing Critical Format
                type = "editbox",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HEALING_CRITICAL_TP),
                getFunc = function ()
                    return Settings.formats.healingcritical
                end,
                setFunc = function (v)
                    Settings.formats.healingcritical = v
                end,
                isMultiline = false,
                default = Defaults.formats.healingcritical,
            },
            {
                -- Healing Font Size
                type = "slider",
                width = "half",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HEALING_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.healing
                end,
                setFunc = function (size)
                    Settings.fontSizes.healing = size
                end,
                default = Defaults.fontSizes.healing,
            },
            {
                -- Healing Critical Font Size
                type = "slider",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HEALING_CRITICAL_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.healingcritical
                end,
                setFunc = function (size)
                    Settings.fontSizes.healingcritical = size
                end,
                default = Defaults.fontSizes.healingcritical,
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_HOT),
                width = "full",
            },
            {
                -- Healing over Time (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_HOT_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showHot
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showHot = v
                end,
                default = Defaults.toggles.incoming.showHot,
            },
            {
                -- Healing over Time (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_HOT_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showHot
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showHot = v
                end,
                default = Defaults.toggles.outgoing.showHot,
            },
            {
                -- Healing over Time Format
                type = "editbox",
                width = "half",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HOT_TP),
                getFunc = function ()
                    return Settings.formats.hot
                end,
                setFunc = function (v)
                    Settings.formats.hot = v
                end,
                isMultiline = false,
                default = Defaults.formats.hot,
            },
            {
                -- Healing over Time Critical Format
                type = "editbox",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HOT_CRITICAL_TP),
                getFunc = function ()
                    return Settings.formats.hotcritical
                end,
                setFunc = function (v)
                    Settings.formats.hotcritical = v
                end,
                isMultiline = false,
                default = Defaults.formats.hotcritical,
            },
            {
                -- Healing over Time Font Size
                type = "slider",
                width = "half",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HOT_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.hot
                end,
                setFunc = function (size)
                    Settings.fontSizes.hot = size
                end,
                default = Defaults.fontSizes.hot,
            },
            {
                -- Healing over Time Critical Font Size
                type = "slider",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HOT_CRITICAL_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.hotcritical
                end,
                setFunc = function (size)
                    Settings.fontSizes.hotcritical = size
                end,
                default = Defaults.fontSizes.hotcritical,
            },
            {
                -- Healing Color Options
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_HEADER_HEALING_COLOR),
                width = "full",
            },
            {
                -- Healing
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING_TP),
                getFunc = function ()
                    return unpack(Settings.colors.healing)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.healing = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.healing[1],
                    g = Defaults.colors.healing[2],
                    b = Defaults.colors.healing[3],
                },
            },
            {
                -- Checkbox Critical Healing Override
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING_OVERRIDE),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING_OVERRIDE_TP),
                getFunc = function ()
                    return Settings.toggles.criticalHealingOverride
                end,
                setFunc = function (v)
                    Settings.toggles.criticalHealingOverride = v
                end,
                default = Defaults.toggles.criticalHealingOverride,
            },
            {
                -- Color Critical Healing Override
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_HEALING_COLOR)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_HEALING_COLOR_TP),
                getFunc = function ()
                    return unpack(Settings.colors.criticalHealingOverride)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.criticalHealingOverride = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.criticalHealingOverride[1],
                    g = Defaults.colors.criticalHealingOverride[2],
                    b = Defaults.colors.criticalHealingOverride[3],
                },
            },
        },
    }

    -- Combat Text - Resource Gain & Drain Options
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_RESOURCE_GAIN_DRAIN), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        controls =
        {
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE),
                width = "full",
            },
            {
                -- Gain Loss Font Size
                type = "slider",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_GAIN_LOSS_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.gainLoss
                end,
                setFunc = function (size)
                    Settings.fontSizes.gainLoss = size
                end,
                default = Defaults.fontSizes.gainLoss,
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE),
                width = "full",
            },
            {
                -- Resource Gain (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_ENERGIZE_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showEnergize
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showEnergize = v
                end,
                default = Defaults.toggles.incoming.showEnergize,
            },
            {
                -- Resource Gain (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_ENERGIZE_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showEnergize
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showEnergize = v
                end,
                default = Defaults.toggles.outgoing.showEnergize,
            },
            {
                -- Resource Gain Format
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_ENERGIZE_TP),
                getFunc = function ()
                    return Settings.formats.energize
                end,
                setFunc = function (v)
                    Settings.formats.energize = v
                end,
                isMultiline = false,
                default = Defaults.formats.energize,
            },
            {
                -- Gain Magicka Color
                type = "colorpicker",
                width = "half",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_MAGICKA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_ENERGIZE_MAGICKA_TP),
                getFunc = function ()
                    return unpack(Settings.colors.energizeMagicka)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.energizeMagicka = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.energizeMagicka[1],
                    g = Defaults.colors.energizeMagicka[2],
                    b = Defaults.colors.energizeMagicka[3],
                },
            },
            {
                -- Gain Stamina Color
                type = "colorpicker",
                width = "half",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_STAMINA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_ENERGIZE_STAMINA_TP),
                getFunc = function ()
                    return unpack(Settings.colors.energizeStamina)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.energizeStamina = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.energizeStamina[1],
                    g = Defaults.colors.energizeStamina[2],
                    b = Defaults.colors.energizeStamina[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE_ULTIMATE),
                width = "full",
            },
            {
                -- Ultimate Gain (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE_ULTIMATE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_ENERGIZE_ULTIMATE_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showUltimateEnergize
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showUltimateEnergize = v
                end,
                default = Defaults.toggles.incoming.showUltimateEnergize,
            },
            {
                -- Ultimate Gain (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE_ULTIMATE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_ENERGIZE_ULTIMATE_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showUltimateEnergize
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showUltimateEnergize = v
                end,
                default = Defaults.toggles.outgoing.showUltimateEnergize,
            },
            {
                -- Ultimate Gain Format
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_ENERGIZE_ULTIMATE_TP),
                getFunc = function ()
                    return Settings.formats.ultimateEnergize
                end,
                setFunc = function (v)
                    Settings.formats.ultimateEnergize = v
                end,
                isMultiline = false,
                default = Defaults.formats.ultimateEnergize,
            },
            {
                -- Gain Ultimate Color
                type = "colorpicker",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_ENERGIZE_ULTIMATE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.energizeUltimate)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.energizeUltimate = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.energizeUltimate[1],
                    g = Defaults.colors.energizeUltimate[2],
                    b = Defaults.colors.energizeUltimate[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_DRAIN),
                width = "full",
            },
            {
                -- Resource Drain (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DRAIN), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_DRAIN_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showDrain
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showDrain = v
                end,
                default = Defaults.toggles.incoming.showDrain,
            },
            {
                -- Resource Drain (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DRAIN), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_DRAIN_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showDrain
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showDrain = v
                end,
                default = Defaults.toggles.outgoing.showDrain,
            },
            {
                -- Resource Damage Format
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DRAIN_TP),
                getFunc = function ()
                    return Settings.formats.drain
                end,
                setFunc = function (v)
                    Settings.formats.drain = v
                end,
                isMultiline = false,
                default = Defaults.formats.drain,
            },
            {
                -- Drain Magicka Color
                type = "colorpicker",
                width = "half",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_MAGICKA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DRAIN_MAGICKA_TP),
                getFunc = function ()
                    return unpack(Settings.colors.drainMagicka)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.drainMagicka = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.drainMagicka[1],
                    g = Defaults.colors.drainMagicka[2],
                    b = Defaults.colors.drainMagicka[3],
                },
            },
            {
                -- Drain Stamina Color
                type = "colorpicker",
                width = "half",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_STAMINA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DRAIN_STAMINA_TP),
                getFunc = function ()
                    return unpack(Settings.colors.drainStamina)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.drainStamina = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.drainStamina[1],
                    g = Defaults.colors.drainStamina[2],
                    b = Defaults.colors.drainStamina[3],
                },
            },
        },
    }

    -- Combat Text - Mitigation Options
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_MITIGATION), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        controls =
        {
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE),
                width = "full",
            },
            {
                -- Mitigation Font Size
                type = "slider",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_MITIGATION_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.mitigation
                end,
                setFunc = function (size)
                    Settings.fontSizes.mitigation = size
                end,
                default = Defaults.fontSizes.mitigation,
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_MISS),
                width = "full",
            },
            {
                -- Missed (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_MISS), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_MISS_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showMiss
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showMiss = v
                end,
                default = Defaults.toggles.incoming.showMiss,
            },
            {
                -- Missed (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_MISS), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_MISS_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showMiss
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showMiss = v
                end,
                default = Defaults.toggles.outgoing.showMiss,
            },
            {
                -- Missed (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_MISS_TP),
                getFunc = function ()
                    return Settings.formats.miss
                end,
                setFunc = function (v)
                    Settings.formats.miss = v
                end,
                isMultiline = false,
                default = Defaults.formats.miss,
            },
            {
                -- Missed (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_MISS_TP),
                getFunc = function ()
                    return unpack(Settings.colors.miss)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.miss = { r, g, b, a }
                end,
                default = { r = Defaults.colors.miss[1], g = Defaults.colors.miss[2], b = Defaults.colors.miss[3] },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_IMMUNE),
                width = "full",
            },
            {
                -- Immune (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_IMMUNE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_IMMUNE_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showImmune
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showImmune = v
                end,
                default = Defaults.toggles.incoming.showImmune,
            },
            {
                -- Immune (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_IMMUNE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_IMMUNE_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showImmune
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showImmune = v
                end,
                default = Defaults.toggles.outgoing.showImmune,
            },
            {
                -- Immune (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_IMMUNE_TP),
                getFunc = function ()
                    return Settings.formats.immune
                end,
                setFunc = function (v)
                    Settings.formats.immune = v
                end,
                isMultiline = false,
                default = Defaults.formats.immune,
            },
            {
                -- Immune (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_IMMUNE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.immune)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.immune = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.immune[1],
                    g = Defaults.colors.immune[2],
                    b = Defaults.colors.immune[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_PARRIED),
                width = "full",
            },
            {
                -- Parried (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_PARRIED), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_PARRIED_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showParried
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showParried = v
                end,
                default = Defaults.toggles.incoming.showParried,
            },
            {
                -- Parried (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_PARRIED), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_PARRIED_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showParried
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showParried = v
                end,
                default = Defaults.toggles.outgoing.showParried,
            },
            {
                -- Parried (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_PARRIED_TP),
                getFunc = function ()
                    return Settings.formats.parried
                end,
                setFunc = function (v)
                    Settings.formats.parried = v
                end,
                isMultiline = false,
                default = Defaults.formats.parried,
            },
            {
                -- Parried (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_PARRIED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.parried)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.parried = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.parried[1],
                    g = Defaults.colors.parried[2],
                    b = Defaults.colors.parried[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_REFLECTED),
                width = "full",
            },
            {
                -- Reflected (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_REFLECTED), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_REFLECTED_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showReflected
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showReflected = v
                end,
                default = Defaults.toggles.incoming.showReflected,
            },
            {
                -- Reflected (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_REFLECTED), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_REFLECTED_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showReflected
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showReflected = v
                end,
                default = Defaults.toggles.outgoing.showReflected,
            },
            {
                -- Reflected (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_REFLECTED_TP),
                getFunc = function ()
                    return Settings.formats.reflected
                end,
                setFunc = function (v)
                    Settings.formats.reflected = v
                end,
                isMultiline = false,
                default = Defaults.formats.reflected,
            },
            {
                -- Reflected (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_REFLETCED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.reflected)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.reflected = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.reflected[1],
                    g = Defaults.colors.reflected[2],
                    b = Defaults.colors.reflected[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE_SHIELD),
                width = "full",
            },
            {
                -- Damage Shielded (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE_SHIELD), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_DAMAGE_SHIELD_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showDamageShield
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showDamageShield = v
                end,
                default = Defaults.toggles.incoming.showDamageShield,
            },
            {
                -- Damage Shielded (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE_SHIELD), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_DAMAGE_SHIELD_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showDamageShield
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showDamageShield = v
                end,
                default = Defaults.toggles.outgoing.showDamageShield,
            },
            {
                -- Damage Shielded (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DAMAGE_SHIELD_TP),
                getFunc = function ()
                    return Settings.formats.damageShield
                end,
                setFunc = function (v)
                    Settings.formats.damageShield = v
                end,
                isMultiline = false,
                default = Defaults.formats.damageShield,
            },
            {
                -- Damage Shielded (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_SHIELD_TP),
                getFunc = function ()
                    return unpack(Settings.colors.damageShield)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.damageShield = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.damageShield[1],
                    g = Defaults.colors.damageShield[2],
                    b = Defaults.colors.damageShield[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_DODGED),
                width = "full",
            },
            {
                -- Dodged (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DODGED), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_DODGED_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showDodged
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showDodged = v
                end,
                default = Defaults.toggles.incoming.showDodged,
            },
            {
                -- Dodged (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DODGED), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_DODGED_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showDodged
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showDodged = v
                end,
                default = Defaults.toggles.outgoing.showDodged,
            },
            {
                -- Dodged (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DODGED_TP),
                getFunc = function ()
                    return Settings.formats.dodged
                end,
                setFunc = function (v)
                    Settings.formats.dodged = v
                end,
                isMultiline = false,
                default = Defaults.formats.dodged,
            },
            {
                -- Dodged (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DODGED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.dodged)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.dodged = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.dodged[1],
                    g = Defaults.colors.dodged[2],
                    b = Defaults.colors.dodged[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_BLOCKED),
                width = "full",
            },
            {
                -- Blocked (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_BLOCKED), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_BLOCKED_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showBlocked
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showBlocked = v
                end,
                default = Defaults.toggles.incoming.showBlocked,
            },
            {
                -- Blocked (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_BLOCKED), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_BLOCKED_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showBlocked
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showBlocked = v
                end,
                default = Defaults.toggles.outgoing.showBlocked,
            },
            {
                -- Blocked (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_BLOCKED_TP),
                getFunc = function ()
                    return Settings.formats.blocked
                end,
                setFunc = function (v)
                    Settings.formats.blocked = v
                end,
                isMultiline = false,
                default = Defaults.formats.blocked,
            },
            {
                -- Blocked (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_BLOCKED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.blocked)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.blocked = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.blocked[1],
                    g = Defaults.colors.blocked[2],
                    b = Defaults.colors.blocked[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_INTERRUPTED),
                width = "full",
            },
            {
                -- Interrupted (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_INTERRUPTED), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_INTERRUPTED_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showInterrupted
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showInterrupted = v
                end,
                default = Defaults.toggles.incoming.showInterrupted,
            },
            {
                -- Interrupted (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_INTERRUPTED), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_INTERRUPTED_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showInterrupted
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showInterrupted = v
                end,
                default = Defaults.toggles.outgoing.showInterrupted,
            },
            {
                -- Interrupted (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_INTERRUPTED_TP),
                getFunc = function ()
                    return Settings.formats.interrupted
                end,
                setFunc = function (v)
                    Settings.formats.interrupted = v
                end,
                isMultiline = false,
                default = Defaults.formats.interrupted,
            },
            {
                -- Interrupted (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INTERRUPTED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.interrupted)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.interrupted = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.interrupted[1],
                    g = Defaults.colors.interrupted[2],
                    b = Defaults.colors.interrupted[3],
                },
            },
        },
    }

    -- Combat Text - Crowd Control Options
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_CROWD_CONTROL), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        controls =
        {
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE),
                width = "full",
            },
            {
                -- Crowd Control Font Size
                type = "slider",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_CROWD_CONTROL_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.crowdControl
                end,
                setFunc = function (size)
                    Settings.fontSizes.crowdControl = size
                end,
                default = Defaults.fontSizes.crowdControl,
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_DISORIENTED),
                width = "full",
            },
            {
                -- Disoriented (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DISORIENTED), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_DISORIENTED_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showDisoriented
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showDisoriented = v
                end,
                default = Defaults.toggles.incoming.showDisoriented,
            },
            {
                -- Disoriented (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DISORIENTED), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_DISORIENTED_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showDisoriented
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showDisoriented = v
                end,
                default = Defaults.toggles.outgoing.showDisoriented,
            },
            {
                -- Disoriented (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DISORIENTED_TP),
                getFunc = function ()
                    return Settings.formats.disoriented
                end,
                setFunc = function (v)
                    Settings.formats.disoriented = v
                end,
                isMultiline = false,
                default = Defaults.formats.disoriented,
            },
            {
                -- Disoriented (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DISORIENTED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.disoriented)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.disoriented = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.disoriented[1],
                    g = Defaults.colors.disoriented[2],
                    b = Defaults.colors.disoriented[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FEARED),
                width = "full",
            },
            {
                -- Feared (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_FEARED), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_FEARED_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showFeared
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showFeared = v
                end,
                default = Defaults.toggles.incoming.showFeared,
            },
            {
                -- Feared (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_FEARED), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_FEARED_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showFeared
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showFeared = v
                end,
                default = Defaults.toggles.outgoing.showFeared,
            },
            {
                -- Feared (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_FEARED_TP),
                getFunc = function ()
                    return Settings.formats.feared
                end,
                setFunc = function (v)
                    Settings.formats.feared = v
                end,
                isMultiline = false,
                default = Defaults.formats.feared,
            },
            {
                -- Feared (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_FEARED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.feared)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.feared = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.feared[1],
                    g = Defaults.colors.feared[2],
                    b = Defaults.colors.feared[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_OFF_BALANCE),
                width = "full",
            },
            {
                -- Off-Balance (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_OFF_BALANCE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_OFF_BALANCE_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showOffBalanced
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showOffBalanced = v
                end,
                default = Defaults.toggles.incoming.showOffBalanced,
            },
            {
                -- Off-Balance (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_OFF_BALANCE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_OFF_BALANCE_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showOffBalanced
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showOffBalanced = v
                end,
                default = Defaults.toggles.outgoing.showOffBalanced,
            },
            {
                -- Off-Balanced (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_OFF_BALANCE_TP),
                getFunc = function ()
                    return Settings.formats.offBalanced
                end,
                setFunc = function (v)
                    Settings.formats.offBalanced = v
                end,
                isMultiline = false,
                default = Defaults.formats.offBalanced,
            },
            {
                -- Off-Balanced (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_OFF_BALANCE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.offBalanced)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.offBalanced = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.offBalanced[1],
                    g = Defaults.colors.offBalanced[2],
                    b = Defaults.colors.offBalanced[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_SILENCED),
                width = "full",
            },
            {
                -- Silenced (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_SILENCED), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_SILENCED_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showSilenced
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showSilenced = v
                end,
                default = Defaults.toggles.incoming.showSilenced,
            },
            {
                -- Silenced (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_SILENCED), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_SILENCED_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showSilenced
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showSilenced = v
                end,
                default = Defaults.toggles.outgoing.showSilenced,
            },
            {
                -- Silenced (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_SILENCED_TP),
                getFunc = function ()
                    return Settings.formats.silenced
                end,
                setFunc = function (v)
                    Settings.formats.silenced = v
                end,
                isMultiline = false,
                default = Defaults.formats.silenced,
            },
            {
                -- Silenced (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_SILENCED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.silenced)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.silenced = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.silenced[1],
                    g = Defaults.colors.silenced[2],
                    b = Defaults.colors.silenced[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_STUNNED),
                width = "full",
            },
            {
                -- Stunned (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_STUNNED), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_STUNNED_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showStunned
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showStunned = v
                end,
                default = Defaults.toggles.incoming.showStunned,
            },
            {
                -- Stunned (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_STUNNED), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_STUNNED_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showStunned
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showStunned = v
                end,
                default = Defaults.toggles.outgoing.showStunned,
            },
            {
                -- Stunned (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_STUNNED_TP),
                getFunc = function ()
                    return Settings.formats.stunned
                end,
                setFunc = function (v)
                    Settings.formats.stunned = v
                end,
                isMultiline = false,
                default = Defaults.formats.stunned,
            },
            {
                -- Stunned (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_STUNNED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.stunned)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.stunned = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.stunned[1],
                    g = Defaults.colors.stunned[2],
                    b = Defaults.colors.stunned[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_CHARMED),
                width = "full",
            },
            {
                -- Charmed (Incoming)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_CHARMED), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_CHARMED_TP),
                getFunc = function ()
                    return Settings.toggles.incoming.showCharmed
                end,
                setFunc = function (v)
                    Settings.toggles.incoming.showCharmed = v
                end,
                default = Defaults.toggles.incoming.showCharmed,
            },
            {
                -- Charmed (Outgoing)
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_CHARMED), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_CHARMED_TP),
                getFunc = function ()
                    return Settings.toggles.outgoing.showCharmed
                end,
                setFunc = function (v)
                    Settings.toggles.outgoing.showCharmed = v
                end,
                default = Defaults.toggles.outgoing.showCharmed,
            },
            {
                -- Charmed (Format)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_CHARMED_TP),
                getFunc = function ()
                    return Settings.formats.charmed
                end,
                setFunc = function (v)
                    Settings.formats.charmed = v
                end,
                isMultiline = false,
                default = Defaults.formats.charmed,
            },
            {
                -- Charmed (Color)
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CHARMED_TP),
                getFunc = function ()
                    return unpack(Settings.colors.charmed)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.charmed = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.charmed[1],
                    g = Defaults.colors.charmed[2],
                    b = Defaults.colors.charmed[3],
                },
            },
        },
    }

    -- Combat Text -- Notification Options
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_NOTIFICATION), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        controls =
        {
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_COMBAT_STATE),
                width = "full",
            },
            {
                -- In Combat
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_IN)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_COMBAT_IN_TP),
                getFunc = function ()
                    return Settings.toggles.showInCombat
                end,
                setFunc = function (v)
                    Settings.toggles.showInCombat = v
                end,
                default = Defaults.toggles.showInCombat,
            },
            {
                -- Out of Combat
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_OUT)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_COMBAT_OUT_TP),
                getFunc = function ()
                    return Settings.toggles.showOutCombat
                end,
                setFunc = function (v)
                    Settings.toggles.showOutCombat = v
                end,
                default = Defaults.toggles.showOutCombat,
            },
            {
                -- In Combat
                type = "editbox",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_IN)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_COMBAT_IN_TP),
                getFunc = function ()
                    return Settings.formats.inCombat
                end,
                setFunc = function (v)
                    Settings.formats.inCombat = v
                end,
                isMultiline = false,
                default = Defaults.formats.inCombat,
            },
            {
                -- Out Combat
                type = "editbox",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_OUT)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_COMBAT_OUT_TP),
                getFunc = function ()
                    return Settings.formats.outCombat
                end,
                setFunc = function (v)
                    Settings.formats.outCombat = v
                end,
                isMultiline = false,
                default = Defaults.formats.outCombat,
            },
            {
                -- Combat State Font Size
                type = "slider",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_COMBAT_STATE_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.combatState
                end,
                setFunc = function (size)
                    Settings.fontSizes.combatState = size
                end,
                default = Defaults.fontSizes.combatState,
            },
            {
                -- In Combat
                type = "colorpicker",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_IN)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_COMBAT_IN_TP),
                getFunc = function ()
                    return unpack(Settings.colors.inCombat)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.inCombat = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.inCombat[1],
                    g = Defaults.colors.inCombat[2],
                    b = Defaults.colors.inCombat[3],
                },
            },
            {
                -- Out Combat
                type = "colorpicker",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_OUT)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_COMBAT_OUT_TP),
                getFunc = function ()
                    return unpack(Settings.colors.outCombat)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.outCombat = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.outCombat[1],
                    g = Defaults.colors.outCombat[2],
                    b = Defaults.colors.outCombat[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_DEATH_HEADER),
                width = "full",
            },
            {
                -- Death Toggle
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CT_DEATH_NOTIFICATION),
                tooltip = GetString(LUIE_STRING_LAM_CT_DEATH_NOTIFICATION_TP),
                getFunc = function ()
                    return Settings.toggles.showDeath
                end,
                setFunc = function (v)
                    Settings.toggles.showDeath = v
                end,
                default = Defaults.toggles.showDeath,
            },
            {
                -- Death Format
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_DEATH_FORMAT_TP),
                getFunc = function ()
                    return Settings.formats.death
                end,
                setFunc = function (v)
                    Settings.formats.death = v
                end,
                isMultiline = false,
                default = Defaults.formats.death,
            },
            {
                -- Death Font Size
                type = "slider",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_DEATH_FONT_SIZE_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.death
                end,
                setFunc = function (size)
                    Settings.fontSizes.death = size
                end,
                default = Defaults.fontSizes.death,
            },
            {
                -- Death Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_DEATH_COLOR_TP),
                getFunc = function ()
                    return unpack(Settings.colors.death)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.death = { r, g, b, a }
                end,
                default = { r = Defaults.colors.death[1], g = Defaults.colors.death[2], b = Defaults.colors.death[3] },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE),
                width = "full",
            },
            {
                -- Points Font Size
                type = "slider",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_POINTS_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.point
                end,
                setFunc = function (size)
                    Settings.fontSizes.point = size
                end,
                default = Defaults.fontSizes.point,
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_ALLIANCE),
                width = "full",
            },
            {
                -- Alliance Points
                type = "checkbox",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_ALLIANCE)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_POINTS_ALLIANCE_TP),
                getFunc = function ()
                    return Settings.toggles.showPointsAlliance
                end,
                setFunc = function (v)
                    Settings.toggles.showPointsAlliance = v
                end,
                default = Defaults.toggles.showPointsAlliance,
            },
            {
                -- Alliance Points
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_ALLIANCE_TP),
                getFunc = function ()
                    return Settings.formats.pointsAlliance
                end,
                setFunc = function (v)
                    Settings.formats.pointsAlliance = v
                end,
                isMultiline = false,
                default = Defaults.formats.pointsAlliance,
            },
            {
                -- Alliance Points Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_ALLIANCE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.pointsAlliance)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.pointsAlliance = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.pointsAlliance[1],
                    g = Defaults.colors.pointsAlliance[2],
                    b = Defaults.colors.pointsAlliance[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_EXPERIENCE),
                width = "full",
            },
            {
                -- Experience Points
                type = "checkbox",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_EXPERIENCE)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_POINTS_EXPERIENCE_TP),
                getFunc = function ()
                    return Settings.toggles.showPointsExperience
                end,
                setFunc = function (v)
                    Settings.toggles.showPointsExperience = v
                end,
                default = Defaults.toggles.showPointsExperience,
            },
            {
                -- Experience Points
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_EXPERIENCE_TP),
                getFunc = function ()
                    return Settings.formats.pointsExperience
                end,
                setFunc = function (v)
                    Settings.formats.pointsExperience = v
                end,
                isMultiline = false,
                default = Defaults.formats.pointsExperience,
            },
            {
                -- Experience Points Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_EXPERIENCE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.pointsExperience)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.pointsExperience = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.pointsExperience[1],
                    g = Defaults.colors.pointsExperience[2],
                    b = Defaults.colors.pointsExperience[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_CHAMPION),
                width = "full",
            },
            {
                -- Champion Points
                type = "checkbox",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_CHAMPION)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_POINTS_CHAMPION_TP),
                getFunc = function ()
                    return Settings.toggles.showPointsChampion
                end,
                setFunc = function (v)
                    Settings.toggles.showPointsChampion = v
                end,
                default = Defaults.toggles.showPointsChampion,
            },
            {
                -- Champion Points
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_CHAMPION_TP),
                getFunc = function ()
                    return Settings.formats.pointsChampion
                end,
                setFunc = function (v)
                    Settings.formats.pointsChampion = v
                end,
                isMultiline = false,
                default = Defaults.formats.pointsChampion,
            },
            {
                -- Champion Points Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_CHAMPION_TP),
                getFunc = function ()
                    return unpack(Settings.colors.pointsChampion)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.pointsChampion = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.pointsChampion[1],
                    g = Defaults.colors.pointsChampion[2],
                    b = Defaults.colors.pointsChampion[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_AND_POTION_READY),
                width = "full",
            },
            {
                -- Font Size Ready
                type = "slider",
                name = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_RESOURCE_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.readylabel
                end,
                setFunc = function (size)
                    Settings.fontSizes.readylabel = size
                end,
                default = Defaults.fontSizes.readylabel,
            },
            {
                -- Ultimate Ready Enable
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ULTIMATE_READY_TP),
                getFunc = function ()
                    return Settings.toggles.showUltimate
                end,
                setFunc = function (v)
                    Settings.toggles.showUltimate = v
                end,
                default = Defaults.toggles.showUltimate,
            },
            {
                -- Potion Ready Enable
                type = "checkbox",
                width = "half",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_POTION_READY_TP),
                getFunc = function ()
                    return Settings.toggles.showPotionReady
                end,
                setFunc = function (v)
                    Settings.toggles.showPotionReady = v
                end,
                default = Defaults.toggles.showPotionReady,
            },
            {
                -- Ultimate Ready Format
                type = "editbox",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_ULTIMATE_TP),
                getFunc = function ()
                    return Settings.formats.ultimateReady
                end,
                setFunc = function (v)
                    Settings.formats.ultimateReady = v
                end,
                isMultiline = false,
                default = Defaults.formats.ultimateReady,
            },
            {
                -- Potion Ready Format
                type = "editbox",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_POTION_TP),
                getFunc = function ()
                    return Settings.formats.potionReady
                end,
                setFunc = function (v)
                    Settings.formats.potionReady = v
                end,
                isMultiline = false,
                default = Defaults.formats.potionReady,
            },
            {
                -- Ultimate Ready Color
                type = "colorpicker",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_ULTIMATE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.ultimateReady)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.ultimateReady = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.ultimateReady[1],
                    g = Defaults.colors.ultimateReady[2],
                    b = Defaults.colors.ultimateReady[3],
                },
            },
            {
                -- Potion Ready Color
                type = "colorpicker",
                width = "half",
                name = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY)),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_POTION_TP),
                getFunc = function ()
                    return unpack(Settings.colors.potionReady)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.potionReady = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.potionReady[1],
                    g = Defaults.colors.potionReady[2],
                    b = Defaults.colors.potionReady[3],
                },
            },
        },
    }

    -- Combat Text - Low Resource Options
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_LOW_RESOURCE), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        controls =
        {
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_RESOURCE_OPTIONS),
                width = "full",
            },
            {
                -- Low Resource Font Size
                type = "slider",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_RESOURCE_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSizes.resource
                end,
                setFunc = function (size)
                    Settings.fontSizes.resource = size
                end,
                default = Defaults.fontSizes.resource,
            },
            {
                -- Low Resource Warning Sound
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_SOUND),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_SOUND_TP),
                getFunc = function ()
                    return Settings.toggles.warningSound
                end,
                setFunc = function (v)
                    Settings.toggles.warningSound = v
                end,
                disabled = function ()
                    return not (Settings.toggles.showLowHealth or Settings.toggles.showLowMagicka or Settings.toggles.showLowStamina)
                end,
                default = Defaults.toggles.warningSound,
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_LOW_HEALTH),
                width = "full",
            },
            {
                -- Low Health
                type = "checkbox",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_LOW_HEALTH)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_LOW_HEALTH_TP),
                getFunc = function ()
                    return Settings.toggles.showLowHealth
                end,
                setFunc = function (v)
                    Settings.toggles.showLowHealth = v
                end,
                default = Defaults.toggles.showLowHealth,
            },
            {
                -- Low Health Warning Threshold Slider
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_HEALTH)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_HEALTH_TP),
                min = 15,
                max = 50,
                step = 1,
                getFunc = function ()
                    return Settings.healthThreshold
                end,
                setFunc = function (threshold)
                    Settings.healthThreshold = threshold
                end,
                disabled = function ()
                    return not Settings.toggles.showLowHealth
                end,
                default = Defaults.healthThreshold,
            },
            {
                -- Low Health Format
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_RESOURCE_TP),
                getFunc = function ()
                    return Settings.formats.resourceHealth
                end,
                setFunc = function (v)
                    Settings.formats.resourceHealth = v
                end,
                isMultiline = false,
                default = Defaults.formats.resourceHealth,
            },
            {
                -- Low Health Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_LOW_HEALTH_TP),
                getFunc = function ()
                    return unpack(Settings.colors.lowHealth)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.lowHealth = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.lowHealth[1],
                    g = Defaults.colors.lowHealth[2],
                    b = Defaults.colors.lowHealth[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_LOW_MAGICKA),
                width = "full",
            },
            {
                -- Low Magicka
                type = "checkbox",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_LOW_MAGICKA)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_LOW_MAGICKA_TP),
                getFunc = function ()
                    return Settings.toggles.showLowMagicka
                end,
                setFunc = function (v)
                    Settings.toggles.showLowMagicka = v
                end,
                default = Defaults.toggles.showLowMagicka,
            },
            {
                -- Low Magicka Warning Threshold Slider
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_MAGICKA)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_MAGICKA_TP),
                min = 15,
                max = 50,
                step = 1,
                getFunc = function ()
                    return Settings.magickaThreshold
                end,
                setFunc = function (threshold)
                    Settings.magickaThreshold = threshold
                end,
                disabled = function ()
                    return not Settings.toggles.showLowMagicka
                end,
                default = Defaults.magickaThreshold,
            },
            {
                -- Low Magicka Format
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_RESOURCE_TP),
                getFunc = function ()
                    return Settings.formats.resourceMagicka
                end,
                setFunc = function (v)
                    Settings.formats.resourceMagicka = v
                end,
                isMultiline = false,
                default = Defaults.formats.resourceMagicka,
            },
            {
                -- Low Magicka Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_LOW_MAGICKA_TP),
                getFunc = function ()
                    return unpack(Settings.colors.lowMagicka)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.lowMagicka = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.lowMagicka[1],
                    g = Defaults.colors.lowMagicka[2],
                    b = Defaults.colors.lowMagicka[3],
                },
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_LOW_STAMINA),
                width = "full",
            },
            {
                -- Low Stamina
                type = "checkbox",
                name = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_LOW_STAMINA)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_LOW_STAMINA_TP),
                getFunc = function ()
                    return Settings.toggles.showLowStamina
                end,
                setFunc = function (v)
                    Settings.toggles.showLowStamina = v
                end,
                default = Defaults.toggles.showLowStamina,
            },
            {
                -- Low Stamina Warning Threshold Slider
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_STAMINA)),
                tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_STAMINA_TP),
                min = 15,
                max = 50,
                step = 1,
                getFunc = function ()
                    return Settings.staminaThreshold
                end,
                setFunc = function (threshold)
                    Settings.staminaThreshold = threshold
                end,
                disabled = function ()
                    return not Settings.toggles.showLowStamina
                end,
                default = Defaults.staminaThreshold,
            },
            {
                -- Low Stamina Format
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_RESOURCE_TP),
                getFunc = function ()
                    return Settings.formats.resourceStamina
                end,
                setFunc = function (v)
                    Settings.formats.resourceStamina = v
                end,
                isMultiline = false,
                default = Defaults.formats.resourceStamina,
            },
            {
                -- Low Stamina Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_LOW_STAMINA_TP),
                getFunc = function ()
                    return unpack(Settings.colors.lowStamina)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.lowStamina = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.lowStamina[1],
                    g = Defaults.colors.lowStamina[2],
                    b = Defaults.colors.lowStamina[3],
                },
            },
        },
    }

    -- Combat Text - Font Format Options Submenu
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_CT_FONT_HEADER),
        controls =
        {
            {
                -- Font Face Dropdown
                type = "dropdown",
                scrollable = true,
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_FONT)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_FACE_TP),
                choices = FontsList,
                sort = "name-up",
                getFunc = function ()
                    return Settings.fontFace
                end,
                setFunc = function (var)
                    Settings.fontFace = var
                    CombatText.ApplyFont()
                end,
                width = "full",
                default = Defaults.fontFace,
            },
            {
                -- Font Size
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_FONT_SIZE)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_SIZE_TP),
                min = 8,
                max = 72,
                step = 1,
                getFunc = function ()
                    return Settings.fontSize
                end,
                setFunc = function (value)
                    Settings.fontSize = value
                    -- Update all font sizes proportionally
                    Settings.fontSizes.damage = value
                    Settings.fontSizes.damagecritical = value
                    Settings.fontSizes.healing = value
                    Settings.fontSizes.healingcritical = value
                    Settings.fontSizes.dot = math.floor(value * 0.8)
                    Settings.fontSizes.dotcritical = math.floor(value * 0.8)
                    Settings.fontSizes.hot = math.floor(value * 0.8)
                    Settings.fontSizes.hotcritical = math.floor(value * 0.8)
                    Settings.fontSizes.gainLoss = value
                    Settings.fontSizes.mitigation = value
                    Settings.fontSizes.crowdControl = math.floor(value * 0.8)
                    Settings.fontSizes.combatState = math.floor(value * 0.75)
                    Settings.fontSizes.death = value
                    Settings.fontSizes.point = math.floor(value * 0.75)
                    Settings.fontSizes.resource = value
                    Settings.fontSizes.readylabel = value
                    CombatText.ApplyFont()
                end,
                width = "full",
                default = Defaults.fontSize,
            },
            {
                -- Font Style
                type = "dropdown",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_FONT_STYLE)),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_STYLE_TP),
                choices =
                {
                    "|cFFFFFF" .. GetString(LUIE_FONT_STYLE_NORMAL) .. "|r",
                    "|c888888" .. GetString(LUIE_FONT_STYLE_SHADOW) .. "|r",
                    "|cEEEEEE" .. GetString(LUIE_FONT_STYLE_OUTLINE) .. "|r",
                    "|cFFFFFF" .. GetString(LUIE_FONT_STYLE_THICK_OUTLINE) .. "|r",
                    "|c777777" .. GetString(LUIE_FONT_STYLE_SOFT_SHADOW_THIN) .. "|r",
                    "|c666666" .. GetString(LUIE_FONT_STYLE_SOFT_SHADOW_THICK) .. "|r",
                },
                choicesValues =
                {
                    GetString(LUIE_FONT_STYLE_VALUE_NORMAL),
                    GetString(LUIE_FONT_STYLE_VALUE_SHADOW),
                    GetString(LUIE_FONT_STYLE_VALUE_OUTLINE),
                    GetString(LUIE_FONT_STYLE_VALUE_THICK_OUTLINE),
                    GetString(LUIE_FONT_STYLE_VALUE_SOFT_SHADOW_THIN),
                    GetString(LUIE_FONT_STYLE_VALUE_SOFT_SHADOW_THICK),
                },
                sort = "name-up",
                getFunc = function ()
                    return Settings.fontStyle
                end,
                setFunc = function (var)
                    Settings.fontStyle = var
                    CombatText.ApplyFont()
                end,
                width = "full",
                default = Defaults.fontStyle,
            },
            {
                -- Test Font Button
                type = "button",
                name = GetString(LUIE_STRING_LAM_CT_FONT_TEST),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_TEST_TP),
                func = function ()
                    callbackManager:FireCallbacks(CombatTextConstants.eventType.COMBAT, CombatTextConstants.combatType.INCOMING, COMBAT_MECHANIC_FLAGS_STAMINA, zo_random(7, 777), GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST), 41567, DAMAGE_TYPE_PHYSICAL, "Test", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
                end,
            },
        },
    }

    -- Combat Text - Animation Options Submenu
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_CT_ANIMATION_HEADER),
        controls =
        {
            {
                -- Animation Type
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_CT_ANIMATION_TYPE),
                tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_TYPE_TP),
                choices = CombatTextConstants.animationType,
                getFunc = function ()
                    return Settings.animation.animationType
                end,
                setFunc = function (v)
                    Settings.animation.animationType = v
                end,
                default = Defaults.animation.animationType,
            },
            {
                -- Animation Duration
                type = "slider",
                name = GetString(LUIE_STRING_LAM_CT_ANIMATION_DURATION),
                tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_DURATION_TP),
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                getFunc = function ()
                    return Settings.animation.animationDuration
                end,
                setFunc = function (v)
                    Settings.animation.animationDuration = v
                end,
                min = 5,
                max = 300,
                step = 5,
                default = 100,
            },
            {
                -- Incoming Direction
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_IN),
                tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_IN_TP),
                choices = CombatTextConstants.directionType,
                getFunc = function ()
                    return Settings.animation.incoming.directionType
                end,
                setFunc = function (v)
                    Settings.animation.incoming.directionType = v
                end,
                default = Defaults.animation.incoming.directionType,
            },
            {
                -- Incoming Icon Position
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_IN),
                tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_IN_TP),
                choices = CombatTextConstants.iconSide,
                getFunc = function ()
                    return Settings.animation.incomingIcon
                end,
                setFunc = function (v)
                    Settings.animation.incomingIcon = v
                end,
                default = Defaults.animation.incomingIcon,
            },
            {
                -- Outgoing Direction
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_OUT),
                tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_OUT_TP),
                choices = CombatTextConstants.directionType,
                getFunc = function ()
                    return Settings.animation.outgoing.directionType
                end,
                setFunc = function (v)
                    Settings.animation.outgoing.directionType = v
                end,
                default = Defaults.animation.outgoing.directionType,
            },
            {
                -- Outgoing Icon Position
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_OUT),
                tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_OUT_TP),
                choices = CombatTextConstants.iconSide,
                getFunc = function ()
                    return Settings.animation.outgoingIcon
                end,
                setFunc = function (v)
                    Settings.animation.outgoingIcon = v
                end,
                default = Defaults.animation.outgoingIcon,
            },
            {
                -- Test Button
                type = "button",
                name = GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST),
                tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST_TP),
                func = function ()
                    callbackManager:FireCallbacks(CombatTextConstants.eventType.COMBAT, CombatTextConstants.combatType.INCOMING, COMBAT_MECHANIC_FLAGS_STAMINA, zo_random(7, 777), GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST), 41567, DAMAGE_TYPE_PHYSICAL, "Test", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
                    callbackManager:FireCallbacks(CombatTextConstants.eventType.COMBAT, CombatTextConstants.combatType.OUTGOING, COMBAT_MECHANIC_FLAGS_STAMINA, zo_random(7, 777), GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST), 41567, DAMAGE_TYPE_PHYSICAL, "Test", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
                end,
            },
        },
    }

    -- Combat Text - Throttle Options (Combat) Options Submenu
    optionsDataCombatText[#optionsDataCombatText + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_CT_THROTTLE_HEADER),
        controls =
        {
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_CT_THROTTLE_DESCRIPTION),
            },
            {
                -- Damage
                type = "slider",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE),
                tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_DAMAGE_TP),
                min = 0,
                max = 500,
                step = 50,
                getFunc = function ()
                    return Settings.throttles.damage
                end,
                setFunc = function (v)
                    Settings.throttles.damage = v
                end,
                default = Defaults.throttles.damage,
            },
            {
                -- Damage over Time
                type = "slider",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_DOT),
                tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_DOT_TP),
                min = 0,
                max = 500,
                step = 50,
                getFunc = function ()
                    return Settings.throttles.dot
                end,
                setFunc = function (v)
                    Settings.throttles.dot = v
                end,
                default = Defaults.throttles.dot,
            },
            {
                -- Healing
                type = "slider",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_HEALING),
                tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_HEALING_TP),
                min = 0,
                max = 500,
                step = 50,
                getFunc = function ()
                    return Settings.throttles.healing
                end,
                setFunc = function (v)
                    Settings.throttles.healing = v
                end,
                default = Defaults.throttles.healing,
            },
            {
                -- Healing over Time
                type = "slider",
                name = GetString(LUIE_STRING_LAM_CT_SHARED_HOT),
                tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_HOT_TP),
                min = 0,
                max = 500,
                step = 50,
                getFunc = function ()
                    return Settings.throttles.hot
                end,
                setFunc = function (v)
                    Settings.throttles.hot = v
                end,
                default = Defaults.throttles.hot,
            },
            {
                -- Throttle Trailer
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CT_THROTTLE_TRAILER),
                tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_TRAILER_TP),
                getFunc = function ()
                    return Settings.toggles.showThrottleTrailer
                end,
                setFunc = function (v)
                    Settings.toggles.showThrottleTrailer = v
                end,
                default = Defaults.toggles.showThrottleTrailer,
            },
            {
                -- Crits
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CT_THROTTLE_CRITICAL)),
                tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_CRITICAL_TP),
                getFunc = function ()
                    return Settings.toggles.throttleCriticals
                end,
                setFunc = function (v)
                    Settings.toggles.throttleCriticals = v
                end,
                disabled = function ()
                    return not Settings.toggles.showThrottleTrailer
                end,
                default = Defaults.toggles.throttleCriticals,
            },
        },
    }

    -- Register the settings panel
    if LUIE.SV.CombatText_Enabled then
        LAM:RegisterAddonPanel(LUIE.name .. "CombatTextOptions", panelDataCombatText)
        LAM:RegisterOptionControls(LUIE.name .. "CombatTextOptions", optionsDataCombatText)
    end
end
