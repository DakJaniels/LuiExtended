---@diagnostic disable: duplicate-doc-field
-- -----------------------------------------------------------------------------
--  LuiExtended — ChatOutput / ChatOutputSettingsUI (hand-maintained EmmyLua)
-- -----------------------------------------------------------------------------

--- @class LUIE_ChatOutput : ZO_InitializingObject
--- @field libChatMessage table|nil
--- @field formatterWrappers table<any, { innerFormatter: function, outerFormatter: function }>
--- @field playerActivatedHandlerRegistered boolean
--- @field externalChatInitializerCallbacksRegistered boolean
--- @field Initialize fun(self: LUIE_ChatOutput)
--- @field GetChatOutputSavedVars fun(self: LUIE_ChatOutput): LUIE_ChatOutputDefaults|nil
--- @field Print fun(self: LUIE_ChatOutput, messageText: string, isSystem?: boolean)
--- @field DeliverToSelectedChatTabs fun(self: LUIE_ChatOutput, messageText: string, isSystem?: boolean)
--- @field IsChatCategoryEnabledOnTab fun(self: LUIE_ChatOutput, chatContainer: table, tabIndex: integer, category: integer): boolean
--- @field FormatForDisplay fun(self: LUIE_ChatOutput, rawMessage: string): string
--- @field InitializePrintRouting fun(self: LUIE_ChatOutput)
--- @field InitializeRouterIntegration fun(self: LUIE_ChatOutput, caModuleEnabled: boolean)
--- @field Initialize fun(self: LUIE_ChatOutput, caModuleEnabled: boolean)
--- @field ApplyLibChatMessageTimePrefixSettings fun(self: LUIE_ChatOutput)
--- @field IsLibChatMessageTimeFormatLockedByPChat fun(self: LUIE_ChatOutput): boolean
--- @field GetTimestampFormatStringForLibChatMessageSync fun(self: LUIE_ChatOutput): string|nil
--- @field SyncLuiExtendedTimestampFormatToLibChatMessage fun(self: LUIE_ChatOutput)
--- @field LuiExtendedFormatToLibChatMessageOsDate fun(self: LUIE_ChatOutput, luiFormat: string|nil): string Maps LUIE tokens to os.date via zo_tokenize/scanner only (not CreateTimestamp).
--- @field LooksLikeLuiExtendedTimestampFormat fun(self: LUIE_ChatOutput, formatStr: string|nil): boolean
--- @field LuiExtendedFormatUsesMilliseconds fun(self: LUIE_ChatOutput, formatStr: string|nil): boolean
--- @field ShouldUseExternalFormatting fun(self: LUIE_ChatOutput): boolean
--- @field IsPChatChatRestoreEnabled fun(self: LUIE_ChatOutput): boolean
--- @field GetMaxChatTabIndex fun(self: LUIE_ChatOutput): integer
--- @field GetChatTabSettingsSlotCount fun(self: LUIE_ChatOutput): integer
--- @field IsChatTabIndexActiveForSettings fun(self: LUIE_ChatOutput, tabIndex: integer): boolean
--- @field GetChatTabSettingsLabel fun(self: LUIE_ChatOutput, tabIndex: integer): string
--- @field GetChatTabSettingsShortLabel fun(self: LUIE_ChatOutput, tabIndex: integer): string
--- @field GetPrimaryChatContainerForSettings fun(self: LUIE_ChatOutput): table|nil
--- @field IsSystemCategoryEnabledOnTabForSettings fun(self: LUIE_ChatOutput, tabIndex: integer): boolean
--- @field SetSystemCategoryEnabledOnTabForSettings fun(self: LUIE_ChatOutput, tabIndex: integer, enabled: boolean)
LUIE_ChatOutput = {}

--- @class LUIE_ChatOutputSettingsUI : ZO_InitializingObject
--- @field chatOutput LUIE_ChatOutput|nil
--- @field chatTabLAMRefreshRegistered boolean
--- @field Initialize fun(self: LUIE_ChatOutputSettingsUI, chatOutput?: LUIE_ChatOutput|nil)
--- @field GetChatOutputSettings fun(self: LUIE_ChatOutputSettingsUI): LUIE_ChatOutputDefaults|nil
--- @field GetChatOutputDefaults fun(self: LUIE_ChatOutputSettingsUI): LUIE_ChatOutputDefaults
--- @field BuildChatOutputLAMControls fun(self: LUIE_ChatOutputSettingsUI, settingsApi: table): table
--- @field BuildLibChatMessageLAMControls fun(self: LUIE_ChatOutputSettingsUI, settingsApi: table): table
--- @field AppendChatOutputConsoleControls fun(self: LUIE_ChatOutputSettingsUI, settings: table, LHAS: table)
LUIE_ChatOutputSettingsUI = {}

--- @class (partial) ChatAnnouncements
--- @field ChatOutput LUIE_ChatOutput
--- @field ChatOutputClass LUIE_ChatOutput

--- @class (partial) LuiExtended
--- @field chatOutputSettingsUI LUIE_ChatOutputSettingsUI|nil
