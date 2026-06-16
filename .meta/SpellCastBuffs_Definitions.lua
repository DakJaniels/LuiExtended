-- ////// START : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended/frontend/SpellCastBuffs.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field public OnMouseEnter fun(self: Control)
---@field public OnMouseExit fun(self: Control)
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_SpellCastBuffIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_EffectsRegion_Template : Control
---@field public hidden boolean
LUIE_SCB_EffectsRegion_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_Tlw_Template : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public tier DrawTier
LUIE_SCB_Tlw_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_DebugOverflowTooltipTopLevel : TopLevelWindow
---@field public tier DrawTier
LUIE_SCB_DebugOverflowTooltipTopLevel = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Back : TextureControl
---@field public layer DrawLayer
---@field public hidden boolean
LUIE_SpellCastBuffIcon_Back = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Frame : TextureControl
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SpellCastBuffIcon_Frame = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_IconBg : TextureControl
---@field public textureFile string
---@field public level integer
---@field public layer DrawLayer
---@field public hidden boolean
LUIE_SpellCastBuffIcon_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Drop : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SpellCastBuffIcon_Drop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Cooldown : CooldownControl
---@field public level integer
---@field public alpha number
---@field public hidden boolean
LUIE_SpellCastBuffIcon_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Icon : TextureControl
---@field public textureFile string
---@field public level integer
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SpellCastBuffIcon_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Label : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field public hidden boolean
LUIE_SpellCastBuffIcon_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_AbilityId : LabelControl
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field public maxLineCount integer
---@field public excludeFromResizeToFitExtents boolean
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SpellCastBuffIcon_AbilityId = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Stack : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field public hidden boolean
LUIE_SpellCastBuffIcon_Stack = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Name : LabelControl
---@field public wrapMode TextWrapMode
---@field public excludeFromResizeToFitExtents boolean
---@field public hidden boolean
LUIE_SpellCastBuffIcon_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_BarBackdrop : BackdropControl
---@field public alpha number
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field public excludeFromResizeToFitExtents boolean
---@field public layer DrawLayer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
LUIE_SpellCastBuffIcon_BarBackdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Bar : StatusBarControl
---@field public hidden boolean
---@field public excludeFromResizeToFitExtents boolean
---@field public layer DrawLayer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_SpellCastBuffIcon_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_EffectsRegion_Template_Preview : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_SCB_EffectsRegion_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_EffectsRegion_Template_IconHolder : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SCB_EffectsRegion_Template_IconHolder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_Tlw_Template_Preview : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_SCB_Tlw_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_Tlw_Template_IconHolder : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SCB_Tlw_Template_IconHolder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_DebugOverflowTooltip : TooltipControl
---@field public tier DrawTier
---@field public headerVerticalOffset number
---@field ResizeToFitPadding {width: layout_measurement, height: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, maxX: layout_measurement}
LUIE_SCB_DebugOverflowTooltip = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_EffectsRegion_Template_Preview_Label : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SCB_EffectsRegion_Template_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_Tlw_Template_Preview_Label : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SCB_Tlw_Template_Preview_Label = {}
---------- LVL: 07 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended/frontend/SpellCastBuffs.xml
-- ////// START : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended\frontend\SpellCastBuffs.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field public OnMouseEnter fun(self: Control)
---@field public OnMouseExit fun(self: Control)
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_SpellCastBuffIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_EffectsRegion_Template : Control
---@field public hidden boolean
LUIE_SCB_EffectsRegion_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_Tlw_Template : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public tier DrawTier
LUIE_SCB_Tlw_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_DebugOverflowTooltipTopLevel : TopLevelWindow
---@field public tier DrawTier
LUIE_SCB_DebugOverflowTooltipTopLevel = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Back : TextureControl
---@field public layer DrawLayer
---@field public hidden boolean
LUIE_SpellCastBuffIcon_Back = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Frame : TextureControl
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SpellCastBuffIcon_Frame = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_IconBg : TextureControl
---@field public textureFile string
---@field public level integer
---@field public layer DrawLayer
---@field public hidden boolean
LUIE_SpellCastBuffIcon_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Drop : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SpellCastBuffIcon_Drop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Cooldown : CooldownControl
---@field public level integer
---@field public alpha number
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_SpellCastBuffIcon_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Icon : TextureControl
---@field public textureFile string
---@field public level integer
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SpellCastBuffIcon_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Label : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field public hidden boolean
LUIE_SpellCastBuffIcon_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_AbilityId : LabelControl
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field public maxLineCount integer
---@field public excludeFromResizeToFitExtents boolean
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SpellCastBuffIcon_AbilityId = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Stack : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field public hidden boolean
LUIE_SpellCastBuffIcon_Stack = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Name : LabelControl
---@field public wrapMode TextWrapMode
---@field public excludeFromResizeToFitExtents boolean
---@field public hidden boolean
LUIE_SpellCastBuffIcon_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_BarBackdrop : BackdropControl
---@field public alpha number
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field public excludeFromResizeToFitExtents boolean
---@field public layer DrawLayer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Edge {edgeFileWidth: integer, edgeFileHeight: integer, edgeFilePadding: integer}
LUIE_SpellCastBuffIcon_BarBackdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon_Bar : StatusBarControl
---@field public hidden boolean
---@field public excludeFromResizeToFitExtents boolean
---@field public layer DrawLayer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_SpellCastBuffIcon_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_EffectsRegion_Template_Preview : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_SCB_EffectsRegion_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_EffectsRegion_Template_IconHolder : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SCB_EffectsRegion_Template_IconHolder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_Tlw_Template_Preview : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_SCB_Tlw_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_Tlw_Template_IconHolder : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SCB_Tlw_Template_IconHolder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_DebugOverflowTooltip : TooltipControl
---@field public tier DrawTier
---@field public headerVerticalOffset number
---@field ResizeToFitPadding {width: layout_measurement, height: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, maxX: layout_measurement}
LUIE_SCB_DebugOverflowTooltip = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_EffectsRegion_Template_Preview_Label : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SCB_EffectsRegion_Template_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SCB_Tlw_Template_Preview_Label : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SCB_Tlw_Template_Preview_Label = {}
---------- LVL: 07 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended\frontend\SpellCastBuffs.xml
