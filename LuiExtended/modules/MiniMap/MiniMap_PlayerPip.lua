-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

--- Centre character arrow (`LUIE_MiniMap_Player`, GetMapPlayerPosition heading) and camera pip
--- (`LUIE_MiniMap_PlayerCam`, GetPlayerCameraHeading). Both sit on the root control, anchored to the scroll
--- centre, and only show while the map follows the player. The camera-heading pip itself is the
--- world-map player pin in MiniMap_PinLayer, which stays visible in both modes (see IsPlayerPinEntryHidden).
--- @class LUIE_MiniMap_PlayerPip : ZO_InitializingObject
--- @field panAndZoom LUIE_MiniMap_PanAndZoom
--- @field player TextureControl
--- @field playerCam TextureControl
--- @field lastPlayerHeading number|nil
--- @field lastCameraHeading number|nil
LUIE_MiniMap_PlayerPip = ZO_InitializingObject:Subclass()

--- @param playerControl TextureControl
--- @param playerCamControl TextureControl
--- @param scrollControl ScrollControl
--- @param panAndZoom LUIE_MiniMap_PanAndZoom
function LUIE_MiniMap_PlayerPip:Initialize(playerControl, playerCamControl, scrollControl, panAndZoom)
    self.panAndZoom = panAndZoom
    self.player = playerControl
    self.playerCam = playerCamControl
    self.lastPlayerHeading = nil
    self.lastCameraHeading = nil

    self.player:SetMouseEnabled(false)
    self.playerCam:SetMouseEnabled(false)
    self.player:ClearAnchors()
    self.player:SetAnchor(CENTER, scrollControl, CENTER, 0, 0)
    self.playerCam:ClearAnchors()
    self.playerCam:SetAnchor(CENTER, scrollControl, CENTER, 0, 0)
    -- TextureControl:SetAddressMode / SetBlendMode (ESOUIDocumentation.txt)
    self.playerCam:SetAddressMode(TEX_MODE_CLAMP)
    self.playerCam:SetBlendMode(TEX_BLEND_MODE_ALPHA)

    self:ApplyDimensions()
    self:ApplyColors()
    self:ApplyVisibility()
end

function LUIE_MiniMap_PlayerPip:ApplyDimensions()
    local drawSize = MiniMap.GetPlayerPinDrawSize()
    local cameraSize = zo_round(drawSize * MiniMap.PLAYER_CAMERA_PIP_SIZE_RATIO)
    self.player:SetResizeToFitFile(false)
    self.player:SetDimensions(drawSize, drawSize)
    self.playerCam:SetResizeToFitFile(false)
    self.playerCam:SetDimensions(cameraSize, cameraSize)
end

function LUIE_MiniMap_PlayerPip:ApplyColors()
    self.player:SetColor(MiniMap.GetPlayerPipColor())
    self.playerCam:SetColor(MiniMap.GetPlayerCameraPipColor())
end

--- Arrow is hidden unless following and `showPlayerPip`; the camera pip is hidden unless following.
function LUIE_MiniMap_PlayerPip:ApplyVisibility()
    local followsPlayer = self.panAndZoom:GetFollowsPlayer()
    local showPlayerPip = MiniMap.SV.showPlayerPip ~= false
    self.player:SetHidden((not followsPlayer) or (not showPlayerPip))
    self.playerCam:SetHidden(not followsPlayer)
    if followsPlayer then
        self.player:SetDrawLayer(DL_OVERLAY)
        self.player:SetDrawTier(DT_HIGH)
        self.player:SetDrawLevel(2)
        self.playerCam:SetDrawLayer(DL_OVERLAY)
        self.playerCam:SetDrawTier(DT_HIGH)
        self.playerCam:SetDrawLevel(1)
        self.lastPlayerHeading = nil
        self.lastCameraHeading = nil
    end
end

--- Per frame (LUIE_MiniMap_Manager:OnFrameUpdate): arrow uses the player heading from GetMapPlayerPosition, camera pip uses GetPlayerCameraHeading.
--- @param playerHeading number|nil
--- @param cameraHeading number
function LUIE_MiniMap_PlayerPip:UpdateHeadings(playerHeading, cameraHeading)
    if playerHeading ~= nil and playerHeading ~= self.lastPlayerHeading then
        self.lastPlayerHeading = playerHeading
        self.player:SetTextureRotation(playerHeading)
    end
    if cameraHeading ~= self.lastCameraHeading then
        self.lastCameraHeading = cameraHeading
        self.playerCam:SetTextureRotation(cameraHeading)
    end
end
