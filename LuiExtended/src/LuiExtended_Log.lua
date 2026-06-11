-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Default log settings
LUIE.log_to_chat = false
LUIE.log_stack_traces = true

local LOG_PROCESSOR_UPDATE = "LUIE_LogProcessor"
local log_queue = {}
local log_processor_scheduled = false

------------------------------
--- Debugging              ---
------------------------------
LUIE.show_log = false
if LUIE.IsDevDebugEnabled() then
    LUIE.show_log = true
end
LUIE.loggerName = "LUIE"

local logger
local viewer
if DebugLogViewer then
    viewer = true
else
    viewer = false
end
if LibDebugLogger then
    -- LibDebugLogger.internal.verboseWhitelist[LUIE.loggerName] = true
    LUIE.logger = LibDebugLogger.Create(LUIE.loggerName)
    logger = true
else
    logger = false
end

local function create_log(log_type, log_content)
    log_content = log_content or "[nil]"
    if not viewer and log_type == "Info" then
        CHAT_ROUTER:AddSystemMessage(log_content)
        return
    end
    if logger and log_type == "Info" then
        LUIE.logger:Info(log_content)
    end
    if not LUIE.show_log then return end
    if logger and log_type == "Debug" then
        LUIE.logger:Debug(log_content)
    end
    if logger and log_type == "Verbose" then
        LUIE.logger:Verbose(log_content)
    end
    if logger and log_type == "Warn" then
        LUIE.logger:Warn(log_content)
    end
end

local function process_next_log_job()
    local job = table.remove(log_queue, 1)
    if job then
        create_log(job[1], job[2] or "[nil]")
    end
end

local function on_log_processor_update()
    process_next_log_job()
    if #log_queue == 0 then
        GetEventManager():UnregisterForUpdate(LOG_PROCESSOR_UPDATE)
        log_processor_scheduled = false
    end
end

local function schedule_log_processor()
    if log_processor_scheduled then return end
    log_processor_scheduled = true
    GetEventManager():RegisterForUpdate(LOG_PROCESSOR_UPDATE, 0, on_log_processor_update)
end

local function emit_message(log_type, text)
    if text == "" then
        text = "[Empty String]"
    elseif text == nil then
        text = "[nil]"
    end
    table.insert(log_queue, { log_type, text })
    schedule_log_processor()
end

local function emit_userdata(log_type, udata)
    local function_limit = 10 -- max functions to list
    local total_limit = 20    -- max total entries (functions + non-functions)
    local function_count = 0
    local entry_count = 0

    local function emit(msg)
        emit_message(log_type, msg)
    end

    local function try(label, obj, fn)
        local ok, res = pcall(fn, obj)
        if ok and res ~= nil then
            emit("  " .. label .. ": " .. tostring(res))
        end
    end

    emit("Userdata: " .. tostring(udata))

    -- Quick, high-signal probes
    if type(udata) == "userdata" then
        if udata.GetName then
            try("GetName", udata, udata.GetName)
        end
        if udata.GetParent then
            try("Parent", udata, function (o)
                local p = o:GetParent()
                return p and p:GetName()
            end)
        end
        if udata.GetOwningWindow then
            try("Owner", udata, function (o)
                local w = o:GetOwningWindow()
                return w and w:GetName()
            end)
        end
        if udata.GetType then
            try("Type", udata, udata.GetType)
        end
    end

    -- Metatable introspection with limits
    local meta = getmetatable(udata)
    if not meta then
        emit("  (No metatable)")
        return
    end

    emit("  (metatable present)")
    local idx = meta.__index
    if type(idx) ~= "table" then
        emit("  __index is " .. type(idx))
        return
    end

    for k, v in pairs(idx) do
        if type(v) == "function" then
            if function_count < function_limit and entry_count < total_limit then
                emit("  Function: " .. tostring(k))
                function_count = function_count + 1
                entry_count = entry_count + 1
            end
        else
            if entry_count < total_limit then
                emit("  " .. tostring(k) .. ": " .. tostring(v))
                entry_count = entry_count + 1
            end
        end

        if entry_count >= total_limit then
            emit("  ... (output truncated due to limit)")
            break
        end
    end
end

local function emit_table(log_type, t, indent, table_history)
    indent = indent or "."
    table_history = table_history or {}

    if t == nil then
        emit_message(log_type, indent .. "[Nil Table]")
        return
    end
    if next(t) == nil then
        emit_message(log_type, indent .. "[Empty Table]")
        return
    end
    if table_history[t] then
        emit_message(log_type, indent .. "[Cycle Detected]")
        return
    end
    table_history[t] = true

    for k, v in pairs(t) do
        local vt = type(v)
        if vt == "table" then
            emit_message(log_type, indent .. "(table): " .. tostring(k) .. " = {")
            emit_table(log_type, v, indent .. "  ", table_history)
            emit_message(log_type, indent .. "}")
        elseif vt == "userdata" then
            emit_message(log_type, indent .. "(userdata): " .. tostring(k) .. " = " .. tostring(v))
            emit_userdata(log_type, v)
        else
            emit_message(log_type, indent .. "(" .. vt .. "): " .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

local function contains_placeholders(str)
    return type(str) == "string" and str:find("<<%d+>>")
end

function LUIE:Log(log_type, ...)
    if not LUIE.show_log then
        if log_type == "Info" then
        else
            -- Exit early if show_log is false and log_type is not "Info"
            return
        end
    end

    local num_args = select("#", ...)
    local first_arg = select(1, ...) -- The first argument is always the message string

    -- Check if the first argument is a string with placeholders
    if type(first_arg) == "string" and contains_placeholders(first_arg) then
        -- Extract any remaining arguments for zo_strformat (after the message string)
        local remaining_args = { select(2, ...) }

        -- Format the string with the remaining arguments
        local formatted_value = zo_strformat(first_arg, unpack(remaining_args))

        -- Emit the formatted message
        emit_message(log_type, formatted_value)

        -- Also emit any remaining arguments (userdata, tables, etc.)
        for i = 1, #remaining_args do
            local value = remaining_args[i]
            if type(value) == "userdata" then
                emit_userdata(log_type, value)
            elseif type(value) == "table" then
                emit_table(log_type, value)
            elseif value ~= nil then
                emit_message(log_type, tostring(value))
            end
        end
        return
    end

    -- Process other argument types (userdata, tables, etc.)
    for i = 1, num_args do
        local value = select(i, ...)
        if type(value) == "userdata" then
            emit_userdata(log_type, value)
        elseif type(value) == "table" then
            emit_table(log_type, value)
        else
            emit_message(log_type, tostring(value))
        end
    end
end
