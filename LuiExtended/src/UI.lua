-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
local windowManager = GetWindowManager()
-- -----------------------------------------------------------------------------
--- @class LUIE.UI : table
--- @field __index LUIE.UI
--- @field isInDebug boolean # Flag to control debug naming mode
--- @field TopLevel fun(self:LUIE.UI, anchors?: table, dims?: table): TopLevelWindow|table # Creates a top-level window control
--- @field Control fun(self:LUIE.UI, parent: userdata, anchors?: table|string, dims?: table|string, hidden?: boolean, name?: string): Control|table # Creates a basic UI control
--- @field Texture fun(self:LUIE.UI, parent: userdata, anchors?: table|"fill", dims?: table|"inherit", texture?: string, drawlayer?: integer, hidden?: boolean): TextureControl|table # Creates a texture control
--- @field Backdrop fun(self:LUIE.UI, parent: userdata, anchors?: table|"fill", dims?: table|"inherit", center?: table, edge?: table, hidden?: boolean): BackdropControl|table # Creates a backdrop control
--- @field ChatBackdrop fun(self:LUIE.UI, parent: userdata, anchors?: table|"fill", dims?: table|"inherit", color?: table, edge_size?: number, hidden?: boolean): BackdropControl|table # Creates a chat-style backdrop
--- @field StatusBar fun(self:LUIE.UI, parent: userdata, anchors?: table|"fill", dims?: table|"inherit", color?: table, hidden?: boolean): StatusBarControl|table # Creates a status bar control
--- @field Label fun(self:LUIE.UI, parent: userdata, anchors?: table|"fill", dims?: table|"inherit", align?: table, font?: string, text?: string, hidden?: boolean, name?: string): LabelControl|table # Creates a label control
local UI = {}
UI.__index = UI
-- -----------------------------------------------------------------------------
-- Debug flag - exposed through UI for testing
UI.isInDebug = false
if LUIE.IsDevDebugEnabled() then
    UI.isInDebug = true
end
-- -----------------------------------------------------------------------------
-- Local control counters
local controlCounters =
{
    ControlWithType = 0,
    TopLevel = 0,
    Control = 0,
    Texture = 0,
    Backdrop = 0,
    ChatBackdrop = 0,
    StatusBar = 0,
    Label = 0,
}
-- -----------------------------------------------------------------------------
--- Gets a unique control name for UI elements
--- @param controlType string The type of control to generate a name for
--- @return string|nil uniqueName The generated unique control name or nil if not in debug mode
local function GetUniqueControlName(controlType)
    if not UI.isInDebug then
        return nil
    end
    controlCounters[controlType] = controlCounters[controlType] + 1
    return string.format("LUIE_%s_Unique_%d", controlType, controlCounters[controlType])
end
-- -----------------------------------------------------------------------------
--- Creates an empty top-level window control
--- @param anchors? table Array of anchor points: [point, relativeTo, relativePoint, offsetX, offsetY]
--- @param dims? table Array of dimensions: [width, height]
--- @return TopLevelWindow tlw The created top-level window
function UI:TopLevel(anchors, dims)
    local name = GetUniqueControlName("TopLevel")
    --- @type TopLevelWindow
    local tlw = windowManager:CreateTopLevelWindow(name)
    tlw:SetClampedToScreen(true)
    tlw:SetMouseEnabled(false)
    tlw:SetMovable(false)
    tlw:SetHidden(true)
    if anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        tlw:SetAnchor(anchors[1], anchors[5] or GuiRoot, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end
    if dims ~= nil and #dims == 2 then
        tlw:SetDimensions(dims[1], dims[2])
    end
    return tlw
end

-- -----------------------------------------------------------------------------
--- Creates a basic UI control element
--- @param parent userdata The parent control
--- @param anchors? table|"fill" Array of anchor points or "fill" to fill parent
--- @param dims? table|"inherit" Array of dimensions or "inherit" to match parent
--- @param hidden? boolean Whether the control starts hidden
--- @param name? string Optional custom control name
--- @return Control|nil c The created control, or nil if parent is invalid
function UI:Control(parent, anchors, dims, hidden, name)
    if not parent then
        return nil
    end
    local controlName = name or GetUniqueControlName("Control")
    --- @type Control
    local c = windowManager:CreateControl(controlName, parent, CT_CONTROL)
    if anchors == "fill" then
        c:SetAnchorFill(parent)
    elseif anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        c:SetAnchor(anchors[1], anchors[5] or parent, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end
    if dims == "inherit" then
        c:SetDimensions(parent:GetWidth(), parent:GetHeight())
    elseif dims ~= nil and #dims == 2 then
        c:SetDimensions(dims[1], dims[2])
    end
    if hidden then
        c:SetHidden(hidden)
    end
    return c
end

-- -----------------------------------------------------------------------------
--- Creates a basic UI control element
--- @param parent userdata The parent control
--- @param anchors? table|"fill" Array of anchor points or "fill" to fill parent
--- @param dims? table|"inherit" Array of dimensions or "inherit" to match parent
--- @param hidden? boolean Whether the control starts hidden
--- @param name? string Optional custom control name
--- @param controlType ControlType
--- @return Control|nil c The created control, or nil if parent is invalid
function UI:ControlWithType(parent, anchors, dims, hidden, name, controlType)
    if not parent then
        return nil
    end
    local controlName = name or GetUniqueControlName("ControlWithType")
    --- @type Control
    local c = windowManager:CreateControl(controlName, parent, controlType)
    if anchors == "fill" then
        c:SetAnchorFill(parent)
    elseif anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        c:SetAnchor(anchors[1], anchors[5] or parent, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end
    if dims == "inherit" then
        c:SetDimensions(parent:GetWidth(), parent:GetHeight())
    elseif dims ~= nil and #dims == 2 then
        c:SetDimensions(dims[1], dims[2])
    end
    if hidden then
        c:SetHidden(hidden)
    end
    return c
end

-- -----------------------------------------------------------------------------
--- Creates a texture control element
--- @param parent userdata The parent control to attach the texture to
--- @param anchors? table|"fill" Array of anchor points [point, relativeTo, relativePoint, offsetX, offsetY] or "fill" to fill parent
--- @param dims? table|"inherit" Array of dimensions [width, height] or "inherit" to match parent
--- @param texture? string Path to the texture file to display
--- @param drawlayer? integer The draw layer for rendering order (DL_* constants)
--- @param hidden? boolean Whether the texture starts hidden
--- @return TextureControl|nil texture The created texture control, or nil if parent is invalid
function UI:Texture(parent, anchors, dims, texture, drawlayer, hidden)
    if not parent then
        return nil
    end
    local name = GetUniqueControlName("Texture")
    --- @type TextureControl
    local t = windowManager:CreateControl(name, parent, CT_TEXTURE)
    if anchors == "fill" then
        t:SetAnchorFill(parent)
    elseif anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        t:SetAnchor(anchors[1], anchors[5] or parent, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end
    if dims == "inherit" then
        t:SetDimensions(parent:GetWidth(), parent:GetHeight())
    elseif dims ~= nil and #dims == 2 then
        t:SetDimensions(dims[1], dims[2])
    end
    if texture then
        t:SetTexture(texture)
    end
    if drawlayer then
        t:SetDrawLayer(drawlayer)
    end
    if hidden then
        t:SetHidden(hidden)
    end
    return t
end

-- -----------------------------------------------------------------------------
--- Creates a backdrop control element
--- @param parent userdata The parent control to attach the backdrop to
--- @param anchors? table|"fill" Array of anchor points [point, relativeTo, relativePoint, offsetX, offsetY] or "fill" to fill parent
--- @param dims? table|"inherit" Array of dimensions [width, height] or "inherit" to match parent
--- @param center? table Array of RGBA values [r, g, b, a] for the center color. Defaults to [0, 0, 0, 0.4]
--- @param edge? table Array of RGBA values [r, g, b, a] for the edge color. Defaults to [0, 0, 0, 0.6]
--- @param hidden? boolean Whether the backdrop starts hidden
--- @return BackdropControl|nil backdrop The created backdrop control, or nil if parent is invalid
function UI:Backdrop(parent, anchors, dims, center, edge, hidden)
    if not parent then
        return nil
    end
    local name = GetUniqueControlName("Backdrop")
    local centerColor = (center ~= nil and #center == 4) and center or { 0, 0, 0, 0.4 }
    local edgeColor = (edge ~= nil and #edge == 4) and edge or { 0, 0, 0, 0.6 }
    --- @type BackdropControl
    local bg = windowManager:CreateControl(name, parent, CT_BACKDROP)
    bg:SetCenterColor(centerColor[1], centerColor[2], centerColor[3], centerColor[4])
    bg:SetEdgeColor(edgeColor[1], edgeColor[2], edgeColor[3], edgeColor[4])
    bg:SetEdgeTexture("", 8, 1, 1, 1)
    bg:SetDrawLayer(DL_BACKGROUND)
    if anchors == "fill" then
        bg:SetAnchorFill(parent)
    elseif anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        bg:SetAnchor(anchors[1], anchors[5] or parent, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end
    if dims == "inherit" then
        bg:SetDimensions(parent:GetWidth(), parent:GetHeight())
    elseif dims ~= nil and #dims == 2 then
        bg:SetDimensions(dims[1], dims[2])
    end
    if hidden then
        bg:SetHidden(hidden)
    end
    return bg
end

-- -----------------------------------------------------------------------------
--- Creates a chat-style backdrop control element
--- @param parent userdata The parent control to attach the backdrop to
--- @param anchors? table|"fill" Array of anchor points [point, relativeTo, relativePoint, offsetX, offsetY] or "fill" to fill parent
--- @param dims? table|"inherit" Array of dimensions [width, height] or "inherit" to match parent
--- @param color? table Array of RGBA values [r, g, b, a] for both center and edge colors. Defaults to [0, 0, 0, 1]
--- @param edge_size? number Size of the backdrop edge in pixels. Defaults to 16
--- @param hidden? boolean Whether the backdrop starts hidden
--- @return BackdropControl|nil backdrop The created chat backdrop control, or nil if parent is invalid
function UI:ChatBackdrop(parent, anchors, dims, color, edge_size, hidden)
    if not parent then
        return nil
    end
    local name = GetUniqueControlName("ChatBackdrop")
    local bgColor = (color ~= nil and #color == 4) and color or { 0, 0, 0, 1 }
    local edgeSize = (edge_size ~= nil and edge_size > 0) and edge_size or 16
    --- @type BackdropControl
    local bg = windowManager:CreateControl(name, parent, CT_BACKDROP)
    bg:SetCenterColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    bg:SetEdgeColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    bg:SetCenterTexture("/esoui/art/chatwindow/chat_bg_center.dds", nil, nil)
    bg:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 256, 256, edgeSize, 1)
    bg:SetInsets(edgeSize, edgeSize, -edgeSize, -edgeSize)
    bg:SetDrawLayer(DL_BACKGROUND)

    if anchors == "fill" then
        bg:SetAnchorFill(parent)
    elseif anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        bg:SetAnchor(anchors[1], anchors[5] or parent, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end
    if dims == "inherit" then
        bg:SetDimensions(parent:GetWidth(), parent:GetHeight())
    elseif dims ~= nil and #dims == 2 then
        bg:SetDimensions(dims[1], dims[2])
    end
    if hidden then
        bg:SetHidden(hidden)
    end
    return bg
end

-- -----------------------------------------------------------------------------
--- Creates a status bar control element
--- @param parent userdata The parent control to attach the status bar to
--- @param anchors? table|"fill" Array of anchor points [point, relativeTo, relativePoint, offsetX, offsetY] or "fill" to fill parent
--- @param dims? table|"inherit" Array of dimensions [width, height] or "inherit" to match parent
--- @param color? table Array of RGB or RGBA values [r, g, b] or [r, g, b, a] for the bar color
--- @param hidden? boolean Whether the status bar starts hidden
--- @return StatusBarControl|nil statusbar The created status bar control, or nil if parent is invalid
function UI:StatusBar(parent, anchors, dims, color, hidden)
    if not parent then
        return nil
    end
    local name = GetUniqueControlName("StatusBar")
    --- @type StatusBarControl
    local sb = windowManager:CreateControl(name, parent, CT_STATUSBAR)

    if anchors == "fill" then
        sb:SetAnchorFill(parent)
    elseif anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        sb:SetAnchor(anchors[1], anchors[5] or parent, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end
    if dims == "inherit" then
        sb:SetDimensions(parent:GetWidth(), parent:GetHeight())
    elseif dims ~= nil and #dims == 2 then
        sb:SetDimensions(dims[1], dims[2])
    end
    if color ~= nil and (#color == 3 or #color == 4) then
        sb:SetColor(unpack(color))
    end
    if hidden then
        sb:SetHidden(hidden)
    end
    return sb
end

-- -----------------------------------------------------------------------------
--- Creates a label control element
--- @param parent userdata The parent control to attach the label to
--- @param anchors? table|"fill" Array of anchor points [point, relativeTo, relativePoint, offsetX, offsetY] or "fill" to fill parent
--- @param dims? table|"inherit" Array of dimensions [width, height] or "inherit" to match parent
--- @param align? table Array of alignment values [horizontal, vertical] using TEXT_ALIGN_* constants. Defaults to [CENTER, CENTER]
--- @param font? string Font to use for the text. Defaults to "ZoFontGame"
--- @param text? string Initial text content for the label
--- @param hidden? boolean Whether the label starts hidden
--- @param name? string Optional custom name for the label control
--- @return LabelControl|nil label The created label control, or nil if parent is invalid
function UI:Label(parent, anchors, dims, align, font, text, hidden, name)
    if not parent then
        return nil
    end
    local labelName = name or GetUniqueControlName("Label")
    local alignment = (align ~= nil and #align == 2) and align or { TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER }
    --- @type LabelControl
    local label = windowManager:CreateControl(labelName, parent, CT_LABEL)
    label:SetFont(font or "LUIE Default Font")
    label:SetHorizontalAlignment(alignment[1])
    label:SetVerticalAlignment(alignment[2])
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    if anchors == "fill" then
        label:SetAnchorFill(parent)
    elseif anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        label:SetAnchor(anchors[1], anchors[5] or parent, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end
    if dims == "inherit" then
        label:SetDimensions(parent:GetWidth(), parent:GetHeight())
    elseif dims ~= nil and #dims == 2 then
        label:SetDimensions(dims[1], dims[2])
    end
    if text then
        label:SetText(text)
    end
    if hidden then
        label:SetHidden(hidden)
    end
    return label
end

-- : Configure as flex container (parent)
--- @alias flexConfig_container {
--- direction: FlexDirection, -- (ROW, COLUMN, ROW_REVERSE, COLUMN_REVERSE)
--- justification: FlexJustification, --(FLEX_START, CENTER, FLEX_END, SPACE_BETWEEN, SPACE_AROUND, SPACE_EVENLY)
--- itemAlignment: FlexAlignment, --(FLEX_START, CENTER, FLEX_END, STRETCH, BASELINE)
--- contentAlignment: FlexAlignment, --(alignment of multiple lines)
--- wrap: FlexWrap, --(NO_WRAP, WRAP, WRAP_REVERSE)
--- padding: table|number, --(internal padding: table with edges or single number for all)
--- }

-- :Configure as flex item (child)
--- @alias flexConfig_item {
--- grow: number, --(flex grow factor, default 0)
--- shrink: number, --(flex shrink factor, default 1)
--- basis: number, --(base size before growing/shrinking)
--- alignSelf: FlexAlignment, --(override parent's item alignment)
--- margin: table|number, --(external margins: table with edges or single number for all - use margins for gaps between children)
--- exclude: boolean, --(exclude from flex layout)
--- }

--- @class flexConfig
--- @field container flexConfig_container?
--- @field item flexConfig_item?

-- -----------------------------------------------------------------------------
--- Creates a flex-enabled control element with optional container and/or item properties
--- @param parent userdata The parent control
--- @param anchors? table|"fill" Array of anchor points or "fill" to fill parent
--- @param dims? table|"inherit" Array of dimensions or "inherit" to match parent
--- @param hidden? boolean Whether the control starts hidden
--- @param flexConfig? flexConfig Configuration table with optional 'container' and 'item' subtables
--- @return Control|object|nil control The created flex control, or nil if parent is invalid
function UI:FlexControl(parent, anchors, dims, hidden, flexConfig)
    if not parent then
        return nil
    end

    local name = GetUniqueControlName("Control")
    local control = windowManager:CreateControl(name, parent, CT_CONTROL)

    -- Apply anchors
    if anchors == "fill" then
        control:SetAnchorFill(parent)
    elseif anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        control:SetAnchor(anchors[1], anchors[5] or parent, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end

    -- Apply dimensions
    if dims == "inherit" then
        control:SetDimensions(parent:GetWidth(), parent:GetHeight())
    elseif dims ~= nil and #dims == 2 then
        control:SetDimensions(dims[1], dims[2])
    end

    -- Apply visibility
    if hidden then
        control:SetHidden(hidden)
    end

    -- Apply flex configuration
    if flexConfig then
        -- Container properties (this control will have flex children)
        if flexConfig.container then
            local container = flexConfig.container

            -- Enable flex layout
            control:SetChildLayout(CHILD_LAYOUT_TYPE_FLEX)

            -- Direction (default: ROW)
            if container.direction then
                control:SetChildFlexDirection(container.direction)
            end

            -- Justification (default: FLEX_START)
            if container.justification then
                control:SetChildFlexJustification(container.justification)
            end

            -- Item alignment on cross axis (default: STRETCH)
            if container.itemAlignment then
                control:SetChildFlexItemAlignment(container.itemAlignment)
            end

            -- Content alignment for multiple lines (default: FLEX_START)
            if container.contentAlignment then
                control:SetChildFlexContentAlignment(container.contentAlignment)
            end

            -- Wrap behavior (default: NO_WRAP)
            if container.wrap then
                control:SetChildFlexWrap(container.wrap)
            end

            -- Internal padding
            if container.padding then
                if type(container.padding) == "number" then
                    -- Single number applies to all edges
                    control:SetFlexPaddings(container.padding, container.padding, container.padding, container.padding)
                elseif type(container.padding) == "table" then
                    -- Table of specific edges or LTRB array
                    if #container.padding == 4 then
                        -- Array format: {left, top, right, bottom}
                        control:SetFlexPaddings(container.padding[1], container.padding[2], container.padding[3], container.padding[4])
                    else
                        -- Edge table format: { [FLEX_EDGE_LEFT] = 4, [FLEX_EDGE_RIGHT] = 4, ... }
                        local left = container.padding[FLEX_EDGE_LEFT] or 0
                        local top = container.padding[FLEX_EDGE_TOP] or 0
                        local right = container.padding[FLEX_EDGE_RIGHT] or 0
                        local bottom = container.padding[FLEX_EDGE_BOTTOM] or 0
                        control:SetFlexPaddings(left, top, right, bottom)
                    end
                end
            end
        end

        -- Item properties (this control is a flex child)
        if flexConfig.item then
            local item = flexConfig.item

            -- Grow factor (default: 0)
            if item.grow then
                control:SetFlexGrow(item.grow)
            end

            -- Shrink factor (default: 1)
            if item.shrink then
                control:SetFlexShrink(item.shrink)
            end

            -- Base size before growing/shrinking
            if item.basis then
                control:SetFlexBasis(item.basis)
            end

            -- Override parent's item alignment
            if item.alignSelf then
                control:SetFlexAlignSelf(item.alignSelf)
            end

            -- Margins
            if item.margin then
                if type(item.margin) == "number" then
                    -- Single number applies to all edges
                    control:SetFlexMargins(item.margin, item.margin, item.margin, item.margin)
                elseif type(item.margin) == "table" then
                    -- Table of specific edges or LTRB array
                    if #item.margin == 4 then
                        -- Array format: {left, top, right, bottom}
                        control:SetFlexMargins(item.margin[1], item.margin[2], item.margin[3], item.margin[4])
                    else
                        -- Edge table format: { [FLEX_EDGE_LEFT] = 4, [FLEX_EDGE_RIGHT] = 4, ... }
                        local left = item.margin[FLEX_EDGE_LEFT] or 0
                        local top = item.margin[FLEX_EDGE_TOP] or 0
                        local right = item.margin[FLEX_EDGE_RIGHT] or 0
                        local bottom = item.margin[FLEX_EDGE_BOTTOM] or 0
                        control:SetFlexMargins(left, top, right, bottom)
                    end
                end
            end

            -- Exclude from flex layout
            if item.exclude then
                control:SetExcludeFromFlexbox(item.exclude)
            end
        end
    end

    return control
end

-- -----------------------------------------------------------------------------
--- @type LUIE.UI
LUIE.UI = UI
