-- -----------------------------------------------------------------------------
--  LuiExtended Console Settings API                                          --
--  Common utility functions for console settings modules using LHAS          --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Local references
local table_insert = table.insert
local table_sort = table.sort
local pairs = pairs
local type = type
local zo_strformat = zo_strformat
local string_gsub = string.gsub

-- ---------------------------------------------------------------------------------------
-- SettingsAPI Class
-- ---------------------------------------------------------------------------------------

--- @class (partial) SettingsAPI_Console : ZO_InitializingObject
--- @field mediaCache table Cache for media lists to avoid regenerating them
--- @field LUIE table LuiExtended namespace
local SettingsAPI = ZO_InitializingObject:Subclass()

-- ---------------------------------------------------------------------------------------
function SettingsAPI:Initialize()
    self.name = "SettingsAPI"
    self.initialized = false
    self.LUIE = LUIE
    self.mediaCache =
    {
        fonts = nil,
        sounds = nil,
        statusbarTextures = nil,
    }
end

-- ---------------------------------------------------------------------------------------
-- LHAS 2.1.7 console navigation helpers
-- ---------------------------------------------------------------------------------------

--- Gamepad list only skips focus when `canSelect` is set on the control; LHAS applies that from params.
--- @param setting table
--- @return table
function SettingsAPI:NormalizeConsoleSetting(setting)
    local LHAS = LibHarvensAddonSettings
    if setting.type == LHAS.ST_LABEL and setting.canSelect == nil then
        setting.canSelect = false
    end
    return setting
end

--- @param allSettings table
--- @param settingsList table
function SettingsAPI:AppendSettingsList(allSettings, settingsList)
    for i = 1, #settingsList do
        table_insert(allSettings, self:NormalizeConsoleSetting(settingsList[i]))
    end
end

--- Appends ST_SECTION plus optional rows. Console LHAS 2.1.8+: `options.subMenu = false` for a header-only row (no drill-in; following rows stay on the parent list).
--- @param allSettings table
--- @param sectionLabel string|integer
--- @param sectionRows table|nil
--- @param options table|nil `{ subMenu = false }`
function SettingsAPI:AppendSection(allSettings, sectionLabel, sectionRows, options)
    local LHAS = LibHarvensAddonSettings
    local sectionEntry =
    {
        type = LHAS.ST_SECTION,
        label = sectionLabel,
    }
    if options and options.subMenu == false then
        sectionEntry.subMenu = false
    end
    table_insert(allSettings, sectionEntry)
    if sectionRows then
        for i = 1, #sectionRows do
            table_insert(allSettings, self:NormalizeConsoleSetting(sectionRows[i]))
        end
    end
end

--- Refreshes visible controls while the addon settings scene is open (LHAS RefreshAddonSettings is hide-gated).
--- @param panel table LibHarvensAddonSettings.AddonSettings
function SettingsAPI:RefreshPanel(panel)
    if panel and panel.selected and panel.UpdateControls then
        panel:UpdateControls()
    end
end

--- @param addonPanel table LibHarvensAddonSettings.AddonSettings
function SettingsAPI:RefreshConsoleAddonSettingsHeader(addonPanel)
    local LHAS = LibHarvensAddonSettings
    local scrollList = LHAS.scrollList
    if not scrollList.header or not addonPanel then
        return
    end
    local addonName = addonPanel.name
    local author, name = addonName:match("^(.+)'s%s(.+)")
    if name == nil then
        name = addonName
    end
    if addonPanel.author then
        author = addonPanel.author
    end
    ZO_GamepadGenericHeader_RefreshData(scrollList.header,
                                        {
                                            titleText = name,
                                            subtitleText = addonPanel.version,
                                            messageText = author and zo_strformat(GetString(SI_ADD_ON_AUTHOR_LINE), author),
                                        })
end

--- Opens LuiExtended main settings → Chat Output (console LHAS section drill-in).
function SettingsAPI:OpenConsoleChatOutputSettings()
    local LHAS = LibHarvensAddonSettings
    local mainPanel = LUIE.consoleMainSettingsPanel
    local sectionSetting = LUIE.consoleChatOutputSectionSetting
    if not mainPanel or not sectionSetting then
        return
    end

    local scrollList = LHAS.scrollList

    local mainList = scrollList:GetMainList()
    local sectionList = scrollList:GetList("Section")

    -- Tear down any drilled-in section (e.g. Chat Announcements) so pooled rows are not left visible.
    if sectionList.currentSection or scrollList:GetCurrentList() == sectionList then
        sectionList.currentSection = nil
        sectionList:Clear()
        sectionList:Commit()
        scrollList:SetCurrentList(mainList)
    end
    mainList:Clear()
    mainList:Commit()

    if not mainPanel.selected then
        mainPanel:Select()
    end

    -- LibHarvensAddonSettings_AddonSelected rebuilds the root list; discard before Chat Output drill-in.
    mainList:Clear()
    mainList:Commit()

    sectionList.currentSection = sectionSetting
    scrollList:SetCurrentList(sectionList)
    mainPanel:SetupSections()
    mainPanel:CreateControls()
    if mainPanel.RefreshSelection then
        mainPanel:RefreshSelection()
    end

    self:RefreshConsoleAddonSettingsHeader(mainPanel)
    PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)

    if SCENE_MANAGER:IsShowing("LibHarvensAddonSettingsScene") == false then
        SCENE_MANAGER:Push("LibHarvensAddonSettingsScene")
    end
end

--- Console: defer live font rebuilds until Reload UI (can exhaust memory on console).
LUIE.ConsoleSettingsPending = LUIE.ConsoleSettingsPending or {}

--- @param pendingKey string e.g. actionBar, unitFramesCustomFont
function SettingsAPI:MarkFontDeferred(pendingKey)
    local wasPending = LUIE.ConsoleSettingsPending[pendingKey]
    LUIE.ConsoleSettingsPending[pendingKey] = true
    if not wasPending and not self.fontDeferChatShown then
        self.fontDeferChatShown = true
        if CHAT_ROUTER then
            LUIE.ChatOutput:Print(GetString(LUIE_STRING_CONSOLE_FONT_APPLY_RELOAD), true)
        end
    end
end

--- @param frameType '"default"'|'"custom"'
function SettingsAPI:MarkUnitFramesFontDeferred(frameType)
    local key = frameType == "custom" and "unitFramesCustomFont" or "unitFramesDefaultFont"
    self:MarkFontDeferred(key)
end

function SettingsAPI:ClearConsoleSettingsPending()
    LUIE.ConsoleSettingsPending = {}
    self.fontDeferChatShown = false
end

--- Call before ReloadUI from console settings menus.
function SettingsAPI:ReloadUIWithPendingClear()
    self:ClearConsoleSettingsPending()
    ReloadUI("ingame")
end

--- Reminder label near font options (console).
--- @return table
function SettingsAPI:ConsoleFontDeferLabelSetting()
    local LHAS = LibHarvensAddonSettings
    return
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_CONSOLE_FONT_PENDING_LABEL),
        canSelect = false,
    }
end

-- ---------------------------------------------------------------------------------------
-- LHAS dropdown + console-safe text
-- ---------------------------------------------------------------------------------------

--- Value for getFunction/default so LHAS matches items by `data` (see equalityFunctionDropDown).
--- @param storedValue any
--- @return table
function SettingsAPI:LHASDropdownGetData(storedValue)
    return { data = storedValue }
end

--- Clamp numeric index dropdown SV; optional English legacy string migration.
--- @param storedValue any
--- @param legacyEnglishToIndex table<string, integer>|nil
--- @param defaultIndex integer
--- @param maxIndex integer
--- @return integer
function SettingsAPI:NormalizeNumericIndexDropdown(storedValue, legacyEnglishToIndex, defaultIndex, maxIndex)
    local index = storedValue
    if type(index) == "string" and legacyEnglishToIndex then
        index = legacyEnglishToIndex[index] or defaultIndex
    end
    if type(index) ~= "number" or index < 1 or index > maxIndex then
        index = defaultIndex
    end
    return index
end

--- @param storedValue any
--- @param defaultIndex integer
--- @return integer
function SettingsAPI:NormalizeGlobalIconOptionIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 1
    return self:NormalizeNumericIndexDropdown(storedValue,
                                              {
                                                  ["All Crowd Control"] = 1,
                                                  ["NPC CC Only"] = 2,
                                                  ["Player CC Only"] = 3,
                                              },
                                              defaultIndex,
                                              3)
end

--- @param storedValue any
--- @param defaultIndex integer
--- @return integer
function SettingsAPI:NormalizeGlobalAlertOptionIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 1
    return self:NormalizeNumericIndexDropdown(storedValue,
                                              {
                                                  ["Show All Incoming Abilities"] = 1,
                                                  ["Only Show Hard CC Effects"] = 2,
                                                  ["Only Show Unbreakable CC Effects"] = 3,
                                              },
                                              defaultIndex,
                                              3)
end

--- @param storedValue any
--- @param defaultIndex integer
--- @return integer
function SettingsAPI:NormalizeChatNameDisplayIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 2
    return self:NormalizeNumericIndexDropdown(storedValue,
                                              {
                                                  ["@UserID"] = 1,
                                                  ["Character Name"] = 2,
                                                  ["Character Name @UserID"] = 3,
                                              },
                                              defaultIndex,
                                              3)
end

--- @param storedValue any
--- @param defaultIndex integer
--- @return integer
function SettingsAPI:NormalizeFriendStatusNameFormatIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 1
    return self:NormalizeNumericIndexDropdown(storedValue,
                                              {
                                                  ["Player Name Display Method"] = 1,
                                                  ["@UserID with Character Name"] = 2,
                                              },
                                              defaultIndex,
                                              2)
end

--- @param storedValue any
--- @param defaultIndex integer
--- @return integer
function SettingsAPI:NormalizeLinkBracketDisplayIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 1
    return self:NormalizeNumericIndexDropdown(storedValue,
                                              {
                                                  ["No Brackets"] = 1,
                                                  ["Display Brackets"] = 2,
                                              },
                                              defaultIndex,
                                              2)
end

--- @param storedValue any
--- @param defaultIndex integer
--- @return integer
function SettingsAPI:NormalizeGuildRankDisplayIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 1
    return self:NormalizeNumericIndexDropdown(storedValue,
                                              {
                                                  ["Self Only"] = 1,
                                                  ["All w/ Permissions"] = 2,
                                                  ["All Rank Changes"] = 3,
                                              },
                                              defaultIndex,
                                              3)
end

--- @param storedValue any
--- @param defaultIndex integer
--- @return integer
function SettingsAPI:NormalizeRotationOptionIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 2
    return self:NormalizeNumericIndexDropdown(storedValue,
                                              {
                                                  ["Horizontal"] = 1,
                                                  ["Vertical"] = 2,
                                              },
                                              defaultIndex,
                                              2)
end

--- @param storedValue any
--- @param defaultIndex integer
--- @return integer
function SettingsAPI:NormalizeGcdMethodIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 1
    return self:NormalizeNumericIndexDropdown(storedValue,
                                              {
                                                  ["Radial"] = 1,
                                                  ["Vertical Reveal"] = 2,
                                              },
                                              defaultIndex,
                                              2)
end

--- @param storedValue any
--- @param defaultIndex integer
--- @return integer
function SettingsAPI:NormalizeDuelStartDisplayIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 1
    return self:NormalizeNumericIndexDropdown(storedValue,
                                              {
                                                  ["Message + Icon"] = 1,
                                                  ["Message Only"] = 2,
                                                  ["Icon Only"] = 3,
                                              },
                                              defaultIndex,
                                              3)
end

--- Unit Frames name display (same indices as chat name display).
function SettingsAPI:NormalizeUfNameDisplayIndex(storedValue, defaultIndex)
    return self:NormalizeChatNameDisplayIndex(storedValue, defaultIndex)
end

function SettingsAPI:NormalizeUfRaidIconIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 1
    local legacy =
    {
        ["No Icons"] = 1,
        ["Class Icons Only"] = 2,
        ["Role Icons Only"] = 3,
        ["Class Icon in PVP, Role in PVE"] = 4,
        ["Class Icon in PVE, Role in PVP"] = 5,
        [GetString(LUIE_STRING_LAM_UF_RAIDICON_NONE)] = 1,
        [GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_ONLY)] = 2,
        [GetString(LUIE_STRING_LAM_UF_RAIDICON_ROLE_ONLY)] = 3,
        [GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_PVP_ROLE_PVE)] = 4,
        [GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_PVE_ROLE_PVP)] = 5,
    }
    return self:NormalizeNumericIndexDropdown(storedValue, legacy, defaultIndex, 5)
end

function SettingsAPI:NormalizeUfPlayerFrameIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 1
    local legacy =
    {
        ["Vertical Stacked Frames"] = 1,
        ["Separated Horizontal Frames"] = 2,
        ["Pyramid"] = 3,
        [GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_VERTICAL)] = 1,
        [GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_HORIZONTAL)] = 2,
        [GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_PYRAMID)] = 3,
    }
    return self:NormalizeNumericIndexDropdown(storedValue, legacy, defaultIndex, 3)
end

function SettingsAPI:NormalizeUfAlignmentIndex(storedValue, defaultIndex)
    defaultIndex = defaultIndex or 1
    local legacy =
    {
        ["Left to Right (Default)"] = 1,
        ["Right to Left"] = 2,
        ["Center"] = 3,
        [GetString(LUIE_STRING_LAM_UF_ALIGNMENT_LEFT_RIGHT)] = 1,
        [GetString(LUIE_STRING_LAM_UF_ALIGNMENT_RIGHT_LEFT)] = 2,
        [GetString(LUIE_STRING_LAM_UF_ALIGNMENT_CENTER)] = 3,
    }
    return self:NormalizeNumericIndexDropdown(storedValue, legacy, defaultIndex, 3)
end

--- Dropdowns that store a fixed token string in SV (e.g. SCB alignment).
--- @param storedValue any
--- @param validTokens table
--- @param defaultToken string
--- @return string
function SettingsAPI:NormalizeTokenChoice(storedValue, validTokens, defaultToken)
    if type(storedValue) == "string" then
        for i = 1, #validTokens do
            if storedValue == validTokens[i] then
                return storedValue
            end
        end
    end
    return defaultToken
end

--- Single-line label for LHAS list rows (never use multi-line LAM DESCRIPTION here).
--- @param stringId string
--- @return string
function SettingsAPI:ConsoleLabel(stringId)
    return GetString(stringId)
end

--- Tooltip safe for gamepad: collapses newlines/tabs to spaces.
--- @param stringId string
--- @return string
function SettingsAPI:ConsoleTooltip(stringId)
    local text = GetString(stringId)
    text = string_gsub(text, "[\r\n\t]+", " ")
    text = string_gsub(text, "%s%s+", " ")
    return zo_strtrim(text)
end

-- ---------------------------------------------------------------------------------------
-- Media List Generation Functions
-- ---------------------------------------------------------------------------------------
-- Note: LuiMedia addon handles all LibMediaProvider registration
-- We just fetch the combined lists here for settings UI

--- Get list of all fonts (LuiMedia already has everything including external media)
--- @return table fontsList Array of {name = string, data = string} items for LHAS dropdowns
function SettingsAPI:GetFontsList()
    if self.mediaCache.fonts then
        return self.mediaCache.fonts
    end

    local fontsList = {}
    for font, _ in pairs(self.LUIE.Fonts) do
        table_insert(fontsList, { name = font, data = font })
    end

    table_sort(fontsList, function (a, b) return a.name < b.name end)
    self.mediaCache.fonts = fontsList
    return fontsList
end

--- Get list of all sounds (LuiMedia already has everything including external media)
--- @return table soundsList Array of {name = string, data = string} items for LHAS dropdowns
function SettingsAPI:GetSoundsList()
    if self.mediaCache.sounds then
        return self.mediaCache.sounds
    end

    local soundsList = {}
    for sound, _ in pairs(self.LUIE.Sounds) do
        table_insert(soundsList, { name = sound, data = sound })
    end

    table_sort(soundsList, function (a, b) return a.name < b.name end)
    self.mediaCache.sounds = soundsList
    return soundsList
end

--- Get list of all statusbar textures (LuiMedia already has everything including external media)
--- @return table statusbarTexturesList Array of {name = string, data = string} items for LHAS dropdowns
function SettingsAPI:GetStatusbarTexturesList()
    if self.mediaCache.statusbarTextures then
        return self.mediaCache.statusbarTextures
    end

    local statusbarTexturesList = {}
    for texture, _ in pairs(self.LUIE.StatusbarTextures) do
        table_insert(statusbarTexturesList, { name = texture, data = texture })
    end

    table_sort(statusbarTexturesList, function (a, b) return a.name < b.name end)
    self.mediaCache.statusbarTextures = statusbarTexturesList
    return statusbarTexturesList
end

--- Get name display options list for UnitFrames
--- @return table nameDisplayItemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetNameDisplayOptionsList()
    local nameDisplayItemsList = {}
    local nameDisplayOptions =
    {
        GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_USERID),
        GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_CHARNAME),
        GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_CHARNAME_USERID)
    }
    for i, option in ipairs(nameDisplayOptions) do
        table_insert(nameDisplayItemsList, { name = option, data = i })
    end
    return nameDisplayItemsList
end

--- Generic helper to convert an options array to LHAS-compatible items
--- @param optionsArray table Array of option strings
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:ConvertOptionsToItems(optionsArray)
    local itemsList = {}
    for i, option in ipairs(optionsArray) do
        table_insert(itemsList, { name = option, data = i })
    end
    return itemsList
end

--- Get raid icon options list for UnitFrames
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetRaidIconOptionsList()
    local raidIconOptions =
    {
        GetString(LUIE_STRING_LAM_UF_RAIDICON_NONE),
        GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_ONLY),
        GetString(LUIE_STRING_LAM_UF_RAIDICON_ROLE_ONLY),
        GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_PVP_ROLE_PVE),
        GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_PVE_ROLE_PVP)
    }
    return self:ConvertOptionsToItems(raidIconOptions)
end

--- Get player frame options list for UnitFrames
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetPlayerFrameOptionsList()
    local playerFrameOptions =
    {
        GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_VERTICAL),
        GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_HORIZONTAL),
        GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_PYRAMID)
    }
    return self:ConvertOptionsToItems(playerFrameOptions)
end

--- Get alignment options list for UnitFrames
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetAlignmentOptionsList()
    local alignmentOptions =
    {
        GetString(LUIE_STRING_LAM_UF_ALIGNMENT_LEFT_RIGHT),
        GetString(LUIE_STRING_LAM_UF_ALIGNMENT_RIGHT_LEFT),
        GetString(LUIE_STRING_LAM_UF_ALIGNMENT_CENTER)
    }
    return self:ConvertOptionsToItems(alignmentOptions)
end

--- Get global icon options list (CC icon options)
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetGlobalIconOptionsList()
    local globalIconOptions =
    {
        GetString(LUIE_STRING_SHARED_CC_ALL),
        GetString(LUIE_STRING_SHARED_CC_NPC_ONLY),
        GetString(LUIE_STRING_SHARED_CC_PLAYER_ONLY),
    }
    return self:ConvertOptionsToItems(globalIconOptions)
end

--- Get global alert options list for CombatInfo
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetGlobalAlertOptionsList()
    local globalAlertOptions =
    {
        GetString(LUIE_STRING_LAM_CI_ALERT_FILTER_ALL),
        GetString(LUIE_STRING_LAM_CI_ALERT_FILTER_HARD_CC),
        GetString(LUIE_STRING_LAM_CI_ALERT_FILTER_UNBREAKABLE_CC),
    }
    return self:ConvertOptionsToItems(globalAlertOptions)
end

--- Get chat name display options list for ChatAnnouncements
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetChatNameDisplayOptionsList()
    local chatNameDisplayOptions =
    {
        GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_USERID),
        GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_CHARNAME),
        GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_CHARNAME_USERID),
    }
    return self:ConvertOptionsToItems(chatNameDisplayOptions)
end

--- Get friend log on/off name format options for ChatAnnouncements Social
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetFriendStatusNameFormatOptionsList()
    local friendStatusNameFormatOptions =
    {
        GetString(LUIE_STRING_LAM_CA_NAMEDISPLAYMETHOD),
        GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF_FORMAT_STOCK),
    }
    return self:ConvertOptionsToItems(friendStatusNameFormatOptions)
end

--- Get link bracket display options list for ChatAnnouncements
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetLinkBracketDisplayOptionsList()
    local linkBracketDisplayOptions =
    {
        GetString(LUIE_STRING_LAM_CA_CHOICE_NO_BRACKETS),
        GetString(LUIE_STRING_LAM_CA_CHOICE_DISPLAY_BRACKETS),
    }
    return self:ConvertOptionsToItems(linkBracketDisplayOptions)
end

--- Get guild rank display options list for ChatAnnouncements
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetGuildRankDisplayOptionsList()
    local guildRankDisplayOptions =
    {
        GetString(LUIE_STRING_LAM_CA_CHOICE_GUILD_RANK_SELF),
        GetString(LUIE_STRING_LAM_CA_CHOICE_GUILD_RANK_PERMISSIONS),
        GetString(LUIE_STRING_LAM_CA_CHOICE_GUILD_RANK_ALL),
    }
    return self:ConvertOptionsToItems(guildRankDisplayOptions)
end

--- Get duel start options list for ChatAnnouncements
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetDuelStartOptionsList()
    local duelStartOptions =
    {
        GetString(LUIE_STRING_LAM_CA_CHOICE_DUEL_MESSAGE_ICON),
        GetString(LUIE_STRING_LAM_CA_CHOICE_DUEL_MESSAGE_ONLY),
        GetString(LUIE_STRING_LAM_CA_CHOICE_DUEL_ICON_ONLY),
    }
    return self:ConvertOptionsToItems(duelStartOptions)
end

--- Get global method options list for ActionBar
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetGlobalMethodOptionsList()
    local globalMethodOptions =
    {
        GetString(LUIE_STRING_LAM_AB_GCD_ANIM_RADIAL),
        GetString(LUIE_STRING_LAM_AB_GCD_ANIM_VERTICAL_REVEAL),
    }
    return self:ConvertOptionsToItems(globalMethodOptions)
end

--- Get rotation options list (Horizontal/Vertical)
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetRotationOptionsList()
    local rotationOptions =
    {
        GetString(LUIE_STRING_SHARED_ORIENTATION_HORIZONTAL),
        GetString(LUIE_STRING_SHARED_ORIENTATION_VERTICAL),
    }
    return self:ConvertOptionsToItems(rotationOptions)
end

--- Bracket style dropdown (4 choices); SV stores index 1-4.
--- @return table
function SettingsAPI:GetBracketStyleOptions4List()
    return
    {
        { name = "[]",                                             data = 1 },
        { name = "()",                                             data = 2 },
        { name = "-",                                              data = 3 },
        { name = GetString(LUIE_STRING_LAM_CA_CHOICE_NO_BRACKETS), data = 4 },
    }
end

--- Bracket style dropdown (5 choices); SV stores index 1-5.
--- @return table
function SettingsAPI:GetBracketStyleOptions5List()
    return
    {
        { name = "[]",                                             data = 1 },
        { name = "()",                                             data = 2 },
        { name = "-",                                              data = 3 },
        { name = ":",                                              data = 4 },
        { name = GetString(LUIE_STRING_LAM_CA_CHOICE_NO_BRACKETS), data = 5 },
    }
end

--- @param storedValue any
--- @param defaultIndex integer
--- @param maxIndex 4|5
--- @return integer
function SettingsAPI:NormalizeBracketStyleIndex(storedValue, defaultIndex, maxIndex)
    local legacy =
    {
        ["[]"] = 1,
        ["()"] = 2,
        ["-"] = 3,
        [":"] = 4,
        ["No Brackets"] = maxIndex,
    }
    return self:NormalizeNumericIndexDropdown(storedValue, legacy, defaultIndex, maxIndex)
end

-- ---------------------------------------------------------------------------------------
-- Singleton Instance
-- ---------------------------------------------------------------------------------------
--- @class (partial) SettingsAPI_Console
LUIE.ConsoleSettingsAPI = SettingsAPI:New()
