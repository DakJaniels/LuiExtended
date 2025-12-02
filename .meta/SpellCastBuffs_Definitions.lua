-- ////// START : GENERATED FROM C:/Users/dack_janiels/source/repos/LUIE/LuiExtended/LuiExtended/frontend\SpellCastBuffs.xml
---------- LVL: 00 ----------
---------- LVL: 01 ----------
---------- LVL: 02 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerBuffs : TopLevelWindow
---@field preview LUIE_SpellCastBuffs_PlayerBuffsPreview
---@field previewLabel LUIE_SpellCastBuffs_PlayerBuffsPreviewPreviewLabel|nil
LUIE_SpellCastBuffs_PlayerBuffs = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerDebuffs : TopLevelWindow
---@field preview LUIE_SpellCastBuffs_PlayerDebuffsPreview
---@field previewLabel LUIE_SpellCastBuffs_PlayerDebuffsPreviewPreviewLabel|nil
LUIE_SpellCastBuffs_PlayerDebuffs = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetBuffs : TopLevelWindow
---@field preview LUIE_SpellCastBuffs_TargetBuffsPreview
---@field previewLabel LUIE_SpellCastBuffs_TargetBuffsPreviewPreviewLabel|nil
LUIE_SpellCastBuffs_TargetBuffs = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetDebuffs : TopLevelWindow
---@field preview LUIE_SpellCastBuffs_TargetDebuffsPreview
---@field previewLabel LUIE_SpellCastBuffs_TargetDebuffsPreviewPreviewLabel|nil
LUIE_SpellCastBuffs_TargetDebuffs = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentBuffs : TopLevelWindow
---@field alignVertical boolean
---@field preview LUIE_SpellCastBuffs_ProminentBuffsPreview
---@field previewLabel LUIE_SpellCastBuffs_ProminentBuffsPreviewPreviewLabel|nil
---@field iconHolder LUIE_SpellCastBuffs_ProminentBuffsIconHolder
LUIE_SpellCastBuffs_ProminentBuffs = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentDebuffs : TopLevelWindow
---@field alignVertical boolean
---@field preview LUIE_SpellCastBuffs_ProminentDebuffsPreview
---@field previewLabel LUIE_SpellCastBuffs_ProminentDebuffsPreviewPreviewLabel|nil
---@field iconHolder LUIE_SpellCastBuffs_ProminentDebuffsIconHolder
LUIE_SpellCastBuffs_ProminentDebuffs = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerLong : TopLevelWindow
---@field alignVertical boolean
---@field skipUpdate integer
---@field preview LUIE_SpellCastBuffs_PlayerLongPreview
---@field previewLabel LUIE_SpellCastBuffs_PlayerLongPreviewPreviewLabel|nil
---@field iconHolder LUIE_SpellCastBuffs_PlayerLongIconHolder
LUIE_SpellCastBuffs_PlayerLong = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIcon : Control
---@field back LUIE_SpellCastBuffIconBack
---@field frame LUIE_SpellCastBuffIconFrame
---@field iconbg LUIE_SpellCastBuffIconIconBG
---@field drop LUIE_SpellCastBuffIconDrop
---@field icon LUIE_SpellCastBuffIconIconBGIcon
---@field cd LUIE_SpellCastBuffIconCooldown
---@field label LUIE_SpellCastBuffIconLabel
---@field abilityId LUIE_SpellCastBuffIconAbilityId
---@field stack LUIE_SpellCastBuffIconStack
---@field name LUIE_SpellCastBuffIconName|nil
---@field bar {backdrop: LUIE_SpellCastBuffIconBarBackdrop, bar: LUIE_SpellCastBuffIconBar}|nil
---@field data table|nil
---@field effectSlotId string|nil
---@field effectId integer|nil
---@field effectName string|nil
---@field buffType BuffEffectType|nil
---@field buffSlot integer|nil
---@field tooltip string|nil
---@field duration number|nil
---@field container string|nil
---@field effectType BuffEffectType|nil
---@field isArtificial boolean|nil
LUIE_SpellCastBuffIcon = ...
---------- LVL: 03 ----------
---------- LVL: 04 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerBuffsPreview : TextureControl
---@field anchorLabel LUIE_SpellCastBuffs_PlayerBuffsPreviewAnchorLabel
---@field anchorTexture LUIE_SpellCastBuffs_PlayerBuffsPreviewAnchorTexture
---@field anchorLabelBg LUIE_SpellCastBuffs_PlayerBuffsPreviewAnchorLabelBg
LUIE_SpellCastBuffs_PlayerBuffsPreview = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerDebuffsPreview : TextureControl
---@field anchorLabel LUIE_SpellCastBuffs_PlayerDebuffsPreviewAnchorLabel
---@field anchorTexture LUIE_SpellCastBuffs_PlayerDebuffsPreviewAnchorTexture
---@field anchorLabelBg LUIE_SpellCastBuffs_PlayerDebuffsPreviewAnchorLabelBg
LUIE_SpellCastBuffs_PlayerDebuffsPreview = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetBuffsPreview : TextureControl
---@field anchorLabel LUIE_SpellCastBuffs_TargetBuffsPreviewAnchorLabel
---@field anchorTexture LUIE_SpellCastBuffs_TargetBuffsPreviewAnchorTexture
---@field anchorLabelBg LUIE_SpellCastBuffs_TargetBuffsPreviewAnchorLabelBg
LUIE_SpellCastBuffs_TargetBuffsPreview = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetDebuffsPreview : TextureControl
---@field anchorLabel LUIE_SpellCastBuffs_TargetDebuffsPreviewAnchorLabel
---@field anchorTexture LUIE_SpellCastBuffs_TargetDebuffsPreviewAnchorTexture
---@field anchorLabelBg LUIE_SpellCastBuffs_TargetDebuffsPreviewAnchorLabelBg
LUIE_SpellCastBuffs_TargetDebuffsPreview = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentBuffsPreview : TextureControl
---@field anchorLabel LUIE_SpellCastBuffs_ProminentBuffsPreviewAnchorLabel
---@field anchorTexture LUIE_SpellCastBuffs_ProminentBuffsPreviewAnchorTexture
---@field anchorLabelBg LUIE_SpellCastBuffs_ProminentBuffsPreviewAnchorLabelBg
LUIE_SpellCastBuffs_ProminentBuffsPreview = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentBuffsIconHolder : Control
LUIE_SpellCastBuffs_ProminentBuffsIconHolder = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentDebuffsPreview : TextureControl
---@field anchorLabel LUIE_SpellCastBuffs_ProminentDebuffsPreviewAnchorLabel
---@field anchorTexture LUIE_SpellCastBuffs_ProminentDebuffsPreviewAnchorTexture
---@field anchorLabelBg LUIE_SpellCastBuffs_ProminentDebuffsPreviewAnchorLabelBg
LUIE_SpellCastBuffs_ProminentDebuffsPreview = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentDebuffsIconHolder : Control
LUIE_SpellCastBuffs_ProminentDebuffsIconHolder = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerLongPreview : TextureControl
---@field anchorLabel LUIE_SpellCastBuffs_PlayerLongPreviewAnchorLabel
---@field anchorTexture LUIE_SpellCastBuffs_PlayerLongPreviewAnchorTexture
---@field anchorLabelBg LUIE_SpellCastBuffs_PlayerLongPreviewAnchorLabelBg
LUIE_SpellCastBuffs_PlayerLongPreview = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerLongIconHolder : Control
LUIE_SpellCastBuffs_PlayerLongIconHolder = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconBackdrop : BackdropControl
LUIE_SpellCastBuffIconBackdrop = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconBack : TextureControl
LUIE_SpellCastBuffIconBack = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconFrame : TextureControl
LUIE_SpellCastBuffIconFrame = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconIconBG : TextureControl
LUIE_SpellCastBuffIconIconBG = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconCooldown : CooldownControl
LUIE_SpellCastBuffIconCooldown = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconDrop : TextureControl
LUIE_SpellCastBuffIconDrop = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconLabel : LabelControl
LUIE_SpellCastBuffIconLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconAbilityId : LabelControl
LUIE_SpellCastBuffIconAbilityId = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconStack : LabelControl
LUIE_SpellCastBuffIconStack = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconName : LabelControl
LUIE_SpellCastBuffIconName = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconBarBackdrop : BackdropControl
LUIE_SpellCastBuffIconBarBackdrop = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconBar : StatusBarControl
LUIE_SpellCastBuffIconBar = ...
---------- LVL: 05 ----------
---------- LVL: 06 ----------
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerBuffsPreviewPreviewLabel : LabelControl
LUIE_SpellCastBuffs_PlayerBuffsPreviewPreviewLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerBuffsPreviewAnchorTexture : TextureControl
LUIE_SpellCastBuffs_PlayerBuffsPreviewAnchorTexture = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerBuffsPreviewAnchorLabel : LabelControl
LUIE_SpellCastBuffs_PlayerBuffsPreviewAnchorLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerBuffsPreviewAnchorLabelBg : BackdropControl
LUIE_SpellCastBuffs_PlayerBuffsPreviewAnchorLabelBg = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerDebuffsPreviewPreviewLabel : LabelControl
LUIE_SpellCastBuffs_PlayerDebuffsPreviewPreviewLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerDebuffsPreviewAnchorTexture : TextureControl
LUIE_SpellCastBuffs_PlayerDebuffsPreviewAnchorTexture = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerDebuffsPreviewAnchorLabel : LabelControl
LUIE_SpellCastBuffs_PlayerDebuffsPreviewAnchorLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerDebuffsPreviewAnchorLabelBg : BackdropControl
LUIE_SpellCastBuffs_PlayerDebuffsPreviewAnchorLabelBg = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetBuffsPreviewPreviewLabel : LabelControl
LUIE_SpellCastBuffs_TargetBuffsPreviewPreviewLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetBuffsPreviewAnchorTexture : TextureControl
LUIE_SpellCastBuffs_TargetBuffsPreviewAnchorTexture = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetBuffsPreviewAnchorLabel : LabelControl
LUIE_SpellCastBuffs_TargetBuffsPreviewAnchorLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetBuffsPreviewAnchorLabelBg : BackdropControl
LUIE_SpellCastBuffs_TargetBuffsPreviewAnchorLabelBg = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetDebuffsPreviewPreviewLabel : LabelControl
LUIE_SpellCastBuffs_TargetDebuffsPreviewPreviewLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetDebuffsPreviewAnchorTexture : TextureControl
LUIE_SpellCastBuffs_TargetDebuffsPreviewAnchorTexture = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetDebuffsPreviewAnchorLabel : LabelControl
LUIE_SpellCastBuffs_TargetDebuffsPreviewAnchorLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_TargetDebuffsPreviewAnchorLabelBg : BackdropControl
LUIE_SpellCastBuffs_TargetDebuffsPreviewAnchorLabelBg = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentBuffsPreviewPreviewLabel : LabelControl
LUIE_SpellCastBuffs_ProminentBuffsPreviewPreviewLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentBuffsPreviewAnchorTexture : TextureControl
LUIE_SpellCastBuffs_ProminentBuffsPreviewAnchorTexture = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentBuffsPreviewAnchorLabel : LabelControl
LUIE_SpellCastBuffs_ProminentBuffsPreviewAnchorLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentBuffsPreviewAnchorLabelBg : BackdropControl
LUIE_SpellCastBuffs_ProminentBuffsPreviewAnchorLabelBg = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentDebuffsPreviewPreviewLabel : LabelControl
LUIE_SpellCastBuffs_ProminentDebuffsPreviewPreviewLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentDebuffsPreviewAnchorTexture : TextureControl
LUIE_SpellCastBuffs_ProminentDebuffsPreviewAnchorTexture = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentDebuffsPreviewAnchorLabel : LabelControl
LUIE_SpellCastBuffs_ProminentDebuffsPreviewAnchorLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_ProminentDebuffsPreviewAnchorLabelBg : BackdropControl
LUIE_SpellCastBuffs_ProminentDebuffsPreviewAnchorLabelBg = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerLongPreviewPreviewLabel : LabelControl
LUIE_SpellCastBuffs_PlayerLongPreviewPreviewLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerLongPreviewAnchorTexture : TextureControl
LUIE_SpellCastBuffs_PlayerLongPreviewAnchorTexture = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerLongPreviewAnchorLabel : LabelControl
LUIE_SpellCastBuffs_PlayerLongPreviewAnchorLabel = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffs_PlayerLongPreviewAnchorLabelBg : BackdropControl
LUIE_SpellCastBuffs_PlayerLongPreviewAnchorLabelBg = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconIconBGIconBGBackdrop : BackdropControl
LUIE_SpellCastBuffIconIconBGIconBGBackdrop = ...
-- ---------------------------------------------------------------------------------------------------------------------
--
---@class LUIE_SpellCastBuffIconIconBGIcon : TextureControl
LUIE_SpellCastBuffIconIconBGIcon = ...
---------- LVL: 07 ----------

-- ---------------------------------------------------------------------------------------------------------------------
-- Custom type definitions for dynamically assigned fields
-- ---------------------------------------------------------------------------------------------------------------------

---@class CustomFrame
---@field buffs Control
---@field debuffs Control

-- ////// END   : GENERATED FROM C:/Users/dack_janiels/source/repos/LUIE/LuiExtended/LuiExtended/frontend\SpellCastBuffs.xml
