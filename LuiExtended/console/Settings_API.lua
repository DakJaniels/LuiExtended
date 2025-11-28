-- -----------------------------------------------------------------------------
--  LuiExtended Console Settings API                                          --
--  Common utility functions for console settings modules using LHAS          --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Local references
local LMP = LibMediaProvider --- @type LibMediaProvider
local table_insert = table.insert
local table_sort = table.sort
local pairs = pairs
local ipairs = ipairs

-- ---------------------------------------------------------------------------------------
-- SettingsAPI Class
-- ---------------------------------------------------------------------------------------

--- @class (partial) SettingsAPI : ZO_InitializingObject
--- @field mediaCache table Cache for media lists to avoid regenerating them
--- @field LMP table LibMediaProvider instance
--- @field LUIE table LuiExtended namespace
local SettingsAPI = ZO_InitializingObject:Subclass()

-- ---------------------------------------------------------------------------------------
function SettingsAPI:Initialize()
    self.name = "SettingsAPI"
    self.initialized = false
    self.LMP = LMP
    self.LUIE = LUIE
    self.mediaCache =
    {
        fonts = nil,
        sounds = nil,
        statusbarTextures = nil,
    }
end

-- ---------------------------------------------------------------------------------------
-- Media Registration Functions
-- ---------------------------------------------------------------------------------------

--- Register all LUIE media with LibMediaProvider
function SettingsAPI:RegisterLUIEMedia()
    for mediaName, mediaPath in pairs(self.LUIE.Fonts) do
        self.LMP:Register(self.LMP.MediaType.FONT, mediaName, mediaPath)
    end
    for mediaName, mediaPath in pairs(self.LUIE.Sounds) do
        self.LMP:Register(self.LMP.MediaType.SOUND, mediaName, mediaPath)
    end
    for mediaName, mediaPath in pairs(self.LUIE.StatusbarTextures) do
        self.LMP:Register(self.LMP.MediaType.STATUSBAR, mediaName, mediaPath)
    end
end

--- Fetch additional media from other addons
function SettingsAPI:FetchExternalMedia()
    for _, mediaName in ipairs(self.LMP:List(self.LMP.MediaType.FONT)) do
        if not self.LUIE.Fonts[mediaName] then
            self.LUIE.Fonts[mediaName] = self.LMP:Fetch(self.LMP.MediaType.FONT, mediaName)
        end
    end
    for _, mediaName in ipairs(self.LMP:List(self.LMP.MediaType.SOUND)) do
        if not self.LUIE.Sounds[mediaName] then
            self.LUIE.Sounds[mediaName] = self.LMP:Fetch(self.LMP.MediaType.SOUND, mediaName)
        end
    end
    for _, mediaName in ipairs(self.LMP:List(self.LMP.MediaType.STATUSBAR)) do
        if not self.LUIE.StatusbarTextures[mediaName] then
            self.LUIE.StatusbarTextures[mediaName] = self.LMP:Fetch(self.LMP.MediaType.STATUSBAR, mediaName)
        end
    end
end

--- Load all media (register LUIE + fetch external)
function SettingsAPI:LoadAllMedia()
    if not self.initialized then
        self:Initialize()
        self.initialized = true
    end
    self:RegisterLUIEMedia()
    self:FetchExternalMedia()
    self:ClearMediaCache()
end

-- ---------------------------------------------------------------------------------------
-- Media List Generation Functions
-- ---------------------------------------------------------------------------------------

--- Get combined list of LUIE and LibMediaProvider fonts
--- @return table fontsList Array of {name = string, data = string} items for LHAS dropdowns
function SettingsAPI:GetFontsList()
    if self.mediaCache.fonts then
        return self.mediaCache.fonts
    end

    local fontsList = {}

    for font, _ in pairs(self.LUIE.Fonts) do
        table_insert(fontsList, { name = font, data = font })
    end
    for _, font in ipairs(self.LMP:List(self.LMP.MediaType.FONT)) do
        if not self.LUIE.Fonts[font] then
            table_insert(fontsList, { name = font, data = font })
        end
    end

    table_sort(fontsList, function (a, b) return a.name < b.name end)
    self.mediaCache.fonts = fontsList
    return fontsList
end

--- Get combined list of LUIE and LibMediaProvider sounds
--- @return table soundsList Array of {name = string, data = string} items for LHAS dropdowns
function SettingsAPI:GetSoundsList()
    if self.mediaCache.sounds then
        return self.mediaCache.sounds
    end

    local soundsList = {}

    for sound, _ in pairs(self.LUIE.Sounds) do
        table_insert(soundsList, { name = sound, data = sound })
    end
    for _, sound in ipairs(self.LMP:List(self.LMP.MediaType.SOUND)) do
        if not self.LUIE.Sounds[sound] then
            table_insert(soundsList, { name = sound, data = sound })
        end
    end

    table_sort(soundsList, function (a, b) return a.name < b.name end)
    self.mediaCache.sounds = soundsList
    return soundsList
end

--- Get combined list of LUIE and LibMediaProvider statusbar textures
--- @return table statusbarTexturesList Array of {name = string, data = string} items for LHAS dropdowns
function SettingsAPI:GetStatusbarTexturesList()
    if self.mediaCache.statusbarTextures then
        return self.mediaCache.statusbarTextures
    end

    local statusbarTexturesList = {}

    for key, _ in pairs(self.LUIE.StatusbarTextures) do
        table_insert(statusbarTexturesList, { name = key, data = key })
    end
    for _, texture in ipairs(self.LMP:List(self.LMP.MediaType.STATUSBAR)) do
        if not self.LUIE.StatusbarTextures[texture] then
            table_insert(statusbarTexturesList, { name = texture, data = texture })
        end
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
    local globalIconOptions = { "All Crowd Control", "NPC CC Only", "Player CC Only" }
    return self:ConvertOptionsToItems(globalIconOptions)
end

--- Get global alert options list for CombatInfo
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetGlobalAlertOptionsList()
    local globalAlertOptions = { "Show All Incoming Abilities", "Only Show Hard CC Effects", "Only Show Unbreakable CC Effects" }
    return self:ConvertOptionsToItems(globalAlertOptions)
end

--- Get chat name display options list for ChatAnnouncements
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetChatNameDisplayOptionsList()
    local chatNameDisplayOptions = { "@UserID", "Character Name", "Character Name @UserID" }
    return self:ConvertOptionsToItems(chatNameDisplayOptions)
end

--- Get link bracket display options list for ChatAnnouncements
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetLinkBracketDisplayOptionsList()
    local linkBracketDisplayOptions = { "No Brackets", "Display Brackets" }
    return self:ConvertOptionsToItems(linkBracketDisplayOptions)
end

--- Get guild rank display options list for ChatAnnouncements
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetGuildRankDisplayOptionsList()
    local guildRankDisplayOptions = { "Self Only", "All w/ Permissions", "All Rank Changes" }
    return self:ConvertOptionsToItems(guildRankDisplayOptions)
end

--- Get duel start options list for ChatAnnouncements
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetDuelStartOptionsList()
    local duelStartOptions = { "Message + Icon", "Message Only", "Icon Only" }
    return self:ConvertOptionsToItems(duelStartOptions)
end

--- Get global method options list for ActionBar
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetGlobalMethodOptionsList()
    local globalMethodOptions = { "Radial", "Vertical Reveal" }
    return self:ConvertOptionsToItems(globalMethodOptions)
end

--- Get rotation options list (Horizontal/Vertical)
--- @return table itemsList Array of {name = string, data = number} items for LHAS dropdowns
function SettingsAPI:GetRotationOptionsList()
    local rotationOptions = { "Horizontal", "Vertical" }
    return self:ConvertOptionsToItems(rotationOptions)
end

-- ---------------------------------------------------------------------------------------
-- Cache Management
-- ---------------------------------------------------------------------------------------

--- Clear media cache (useful for when LMP is loaded after initial load)
function SettingsAPI:ClearMediaCache()
    self.mediaCache.fonts = nil
    self.mediaCache.sounds = nil
    self.mediaCache.statusbarTextures = nil
end

--- Force refresh of all media lists
function SettingsAPI:RefreshMediaLists()
    self:ClearMediaCache()
    self:GetFontsList()
    self:GetSoundsList()
    self:GetStatusbarTexturesList()
end

--- Handle dynamic media registration from other addons
--- @param mediaType string The media type that was registered
--- @param mediaName string The name of the media that was registered
function SettingsAPI:HandleMediaRegistration(mediaType, mediaName)
    if mediaType == self.LMP.MediaType.FONT then
        self.LUIE.Fonts[mediaName] = self.LMP:Fetch(mediaType, mediaName)
    elseif mediaType == self.LMP.MediaType.SOUND then
        self.LUIE.Sounds[mediaName] = self.LMP:Fetch(mediaType, mediaName)
    elseif mediaType == self.LMP.MediaType.STATUSBAR then
        self.LUIE.StatusbarTextures[mediaName] = self.LMP:Fetch(mediaType, mediaName)
    end

    self:ClearMediaCache()
end

--- Get media path for a specific media name and type
--- @param mediaType string The media type
--- @param mediaName string The media name
--- @return string|nil The media path or nil if not found
function SettingsAPI:GetMediaPath(mediaType, mediaName)
    return self.LMP:Fetch(mediaType, mediaName)
end

--- Check if a media item exists
--- @param mediaType string The media type
--- @param mediaName string The media name
--- @return boolean True if the media exists
function SettingsAPI:IsMediaValid(mediaType, mediaName)
    return self.LMP:IsValid(mediaType, mediaName)
end

--- Get the LibMediaProvider instance
--- @return table The LibMediaProvider instance
function SettingsAPI:GetLibMediaProvider()
    return self.LMP
end

--- Get the LibMediaProvider MediaType constants
--- @return table The MediaType constants
function SettingsAPI:GetMediaTypes()
    return self.LMP.MediaType
end

-- ---------------------------------------------------------------------------------------
-- Singleton Instance
-- ---------------------------------------------------------------------------------------

LUIE.ConsoleSettingsAPI = SettingsAPI:New()
