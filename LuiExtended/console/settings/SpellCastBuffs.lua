-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- Load Console Settings API
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

    -- Register the settings panel
    if not LUIE.SV.SpellCastBuff_Enable then
        return
    end

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

    -- Build font style list once for reuse
    local fontStyleItems = {}
    for i, styleName in ipairs(LUIE.FONT_STYLE_CHOICES) do
        fontStyleItems[i] = { name = styleName, data = LUIE.FONT_STYLE_CHOICES_VALUES[i] }
    end

    -- Get status bar texture list from SettingsAPI
    local statusbarTextureItems = SettingsAPI:GetStatusbarTexturesList()

    -- Build rotation options list once for reuse
    local rotationOptionsItems = {}
    for i, optionName in ipairs(rotationOptions) do
        rotationOptionsItems[i] = { name = optionName, data = rotationOptionsKeys[optionName] }
    end

    -- Collect initial settings for main menu
    local initialSettings = {}

    -- Buffs & Debuffs Description
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_BUFFS_DESCRIPTION),
    }

    -- ReloadUI Button
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
        clickHandler = function ()
            ReloadUI("ingame")
        end,
    }

    -- Buffs Window Unlock
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_BUFF_UNLOCKWINDOW),
        tooltip = GetString(LUIE_STRING_LAM_BUFF_UNLOCKWINDOW_TP),
        getFunction = function ()
            return g_BuffsMovingEnabled
        end,
        setFunction = function (v)
            g_BuffsMovingEnabled = v
            -- Ensure lockPositionToUnitFrames is properly initialized when unlocking frames
            if v and SpellCastBuffs.SV.lockPositionToUnitFrames == nil then
                SpellCastBuffs.SV.lockPositionToUnitFrames = false
            end
            SpellCastBuffs.SetMovingState(v)
        end,
        default = false,
    }

    -- Buffs Window Reset position
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_RESETPOSITION),
        tooltip = GetString(LUIE_STRING_LAM_BUFF_RESETPOSITION_TP),
        buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
        clickHandler = SpellCastBuffs.ResetTlwPosition,
    }

    -- Hard-Lock Position to Unit Frames
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_BUFF_HARDLOCK),
        tooltip = GetString(LUIE_STRING_LAM_BUFF_HARDLOCK_TP),
        getFunction = function ()
            return Settings.lockPositionToUnitFrames
        end,
        setFunction = function (v)
            Settings.lockPositionToUnitFrames = v
        end,
        default = Defaults.lockPositionToUnitFrames,
    }

    -- Initialize all settings and menu buttons for submenus
    local backButton = nil
    local menuButtons = {}
    local sectionGroups = {}

    -- Helper function to build section settings
    local function buildSectionSettings(sectionName, settingsBuilder)
        local sectionSettings = {}
        settingsBuilder(sectionSettings)
        sectionGroups[sectionName] = sectionSettings
    end

    -- Build Position and Display Options Section
    buildSectionSettings("PositionDisplay", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_HEADER_POSITION),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure position and display options for buffs and debuffs.",
        }

        -- Hide OakenSoul
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_HIDE_OAKENSOUL),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_HIDE_OAKENSOUL_TP),
            getFunction = function ()
                return Settings.HideOakenSoul
            end,
            setFunction = function (v)
                Settings.HideOakenSoul = v
            end,
            default = Defaults.HideOakenSoul,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERBUFF)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERBUFF_TP),
            getFunction = function ()
                return not Settings.HidePlayerBuffs
            end,
            setFunction = function (v)
                Settings.HidePlayerBuffs = not v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.HidePlayerBuffs,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERDEBUFF)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWPLAYERDEBUFF_TP),
            getFunction = function ()
                return not Settings.HidePlayerDebuffs
            end,
            setFunction = function (v)
                Settings.HidePlayerDebuffs = not v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.HidePlayerDebuffs,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETBUFF)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETBUFF_TP),
            getFunction = function ()
                return not Settings.HideTargetBuffs
            end,
            setFunction = function (v)
                Settings.HideTargetBuffs = not v
            end,
            default = not Defaults.HideTargetBuffs,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETDEBUFF)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWTARGETDEBUFF_TP),
            getFunction = function ()
                return not Settings.HideTargetDebuffs
            end,
            setFunction = function (v)
                Settings.HideTargetDebuffs = not v
            end,
            default = not Defaults.HideTargetDebuffs,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOWGROUNDBUFFDEBUFF)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWGROUNDBUFFDEBUFF_TP),
            getFunction = function ()
                return not Settings.HideGroundEffects
            end,
            setFunction = function (v)
                Settings.HideGroundEffects = not v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Settings.HideGroundEffects,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Ground Damage Auras
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SHOW_GROUND_DAMAGE)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOW_GROUND_DAMAGE_TP),
            getFunction = function ()
                return Settings.GroundDamageAura
            end,
            setFunction = function (v)
                Settings.GroundDamageAura = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Settings.GroundDamageAura,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Add Extra
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_ADD_EXTRA_BUFFS)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_ADD_EXTRA_BUFFS_TP),
            getFunction = function ()
                return Settings.ExtraBuffs
            end,
            setFunction = function (v)
                Settings.ExtraBuffs = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Settings.ExtraBuffs,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Extra Expanded
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_EXTEND_EXTRA),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_EXTEND_EXTRA_TP),
            getFunction = function ()
                return Settings.ExtraExpanded
            end,
            setFunction = function (v)
                Settings.ExtraExpanded = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Settings.ExtraExpanded,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ExtraBuffs)
            end,
        }

        -- Reduce
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_REDUCE)),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_REDUCE_TP),
            getFunction = function ()
                return Settings.HideReduce
            end,
            setFunction = function (v)
                Settings.HideReduce = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Settings.HideReduce,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Always Show Shared Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_ALWAYS_SHARED_EFFECTS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_ALWAYS_SHARED_EFFECTS_TP),
            getFunction = function ()
                return Settings.ShowSharedEffects
            end,
            setFunction = function (v)
                Settings.ShowSharedEffects = v
                SpellCastBuffs.UpdateDisplayOverrideIdList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShowSharedEffects,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Always Show Major/Minor Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_ALWAYS_MAJOR_MINOR_EFFECTS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_ALWAYS_MAJOR_MINOR_EFFECTS_TP),
            getFunction = function ()
                return Settings.ShowSharedMajorMinor
            end,
            setFunction = function (v)
                Settings.ShowSharedMajorMinor = v
                SpellCastBuffs.UpdateDisplayOverrideIdList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShowSharedMajorMinor,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }
    end)

    -- Build Long & Short Term Effects Filters Section
    buildSectionSettings("LongShortTerm", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_LONG_SHORT_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure long and short term effects filters.",
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_SELF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_SELF_TP),
            getFunction = function ()
                return Settings.ShortTermEffects_Player
            end,
            setFunction = function (v)
                Settings.ShortTermEffects_Player = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShortTermEffects_Player,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHORTTERM_TARGET_TP),
            getFunction = function ()
                return Settings.ShortTermEffects_Target
            end,
            setFunction = function (v)
                Settings.ShortTermEffects_Target = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShortTermEffects_Target,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SELF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SELF_TP),
            getFunction = function ()
                return Settings.LongTermEffects_Player
            end,
            setFunction = function (v)
                Settings.LongTermEffects_Player = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.LongTermEffects_Player,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Separate control for player effects
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SEPCTRL),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SEPCTRL_TP),
            getFunction = function ()
                return Settings.LongTermEffectsSeparate
            end,
            setFunction = function (v)
                Settings.LongTermEffectsSeparate = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.LongTermEffectsSeparate,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.LongTermEffects_Player)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_TARGET_TP),
            getFunction = function ()
                return Settings.LongTermEffects_Target
            end,
            setFunction = function (v)
                Settings.LongTermEffects_Target = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.LongTermEffects_Target,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }
    end)

    -- Build Misc Options Section
    buildSectionSettings("Misc", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure miscellaneous buff and debuff display options.",
        }

        -- Show Rezz Immunity Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWREZZ),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWREZZ_TP),
            getFunction = function ()
                return Settings.ShowResurrectionImmunity
            end,
            setFunction = function (v)
                Settings.ShowResurrectionImmunity = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShowResurrectionImmunity,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Show Recall Cooldown Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWRECALL),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWRECALL_TP),
            getFunction = function ()
                return Settings.ShowRecall
            end,
            setFunction = function (v)
                Settings.ShowRecall = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShowRecall,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Show Werewolf Timer Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWWEREWOLF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWWEREWOLF_TP),
            getFunction = function ()
                return Settings.ShowWerewolf
            end,
            setFunction = function (v)
                Settings.ShowWerewolf = v
                SpellCastBuffs.RegisterWerewolfEvents()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShowWerewolf,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Short Term - Set ICD - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SETICDPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SETICDPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreSetICDPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreSetICDPlayer = not v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreSetICDPlayer,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Short Term - Ability ICD - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ABILITYICDPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ABILITYICDPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreAbilityICDPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreAbilityICDPlayer = not v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreAbilityICDPlayer,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Show Block Player Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWBLOCKPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWBLOCKPLAYER_TP),
            getFunction = function ()
                return Settings.ShowBlockPlayer
            end,
            setFunction = function (v)
                Settings.ShowBlockPlayer = v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShowBlockPlayer,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Show Block Target Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWBLOCKTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWBLOCKTARGET_TP),
            getFunction = function ()
                return Settings.ShowBlockTarget
            end,
            setFunction = function (v)
                Settings.ShowBlockTarget = v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ShowBlockTarget,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Show Stealth Player Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHPLAYER_TP),
            getFunction = function ()
                return Settings.StealthStatePlayer
            end,
            setFunction = function (v)
                Settings.StealthStatePlayer = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.StealthStatePlayer,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Show Stealth Target Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_SHOWSTEALTHTARGET_TP),
            getFunction = function ()
                return Settings.StealthStateTarget
            end,
            setFunction = function (v)
                Settings.StealthStateTarget = v
                SpellCastBuffs.ReloadEffects("reticleover")
            end,
            default = Defaults.StealthStateTarget,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Show Disguise Player Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISEPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISEPLAYER_TP),
            getFunction = function ()
                return Settings.DisguiseStatePlayer
            end,
            setFunction = function (v)
                Settings.DisguiseStatePlayer = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.DisguiseStatePlayer,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Show Disguise Target Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISETARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_MISC_LOOTSHOWDISGUISETARGET_TP),
            getFunction = function ()
                return Settings.DisguiseStateTarget
            end,
            setFunction = function (v)
                Settings.DisguiseStateTarget = v
                SpellCastBuffs.ReloadEffects("reticleover")
            end,
            default = Defaults.DisguiseStateTarget,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }
    end)

    -- Build Long Term Effects Section
    buildSectionSettings("LongTerm", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure long term effects display options.",
        }

        -- Long Term - Disguises
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_DISGUISE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_DISGUISE_TP),
            getFunction = function ()
                return not Settings.IgnoreDisguise
            end,
            setFunction = function (v)
                Settings.IgnoreDisguise = not v
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.IgnoreDisguise,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Assistants
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ASSISTANT),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ASSISTANT_TP),
            getFunction = function ()
                return not Settings.IgnoreAssistant
            end,
            setFunction = function (v)
                Settings.IgnoreAssistant = not v
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.IgnoreAssistant,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Pets
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET_TP),
            getFunction = function ()
                return not Settings.IgnorePet
            end,
            setFunction = function (v)
                Settings.IgnorePet = not v
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.IgnorePet,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Use Generic Pet Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET_ICON),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_PET_ICON_TP),
            getFunction = function ()
                return Settings.PetDetail
            end,
            setFunction = function (v)
                Settings.PetDetail = v
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.PetDetail,
            disable = function ()
                return Settings.IgnorePet
            end,
        }

        -- Long Term - Mounts (Player)
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_PLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_PLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreMountPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreMountPlayer = not v
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.IgnoreMountPlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Use Generic Mount Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_ICON),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MOUNT_ICON_TP),
            getFunction = function ()
                return Settings.MountDetail
            end,
            setFunction = function (v)
                Settings.MountDetail = v
                SpellCastBuffs.OnPlayerActivated()
            end,
            default = not Defaults.MountDetail,
            disable = function ()
                return Settings.IgnoreMountPlayer
            end,
        }

        -- Long Term - Mundus - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MUNDUSPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MUNDUSPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreMundusPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreMundusPlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreMundusPlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Mundus - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MUNDUSTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_MUNDUSTARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreMundusTarget
            end,
            setFunction = function (v)
                Settings.IgnoreMundusTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreMundusTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Food & Drink - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_FOODPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_FOODPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreFoodPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreFoodPlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreFoodPlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Food & Drink - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_FOODTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_FOODTARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreFoodTarget
            end,
            setFunction = function (v)
                Settings.IgnoreFoodTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreFoodTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Experience - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_EXPERIENCEPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_EXPERIENCEPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreExperiencePlayer
            end,
            setFunction = function (v)
                Settings.IgnoreExperiencePlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreExperiencePlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Experience - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_EXPERIENCETARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_EXPERIENCETARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreExperienceTarget
            end,
            setFunction = function (v)
                Settings.IgnoreExperienceTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreExperienceTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Alliance XP - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ALLIANCEXPPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ALLIANCEXPPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreAllianceXPPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreAllianceXPPlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreAllianceXPPlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Alliance XP - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ALLIANCEXPTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ALLIANCEXPTARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreAllianceXPTarget
            end,
            setFunction = function (v)
                Settings.IgnoreAllianceXPTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreAllianceXPTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Vamp Stage - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPSTAGEPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPSTAGEPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreVampPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreVampPlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreVampPlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Vamp Stage - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPSTAGETARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPSTAGETARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreVampTarget
            end,
            setFunction = function (v)
                Settings.IgnoreVampTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreVampTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Lycanthrophy - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_LYCANPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_LYCANPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreLycanPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreLycanPlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreLycanPlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Lycanthrophy - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_LYCANTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_LYCANTARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreLycanTarget
            end,
            setFunction = function (v)
                Settings.IgnoreLycanTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreLycanTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Bite Disease - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPWWPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPWWPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreDiseasePlayer
            end,
            setFunction = function (v)
                Settings.IgnoreDiseasePlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreDiseasePlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Bite Disease - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPWWTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_VAMPWWTARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreDiseaseTarget
            end,
            setFunction = function (v)
                Settings.IgnoreDiseaseTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreDiseaseTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Bite Timers - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BITEPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BITEPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreBitePlayer
            end,
            setFunction = function (v)
                Settings.IgnoreBitePlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreBitePlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Bite Timers - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BITETARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BITETARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreBiteTarget
            end,
            setFunction = function (v)
                Settings.IgnoreBiteTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreBiteTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Battle Spirit - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BSPIRITPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BSPIRITPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreBattleSpiritPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreBattleSpiritPlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
                SpellCastBuffs.ArtificialEffectUpdate()
            end,
            default = not Defaults.IgnoreBattleSpiritPlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Battle Spirit - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BSPIRITTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_BSPIRITTARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreBattleSpiritTarget
            end,
            setFunction = function (v)
                Settings.IgnoreBattleSpiritTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreBattleSpiritTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Cyrodiil - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CYROPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CYROPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreCyrodiilPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreCyrodiilPlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreCyrodiilPlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Cyrodiil - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CYROTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CYROTARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreCyrodiilTarget
            end,
            setFunction = function (v)
                Settings.IgnoreCyrodiilTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreCyrodiilTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - ESO Plus - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ESOPLUSPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ESOPLUSPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreEsoPlusPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreEsoPlusPlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreEsoPlusPlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - ESO Plus - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ESOPLUSTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_ESOPLUSTARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreEsoPlusTarget
            end,
            setFunction = function (v)
                Settings.IgnoreEsoPlusTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreEsoPlusTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Soul Summons - Player
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SOULSUMMONSPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SOULSUMMONSPLAYER_TP),
            getFunction = function ()
                return not Settings.IgnoreSoulSummonsPlayer
            end,
            setFunction = function (v)
                Settings.IgnoreSoulSummonsPlayer = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreSoulSummonsPlayer,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }

        -- Long Term - Soul Summons - Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SOULSUMMONSTARGET),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_SOULSUMMONSTARGET_TP),
            getFunction = function ()
                return not Settings.IgnoreSoulSummonsTarget
            end,
            setFunction = function (v)
                Settings.IgnoreSoulSummonsTarget = not v
                SpellCastBuffs.UpdateContextHideList()
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = not Defaults.IgnoreSoulSummonsTarget,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.LongTermEffects_Player or Settings.LongTermEffects_Target))
            end,
        }
    end)

    -- Build Icon Options Section
    buildSectionSettings("Icon", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_ICON_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure icon display options for buffs and debuffs.",
        }

        -- Buff Icon Size
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            format = "%.0f",
            label = GetString(LUIE_STRING_LAM_BUFF_ICONSIZE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_ICONSIZE_TP),
            min = 30,
            max = 60,
            step = 2,
            getFunction = function ()
                return Settings.IconSize
            end,
            setFunction = function (v)
                Settings.IconSize = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.IconSize,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Buff Show Remaining Time Label
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_SHOWREMAINTIMELABEL),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWREMAINTIMELABEL_TP),
            getFunction = function ()
                return Settings.RemainingText
            end,
            setFunction = function (v)
                Settings.RemainingText = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.RemainingText,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Buff Label Position
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            format = "%.0f",
            label = GetString(LUIE_STRING_LAM_CI_SHARED_POSITION),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LABEL_POSITION_TP),
            min = -64,
            max = 64,
            step = 2,
            getFunction = function ()
                return Settings.LabelPosition
            end,
            setFunction = function (v)
                Settings.LabelPosition = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.LabelPosition,
            disable = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }

        -- Buff Label Font
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_FONT_TP),
            items = SettingsAPI:GetFontsList(),
            getFunction = function ()
                return Settings.BuffFontFace
            end,
            setFunction = function (v)
                Settings.BuffFontFace = v
                SpellCastBuffs.ApplyFont()
            end,
            default = Defaults.BuffFontFace,
            disable = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }

        -- Buff Font Size
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            format = "%.0f",
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            getFunction = function ()
                return Settings.BuffFontSize
            end,
            setFunction = function (v)
                Settings.BuffFontSize = v
                SpellCastBuffs.ApplyFont()
            end,
            default = Defaults.BuffFontSize,
            disable = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }

        -- Buff Font Style
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_FONTSTYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
                    if Settings.BuffFontStyle == choiceValue then
                        return LUIE.FONT_STYLE_CHOICES[i]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (v)
                for i, choiceName in ipairs(LUIE.FONT_STYLE_CHOICES) do
                    if v == choiceName then
                        Settings.BuffFontStyle = LUIE.FONT_STYLE_CHOICES_VALUES[i]
                        SpellCastBuffs.ApplyFont()
                        return
                    end
                end
            end,
            default = Defaults.BuffFontStyle,
            disable = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }

        -- Buff Colored Label
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_POTION_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LABELCOLOR_TP),
            getFunction = function ()
                return Settings.RemainingTextColoured
            end,
            setFunction = function (v)
                Settings.RemainingTextColoured = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.RemainingTextColoured,
            disable = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }

        -- Buff Show Seconds Fractions
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
            getFunction = function ()
                return Settings.RemainingTextMillis
            end,
            setFunction = function (v)
                Settings.RemainingTextMillis = v
            end,
            default = Defaults.RemainingTextMillis,
            disable = function ()
                return not (Settings.RemainingText and LUIE.SV.SpellCastBuff_Enable)
            end,
        }

        -- Buff Glow Icon Border
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_GLOWICONBORDER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_GLOWICONBORDER_TP),
            getFunction = function ()
                return Settings.GlowIcons
            end,
            setFunction = function (v)
                Settings.GlowIcons = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.GlowIcons,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Buff Show Border Cooldown
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_SHOWBORDERCOOLDOWN),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWBORDERCOOLDOWN_TP),
            getFunction = function ()
                return Settings.RemainingCooldown
            end,
            setFunction = function (v)
                Settings.RemainingCooldown = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.RemainingCooldown,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Buff Fade Expiring Icon
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_FADEEXPIREICON),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_FADEEXPIREICON_TP),
            getFunction = function ()
                return Settings.FadeOutIcons
            end,
            setFunction = function (v)
                Settings.FadeOutIcons = v
            end,
            default = Defaults.FadeOutIcons,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Icon Normalization Options
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_NORMALIZE_HEADER),
        }

        -- Use Generic Icon for CC Type
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_TP),
            getFunction = function ()
                return Settings.UseDefaultIcon
            end,
            setFunction = function (v)
                Settings.UseDefaultIcon = v
            end,
            default = Defaults.UseDefaultIcon,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Generic Icon Options
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS_TP),
            items = SettingsAPI:GetGlobalIconOptionsList(),
            getFunction = function ()
                local index = Settings.DefaultIconOptions
                if type(index) == "string" then
                    index = globalIconOptionsKeys[index] or 1
                end
                return globalIconOptions[index] or globalIconOptions[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.DefaultIconOptions = item.data
            end,
            default = globalIconOptions[Defaults.DefaultIconOptions],
            disable = function ()
                return not Settings.UseDefaultIcon
            end,
        }
    end)

    -- Build Color Options Section
    buildSectionSettings("Color", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure color options for buffs and debuffs.",
        }

        -- Basic Color Options
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER_BASIC),
        }

        -- buff
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_BUFF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_BUFF_TP),
            getFunction = function ()
                return Settings.colors.buff[1], Settings.colors.buff[2], Settings.colors.buff[3], Settings.colors.buff[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.buff = { r, g, b, a }
            end,
            default = Defaults.colors.buff,
        }

        -- debuff
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_DEBUFF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_DEBUFF_TP),
            getFunction = function ()
                return Settings.colors.debuff[1], Settings.colors.debuff[2], Settings.colors.debuff[3], Settings.colors.debuff[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.debuff = { r, g, b, a }
            end,
            default = Defaults.colors.debuff,
        }

        -- prioritybuff
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYBUFF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYBUFF_TP),
            getFunction = function ()
                return Settings.colors.prioritybuff[1], Settings.colors.prioritybuff[2], Settings.colors.prioritybuff[3], Settings.colors.prioritybuff[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.prioritybuff = { r, g, b, a }
            end,
            default = Defaults.colors.prioritybuff,
        }

        -- prioritydebuff
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYDEBUFF),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_PRIORITYDEBUFF_TP),
            getFunction = function ()
                return Settings.colors.prioritydebuff[1], Settings.colors.prioritydebuff[2], Settings.colors.prioritydebuff[3], Settings.colors.prioritydebuff[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.prioritydebuff = { r, g, b, a }
            end,
            default = Defaults.colors.prioritydebuff,
        }

        -- Unbreakable & Cosmetic Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER_UNBREAKABLE),
        }

        -- Unbreakable Toggle
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE_TOGGLE_TP),
            getFunction = function ()
                return Settings.ColorUnbreakable
            end,
            setFunction = function (v)
                Settings.ColorUnbreakable = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ColorUnbreakable,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- unbreakable
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_UNBREAKABLE_TP),
            getFunction = function ()
                return Settings.colors.unbreakable[1], Settings.colors.unbreakable[2], Settings.colors.unbreakable[3], Settings.colors.unbreakable[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.unbreakable = { r, g, b, a }
            end,
            default = Defaults.colors.unbreakable,
            disable = function ()
                return not Settings.ColorUnbreakable
            end,
        }

        -- Cosmetic Toggle
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC_TOGGLE_TP),
            getFunction = function ()
                return Settings.ColorCosmetic
            end,
            setFunction = function (v)
                Settings.ColorCosmetic = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ColorCosmetic,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- cosmetic
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_COSMETIC_TP),
            getFunction = function ()
                return Settings.colors.cosmetic[1], Settings.colors.cosmetic[2], Settings.colors.cosmetic[3], Settings.colors.cosmetic[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.cosmetic = { r, g, b, a }
            end,
            default = Defaults.colors.cosmetic,
            disable = function ()
                return not Settings.ColorCosmetic
            end,
        }

        -- Crowd Control Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER_CROWD_CONTROL),
        }

        -- CC Toggle
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_BY_CC),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_BY_CC_TP),
            getFunction = function ()
                return Settings.ColorCC
            end,
            setFunction = function (v)
                Settings.ColorCC = v
                SpellCastBuffs.ReloadEffects("player")
            end,
            default = Defaults.ColorCC,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- nocc
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_NOCC),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_NOCC_TP),
            getFunction = function ()
                return Settings.colors.nocc[1], Settings.colors.nocc[2], Settings.colors.nocc[3], Settings.colors.nocc[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.nocc = { r, g, b, a }
            end,
            default = Defaults.colors.nocc,
            disable = function ()
                return not Settings.ColorCC
            end,
        }

        -- stun
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_STUN),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_STUN_TP),
            getFunction = function ()
                return Settings.colors.stun[1], Settings.colors.stun[2], Settings.colors.stun[3], Settings.colors.stun[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.stun = { r, g, b, a }
            end,
            default = Defaults.colors.stun,
            disable = function ()
                return not Settings.ColorCC
            end,
        }

        -- knockback
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_KNOCKBACK),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_KNOCKBACK_TP),
            getFunction = function ()
                return Settings.colors.knockback[1], Settings.colors.knockback[2], Settings.colors.knockback[3], Settings.colors.knockback[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.knockback = { r, g, b, a }
            end,
            default = Defaults.colors.knockback,
            disable = function ()
                return not Settings.ColorCC
            end,
        }

        -- levitate
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_LEVITATE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_LEVITATE_TP),
            getFunction = function ()
                return Settings.colors.levitate[1], Settings.colors.levitate[2], Settings.colors.levitate[3], Settings.colors.levitate[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.levitate = { r, g, b, a }
            end,
            default = Defaults.colors.levitate,
            disable = function ()
                return not Settings.ColorCC
            end,
        }

        -- disorient
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_DISORIENT),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_DISORIENT_TP),
            getFunction = function ()
                return Settings.colors.disorient[1], Settings.colors.disorient[2], Settings.colors.disorient[3], Settings.colors.disorient[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.disorient = { r, g, b, a }
            end,
            default = Defaults.colors.disorient,
            disable = function ()
                return not Settings.ColorCC
            end,
        }

        -- fear
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_FEAR),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_FEAR_TP),
            getFunction = function ()
                return Settings.colors.fear[1], Settings.colors.fear[2], Settings.colors.fear[3], Settings.colors.fear[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.fear = { r, g, b, a }
            end,
            default = Defaults.colors.fear,
            disable = function ()
                return not Settings.ColorCC
            end,
        }

        -- charm
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_CHARM),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_CHARM_TP),
            getFunction = function ()
                return Settings.colors.charm[1], Settings.colors.charm[2], Settings.colors.charm[3], Settings.colors.charm[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.charm = { r, g, b, a }
            end,
            default = Defaults.colors.charm,
            disable = function ()
                return not Settings.ColorCC
            end,
        }

        -- stagger
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_STAGGER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_STAGGER_TP),
            getFunction = function ()
                return Settings.colors.stagger[1], Settings.colors.stagger[2], Settings.colors.stagger[3], Settings.colors.stagger[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.stagger = { r, g, b, a }
            end,
            default = Defaults.colors.stagger,
            disable = function ()
                return not Settings.ColorCC
            end,
        }

        -- silence
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_SILENCE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_SILENCE_TP),
            getFunction = function ()
                return Settings.colors.silence[1], Settings.colors.silence[2], Settings.colors.silence[3], Settings.colors.silence[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.silence = { r, g, b, a }
            end,
            default = Defaults.colors.silence,
            disable = function ()
                return not Settings.ColorCC
            end,
        }

        -- snare
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_SNARE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_SNARE_TP),
            getFunction = function ()
                return Settings.colors.snare[1], Settings.colors.snare[2], Settings.colors.snare[3], Settings.colors.snare[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.snare = { r, g, b, a }
            end,
            default = Defaults.colors.snare,
            disable = function ()
                return not Settings.ColorCC
            end,
        }

        -- root
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_COLOR_ROOT),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_COLOR_ROOT_TP),
            getFunction = function ()
                return Settings.colors.root[1], Settings.colors.root[2], Settings.colors.root[3], Settings.colors.root[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.colors.root = { r, g, b, a }
            end,
            default = Defaults.colors.root,
            disable = function ()
                return not Settings.ColorCC
            end,
        }
    end)

    -- Build Alignment & Sorting Options Section
    buildSectionSettings("AlignmentSorting", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_SORTING_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure alignment and sorting options for buffs and debuffs.",
        }

        -- Buffs/Debuffs Alignment & Sorting
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_SORTING_NORMAL_HEADER),
        }

        -- Buff Alignment (BuffsPlayer)
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
            items =
            {
                { name = "Left",     data = "Left"     },
                { name = "Centered", data = "Centered" },
                { name = "Right",    data = "Right"    },
            },
            getFunction = function ()
                local value = Settings.AlignmentBuffsPlayer
                if value == "Left" or value == "Centered" or value == "Right" then
                    return value
                end
                return Defaults.AlignmentBuffsPlayer or "Left"
            end,
            setFunction = function (combobox, value, item)
                Settings.AlignmentBuffsPlayer = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.AlignmentBuffsPlayer or "Left",
        }

        -- Buff Sort Direction (BuffsPlayer)
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
            items =
            {
                { name = "Left to Right", data = "Left to Right" },
                { name = "Right to Left", data = "Right to Left" },
            },
            getFunction = function ()
                local value = Settings.SortBuffsPlayer
                if value == "Left to Right" or value == "Right to Left" then
                    return value
                end
                return Defaults.SortBuffsPlayer or "Left to Right"
            end,
            setFunction = function (combobox, value, item)
                Settings.SortBuffsPlayer = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.SortBuffsPlayer or "Left to Right",
        }

        -- Buff Alignment (DebuffsPlayer)
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
            items =
            {
                { name = "Left",     data = "Left"     },
                { name = "Centered", data = "Centered" },
                { name = "Right",    data = "Right"    },
            },
            getFunction = function ()
                local value = Settings.AlignmentDebuffsPlayer
                if value == "Left" or value == "Centered" or value == "Right" then
                    return value
                end
                return Defaults.AlignmentDebuffsPlayer or "Left"
            end,
            setFunction = function (combobox, value, item)
                Settings.AlignmentDebuffsPlayer = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.AlignmentDebuffsPlayer or "Left",
        }

        -- Buff Sort Direction (DebuffsPlayer)
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
            items =
            {
                { name = "Left to Right", data = "Left to Right" },
                { name = "Right to Left", data = "Right to Left" },
            },
            getFunction = function ()
                local value = Settings.SortDebuffsPlayer
                if value == "Left to Right" or value == "Right to Left" then
                    return value
                end
                return Defaults.SortDebuffsPlayer or "Left to Right"
            end,
            setFunction = function (combobox, value, item)
                Settings.SortDebuffsPlayer = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.SortDebuffsPlayer or "Left to Right",
        }

        -- Buff Alignment (BuffsTarget)
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
            items =
            {
                { name = "Left",     data = "Left"     },
                { name = "Centered", data = "Centered" },
                { name = "Right",    data = "Right"    },
            },
            getFunction = function ()
                local value = Settings.AlignmentBuffsTarget
                if value == "Left" or value == "Centered" or value == "Right" then
                    return value
                end
                return Defaults.AlignmentBuffsTarget or "Left"
            end,
            setFunction = function (combobox, value, item)
                Settings.AlignmentBuffsTarget = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.AlignmentBuffsTarget or "Left",
        }

        -- Buff Sort Direction (BuffsTarget)
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
            items =
            {
                { name = "Left to Right", data = "Left to Right" },
                { name = "Right to Left", data = "Right to Left" },
            },
            getFunction = function ()
                local value = Settings.SortBuffsTarget
                if value == "Left to Right" or value == "Right to Left" then
                    return value
                end
                return Defaults.SortBuffsTarget or "Left to Right"
            end,
            setFunction = function (combobox, value, item)
                Settings.SortBuffsTarget = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.SortBuffsTarget or "Left to Right",
        }

        -- Buff Alignment (DebuffsTarget)
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_GENERIC_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
            items =
            {
                { name = "Left",     data = "Left"     },
                { name = "Centered", data = "Centered" },
                { name = "Right",    data = "Right"    },
            },
            getFunction = function ()
                local value = Settings.AlignmentDebuffsTarget
                if value == "Left" or value == "Centered" or value == "Right" then
                    return value
                end
                return Defaults.AlignmentDebuffsTarget or "Left"
            end,
            setFunction = function (combobox, value, item)
                Settings.AlignmentDebuffsTarget = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.AlignmentDebuffsTarget or "Left",
        }

        -- Buff Sort Direction (DebuffsTarget)
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
            items =
            {
                { name = "Left to Right", data = "Left to Right" },
                { name = "Right to Left", data = "Right to Left" },
            },
            getFunction = function ()
                local value = Settings.SortDebuffsTarget
                if value == "Left to Right" or value == "Right to Left" then
                    return value
                end
                return Defaults.SortDebuffsTarget or "Left to Right"
            end,
            setFunction = function (combobox, value, item)
                Settings.SortDebuffsTarget = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.SortDebuffsTarget or "Left to Right",
        }

        -- Unanchored Player / Target Buff Options
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_SORTING_UNANCHORED_HEADER),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_BUFF_SORTING_UNANCHORED_DESCRIPTION),
        }

        -- Buff Width - Player Buffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            format = "%.0f",
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
            min = 40,
            max = 1920,
            step = 10,
            getFunction = function ()
                return Settings.WidthPlayerBuffs
            end,
            setFunction = function (v)
                Settings.WidthPlayerBuffs = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.WidthPlayerBuffs,
            disable = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }

        -- Buff Stack Direction - Player Buffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS)),
            items =
            {
                { name = "Down", data = "Down" },
                { name = "Up",   data = "Up"   },
            },
            getFunction = function ()
                return Settings.StackPlayerBuffs
            end,
            setFunction = function (v)
                Settings.StackPlayerBuffs = v
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.StackPlayerBuffs,
            disable = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }

        -- Buff Width - Player Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            format = "%.0f",
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
            min = 40,
            max = 1920,
            step = 10,
            getFunction = function ()
                return Settings.WidthPlayerDebuffs
            end,
            setFunction = function (v)
                Settings.WidthPlayerDebuffs = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.WidthPlayerDebuffs,
            disable = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }

        -- Buff Stack Direction - Player Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS)),
            items =
            {
                { name = "Down", data = "Down" },
                { name = "Up",   data = "Up"   },
            },
            getFunction = function ()
                return Settings.StackPlayerDebuffs
            end,
            setFunction = function (v)
                Settings.StackPlayerDebuffs = v
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.StackPlayerDebuffs,
            disable = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }

        -- Buff Width - Target Buffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            format = "%.0f",
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
            min = 40,
            max = 1920,
            step = 10,
            getFunction = function ()
                return Settings.WidthTargetBuffs
            end,
            setFunction = function (v)
                Settings.WidthTargetBuffs = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.WidthTargetBuffs,
            disable = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }

        -- Buff Stack Direction - Target Buffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS)),
            items =
            {
                { name = "Down", data = "Down" },
                { name = "Up",   data = "Up"   },
            },
            getFunction = function ()
                return Settings.StackTargetBuffs
            end,
            setFunction = function (v)
                Settings.StackTargetBuffs = v
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.StackTargetBuffs,
            disable = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }

        -- Buff Width - Target Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            format = "%.0f",
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_WIDTH_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
            min = 40,
            max = 1920,
            step = 10,
            getFunction = function ()
                return Settings.WidthTargetDebuffs
            end,
            setFunction = function (v)
                Settings.WidthTargetDebuffs = v
                SpellCastBuffs.Reset()
            end,
            default = Defaults.WidthTargetDebuffs,
            disable = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }

        -- Buff Stack Direction - Target Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_STACK_GENERIC_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS)),
            items =
            {
                { name = "Down", data = "Down" },
                { name = "Up",   data = "Up"   },
            },
            getFunction = function ()
                return Settings.StackTargetDebuffs
            end,
            setFunction = function (v)
                Settings.StackTargetDebuffs = v
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.StackTargetDebuffs,
            disable = function ()
                return Settings.lockPositionToUnitFrames
            end,
        }

        -- Long Term Alignment & Sorting
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_SORTING_LONGTERM_HEADER),
        }

        -- Container Orientation (Long Term)
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CONTAINER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_LONGTERM_CONTAINER_TP),
            items = SettingsAPI:GetRotationOptionsList(),
            getFunction = function ()
                local index = Settings.LongTermEffectsSeparateAlignment
                if type(index) == "string" then
                    index = rotationOptionsKeys[index] or 2
                end
                return rotationOptions[index] or rotationOptions[2]
            end,
            setFunction = function (combobox, value, item)
                Settings.LongTermEffectsSeparateAlignment = item.data
                SpellCastBuffs.ResetContainerOrientation()
                SpellCastBuffs.Reset()
            end,
            default = rotationOptions[2],
        }

        -- Horizontal Long Term Icons Alignment
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
            items =
            {
                { name = "Left",     data = "Left"     },
                { name = "Centered", data = "Centered" },
                { name = "Right",    data = "Right"    },
            },
            getFunction = function ()
                local value = Settings.AlignmentLongHorz
                if value == "Left" or value == "Centered" or value == "Right" then
                    return value
                end
                return Defaults.AlignmentLongHorz or "Left"
            end,
            setFunction = function (combobox, value, item)
                Settings.AlignmentLongHorz = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.AlignmentLongHorz or "Left",
            disable = function ()
                return Settings.LongTermEffectsSeparateAlignment == 2
            end,
        }

        -- Horizontal Long Term Sort
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
            items =
            {
                { name = "Left to Right", data = "Left to Right" },
                { name = "Right to Left", data = "Right to Left" },
            },
            getFunction = function ()
                local value = Settings.SortLongHorz
                if value == "Left to Right" or value == "Right to Left" then
                    return value
                end
                return Defaults.SortLongHorz or "Left to Right"
            end,
            setFunction = function (combobox, value, item)
                Settings.SortLongHorz = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.SortLongHorz or "Left to Right",
            disable = function ()
                return Settings.LongTermEffectsSeparateAlignment == 2
            end,
        }

        -- Vertical Long Term Icons Alignment
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
            items =
            {
                { name = "Top",      data = "Top"      },
                { name = "Centered", data = "Centered" },
                { name = "Bottom",   data = "Bottom"   },
            },
            getFunction = function ()
                local value = Settings.AlignmentLongVert
                if value == "Top" or value == "Centered" or value == "Bottom" then
                    return value
                end
                return Defaults.AlignmentLongVert or "Top"
            end,
            setFunction = function (combobox, value, item)
                Settings.AlignmentLongVert = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.AlignmentLongVert or "Top",
            disable = function ()
                return Settings.LongTermEffectsSeparateAlignment == 1
            end,
        }

        -- Vertical Long Term Sort
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS)),
            items =
            {
                { name = "Bottom to Top", data = "Bottom to Top" },
                { name = "Top to Bottom", data = "Top to Bottom" },
            },
            getFunction = function ()
                local value = Settings.SortLongVert
                if value == "Bottom to Top" or value == "Top to Bottom" then
                    return value
                end
                return Defaults.SortLongVert or "Bottom to Top"
            end,
            setFunction = function (combobox, value, item)
                Settings.SortLongVert = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.SortLongVert or "Bottom to Top",
            disable = function ()
                return Settings.LongTermEffectsSeparateAlignment == 1
            end,
        }

        -- Prominent Alignment & Sorting
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_SORTING_PROMINET_HEADER),
        }

        -- Prominent Buff Container Orientation
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFCONTAINER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFCONTAINER_TP),
            items = SettingsAPI:GetRotationOptionsList(),
            getFunction = function ()
                local index = Settings.ProminentBuffContainerAlignment
                if type(index) == "string" then
                    index = rotationOptionsKeys[index] or 2
                end
                return rotationOptions[index] or rotationOptions[2]
            end,
            setFunction = function (combobox, value, item)
                Settings.ProminentBuffContainerAlignment = item.data
                SpellCastBuffs.ResetContainerOrientation()
                SpellCastBuffs.Reset()
            end,
            default = rotationOptions[2],
        }

        -- Horizontal Prominent Buffs Icons Alignment
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
            items =
            {
                { name = "Left",     data = "Left"     },
                { name = "Centered", data = "Centered" },
                { name = "Right",    data = "Right"    },
            },
            getFunction = function ()
                local value = Settings.AlignmentPromBuffsHorz
                if value == "Left" or value == "Centered" or value == "Right" then
                    return value
                end
                return Defaults.AlignmentPromBuffsHorz or "Left"
            end,
            setFunction = function (combobox, value, item)
                Settings.AlignmentPromBuffsHorz = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.AlignmentPromBuffsHorz or "Left",
            disable = function ()
                return Settings.ProminentBuffContainerAlignment == 2
            end,
        }

        -- Horizontal Prominent Buffs Sort
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
            items =
            {
                { name = "Left to Right", data = "Left to Right" },
                { name = "Right to Left", data = "Right to Left" },
            },
            getFunction = function ()
                local value = Settings.SortPromBuffsHorz
                if value == "Left to Right" or value == "Right to Left" then
                    return value
                end
                return Defaults.SortPromBuffsHorz or "Left to Right"
            end,
            setFunction = function (combobox, value, item)
                Settings.SortPromBuffsHorz = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.SortPromBuffsHorz or "Left to Right",
            disable = function ()
                return Settings.ProminentBuffContainerAlignment == 2
            end,
        }

        -- Vertical Prominent Buffs Icons Alignment
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
            items =
            {
                { name = "Top",      data = "Top"      },
                { name = "Centered", data = "Centered" },
                { name = "Bottom",   data = "Bottom"   },
            },
            getFunction = function ()
                local value = Settings.AlignmentPromBuffsVert
                if value == "Top" or value == "Centered" or value == "Bottom" then
                    return value
                end
                return Defaults.AlignmentPromBuffsVert or "Top"
            end,
            setFunction = function (combobox, value, item)
                Settings.AlignmentPromBuffsVert = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.AlignmentPromBuffsVert or "Top",
            disable = function ()
                return Settings.ProminentBuffContainerAlignment == 1
            end,
        }

        -- Vertical Prominent Buffs Sort
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS)),
            items =
            {
                { name = "Bottom to Top", data = "Bottom to Top" },
                { name = "Top to Bottom", data = "Top to Bottom" },
            },
            getFunction = function ()
                local value = Settings.SortPromBuffsVert
                if value == "Bottom to Top" or value == "Top to Bottom" then
                    return value
                end
                return Defaults.SortPromBuffsVert or "Bottom to Top"
            end,
            setFunction = function (combobox, value, item)
                Settings.SortPromBuffsVert = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.SortPromBuffsVert or "Bottom to Top",
            disable = function ()
                return Settings.ProminentBuffContainerAlignment == 1
            end,
        }

        -- Prominent Debuff Container Orientation
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFCONTAINER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFCONTAINER_TP),
            items = SettingsAPI:GetRotationOptionsList(),
            getFunction = function ()
                local index = Settings.ProminentDebuffContainerAlignment
                if type(index) == "string" then
                    index = rotationOptionsKeys[index] or 2
                end
                return rotationOptions[index] or rotationOptions[2]
            end,
            setFunction = function (combobox, value, item)
                Settings.ProminentDebuffContainerAlignment = item.data
                SpellCastBuffs.ResetContainerOrientation()
                SpellCastBuffs.Reset()
            end,
            default = rotationOptions[2],
        }

        -- Horizontal Prominent Debuffs Icons Alignment
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_HORIZONTAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
            items =
            {
                { name = "Left",     data = "Left"     },
                { name = "Centered", data = "Centered" },
                { name = "Right",    data = "Right"    },
            },
            getFunction = function ()
                local value = Settings.AlignmentPromDebuffsHorz
                if value == "Left" or value == "Centered" or value == "Right" then
                    return value
                end
                return Defaults.AlignmentPromDebuffsHorz or "Left"
            end,
            setFunction = function (combobox, value, item)
                Settings.AlignmentPromDebuffsHorz = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.AlignmentPromDebuffsHorz or "Left",
            disable = function ()
                return Settings.ProminentDebuffContainerAlignment == 2
            end,
        }

        -- Horizontal Prominent Debuffs Sort
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_HORIZONTAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
            items =
            {
                { name = "Left to Right", data = "Left to Right" },
                { name = "Right to Left", data = "Right to Left" },
            },
            getFunction = function ()
                local value = Settings.SortPromDebuffsHorz
                if value == "Left to Right" or value == "Right to Left" then
                    return value
                end
                return Defaults.SortPromDebuffsHorz or "Left to Right"
            end,
            setFunction = function (combobox, value, item)
                Settings.SortPromDebuffsHorz = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.SortPromDebuffsHorz,
            disable = function ()
                return Settings.ProminentDebuffContainerAlignment == 2
            end,
        }

        -- Vertical Prominent Debuffs Icons Alignment
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_VERTICAL_ALIGN_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
            items =
            {
                { name = "Top",      data = "Top"      },
                { name = "Centered", data = "Centered" },
                { name = "Bottom",   data = "Bottom"   },
            },
            getFunction = function ()
                local value = Settings.AlignmentPromDebuffsVert
                if value == "Top" or value == "Centered" or value == "Bottom" then
                    return value
                end
                return Defaults.AlignmentPromDebuffsVert or "Top"
            end,
            setFunction = function (combobox, value, item)
                Settings.AlignmentPromDebuffsVert = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.AlignmentPromDebuffsVert or "Top",
            disable = function ()
                return Settings.ProminentDebuffContainerAlignment == 1
            end,
        }

        -- Vertical Prominent Debuffs Sort
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_BUFF_SORTING_SORT_VERTICAL_TP), GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS)),
            items =
            {
                { name = "Bottom to Top", data = "Bottom to Top" },
                { name = "Top to Bottom", data = "Top to Bottom" },
            },
            getFunction = function ()
                local value = Settings.SortPromDebuffsVert
                if value == "Bottom to Top" or value == "Top to Bottom" then
                    return value
                end
                return Defaults.SortPromDebuffsVert or "Bottom to Top"
            end,
            setFunction = function (combobox, value, item)
                Settings.SortPromDebuffsVert = item.data
                SpellCastBuffs.SetupContainerAlignment()
                SpellCastBuffs.SetupContainerSort()
            end,
            default = Defaults.SortPromDebuffsVert or "Bottom to Top",
            disable = function ()
                return Settings.ProminentDebuffContainerAlignment == 1
            end,
        }
    end)

    -- Build Tooltip Options Section
    buildSectionSettings("Tooltip", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure tooltip display options for buffs and debuffs.",
        }

        -- Tooltip Enable
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ENABLE_TP),
            getFunction = function ()
                return Settings.TooltipEnable
            end,
            setFunction = function (v)
                Settings.TooltipEnable = v
            end,
            default = Defaults.TooltipEnable,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Tooltip Custom
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_CUSTOM),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_CUSTOM_TP),
            getFunction = function ()
                return Settings.TooltipCustom
            end,
            setFunction = function (v)
                Settings.TooltipCustom = v
            end,
            default = Defaults.TooltipCustom,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Tooltip Ability Id
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ABILITY_ID),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_ABILITY_ID_TP),
            getFunction = function ()
                return Settings.TooltipAbilityId
            end,
            setFunction = function (v)
                Settings.TooltipAbilityId = v
            end,
            default = Defaults.TooltipAbilityId,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Tooltip Buff Type
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_BUFF_TYPE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_BUFF_TYPE_TP),
            getFunction = function ()
                return Settings.TooltipBuffType
            end,
            setFunction = function (v)
                Settings.TooltipBuffType = v
            end,
            default = Defaults.TooltipBuffType,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Sticky Tooltip Slider
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_STICKY),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_STICKY_TP),
            min = 0,
            max = 5000,
            step = 100,
            getFunction = function ()
                return Settings.TooltipSticky
            end,
            setFunction = function (value)
                Settings.TooltipSticky = value
            end,
            default = Defaults.TooltipSticky,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }
    end)

    -- Build Priority Buffs & Debuffs Options Section
    buildSectionSettings("Priority", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DESCRIPTION),
        }

        -- Prominent Buffs & Debuffs Description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DESCRIPTION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DIALOGUE_DESCRIPT),
        }

        -- Store temp text for adding priority buffs
        if not Settings.tempPriorityBuffsText then
            Settings.tempPriorityBuffsText = ""
        end

        -- Add Priority Buff edit box
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunction = function ()
                return Settings.tempPriorityBuffsText or ""
            end,
            setFunction = function (value)
                Settings.tempPriorityBuffsText = value
            end,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Add Priority Buff button
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
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
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Manage Priority Buffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_BUFF_REMLIST_TP),
            clickHandler = function ()
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_PRIORITY_BUFFS")
            end,
            buttonText = GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_BUFFS),
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Clear Priority Buffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_BUFFS),
            tooltip = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_BUFFS_TP),
            clickHandler = function ()
                ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_PRIORITY_BUFFS")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_BUFFS),
        }

        -- Store temp text for adding priority debuffs
        if not Settings.tempPriorityDebuffsText then
            Settings.tempPriorityDebuffsText = ""
        end

        -- Add Priority Debuff edit box
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunction = function ()
                return Settings.tempPriorityDebuffsText or ""
            end,
            setFunction = function (value)
                Settings.tempPriorityDebuffsText = value
            end,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Add Priority Debuff button
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
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
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Manage Priority Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PRIORITY_DEBUFF_REMLIST_TP),
            clickHandler = function ()
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_PRIORITY_DEBUFFS")
            end,
            buttonText = GetString(LUIE_STRING_CUSTOM_LIST_PRIORITY_DEBUFFS),
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Clear Priority Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_DEBUFFS),
            tooltip = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_DEBUFFS_TP),
            clickHandler = function ()
                ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_PRIORITY_DEBUFFS")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_PRIORITY_CLEAR_DEBUFFS),
        }
    end)

    -- Build Prominent Buffs & Debuffs Options Section
    buildSectionSettings("Prominent", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_DESCRIPTION),
        }

        -- Prominent Buffs Label Toggle
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_LABEL),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_LABEL_TP),
            getFunction = function ()
                return Settings.ProminentLabel
            end,
            setFunction = function (value)
                Settings.ProminentLabel = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ProminentLabel,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Prominent Buffs Label Font Face
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTFACE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTFACE_TP),
            items = SettingsAPI:GetFontsList(),
            getFunction = function ()
                return Settings.ProminentLabelFontFace
            end,
            setFunction = function (combobox, value, item)
                Settings.ProminentLabelFontFace = item.data or item.name or value
                SpellCastBuffs.ApplyFont()
            end,
            default = Defaults.ProminentLabelFontFace,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentLabel)
            end,
        }

        -- Prominent Buffs Label Font Size
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSIZE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            getFunction = function ()
                return Settings.ProminentLabelFontSize
            end,
            setFunction = function (value)
                Settings.ProminentLabelFontSize = value
                SpellCastBuffs.ApplyFont()
            end,
            default = Defaults.ProminentLabelFontSize,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentLabel)
            end,
        }

        -- Prominent Buffs Label Font Style
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSTYLE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_FONTSTYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                return Settings.ProminentLabelFontStyle
            end,
            setFunction = function (combobox, value, item)
                Settings.ProminentLabelFontStyle = item.data or item.name or value
                SpellCastBuffs.ApplyFont()
            end,
            default = Defaults.ProminentLabelFontStyle,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentLabel)
            end,
        }

        -- Prominent Buffs Progress Bar
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR_TP),
            getFunction = function ()
                return Settings.ProminentProgress
            end,
            setFunction = function (value)
                Settings.ProminentProgress = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ProminentProgress,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Prominent Buffs Progress Bar Texture
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR_TEXTURE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_PROGRESSBAR_TEXTURE_TP),
            items = statusbarTextureItems,
            getFunction = function ()
                return Settings.ProminentProgressTexture
            end,
            setFunction = function (combobox, value, item)
                Settings.ProminentProgressTexture = item.data or item.name or value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ProminentProgressTexture,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
            end,
        }

        -- Prominent Buffs Gradient Color 1
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF1),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF1_TP),
            getFunction = function ()
                return Settings.ProminentProgressBuffC1[1], Settings.ProminentProgressBuffC1[2], Settings.ProminentProgressBuffC1[3], Settings.ProminentProgressBuffC1[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.ProminentProgressBuffC1 = { r, g, b, a }
                SpellCastBuffs.Reset()
            end,
            default = Settings.ProminentProgressBuffC1,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
            end
        }

        -- Prominent Buffs Gradient Color 2
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF2),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFF2_TP),
            getFunction = function ()
                return Settings.ProminentProgressBuffC2[1], Settings.ProminentProgressBuffC2[2], Settings.ProminentProgressBuffC2[3], Settings.ProminentProgressBuffC2[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.ProminentProgressBuffC2 = { r, g, b, a }
                SpellCastBuffs.Reset()
            end,
            default = Settings.ProminentProgressBuffC2,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
            end
        }

        -- Prominent Buffs Gradient Color 1 (Priority)
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY1),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY1_TP),
            getFunction = function ()
                return Settings.ProminentProgressBuffPriorityC1[1], Settings.ProminentProgressBuffPriorityC1[2], Settings.ProminentProgressBuffPriorityC1[3], Settings.ProminentProgressBuffPriorityC1[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.ProminentProgressBuffPriorityC1 = { r, g, b, a }
                SpellCastBuffs.Reset()
            end,
            default = Settings.ProminentProgressBuffPriorityC1,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
            end
        }

        -- Prominent Buffs Gradient Color 2 (Priority)
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY2),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORBUFFPRIORITY2_TP),
            getFunction = function ()
                return Settings.ProminentProgressBuffPriorityC2[1], Settings.ProminentProgressBuffPriorityC2[2], Settings.ProminentProgressBuffPriorityC2[3], Settings.ProminentProgressBuffPriorityC2[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.ProminentProgressBuffPriorityC2 = { r, g, b, a }
                SpellCastBuffs.Reset()
            end,
            default = Settings.ProminentProgressBuffPriorityC2,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
            end
        }

        -- Prominent Debuffs Gradient Color 1
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF1),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF1_TP),
            getFunction = function ()
                return Settings.ProminentProgressDebuffC1[1], Settings.ProminentProgressDebuffC1[2], Settings.ProminentProgressDebuffC1[3], Settings.ProminentProgressDebuffC1[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.ProminentProgressDebuffC1 = { r, g, b, a }
                SpellCastBuffs.Reset()
            end,
            default = Settings.ProminentProgressDebuffC1,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
            end
        }

        -- Prominent Debuffs Gradient Color 2
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF2),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFF2_TP),
            getFunction = function ()
                return Settings.ProminentProgressDebuffC2[1], Settings.ProminentProgressDebuffC2[2], Settings.ProminentProgressDebuffC2[3], Settings.ProminentProgressDebuffC2[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.ProminentProgressDebuffC2 = { r, g, b, a }
                SpellCastBuffs.Reset()
            end,
            default = Settings.ProminentProgressDebuffC2,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
            end
        }

        -- Prominent Debuffs Gradient Color 1 (Priority)
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY1),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY1_TP),
            getFunction = function ()
                return Settings.ProminentProgressDebuffPriorityC1[1], Settings.ProminentProgressDebuffPriorityC1[2], Settings.ProminentProgressDebuffPriorityC1[3], Settings.ProminentProgressDebuffPriorityC1[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.ProminentProgressDebuffPriorityC1 = { r, g, b, a }
                SpellCastBuffs.Reset()
            end,
            default = Settings.ProminentProgressDebuffPriorityC1,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
            end
        }

        -- Prominent Debuffs Gradient Color 2 (Priority)
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY2),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_COLORDEBUFFPRIORITY2_TP),
            getFunction = function ()
                return Settings.ProminentProgressDebuffPriorityC2[1], Settings.ProminentProgressDebuffPriorityC2[2], Settings.ProminentProgressDebuffPriorityC2[3], Settings.ProminentProgressDebuffPriorityC2[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.ProminentProgressDebuffPriorityC2 = { r, g, b, a }
                SpellCastBuffs.Reset()
            end,
            default = Settings.ProminentProgressDebuffPriorityC2,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and Settings.ProminentProgress)
            end
        }

        -- Prominent Buffs Label/Progress Bar Direction
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFLABELDIRECTION),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFFLABELDIRECTION_TP),
            items = { "Right", "Left" },
            getFunction = function ()
                return Settings.ProminentBuffLabelDirection
            end,
            setFunction = function (combobox, value, item)
                Settings.ProminentBuffLabelDirection = item.data or item.name or value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ProminentBuffLabelDirection,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.ProminentLabel or Settings.ProminentProgress))
            end,
        }

        -- Prominent Debuffs Label/Progress Bar Direction
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFLABELDIRECTION),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFFLABELDIRECTION_TP),
            items = { "Right", "Left" },
            getFunction = function ()
                return Settings.ProminentDebuffLabelDirection
            end,
            setFunction = function (combobox, value, item)
                Settings.ProminentDebuffLabelDirection = item.data or item.name or value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ProminentDebuffLabelDirection,
            disable = function ()
                return not (LUIE.SV.SpellCastBuff_Enable and (Settings.ProminentLabel or Settings.ProminentProgress))
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_BUFF_PROM_DIALOGUE_DESCRIPT),
        }

        -- Store temp text for adding prominent buffs
        if not Settings.tempProminentBuffsText then
            Settings.tempProminentBuffsText = ""
        end

        -- Add Prominent Buff edit box
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunction = function ()
                return Settings.tempProminentBuffsText or ""
            end,
            setFunction = function (value)
                Settings.tempProminentBuffsText = value
            end,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Add Prominent Buff button
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
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
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Manage Prominent Buffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_BUFF_REMLIST_TP),
            clickHandler = function ()
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_PROMINENT_BUFFS")
            end,
            buttonText = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS),
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Clear Prominent Buffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_BUFFS),
            tooltip = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_BUFFS_TP),
            clickHandler = function ()
                ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_PROMINENT_BUFFS")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_BUFFS),
        }

        -- Store temp text for adding prominent debuffs
        if not Settings.tempProminentDebuffsText then
            Settings.tempProminentDebuffsText = ""
        end

        -- Add Prominent Debuff edit box
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunction = function ()
                return Settings.tempProminentDebuffsText or ""
            end,
            setFunction = function (value)
                Settings.tempProminentDebuffsText = value
            end,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Add Prominent Debuff button
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
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
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Manage Prominent Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_PROM_DEBUFF_REMLIST_TP),
            clickHandler = function ()
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_PROMINENT_DEBUFFS")
            end,
            buttonText = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS),
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Clear Prominent Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_DEBUFFS),
            tooltip = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_DEBUFFS_TP),
            clickHandler = function ()
                ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_PROMINENT_DEBUFFS")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_PROMINENT_CLEAR_DEBUFFS),
        }
    end)

    -- Build Blacklist Section
    buildSectionSettings("Blacklist", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT),
        }

        -- Add Minor Buffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_BUFF),
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
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Add Major Buffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_BUFF),
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
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Add Minor Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MINOR_DEBUFF),
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
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Add Major Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADD_MAJOR_DEBUFF),
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
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Store temp text for adding items
        if not Settings.tempBlacklistText then
            Settings.tempBlacklistText = ""
        end

        -- Add Item edit box
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunction = function ()
                return Settings.tempBlacklistText or ""
            end,
            setFunction = function (value)
                Settings.tempBlacklistText = value
            end,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Add Item button
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
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
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Clear Blacklist
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
            tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
            clickHandler = function ()
                ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_ABILITY_BLACKLIST")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Manage Blacklist
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST_TP),
            clickHandler = function ()
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_BLACKLIST")
            end,
            buttonText = GetString(LUIE_STRING_CUSTOM_LIST_AURA_BLACKLIST),
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }
    end)

    -- Build Debug Options Section
    buildSectionSettings("Debug", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = "Debug Options",
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure debug options for development.",
        }

        -- Debug - Show AbilityId on Buffs & Debuffs
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show AbilityId on Buffs & Debuffs",
            tooltip = "Toggle the display of AbilityId on buffs and debuffs - useful for adding auras to Prominent Buffs & Debuffs or the Aura Blacklist.",
            getFunction = function ()
                return Settings.ShowDebugAbilityId
            end,
            setFunction = function (value)
                Settings.ShowDebugAbilityId = value
                SpellCastBuffs.Reset()
            end,
            default = Defaults.ShowDebugAbilityId,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Debug - Show Debug for Combat Events
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show Debug for Combat Events",
            tooltip = "Display debug information for combat events - used for development.",
            getFunction = function ()
                return Settings.ShowDebugCombat
            end,
            setFunction = function (value)
                Settings.ShowDebugCombat = value
                SpellCastBuffs.RegisterDebugEvents()
            end,
            default = Defaults.ShowDebugCombat,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Debug - Show Debug for Effect Change Events
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show Debug for Effect Change Events",
            tooltip = "Display debug information for effect change events - used for development.",
            getFunction = function ()
                return Settings.ShowDebugEffect
            end,
            setFunction = function (value)
                Settings.ShowDebugEffect = value
                SpellCastBuffs.RegisterDebugEvents()
            end,
            default = Defaults.ShowDebugEffect,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }

        -- Debug - Filter Debug Events & Effects
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Filter Debug Events & Effects",
            tooltip = "Filter out events and effects that have already been processed - used for development.",
            getFunction = function ()
                return Settings.ShowDebugFilter
            end,
            setFunction = function (value)
                Settings.ShowDebugFilter = value
            end,
            default = Defaults.ShowDebugFilter,
            disable = function ()
                return not LUIE.SV.SpellCastBuff_Enable
            end,
        }
    end)

    -- Create back button
    backButton =
    {
        type = LHAS.ST_BUTTON,
        label = "BACK",
        buttonText = "BACK",
        tooltip = "",
        clickHandler = function (control)
            panel:RemoveAllSettings()
            local mainMenuSettings = {}
            for i = 1, #initialSettings do
                mainMenuSettings[i] = initialSettings[i]
            end
            for i = 1, #menuButtons do
                mainMenuSettings[#mainMenuSettings + 1] = menuButtons[i]
            end
            panel:AddSettings(mainMenuSettings)
            if IsConsoleUI() then
                LibHarvensAddonSettings.list:SetSelectedIndexWithoutAnimation(1)
            end
        end
    }

    -- Helper function to create menu buttons
    local function createMenuButton(sectionName, labelText)
        return
        {
            type = LHAS.ST_BUTTON,
            label = labelText,
            buttonText = labelText,
            tooltip = "",
            clickHandler = function (control)
                panel:RemoveAllSettings()
                local sectionSettings = {}
                for i = 1, #sectionGroups[sectionName] do
                    sectionSettings[i] = sectionGroups[sectionName][i]
                end
                sectionSettings[#sectionSettings + 1] = backButton
                panel:AddSettings(sectionSettings)
                if IsConsoleUI() then
                    LibHarvensAddonSettings.list:SetSelectedIndexWithoutAnimation(2)
                end
            end
        }
    end

    -- Create menu buttons for each section
    menuButtons[#menuButtons + 1] = createMenuButton("PositionDisplay", GetString(LUIE_STRING_LAM_BUFF_HEADER_POSITION))
    menuButtons[#menuButtons + 1] = createMenuButton("LongShortTerm", GetString(LUIE_STRING_LAM_BUFF_LONG_SHORT_HEADER))
    menuButtons[#menuButtons + 1] = createMenuButton("Misc", GetString(LUIE_STRING_LAM_BUFF_MISC_HEADER))
    menuButtons[#menuButtons + 1] = createMenuButton("LongTerm", GetString(LUIE_STRING_LAM_BUFF_LONGTERM_HEADER))
    menuButtons[#menuButtons + 1] = createMenuButton("Icon", GetString(LUIE_STRING_LAM_BUFF_ICON_HEADER))
    menuButtons[#menuButtons + 1] = createMenuButton("Color", GetString(LUIE_STRING_LAM_BUFF_COLOR_HEADER))
    menuButtons[#menuButtons + 1] = createMenuButton("AlignmentSorting", GetString(LUIE_STRING_LAM_BUFF_SORTING_HEADER))
    menuButtons[#menuButtons + 1] = createMenuButton("Tooltip", GetString(LUIE_STRING_LAM_BUFF_TOOLTIP_HEADER))
    menuButtons[#menuButtons + 1] = createMenuButton("Priority", GetString(LUIE_STRING_LAM_BUFF_PRIORITY_HEADER))
    menuButtons[#menuButtons + 1] = createMenuButton("Prominent", GetString(LUIE_STRING_LAM_BUFF_PROM_HEADER))
    menuButtons[#menuButtons + 1] = createMenuButton("Blacklist", GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_HEADER))
    menuButtons[#menuButtons + 1] = createMenuButton("Debug", "Debug Options")

    -- Initialize main menu
    local mainMenuSettings = {}
    for i = 1, #initialSettings do
        mainMenuSettings[i] = initialSettings[i]
    end
    for i = 1, #menuButtons do
        mainMenuSettings[#mainMenuSettings + 1] = menuButtons[i]
    end
    panel:AddSettings(mainMenuSettings)
end
