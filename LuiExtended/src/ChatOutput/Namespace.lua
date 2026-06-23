-- -----------------------------------------------------------------------------
--  LuiExtended — Chat output routing (LUIE.SV.ChatOutput)
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- Account-wide chat print routing (tabs, timestamps, LibChatMessage, pChat/rChat).
--- @class LUIE_ChatOutput : ZO_InitializingObject
--- @field libChatMessage table|nil LibChatMessage proxy instance
--- @field formatterWrappers table<any, { innerFormatter: function, outerFormatter: function }>
--- @field playerActivatedHandlerRegistered boolean
--- @field externalChatInitializerCallbacksRegistered boolean
--- @field noDeliverableTabWarningShown boolean
--- @field pendingPrintQueue { messageText: string, isSystem: boolean|nil }[]|nil
--- @field timestampColorHex string
local LUIE_ChatOutput = ZO_InitializingObject:Subclass()

function LUIE_ChatOutput:Initialize()
    self.libChatMessage = nil
    self.formatterWrappers = {}
    self.playerActivatedHandlerRegistered = false
    self.externalChatInitializerCallbacksRegistered = false
    self.noDeliverableTabWarningShown = false
    self.pendingPrintQueue = {}
    self.timestampColorHex = ZO_OFF_WHITE:ToHex()
end

LUIE.ChatOutputClass = LUIE_ChatOutput
LUIE.ChatOutput = LUIE_ChatOutput:New()
