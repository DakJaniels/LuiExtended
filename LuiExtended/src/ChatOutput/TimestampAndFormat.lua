-- -----------------------------------------------------------------------------
--  LuiExtended — Chat timestamps and CHAT_ROUTER helpers (LUIE.SV.ChatOutput)
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class LUIE_ChatOutput
local LUIE_ChatOutput = LUIE.ChatOutputClass

local select = select
local tonumber = tonumber
local unpack = unpack
local string_match = string.match
local string_format = string.format

local function getCurrentMillisecondsFormatted()
    local currentTimeMs = GetFrameTimeMilliseconds()
    return string_format("%03d", currentTimeMs % 1000)
end

--- @param self LUIE_ChatOutput
function LUIE_ChatOutput:UpdateTimeStampColor()
    local color
    local chatOutputSv = LUIE.SV and LUIE.SV.ChatOutput
    color = chatOutputSv and chatOutputSv.TimeStampColor
    if color == nil then
        color = LUIE.Defaults.ChatOutput.TimeStampColor or { 0.5607843137, 0.5607843137, 0.5607843137 }
    end
    self.timestampColorHex = ZO_ColorDef:New(unpack(color)):ToHex()
end

--- @param self LUIE_ChatOutput
--- @param timeStr string
--- @param formatStr string|nil
--- @param milliseconds string|nil
--- @return string
function LUIE_ChatOutput:CreateTimestamp(timeStr, formatStr, milliseconds)
    local chatOutput = LUIE.SV and LUIE.SV.ChatOutput or LUIE.Defaults.ChatOutput
    local usingChatDefaultFormat = formatStr == nil
    formatStr = formatStr or chatOutput.TimeStampFormat
    local formatUsesMilliseconds = type(formatStr) == "string" and zo_strfind(formatStr, "xy", 1, true) ~= nil
    if formatUsesMilliseconds then
        milliseconds = milliseconds or getCurrentMillisecondsFormatted()
    elseif usingChatDefaultFormat and chatOutput.TimeStamp then
        milliseconds = milliseconds or getCurrentMillisecondsFormatted()
    end
    if milliseconds == nil then
        milliseconds = ""
    end

    local hours, minutes, seconds = string_match(timeStr, "([^%:]+):([^%:]+):([^%:]+)")
    local hoursNoLead = tonumber(hours)
    local hours12NoLead = (hoursNoLead - 1) % 12 + 1
    local hours12
    if hours12NoLead < 10 then
        hours12 = "0" .. hours12NoLead
    else
        hours12 = hours12NoLead
    end
    local pUp = "AM"
    local pLow = "am"
    if hoursNoLead >= 12 then
        pUp = "PM"
        pLow = "pm"
    end

    local timestamp = formatStr
    timestamp = StringOnlyGSUB(timestamp, "HH", hours)
    timestamp = StringOnlyGSUB(timestamp, "H", hoursNoLead)
    timestamp = StringOnlyGSUB(timestamp, "hh", hours12)
    timestamp = StringOnlyGSUB(timestamp, "h", hours12NoLead)
    timestamp = StringOnlyGSUB(timestamp, "m", minutes)
    timestamp = StringOnlyGSUB(timestamp, "s", seconds)
    timestamp = StringOnlyGSUB(timestamp, "A", pUp)
    timestamp = StringOnlyGSUB(timestamp, "a", pLow)
    timestamp = StringOnlyGSUB(timestamp, "xy", milliseconds)
    return timestamp
end

--- @param self LUIE_ChatOutput
--- @param msg string
--- @param doTimestamp boolean
--- @param lineNumber number|nil
--- @param chanCode number|nil
--- @return string
function LUIE_ChatOutput:FormatMessage(msg, doTimestamp, lineNumber, chanCode)
    local formattedMsg = msg or ""
    if doTimestamp then
        local timestring = GetTimeString()
        local timestamp = self:CreateTimestamp(timestring, nil, nil)

        local timestampText
        if lineNumber and chanCode then
            timestampText = ZO_LinkHandler_CreateLink(timestamp, nil, "LUIE", lineNumber .. ":" .. chanCode)
        else
            timestampText = timestamp
        end

        local timestampFormatted = string_format("|c%s[%s]|r ", self.timestampColorHex, timestampText)
        formattedMsg = timestampFormatted .. formattedMsg
    end
    return formattedMsg
end

--- @param self LUIE_ChatOutput
--- @param messageOrFormatter string
--- @param ... any
function LUIE_ChatOutput:AddSystemMessage(messageOrFormatter, ...)
    local formattedMessage
    if select("#", ...) > 0 then
        formattedMessage = string_format(messageOrFormatter or "", ...)
    else
        formattedMessage = messageOrFormatter or ""
    end
    CHAT_ROUTER:AddSystemMessage(formattedMessage)
end
