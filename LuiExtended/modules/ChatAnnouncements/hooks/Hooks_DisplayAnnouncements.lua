-- -----------------------------------------------------------------------------
--  LuiExtended — Chat Announcements hook shared context (CSA / alerts)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local S = ChatAnnouncements.State
local I = ChatAnnouncements.Internal
local B = ChatAnnouncements.Brackets
local ColorizeColors = ChatAnnouncements.Colors
local Data = LuiData.Data
local Quests = Data.Quests
local ChatOutput = LUIE.ChatOutput
local string_format = string.format
local table_insert = table.insert
local windowManager = GetWindowManager()

--- @param ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterDisplayAnnouncements(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
    local function ActivityFinderCompleteHook()
        local message = GetString(SI_ACTIVITY_FINDER_ACTIVITY_COMPLETE_ANNOUNCEMENT_TEXT)
        if ChatAnnouncements.SV.Group.GroupLFGCompleteCA then
            ChatOutput:Print(message, true)
        end

        if ChatAnnouncements.SV.Group.GroupLFGCompleteCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LFG_COMPLETE_ANNOUNCEMENT)
            messageParams:SetText(message)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACTIVITY_COMPLETE)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Group.GroupLFGCompleteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end

        if not ChatAnnouncements.SV.Group.GroupLFGCompleteCSA then
            PlaySound(SOUNDS.LFG_COMPLETE_ANNOUNCEMENT)
        end

        return true
    end

    S.g_previousEndlessDungeonProgression = { 0, 0, 0 } -- Stage, Cycle, Arc

    local function GetEndlessDungeonProgressMessageParams()
        local stage, cycle, arc = ENDLESS_DUNGEON_MANAGER:GetProgression()
        local previousStage, previousCycle, previousArc = unpack(S.g_previousEndlessDungeonProgression)
        if stage == 1 and cycle == 1 and arc == 1 then
            -- Force the initial CSA to roll over from all 0s to all 1s.
            previousStage, previousCycle, previousArc = 0, 0, 0
        end

        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_ROLLING_METER_PROGRESS_TEXT)
        local stageIcon, cycleIcon, arcIcon = ZO_EndlessDungeonManager.GetProgressionIcons()
        local stageNarration, cycleNarration, arcNarration = ZO_EndlessDungeonManager.GetProgressionNarrationDescriptions(stage, cycle, arc)
        local progressData =
        {
            {
                iconTexture = arcIcon,
                narrationDescription = arcNarration,
                initialValue = previousArc,
                finalValue = arc,
            },
            {
                iconTexture = cycleIcon,
                narrationDescription = cycleNarration,
                initialValue = previousCycle,
                finalValue = cycle,
            },
            {
                iconTexture = stageIcon,
                narrationDescription = stageNarration,
                initialValue = previousStage,
                finalValue = stage,
            },
        }
        messageParams:SetRollingMeterProgressData(progressData)

        -- Update the previous progression values.
        S.g_previousEndlessDungeonProgression[1] = stage
        S.g_previousEndlessDungeonProgression[2] = cycle
        S.g_previousEndlessDungeonProgression[3] = arc

        return messageParams
    end

    local function RefreshEndlessDungeonProgressionState()
        local stage, cycle, arc = ENDLESS_DUNGEON_MANAGER:GetProgression()
        S.g_previousEndlessDungeonProgression[1] = stage
        S.g_previousEndlessDungeonProgression[2] = cycle
        S.g_previousEndlessDungeonProgression[3] = arc
    end

    ENDLESS_DUNGEON_MANAGER:RegisterCallback("StateChanged", RefreshEndlessDungeonProgressionState)

    local function UpdateEndlessDungeonTrackers()
        ENDLESS_DUNGEON_HUD_TRACKER:UpdateProgress()
        ENDLESS_DUNGEON_BUFF_TRACKER_GAMEPAD:UpdateProgress()
        if ENDLESS_DUNGEON_BUFF_TRACKER_KEYBOARD then
            ENDLESS_DUNGEON_BUFF_TRACKER_KEYBOARD:UpdateProgress()
        end
    end

    local ZoneIds =
    {
        [1436] = "Endless Archive", -- Dungeon - Endless Archive
        [888] = "Craglorn",         -- Zone - Craglorn
        [584] = "Imperial City",    -- Imperial City (Overland)
        [643] = "Imperial City",    -- Imperial City (Sewers)
        [635] = "Dragonstar Arena", -- Dragonstar Arena
    }

    local MapIds =
    {
        [988] = "Maelstrom Arena", -- Vale of the Surreal (Maelstrom Arena - Stage 1)
        [963] = "Maelstrom Arena", -- Seht's Balcony (Maelstrom Arena - Stage 2)
        -- TODO - Need MapIds for Stage 3-9
    }

    local function ResolveDisplayAnnouncementMessages(type)
        local settings
        if type == "Imperial City" then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneIC
        elseif type == "Craglorn" then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneCraglorn
        elseif type == "Maelstrom Arena" then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ArenaMaelstrom
        elseif type == "Dragonstar Arena" then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ArenaDragonstar
        elseif type == "Endless Archive" then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.DungeonEndlessArchive
        end
        return settings
    end

    -- EVENT_DISPLAY_ANNOUNCEMENT (CSA Handler)
    local function DisplayAnnouncementHook(primaryText, secondaryText, icon, soundId, lifespanMS, category)
        -- Disable Respec Display Announcement since we handle this from loot announcements (using Respec scroll)
        if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE1) then
            return true
        end

        -- Setup CSA with default function (don't display CSA here yet, we filter to check)
        soundId = soundId == "" and SOUNDS.DISPLAY_ANNOUNCEMENT or soundId

        local messageParams
        if category == CSA_CATEGORY_ENDLESS_DUNGEON_STAGE_STARTED_TEXT then
            -- Endless Dungeon Progression CSA special case
            messageParams = GetEndlessDungeonProgressMessageParams()
            if not messageParams then
                -- The progression did not change; this should never happen.
                return
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ENDLESS_DUNGEON_PROGRESS)
            messageParams:SetOnDisplayCallback(UpdateEndlessDungeonTrackers)
        else
            -- Standard Display Announcement
            messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, soundId)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        end

        if soundId then
            messageParams:SetSound(soundId)
        end

        if icon ~= ZO_NO_TEXTURE_FILE then
            messageParams:SetIconData(icon)
        end

        if lifespanMS > 0 then
            messageParams:SetLifespanMS(lifespanMS)
        end

        -- Sanitize text.
        if primaryText == "" then
            primaryText = nil
        end
        if secondaryText == "" then
            secondaryText = nil
        end

        -- No message so return
        if primaryText == nil and secondaryText == nil then
            return
        end

        -- Check zoneId or mapId if needed
        local zoneId = GetZoneId(GetCurrentMapZoneIndex())
        local mapId = GetCurrentMapId() -- Some areas don't have proper zoneIds (Maelstrom Arena)
        local type
        if ZoneIds[zoneId] then
            type = ZoneIds[zoneId]
        elseif MapIds[mapId] then
            type = MapIds[mapId]
        end

        local settings     -- local variable for pulling SV
        local debugDisable -- flag to disable debug when its enabled

        -- Settings either use the subcategory settings or the generic settings if no subcategory
        if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE0) or primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE1) or primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE4) then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.Respec
            debugDisable = true
            -- Update message syntax here
            if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE0) then
                primaryText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_SKILLS)
            end
            if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE1) then
                primaryText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_ATTRIBUTES)
            end
            if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE4) then
                primaryText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_SKILL_LINE)
            end
        elseif primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPENTER_D) or primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPLEAVE_D) then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.GroupArea
            debugDisable = true
            -- Update message syntax here
            if primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPENTER_D) then
                primaryText = GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPENTER_C)
            end
            if primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPLEAVE_D) then
                primaryText = GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPLEAVE_C)
            end
        elseif primaryText == GetString(LUIE_STRING_CA_DISPLAY_DUNGEON_JOINING_ENCOUNTER_IN_PROGRESS) then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.DungeonTrial
            debugDisable = true
        else
            local nightMarketSettings = ChatAnnouncements.ResolveNightMarketDisplayAnnouncement(primaryText, secondaryText)
            if nightMarketSettings then
                settings = nightMarketSettings
                debugDisable = true
            end
        end

        if not settings then
            if type then
                settings = ResolveDisplayAnnouncementMessages(type)
                debugDisable = true
            else
                settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.General
            end
        end

        -- Debug function
        if ChatAnnouncements.SV.DisplayAnnouncements.Debug and not debugDisable then
            d("EVENT_DISPLAY_ANNOUNCEMENT: If you see this message please post a screenshot and context for the event on the LUI Extended ESOUI page.")
            if primaryText then
                d("Primary Text: " .. primaryText)
            end
            if secondaryText then
                d("Secondary Text: " .. secondaryText)
            end
            local zoneid = GetZoneId(GetCurrentMapZoneIndex())
            d("Zone Id: " .. zoneid)
            local mapid = GetCurrentMapId()
            d("Map Id: " .. mapid)
            d("Category: " .. tostring(category))
            d("Icon: " .. tostring(icon))
            d("LifespanMS: " .. tostring(lifespanMS))
        end

        -- Display CA if enabled
        if settings.CA then
            -- Some formatting may be needed for CA:
            local caPrimary = primaryText
            local caSecondary = secondaryText
            local language = GetCVar("language.2")
            -- Extra formatting in Imperial City: Remove "Entered: " and format it and add it back on and color the message.
            -- Note we don't want to mess with strings outside of EN localization for now (TODO)
            -- Custom formatting for IC messages
            if settings == LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneIC and language == "en" then
                local prefix = GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_IC_TITLE_PREFIX)
                caPrimary = zo_strgsub(primaryText, prefix, "")
                caPrimary = settings.Description and string_format("%s|c%s%s: |r", prefix, ColorizeColors.QuestColorLocNameColorize, caPrimary) or string_format("%s|c%s%s|r", prefix, ColorizeColors.QuestColorLocNameColorize, caPrimary)
                caSecondary = settings.Description and string_format("|c%s%s|r", ColorizeColors.QuestColorLocDescriptionColorize, caSecondary) or ""
                ChatOutput:Print(caPrimary .. caSecondary)
                -- Add an "!" to the CA for Craglorn buffs
            elseif settings == LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneCraglorn and language == "en" then
                caPrimary = primaryText .. "!"
                ChatOutput:Print(caPrimary)
                -- Add an "!" to the Maelstrom Arena Round CA messages (VMA messages have two lines other then the rounds)
            elseif settings == LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ArenaMaelstrom and secondaryText == nil then
                caPrimary = primaryText .. "!"
                ChatOutput:Print(caPrimary)
            else
                if primaryText and secondaryText then
                    ChatOutput:Print(caPrimary .. ": " .. caSecondary)
                elseif primaryText then
                    ChatOutput:Print(caPrimary)
                elseif secondaryText then
                    ChatOutput:Print(caSecondary)
                end
            end
        end

        -- Display CSA if enabled
        if settings.CSA then
            messageParams:SetText(primaryText, secondaryText)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert if enabled
        if settings.Alert then
            if primaryText and secondaryText then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, (primaryText .. ": " .. secondaryText))
            elseif primaryText then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, primaryText)
            elseif secondaryText then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, secondaryText)
            end
        end

        -- If the CSA is disabled, play a sound if Chat Announcement or Alert are enabled
        if (settings.CA or settings.Alert) and not settings.CSA then
            if soundId then
                PlaySound(SOUNDS.NONE)
                -- Fallback sound if no soundId
            else
                PlaySound(SOUNDS.DISPLAY_ANNOUNCEMENT)
            end
        end

        return true
    end
    ZO_PreHook(csaHandlers, EVENT_DISPLAY_ANNOUNCEMENT, DisplayAnnouncementHook)
    ZO_PreHook(csaHandlers, EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE, ActivityFinderCompleteHook)
end
