-- ////// START : GENERATED FROM C:/Users/dack_janiels/Desktop/LUIE_WORKSPACE/LuiExtended/LuiExtended\pc\frontend\Changelog.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_Changelog : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public tier DrawTier
---@field public layer DrawLayer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_Changelog = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_Changelog_Background : BackdropControl
---@field public edgeColor string
---@field public centerColor string
---@field AnchorFill boolean
LUIE_Changelog_Background = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_Changelog_BackgroundMungeOverlay : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_Changelog_BackgroundMungeOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_Changelog_TitleBar : Control
---@field Dimensions {y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_Changelog_TitleBar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_Changelog_About : LabelControl
---@field public font string
---@field public wrapMode TextWrapMode
---@field public color string
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {y: layout_measurement}
LUIE_Changelog_About = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_Changelog_Container : Control
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field public OnInitialized fun(self: Control)
LUIE_Changelog_Container = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_Changelog_TitleBarBg : BackdropControl
---@field public edgeColor string
---@field public centerColor string
---@field AnchorFill boolean
LUIE_Changelog_TitleBarBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_Changelog_Title : LabelControl
---@field public font string
---@field public wrapMode TextWrapMode
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public color string
---@field AnchorFill boolean
LUIE_Changelog_Title = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_Changelog_Close : ButtonControl
---@field public font string
---@field public text string
---@field public mouseEnabled boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field public OnClicked fun(self: Control, button: integer, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_Changelog_Close = {}
---------- LVL: 07 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/Desktop/LUIE_WORKSPACE/LuiExtended/LuiExtended\pc\frontend\Changelog.xml
