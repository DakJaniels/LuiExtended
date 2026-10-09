-- ////// START : GENERATED FROM frontend/MiniMap.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Tile : TextureControl
---@field public pixelRoundingEnabled boolean
---@field public textureFileReleaseOption ReleaseReferenceOptions
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_MiniMap_Tile = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Pin : Control
---@field public tier DrawTier
---@field public level integer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_MiniMap_Pin = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_AreaBlob : TextureControl
---@field public tier DrawTier
---@field public level integer
---@field public pixelRoundingEnabled boolean
---@field public shaderEffectType ShaderEffectType
LUIE_MiniMap_AreaBlob = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_PolygonBlob : PolygonControl
---@field public pointLayout PolygonPointLayout
---@field public smoothingEnabled boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Border {minThickness: layout_measurement, maxThickness: layout_measurement, textureFile: string}
LUIE_MiniMap_PolygonBlob = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_KeepLink : LineControl
---@field public level integer
---@field public thickness layout_measurement
LUIE_MiniMap_KeepLink = {}
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
---@field public OnMoveStop fun(self: Control)
---@field public OnResizeStart fun(self: Control)
---@field public OnResizeStop fun(self: Control)
---@field public OnMouseWheel fun(self: Control, delta: integer, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
---@field public OnRectChanged fun(self: Control, newLeft: number, newTop: number, newRight: number, newBottom: number, oldLeft: number, oldTop: number, oldRight: number, oldBottom: number)
LUIE_MiniMap = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_PinHighlight : TextureControl
---@field public textureFile string
---@field public pixelRoundingEnabled boolean
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_PinHighlight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_PinBackground : TextureControl
---@field public pixelRoundingEnabled boolean
---@field AnchorFill boolean
LUIE_MiniMap_PinBackground = {}
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
---@class LUIE_MiniMap_Background : BackdropControl
---@field public resizeToFitDescendents boolean
---@field public layer DrawLayer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_Background = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Parchment : TextureControl
---@field public textureFile string
---@field public addressMode TextureAddressMode
---@field public autoAdjustTextureCoords boolean
---@field public layer DrawLayer
---@field public level integer
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_Parchment = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll : ScrollControl
---@field public mouseEnabled boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field public OnMouseDown fun(self: Control, button: integer, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
---@field public OnScrollOffsetChanged fun(self: ScrollControl, horizontal: number, vertical: number)
LUIE_MiniMap_Scroll = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_ZoomLabel : LabelControl
---@field public font string
---@field public alpha number
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field public text string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_ZoomLabel = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_DragBar : Control
---@field public mouseEnabled boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field public OnInitialized fun(self: Control)
---@field public OnMouseEnter fun(self: Control)
---@field public OnMouseExit fun(self: Control)
---@field public OnDragStart fun(self: Control, button: integer)
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_MiniMap_DragBar = {}
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
---@class LUIE_MiniMap_ZoomMouseOverArea : Control
---@field public mouseEnabled boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field public OnMouseEnter fun(self: Control)
---@field public OnMouseExit fun(self: Control)
LUIE_MiniMap_ZoomMouseOverArea = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_ZoomIn : ButtonControl
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public mouseOverBlendMode TextureBlendMode
---@field public layer DrawLayer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Textures {normal: string, pressed: string, disabled: string, mouseOver: string}
---@field public OnClicked fun(self: Control, button: integer, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
---@field public OnMouseEnter fun(self: Control)
---@field public OnMouseExit fun(self: Control)
LUIE_MiniMap_ZoomIn = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_ZoomOut : ButtonControl
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public mouseOverBlendMode TextureBlendMode
---@field public layer DrawLayer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Textures {normal: string, pressed: string, disabled: string, mouseOver: string}
---@field public OnClicked fun(self: Control, button: integer, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
---@field public OnMouseEnter fun(self: Control)
---@field public OnMouseExit fun(self: Control)
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
---@field public OnMouseDown fun(self: Control, button: integer, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
---@field public OnMouseUp fun(self: Control, button: integer, upInside: boolean, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
LUIE_MiniMap_Scroll_Map = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_StatusOverlay : StatusBarControl
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field public color string
---@field public alpha number
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_MiniMap_Scroll_StatusOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_DragBar_Backdrop : BackdropControl
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public alpha number
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field Edge {file: string, edgeFileWidth: integer, edgeFileHeight: integer}
---@field Center {file: string}
LUIE_MiniMap_DragBar_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_DragBar_PositionLock : ButtonControl
---@field public mouseOverBlendMode TextureBlendMode
---@field public mouseEnabled boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
---@field public OnInitialized fun(self: Control)
---@field public OnClicked fun(self: Control, button: integer, ctrl: boolean, alt: boolean, shift: boolean, command: boolean)
---@field public OnMouseEnter fun(self: Control)
---@field public OnMouseExit fun(self: Control)
LUIE_MiniMap_DragBar_PositionLock = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_DragBar_DragHandle : Control
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_DragBar_DragHandle = {}
---------- LVL: 07 ----------
---------- LVL: 08 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_Map_Tiles : Control
---@field AnchorFill boolean
LUIE_MiniMap_Scroll_Map_Tiles = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_Map_Links : Control
---@field AnchorFill boolean
LUIE_MiniMap_Scroll_Map_Links = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_Map_Polygons : Control
---@field AnchorFill boolean
LUIE_MiniMap_Scroll_Map_Polygons = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_Map_Pins : Control
---@field AnchorFill boolean
LUIE_MiniMap_Scroll_Map_Pins = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_Scroll_StatusOverlay_Label : LabelControl
---@field public font string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field public text string
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_MiniMap_Scroll_StatusOverlay_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_DragBar_DragHandle_Line1 : TextureControl
---@field public color string
---@field public alpha number
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_DragBar_DragHandle_Line1 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_DragBar_DragHandle_Line2 : TextureControl
---@field public color string
---@field public alpha number
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_DragBar_DragHandle_Line2 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_MiniMap_DragBar_DragHandle_Line3 : TextureControl
---@field public color string
---@field public alpha number
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_MiniMap_DragBar_DragHandle_Line3 = {}
---------- LVL: 09 ----------
-- ////// END   : GENERATED FROM frontend/MiniMap.xml
