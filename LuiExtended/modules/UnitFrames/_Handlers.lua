-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

--- Small-group / raid unit backdrop or top-info strip (`control`, `topInfo`) — `defaultUnitTag` set in CustomFrames build and refreshed in `_MenuFunctions.lua`.
--- @class LUIE_GroupFrameInteractionControl : Control
--- @field defaultUnitTag string

-- Right Click function for group frames - updated to match ZOS implementation
--- @param self LUIE_GroupFrameInteractionControl
--- @param button MouseButtonIndex Which mouse button was released; compare to MOUSE_BUTTON_INDEX_* constants.
--- @param upInside boolean True when the mouse was released over this control.
function UnitFrames.GroupFrames_OnMouseUp(self, button, upInside)
    local unitTag = self.defaultUnitTag
    if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
        ClearMenu()
        local isPlayer = AreUnitsEqual(unitTag, "player")
        local isLFG = DoesGroupModificationRequireVote()
        local displayName = zo_strformat("<<C:1>>", GetUnitDisplayName(unitTag))
        local characterName = GetUnitName(unitTag)
        local isOnline = IsUnitOnline(unitTag)
        local playerIsLeader = IsUnitGroupLeader("player")

        if isPlayer then
            AddMenuItem(GetString(SI_GROUP_LIST_MENU_LEAVE_GROUP), function ()
                ZO_Dialogs_ShowDialog("GROUP_LEAVE_DIALOG")
            end)
        elseif isOnline then
            if IsChatSystemAvailableForCurrentPlatform() then
                AddMenuItem(GetString(SI_SOCIAL_LIST_PANEL_WHISPER), function ()
                    StartChatInput("", CHAT_CHANNEL_WHISPER, characterName)
                end)
            end
            AddMenuItem(GetString(SI_SOCIAL_MENU_VISIT_HOUSE), function ()
                JumpToHouse(displayName)
            end)
            if not ZO_IsTributeLocked() then
                AddMenuItem(GetString(SI_SOCIAL_MENU_TRIBUTE_INVITE), function ()
                    InviteToTributeByDisplayName(displayName)
                end)
            end
            AddMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function ()
                JumpToGroupMember(characterName)
            end)
        end

        if not isPlayer and not IsFriend(displayName) and not IsIgnored(displayName) then
            AddMenuItem(GetString(SI_SOCIAL_MENU_ADD_FRIEND), function ()
                ZO_Dialogs_ShowDialog("REQUEST_FRIEND", { name = displayName })
            end)
        end

        if IsGroupModificationAvailable() then
            if playerIsLeader then
                if isPlayer then
                    if not isLFG then
                        AddMenuItem(GetString(SI_GROUP_LIST_MENU_DISBAND_GROUP), function ()
                            ZO_Dialogs_ShowDialog("GROUP_DISBAND_DIALOG")
                        end)
                    end
                else
                    if not isLFG then
                        AddMenuItem(GetString(SI_GROUP_LIST_MENU_KICK_FROM_GROUP), function ()
                            GroupKick(unitTag)
                        end)
                    end
                end
            end
        end

        -- Per design, promoting doesn't expressly fall under the mantle of "group modification"
        if playerIsLeader and not isPlayer and isOnline then
            AddMenuItem(GetString(SI_GROUP_LIST_MENU_PROMOTE_TO_LEADER), function ()
                GroupPromote(unitTag)
            end)
        end

        ShowMenu(self)
    end
end
