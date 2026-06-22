-- ////// START : GENERATED FROM C:/Users/dack_janiels/Desktop/LUIE_WORKSPACE/LuiExtended/LuiExtended\frontend\UnitFrames\CompanionFrame.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionAbilitySlot_Template : BackdropControl
---@field public mouseEnabled boolean
---@field public centerColor string
---@field public edgeColor string
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Edge {edgeSize: layout_measurement}
---@field public OnInitialized fun(self: Control)
LUIE_UF_CompanionAbilitySlot_Template = {}
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
LUIE_UF_CompanionFrame_Template = {}
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionAbilitySlot_Template_Icon : TextureControl
---@field public textureFile string
---@field public layer DrawLayer
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_CompanionAbilitySlot_Template_Icon = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionAbilitySlot_Template_Cooldown : CooldownControl
---@field public tier DrawTier
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_CompanionAbilitySlot_Template_Cooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionAbilitySlot_Template_EffectCooldown : CooldownControl
---@field public tier DrawTier
---@field public fillColor string
---@field public alpha number
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_CompanionAbilitySlot_Template_EffectCooldown = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionAbilitySlot_Template_Duration : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_CompanionAbilitySlot_Template_Duration = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionAbilitySlot_Template_Stack : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_CompanionAbilitySlot_Template_Stack = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Preview : Control
---@field public hidden boolean
---@field public mouseEnabled boolean
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field AnchorFill boolean
LUIE_UF_CompanionFrame_Template_Preview = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion : Control
---@field public hidden boolean
---@field Dimensions {x: layout_measurement, y: layout_measurement}
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition}
LUIE_UF_CompanionFrame_Template_Companion = {}
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Preview_Backdrop : BackdropControl
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public level integer
---@field Edge {edgeSize: layout_measurement}
---@field AnchorFill boolean
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
---@field public hidden boolean
---@field AnchorFill boolean
---@field Edge {edgeSize: layout_measurement}
LUIE_UF_CompanionFrame_Template_Companion_Health = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_RapportFlourish : LabelControl
---@field public text string
---@field public font string
---@field public color string
---@field public horizontalAlignment TextAlignment
---@field public verticalAlignment TextAlignment
---@field public layer DrawLayer
---@field public tier DrawTier
---@field public hidden boolean
---@field Anchor {point: AnchorPosition, relativeTo: string, relativePoint: AnchorPosition, offsetX: layout_measurement}
LUIE_UF_CompanionFrame_Template_Companion_RapportFlourish = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities : Control
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities = {}
---------- LVL: 07 ----------
---------- LVL: 08 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_Bar : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_Bar = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_Trauma : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_Trauma = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_Shield : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_Shield = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_NoHealingOverlay : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_NoHealingOverlay = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_NoHealingStripe : StatusBarControl
---@field public hidden boolean
---@field AnchorFill boolean
LUIE_UF_CompanionFrame_Template_Companion_Health_NoHealingStripe = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_Health_PossessionOverlay : Control
---@field public hidden boolean
---@field AnchorFill boolean
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
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_SlotBuiltinInterrupt : BackdropControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_SlotBuiltinInterrupt = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot3 : BackdropControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot3 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot4 : BackdropControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot4 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot5 : BackdropControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot5 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot6 : BackdropControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot6 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot7 : BackdropControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot7 = {}
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot8 : BackdropControl
---@field public hidden boolean
LUIE_UF_CompanionFrame_Template_Companion_CompanionAbilities_Slot8 = {}
---------- LVL: 09 ----------
---------- LVL: 10 ----------
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
-- ////// END   : GENERATED FROM C:/Users/dack_janiels/Desktop/LUIE_WORKSPACE/LuiExtended/LuiExtended\frontend\UnitFrames\CompanionFrame.xml
