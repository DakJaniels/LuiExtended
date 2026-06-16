-- ////// START : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended/frontend/MiniMap.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public resizeHandleSize number
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Zone : LabelControl
---@field public font string
---@field public layer DrawLayer
---@field public text string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_MiniMap_Zone = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_ZoomLabel : LabelControl
---@field public font string
---@field public alpha number
---@field public layer DrawLayer
---@field public text string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_ZoomLabel = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Background : BackdropControl
---@field public resizeToFitDescendents boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_Background = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll : ScrollControl
---@field public mouseEnabled boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_MiniMap_Scroll = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_ZoomIn : ButtonControl
---@field public hidden boolean
---@field public layer DrawLayer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Textures {normal: string, pressed: string, disabled: string}
LUIE_MiniMap_ZoomIn = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_ZoomOut : ButtonControl
---@field public hidden boolean
---@field public layer DrawLayer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Textures {normal: string, pressed: string, disabled: string}
LUIE_MiniMap_ZoomOut = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Player : TextureControl
---@field public resizeToFitFile boolean
---@field public layer DrawLayer
---@field public textureFile string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_MiniMap_Player = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_PlayerCam : TextureControl
---@field public resizeToFitFile boolean
---@field public layer DrawLayer
---@field public textureFile string
---@field public alpha number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_MiniMap_PlayerCam = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Zone_Divider : TextureControl
---@field public textureFile string
---@field Dimensions {y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_Zone_Divider = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_Map : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_MiniMap_Scroll_Map = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_StatusOverlay : StatusBarControl
---@field public layer DrawLayer
---@field public color string
---@field public alpha number
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_MiniMap_Scroll_StatusOverlay = {}
---------- LVL: 07 ----------
---------- LVL: 08 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_Map_Pins : Control
---@field public layer DrawLayer
---@field AnchorFill boolean
LUIE_MiniMap_Scroll_Map_Pins = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_StatusOverlay_Label : LabelControl
---@field public font string
---@field public layer DrawLayer
---@field public text string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_MiniMap_Scroll_StatusOverlay_Label = {}
---------- LVL: 09 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended/frontend/MiniMap.xml
-- ////// START : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended\frontend\MiniMap.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public resizeHandleSize number
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public shape ShapeType
---@field public tier DrawTier
---@field public allowBringToTop boolean
---@field public space Space
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Zone : LabelControl
---@field public font string
---@field public layer DrawLayer
---@field public text string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_MiniMap_Zone = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_ZoomLabel : LabelControl
---@field public font string
---@field public alpha number
---@field public layer DrawLayer
---@field public text string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_ZoomLabel = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Background : BackdropControl
---@field public resizeToFitDescendents boolean
---@field public layer DrawLayer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_Background = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll : ScrollControl
---@field public mouseEnabled boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_MiniMap_Scroll = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Player : TextureControl
---@field public resizeToFitFile boolean
---@field public layer DrawLayer
---@field public textureFile string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_MiniMap_Player = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_PlayerCam : TextureControl
---@field public resizeToFitFile boolean
---@field public layer DrawLayer
---@field public textureFile string
---@field public alpha number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_MiniMap_PlayerCam = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_ZoomIn : ButtonControl
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Textures {normal: string, pressed: string, disabled: string}
LUIE_MiniMap_ZoomIn = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_ZoomOut : ButtonControl
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Textures {normal: string, pressed: string, disabled: string}
LUIE_MiniMap_ZoomOut = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Zone_Divider : TextureControl
---@field public textureFile string
---@field Dimensions {y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_Zone_Divider = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_Map : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_MiniMap_Scroll_Map = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_StatusOverlay : StatusBarControl
---@field public layer DrawLayer
---@field public color string
---@field public alpha number
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_MiniMap_Scroll_StatusOverlay = {}
---------- LVL: 07 ----------
---------- LVL: 08 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_Map_Pins : Control
---@field public layer DrawLayer
---@field AnchorFill boolean
LUIE_MiniMap_Scroll_Map_Pins = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_StatusOverlay_Label : LabelControl
---@field public font string
---@field public layer DrawLayer
---@field public text string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_MiniMap_Scroll_StatusOverlay_Label = {}
---------- LVL: 09 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/Documents/LUIE/LuiExtended/LuiExtended\frontend\MiniMap.xml
