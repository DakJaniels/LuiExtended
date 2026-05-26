-- ////// START : GENERATED FROM C:\Users\dack_janiels\Documents\LUIE\LuiExtended\LuiExtended\frontend\UnitFrames.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_PossessionHaloAnimation : AnimationTimeline
---@field public playbackType AnimationPlayback
---@field public loopCount string
LUIE_PossessionHaloAnimation = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_NoHealingFadeAnimation : AnimationTimeline
---@field public OnStop fun(self: AnimationTimeline, completedPlaying: boolean)
LUIE_NoHealingFadeAnimation = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_RegenAnimationTemplate : AnimationTimeline
---@field public playbackType AnimationPlayback
---@field public loopCount string
LUIE_RegenAnimationTemplate = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_PowerGlowAnimation : AnimationTimeline
---@field public playbackType AnimationPlayback
---@field public loopCount string
LUIE_PowerGlowAnimation = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_CombatGlowBorder : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public tier DrawTier
---@field public level integer
---@field public hidden boolean
---@field Edge {edgeSize: layout_measurement}
LUIE_CombatGlowBorder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_DodgePredictionMarker : BackdropControl
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public tier DrawTier
---@field public layer DrawLayer
---@field public level integer
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Edge {edgeSize: layout_measurement}
LUIE_DodgePredictionMarker = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_DecreasedArmorOverlay : Control
---@field public tier DrawTier
---@field public level integer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_DecreasedArmorOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_DecreasedArmorOverlay_Small : Control
---@field public tier DrawTier
---@field public level integer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Dimensions {x: layout_measurement, y: layout_measurement}
LUIE_DecreasedArmorOverlay_Small = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_SmallGroupMember_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template : Control
---@field public mouseEnabled boolean
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_RaidGroupMember_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_PetGroupMember_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_BossMember_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_PlayerFrame_Template = {}
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
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_TargetFrame_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_AvaPlayerTargetFrame_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupFrame_Template : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_SmallGroupFrame_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupFrame_Template : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_RaidGroupFrame_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetFrame_Template : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_PetFrame_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_CompanionFrame_Template = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossFrame_Template : TopLevelWindow
---@field public mouseEnabled boolean
---@field public movable boolean
---@field public clampedToScreen boolean
---@field public hidden boolean
---@field public layer DrawLayer
---@field public level integer
---@field public tier DrawTier
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_BossFrame_Template = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_DecreasedArmorOverlay_SmallTex : TextureControl
---@field public layer DrawLayer
---@field public level integer
---@field public alpha number
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_DecreasedArmorOverlay_SmallTex = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_DecreasedArmorOverlay_NormalTex : TextureControl
---@field public layer DrawLayer
---@field public level integer
---@field public alpha number
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_DecreasedArmorOverlay_NormalTex = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_DecreasedArmorOverlay_Small_SmallTex : TextureControl
---@field public layer DrawLayer
---@field public level integer
---@field public alpha number
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_DecreasedArmorOverlay_Small_SmallTex = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_SmallGroupMember_Template_Health = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_TopInfo : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_SmallGroupMember_Template_TopInfo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer : Control
---@field public hidden boolean
LUIE_UF_SmallGroupMember_Template_LibGroupContainer = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_ResourceMagicka : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_SmallGroupMember_Template_ResourceMagicka = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_ResourceStamina : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_SmallGroupMember_Template_ResourceStamina = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_RaidGroupMember_Template_Health = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_LibGroupContainer : Control
---@field public hidden boolean
LUIE_UF_RaidGroupMember_Template_LibGroupContainer = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_ResourceMagicka : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_RaidGroupMember_Template_ResourceMagicka = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_ResourceStamina : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_RaidGroupMember_Template_ResourceStamina = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_PetGroupMember_Template_Health = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_BossMember_Template_Health = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Preview : Control
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public clampedToScreen boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
LUIE_UF_PlayerFrame_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_PlayerFrame_Template_Player = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Buffs : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_PlayerFrame_Template_Buffs = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Debuffs : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_PlayerFrame_Template_Debuffs = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Preview : Control
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public clampedToScreen boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
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
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Preview : Control
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public clampedToScreen boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
LUIE_UF_AvaPlayerTargetFrame_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_AvaPlayerTargetFrame_Template_Target = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupFrame_Template_Preview : Control
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public clampedToScreen boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
LUIE_UF_SmallGroupFrame_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupFrame_Template_Preview : Control
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public clampedToScreen boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
LUIE_UF_RaidGroupFrame_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetFrame_Template_Preview : Control
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public clampedToScreen boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
LUIE_UF_PetFrame_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Preview : Control
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public clampedToScreen boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
LUIE_UF_CompanionFrame_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_CompanionFrame_Template_Companion = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossFrame_Template_Preview : Control
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public clampedToScreen boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
LUIE_UF_BossFrame_Template_Preview = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_SmallGroupMember_Template_Health_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_Trauma : StatusBarControl
---@field public hidden boolean
LUIE_UF_SmallGroupMember_Template_Health_Trauma = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_Shield : StatusBarControl
---@field public hidden boolean
LUIE_UF_SmallGroupMember_Template_Health_Shield = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_NoHealingOverlay : StatusBarControl
---@field public hidden boolean
LUIE_UF_SmallGroupMember_Template_Health_NoHealingOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_NoHealingStripe : StatusBarControl
---@field public hidden boolean
LUIE_UF_SmallGroupMember_Template_Health_NoHealingStripe = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_PossessionOverlay : Control
---@field public hidden boolean
LUIE_UF_SmallGroupMember_Template_Health_PossessionOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_ArmorInc : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_SmallGroupMember_Template_Health_ArmorInc = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_LabelOne : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_SmallGroupMember_Template_Health_LabelOne = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_LabelTwo : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_SmallGroupMember_Template_Health_LabelTwo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_RoleIcon : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_SmallGroupMember_Template_Health_RoleIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_Dead : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_SmallGroupMember_Template_Health_Dead = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_StatsLabel : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement, offsetY: layout_measurement}
LUIE_UF_SmallGroupMember_Template_Health_StatsLabel = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_TopInfo_Name : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_SmallGroupMember_Template_TopInfo_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_TopInfo_LevelIcon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_SmallGroupMember_Template_TopInfo_LevelIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_TopInfo_Level : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_SmallGroupMember_Template_TopInfo_Level = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_TopInfo_ClassIcon : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_SmallGroupMember_Template_TopInfo_ClassIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_TopInfo_FriendIcon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_SmallGroupMember_Template_TopInfo_FriendIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_TopInfo_Leader : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_SmallGroupMember_Template_TopInfo_Leader = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer_FoodDrinkBackdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_SmallGroupMember_Template_LibGroupContainer_FoodDrinkBackdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer_Ult1Backdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_SmallGroupMember_Template_LibGroupContainer_Ult1Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer_Ult2Backdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_SmallGroupMember_Template_LibGroupContainer_Ult2Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer_PotionBackdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_SmallGroupMember_Template_LibGroupContainer_PotionBackdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_ResourceMagicka_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_SmallGroupMember_Template_ResourceMagicka_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_ResourceStamina_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_SmallGroupMember_Template_ResourceStamina_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_RaidGroupMember_Template_Health_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_Trauma : StatusBarControl
---@field public hidden boolean
LUIE_UF_RaidGroupMember_Template_Health_Trauma = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_Shield : StatusBarControl
---@field public hidden boolean
LUIE_UF_RaidGroupMember_Template_Health_Shield = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_NoHealingOverlay : StatusBarControl
---@field public hidden boolean
LUIE_UF_RaidGroupMember_Template_Health_NoHealingOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_NoHealingStripe : StatusBarControl
---@field public hidden boolean
LUIE_UF_RaidGroupMember_Template_Health_NoHealingStripe = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_PossessionOverlay : Control
---@field public hidden boolean
LUIE_UF_RaidGroupMember_Template_Health_PossessionOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_RaidGroupMember_Template_Health_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_Name : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_RaidGroupMember_Template_Health_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_RoleIcon : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_RaidGroupMember_Template_Health_RoleIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_ClassIcon : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_RaidGroupMember_Template_Health_ClassIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_Dead : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_RaidGroupMember_Template_Health_Dead = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_Leader : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_RaidGroupMember_Template_Health_Leader = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_ResourceMagicka_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_RaidGroupMember_Template_ResourceMagicka_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_ResourceStamina_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_RaidGroupMember_Template_ResourceStamina_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_PetGroupMember_Template_Health_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_Trauma : StatusBarControl
---@field public hidden boolean
LUIE_UF_PetGroupMember_Template_Health_Trauma = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_Shield : StatusBarControl
---@field public hidden boolean
LUIE_UF_PetGroupMember_Template_Health_Shield = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_NoHealingOverlay : StatusBarControl
---@field public hidden boolean
LUIE_UF_PetGroupMember_Template_Health_NoHealingOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_NoHealingStripe : StatusBarControl
---@field public hidden boolean
LUIE_UF_PetGroupMember_Template_Health_NoHealingStripe = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_PossessionOverlay : Control
---@field public hidden boolean
LUIE_UF_PetGroupMember_Template_Health_PossessionOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_ArmorInc : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PetGroupMember_Template_Health_ArmorInc = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PetGroupMember_Template_Health_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_Dead : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PetGroupMember_Template_Health_Dead = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_Name : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PetGroupMember_Template_Health_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_BossMember_Template_Health_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_Trauma : StatusBarControl
---@field public hidden boolean
LUIE_UF_BossMember_Template_Health_Trauma = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_Invulnerable : StatusBarControl
---@field public hidden boolean
LUIE_UF_BossMember_Template_Health_Invulnerable = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_InvulnerableInlay : StatusBarControl
---@field public hidden boolean
LUIE_UF_BossMember_Template_Health_InvulnerableInlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_Shield : StatusBarControl
---@field public hidden boolean
LUIE_UF_BossMember_Template_Health_Shield = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_NoHealingOverlay : StatusBarControl
---@field public hidden boolean
LUIE_UF_BossMember_Template_Health_NoHealingOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_NoHealingStripe : StatusBarControl
---@field public hidden boolean
LUIE_UF_BossMember_Template_Health_NoHealingStripe = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_PossessionOverlay : Control
---@field public hidden boolean
LUIE_UF_BossMember_Template_Health_PossessionOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_ThresholdContainer : Control
---@field public hidden boolean
LUIE_UF_BossMember_Template_Health_ThresholdContainer = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_BossMember_Template_Health_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_Dead : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_BossMember_Template_Health_Dead = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_Name : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_BossMember_Template_Health_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Preview_Backdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_PlayerFrame_Template_Preview_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Preview_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_PlayerFrame_Template_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_Health = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Magicka : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_Magicka = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Stamina : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_Stamina = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_TopInfo : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_TopInfo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_BotInfo : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_BotInfo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_BuffAnchor : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_BuffAnchor = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Buffs_Preview : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Buffs_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Buffs_IconHolder : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_PlayerFrame_Template_Buffs_IconHolder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Debuffs_Preview : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Debuffs_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Debuffs_IconHolder : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_PlayerFrame_Template_Debuffs_IconHolder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Preview_Backdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Edge {edgeSize: layout_measurement}
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
---@field public centerColor string
---@field public edgeColor string
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
LUIE_UF_TargetFrame_Template_Debuffs_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Debuffs_IconHolder : Control
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Debuffs_IconHolder = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Preview_Backdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_AvaPlayerTargetFrame_Template_Preview_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Preview_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_AvaPlayerTargetFrame_Template_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_TopInfo : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_TopInfo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_BotInfo : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_BotInfo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_BuffAnchor : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_BuffAnchor = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupFrame_Template_Preview_Backdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_SmallGroupFrame_Template_Preview_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupFrame_Template_Preview_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_SmallGroupFrame_Template_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupFrame_Template_Preview_Backdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_RaidGroupFrame_Template_Preview_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupFrame_Template_Preview_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_RaidGroupFrame_Template_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetFrame_Template_Preview_Backdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_PetFrame_Template_Preview_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetFrame_Template_Preview_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_PetFrame_Template_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Preview_Backdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_CompanionFrame_Template_Preview_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Preview_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_CompanionFrame_Template_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_CompanionFrame_Template_Companion_Health = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossFrame_Template_Preview_Backdrop : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_BossFrame_Template_Preview_Backdrop = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossFrame_Template_Preview_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetY: layout_measurement}
LUIE_UF_BossFrame_Template_Preview_Label = {}
---------- LVL: 07 ----------
---------- LVL: 08 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_PossessionOverlay_GlowLeft : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_SmallGroupMember_Template_Health_PossessionOverlay_GlowLeft = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_PossessionOverlay_GlowRight : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_SmallGroupMember_Template_Health_PossessionOverlay_GlowRight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_Health_PossessionOverlay_GlowCenter : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_SmallGroupMember_Template_Health_PossessionOverlay_GlowCenter = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer_FoodDrinkBackdrop_Icon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_SmallGroupMember_Template_LibGroupContainer_FoodDrinkBackdrop_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer_FoodDrinkBackdrop_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_SmallGroupMember_Template_LibGroupContainer_FoodDrinkBackdrop_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer_Ult1Backdrop_Icon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_SmallGroupMember_Template_LibGroupContainer_Ult1Backdrop_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer_Ult2Backdrop_Icon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_SmallGroupMember_Template_LibGroupContainer_Ult2Backdrop_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer_PotionBackdrop_Icon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_SmallGroupMember_Template_LibGroupContainer_PotionBackdrop_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_SmallGroupMember_Template_LibGroupContainer_PotionBackdrop_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_SmallGroupMember_Template_LibGroupContainer_PotionBackdrop_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_PossessionOverlay_GlowLeft : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_RaidGroupMember_Template_Health_PossessionOverlay_GlowLeft = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_PossessionOverlay_GlowRight : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_RaidGroupMember_Template_Health_PossessionOverlay_GlowRight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_RaidGroupMember_Template_Health_PossessionOverlay_GlowCenter : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_RaidGroupMember_Template_Health_PossessionOverlay_GlowCenter = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_PossessionOverlay_GlowLeft : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_PetGroupMember_Template_Health_PossessionOverlay_GlowLeft = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_PossessionOverlay_GlowRight : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_PetGroupMember_Template_Health_PossessionOverlay_GlowRight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PetGroupMember_Template_Health_PossessionOverlay_GlowCenter : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_PetGroupMember_Template_Health_PossessionOverlay_GlowCenter = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_PossessionOverlay_GlowLeft : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_BossMember_Template_Health_PossessionOverlay_GlowLeft = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_PossessionOverlay_GlowRight : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_BossMember_Template_Health_PossessionOverlay_GlowRight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_BossMember_Template_Health_PossessionOverlay_GlowCenter : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_BossMember_Template_Health_PossessionOverlay_GlowCenter = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Player_Health_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_Trauma : StatusBarControl
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Player_Health_Trauma = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_Shield : StatusBarControl
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Player_Health_Shield = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_NoHealingOverlay : StatusBarControl
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Player_Health_NoHealingOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_NoHealingStripe : StatusBarControl
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Player_Health_NoHealingStripe = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_PossessionOverlay : Control
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Player_Health_PossessionOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_ArmorInc : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_Health_ArmorInc = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_LabelOne : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_Health_LabelOne = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_LabelTwo : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_Health_LabelTwo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Magicka_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Player_Magicka_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Magicka_LabelOne : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_Magicka_LabelOne = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Magicka_LabelTwo : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_Magicka_LabelTwo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Stamina_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Player_Stamina_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Stamina_LabelOne : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_Stamina_LabelOne = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Stamina_LabelTwo : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_Stamina_LabelTwo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_TopInfo_Name : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_PlayerFrame_Template_Player_TopInfo_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_TopInfo_LevelIcon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_PlayerFrame_Template_Player_TopInfo_LevelIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_TopInfo_Level : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_TopInfo_Level = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_TopInfo_ClassIcon : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_TopInfo_ClassIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_BotInfo_Alternative : BackdropControl
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_BotInfo_Alternative = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_BotInfo_Dead : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_BotInfo_Dead = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Buffs_Preview_Label : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_PlayerFrame_Template_Buffs_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Debuffs_Preview_Label : LabelControl
---@field public wrapMode TextWrapMode
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public excludeFromResizeToFitExtents boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_PlayerFrame_Template_Debuffs_Preview_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_TargetFrame_Template_Target_Health_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_Trauma : StatusBarControl
---@field public hidden boolean
LUIE_UF_TargetFrame_Template_Target_Health_Trauma = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_Invulnerable : StatusBarControl
---@field public hidden boolean
LUIE_UF_TargetFrame_Template_Target_Health_Invulnerable = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_InvulnerableInlay : StatusBarControl
---@field public hidden boolean
LUIE_UF_TargetFrame_Template_Target_Health_InvulnerableInlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_Shield : StatusBarControl
---@field public hidden boolean
LUIE_UF_TargetFrame_Template_Target_Health_Shield = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_NoHealingOverlay : StatusBarControl
---@field public hidden boolean
LUIE_UF_TargetFrame_Template_Target_Health_NoHealingOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_NoHealingStripe : StatusBarControl
---@field public hidden boolean
LUIE_UF_TargetFrame_Template_Target_Health_NoHealingStripe = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_Health_PossessionOverlay : Control
---@field public hidden boolean
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
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_LevelIcon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_TargetFrame_Template_Target_TopInfo_LevelIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_TargetFrame_Template_Target_TopInfo_Level : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
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
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_Trauma : StatusBarControl
---@field public hidden boolean
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_Trauma = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_Shield : StatusBarControl
---@field public hidden boolean
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_Shield = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_NoHealingOverlay : StatusBarControl
---@field public hidden boolean
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_NoHealingOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_NoHealingStripe : StatusBarControl
---@field public hidden boolean
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_NoHealingStripe = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_PossessionOverlay : Control
---@field public hidden boolean
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_PossessionOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_LabelOne : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_LabelOne = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_LabelTwo : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_LabelTwo = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_TopInfo_Name : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_TopInfo_Name = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_TopInfo_ClassIcon : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_TopInfo_ClassIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_TopInfo_AvaRankIcon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_TopInfo_AvaRankIcon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_BotInfo_ClassName : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_BotInfo_ClassName = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_BotInfo_Title : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_BotInfo_Title = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_BotInfo_AvaRank : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_BotInfo_AvaRank = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_BotInfo_Dead : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_BotInfo_Dead = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_Trauma : StatusBarControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_Trauma = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_Shield : StatusBarControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_Shield = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_NoHealingOverlay : StatusBarControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_NoHealingOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_NoHealingStripe : StatusBarControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_NoHealingStripe = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_PossessionOverlay : Control
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_PossessionOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_ArmorInc : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_CompanionFrame_Template_Companion_Health_ArmorInc = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_Label : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_CompanionFrame_Template_Companion_Health_Label = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_Dead : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_CompanionFrame_Template_Companion_Health_Dead = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_Name : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_CompanionFrame_Template_Companion_Health_Name = {}
---------- LVL: 09 ----------
---------- LVL: 10 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_PossessionOverlay_GlowLeft : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_PlayerFrame_Template_Player_Health_PossessionOverlay_GlowLeft = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_PossessionOverlay_GlowRight : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_PlayerFrame_Template_Player_Health_PossessionOverlay_GlowRight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_Health_PossessionOverlay_GlowCenter : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_PlayerFrame_Template_Player_Health_PossessionOverlay_GlowCenter = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_BotInfo_Alternative_Enlightenment : StatusBarControl
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Player_BotInfo_Alternative_Enlightenment = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_BotInfo_Alternative_Bar : StatusBarControl
---@field public hidden boolean
LUIE_UF_PlayerFrame_Template_Player_BotInfo_Alternative_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_PlayerFrame_Template_Player_BotInfo_Alternative_Icon : TextureControl
---@field public textureFile string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_PlayerFrame_Template_Player_BotInfo_Alternative_Icon = {}
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
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_PossessionOverlay_GlowLeft : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_PossessionOverlay_GlowLeft = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_PossessionOverlay_GlowRight : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_PossessionOverlay_GlowRight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_PossessionOverlay_GlowCenter : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_AvaPlayerTargetFrame_Template_Target_Health_PossessionOverlay_GlowCenter = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_PossessionOverlay_GlowLeft : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_CompanionFrame_Template_Companion_Health_PossessionOverlay_GlowLeft = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_PossessionOverlay_GlowRight : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_CompanionFrame_Template_Companion_Health_PossessionOverlay_GlowRight = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_PossessionOverlay_GlowCenter : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field Anchor2 {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
---@field TextureCoords {left: number, right: number, top: number, bottom: number}
LUIE_UF_CompanionFrame_Template_Companion_Health_PossessionOverlay_GlowCenter = {}
---------- LVL: 11 ----------
-- ////// END   : GENERATED FROM C:\Users\dack_janiels\Documents\LUIE\LuiExtended\LuiExtended\frontend\UnitFrames.xml
