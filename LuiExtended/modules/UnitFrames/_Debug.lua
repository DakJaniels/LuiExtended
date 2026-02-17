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

-- Debug Functions

local function CustomFramesDebugGroup()
    local groupContainer = UnitFrames.CustomFrames["SmallGroup1"].tlw
    if not groupContainer then return end

    -- Make container visible
    groupContainer:SetHidden(false)

    -- Position container
    groupContainer:ClearAnchors()
    groupContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100, 100)

    -- Apply proper group layout (this sets dimensions and spacing correctly)
    UnitFrames.CustomFramesApplyLayoutGroup(false)

    -- Show all group frames and set them to player unitTag for preview
    for i = 1, UNIT_FRAMES.SMALL_GROUP.size do
        local unitTag = UNIT_FRAMES.SMALL_GROUP.prefix .. i
        local frame = UnitFrames.CustomFrames[unitTag]
        if frame then
            frame.unitTag = UNIT_FRAMES.SINGLE.PLAYER
            frame.control:SetHidden(false)
            UnitFrames.UpdateStaticControls(frame)
        end
    end

    -- Handle leader icon for first frame
    if UNIT_FRAMES.SMALL_GROUP.special and UNIT_FRAMES.SMALL_GROUP.special.first then
        local firstFrame = UnitFrames.CustomFrames[UNIT_FRAMES.SMALL_GROUP.prefix .. "1"]
        if firstFrame then
            for component, settings in pairs(UNIT_FRAMES.SMALL_GROUP.special.first) do
                if firstFrame[component] then
                    --- @diagnostic disable-next-line: undefined-field
                    firstFrame[component]:SetHidden(false)
                    if settings.texture then
                        --- @diagnostic disable-next-line: undefined-field
                        firstFrame[component]:SetTexture(settings.texture)
                    end
                end
            end
        end
    end

    UnitFrames.OnLeaderUpdate(nil, UNIT_FRAMES.SMALL_GROUP.prefix .. "1")
end

local function CustomFramesDebugRaid()
    local raidContainer = UnitFrames.CustomFrames["RaidGroup1"].tlw
    if not raidContainer then return end

    -- Make container visible
    raidContainer:SetHidden(false)

    -- Position container
    raidContainer:ClearAnchors()
    raidContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100, 100)

    -- Apply proper raid layout (this sets dimensions and spacing correctly)
    UnitFrames.CustomFramesApplyLayoutRaid(false)

    -- Show all raid frames and set them to player unitTag for preview
    for i = 1, UNIT_FRAMES.RAID_GROUP.size do
        local unitTag = UNIT_FRAMES.RAID_GROUP.prefix .. i
        local frame = UnitFrames.CustomFrames[unitTag]
        if frame then
            frame.unitTag = UNIT_FRAMES.SINGLE.PLAYER
            frame.control:SetHidden(false)
            UnitFrames.UpdateStaticControls(frame)
        end
    end

    UnitFrames.OnLeaderUpdate(nil, UNIT_FRAMES.RAID_GROUP.prefix .. "1")
end

local function CustomFramesDebugPlayer()
    DebugSingleFrame(UNIT_FRAMES.SINGLE.PLAYER)
end

local function CustomFramesDebugTarget()
    DebugSingleFrame(UNIT_FRAMES.SINGLE.TARGET)
end

local function CustomFramesDebugPets()
    local petContainer = UnitFrames.CustomFrames["PetGroup1"].tlw
    if not petContainer then return end

    -- Make container visible
    petContainer:SetHidden(false)

    -- Position container
    petContainer:ClearAnchors()
    petContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100, 100)

    -- Apply proper pet layout (this sets dimensions and spacing correctly)
    UnitFrames.CustomFramesApplyLayoutPet(true)

    -- Show all pet frames and set them to player unitTag for preview
    for i = 1, UNIT_FRAMES.PET_GROUP.size do
        local unitTag = UNIT_FRAMES.PET_GROUP.prefix .. i
        local frame = UnitFrames.CustomFrames[unitTag]
        if frame then
            frame.unitTag = UNIT_FRAMES.SINGLE.PLAYER
            frame.control:SetHidden(false)
            UnitFrames.UpdateStaticControls(frame)
        end
    end
end

local function CustomFramesDebugBosses()
    -- Special handling for boss frames since they have their own container and layout logic
    local bossContainer = UnitFrames.CustomFrames["boss1"].tlw
    if not bossContainer then return end

    -- Make container visible
    bossContainer:SetHidden(false)

    -- Position container
    bossContainer:ClearAnchors()
    bossContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 100, 100)

    -- Apply proper boss layout (this sets dimensions and spacing correctly)
    UnitFrames.CustomFramesApplyLayoutBosses()

    -- Show all boss frames and set them to player unitTag for preview
    for i = 1, UNIT_FRAMES.BOSS.size do
        local unitTag = UNIT_FRAMES.BOSS.prefix .. i
        local frame = UnitFrames.CustomFrames[unitTag]
        if frame then
            frame.unitTag = UNIT_FRAMES.SINGLE.PLAYER
            frame.control:SetHidden(false)
            UnitFrames.UpdateStaticControls(frame)
        end
    end

    -- Update threshold markers to display them properly on each frame
    UnitFrames.UpdateBossThresholds()
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

for command, handler in pairs(DEBUG_COMMANDS) do
    SLASH_COMMANDS[command] = handler
end
