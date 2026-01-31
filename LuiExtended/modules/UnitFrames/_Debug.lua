-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

-- -----------------------------------------------------------------------------
-- * DEBUG FUNCTIONS *
-- -----------------------------------------------------------------------------

-- Constants
local UNIT_FRAMES =
{
    SMALL_GROUP =
    {
        prefix = "SmallGroup",
        size = 4,
        special =
        {
            first =
            {
                friendIcon =
                {
                    texture = "/esoui/art/campaign/campaignbrowser_friends.dds"
                }
            }
        }
    },
    RAID_GROUP =
    {
        prefix = "RaidGroup",
        size = 12
    },
    PET_GROUP =
    {
        prefix = "PetGroup",
        size = 7
    },
    BOSS =
    {
        prefix = "boss",
        size = 7
    },
    SINGLE =
    {
        PLAYER = "player",
        TARGET = "reticleover",
        COMPANION = "companion"
    }
}

-- Helper function to debug a single frame
local function DebugSingleFrame(frameType)
    local frame = UnitFrames.CustomFrames[frameType]
    if not frame then return end

    frame.unitTag = UNIT_FRAMES.SINGLE.PLAYER
    frame.control:SetHidden(false)
    UnitFrames.UpdateStaticControls(frame)
end

local function DebugMultipleFrames(frameConfig)
    local raidContainer = UnitFrames.CustomFrames["RaidGroup1"].tlw
    if raidContainer then
        -- Make container visible
        raidContainer:SetHidden(false)

        -- Position container
        raidContainer:ClearAnchors()
        raidContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100, 100)

        -- Get dimensions from saved variables
        local frameWidth = UnitFrames.SV.RaidBarWidth
        local frameHeight = UnitFrames.SV.RaidBarHeight
        local spacing = 0 -- Remove spacing between frames for tight stacking

        -- Set container size
        raidContainer:SetDimensions(frameWidth, frameHeight * frameConfig.size)

        -- Position frames
        for i = 1, frameConfig.size do
            local unitTag = frameConfig.prefix .. i
            local frame = UnitFrames.CustomFrames[unitTag]
            if frame then
                frame.unitTag = UNIT_FRAMES.SINGLE.PLAYER
                frame.control:SetHidden(false)

                -- Position frame with no spacing
                frame.control:ClearAnchors()
                frame.control:SetAnchor(TOPLEFT, raidContainer, TOPLEFT, 0, (i - 1) * frameHeight)
                frame.control:SetDimensions(frameWidth, frameHeight)

                -- Ensure name label is properly set
                if frame.name then
                    frame.name:SetText("DEBUG") -- Set consistent name for debug
                    frame.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                end

                UnitFrames.UpdateStaticControls(frame)
            end
        end
    end

    -- Handle special cases
    if frameConfig.special and frameConfig.special.first then
        local firstFrame = UnitFrames.CustomFrames[frameConfig.prefix .. "1"]
        if firstFrame then
            for component, settings in pairs(frameConfig.special.first) do
                if firstFrame[component] then
                    firstFrame[component]:SetHidden(false)
                    if settings.texture then
                        firstFrame[component]:SetTexture(settings.texture)
                    end
                end
            end
        end
    end

    if frameConfig.prefix == UNIT_FRAMES.SMALL_GROUP.prefix or
    frameConfig.prefix == UNIT_FRAMES.RAID_GROUP.prefix then
        UnitFrames.OnLeaderUpdate(nil, frameConfig.prefix .. "1")
    end
end

-- Debug Functions

local function CustomFramesDebugGroup()
    DebugMultipleFrames(UNIT_FRAMES.SMALL_GROUP)
end

local function CustomFramesDebugRaid()
    DebugMultipleFrames(UNIT_FRAMES.RAID_GROUP)
end

local function CustomFramesDebugPlayer()
    DebugSingleFrame(UNIT_FRAMES.SINGLE.PLAYER)
end

local function CustomFramesDebugTarget()
    DebugSingleFrame(UNIT_FRAMES.SINGLE.TARGET)
end

local function CustomFramesDebugPets()
    DebugMultipleFrames(UNIT_FRAMES.PET_GROUP)
end

local function CustomFramesDebugBosses()
    DebugMultipleFrames(UNIT_FRAMES.BOSS)
end

local function CustomFramesDebugCompanion()
    DebugSingleFrame(UNIT_FRAMES.SINGLE.COMPANION)
end

local DEBUG_COMMANDS =
{
    ["/luiufsm"] = CustomFramesDebugGroup,
    ["/luiufraid"] = CustomFramesDebugRaid,
    ["/luiufplayer"] = CustomFramesDebugPlayer,
    ["/luiuftar"] = CustomFramesDebugTarget,
    ["/luiufpet"] = CustomFramesDebugPets,
    ["/luiufboss"] = CustomFramesDebugBosses,
    ["/luiufcomp"] = CustomFramesDebugCompanion,
}

--- Initializes debug slash commands
--- These commands are only available when developer debug mode is enabled
for command, handler in pairs(DEBUG_COMMANDS) do
    SLASH_COMMANDS[command] = handler
end
