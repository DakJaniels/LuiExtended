-- Archived excerpt from LuiExtended/pc/settings/CombatInfo.lua (Synergy Tracker).
-- Merge back into CombatInfo.CreateSettings when re-enabling Synergy Tracker.
local function GetSynergyTracker()
    return CombatInfo.SynergyTrackerInstance
end
local synergyDisplayChoices =
{
    GetString(LUIE_STRING_LAM_CI_SYNERGY_MODE_SINGLE),
    GetString(LUIE_STRING_LAM_CI_SYNERGY_MODE_MULTI),
    GetString(LUIE_STRING_LAM_CI_SYNERGY_MODE_COMPACT),
    GetString(LUIE_STRING_LAM_CI_SYNERGY_MODE_MINIMAL),
    GetString(LUIE_STRING_LAM_CI_SYNERGY_MODE_HIDDEN),
}
local synergyDisplayValues = { "single", "multi", "compact", "minimal", "hidden" }

    -- Synergy Tracker
    -- Forward-declare so the Refresh button closure can reference them before assignment
    local synergySubmenuControls
    local SYNERGY_STATIC_COUNT
    local BuildSynergyDetectedControls

    -- Rebuilds the per-synergy controls from current detectedSynergies into synergySubmenuControls.
    -- Truncates back to the static entries first so it is safe to call repeatedly.
    BuildSynergyDetectedControls = function ()
        while #synergySubmenuControls > SYNERGY_STATIC_COUNT do
            table.remove(synergySubmenuControls)
        end
        local t = GetSynergyTracker()
        local list = t and t:GetDetectedSynergiesSorted() or {}
        for _, synergyData in ipairs(list) do
            local abilityId = synergyData.abilityId
            local sName = synergyData.name
            local icon = synergyData.icon
            local timesSeen = synergyData.timesSeen

            table_insert(synergySubmenuControls,
                         {
                             type = "description",
                             text = zo_iconFormat(icon, 32, 32) .. " " .. zo_strformat("<<C:1>>", sName) .. string_format(" |cAAAAAA(Seen: %d times)|r", timesSeen),
                             width = "full",
                         })

            table_insert(synergySubmenuControls,
                         {
                             type = "checkbox",
                             name = zo_strformat("\t\t\t\t\t<<1>>", "Blacklist (Hide)"),
                             tooltip = string_format("Hide this synergy from the tracker. Ability ID: [%d]", abilityId),
                             getFunc = function ()
                                 return Settings.synergy.blacklist[abilityId] or false
                             end,
                             setFunc = function (value)
                                 Settings.synergy.blacklist[abilityId] = value or nil
                                 local tk = GetSynergyTracker()
                                 if tk then
                                     tk:RefreshActiveSynergies()
                                 end
                             end,
                             width = "full",
                             default = false,
                             disabled = function ()
                                 return not Settings.synergy.enabled
                             end,
                         })

            table_insert(synergySubmenuControls,
                         {
                             type = "slider",
                             name = zo_strformat("\t\t\t\t\t<<1>>", "Priority Override"),
                             tooltip = string_format("Set priority for %s. Higher values = higher priority. 0 = game default.", sName),
                             min = 0,
                             max = 10,
                             step = 1,
                             default = 0,
                             getFunc = function ()
                                 return Settings.synergy.priorityOverrides[abilityId] or 0
                             end,
                             setFunc = function (value)
                                 if value > 0 then
                                     Settings.synergy.priorityOverrides[abilityId] = value
                                     SetSynergyPriorityOverride(abilityId, value)
                                 else
                                     Settings.synergy.priorityOverrides[abilityId] = nil
                                     ClearSynergyPriorityOverride(abilityId)
                                 end
                             end,
                             width = "full",
                             disabled = function ()
                                 return not Settings.synergy.enabled or (Settings.synergy.blacklist[abilityId] == true)
                             end,
                         })

            table_insert(synergySubmenuControls,
                         {
                             type = "divider",
                             width = "full",
                         })
        end
    end

    synergySubmenuControls =
    {
        {
            type = "description",
            text = GetString(LUIE_STRING_LAM_CI_SYNERGY_HEADER_DESC),
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_CI_SYNERGY_UNLOCK),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_UNLOCK_TP),
            getFunc = function ()
                return Settings.synergy.unlocked
            end,
            setFunc = function (value)
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:SetUnlocked(value)
                end
            end,
            width = "half",
            default = false,
            disabled = function ()
                return not Settings.synergy.enabled
            end,
        },
        {
            type = "button",
            name = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_RESET_TP),
            func = function ()
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:ResetPosition()
                end
            end,
            width = "half",
            disabled = function ()
                return not Settings.synergy.enabled
            end,
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_CI_SYNERGY_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_ENABLE_TP),
            default = Defaults.synergy.enabled,
            getFunc = function ()
                return Settings.synergy.enabled
            end,
            setFunc = function (value)
                Settings.synergy.enabled = value
            end,
            width = "full",
            warning = GetString(LUIE_STRING_LAM_CI_REQUIRES_RELOAD_WARNING),
            requiresReload = true,
        },
        {
            type = "header",
            name = GetString(LUIE_STRING_LAM_CI_DISPLAY_OPTIONS),
        },
        {
            type = "slider",
            name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_SHARED_OOC_OPACITY)),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_OOC_OPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunc = function ()
                return Settings.synergy.oocAlpha
            end,
            setFunc = function (value)
                Settings.synergy.oocAlpha = value
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:ApplyDisplayAlpha()
                end
            end,
            width = "full",
            default = Defaults.synergy.oocAlpha,
            disabled = function ()
                return not Settings.synergy.enabled
            end,
        },
        {
            type = "slider",
            name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_SHARED_IC_OPACITY)),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_IC_OPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunc = function ()
                return Settings.synergy.incAlpha
            end,
            setFunc = function (value)
                Settings.synergy.incAlpha = value
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:ApplyDisplayAlpha()
                end
            end,
            width = "full",
            default = Defaults.synergy.incAlpha,
            disabled = function ()
                return not Settings.synergy.enabled
            end,
        },
        {
            type = "dropdown",
            name = GetString(LUIE_STRING_LAM_CI_SYNERGY_DISPLAY_MODE),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_DISPLAY_MODE_TP),
            choices = synergyDisplayChoices,
            choicesValues = synergyDisplayValues,
            getFunc = function ()
                return Settings.synergy.displayMode
            end,
            setFunc = function (value)
                Settings.synergy.displayMode = value
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:ApplyRowLayout(Settings.synergy.displayMode)
                    tracker:UpdateDisplay()
                end
            end,
            width = "full",
            default = Defaults.synergy.displayMode,
            disabled = function ()
                return not Settings.synergy.enabled
            end,
        },
        {
            type = "checkbox",
            name = zo_strformat("\t\t\t\t\t<<1>>", "Horizontal Icon Layout"),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_HORIZONTAL_ICONS_TP),
            getFunc = function ()
                return Settings.synergy.minimalHorizontal
            end,
            setFunc = function (value)
                Settings.synergy.minimalHorizontal = value
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:ApplyRowLayout(Settings.synergy.displayMode)
                    tracker:UpdateDisplay()
                end
            end,
            width = "full",
            default = Defaults.synergy.minimalHorizontal,
            disabled = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode ~= "minimal"
            end,
        },
        {
            type = "dropdown",
            name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CI_SYNERGY_HORIZONTAL_ALIGN)),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_HORIZONTAL_ALIGN_TP),
            choices =
            {
                GetString(LUIE_STRING_SHARED_ALIGN_LEFT),
                GetString(LUIE_STRING_SHARED_ALIGN_RIGHT),
            },
            choicesValues = { "left", "right" },
            getFunc = function ()
                local align = Settings.synergy.minimalHorizontalAlign
                if align ~= "right" then
                    return "left"
                end
                return align
            end,
            setFunc = function (value)
                Settings.synergy.minimalHorizontalAlign = value
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:ApplyRowLayout(Settings.synergy.displayMode)
                    tracker:UpdateDisplay()
                end
            end,
            width = "full",
            default = Defaults.synergy.minimalHorizontalAlign,
            disabled = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode ~= "minimal" or not Settings.synergy.minimalHorizontal
            end,
        },
        {
            type = "slider",
            name = zo_strformat("\t\t\t\t\t<<1>>", "Maximum Synergies to Display"),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_MAX_DISPLAY_TP),
            min = 1,
            max = 10,
            step = 1,
            getFunc = function ()
                return Settings.synergy.maxDisplay
            end,
            setFunc = function (value)
                Settings.synergy.maxDisplay = value
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:ApplyRowLayout(Settings.synergy.displayMode)
                    tracker:UpdateDisplay()
                end
            end,
            width = "full",
            default = Defaults.synergy.maxDisplay,
            disabled = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode == "single" or Settings.synergy.displayMode == "hidden"
            end,
        },
        {
            type = "checkbox",
            name = zo_strformat("\t\t\t\t\t<<1>>", "Show Priority Numbers"),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_SHOW_PRIORITY_TP),
            getFunc = function ()
                return Settings.synergy.showPriority
            end,
            setFunc = function (value)
                Settings.synergy.showPriority = value
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:UpdateDisplayOptions()
                end
            end,
            width = "full",
            default = Defaults.synergy.showPriority,
            disabled = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode == "hidden"
            end,
        },
        {
            type = "checkbox",
            name = zo_strformat("\t\t\t\t\t<<1>>", "Show Position Numbers"),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_SHOW_POSITION_TP),
            getFunc = function ()
                return Settings.synergy.showKeybinds
            end,
            setFunc = function (value)
                Settings.synergy.showKeybinds = value
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:UpdateDisplayOptions()
                end
            end,
            width = "full",
            default = Defaults.synergy.showKeybinds,
            disabled = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode == "minimal" or Settings.synergy.displayMode == "hidden"
            end,
        },
        {
            type = "checkbox",
            name = zo_strformat("\t\t\t\t\t<<1>>", "Play Sound on New Synergy"),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_SOUND_NEW_TP),
            getFunc = function ()
                return Settings.synergy.playSound
            end,
            setFunc = function (value)
                Settings.synergy.playSound = value
            end,
            width = "full",
            default = Defaults.synergy.playSound,
            disabled = function ()
                return not Settings.synergy.enabled
            end,
        },
        {
            type = "checkbox",
            name = zo_strformat("\t\t\t\t\t<<1>>", "Show Synergies on Cooldown"),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_SHOW_COOLDOWN_TP),
            getFunc = function ()
                return Settings.synergy.showCooldowns
            end,
            setFunc = function (value)
                Settings.synergy.showCooldowns = value
                local tracker = GetSynergyTracker()
                if tracker then
                    if not value then
                        tracker.synergyCooldowns = {}
                    end
                    tracker:UpdateDisplay()
                end
            end,
            width = "full",
            default = Defaults.synergy.showCooldowns,
            disabled = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode == "single" or Settings.synergy.displayMode == "hidden"
            end,
        },
        {
            type = "header",
            name = GetString(LUIE_STRING_LAM_CI_SYNERGY_DETECTED_HEADER),
        },
        {
            type = "description",
            text = GetString(LUIE_STRING_LAM_CI_SYNERGY_DETECTED_DESC),
        },
        {
            type = "button",
            name = GetString(LUIE_STRING_LAM_CI_SYNERGY_CLEAR_OVERRIDES),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_CLEAR_OVERRIDES_TP),
            func = function ()
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:ClearAllPriorityOverrides()
                end
            end,
            width = "half",
            disabled = function ()
                return not Settings.synergy.enabled
            end,
        },
        {
            type = "button",
            name = GetString(LUIE_STRING_LAM_CI_SYNERGY_CLEAR_BLACKLIST),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_CLEAR_BLACKLIST_TP),
            func = function ()
                Settings.synergy.blacklist = {}
                local tracker = GetSynergyTracker()
                if tracker then
                    tracker:RefreshActiveSynergies()
                end
                LUIE.ChatOutput:Print(GetString(LUIE_STRING_CI_CHAT_BLACKLIST_CLEARED), true)
            end,
            width = "half",
            disabled = function ()
                return not Settings.synergy.enabled
            end,
        },
        {
            type = "button",
            name = GetString(LUIE_STRING_LAM_CI_SYNERGY_REFRESH_LIST),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_REFRESH_LIST_TP),
            func = function ()
                BuildSynergyDetectedControls()
            end,
            width = "half",
            disabled = function ()
                return not Settings.synergy.enabled
            end,
        },
    }

    -- Record static control count so BuildSynergyDetectedControls knows where to truncate
    SYNERGY_STATIC_COUNT = #synergySubmenuControls

    -- Populate detected synergies for the current session
    BuildSynergyDetectedControls()

    optionsDataCombatInfo[#optionsDataCombatInfo + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_CI_SYNERGY_TRACKER_HEADER),
        controls = synergySubmenuControls,
    }
