-- ////// START : GENERATED FROM C:\Users\dack_janiels\Documents\LUIE\LuiExtended\LuiExtended\frontend\AbilityAlerts.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertFrame : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field public OnMoveStart fun(self: Control)
---@field public OnMoveStop fun(self: Control)
LUIE_AlertFrame = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_AlertTemplate = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertFrame_Preview : BackdropControl
---@field public hidden boolean
---@field public centerColor string
---@field public edgeColor string
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
LUIE_AlertFrame_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate_Prefix : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_AlertTemplate_Prefix = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate_Name : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_AlertTemplate_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate_Modifier : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_AlertTemplate_Modifier = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate_Icon : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
LUIE_AlertTemplate_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate_Mitigation : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_AlertTemplate_Mitigation = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate_Timer : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_AlertTemplate_Timer = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertFrame_Preview_AnchorTexture : TextureControl
---@field public textureFile string
---@field public color string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_AlertFrame_Preview_AnchorTexture = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertFrame_Preview_AnchorLabelBg : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
LUIE_AlertFrame_Preview_AnchorLabelBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertFrame_Preview_AnchorLabel : LabelControl
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
LUIE_AlertFrame_Preview_AnchorLabel = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate_Icon_Back : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
LUIE_AlertTemplate_Icon_Back = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate_Icon_IconBg : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
LUIE_AlertTemplate_Icon_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate_Icon_Cd : CooldownControl
---@field public fillColor string
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_AlertTemplate_Icon_Cd = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_AlertTemplate_Icon_Icon : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_AlertTemplate_Icon_Icon = {}
---------- LVL: 07 ----------
-- ////// END   : GENERATED FROM C:\Users\dack_janiels\Documents\LUIE\LuiExtended\LuiExtended\frontend\AbilityAlerts.xml
