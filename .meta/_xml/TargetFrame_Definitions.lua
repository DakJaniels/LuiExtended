-- ////// START : GENERATED FROM C:/Users/dack_janiels/Desktop/LUIE_WORKSPACE/LuiExtended/LuiExtended\frontend\UnitFrames\TargetFrame.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_UF_TargetFrame_Template = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Preview : Control
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Target = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Buffs : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_TargetFrame_Template_Buffs = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Debuffs : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_TargetFrame_Template_Debuffs = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Preview_Backdrop : BackdropControl
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Edge {edgeSize: layout_measurement}
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Preview_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Preview_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health : BackdropControl
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_Health = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Skull : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_Skull = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_TopInfo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_BotInfo : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_BotInfo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_BuffAnchor : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_BuffAnchor = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Buffs_Preview : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Buffs_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Buffs_IconHolder : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Buffs_IconHolder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Debuffs_Preview : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Debuffs_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Debuffs_IconHolder : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Debuffs_IconHolder = {}
---------- LVL: 07 ----------
---------- LVL: 08 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_Bar : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Target_Health_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_Trauma : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Target_Health_Trauma = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_Invulnerable : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Target_Health_Invulnerable = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_InvulnerableInlay : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Target_Health_InvulnerableInlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_Shield : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Target_Health_Shield = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_NoHealingOverlay : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Target_Health_NoHealingOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_NoHealingStripe : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Target_Health_NoHealingStripe = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_PossessionOverlay : Control
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_TargetFrame_Template_Target_Health_PossessionOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_ArmorInc : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_Health_ArmorInc = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_LabelOne : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_Health_LabelOne = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_LabelTwo : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_Health_LabelTwo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_Dead : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_Health_Dead = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_Name : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Target_TopInfo_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_OverlandDifficultyIcon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Target_TopInfo_OverlandDifficultyIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_LevelIcon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Target_TopInfo_LevelIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_VeterancyRankIcon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Target_TopInfo_VeterancyRankIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_Level : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public maxLineCount integer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_TopInfo_Level = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_ClassIcon : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_TopInfo_ClassIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_ClassName : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_TopInfo_ClassName = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_FriendIcon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_TopInfo_FriendIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_Star1 : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_TopInfo_Star1 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_Star2 : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_TopInfo_Star2 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_Star3 : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_TopInfo_Star3 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_BotInfo_Title : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Target_BotInfo_Title = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_BotInfo_AvaRankIcon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_BotInfo_AvaRankIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_BotInfo_AvaRank : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_TargetFrame_Template_Target_BotInfo_AvaRank = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Buffs_Preview_Label : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Buffs_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Debuffs_Preview_Label : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Debuffs_Preview_Label = {}
---------- LVL: 09 ----------
---------- LVL: 10 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_PossessionOverlay_GlowLeft : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_TargetFrame_Template_Target_Health_PossessionOverlay_GlowLeft = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_PossessionOverlay_GlowRight : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_TargetFrame_Template_Target_Health_PossessionOverlay_GlowRight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_PossessionOverlay_GlowCenter : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_TargetFrame_Template_Target_Health_PossessionOverlay_GlowCenter = {}
---------- LVL: 11 ----------
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/Desktop/LUIE_WORKSPACE/LuiExtended/LuiExtended\frontend\UnitFrames\TargetFrame.xml
