---@meta LibLazyCrafting
-- Optional dependency. LibLazyCrafting 4.042.
-- Craft functions are copied onto the table returned by `AddRequestingAddon`.
-- They are not methods of `LibLazyCrafting` itself, except `GetSetIndexes`.
-- `IsPerformingCraftProcess` returns the three fields of `isCurrentlyCrafting`.

---@alias LLC_CraftEvent
---| "success"
---| "item not found"
---| "not enough mats"
---| "not enough skill"
---| "no further craft items possible"
---| "initial stage of crafting complete"
---| "enchantment failed"
---| "item has been improved one stage, but is not yet at final quality"
---| "starting crafting"

---@class LLC_CraftResult
---@field bag integer|nil
---@field slot integer|nil
---@field reference string|nil

---@alias LLC_CraftCallback fun(event: LLC_CraftEvent, station: integer, result: LLC_CraftResult)

---@class LLC_CraftRequest
---@field type string|nil `"deconstruct"`, `"improvement"`, and the station craft types.
---@field reference string|nil
---@field Requester string|nil
---@field style integer|string|nil `LLC_FREE_STYLE_CHOICE` is the string `"free style choice"`.
---@field station integer|nil
---@field pattern integer|nil
---@field recipeIndex integer|nil

---@class LLC_Addon
---@field addonName string
---@field personalQueue LLC_CraftRequest[][] Seven station queues.
---@field autocraft boolean
---@field version number
---@field functionCallback LLC_CraftCallback
local LLC_Addon = {}

---@param patternIndex integer
---@param materialIndex integer
---@param materialQuantity integer
---@param styleIndex integer|string
---@param traitIndex integer
---@param useUniversalStyleItem boolean
---@param stationOverride integer
---@param setIndex integer
---@param quality integer
---@param autocraft boolean|nil
---@param reference string|nil
---@param potencyId integer|nil
---@param essenceId integer|nil
---@param aspectId integer|nil
---@param smithingQuantity integer|nil
---@return LLC_CraftRequest|nil
function LLC_Addon:CraftSmithingItem(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, useUniversalStyleItem, stationOverride, setIndex, quality, autocraft, reference, potencyId, essenceId, aspectId, smithingQuantity) end

---@param patternIndex integer
---@param isCP boolean
---@param level integer
---@param styleIndex integer|string
---@param traitIndex integer
---@param useUniversalStyleItem boolean
---@param stationOverride integer
---@param setIndex integer
---@param quality integer
---@param autocraft boolean|nil
---@param reference string|nil
---@param potencyId integer|nil
---@param essenceId integer|nil
---@param aspectId integer|nil
---@param smithingQuantity integer|nil
---@return LLC_CraftRequest|nil
function LLC_Addon:CraftSmithingItemByLevel(patternIndex, isCP, level, styleIndex, traitIndex, useUniversalStyleItem, stationOverride, setIndex, quality, autocraft, reference, potencyId, essenceId, aspectId, smithingQuantity) end

---@param itemLink string
---@param reference string|nil
function LLC_Addon:CraftSmithingItemFromLink(itemLink, reference) end

---@param bagIndex integer
---@param slotIndex integer
---@param newQuality integer
---@param autocraft boolean|nil
---@param reference string|nil
function LLC_Addon:ImproveSmithingItem(bagIndex, slotIndex, newQuality, autocraft, reference) end

---@param bagIndex integer
---@param slotIndex integer
---@param autocraft boolean|nil
---@param reference string|nil
function LLC_Addon:DeconstructSmithingItem(bagIndex, slotIndex, autocraft, reference) end

---@param isCP boolean
---@param level integer
---@return boolean
function LLC_Addon:isSmithingLevelValid(isCP, level) end

---@param request LLC_CraftRequest
---@param requirements table|nil
---@return table
function LLC_Addon:CompileRequirements(request, requirements) end

---@return table
function LLC_Addon:GetSetIndexes() end

---@param requestTable LLC_CraftRequest
---@return string|nil
function LLC_Addon:getItemLinkFromRequest(requestTable) end

---@param pattern integer
---@param isCP boolean
---@param level integer
---@param style integer|string
---@param trait integer
---@param station integer
---@param setIndex integer
---@param quality integer
---@param potencyId integer|nil
---@param essenceId integer|nil
---@param aspectId integer|nil
---@return string|nil
function LLC_Addon:getItemLinkFromParticulars(pattern, isCP, level, style, trait, station, setIndex, quality, potencyId, essenceId, aspectId) end

---@param text string
function LLC_Addon:importCraftableLinksFromString(text) end

---@param existingRequestTable LLC_CraftRequest
---@param glyphBag integer
---@param glyphSlot integer
function LLC_Addon:AddExistingGlyphToGear(existingRequestTable, glyphBag, glyphSlot) end

---@param existingRequestTable LLC_CraftRequest
---@param gearBag integer
---@param gearSlot integer
function LLC_Addon:AddGlyphToExistingGear(existingRequestTable, gearBag, gearSlot) end

---@param potencyBagId integer
---@param potencySlot integer
---@param essenceBagId integer
---@param essenceSlot integer
---@param aspectBagId integer
---@param aspectSlot integer
---@param autocraft boolean|nil
---@param reference string|nil
---@param gearRequestTable LLC_CraftRequest|nil
---@param quantity integer|nil
function LLC_Addon:CraftEnchantingGlyph(potencyBagId, potencySlot, essenceBagId, essenceSlot, aspectBagId, aspectSlot, autocraft, reference, gearRequestTable, quantity) end

--- Same function as `CraftEnchantingGlyph`.
function LLC_Addon:CraftEnchantingItem(...) end

---@param potencyItemID integer
---@param essenceItemID integer
---@param aspectItemID integer
---@param autocraft boolean|nil
---@param reference string|nil
---@param gearRequestTable LLC_CraftRequest|nil
---@param quantity integer|nil
function LLC_Addon:CraftEnchantingItemId(potencyItemID, essenceItemID, aspectItemID, autocraft, reference, gearRequestTable, quantity) end

---@param isCP boolean
---@param level integer
---@param enchantId integer
---@param quality integer
---@param autocraft boolean|nil
---@param reference string|nil
---@param gearRequestTableOrQuantity LLC_CraftRequest|integer|nil
function LLC_Addon:CraftEnchantingGlyphByAttributes(isCP, level, enchantId, quality, autocraft, reference, gearRequestTableOrQuantity) end

---@param isCP boolean
---@param level integer
---@param resultItemId integer
---@param quality integer
---@param autocraft boolean|nil
---@param reference string|nil
---@param gearRequestTableOrQuantity LLC_CraftRequest|integer|nil
function LLC_Addon:CraftEnchantingGlyphDesiredResult(isCP, level, resultItemId, quality, autocraft, reference, gearRequestTableOrQuantity) end

--- Dot call. The stored function has no `self` parameter.
---@param isCP boolean
---@param level integer
---@param enchantId integer
---@param quality integer
function LLC_Addon.EnchantAttributesToGlyphIds(isCP, level, enchantId, quality) end

---@param solventBagId integer
---@param solventSlotId integer
---@param reagent1BagId integer
---@param reagent1SlotId integer
---@param reagent2BagId integer
---@param reagent2SlotId integer
---@param reagent3BagId integer|nil
---@param reagent3SlotId integer|nil
---@param timesToMake integer
---@param autocraft boolean|nil
---@param reference string|nil
function LLC_Addon:CraftAlchemyPotion(solventBagId, solventSlotId, reagent1BagId, reagent1SlotId, reagent2BagId, reagent2SlotId, reagent3BagId, reagent3SlotId, timesToMake, autocraft, reference) end

---@param solventId integer
---@param reagentId1 integer
---@param reagentId2 integer
---@param reagentId3 integer|nil
---@param timesToMake integer
---@param autocraft boolean|nil
---@param reference string|nil
function LLC_Addon:CraftAlchemyItemId(solventId, reagentId1, reagentId2, reagentId3, timesToMake, autocraft, reference) end

---@param recipeId integer
---@param timesToMake integer
---@param autocraft boolean|nil
---@param reference string|nil
function LLC_Addon:CraftProvisioningItemByRecipeId(recipeId, timesToMake, autocraft, reference) end

--- Same function as `CraftProvisioningItemByRecipeId`.
function LLC_Addon:CraftFurnishingItemByRecipeItemId(...) end

---@param resultItemId integer
---@param timesToMake integer
---@param autocraft boolean|nil
---@param reference string|nil
function LLC_Addon:CraftProvisioningItemByResultItemId(resultItemId, timesToMake, autocraft, reference) end

--- Same function as `CraftProvisioningItemByResultItemId`.
function LLC_Addon:CraftFurnishingItemByResultItemId(...) end

---@param recipeListIndex integer
---@param recipeIndex integer
---@param timesToMake integer
---@param autocraft boolean|nil
---@param reference string|nil
function LLC_Addon:CraftProvisioningItemByRecipeIndex(recipeListIndex, recipeIndex, timesToMake, autocraft, reference) end

--- Same function as `CraftProvisioningItemByRecipeIndex`.
function LLC_Addon:CraftProvisioningItem(...) end

--- Same function as `CraftProvisioningItemByRecipeIndex`.
function LLC_Addon:CraftFurnishingItemByRecipeIndex(...) end

---@param station integer
---@param position integer
function LLC_Addon:craftItem(station, position) end

function LLC_Addon:CraftAllItems() end

---@param station integer
---@param position integer
function LLC_Addon:cancelItem(station, position) end

---@param reference string
function LLC_Addon:cancelItemByReference(reference) end

---@param reference string
function LLC_Addon:findItemByReference(reference) end

---@param requestTable LLC_CraftRequest
function LLC_Addon:getMatRequirements(requestTable) end

---@param newAutoCraftSetting boolean
function LLC_Addon:SetAllAutoCraft(newAutoCraftSetting) end

---@param itemId integer
---@return integer|nil bag
---@return integer slot
function LLC_Addon:findItemLocationById(itemId) end

---@param itemId integer
---@return string
function LLC_Addon:getItemLinkFromItemId(itemId) end

---@class LibLazyCrafting
---@field name string
---@field version number Library minor, 4.042 when this copy loaded.
---@field isCurrentlyCrafting [boolean, string, string] [1] active, [2] kind (`"enchanting"`, `"smithing"`, `"improve"`, `"alchemy"`, `"provisioning"`), [3] requester.
---@field craftingQueue table<string, LLC_CraftRequest[][]>
---@field craftInteractionTables table
---@field addonInteractionTables table<string, LLC_Addon>
---@field functionTable table<string, function>
LibLazyCrafting = {}

--- False when this version is not newer than the one already registered.
---@param widgetType string
---@param widgetVersion integer
---@return boolean
function LibLazyCrafting:RegisterWidget(widgetType, widgetVersion) end

---@return integer
function LibLazyCrafting.GetNextQueueOrder() end

---@param addonName string
---@param autocraft boolean|nil
---@param functionCallback LLC_CraftCallback
---@param optionalDebugAuthor string|nil
---@param styleTable table|nil
---@return LLC_Addon
function LibLazyCrafting:AddRequestingAddon(addonName, autocraft, functionCallback, optionalDebugAuthor, styleTable) end

---@param addonName string
---@param functionCallback LLC_CraftCallback
function LibLazyCrafting:AddListeningAddon(addonName, functionCallback) end

---@param addonName string
---@return LLC_Addon|nil
function LibLazyCrafting:GetRequestingAddon(addonName) end

--- Unpacks `isCurrentlyCrafting`: active, kind, requester. Nil when the field is missing.
---@return boolean|nil active
---@return string|nil kind
---@return string|nil requester
function LibLazyCrafting:IsPerformingCraftProcess() end

---@param itemSlot integer
function LibLazyCrafting:SetItemStatusNew(itemSlot) end

--- Also present on `LibLazyCrafting` itself, unlike the other craft helpers.
---@return table
function LibLazyCrafting.GetSetIndexes() end

---@type "success"
LLC_CRAFT_SUCCESS = "success"
---@type "item not found"
LLC_ITEM_TO_IMPROVE_NOT_FOUND = "item not found"
---@type "not enough mats"
LLC_INSUFFICIENT_MATERIALS = "not enough mats"
---@type "not enough skill"
LLC_INSUFFICIENT_SKILL = "not enough skill"
---@type "no further craft items possible"
LLC_NO_FURTHER_CRAFT_POSSIBLE = "no further craft items possible"
---@type "initial stage of crafting complete"
LLC_INITIAL_CRAFT_SUCCESS = "initial stage of crafting complete"
---@type "enchantment failed"
LLC_ENCHANTMENT_FAILED = "enchantment failed"
---@type "item has been improved one stage, but is not yet at final quality"
LLC_CRAFT_PARTIAL_IMPROVEMENT = "item has been improved one stage, but is not yet at final quality"
---@type "starting crafting"
LLC_CRAFT_BEGIN = "starting crafting"
--- Assigned from Smithing.lua, outside `Init`.
---@type "free style choice"
LLC_FREE_STYLE_CHOICE = "free style choice"

--- True when the base item icon is the Breton light robe.
---@param link string
---@return boolean
function IsItemLinkRobe(link) end

--- Created inside `Init` after the first player activation.
---@type LLC_Addon|nil
LLC_Global = LLC_Global
---@type LLC_Addon|nil
LLC_UserRequests = LLC_UserRequests

---@type LibLazyCrafting|nil
LibLazyCrafting = LibLazyCrafting
