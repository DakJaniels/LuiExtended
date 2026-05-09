-- ////// START : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended/frontend\Changelog.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_Changelog : TopLevelWindow
--- @field public mouseEnabled boolean
--- @field public movable boolean
--- @field public clampedToScreen boolean
--- @field public hidden boolean
--- @field public tier DrawTier
--- @field public layer DrawLayer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_Changelog = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_Changelog_Background : BackdropControl, ZO_ThinBackdrop
LUIE_Changelog_Background = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_Changelog_Title : LabelControl
--- @field public font string
--- @field public wrapMode TextWrapMode
--- @field public verticalAlignment TextAlignment
--- @field Anchor {relativeTo: string, relativePoint: AnchorPosition, point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_Changelog_Title = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_Changelog_About : LabelControl
--- @field public font string
--- @field public wrapMode TextWrapMode
--- @field Anchor {relativeTo: string, relativePoint: AnchorPosition, point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_Changelog_About = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_Changelog_Close : ButtonControl, ZO_CloseButton
--- @field Anchor {point: AnchorPosition, offsetY: layout_measurement, offsetX: layout_measurement}
--- @field public OnClicked fun(self: Control, button: integer, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_Changelog_Close = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_Changelog_Container : Control, ZO_ScrollContainer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
--- @field public OnInitialized fun(self: Control)
LUIE_Changelog_Container = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_Changelog_Text : LabelControl
--- @field public font string
--- @field public wrapMode TextWrapMode
--- @field Dimensions {x: layout_measurement}
--- @field public OnInitialized fun(self: Control)
LUIE_Changelog_Text = {}
---------- LVL: 05 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended/frontend\Changelog.xml
