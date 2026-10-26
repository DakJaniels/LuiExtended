-- -----------------------------------------------------------------------------
--  LuiExtended - debug environment (LUIE-core addon allowlist via /luie debug)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local addOnManager = GetAddOnManager()
local eventManager = GetEventManager()
local GetString = GetString
local zo_strlower = zo_strlower
local string_format = string.format
local pairs = pairs

local debugEnvironmentLogoutPrehooked = false
local debugEnvironmentReloadChatShown = false

local DEBUG_ENVIRONMENT_RELOAD_CHAT_NAMESPACE = "LuiExtended_DebugEnvironmentReloadChat"

--- Stored in SV (not localized text) so reload chat respects client locale.
local PENDING_CHAT_TOKEN_ACTIVE = "@LUIE_DEBUG_ENV_ACTIVE@"
local PENDING_CHAT_TOKEN_DISABLED = "@LUIE_DEBUG_ENV_DISABLED@"

--- Pre-token SavedVariables (English); resolved via GetString on display.
local LEGACY_PENDING_ACTIVE =
"Debug environment is active. LUIE core addons were enabled; you may enable more addons to test interactions. Use '/luie debug off' to restore your addon list."
local LEGACY_PENDING_DISABLED = "Debug environment disabled. Your previous addon selection was restored."

local CORE_ALLOWLIST =
{
    ["LuiExtended"] = true,
    ["LuiData"] = true,
    ["LuiMedia"] = true,
    ["LibMediaProvider"] = true,
}

--- LuiExtended.addon ## OptionalDependsOn (version suffixes stripped).
local OPTIONAL_DEPENDENCY_ALLOWLIST =
{
    ["LibChatMessage"] = true,
    ["pChat"] = true,
    ["rChat"] = true,
    ["GamepadMiniChatTabs"] = true,
    ["CombatMetrics"] = true,
    ["CrutchAlerts"] = true,
    ["LibGroupResources"] = true,
    ["LibGroupCombatStats"] = true,
    ["LibGroupPotionCooldowns"] = true,
    ["LibDebugLogger"] = true,
    ["DebugLogViewer"] = true,
    ["DolgubonsLazyWritCreator"] = true,
    ["LibLazyCrafting"] = true,
    ["LootLog"] = true,
    ["Taneth"] = true,
    ["LibCombat"] = true,
    ["LibCombat2"] = true,
    ["LibSlashCommander"] = true,
    ["HarvestMap"] = true,
    ["LibMapPins-1.0"] = true,
    ["Pre101046UI"] = true,
    ["LibCustomNames"] = true,
    ["LibCustomIcons"] = true,
}

--- ## DependsOn / ## PCDependsOn / ## ConsoleDependsOn of the addons above.
--- LibAddonMenu-2.0 is core on PC. LibHarvensAddonSettings is core on console.
--- Both are listed here so the other platform still loads addons that require them.
local OPTIONAL_DEPENDENCY_REQUIRED_ALLOWLIST =
{
    -- HarvestMap.addon and pChat.txt
    ["LibMainMenu-2.0"] = true,
    -- HarvestMapData/Modules: addon names are the manifest folders, not the parent folder.
    -- SubmoduleManager.lua registers these on EVENT_ADD_ON_LOADED. Each DependsOn HarvestMap.
    ["HarvestMapAD"] = true,
    ["HarvestMapDC"] = true,
    ["HarvestMapEP"] = true,
    ["HarvestMapDLC"] = true,
    ["HarvestMapNF"] = true,
    -- HarvestMap.addon ## OptionalDependsOn. Addon folder is HarvestMap/Libs/NodeDetection.
    ["NodeDetection"] = true,
    -- pChat.txt; also CombatMetrics.addon and DebugLogViewer.addon
    ["LibCustomMenu"] = true,
    -- pChat.txt
    ["LibAddonMenuSoundSlider"] = true,
    -- GamepadMiniChatTabs.addon
    ["LibHarvensAddonSettings"] = true,
    ["LibRadialMenu"] = true,
    -- LibGroupResources.addon, LibGroupCombatStats.addon, LibGroupPotionCooldowns.addon
    ["LibGroupBroadcast"] = true,
    -- LootLog.addon
    ["LibExtendedJournal"] = true,
    -- CombatMetrics.addon; CombatMetricsFightData.txt also DependsOn LibDataEncode and LibCombat
    ["CombatMetricsFightData"] = true,
    ["LibDataEncode"] = true,
    -- DebugLogViewer.addon
    ["LibGetText"] = true,
    -- DolgubonsLazyWritCreator.addon ## ConsoleDependsOn
    ["LibPrice"] = true,
    ["LibQRCode"] = true,
    -- DolgubonsLazyWritCreator.addon ## OptionalDependsOn. Standalone LibFeedback.addon DependsOn LibDebugLogger.
    ["LibFeedback"] = true,
    -- HarvestMap, pChat, LibCustomIcons, LibGroupBroadcast, CombatMetrics, DebugLogViewer, LibRadialMenu
    ["LibAddonMenu-2.0"] = true,
}

--- @class AddOnScanEntry
--- @field index luaindex
--- @field name string

--- Snapshot and cached indices for apply (one AddOnManager pass).
--- @return table<string, boolean> states
--- @return AddOnScanEntry[] entries
local function ScanAddOnManager()
    local states = {}
    local entries = {}
    local numAddOns = addOnManager:GetNumAddOns()
    for i = 1, numAddOns do
        local name, _, _, _, enabled = addOnManager:GetAddOnInfo(i)
        if name then
            states[name] = enabled
            entries[#entries + 1] = { index = i, name = name }
        end
    end
    return states, entries
end

--- @param enabledByName table<string, boolean>
--- @param entries AddOnScanEntry[]|nil from ScanAddOnManager; omit for restore-only apply
local function ApplyEnabledByName(enabledByName, entries)
    if entries then
        for entryIndex = 1, #entries do
            local entry = entries[entryIndex]
            addOnManager:SetAddOnEnabled(entry.index, enabledByName[entry.name] == true)
        end
        return
    end
    local numAddOns = addOnManager:GetNumAddOns()
    for i = 1, numAddOns do
        local name, _, _, _, _ = addOnManager:GetAddOnInfo(i)
        if name then
            addOnManager:SetAddOnEnabled(i, enabledByName[name] == true)
        end
    end
end

--- @param entries AddOnScanEntry[]
--- @return table<string, luaindex>
local function BuildAddOnIndexByName(entries)
    local addOnIndexByName = {}
    for entryIndex = 1, #entries do
        local entry = entries[entryIndex]
        addOnIndexByName[entry.name] = entry.index
    end
    return addOnIndexByName
end

--- Required ## DependsOn only. GetAddOnDependencyInfo does not return ## OptionalDependsOn.
--- @param allowlist table<string, boolean>
--- @param addOnIndexByName table<string, luaindex>
local function AddRequiredDependenciesToAllowlist(allowlist, addOnIndexByName)
    local namesToVisit = {}
    for addOnName in pairs(allowlist) do
        namesToVisit[#namesToVisit + 1] = addOnName
    end
    local visitedAddOnName = {}
    local visitIndex = 1
    while visitIndex <= #namesToVisit do
        local addOnName = namesToVisit[visitIndex]
        visitIndex = visitIndex + 1
        if not visitedAddOnName[addOnName] then
            visitedAddOnName[addOnName] = true
            local addOnIndex = addOnIndexByName[addOnName]
            if addOnIndex then
                local numDependencies = addOnManager:GetAddOnNumDependencies(addOnIndex)
                for dependencyIndex = 1, numDependencies do
                    local dependencyName = addOnManager:GetAddOnDependencyInfo(addOnIndex, dependencyIndex)
                    if dependencyName and dependencyName ~= "" and not allowlist[dependencyName] then
                        allowlist[dependencyName] = true
                        namesToVisit[#namesToVisit + 1] = dependencyName
                    end
                end
            end
        end
    end
end

--- @param includeOptionalDependencies boolean
--- @param entries AddOnScanEntry[]
--- @return table<string, boolean>
local function GetDebugEnvironmentAllowlist(includeOptionalDependencies, entries)
    local allowlist = {}
    for name in pairs(CORE_ALLOWLIST) do
        allowlist[name] = true
    end
    if ZO_IsConsoleOrGameCoreUI() then
        allowlist["LibHarvensAddonSettings"] = true
        allowlist["LibConsoleDialogs"] = true
    else
        allowlist["LibAddonMenu-2.0"] = true
    end
    if includeOptionalDependencies then
        for name in pairs(OPTIONAL_DEPENDENCY_ALLOWLIST) do
            allowlist[name] = true
        end
        for name in pairs(OPTIONAL_DEPENDENCY_REQUIRED_ALLOWLIST) do
            allowlist[name] = true
        end
        AddRequiredDependenciesToAllowlist(allowlist, BuildAddOnIndexByName(entries))
    end
    return allowlist
end

local function DebugEnvironmentChat(message)
    LUIE.ChatOutput:Print(message, true)
end

local function GetDebugEnvironmentActiveReloadMessage()
    if LUIE.SV and LUIE.SV.DebugEnvironmentIncludeOptionalDependencies == true then
        return GetString(LUIE_STRING_DEBUG_ENV_ACTIVE_RELOAD_OPTDEPS)
    end
    return GetString(LUIE_STRING_DEBUG_ENV_ACTIVE_RELOAD)
end

--- @param pending string|nil
--- @return string|nil
local function ResolvePendingChatMessage(pending)
    if not pending or pending == "" then
        return nil
    end
    if pending == PENDING_CHAT_TOKEN_ACTIVE or pending == LEGACY_PENDING_ACTIVE then
        return GetDebugEnvironmentActiveReloadMessage()
    end
    if pending == PENDING_CHAT_TOKEN_DISABLED or pending == LEGACY_PENDING_DISABLED then
        return GetString(LUIE_STRING_DEBUG_ENV_DISABLED_RESTORE)
    end
    return pending
end

--- @return boolean
function LUIE.IsDebugEnvironmentActive()
    return LUIE.SV and LUIE.SV.DebugEnvironmentActive == true
end

local function ClearDebugEnvironmentSavedVars()
    if not LUIE.SV then
        return
    end
    LUIE.SV.DebugEnvironmentActive = false
    LUIE.SV.DebugEnvironmentRestore = nil
    LUIE.SV.DebugEnvironmentPendingChat = nil
    LUIE.SV.DebugEnvironmentIncludeOptionalDependencies = nil
end

--- Restore pre-debug addon selection and clear debug SV before logout unloads the UI.
local function EndDebugEnvironmentForLogout()
    if not LUIE.SV or not LUIE.IsDebugEnvironmentActive() then
        return
    end
    local restore = LUIE.SV.DebugEnvironmentRestore
    if restore then
        ApplyEnabledByName(restore)
    end
    ClearDebugEnvironmentSavedVars()
end

function LUIE.RegisterDebugEnvironmentLogoutHooks()
    if debugEnvironmentLogoutPrehooked then
        return
    end
    ZO_PreHook("Logout", EndDebugEnvironmentForLogout)
    ZO_PreHook("Quit", EndDebugEnvironmentForLogout)
    debugEnvironmentLogoutPrehooked = true
end

--- @param enable boolean
--- @param includeOptionalDependencies boolean|nil
--- @return boolean success
--- @return string? message
function LUIE.ApplyDebugEnvironment(enable, includeOptionalDependencies)
    if enable then
        if LUIE.IsDebugEnvironmentActive() then
            return false, GetString(LUIE_STRING_DEBUG_ENV_ALREADY_ACTIVE)
        end
        local currentStates, entries = ScanAddOnManager()
        LUIE.SV.DebugEnvironmentRestore = currentStates
        ApplyEnabledByName(GetDebugEnvironmentAllowlist(includeOptionalDependencies == true, entries), entries)
        LUIE.SV.DebugEnvironmentActive = true
        LUIE.SV.DebugEnvironmentIncludeOptionalDependencies = includeOptionalDependencies == true
        LUIE.SV.DebugEnvironmentPendingChat = PENDING_CHAT_TOKEN_ACTIVE
        return true, GetString(LUIE_STRING_DEBUG_ENV_ENABLE_RELOAD)
    end

    if not LUIE.IsDebugEnvironmentActive() then
        return false, GetString(LUIE_STRING_DEBUG_ENV_NOT_ACTIVE)
    end
    local restore = LUIE.SV.DebugEnvironmentRestore
    if not restore then
        LUIE.SV.DebugEnvironmentActive = false
        LUIE.SV.DebugEnvironmentIncludeOptionalDependencies = nil
        return false, GetString(LUIE_STRING_DEBUG_ENV_NO_RESTORE)
    end
    ApplyEnabledByName(restore)
    LUIE.SV.DebugEnvironmentActive = false
    LUIE.SV.DebugEnvironmentRestore = nil
    LUIE.SV.DebugEnvironmentIncludeOptionalDependencies = nil
    LUIE.SV.DebugEnvironmentPendingChat = PENDING_CHAT_TOKEN_DISABLED
    return true, GetString(LUIE_STRING_DEBUG_ENV_DISABLE_RELOAD)
end

--- One-shot message after debug on/off, or the active reminder on any reload while debug is on.
--- @return string|nil
local function TakeDebugEnvironmentReloadChatMessage()
    if not LUIE.SV then
        return nil
    end
    local pending = LUIE.SV.DebugEnvironmentPendingChat
    if pending and pending ~= "" then
        LUIE.SV.DebugEnvironmentPendingChat = nil
        return ResolvePendingChatMessage(pending)
    end
    if LUIE.IsDebugEnvironmentActive() then
        return GetDebugEnvironmentActiveReloadMessage()
    end
    return nil
end

--- Prints at most once per UI load (pending on/off transition, or active reminder while debug is on).
local function ShowDebugEnvironmentReloadChatOnce()
    if debugEnvironmentReloadChatShown then
        return
    end
    debugEnvironmentReloadChatShown = true
    eventManager:UnregisterForEvent(DEBUG_ENVIRONMENT_RELOAD_CHAT_NAMESPACE, EVENT_PLAYER_ACTIVATED)

    local message = TakeDebugEnvironmentReloadChatMessage()
    if not message then
        return
    end
    zo_callLater(function ()
                     DebugEnvironmentChat(message)
                 end, 0)
end

--- After init: show on ReloadUI when already in world, or on first EVENT_PLAYER_ACTIVATED when not.
function LUIE.ScheduleDebugEnvironmentReloadChat()
    if IsPlayerActivated() then
        zo_callLater(ShowDebugEnvironmentReloadChatOnce, 0)
        return
    end
    eventManager:RegisterForEvent(DEBUG_ENVIRONMENT_RELOAD_CHAT_NAMESPACE, EVENT_PLAYER_ACTIVATED, ShowDebugEnvironmentReloadChatOnce)
end

local function PrintDebugEnvironmentStatus()
    local active = LUIE.IsDebugEnvironmentActive()
    local restore = LUIE.SV.DebugEnvironmentRestore
    if active then
        local count = 0
        if restore then
            for _ in pairs(restore) do
                count = count + 1
            end
        end
        DebugEnvironmentChat(zo_strformat(GetString(LUIE_STRING_DEBUG_ENV_STATUS_ACTIVE), count))
    else
        DebugEnvironmentChat(GetString(LUIE_STRING_DEBUG_ENV_STATUS_INACTIVE))
    end
end

local function PrintUsage()
    DebugEnvironmentChat(GetString(LUIE_STRING_DEBUG_ENV_USAGE_DEBUG))
    DebugEnvironmentChat(GetString(LUIE_STRING_DEBUG_ENV_USAGE_SVSTATUS))
end

function LUIE.LuieSlashCommandPrintUsage()
    PrintUsage()
end

function LUIE.LuieSlashCommandSvStatus()
    LUIE.PrintSavedVariablesMigrationStatus()
end

function LUIE.LuieSlashCommandDebug(action)
    action = zo_strlower(zo_strtrim(action or ""))
    if action == "" or action == "status" then
        PrintDebugEnvironmentStatus()
        return
    end
    if action == "on" or action == "on optdeps" then
        local includeOptionalDependencies = action == "on optdeps"
        local success, message = LUIE.ApplyDebugEnvironment(true, includeOptionalDependencies)
        DebugEnvironmentChat(message or "")
        if success then
            zo_callLater(function ()
                             ReloadUI("ingame")
                         end, 250)
        end
        return
    end
    if action == "off" then
        local success, message = LUIE.ApplyDebugEnvironment(false)
        DebugEnvironmentChat(message or "")
        if success then
            zo_callLater(function ()
                             ReloadUI("ingame")
                         end, 250)
        end
        return
    end
    PrintUsage()
end

function LUIE.OnLuieSlashCommand(args)
    args = zo_strtrim(args or "")
    if args == "" then
        PrintUsage()
        return
    end
    local sub, action = zo_strlower(args):match("^(%S+)%s*(.*)$")
    sub = sub or ""
    action = action or ""
    if sub == "svstatus" then
        LUIE.LuieSlashCommandSvStatus()
        return
    end
    if sub ~= "debug" then
        PrintUsage()
        return
    end
    LUIE.LuieSlashCommandDebug(action)
end
