-- ////// START : GENERATED FROM C:\Users\dack_janiels\Documents\LUIE\LuiExtended\LuiExtended\frontend\CombatText.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_PanelPreviewBacking : BackdropControl
---@field public hidden boolean
---@field public centerColor string
---@field public edgeColor string
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
LUIE_CombatText_PanelPreviewBacking = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText : TopLevelWindow
---@field public mouseEnabled boolean
---@field public clampedToScreen boolean
---@field public movable boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_CombatText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Virtual : Control
LUIE_CombatText_Virtual = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_PanelPreviewBacking_AnchorTexture : TextureControl
---@field public textureFile string
---@field public color string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_CombatText_PanelPreviewBacking_AnchorTexture = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_PanelPreviewBacking_AnchorLabelBg : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
LUIE_CombatText_PanelPreviewBacking_AnchorLabelBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_PanelPreviewBacking_AnchorLabel : LabelControl
---@field public font string
---@field public color string
---@field public text string
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_CombatText_PanelPreviewBacking_AnchorLabel = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Outgoing : Control
---@field public clampedToScreen boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
---@field public OnMoveStart fun(self: Control)
---@field public OnMoveStop fun(self: Control)
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_CombatText_Outgoing = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Incoming : Control
---@field public clampedToScreen boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
---@field public OnMoveStart fun(self: Control)
---@field public OnMoveStop fun(self: Control)
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_CombatText_Incoming = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Alert : Control
---@field public clampedToScreen boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field public OnMoveStart fun(self: Control)
---@field public OnMoveStop fun(self: Control)
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_CombatText_Alert = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Point : Control
---@field public clampedToScreen boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field public OnMoveStart fun(self: Control)
---@field public OnMoveStop fun(self: Control)
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_CombatText_Point = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Resource : Control
---@field public clampedToScreen boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field public OnMoveStart fun(self: Control)
---@field public OnMoveStop fun(self: Control)
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_CombatText_Resource = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Virtual_Amount : LabelControl
LUIE_CombatText_Virtual_Amount = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Virtual_Icon : TextureControl
---@field public hidden boolean
LUIE_CombatText_Virtual_Icon = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Outgoing_Preview : BackdropControl, LUIE_CombatText_PanelPreviewBacking
LUIE_CombatText_Outgoing_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Outgoing_Backdrop : BackdropControl, ZO_DefaultBackdrop
---@field public alpha number
---@field public hidden boolean
LUIE_CombatText_Outgoing_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Outgoing_Label : LabelControl
---@field public font string
---@field public color string
---@field public inheritAlpha boolean
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field public wrapMode TextWrapMode
LUIE_CombatText_Outgoing_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Incoming_Preview : BackdropControl, LUIE_CombatText_PanelPreviewBacking
LUIE_CombatText_Incoming_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Incoming_Backdrop : BackdropControl, ZO_DefaultBackdrop
---@field public alpha number
---@field public hidden boolean
LUIE_CombatText_Incoming_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Incoming_Label : LabelControl
---@field public font string
---@field public color string
---@field public inheritAlpha boolean
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field public wrapMode TextWrapMode
LUIE_CombatText_Incoming_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Alert_Preview : BackdropControl, LUIE_CombatText_PanelPreviewBacking
LUIE_CombatText_Alert_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Alert_Backdrop : BackdropControl, ZO_DefaultBackdrop
---@field public alpha number
---@field public hidden boolean
LUIE_CombatText_Alert_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Alert_Label : LabelControl
---@field public font string
---@field public color string
---@field public inheritAlpha boolean
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field public wrapMode TextWrapMode
LUIE_CombatText_Alert_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Point_Preview : BackdropControl, LUIE_CombatText_PanelPreviewBacking
LUIE_CombatText_Point_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Point_Backdrop : BackdropControl, ZO_DefaultBackdrop
---@field public alpha number
---@field public hidden boolean
LUIE_CombatText_Point_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Point_Label : LabelControl
---@field public font string
---@field public color string
---@field public inheritAlpha boolean
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field public wrapMode TextWrapMode
LUIE_CombatText_Point_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Resource_Preview : BackdropControl, LUIE_CombatText_PanelPreviewBacking
LUIE_CombatText_Resource_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Resource_Backdrop : BackdropControl, ZO_DefaultBackdrop
---@field public alpha number
---@field public hidden boolean
LUIE_CombatText_Resource_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Resource_Label : LabelControl
---@field public font string
---@field public color string
---@field public inheritAlpha boolean
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field public wrapMode TextWrapMode
LUIE_CombatText_Resource_Label = {}
---------- LVL: 07 ----------
-- ////// END   : GENERATED FROM C:\Users\dack_janiels\Documents\LUIE\LuiExtended\LuiExtended\frontend\CombatText.xml
