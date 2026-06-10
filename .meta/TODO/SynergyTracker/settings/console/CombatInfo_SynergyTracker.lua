-- Archived excerpt from LuiExtended/console/settings/CombatInfo.lua (Synergy Tracker).
-- Restore buildSectionSettings block and AppendSection line documented in README.md.
    -- Build Synergy Tracker Section
    buildSectionSettings("SynergyTracker", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_TRACKER_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_HEADER_DESC),
            canSelect = false,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_UNLOCK),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_UNLOCK_TP),
            getFunction = function ()
                return Settings.synergy.unlocked
            end,
            setFunction = function (v)
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:SetUnlocked(v)
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled
            end,
            default = false
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_RESET_TP),
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
            clickHandler = function ()
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:ResetPosition()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled
            end
        }

        local gwSyn = GuiRoot:GetWidth()
        local ghSyn = GuiRoot:GetHeight()
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X_TP),
            min = -gwSyn,
            max = gwSyn,
            step = 10,
            getFunction = function ()
                return Settings.synergy.offsetX or 0
            end,
            setFunction = function (value)
                Settings.synergy.offsetX = value
                if Settings.synergy.offsetY == nil then
                    Settings.synergy.offsetY = 200
                end
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:ApplyPosition()
                end
            end,
            disable = function () return not Settings.synergy.enabled end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y_TP),
            min = -ghSyn,
            max = ghSyn,
            step = 10,
            getFunction = function ()
                return Settings.synergy.offsetY or 200
            end,
            setFunction = function (value)
                if Settings.synergy.offsetX == nil then
                    Settings.synergy.offsetX = 0
                end
                Settings.synergy.offsetY = value
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:ApplyPosition()
                end
            end,
            disable = function () return not Settings.synergy.enabled end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_ENABLE_TP),
            getFunction = function ()
                return Settings.synergy.enabled
            end,
            setFunction = function (v)
                Settings.synergy.enabled = v
            end,
            default = Defaults.synergy.enabled
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_DISPLAY_OPTIONS)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_SHARED_OOC_OPACITY),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_OOC_OPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            format = "%.0f",
            getFunction = function ()
                return Settings.synergy.oocAlpha
            end,
            setFunction = function (v)
                Settings.synergy.oocAlpha = v
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:ApplyDisplayAlpha()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled
            end,
            default = Defaults.synergy.oocAlpha
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_SHARED_IC_OPACITY),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_IC_OPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            format = "%.0f",
            getFunction = function ()
                return Settings.synergy.incAlpha
            end,
            setFunction = function (v)
                Settings.synergy.incAlpha = v
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:ApplyDisplayAlpha()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled
            end,
            default = Defaults.synergy.incAlpha
        }

        -- Build display mode items
        local displayModeItems =
        {
            { name = GetString(LUIE_STRING_LAM_CI_SYNERGY_MODE_SINGLE),  data = "single"  },
            { name = GetString(LUIE_STRING_LAM_CI_SYNERGY_MODE_MULTI),   data = "multi"   },
            { name = GetString(LUIE_STRING_LAM_CI_SYNERGY_MODE_COMPACT), data = "compact" },
            { name = GetString(LUIE_STRING_LAM_CI_SYNERGY_MODE_MINIMAL), data = "minimal" },
            { name = GetString(LUIE_STRING_LAM_CI_SYNERGY_MODE_HIDDEN),  data = "hidden"  },
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_DISPLAY_MODE),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_DISPLAY_MODE_TP),
            items = displayModeItems,
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(Settings.synergy.displayMode)
            end,
            setFunction = function (combobox, value, item)
                Settings.synergy.displayMode = item.data
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:ApplyRowLayout(Settings.synergy.displayMode)
                    tracker:UpdateDisplay()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.synergy.displayMode)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_HORIZONTAL_ICONS),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_HORIZONTAL_ICONS_TP),
            getFunction = function ()
                return Settings.synergy.minimalHorizontal
            end,
            setFunction = function (v)
                Settings.synergy.minimalHorizontal = v
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:ApplyRowLayout(Settings.synergy.displayMode)
                    tracker:UpdateDisplay()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode ~= "minimal"
            end,
            default = Defaults.synergy.minimalHorizontal
        }

        local horizontalAlignItems =
        {
            { name = GetString(LUIE_STRING_SHARED_ALIGN_LEFT),  data = "left"  },
            { name = GetString(LUIE_STRING_SHARED_ALIGN_RIGHT), data = "right" },
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_HORIZONTAL_ALIGN),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_HORIZONTAL_ALIGN_TP),
            items = horizontalAlignItems,
            getFunction = function ()
                local align = Settings.synergy.minimalHorizontalAlign
                if align ~= "right" then
                    align = "left"
                end
                for _, item in ipairs(horizontalAlignItems) do
                    if item.data == align then
                        return item
                    end
                end
                return horizontalAlignItems[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.synergy.minimalHorizontalAlign = item.data
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:ApplyRowLayout(Settings.synergy.displayMode)
                    tracker:UpdateDisplay()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode ~= "minimal" or not Settings.synergy.minimalHorizontal
            end,
            default = horizontalAlignItems[1]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_MAX_DISPLAY),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_MAX_DISPLAY_TP),
            min = 1,
            max = 10,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return Settings.synergy.maxDisplay
            end,
            setFunction = function (v)
                Settings.synergy.maxDisplay = v
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:ApplyRowLayout(Settings.synergy.displayMode)
                    tracker:UpdateDisplay()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode == "single" or Settings.synergy.displayMode == "hidden"
            end,
            default = Defaults.synergy.maxDisplay
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_SHOW_PRIORITY),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_SHOW_PRIORITY_TP),
            getFunction = function ()
                return Settings.synergy.showPriority
            end,
            setFunction = function (v)
                Settings.synergy.showPriority = v
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:UpdateDisplayOptions()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode == "hidden"
            end,
            default = Defaults.synergy.showPriority
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_SHOW_POSITION),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_SHOW_POSITION_TP),
            getFunction = function ()
                return Settings.synergy.showKeybinds
            end,
            setFunction = function (v)
                Settings.synergy.showKeybinds = v
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:UpdateDisplayOptions()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode == "minimal" or Settings.synergy.displayMode == "hidden"
            end,
            default = Defaults.synergy.showKeybinds
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_SOUND_NEW),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_SOUND_NEW_TP),
            getFunction = function ()
                return Settings.synergy.playSound
            end,
            setFunction = function (v)
                Settings.synergy.playSound = v
            end,
            disable = function ()
                return not Settings.synergy.enabled
            end,
            default = Defaults.synergy.playSound
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_SHOW_COOLDOWN),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_SHOW_COOLDOWN_TP),
            getFunction = function ()
                return Settings.synergy.showCooldowns
            end,
            setFunction = function (v)
                Settings.synergy.showCooldowns = v
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    if not v then
                        tracker.synergyCooldowns = {}
                    end
                    tracker:UpdateDisplay()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled or Settings.synergy.displayMode == "single" or Settings.synergy.displayMode == "hidden"
            end,
            default = Defaults.synergy.showCooldowns
        }

        -- Detected Synergies & Priority Overrides Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_DETECTED_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_DETECTED_DESC)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_CLEAR_OVERRIDES),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_CLEAR_OVERRIDES_TP),
            buttontext = GetString(LUIE_STRING_LAM_CI_SYNERGY_CLEAR_OVERRIDES),
            clickHandler = function ()
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:ClearAllPriorityOverrides()
                end
            end,
            disable = function ()
                return not Settings.synergy.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_CLEAR_BLACKLIST),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_CLEAR_BLACKLIST_TP),
            buttontext = GetString(LUIE_STRING_LAM_CI_SYNERGY_CLEAR_BLACKLIST),
            clickHandler = function ()
                Settings.synergy.blacklist = {}
                local tracker = CombatInfo.SynergyTrackerInstance
                if tracker then
                    tracker:RefreshActiveSynergies()
                end
                LUIE.ChatOutput:Print(GetString(LUIE_STRING_CI_CHAT_BLACKLIST_CLEARED_REFRESH), true)
            end,
            disable = function ()
                return not Settings.synergy.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CI_SYNERGY_REFRESH_LIST),
            tooltip = GetString(LUIE_STRING_LAM_CI_SYNERGY_REFRESH_LIST_CONSOLE_TP),
            buttontext = GetString(LUIE_STRING_LAM_CI_SYNERGY_REFRESH_LIST),
            clickHandler = function ()
                LUIE.ChatOutput:Print(GetString(LUIE_STRING_CI_CHAT_SYNERGY_REFRESH_SETTINGS), true)
            end,
            disable = function ()
                return not Settings.synergy.enabled
            end
        }

        -- NOTE: Dynamic synergy list generation (detected synergies)
        -- Dynamically add detected synergies to the settings menu (if tracker exists)
        local tracker = CombatInfo.SynergyTrackerInstance
        local detectedList = tracker and tracker:GetDetectedSynergiesSorted() or {}
        if #detectedList > 0 then
            for _, synergyData in ipairs(detectedList) do
                local abilityId = synergyData.abilityId
                local name = synergyData.name
                local icon = synergyData.icon
                local timesSeen = synergyData.timesSeen

                -- Synergy description with icon and name
                settings[#settings + 1] =
                {
                    type = LHAS.ST_LABEL,
                    label = zo_iconTextFormat(icon, 32, 32, " " .. zo_strformat("<<C:1>>", name) .. string_format(" |cAAAAAA(Seen: %d times)|r", timesSeen), true, true)
                }

                -- Blacklist toggle
                settings[#settings + 1] =
                {
                    type = LHAS.ST_CHECKBOX,
                    label = GetString(LUIE_STRING_LAM_CI_SYNERGY_BLACKLIST_HIDE),
                    tooltip = string_format("Hide this synergy from the tracker. Ability ID: [%d]", abilityId),
                    getFunction = function ()
                        return Settings.synergy.blacklist[abilityId] or false
                    end,
                    setFunction = function (v)
                        Settings.synergy.blacklist[abilityId] = v or nil
                        if tracker then
                            tracker:RefreshActiveSynergies()
                        end
                    end,
                    disable = function ()
                        return not Settings.synergy.enabled
                    end,
                    default = false
                }

                -- Priority slider
                settings[#settings + 1] =
                {
                    type = LHAS.ST_SLIDER,
                    label = GetString(LUIE_STRING_LAM_CI_SYNERGY_PRIORITY_OVERRIDE),
                    tooltip = string_format("Set priority for %s. Higher values = higher priority. 0 = game default.", name),
                    min = 0,
                    max = 10,
                    step = 1,
                    format = "%.0f",
                    getFunction = function ()
                        return Settings.synergy.priorityOverrides[abilityId] or 0
                    end,
                    setFunction = function (v)
                        if v > 0 then
                            Settings.synergy.priorityOverrides[abilityId] = v
                            SetSynergyPriorityOverride(abilityId, v)
                        else
                            Settings.synergy.priorityOverrides[abilityId] = nil
                            ClearSynergyPriorityOverride(abilityId)
                        end
                    end,
                    disable = function ()
                        return not Settings.synergy.enabled or (Settings.synergy.blacklist[abilityId] == true)
                    end,
                    default = 0
                }
            end
        end
    end)

    -- AppendSection (in CreateSettings after all buildSectionSettings calls):
    -- SettingsAPI:AppendSection(allSettings, "Synergy Tracker", sectionGroups["SynergyTracker"])

