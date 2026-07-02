-- -----------------------------------------------------------------------------
--  LuiExtended — SpellCastBuffs buff icon pools (ZO_ControlPool + ZO_MetaPool)
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

--- Shared source pool (ZO_BuffDebuff pattern: one control pool, meta pool per container).
--- @type ZO_ControlPool|nil
SpellCastBuffs.buffIconControlPool = nil

--- @type table<string, ZO_MetaPool>
SpellCastBuffs.buffIconMetaPools = {}

--- Full icon rebuild (sort, pool acquire/release) when true; light tick updates timers only.
SpellCastBuffs.displayDirty = true

--- Bumped when layout-affecting settings change (IconSize, flex, anchors).
SpellCastBuffs.displayLayoutVersion = 0

--- Session high water for dev pool metrics (GetTotalObjectCount on source pool).
SpellCastBuffs.buffIconPoolHighWater = 0

--- Hidden textures kept alive so inset DDS stays resident (avoids async pop-in on rebind).
local buffIconInsetPreloadControls = nil

function SpellCastBuffs.MarkDisplayDirty()
    SpellCastBuffs.displayDirty = true
end

function SpellCastBuffs.MarkDisplayLayoutDirty()
    SpellCastBuffs.displayLayoutVersion = SpellCastBuffs.displayLayoutVersion + 1
    SpellCastBuffs.MarkDisplayDirty()
end

function SpellCastBuffs.RecordBuffIconPoolHighWater()
    local controlPool = SpellCastBuffs.buffIconControlPool
    if not controlPool then
        return
    end
    local total = controlPool:GetTotalObjectCount()
    if total > SpellCastBuffs.buffIconPoolHighWater then
        SpellCastBuffs.buffIconPoolHighWater = total
    end
end

--- Placeholder while pooled; paired with RELEASE_TEXTURE_AT_ZERO_REFERENCES so ability art refs can drop on release.
local BUFF_ICON_MISSING_TEXTURE = "EsoUI/Art/Icons/icon_missing.dds"

local function ApplyBuffIconTextureReleasePolicy(textureControl)
    if textureControl and textureControl.SetTextureReleaseOption then
        textureControl:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
    end
end

local function PreloadBuffIconInsetTextures()
    if buffIconInsetPreloadControls then
        return
    end
    buffIconInsetPreloadControls = {}
    local paths =
    {
        "EsoUI/Art/ActionBar/abilityInset.dds",
        "EsoUI/Art/Miscellaneous/Gamepad/gp_edgeFill.dds",
    }
    for i, path in ipairs(paths) do
        local tex = WINDOW_MANAGER:CreateControl("LUIE_SCB_InsetPreload" .. i, GuiRoot, CT_TEXTURE)
        tex:SetHidden(true)
        tex:SetDimensions(4, 4)
        tex:SetTexture(path)
        buffIconInsetPreloadControls[i] = tex
    end
end

local function ResetBuffIconDynamicTextures(buff)
    if buff.icon then
        buff.icon:SetTexture(BUFF_ICON_MISSING_TEXTURE)
    end
    if buff.back then
        buff.back:SetTexture(BUFF_ICON_MISSING_TEXTURE)
    end
    if buff.frame then
        buff.frame:SetTexture(BUFF_ICON_MISSING_TEXTURE)
    end
end

local function ResetBuffIconControl(buff)
    buff:SetHidden(true)
    buff:SetExcludeFromFlexbox(true)
    buff:ClearAnchors()
    buff:SetAlpha(1)
    SpellCastBuffs.ResetBuffIconChromeAlphas(buff)
    buff:SetParent(GuiRoot)
    if buff.cd then
        buff.cd:ResetCooldown()
        buff.cd:SetHidden(true)
    end
    buff.label:SetText("")
    buff.stack:SetHidden(true)
    if buff.abilityId then
        buff.abilityId:SetText("")
        buff.abilityId:SetScale(1)
        buff.abilityId:SetHidden(true)
    end
    if buff.name then
        buff.name:SetText("")
    end
    if buff.bar then
        buff.bar.bar:SetValue(0)
    end
    buff.lastAbilityIdText = nil
    buff.lastAbilityIdLayoutIconSize = nil
    buff.lastAbilityIdLayoutOutset = nil
    buff.lastAbilityIdLayoutShown = nil
    buff.lastLabelText = nil
    buff.lastStackText = nil
    buff.lastFlexContainer = nil
    buff.lastAppliedIconSize = nil
    buff.lastLayoutVersion = nil
    buff.lastChromeLayoutVersion = nil
    buff.abilityIdLabelDirty = true
    if buff.iconbg then
        buff.iconbg:SetHidden(true)
    end
    ResetBuffIconDynamicTextures(buff)
end

local function SetupBuffIconControlReferences(buff)
    buff.back = buff:GetNamedChild("_Back")
    buff.frame = buff:GetNamedChild("_Frame")
    buff.iconbg = buff:GetNamedChild("_IconBg")
    buff.drop = buff:GetNamedChild("_Drop")
    buff.drop:SetTexture(LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_BACKGROUND_DDS)
    buff.icon = buff:GetNamedChild("_Icon")
    buff.label = buff:GetNamedChild("_Label")
    buff.abilityId = buff:GetNamedChild("_AbilityId")
    buff.stack = buff:GetNamedChild("_Stack")
    buff.cd = buff:GetNamedChild("_Cooldown")
    buff.name = buff:GetNamedChild("_Name")

    local barBackdrop = buff:GetNamedChild("_BarBackdrop")
    local bar = buff:GetNamedChild("_Bar")
    buff.bar =
    {
        backdrop = barBackdrop,
        bar = bar,
    }

    buff.frame:SetPixelRoundingEnabled(true)

    if buff.cd then
        buff.cd:SetLeadingEdgeTexture("")
    end
    SpellCastBuffs.ApplyBuffIconDrawOrder(buff)

    ApplyBuffIconTextureReleasePolicy(buff.icon)
    ApplyBuffIconTextureReleasePolicy(buff.back)
    ApplyBuffIconTextureReleasePolicy(buff.frame)

    buff.iconbg:SetTexture(SpellCastBuffs.GetGenericIconInsetTexture())

    SpellCastBuffs.ApplyAbilityFrameTextureCoords(buff.back, SpellCastBuffs.SV.IconSize)

    buff.label:SetFont(SpellCastBuffs.buffsFont or LUIE.Font.GetDefaultFont())
    buff.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    buff.label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    buff.abilityId:SetFont(SpellCastBuffs.buffsFont or LUIE.Font.GetDefaultFont())
    buff.abilityId:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    buff.stack:SetFont(SpellCastBuffs.buffsFont or LUIE.Font.GetDefaultFont())
    buff.stack:SetAnchor(CENTER, buff, BOTTOMLEFT, 0, 0)
    buff.stack:SetAnchor(CENTER, buff, TOPRIGHT, -SpellCastBuffs.padding * 3, SpellCastBuffs.padding * 3)
    buff.name:SetFont(SpellCastBuffs.prominentFont or LUIE.Font.GetDefaultFont())

    buff.bar.backdrop:SetEdgeTexture("", 8, 2, 2, 2)
    buff.bar.backdrop:SetDrawLayer(DL_BACKGROUND)
    buff.bar.backdrop:SetDrawLevel(DL_CONTROLS)
    buff.bar.bar:SetMinMax(0, 1)
end

function SpellCastBuffs.InitializeBuffIconPools()
    if SpellCastBuffs.buffIconControlPool then
        return
    end

    local controlPool = ZO_ControlPool:New("LUIE_SpellCastBuffIcon", nil, "LUIE_SpellCastBuff")

    controlPool:SetCustomFactoryBehavior(function (buff)
        SetupBuffIconControlReferences(buff)
    end)

    SpellCastBuffs.buffIconControlPool = controlPool
    SpellCastBuffs.buffIconMetaPools = {}
    PreloadBuffIconInsetTextures()
end

--- @param containerKey string
--- @return ZO_MetaPool
function SpellCastBuffs.GetBuffIconMetaPool(containerKey)
    SpellCastBuffs.InitializeBuffIconPools()

    local metaPool = SpellCastBuffs.buffIconMetaPools[containerKey]
    if metaPool then
        return metaPool
    end

    metaPool = ZO_MetaPool:New(SpellCastBuffs.buffIconControlPool)
    metaPool.containerKey = containerKey

    metaPool:SetCustomAcquireBehavior(function (buff)
        local buffContainer = SpellCastBuffs.BuffContainers[containerKey]
        local iconHolder = buffContainer and buffContainer.iconHolder
        if iconHolder then
            buff:SetParent(iconHolder)
        end
        buff:ClearAnchors()
        buff:SetFlexGrow(0)
        buff:SetFlexShrink(0)
        SpellCastBuffs.ApplyBuffIconSlotDimensions(buff, SpellCastBuffs.SV.IconSize)
        SpellCastBuffs.ApplyBuffIconAbilityIdLayout(buff)
        local borderTexture = SpellCastBuffs.IsDebuffAuraContainer(containerKey) and SpellCastBuffs.GetDebuffBorderTexture() or SpellCastBuffs.GetBuffBorderTexture()
        buff.back:SetTexture(borderTexture)
        SpellCastBuffs.ApplyAbilityFrameTextureCoords(buff.back, SpellCastBuffs.SV.IconSize)
    end)

    metaPool:SetCustomResetBehavior(ResetBuffIconControl)

    SpellCastBuffs.buffIconMetaPools[containerKey] = metaPool
    return metaPool
end

--- Release active icons with index greater than `activeCount` (return to source pool).
--- @param containerKey string
--- @param activeCount number
function SpellCastBuffs.ReleaseSurplusBuffIcons(containerKey, activeCount)
    local buffContainer = SpellCastBuffs.BuffContainers[containerKey]
    if not buffContainer or not buffContainer.icons then
        return
    end

    local metaPool = SpellCastBuffs.buffIconMetaPools[containerKey]
    if not metaPool then
        return
    end

    for i = #buffContainer.icons, activeCount + 1, -1 do
        local icon = buffContainer.icons[i]
        if icon and icon.poolKey then
            metaPool:ReleaseObject(icon.poolKey)
        end
        buffContainer.icons[i] = nil
    end
end
