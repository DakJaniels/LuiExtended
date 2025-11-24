-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Load Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs
local BlacklistPresets = LuiData.Data.AbilityBlacklistPresets

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

-- Create a list of abilityId's / abilityName's to use for Blacklist (LHAS version)
local function GenerateCustomListLHAS(input)
    local items = {}
    local counter = 0
    for id in pairs(input) do
        counter = counter + 1
        local name
        -- If the input is a numeric value then we can pull this abilityId's info.
        if type(id) == "number" then
            name = zo_iconFormat(GetAbilityIcon(id), 16, 16) .. " [" .. id .. "] " .. zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
            -- If the input is not numeric then add this as a name only.
        else
            name = id
        end
        items[counter] = { name = name, data = id }
    end
    return items
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
            if LHAS and LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
        end,
    },
    [2] =
    { -- Clear Prominent Buffs
        identifier = "LUIE_CLEAR_PROMINENT_BUFFS",
        title = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_BUFFS),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG_LIST), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
        callback = function (_)
            SpellCastBuffs.ClearCustomList(SpellCastBuffs.SV.PromBuffTable)
            if LHAS and LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
        end,
    },
    [3] =
    { -- Clear Prominent Debuffs
        identifier = "LUIE_CLEAR_PROMINENT_DEBUFFS",
        title = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_DEBUFFS),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG_LIST), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
        callback = function (_)
            SpellCastBuffs.ClearCustomList(SpellCastBuffs.SV.PromDebuffTable)
            if LHAS and LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
        end,
    },

    [4] =
    { -- Clear Priority Buffs
        identifier = "LUIE_CLEAR_PRIORITY_BUFFS",
        title = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_BUFFS),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG_LIST), GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS)),
        callback = function (_)
            SpellCastBuffs.ClearCustomList(SpellCastBuffs.SV.PriorityBuffTable)
            if LHAS and LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
        end,
    },
    [5] =
    { -- Clear Priority Debuffs
        identifier = "LUIE_CLEAR_PRIORITY_DEBUFFS",
        title = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_DEBUFFS),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG_LIST), GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS)),
        callback = function (_)
            SpellCastBuffs.ClearCustomList(SpellCastBuffs.SV.PriorityDebuffTable)
            if LHAS and LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
        end,
    },
}

local function loadDialogButtons()
    for i = 1, #dialogs do
        local dialog = dialogs[i]
        LUIE.RegisterDialogueButton(dialog.identifier, dialog.title, dialog.text, dialog.callback)
    end
end

function SpellCastBuffs.CreateConsoleSettings()
    local Defaults = SpellCastBuffs.Defaults
    local Settings = SpellCastBuffs.SV

    -- Load Dialog Buttons
    loadDialogButtons()

    -- Register custom blacklist/whitelist management dialogs
    -- Blacklist Dialog
    LUIE.RegisterBlacklistDialog(
        "LUIE_MANAGE_BLACKLIST",
        GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST),
        function ()
            return GenerateCustomListLHAS(Settings.BlacklistTable)
        end,
        function (itemData)
            SpellCastBuffs.RemoveFromCustomList(Settings.BlacklistTable, itemData)
        end,
        function (text)
            SpellCastBuffs.AddToCustomList(Settings.BlacklistTable, text)
        end,
        function ()
            SpellCastBuffs.ClearCustomList(Settings.BlacklistTable)
        end
    )

    -- Priority Buffs Dialog
    LUIE.RegisterBlacklistDialog(
        "LUIE_MANAGE_PRIORITY_BUFFS",
        GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS),
        function ()
            return GenerateCustomListLHAS(Settings.PriorityBuffTable)
        end,
        function (itemData)
            SpellCastBuffs.RemoveFromCustomList(Settings.PriorityBuffTable, itemData)
        end,
        function (text)
            SpellCastBuffs.AddToCustomList(Settings.PriorityBuffTable, text)
        end,
        function ()
            SpellCastBuffs.ClearCustomList(Settings.PriorityBuffTable)
        end
    )

    -- Priority Debuffs Dialog
    LUIE.RegisterBlacklistDialog(
        "LUIE_MANAGE_PRIORITY_DEBUFFS",
        GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS),
        function ()
            return GenerateCustomListLHAS(Settings.PriorityDebuffTable)
        end,
        function (itemData)
            SpellCastBuffs.RemoveFromCustomList(Settings.PriorityDebuffTable, itemData)
        end,
        function (text)
            SpellCastBuffs.AddToCustomList(Settings.PriorityDebuffTable, text)
        end,
        function ()
            SpellCastBuffs.ClearCustomList(Settings.PriorityDebuffTable)
        end
    )

    -- Prominent Buffs Dialog
    LUIE.RegisterBlacklistDialog(
        "LUIE_MANAGE_PROMINENT_BUFFS",
        GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS),
        function ()
            return GenerateCustomListLHAS(Settings.PromBuffTable)
        end,
        function (itemData)
            SpellCastBuffs.RemoveFromCustomList(Settings.PromBuffTable, itemData)
        end,
        function (text)
            SpellCastBuffs.AddToCustomList(Settings.PromBuffTable, text)
        end,
        function ()
            SpellCastBuffs.ClearCustomList(Settings.PromBuffTable)
        end
    )

    -- Prominent Debuffs Dialog
    LUIE.RegisterBlacklistDialog(
        "LUIE_MANAGE_PROMINENT_DEBUFFS",
        GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS),
        function ()
            return GenerateCustomListLHAS(Settings.PromDebuffTable)
        end,
        function (itemData)
            SpellCastBuffs.RemoveFromCustomList(Settings.PromDebuffTable, itemData)
        end,
        function (text)
            SpellCastBuffs.AddToCustomList(Settings.PromDebuffTable, text)
        end,
        function ()
            SpellCastBuffs.ClearCustomList(Settings.PromDebuffTable)
        end
    )

    -- Register the settings panel
    if not LUIE.SV.SpellCastBuff_Enable then
        return
    end

    local panel = LHAS:AddAddon(zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_BUFFSDEBUFFS)),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset all SpellCastBuffs settings to defaults
                                        SpellCastBuffs.ResetTlwPosition()
                                    end,
                                })

    -- Buffs & Debuffs Description
    panel:AddSetting(SettingsAPI.CreateDescriptionOption(
        {
            text = GetString(LUIE_STRING_LAM_BUFFS_DESCRIPTION),
        }))

    -- ReloadUI Button
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_RELOADUI),
            tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
            clickHandler = function ()
                ReloadUI("ingame")
            end,
            buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
        }))

    -- Buffs Window Unlock
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_UNLOCKWINDOW),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_UNLOCKWINDOW_TP),
            getFunc = function ()
                return g_BuffsMovingEnabled
            end,
            setFunc = function (value)
                g_BuffsMovingEnabled = value
                -- Ensure lockPositionToUnitFrames is properly initialized when unlocking frames
                if value and SpellCastBuffs.SV.lockPositionToUnitFrames == nil then
                    SpellCastBuffs.SV.lockPositionToUnitFrames = false
                end
                SpellCastBuffs.SetMovingState(value)
            end,
            default = false,
        }))

    -- Buffs Window Reset position
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_RESETPOSITION_TP),
            clickHandler = SpellCastBuffs.ResetTlwPosition,
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
        }))

    -- Hard-Lock Position to Unit Frames
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_HARDLOCK),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_HARDLOCK_TP),
            getFunc = function ()
                return Settings.lockPositionToUnitFrames
            end,
            setFunc = function (value)
                Settings.lockPositionToUnitFrames = value
            end,
            default = Defaults.lockPositionToUnitFrames,
        }))

    -- Buffs&Debuffs - Position and Display Options Submenu
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_HEADER_POSITION),
        }))

    -- Hide OakenSoul
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_MISC_HIDE_OAKENSOUL),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_HIDE_OAKENSOUL_TP),
            getFunc = function ()
                return Settings.HideOakenSoul
            end,
            setFunc = function (value)
                Settings.HideOakenSoul = value
            end,
            default = Defaults.HideOakenSoul,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERBUFF)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERBUFF_TP),
            getFunc = function ()
                return not Settings.HidePlayerBuffs
            end,
            setFunc = function (value)
                Settings.HidePlayerBuffs = not value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.HidePlayerBuffs,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERDEBUFF)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERDEBUFF_TP),
            getFunc = function ()
                return not Settings.HidePlayerDebuffs
            end,
            setFunc = function (value)
                Settings.HidePlayerDebuffs = not value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.HidePlayerDebuffs,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETBUFF)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETBUFF_TP),
            getFunc = function ()
                return not Settings.HideTargetBuffs
            end,
            setFunc = function (value)
                Settings.HideTargetBuffs = not value
            end,
            default = not Defaults.HideTargetBuffs,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETDEBUFF)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETDEBUFF_TP),
            getFunc = function ()
                return not Settings.HideTargetDebuffs
            end,
            setFunc = function (value)
                Settings.HideTargetDebuffs = not value
            end,
            default = not Defaults.HideTargetDebuffs,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWGROUNDBUFFDEBUFF)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWGROUNDBUFFDEBUFF_TP),
            getFunc = function ()
                return not Settings.HideGroundEffects
            end,
            setFunc = function (value)
                Settings.HideGroundEffects = not value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Settings.HideGroundEffects,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Ground Damage Auras
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOW_GROUND_DAMAGE)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOW_GROUND_DAMAGE_TP),
            getFunc = function ()
                return Settings.GroundDamageAura
            end,
            setFunc = function (value)
                Settings.GroundDamageAura = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Settings.GroundDamageAura,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Add Extra
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_ADD_EXTRA_BUFFS)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_ADD_EXTRA_BUFFS_TP),
            getFunc = function ()
                return Settings.ExtraBuffs
            end,
            setFunc = function (value)
                Settings.ExtraBuffs = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Settings.ExtraBuffs,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Extra Expanded
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_EXTEND_EXTRA)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_EXTEND_EXTRA_TP),
            getFunc = function ()
                return Settings.ExtraExpanded
            end,
            setFunc = function (value)
                Settings.ExtraExpanded = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Settings.ExtraExpanded,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ExtraBuffs)
            end,
        }))

    -- Reduce
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_REDUCE)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_REDUCE_TP),
            getFunc = function ()
                return Settings.HideReduce
            end,
            setFunc = function (value)
                Settings.HideReduce = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Settings.HideReduce,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Always Show Shared Debuffs
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = Defaults.ShowSharedEffects,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Always Show Major/Minor Debuffs
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = Defaults.ShowSharedMajorMinor,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Buffs&Debuffs - Long & Short Term Effects Filters
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONG_SHORT_HEADER),
        }))

    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_SELF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_SELF_TP),
            getFunc = function ()
                return Settings.ShortTermEffects_Player
            end,
            setFunc = function (value)
                Settings.ShortTermEffects_Player = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShortTermEffects_Player,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_TARGET_TP),
            getFunc = function ()
                return Settings.ShortTermEffects_Target
            end,
            setFunc = function (value)
                Settings.ShortTermEffects_Target = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShortTermEffects_Target,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SELF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SELF_TP),
            getFunc = function ()
                return Settings.LongTermEffects_Player
            end,
            setFunc = function (value)
                Settings.LongTermEffects_Player = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.LongTermEffects_Player,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Separate control for player effects
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SEPCTRL)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SEPCTRL_TP),
            getFunc = function ()
                return Settings.LongTermEffectsSeparate
            end,
            setFunc = function (value)
                Settings.LongTermEffectsSeparate = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.LongTermEffectsSeparate,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.LongTermEffects_Player)
            end,
        }))

    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_TARGET_TP),
            getFunc = function ()
                return Settings.LongTermEffects_Target
            end,
            setFunc = function (value)
                Settings.LongTermEffects_Target = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.LongTermEffects_Target,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Misc Header
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_MISC_HEADER),
        }))

    -- Show Rezz Immunity Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWREZZ),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWREZZ_TP),
            getFunc = function ()
                return Settings.ShowResurrectionImmunity
            end,
            setFunc = function (value)
                Settings.ShowResurrectionImmunity = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShowResurrectionImmunity,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Show Recall Cooldown Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWRECALL),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWRECALL_TP),
            getFunc = function ()
                return Settings.ShowRecall
            end,
            setFunc = function (value)
                Settings.ShowRecall = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShowRecall,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Show Werewolf Timer Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = Defaults.ShowWerewolf,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Short Term - Set ICD - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SETICDPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SETICDPLAYER_TP),
            getFunc = function ()
                return not Settings.IgnoreSetICDPlayer
            end,
            setFunc = function (value)
                Settings.IgnoreSetICDPlayer = not value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreSetICDPlayer,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Short Term - Ability ICD - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ABILITYICDPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ABILITYICDPLAYER_TP),
            getFunc = function ()
                return not Settings.IgnoreAbilityICDPlayer
            end,
            setFunc = function (value)
                Settings.IgnoreAbilityICDPlayer = not value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreAbilityICDPlayer,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Show Block Player Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWBLOCKPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWBLOCKPLAYER_TP),
            getFunc = function ()
                return Settings.ShowBlockPlayer
            end,
            setFunc = function (value)
                Settings.ShowBlockPlayer = value
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShowBlockPlayer,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Show Block Target Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = Defaults.ShowBlockTarget,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Show Stealth Player Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHPLAYER_TP),
            getFunc = function ()
                return Settings.StealthStatePlayer
            end,
            setFunc = function (value)
                Settings.StealthStatePlayer = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.StealthStatePlayer,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Show Stealth Target Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHTARGET_TP),
            getFunc = function ()
                return Settings.StealthStateTarget
            end,
            setFunc = function (value)
                Settings.StealthStateTarget = value
                SpellCastBuffs.ReloadEffects("reticleover")
            end,
            default = Defaults.StealthStateTarget,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Show Disguise Player Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISEPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISEPLAYER_TP),
            getFunc = function ()
                return Settings.DisguiseStatePlayer
            end,
            setFunc = function (value)
                Settings.DisguiseStatePlayer = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.DisguiseStatePlayer,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Show Disguise Target Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISETARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISETARGET_TP),
            getFunc = function ()
                return Settings.DisguiseStateTarget
            end,
            setFunc = function (value)
                Settings.DisguiseStateTarget = value
                SpellCastBuffs.ReloadEffects("reticleover")
            end,
            default = Defaults.DisguiseStateTarget,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Long Term Header
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_HEADER),
        }))

    -- Long Term - Disguises
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_DISGUISE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_DISGUISE_TP),
            getFunc = function ()
                return not Settings.IgnoreDisguise
            end,
            setFunc = function (value)
                Settings.IgnoreDisguise = not value
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.IgnoreDisguise,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Assistants
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ASSISTANT),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ASSISTANT_TP),
            getFunc = function ()
                return not Settings.IgnoreAssistant
            end,
            setFunc = function (value)
                Settings.IgnoreAssistant = not value
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.IgnoreAssistant,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Pets
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET_TP),
            getFunc = function ()
                return not Settings.IgnorePet
            end,
            setFunc = function (value)
                Settings.IgnorePet = not value
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.IgnorePet,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Use Generic Pet Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET_ICON)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET_ICON_TP),
            getFunc = function ()
                return Settings.PetDetail
            end,
            setFunc = function (value)
                Settings.PetDetail = value
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.PetDetail,
            disabled = function ()
                return Settings.IgnorePet
            end,
        }))

    -- Long Term - Mounts (Player)
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_PLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_PLAYER_TP),
            getFunc = function ()
                return not Settings.IgnoreMountPlayer
            end,
            setFunc = function (value)
                Settings.IgnoreMountPlayer = not value
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.IgnoreMountPlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Use Generic Mount Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_ICON)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_ICON_TP),
            getFunc = function ()
                return Settings.MountDetail
            end,
            setFunc = function (value)
                Settings.MountDetail = value
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.MountDetail,
            disabled = function ()
                return Settings.IgnoreMountPlayer
            end,
        }))

    -- Long Term - Mundus - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreMundusPlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Mundus - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreMundusTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Food & Drink - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreFoodPlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Food & Drink - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreFoodTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Experience - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreExperiencePlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Experience - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreExperienceTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Alliance XP - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreAllianceXPPlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Alliance XP - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreAllianceXPTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Vamp Stage - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreVampPlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Vamp Stage - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreVampTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Lycanthrophy - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreLycanPlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Lycanthrophy - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreLycanTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Bite Disease - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreDiseasePlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Bite Disease - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreDiseaseTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Bite Timers - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreBitePlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Bite Timers - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreBiteTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Battle Spirit - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreBattleSpiritPlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Battle Spirit - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreBattleSpiritTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Cyrodiil - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreCyrodiilPlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Cyrodiil - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreCyrodiilTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - ESO Plus - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreEsoPlusPlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - ESO Plus - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreEsoPlusTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Soul Summons - Player
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreSoulSummonsPlayer,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Long Term - Soul Summons - Target
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
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
            default = not Defaults.IgnoreSoulSummonsTarget,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }))

    -- Buffs&Debuffs - Icon Options Submenu
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_ICON_HEADER),
        }))

    -- Buff Icon Size
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
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
            default = Defaults.IconSize,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Buff Show Remaining Time Label
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_SHOWREMAINTIMELABEL),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWREMAINTIMELABEL_TP),
            getFunc = function ()
                return Settings.RemainingText
            end,
            setFunc = function (value)
                Settings.RemainingText = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.RemainingText,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Buff Label Position
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_CI_SHARED_POSITION)),
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
            default = Defaults.LabelPosition,
            disabled = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }))

    -- Buff Label Font
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_FONT)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_FONT_TP),
            choices = SettingsAPI.GetFontsList(),
            getFunc = function ()
                return Settings.BuffFontFace
            end,
            setFunc = function (value)
                Settings.BuffFontFace = value
                SpellCastBuffs.ApplyFont()
            end,
            default = Defaults.BuffFontFace,
            disabled = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }))

    -- Buff Font Size
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_FONT_SIZE)),
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
            default = Defaults.BuffFontSize,
            disabled = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }))

    -- Buff Font Style
    panel:AddSetting(SettingsAPI.CreateFontStyleDropdown(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_FONT_STYLE)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_FONTSTYLE_TP),
            getFunc = function ()
                return Settings.BuffFontStyle
            end,
            setFunc = function (value)
                Settings.BuffFontStyle = value
                SpellCastBuffs.ApplyFont()
            end,
            default = Defaults.BuffFontStyle,
            disabled = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }))

    -- Buff Colored Label
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_CI_POTION_COLOR)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LABELCOLOR_TP),
            getFunc = function ()
                return Settings.RemainingTextColoured
            end,
            setFunc = function (value)
                Settings.RemainingTextColoured = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.RemainingTextColoured,
            disabled = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }))

    -- Buff Show Seconds Fractions
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
            getFunc = function ()
                return Settings.RemainingTextMillis
            end,
            setFunc = function (value)
                Settings.RemainingTextMillis = value
            end,
            default = Defaults.RemainingTextMillis,
            disabled = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }))

    -- Buff Glow Icon Border
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_GLOWICONBORDER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_GLOWICONBORDER_TP),
            getFunc = function ()
                return Settings.GlowIcons
            end,
            setFunc = function (value)
                Settings.GlowIcons = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.GlowIcons,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Buff Show Border Cooldown
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_SHOWBORDERCOOLDOWN),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWBORDERCOOLDOWN_TP),
            getFunc = function ()
                return Settings.RemainingCooldown
            end,
            setFunc = function (value)
                Settings.RemainingCooldown = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.RemainingCooldown,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Buff Fade Expiring Icon
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_FADEEXPIREICON),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_FADEEXPIREICON_TP),
            getFunc = function ()
                return Settings.FadeOutIcons
            end,
            setFunc = function (value)
                Settings.FadeOutIcons = value
            end,
            default = Defaults.FadeOutIcons,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Icon Normalization Options
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_NORMALIZE_HEADER),
        }))

    -- Use Generic Icon for CC Type
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_TP),
            getFunc = function ()
                return Settings.UseDefaultIcon
            end,
            setFunc = function (newValue)
                Settings.UseDefaultIcon = newValue
            end,
            default = Defaults.UseDefaultIcon,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Generic Icon Options
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS)),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS_TP),
            choices = globalIconOptions,
            getFunc = function ()
                return globalIconOptions[Settings.DefaultIconOptions]
            end,
            setFunc = function (combobox, value, item)
                Settings.DefaultIconOptions = globalIconOptionsKeys[value]
            end,
            default = globalIconOptions[Defaults.DefaultIconOptions],
            disabled = function ()
                return not Settings.UseDefaultIcon
            end,
        }))

    -- Buffs&Debuffs - Color Options Submenu
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER),
        }))

    -- Basic Color Options
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER_BASIC),
        }))

    -- buff
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_BUFF),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_BUFF_TP),
        function ()
            return unpack(Settings.colors.buff)
        end,
        function (r, g, b, a)
            Settings.colors.buff = { r, g, b, a }
        end,
        Defaults.colors.buff
    ))

    -- debuff
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_DEBUFF),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_DEBUFF_TP),
        function ()
            return unpack(Settings.colors.debuff)
        end,
        function (r, g, b, a)
            Settings.colors.debuff = { r, g, b, a }
        end,
        Defaults.colors.debuff
    ))

    -- prioritybuff
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYBUFF),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYBUFF_TP),
        function ()
            return unpack(Settings.colors.prioritybuff)
        end,
        function (r, g, b, a)
            Settings.colors.prioritybuff = { r, g, b, a }
        end,
        Defaults.colors.prioritybuff
    ))

    -- prioritydebuff
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYDEBUFF),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYDEBUFF_TP),
        function ()
            return unpack(Settings.colors.prioritydebuff)
        end,
        function (r, g, b, a)
            Settings.colors.prioritydebuff = { r, g, b, a }
        end,
        Defaults.colors.prioritydebuff
    ))

    -- Unbreakable & Cosmetic Header
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER_UNBREAKABLE),
        }))

    -- Unbreakable Toggle
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE_TOGGLE_TP),
            getFunc = function ()
                return Settings.ColorUnbreakable
            end,
            setFunc = function (value)
                Settings.ColorUnbreakable = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ColorUnbreakable,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- unbreakable
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE)),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE_TP),
        function ()
            return unpack(Settings.colors.unbreakable)
        end,
        function (r, g, b, a)
            Settings.colors.unbreakable = { r, g, b, a }
        end,
        Defaults.colors.unbreakable,
        nil,
        function ()
            return not Settings.ColorUnbreakable
        end
    ))

    -- Cosmetic Toggle
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC_TOGGLE_TP),
            getFunc = function ()
                return Settings.ColorCosmetic
            end,
            setFunc = function (value)
                Settings.ColorCosmetic = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ColorCosmetic,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- cosmetic
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC)),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC_TP),
        function ()
            return unpack(Settings.colors.cosmetic)
        end,
        function (r, g, b, a)
            Settings.colors.cosmetic = { r, g, b, a }
        end,
        Defaults.colors.cosmetic,
        nil,
        function ()
            return not Settings.ColorCosmetic
        end
    ))

    -- Crowd Control Header
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER_CROWD_CONTROL),
        }))

    -- CC Toggle
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_COLOR_BY_CC),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_BY_CC_TP),
            getFunc = function ()
                return Settings.ColorCC
            end,
            setFunc = function (value)
                Settings.ColorCC = value
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ColorCC,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- nocc
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_NOCC),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_NOCC_TP),
        function ()
            return unpack(Settings.colors.nocc)
        end,
        function (r, g, b, a)
            Settings.colors.nocc = { r, g, b, a }
        end,
        Defaults.colors.nocc,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- stun
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_STUN),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_STUN_TP),
        function ()
            return unpack(Settings.colors.stun)
        end,
        function (r, g, b, a)
            Settings.colors.stun = { r, g, b, a }
        end,
        Defaults.colors.stun,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- knockback
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_KNOCKBACK),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_KNOCKBACK_TP),
        function ()
            return unpack(Settings.colors.knockback)
        end,
        function (r, g, b, a)
            Settings.colors.knockback = { r, g, b, a }
        end,
        Defaults.colors.knockback,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- levitate
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_LEVITATE),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_LEVITATE_TP),
        function ()
            return unpack(Settings.colors.levitate)
        end,
        function (r, g, b, a)
            Settings.colors.levitate = { r, g, b, a }
        end,
        Defaults.colors.levitate,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- disorient
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_DISORIENT),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_DISORIENT_TP),
        function ()
            return unpack(Settings.colors.disorient)
        end,
        function (r, g, b, a)
            Settings.colors.disorient = { r, g, b, a }
        end,
        Defaults.colors.disorient,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- fear
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_FEAR),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_FEAR_TP),
        function ()
            return unpack(Settings.colors.fear)
        end,
        function (r, g, b, a)
            Settings.colors.fear = { r, g, b, a }
        end,
        Defaults.colors.fear,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- charm
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_CHARM),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_CHARM_TP),
        function ()
            return unpack(Settings.colors.charm)
        end,
        function (r, g, b, a)
            Settings.colors.charm = { r, g, b, a }
        end,
        Defaults.colors.charm,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- stagger
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_STAGGER),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_STAGGER_TP),
        function ()
            return unpack(Settings.colors.stagger)
        end,
        function (r, g, b, a)
            Settings.colors.stagger = { r, g, b, a }
        end,
        Defaults.colors.stagger,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- silence
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_SILENCE),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_SILENCE_TP),
        function ()
            return unpack(Settings.colors.silence)
        end,
        function (r, g, b, a)
            Settings.colors.silence = { r, g, b, a }
        end,
        Defaults.colors.silence,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- snare
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_SNARE),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_SNARE_TP),
        function ()
            return unpack(Settings.colors.snare)
        end,
        function (r, g, b, a)
            Settings.colors.snare = { r, g, b, a }
        end,
        Defaults.colors.snare,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- root
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_BUFF_COLOR_ROOT),
        GetString(LUIE_STRING_LAM_BUFF_COLOR_ROOT_TP),
        function ()
            return unpack(Settings.colors.root)
        end,
        function (r, g, b, a)
            Settings.colors.root = { r, g, b, a }
        end,
        Defaults.colors.root,
        nil,
        function ()
            return not Settings.ColorCC
        end
    ))

    -- Buffs&Debuffs - Alignment & Sorting Options Submenu
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_SORTING_HEADER),
        }))

    -- Buffs/Debuffs Alignment & Sorting
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_SORTING_NORMAL_HEADER),
        }))

    -- Buff Alignment (BuffsPlayer)
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.AlignmentBuffsPlayer,
        }))

    -- Buff Sort Direction (BuffsPlayer)
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.SortBuffsPlayer,
        }))

    -- Buff Alignment (DebuffsPlayer)
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.AlignmentDebuffsPlayer,
        }))

    -- Buff Sort Direction (DebuffsPlayer)
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.SortDebuffsPlayer,
        }))

    -- Buff Alignment (BuffsTarget)
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.AlignmentBuffsTarget,
        }))

    -- Buff Sort Direction (BuffsTarget)
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.SortBuffsTarget,
        }))

    -- Buff Alignment (DebuffsTarget)
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.AlignmentDebuffsTarget,
        }))

    -- Buff Sort Direction (DebuffsTarget)
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.SortDebuffsTarget,
        }))

    -- Unanchored Player / Target Buff Options
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_SORTING_UNANCHORED_HEADER),
        }))

    panel:AddSetting(SettingsAPI.CreateDescriptionOption(
        {
            text = GetString(LUIE_STRING_LAM_BUFF_SORTING_UNANCHORED_DESCRIPTION),
        }))

    -- Buff Width - Player Buffs
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
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
            default = Defaults.WidthPlayerBuffs,
            disabled = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }))

    -- Buff Stack Direction - Player Buffs
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.StackPlayerBuffs,
            disabled = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }))

    -- Buff Width - Player Debuffs
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
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
            default = Defaults.WidthPlayerDebuffs,
            disabled = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }))

    -- Buff Stack Direction - Player Debuffs
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.StackPlayerDebuffs,
            disabled = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }))

    -- Buff Width - Target Buffs
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
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
            default = Defaults.WidthTargetBuffs,
            disabled = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }))

    -- Buff Stack Direction - Target Buffs
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.StackTargetBuffs,
            disabled = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }))

    -- Buff Width - Target Debuffs
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
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
            default = Defaults.WidthTargetDebuffs,
            disabled = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }))

    -- Buff Stack Direction - Target Debuffs
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.StackTargetDebuffs,
            disabled = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }))

    -- Long Term Alignment & Sorting
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_SORTING_LONGTERM_HEADER),
        }))

    -- Container Orientation (Long Term)
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CONTAINER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CONTAINER_TP),
            choices = rotationOptions,
            getFunc = function ()
                return rotationOptions[Settings.LongTermEffectsSeparateAlignment]
            end,
            setFunc = function (combobox, value, item)
                Settings.LongTermEffectsSeparateAlignment = rotationOptionsKeys[value]
                SpellCastBuffs.ResetContainerOrientation()
                SpellCastBuffs.Reset()
            end,
            default = rotationOptions[2],
        }))

    -- Horizontal Long Term Icons Alignment
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.AlignmentLongHorz,
            disabled = function ()
                return Settings.LongTermEffectsSeparateAlignment == 2
            end,
        }))

    -- Horizontal Long Term Sort
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.SortLongHorz,
            disabled = function ()
                return Settings.LongTermEffectsSeparateAlignment == 2
            end,
        }))

    -- Vertical Long Term Icons Alignment
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.AlignmentLongVert,
            disabled = function ()
                return Settings.LongTermEffectsSeparateAlignment == 1
            end,
        }))

    -- Vertical Long Term Sort
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.SortLongVert,
            disabled = function ()
                return Settings.LongTermEffectsSeparateAlignment == 1
            end,
        }))

    -- Prominent Alignment & Sorting
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_SORTING_PROMINET_HEADER),
        }))

    -- Prominent Buff Container Orientation
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFCONTAINER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFCONTAINER_TP),
            choices = rotationOptions,
            getFunc = function ()
                return rotationOptions[Settings.ProminentBuffContainerAlignment]
            end,
            setFunc = function (combobox, value, item)
                Settings.ProminentBuffContainerAlignment = rotationOptionsKeys[value]
                SpellCastBuffs.ResetContainerOrientation()
                SpellCastBuffs.Reset()
            end,
            default = rotationOptions[2],
        }))

    -- Horizontal Prominent Buffs Icons Alignment
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.AlignmentPromBuffsHorz,
            disabled = function ()
                return Settings.ProminentBuffContainerAlignment == 2
            end,
        }))

    -- Horizontal Prominent Buffs Sort
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.SortPromBuffsHorz,
            disabled = function ()
                return Settings.ProminentBuffContainerAlignment == 2
            end,
        }))

    -- Vertical Prominent Buffs Icons Alignment
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.AlignmentPromBuffsVert,
            disabled = function ()
                return Settings.ProminentBuffContainerAlignment == 1
            end,
        }))

    -- Vertical Prominent Buffs Sort
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.SortPromBuffsVert,
            disabled = function ()
                return Settings.ProminentBuffContainerAlignment == 1
            end,
        }))

    -- Prominent Debuff Container Orientation
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFCONTAINER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFCONTAINER_TP),
            choices = rotationOptions,
            getFunc = function ()
                return rotationOptions[Settings.ProminentDebuffContainerAlignment]
            end,
            setFunc = function (combobox, value, item)
                Settings.ProminentDebuffContainerAlignment = rotationOptionsKeys[value]
                SpellCastBuffs.ResetContainerOrientation()
                SpellCastBuffs.Reset()
            end,
            default = rotationOptions[2],
        }))

    -- Horizontal Prominent Debuffs Icons Alignment
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.AlignmentPromDebuffsHorz,
            disabled = function ()
                return Settings.ProminentDebuffContainerAlignment == 2
            end,
        }))

    -- Horizontal Prominent Debuffs Sort
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.SortPromDebuffsHorz,
            disabled = function ()
                return Settings.ProminentDebuffContainerAlignment == 2
            end,
        }))

    -- Vertical Prominent Debuffs Icons Alignment
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.AlignmentPromDebuffsVert,
            disabled = function ()
                return Settings.ProminentDebuffContainerAlignment == 1
            end,
        }))

    -- Vertical Prominent Debuffs Sort
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
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
            default = Defaults.SortPromDebuffsVert,
            disabled = function ()
                return Settings.ProminentDebuffContainerAlignment == 1
            end,
        }))

    -- Buffs&Debuffs - Tooltip Options Submenu
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_HEADER),
        }))

    -- Tooltip Enable
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ENABLE_TP),
            getFunc = function ()
                return Settings.TooltipEnable
            end,
            setFunc = function (value)
                Settings.TooltipEnable = value
            end,
            default = Defaults.TooltipEnable,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Tooltip Custom
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_CUSTOM),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_CUSTOM_TP),
            getFunc = function ()
                return Settings.TooltipCustom
            end,
            setFunc = function (value)
                Settings.TooltipCustom = value
            end,
            default = Defaults.TooltipCustom,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Tooltip Ability Id
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ABILITY_ID),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ABILITY_ID_TP),
            getFunc = function ()
                return Settings.TooltipAbilityId
            end,
            setFunc = function (value)
                Settings.TooltipAbilityId = value
            end,
            default = Defaults.TooltipAbilityId,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Tooltip Buff Type
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_BUFF_TYPE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_BUFF_TYPE_TP),
            getFunc = function ()
                return Settings.TooltipBuffType
            end,
            setFunc = function (value)
                Settings.TooltipBuffType = value
            end,
            default = Defaults.TooltipBuffType,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Sticky Tooltip Slider
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
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
            default = Defaults.TooltipSticky,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Buffs&Debuffs - Priority Buffs & Debuffs Options Submenu
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_HEADER),
        }))

    -- Prominent Buffs & Debuffs Description
    panel:AddSetting(SettingsAPI.CreateDescriptionOption(
        {
            text = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DESCRIPTION),
        }))

    panel:AddSetting(SettingsAPI.CreateDescriptionOption(
        {
            text = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DIALOGUE_DESCRIPT),
        }))

    -- Store temp text for adding priority buffs
    if not Settings.tempPriorityBuffsText then
        Settings.tempPriorityBuffsText = ""
    end

    -- Add Priority Buff edit box
    panel:AddSetting(SettingsAPI.CreateEditboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunc = function ()
                return Settings.tempPriorityBuffsText or ""
            end,
            setFunc = function (value)
                Settings.tempPriorityBuffsText = value
            end,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Add Priority Buff button
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            clickHandler = function ()
                local text = Settings.tempPriorityBuffsText or ""
                if text and text ~= "" then
                    SpellCastBuffs.AddToCustomList(Settings.PriorityBuffTable, text)
                    Settings.tempPriorityBuffsText = ""
                    -- Refresh the dialog if it's open
                    if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_PRIORITY_BUFFS"] then
                        LUIE.RefreshBlacklistDialog("LUIE_MANAGE_PRIORITY_BUFFS")
                    end
                    -- Refresh settings to clear the edit box
                    if LHAS and LHAS.RefreshAddonSettings then
                        LHAS:RefreshAddonSettings()
                    end
                end
            end,
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Manage Priority Buffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_BUFF_REMLIST_TP),
            clickHandler = function ()
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_PRIORITY_BUFFS")
            end,
            buttonText = GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Clear Priority Buffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_BUFFS),
            tooltip = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_BUFFS_TP),
            clickHandler = function ()
                ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_PRIORITY_BUFFS")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_BUFFS),
        }))

    -- Store temp text for adding priority debuffs
    if not Settings.tempPriorityDebuffsText then
        Settings.tempPriorityDebuffsText = ""
    end

    -- Add Priority Debuff edit box
    panel:AddSetting(SettingsAPI.CreateEditboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunc = function ()
                return Settings.tempPriorityDebuffsText or ""
            end,
            setFunc = function (value)
                Settings.tempPriorityDebuffsText = value
            end,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Add Priority Debuff button
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            clickHandler = function ()
                local text = Settings.tempPriorityDebuffsText or ""
                if text and text ~= "" then
                    SpellCastBuffs.AddToCustomList(Settings.PriorityDebuffTable, text)
                    Settings.tempPriorityDebuffsText = ""
                    -- Refresh the dialog if it's open
                    if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_PRIORITY_DEBUFFS"] then
                        LUIE.RefreshBlacklistDialog("LUIE_MANAGE_PRIORITY_DEBUFFS")
                    end
                    -- Refresh settings to clear the edit box
                    if LHAS and LHAS.RefreshAddonSettings then
                        LHAS:RefreshAddonSettings()
                    end
                end
            end,
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Manage Priority Debuffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DEBUFF_REMLIST_TP),
            clickHandler = function ()
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_PRIORITY_DEBUFFS")
            end,
            buttonText = GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Clear Priority Debuffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_DEBUFFS),
            tooltip = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_DEBUFFS_TP),
            clickHandler = function ()
                ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_PRIORITY_DEBUFFS")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_DEBUFFS),
        }))

    -- Buffs&Debuffs - Prominent Buffs & Debuffs Options Submenu
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_PROM_HEADER),
        }))

    -- Prominent Buffs & Debuffs Description
    panel:AddSetting(SettingsAPI.CreateDescriptionOption(
        {
            text = GetString(LUIE_STRING_LAM_BUFF_PROM_DESCRIPTION),
        }))

    -- Prominent Buffs Label Toggle
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_PROM_LABEL),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_LABEL_TP),
            getFunc = function ()
                return Settings.ProminentLabel
            end,
            setFunc = function (value)
                Settings.ProminentLabel = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ProminentLabel,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Prominent Buffs Label Font Face
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_FONTFACE)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTFACE_TP),
            choices = SettingsAPI.GetFontsList(),
            getFunc = function ()
                return Settings.ProminentLabelFontFace
            end,
            setFunc = function (value)
                Settings.ProminentLabelFontFace = value
                SpellCastBuffs.ApplyFont()
            end,
            default = Defaults.ProminentLabelFontFace,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentLabel)
            end,
        }))

    -- Prominent Buffs Label Font Size
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSIZE)),
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
            default = Defaults.ProminentLabelFontSize,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentLabel)
            end,
        }))

    -- Prominent Buffs Label Font Style
    panel:AddSetting(SettingsAPI.CreateFontStyleDropdown(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSTYLE)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSTYLE_TP),
            getFunc = function ()
                return Settings.ProminentLabelFontStyle
            end,
            setFunc = function (value)
                Settings.ProminentLabelFontStyle = value
                SpellCastBuffs.ApplyFont()
            end,
            default = Defaults.ProminentLabelFontStyle,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentLabel)
            end,
        }))

    -- Prominent Buffs Progress Bar
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR_TP),
            getFunc = function ()
                return Settings.ProminentProgress
            end,
            setFunc = function (value)
                Settings.ProminentProgress = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ProminentProgress,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Prominent Buffs Progress Bar Texture
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR_TEXTURE)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR_TEXTURE_TP),
            choices = SettingsAPI.GetStatusbarTexturesList(),
            getFunc = function ()
                return Settings.ProminentProgressTexture
            end,
            setFunc = function (value)
                Settings.ProminentProgressTexture = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ProminentProgressTexture,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
            end,
        }))

    -- Prominent Buffs Gradient Color 1
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF1)),
        GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF1_TP),
        function ()
            return unpack(Settings.ProminentProgressBuffC1)
        end,
        function (r, g, b, a)
            Settings.ProminentProgressBuffC1 = { r, g, b, a }
            SpellCastBuffs.Reset()
        end,
        Settings.ProminentProgressBuffC1,
        nil,
        function ()
            return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
        end
    ))

    -- Prominent Buffs Gradient Color 2
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF2)),
        GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF2_TP),
        function ()
            return unpack(Settings.ProminentProgressBuffC2)
        end,
        function (r, g, b, a)
            Settings.ProminentProgressBuffC2 = { r, g, b, a }
            SpellCastBuffs.Reset()
        end,
        Settings.ProminentProgressBuffC2,
        nil,
        function ()
            return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
        end
    ))

    -- Prominent Buffs Gradient Color 1 (Priority)
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY1)),
        GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY1_TP),
        function ()
            return unpack(Settings.ProminentProgressBuffPriorityC1)
        end,
        function (r, g, b, a)
            Settings.ProminentProgressBuffPriorityC1 = { r, g, b, a }
            SpellCastBuffs.Reset()
        end,
        Settings.ProminentProgressBuffPriorityC1,
        nil,
        function ()
            return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
        end
    ))

    -- Prominent Buffs Gradient Color 2 (Priority)
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY2)),
        GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY2_TP),
        function ()
            return unpack(Settings.ProminentProgressBuffPriorityC2)
        end,
        function (r, g, b, a)
            Settings.ProminentProgressBuffPriorityC2 = { r, g, b, a }
            SpellCastBuffs.Reset()
        end,
        Settings.ProminentProgressBuffPriorityC2,
        nil,
        function ()
            return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
        end
    ))

    -- Prominent Debuffs Gradient Color 1
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF1)),
        GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF1_TP),
        function ()
            return unpack(Settings.ProminentProgressDebuffC1)
        end,
        function (r, g, b, a)
            Settings.ProminentProgressDebuffC1 = { r, g, b, a }
            SpellCastBuffs.Reset()
        end,
        Settings.ProminentProgressDebuffC1,
        nil,
        function ()
            return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
        end
    ))

    -- Prominent Debuffs Gradient Color 2
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF2)),
        GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF2_TP),
        function ()
            return unpack(Settings.ProminentProgressDebuffC2)
        end,
        function (r, g, b, a)
            Settings.ProminentProgressDebuffC2 = { r, g, b, a }
            SpellCastBuffs.Reset()
        end,
        Settings.ProminentProgressDebuffC2,
        nil,
        function ()
            return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
        end
    ))

    -- Prominent Debuffs Gradient Color 1 (Priority)
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY1)),
        GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY1_TP),
        function ()
            return unpack(Settings.ProminentProgressDebuffPriorityC1)
        end,
        function (r, g, b, a)
            Settings.ProminentProgressDebuffPriorityC1 = { r, g, b, a }
            SpellCastBuffs.Reset()
        end,
        Settings.ProminentProgressDebuffPriorityC1,
        nil,
        function ()
            return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
        end
    ))

    -- Prominent Debuffs Gradient Color 2 (Priority)
    panel:AddSetting(SettingsAPI.CreateColorpickerFromTable(
        SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY2)),
        GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY2_TP),
        function ()
            return unpack(Settings.ProminentProgressDebuffPriorityC2)
        end,
        function (r, g, b, a)
            Settings.ProminentProgressDebuffPriorityC2 = { r, g, b, a }
            SpellCastBuffs.Reset()
        end,
        Settings.ProminentProgressDebuffPriorityC2,
        nil,
        function ()
            return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
        end
    ))

    -- Prominent Buffs Label/Progress Bar Direction
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFLABELDIRECTION),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFLABELDIRECTION_TP),
            choices = { "Right", "Left" },
            getFunc = function ()
                return Settings.ProminentBuffLabelDirection
            end,
            setFunc = function (value)
                Settings.ProminentBuffLabelDirection = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ProminentBuffLabelDirection,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.ProminentLabel or Settings.ProminentProgress))
            end,
        }))

    -- Prominent Debuffs Label/Progress Bar Direction
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFLABELDIRECTION),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFLABELDIRECTION_TP),
            choices = { "Right", "Left" },
            getFunc = function ()
                return Settings.ProminentDebuffLabelDirection
            end,
            setFunc = function (value)
                Settings.ProminentDebuffLabelDirection = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ProminentDebuffLabelDirection,
            disabled = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.ProminentLabel or Settings.ProminentProgress))
            end,
        }))

    panel:AddSetting(SettingsAPI.CreateDescriptionOption(
        {
            text = GetString(LUIE_STRING_LAM_BUFF_PROM_DIALOGUE_DESCRIPT),
        }))

    -- Store temp text for adding prominent buffs
    if not Settings.tempProminentBuffsText then
        Settings.tempProminentBuffsText = ""
    end

    -- Add Prominent Buff edit box
    panel:AddSetting(SettingsAPI.CreateEditboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunc = function ()
                return Settings.tempProminentBuffsText or ""
            end,
            setFunc = function (value)
                Settings.tempProminentBuffsText = value
            end,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Add Prominent Buff button
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            clickHandler = function ()
                local text = Settings.tempProminentBuffsText or ""
                if text and text ~= "" then
                    SpellCastBuffs.AddToCustomList(Settings.PromBuffTable, text)
                    Settings.tempProminentBuffsText = ""
                    -- Refresh the dialog if it's open
                    if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_PROMINENT_BUFFS"] then
                        LUIE.RefreshBlacklistDialog("LUIE_MANAGE_PROMINENT_BUFFS")
                    end
                    -- Refresh settings to clear the edit box
                    if LHAS and LHAS.RefreshAddonSettings then
                        LHAS:RefreshAddonSettings()
                    end
                end
            end,
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Manage Prominent Buffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFF_REMLIST_TP),
            clickHandler = function ()
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_PROMINENT_BUFFS")
            end,
            buttonText = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Clear Prominent Buffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_BUFFS),
            tooltip = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_BUFFS_TP),
            clickHandler = function ()
                ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_PROMINENT_BUFFS")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_BUFFS),
        }))

    -- Store temp text for adding prominent debuffs
    if not Settings.tempProminentDebuffsText then
        Settings.tempProminentDebuffsText = ""
    end

    -- Add Prominent Debuff edit box
    panel:AddSetting(SettingsAPI.CreateEditboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunc = function ()
                return Settings.tempProminentDebuffsText or ""
            end,
            setFunc = function (value)
                Settings.tempProminentDebuffsText = value
            end,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Add Prominent Debuff button
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            clickHandler = function ()
                local text = Settings.tempProminentDebuffsText or ""
                if text and text ~= "" then
                    SpellCastBuffs.AddToCustomList(Settings.PromDebuffTable, text)
                    Settings.tempProminentDebuffsText = ""
                    -- Refresh the dialog if it's open
                    if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_PROMINENT_DEBUFFS"] then
                        LUIE.RefreshBlacklistDialog("LUIE_MANAGE_PROMINENT_DEBUFFS")
                    end
                    -- Refresh settings to clear the edit box
                    if LHAS and LHAS.RefreshAddonSettings then
                        LHAS:RefreshAddonSettings()
                    end
                end
            end,
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Manage Prominent Debuffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFF_REMLIST_TP),
            clickHandler = function ()
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_PROMINENT_DEBUFFS")
            end,
            buttonText = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Clear Prominent Debuffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_DEBUFFS),
            tooltip = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_DEBUFFS_TP),
            clickHandler = function ()
                ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_PROMINENT_DEBUFFS")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_DEBUFFS),
        }))

    -- Buffs&Debuffs - Blacklist Submenu
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_HEADER),
        }))

    -- Buffs & Debuffs Blacklist Description
    panel:AddSetting(SettingsAPI.CreateDescriptionOption(
        {
            text = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT),
        }))

    -- Add Minor Buffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_BUFF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_BUFF_TP),
            clickHandler = function ()
                SpellCastBuffs.AddBulkToCustomList(Settings.BlacklistTable, BlacklistPresets.MinorBuffs)
                if LHAS and LHAS.RefreshAddonSettings then
                    LHAS:RefreshAddonSettings()
                end
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_BLACKLIST")
            end,
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_BUFF),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Add Major Buffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_BUFF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_BUFF_TP),
            clickHandler = function ()
                SpellCastBuffs.AddBulkToCustomList(Settings.BlacklistTable, BlacklistPresets.MajorBuffs)
                if LHAS and LHAS.RefreshAddonSettings then
                    LHAS:RefreshAddonSettings()
                end
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_BLACKLIST")
            end,
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_BUFF),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Add Minor Debuffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_DEBUFF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_DEBUFF_TP),
            clickHandler = function ()
                SpellCastBuffs.AddBulkToCustomList(Settings.BlacklistTable, BlacklistPresets.MinorDebuffs)
                if LHAS and LHAS.RefreshAddonSettings then
                    LHAS:RefreshAddonSettings()
                end
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_BLACKLIST")
            end,
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_DEBUFF),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Add Major Debuffs
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_DEBUFF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_DEBUFF_TP),
            clickHandler = function ()
                SpellCastBuffs.AddBulkToCustomList(Settings.BlacklistTable, BlacklistPresets.MajorDebuffs)
                if LHAS and LHAS.RefreshAddonSettings then
                    LHAS:RefreshAddonSettings()
                end
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_BLACKLIST")
            end,
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_DEBUFF),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Store temp text for adding items
    if not Settings.tempBlacklistText then
        Settings.tempBlacklistText = ""
    end

    -- Add Item edit box
    panel:AddSetting(SettingsAPI.CreateEditboxOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunc = function ()
                return Settings.tempBlacklistText or ""
            end,
            setFunc = function (value)
                Settings.tempBlacklistText = value
            end,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Add Item button
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            clickHandler = function ()
                local text = Settings.tempBlacklistText or ""
                if text and text ~= "" then
                    SpellCastBuffs.AddToCustomList(Settings.BlacklistTable, text)
                    Settings.tempBlacklistText = ""
                    -- Refresh the blacklist dialog if it's open
                    if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_BLACKLIST"] then
                        LUIE.RefreshBlacklistDialog("LUIE_MANAGE_BLACKLIST")
                    end
                    -- Refresh settings to clear the edit box
                    if LHAS and LHAS.RefreshAddonSettings then
                        LHAS:RefreshAddonSettings()
                    end
                end
            end,
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Clear Blacklist
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
            tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
            clickHandler = function ()
                ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_ABILITY_BLACKLIST")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Manage Blacklist
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST_TP),
            clickHandler = function ()
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_BLACKLIST")
            end,
            buttonText = GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST),
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Debug Options
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = "Debug Options",
        }))

    -- Debug - Show AbilityId on Buffs & Debuffs
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = "Show AbilityId on Buffs & Debuffs",
            tooltip = "Toggle the display of AbilityId on buffs and debuffs - useful for adding auras to Prominent Buffs & Debuffs or the Aura Blacklist.",
            getFunc = function ()
                return Settings.ShowDebugAbilityId
            end,
            setFunc = function (value)
                Settings.ShowDebugAbilityId = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ShowDebugAbilityId,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Debug - Show Debug for Combat Events
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = "Show Debug for Combat Events",
            tooltip = "Display debug information for combat events - used for development.",
            getFunc = function ()
                return Settings.ShowDebugCombat
            end,
            setFunc = function (value)
                Settings.ShowDebugCombat = value
                SpellCastBuffs.RegisterDebugEvents()
            end,
            default = Defaults.ShowDebugCombat,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Debug - Show Debug for Effect Change Events
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = "Show Debug for Effect Change Events",
            tooltip = "Display debug information for effect change events - used for development.",
            getFunc = function ()
                return Settings.ShowDebugEffect
            end,
            setFunc = function (value)
                Settings.ShowDebugEffect = value
                SpellCastBuffs.RegisterDebugEvents()
            end,
            default = Defaults.ShowDebugEffect,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))

    -- Debug - Filter Debug Events & Effects
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = "Filter Debug Events & Effects",
            tooltip = "Filter out events and effects that have already been processed - used for development.",
            getFunc = function ()
                return Settings.ShowDebugFilter
            end,
            setFunc = function (value)
                Settings.ShowDebugFilter = value
            end,
            default = Defaults.ShowDebugFilter,
            disabled = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }))
end
