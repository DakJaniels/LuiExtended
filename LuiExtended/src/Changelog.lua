-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
local zo_strformat = zo_strformat
local table_concat = table.concat
local GetDisplayName = GetDisplayName
-- -----------------------------------------------------------------------------
local changelogMessages =
{
    -- Version Header
    "|cFFA500LuiExtended Version 7.0.0.0|r",
    "",
    -- Fixes
    "|cFFFF00Fixes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Grim Focus and Bound Armorments count now go to the new 10/8 respectively.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Merged dannystewart PR # 338 to \"Fix trailing dash persisting after countdown timer expires in AbilityAlerts.\"",
    "",
    -- New Features
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Group buffs/debuffs found in the SpellcastBuff module, this is in beta and can be turned off.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added right click support for buffs so you can easily add/remove them to the prominent buff/debuff and group buff/debuff trackers. work in progress.",
    "",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t I'm sure I missed a note on some other things that changed. View the full change log on Git.",
    "",
}
-- -----------------------------------------------------------------------------
-- Hide toggle called by the menu or xml button
function LUIE.ToggleChangelog(option)
    LUIE_Changelog:ClearAnchors()
    LUIE_Changelog:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
    LUIE_Changelog:SetHidden(option)
end

-- -----------------------------------------------------------------------------
-- Called on initialize
function LUIE.ChangelogScreen()
    -- concat messages into one string
    local changelog = table_concat(changelogMessages, "\n")
    -- If text start with '*' replace it with bullet texture
    changelog = StringOnlyGSUB(changelog, "%[%*%]", "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t")
    -- Set the window title
    LUIE_Changelog_Title:SetText(zo_strformat("<<1>> Changelog", LUIE.name))
    -- Set the about string
    LUIE_Changelog_About:SetText(zo_strformat("v<<1>> by <<2>>", LUIE.version, LUIE.author))
    -- Set the changelog text
    LUIE_Changelog_Text:SetText(changelog)

    -- Display the changelog if version number < current version
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].WelcomeVersion ~= LUIE.version then
        LUIE_Changelog:SetHidden(false)
    end

    -- Set version to current version
    LUIESV["Default"][GetDisplayName()]["$AccountWide"].WelcomeVersion = LUIE.version
end

-- -----------------------------------------------------------------------------
