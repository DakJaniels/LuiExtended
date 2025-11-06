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
    "|cFFA500LuiExtended Version 7.1.0.5|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Significant CombatInfo performance optimization: eliminated redundant function calls and addon state checks that were causing frame freezes on high-buff-count scenarios (especially noticeable on Arcanist).",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Integration with LibFoodDrinkBuff: small group unit frames now display food/drink buff status icons and time remaining. Can be turned on and configured in the Unit Frames settings.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.4|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t No-healing overlay is now rendered above the shield overlay.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Shield animations are smooth again. oops.",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Ability timers can now be manually changed in the settings.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Synergy Panel, viewer for recent seen synergies.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t In-Combat unitframe border, added settings for Group and RaidGroup to have a red(by default) border around frames when in combat.",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Moved code around in the CombatInfo module. *Shouldn't break anything.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added two ZOS Method overwrites to bypass a *Private* function error when using custom icons; the error propagated when dragging a ability in the skills menu.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.3|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added small group sort by role, just like raid frames.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LibGroupBroadcast integrations, ULT icons, potion icon, dps, hps are only visible in small group frames for now, raid frames will need ui rework to fit everything in.\n Resource bars should be placed below the raid frame in a small gap if that setting is enabled.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Migrated font system to use ZOS's native ZO_CreateFontString function.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Implemented migration system with SV flags to automatically convert legacy font style values (runs once per module).",
    "",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Cleaned up obsolete font style string constants from localization files.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Consolidated settings menu font style dropdowns to use shared arrays for consistency.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.2|r",
    "",
    -- New Features
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Integration with LibGroupResources, LibGroupCombatStats, LibGroupPotionCooldowns.\nTweaks will be made, need people to test and let me know.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.1|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t \nUnitframes should now show visuals correctly; somehow in testing I didn't catch a 0-index issue, sorry all.\nLet me know in the ESOUI comments/Github if any issues remain.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.0|r",
    "",
    -- New Features
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Implemented ZOS-style coordinator architecture for Unit Attribute Visualizers.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Completely refactored UnitFrames module for improved code quality and maintainability.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Enhanced no-healing indicator with distinctive diagonal stripe pattern for better visibility.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Reduced power shield update animation duration from 250ms to 100ms for more responsive feedback.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Improved attribute visualizer module architecture with proper event handling and unit-tag filtering.",
    "",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Significant code cleanup and elimination of duplication throughout the codebase.",
    "",
    "|cFFA500LuiExtended Version 7.0.2.0|r",
    "",
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added support for 16:10 displays and Steam Deck.",
    "",
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Updated aspect ratio detection and scaling for unit frames.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.0.1.0|r",
    "",
    -- New Features
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added option to use @account names instead of character names in teammate death notifications (Combat Text → Group Member Death → Use Account Names).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added transparency control for Info Panel (Info Panel → Info Panel Transparency, %).",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Refactored font system to use 'LUIE Default Font' instead of 'Univers 67' across all modules for better consistency.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added initial console support and improved settings compatibility.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Various settings improvements and optimizations.",
    "",
    -- Removals
    "|cFFFF00Removed:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Group Buffs functionality. Users should now use the dedicated 'Group Buff Panels addon by code65536' instead.",
    "",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Updated terms and license information.",
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
