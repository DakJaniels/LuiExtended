-- -----------------------------------------------------------------------------
--  LuiExtended — debug environment (LUIE-core addon allowlist via /luie debug)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local addOnManager = GetAddOnManager()
local zo_strlower = zo_strlower
local string_format = string.format
local pairs = pairs

local CORE_ALLOWLIST =
{
    ["LuiExtended"] = true,
    ["LuiData"] = true,
    ["LuiMedia"] = true,
    ["LibMediaProvider"] = true,
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
        local name = addOnManager:GetAddOnInfo(i)
        if name then
            addOnManager:SetAddOnEnabled(i, enabledByName[name] == true)
        end
    end
end

--- @return table<string, boolean>
local function GetDebugEnvironmentAllowlist()
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
    return allowlist
end

local function DebugEnvironmentChat(message)
    LUIE.AddSystemMessage("[LUIE] " .. message)
end

--- @return boolean
function LUIE.IsDebugEnvironmentActive()
    return LUIE.SV.DebugEnvironmentActive == true
end

--- @param enable boolean
--- @return boolean success
--- @return string? message
function LUIE.ApplyDebugEnvironment(enable)
    if enable then
        if LUIE.IsDebugEnvironmentActive() then
            return false, "Debug environment is already active. Use '/luie debug off' first."
        end
        local currentStates, entries = ScanAddOnManager()
        LUIE.SV.DebugEnvironmentRestore = currentStates
        ApplyEnabledByName(GetDebugEnvironmentAllowlist(), entries)
        LUIE.SV.DebugEnvironmentActive = true
        LUIE.SV.DebugEnvironmentPendingChat = "Debug environment is active. Only LUIE core addons are enabled. Use '/luie debug off' to restore your addon list."
        return true, "Debug environment enabled. Reloading UI..."
    end

    if not LUIE.IsDebugEnvironmentActive() then
        return false, "Debug environment is not active."
    end
    local restore = LUIE.SV.DebugEnvironmentRestore
    if not restore then
        LUIE.SV.DebugEnvironmentActive = false
        return false, "Debug environment has no restore snapshot. Toggle addons manually in the AddOns menu."
    end
    ApplyEnabledByName(restore)
    LUIE.SV.DebugEnvironmentActive = false
    LUIE.SV.DebugEnvironmentRestore = nil
    LUIE.SV.DebugEnvironmentPendingChat = "Debug environment disabled. Your previous addon selection was restored."
    return true, "Debug environment disabled. Reloading UI..."
end

--- Shows a chat line queued before ReloadUI (post-reload confirmation). Call after saved vars load.
function LUIE.ShowDebugEnvironmentPendingChat()
    if not LUIE.SV then
        return
    end
    local message = LUIE.SV.DebugEnvironmentPendingChat
    if not message or message == "" then
        return
    end
    LUIE.SV.DebugEnvironmentPendingChat = nil
    zo_callLater(function ()
                     DebugEnvironmentChat(message)
                 end, 0)
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
        DebugEnvironmentChat(string_format("Debug environment: active (%d addons in restore snapshot).", count))
    else
        DebugEnvironmentChat("Debug environment: inactive.")
    end
end

local function PrintUsage()
    DebugEnvironmentChat("Usage: /luie debug on | off | status")
end

function LUIE.OnLuieSlashCommand(args)
    args = zo_strtrim(args or "")
    if args == "" then
        PrintUsage()
        return
    end
    local sub, action = zo_strlower(args):match("^(%S+)%s*(%S*)")
    sub = sub or ""
    action = action or ""
    if sub ~= "debug" then
        PrintUsage()
        return
    end
    if action == "" or action == "status" then
        PrintDebugEnvironmentStatus()
        return
    end
    if action == "on" then
        local success, message = LUIE.ApplyDebugEnvironment(true)
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
