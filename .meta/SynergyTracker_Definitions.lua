-- ////// START : GENERATED FROM C:/Users/dack_janiels/source/repos/LUIE/LuiExtended/LuiExtended/frontend\SynergyTracker.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field public OnMoveStop fun(self: Control)
---@field public OnUpdate fun(self: Control, time: number)
LUIE_SynergyTracker_UI = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Background : BackdropControl
---@field public hidden boolean
---@field public centerColor string
---@field public edgeColor string
---@field AnchorFill boolean
LUIE_SynergyTracker_UI_Background = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row1 : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row1 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row2 : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row2 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row3 : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row3 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row4 : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row4 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row5 : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row5 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row6 : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row6 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row7 : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row7 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row8 : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row8 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row9 : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row9 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row10 : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row10 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Preview : BackdropControl
---@field public hidden boolean
---@field public centerColor string
---@field public edgeColor string
---@field AnchorFill boolean
LUIE_SynergyTracker_UI_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Preview_CoordLabel : LabelControl
---@field public font string
---@field public color string
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Preview_CoordLabel = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Preview_Label : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Preview_Label = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row1_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row1_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row1_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row1_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row1_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row1_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row1_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_UI_Row1_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row1_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row1_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row1_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row1_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row1_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row1_CooldownText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row2_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row2_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row2_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row2_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row2_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row2_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row2_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_UI_Row2_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row2_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row2_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row2_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row2_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row2_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row2_CooldownText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row3_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row3_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row3_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row3_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row3_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row3_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row3_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_UI_Row3_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row3_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row3_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row3_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row3_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row3_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row3_CooldownText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row4_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row4_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row4_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row4_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row4_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row4_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row4_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_UI_Row4_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row4_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row4_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row4_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row4_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row4_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row4_CooldownText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row5_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row5_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row5_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row5_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row5_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row5_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row5_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_UI_Row5_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row5_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row5_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row5_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row5_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row5_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row5_CooldownText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row6_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row6_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row6_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row6_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row6_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row6_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row6_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_UI_Row6_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row6_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row6_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row6_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row6_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row6_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row6_CooldownText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row7_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row7_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row7_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row7_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row7_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row7_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row7_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_UI_Row7_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row7_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row7_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row7_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row7_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row7_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row7_CooldownText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row8_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row8_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row8_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row8_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row8_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row8_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row8_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_UI_Row8_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row8_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row8_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row8_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row8_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row8_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row8_CooldownText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row9_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row9_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row9_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row9_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row9_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row9_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row9_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_UI_Row9_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row9_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row9_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row9_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row9_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row9_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row9_CooldownText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row10_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row10_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row10_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row10_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row10_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public text string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row10_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row10_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_UI_Row10_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row10_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_UI_Row10_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row10_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row10_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Row10_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_UI_Row10_CooldownText = {}
---------- LVL: 07 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/source/repos/LUIE/LuiExtended/LuiExtended/frontend\SynergyTracker.xml
