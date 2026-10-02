-- ////// START : GENERATED FROM LuiExtended/frontend/ActionBar.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public OnMoveStart fun(self: Control)
---@field public OnMoveStop fun(self: Control)
LUIE_ACTIONBAR_CASTBAR_TLC = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Preview : BackdropControl
---@field public hidden boolean
---@field public layer DrawLayer
---@field AnchorFill boolean
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
---@field public OnInitialized fun(self: Control)
LUIE_ACTIONBAR_CASTBAR_TLC_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon : BackdropControl
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
---@field public OnInitialized fun(self: Control)
LUIE_ACTIONBAR_CASTBAR_TLC_Icon = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Preview_Label : LabelControl
---@field public text string
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_ACTIONBAR_CASTBAR_TLC_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Preview_AnchorTexture : TextureControl
---@field public textureFile string
---@field public color string
---@field public alpha number
---@field public layer DrawLayer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_ACTIONBAR_CASTBAR_TLC_Preview_AnchorTexture = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Preview_AnchorLabelBg : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
LUIE_ACTIONBAR_CASTBAR_TLC_Preview_AnchorLabelBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Preview_AnchorLabel : LabelControl
---@field public font string
---@field public color string
---@field public text string
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public layer DrawLayer
---@field public tier DrawTier
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_ACTIONBAR_CASTBAR_TLC_Preview_AnchorLabel = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon_Back : TextureControl
---@field public layer DrawLayer
---@field public tier DrawTier
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_ACTIONBAR_CASTBAR_TLC_Icon_Back = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon_IconBg : TextureControl
---@field public layer DrawLayer
---@field public level integer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_ACTIONBAR_CASTBAR_TLC_Icon_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon_Icon : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_ACTIONBAR_CASTBAR_TLC_Icon_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop : BackdropControl
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
---@field public OnInitialized fun(self: Control)
LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop = {}
---------- LVL: 07 ----------
---------- LVL: 08 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_Bar : StatusBarControl
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_Name : LabelControl
---@field public text string
---@field public hidden boolean
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_Timer : LabelControl
---@field public text string
---@field public hidden boolean
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_Timer = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_LineLA : TextureControl
---@field public color string
---@field public hidden boolean
LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_LineLA = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_LineSkill : TextureControl
---@field public color string
---@field public hidden boolean
LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_LineSkill = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_LineDelay : TextureControl
---@field public color string
---@field public hidden boolean
LUIE_ACTIONBAR_CASTBAR_TLC_Icon_BarBackdrop_LineDelay = {}
---------- LVL: 09 ----------
-- ////// END   : GENERATED FROM LuiExtended/frontend/ActionBar.xml
