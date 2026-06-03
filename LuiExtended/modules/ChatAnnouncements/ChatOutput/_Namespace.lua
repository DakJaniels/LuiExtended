-- -----------------------------------------------------------------------------
--  LuiExtended — Chat output routing (LUIE.SV.ChatOutput)
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

--- Account-wide chat print routing (tabs, timestamps, LibChatMessage, pChat/rChat).
--- @class LUIE_ChatOutput : ZO_InitializingObject
--- @field libChatMessage table|nil LibChatMessage proxy instance
--- @field formatterWrappers table<any, { innerFormatter: function, outerFormatter: function }>
--- @field playerActivatedHandlerRegistered boolean
--- @field externalChatInitializerCallbacksRegistered boolean
local LUIE_ChatOutput = ZO_InitializingObject:Subclass()

function LUIE_ChatOutput:Initialize()
    self.libChatMessage = nil
    self.formatterWrappers = {}
    self.playerActivatedHandlerRegistered = false
    self.externalChatInitializerCallbacksRegistered = false
end

--- @class (partial) ChatAnnouncements
--- @field ChatOutput LUIE_ChatOutput
--- @field ChatOutputClass LUIE_ChatOutput
ChatAnnouncements.ChatOutputClass = LUIE_ChatOutput
ChatAnnouncements.ChatOutput = LUIE_ChatOutput:New()
