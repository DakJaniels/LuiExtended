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

--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs
local BlacklistPresets = LUIE.Data.AbilityBlacklistPresets

local type, pairs = type, pairs
local zo_strformat = zo_strformat
local table_insert = table.insert

local g_BuffsMovingEnabled = false -- Helper local flag

local rotationOptions = { "Horizontal", "Vertical" }
local rotationOptionsKeys = { ["Horizontal"] = 1, ["Vertical"] = 2 }
local globalIconOptions = { "All Crowd Control", "NPC CC Only", "Player CC Only" }
local globalIconOptionsKeys = { ["All Crowd Control"] = 1, ["NPC CC Only"] = 2, ["Player CC Only"] = 3 }

-- Variables for custom generated tables
local PromBuffs, PromBuffsValues = {}, {}
local PromDebuffs, PromDebuffsValues = {}, {}
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
        identifier = "LUIE_CLEAR_ABILITY_BLACKLIST",
        title = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG), GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST)),
        callback = function (_)
            SpellCastBuffs.ClearCustomList(SpellCastBuffs.SV.BlacklistTable)
            LUIE_Blacklist:UpdateChoices(GenerateCustomList(SpellCastBuffs.SV.BlacklistTable))
        end,
    },
    [2] =
    { -- Clear Prominent Buffs
        identifier = "LUIE_CLEAR_PROMINENT_BUFFS",
        title = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_BUFFS),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG_LIST), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
        callback = function (_)
            SpellCastBuffs.ClearCustomList(SpellCastBuffs.SV.PromBuffTable)
            LUIE_Prominent_Buffs_List:UpdateChoices(GenerateCustomList(SpellCastBuffs.SV.PromBuffTable))
        end,
    },
    [3] =
    { -- Clear Prominent Debuffs
        identifier = "LUIE_CLEAR_PROMINENT_DEBUFFS",
        title = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_DEBUFFS),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG_LIST), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
        callback = function (_)
            SpellCastBuffs.ClearCustomList(SpellCastBuffs.SV.PromDebuffTable)
            LUIE_Prominent_Debuffs_List:UpdateChoices(GenerateCustomList(SpellCastBuffs.SV.PromDebuffTable))
        end,
    },

    [4] =
    { -- Clear Priority Buffs
        identifier = "LUIE_CLEAR_PRIORITY_BUFFS",
        title = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_BUFFS),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG_LIST), GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS)),
        callback = function (_)
            SpellCastBuffs.ClearCustomList(SpellCastBuffs.SV.PriorityBuffTable)
            LUIE_Priority_Buffs_List:UpdateChoices(GenerateCustomList(SpellCastBuffs.SV.PriorityBuffTable))
        end,
    },
    [5] =
    { -- Clear Priority Debuffs
        identifier = "LUIE_CLEAR_PRIORITY_DEBUFFS",
        title = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_DEBUFFS),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG_LIST), GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS)),
        callback = function (_)
            SpellCastBuffs.ClearCustomList(SpellCastBuffs.SV.PriorityDebuffTable)
            LUIE_Priority_Debuffs_List:UpdateChoices(GenerateCustomList(SpellCastBuffs.SV.PriorityDebuffTable))
        end,
    },
}

local function loadDialogButtons()
    for i = 1, #dialogs do
        local dialog = dialogs[i]
        LUIE.RegisterDialogueButton(dialog.identifier, dialog.title, dialog.text, dialog.callback)
    end
end

function SpellCastBuffs.CreateSettings()
    -- Load LibAddonMenu
    local LAM = LibAddonMenu2
    if LAM == nil then
        return
    end

    local Defaults = SpellCastBuffs.Defaults
    local Settings = SpellCastBuffs.SV

    -- Load Dialog Buttons
    loadDialogButtons()

    local panelDataBuffsDebuffs =
    {
        type = "panel",
        name = zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_BUFFSDEBUFFS)),
        displayName = zo_strformat("<<1>> <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_BUFFSDEBUFFS)),
        author = LUIE.author .. "\n",
        version = LUIE.version,
        website = LUIE.website,
        feedback = LUIE.feedback,
        translation = LUIE.translation,
        donation = LUIE.donation,
        slashCommand = "/luiscb",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsDataBuffsDebuffs = {}

    -- Buffs & Debuffs Description
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "description",
        text = GetString(LUIE_STRING_LAM_BUFFS_DESCRIPTION),
    }

    -- ReloadUI Button
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        func = function ()
            ReloadUI("ingame")
        end,
        width = "full",
    }

    -- Buffs Window Unlock
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_BUFF_UNLOCKWINDOW),
        tooltip = GetString(LUIE_STRING_LAM_BUFF_UNLOCKWINDOW_TP),
        getFunc = function ()
            return g_BuffsMovingEnabled
        end,
        setFunc = function (value)
            g_BuffsMovingEnabled = value
            SpellCastBuffs.SetMovingState(value)
        end,
        width = "half",
        default = false,
        resetFunc = SpellCastBuffs.ResetTlwPosition,
    }

    -- Grid Snap Settings for Buffs
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "checkbox",
        name = "Enable Grid Snap (Buffs)",
        tooltip = "Enable snapping buff frames to a grid when moving them",
        getFunc = function ()
            return LUIESV.Default[GetDisplayName()]["$AccountWide"].snapToGrid_buffs
        end,
        setFunc = function (value)
            LUIESV.Default[GetDisplayName()]["$AccountWide"].snapToGrid_buffs = value
        end,
        width = "half",
        default = false,
    }

    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "slider",
        name = "Grid Size (Buffs)",
        tooltip = "Set the size of the grid for snapping buff frames",
        min = 5,
        max = 100,
        step = 5,
        getFunc = function ()
            return LUIESV.Default[GetDisplayName()]["$AccountWide"].snapToGridSize_buffs or 15
        end,
        setFunc = function (value)
            LUIESV.Default[GetDisplayName()]["$AccountWide"].snapToGridSize_buffs = value
        end,
        width = "half",
        default = 15,
        disabled = function ()
            return not LUIESV.Default[GetDisplayName()]["$AccountWide"].snapToGrid_buffs
        end,
    }

    -- Buffs Window Reset position
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RESETPOSITION),
        tooltip = GetString(LUIE_STRING_LAM_BUFF_RESETPOSITION_TP),
        func = SpellCastBuffs.ResetTlwPosition,
        width = "half",
    }
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        -- Hard-Lock Position to Unit Frames
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_BUFF_HARDLOCK),
        tooltip = GetString(LUIE_STRING_LAM_BUFF_HARDLOCK_TP),
        getFunc = function ()
            return Settings.lockPositionToUnitFrames
        end,
        setFunc = function (value)
            Settings.lockPositionToUnitFrames = value
        end,
        width = "full",
        warning = GetString(LUIE_STRING_LAM_BUFF_HARDLOCK_WARNING),
        default = Defaults.lockPositionToUnitFrames,
    }

    -- Buffs&Debuffs - Position and Display Options Submenu
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_BUFF_HEADER_POSITION),
        controls =
        {
            {
                -- Hide OakenSoul
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_HIDE_OAKENSOUL),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_HIDE_OAKENSOUL_TP),
                getFunc = function ()
                    return Settings.HideOakenSoul
                end,
                setFunc = function (value)
                    Settings.HideOakenSoul = value
                end,
                width = "full",
                default = Defaults.HideOakenSoul,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
                requiresReload = true,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERBUFF)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERBUFF_TP),
                getFunc = function ()
                    return not Settings.HidePlayerBuffs
                end,
                setFunc = function (value)
                    Settings.HidePlayerBuffs = not value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "half",
                default = not Defaults.HidePlayerBuffs,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERDEBUFF)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERDEBUFF_TP),
                getFunc = function ()
                    return not Settings.HidePlayerDebuffs
                end,
                setFunc = function (value)
                    Settings.HidePlayerDebuffs = not value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "half",
                default = not Defaults.HidePlayerDebuffs,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETBUFF)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETBUFF_TP),
                getFunc = function ()
                    return not Settings.HideTargetBuffs
                end,
                setFunc = function (value)
                    Settings.HideTargetBuffs = not value
                end,
                width = "half",
                default = not Defaults.HideTargetBuffs,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETDEBUFF)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETDEBUFF_TP),
                getFunc = function ()
                    return not Settings.HideTargetDebuffs
                end,
                setFunc = function (value)
                    Settings.HideTargetDebuffs = not value
                end,
                width = "half",
                default = not Defaults.HideTargetDebuffs,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWGROUNDBUFFDEBUFF)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWGROUNDBUFFDEBUFF_TP),
                getFunc = function ()
                    return not Settings.HideGroundEffects
                end,
                setFunc = function (value)
                    Settings.HideGroundEffects = not value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "half",
                default = not Settings.HideGroundEffects,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Ground Damage Auras
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOW_GROUND_DAMAGE)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOW_GROUND_DAMAGE_TP),
                getFunc = function ()
                    return Settings.GroundDamageAura
                end,
                setFunc = function (value)
                    Settings.GroundDamageAura = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "half",
                default = Settings.GroundDamageAura,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                type = "divider",
            },
            {
                -- Add Extra
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_ADD_EXTRA_BUFFS)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_ADD_EXTRA_BUFFS_TP),
                getFunc = function ()
                    return Settings.ExtraBuffs
                end,
                setFunc = function (value)
                    Settings.ExtraBuffs = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Settings.ExtraBuffs,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Extra Expanded
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_EXTEND_EXTRA)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_EXTEND_EXTRA_TP),
                getFunc = function ()
                    return Settings.ExtraExpanded
                end,
                setFunc = function (value)
                    Settings.ExtraExpanded = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Settings.ExtraExpanded,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ExtraBuffs)
                end,
            },
            {
                type = "divider",
            },
            {
                -- Reduce
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_REDUCE)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_REDUCE_TP),
                getFunc = function ()
                    return Settings.HideReduce
                end,
                setFunc = function (value)
                    Settings.HideReduce = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Settings.HideReduce,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },

            {
                -- Always Show Shared Debuffs
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_ALWAYS_SHARED_EFFECTS),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_ALWAYS_SHARED_EFFECTS_TP),
                getFunc = function ()
                    return Settings.ShowSharedEffects
                end,
                setFunc = function (value)
                    Settings.ShowSharedEffects = value
                    SpellCastBuffs.UpdateDisplayOverrideIdList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ShowSharedEffects,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },

            {
                -- Always Show Major/Minor Debuffs
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_ALWAYS_MAJOR_MINOR_EFFECTS),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_ALWAYS_MAJOR_MINOR_EFFECTS_TP),
                getFunc = function ()
                    return Settings.ShowSharedMajorMinor
                end,
                setFunc = function (value)
                    Settings.ShowSharedMajorMinor = value
                    SpellCastBuffs.UpdateDisplayOverrideIdList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ShowSharedMajorMinor,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
        },
    }

    -- Buffs&Debuffs - Long & Short Term Effects Filters
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_BUFF_LONG_SHORT_HEADER),
        controls =
        {
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_SELF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_SELF_TP),
                getFunc = function ()
                    return Settings.ShortTermEffects_Player
                end,
                setFunc = function (value)
                    Settings.ShortTermEffects_Player = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ShortTermEffects_Player,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_TARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_TARGET_TP),
                getFunc = function ()
                    return Settings.ShortTermEffects_Target
                end,
                setFunc = function (value)
                    Settings.ShortTermEffects_Target = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ShortTermEffects_Target,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SELF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SELF_TP),
                getFunc = function ()
                    return Settings.LongTermEffects_Player
                end,
                setFunc = function (value)
                    Settings.LongTermEffects_Player = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.LongTermEffects_Player,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Separate control for player effects
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SEPCTRL)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SEPCTRL_TP),
                getFunc = function ()
                    return Settings.LongTermEffectsSeparate
                end,
                setFunc = function (value)
                    Settings.LongTermEffectsSeparate = value
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.LongTermEffectsSeparate,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.LongTermEffects_Player)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_TARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_TARGET_TP),
                getFunc = function ()
                    return Settings.LongTermEffects_Target
                end,
                setFunc = function (value)
                    Settings.LongTermEffects_Target = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.LongTermEffects_Target,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },

            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_HEADER),
                width = "full",
            },

            --[[
            {
                -- Show Sprint Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSPRINT),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSPRINT_TP),
                getFunc = function() return Settings.ShowSprint end,
                setFunc = function(value) Settings.ShowSprint = value end,
                width = "full",
                default = Defaults.ShowSprint,
                disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
            },
            {
                -- Show Gallop Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWGALLOP),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWGALLOP_TP),
                getFunc = function() return Settings.ShowGallop end,
                setFunc = function(value) Settings.ShowGallop = value end,
                width = "full",
                default = Defaults.ShowGallop,
                disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
            },
            ]]
            --
            {
                -- Show Rezz Immunity Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWREZZ),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWREZZ_TP),
                getFunc = function ()
                    return Settings.ShowResurrectionImmunity
                end,
                setFunc = function (value)
                    Settings.ShowResurrectionImmunity = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ShowResurrectionImmunity,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Show Recall Cooldown Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWRECALL),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWRECALL_TP),
                getFunc = function ()
                    return Settings.ShowRecall
                end,
                setFunc = function (value)
                    Settings.ShowRecall = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ShowRecall,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Show Werewolf Timer Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWWEREWOLF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWWEREWOLF_TP),
                getFunc = function ()
                    return Settings.ShowWerewolf
                end,
                setFunc = function (value)
                    Settings.ShowWerewolf = value
                    SpellCastBuffs.RegisterWerewolfEvents()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ShowWerewolf,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Short Term - Set ICD - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SETICDPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SETICDPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreSetICDPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreSetICDPlayer = not value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreSetICDPlayer,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Short Term - Ability ICD - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ABILITYICDPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ABILITYICDPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreAbilityICDPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreAbilityICDPlayer = not value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreAbilityICDPlayer,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            --[[ TODO: Reimplement if possible
            {
                -- Show Block Player Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWBLOCKPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWBLOCKPLAYER_TP),
                getFunc = function() return Settings.ShowBlockPlayer end,
                setFunc = function(value) Settings.ShowBlockPlayer = value SpellCastBuffs.UpdateContextHideList() SpellCastBuffs.ReloadEffects("player") end,
                width = "full",
                default = Defaults.ShowBlockPlayer,
                disabled = function() return not LUIE.SV.SpellCastBuff_Enable end,
            },
            ]]
            --
            {
                -- Show Block Target Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWBLOCKTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWBLOCKTARGET_TP),
                getFunc = function ()
                    return Settings.ShowBlockTarget
                end,
                setFunc = function (value)
                    Settings.ShowBlockTarget = value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ShowBlockTarget,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Show Stealth Player Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHPLAYER_TP),
                getFunc = function ()
                    return Settings.StealthStatePlayer
                end,
                setFunc = function (value)
                    Settings.StealthStatePlayer = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.StealthStatePlayer,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Show Stealth Target Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHTARGET_TP),
                getFunc = function ()
                    return Settings.StealthStateTarget
                end,
                setFunc = function (value)
                    Settings.StealthStateTarget = value
                    SpellCastBuffs.ReloadEffects("reticleover")
                end,
                width = "full",
                default = Defaults.StealthStateTarget,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Show Disguise Player Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISEPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISEPLAYER_TP),
                getFunc = function ()
                    return Settings.DisguiseStatePlayer
                end,
                setFunc = function (value)
                    Settings.DisguiseStatePlayer = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.DisguiseStatePlayer,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Show Disguise Target Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISETARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISETARGET_TP),
                getFunc = function ()
                    return Settings.DisguiseStateTarget
                end,
                setFunc = function (value)
                    Settings.DisguiseStateTarget = value
                    SpellCastBuffs.ReloadEffects("reticleover")
                end,
                width = "full",
                default = Defaults.DisguiseStateTarget,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },

            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_HEADER),
                width = "full",
            },

            {
                -- Long Term - Disguises
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_DISGUISE),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_DISGUISE_TP),
                getFunc = function ()
                    return not Settings.IgnoreDisguise
                end,
                setFunc = function (value)
                    Settings.IgnoreDisguise = not value
                    SpellCastBuffs.OnPlayerActivated()
                end,
                width = "full",
                default = not Defaults.IgnoreDisguise,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Assistants
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ASSISTANT),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ASSISTANT_TP),
                getFunc = function ()
                    return not Settings.IgnoreAssistant
                end,
                setFunc = function (value)
                    Settings.IgnoreAssistant = not value
                    SpellCastBuffs.OnPlayerActivated()
                end,
                width = "full",
                default = not Defaults.IgnoreAssistant,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Pets
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET_TP),
                getFunc = function ()
                    return not Settings.IgnorePet
                end,
                setFunc = function (value)
                    Settings.IgnorePet = not value
                    SpellCastBuffs.OnPlayerActivated()
                end,
                width = "full",
                default = not Defaults.IgnorePet,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Use Generic Pet Icon
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET_ICON)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET_ICON_TP),
                getFunc = function ()
                    return Settings.PetDetail
                end,
                setFunc = function (value)
                    Settings.PetDetail = value
                    SpellCastBuffs.OnPlayerActivated()
                end,
                width = "full",
                default = not Defaults.PetDetail,
                disabled = function ()
                    return Settings.IgnorePet
                end,
            },
            {
                -- Long Term - Mounts (Player)
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_PLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_PLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreMountPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreMountPlayer = not value
                    SpellCastBuffs.OnPlayerActivated()
                end,
                width = "full",
                default = not Defaults.IgnoreMountPlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Use Generic Mount Icon
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_ICON)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_ICON_TP),
                getFunc = function ()
                    return Settings.MountDetail
                end,
                setFunc = function (value)
                    Settings.MountDetail = value
                    SpellCastBuffs.OnPlayerActivated()
                end,
                width = "full",
                default = not Defaults.MountDetail,
                disabled = function ()
                    return Settings.IgnoreMountPlayer
                end,
            },
            --[[
            {
                -- Long Term - Mounts (Target)
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_TARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_TARGET_TP),
                getFunc = function() return not Settings.IgnoreMountTarget end,
                setFunc = function(value) Settings.IgnoreMountTarget = not value end,
                width = "full",
                default = not Defaults.IgnoreMountTarget,
                disabled = function() return not ( LUIE.SV.SpellCastBuff_Enable and ( Settings.LongTermEffects_Player or Settings.LongTermEffects_Target ) ) end,
            },
            ]]
            --
            {
                -- Long Term - Mundus - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MUNDUSPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MUNDUSPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreMundusPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreMundusPlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreMundusPlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Mundus - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MUNDUSTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MUNDUSTARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreMundusTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreMundusTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreMundusTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Food & Drink - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_FOODPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_FOODPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreFoodPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreFoodPlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreFoodPlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Food & Drink - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_FOODTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_FOODTARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreFoodTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreFoodTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreFoodTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Experience - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_EXPERIENCEPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_EXPERIENCEPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreExperiencePlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreExperiencePlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreExperiencePlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Experience - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_EXPERIENCETARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_EXPERIENCETARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreExperienceTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreExperienceTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreExperienceTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },

            {
                -- Long Term - Alliance XP - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ALLIANCEXPPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ALLIANCEXPPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreAllianceXPPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreAllianceXPPlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreAllianceXPPlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Alliance XP - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ALLIANCEXPTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ALLIANCEXPTARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreAllianceXPTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreAllianceXPTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreAllianceXPTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },

            {
                -- Long Term - Vamp Stage - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPSTAGEPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPSTAGEPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreVampPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreVampPlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreVampPlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Vamp Stage - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPSTAGETARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPSTAGETARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreVampTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreVampTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreVampTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Lycanthrophy - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_LYCANPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_LYCANPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreLycanPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreLycanPlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreLycanPlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Lycanthrophy - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_LYCANTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_LYCANTARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreLycanTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreLycanTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreLycanTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Bite Disease - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPWWPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPWWPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreDiseasePlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreDiseasePlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreDiseasePlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Bite Disease - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPWWTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPWWTARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreDiseaseTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreDiseaseTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreDiseaseTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Bite Timers - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BITEPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BITEPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreBitePlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreBitePlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreBitePlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Bite Timers - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BITETARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BITETARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreBiteTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreBiteTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreBiteTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Battle Spirit - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BSPIRITPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BSPIRITPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreBattleSpiritPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreBattleSpiritPlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                    SpellCastBuffs.ArtificialEffectUpdate()
                end,
                width = "full",
                default = not Defaults.IgnoreBattleSpiritPlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Battle Spirit - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BSPIRITTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BSPIRITTARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreBattleSpiritTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreBattleSpiritTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreBattleSpiritTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Cyrodiil - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CYROPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CYROPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreCyrodiilPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreCyrodiilPlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreCyrodiilPlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Crodiil - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CYROTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CYROTARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreCyrodiilTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreCyrodiilTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreCyrodiilTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - ESO Plus - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ESOPLUSPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ESOPLUSPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreEsoPlusPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreEsoPlusPlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreEsoPlusPlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - ESO Plus - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ESOPLUSTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ESOPLUSTARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreEsoPlusTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreEsoPlusTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreEsoPlusTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Soul Summons - Player
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SOULSUMMONSPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SOULSUMMONSPLAYER_TP),
                getFunc = function ()
                    return not Settings.IgnoreSoulSummonsPlayer
                end,
                setFunc = function (value)
                    Settings.IgnoreSoulSummonsPlayer = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreSoulSummonsPlayer,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
            {
                -- Long Term - Soul Summons - Target
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SOULSUMMONSTARGET),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SOULSUMMONSTARGET_TP),
                getFunc = function ()
                    return not Settings.IgnoreSoulSummonsTarget
                end,
                setFunc = function (value)
                    Settings.IgnoreSoulSummonsTarget = not value
                    SpellCastBuffs.UpdateContextHideList()
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = not Defaults.IgnoreSoulSummonsTarget,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
                end,
            },
        },
    }

    -- Buffs&Debuffs - Icon Options Submenu
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_BUFF_ICON_HEADER),
        controls =
        {
            {
                -- Buff Icon Size
                type = "slider",
                name = GetString(LUIE_STRING_LAM_BUFF_ICONSIZE),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_ICONSIZE_TP),
                min = 30,
                max = 60,
                step = 2,
                getFunc = function ()
                    return Settings.IconSize
                end,
                setFunc = function (value)
                    Settings.IconSize = value
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.IconSize,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Buff Show Remaining Time Label
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_SHOWREMAINTIMELABEL),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWREMAINTIMELABEL_TP),
                getFunc = function ()
                    return Settings.RemainingText
                end,
                setFunc = function (value)
                    Settings.RemainingText = value
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.RemainingText,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Buff Label Position
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CI_SHARED_POSITION)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LABEL_POSITION_TP),
                min = -64,
                max = 64,
                step = 2,
                getFunc = function ()
                    return Settings.LabelPosition
                end,
                setFunc = function (value)
                    Settings.LabelPosition = value
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.LabelPosition,
                disabled = function ()
                    return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
                end,
            },
            {
                -- Buff Label Font
                type = "dropdown",
                scrollable = true,
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_FONT)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_FONT_TP),
                choices = FontsList,
                sort = "name-up",
                getFunc = function ()
                    return Settings.BuffFontFace
                end,
                setFunc = function (var)
                    Settings.BuffFontFace = var
                    SpellCastBuffs.ApplyFont()
                end,
                width = "full",
                default = Defaults.BuffFontFace,
                disabled = function ()
                    return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
                end,
            },
            {
                -- Buff Font Size
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_FONT_SIZE)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_FONTSIZE_TP),
                min = 10,
                max = 30,
                step = 1,
                getFunc = function ()
                    return Settings.BuffFontSize
                end,
                setFunc = function (value)
                    Settings.BuffFontSize = value
                    SpellCastBuffs.ApplyFont()
                end,
                width = "full",
                default = Defaults.BuffFontSize,
                disabled = function ()
                    return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
                end,
            },
            {
                -- Buff Font Style
                type = "dropdown",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_FONT_STYLE)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_FONTSTYLE_TP),
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
                    return Settings.BuffFontStyle
                end,
                setFunc = function (var)
                    Settings.BuffFontStyle = var
                    SpellCastBuffs.ApplyFont()
                end,
                width = "full",
                default = Defaults.BuffFontStyle,
                disabled = function ()
                    return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
                end,
            },
            {
                -- Buff Colored Label
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CI_POTION_COLOR)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LABELCOLOR_TP),
                getFunc = function ()
                    return Settings.RemainingTextColoured
                end,
                setFunc = function (value)
                    Settings.RemainingTextColoured = value
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.RemainingTextColoured,
                disabled = function ()
                    return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
                end,
            },
            {
                -- Buff Show Seconds Fractions
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
                getFunc = function ()
                    return Settings.RemainingTextMillis
                end,
                setFunc = function (value)
                    Settings.RemainingTextMillis = value
                end,
                width = "full",
                default = Defaults.RemainingTextMillis,
                disabled = function ()
                    return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
                end,
            },
            {
                -- Buff Glow Icon Border
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_GLOWICONBORDER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_GLOWICONBORDER_TP),
                getFunc = function ()
                    return Settings.GlowIcons
                end,
                setFunc = function (value)
                    Settings.GlowIcons = value
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.GlowIcons,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Buff Show Border Cooldown
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_SHOWBORDERCOOLDOWN),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWBORDERCOOLDOWN_TP),
                getFunc = function ()
                    return Settings.RemainingCooldown
                end,
                setFunc = function (value)
                    Settings.RemainingCooldown = value
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.RemainingCooldown,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Buff Fade Expiring Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_FADEEXPIREICON),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_FADEEXPIREICON_TP),
                getFunc = function ()
                    return Settings.FadeOutIcons
                end,
                setFunc = function (value)
                    Settings.FadeOutIcons = value
                end,
                width = "full",
                default = Defaults.FadeOutIcons,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },

            -- Icon Normalization Options
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_BUFF_NORMALIZE_HEADER),
                width = "full",
            },
            {
                -- Use Generic Icon for CC Type
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON),
                tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_TP),
                getFunc = function ()
                    return Settings.UseDefaultIcon
                end,
                setFunc = function (newValue)
                    Settings.UseDefaultIcon = newValue
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
                default = Defaults.UseDefaultIcon,
            },
            {
                -- Generic Icon Options
                type = "dropdown",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS)),
                tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS_TP),
                choices = globalIconOptions,
                getFunc = function ()
                    return globalIconOptions[Settings.DefaultIconOptions]
                end,
                setFunc = function (value)
                    Settings.DefaultIconOptions = globalIconOptionsKeys[value]
                end,
                width = "full",
                disabled = function ()
                    return not Settings.UseDefaultIcon
                end,
                default = Defaults.DefaultIconOptions,
            },
        },
    }

    -- Buffs&Debuffs - Color Options Submenu
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER),
        controls =
        {
            {
                -- Basic Color Options
                type = "header",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER_BASIC),
                width = "full",
            },
            {
                -- buff
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_BUFF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_BUFF_TP),
                getFunc = function ()
                    return unpack(Settings.colors.buff)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.buff = { r, g, b, a }
                end,
                default = { r = Defaults.colors.buff[1], g = Defaults.colors.buff[2], b = Defaults.colors.buff[3] },
                width = "half",
            },
            {
                -- debuff
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_DEBUFF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_DEBUFF_TP),
                getFunc = function ()
                    return unpack(Settings.colors.debuff)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.debuff = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.debuff[1],
                    g = Defaults.colors.debuff[2],
                    b = Defaults.colors.debuff[3],
                },
                width = "half",
            },
            {
                -- prioritybuff
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYBUFF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYBUFF_TP),
                getFunc = function ()
                    return unpack(Settings.colors.prioritybuff)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.prioritybuff = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.prioritybuff[1],
                    g = Defaults.colors.prioritybuff[2],
                    b = Defaults.colors.prioritybuff[3],
                },
                width = "half",
            },
            {
                -- prioritydebuff
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYDEBUFF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYDEBUFF_TP),
                getFunc = function ()
                    return unpack(Settings.colors.prioritydebuff)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.prioritydebuff = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.prioritydebuff[1],
                    g = Defaults.colors.prioritydebuff[2],
                    b = Defaults.colors.prioritydebuff[3],
                },
                width = "half",
            },
            {
                -- Unbreakable & Cosmetic Header
                type = "header",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER_UNBREAKABLE),
                width = "full",
            },
            {
                -- Unbreakable Toggle
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE_TOGGLE),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE_TOGGLE_TP),
                getFunc = function ()
                    return Settings.ColorUnbreakable
                end,
                setFunc = function (value)
                    Settings.ColorUnbreakable = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ColorUnbreakable,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- unbreakable
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.unbreakable)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.unbreakable = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.unbreakable[1],
                    g = Defaults.colors.unbreakable[2],
                    b = Defaults.colors.unbreakable[3],
                },
                disabled = function ()
                    return not Settings.ColorUnbreakable
                end,
            },

            {
                -- Cosmetic Toggle
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC_TOGGLE),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC_TOGGLE_TP),
                getFunc = function ()
                    return Settings.ColorCosmetic
                end,
                setFunc = function (value)
                    Settings.ColorCosmetic = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ColorCosmetic,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- cosmetic
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC_TP),
                getFunc = function ()
                    return unpack(Settings.colors.cosmetic)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.cosmetic = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.cosmetic[1],
                    g = Defaults.colors.cosmetic[2],
                    b = Defaults.colors.cosmetic[3],
                },
                disabled = function ()
                    return not Settings.ColorCosmetic
                end,
            },
            {
                -- Crowd Control Header
                type = "header",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER_CROWD_CONTROL),
                width = "full",
            },
            {
                -- CC Toggle
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_BY_CC),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_BY_CC_TP),
                getFunc = function ()
                    return Settings.ColorCC
                end,
                setFunc = function (value)
                    Settings.ColorCC = value
                    SpellCastBuffs.ReloadEffects("player")
                end,
                width = "full",
                default = Defaults.ColorCC,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- nocc
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_NOCC),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_NOCC_TP),
                getFunc = function ()
                    return unpack(Settings.colors.nocc)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.nocc = { r, g, b, a }
                end,
                default = { r = Defaults.colors.nocc[1], g = Defaults.colors.nocc[2], b = Defaults.colors.nocc[3] },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
            {
                -- stun
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_STUN),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_STUN_TP),
                getFunc = function ()
                    return unpack(Settings.colors.stun)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.stun = { r, g, b, a }
                end,
                default = { r = Defaults.colors.stun[1], g = Defaults.colors.stun[2], b = Defaults.colors.stun[3] },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
            {
                -- knockback
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_KNOCKBACK),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_KNOCKBACK_TP),
                getFunc = function ()
                    return unpack(Settings.colors.knockback)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.knockback = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.knockback[1],
                    g = Defaults.colors.knockback[2],
                    b = Defaults.colors.knockback[3],
                },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
            {
                -- levitate
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_LEVITATE),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_LEVITATE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.levitate)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.levitate = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.levitate[1],
                    g = Defaults.colors.levitate[2],
                    b = Defaults.colors.levitate[3],
                },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
            {
                -- disorient
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_DISORIENT),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_DISORIENT_TP),
                getFunc = function ()
                    return unpack(Settings.colors.disorient)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.disorient = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.disorient[1],
                    g = Defaults.colors.disorient[2],
                    b = Defaults.colors.disorient[3],
                },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
            {
                -- fear
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_FEAR),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_FEAR_TP),
                getFunc = function ()
                    return unpack(Settings.colors.fear)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.fear = { r, g, b, a }
                end,
                default = { r = Defaults.colors.fear[1], g = Defaults.colors.fear[2], b = Defaults.colors.fear[3] },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
            {
                -- charm
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_CHARM),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_CHARM_TP),
                getFunc = function ()
                    return unpack(Settings.colors.charm)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.charm = { r, g, b, a }
                end,
                default = { r = Defaults.colors.charm[1], g = Defaults.colors.charm[2], b = Defaults.colors.charm[3] },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
            {
                -- stagger
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_STAGGER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_STAGGER_TP),
                getFunc = function ()
                    return unpack(Settings.colors.stagger)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.stagger = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.stagger[1],
                    g = Defaults.colors.stagger[2],
                    b = Defaults.colors.stagger[3],
                },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
            {
                -- silence
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_SILENCE),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_SILENCE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.silence)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.silence = { r, g, b, a }
                end,
                default =
                {
                    r = Defaults.colors.silence[1],
                    g = Defaults.colors.silence[2],
                    b = Defaults.colors.silence[3],
                },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
            {
                -- snare
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_SNARE),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_SNARE_TP),
                getFunc = function ()
                    return unpack(Settings.colors.snare)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.snare = { r, g, b, a }
                end,
                default = { r = Defaults.colors.snare[1], g = Defaults.colors.snare[2], b = Defaults.colors.snare[3] },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
            {
                -- root
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_BUFF_COLOR_ROOT),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_ROOT_TP),
                getFunc = function ()
                    return unpack(Settings.colors.root)
                end,
                setFunc = function (r, g, b, a)
                    Settings.colors.root = { r, g, b, a }
                end,
                default = { r = Defaults.colors.root[1], g = Defaults.colors.root[2], b = Defaults.colors.root[3] },
                width = "half",
                disabled = function ()
                    return not Settings.ColorCC
                end,
            },
        },
    }

    -- Buffs&Debuffs - Alignment & Sorting Options Submenu
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_BUFF_SORTING_HEADER),
        controls =
        {
            -- Buffs/Debuffs Alignment & Sorting
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_BUFF_SORTING_NORMAL_HEADER),
                width = "full",
            },
            {
                -- Buff Alignment (BuffsPlayer)
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
                choices = { "Left", "Centered", "Right" },
                getFunc = function ()
                    return Settings.AlignmentBuffsPlayer
                end,
                setFunc = function (value)
                    Settings.AlignmentBuffsPlayer = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.AlignmentBuffsPlayer,
            },
            {
                -- Buff Sort Direction (BuffsPlayer)
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
                choices = { "Left to Right", "Right to Left" },
                getFunc = function ()
                    return Settings.SortBuffsPlayer
                end,
                setFunc = function (value)
                    Settings.SortBuffsPlayer = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.SortBuffsPlayer,
            },
            {
                -- Buff Alignment (DebuffsPlayer)
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
                choices = { "Left", "Centered", "Right" },
                getFunc = function ()
                    return Settings.AlignmentDebuffsPlayer
                end,
                setFunc = function (value)
                    Settings.AlignmentDebuffsPlayer = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.AlignmentDebuffsPlayer,
            },
            {
                -- Buff Sort Direction (DebuffsPlayer)
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
                choices = { "Left to Right", "Right to Left" },
                getFunc = function ()
                    return Settings.SortDebuffsPlayer
                end,
                setFunc = function (value)
                    Settings.SortDebuffsPlayer = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.SortDebuffsPlayer,
            },
            {
                -- Buff Alignment (BuffsTarget)
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
                choices = { "Left", "Centered", "Right" },
                getFunc = function ()
                    return Settings.AlignmentBuffsTarget
                end,
                setFunc = function (value)
                    Settings.AlignmentBuffsTarget = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.AlignmentBuffsTarget,
            },
            {
                -- Buff Sort Direction (BuffsTarget)
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
                choices = { "Left to Right", "Right to Left" },
                getFunc = function ()
                    return Settings.SortBuffsTarget
                end,
                setFunc = function (value)
                    Settings.SortBuffsTarget = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.SortBuffsTarget,
            },
            {
                -- Buff Alignment (DebuffsTarget)
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
                choices = { "Left", "Centered", "Right" },
                getFunc = function ()
                    return Settings.AlignmentDebuffsTarget
                end,
                setFunc = function (value)
                    Settings.AlignmentDebuffsTarget = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.AlignmentDebuffsTarget,
            },
            {
                -- Buff Sort Direction (DebuffsTarget)
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
                choices = { "Left to Right", "Right to Left" },
                getFunc = function ()
                    return Settings.SortDebuffsTarget
                end,
                setFunc = function (value)
                    Settings.SortDebuffsTarget = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.SortDebuffsTarget,
            },

            -- Unanchored Player / Target Buff Options
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_BUFF_SORTING_UNANCHORED_HEADER),
                width = "full",
            },
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_BUFF_SORTING_UNANCHORED_DESCRIPTION),
            },

            {
                -- Buff Width - Player Buffs
                type = "slider",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
                min = 40,
                max = 1920,
                step = 10,
                getFunc = function ()
                    return Settings.WidthPlayerBuffs
                end,
                setFunc = function (value)
                    Settings.WidthPlayerBuffs = value
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default = Defaults.WidthPlayerBuffs,
                disabled = function ()
                    return Settings.lockPositionToUnitFrames
                end,
            },

            {
                -- Buff Stack Direction - Player Buffs
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
                choices = { "Down", "Up" },
                getFunc = function ()
                    return Settings.StackPlayerBuffs
                end,
                setFunc = function (value)
                    Settings.StackPlayerBuffs = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.StackPlayerBuffs,
                disabled = function ()
                    return Settings.lockPositionToUnitFrames
                end,
            },

            {
                -- Buff Width - Player Debuffs
                type = "slider",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
                min = 40,
                max = 1920,
                step = 10,
                getFunc = function ()
                    return Settings.WidthPlayerDebuffs
                end,
                setFunc = function (value)
                    Settings.WidthPlayerDebuffs = value
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default = Defaults.WidthPlayerDebuffs,
                disabled = function ()
                    return Settings.lockPositionToUnitFrames
                end,
            },

            {
                -- Buff Stack Direction - Player Debuffs
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
                choices = { "Down", "Up" },
                getFunc = function ()
                    return Settings.StackPlayerDebuffs
                end,
                setFunc = function (value)
                    Settings.StackPlayerDebuffs = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.StackPlayerDebuffs,
                disabled = function ()
                    return Settings.lockPositionToUnitFrames
                end,
            },

            {
                -- Buff Width - Target Buffs
                type = "slider",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
                min = 40,
                max = 1920,
                step = 10,
                getFunc = function ()
                    return Settings.WidthTargetBuffs
                end,
                setFunc = function (value)
                    Settings.WidthTargetBuffs = value
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default = Defaults.WidthTargetBuffs,
                disabled = function ()
                    return Settings.lockPositionToUnitFrames
                end,
            },

            {
                -- Buff Stack Direction - Target Buffs
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
                choices = { "Down", "Up" },
                getFunc = function ()
                    return Settings.StackTargetBuffs
                end,
                setFunc = function (value)
                    Settings.StackTargetBuffs = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.StackTargetBuffs,
                disabled = function ()
                    return Settings.lockPositionToUnitFrames
                end,
            },

            {
                -- Buff Width - Target Debuffs
                type = "slider",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
                min = 40,
                max = 1920,
                step = 10,
                getFunc = function ()
                    return Settings.WidthTargetDebuffs
                end,
                setFunc = function (value)
                    Settings.WidthTargetDebuffs = value
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default = Defaults.WidthTargetDebuffs,
                disabled = function ()
                    return Settings.lockPositionToUnitFrames
                end,
            },

            {
                -- Buff Stack Direction - Target Debuffs
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
                choices = { "Down", "Up" },
                getFunc = function ()
                    return Settings.StackTargetDebuffs
                end,
                setFunc = function (value)
                    Settings.StackTargetDebuffs = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.StackTargetDebuffs,
                disabled = function ()
                    return Settings.lockPositionToUnitFrames
                end,
            },

            -- Long Term Alignment & Sorting
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_BUFF_SORTING_LONGTERM_HEADER),
                width = "full",
            },
            {
                -- Container Orientation (Long Term)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CONTAINER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CONTAINER_TP),
                choices = rotationOptions,
                getFunc = function ()
                    return rotationOptions[Settings.LongTermEffectsSeparateAlignment]
                end,
                setFunc = function (value)
                    Settings.LongTermEffectsSeparateAlignment = rotationOptionsKeys[value]
                    SpellCastBuffs.ResetContainerOrientation()
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = rotationOptions[2],
            },
            {
                -- Horizontal Long Term Icons Alignment
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
                choices = { "Left", "Centered", "Right" },
                getFunc = function ()
                    return Settings.AlignmentLongHorz
                end,
                setFunc = function (value)
                    Settings.AlignmentLongHorz = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.AlignmentLongHorz,
                disabled = function ()
                    return Settings.LongTermEffectsSeparateAlignment == 2
                end,
            },
            {
                -- Horizontal Long Term Sort
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
                choices = { "Left to Right", "Right to Left" },
                getFunc = function ()
                    return Settings.SortLongHorz
                end,
                setFunc = function (value)
                    Settings.SortLongHorz = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.SortLongHorz,
                disabled = function ()
                    return Settings.LongTermEffectsSeparateAlignment == 2
                end,
            },
            {
                -- Vertical Long Term Icons Alignment
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
                choices = { "Top", "Centered", "Bottom" },
                getFunc = function ()
                    return Settings.AlignmentLongVert
                end,
                setFunc = function (value)
                    Settings.AlignmentLongVert = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.AlignmentLongVert,
                disabled = function ()
                    return Settings.LongTermEffectsSeparateAlignment == 1
                end,
            },
            {
                -- Vertical Long Term Sort
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
                choices = { "Bottom to Top", "Top to Bottom" },
                getFunc = function ()
                    return Settings.SortLongVert
                end,
                setFunc = function (value)
                    Settings.SortLongVert = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.SortLongVert,
                disabled = function ()
                    return Settings.LongTermEffectsSeparateAlignment == 1
                end,
            },

            -- Prominent Alignment & Sorting
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_BUFF_SORTING_PROMINET_HEADER),
                width = "full",
            },

            {
                -- Prominent Buff Container Orientation
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFCONTAINER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFCONTAINER_TP),
                choices = rotationOptions,
                getFunc = function ()
                    return rotationOptions[Settings.ProminentBuffContainerAlignment]
                end,
                setFunc = function (value)
                    Settings.ProminentBuffContainerAlignment = rotationOptionsKeys[value]
                    SpellCastBuffs.ResetContainerOrientation()
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = rotationOptions[2],
            },
            {
                -- Horizontal Prominent Buffs Icons Alignment
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
                choices = { "Left", "Centered", "Right" },
                getFunc = function ()
                    return Settings.AlignmentPromBuffsHorz
                end,
                setFunc = function (value)
                    Settings.AlignmentPromBuffsHorz = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.AlignmentPromBuffsHorz,
                disabled = function ()
                    return Settings.ProminentBuffContainerAlignment == 2
                end,
            },
            {
                -- Horizontal Prominent Buffs Sort
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
                choices = { "Left to Right", "Right to Left" },
                getFunc = function ()
                    return Settings.SortPromBuffsHorz
                end,
                setFunc = function (value)
                    Settings.SortPromBuffsHorz = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.SortPromBuffsHorz,
                disabled = function ()
                    return Settings.ProminentBuffContainerAlignment == 2
                end,
            },
            {
                -- Vertical Prominent Buffs Icons Alignment
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
                choices = { "Top", "Centered", "Bottom" },
                getFunc = function ()
                    return Settings.AlignmentPromBuffsVert
                end,
                setFunc = function (value)
                    Settings.AlignmentPromBuffsVert = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.AlignmentPromBuffsVert,
                disabled = function ()
                    return Settings.ProminentBuffContainerAlignment == 1
                end,
            },
            {
                -- Vertical Prominent Buffs Sort
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
                choices = { "Bottom to Top", "Top to Bottom" },
                getFunc = function ()
                    return Settings.SortPromBuffsVert
                end,
                setFunc = function (value)
                    Settings.SortPromBuffsVert = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.SortPromBuffsVert,
                disabled = function ()
                    return Settings.ProminentBuffContainerAlignment == 1
                end,
            },
            {
                type = "divider",
            },
            {
                -- Prominent Debuff Container Orientation
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFCONTAINER),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFCONTAINER_TP),
                choices = rotationOptions,
                getFunc = function ()
                    return rotationOptions[Settings.ProminentDebuffContainerAlignment]
                end,
                setFunc = function (value)
                    Settings.ProminentDebuffContainerAlignment = rotationOptionsKeys[value]
                    SpellCastBuffs.ResetContainerOrientation()
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = rotationOptions[2],
            },
            {
                -- Horizontal Prominent Debuffs Icons Alignment
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
                choices = { "Left", "Centered", "Right" },
                getFunc = function ()
                    return Settings.AlignmentPromDebuffsHorz
                end,
                setFunc = function (value)
                    Settings.AlignmentPromDebuffsHorz = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.AlignmentPromDebuffsHorz,
                disabled = function ()
                    return Settings.ProminentDebuffContainerAlignment == 2
                end,
            },
            {
                -- Horizontal Prominent Debuffs Sort
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
                choices = { "Left to Right", "Right to Left" },
                getFunc = function ()
                    return Settings.SortPromDebuffsHorz
                end,
                setFunc = function (value)
                    Settings.SortPromDebuffsHorz = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.SortPromDebuffsHorz,
                disabled = function ()
                    return Settings.ProminentDebuffContainerAlignment == 2
                end,
            },
            {
                -- Vertical Prominent Debuffs Icons Alignment
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
                choices = { "Top", "Centered", "Bottom" },
                getFunc = function ()
                    return Settings.AlignmentPromDebuffsVert
                end,
                setFunc = function (value)
                    Settings.AlignmentPromDebuffsVert = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.AlignmentPromDebuffsVert,
                disabled = function ()
                    return Settings.ProminentDebuffContainerAlignment == 1
                end,
            },
            {
                -- Vertical Prominent Debuffs Sort
                type = "dropdown",
                name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
                tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
                choices = { "Bottom to Top", "Top to Bottom" },
                getFunc = function ()
                    return Settings.SortPromDebuffsVert
                end,
                setFunc = function (value)
                    Settings.SortPromDebuffsVert = value
                    SpellCastBuffs.SetupContainerAlignment()
                    SpellCastBuffs.SetupContainerSort()
                end,
                width = "half",
                default = Defaults.SortPromDebuffsVert,
                disabled = function ()
                    return Settings.ProminentDebuffContainerAlignment == 1
                end,
            },
        },
    }

    -- Buffs&Debuffs - Tooltip Options Submenu
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_HEADER),
        controls =
        {
            {
                -- Tooltip Enable
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ENABLE),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ENABLE_TP),
                getFunc = function ()
                    return Settings.TooltipEnable
                end,
                setFunc = function (value)
                    Settings.TooltipEnable = value
                end,
                width = "full",
                default = Defaults.TooltipEnable,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Tooltip Custom
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_CUSTOM),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_CUSTOM_TP),
                getFunc = function ()
                    return Settings.TooltipCustom
                end,
                setFunc = function (value)
                    Settings.TooltipCustom = value
                end,
                width = "full",
                default = Defaults.TooltipCustom,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Tooltip Ability Id
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ABILITY_ID),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ABILITY_ID_TP),
                getFunc = function ()
                    return Settings.TooltipAbilityId
                end,
                setFunc = function (value)
                    Settings.TooltipAbilityId = value
                end,
                width = "full",
                default = Defaults.TooltipAbilityId,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Tooltip Buff Type
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_BUFF_TYPE),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_BUFF_TYPE_TP),
                getFunc = function ()
                    return Settings.TooltipBuffType
                end,
                setFunc = function (value)
                    Settings.TooltipBuffType = value
                end,
                width = "full",
                default = Defaults.TooltipBuffType,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Sticky Tooltip Slider
                type = "slider",
                name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_STICKY),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_STICKY_TP),
                min = 0,
                max = 5000,
                step = 100,
                getFunc = function ()
                    return Settings.TooltipSticky
                end,
                setFunc = function (value)
                    Settings.TooltipSticky = value
                end,
                width = "full",
                default = Defaults.TooltipSticky,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
        },
    }

    -- Buffs&Debuffs - Priority Buffs & Debuffs Options Submenu
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_HEADER),
        controls =
        {
            {
                -- Prominent Buffs & Debuffs Description
                type = "description",
                text = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DESCRIPTION),
            },
            {
                type = "divider",
            },
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DIALOGUE_DESCRIPT),
            },
            {
                -- Priority Buffs List (Add)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_BUFF_ADDLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_BUFF_ADDLIST_TP),
                getFunc = function () end,
                setFunc = function (value)
                    SpellCastBuffs.AddToCustomList(Settings.PriorityBuffTable, value)
                    LUIE_Priority_Buffs_List:UpdateChoices(GenerateCustomList(Settings.PriorityBuffTable))
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Priority Buffs List (Remove)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_BUFF_REMLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_BUFF_REMLIST_TP),
                choices = PromBuffs,
                choicesValues = PromBuffsValues,
                scrollable = true,
                sort = "name-up",
                getFunc = function ()
                    LUIE_Priority_Buffs_List:UpdateChoices(GenerateCustomList(Settings.PriorityBuffTable))
                end,
                setFunc = function (value)
                    SpellCastBuffs.RemoveFromCustomList(Settings.PriorityBuffTable, value)
                    LUIE_Priority_Buffs_List:UpdateChoices(GenerateCustomList(Settings.PriorityBuffTable))
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
                reference = "LUIE_Priority_Buffs_List",
            },
            {
                -- Clear Priority Buffs
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_BUFFS),
                tooltip = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_BUFFS_TP),
                func = function ()
                    ZO_Dialogs_ShowDialog("LUIE_CLEAR_PRIORITY_BUFFS")
                end,
                width = "half",
            },
            {
                -- Priority Debuffs List (Add)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DEBUFF_ADDLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DEBUFF_ADDLIST_TP),
                getFunc = function () end,
                setFunc = function (value)
                    SpellCastBuffs.AddToCustomList(Settings.PriorityDebuffTable, value)
                    LUIE_Priority_Debuffs_List:UpdateChoices(GenerateCustomList(Settings.PriorityDebuffTable))
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Priority Debuffs List (Remove)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DEBUFF_REMLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DEBUFF_REMLIST_TP),
                choices = PromDebuffs,
                choicesValues = PromDebuffsValues,
                scrollable = true,
                sort = "name-up",
                getFunc = function ()
                    LUIE_Priority_Debuffs_List:UpdateChoices(GenerateCustomList(Settings.PriorityDebuffTable))
                end,
                setFunc = function (value)
                    SpellCastBuffs.RemoveFromCustomList(Settings.PriorityDebuffTable, value)
                    LUIE_Priority_Debuffs_List:UpdateChoices(GenerateCustomList(Settings.PriorityDebuffTable))
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
                reference = "LUIE_Priority_Debuffs_List",
            },
            {
                -- Clear Priority Debuffs
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_DEBUFFS),
                tooltip = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_DEBUFFS_TP),
                func = function ()
                    ZO_Dialogs_ShowDialog("LUIE_CLEAR_PRIORITY_DEBUFFS")
                end,
                width = "half",
            },
        },
    }

    -- Buffs&Debuffs - Prominent Buffs & Debuffs Options Submenu
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_BUFF_PROM_HEADER),
        controls =
        {
            {
                -- Prominent Buffs & Debuffs Description
                type = "description",
                text = GetString(LUIE_STRING_LAM_BUFF_PROM_DESCRIPTION),
            },
            {
                -- Prominent Buffs Label Toggle
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_PROM_LABEL),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_LABEL_TP),
                getFunc = function ()
                    return Settings.ProminentLabel
                end,
                setFunc = function (value)
                    Settings.ProminentLabel = value
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.ProminentLabel,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Prominent Buffs Label Font Face
                type = "dropdown",
                scrollable = true,
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_FONTFACE)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTFACE_TP),
                choices = FontsList,
                sort = "name-up",
                getFunc = function ()
                    return Settings.ProminentLabelFontFace
                end,
                setFunc = function (var)
                    Settings.ProminentLabelFontFace = var
                    SpellCastBuffs.ApplyFont()
                end,
                width = "full",
                default = Defaults.ProminentLabelFontFace,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentLabel)
                end,
            },
            {
                -- Prominent Buffs Label Font Size
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSIZE)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSIZE_TP),
                min = 10,
                max = 30,
                step = 1,
                getFunc = function ()
                    return Settings.ProminentLabelFontSize
                end,
                setFunc = function (value)
                    Settings.ProminentLabelFontSize = value
                    SpellCastBuffs.ApplyFont()
                end,
                width = "full",
                default = Defaults.ProminentLabelFontSize,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentLabel)
                end,
            },
            {
                -- Prominent Buffs Label Font Style
                type = "dropdown",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSTYLE)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSTYLE_TP),
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
                    return Settings.ProminentLabelFontStyle
                end,
                setFunc = function (var)
                    Settings.ProminentLabelFontStyle = var
                    SpellCastBuffs.ApplyFont()
                end,
                width = "full",
                default = Defaults.ProminentLabelFontStyle,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentLabel)
                end,
            },
            {
                -- Prominent Buffs Progress Bar
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR_TP),
                getFunc = function ()
                    return Settings.ProminentProgress
                end,
                setFunc = function (value)
                    Settings.ProminentProgress = value
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.ProminentProgress,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Prominent Buffs Progress Bar Texture
                type = "dropdown",
                scrollable = true,
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR_TEXTURE)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR_TEXTURE_TP),
                choices = StatusbarTexturesList,
                sort = "name-up",
                getFunc = function ()
                    return Settings.ProminentProgressTexture
                end,
                setFunc = function (value)
                    Settings.ProminentProgressTexture = value
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.ProminentProgressTexture,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
                end,
            },
            {
                -- Prominent Buffs Gradient Color 1
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF1)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF1_TP),
                getFunc = function ()
                    return unpack(Settings.ProminentProgressBuffC1)
                end,
                setFunc = function (r, g, b, a)
                    Settings.ProminentProgressBuffC1 = { r, g, b, a }
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default =
                {
                    r = Settings.ProminentProgressBuffC1[1],
                    g = Settings.ProminentProgressBuffC1[2],
                    b = Settings.ProminentProgressBuffC1[3],
                },
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
                end,
            },
            {
                -- Prominent Buffs Gradient Color 2
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF2)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF2_TP),
                getFunc = function ()
                    return unpack(Settings.ProminentProgressBuffC2)
                end,
                setFunc = function (r, g, b, a)
                    Settings.ProminentProgressBuffC2 = { r, g, b, a }
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default =
                {
                    r = Settings.ProminentProgressBuffC2[1],
                    g = Settings.ProminentProgressBuffC2[2],
                    b = Settings.ProminentProgressBuffC2[3],
                },
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
                end,
            },

            {
                -- Prominent Buffs Gradient Color 1 (Priority)
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY1)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY1_TP),
                getFunc = function ()
                    return unpack(Settings.ProminentProgressBuffPriorityC1)
                end,
                setFunc = function (r, g, b, a)
                    Settings.ProminentProgressBuffPriorityC1 = { r, g, b, a }
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default =
                {
                    r = Settings.ProminentProgressBuffPriorityC1[1],
                    g = Settings.ProminentProgressBuffPriorityC1[2],
                    b = Settings.ProminentProgressBuffPriorityC1[3],
                },
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
                end,
            },
            {
                -- Prominent Buffs Gradient Color 2 (Priority)
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY2)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY2_TP),
                getFunc = function ()
                    return unpack(Settings.ProminentProgressBuffPriorityC2)
                end,
                setFunc = function (r, g, b, a)
                    Settings.ProminentProgressBuffPriorityC2 = { r, g, b, a }
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default =
                {
                    r = Settings.ProminentProgressBuffPriorityC2[1],
                    g = Settings.ProminentProgressBuffPriorityC2[2],
                    b = Settings.ProminentProgressBuffPriorityC2[3],
                },
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
                end,
            },

            {
                -- Prominent Debuffs Gradient Color 1
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF1)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF1_TP),
                getFunc = function ()
                    return unpack(Settings.ProminentProgressDebuffC1)
                end,
                setFunc = function (r, g, b, a)
                    Settings.ProminentProgressDebuffC1 = { r, g, b, a }
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default =
                {
                    r = Settings.ProminentProgressDebuffC1[1],
                    g = Settings.ProminentProgressDebuffC1[2],
                    b = Settings.ProminentProgressDebuffC1[3],
                },
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
                end,
            },
            {
                -- Prominent Debuffs Gradient Color 2
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF2)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF2_TP),
                getFunc = function ()
                    return unpack(Settings.ProminentProgressDebuffC2)
                end,
                setFunc = function (r, g, b, a)
                    Settings.ProminentProgressDebuffC2 = { r, g, b, a }
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default =
                {
                    r = Settings.ProminentProgressDebuffC2[1],
                    g = Settings.ProminentProgressDebuffC2[2],
                    b = Settings.ProminentProgressDebuffC2[3],
                },
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
                end,
            },

            {
                -- Prominent Debuffs Gradient Color 1 (Priority)
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY1)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY1_TP),
                getFunc = function ()
                    return unpack(Settings.ProminentProgressDebuffPriorityC1)
                end,
                setFunc = function (r, g, b, a)
                    Settings.ProminentProgressDebuffPriorityC1 = { r, g, b, a }
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default =
                {
                    r = Settings.ProminentProgressDebuffPriorityC1[1],
                    g = Settings.ProminentProgressDebuffPriorityC1[2],
                    b = Settings.ProminentProgressDebuffPriorityC1[3],
                },
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
                end,
            },
            {
                -- Prominent Debuffs Gradient Color 2 (Priority)
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY2)),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY2_TP),
                getFunc = function ()
                    return unpack(Settings.ProminentProgressDebuffPriorityC2)
                end,
                setFunc = function (r, g, b, a)
                    Settings.ProminentProgressDebuffPriorityC2 = { r, g, b, a }
                    SpellCastBuffs.Reset()
                end,
                width = "half",
                default =
                {
                    r = Settings.ProminentProgressDebuffPriorityC2[1],
                    g = Settings.ProminentProgressDebuffPriorityC2[2],
                    b = Settings.ProminentProgressDebuffPriorityC2[3],
                },
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
                end,
            },

            {
                -- Prominent Buffs Label/Progress Bar Direction
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFLABELDIRECTION),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFLABELDIRECTION_TP),
                choices = { "Right", "Left" },
                sort = "name-up",
                getFunc = function ()
                    return Settings.ProminentBuffLabelDirection
                end,
                setFunc = function (var)
                    Settings.ProminentBuffLabelDirection = var
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.ProminentBuffLabelDirection,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.ProminentLabel or Settings.ProminentProgress))
                end,
            },
            {
                -- Prominent Debuffs Label/Progress Bar Direction
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFLABELDIRECTION),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFLABELDIRECTION_TP),
                choices = { "Right", "Left" },
                sort = "name-up",
                getFunc = function ()
                    return Settings.ProminentDebuffLabelDirection
                end,
                setFunc = function (var)
                    Settings.ProminentDebuffLabelDirection = var
                    SpellCastBuffs.Reset()
                end,
                width = "full",
                default = Defaults.ProminentDebuffLabelDirection,
                disabled = function ()
                    return not (LUIE.SV.SpellCastBuff_Enable and (Settings.ProminentLabel or Settings.ProminentProgress))
                end,
            },
            {
                type = "divider",
            },
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_BUFF_PROM_DIALOGUE_DESCRIPT),
            },
            {
                -- Prominent Buffs List (Add)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFF_ADDLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFF_ADDLIST_TP),
                getFunc = function () end,
                setFunc = function (value)
                    SpellCastBuffs.AddToCustomList(Settings.PromBuffTable, value)
                    LUIE_Prominent_Buffs_List:UpdateChoices(GenerateCustomList(Settings.PromBuffTable))
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Prominent Buffs List (Remove)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFF_REMLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFF_REMLIST_TP),
                choices = PromBuffs,
                choicesValues = PromBuffsValues,
                scrollable = true,
                sort = "name-up",
                getFunc = function ()
                    LUIE_Prominent_Buffs_List:UpdateChoices(GenerateCustomList(Settings.PromBuffTable))
                end,
                setFunc = function (value)
                    SpellCastBuffs.RemoveFromCustomList(Settings.PromBuffTable, value)
                    LUIE_Prominent_Buffs_List:UpdateChoices(GenerateCustomList(Settings.PromBuffTable))
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
                reference = "LUIE_Prominent_Buffs_List",
            },
            {
                -- Clear Prominent Buffs
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_BUFFS),
                tooltip = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_BUFFS_TP),
                func = function ()
                    ZO_Dialogs_ShowDialog("LUIE_CLEAR_PROMINENT_BUFFS")
                end,
                width = "half",
            },
            {
                -- Prominent Debuffs List (Add)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFF_ADDLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFF_ADDLIST_TP),
                getFunc = function () end,
                setFunc = function (value)
                    SpellCastBuffs.AddToCustomList(Settings.PromDebuffTable, value)
                    LUIE_Prominent_Debuffs_List:UpdateChoices(GenerateCustomList(Settings.PromDebuffTable))
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Prominent Debuffs List (Remove)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFF_REMLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFF_REMLIST_TP),
                choices = PromDebuffs,
                choicesValues = PromDebuffsValues,
                scrollable = true,
                sort = "name-up",
                getFunc = function ()
                    LUIE_Prominent_Debuffs_List:UpdateChoices(GenerateCustomList(Settings.PromDebuffTable))
                end,
                setFunc = function (value)
                    SpellCastBuffs.RemoveFromCustomList(Settings.PromDebuffTable, value)
                    LUIE_Prominent_Debuffs_List:UpdateChoices(GenerateCustomList(Settings.PromDebuffTable))
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
                reference = "LUIE_Prominent_Debuffs_List",
            },
            {
                -- Clear Prominent Debuffs
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_DEBUFFS),
                tooltip = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_DEBUFFS_TP),
                func = function ()
                    ZO_Dialogs_ShowDialog("LUIE_CLEAR_PROMINENT_DEBUFFS")
                end,
                width = "half",
            },
        },
    }

    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_HEADER),
        controls =
        {
            {
                -- Buffs & Debuffs Blacklist Description
                type = "description",
                text = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT),
            },
            -- Add Minor Buffs
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_BUFF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_BUFF_TP),
                func = function ()
                    SpellCastBuffs.AddBulkToCustomList(Settings.BlacklistTable, BlacklistPresets.MinorBuffs)
                    LUIE_Blacklist:UpdateChoices(GenerateCustomList(Settings.BlacklistTable))
                end,
                width = "half",
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            -- Add Major Buffs
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_BUFF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_BUFF_TP),
                func = function ()
                    SpellCastBuffs.AddBulkToCustomList(Settings.BlacklistTable, BlacklistPresets.MajorBuffs)
                    LUIE_Blacklist:UpdateChoices(GenerateCustomList(Settings.BlacklistTable))
                end,
                width = "half",
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            -- Add Minor Debuffs
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_DEBUFF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_DEBUFF_TP),
                func = function ()
                    SpellCastBuffs.AddBulkToCustomList(Settings.BlacklistTable, BlacklistPresets.MinorDebuffs)
                    LUIE_Blacklist:UpdateChoices(GenerateCustomList(Settings.BlacklistTable))
                end,
                width = "half",
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            -- Add Major Debuffs
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_DEBUFF),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_DEBUFF_TP),
                func = function ()
                    SpellCastBuffs.AddBulkToCustomList(Settings.BlacklistTable, BlacklistPresets.MajorDebuffs)
                    LUIE_Blacklist:UpdateChoices(GenerateCustomList(Settings.BlacklistTable))
                end,
                width = "half",
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Clear Blacklist
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
                tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
                func = function ()
                    ZO_Dialogs_ShowDialog("LUIE_CLEAR_ABILITY_BLACKLIST")
                end,
                width = "half",
            },
            {
                -- Buffs & Debuffs Blacklist (Add)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
                getFunc = function () end,
                setFunc = function (value)
                    SpellCastBuffs.AddToCustomList(Settings.BlacklistTable, value)
                    LUIE_Blacklist:UpdateChoices(GenerateCustomList(Settings.BlacklistTable))
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
            },
            {
                -- Buffs & Debuffs Blacklist (Remove)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST_TP),
                choices = Blacklist,
                choicesValues = BlacklistValues,
                scrollable = true,
                sort = "name-up",
                getFunc = function ()
                    LUIE_Blacklist:UpdateChoices(GenerateCustomList(Settings.BlacklistTable))
                end,
                setFunc = function (value)
                    SpellCastBuffs.RemoveFromCustomList(Settings.BlacklistTable, value)
                    LUIE_Blacklist:UpdateChoices(GenerateCustomList(Settings.BlacklistTable))
                end,
                disabled = function ()
                    return not LUIE.SV.SpellCastBuff_Enable
                end,
                reference = "LUIE_Blacklist",
            },
        },
    }

    -- Debug Options
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "header",
        name = "Debug Options",
        width = "full",
    }

    -- Debug
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "checkbox",
        name = "Show AbilityId on Buffs & Debuffs",
        tooltip = "Toggle the display of AbilityId on buffs and debuffs - useful for adding auras to Prominent Buffs & Debuffs or the Aura Blacklist.",
        getFunc = function ()
            return Settings.ShowDebugAbilityId
        end,
        setFunc = function (value)
            Settings.ShowDebugAbilityId = value
            SpellCastBuffs.Reset()
        end,
        width = "full",
        default = Defaults.ShowDebugAbilityId,
        disabled = function ()
            return not LUIE.SV.SpellCastBuff_Enable
        end,
    }

    -- Debug
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "checkbox",
        name = "Show Debug for Combat Events",
        tooltip = "Display debug information for combat events - used for development.",
        getFunc = function ()
            return Settings.ShowDebugCombat
        end,
        setFunc = function (value)
            Settings.ShowDebugCombat = value
            SpellCastBuffs.RegisterDebugEvents()
        end,
        width = "full",
        default = Defaults.ShowDebugCombat,
        disabled = function ()
            return not LUIE.SV.SpellCastBuff_Enable
        end,
    }

    -- Debug
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "checkbox",
        name = "Show Debug for Effect Change Events",
        tooltip = "Display debug information for effect change events - used for development.",
        getFunc = function ()
            return Settings.ShowDebugEffect
        end,
        setFunc = function (value)
            Settings.ShowDebugEffect = value
            SpellCastBuffs.RegisterDebugEvents()
        end,
        width = "full",
        default = Defaults.ShowDebugEffect,
        disabled = function ()
            return not LUIE.SV.SpellCastBuff_Enable
        end,
    }

    -- Debug
    optionsDataBuffsDebuffs[#optionsDataBuffsDebuffs + 1] =
    {
        type = "checkbox",
        name = "Filter Debug Events & Effects",
        tooltip = "Filter out events and effects that have already been processed - used for development.",
        getFunc = function ()
            return Settings.ShowDebugFilter
        end,
        setFunc = function (value)
            Settings.ShowDebugFilter = value
        end,
        width = "full",
        default = Defaults.ShowDebugFilter,
        disabled = function ()
            return not LUIE.SV.SpellCastBuff_Enable
        end,
    }

    -- Register the settings panel
    if LUIE.SV.SpellCastBuff_Enable then
        LAM:RegisterAddonPanel(LUIE.name .. "BuffsAndDebuffsOptions", panelDataBuffsDebuffs)
        LAM:RegisterOptionControls(LUIE.name .. "BuffsAndDebuffsOptions", optionsDataBuffsDebuffs)
    end
end
