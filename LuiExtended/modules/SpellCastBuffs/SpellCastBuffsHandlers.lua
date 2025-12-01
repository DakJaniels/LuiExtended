-- -----------------------------------------------------------------------------
--  LuiExtended - SpellCastBuffs Handlers
--  License: The MIT License (MIT)
-- -----------------------------------------------------------------------------

-- Global handler functions for XML event handlers

--- @class (partial) LuiExtended
local LUIE = LUIE

local SpellCastBuffs = LUIE.SpellCastBuffs
local moduleName = "SpellCastBuffs"
local eventManager = EVENT_MANAGER

-- TopLevelControl OnMoveStop handlers (with grid snapping support)
---
--- @param self LUIE_SpellCastBuffs_PlayerBuffs
function LUIE_SpellCastBuffs_PlayerBuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    SpellCastBuffs.SV.playerbOffsetX = left
    SpellCastBuffs.SV.playerbOffsetY = top
end

---
--- @param self LUIE_SpellCastBuffs_PlayerDebuffs
function LUIE_SpellCastBuffs_PlayerDebuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    SpellCastBuffs.SV.playerdOffsetX = left
    SpellCastBuffs.SV.playerdOffsetY = top
end

---
--- @param self LUIE_SpellCastBuffs_TargetBuffs
function LUIE_SpellCastBuffs_TargetBuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    SpellCastBuffs.SV.targetbOffsetX = left
    SpellCastBuffs.SV.targetbOffsetY = top
end

---
--- @param self LUIE_SpellCastBuffs_TargetDebuffs
function LUIE_SpellCastBuffs_TargetDebuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    SpellCastBuffs.SV.targetdOffsetX = left
    SpellCastBuffs.SV.targetdOffsetY = top
end

---
--- @param self LUIE_SpellCastBuffs_ProminentBuffs
function LUIE_SpellCastBuffs_ProminentBuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    if self.alignVertical then
        SpellCastBuffs.SV.prominentbVOffsetX = left
        SpellCastBuffs.SV.prominentbVOffsetY = top
    else
        SpellCastBuffs.SV.prominentbHOffsetX = left
        SpellCastBuffs.SV.prominentbHOffsetY = top
    end
end

---
--- @param self LUIE_SpellCastBuffs_ProminentDebuffs
function LUIE_SpellCastBuffs_ProminentDebuffs_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    if self.alignVertical then
        SpellCastBuffs.SV.prominentdVOffsetX = left
        SpellCastBuffs.SV.prominentdVOffsetY = top
    else
        SpellCastBuffs.SV.prominentdHOffsetX = left
        SpellCastBuffs.SV.prominentdHOffsetY = top
    end
end

---
--- @param self LUIE_SpellCastBuffs_PlayerLong
function LUIE_SpellCastBuffs_PlayerLong_OnMoveStop(self)
    local left, top = self:GetLeft(), self:GetTop()
    -- Apply grid snapping if enabled
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_buffs then
        left, top = LUIE.ApplyGridSnap(left, top, "buffs")
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
    if self.alignVertical then
        SpellCastBuffs.SV.playerVOffsetX = left
        SpellCastBuffs.SV.playerVOffsetY = top
    else
        SpellCastBuffs.SV.playerHOffsetX = left
        SpellCastBuffs.SV.playerHOffsetY = top
    end
end

-- Buff icon mouse event handlers (for virtual template)
---
--- @param self LUIE_SpellCastBuffIcon
function LUIE_SpellCastBuffIcon_OnMouseEnter(self)
    SpellCastBuffs.Buff_OnMouseEnter(self)
end

---
--- @param self LUIE_SpellCastBuffIcon
function LUIE_SpellCastBuffIcon_OnMouseExit(self)
    SpellCastBuffs.Buff_OnMouseExit(self)
end

---
--- @param self LUIE_SpellCastBuffIcon
--- @param button MouseButtonIndex
--- @param upInside boolean
--- @param ctrl boolean
--- @param alt boolean
--- @param shift boolean
--- @param command boolean
function LUIE_SpellCastBuffIcon_OnMouseUp(self, button, upInside, ctrl, alt, shift, command)
    SpellCastBuffs.Buff_OnMouseUp(self, button, upInside)
end

-- TopLevelControl OnMoveStart handler (shared by all containers)
---
--- @param self TopLevelWindow
function LUIE_SpellCastBuffs_OnMoveStart(self)
    eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
        if self.preview and self.preview.anchorLabel then
            self.preview.anchorLabel:SetText(string.format("%d, %d", self:GetLeft(), self:GetTop()))
        end
    end)
end
