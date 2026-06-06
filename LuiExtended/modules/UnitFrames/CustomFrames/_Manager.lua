-- -----------------------------------------------------------------------------
--  LuiExtended - Custom frame manager (ZOS ZO_UnitFrames_Manager pattern)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local CATEGORY_STATIC = "static"
local CATEGORY_SMALL_GROUP = "smallGroup"
local CATEGORY_RAID = "raid"
local CATEGORY_PET = "pet"

--- @class LUIE_CustomFrames_Manager : ZO_InitializingObject
LUIE_CustomFrames_Manager = ZO_InitializingObject:Subclass()

function LUIE_CustomFrames_Manager:Initialize()
    self.staticFrames = {}
    self.smallGroupFrames = {}
    self.raidFrames = {}
    self.petFrames = {}
end

local function IsSmallGroupRegistryKey(registryKey)
    return registryKey and string.sub(registryKey, 1, 10) == "SmallGroup"
end

local function IsRaidRegistryKey(registryKey)
    return registryKey and string.sub(registryKey, 1, 9) == "RaidGroup"
end

local function IsPetRegistryKey(registryKey)
    return registryKey and string.sub(registryKey, 1, 8) == "PetGroup"
end

--- @param registryKey string|nil
--- @param category string|nil
--- @return table
function LUIE_CustomFrames_Manager:GetUnitFrameLookupTable(registryKey, category)
    category = category or (registryKey and UnitFrames.CustomFrames[registryKey] and UnitFrames.CustomFrames[registryKey].frameCategory)

    if category == CATEGORY_SMALL_GROUP or IsSmallGroupRegistryKey(registryKey) then
        return self.smallGroupFrames
    end
    if category == CATEGORY_RAID or IsRaidRegistryKey(registryKey) then
        return self.raidFrames
    end
    if category == CATEGORY_PET or IsPetRegistryKey(registryKey) then
        return self.petFrames
    end
    return self.staticFrames
end

--- @param registryKey string
--- @return LUIE_CustomFrameObject|nil
function LUIE_CustomFrames_Manager:GetFrame(registryKey)
    if not registryKey then
        return nil
    end
    local bucket = self:GetUnitFrameLookupTable(registryKey)
    return bucket and bucket[registryKey]
end

--- @param category string
--- @param callback fun(registryKey: string, frameObject: LUIE_CustomFrameObject)
function LUIE_CustomFrames_Manager:ForEachFrameInBucket(category, callback)
    local bucket = self:GetUnitFrameLookupTable(nil, category)
    if not bucket then
        return
    end
    for registryKey, frameObject in pairs(bucket) do
        callback(registryKey, frameObject)
    end
end

--- @param callback fun(registryKey: string, frameObject: LUIE_CustomFrameObject)
function LUIE_CustomFrames_Manager:ForEachRegisteredFrame(callback)
    self:ForEachFrameInBucket(CATEGORY_STATIC, callback)
    self:ForEachFrameInBucket(CATEGORY_SMALL_GROUP, callback)
    self:ForEachFrameInBucket(CATEGORY_RAID, callback)
    self:ForEachFrameInBucket(CATEGORY_PET, callback)
end

--- @param category string
--- @return LUIE_CustomFrameObject|nil
function LUIE_CustomFrames_Manager:GetCategoryAnchorFrame(category)
    if category == CATEGORY_SMALL_GROUP then
        return self:GetFrame("SmallGroup1")
    elseif category == CATEGORY_RAID then
        return self:GetFrame("RaidGroup1")
    elseif category == CATEGORY_PET then
        return self:GetFrame("PetGroup1")
    end
    return nil
end

--- @param registryKey string
--- @param frameObject LUIE_CustomFrameObject
--- @param category string
function LUIE_CustomFrames_Manager:RegisterFrame(registryKey, frameObject, category)
    local bucket = self:GetUnitFrameLookupTable(registryKey, category)
    if bucket then
        bucket[registryKey] = frameObject
    end
    UnitFrames.CustomFrames[registryKey] = frameObject
end

--- @param registryKey string
--- @param builtTable table
--- @param category string
--- @param visualizerSetupFunction function|nil
--- @return LUIE_CustomFrameObject
function LUIE_CustomFrames_Manager:CreateFrame(registryKey, builtTable, category, visualizerSetupFunction)
    local existing = self:GetFrame(registryKey)
    if existing then
        if existing.tlw and not existing.tlw.hudSceneFragment then
            LUIE.CustomFramesShared.RegisterCustomFrameHudFragment(existing.tlw)
        end
        if visualizerSetupFunction and not existing.attributeVisualizer then
            visualizerSetupFunction(existing)
        end
        return existing
    end

    local frameObject = LUIE_CustomFrameObject.WrapBuiltTable(builtTable, registryKey, category)
    self:RegisterFrame(registryKey, frameObject, category)

    if frameObject.tlw and not frameObject.tlw.hudSceneFragment then
        LUIE.CustomFramesShared.RegisterCustomFrameHudFragment(frameObject.tlw)
    end

    if visualizerSetupFunction then
        visualizerSetupFunction(frameObject)
        if frameObject.attributeVisualizer and DoesUnitExist(frameObject:GetVisualizerUnitTag()) then
            frameObject.attributeVisualizer:OnUnitChanged()
        end
    end

    return frameObject
end

UnitFrames.CustomFramesManager = LUIE_CustomFrames_Manager:New()
