-- ////// START : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended/frontend\CrowdControlTracker.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker : TopLevelWindow
--- @field public mouseEnabled boolean
--- @field public movable boolean
--- @field public clampedToScreen boolean
--- @field public hidden boolean
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition}
--- @field public OnMoveStop fun(self: Control)
LUIE_CCTracker = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_IconFrame : Control
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition}
LUIE_CCTracker_IconFrame = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame : Control
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition}
LUIE_CCTracker_BreakFreeFrame = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_TextFrame : Control
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_CCTracker_TextFrame = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_Timer : Control
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field public OnUpdate fun(self: Control, time: number)
LUIE_CCTracker_Timer = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_IconFrame_Icon : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_CCTracker_IconFrame_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_IconFrame_IconBG : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_CCTracker_IconFrame_IconBG = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_IconFrame_UnderIcon : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field public color string
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_CCTracker_IconFrame_UnderIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_IconFrame_IconBorder : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_CCTracker_IconFrame_IconBorder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_IconFrame_IconBorderHighlight : TextureControl
--- @field public blendMode TextureBlendMode
--- @field public layer DrawLayer
--- @field public level integer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_CCTracker_IconFrame_IconBorderHighlight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_IconFrame_Cooldown : CooldownControl, ZO_DefaultCooldown
--- @field public layer DrawLayer
--- @field public level integer
--- @field public hidden boolean
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_CCTracker_IconFrame_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_IconFrame_GlobalCooldown : CooldownControl, ZO_DefaultCooldown
--- @field public layer DrawLayer
--- @field public level integer
--- @field public hidden boolean
--- @field public fillColor string
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_CCTracker_IconFrame_GlobalCooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Left : Control
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition}
LUIE_CCTracker_BreakFreeFrame_Left = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Right : Control
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition}
LUIE_CCTracker_BreakFreeFrame_Right = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Middle : Control
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition}
LUIE_CCTracker_BreakFreeFrame_Middle = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_TextFrame_Label : LabelControl
--- @field public horizontalAlignment TextAlignment
--- @field public verticalAlignment TextAlignment
--- @field public inheritAlpha boolean
--- @field public color string
--- @field public wrapMode TextWrapMode
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetY: layout_measurement}
LUIE_CCTracker_TextFrame_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_Timer_Label : LabelControl
--- @field public horizontalAlignment TextAlignment
--- @field public verticalAlignment TextAlignment
--- @field public inheritAlpha boolean
--- @field public font string
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetY: layout_measurement}
LUIE_CCTracker_Timer_Label = {}
---------- LVL: 07 ----------
---------- LVL: 08 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Left_Icon : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_CCTracker_BreakFreeFrame_Left_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Left_IconBG : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field public color string
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_CCTracker_BreakFreeFrame_Left_IconBG = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Left_UnderIcon : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field public color string
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_CCTracker_BreakFreeFrame_Left_UnderIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Left_IconBorder : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetY: layout_measurement}
LUIE_CCTracker_BreakFreeFrame_Left_IconBorder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Left_IconBorderHighlight : TextureControl
--- @field public blendMode TextureBlendMode
--- @field public layer DrawLayer
--- @field public level integer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetY: layout_measurement}
LUIE_CCTracker_BreakFreeFrame_Left_IconBorderHighlight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Right_Icon : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_CCTracker_BreakFreeFrame_Right_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Right_IconBG : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field public color string
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_CCTracker_BreakFreeFrame_Right_IconBG = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Right_UnderIcon : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field public color string
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_CCTracker_BreakFreeFrame_Right_UnderIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Right_IconBorder : TextureControl
--- @field public layer DrawLayer
--- @field public level integer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetY: layout_measurement}
LUIE_CCTracker_BreakFreeFrame_Right_IconBorder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
--- @class LUIE_CCTracker_BreakFreeFrame_Right_IconBorderHighlight : TextureControl
--- @field public blendMode TextureBlendMode
--- @field public layer DrawLayer
--- @field public level integer
--- @field Dimensions {x: layout_measurement, y: layout_measurement}
--- @field Anchor {point: AnchorPosition, offsetY: layout_measurement}
LUIE_CCTracker_BreakFreeFrame_Right_IconBorderHighlight = {}
---------- LVL: 09 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended/frontend\CrowdControlTracker.xml
