-- Scale up in-game setting max values (defaults: 50 * 10 = 500 where applicable)

local function setCombatSettingMaxValue(settingPanel, settingTypeKey, settingKey, defaultValue, scaleFactor)
    ZO_SharedOptions_SettingsData[settingPanel][settingTypeKey][settingKey].maxValue = defaultValue * scaleFactor
end

local function setNameplateGlowMaxValue(settingPanel, settingTypeKey, settingKey, defaultValue, scaleFactor)
    local settingEntry = ZO_SharedOptions_SettingsData[settingPanel][settingTypeKey][settingKey]
    settingEntry.showValueMax = defaultValue * scaleFactor
    settingEntry.maxValue = scaleFactor
end

-- Combat: monster tell brightness (AOE)
local monsterTellBrightnessDefault = 50
local monsterTellBrightnessScaleFactor = 10
local monsterTellBrightnessSettingKeys =
{
    COMBAT_SETTING_MONSTER_TELLS_FRIENDLY_BRIGHTNESS,
    COMBAT_SETTING_MONSTER_TELLS_ENEMY_BRIGHTNESS,
}
for _, settingKey in ipairs(monsterTellBrightnessSettingKeys) do
    setCombatSettingMaxValue(
        SETTING_PANEL_GAMEPLAY,
        SETTING_TYPE_COMBAT,
        settingKey,
        monsterTellBrightnessDefault,
        monsterTellBrightnessScaleFactor
    )
end

-- Nameplates: glow thickness / intensity
local nameplateGlowDefault = 50
local nameplateGlowScaleFactor = 10
local nameplateGlowSettingKeys =
{
    IN_WORLD_UI_SETTING_GLOW_THICKNESS,
    IN_WORLD_UI_SETTING_TARGET_GLOW_INTENSITY,
    IN_WORLD_UI_SETTING_INTERACTABLE_GLOW_INTENSITY,
}
local nameplateSettingPanel = SETTING_PANEL_NAMEPLATES
local nameplateSettingType = SETTING_TYPE_IN_WORLD
for _, settingKey in ipairs(nameplateGlowSettingKeys) do
    setNameplateGlowMaxValue(
        nameplateSettingPanel,
        nameplateSettingType,
        settingKey,
        nameplateGlowDefault,
        nameplateGlowScaleFactor
    )
end
