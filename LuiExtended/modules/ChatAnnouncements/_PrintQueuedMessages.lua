-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

local eventManager = GetEventManager()

--- @class (partial) LuiExtended
local LUIE = LUIE
local printToChat = LUIE.PrintToChat

-- ChatAnnouncements namespace
--- @class (partial) ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements
local moduleName = ChatAnnouncements.moduleName

-- Message processor registry with explicit ordering.
local MessageProcessors =
{
    [1] =
    {
        messageType = "NOTIFICATION",
        processor = function (message)
            local isSystem = message.isSystem or false
            printToChat(message.message, isSystem)
        end
    },
    [2] =
    {
        messageType = "QUEST_POI",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [3] =
    {
        messageType = "QUEST",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [4] =
    {
        messageType = "EXPERIENCE",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [5] =
    {
        messageType = "EXPERIENCE_LEVEL",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [6] =
    {
        messageType = "SKILL_GAIN",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [7] =
    {
        messageType = "SKILL_MORPH",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [8] =
    {
        messageType = "SKILL_LINE",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [9] =
    {
        messageType = "SKILL",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [10] =
    {
        messageType = "CURRENCY_POSTAGE",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [11] =
    {
        messageType = "QUEST_LOOT_REMOVE",
        processor = function (message)
            if not ChatAnnouncements.questItemAdded[message.itemId] then
                printToChat(message.message)
            end
        end
    },
    [12] =
    {
        messageType = "CONTAINER",
        processor = function (message)
            ChatAnnouncements.ResolveItemMessage(
                message.message,
                message.formattedRecipient,
                message.color,
                message.logPrefix,
                message.totalString,
                message.groupLoot
            )
        end
    },
    [13] =
    {
        messageType = "CURRENCY",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [14] =
    {
        messageType = "QUEST_LOOT_ADD",
        processor = function (message)
            if not ChatAnnouncements.questItemRemoved[message.itemId] then
                printToChat(message.message)
            end
        end
    },
    [15] =
    {
        messageType = "LOOT",
        processor = function (message)
            ChatAnnouncements.ResolveItemMessage(
                message.message,
                message.formattedRecipient,
                message.color,
                message.logPrefix,
                message.totalString,
                message.groupLoot
            )
        end
    },
    [16] =
    {
        messageType = "ANTIQUITY",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [17] =
    {
        messageType = "COLLECTIBLE",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [18] =
    {
        messageType = "ACHIEVEMENT",
        processor = function (message)
            printToChat(message.message)
        end
    },
    [19] =
    {
        messageType = "MESSAGE",
        processor = function (message)
            local isSystem = message.isSystem or false
            printToChat(message.message, isSystem)
        end
    }
}

-- Build a direct lookup table for messageType to processor function
local MessageTypeProcessors = {}
for i = 1, #MessageProcessors do
    local entry = MessageProcessors[i]
    MessageTypeProcessors[entry.messageType] = entry.processor
end

-- Validate a message.
local function IsValidMessage(message)
    return message and message.message ~= ""
end

-- Process messages of a specific type.
local function ProcessMessages(messageType)
    local QueuedMessages = ChatAnnouncements.QueuedMessages
    local processor = MessageTypeProcessors[messageType]
    if processor then
        for i = 1, #QueuedMessages do
            local message = QueuedMessages[i]
            if IsValidMessage(message) and message.messageType == messageType then
                processor(message)
            end
        end
    end
end

-- Print queued messages.
function ChatAnnouncements.PrintQueuedMessages()
    -- Process messages in order using numeric indices
    for i = 1, #MessageProcessors do
        local processor = MessageProcessors[i]
        if processor then
            ProcessMessages(processor.messageType)
        end
    end

    -- Clear Messages and Unregister Print Event
    ChatAnnouncements.QueuedMessages = {}
    ChatAnnouncements.QueuedMessagesCounter = 1
    eventManager:UnregisterForUpdate(moduleName .. "Printer")
end
