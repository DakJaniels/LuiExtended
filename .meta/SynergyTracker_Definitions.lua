-- ////// START : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended\frontend\SynergyTracker.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_RowTemplate : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_SynergyTracker_RowTemplate = {}
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
LUIE_SynergyTracker_UI = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_RowTemplate_IconBg : TextureControl
---@field public textureFile string
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_RowTemplate_IconBg = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_RowTemplate_Icon : TextureControl
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_RowTemplate_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_RowTemplate_PosNum : LabelControl
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_RowTemplate_PosNum = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_RowTemplate_Name : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public wrapMode TextWrapMode
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field DimensionConstraints {minX: layout_measurement, minY: layout_measurement, maxX: layout_measurement, maxY: layout_measurement}
LUIE_SynergyTracker_RowTemplate_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_RowTemplate_Priority : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_SynergyTracker_RowTemplate_Priority = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_RowTemplate_Cooldown : CooldownControl
---@field public hidden boolean
---@field public textureFile string
---@field public fillColor string
---@field public alpha number
---@field public desaturation number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_RowTemplate_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_RowTemplate_CooldownText : LabelControl
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public color string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_SynergyTracker_RowTemplate_CooldownText = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SynergyTracker_UI_Background : BackdropControl
---@field public hidden boolean
---@field public centerColor string
---@field public edgeColor string
---@field AnchorFill boolean
---@field public OnInitialized fun(self: Control)
LUIE_SynergyTracker_UI_Background = {}
---------- LVL: 05 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended\frontend\SynergyTracker.xml
