-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
--- @type LUIE.CustomFramesShared
local Shared = LUIE.CustomFramesShared
local CreateLUIETopLevel = Shared.CreateLUIETopLevel
local ApplyStackedMemberAnchors = Shared.ApplyStackedMemberAnchors
local CreateMemberRangeFromVirtual = Shared.CreateMemberRangeFromVirtual
local CreateCombatGlowBorder = Shared.CreateCombatGlowBorder
function LUIE.CustomFramesBuildPlayer()
    if UnitFrames.SV.CustomFramesPlayer then
        local playerTlw = CreateLUIETopLevel("LUIE_CustomPlayerFrame", "LUIE_UF_PlayerFrame_Template")
        playerTlw.customPositionAttr = "CustomFramesPlayerFramePos"
        playerTlw.preview = playerTlw:GetNamedChild("_Preview")
        local player = playerTlw:GetNamedChild("_Player")
        local topInfo = player:GetNamedChild("_TopInfo")
        local botInfo = player:GetNamedChild("_BotInfo")
        local buffAnchor = player:GetNamedChild("_BuffAnchor")
        local phb = player:GetNamedChild("_Health")
        local pmb = player:GetNamedChild("_Magicka")
        local psb = player:GetNamedChild("_Stamina")
        local alt = botInfo:GetNamedChild("_Alternative")
        local pli = topInfo:GetNamedChild("_LevelIcon")

        UnitFrames.CustomFrames["player"] =
        {
            ["unitTag"] = "player",
            ["tlw"] = playerTlw,
            ["control"] = player,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = phb,
                ["labelOne"] = phb:GetNamedChild("_LabelOne"),
                ["labelTwo"] = phb:GetNamedChild("_LabelTwo"),
                ["trauma"] = phb:GetNamedChild("_Trauma"),
                ["bar"] = phb:GetNamedChild("_Bar"),
                ["shield"] = phb:GetNamedChild("_Shield"),
                ["noHealingOverlay"] = phb:GetNamedChild("_NoHealingOverlay"),
                ["noHealingStripe"] = phb:GetNamedChild("_NoHealingStripe"),
                ["possessionOverlay"] = phb:GetNamedChild("_PossessionOverlay"),
                ["threshold"] = UnitFrames.healthThreshold,
            },
            [COMBAT_MECHANIC_FLAGS_MAGICKA] =
            {
                ["backdrop"] = pmb,
                ["labelOne"] = pmb:GetNamedChild("_LabelOne"),
                ["labelTwo"] = pmb:GetNamedChild("_LabelTwo"),
                ["bar"] = pmb:GetNamedChild("_Bar"),
                ["threshold"] = UnitFrames.magickaThreshold,
            },
            [COMBAT_MECHANIC_FLAGS_STAMINA] =
            {
                ["backdrop"] = psb,
                ["labelOne"] = psb:GetNamedChild("_LabelOne"),
                ["labelTwo"] = psb:GetNamedChild("_LabelTwo"),
                ["bar"] = psb:GetNamedChild("_Bar"),
                ["threshold"] = UnitFrames.staminaThreshold,
            },
            ["alternative"] =
            {
                ["backdrop"] = alt,
                ["enlightenment"] = alt:GetNamedChild("_Enlightenment"),
                ["bar"] = alt:GetNamedChild("_Bar"),
                ["icon"] = alt:GetNamedChild("_Icon"),
            },
            ["topInfo"] = topInfo,
            ["name"] = topInfo:GetNamedChild("_Name"),
            ["levelIcon"] = pli,
            ["veterancyRankIcon"] = topInfo:GetNamedChild("_VeterancyRankIcon"),
            ["overlandDifficultyIcon"] = topInfo:GetNamedChild("_OverlandDifficultyIcon"),
            ["level"] = topInfo:GetNamedChild("_Level"),
            ["classIcon"] = topInfo:GetNamedChild("_ClassIcon"),
            ["botInfo"] = botInfo,
            ["buffAnchor"] = buffAnchor,
            ["buffs"] = playerTlw:GetNamedChild("_Buffs"),
            ["debuffs"] = playerTlw:GetNamedChild("_Debuffs"),
        }

        UnitFrames.CustomFrames["player"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

        -- Hide labels based on settings
        local labelSettings =
        {
            { flag = UnitFrames.SV.HideLabelHealth,  mechanic = COMBAT_MECHANIC_FLAGS_HEALTH  },
            { flag = UnitFrames.SV.HideLabelStamina, mechanic = COMBAT_MECHANIC_FLAGS_STAMINA },
            { flag = UnitFrames.SV.HideLabelMagicka, mechanic = COMBAT_MECHANIC_FLAGS_MAGICKA },
        }

        local settingKey = nil
        local setting
        while true do
            settingKey, setting = next(labelSettings, settingKey)
            if settingKey == nil then break end
            if setting.flag then
                UnitFrames.CustomFrames["player"][setting.mechanic].labelOne:SetHidden(true)
                UnitFrames.CustomFrames["player"][setting.mechanic].labelTwo:SetHidden(true)
            end
        end

        UnitFrames.CustomFrames["controlledsiege"] =
        {
            ["unitTag"] = "controlledsiege",
        }
        UnitFrames.CustomFramesManager:CreateFrame("player", UnitFrames.CustomFrames["player"], "player", LUIE_CustomFrameVisualizers.SetupPlayerFrame)
        UnitFrames.CustomFramesManager:CreateFrame("controlledsiege", UnitFrames.CustomFrames["controlledsiege"], "controlledsiege", LUIE_CustomFrameVisualizers.SetupControlledSiegeFrame)
    end
end

function LUIE_PlayerCustomFrameData:BuildStaticData()
    LUIE.CustomFramesBuildPlayer()
end
