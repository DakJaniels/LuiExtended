local NAME = "AntiClankerAddonConsortiumUpdateChecker"
local VERSION = 25

if type(_G[NAME]) == "number" and _G[NAME] >= VERSION then return end
_G[NAME] = VERSION

local KNOWN_VERSIONS = {
    -- Kyzeragon
    ["CrutchAlerts"]          = 22700,
    ["KyzderpsDerps"]         = 1540,

    -- code65536
    ["CharacterKnowledge"]    = 301030,
    ["CollectiblesTracker"]   = 306020,
    ["CombatAlerts"]          = 206070,
    ["GroupBuffPanels"]       = 203030,
    ["ItemBrowser"]           = 407010,
    ["LootLog"]               = 410010,
    ["Raidificator"]          = 407030,

    -- M0R_Gaming
    ["M0RMarkers"]            = 223,

    -- DakJaniels
    ["LuiExtended"]           = 7269,

    -- m00nyONE
    ["LibGroupCombatStats"]   = 20260726,
}

local MESSAGE = {
    default = "[LibForgottenAddons] You have the addon “<<1>>” installed, but it is an older version. Your version is <<2>>, while the expected version is <<3>> or newer.",
    de = "[LibForgottenAddons] Du hast das Add-on „<<1>>“ installiert, aber es handelt sich dabei um eine veraltete Version. Deine Version ist <<2>>, während die erwartete Version <<3>> oder neuer ist.",
    es = "[LibForgottenAddons] Tienes una instalación antigua del addon “<<1>>”. Tu instalación es la versión <<2>> mientras que la versión esperada es <<3>> o más reciente.",
    fr = "[LibForgottenAddons] Votre addon “<<1>>” n'est plus à jour. La version installée est <<2>> au lieu de <<3>> ou mieux.",
    jp = "[LibForgottenAddons] インストールされているアドオン「<<1>>」は古いバージョンです。現在のバージョンは <<2>> ですが、必要なバージョンは <<3>> 以上です。",
    ru = "[LibForgottenAddons] Установленная у вас версия дополнения “<<1>>” устарела. Текущая версия установленного дополнения <<2>>. Установите версию <<3>> или выше.",
    zh = "[LibForgottenAddons] 你当前使用的<<1>>为旧版本。当前的版本为<<2>>，而推荐版本为<<3>>或者更新。",
}
MESSAGE = MESSAGE[GetCVar("Language.2")] or MESSAGE.default

local PANEL_ID = "LibForgottenAddonsSettings"

---------------------------------------------------------------------
-- Version check
---------------------------------------------------------------------
-- Addon table like ACACUC_CrutchAlerts = {notifiedVersion = 22300, times = 1}
local SV_PREFIX = "ACACUC_"
local function GetSV(addonName, createIfNecessary)
    local addonTable = _G[SV_PREFIX .. addonName]
    if (type(addonTable) == "table") then
        return addonTable
    elseif (createIfNecessary) then
        addonTable = {}
        _G[SV_PREFIX .. addonName] = addonTable
        return addonTable
    end
end

local function SetEnablementState(enabled)
    local newState = GetTimeStamp() + (enabled and BitLShift(1, 33) or 0)
    local am = GetAddOnManager()
    for i = 1, am:GetNumAddOns() do
        local addonName, _, _, _, addonEnabled = am:GetAddOnInfo(i)
        if addonEnabled and KNOWN_VERSIONS[addonName] then
            local sv = GetSV(addonName, true)
            sv.enabled = newState
        end
    end
end

local function GetEnablementState()
    local lastStateSeen = true
    local lastStateTime = 0
    for addonName in pairs(KNOWN_VERSIONS) do
        local sv = GetSV(addonName)
        if (sv and sv.enabled) then
            local svTime = BitAnd(sv.enabled, 0x1FFFFFFFF)
            if (svTime > lastStateTime) then
                lastStateTime = svTime
                lastStateSeen = BitRShift(sv.enabled, 33) == 1
            end
        end
    end

    -- Continuity with legacy ACACUpdateCheckDisabled
    if (lastStateTime == 0 and ACACUpdateCheckDisabled ~= nil) then
        ACACUpdateCheckDisabled = nil
        SetEnablementState(false)
        return false
    end

    return lastStateSeen
end

---------------------------------------------------------------------
-- Setting
---------------------------------------------------------------------
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if (not LAM) then return false end

    local panelData = {
        type = "panel",
        name = "LibForgottenAddons",
        author = "Kyzeragon, @code65536",
        version = tostring(VERSION),
    }

    local optionsData = {
        {
            type = "description",
            text = "LibForgottenAddons is a bundled library distributed within multiple addons. It checks installed add-on versions against known versions, because Minion 3 tends to \"forget\" the addons that it's tracking.",
        },
        {
            type = "checkbox",
            name = "Enabled",
            tooltip = "Whether to check addon versions on initial load. This will take effect on the next reload.\n\nThis settings page is shown only when you have been notified about an update. |cFF5555If you disable update notifications, this settings page will be removed \"forever.\"|r To get it back later, use the command\n/libforgottenaddonsenable",
            default = true,
            getFunc = GetEnablementState,
            setFunc = SetEnablementState,
            warning = "This settings page is shown only when you have been notified about an update. |cFF5555If you disable update notifications, this settings page will be removed \"forever.\"|r To get it back later, use the command\n/libforgottenaddonsenable",
            isDangerous = true,
        },
        {
            type = "description",
            text = "To fix Minion 3's forgotten addons, search for and install the individual addons again. If you think you have already updated and reloaded UI, there could be issues with OneDrive confusing ESO / Minion with a second Documents folder. It's recommended to turn off OneDrive if you don't actually use it, but remember to back up your files first!\n\nYou can also consider trying the Minion 4 beta, which has automatic dependency handling.",
        },
        {
            type = "description",
            text = "\n\nAddons that bundle this library include Character Knowledge, Collectibles Tracker, Code's Combat Alerts, CrutchAlerts, Group Buff Panels, Item Set Browser, Kyzderp's Derps, Loot Log, Lui Extended, More Markers, and Raidificator.",
        },
    }

    LAM:RegisterAddonPanel(PANEL_ID, panelData)
    LAM:RegisterOptionControls(PANEL_ID, optionsData)

    return true
end


---------------------------------------------------------------------
-- Run on load
---------------------------------------------------------------------
local function CheckVersions()
    local am = GetAddOnManager()

    local messageQueue = nil
    for i = 1, am:GetNumAddOns() do
        local addonName, addonTitle, _, _, addonEnabled = am:GetAddOnInfo(i)

        if addonEnabled and KNOWN_VERSIONS[addonName] then
            local installedVersion = am:GetAddOnVersion(i) or 0
            local expectedVersion = KNOWN_VERSIONS[addonName]

            if installedVersion < expectedVersion then
                -- Only notify the same version up to 3 times (assuming the SV table is defined)
                local sv = GetSV(addonName)

                local notifiedVersion = (sv and sv.notifiedVersion) or 0
                local timesNotified = 0
                if (expectedVersion == notifiedVersion) then
                    timesNotified = (sv and sv.times) or 0
                end

                if (timesNotified < 3) then
                    messageQueue = messageQueue or {}
                    table.insert(messageQueue, zo_strformat(MESSAGE, addonTitle, installedVersion, expectedVersion))

                    -- Save number of times this version has been notified
                    sv = GetSV(addonName, true)
                    sv.notifiedVersion = expectedVersion
                    sv.times = timesNotified + 1
                end
            end
        end
    end

    if (messageQueue) then
        if (CreateSettingsMenu()) then -- menu creation can fail if no LAM
            table.insert(messageQueue, "[LibForgottenAddons] For more information, |c20aaf5|H0:ACACUC:1|h[open the settings]|h|r.")
        end
        zo_callLater(function()
            for _, message in ipairs(messageQueue) do
                CHAT_ROUTER:AddSystemMessage(message)
            end
        end, 6000)
    end
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_PLAYER_ACTIVATED) -- In case we are overriding an older version embedded in another addon

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, function()
    if (GetEnablementState()) then
        CheckVersions()
    else
        SLASH_COMMANDS["/libforgottenaddonsenable"] = function()
            CHAT_ROUTER:AddSystemMessage("[LibForgottenAddons] Enabled. This will take effect on the next reload.")
            SetEnablementState(true)
        end
    end

    -- Always register the link handler because there can be an error with unhandled links, e.g. if clicking an old link in pChat history
    local linkHandler = function(_, _, _, _, linkType)
        if (linkType == "ACACUC") then
            if (_G[PANEL_ID] or CreateSettingsMenu()) then
                LibAddonMenu2:OpenToPanel(_G[PANEL_ID])
            else
                CHAT_ROUTER:AddSystemMessage("[LibForgottenAddons] Cannot open settings because LibAddonMenu-2.0 is not available.")
            end
            return true
        end
    end
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, linkHandler)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, linkHandler)
end, true)
