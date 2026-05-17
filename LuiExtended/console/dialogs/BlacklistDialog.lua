-- Custom Blacklist Dialog for Console
-- Based on ZO_GenericParametricListGamepadDialogTemplate

local BlacklistDialog = {}

-- Store dialog instances
local dialogInstances = {}

-- Track which dialogs are currently rebuilding to prevent concurrent rebuilds
local rebuildingDialogs = {}

-- Template setup function
function LUIE.BlacklistDialog_OnInitialized(dialog)
    ZO_GenericParametricListGamepadDialogTemplate_OnInitialized(dialog)

    -- Override setup to use our custom parametric list builder
    dialog.setupFunc = BlacklistDialog.Setup

    -- Store reference
    dialogInstances[dialog] = true
end

-- Setup the dialog with blacklist data
function BlacklistDialog.Setup(dialog, data)
    if not data then
        return
    end

    -- Refresh header
    ZO_GenericGamepadDialog_RefreshHeaderData(dialog, data.headerData)

    -- Store data for refresh and button callbacks
    dialog.blacklistData = data

    -- Build parametric list
    local parametricList = {}

    -- Track indices for different entry types
    local itemStartIndex = nil

    -- Add section header and items
    if data.generateItemsFunc then
        local items = data.generateItemsFunc()
        if items and #items > 0 then
            -- Sort items alphabetically
            table.sort(items, function (a, b)
                local nameA = type(a) == "table" and a.name or tostring(a)
                local nameB = type(b) == "table" and b.name or tostring(b)
                return nameA < nameB
            end)

            -- Add section header
            parametricList[#parametricList + 1] =
            {
                template = "ZO_GamepadMenuEntryTemplate",
                text = "", -- Empty text to prevent default "EntryItem1" text
                header = data.listHeaderText or GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST),
                templateData =
                {
                    setup = function (control, entryData, selected, reselectingDuringRebuild, enabled, active)
                        -- Initialize control if needed
                        if not control.label then
                            ZO_SharedGamepadEntry_OnInitialized(control)
                        end
                        -- Setup the gamepad menu entry template
                        ZO_SharedGamepadEntry_OnSetup(control, entryData, selected, reselectingDuringRebuild, enabled, active)
                    end,
                    canSelect = false,
                },
            }

            -- Track where items start
            itemStartIndex = #parametricList + 1

            -- Add each item as a removable entry
            for i, item in ipairs(items) do
                local itemName = type(item) == "table" and item.name or tostring(item)
                local itemData = type(item) == "table" and item.data or item

                -- Ensure itemName is never nil or empty
                if not itemName or itemName == "" then
                    itemName = tostring(itemData) or "Unknown Item"
                end

                parametricList[#parametricList + 1] =
                {
                    template = "ZO_GamepadMenuEntryTemplate",
                    text = itemName,
                    templateData =
                    {
                        setup = function (control, entryData, selected, reselectingDuringRebuild, enabled, active)
                            -- Initialize control if needed
                            if not control.label then
                                ZO_SharedGamepadEntry_OnInitialized(control)
                            end
                            -- Setup the gamepad menu entry template
                            ZO_SharedGamepadEntry_OnSetup(control, entryData, selected, reselectingDuringRebuild, enabled, active)
                        end,
                        entryType = "item",
                        itemData = itemData,
                        statusText = GetString(SI_DIALOG_REMOVE),
                    },
                }
            end
        else
            -- No items message
            parametricList[#parametricList + 1] =
            {
                template = "ZO_GamepadMenuEntryTemplate",
                text = data.emptyListText or GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_EMPTYLIST),
                templateData =
                {
                    setup = function (control, entryData, selected, reselectingDuringRebuild, enabled, active)
                        -- Initialize control if needed
                        if not control.label then
                            ZO_SharedGamepadEntry_OnInitialized(control)
                        end
                        -- Setup the gamepad menu entry template
                        ZO_SharedGamepadEntry_OnSetup(control, entryData, selected, reselectingDuringRebuild, enabled, active)
                    end,
                    canSelect = false,
                },
            }
        end
    end

    -- Prevent concurrent rebuilds
    local dialogKey = dialog:GetName()
    if rebuildingDialogs[dialogKey] then
        return
    end
    rebuildingDialogs[dialogKey] = true

    -- Store whether the list was active before rebuilding
    local wasActive = dialog.entryList and dialog.entryList:IsActive() or false

    -- Rebuild the parametric list (RebuildEntryList handles clearing internally)
    dialog.info = dialog.info or {}
    dialog.info.parametricList = parametricList

    -- Set up buttons for keybind strip
    dialog.info.buttons = {}

    -- "Remove Entry" button - visible when an item entry is selected
    if data.onSelectCallback then
        dialog.info.buttons[#dialog.info.buttons + 1] =
        {
            text = GetString(SI_DIALOG_REMOVE),
            keybind = "DIALOG_PRIMARY",
            callback = function (dialogControl)
                local selectedData = dialogControl.entryList:GetSelectedData()
                if selectedData then
                    -- Check both entryType and itemData to determine if this is an item entry
                    local entryType = selectedData.entryType
                    local itemData = selectedData.itemData
                    if entryType == "item" and itemData then
                        data.onSelectCallback(itemData)
                        -- Refresh the dialog
                        zo_callLater(function ()
                                         BlacklistDialog.Refresh(dialogControl, data)
                                     end, 50)
                    end
                end
            end,
            visible = function (dialogControl)
                if not dialogControl.entryList then
                    return false
                end
                local selectedData = dialogControl.entryList:GetSelectedData()
                if not selectedData then
                    return false
                end
                -- Check if this is an item entry (has entryType == "item" and itemData)
                return selectedData.entryType == "item" and selectedData.itemData ~= nil
            end,
            enabled = function (dialogControl)
                if not dialogControl.entryList then
                    return false
                end
                local selectedData = dialogControl.entryList:GetSelectedData()
                if not selectedData then
                    return false
                end
                -- Check if this is an item entry and has valid itemData
                return selectedData.entryType == "item" and selectedData.itemData ~= nil
            end,
        }
    end

    -- "Back" button - always visible, closes dialog and returns to addon settings
    dialog.info.buttons[#dialog.info.buttons + 1] =
    {
        text = SI_DIALOG_CANCEL,
        keybind = "DIALOG_NEGATIVE",
        callback = function (dialogControl)
            -- Close the dialog and return to addon settings
            ZO_Dialogs_ReleaseDialogOnButtonPress(dialogControl.name)
        end,
        visible = function (dialogControl)
            return true
        end,
        enabled = function (dialogControl)
            return true
        end,
    }

    -- Set up selection changed callback to update buttons
    dialog.info.parametricListOnSelectionChangedCallback = function (dialogControl)
        -- This will trigger KEYBIND_STRIP:UpdateKeybindButtonGroup automatically
        -- via DefaultOnSelectionChangedCallback in the template
    end

    ZO_GenericParametricListGamepadDialogTemplate_RebuildEntryList(dialog)

    -- Reactivate the entry list if it was active before rebuilding
    if wasActive and dialog.entryList then
        zo_callLater(function ()
                         if dialog.entryList and dialog:IsControlHidden() == false then
                             dialog.entryList:Activate()
                         end
                     end, 50)
    end

    -- Clear the rebuilding flag after a short delay
    zo_callLater(function ()
                     rebuildingDialogs[dialogKey] = nil
                 end, 100)
end

-- Refresh the dialog with updated data
function BlacklistDialog.Refresh(dialog, data)
    if dialog and dialog.entryList then
        BlacklistDialog.Setup(dialog, data)
    end
end

-- Show a blacklist dialog
function BlacklistDialog.Show(identifier, title, generateItemsFunc, onSelectCallback, addItemCallback, clearCallback, listHeaderText, emptyListText)
    -- Create or get existing dialog control (ESO dialog system needs the control to exist)
    local dialogName = "LUIE_BlacklistDialog_" .. identifier
    local dialog = GetControl(dialogName)

    if not dialog then
        dialog = CreateControlFromVirtual(dialogName, GuiRoot, "LUIE_BlacklistDialog")
    end

    -- Prepare data
    local data =
    {
        headerData =
        {
            titleText = title,
        },
        generateItemsFunc = generateItemsFunc,
        onSelectCallback = onSelectCallback,
        addItemCallback = addItemCallback,
        clearCallback = clearCallback,
        listHeaderText = listHeaderText,
        emptyListText = emptyListText,
    }

    -- Register with ESO dialogs system
    local dialogKey = "LUIE_BLACKLIST_" .. identifier

    local dialogInfo =
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        canQueue = true,
        blockDialogReleaseOnPress = true, -- Prevent auto-close on button press so we can refresh the dialog
        title =
        {
            text = title,
        },
        setup = function (dialogControl, setupData)
            -- Setup the dialog when ESO dialog system calls this
            BlacklistDialog.Setup(dialogControl, setupData)
        end,
    }

    ESO_Dialogs[dialogKey] = dialogInfo

    -- Show using gamepad dialog system (it will call setup and create the dialog control)
    ZO_Dialogs_ShowGamepadDialog(dialogKey, data)
end

-- Store the module
LUIE.BlacklistDialog = BlacklistDialog
