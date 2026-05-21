-- ////// START : GENERATED FROM C:\Users\dack_janiels\Documents\LUIE\LuiExtended\LuiExtended\frontend\InfoPanel.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel : TopLevelWindow
---@field public mouseEnabled boolean
---@field public clampedToScreen boolean
---@field public movable boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field public OnMoveStop fun(self: Control)
LUIE_InfoPanel = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_Divider : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {y: layout_measurement}
LUIE_InfoPanel_Divider = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_TopRow : Control
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_TopRow = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow : Control
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_TopRow_Latency : Control
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_TopRow_Latency = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_TopRow_Fps : LabelControl
---@field public font string
---@field public color string
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public wrapMode TextWrapMode
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_TopRow_Fps = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_TopRow_Memory : LabelControl
---@field public font string
---@field public color string
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public wrapMode TextWrapMode
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_TopRow_Memory = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_TopRow_Clock : LabelControl
---@field public font string
---@field public color string
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public wrapMode TextWrapMode
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_TopRow_Clock = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_TopRow_Gems : Control
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_TopRow_Gems = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_FeedTimer : Control
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_FeedTimer = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Armour : Control
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Armour = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Weapons : Control
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Weapons = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Bags : Control
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Bags = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Gold : Control
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Gold = {}
---------- LVL: 07 ----------
---------- LVL: 08 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_TopRow_Latency_Icon : TextureControl
---@field public textureFile string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_TopRow_Latency_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_TopRow_Latency_Label : LabelControl
---@field public font string
---@field public color string
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_TopRow_Latency_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_TopRow_Gems_Icon : TextureControl
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_TopRow_Gems_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_TopRow_Gems_Label : LabelControl
---@field public font string
---@field public color string
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_TopRow_Gems_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_FeedTimer_Icon : TextureControl
---@field public textureFile string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_FeedTimer_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_FeedTimer_Label : LabelControl
---@field public font string
---@field public color string
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_FeedTimer_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Armour_Icon : TextureControl
---@field public textureFile string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Armour_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Armour_Label : LabelControl
---@field public font string
---@field public color string
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Armour_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Weapons_Main : TextureControl
---@field public textureFile string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Weapons_Main = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Weapons_Swap : TextureControl
---@field public textureFile string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Weapons_Swap = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Bags_Icon : TextureControl
---@field public textureFile string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Bags_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Bags_Label : LabelControl
---@field public font string
---@field public color string
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Bags_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Gold_Icon : TextureControl
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Gold_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_InfoPanel_BotRow_Gold_Label : LabelControl
---@field public font string
---@field public color string
---@field public verticalAlignment TextAlignment
---@field public horizontalAlignment TextAlignment
---@field public text string
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_InfoPanel_BotRow_Gold_Label = {}
---------- LVL: 09 ----------
-- ////// END   : GENERATED FROM C:\Users\dack_janiels\Documents\LUIE\LuiExtended\LuiExtended\frontend\InfoPanel.xml
