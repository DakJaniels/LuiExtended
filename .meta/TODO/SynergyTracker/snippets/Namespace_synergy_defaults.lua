-- Archived excerpt from LuiExtended/modules/CombatInfo/Namespace.lua

--- @class (partial) SynergyTracker
CombatInfo.SynergyTracker =
{
    name = LUIE.name .. "CombatInfo" .. "SynergyTracker",
}

-- Inside CombatInfo.Defaults:
    synergy =
    {
        enabled = false,
        unlocked = false,
        displayMode = "multi",
        minimalHorizontal = false,
        minimalHorizontalAlign = "left",
        maxDisplay = 10,
        showPriority = true,
        showKeybinds = true,
        playSound = true,
        showCooldowns = true,
        oocAlpha = 100,
        incAlpha = 100,
        offsetX = 0,
        offsetY = 200,
        detectedSynergies = {},
        priorityOverrides = {},
        blacklist = {},
    },
