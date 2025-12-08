-- ////// START : GENERATED FROM C:/Users/dack_janiels/source/repos/LUIE/LuiExtended/LuiExtended/frontend\CombatText.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
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
---@class LUIE_CombatText_Outgoing : Control
---@field public clampedToScreen boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_CombatText_Outgoing = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Incoming : Control
---@field public clampedToScreen boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_CombatText_Incoming = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Alert : Control
---@field public clampedToScreen boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_CombatText_Alert = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Point : Control
---@field public clampedToScreen boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_CombatText_Point = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Resource : Control
---@field public clampedToScreen boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
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
---@class LUIE_CombatText_Outgoing_Backdrop : BackdropControl
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
---@field AnchorFill boolean
LUIE_CombatText_Outgoing_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Incoming_Backdrop : BackdropControl
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
---@field AnchorFill boolean
LUIE_CombatText_Incoming_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Alert_Backdrop : BackdropControl
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
---@field AnchorFill boolean
LUIE_CombatText_Alert_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Point_Backdrop : BackdropControl
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
---@field AnchorFill boolean
LUIE_CombatText_Point_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatText_Resource_Backdrop : BackdropControl
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
---@field AnchorFill boolean
LUIE_CombatText_Resource_Label = {}
---------- LVL: 07 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/source/repos/LUIE/LuiExtended/LuiExtended/frontend\CombatText.xml
