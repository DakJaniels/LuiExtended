-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
--  LuaLS: canonical frame types in modules/UnitFrames/_annotations/*.meta.lua
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

--- @type LUIE.CustomFramesShared
local Shared = LUIE.CustomFramesShared

--- @class LUIE_PooledCustomFrameDataObject : ZO_InitializingObject
LUIE_PooledCustomFrameDataObject = ZO_InitializingObject:Subclass()

function LUIE_PooledCustomFrameDataObject:Reset()
end

--- @param ... unknown
function LUIE_PooledCustomFrameDataObject:BuildStaticData(...)
end

function LUIE_PooledCustomFrameDataObject:BuildData(...)
    self:BuildStaticData(...)
    self:RefreshDynamicData()
end

function LUIE_PooledCustomFrameDataObject:RefreshDynamicData()
end

--- @class LUIE_CustomFramePowerData_Base : LUIE_PooledCustomFrameDataObject
LUIE_CustomFramePowerData_Base = LUIE_PooledCustomFrameDataObject:Subclass()

--- Wire UAV-related overlays on a health (or power) row after XML references exist.
--- @param powerBar UnitFrames.CustomFramePowerEntry|nil
--- @param frame UnitFrames.CustomFrameUnitEntry|nil
function LUIE_CustomFramePowerData_Base.BuildAttributeVisualControls(powerBar, frame)
    if not powerBar or not powerBar.backdrop or not powerBar.bar then
        return
    end

    if powerBar.noHealingOverlay then
        powerBar.noHealingOverlay:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
        powerBar.noHealingOverlay:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
        powerBar.noHealingOverlay:SetTexture(LUIE_MEDIA_UNITFRAMES_TEXTURES_DIAGONAL_DDS)
        powerBar.noHealingOverlay:SetDrawLevel(Shared.HEALTH_BAR_FILL_DRAW_LEVEL + 1)
        powerBar.noHealingOverlay:SetHidden(true)
        powerBar.noHealingOverlay:SetAlpha(0)
        powerBar.noHealingOverlay:SetColor(0.8, 0.1, 0.1, 0.5)
    end

    if powerBar.labelOne then
        powerBar.labelOne:SetDrawTier(DT_HIGH)
        powerBar.labelOne:SetDrawLayer(DL_OVERLAY)
        powerBar.labelOne:SetDrawLevel(10)
    end
    if powerBar.labelTwo then
        powerBar.labelTwo:SetDrawTier(DT_HIGH)
        powerBar.labelTwo:SetDrawLayer(DL_OVERLAY)
        powerBar.labelTwo:SetDrawLevel(10)
    end
    if powerBar.label then
        powerBar.label:SetDrawTier(DT_HIGH)
        powerBar.label:SetDrawLayer(DL_OVERLAY)
        powerBar.label:SetDrawLevel(10)
    end
    if frame and frame.roleIcon then
        frame.roleIcon:SetDrawTier(DT_HIGH)
        frame.roleIcon:SetDrawLayer(DL_OVERLAY)
        frame.roleIcon:SetDrawLevel(10)
    end

    if powerBar.noHealingStripe then
        powerBar.noHealingStripe:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
        powerBar.noHealingStripe:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
        powerBar.noHealingStripe:SetTexture(LUIE_MEDIA_UNITFRAMES_TEXTURES_DIAGONAL_DDS)
        powerBar.noHealingStripe:SetDrawLevel(Shared.HEALTH_BAR_FILL_DRAW_LEVEL + 1)
        powerBar.noHealingStripe:SetColor(1, 0.3, 0.3, 0.8)
        powerBar.noHealingStripe:SetHidden(true)
    end

    if powerBar.noHealingOverlay and not powerBar.noHealingFadeAnimation then
        powerBar.noHealingFadeAnimation = Shared.CreateNoHealingFadeAnimation(
            powerBar.noHealingOverlay,
            powerBar.noHealingStripe
        )
    end

    if powerBar.possessionOverlay then
        powerBar.possessionOverlay:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 0, -2)
        powerBar.possessionOverlay:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, 0, 2)
        powerBar.possessionOverlay:SetDrawTier(DT_HIGH)
        powerBar.possessionOverlay:SetDrawLayer(DL_CONTROLS)

        if not powerBar.possessionGlowLeft then
            powerBar.possessionGlowLeft = powerBar.possessionOverlay:GetNamedChild("_GlowLeft")
            powerBar.possessionGlowRight = powerBar.possessionOverlay:GetNamedChild("_GlowRight")
            powerBar.possessionGlowCenter = powerBar.possessionOverlay:GetNamedChild("_GlowCenter")

            if powerBar.bar then
                powerBar.possessionHalo = Shared.CreatePossessionHaloAnimation(powerBar.backdrop, powerBar.bar)
            end
        end
    end
end

function LUIE_CustomFramePowerData_Base:ApplyRegenStrips(frameConfig)
    if not UnitFrames.SV[frameConfig.enableFlag] then
        return
    end

    for i = frameConfig.startIndex, frameConfig.endIndex do
        local unitTag = frameConfig.prefix .. (i == 0 and "" or i)
        local frame = UnitFrames.CustomFrames[unitTag]

        if frame then
            local powerTypeList =
            {
                COMBAT_MECHANIC_FLAGS_HEALTH,
                COMBAT_MECHANIC_FLAGS_MAGICKA,
                COMBAT_MECHANIC_FLAGS_STAMINA,
            }
            local powerTypeKey = nil
            local powerType
            while true do
                powerTypeKey, powerType = next(powerTypeList, powerTypeKey)
                if powerTypeKey == nil then break end
                if frame[powerType] then
                    local backdrop = frame[powerType].backdrop
                    local size1 = UnitFrames.SV[frameConfig.widthSV]
                    local size2 = UnitFrames.SV[frameConfig.heightSV]

                    if size1 and size2 then
                        local heightReduction = size2 * frameConfig.heightMultiplier
                        local dims = { size1 - 4, size2 - heightReduction }

                        frame[powerType].regen1 = Shared.CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, dims, 0.55, "regen1")
                        frame[powerType].regen2 = Shared.CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, dims, 0.55, "regen2")
                        frame[powerType].degen1 = Shared.CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, dims, 0.55, "degen1")
                        frame[powerType].degen2 = Shared.CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, dims, 0.55, "degen2")
                    end
                end
            end
        end
    end
end

function LUIE_CustomFramePowerData_Base:ApplyArmorAndPowerOverlays(frameConfig)
    local armorEnabled = frameConfig.enableFlag and UnitFrames.SV[frameConfig.enableFlag]
    local powerEnabled = frameConfig.powerEnableFlag and UnitFrames.SV[frameConfig.powerEnableFlag]
    if not armorEnabled and not powerEnabled then
        return
    end

    for i = frameConfig.startIndex, frameConfig.endIndex do
        local unitTag = frameConfig.prefix .. (i == 0 and "" or i)
        local frame = UnitFrames.CustomFrames[unitTag]

        if frame and frame[COMBAT_MECHANIC_FLAGS_HEALTH] then
            if not frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat then
                frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat = {}
            end

            local backdrop = frame[COMBAT_MECHANIC_FLAGS_HEALTH].backdrop
            local bar = frame[COMBAT_MECHANIC_FLAGS_HEALTH].bar
            if armorEnabled then
                frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_ARMOR_RATING] =
                {
                    ["dec"] = Shared.CreateDecreasedArmorOverlay(backdrop, false),
                    ["inc"] = backdrop:GetNamedChild("_ArmorInc"),
                }
            end
            if powerEnabled and bar then
                frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_POWER] =
                {
                    ["inc"] = Shared.CreateIncreasedPowerTexture(backdrop, bar),
                }
            end
        end
    end
end

--- @param frame UnitFrames.CustomFrameUnitEntry
--- @return table|nil savedHealth row { powerValue, powerMax, powerEffectiveMax, shield, trauma }
local function GetSavedHealthForCustomFrame(frame)
    if not frame then
        return nil
    end
    local tag = frame.GetVisualizerUnitTag and frame:GetVisualizerUnitTag()
    if tag and UnitFrames.savedHealth[tag] then
        return UnitFrames.savedHealth[tag]
    end
    local registryKey = frame.frameRegistryKey
    if registryKey then
        if string.sub(registryKey, 1, 10) == "SmallGroup" then
            local index = tonumber(string.sub(registryKey, 11))
            if index and UnitFrames.savedHealth["group" .. index] then
                return UnitFrames.savedHealth["group" .. index]
            end
        elseif string.sub(registryKey, 1, 9) == "RaidGroup" then
            local index = tonumber(string.sub(registryKey, 10))
            if index and UnitFrames.savedHealth["group" .. index] then
                return UnitFrames.savedHealth["group" .. index]
            end
        end
    end
    return nil
end

--- @param frame UnitFrames.CustomFrameUnitEntry
--- @param shieldOverlay boolean
function LUIE_CustomFramePowerData_Base:ApplyShieldBarMode(frame, shieldOverlay)
    local powerBar = frame[COMBAT_MECHANIC_FLAGS_HEALTH]
    if not powerBar or not powerBar.shield then
        return
    end

    powerBar.shield:ClearAnchors()
    if shieldOverlay then
        powerBar.shield:SetParent(powerBar.backdrop)
        if UnitFrames.SV.CustomShieldBarFull then
            powerBar.shield:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
            powerBar.shield:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
        else
            powerBar.shield:SetAnchor(BOTTOMLEFT, powerBar.backdrop, BOTTOMLEFT, 1, 1)
            powerBar.shield:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
            powerBar.shield:SetHeight(UnitFrames.SV.CustomShieldBarHeight)
        end
    else
        if not powerBar.shieldbackdrop then
            powerBar.shieldbackdrop = frame.control:CreateControl("$(parent)HealthShieldBackdrop", CT_BACKDROP)
            powerBar.shieldbackdrop:SetCenterColor(0, 0, 0, 0.4)
            powerBar.shieldbackdrop:SetEdgeColor(0, 0, 0, 0.6)
            powerBar.shieldbackdrop:SetEdgeTexture("", 8, 1, 1, 1)
            powerBar.shieldbackdrop:SetDrawLayer(DL_BACKGROUND)
            powerBar.shieldbackdrop:SetHidden(true)
        end
        powerBar.shield:SetParent(powerBar.shieldbackdrop)
        powerBar.shield:SetAnchor(TOPLEFT, powerBar.shieldbackdrop, TOPLEFT, 1, 1)
        powerBar.shield:SetAnchor(BOTTOMRIGHT, powerBar.shieldbackdrop, BOTTOMRIGHT, -1, -1)
    end
    powerBar.shield:SetDrawLevel(Shared.HEALTH_BAR_FILL_DRAW_LEVEL + 2)

    local saved = GetSavedHealthForCustomFrame(frame)
    local shieldValue = saved and saved[4] or 0
    if shieldValue <= 0 then
        powerBar.shield:SetValue(0)
        powerBar.shield:SetHidden(true)
        if powerBar.shieldbackdrop then
            powerBar.shieldbackdrop:SetHidden(true)
        end
    end

    if powerBar.trauma then
        local traumaValue = saved and saved[5] or 0
        if traumaValue <= 0 then
            powerBar.trauma:SetValue(0)
            powerBar.trauma:SetHidden(true)
        end
    end
end

--- @param unitTag string
--- @param powerType integer
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
--- @param isDead boolean
--- @param forceInit boolean|nil
function LUIE_CustomFramePowerData_Base:UpdatePower(unitTag, powerType, powerValue, powerMax, powerEffectiveMax, isDead, forceInit)
    local frame = UnitFrames.CustomFrames[unitTag]
    if not frame or not frame[powerType] then
        return
    end
    UnitFrames.UpdateAttribute(unitTag, powerType, frame[powerType], powerValue, powerEffectiveMax, isDead, forceInit)
end

--- Routes custom-frame power updates through frame data power API.
function UnitFrames.UpdateCustomFramePower(unitTag, powerType, powerValue, powerMax, powerEffectiveMax, isDead, forceInit)
    LUIE.CustomFramesPowerData:UpdatePower(unitTag, powerType, powerValue, powerMax, powerEffectiveMax, isDead, forceInit)
end

--- @class LUIE_CustomFrameData_Base : LUIE_PooledCustomFrameDataObject
--- @field unitTag string|nil
--- @field frameRegistryKey string|nil
--- @field frameCategory string|nil
--- @field visualizerUnitTag string|nil
--- @field attributeVisualizer LUIE_UnitAttributeVisualizer|nil
--- @field hudSceneFragment ZO_HUDFadeSceneFragment|nil
--- @field tlw LUIE_PositionableTopLevelWindow|nil
--- @field control Control|nil
--- @field roleIcon Control|nil
--- @field resourceMagicka UnitFrames.CustomFrameResourceRow|nil
--- @field resourceStamina UnitFrames.CustomFrameResourceRow|nil
--- @field [integer] UnitFrames.CustomFramePowerEntry
--- @field [string] unknown
LUIE_CustomFrameData_Base = LUIE_PooledCustomFrameDataObject:Subclass()
LUIE_CustomFrameData_Base:IGNORE_UNIMPLEMENTED()

--- ZOS-style custom unit frame object (alias for frame data base metatable).
--- @class LUIE_CustomFrameObject : LUIE_CustomFrameData_Base
LUIE_CustomFrameObject = LUIE_CustomFrameData_Base

--- Promote a built frame table to ZOS-style frame object semantics (backward-compatible field access).
--- @param frame table
--- @param registryKey string CustomFrames registry key (e.g. SmallGroup1)
--- @param category string
--- @return LUIE_CustomFrameObject
function LUIE_CustomFrameObject.WrapBuiltTable(frame, registryKey, category)
    setmetatable(frame, LUIE_CustomFrameObject)
    frame.frameRegistryKey = registryKey
    frame.frameCategory = category
    if frame.tlw and frame.tlw.hudSceneFragment then
        frame.hudSceneFragment = frame.tlw.hudSceneFragment
    end
    return frame
end

--- @deprecated Use CustomFramesManager:CreateFrame or LUIE_CustomFrameObject.WrapBuiltTable
function LUIE_CustomFrameData_Base.Adopt(frame, registryKey, category)
    return LUIE_CustomFrameObject.WrapBuiltTable(frame, registryKey, category)
end

--- @param unitTag string
--- @param frame table
function LUIE_CustomFrameData_Base.Register(unitTag, frame)
    UnitFrames.CustomFrames[unitTag] = frame
end

function LUIE_CustomFrameData_Base:GetUnitTag()
    return self.unitTag or self.frameRegistryKey
end

function LUIE_CustomFrameData_Base:GetFrameRegistryKey()
    return self.frameRegistryKey
end

function LUIE_CustomFrameData_Base:GetFrameCategory()
    return self.frameCategory
end

function LUIE_CustomFrameData_Base:GetTopLevel()
    return self.tlw
end

--- Game unit tag for UnitFrames.GetVisualizerForUnit / UAV (may differ from registry key before group alias).
function LUIE_CustomFrameData_Base:GetVisualizerUnitTag()
    return self.unitTag or self.visualizerUnitTag or self.frameRegistryKey
end

--- @param mechanic integer|string
--- @return UnitFrames.CustomFramePowerEntry|nil
function LUIE_CustomFrameData_Base:GetPowerEntry(mechanic)
    return self[mechanic]
end

function LUIE_CustomFrameData_Base:SetupPowerBarAnchors()
    local powerTypeList = { COMBAT_MECHANIC_FLAGS_HEALTH, COMBAT_MECHANIC_FLAGS_MAGICKA, COMBAT_MECHANIC_FLAGS_STAMINA, "alternative" }
    local powerTypeKey = nil
    local powerType
    while true do
        powerTypeKey, powerType = next(powerTypeList, powerTypeKey)
        if powerTypeKey == nil then break end
        local powerBar = self[powerType]

        if powerBar and powerBar.bar and powerBar.backdrop then
            powerBar.bar:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
            powerBar.bar:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)

            if powerBar.enlightenment then
                powerBar.enlightenment:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                powerBar.enlightenment:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
            end

            if powerBar.trauma then
                powerBar.trauma:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                powerBar.trauma:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
            end

            if powerBar.invulnerable then
                powerBar.invulnerable:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                powerBar.invulnerable:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
                powerBar.invulnerableInlay:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 3, 3)
                powerBar.invulnerableInlay:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -3, -3)
            end

            if powerType == COMBAT_MECHANIC_FLAGS_HEALTH or powerBar.noHealingOverlay or powerBar.possessionOverlay then
                LUIE_CustomFramePowerData_Base.BuildAttributeVisualControls(powerBar, self)
            end
        end
    end

    if self.resourceMagicka and self.resourceMagicka.bar then
        self.resourceMagicka.bar:SetAnchor(TOPLEFT, self.resourceMagicka.backdrop, TOPLEFT, 1, 1)
        self.resourceMagicka.bar:SetAnchor(BOTTOMRIGHT, self.resourceMagicka.backdrop, BOTTOMRIGHT, -1, -1)
    end
    if self.resourceStamina and self.resourceStamina.bar then
        self.resourceStamina.bar:SetAnchor(TOPLEFT, self.resourceStamina.backdrop, TOPLEFT, 1, 1)
        self.resourceStamina.bar:SetAnchor(BOTTOMRIGHT, self.resourceStamina.backdrop, BOTTOMRIGHT, -1, -1)
    end
end

function LUIE_CustomFrameData_Base:SetupMovementAndPreview(moduleName, eventManager)
    if not self.tlw then
        return
    end

    local function tlwOnMoveStart(tlwSelf)
        if tlwSelf.preview.anchorLabel then
            eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
                tlwSelf.preview.anchorLabel:SetText(zo_strformat("<<1>>, <<2>>", tlwSelf:GetLeft(), tlwSelf:GetTop()))
            end)
        end
    end

    local function tlwOnMoveStop(tlwSelf)
        eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
        UnitFrames.SV[tlwSelf.customPositionAttr] = { tlwSelf:GetLeft(), tlwSelf:GetTop() }
    end

    self.tlw:SetHandler("OnMoveStart", tlwOnMoveStart)
    self.tlw:SetHandler("OnMoveStop", tlwOnMoveStop)

    if not self.tlw.preview then
        return
    end

    self.tlw.preview.anchorTexture = self.tlw.preview:CreateControl("$(parent)AnchorTexture", CT_TEXTURE)
    self.tlw.preview.anchorTexture:SetAnchor(TOPLEFT, self.tlw.preview, TOPLEFT)
    self.tlw.preview.anchorTexture:SetDimensions(16, 16)
    self.tlw.preview.anchorTexture:SetTexture("/esoui/art/reticle/border_topleft.dds")
    self.tlw.preview.anchorTexture:SetDrawLayer(DL_OVERLAY)
    self.tlw.preview.anchorTexture:SetColor(1, 1, 0, 0.9)

    if not self.tlw.preview.anchorLabel then
        self.tlw.preview.anchorLabel = self.tlw.preview:CreateControl("$(parent)AnchorLabel", CT_LABEL)
        self.tlw.preview.anchorLabel:SetFont(LUIE.GetPositionLabelFont())
        self.tlw.preview.anchorLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.tlw.preview.anchorLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
        self.tlw.preview.anchorLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        self.tlw.preview.anchorLabel:SetAnchor(BOTTOMLEFT, self.tlw.preview, TOPLEFT, 0, -1)
        self.tlw.preview.anchorLabel:SetText("xxx, yyy")
        self.tlw.preview.anchorLabel:SetColor(1, 1, 0, 1)
        self.tlw.preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
        self.tlw.preview.anchorLabel:SetDrawTier(DT_MEDIUM)
        self.tlw.preview.anchorLabelBg = self.tlw.preview.anchorLabel:CreateControl("$(parent)Bg", CT_BACKDROP)
        self.tlw.preview.anchorLabelBg:SetCenterColor(0, 0, 0, 1)
        self.tlw.preview.anchorLabelBg:SetEdgeColor(0, 0, 0, 1)
        self.tlw.preview.anchorLabelBg:SetEdgeTexture("", 8, 1, 1, 1)
        self.tlw.preview.anchorLabelBg:SetDrawLayer(DL_BACKGROUND)
        self.tlw.preview.anchorLabelBg:SetAnchorFill(self.tlw.preview.anchorLabel)
        self.tlw.preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
        self.tlw.preview.anchorLabelBg:SetDrawTier(DT_LOW)
    else
        LUIE.ApplyPositionLabelFont(self.tlw.preview.anchorLabel)
    end
end

function LUIE_CustomFrameData_Base:RefreshDynamicData()
end

function LUIE_CustomFrameData_Base:OnUnitChanged()
end

--- Keeps per-frame UAV event filters aligned with `unitTag` after group/pet slot aliasing.
function LUIE_CustomFrameData_Base:SyncAttributeVisualizerUnitTag()
    if not self.attributeVisualizer then
        return
    end

    local gameTag = self.unitTag
    if gameTag and (string.sub(gameTag, 1, 5) == "group" or string.sub(gameTag, 1, 9) == "playerpet") then
        self.visualizerUnitTag = gameTag
        self.attributeVisualizer:SetUnitTag(gameTag)
    else
        self.visualizerUnitTag = nil
        self.attributeVisualizer:SetUnitTag(nil)
    end
end

--- @param mechanic integer|string
--- @return Control|nil
function LUIE_CustomFrameData_Base:GetPowerBackdrop(mechanic)
    local powerEntry = self[mechanic]
    return powerEntry and powerEntry.backdrop
end

--- @return LUIE_UnitAttributeVisualizer|nil
function LUIE_CustomFrameData_Base:GetAttributeVisualizer()
    return self.attributeVisualizer
end

--- @param soundTable table|nil
--- @return LUIE_UnitAttributeVisualizer
function LUIE_CustomFrameData_Base:CreateAttributeVisualizer(soundTable)
    if not self.attributeVisualizer then
        local unitTag = self:GetVisualizerUnitTag()
        local health = self:GetPowerBackdrop(COMBAT_MECHANIC_FLAGS_HEALTH)
        local magicka = self:GetPowerBackdrop(COMBAT_MECHANIC_FLAGS_MAGICKA)
        local stamina = self:GetPowerBackdrop(COMBAT_MECHANIC_FLAGS_STAMINA)
        self.attributeVisualizer = LUIE_UnitAttributeVisualizer:New(unitTag, soundTable, health, magicka, stamina)
        self.attributeVisualizer.customFrame = self
        local vizUnitTag = self:GetVisualizerUnitTag()
        if vizUnitTag then
            UnitFrames.Visualizers[vizUnitTag] = self.attributeVisualizer
        end
    end
    return self.attributeVisualizer
end

--- @class LUIE_GroupMemberCustomFrameData_Base : LUIE_CustomFrameData_Base
LUIE_GroupMemberCustomFrameData_Base = LUIE_CustomFrameData_Base:Subclass()
LUIE_GroupMemberCustomFrameData_Base:IGNORE_UNIMPLEMENTED()

LUIE_CustomFrameData_Base:MUST_IMPLEMENT("BuildStaticData")

--- @class LUIE_PlayerCustomFrameData : LUIE_CustomFrameData_Base
LUIE_PlayerCustomFrameData = LUIE_CustomFrameData_Base:Subclass()

--- @class LUIE_TargetCustomFrameData : LUIE_CustomFrameData_Base
LUIE_TargetCustomFrameData = LUIE_CustomFrameData_Base:Subclass()

--- @class LUIE_AvaTargetCustomFrameData : LUIE_CustomFrameData_Base
LUIE_AvaTargetCustomFrameData = LUIE_CustomFrameData_Base:Subclass()

--- @class LUIE_SmallGroupCustomFrameData : LUIE_GroupMemberCustomFrameData_Base
LUIE_SmallGroupCustomFrameData = LUIE_GroupMemberCustomFrameData_Base:Subclass()

--- @class LUIE_RaidCustomFrameData : LUIE_GroupMemberCustomFrameData_Base
LUIE_RaidCustomFrameData = LUIE_GroupMemberCustomFrameData_Base:Subclass()

--- @class LUIE_PetCustomFrameData : LUIE_GroupMemberCustomFrameData_Base
LUIE_PetCustomFrameData = LUIE_GroupMemberCustomFrameData_Base:Subclass()

--- @class LUIE_CompanionCustomFrameData : LUIE_CustomFrameData_Base
LUIE_CompanionCustomFrameData = LUIE_CustomFrameData_Base:Subclass()

--- @class LUIE_BossCustomFrameData : LUIE_CustomFrameData_Base
LUIE_BossCustomFrameData = LUIE_CustomFrameData_Base:Subclass()

--- @class LUIE_ControlledSiegeCustomFrameData : LUIE_CustomFrameData_Base
LUIE_ControlledSiegeCustomFrameData = LUIE_CustomFrameData_Base:Subclass()

function LUIE_ControlledSiegeCustomFrameData:BuildStaticData()
    local built =
    {
        ["unitTag"] = "controlledsiege",
    }
    UnitFrames.CustomFrames["controlledsiege"] = built
    UnitFrames.CustomFramesManager:CreateFrame("controlledsiege", built, "controlledsiege", LUIE_CustomFrameVisualizers.SetupControlledSiegeFrame)
end

function LUIE_ControlledSiegeCustomFrameData:BuildData()
    self:BuildStaticData()
end

LUIE.CustomFramesPowerData = LUIE_CustomFramePowerData_Base
