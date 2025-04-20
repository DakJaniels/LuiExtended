-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- -----------------------------------------------------------------------------
local eventManager = GetEventManager()
local pairs = pairs
local ipairs = ipairs
local select = select
local tonumber = tonumber
local type = type
local string_find = LUIE.string and LUIE.string.find
local string_gmatch = LUIE.string and LUIE.string.gmatch
local string_gsub = LUIE.string and LUIE.string.gsub
local string_match = LUIE.string and LUIE.string.match
local string_rep = LUIE.string and LUIE.string.rep
local string_format = LUIE.string and LUIE.string.format
local table_concat = LUIE.table and LUIE.table.concat
local table_insert = LUIE.table and LUIE.table.insert
local table_move = LUIE.table and LUIE.table.move
local table_remove = LUIE.table and LUIE.table.remove
local table_sort = LUIE.table and LUIE.table.sort
local unpack = LUIE.table and LUIE.table.unpack
local GetString = GetString
local zo_strformat = zo_strformat

do
    --- @param addonName string
    --- @return boolean
    local function is_it_enabled(addonName)
        local addonManager = GetAddOnManager()
        local numAddOns = addonManager:GetNumAddOns()

        for i = 1, numAddOns do
            local name, _, _, _, _, state, _, _ = addonManager:GetAddOnInfo(i)

            if name == addonName and state == ADDON_STATE_ENABLED then
                return true
            end
        end

        return false
    end

    LUIE.IsItEnabled = is_it_enabled
end

-- -----------------------------------------------------------------------------
-- This is needed due to LibDebugLogger hooking zo_callLater.
-- -----------------------------------------------------------------------------
do
    local LUIE_CallLaterId = 1
    ---
    --- @param func function
    --- @param ms integer
    --- @return integer
    local function callLater(func, ms)
        local id = LUIE_CallLaterId
        local name = "LUIE_CallLaterFunction" .. id
        LUIE_CallLaterId = LUIE_CallLaterId + 1

        eventManager:RegisterForUpdate(name, ms, function ()
            eventManager:UnregisterForUpdate(name)
            func(id)
        end)
        return id
    end

    LUIE_CallLater = callLater
end

-- -----------------------------------------------------------------------------
--- Called from the menu and on initialization to update the timestamp color when changed.
LUIE.TimeStampColorize = nil

-- -----------------------------------------------------------------------------
--- Updates the timestamp color based on the value in LUIE.ChatAnnouncements.SV.TimeStampColor.
function LUIE.UpdateTimeStampColor()
    local color = LUIE.ChatAnnouncements.SV.TimeStampColor or { 0.5607843137, 0.5607843137, 0.5607843137 }
    LUIE.TimeStampColorize = ZO_ColorDef:New(unpack(color)):ToHex()
end

-- -----------------------------------------------------------------------------
--- Toggle the display of the Alert Frame.
--- Sets the visibility of the ZO_AlertTextNotification based on the value of LUIE.SV.HideAlertFrame.
function LUIE.SetupAlertFrameVisibility()
    ZO_AlertTextNotification:SetHidden(LUIE.SV.HideAlertFrame)
end

-- -----------------------------------------------------------------------------
do
    -- Get milliseconds from game time
    local function getCurrentMillisecondsFormatted()
        local currentTimeMs = GetGameTimeMilliseconds()
        if currentTimeMs == nil then return end
        local formattedTime = string_format("%03d", currentTimeMs % 1000)
        return formattedTime
    end

    --- Returns a formatted timestamp based on the provided time string and format string.
    --- @param timeStr string: The time string in the format "HH:MM:SS".
    --- @param formatStr string|nil (optional): The format string for the timestamp. If not provided, the default format from LUIE.ChatAnnouncements.SV.TimeStampFormat will be used.
    --- @param milliseconds string|nil
    --- @return string @ The formatted timestamp.
    local function CreateTimestamp(timeStr, formatStr, milliseconds)
        local showTimestamp = LUIE.ChatAnnouncements.SV.TimeStamp
        if showTimestamp then
            milliseconds = milliseconds or getCurrentMillisecondsFormatted()
        end
        if milliseconds == nil then milliseconds = "" end
        formatStr = formatStr or LUIE.ChatAnnouncements.SV.TimeStampFormat

        -- split up default timestamp
        local hours, minutes, seconds = string_match(timeStr, "([^%:]+):([^%:]+):([^%:]+)")
        local hoursNoLead = tonumber(hours) -- hours without leading zero
        local hours12NoLead = (hoursNoLead - 1) % 12 + 1
        local hours12
        if (hours12NoLead < 10) then
            hours12 = "0" .. hours12NoLead
        else
            hours12 = hours12NoLead
        end
        local pUp = "AM"
        local pLow = "am"
        if (hoursNoLead >= 12) then
            pUp = "PM"
            pLow = "pm"
        end

        -- create new one
        -- >If you add new formats make sure to update the tooltip at LUIE_STRING_LAM_CA_TIMESTAMPFORMAT_TP too
        local timestamp = formatStr
        timestamp = string_gsub(timestamp, "HH", hours)
        timestamp = string_gsub(timestamp, "H", hoursNoLead)
        timestamp = string_gsub(timestamp, "hh", hours12)
        timestamp = string_gsub(timestamp, "h", hours12NoLead)
        timestamp = string_gsub(timestamp, "m", minutes)
        timestamp = string_gsub(timestamp, "s", seconds)
        timestamp = string_gsub(timestamp, "A", pUp)
        timestamp = string_gsub(timestamp, "a", pLow)
        timestamp = string_gsub(timestamp, "xy", milliseconds)
        return timestamp
    end

    LUIE.CreateTimestamp = CreateTimestamp
end

-- -----------------------------------------------------------------------------
do
    --- Helper function to format a message with an optional timestamp.
    --- @param msg string: The message to be formatted.
    --- @param doTimestamp boolean: If true, a timestamp will be added to the formatted message.
    --- @param lineNumber? number: The current line number for the chat message.
    --- @param chanCode? number: The chat channel code.
    --- @return string: The formatted message.
    local function FormatMessage(msg, doTimestamp, lineNumber, chanCode)
        local formattedMsg = msg or ""
        if doTimestamp then
            local timestring = GetTimeString()
            local timestamp = LUIE.CreateTimestamp(timestring, nil, nil)

            -- Make timestamp clickable if lineNumber and chanCode are provided
            local timestampText
            if lineNumber and chanCode then
                timestampText = ZO_LinkHandler_CreateLink(timestamp, nil, "LUIE", lineNumber .. ":" .. chanCode)
            else
                timestampText = timestamp
            end

            -- Format with color and brackets
            local timestampFormatted = string_format("|c%s[%s]|r ", LUIE.TimeStampColorize, timestampText)

            -- Combine timestamp with message
            formattedMsg = timestampFormatted .. formattedMsg
        end
        return formattedMsg
    end

    LUIE.FormatMessage = FormatMessage
end
-- -----------------------------------------------------------------------------
--- Hides or shows all LUIE components.
--- @param hidden boolean: If true, all components will be hidden. If false, all components will be shown.
function LUIE.ToggleVisibility(hidden)
    for _, control in pairs(LUIE.Components) do
        control:SetHidden(hidden)
    end
end

-- -----------------------------------------------------------------------------
do
    --- Adds a system message to the chat.
    --- @param messageOrFormatter string: The message to be printed.
    --- @param ... string: Variable number of arguments to be formatted into the message.
    local function AddSystemMessage(messageOrFormatter, ...)
        -- Format the message if there are arguments
        local formattedMessage
        if select("#", ...) > 0 then
            -- Escape '%' characters to prevent illegal format specifiers
            local safeFormat = string_gsub(messageOrFormatter, "%%", "%%%%")
            formattedMessage = string_format(safeFormat, ...)
        else
            formattedMessage = messageOrFormatter
        end

        CHAT_ROUTER:AddSystemMessage(formattedMessage)

        if LibDebugLogger and LUIE.IsDevDebugEnabled() then
            LUIE.Debug(formattedMessage, ...)
        end
    end

    LUIE.AddSystemMessage = AddSystemMessage
end
-- -----------------------------------------------------------------------------
do
    local FormatMessage = LUIE.FormatMessage
    local SystemMessage = LUIE.AddSystemMessage

    --- Prints a message to specific chat windows based on user settings
    --- @param formattedMsg string: The message to print
    --- @param isSystem boolean: Whether this is a system message
    local function PrintToChatWindows(formattedMsg, isSystem)
        -- If system messages should go to all windows and this is a system message, use SystemMessage
        if isSystem and LUIE.ChatAnnouncements.SV.ChatSystemAll then
            SystemMessage(formattedMsg)
            return
        end

        -- Otherwise, print to individual tabs based on settings
        for _, cc in ipairs(ZO_GetChatSystem().containers) do
            for i = 1, #cc.windows do
                if LUIE.ChatAnnouncements.SV.ChatTab[i] == true then
                    local chatContainer = cc
                    local chatWindow = cc.windows[i]

                    -- Skip Combat Metrics Log window if CMX is enabled
                    local skipWindow = false
                    if CMX and CMX.db and CMX.db.chatLog then
                        if chatContainer:GetTabName(i) == CMX.db.chatLog.name then
                            skipWindow = true
                        end
                    end

                    if not skipWindow then
                        chatContainer:AddEventMessageToWindow(chatWindow, formattedMsg, CHAT_CATEGORY_SYSTEM)
                    end
                end
            end
        end
    end

    --- Easy Print to Chat.
    --- Prints a message to the chat.
    --- @param msg string: The message to be printed.
    --- @param isSystem? boolean: If true, the message is considered a system message.
    local function PrintToChat(msg, isSystem)
        -- Guard clause: exit early if chat system not ready
        if not ZO_GetChatSystem().primaryContainer then
            return
        end

        -- Default message if none provided
        msg = msg or "no message"

        -- Determine if we should format the message with a timestamp
        local shouldFormat = not LUIE.ChatAnnouncements.SV.ChatBypassFormat
        local doTimestamp = LUIE.ChatAnnouncements.SV.TimeStamp
        local formattedMsg = shouldFormat
            and FormatMessage(msg, doTimestamp)
            or msg

        -- Method 1: Print to all tabs (uses SystemMessage)
        if LUIE.ChatAnnouncements.SV.ChatMethod == "Print to All Tabs" then
            SystemMessage(formattedMsg)
            return
        end

        -- Method 2: Print to specific tabs
        PrintToChatWindows(formattedMsg, isSystem)
    end

    LUIE.PrintToChat = PrintToChat
end
-- -----------------------------------------------------------------------------
--- Formats a number with optional shortening and localized separators.
--- @param number number The number to format
--- @param shorten? boolean Whether to abbreviate large numbers (e.g. 1.5M)
--- @param comma? boolean Whether to add localized digit separators
--- @return string|number @The formatted number
function LUIE.AbbreviateNumber(number, shorten, comma)
    if number > 0 and shorten then
        local value
        local suffix
        if number >= 1000000000 then
            value = number / 1000000000
            suffix = "G"
        elseif number >= 1000000 then
            value = number / 1000000
            suffix = "M"
        elseif number >= 1000 then
            value = number / 1000
            suffix = "k"
        else
            value = number
        end
        -- If we could not convert even to "G", return full number
        if value >= 1000 then
            if comma then
                value = ZO_CommaDelimitDecimalNumber(number)
                return value
            else
                return number
            end
        elseif value >= 100 or suffix == nil then
            value = string_format("%d", value)
        else
            value = string_format("%.1f", value)
        end
        if suffix ~= nil then
            value = value .. suffix
        end
        return value
    end
    -- Add commas if needed
    if comma then
        local value = ZO_CommaDelimitDecimalNumber(number)
        return value
    end
    return number
end

-- -----------------------------------------------------------------------------
--- Takes an input with a name identifier, title, text, and callback function to create a dialogue button.
--- @param identifier string: The identifier for the dialogue button.
--- @param title string: The title text for the dialogue button.
--- @param text string: The main text for the dialogue button.
--- @param callback function: The callback function to be executed when the button is clicked.
--- @return table identifier: The created dialogue button table.
function LUIE.RegisterDialogueButton(identifier, title, text, callback)
    ESO_Dialogs[identifier] =
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        canQueue = true,
        title =
        {
            text = title,
        },
        mainText =
        {
            text = text,
        },
        buttons =
        {
            {
                text = SI_DIALOG_CONFIRM,
                callback = callback,
            },
            {
                text = SI_DIALOG_CANCEL,
            },
        },
    }
    return ESO_Dialogs[identifier]
end

-- -----------------------------------------------------------------------------
-- Initialize empty table if it doesn't exist
if not LUIE.GuildIndexData then
    --- @class LUIE_GuildIndexData
    --- @field [integer] {
    --- id : integer,
    --- name : string,
    --- guildAlliance : integer|Alliance,
    --- }
    LUIE.GuildIndexData = {}
end
--- Function to update guild data.
--- Retrieves information about each guild the player is a member of and stores it in LUIE.GuildIndexData table.
function LUIE.UpdateGuildData()
    local GuildsIndex = GetNumGuilds()
    for i = 1, GuildsIndex do
        local id = GetGuildId(i)
        local name = GetGuildName(id)
        local guildAlliance = GetGuildAlliance(id)
        LUIE.GuildIndexData[i] =
        {
            id = id,
            name = name,
            guildAlliance = guildAlliance
        }
    end
end

-- -----------------------------------------------------------------------------
--- Simple function to check the veteran difficulty.
--- @return boolean: Returns true if the player is in a veteran dungeon or using veteran difficulty, false otherwise.
function LUIE.ResolveVeteranDifficulty()
    if GetGroupSize() <= 1 and IsUnitUsingVeteranDifficulty("player") then
        return true
    elseif GetCurrentZoneDungeonDifficulty() == 2 or IsGroupUsingVeteranDifficulty() == true then
        return true
    else
        return false
    end
end

-- -----------------------------------------------------------------------------
--- Simple function that checks if the player is in a PVP zone.
--- @return boolean: Returns true if the player is PvP flagged, false otherwise.
function LUIE.ResolvePVPZone()
    if IsUnitPvPFlagged("player") then
        return true
    else
        return false
    end
end

-- -----------------------------------------------------------------------------
--- Pulls the name for the current morph of a skill.
--- @param abilityId number: The AbilityId of the skill.
--- @return string abilityName: The name of the current morph of the skill.
function LUIE.GetSkillMorphName(abilityId)
    local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
    local abilityName = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    return abilityName
end

-- -----------------------------------------------------------------------------
--- Pulls the icon for the current morph of a skill.
--- @param abilityId number: The AbilityId of the skill.
--- @return string abilityIcon: The icon path of the current morph of the skill.
function LUIE.GetSkillMorphIcon(abilityId)
    local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
    local abilityIcon = select(2, GetSkillAbilityInfo(skillType, skillIndex, abilityIndex))
    return abilityIcon
end

-- -----------------------------------------------------------------------------
--- Pulls the AbilityId for the current morph of a skill.
--- @param abilityId number: The AbilityId of the skill.
--- @return number morphAbilityId: The AbilityId of the current morph of the skill.
function LUIE.GetSkillMorphAbilityId(abilityId)
    local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
    local morphAbilityId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, false)
    return morphAbilityId -- renamed local (abilityId) to avoid naming conflicts with the parameter
end

-- -----------------------------------------------------------------------------
--- Function to update the syntax for default Mundus Stone tooltips we pull (in order to retain scaling).
--- @param abilityId number: The ID of the ability.
--- @param tooltipText string: The original tooltip text.
--- @return string tooltipText: The updated tooltip text.
function LUIE.UpdateMundusTooltipSyntax(abilityId, tooltipText)
    -- Update syntax for The Lady, The Lover, and the Thief Mundus stones since they aren't consistent with other buffs.
    if abilityId == 13976 or abilityId == 13981 then -- The Lady / The Lover
        tooltipText = string_gsub(tooltipText, GetString(LUIE_STRING_SKILL_MUNDUS_SUB_RES_PEN), GetString(LUIE_STRING_SKILL_MUNDUS_SUB_RES_PEN_REPLACE))
    elseif abilityId == 13975 then                   -- The Thief
        tooltipText = string_gsub(tooltipText, GetString(LUIE_STRING_SKILL_MUNDUS_SUB_THIEF), GetString(LUIE_STRING_SKILL_MUNDUS_SUB_THIEF_REPLACE))
    end
    -- Replace "Increases your" with "Increase"
    tooltipText = string_gsub(tooltipText, GetString(LUIE_STRING_SKILL_MUNDUS_STRING), GetString(LUIE_STRING_SKILL_DRINK_INCREASE))
    return tooltipText
end

-- -----------------------------------------------------------------------------
do
    --- @param actionSlotIndex integer
    --- @param hotbarCategory HotBarCategory?
    --- @return integer actionId
    local function GetSlotTrueBoundId(actionSlotIndex, hotbarCategory)
        hotbarCategory = hotbarCategory or GetActiveHotbarCategory()
        local actionId = GetSlotBoundId(actionSlotIndex, hotbarCategory)
        local actionType = GetSlotType(actionSlotIndex, hotbarCategory)
        if actionType == ACTION_TYPE_CRAFTED_ABILITY then
            actionId = GetAbilityIdForCraftedAbilityId(actionId)
        end
        return actionId
    end
    LUIE.GetSlotTrueBoundId = GetSlotTrueBoundId
end
-- -----------------------------------------------------------------------------

-- Add this if not already.
if not SLASH_COMMANDS["/rl"] then
    SLASH_COMMANDS["/rl"] = ReloadUI("ingame")
end

-- -----------------------------------------------------------------------------
---
--- @param conditionType QuestConditionType
--- @return string
function LUIE.GetQuestConditionTypeName(conditionType)
    local conditionTypes =
    {
        [QUEST_CONDITION_TYPE_ABILITY_TYPE_USED_ON_NPC] = "QUEST_CONDITION_TYPE_ABILITY_TYPE_USED_ON_NPC",
        [QUEST_CONDITION_TYPE_ABILITY_TYPE_USED_ON_TABLE] = "QUEST_CONDITION_TYPE_ABILITY_TYPE_USED_ON_TABLE",
        [QUEST_CONDITION_TYPE_ABILITY_USED_ON_NPC] = "QUEST_CONDITION_TYPE_ABILITY_USED_ON_NPC",
        [QUEST_CONDITION_TYPE_ABILITY_USED_ON_TABLE] = "QUEST_CONDITION_TYPE_ABILITY_USED_ON_TABLE",
        [QUEST_CONDITION_TYPE_ADVANCE_COMPLETABLE_SIBLINGS] = "QUEST_CONDITION_TYPE_ADVANCE_COMPLETABLE_SIBLINGS",
        [QUEST_CONDITION_TYPE_ARTIFACT_CAPTURED] = "QUEST_CONDITION_TYPE_ARTIFACT_CAPTURED",
        [QUEST_CONDITION_TYPE_ARTIFACT_RETURNED] = "QUEST_CONDITION_TYPE_ARTIFACT_RETURNED",
        [QUEST_CONDITION_TYPE_BATTLEGROUND_EARNED_POINTS] = "QUEST_CONDITION_TYPE_BATTLEGROUND_EARNED_POINTS",
        [QUEST_CONDITION_TYPE_BATTLEGROUND_PARTICIPATION] = "QUEST_CONDITION_TYPE_BATTLEGROUND_PARTICIPATION",
        [QUEST_CONDITION_TYPE_BATTLEGROUND_VICTORY] = "QUEST_CONDITION_TYPE_BATTLEGROUND_VICTORY",
        [QUEST_CONDITION_TYPE_CAPTURE_KEEP_TYPE_UNIQUE_KEEPS] = "QUEST_CONDITION_TYPE_CAPTURE_KEEP_TYPE_UNIQUE_KEEPS",
        [QUEST_CONDITION_TYPE_CAPTURE_KEEP_TYPE] = "QUEST_CONDITION_TYPE_CAPTURE_KEEP_TYPE",
        [QUEST_CONDITION_TYPE_CAPTURE_SPECIFIC_KEEP] = "QUEST_CONDITION_TYPE_CAPTURE_SPECIFIC_KEEP",
        [QUEST_CONDITION_TYPE_COLLECT_ITEM] = "QUEST_CONDITION_TYPE_COLLECT_ITEM",
        [QUEST_CONDITION_TYPE_CRAFT_ITEM] = "QUEST_CONDITION_TYPE_CRAFT_ITEM",
        [QUEST_CONDITION_TYPE_CRAFT_RANDOM_WRIT_ITEM] = "QUEST_CONDITION_TYPE_CRAFT_RANDOM_WRIT_ITEM",
        [QUEST_CONDITION_TYPE_DECONSTRUCT_ITEM] = "QUEST_CONDITION_TYPE_DECONSTRUCT_ITEM",
        [QUEST_CONDITION_TYPE_DISMISSED_COMPANION] = "QUEST_CONDITION_TYPE_DISMISSED_COMPANION",
        [QUEST_CONDITION_TYPE_EARN_CHAMPION_POINT] = "QUEST_CONDITION_TYPE_EARN_CHAMPION_POINT",
        [QUEST_CONDITION_TYPE_ENTER_SUBZONE] = "QUEST_CONDITION_TYPE_ENTER_SUBZONE",
        [QUEST_CONDITION_TYPE_ENTER_ZONE] = "QUEST_CONDITION_TYPE_ENTER_ZONE",
        [QUEST_CONDITION_TYPE_EQUIP_ITEM] = "QUEST_CONDITION_TYPE_EQUIP_ITEM",
        [QUEST_CONDITION_TYPE_EVENT_FAIL] = "QUEST_CONDITION_TYPE_EVENT_FAIL",
        [QUEST_CONDITION_TYPE_EVENT_SUCCESS] = "QUEST_CONDITION_TYPE_EVENT_SUCCESS",
        [QUEST_CONDITION_TYPE_EXIT_SUBZONE] = "QUEST_CONDITION_TYPE_EXIT_SUBZONE",
        [QUEST_CONDITION_TYPE_FOLLOWER_GAINED] = "QUEST_CONDITION_TYPE_FOLLOWER_GAINED",
        [QUEST_CONDITION_TYPE_FOLLOWER_LOST] = "QUEST_CONDITION_TYPE_FOLLOWER_LOST",
        [QUEST_CONDITION_TYPE_GATHER_ITEM_TRAIT] = "QUEST_CONDITION_TYPE_GATHER_ITEM_TRAIT",
        [QUEST_CONDITION_TYPE_GATHER_ITEM_TYPE] = "QUEST_CONDITION_TYPE_GATHER_ITEM_TYPE",
        [QUEST_CONDITION_TYPE_GATHER_ITEM] = "QUEST_CONDITION_TYPE_GATHER_ITEM",
        [QUEST_CONDITION_TYPE_GIVE_ITEM] = "QUEST_CONDITION_TYPE_GIVE_ITEM",
        [QUEST_CONDITION_TYPE_GOTO_POINT] = "QUEST_CONDITION_TYPE_GOTO_POINT",
        [QUEST_CONDITION_TYPE_GUILD_TRADER_GOLD_TRANSACTION] = "QUEST_CONDITION_TYPE_GUILD_TRADER_GOLD_TRANSACTION",
        [QUEST_CONDITION_TYPE_HAS_ITEM] = "QUEST_CONDITION_TYPE_HAS_ITEM",
        [QUEST_CONDITION_TYPE_INTERACT_MONSTER] = "QUEST_CONDITION_TYPE_INTERACT_MONSTER",
        [QUEST_CONDITION_TYPE_INTERACT_OBJECT_IN_STATE] = "QUEST_CONDITION_TYPE_INTERACT_OBJECT_IN_STATE",
        [QUEST_CONDITION_TYPE_INTERACT_OBJECT] = "QUEST_CONDITION_TYPE_INTERACT_OBJECT",
        [QUEST_CONDITION_TYPE_INTERACT_SIMPLE_OBJECT_IN_STATE] = "QUEST_CONDITION_TYPE_INTERACT_SIMPLE_OBJECT_IN_STATE",
        [QUEST_CONDITION_TYPE_INTERACT_SIMPLE_OBJECT] = "QUEST_CONDITION_TYPE_INTERACT_SIMPLE_OBJECT",
        [QUEST_CONDITION_TYPE_KILL_BOUNTY_CLASSIFICATION_TYPE] = "QUEST_CONDITION_TYPE_KILL_BOUNTY_CLASSIFICATION_TYPE",
        [QUEST_CONDITION_TYPE_KILL_ENEMY_GUARDS] = "QUEST_CONDITION_TYPE_KILL_ENEMY_GUARDS",
        [QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS_OF_CLASS] = "QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS_OF_CLASS",
        [QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS_WHILE_DEFENDING_KEEP] = "QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS_WHILE_DEFENDING_KEEP",
        [QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS] = "QUEST_CONDITION_TYPE_KILL_ENEMY_PLAYERS",
        [QUEST_CONDITION_TYPE_KILL_MONSTER_TABLE] = "QUEST_CONDITION_TYPE_KILL_MONSTER_TABLE",
        [QUEST_CONDITION_TYPE_KILL_MONSTER_TYPE] = "QUEST_CONDITION_TYPE_KILL_MONSTER_TYPE",
        [QUEST_CONDITION_TYPE_KILL_MONSTER] = "QUEST_CONDITION_TYPE_KILL_MONSTER",
        [QUEST_CONDITION_TYPE_LEAVE_REVIVE_COUNTER_LIST] = "QUEST_CONDITION_TYPE_LEAVE_REVIVE_COUNTER_LIST",
        [QUEST_CONDITION_TYPE_LEVEL_UP] = "QUEST_CONDITION_TYPE_LEVEL_UP",
        [QUEST_CONDITION_TYPE_LOOT_TREASURE_CHEST] = "QUEST_CONDITION_TYPE_LOOT_TREASURE_CHEST",
        [QUEST_CONDITION_TYPE_NPC_GOAL_FAIL] = "QUEST_CONDITION_TYPE_NPC_GOAL_FAIL",
        [QUEST_CONDITION_TYPE_NPC_GOAL] = "QUEST_CONDITION_TYPE_NPC_GOAL",
        [QUEST_CONDITION_TYPE_PICKPOCKET_ITEM] = "QUEST_CONDITION_TYPE_PICKPOCKET_ITEM",
        [QUEST_CONDITION_TYPE_PLAYER_DEATH] = "QUEST_CONDITION_TYPE_PLAYER_DEATH",
        [QUEST_CONDITION_TYPE_PLAYER_LOGOUT] = "QUEST_CONDITION_TYPE_PLAYER_LOGOUT",
        [QUEST_CONDITION_TYPE_READ_BOOK] = "QUEST_CONDITION_TYPE_READ_BOOK",
        [QUEST_CONDITION_TYPE_SCRIBE_ABILITY] = "QUEST_CONDITION_TYPE_SCRIBE_ABILITY",
        [QUEST_CONDITION_TYPE_SCRIPT_ACTION] = "QUEST_CONDITION_TYPE_SCRIPT_ACTION",
        [QUEST_CONDITION_TYPE_SELL_LAUNDER_ITEM] = "QUEST_CONDITION_TYPE_SELL_LAUNDER_ITEM",
        [QUEST_CONDITION_TYPE_SUBCLASS_SWAP_SKILL_LINE] = "QUEST_CONDITION_TYPE_SUBCLASS_SWAP_SKILL_LINE",
        [QUEST_CONDITION_TYPE_SUBCLASS_TRAIN_SKILL_LINE] = "QUEST_CONDITION_TYPE_SUBCLASS_TRAIN_SKILL_LINE",
        [QUEST_CONDITION_TYPE_SUMMONED_COMPANION] = "QUEST_CONDITION_TYPE_SUMMONED_COMPANION",
        [QUEST_CONDITION_TYPE_TALK_TO] = "QUEST_CONDITION_TYPE_TALK_TO",
        [QUEST_CONDITION_TYPE_TIMER] = "QUEST_CONDITION_TYPE_TIMER",
        [QUEST_CONDITION_TYPE_TRANSITION_INTERACT_OBJECT] = "QUEST_CONDITION_TYPE_TRANSITION_INTERACT_OBJECT",
        [QUEST_CONDITION_TYPE_TRIBUTE_LOST_MATCH_MONSTER] = "QUEST_CONDITION_TYPE_TRIBUTE_LOST_MATCH_MONSTER",
        [QUEST_CONDITION_TYPE_TRIBUTE_LOST_MATCH_PLAYER] = "QUEST_CONDITION_TYPE_TRIBUTE_LOST_MATCH_PLAYER",
        [QUEST_CONDITION_TYPE_TRIBUTE_WON_MATCH_MONSTER] = "QUEST_CONDITION_TYPE_TRIBUTE_WON_MATCH_MONSTER",
        [QUEST_CONDITION_TYPE_TRIBUTE_WON_MATCH_PLAYER] = "QUEST_CONDITION_TYPE_TRIBUTE_WON_MATCH_PLAYER",
        [QUEST_CONDITION_TYPE_UNEARTH_ANTIQUITY] = "QUEST_CONDITION_TYPE_UNEARTH_ANTIQUITY",
        [QUEST_CONDITION_TYPE_USE_QUEST_ITEM] = "QUEST_CONDITION_TYPE_USE_QUEST_ITEM",
        [QUEST_CONDITION_TYPE_VENDOR_GOLD_TRANSACTION] = "QUEST_CONDITION_TYPE_VENDOR_GOLD_TRANSACTION",
    }
    return conditionTypes[conditionType] or string_format("UNKNOWN_CONDITION_TYPE_%d", conditionType)
end

-- -----------------------------------------------------------------------------
--- Converts a quest type to its string name representation
--- @param questType QuestType
--- @return string
function LUIE.GetQuestTypeName(questType)
    local questTypes =
    {
        [QUEST_TYPE_AVA_GRAND]        = "QUEST_TYPE_AVA_GRAND",
        [QUEST_TYPE_AVA_GROUP]        = "QUEST_TYPE_AVA_GROUP",
        [QUEST_TYPE_AVA]              = "QUEST_TYPE_AVA",
        [QUEST_TYPE_BATTLEGROUND]     = "QUEST_TYPE_BATTLEGROUND",
        [QUEST_TYPE_CLASS]            = "QUEST_TYPE_CLASS",
        [QUEST_TYPE_COMPANION]        = "QUEST_TYPE_COMPANION",
        [QUEST_TYPE_CRAFTING]         = "QUEST_TYPE_CRAFTING",
        [QUEST_TYPE_DUNGEON]          = "QUEST_TYPE_DUNGEON",
        [QUEST_TYPE_GROUP]            = "QUEST_TYPE_GROUP",
        [QUEST_TYPE_GUILD]            = "QUEST_TYPE_GUILD",
        [QUEST_TYPE_HOLIDAY_EVENT]    = "QUEST_TYPE_HOLIDAY_EVENT",
        [QUEST_TYPE_MAIN_STORY]       = "QUEST_TYPE_MAIN_STORY",
        [QUEST_TYPE_NONE]             = "QUEST_TYPE_NONE",
        [QUEST_TYPE_PROLOGUE]         = "QUEST_TYPE_PROLOGUE",
        [QUEST_TYPE_RAID]             = "QUEST_TYPE_RAID",
        [QUEST_TYPE_SCRIBING]         = "QUEST_TYPE_SCRIBING",
        [QUEST_TYPE_TRIBUTE]          = "QUEST_TYPE_TRIBUTE",
        [QUEST_TYPE_UNDAUNTED_PLEDGE] = "QUEST_TYPE_UNDAUNTED_PLEDGE",
    }
    return questTypes[questType] or string_format("UNKNOWN_QUEST_TYPE_%d", questType)
end

-- -----------------------------------------------------------------------------
--- Valid item types for deconstruction
local DECONSTRUCTIBLE_ITEM_TYPES =
{
    [ITEMTYPE_ADDITIVE] = true,
    [ITEMTYPE_ARMOR_BOOSTER] = true,
    [ITEMTYPE_ARMOR_TRAIT] = true,
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = true,
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = true,
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = true,
    [ITEMTYPE_CLOTHIER_BOOSTER] = true,
    [ITEMTYPE_CLOTHIER_MATERIAL] = true,
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = true,
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = true,
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = true,
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = true,
    [ITEMTYPE_ENCHANTMENT_BOOSTER] = true,
    [ITEMTYPE_FISH] = true,
    [ITEMTYPE_GLYPH_ARMOR] = true,
    [ITEMTYPE_GLYPH_JEWELRY] = true,
    [ITEMTYPE_GLYPH_WEAPON] = true,
    [ITEMTYPE_GROUP_REPAIR] = true,
    [ITEMTYPE_INGREDIENT] = true,
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = true,
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = true,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = true,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = true,
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = true,
    [ITEMTYPE_JEWELRY_TRAIT] = true,
    [ITEMTYPE_POISON_BASE] = true,
    [ITEMTYPE_POTION_BASE] = true,
    [ITEMTYPE_RAW_MATERIAL] = true,
    [ITEMTYPE_REAGENT] = true,
    [ITEMTYPE_STYLE_MATERIAL] = true,
    [ITEMTYPE_WEAPON] = true,
    [ITEMTYPE_WEAPON_BOOSTER] = true,
    [ITEMTYPE_WEAPON_TRAIT] = true,
    [ITEMTYPE_WOODWORKING_BOOSTER] = true,
    [ITEMTYPE_WOODWORKING_MATERIAL] = true,
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = true,
}

-- -----------------------------------------------------------------------------
--- Valid crafting types for deconstruction
local DECONSTRUCTIBLE_CRAFTING_TYPES =
{
    [CRAFTING_TYPE_BLACKSMITHING] = true,
    [CRAFTING_TYPE_CLOTHIER] = true,
    [CRAFTING_TYPE_WOODWORKING] = true,
    [CRAFTING_TYPE_JEWELRYCRAFTING] = true,
}

--- @alias SmithingMode integer
--- | `SMITHING_MODE_ROOT` # 0
--- | `SMITHING_MODE_REFINEMENT` # 1
--- | `SMITHING_MODE_CREATION` # 2
--- | `SMITHING_MODE_DECONSTRUCTION` # 3
--- | `SMITHING_MODE_IMPROVEMENT` # 4
--- | `SMITHING_MODE_RESEARCH` # 5
--- | `SMITHING_MODE_RECIPES` # 6
--- | `SMITHING_MODE_CONSOLIDATED_SET_SELECTION` # 7

--- @alias EnchanthingMode integer
--- | `ENCHANTING_MODE_NONE` # 0
--- | `ENCHANTING_MODE_CREATION` # 1
--- | `ENCHANTING_MODE_EXTRACTION` # 2
--- | `ENCHANTING_MODE_RECIPES` # 3

-- -----------------------------------------------------------------------------
--- Get the current crafting mode, accounting for both keyboard and gamepad UI
--- @return integer|SmithingMode mode The current crafting mode
function LUIE.GetSmithingMode()
    local mode
    if IsInGamepadPreferredMode() == true then
        -- In Gamepad UI, use SMITHING_GAMEPAD.mode
        mode = SMITHING_GAMEPAD and SMITHING_GAMEPAD.mode
    else
        -- For Keyboard UI, use SMITHING.mode
        mode = SMITHING and SMITHING.mode
    end
    --- @cast mode SmithingMode
    -- At this point, mode should already be one of:
    -- SMITHING_MODE_ROOT                       = 0
    -- SMITHING_MODE_REFINEMENT                 = 1
    -- SMITHING_MODE_CREATION                   = 2
    -- SMITHING_MODE_DECONSTRUCTION             = 3
    -- SMITHING_MODE_IMPROVEMENT                = 4
    -- SMITHING_MODE_RESEARCH                   = 5
    -- SMITHING_MODE_RECIPES                    = 6
    -- SMITHING_MODE_CONSOLIDATED_SET_SELECTION = 7
    --
    -- Return mode (defaulting to SMITHING_MODE_ROOT if for some reason mode is nil)
    return mode or SMITHING_MODE_ROOT
end

function LUIE.GetEnchantingMode()
    local enchantingmode
    if IsInGamepadPreferredMode() == true then
        enchantingmode = GAMEPAD_ENCHANTING
    else
        enchantingmode = ENCHANTING
    end
    local mode = enchantingmode:GetEnchantingMode()
    --- @cast mode EnchanthingMode
    return mode or ENCHANTING_MODE_NONE
end

-- -----------------------------------------------------------------------------
--- Checks if an item type is valid for deconstruction in the current crafting context
--- @param itemType number The item type to check
--- @return boolean @Returns true if the item can be deconstructed in current context
function LUIE.ResolveCraftingUsed(itemType)
    local craftingType = GetCraftingInteractionType()
    local DECONSTRUCTION_MODE = 3

    -- Check if current crafting type allows deconstruction and we're in deconstruction mode
    return DECONSTRUCTIBLE_CRAFTING_TYPES[craftingType]
        and LUIE.GetSmithingMode() == DECONSTRUCTION_MODE
        and DECONSTRUCTIBLE_ITEM_TYPES[itemType] or false
end

-- -----------------------------------------------------------------------------
--- Utility function to handle font setup and validation
--- @param fontNameKey string: The key for the font name.
--- @param fontStyleKey string|nil: The key for the font style (optional).
--- @param fontSizeKey string|nil: The key for the font size (optional).
--- @param settings table: The settings table containing the font settings.
--- @param defaultFont string: The default font name.
--- @param defaultStyle string|nil: The default font style (optional).
--- @param defaultSize number|nil: The default font size (optional).
--- @return string: The formatted font string.
function LUIE.SetupFont(fontNameKey, fontStyleKey, fontSizeKey, settings, defaultFont, defaultStyle, defaultSize)
    -- Handle font name
    local fontName = LUIE.Fonts[settings[fontNameKey]]
    if not fontName or fontName == "" then
        LUIE.PrintToChat(GetString(LUIE_STRING_ERROR_FONT), true)
        fontName = defaultFont
        return fontName
    end

    -- Handle font size and style - if keys aren't provided, don't try to access them in settings
    local fontSize = fontSizeKey and ((settings[fontSizeKey] and settings[fontSizeKey] > 0) and settings[fontSizeKey] or defaultSize)
    local fontStyle = fontStyleKey and ((settings[fontStyleKey] and settings[fontStyleKey] ~= "") and settings[fontStyleKey] or defaultStyle)

    -- Build the font string based on what parameters are available
    if fontSize and fontStyle then
        return fontName .. "|" .. fontSize .. "|" .. fontStyle
    elseif fontSize then
        return fontName .. "|" .. fontSize
    else
        return fontName
    end
end

-- -----------------------------------------------------------------------------
--- Helper function to generate font string with appropriate shadow style based on size
--- @param fontName string: The name of the font.
--- @param fontSize number: The size of the font.
--- @param overrideShadowStyle? string: The shadow style to override.
--- @return string: The formatted font string.
function LUIE.GetFormattedFontString(fontName, fontSize, overrideShadowStyle)
    local shadowStyle = overrideShadowStyle
    if not shadowStyle then
        shadowStyle = fontSize <= 14 and "soft-shadow-thin" or "soft-shadow-thick"
    end
    return ("%s|%d|%s"):format(fontName, fontSize, shadowStyle)
end

-- -----------------------------------------------------------------------------

--- @type table<integer,string>
local CLASS_ICONS = {}

for i = 1, GetNumClasses() do
    local classId, lore, normalIconKeyboard, pressedIconKeyboard, mouseoverIconKeyboard, isSelectable, ingameIconKeyboard, ingameIconGamepad, normalIconGamepad, pressedIconGamepad = GetClassInfo(i)
    CLASS_ICONS[classId] = ingameIconGamepad
end

LUIE.CLASS_ICONS = CLASS_ICONS

---
--- @param classId integer
--- @return string
function LUIE.GetClassIcon(classId)
    return CLASS_ICONS[classId]
end

-- -----------------------------------------------------------------------------

--- @param armorType ArmorType
--- @return integer counter
local function GetEquippedArmorPieces(armorType)
    local counter = 0
    for i = 0, 16 do
        local itemLink = GetItemLink(BAG_WORN, i, LINK_STYLE_DEFAULT)
        if GetItemLinkArmorType(itemLink) == armorType then
            counter = counter + 1
        end
    end
    return counter
end

-- Tooltip handler definitions
local TooltipHandlers =
{
    -- Brace
    [974] = function ()
        local _, _, mitigation = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_BLOCK_MITIGATION)
        local _, _, speed = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_BLOCK_SPEED)
        local _, cost = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_BLOCK_COST)

        -- Get weapon type for resource determination
        local function getActiveWeaponType()
            local weaponPair = GetActiveWeaponPairInfo()
            if weaponPair == ACTIVE_WEAPON_PAIR_MAIN then
                return GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
            elseif weaponPair == ACTIVE_WEAPON_PAIR_BACKUP then
                return GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
            end
            return WEAPONTYPE_NONE
        end

        -- Determine resource type based on weapon and skills
        local function getResourceType()
            local weaponType = getActiveWeaponType()
            if weaponType == WEAPONTYPE_FROST_STAFF then
                local skillType, skillIndex, abilityIndex = GetSpecificSkillAbilityKeysByAbilityId(30948)
                local purchased = select(6, GetSkillAbilityInfo(skillType, skillIndex, abilityIndex))
                if purchased then
                    return GetString(SI_ATTRIBUTES2) -- Magicka
                end
            end
            return GetString(SI_ATTRIBUTES3) -- Stamina
        end

        local finalSpeed = 100 - speed
        local roundedMitigation = zo_floor(mitigation * 100 + 0.5) / 100
        return zo_strformat(GetString(LUIE_STRING_SKILL_BRACE_TP), roundedMitigation, finalSpeed, cost, getResourceType())
    end,

    -- Crouch
    [20299] = function ()
        local _, _, speed = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_SNEAK_SPEED_REDUCTION)
        local _, cost = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_SNEAK_COST)

        if speed <= 0 or speed >= 100 then
            return zo_strformat(GetString(LUIE_STRING_SKILL_HIDDEN_NO_SPEED_TP), cost)
        end
        return zo_strformat(GetString(LUIE_STRING_SKILL_HIDDEN_TP), 100 - speed, cost)
    end,

    -- Unchained
    [98316] = function ()
        local duration = (GetAbilityDuration(98316) or 0) / 1000
        local pointsSpent = GetNumPointsSpentOnChampionSkill(64) * 1.1
        local adjustPoints = pointsSpent == 0 and 55 or zo_floor(pointsSpent * 100 + 0.5) / 100
        return zo_strformat(GetString(LUIE_STRING_SKILL_UNCHAINED_TP), duration, adjustPoints)
    end,

    -- Medium Armor Evasion
    [150057] = function ()
        local counter = GetEquippedArmorPieces(ARMORTYPE_MEDIUM) * 2
        return zo_strformat(GetString(LUIE_STRING_SKILL_MEDIUM_ARMOR_EVASION), counter)
    end,

    -- Unstoppable Brute
    [126582] = function ()
        local counter = GetEquippedArmorPieces(ARMORTYPE_HEAVY) * 5
        local duration = (GetAbilityDuration(126582) or 0) / 1000
        return zo_strformat(GetString(LUIE_STRING_SKILL_UNSTOPPABLE_BRUTE), duration, counter)
    end,

    -- Immovable
    [126583] = function ()
        local counter = GetEquippedArmorPieces(ARMORTYPE_HEAVY) * 5
        local duration = (GetAbilityDuration(126583) or 0) / 1000
        return zo_strformat(GetString(LUIE_STRING_SKILL_IMMOVABLE), duration, counter, 65 + counter)
    end,
}

-- Returns dynamic tooltips when called by Tooltip function
function LUIE.DynamicTooltip(abilityId)
    local handler = TooltipHandlers[abilityId]
    return handler and handler()
end

-- -----------------------------------------------------------------------------

--- @param soundCategory ItemUISoundCategory
--- @return string
function LUIE.GetItemSoundCategoryName(soundCategory)
    -- Ensure soundCategory is a valid number; if nil, default to 0.
    soundCategory = tonumber(soundCategory) or 0

    local soundCategories =
    {
        [ITEM_SOUND_CATEGORY_ANIMAL_COMPONENT]       = "ITEM_SOUND_CATEGORY_ANIMAL_COMPONENT",
        [ITEM_SOUND_CATEGORY_BATTLEFLAG]             = "ITEM_SOUND_CATEGORY_BATTLEFLAG",
        [ITEM_SOUND_CATEGORY_BOOK]                   = "ITEM_SOUND_CATEGORY_BOOK",
        [ITEM_SOUND_CATEGORY_BOOSTER]                = "ITEM_SOUND_CATEGORY_BOOSTER",
        [ITEM_SOUND_CATEGORY_BOW]                    = "ITEM_SOUND_CATEGORY_BOW",
        [ITEM_SOUND_CATEGORY_BREAD]                  = "ITEM_SOUND_CATEGORY_BREAD",
        [ITEM_SOUND_CATEGORY_CLOTH_COMPONENT]        = "ITEM_SOUND_CATEGORY_CLOTH_COMPONENT",
        [ITEM_SOUND_CATEGORY_CRAFTED_ABILITY_SCRIPT] = "ITEM_SOUND_CATEGORY_CRAFTED_ABILITY_SCRIPT",
        [ITEM_SOUND_CATEGORY_CRAFTED_ABILITY]        = "ITEM_SOUND_CATEGORY_CRAFTED_ABILITY",
        [ITEM_SOUND_CATEGORY_CUSTOM_SOUND]           = "ITEM_SOUND_CATEGORY_CUSTOM_SOUND",
        [ITEM_SOUND_CATEGORY_DAGGER]                 = "ITEM_SOUND_CATEGORY_DAGGER",
        [ITEM_SOUND_CATEGORY_DEFAULT]                = "ITEM_SOUND_CATEGORY_DEFAULT",
        [ITEM_SOUND_CATEGORY_DRINK]                  = "ITEM_SOUND_CATEGORY_DRINK",
        [ITEM_SOUND_CATEGORY_ENCHANTED_MEDALLION]    = "ITEM_SOUND_CATEGORY_ENCHANTED_MEDALLION",
        [ITEM_SOUND_CATEGORY_ENCHANTMENT]            = "ITEM_SOUND_CATEGORY_ENCHANTMENT",
        [ITEM_SOUND_CATEGORY_FISH]                   = "ITEM_SOUND_CATEGORY_FISH",
        [ITEM_SOUND_CATEGORY_FOOD]                   = "ITEM_SOUND_CATEGORY_FOOD",
        [ITEM_SOUND_CATEGORY_FOOTLOCKER]             = "ITEM_SOUND_CATEGORY_FOOTLOCKER",
        [ITEM_SOUND_CATEGORY_HEAVY_ARMOR]            = "ITEM_SOUND_CATEGORY_HEAVY_ARMOR",
        [ITEM_SOUND_CATEGORY_INGREDIENT]             = "ITEM_SOUND_CATEGORY_INGREDIENT",
        [ITEM_SOUND_CATEGORY_LIGHT_ARMOR]            = "ITEM_SOUND_CATEGORY_LIGHT_ARMOR",
        [ITEM_SOUND_CATEGORY_LURE]                   = "ITEM_SOUND_CATEGORY_LURE",
        [ITEM_SOUND_CATEGORY_MEAT]                   = "ITEM_SOUND_CATEGORY_MEAT",
        [ITEM_SOUND_CATEGORY_MEDIUM_ARMOR]           = "ITEM_SOUND_CATEGORY_MEDIUM_ARMOR",
        [ITEM_SOUND_CATEGORY_METAL_COMPONENT]        = "ITEM_SOUND_CATEGORY_METAL_COMPONENT",
        [ITEM_SOUND_CATEGORY_MINERAL_COMPONENT]      = "ITEM_SOUND_CATEGORY_MINERAL_COMPONENT",
        [ITEM_SOUND_CATEGORY_NECKLACE]               = "ITEM_SOUND_CATEGORY_NECKLACE",
        [ITEM_SOUND_CATEGORY_NONE]                   = "ITEM_SOUND_CATEGORY_NONE",
        [ITEM_SOUND_CATEGORY_ONE_HAND_AX]            = "ITEM_SOUND_CATEGORY_ONE_HAND_AX",
        [ITEM_SOUND_CATEGORY_ONE_HAND_HAMMER]        = "ITEM_SOUND_CATEGORY_ONE_HAND_HAMMER",
        [ITEM_SOUND_CATEGORY_ONE_HAND_SWORD]         = "ITEM_SOUND_CATEGORY_ONE_HAND_SWORD",
        [ITEM_SOUND_CATEGORY_PLANT_COMPONENT]        = "ITEM_SOUND_CATEGORY_PLANT_COMPONENT",
        [ITEM_SOUND_CATEGORY_POTION]                 = "ITEM_SOUND_CATEGORY_POTION",
        [ITEM_SOUND_CATEGORY_REPAIR_KIT]             = "ITEM_SOUND_CATEGORY_REPAIR_KIT",
        [ITEM_SOUND_CATEGORY_RING]                   = "ITEM_SOUND_CATEGORY_RING",
        [ITEM_SOUND_CATEGORY_RUNE]                   = "ITEM_SOUND_CATEGORY_RUNE",
        [ITEM_SOUND_CATEGORY_SCROLL]                 = "ITEM_SOUND_CATEGORY_SCROLL",
        [ITEM_SOUND_CATEGORY_SHIELD]                 = "ITEM_SOUND_CATEGORY_SHIELD",
        [ITEM_SOUND_CATEGORY_SIEGE]                  = "ITEM_SOUND_CATEGORY_SIEGE",
        [ITEM_SOUND_CATEGORY_SOUL_GEM]               = "ITEM_SOUND_CATEGORY_SOUL_GEM",
        [ITEM_SOUND_CATEGORY_STAFF]                  = "ITEM_SOUND_CATEGORY_STAFF",
        [ITEM_SOUND_CATEGORY_STEW]                   = "ITEM_SOUND_CATEGORY_STEW",
        [ITEM_SOUND_CATEGORY_TABARD]                 = "ITEM_SOUND_CATEGORY_TABARD",
        [ITEM_SOUND_CATEGORY_TRASH_LOOT]             = "ITEM_SOUND_CATEGORY_TRASH_LOOT",
        [ITEM_SOUND_CATEGORY_TWO_HAND_AX]            = "ITEM_SOUND_CATEGORY_TWO_HAND_AX",
        [ITEM_SOUND_CATEGORY_TWO_HAND_HAMMER]        = "ITEM_SOUND_CATEGORY_TWO_HAND_HAMMER",
        [ITEM_SOUND_CATEGORY_TWO_HAND_SWORD]         = "ITEM_SOUND_CATEGORY_TWO_HAND_SWORD",
        [ITEM_SOUND_CATEGORY_UNUSED]                 = "ITEM_SOUND_CATEGORY_UNUSED",
        [ITEM_SOUND_CATEGORY_WOOD_COMPONENT]         = "ITEM_SOUND_CATEGORY_WOOD_COMPONENT",
    }
    return soundCategories[soundCategory] or string_format("UNKNOWN_SOUND_CATEGORY_%d", soundCategory)
end

-- -----------------------------------------------------------------------------

--- @param soundAction ItemUISoundAction
--- @return string
function LUIE.GetItemSoundActionName(soundAction)
    local soundActions =
    {
        [ITEM_SOUND_ACTION_ACQUIRE] = "ITEM_SOUND_ACTION_ACQUIRE",
        [ITEM_SOUND_ACTION_CRAFTED] = "ITEM_SOUND_ACTION_CRAFTED",
        [ITEM_SOUND_ACTION_DESTROY] = "ITEM_SOUND_ACTION_DESTROY",
        [ITEM_SOUND_ACTION_EQUIP] = "ITEM_SOUND_ACTION_EQUIP",
        [ITEM_SOUND_ACTION_PICKUP] = "ITEM_SOUND_ACTION_PICKUP",
        [ITEM_SOUND_ACTION_SLOT] = "ITEM_SOUND_ACTION_SLOT",
        [ITEM_SOUND_ACTION_UNEQUIP] = "ITEM_SOUND_ACTION_UNEQUIP",
        [ITEM_SOUND_ACTION_USE] = "ITEM_SOUND_ACTION_USE",
    }
    return soundActions[soundAction] or string_format("UNKNOWN_SOUND_ACTION_%d", soundAction)
end

-- -----------------------------------------------------------------------------

--- @param updateReason InventoryUpdateReason
--- @return string
function LUIE.GetInventoryUpdateReasonName(updateReason)
    local updateReasons =
    {
        [INVENTORY_UPDATE_REASON_ARMORY_BUILD_CHANGED] = "INVENTORY_UPDATE_REASON_ARMORY_BUILD_CHANGED",
        [INVENTORY_UPDATE_REASON_DEFAULT] = "INVENTORY_UPDATE_REASON_DEFAULT",
        [INVENTORY_UPDATE_REASON_DURABILITY_CHANGE] = "INVENTORY_UPDATE_REASON_DURABILITY_CHANGE",
        [INVENTORY_UPDATE_REASON_DYE_CHANGE] = "INVENTORY_UPDATE_REASON_DYE_CHANGE",
        [INVENTORY_UPDATE_REASON_ITEM_CHARGE] = "INVENTORY_UPDATE_REASON_ITEM_CHARGE",
        [INVENTORY_UPDATE_REASON_PLAYER_LOCKED] = "INVENTORY_UPDATE_REASON_PLAYER_LOCKED",
    }
    return updateReasons[updateReason] or string_format("UNKNOWN_UPDATE_REASON_%d", updateReason)
end

-- -----------------------------------------------------------------------------

--- @param bag Bag
--- @return string
function LUIE.GetBagName(bag)
    local bagNames =
    {
        [BAG_BACKPACK] = "BAG_BACKPACK",
        [BAG_BANK] = "BAG_BANK",
        [BAG_BUYBACK] = "BAG_BUYBACK",
        [BAG_COMPANION_WORN] = "BAG_COMPANION_WORN",
        [BAG_FURNITURE_VAULT] = "BAG_FURNITURE_VAULT",
        [BAG_GUILDBANK] = "BAG_GUILDBANK",
        [BAG_HOUSE_BANK_EIGHT] = "BAG_HOUSE_BANK_EIGHT",
        [BAG_HOUSE_BANK_FIVE] = "BAG_HOUSE_BANK_FIVE",
        [BAG_HOUSE_BANK_FOUR] = "BAG_HOUSE_BANK_FOUR",
        [BAG_HOUSE_BANK_NINE] = "BAG_HOUSE_BANK_NINE",
        [BAG_HOUSE_BANK_ONE] = "BAG_HOUSE_BANK_ONE",
        [BAG_HOUSE_BANK_SEVEN] = "BAG_HOUSE_BANK_SEVEN",
        [BAG_HOUSE_BANK_SIX] = "BAG_HOUSE_BANK_SIX",
        [BAG_HOUSE_BANK_TEN] = "BAG_HOUSE_BANK_TEN",
        [BAG_HOUSE_BANK_THREE] = "BAG_HOUSE_BANK_THREE",
        [BAG_HOUSE_BANK_TWO] = "BAG_HOUSE_BANK_TWO",
        [BAG_SUBSCRIBER_BANK] = "BAG_SUBSCRIBER_BANK",
        [BAG_VIRTUAL] = "BAG_VIRTUAL",
        [BAG_WORN] = "BAG_WORN",
    }
    return bagNames[bag] or string_format("UNKNOWN_BAG_%d", bag)
end

-- -----------------------------------------------------------------------------

--- @param lootType LootItemType
--- @return string
function LUIE.GetLootTypeName(lootType)
    local lootTypes =
    {
        [LOOT_TYPE_ANTIQUITY_LEAD] = "LOOT_TYPE_ANTIQUITY_LEAD",
        [LOOT_TYPE_ANY] = "LOOT_TYPE_ANY",
        [LOOT_TYPE_DEPRECATED_7] = "LOOT_TYPE_ARCHIVAL_FORTUNES",
        [LOOT_TYPE_DEPRECATED_3] = "LOOT_TYPE_CHAOTIC_CREATIA",
        [LOOT_TYPE_COLLECTIBLE] = "LOOT_TYPE_COLLECTIBLE",
        [LOOT_TYPE_DEPRECATED_5] = "LOOT_TYPE_EVENT_TICKET",
        [LOOT_TYPE_DEPRECATED_8] = "LOOT_TYPE_IMPERIAL_FRAGMENTS",
        [LOOT_TYPE_ITEM] = "LOOT_TYPE_ITEM",
        [LOOT_TYPE_CURRENCY] = "LOOT_TYPE_MONEY",
        [LOOT_TYPE_QUEST_ITEM] = "LOOT_TYPE_QUEST_ITEM",
        [LOOT_TYPE_DEPRECATED_4] = "LOOT_TYPE_STYLE_STONES",
        [LOOT_TYPE_DEPRECATED_1] = "LOOT_TYPE_TELVAR_STONES",
        [LOOT_TYPE_TRIBUTE_CARD_UPGRADE] = "LOOT_TYPE_TRIBUTE_CARD_UPGRADE",
        [LOOT_TYPE_DEPRECATED_6] = "LOOT_TYPE_UNDAUNTED_KEYS",
        [LOOT_TYPE_DEPRECATED_2] = "LOOT_TYPE_WRIT_VOUCHERS",
    }
    return lootTypes[lootType] or string_format("UNKNOWN_LOOT_TYPE_%d", lootType)
end

function LUIE.GetEventName(eventCode)
    local eventNames =
    {
        [EVENT_ABILITY_LIST_CHANGED] = "EVENT_ABILITY_LIST_CHANGED",
        [EVENT_ABILITY_PROGRESSION_RANK_UPDATE] = "EVENT_ABILITY_PROGRESSION_RANK_UPDATE",
        [EVENT_ABILITY_PROGRESSION_RESULT] = "EVENT_ABILITY_PROGRESSION_RESULT",
        [EVENT_ABILITY_PROGRESSION_XP_UPDATE] = "EVENT_ABILITY_PROGRESSION_XP_UPDATE",
        [EVENT_ABILITY_REQUIREMENTS_FAIL] = "EVENT_ABILITY_REQUIREMENTS_FAIL",
        [EVENT_ACCEPT_SHARED_QUEST_RESPONSE] = "EVENT_ACCEPT_SHARED_QUEST_RESPONSE",
        [EVENT_ACCOUNT_EMAIL_ACTIVATION_EMAIL_SENT] = "EVENT_ACCOUNT_EMAIL_ACTIVATION_EMAIL_SENT",
        [EVENT_ACHIEVEMENT_AWARDED] = "EVENT_ACHIEVEMENT_AWARDED",
        [EVENT_ACHIEVEMENT_UPDATED] = "EVENT_ACHIEVEMENT_UPDATED",
        [EVENT_ACHIEVEMENTS_COMPLETED_ON_UPGRADE_TO_ACCOUNT_WIDE] = "EVENT_ACHIEVEMENTS_COMPLETED_ON_UPGRADE_TO_ACCOUNT_WIDE",
        [EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY] = "EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY",
        [EVENT_ACHIEVEMENTS_UPDATED] = "EVENT_ACHIEVEMENTS_UPDATED",
        [EVENT_ACTION_BAR_IS_RESPECCABLE_BAR_STATE_CHANGED] = "EVENT_ACTION_BAR_IS_RESPECCABLE_BAR_STATE_CHANGED",
        [EVENT_ACTION_BAR_LOCKED_REASON_CHANGED] = "EVENT_ACTION_BAR_LOCKED_REASON_CHANGED",
        [EVENT_ACTION_BAR_SLOTTING_ALLOWED_STATE_CHANGED] = "EVENT_ACTION_BAR_SLOTTING_ALLOWED_STATE_CHANGED",
        [EVENT_ACTION_LAYER_POPPED] = "EVENT_ACTION_LAYER_POPPED",
        [EVENT_ACTION_LAYER_PUSHED] = "EVENT_ACTION_LAYER_PUSHED",
        [EVENT_ACTION_SLOT_ABILITY_USED] = "EVENT_ACTION_SLOT_ABILITY_USED",
        [EVENT_ACTION_SLOT_ABILITY_USED_WRONG_WEAPON] = "EVENT_ACTION_SLOT_ABILITY_USED_WRONG_WEAPON",
        [EVENT_ACTION_SLOT_EFFECT_UPDATE] = "EVENT_ACTION_SLOT_EFFECT_UPDATE",
        [EVENT_ACTION_SLOT_EFFECTS_CLEARED] = "EVENT_ACTION_SLOT_EFFECTS_CLEARED",
        [EVENT_ACTION_SLOT_STATE_UPDATED] = "EVENT_ACTION_SLOT_STATE_UPDATED",
        [EVENT_ACTION_SLOT_UPDATED] = "EVENT_ACTION_SLOT_UPDATED",
        [EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED] = "EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED",
        [EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED] = "EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED",
        [EVENT_ACTION_SLOTS_FULL_UPDATE] = "EVENT_ACTION_SLOTS_FULL_UPDATE",
        [EVENT_ACTION_UPDATE_COOLDOWNS] = "EVENT_ACTION_UPDATE_COOLDOWNS",
        [EVENT_ACTIVE_COMPANION_STATE_CHANGED] = "EVENT_ACTIVE_COMPANION_STATE_CHANGED",
        [EVENT_ACTIVE_DAEDRIC_ARTIFACT_CHANGED] = "EVENT_ACTIVE_DAEDRIC_ARTIFACT_CHANGED",
        [EVENT_ACTIVE_DISPLAY_CHANGED] = "EVENT_ACTIVE_DISPLAY_CHANGED",
        [EVENT_ACTIVE_MOUNT_CHANGED] = "EVENT_ACTIVE_MOUNT_CHANGED",
        [EVENT_ACTIVE_QUEST_TOOL_CHANGED] = "EVENT_ACTIVE_QUEST_TOOL_CHANGED",
        [EVENT_ACTIVE_QUEST_TOOL_CLEARED] = "EVENT_ACTIVE_QUEST_TOOL_CLEARED",
        [EVENT_ACTIVE_QUICKSLOT_CHANGED] = "EVENT_ACTIVE_QUICKSLOT_CHANGED",
        [EVENT_ACTIVE_WEAPON_PAIR_CHANGED] = "EVENT_ACTIVE_WEAPON_PAIR_CHANGED",
        [EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE] = "EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE",
        [EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE] = "EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE",
        [EVENT_ACTIVITY_FINDER_STATUS_UPDATE] = "EVENT_ACTIVITY_FINDER_STATUS_UPDATE",
        [EVENT_ACTIVITY_QUEUE_RESULT] = "EVENT_ACTIVITY_QUEUE_RESULT",
        [EVENT_ADD_ON_LOADED] = "EVENT_ADD_ON_LOADED",
        [EVENT_ADD_ONS_LOADED] = "EVENT_ADD_ONS_LOADED",
        [EVENT_AGENT_CHAT_ACCEPTED] = "EVENT_AGENT_CHAT_ACCEPTED",
        [EVENT_AGENT_CHAT_DECLINED] = "EVENT_AGENT_CHAT_DECLINED",
        [EVENT_AGENT_CHAT_FORCED] = "EVENT_AGENT_CHAT_FORCED",
        [EVENT_AGENT_CHAT_REQUESTED] = "EVENT_AGENT_CHAT_REQUESTED",
        [EVENT_AGENT_CHAT_TERMINATED] = "EVENT_AGENT_CHAT_TERMINATED",
        [EVENT_ALL_GUI_SCREENS_RESIZE_STARTED] = "EVENT_ALL_GUI_SCREENS_RESIZE_STARTED",
        [EVENT_ALL_GUI_SCREENS_RESIZED] = "EVENT_ALL_GUI_SCREENS_RESIZED",
        [EVENT_ALLIANCE_POINT_UPDATE] = "EVENT_ALLIANCE_POINT_UPDATE",
        [EVENT_ANIMATION_NOTE] = "EVENT_ANIMATION_NOTE",
        [EVENT_ANTIQUITIES_UPDATED] = "EVENT_ANTIQUITIES_UPDATED",
        [EVENT_ANTIQUITY_DIG_SITES_UPDATED] = "EVENT_ANTIQUITY_DIG_SITES_UPDATED",
        [EVENT_ANTIQUITY_DIG_SPOT_DIG_POWER_CHANGED] = "EVENT_ANTIQUITY_DIG_SPOT_DIG_POWER_CHANGED",
        [EVENT_ANTIQUITY_DIG_SPOT_DURABILITY_CHANGED] = "EVENT_ANTIQUITY_DIG_SPOT_DURABILITY_CHANGED",
        [EVENT_ANTIQUITY_DIG_SPOT_STABILITY_CHANGED] = "EVENT_ANTIQUITY_DIG_SPOT_STABILITY_CHANGED",
        [EVENT_ANTIQUITY_DIGGING_ACTIVE_SKILL_USE_RESULT] = "EVENT_ANTIQUITY_DIGGING_ACTIVE_SKILL_USE_RESULT",
        [EVENT_ANTIQUITY_DIGGING_ANTIQUITY_UNEARTHED] = "EVENT_ANTIQUITY_DIGGING_ANTIQUITY_UNEARTHED",
        [EVENT_ANTIQUITY_DIGGING_BONUS_LOOT_UNEARTHED] = "EVENT_ANTIQUITY_DIGGING_BONUS_LOOT_UNEARTHED",
        [EVENT_ANTIQUITY_DIGGING_DIG_POWER_REFUND] = "EVENT_ANTIQUITY_DIGGING_DIG_POWER_REFUND",
        [EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE] = "EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE",
        [EVENT_ANTIQUITY_DIGGING_GAME_OVER] = "EVENT_ANTIQUITY_DIGGING_GAME_OVER",
        [EVENT_ANTIQUITY_DIGGING_MOUSE_OVER_ACTIVE_SKILL_CHANGED] = "EVENT_ANTIQUITY_DIGGING_MOUSE_OVER_ACTIVE_SKILL_CHANGED",
        [EVENT_ANTIQUITY_DIGGING_NUM_RADARS_REMAINING_CHANGED] = "EVENT_ANTIQUITY_DIGGING_NUM_RADARS_REMAINING_CHANGED",
        [EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY] = "EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY",
        [EVENT_ANTIQUITY_JOURNAL_SHOW_SCRYABLE] = "EVENT_ANTIQUITY_JOURNAL_SHOW_SCRYABLE",
        [EVENT_ANTIQUITY_LEAD_ACQUIRED] = "EVENT_ANTIQUITY_LEAD_ACQUIRED",
        [EVENT_ANTIQUITY_SCRYING_RESULT] = "EVENT_ANTIQUITY_SCRYING_RESULT",
        [EVENT_ANTIQUITY_SEARCH_RESULTS_READY] = "EVENT_ANTIQUITY_SEARCH_RESULTS_READY",
        [EVENT_ANTIQUITY_SELECTED_TOOL_CHANGED] = "EVENT_ANTIQUITY_SELECTED_TOOL_CHANGED",
        [EVENT_ANTIQUITY_SHOW_CODEX_ENTRY] = "EVENT_ANTIQUITY_SHOW_CODEX_ENTRY",
        [EVENT_ANTIQUITY_TRACKING_INITIALIZED] = "EVENT_ANTIQUITY_TRACKING_INITIALIZED",
        [EVENT_ANTIQUITY_TRACKING_UPDATE] = "EVENT_ANTIQUITY_TRACKING_UPDATE",
        [EVENT_ANTIQUITY_UPDATED] = "EVENT_ANTIQUITY_UPDATED",
        [EVENT_APP_GUI_HIDDEN_STATE_CHANGED] = "EVENT_APP_GUI_HIDDEN_STATE_CHANGED",
        [EVENT_ARMORY_BUILD_CHAMPION_SLOTS_MODIFIED] = "EVENT_ARMORY_BUILD_CHAMPION_SLOTS_MODIFIED",
        [EVENT_ARMORY_BUILD_COUNT_UPDATED] = "EVENT_ARMORY_BUILD_COUNT_UPDATED",
        [EVENT_ARMORY_BUILD_OPERATION_STARTED] = "EVENT_ARMORY_BUILD_OPERATION_STARTED",
        [EVENT_ARMORY_BUILD_RESTORE_RESPONSE] = "EVENT_ARMORY_BUILD_RESTORE_RESPONSE",
        [EVENT_ARMORY_BUILD_SAVE_RESPONSE] = "EVENT_ARMORY_BUILD_SAVE_RESPONSE",
        [EVENT_ARMORY_BUILD_UPDATED] = "EVENT_ARMORY_BUILD_UPDATED",
        [EVENT_ARMORY_BUILDS_FULL_UPDATE] = "EVENT_ARMORY_BUILDS_FULL_UPDATE",
        [EVENT_ARTIFACT_CONTROL_STATE] = "EVENT_ARTIFACT_CONTROL_STATE",
        [EVENT_ARTIFACT_SCROLL_STATE_CHANGED] = "EVENT_ARTIFACT_SCROLL_STATE_CHANGED",
        [EVENT_ARTIFICIAL_EFFECT_ADDED] = "EVENT_ARTIFICIAL_EFFECT_ADDED",
        [EVENT_ARTIFICIAL_EFFECT_REMOVED] = "EVENT_ARTIFICIAL_EFFECT_REMOVED",
        [EVENT_ASSIGNED_CAMPAIGN_CHANGED] = "EVENT_ASSIGNED_CAMPAIGN_CHANGED",
        [EVENT_ATTRIBUTE_RESPEC_RESULT] = "EVENT_ATTRIBUTE_RESPEC_RESULT",
        [EVENT_ATTRIBUTE_UPGRADE_UPDATED] = "EVENT_ATTRIBUTE_UPGRADE_UPDATED",
        [EVENT_AUTO_MAP_NAVIGATION_TARGET_SET] = "EVENT_AUTO_MAP_NAVIGATION_TARGET_SET",
        [EVENT_AVAILABLE_DISPLAY_DEVICES_CHANGED] = "EVENT_AVAILABLE_DISPLAY_DEVICES_CHANGED",
        [EVENT_AVENGE_KILL] = "EVENT_AVENGE_KILL",
        [EVENT_BACKGROUND_LIST_FILTER_COMPLETE] = "EVENT_BACKGROUND_LIST_FILTER_COMPLETE",
        [EVENT_BANK_DEPOSIT_NOT_ALLOWED] = "EVENT_BANK_DEPOSIT_NOT_ALLOWED",
        [EVENT_BANK_IS_FULL] = "EVENT_BANK_IS_FULL",
        [EVENT_BANKED_CURRENCY_UPDATE] = "EVENT_BANKED_CURRENCY_UPDATE",
        [EVENT_BANKED_MONEY_UPDATE] = "EVENT_BANKED_MONEY_UPDATE",
        [EVENT_BATTLEGROUND_INACTIVITY_WARNING] = "EVENT_BATTLEGROUND_INACTIVITY_WARNING",
        [EVENT_BATTLEGROUND_KILL] = "EVENT_BATTLEGROUND_KILL",
        [EVENT_BATTLEGROUND_LEADERBOARD_DATA_RECEIVED] = "EVENT_BATTLEGROUND_LEADERBOARD_DATA_RECEIVED",
        [EVENT_BATTLEGROUND_MMR_LOSS_REDUCED] = "EVENT_BATTLEGROUND_MMR_LOSS_REDUCED",
        [EVENT_BATTLEGROUND_RULESET_CHANGED] = "EVENT_BATTLEGROUND_RULESET_CHANGED",
        [EVENT_BATTLEGROUND_SCOREBOARD_UPDATED] = "EVENT_BATTLEGROUND_SCOREBOARD_UPDATED",
        [EVENT_BATTLEGROUND_SHUTDOWN_TIMER] = "EVENT_BATTLEGROUND_SHUTDOWN_TIMER",
        [EVENT_BATTLEGROUND_STATE_CHANGED] = "EVENT_BATTLEGROUND_STATE_CHANGED",
        [EVENT_BEGIN_CUTSCENE] = "EVENT_BEGIN_CUTSCENE",
        [EVENT_BEGIN_LOCKPICK] = "EVENT_BEGIN_LOCKPICK",
        [EVENT_BEGIN_SIEGE_CONTROL] = "EVENT_BEGIN_SIEGE_CONTROL",
        [EVENT_BEGIN_SIEGE_UPGRADE] = "EVENT_BEGIN_SIEGE_UPGRADE",
        [EVENT_BOSSES_CHANGED] = "EVENT_BOSSES_CHANGED",
        [EVENT_BROADCAST] = "EVENT_BROADCAST",
        [EVENT_BUY_RECEIPT] = "EVENT_BUY_RECEIPT",
        [EVENT_BUYBACK_RECEIPT] = "EVENT_BUYBACK_RECEIPT",
        [EVENT_CADWELL_PROGRESSION_LEVEL_CHANGED] = "EVENT_CADWELL_PROGRESSION_LEVEL_CHANGED",
        [EVENT_CAMPAIGN_ALLIANCE_LOCK_ACTIVATED] = "EVENT_CAMPAIGN_ALLIANCE_LOCK_ACTIVATED",
        [EVENT_CAMPAIGN_ALLIANCE_LOCK_PENDING] = "EVENT_CAMPAIGN_ALLIANCE_LOCK_PENDING",
        [EVENT_CAMPAIGN_ASSIGNMENT_RESULT] = "EVENT_CAMPAIGN_ASSIGNMENT_RESULT",
        [EVENT_CAMPAIGN_EMPEROR_CHANGED] = "EVENT_CAMPAIGN_EMPEROR_CHANGED",
        [EVENT_CAMPAIGN_HISTORY_WINDOW_CHANGED] = "EVENT_CAMPAIGN_HISTORY_WINDOW_CHANGED",
        [EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED] = "EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED",
        [EVENT_CAMPAIGN_QUEUE_JOINED] = "EVENT_CAMPAIGN_QUEUE_JOINED",
        [EVENT_CAMPAIGN_QUEUE_LEFT] = "EVENT_CAMPAIGN_QUEUE_LEFT",
        [EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED] = "EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED",
        [EVENT_CAMPAIGN_QUEUE_STATE_CHANGED] = "EVENT_CAMPAIGN_QUEUE_STATE_CHANGED",
        [EVENT_CAMPAIGN_SCORE_DATA_CHANGED] = "EVENT_CAMPAIGN_SCORE_DATA_CHANGED",
        [EVENT_CAMPAIGN_SELECTION_DATA_CHANGED] = "EVENT_CAMPAIGN_SELECTION_DATA_CHANGED",
        [EVENT_CAMPAIGN_STATE_INITIALIZED] = "EVENT_CAMPAIGN_STATE_INITIALIZED",
        [EVENT_CAMPAIGN_UNASSIGNMENT_RESULT] = "EVENT_CAMPAIGN_UNASSIGNMENT_RESULT",
        [EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION] = "EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION",
        [EVENT_CANCEL_GROUND_TARGET_MODE] = "EVENT_CANCEL_GROUND_TARGET_MODE",
        [EVENT_CANCEL_MOUSE_REQUEST_DESTROY_ITEM] = "EVENT_CANCEL_MOUSE_REQUEST_DESTROY_ITEM",
        [EVENT_CANCEL_REQUEST_CONFIRM_USE_ITEM] = "EVENT_CANCEL_REQUEST_CONFIRM_USE_ITEM",
        [EVENT_CANNOT_CROUCH_WHILE_CARRYING_ARTIFACT] = "EVENT_CANNOT_CROUCH_WHILE_CARRYING_ARTIFACT",
        [EVENT_CANNOT_DO_THAT_WHILE_DEAD] = "EVENT_CANNOT_DO_THAT_WHILE_DEAD",
        [EVENT_CANNOT_DO_THAT_WHILE_HIDDEN] = "EVENT_CANNOT_DO_THAT_WHILE_HIDDEN",
        [EVENT_CAPS_LOCK_STATE_CHANGED] = "EVENT_CAPS_LOCK_STATE_CHANGED",
        [EVENT_CAPTURE_AREA_SPAWNED] = "EVENT_CAPTURE_AREA_SPAWNED",
        [EVENT_CAPTURE_AREA_STATE_CHANGED] = "EVENT_CAPTURE_AREA_STATE_CHANGED",
        [EVENT_CAPTURE_AREA_STATUS] = "EVENT_CAPTURE_AREA_STATUS",
        [EVENT_CAPTURE_FLAG_STATE_CHANGED] = "EVENT_CAPTURE_FLAG_STATE_CHANGED",
        [EVENT_CARRIED_CURRENCY_UPDATE] = "EVENT_CARRIED_CURRENCY_UPDATE",
        [EVENT_CHAMPION_LEVEL_ACHIEVED] = "EVENT_CHAMPION_LEVEL_ACHIEVED",
        [EVENT_CHAMPION_POINT_GAINED] = "EVENT_CHAMPION_POINT_GAINED",
        [EVENT_CHAMPION_POINT_UPDATE] = "EVENT_CHAMPION_POINT_UPDATE",
        [EVENT_CHAMPION_PURCHASE_RESULT] = "EVENT_CHAMPION_PURCHASE_RESULT",
        [EVENT_CHAMPION_SYSTEM_UNLOCKED] = "EVENT_CHAMPION_SYSTEM_UNLOCKED",
        [EVENT_CHAT_CATEGORY_COLOR_CHANGED] = "EVENT_CHAT_CATEGORY_COLOR_CHANGED",
        [EVENT_CHAT_LOG_TOGGLED] = "EVENT_CHAT_LOG_TOGGLED",
        [EVENT_CHAT_MESSAGE_CHANNEL] = "EVENT_CHAT_MESSAGE_CHANNEL",
        [EVENT_CHATTER_BEGIN] = "EVENT_CHATTER_BEGIN",
        [EVENT_CHATTER_END] = "EVENT_CHATTER_END",
        [EVENT_CLAIM_LEVEL_UP_REWARD_RESULT] = "EVENT_CLAIM_LEVEL_UP_REWARD_RESULT",
        [EVENT_CLAIM_REWARD_RESULT] = "EVENT_CLAIM_REWARD_RESULT",
        [EVENT_CLEAR_NEW_ON_ALL_SKILL_LINES] = "EVENT_CLEAR_NEW_ON_ALL_SKILL_LINES",
        [EVENT_CLIENT_INTERACT_RESULT] = "EVENT_CLIENT_INTERACT_RESULT",
        [EVENT_CLOSE_BANK] = "EVENT_CLOSE_BANK",
        [EVENT_CLOSE_GUILD_BANK] = "EVENT_CLOSE_GUILD_BANK",
        [EVENT_CLOSE_STORE] = "EVENT_CLOSE_STORE",
        [EVENT_CLOSE_TRADING_HOUSE] = "EVENT_CLOSE_TRADING_HOUSE",
        [EVENT_COLLECTIBLE_BLACKLIST_UPDATED] = "EVENT_COLLECTIBLE_BLACKLIST_UPDATED",
        [EVENT_COLLECTIBLE_CATEGORY_NEW_STATUS_CLEARED] = "EVENT_COLLECTIBLE_CATEGORY_NEW_STATUS_CLEARED",
        [EVENT_COLLECTIBLE_DYE_DATA_UPDATED] = "EVENT_COLLECTIBLE_DYE_DATA_UPDATED",
        [EVENT_COLLECTIBLE_NEW_STATUS_CLEARED] = "EVENT_COLLECTIBLE_NEW_STATUS_CLEARED",
        [EVENT_COLLECTIBLE_NOTIFICATION_NEW] = "EVENT_COLLECTIBLE_NOTIFICATION_NEW",
        [EVENT_COLLECTIBLE_NOTIFICATION_REMOVED] = "EVENT_COLLECTIBLE_NOTIFICATION_REMOVED",
        [EVENT_COLLECTIBLE_ON_COOLDOWN] = "EVENT_COLLECTIBLE_ON_COOLDOWN",
        [EVENT_COLLECTIBLE_RENAME_ERROR] = "EVENT_COLLECTIBLE_RENAME_ERROR",
        [EVENT_COLLECTIBLE_REQUEST_BROWSE_TO] = "EVENT_COLLECTIBLE_REQUEST_BROWSE_TO",
        [EVENT_COLLECTIBLE_SET_IN_WATER_ALERT] = "EVENT_COLLECTIBLE_SET_IN_WATER_ALERT",
        [EVENT_COLLECTIBLE_UPDATED] = "EVENT_COLLECTIBLE_UPDATED",
        [EVENT_COLLECTIBLE_USE_BLOCKED] = "EVENT_COLLECTIBLE_USE_BLOCKED",
        [EVENT_COLLECTIBLE_USE_RESULT] = "EVENT_COLLECTIBLE_USE_RESULT",
        [EVENT_COLLECTIBLE_USER_FLAGS_UPDATED] = "EVENT_COLLECTIBLE_USER_FLAGS_UPDATED",
        [EVENT_COLLECTIBLES_SEARCH_RESULTS_READY] = "EVENT_COLLECTIBLES_SEARCH_RESULTS_READY",
        [EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED] = "EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED",
        [EVENT_COLLECTION_UPDATED] = "EVENT_COLLECTION_UPDATED",
        [EVENT_COMBAT_EVENT] = "EVENT_COMBAT_EVENT",
        [EVENT_COMPANION_ACTIVATED] = "EVENT_COMPANION_ACTIVATED",
        [EVENT_COMPANION_DEACTIVATED] = "EVENT_COMPANION_DEACTIVATED",
        [EVENT_COMPANION_EXPERIENCE_GAIN] = "EVENT_COMPANION_EXPERIENCE_GAIN",
        [EVENT_COMPANION_RAPPORT_UPDATE] = "EVENT_COMPANION_RAPPORT_UPDATE",
        [EVENT_COMPANION_SKILL_LINE_ADDED] = "EVENT_COMPANION_SKILL_LINE_ADDED",
        [EVENT_COMPANION_SKILL_RANK_UPDATE] = "EVENT_COMPANION_SKILL_RANK_UPDATE",
        [EVENT_COMPANION_SKILL_XP_UPDATE] = "EVENT_COMPANION_SKILL_XP_UPDATE",
        [EVENT_COMPANION_SKILLS_FULL_UPDATE] = "EVENT_COMPANION_SKILLS_FULL_UPDATE",
        [EVENT_COMPANION_SUMMON_RESULT] = "EVENT_COMPANION_SUMMON_RESULT",
        [EVENT_COMPANION_ULTIMATE_FAILURE] = "EVENT_COMPANION_ULTIMATE_FAILURE",
        [EVENT_CONFIRM_INTERACT] = "EVENT_CONFIRM_INTERACT",
        [EVENT_CONSOLE_ADD_ONS_MEMORY_LIMIT_REACHED] = "EVENT_CONSOLE_ADD_ONS_MEMORY_LIMIT_REACHED",
        [EVENT_CONSOLE_ADD_ONS_SAVED_VARIABLES_LIMIT_REACHED] = "EVENT_CONSOLE_ADD_ONS_SAVED_VARIABLES_LIMIT_REACHED",
        [EVENT_CONSOLE_ADDONS_DISABLED_STATE_CHANGED] = "EVENT_CONSOLE_ADDONS_DISABLED_STATE_CHANGED",
        [EVENT_CONSOLE_INFO_RECEIVED] = "EVENT_CONSOLE_INFO_RECEIVED",
        [EVENT_CONSOLE_TEXT_VALIDATION_RESULT] = "EVENT_CONSOLE_TEXT_VALIDATION_RESULT",
        [EVENT_CONSOLIDATED_SMITHING_ITEM_SET_SEARCH_RESULTS_READY] = "EVENT_CONSOLIDATED_SMITHING_ITEM_SET_SEARCH_RESULTS_READY",
        [EVENT_CONSOLIDATED_STATION_ACTIVE_SET_UPDATED] = "EVENT_CONSOLIDATED_STATION_ACTIVE_SET_UPDATED",
        [EVENT_CONSOLIDATED_STATION_SETS_UPDATED] = "EVENT_CONSOLIDATED_STATION_SETS_UPDATED",
        [EVENT_CONTROLLER_CONNECTED] = "EVENT_CONTROLLER_CONNECTED",
        [EVENT_CONTROLLER_DISCONNECTED] = "EVENT_CONTROLLER_DISCONNECTED",
        [EVENT_CONVERSATION_FAILED_INVENTORY_FULL] = "EVENT_CONVERSATION_FAILED_INVENTORY_FULL",
        [EVENT_CONVERSATION_FAILED_UNIQUE_ITEM] = "EVENT_CONVERSATION_FAILED_UNIQUE_ITEM",
        [EVENT_CONVERSATION_UPDATED] = "EVENT_CONVERSATION_UPDATED",
        [EVENT_CORONATE_EMPEROR_NOTIFICATION] = "EVENT_CORONATE_EMPEROR_NOTIFICATION",
        [EVENT_CRAFT_BAG_AUTO_TRANSFER_NOTIFICATION_CLEARED] = "EVENT_CRAFT_BAG_AUTO_TRANSFER_NOTIFICATION_CLEARED",
        [EVENT_CRAFT_COMPLETED] = "EVENT_CRAFT_COMPLETED",
        [EVENT_CRAFT_FAILED] = "EVENT_CRAFT_FAILED",
        [EVENT_CRAFT_STARTED] = "EVENT_CRAFT_STARTED",
        [EVENT_CRAFTED_ABILITY_LOCK_STATE_CHANGED] = "EVENT_CRAFTED_ABILITY_LOCK_STATE_CHANGED",
        [EVENT_CRAFTED_ABILITY_RESET] = "EVENT_CRAFTED_ABILITY_RESET",
        [EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED] = "EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED",
        [EVENT_CRAFTED_ABILITY_SEARCH_RESULTS_READY] = "EVENT_CRAFTED_ABILITY_SEARCH_RESULTS_READY",
        [EVENT_CRAFTING_STATION_INTERACT] = "EVENT_CRAFTING_STATION_INTERACT",
        [EVENT_CROWN_CRATE_INVENTORY_UPDATED] = "EVENT_CROWN_CRATE_INVENTORY_UPDATED",
        [EVENT_CROWN_CRATE_OPEN_RESPONSE] = "EVENT_CROWN_CRATE_OPEN_RESPONSE",
        [EVENT_CROWN_CRATE_QUANTITY_UPDATE] = "EVENT_CROWN_CRATE_QUANTITY_UPDATE",
        [EVENT_CROWN_CRATES_SYSTEM_STATE_CHANGED] = "EVENT_CROWN_CRATES_SYSTEM_STATE_CHANGED",
        [EVENT_CROWN_GEM_UPDATE] = "EVENT_CROWN_GEM_UPDATE",
        [EVENT_CROWN_UPDATE] = "EVENT_CROWN_UPDATE",
        [EVENT_CURRENCY_CAPS_CHANGED] = "EVENT_CURRENCY_CAPS_CHANGED",
        [EVENT_CURRENCY_UPDATE] = "EVENT_CURRENCY_UPDATE",
        [EVENT_CURRENT_CAMPAIGN_CHANGED] = "EVENT_CURRENT_CAMPAIGN_CHANGED",
        [EVENT_CURRENT_SUBZONE_LIST_CHANGED] = "EVENT_CURRENT_SUBZONE_LIST_CHANGED",
        [EVENT_CURSOR_DROPPED] = "EVENT_CURSOR_DROPPED",
        [EVENT_CURSOR_PICKUP] = "EVENT_CURSOR_PICKUP",
        [EVENT_CUSTOMER_SERVICE_FEEDBACK_SUBMITTED] = "EVENT_CUSTOMER_SERVICE_FEEDBACK_SUBMITTED",
        [EVENT_CUSTOMER_SERVICE_TICKET_SUBMITTED] = "EVENT_CUSTOMER_SERVICE_TICKET_SUBMITTED",
        [EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED] = "EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED",
        [EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED] = "EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED",
        [EVENT_DAILY_LOGIN_MONTH_CHANGED] = "EVENT_DAILY_LOGIN_MONTH_CHANGED",
        [EVENT_DAILY_LOGIN_REWARDS_CLAIMED] = "EVENT_DAILY_LOGIN_REWARDS_CLAIMED",
        [EVENT_DAILY_LOGIN_REWARDS_UPDATED] = "EVENT_DAILY_LOGIN_REWARDS_UPDATED",
        [EVENT_DEFERRED_SETTING_REQUEST_COMPLETED] = "EVENT_DEFERRED_SETTING_REQUEST_COMPLETED",
        [EVENT_DELETE_MAIL_RESPONSE] = "EVENT_DELETE_MAIL_RESPONSE",
        [EVENT_DEPOSE_EMPEROR_NOTIFICATION] = "EVENT_DEPOSE_EMPEROR_NOTIFICATION",
        [EVENT_DIFFICULTY_LEVEL_CHANGED] = "EVENT_DIFFICULTY_LEVEL_CHANGED",
        [EVENT_DISABLE_SIEGE_AIM_ABILITY] = "EVENT_DISABLE_SIEGE_AIM_ABILITY",
        [EVENT_DISABLE_SIEGE_FIRE_ABILITY] = "EVENT_DISABLE_SIEGE_FIRE_ABILITY",
        [EVENT_DISABLE_SIEGE_PACKUP_ABILITY] = "EVENT_DISABLE_SIEGE_PACKUP_ABILITY",
        [EVENT_DISABLED_ACTIVITIES_UPDATE] = "EVENT_DISABLED_ACTIVITIES_UPDATE",
        [EVENT_DISCOVERY_EXPERIENCE] = "EVENT_DISCOVERY_EXPERIENCE",
        [EVENT_DISGUISE_STATE_CHANGED] = "EVENT_DISGUISE_STATE_CHANGED",
        [EVENT_DISPLAY_ACTIVE_COMBAT_TIP] = "EVENT_DISPLAY_ACTIVE_COMBAT_TIP",
        [EVENT_DISPLAY_ALERT] = "EVENT_DISPLAY_ALERT",
        [EVENT_DISPLAY_ANNOUNCEMENT] = "EVENT_DISPLAY_ANNOUNCEMENT",
        [EVENT_DISPLAY_TUTORIAL] = "EVENT_DISPLAY_TUTORIAL",
        [EVENT_DISPLAY_TUTORIAL_WITH_ANCHOR] = "EVENT_DISPLAY_TUTORIAL_WITH_ANCHOR",
        [EVENT_DISPOSITION_UPDATE] = "EVENT_DISPOSITION_UPDATE",
        [EVENT_DUEL_COUNTDOWN] = "EVENT_DUEL_COUNTDOWN",
        [EVENT_DUEL_FINISHED] = "EVENT_DUEL_FINISHED",
        [EVENT_DUEL_INVITE_ACCEPTED] = "EVENT_DUEL_INVITE_ACCEPTED",
        [EVENT_DUEL_INVITE_CANCELED] = "EVENT_DUEL_INVITE_CANCELED",
        [EVENT_DUEL_INVITE_DECLINED] = "EVENT_DUEL_INVITE_DECLINED",
        [EVENT_DUEL_INVITE_FAILED] = "EVENT_DUEL_INVITE_FAILED",
        [EVENT_DUEL_INVITE_RECEIVED] = "EVENT_DUEL_INVITE_RECEIVED",
        [EVENT_DUEL_INVITE_REMOVED] = "EVENT_DUEL_INVITE_REMOVED",
        [EVENT_DUEL_INVITE_SENT] = "EVENT_DUEL_INVITE_SENT",
        [EVENT_DUEL_NEAR_BOUNDARY] = "EVENT_DUEL_NEAR_BOUNDARY",
        [EVENT_DUEL_STARTED] = "EVENT_DUEL_STARTED",
        [EVENT_DURANGO_ACCOUNT_PICKER_RETURNED] = "EVENT_DURANGO_ACCOUNT_PICKER_RETURNED",
        [EVENT_DYE_STAMP_USE_FAIL] = "EVENT_DYE_STAMP_USE_FAIL",
        [EVENT_DYEING_STATION_INTERACT_END] = "EVENT_DYEING_STATION_INTERACT_END",
        [EVENT_DYEING_STATION_INTERACT_START] = "EVENT_DYEING_STATION_INTERACT_START",
        [EVENT_DYES_SEARCH_RESULTS_READY] = "EVENT_DYES_SEARCH_RESULTS_READY",
        [EVENT_EFFECT_CHANGED] = "EVENT_EFFECT_CHANGED",
        [EVENT_EFFECTS_FULL_UPDATE] = "EVENT_EFFECTS_FULL_UPDATE",
        [EVENT_ENABLE_SIEGE_AIM_ABILITY] = "EVENT_ENABLE_SIEGE_AIM_ABILITY",
        [EVENT_ENABLE_SIEGE_FIRE_ABILITY] = "EVENT_ENABLE_SIEGE_FIRE_ABILITY",
        [EVENT_ENABLE_SIEGE_PACKUP_ABILITY] = "EVENT_ENABLE_SIEGE_PACKUP_ABILITY",
        [EVENT_END_CRAFTING_STATION_INTERACT] = "EVENT_END_CRAFTING_STATION_INTERACT",
        [EVENT_END_CUTSCENE] = "EVENT_END_CUTSCENE",
        [EVENT_END_FAST_TRAVEL_INTERACTION] = "EVENT_END_FAST_TRAVEL_INTERACTION",
        [EVENT_END_FAST_TRAVEL_KEEP_INTERACTION] = "EVENT_END_FAST_TRAVEL_KEEP_INTERACTION",
        [EVENT_END_KEEP_GUILD_CLAIM_INTERACTION] = "EVENT_END_KEEP_GUILD_CLAIM_INTERACTION",
        [EVENT_END_KEEP_GUILD_RELEASE_INTERACTION] = "EVENT_END_KEEP_GUILD_RELEASE_INTERACTION",
        [EVENT_END_SIEGE_CONTROL] = "EVENT_END_SIEGE_CONTROL",
        [EVENT_END_SOUL_GEM_RESURRECTION] = "EVENT_END_SOUL_GEM_RESURRECTION",
        [EVENT_ENDLESS_DUNGEON_BUFF_SELECTOR_CHOICES_RECEIVED] = "EVENT_ENDLESS_DUNGEON_BUFF_SELECTOR_CHOICES_RECEIVED",
        [EVENT_ENDLESS_DUNGEON_BUFF_STACK_COUNT_UPDATED] = "EVENT_ENDLESS_DUNGEON_BUFF_STACK_COUNT_UPDATED",
        [EVENT_ENDLESS_DUNGEON_COMPLETED] = "EVENT_ENDLESS_DUNGEON_COMPLETED",
        [EVENT_ENDLESS_DUNGEON_CONFIRM_COMPANION_SUMMONING] = "EVENT_ENDLESS_DUNGEON_CONFIRM_COMPANION_SUMMONING",
        [EVENT_ENDLESS_DUNGEON_COUNTER_VALUE_CHANGED] = "EVENT_ENDLESS_DUNGEON_COUNTER_VALUE_CHANGED",
        [EVENT_ENDLESS_DUNGEON_INITIALIZED] = "EVENT_ENDLESS_DUNGEON_INITIALIZED",
        [EVENT_ENDLESS_DUNGEON_LEADERBOARD_DATA_RECEIVED] = "EVENT_ENDLESS_DUNGEON_LEADERBOARD_DATA_RECEIVED",
        [EVENT_ENDLESS_DUNGEON_LEADERBOARD_PLAYER_DATA_CHANGED] = "EVENT_ENDLESS_DUNGEON_LEADERBOARD_PLAYER_DATA_CHANGED",
        [EVENT_ENDLESS_DUNGEON_NEW_BEST_SCORE] = "EVENT_ENDLESS_DUNGEON_NEW_BEST_SCORE",
        [EVENT_ENDLESS_DUNGEON_OF_THE_WEEK_TURNOVER] = "EVENT_ENDLESS_DUNGEON_OF_THE_WEEK_TURNOVER",
        [EVENT_ENDLESS_DUNGEON_RESET_BEST_SCORE] = "EVENT_ENDLESS_DUNGEON_RESET_BEST_SCORE",
        [EVENT_ENDLESS_DUNGEON_SCORE_UPDATED] = "EVENT_ENDLESS_DUNGEON_SCORE_UPDATED",
        [EVENT_ENDLESS_DUNGEON_STARTED] = "EVENT_ENDLESS_DUNGEON_STARTED",
        [EVENT_ENLIGHTENED_STATE_GAINED] = "EVENT_ENLIGHTENED_STATE_GAINED",
        [EVENT_ENLIGHTENED_STATE_LOST] = "EVENT_ENLIGHTENED_STATE_LOST",
        [EVENT_ENTER_GROUND_TARGET_MODE] = "EVENT_ENTER_GROUND_TARGET_MODE",
        [EVENT_ESO_PLUS_FREE_TRIAL_NOTIFICATION_CLEARED] = "EVENT_ESO_PLUS_FREE_TRIAL_NOTIFICATION_CLEARED",
        [EVENT_ESO_PLUS_FREE_TRIAL_STATUS_CHANGED] = "EVENT_ESO_PLUS_FREE_TRIAL_STATUS_CHANGED",
        [EVENT_EVENT_TICKET_UPDATE] = "EVENT_EVENT_TICKET_UPDATE",
        [EVENT_EXPERIENCE_GAIN] = "EVENT_EXPERIENCE_GAIN",
        [EVENT_EXPERIENCE_UPDATE] = "EVENT_EXPERIENCE_UPDATE",
        [EVENT_EXPIRING_MARKET_CURRENCY_NOTIFICATION] = "EVENT_EXPIRING_MARKET_CURRENCY_NOTIFICATION",
        [EVENT_EXPIRING_MARKET_CURRENCY_NOTIFICATION_CLEARED] = "EVENT_EXPIRING_MARKET_CURRENCY_NOTIFICATION_CLEARED",
        [EVENT_EXPIRING_MARKET_CURRENCY_STATE_UPDATED] = "EVENT_EXPIRING_MARKET_CURRENCY_STATE_UPDATED",
        [EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED] = "EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED",
        [EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED] = "EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED",
        [EVENT_FAST_TRAVEL_NETWORK_UPDATED] = "EVENT_FAST_TRAVEL_NETWORK_UPDATED",
        [EVENT_FEEDBACK_REQUESTED] = "EVENT_FEEDBACK_REQUESTED",
        [EVENT_FEEDBACK_TOO_FREQUENT_SCREENSHOT] = "EVENT_FEEDBACK_TOO_FREQUENT_SCREENSHOT",
        [EVENT_FINESSE_RANK_CHANGED] = "EVENT_FINESSE_RANK_CHANGED",
        [EVENT_FISHING_LURE_CLEARED] = "EVENT_FISHING_LURE_CLEARED",
        [EVENT_FISHING_LURE_SET] = "EVENT_FISHING_LURE_SET",
        [EVENT_FIXED_BROADCAST] = "EVENT_FIXED_BROADCAST",
        [EVENT_FOLLOWER_SCENE_FINISHED_FRAGMENT_TRANSITION] = "EVENT_FOLLOWER_SCENE_FINISHED_FRAGMENT_TRANSITION",
        [EVENT_FORCE_DISABLED_ADDONS_UPDATED] = "EVENT_FORCE_DISABLED_ADDONS_UPDATED",
        [EVENT_FORCE_RESPEC] = "EVENT_FORCE_RESPEC",
        [EVENT_FORWARD_CAMP_RESPAWN_TIMER_BEGINS] = "EVENT_FORWARD_CAMP_RESPAWN_TIMER_BEGINS",
        [EVENT_FORWARD_CAMPS_UPDATED] = "EVENT_FORWARD_CAMPS_UPDATED",
        [EVENT_FORWARD_TRANSCRIPT_TO_TEXT_CHAT_ACCESSIBILITY_SETTING_CHANGED] = "EVENT_FORWARD_TRANSCRIPT_TO_TEXT_CHAT_ACCESSIBILITY_SETTING_CHANGED",
        [EVENT_FRIEND_ADDED] = "EVENT_FRIEND_ADDED",
        [EVENT_FRIEND_CHARACTER_CHAMPION_POINTS_CHANGED] = "EVENT_FRIEND_CHARACTER_CHAMPION_POINTS_CHANGED",
        [EVENT_FRIEND_CHARACTER_INFO_RECEIVED] = "EVENT_FRIEND_CHARACTER_INFO_RECEIVED",
        [EVENT_FRIEND_CHARACTER_LEVEL_CHANGED] = "EVENT_FRIEND_CHARACTER_LEVEL_CHANGED",
        [EVENT_FRIEND_CHARACTER_UPDATED] = "EVENT_FRIEND_CHARACTER_UPDATED",
        [EVENT_FRIEND_CHARACTER_VETERAN_RANK_CHANGED] = "EVENT_FRIEND_CHARACTER_VETERAN_RANK_CHANGED",
        [EVENT_FRIEND_CHARACTER_ZONE_CHANGED] = "EVENT_FRIEND_CHARACTER_ZONE_CHANGED",
        [EVENT_FRIEND_DISPLAY_NAME_CHANGED] = "EVENT_FRIEND_DISPLAY_NAME_CHANGED",
        [EVENT_FRIEND_NOTE_UPDATED] = "EVENT_FRIEND_NOTE_UPDATED",
        [EVENT_FRIEND_PLAYER_STATUS_CHANGED] = "EVENT_FRIEND_PLAYER_STATUS_CHANGED",
        [EVENT_FRIEND_REMOVED] = "EVENT_FRIEND_REMOVED",
        [EVENT_FULLSCREEN_MODE_CHANGED] = "EVENT_FULLSCREEN_MODE_CHANGED",
        [EVENT_FURNITURE_ITEMS_TRANSFERRED_TO_FURNITURE_VAULT] = "EVENT_FURNITURE_ITEMS_TRANSFERRED_TO_FURNITURE_VAULT",
        [EVENT_GAME_CAMERA_ACTIVATED] = "EVENT_GAME_CAMERA_ACTIVATED",
        [EVENT_GAME_CAMERA_CHARACTER_FRAMING_STARTED] = "EVENT_GAME_CAMERA_CHARACTER_FRAMING_STARTED",
        [EVENT_GAME_CAMERA_DEACTIVATED] = "EVENT_GAME_CAMERA_DEACTIVATED",
        [EVENT_GAME_CAMERA_UI_MODE_CHANGED] = "EVENT_GAME_CAMERA_UI_MODE_CHANGED",
        [EVENT_GAME_CREDITS_READY] = "EVENT_GAME_CREDITS_READY",
        [EVENT_GAME_FOCUS_CHANGED] = "EVENT_GAME_FOCUS_CHANGED",
        [EVENT_GAMEPAD_PREFERRED_MODE_CHANGED] = "EVENT_GAMEPAD_PREFERRED_MODE_CHANGED",
        [EVENT_GAMEPAD_TYPE_CHANGED] = "EVENT_GAMEPAD_TYPE_CHANGED",
        [EVENT_GAMEPAD_USE_KEYBOARD_CHAT_CHANGED] = "EVENT_GAMEPAD_USE_KEYBOARD_CHAT_CHANGED",
        [EVENT_GIFT_ACTION_RESULT] = "EVENT_GIFT_ACTION_RESULT",
        [EVENT_GIFTING_GRACE_PERIOD_STARTED] = "EVENT_GIFTING_GRACE_PERIOD_STARTED",
        [EVENT_GIFTING_UNLOCKED_STATUS_CHANGED] = "EVENT_GIFTING_UNLOCKED_STATUS_CHANGED",
        [EVENT_GIFTS_UPDATED] = "EVENT_GIFTS_UPDATED",
        [EVENT_GLOBAL_MOUSE_DOWN] = "EVENT_GLOBAL_MOUSE_DOWN",
        [EVENT_GLOBAL_MOUSE_UP] = "EVENT_GLOBAL_MOUSE_UP",
        [EVENT_GRAVEYARD_USAGE_FAILURE] = "EVENT_GRAVEYARD_USAGE_FAILURE",
        [EVENT_GROUP_ADD_ON_DATA_RECEIVED] = "EVENT_GROUP_ADD_ON_DATA_RECEIVED",
        [EVENT_GROUP_CAMPAIGN_ASSIGNMENTS_CHANGED] = "EVENT_GROUP_CAMPAIGN_ASSIGNMENTS_CHANGED",
        [EVENT_GROUP_ELECTION_FAILED] = "EVENT_GROUP_ELECTION_FAILED",
        [EVENT_GROUP_ELECTION_NOTIFICATION_ADDED] = "EVENT_GROUP_ELECTION_NOTIFICATION_ADDED",
        [EVENT_GROUP_ELECTION_NOTIFICATION_REMOVED] = "EVENT_GROUP_ELECTION_NOTIFICATION_REMOVED",
        [EVENT_GROUP_ELECTION_PROGRESS_UPDATED] = "EVENT_GROUP_ELECTION_PROGRESS_UPDATED",
        [EVENT_GROUP_ELECTION_REQUESTED] = "EVENT_GROUP_ELECTION_REQUESTED",
        [EVENT_GROUP_ELECTION_RESULT] = "EVENT_GROUP_ELECTION_RESULT",
        [EVENT_GROUP_FINDER_APPLICATION_RECEIVED] = "EVENT_GROUP_FINDER_APPLICATION_RECEIVED",
        [EVENT_GROUP_FINDER_APPLY_TO_GROUP_LISTING_RESULT] = "EVENT_GROUP_FINDER_APPLY_TO_GROUP_LISTING_RESULT",
        [EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT] = "EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT",
        [EVENT_GROUP_FINDER_GROUP_LISTING_ATTAINED_ROLES_CHANGED] = "EVENT_GROUP_FINDER_GROUP_LISTING_ATTAINED_ROLES_CHANGED",
        [EVENT_GROUP_FINDER_JOIN_GROUP_FAILED] = "EVENT_GROUP_FINDER_JOIN_GROUP_FAILED",
        [EVENT_GROUP_FINDER_LONG_SEARCH_WARNING] = "EVENT_GROUP_FINDER_LONG_SEARCH_WARNING",
        [EVENT_GROUP_FINDER_MAX_SEARCHABLE] = "EVENT_GROUP_FINDER_MAX_SEARCHABLE",
        [EVENT_GROUP_FINDER_MEMBER_ALERT] = "EVENT_GROUP_FINDER_MEMBER_ALERT",
        [EVENT_GROUP_FINDER_REFRESH_SEARCH] = "EVENT_GROUP_FINDER_REFRESH_SEARCH",
        [EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_APPLICATION] = "EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_APPLICATION",
        [EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_RESULT] = "EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_RESULT",
        [EVENT_GROUP_FINDER_RESOLVE_GROUP_LISTING_APPLICATION_RESULT] = "EVENT_GROUP_FINDER_RESOLVE_GROUP_LISTING_APPLICATION_RESULT",
        [EVENT_GROUP_FINDER_SEARCH_COMPLETE] = "EVENT_GROUP_FINDER_SEARCH_COMPLETE",
        [EVENT_GROUP_FINDER_SEARCH_COOLDOWN_UPDATE] = "EVENT_GROUP_FINDER_SEARCH_COOLDOWN_UPDATE",
        [EVENT_GROUP_FINDER_SEARCH_UPDATED] = "EVENT_GROUP_FINDER_SEARCH_UPDATED",
        [EVENT_GROUP_FINDER_STATUS_UPDATED] = "EVENT_GROUP_FINDER_STATUS_UPDATED",
        [EVENT_GROUP_FINDER_UPDATE_APPLICATIONS] = "EVENT_GROUP_FINDER_UPDATE_APPLICATIONS",
        [EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT] = "EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT",
        [EVENT_GROUP_INVITE_ACCEPT_RESPONSE_TIMEOUT] = "EVENT_GROUP_INVITE_ACCEPT_RESPONSE_TIMEOUT",
        [EVENT_GROUP_INVITE_RECEIVED] = "EVENT_GROUP_INVITE_RECEIVED",
        [EVENT_GROUP_INVITE_REMOVED] = "EVENT_GROUP_INVITE_REMOVED",
        [EVENT_GROUP_INVITE_RESPONSE] = "EVENT_GROUP_INVITE_RESPONSE",
        [EVENT_GROUP_LISTING_INFO_REQUEST_COMPLETE] = "EVENT_GROUP_LISTING_INFO_REQUEST_COMPLETE",
        [EVENT_GROUP_MEMBER_ACCOUNT_NAME_UPDATED] = "EVENT_GROUP_MEMBER_ACCOUNT_NAME_UPDATED",
        [EVENT_GROUP_MEMBER_CONNECTED_STATUS] = "EVENT_GROUP_MEMBER_CONNECTED_STATUS",
        [EVENT_GROUP_MEMBER_IN_REMOTE_REGION] = "EVENT_GROUP_MEMBER_IN_REMOTE_REGION",
        [EVENT_GROUP_MEMBER_JOINED] = "EVENT_GROUP_MEMBER_JOINED",
        [EVENT_GROUP_MEMBER_LEFT] = "EVENT_GROUP_MEMBER_LEFT",
        [EVENT_GROUP_MEMBER_POSITION_REQUEST_COMPLETE] = "EVENT_GROUP_MEMBER_POSITION_REQUEST_COMPLETE",
        [EVENT_GROUP_MEMBER_ROLE_CHANGED] = "EVENT_GROUP_MEMBER_ROLE_CHANGED",
        [EVENT_GROUP_MEMBER_SUBZONE_CHANGED] = "EVENT_GROUP_MEMBER_SUBZONE_CHANGED",
        [EVENT_GROUP_NOTIFICATION_MESSAGE] = "EVENT_GROUP_NOTIFICATION_MESSAGE",
        [EVENT_GROUP_OPERATION_RESULT] = "EVENT_GROUP_OPERATION_RESULT",
        [EVENT_GROUP_SUPPORT_RANGE_UPDATE] = "EVENT_GROUP_SUPPORT_RANGE_UPDATE",
        [EVENT_GROUP_TYPE_CHANGED] = "EVENT_GROUP_TYPE_CHANGED",
        [EVENT_GROUP_UPDATE] = "EVENT_GROUP_UPDATE",
        [EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED] = "EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED",
        [EVENT_GROUPING_TOOLS_FIND_REPLACEMENT_NOTIFICATION_NEW] = "EVENT_GROUPING_TOOLS_FIND_REPLACEMENT_NOTIFICATION_NEW",
        [EVENT_GROUPING_TOOLS_FIND_REPLACEMENT_NOTIFICATION_REMOVED] = "EVENT_GROUPING_TOOLS_FIND_REPLACEMENT_NOTIFICATION_REMOVED",
        [EVENT_GROUPING_TOOLS_LFG_JOINED] = "EVENT_GROUPING_TOOLS_LFG_JOINED",
        [EVENT_GROUPING_TOOLS_NO_LONGER_LFG] = "EVENT_GROUPING_TOOLS_NO_LONGER_LFG",
        [EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED] = "EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED",
        [EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED] = "EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED",
        [EVENT_GUI_HIDDEN] = "EVENT_GUI_HIDDEN",
        [EVENT_GUI_UNLOADING] = "EVENT_GUI_UNLOADING",
        [EVENT_GUI_WORLD_PARTICLE_EFFECT_READY] = "EVENT_GUI_WORLD_PARTICLE_EFFECT_READY",
        [EVENT_GUILD_BANK_DESELECTED] = "EVENT_GUILD_BANK_DESELECTED",
        [EVENT_GUILD_BANK_ITEM_ADDED] = "EVENT_GUILD_BANK_ITEM_ADDED",
        [EVENT_GUILD_BANK_ITEM_REMOVED] = "EVENT_GUILD_BANK_ITEM_REMOVED",
        [EVENT_GUILD_BANK_ITEMS_READY] = "EVENT_GUILD_BANK_ITEMS_READY",
        [EVENT_GUILD_BANK_OPEN_ERROR] = "EVENT_GUILD_BANK_OPEN_ERROR",
        [EVENT_GUILD_BANK_SELECTED] = "EVENT_GUILD_BANK_SELECTED",
        [EVENT_GUILD_BANK_TRANSFER_ERROR] = "EVENT_GUILD_BANK_TRANSFER_ERROR",
        [EVENT_GUILD_BANK_UPDATED_QUANTITY] = "EVENT_GUILD_BANK_UPDATED_QUANTITY",
        [EVENT_GUILD_BANKED_MONEY_UPDATE] = "EVENT_GUILD_BANKED_MONEY_UPDATE",
        [EVENT_GUILD_CLAIM_KEEP_CAMPAIGN_NOTIFICATION] = "EVENT_GUILD_CLAIM_KEEP_CAMPAIGN_NOTIFICATION",
        [EVENT_GUILD_CLAIM_KEEP_RESPONSE] = "EVENT_GUILD_CLAIM_KEEP_RESPONSE",
        [EVENT_GUILD_DATA_LOADED] = "EVENT_GUILD_DATA_LOADED",
        [EVENT_GUILD_DESCRIPTION_CHANGED] = "EVENT_GUILD_DESCRIPTION_CHANGED",
        [EVENT_GUILD_FINDER_APPLICATION_RESPONSE] = "EVENT_GUILD_FINDER_APPLICATION_RESPONSE",
        [EVENT_GUILD_FINDER_APPLICATION_RESULTS_GUILD] = "EVENT_GUILD_FINDER_APPLICATION_RESULTS_GUILD",
        [EVENT_GUILD_FINDER_APPLICATION_RESULTS_PLAYER] = "EVENT_GUILD_FINDER_APPLICATION_RESULTS_PLAYER",
        [EVENT_GUILD_FINDER_BLACKLIST_RESPONSE] = "EVENT_GUILD_FINDER_BLACKLIST_RESPONSE",
        [EVENT_GUILD_FINDER_BLACKLIST_RESULTS] = "EVENT_GUILD_FINDER_BLACKLIST_RESULTS",
        [EVENT_GUILD_FINDER_GUILD_APPLICATIONS_VIEWED] = "EVENT_GUILD_FINDER_GUILD_APPLICATIONS_VIEWED",
        [EVENT_GUILD_FINDER_GUILD_NEW_APPLICATIONS] = "EVENT_GUILD_FINDER_GUILD_NEW_APPLICATIONS",
        [EVENT_GUILD_FINDER_LONG_SEARCH_WARNING] = "EVENT_GUILD_FINDER_LONG_SEARCH_WARNING",
        [EVENT_GUILD_FINDER_PLAYER_APPLICATIONS_CHANGED] = "EVENT_GUILD_FINDER_PLAYER_APPLICATIONS_CHANGED",
        [EVENT_GUILD_FINDER_PROCESS_APPLICATION_RESPONSE] = "EVENT_GUILD_FINDER_PROCESS_APPLICATION_RESPONSE",
        [EVENT_GUILD_FINDER_SEARCH_COMPLETE] = "EVENT_GUILD_FINDER_SEARCH_COMPLETE",
        [EVENT_GUILD_FINDER_SEARCH_COOLDOWN_UPDATE] = "EVENT_GUILD_FINDER_SEARCH_COOLDOWN_UPDATE",
        [EVENT_GUILD_HISTORY_CATEGORY_UPDATED] = "EVENT_GUILD_HISTORY_CATEGORY_UPDATED",
        [EVENT_GUILD_HISTORY_REFRESHED] = "EVENT_GUILD_HISTORY_REFRESHED",
        [EVENT_GUILD_ID_CHANGED] = "EVENT_GUILD_ID_CHANGED",
        [EVENT_GUILD_INFO_REQUEST_COMPLETE] = "EVENT_GUILD_INFO_REQUEST_COMPLETE",
        [EVENT_GUILD_INVITE_ADDED] = "EVENT_GUILD_INVITE_ADDED",
        [EVENT_GUILD_INVITE_PLAYER_SUCCESSFUL] = "EVENT_GUILD_INVITE_PLAYER_SUCCESSFUL",
        [EVENT_GUILD_INVITE_REMOVED] = "EVENT_GUILD_INVITE_REMOVED",
        [EVENT_GUILD_INVITE_TO_BLACKLISTED_PLAYER] = "EVENT_GUILD_INVITE_TO_BLACKLISTED_PLAYER",
        [EVENT_GUILD_INVITES_INITIALIZED] = "EVENT_GUILD_INVITES_INITIALIZED",
        [EVENT_GUILD_KEEP_ATTACK_UPDATE] = "EVENT_GUILD_KEEP_ATTACK_UPDATE",
        [EVENT_GUILD_KEEP_CLAIM_UPDATED] = "EVENT_GUILD_KEEP_CLAIM_UPDATED",
        [EVENT_GUILD_KIOSK_ACTIVE_BIDS_RESPONSE] = "EVENT_GUILD_KIOSK_ACTIVE_BIDS_RESPONSE",
        [EVENT_GUILD_KIOSK_CONSIDER_BID_START] = "EVENT_GUILD_KIOSK_CONSIDER_BID_START",
        [EVENT_GUILD_KIOSK_CONSIDER_BID_STOP] = "EVENT_GUILD_KIOSK_CONSIDER_BID_STOP",
        [EVENT_GUILD_KIOSK_CONSIDER_PURCHASE_START] = "EVENT_GUILD_KIOSK_CONSIDER_PURCHASE_START",
        [EVENT_GUILD_KIOSK_CONSIDER_PURCHASE_STOP] = "EVENT_GUILD_KIOSK_CONSIDER_PURCHASE_STOP",
        [EVENT_GUILD_KIOSK_ERROR] = "EVENT_GUILD_KIOSK_ERROR",
        [EVENT_GUILD_KIOSK_RESULT] = "EVENT_GUILD_KIOSK_RESULT",
        [EVENT_GUILD_LEVEL_CHANGED] = "EVENT_GUILD_LEVEL_CHANGED",
        [EVENT_GUILD_LOST_KEEP_CAMPAIGN_NOTIFICATION] = "EVENT_GUILD_LOST_KEEP_CAMPAIGN_NOTIFICATION",
        [EVENT_GUILD_MEMBER_ADDED] = "EVENT_GUILD_MEMBER_ADDED",
        [EVENT_GUILD_MEMBER_CHARACTER_CHAMPION_POINTS_CHANGED] = "EVENT_GUILD_MEMBER_CHARACTER_CHAMPION_POINTS_CHANGED",
        [EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED] = "EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED",
        [EVENT_GUILD_MEMBER_CHARACTER_UPDATED] = "EVENT_GUILD_MEMBER_CHARACTER_UPDATED",
        [EVENT_GUILD_MEMBER_CHARACTER_VETERAN_RANK_CHANGED] = "EVENT_GUILD_MEMBER_CHARACTER_VETERAN_RANK_CHANGED",
        [EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED] = "EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED",
        [EVENT_GUILD_MEMBER_DEMOTE_SUCCESSFUL] = "EVENT_GUILD_MEMBER_DEMOTE_SUCCESSFUL",
        [EVENT_GUILD_MEMBER_NOTE_CHANGED] = "EVENT_GUILD_MEMBER_NOTE_CHANGED",
        [EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED] = "EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED",
        [EVENT_GUILD_MEMBER_PROMOTE_SUCCESSFUL] = "EVENT_GUILD_MEMBER_PROMOTE_SUCCESSFUL",
        [EVENT_GUILD_MEMBER_RANK_CHANGED] = "EVENT_GUILD_MEMBER_RANK_CHANGED",
        [EVENT_GUILD_MEMBER_REMOVED] = "EVENT_GUILD_MEMBER_REMOVED",
        [EVENT_GUILD_MOTD_CHANGED] = "EVENT_GUILD_MOTD_CHANGED",
        [EVENT_GUILD_NAME_AVAILABLE] = "EVENT_GUILD_NAME_AVAILABLE",
        [EVENT_GUILD_PLAYER_RANK_CHANGED] = "EVENT_GUILD_PLAYER_RANK_CHANGED",
        [EVENT_GUILD_RANK_CHANGED] = "EVENT_GUILD_RANK_CHANGED",
        [EVENT_GUILD_RANKS_CHANGED] = "EVENT_GUILD_RANKS_CHANGED",
        [EVENT_GUILD_RECRUITMENT_INFO_UPDATED] = "EVENT_GUILD_RECRUITMENT_INFO_UPDATED",
        [EVENT_GUILD_RELEASE_KEEP_CAMPAIGN_NOTIFICATION] = "EVENT_GUILD_RELEASE_KEEP_CAMPAIGN_NOTIFICATION",
        [EVENT_GUILD_RELEASE_KEEP_RESPONSE] = "EVENT_GUILD_RELEASE_KEEP_RESPONSE",
        [EVENT_GUILD_SELF_JOINED_GUILD] = "EVENT_GUILD_SELF_JOINED_GUILD",
        [EVENT_GUILD_SELF_LEFT_GUILD] = "EVENT_GUILD_SELF_LEFT_GUILD",
        [EVENT_GUILD_TRADER_HIRED_UPDATED] = "EVENT_GUILD_TRADER_HIRED_UPDATED",
        [EVENT_HELP_INITIALIZED] = "EVENT_HELP_INITIALIZED",
        [EVENT_HELP_SEARCH_RESULTS_READY] = "EVENT_HELP_SEARCH_RESULTS_READY",
        [EVENT_HELP_SHOW_SPECIFIC_PAGE] = "EVENT_HELP_SHOW_SPECIFIC_PAGE",
        [EVENT_HERALDRY_CUSTOMIZATION_END] = "EVENT_HERALDRY_CUSTOMIZATION_END",
        [EVENT_HERALDRY_CUSTOMIZATION_START] = "EVENT_HERALDRY_CUSTOMIZATION_START",
        [EVENT_HERALDRY_FUNDS_UPDATED] = "EVENT_HERALDRY_FUNDS_UPDATED",
        [EVENT_HERALDRY_SAVED] = "EVENT_HERALDRY_SAVED",
        [EVENT_HIDE_BOOK] = "EVENT_HIDE_BOOK",
        [EVENT_HIDE_OBJECTIVE_STATUS] = "EVENT_HIDE_OBJECTIVE_STATUS",
        [EVENT_HIGH_FALL_DAMAGE] = "EVENT_HIGH_FALL_DAMAGE",
        [EVENT_HOLIDAYS_CHANGED] = "EVENT_HOLIDAYS_CHANGED",
        [EVENT_HOT_BAR_RESULT] = "EVENT_HOT_BAR_RESULT",
        [EVENT_HOTBAR_SLOT_CHANGE_REQUESTED] = "EVENT_HOTBAR_SLOT_CHANGE_REQUESTED",
        [EVENT_HOTBAR_SLOT_STATE_UPDATED] = "EVENT_HOTBAR_SLOT_STATE_UPDATED",
        [EVENT_HOTBAR_SLOT_UPDATED] = "EVENT_HOTBAR_SLOT_UPDATED",
        [EVENT_HOUSE_FURNITURE_COUNT_UPDATED] = "EVENT_HOUSE_FURNITURE_COUNT_UPDATED",
        [EVENT_HOUSE_TOURS_CURRENT_HOUSE_LISTING_UPDATED] = "EVENT_HOUSE_TOURS_CURRENT_HOUSE_LISTING_UPDATED",
        [EVENT_HOUSE_TOURS_HOUSE_RECOMMENDATION_COUNT_UPDATED] = "EVENT_HOUSE_TOURS_HOUSE_RECOMMENDATION_COUNT_UPDATED",
        [EVENT_HOUSE_TOURS_LISTING_OPERATION_COOLDOWN_STATE_CHANGED] = "EVENT_HOUSE_TOURS_LISTING_OPERATION_COOLDOWN_STATE_CHANGED",
        [EVENT_HOUSE_TOURS_LISTING_OPERATION_RESPONSE] = "EVENT_HOUSE_TOURS_LISTING_OPERATION_RESPONSE",
        [EVENT_HOUSE_TOURS_LISTING_OPERATION_STARTED] = "EVENT_HOUSE_TOURS_LISTING_OPERATION_STARTED",
        [EVENT_HOUSE_TOURS_LISTING_RECOMMENDED_NOTIFICATIONS_UPDATED] = "EVENT_HOUSE_TOURS_LISTING_RECOMMENDED_NOTIFICATIONS_UPDATED",
        [EVENT_HOUSE_TOURS_SAVE_FAVORITE_OPERATION_COMPLETE] = "EVENT_HOUSE_TOURS_SAVE_FAVORITE_OPERATION_COMPLETE",
        [EVENT_HOUSE_TOURS_SAVE_RECOMMENDATION_OPERATION_COMPLETE] = "EVENT_HOUSE_TOURS_SAVE_RECOMMENDATION_OPERATION_COMPLETE",
        [EVENT_HOUSE_TOURS_SEARCH_COMPLETE] = "EVENT_HOUSE_TOURS_SEARCH_COMPLETE",
        [EVENT_HOUSE_TOURS_SEARCH_COOLDOWN_COMPLETE] = "EVENT_HOUSE_TOURS_SEARCH_COOLDOWN_COMPLETE",
        [EVENT_HOUSE_TOURS_STATUS_UPDATED] = "EVENT_HOUSE_TOURS_STATUS_UPDATED",
        [EVENT_HOUSING_ADD_PERMISSIONS_CANT_ADD_SELF] = "EVENT_HOUSING_ADD_PERMISSIONS_CANT_ADD_SELF",
        [EVENT_HOUSING_ADD_PERMISSIONS_FAILED] = "EVENT_HOUSING_ADD_PERMISSIONS_FAILED",
        [EVENT_HOUSING_EDITOR_COMMAND_RESULT] = "EVENT_HOUSING_EDITOR_COMMAND_RESULT",
        [EVENT_HOUSING_EDITOR_LINK_TARGET_CHANGED] = "EVENT_HOUSING_EDITOR_LINK_TARGET_CHANGED",
        [EVENT_HOUSING_EDITOR_MODE_CHANGED] = "EVENT_HOUSING_EDITOR_MODE_CHANGED",
        [EVENT_HOUSING_EDITOR_REQUEST_RESULT] = "EVENT_HOUSING_EDITOR_REQUEST_RESULT",
        [EVENT_HOUSING_FURNITURE_MOVED] = "EVENT_HOUSING_FURNITURE_MOVED",
        [EVENT_HOUSING_FURNITURE_PATH_DATA_CHANGED] = "EVENT_HOUSING_FURNITURE_PATH_DATA_CHANGED",
        [EVENT_HOUSING_FURNITURE_PATH_NODE_ADDED] = "EVENT_HOUSING_FURNITURE_PATH_NODE_ADDED",
        [EVENT_HOUSING_FURNITURE_PATH_NODE_MOVED] = "EVENT_HOUSING_FURNITURE_PATH_NODE_MOVED",
        [EVENT_HOUSING_FURNITURE_PATH_NODE_REMOVED] = "EVENT_HOUSING_FURNITURE_PATH_NODE_REMOVED",
        [EVENT_HOUSING_FURNITURE_PATH_NODES_RESTORED] = "EVENT_HOUSING_FURNITURE_PATH_NODES_RESTORED",
        [EVENT_HOUSING_FURNITURE_PATH_STARTING_NODE_INDEX_CHANGED] = "EVENT_HOUSING_FURNITURE_PATH_STARTING_NODE_INDEX_CHANGED",
        [EVENT_HOUSING_FURNITURE_PLACED] = "EVENT_HOUSING_FURNITURE_PLACED",
        [EVENT_HOUSING_FURNITURE_REMOVED] = "EVENT_HOUSING_FURNITURE_REMOVED",
        [EVENT_HOUSING_FURNITURE_RETRIEVE_TO_BAG_CHANGED] = "EVENT_HOUSING_FURNITURE_RETRIEVE_TO_BAG_CHANGED",
        [EVENT_HOUSING_FURNITURE_STATE_CHANGED] = "EVENT_HOUSING_FURNITURE_STATE_CHANGED",
        [EVENT_HOUSING_LOAD_PERMISSIONS_RESULT] = "EVENT_HOUSING_LOAD_PERMISSIONS_RESULT",
        [EVENT_HOUSING_OCCUPANT_ARRIVED] = "EVENT_HOUSING_OCCUPANT_ARRIVED",
        [EVENT_HOUSING_OCCUPANT_DEPARTED] = "EVENT_HOUSING_OCCUPANT_DEPARTED",
        [EVENT_HOUSING_PATH_NODE_SELECTION_CHANGED] = "EVENT_HOUSING_PATH_NODE_SELECTION_CHANGED",
        [EVENT_HOUSING_PERMISSIONS_CHANGED] = "EVENT_HOUSING_PERMISSIONS_CHANGED",
        [EVENT_HOUSING_PERMISSIONS_SAVE_COMPLETE] = "EVENT_HOUSING_PERMISSIONS_SAVE_COMPLETE",
        [EVENT_HOUSING_PERMISSIONS_SAVE_PENDING] = "EVENT_HOUSING_PERMISSIONS_SAVE_PENDING",
        [EVENT_HOUSING_PLAYER_INFO_CHANGED] = "EVENT_HOUSING_PLAYER_INFO_CHANGED",
        [EVENT_HOUSING_POPULATION_CHANGED] = "EVENT_HOUSING_POPULATION_CHANGED",
        [EVENT_HOUSING_PREVIEW_INSPECTION_STATE_CHANGED] = "EVENT_HOUSING_PREVIEW_INSPECTION_STATE_CHANGED",
        [EVENT_HOUSING_PRIMARY_RESIDENCE_SET] = "EVENT_HOUSING_PRIMARY_RESIDENCE_SET",
        [EVENT_HOUSING_TARGET_FURNITURE_CHANGED] = "EVENT_HOUSING_TARGET_FURNITURE_CHANGED",
        [EVENT_IGNORE_ADDED] = "EVENT_IGNORE_ADDED",
        [EVENT_IGNORE_NOTE_UPDATED] = "EVENT_IGNORE_NOTE_UPDATED",
        [EVENT_IGNORE_ONLINE_CHARACTER_CHANGED] = "EVENT_IGNORE_ONLINE_CHARACTER_CHANGED",
        [EVENT_IGNORE_REMOVED] = "EVENT_IGNORE_REMOVED",
        [EVENT_IMPACTFUL_HIT] = "EVENT_IMPACTFUL_HIT",
        [EVENT_INCOMING_FRIEND_INVITE_ADDED] = "EVENT_INCOMING_FRIEND_INVITE_ADDED",
        [EVENT_INCOMING_FRIEND_INVITE_NOTE_UPDATED] = "EVENT_INCOMING_FRIEND_INVITE_NOTE_UPDATED",
        [EVENT_INCOMING_FRIEND_INVITE_REMOVED] = "EVENT_INCOMING_FRIEND_INVITE_REMOVED",
        [EVENT_INPUT_LANGUAGE_CHANGED] = "EVENT_INPUT_LANGUAGE_CHANGED",
        [EVENT_INPUT_TYPE_CHANGED] = "EVENT_INPUT_TYPE_CHANGED",
        [EVENT_INSTANCE_KICK_TIME_UPDATE] = "EVENT_INSTANCE_KICK_TIME_UPDATE",
        [EVENT_INTERACT_BUSY] = "EVENT_INTERACT_BUSY",
        [EVENT_INTERACTION_ENDED] = "EVENT_INTERACTION_ENDED",
        [EVENT_INTERFACE_SETTING_CHANGED] = "EVENT_INTERFACE_SETTING_CHANGED",
        [EVENT_INVENTORY_BAG_CAPACITY_CHANGED] = "EVENT_INVENTORY_BAG_CAPACITY_CHANGED",
        [EVENT_INVENTORY_BANK_CAPACITY_CHANGED] = "EVENT_INVENTORY_BANK_CAPACITY_CHANGED",
        [EVENT_INVENTORY_BOUGHT_BAG_SPACE] = "EVENT_INVENTORY_BOUGHT_BAG_SPACE",
        [EVENT_INVENTORY_BOUGHT_BANK_SPACE] = "EVENT_INVENTORY_BOUGHT_BANK_SPACE",
        [EVENT_INVENTORY_BUY_BAG_SPACE] = "EVENT_INVENTORY_BUY_BAG_SPACE",
        [EVENT_INVENTORY_BUY_BANK_SPACE] = "EVENT_INVENTORY_BUY_BANK_SPACE",
        [EVENT_INVENTORY_CLOSE_BUY_SPACE] = "EVENT_INVENTORY_CLOSE_BUY_SPACE",
        [EVENT_INVENTORY_EQUIP_MYTHIC_FAILED] = "EVENT_INVENTORY_EQUIP_MYTHIC_FAILED",
        [EVENT_INVENTORY_FULL_UPDATE] = "EVENT_INVENTORY_FULL_UPDATE",
        [EVENT_INVENTORY_IS_FULL] = "EVENT_INVENTORY_IS_FULL",
        [EVENT_INVENTORY_ITEM_DESTROYED] = "EVENT_INVENTORY_ITEM_DESTROYED",
        [EVENT_INVENTORY_ITEM_USED] = "EVENT_INVENTORY_ITEM_USED",
        [EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG] = "EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG",
        [EVENT_INVENTORY_SINGLE_SLOT_UPDATE] = "EVENT_INVENTORY_SINGLE_SLOT_UPDATE",
        [EVENT_INVENTORY_SLOT_LOCKED] = "EVENT_INVENTORY_SLOT_LOCKED",
        [EVENT_INVENTORY_SLOT_UNLOCKED] = "EVENT_INVENTORY_SLOT_UNLOCKED",
        [EVENT_ITEM_COMBINATION_RESULT] = "EVENT_ITEM_COMBINATION_RESULT",
        [EVENT_ITEM_LAUNDER_RESULT] = "EVENT_ITEM_LAUNDER_RESULT",
        [EVENT_ITEM_ON_COOLDOWN] = "EVENT_ITEM_ON_COOLDOWN",
        [EVENT_ITEM_PREVIEW_READY] = "EVENT_ITEM_PREVIEW_READY",
        [EVENT_ITEM_REPAIR_FAILURE] = "EVENT_ITEM_REPAIR_FAILURE",
        [EVENT_ITEM_SET_COLLECTION_SLOT_NEW_STATUS_CLEARED] = "EVENT_ITEM_SET_COLLECTION_SLOT_NEW_STATUS_CLEARED",
        [EVENT_ITEM_SET_COLLECTION_UPDATED] = "EVENT_ITEM_SET_COLLECTION_UPDATED",
        [EVENT_ITEM_SET_COLLECTIONS_SEARCH_RESULTS_READY] = "EVENT_ITEM_SET_COLLECTIONS_SEARCH_RESULTS_READY",
        [EVENT_ITEM_SET_COLLECTIONS_UPDATED] = "EVENT_ITEM_SET_COLLECTIONS_UPDATED",
        [EVENT_ITEM_SLOT_CHANGED] = "EVENT_ITEM_SLOT_CHANGED",
        [EVENT_JUMP_FAILED] = "EVENT_JUMP_FAILED",
        [EVENT_JUSTICE_BEING_ARRESTED] = "EVENT_JUSTICE_BEING_ARRESTED",
        [EVENT_JUSTICE_BOUNTY_PAYOFF_AMOUNT_UPDATED] = "EVENT_JUSTICE_BOUNTY_PAYOFF_AMOUNT_UPDATED",
        [EVENT_JUSTICE_FENCE_UPDATE] = "EVENT_JUSTICE_FENCE_UPDATE",
        [EVENT_JUSTICE_GOLD_PICKPOCKETED] = "EVENT_JUSTICE_GOLD_PICKPOCKETED",
        [EVENT_JUSTICE_GOLD_REMOVED] = "EVENT_JUSTICE_GOLD_REMOVED",
        [EVENT_JUSTICE_INFAMY_UPDATED] = "EVENT_JUSTICE_INFAMY_UPDATED",
        [EVENT_JUSTICE_NO_LONGER_KOS] = "EVENT_JUSTICE_NO_LONGER_KOS",
        [EVENT_JUSTICE_NOW_KOS] = "EVENT_JUSTICE_NOW_KOS",
        [EVENT_JUSTICE_PICKPOCKET_FAILED] = "EVENT_JUSTICE_PICKPOCKET_FAILED",
        [EVENT_JUSTICE_STOLEN_ITEMS_REMOVED] = "EVENT_JUSTICE_STOLEN_ITEMS_REMOVED",
        [EVENT_KEEP_ALLIANCE_OWNER_CHANGED] = "EVENT_KEEP_ALLIANCE_OWNER_CHANGED",
        [EVENT_KEEP_END_INTERACTION] = "EVENT_KEEP_END_INTERACTION",
        [EVENT_KEEP_GATE_STATE_CHANGED] = "EVENT_KEEP_GATE_STATE_CHANGED",
        [EVENT_KEEP_GUILD_CLAIM_UPDATE] = "EVENT_KEEP_GUILD_CLAIM_UPDATE",
        [EVENT_KEEP_INITIALIZED] = "EVENT_KEEP_INITIALIZED",
        [EVENT_KEEP_IS_PASSABLE_CHANGED] = "EVENT_KEEP_IS_PASSABLE_CHANGED",
        [EVENT_KEEP_PIECE_DIRECTIONAL_ACCESS_CHANGED] = "EVENT_KEEP_PIECE_DIRECTIONAL_ACCESS_CHANGED",
        [EVENT_KEEP_RESOURCE_UPDATE] = "EVENT_KEEP_RESOURCE_UPDATE",
        [EVENT_KEEP_START_INTERACTION] = "EVENT_KEEP_START_INTERACTION",
        [EVENT_KEEP_UNDER_ATTACK_CHANGED] = "EVENT_KEEP_UNDER_ATTACK_CHANGED",
        [EVENT_KEEPS_INITIALIZED] = "EVENT_KEEPS_INITIALIZED",
        [EVENT_KEYBIND_DISPLAY_MODE_CHANGED] = "EVENT_KEYBIND_DISPLAY_MODE_CHANGED",
        [EVENT_KEYBINDING_CLEARED] = "EVENT_KEYBINDING_CLEARED",
        [EVENT_KEYBINDING_SET] = "EVENT_KEYBINDING_SET",
        [EVENT_KEYBINDINGS_LOADED] = "EVENT_KEYBINDINGS_LOADED",
        [EVENT_KILL_LOCATIONS_UPDATED] = "EVENT_KILL_LOCATIONS_UPDATED",
        [EVENT_LEADER_TO_FOLLOWER_SYNC] = "EVENT_LEADER_TO_FOLLOWER_SYNC",
        [EVENT_LEADER_UPDATE] = "EVENT_LEADER_UPDATE",
        [EVENT_LEADERBOARD_SCORE_NOTIFICATION_ADDED] = "EVENT_LEADERBOARD_SCORE_NOTIFICATION_ADDED",
        [EVENT_LEADERBOARD_SCORE_NOTIFICATION_REMOVED] = "EVENT_LEADERBOARD_SCORE_NOTIFICATION_REMOVED",
        [EVENT_LEAVE_CAMPAIGN_QUEUE_RESPONSE] = "EVENT_LEAVE_CAMPAIGN_QUEUE_RESPONSE",
        [EVENT_LEAVE_RAM_ESCORT] = "EVENT_LEAVE_RAM_ESCORT",
        [EVENT_LEVEL_UP_REWARD_CHOICE_UPDATED] = "EVENT_LEVEL_UP_REWARD_CHOICE_UPDATED",
        [EVENT_LEVEL_UP_REWARD_UPDATED] = "EVENT_LEVEL_UP_REWARD_UPDATED",
        [EVENT_LEVEL_UPDATE] = "EVENT_LEVEL_UPDATE",
        [EVENT_LINKED_WORLD_POSITION_CHANGED] = "EVENT_LINKED_WORLD_POSITION_CHANGED",
        [EVENT_LOCAL_PLAYER_MODEL_REBUILT] = "EVENT_LOCAL_PLAYER_MODEL_REBUILT",
        [EVENT_LOCKPICK_BREAK_PREVENTED] = "EVENT_LOCKPICK_BREAK_PREVENTED",
        [EVENT_LOCKPICK_BROKE] = "EVENT_LOCKPICK_BROKE",
        [EVENT_LOCKPICK_FAILED] = "EVENT_LOCKPICK_FAILED",
        [EVENT_LOCKPICK_SUCCESS] = "EVENT_LOCKPICK_SUCCESS",
        [EVENT_LOGOUT_DEFERRED] = "EVENT_LOGOUT_DEFERRED",
        [EVENT_LOGOUT_DISALLOWED] = "EVENT_LOGOUT_DISALLOWED",
        [EVENT_LOOT_CLOSED] = "EVENT_LOOT_CLOSED",
        [EVENT_LOOT_ITEM_FAILED] = "EVENT_LOOT_ITEM_FAILED",
        [EVENT_LOOT_RECEIVED] = "EVENT_LOOT_RECEIVED",
        [EVENT_LOOT_UPDATED] = "EVENT_LOOT_UPDATED",
        [EVENT_LORE_BOOK_ALREADY_KNOWN] = "EVENT_LORE_BOOK_ALREADY_KNOWN",
        [EVENT_LORE_BOOK_LEARNED] = "EVENT_LORE_BOOK_LEARNED",
        [EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE] = "EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE",
        [EVENT_LORE_COLLECTION_COMPLETED] = "EVENT_LORE_COLLECTION_COMPLETED",
        [EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE] = "EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE",
        [EVENT_LORE_LIBRARY_INITIALIZED] = "EVENT_LORE_LIBRARY_INITIALIZED",
        [EVENT_LOW_FALL_DAMAGE] = "EVENT_LOW_FALL_DAMAGE",
        [EVENT_LUA_ERROR] = "EVENT_LUA_ERROR",
        [EVENT_MAIL_ATTACHED_MONEY_CHANGED] = "EVENT_MAIL_ATTACHED_MONEY_CHANGED",
        [EVENT_MAIL_ATTACHMENT_ADDED] = "EVENT_MAIL_ATTACHMENT_ADDED",
        [EVENT_MAIL_ATTACHMENT_REMOVED] = "EVENT_MAIL_ATTACHMENT_REMOVED",
        [EVENT_MAIL_CLOSE_MAILBOX] = "EVENT_MAIL_CLOSE_MAILBOX",
        [EVENT_MAIL_COD_CHANGED] = "EVENT_MAIL_COD_CHANGED",
        [EVENT_MAIL_INBOX_UPDATE] = "EVENT_MAIL_INBOX_UPDATE",
        [EVENT_MAIL_NUM_UNREAD_CHANGED] = "EVENT_MAIL_NUM_UNREAD_CHANGED",
        [EVENT_MAIL_OPEN_MAILBOX] = "EVENT_MAIL_OPEN_MAILBOX",
        [EVENT_MAIL_READABLE] = "EVENT_MAIL_READABLE",
        [EVENT_MAIL_REMOVED] = "EVENT_MAIL_REMOVED",
        [EVENT_MAIL_SEND_FAILED] = "EVENT_MAIL_SEND_FAILED",
        [EVENT_MAIL_SEND_SUCCESS] = "EVENT_MAIL_SEND_SUCCESS",
        [EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE] = "EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE",
        [EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS] = "EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS",
        [EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS] = "EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS",
        [EVENT_MAIL_WITH_ATTACHMENTS_AVAILABLE] = "EVENT_MAIL_WITH_ATTACHMENTS_AVAILABLE",
        [EVENT_MAP_PING] = "EVENT_MAP_PING",
        [EVENT_MARKET_ANNOUNCEMENT_UPDATED] = "EVENT_MARKET_ANNOUNCEMENT_UPDATED",
        [EVENT_MARKET_PRODUCT_AVAILABILITY_UPDATED] = "EVENT_MARKET_PRODUCT_AVAILABILITY_UPDATED",
        [EVENT_MARKET_PRODUCTS_UNLOCKED] = "EVENT_MARKET_PRODUCTS_UNLOCKED",
        [EVENT_MARKET_PRODUCTS_UNLOCKED_NOTIFICATIONS_CLEARED] = "EVENT_MARKET_PRODUCTS_UNLOCKED_NOTIFICATIONS_CLEARED",
        [EVENT_MARKET_PURCHASE_RESULT] = "EVENT_MARKET_PURCHASE_RESULT",
        [EVENT_MARKET_STATE_UPDATED] = "EVENT_MARKET_STATE_UPDATED",
        [EVENT_MATCH_TRADING_HOUSE_ITEM_NAMES_COMPLETE] = "EVENT_MATCH_TRADING_HOUSE_ITEM_NAMES_COMPLETE",
        [EVENT_MAX_CHARACTER_SLOTS_CHANGED] = "EVENT_MAX_CHARACTER_SLOTS_CHANGED",
        [EVENT_MEDAL_AWARDED] = "EVENT_MEDAL_AWARDED",
        [EVENT_MOD_BROWSER_SEARCH_COMPLETE] = "EVENT_MOD_BROWSER_SEARCH_COMPLETE",
        [EVENT_MOD_INSTALL_STATE_CHANGED] = "EVENT_MOD_INSTALL_STATE_CHANGED",
        [EVENT_MOD_LISTING_DEPENDENCIES_LOAD_COMPLETE] = "EVENT_MOD_LISTING_DEPENDENCIES_LOAD_COMPLETE",
        [EVENT_MOD_LISTING_IMAGE_LOAD_COMPLETE] = "EVENT_MOD_LISTING_IMAGE_LOAD_COMPLETE",
        [EVENT_MOD_LISTING_RELEASE_NOTE_LOAD_COMPLETE] = "EVENT_MOD_LISTING_RELEASE_NOTE_LOAD_COMPLETE",
        [EVENT_MOD_LISTING_REPORT_SUBMITTED] = "EVENT_MOD_LISTING_REPORT_SUBMITTED",
        [EVENT_MONEY_UPDATE] = "EVENT_MONEY_UPDATE",
        [EVENT_MOST_RECENT_GAMEPAD_TYPE_CHANGED] = "EVENT_MOST_RECENT_GAMEPAD_TYPE_CHANGED",
        [EVENT_MOUNT_FAILURE] = "EVENT_MOUNT_FAILURE",
        [EVENT_MOUNT_INFO_UPDATED] = "EVENT_MOUNT_INFO_UPDATED",
        [EVENT_MOUNTED_STATE_CHANGED] = "EVENT_MOUNTED_STATE_CHANGED",
        [EVENT_MOUSE_REQUEST_ABANDON_QUEST] = "EVENT_MOUSE_REQUEST_ABANDON_QUEST",
        [EVENT_MOUSE_REQUEST_DESTROY_ITEM] = "EVENT_MOUSE_REQUEST_DESTROY_ITEM",
        [EVENT_MOUSE_REQUEST_DESTROY_ITEM_FAILED] = "EVENT_MOUSE_REQUEST_DESTROY_ITEM_FAILED",
        [EVENT_MULTIPLE_RECIPES_LEARNED] = "EVENT_MULTIPLE_RECIPES_LEARNED",
        [EVENT_MURDERBALL_STATE_CHANGED] = "EVENT_MURDERBALL_STATE_CHANGED",
        [EVENT_NEW_DAILY_LOGIN_REWARD_AVAILABLE] = "EVENT_NEW_DAILY_LOGIN_REWARD_AVAILABLE",
        [EVENT_NEW_HIRELING_CORRESPONDENCE_RECEIVED] = "EVENT_NEW_HIRELING_CORRESPONDENCE_RECEIVED",
        [EVENT_NEW_MOVEMENT_IN_UI_MODE] = "EVENT_NEW_MOVEMENT_IN_UI_MODE",
        [EVENT_NO_DAEDRIC_PICKUP_AS_EMPEROR] = "EVENT_NO_DAEDRIC_PICKUP_AS_EMPEROR",
        [EVENT_NO_DAEDRIC_PICKUP_WHEN_STEALTHED] = "EVENT_NO_DAEDRIC_PICKUP_WHEN_STEALTHED",
        [EVENT_NO_INTERACT_TARGET] = "EVENT_NO_INTERACT_TARGET",
        [EVENT_NON_COMBAT_BONUS_CHANGED] = "EVENT_NON_COMBAT_BONUS_CHANGED",
        [EVENT_NOT_ENOUGH_MONEY] = "EVENT_NOT_ENOUGH_MONEY",
        [EVENT_OBJECTIVE_COMPLETED] = "EVENT_OBJECTIVE_COMPLETED",
        [EVENT_OBJECTIVE_CONTROL_STATE] = "EVENT_OBJECTIVE_CONTROL_STATE",
        [EVENT_OBJECTIVES_UPDATED] = "EVENT_OBJECTIVES_UPDATED",
        [EVENT_OPEN_ARMORY_MENU] = "EVENT_OPEN_ARMORY_MENU",
        [EVENT_OPEN_BANK] = "EVENT_OPEN_BANK",
        [EVENT_OPEN_COMPANION_MENU] = "EVENT_OPEN_COMPANION_MENU",
        [EVENT_OPEN_FENCE] = "EVENT_OPEN_FENCE",
        [EVENT_OPEN_GUILD_BANK] = "EVENT_OPEN_GUILD_BANK",
        [EVENT_OPEN_HOUSE_STORE] = "EVENT_OPEN_HOUSE_STORE",
        [EVENT_OPEN_STORE] = "EVENT_OPEN_STORE",
        [EVENT_OPEN_TIMED_ACTIVITIES] = "EVENT_OPEN_TIMED_ACTIVITIES",
        [EVENT_OPEN_TRADING_HOUSE] = "EVENT_OPEN_TRADING_HOUSE",
        [EVENT_OPEN_UI_SYSTEM] = "EVENT_OPEN_UI_SYSTEM",
        [EVENT_OUTFIT_CHANGE_RESPONSE] = "EVENT_OUTFIT_CHANGE_RESPONSE",
        [EVENT_OUTFIT_EQUIP_RESPONSE] = "EVENT_OUTFIT_EQUIP_RESPONSE",
        [EVENT_OUTFIT_RENAME_RESPONSE] = "EVENT_OUTFIT_RENAME_RESPONSE",
        [EVENT_OUTFITS_INITIALIZED] = "EVENT_OUTFITS_INITIALIZED",
        [EVENT_OUTGOING_FRIEND_INVITE_ADDED] = "EVENT_OUTGOING_FRIEND_INVITE_ADDED",
        [EVENT_OUTGOING_FRIEND_INVITE_REMOVED] = "EVENT_OUTGOING_FRIEND_INVITE_REMOVED",
        [EVENT_PATH_FINDING_NETWORK_LINK_CHANGED] = "EVENT_PATH_FINDING_NETWORK_LINK_CHANGED",
        [EVENT_PENDING_CURRENCY_REWARD_CACHED] = "EVENT_PENDING_CURRENCY_REWARD_CACHED",
        [EVENT_PENDING_EXPERIENCE_REWARD_CACHED] = "EVENT_PENDING_EXPERIENCE_REWARD_CACHED",
        [EVENT_PENDING_INTERACTION_CANCELLED] = "EVENT_PENDING_INTERACTION_CANCELLED",
        [EVENT_PERSONALITY_CHANGED] = "EVENT_PERSONALITY_CHANGED",
        [EVENT_PICKPOCKET_STATE_UPDATED] = "EVENT_PICKPOCKET_STATE_UPDATED",
        [EVENT_PLATFORM_ACHIEVEMENT_TRIGGERED] = "EVENT_PLATFORM_ACHIEVEMENT_TRIGGERED",
        [EVENT_PLATFORM_STORE_DIALOG_FINISHED] = "EVENT_PLATFORM_STORE_DIALOG_FINISHED",
        [EVENT_PLATFORMS_LIST_LOADED] = "EVENT_PLATFORMS_LIST_LOADED",
        [EVENT_PLAYER_ACTIVATED] = "EVENT_PLAYER_ACTIVATED",
        [EVENT_PLAYER_ACTIVELY_ENGAGED_STATE] = "EVENT_PLAYER_ACTIVELY_ENGAGED_STATE",
        [EVENT_PLAYER_ALIVE] = "EVENT_PLAYER_ALIVE",
        [EVENT_PLAYER_COMBAT_STATE] = "EVENT_PLAYER_COMBAT_STATE",
        [EVENT_PLAYER_DEACTIVATED] = "EVENT_PLAYER_DEACTIVATED",
        [EVENT_PLAYER_DEAD] = "EVENT_PLAYER_DEAD",
        [EVENT_PLAYER_DEATH_INFO_UPDATE] = "EVENT_PLAYER_DEATH_INFO_UPDATE",
        [EVENT_PLAYER_DEATH_REQUEST_FAILURE] = "EVENT_PLAYER_DEATH_REQUEST_FAILURE",
        [EVENT_PLAYER_EMOTE_FAILED_PLAY] = "EVENT_PLAYER_EMOTE_FAILED_PLAY",
        [EVENT_PLAYER_IN_PIN_AREA_CHANGED] = "EVENT_PLAYER_IN_PIN_AREA_CHANGED",
        [EVENT_PLAYER_NOT_SWIMMING] = "EVENT_PLAYER_NOT_SWIMMING",
        [EVENT_PLAYER_QUEUED_FOR_CYCLIC_RESPAWN] = "EVENT_PLAYER_QUEUED_FOR_CYCLIC_RESPAWN",
        [EVENT_PLAYER_REINCARNATED] = "EVENT_PLAYER_REINCARNATED",
        [EVENT_PLAYER_STATUS_CHANGED] = "EVENT_PLAYER_STATUS_CHANGED",
        [EVENT_PLAYER_STUNNED_STATE_CHANGED] = "EVENT_PLAYER_STUNNED_STATE_CHANGED",
        [EVENT_PLAYER_SWIMMING] = "EVENT_PLAYER_SWIMMING",
        [EVENT_PLAYER_TELEPORTED_LOCALLY] = "EVENT_PLAYER_TELEPORTED_LOCALLY",
        [EVENT_PLAYER_TITLES_UPDATE] = "EVENT_PLAYER_TITLES_UPDATE",
        [EVENT_PLEDGE_OF_MARA_OFFER] = "EVENT_PLEDGE_OF_MARA_OFFER",
        [EVENT_PLEDGE_OF_MARA_OFFER_REMOVED] = "EVENT_PLEDGE_OF_MARA_OFFER_REMOVED",
        [EVENT_PLEDGE_OF_MARA_RESULT] = "EVENT_PLEDGE_OF_MARA_RESULT",
        [EVENT_POI_DISCOVERED] = "EVENT_POI_DISCOVERED",
        [EVENT_POI_UPDATED] = "EVENT_POI_UPDATED",
        [EVENT_POIS_INITIALIZED] = "EVENT_POIS_INITIALIZED",
        [EVENT_POWER_UPDATE] = "EVENT_POWER_UPDATE",
        [EVENT_PREPARE_FOR_JUMP] = "EVENT_PREPARE_FOR_JUMP",
        [EVENT_PREVIEW_COLLECTIBLE_ACTION_RESET] = "EVENT_PREVIEW_COLLECTIBLE_ACTION_RESET",
        [EVENT_PROFILE_CARD_DIALOG_CLOSED] = "EVENT_PROFILE_CARD_DIALOG_CLOSED",
        [EVENT_PROFILE_CARD_DIALOG_OPENED] = "EVENT_PROFILE_CARD_DIALOG_OPENED",
        [EVENT_PROFILE_DURANGO_SIGNED_OUT] = "EVENT_PROFILE_DURANGO_SIGNED_OUT",
        [EVENT_PROFILE_LOGIN_REQUESTED] = "EVENT_PROFILE_LOGIN_REQUESTED",
        [EVENT_PROFILE_LOGIN_RESULT] = "EVENT_PROFILE_LOGIN_RESULT",
        [EVENT_PROFILE_ORBIS_SIGNED_OUT] = "EVENT_PROFILE_ORBIS_SIGNED_OUT",
        [EVENT_PROFILE_SAVELOAD_FAIL] = "EVENT_PROFILE_SAVELOAD_FAIL",
        [EVENT_PROFILE_SAVELOAD_REQUESTED] = "EVENT_PROFILE_SAVELOAD_REQUESTED",
        [EVENT_PROFILE_SAVELOAD_SUCCESSFUL] = "EVENT_PROFILE_SAVELOAD_SUCCESSFUL",
        [EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED] = "EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED",
        [EVENT_PROMOTIONAL_EVENTS_ACTIVITY_TRACKING_UPDATED] = "EVENT_PROMOTIONAL_EVENTS_ACTIVITY_TRACKING_UPDATED",
        [EVENT_PROMOTIONAL_EVENTS_CAMPAIGNS_UPDATED] = "EVENT_PROMOTIONAL_EVENTS_CAMPAIGNS_UPDATED",
        [EVENT_PROMOTIONAL_EVENTS_REWARDS_CLAIMED] = "EVENT_PROMOTIONAL_EVENTS_REWARDS_CLAIMED",
        [EVENT_PVP_KILL_FEED_DEATH] = "EVENT_PVP_KILL_FEED_DEATH",
        [EVENT_QUEST_ADDED] = "EVENT_QUEST_ADDED",
        [EVENT_QUEST_ADVANCED] = "EVENT_QUEST_ADVANCED",
        [EVENT_QUEST_COMPLETE] = "EVENT_QUEST_COMPLETE",
        [EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL] = "EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL",
        [EVENT_QUEST_COMPLETE_DIALOG] = "EVENT_QUEST_COMPLETE_DIALOG",
        [EVENT_QUEST_CONDITION_COUNTER_CHANGED] = "EVENT_QUEST_CONDITION_COUNTER_CHANGED",
        [EVENT_QUEST_CONDITION_OVERRIDE_TEXT_CHANGED] = "EVENT_QUEST_CONDITION_OVERRIDE_TEXT_CHANGED",
        [EVENT_QUEST_LIST_UPDATED] = "EVENT_QUEST_LIST_UPDATED",
        [EVENT_QUEST_LOG_IS_FULL] = "EVENT_QUEST_LOG_IS_FULL",
        [EVENT_QUEST_OFFERED] = "EVENT_QUEST_OFFERED",
        [EVENT_QUEST_OPTIONAL_STEP_ADVANCED] = "EVENT_QUEST_OPTIONAL_STEP_ADVANCED",
        [EVENT_QUEST_POSITION_REQUEST_COMPLETE] = "EVENT_QUEST_POSITION_REQUEST_COMPLETE",
        [EVENT_QUEST_REMOVED] = "EVENT_QUEST_REMOVED",
        [EVENT_QUEST_SHARE_REMOVED] = "EVENT_QUEST_SHARE_REMOVED",
        [EVENT_QUEST_SHARE_RESULT] = "EVENT_QUEST_SHARE_RESULT",
        [EVENT_QUEST_SHARED] = "EVENT_QUEST_SHARED",
        [EVENT_QUEST_SHOW_JOURNAL_ENTRY] = "EVENT_QUEST_SHOW_JOURNAL_ENTRY",
        [EVENT_QUEST_TIMER_PAUSED] = "EVENT_QUEST_TIMER_PAUSED",
        [EVENT_QUEST_TIMER_UPDATED] = "EVENT_QUEST_TIMER_UPDATED",
        [EVENT_QUEST_TOOL_UPDATED] = "EVENT_QUEST_TOOL_UPDATED",
        [EVENT_QUEUE_FOR_CAMPAIGN_RESPONSE] = "EVENT_QUEUE_FOR_CAMPAIGN_RESPONSE",
        [EVENT_RAID_LEADERBOARD_DATA_RECEIVED] = "EVENT_RAID_LEADERBOARD_DATA_RECEIVED",
        [EVENT_RAID_LEADERBOARD_PLAYER_DATA_CHANGED] = "EVENT_RAID_LEADERBOARD_PLAYER_DATA_CHANGED",
        [EVENT_RAID_OF_THE_WEEK_INFO_RECEIVED] = "EVENT_RAID_OF_THE_WEEK_INFO_RECEIVED",
        [EVENT_RAID_OF_THE_WEEK_TURNOVER] = "EVENT_RAID_OF_THE_WEEK_TURNOVER",
        [EVENT_RAID_PARTICIPATION_UPDATE] = "EVENT_RAID_PARTICIPATION_UPDATE",
        [EVENT_RAID_REVIVE_COUNTER_UPDATE] = "EVENT_RAID_REVIVE_COUNTER_UPDATE",
        [EVENT_RAID_TIMER_STATE_UPDATE] = "EVENT_RAID_TIMER_STATE_UPDATE",
        [EVENT_RAID_TRIAL_COMPLETE] = "EVENT_RAID_TRIAL_COMPLETE",
        [EVENT_RAID_TRIAL_FAILED] = "EVENT_RAID_TRIAL_FAILED",
        [EVENT_RAID_TRIAL_NEW_BEST_SCORE] = "EVENT_RAID_TRIAL_NEW_BEST_SCORE",
        [EVENT_RAID_TRIAL_RESET_BEST_SCORE] = "EVENT_RAID_TRIAL_RESET_BEST_SCORE",
        [EVENT_RAID_TRIAL_SCORE_UPDATE] = "EVENT_RAID_TRIAL_SCORE_UPDATE",
        [EVENT_RAID_TRIAL_STARTED] = "EVENT_RAID_TRIAL_STARTED",
        [EVENT_RAM_ESCORT_COUNT_UPDATE] = "EVENT_RAM_ESCORT_COUNT_UPDATE",
        [EVENT_RANDOM_DICE_ROLL] = "EVENT_RANDOM_DICE_ROLL",
        [EVENT_RANDOM_MOUNT_SETTING_CHANGED] = "EVENT_RANDOM_MOUNT_SETTING_CHANGED",
        [EVENT_RANDOM_RANGE_ROLL] = "EVENT_RANDOM_RANGE_ROLL",
        [EVENT_RANK_POINT_UPDATE] = "EVENT_RANK_POINT_UPDATE",
        [EVENT_REASON_HARDWARE] = "EVENT_REASON_HARDWARE",
        [EVENT_REASON_SOFTWARE] = "EVENT_REASON_SOFTWARE",
        [EVENT_RECALL_KEEP_USE_RESULT] = "EVENT_RECALL_KEEP_USE_RESULT",
        [EVENT_RECIPE_ALREADY_KNOWN] = "EVENT_RECIPE_ALREADY_KNOWN",
        [EVENT_RECIPE_LEARNED] = "EVENT_RECIPE_LEARNED",
        [EVENT_RECONSTRUCT_RESPONSE] = "EVENT_RECONSTRUCT_RESPONSE",
        [EVENT_RECONSTRUCT_STARTED] = "EVENT_RECONSTRUCT_STARTED",
        [EVENT_REMOTE_SCENE_REQUEST] = "EVENT_REMOTE_SCENE_REQUEST",
        [EVENT_REMOTE_TOP_LEVEL_CHANGE] = "EVENT_REMOTE_TOP_LEVEL_CHANGE",
        [EVENT_REMOVE_ACTIVE_COMBAT_TIP] = "EVENT_REMOVE_ACTIVE_COMBAT_TIP",
        [EVENT_REMOVE_TUTORIAL] = "EVENT_REMOVE_TUTORIAL",
        [EVENT_REQUEST_ALERT] = "EVENT_REQUEST_ALERT",
        [EVENT_REQUEST_CONFIRM_USE_ITEM] = "EVENT_REQUEST_CONFIRM_USE_ITEM",
        [EVENT_REQUEST_CROWN_GEM_TUTORIAL] = "EVENT_REQUEST_CROWN_GEM_TUTORIAL",
        [EVENT_REQUEST_SHOW_GAMEPAD_CHAPTER_UPGRADE] = "EVENT_REQUEST_SHOW_GAMEPAD_CHAPTER_UPGRADE",
        [EVENT_REQUEST_SHOW_GIFT_INVENTORY] = "EVENT_REQUEST_SHOW_GIFT_INVENTORY",
        [EVENT_REQUIREMENTS_FAIL] = "EVENT_REQUIREMENTS_FAIL",
        [EVENT_RESEND_VERIFICATION_EMAIL_RESULT] = "EVENT_RESEND_VERIFICATION_EMAIL_RESULT",
        [EVENT_RESUME_FROM_SUSPEND] = "EVENT_RESUME_FROM_SUSPEND",
        [EVENT_RESURRECT_FAILURE] = "EVENT_RESURRECT_FAILURE",
        [EVENT_RESURRECT_REQUEST] = "EVENT_RESURRECT_REQUEST",
        [EVENT_RESURRECT_REQUEST_REMOVED] = "EVENT_RESURRECT_REQUEST_REMOVED",
        [EVENT_RESURRECT_RESULT] = "EVENT_RESURRECT_RESULT",
        [EVENT_RETICLE_HIDDEN_UPDATE] = "EVENT_RETICLE_HIDDEN_UPDATE",
        [EVENT_RETICLE_TARGET_CHANGED] = "EVENT_RETICLE_TARGET_CHANGED",
        [EVENT_RETICLE_TARGET_COMPANION_CHANGED] = "EVENT_RETICLE_TARGET_COMPANION_CHANGED",
        [EVENT_RETICLE_TARGET_PLAYER_CHANGED] = "EVENT_RETICLE_TARGET_PLAYER_CHANGED",
        [EVENT_RETRAIT_RESPONSE] = "EVENT_RETRAIT_RESPONSE",
        [EVENT_RETRAIT_STARTED] = "EVENT_RETRAIT_STARTED",
        [EVENT_RETRAIT_STATION_INTERACT_START] = "EVENT_RETRAIT_STATION_INTERACT_START",
        [EVENT_RETURNING_PLAYER_DAILY_LOGIN_REWARD_CLAIMED] = "EVENT_RETURNING_PLAYER_DAILY_LOGIN_REWARD_CLAIMED",
        [EVENT_RETURNING_PLAYER_INSTANCE_JUMP_RESULT] = "EVENT_RETURNING_PLAYER_INSTANCE_JUMP_RESULT",
        [EVENT_REVEAL_ANTIQUITY_DIG_SITES_ON_MAP] = "EVENT_REVEAL_ANTIQUITY_DIG_SITES_ON_MAP",
        [EVENT_REVENGE_KILL] = "EVENT_REVENGE_KILL",
        [EVENT_RIDING_SKILL_IMPROVEMENT] = "EVENT_RIDING_SKILL_IMPROVEMENT",
        [EVENT_SAVE_DATA_COMPLETE] = "EVENT_SAVE_DATA_COMPLETE",
        [EVENT_SAVE_DATA_START] = "EVENT_SAVE_DATA_START",
        [EVENT_SAVE_GUILD_RANKS_RESPONSE] = "EVENT_SAVE_GUILD_RANKS_RESPONSE",
        [EVENT_SCREEN_RESIZED] = "EVENT_SCREEN_RESIZED",
        [EVENT_SCREENSHOT_SAVED] = "EVENT_SCREENSHOT_SAVED",
        [EVENT_SCRIBING_DISABLED] = "EVENT_SCRIBING_DISABLED",
        [EVENT_SCRIBING_ERROR_RESULT] = "EVENT_SCRIBING_ERROR_RESULT",
        [EVENT_SCRIBING_ITEM_USE_RESULT] = "EVENT_SCRIBING_ITEM_USE_RESULT",
        [EVENT_SCRIPT_ACCESS_VIOLATION] = "EVENT_SCRIPT_ACCESS_VIOLATION",
        [EVENT_SCRIPTED_WORLD_EVENT_INVITE] = "EVENT_SCRIPTED_WORLD_EVENT_INVITE",
        [EVENT_SCRIPTED_WORLD_EVENT_INVITE_REMOVED] = "EVENT_SCRIPTED_WORLD_EVENT_INVITE_REMOVED",
        [EVENT_SCRYING_ACTIVE_SKILL_USE_RESULT] = "EVENT_SCRYING_ACTIVE_SKILL_USE_RESULT",
        [EVENT_SCRYING_EXIT_RESPONSE] = "EVENT_SCRYING_EXIT_RESPONSE",
        [EVENT_SECURE_3D_RENDER_MODE_CHANGED] = "EVENT_SECURE_3D_RENDER_MODE_CHANGED",
        [EVENT_SECURE_RENDER_MODE_CHANGED] = "EVENT_SECURE_RENDER_MODE_CHANGED",
        [EVENT_SELECT_FROM_USER_LIST_DIALOG_RESULT] = "EVENT_SELECT_FROM_USER_LIST_DIALOG_RESULT",
        [EVENT_SELL_RECEIPT] = "EVENT_SELL_RECEIPT",
        [EVENT_SET_SUBTITLE] = "EVENT_SET_SUBTITLE",
        [EVENT_SHOW_BOOK] = "EVENT_SHOW_BOOK",
        [EVENT_SHOW_DAILY_LOGIN_REWARDS_SCENE] = "EVENT_SHOW_DAILY_LOGIN_REWARDS_SCENE",
        [EVENT_SHOW_PREGAME_GUI_IN_STATE] = "EVENT_SHOW_PREGAME_GUI_IN_STATE",
        [EVENT_SHOW_SPECIFIC_HELP_PAGE] = "EVENT_SHOW_SPECIFIC_HELP_PAGE",
        [EVENT_SHOW_SUBTITLE] = "EVENT_SHOW_SUBTITLE",
        [EVENT_SHOW_TREASURE_MAP] = "EVENT_SHOW_TREASURE_MAP",
        [EVENT_SHOW_WORLD_MAP] = "EVENT_SHOW_WORLD_MAP",
        [EVENT_SHOW_ZONE_STORIES_SCENE] = "EVENT_SHOW_ZONE_STORIES_SCENE",
        [EVENT_SIEGE_BUSY] = "EVENT_SIEGE_BUSY",
        [EVENT_SIEGE_CONTROL_ANOTHER_PLAYER] = "EVENT_SIEGE_CONTROL_ANOTHER_PLAYER",
        [EVENT_SIEGE_CREATION_FAILED_CLOSEST_DOOR_ALREADY_HAS_RAM] = "EVENT_SIEGE_CREATION_FAILED_CLOSEST_DOOR_ALREADY_HAS_RAM",
        [EVENT_SIEGE_CREATION_FAILED_NO_VALID_DOOR] = "EVENT_SIEGE_CREATION_FAILED_NO_VALID_DOOR",
        [EVENT_SIEGE_FIRE_FAILED_COOLDOWN] = "EVENT_SIEGE_FIRE_FAILED_COOLDOWN",
        [EVENT_SIEGE_FIRE_FAILED_RETARGETING] = "EVENT_SIEGE_FIRE_FAILED_RETARGETING",
        [EVENT_SIEGE_PACK_FAILED_INVENTORY_FULL] = "EVENT_SIEGE_PACK_FAILED_INVENTORY_FULL",
        [EVENT_SIEGE_PACK_FAILED_NOT_CREATOR] = "EVENT_SIEGE_PACK_FAILED_NOT_CREATOR",
        [EVENT_SKILL_ABILITY_PROGRESSIONS_UPDATED] = "EVENT_SKILL_ABILITY_PROGRESSIONS_UPDATED",
        [EVENT_SKILL_BUILD_SELECTION_UPDATED] = "EVENT_SKILL_BUILD_SELECTION_UPDATED",
        [EVENT_SKILL_LINE_ADDED] = "EVENT_SKILL_LINE_ADDED",
        [EVENT_SKILL_POINTS_CHANGED] = "EVENT_SKILL_POINTS_CHANGED",
        [EVENT_SKILL_RANK_UPDATE] = "EVENT_SKILL_RANK_UPDATE",
        [EVENT_SKILL_RESPEC_RESULT] = "EVENT_SKILL_RESPEC_RESULT",
        [EVENT_SKILL_STYLE_DISABLED_BY_SERVER] = "EVENT_SKILL_STYLE_DISABLED_BY_SERVER",
        [EVENT_SKILL_XP_UPDATE] = "EVENT_SKILL_XP_UPDATE",
        [EVENT_SKILLS_FULL_UPDATE] = "EVENT_SKILLS_FULL_UPDATE",
        [EVENT_SKYSHARDS_UPDATED] = "EVENT_SKYSHARDS_UPDATED",
        [EVENT_SLD_SAVE_LOAD_ERROR] = "EVENT_SLD_SAVE_LOAD_ERROR",
        [EVENT_SLOT_IS_LOCKED_FAILURE] = "EVENT_SLOT_IS_LOCKED_FAILURE",
        [EVENT_SMITHING_TRAIT_RESEARCH_CANCELED] = "EVENT_SMITHING_TRAIT_RESEARCH_CANCELED",
        [EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED] = "EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED",
        [EVENT_SMITHING_TRAIT_RESEARCH_STARTED] = "EVENT_SMITHING_TRAIT_RESEARCH_STARTED",
        [EVENT_SMITHING_TRAIT_RESEARCH_TIMES_UPDATED] = "EVENT_SMITHING_TRAIT_RESEARCH_TIMES_UPDATED",
        [EVENT_SOCIAL_DATA_LOADED] = "EVENT_SOCIAL_DATA_LOADED",
        [EVENT_SOCIAL_ERROR] = "EVENT_SOCIAL_ERROR",
        [EVENT_SOUL_GEM_ITEM_CHARGE_FAILURE] = "EVENT_SOUL_GEM_ITEM_CHARGE_FAILURE",
        [EVENT_SPAM_WARNING] = "EVENT_SPAM_WARNING",
        [EVENT_STABLE_INTERACT_END] = "EVENT_STABLE_INTERACT_END",
        [EVENT_STABLE_INTERACT_START] = "EVENT_STABLE_INTERACT_START",
        [EVENT_STACKED_ALL_ITEMS_IN_BAG] = "EVENT_STACKED_ALL_ITEMS_IN_BAG",
        [EVENT_START_ATTRIBUTE_RESPEC] = "EVENT_START_ATTRIBUTE_RESPEC",
        [EVENT_START_FAST_TRAVEL_INTERACTION] = "EVENT_START_FAST_TRAVEL_INTERACTION",
        [EVENT_START_FAST_TRAVEL_KEEP_INTERACTION] = "EVENT_START_FAST_TRAVEL_KEEP_INTERACTION",
        [EVENT_START_KEEP_GUILD_CLAIM_INTERACTION] = "EVENT_START_KEEP_GUILD_CLAIM_INTERACTION",
        [EVENT_START_KEEP_GUILD_RELEASE_INTERACTION] = "EVENT_START_KEEP_GUILD_RELEASE_INTERACTION",
        [EVENT_START_SKILL_RESPEC] = "EVENT_START_SKILL_RESPEC",
        [EVENT_START_SOUL_GEM_RESURRECTION] = "EVENT_START_SOUL_GEM_RESURRECTION",
        [EVENT_START_WAIT_SPINNER] = "EVENT_START_WAIT_SPINNER",
        [EVENT_STATS_UPDATED] = "EVENT_STATS_UPDATED",
        [EVENT_STEALTH_STATE_CHANGED] = "EVENT_STEALTH_STATE_CHANGED",
        [EVENT_STOP_ANTIQUITY_DIGGING] = "EVENT_STOP_ANTIQUITY_DIGGING",
        [EVENT_STOP_WAIT_SPINNER] = "EVENT_STOP_WAIT_SPINNER",
        [EVENT_STORE_FAILURE] = "EVENT_STORE_FAILURE",
        [EVENT_STUCK_BEGIN] = "EVENT_STUCK_BEGIN",
        [EVENT_STUCK_CANCELED] = "EVENT_STUCK_CANCELED",
        [EVENT_STUCK_COMPLETE] = "EVENT_STUCK_COMPLETE",
        [EVENT_STUCK_ERROR_ALREADY_IN_PROGRESS] = "EVENT_STUCK_ERROR_ALREADY_IN_PROGRESS",
        [EVENT_STUCK_ERROR_IN_COMBAT] = "EVENT_STUCK_ERROR_IN_COMBAT",
        [EVENT_STUCK_ERROR_INVALID_LOCATION] = "EVENT_STUCK_ERROR_INVALID_LOCATION",
        [EVENT_STUCK_ERROR_ON_COOLDOWN] = "EVENT_STUCK_ERROR_ON_COOLDOWN",
        [EVENT_STYLE_LEARNED] = "EVENT_STYLE_LEARNED",
        [EVENT_SUBSCRIBER_BANK_IS_LOCKED] = "EVENT_SUBSCRIBER_BANK_IS_LOCKED",
        [EVENT_SYNERGY_ABILITY_CHANGED] = "EVENT_SYNERGY_ABILITY_CHANGED",
        [EVENT_SYSTEM_HELP_OPENED] = "EVENT_SYSTEM_HELP_OPENED",
        [EVENT_SYSTEM_MENU_CLOSED] = "EVENT_SYSTEM_MENU_CLOSED",
        [EVENT_SYSTEM_MENU_OPENED] = "EVENT_SYSTEM_MENU_OPENED",
        [EVENT_TARGET_CHANGED] = "EVENT_TARGET_CHANGED",
        [EVENT_TARGET_MARKER_UPDATE] = "EVENT_TARGET_MARKER_UPDATE",
        [EVENT_TELVAR_STONE_UPDATE] = "EVENT_TELVAR_STONE_UPDATE",
        [EVENT_TIMED_ACTIVITIES_UPDATED] = "EVENT_TIMED_ACTIVITIES_UPDATED",
        [EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED] = "EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED",
        [EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED] = "EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED",
        [EVENT_TIMED_ACTIVITY_TYPE_PROGRESS_UPDATED] = "EVENT_TIMED_ACTIVITY_TYPE_PROGRESS_UPDATED",
        [EVENT_TITLE_UPDATE] = "EVENT_TITLE_UPDATE",
        [EVENT_TOGGLE_HELP] = "EVENT_TOGGLE_HELP",
        [EVENT_TRACKED_ZONE_STORY_ACTIVITY_COMPLETED] = "EVENT_TRACKED_ZONE_STORY_ACTIVITY_COMPLETED",
        [EVENT_TRACKING_UPDATE] = "EVENT_TRACKING_UPDATE",
        [EVENT_TRADE_ACCEPT_FAILED_NOT_ENOUGH_MONEY] = "EVENT_TRADE_ACCEPT_FAILED_NOT_ENOUGH_MONEY",
        [EVENT_TRADE_CANCELED] = "EVENT_TRADE_CANCELED",
        [EVENT_TRADE_CONFIRMATION_CHANGED] = "EVENT_TRADE_CONFIRMATION_CHANGED",
        [EVENT_TRADE_ELEVATION_FAILED] = "EVENT_TRADE_ELEVATION_FAILED",
        [EVENT_TRADE_FAILED] = "EVENT_TRADE_FAILED",
        [EVENT_TRADE_INVITE_ACCEPTED] = "EVENT_TRADE_INVITE_ACCEPTED",
        [EVENT_TRADE_INVITE_CANCELED] = "EVENT_TRADE_INVITE_CANCELED",
        [EVENT_TRADE_INVITE_CONSIDERING] = "EVENT_TRADE_INVITE_CONSIDERING",
        [EVENT_TRADE_INVITE_DECLINED] = "EVENT_TRADE_INVITE_DECLINED",
        [EVENT_TRADE_INVITE_FAILED] = "EVENT_TRADE_INVITE_FAILED",
        [EVENT_TRADE_INVITE_REMOVED] = "EVENT_TRADE_INVITE_REMOVED",
        [EVENT_TRADE_INVITE_WAITING] = "EVENT_TRADE_INVITE_WAITING",
        [EVENT_TRADE_ITEM_ADD_FAILED] = "EVENT_TRADE_ITEM_ADD_FAILED",
        [EVENT_TRADE_ITEM_ADDED] = "EVENT_TRADE_ITEM_ADDED",
        [EVENT_TRADE_ITEM_REMOVED] = "EVENT_TRADE_ITEM_REMOVED",
        [EVENT_TRADE_ITEM_UPDATED] = "EVENT_TRADE_ITEM_UPDATED",
        [EVENT_TRADE_MONEY_CHANGED] = "EVENT_TRADE_MONEY_CHANGED",
        [EVENT_TRADE_SUCCEEDED] = "EVENT_TRADE_SUCCEEDED",
        [EVENT_TRADING_HOUSE_AWAITING_RESPONSE] = "EVENT_TRADING_HOUSE_AWAITING_RESPONSE",
        [EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE] = "EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE",
        [EVENT_TRADING_HOUSE_ERROR] = "EVENT_TRADING_HOUSE_ERROR",
        [EVENT_TRADING_HOUSE_OPERATION_TIME_OUT] = "EVENT_TRADING_HOUSE_OPERATION_TIME_OUT",
        [EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE] = "EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE",
        [EVENT_TRADING_HOUSE_RESPONSE_RECEIVED] = "EVENT_TRADING_HOUSE_RESPONSE_RECEIVED",
        [EVENT_TRADING_HOUSE_RESPONSE_TIMEOUT] = "EVENT_TRADING_HOUSE_RESPONSE_TIMEOUT",
        [EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE] = "EVENT_TRADING_HOUSE_SEARCH_COOLDOWN_UPDATE",
        [EVENT_TRADING_HOUSE_SELECTED_GUILD_CHANGED] = "EVENT_TRADING_HOUSE_SELECTED_GUILD_CHANGED",
        [EVENT_TRADING_HOUSE_STATUS_RECEIVED] = "EVENT_TRADING_HOUSE_STATUS_RECEIVED",
        [EVENT_TRAIT_LEARNED] = "EVENT_TRAIT_LEARNED",
        [EVENT_TRIAL_FEATURE_RESTRICTED] = "EVENT_TRIAL_FEATURE_RESTRICTED",
        [EVENT_TRIBUTE_CAMPAIGN_CHANGE] = "EVENT_TRIBUTE_CAMPAIGN_CHANGE",
        [EVENT_TRIBUTE_CLUB_EXPERIENCE_GAINED] = "EVENT_TRIBUTE_CLUB_EXPERIENCE_GAINED",
        [EVENT_TRIBUTE_CLUB_INIT] = "EVENT_TRIBUTE_CLUB_INIT",
        [EVENT_TRIBUTE_CLUB_RANK_CHANGED] = "EVENT_TRIBUTE_CLUB_RANK_CHANGED",
        [EVENT_TRIBUTE_EXIT_RESPONSE] = "EVENT_TRIBUTE_EXIT_RESPONSE",
        [EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE] = "EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE",
        [EVENT_TRIBUTE_INVITE_ACCEPTED] = "EVENT_TRIBUTE_INVITE_ACCEPTED",
        [EVENT_TRIBUTE_INVITE_CANCELED] = "EVENT_TRIBUTE_INVITE_CANCELED",
        [EVENT_TRIBUTE_INVITE_DECLINED] = "EVENT_TRIBUTE_INVITE_DECLINED",
        [EVENT_TRIBUTE_INVITE_FAILED] = "EVENT_TRIBUTE_INVITE_FAILED",
        [EVENT_TRIBUTE_INVITE_RECEIVED] = "EVENT_TRIBUTE_INVITE_RECEIVED",
        [EVENT_TRIBUTE_INVITE_REMOVED] = "EVENT_TRIBUTE_INVITE_REMOVED",
        [EVENT_TRIBUTE_INVITE_SENT] = "EVENT_TRIBUTE_INVITE_SENT",
        [EVENT_TRIBUTE_LEADERBOARD_DATA_RECEIVED] = "EVENT_TRIBUTE_LEADERBOARD_DATA_RECEIVED",
        [EVENT_TRIBUTE_LEADERBOARD_RANK_RECEIVED] = "EVENT_TRIBUTE_LEADERBOARD_RANK_RECEIVED",
        [EVENT_TRIBUTE_PATRON_PROGRESSION_DATA_CHANGED] = "EVENT_TRIBUTE_PATRON_PROGRESSION_DATA_CHANGED",
        [EVENT_TRIBUTE_PATRONS_SEARCH_RESULTS_READY] = "EVENT_TRIBUTE_PATRONS_SEARCH_RESULTS_READY",
        [EVENT_TRIBUTE_PLAYER_CAMPAIGN_INIT] = "EVENT_TRIBUTE_PLAYER_CAMPAIGN_INIT",
        [EVENT_TRIBUTE_PLAYER_TURN_STARTED] = "EVENT_TRIBUTE_PLAYER_TURN_STARTED",
        [EVENT_TUTORIAL_SYSTEM_ENABLED_STATE_CHANGED] = "EVENT_TUTORIAL_SYSTEM_ENABLED_STATE_CHANGED",
        [EVENT_TUTORIAL_TRIGGER_COMPLETED] = "EVENT_TUTORIAL_TRIGGER_COMPLETED",
        [EVENT_TUTORIALS_RESET] = "EVENT_TUTORIALS_RESET",
        [EVENT_UI_ERROR] = "EVENT_UI_ERROR",
        [EVENT_ULTIMATE_ABILITY_COST_CHANGED] = "EVENT_ULTIMATE_ABILITY_COST_CHANGED",
        [EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED] = "EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED",
        [EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED] = "EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED",
        [EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED] = "EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED",
        [EVENT_UNIT_CHARACTER_NAME_CHANGED] = "EVENT_UNIT_CHARACTER_NAME_CHANGED",
        [EVENT_UNIT_CREATED] = "EVENT_UNIT_CREATED",
        [EVENT_UNIT_DEATH_STATE_CHANGED] = "EVENT_UNIT_DEATH_STATE_CHANGED",
        [EVENT_UNIT_DESTROYED] = "EVENT_UNIT_DESTROYED",
        [EVENT_UNLOCKED_DYES_UPDATED] = "EVENT_UNLOCKED_DYES_UPDATED",
        [EVENT_UNLOCKED_HIRELING_CORRESPONDENCE_INITIALIZED] = "EVENT_UNLOCKED_HIRELING_CORRESPONDENCE_INITIALIZED",
        [EVENT_UNLOCKED_HIRELING_CORRESPONDENCE_UPDATED] = "EVENT_UNLOCKED_HIRELING_CORRESPONDENCE_UPDATED",
        [EVENT_UNSPENT_CHAMPION_POINTS_CHANGED] = "EVENT_UNSPENT_CHAMPION_POINTS_CHANGED",
        [EVENT_UNSUCCESSFUL_REQUEST_RESULT] = "EVENT_UNSUCCESSFUL_REQUEST_RESULT",
        [EVENT_UPDATE_BUYBACK] = "EVENT_UPDATE_BUYBACK",
        [EVENT_UPDATE_GUI_LOADING_PROGRESS] = "EVENT_UPDATE_GUI_LOADING_PROGRESS",
        [EVENT_VETERAN_DIFFICULTY_CHANGED] = "EVENT_VETERAN_DIFFICULTY_CHANGED",
        [EVENT_VIBRATION] = "EVENT_VIBRATION",
        [EVENT_VIDEO_PLAYBACK_CANCEL_STARTED] = "EVENT_VIDEO_PLAYBACK_CANCEL_STARTED",
        [EVENT_VIDEO_PLAYBACK_COMPLETE] = "EVENT_VIDEO_PLAYBACK_COMPLETE",
        [EVENT_VIDEO_PLAYBACK_CONFIRM_CANCEL] = "EVENT_VIDEO_PLAYBACK_CONFIRM_CANCEL",
        [EVENT_VIDEO_PLAYBACK_ERROR] = "EVENT_VIDEO_PLAYBACK_ERROR",
        [EVENT_VISUAL_LAYER_CHANGED] = "EVENT_VISUAL_LAYER_CHANGED",
        [EVENT_VOICE_CHANNEL_AVAILABLE] = "EVENT_VOICE_CHANNEL_AVAILABLE",
        [EVENT_VOICE_CHANNEL_JOINED] = "EVENT_VOICE_CHANNEL_JOINED",
        [EVENT_VOICE_CHANNEL_LEFT] = "EVENT_VOICE_CHANNEL_LEFT",
        [EVENT_VOICE_CHANNEL_UNAVAILABLE] = "EVENT_VOICE_CHANNEL_UNAVAILABLE",
        [EVENT_VOICE_CHAT_ACCESSIBILITY_SETTING_CHANGED] = "EVENT_VOICE_CHAT_ACCESSIBILITY_SETTING_CHANGED",
        [EVENT_VOICE_CHAT_TRANSCRIPT] = "EVENT_VOICE_CHAT_TRANSCRIPT",
        [EVENT_VOICE_DEVICE_INFO] = "EVENT_VOICE_DEVICE_INFO",
        [EVENT_VOICE_MUTE_LIST_UPDATED] = "EVENT_VOICE_MUTE_LIST_UPDATED",
        [EVENT_VOICE_TRANSMIT_CHANNEL_CHANGED] = "EVENT_VOICE_TRANSMIT_CHANNEL_CHANGED",
        [EVENT_VOICE_USER_JOINED_CHANNEL] = "EVENT_VOICE_USER_JOINED_CHANNEL",
        [EVENT_VOICE_USER_LEFT_CHANNEL] = "EVENT_VOICE_USER_LEFT_CHANNEL",
        [EVENT_VOICE_USER_SPEAKING] = "EVENT_VOICE_USER_SPEAKING",
        [EVENT_WEAPON_PAIR_LOCK_CHANGED] = "EVENT_WEAPON_PAIR_LOCK_CHANGED",
        [EVENT_WEAPON_SWAP_LOCKED] = "EVENT_WEAPON_SWAP_LOCKED",
        [EVENT_WEB_BROWSER_CLOSED] = "EVENT_WEB_BROWSER_CLOSED",
        [EVENT_WEB_BROWSER_OPENED] = "EVENT_WEB_BROWSER_OPENED",
        [EVENT_WEREWOLF_STATE_CHANGED] = "EVENT_WEREWOLF_STATE_CHANGED",
        [EVENT_WORLD_EVENT_ACTIVATED] = "EVENT_WORLD_EVENT_ACTIVATED",
        [EVENT_WORLD_EVENT_ACTIVE_LOCATION_CHANGED] = "EVENT_WORLD_EVENT_ACTIVE_LOCATION_CHANGED",
        [EVENT_WORLD_EVENT_DEACTIVATED] = "EVENT_WORLD_EVENT_DEACTIVATED",
        [EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE] = "EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE",
        [EVENT_WORLD_EVENT_UNIT_CREATED] = "EVENT_WORLD_EVENT_UNIT_CREATED",
        [EVENT_WORLD_EVENT_UNIT_DESTROYED] = "EVENT_WORLD_EVENT_UNIT_DESTROYED",
        [EVENT_WORLD_EVENTS_INITIALIZED] = "EVENT_WORLD_EVENTS_INITIALIZED",
        [EVENT_WRIT_VOUCHER_UPDATE] = "EVENT_WRIT_VOUCHER_UPDATE",
        [EVENT_ZONE_CHANGED] = "EVENT_ZONE_CHANGED",
        [EVENT_ZONE_CHANNEL_CHANGED] = "EVENT_ZONE_CHANNEL_CHANGED",
        [EVENT_ZONE_COLLECTIBLE_REQUIREMENT_FAILED] = "EVENT_ZONE_COLLECTIBLE_REQUIREMENT_FAILED",
        [EVENT_ZONE_SCORING_CHANGED] = "EVENT_ZONE_SCORING_CHANGED",
        [EVENT_ZONE_STORY_ACTIVITY_TRACKED] = "EVENT_ZONE_STORY_ACTIVITY_TRACKED",
        [EVENT_ZONE_STORY_ACTIVITY_TRACKING_INIT] = "EVENT_ZONE_STORY_ACTIVITY_TRACKING_INIT",
        [EVENT_ZONE_STORY_ACTIVITY_UNTRACKED] = "EVENT_ZONE_STORY_ACTIVITY_UNTRACKED",
        [EVENT_ZONE_STORY_QUEST_ACTIVITY_TRACKED] = "EVENT_ZONE_STORY_QUEST_ACTIVITY_TRACKED",
        [EVENT_ZONE_UPDATE] = "EVENT_ZONE_UPDATE",
    }
    return eventNames[eventCode] or string_format("UNKNOWN_EVENT_%d", eventCode)
end
