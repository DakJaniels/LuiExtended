-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data
local CrowdControl = Data.CrowdControl
-- CrowdControl.aoePlayerUltimate
-- CrowdControl.aoePlayerNormal
-- CrowdControl.aoePlayerSet
-- CrowdControl.aoeTrap
-- cc.aoeBoss
-- CrowdControl.aoeElite
-- CrowdControl.aoeNormal
-- Increment by 1 here if we want to change priority. Best way to do this is +1 for a new ability, and shared morphs or other damage sources from a shared attack don't increment.
-- Priority system doesn't support gaps so NEVER more than +1 here, also the FIRST ability in each tier needs to be +0 to prevent skips if a category is disabled in the options.
--- @class (partial) aoeNPCNormal
local aoeNPCNormal =
{

    [4769] = 1, -- Choking Pollen (Lurcher),
    [4772] = 1, -- Fiery Breath (Daedroth),
    [5265] = 1, -- Burning Ground (Shalk),
    [6162] = 1, -- Rain of Fire (Scamp),
    [7883] = 1, -- Guardian Storm (Cyrodiil Mage),
    [8088] = 1, -- Poison Spray (Giant Spider),
    [8604] = 1, -- Vigorous Swipe (Mammoth),
    [8628] = 1, -- Charged Ground (Harpy),
    [9749] = 1, -- Envelop (Banekin),
    [10813] = 1, -- Ignite (Synergy - Fire Mage),
    [10947] = 1, -- Fiery Breath (Shalk),
    [13680] = 1, -- Acid Blood (Assassin Beetle),
    [14068] = 1, -- Ignite (Synergy - Archer),
    [16040] = 1, -- Hurricane (Nereid),
    [16698] = 1, -- Poisonbloom (Netch),
    [19997] = 1, -- Static Field (Dwemer Spider - Synergy),
    [20812] = 1, -- Defiled Ground (Lich),
    [27100] = 1, -- Shocking Rake (Dreugh),
    [28629] = 1, -- Volley (Archer),
    [37131] = 0, -- Ice Cage (Battlemage),
    [38125] = 1, -- Caltrops  (Faction NPCs),
    [38260] = 0, -- Ignite (Synergy - Fire Mage),
    [46819] = 1, -- Storm Damage (Cyrodiil Mage),
    [47102] = 1, -- Fire Rune (Fire Mage),
    [51282] = 1, -- Flame Tornado (Air Atronach - Flame),
    [51645] = 1, -- Frozen Ground (Frost Atronach),
    [61374] = 1, -- Infectious Swarm (Necrotic Hoarvor),
    [62502] = 1, -- Fiery Wind (Justice Mage),
    [69950] = 1, -- Desecrated Ground (Undead Synergy),
    [70414] = 0, -- Ignite (Synergy - Cyrodiil Archer),
    [72996] = 1, -- Symphony of Blades (Defiled Aegis),
    [73437] = 1, -- Soul Flame (Daedric Titan),
    [73929] = 0, -- Soul Cage (Lich),
    [73937] = 1, -- Soul Cage (Lich),
    [76624] = 1, -- Pool of Shadow (Voidbringer),
    [76728] = 0, -- Pool of Shadow (Voidbringer),
    [84837] = 1, -- Broken Pact (Skaafin Witchling),
    [85391] = 1, -- Slash (Cliff Strider),
    [85421] = 1, -- Retch (Cliff Strider),
    [87126] = 1, -- Heat Vents (Fetcherfly Nest),
    [87902] = 1, -- Bombard (Arbalest),
    [88323] = 1, -- Blast Furnace (Iron Atronach),
    [88330] = 0, -- Pool of Shadow (Skaafin Masquer),
    [88334] = 0, -- Pool of Shadow (Skaafin Masquer),
    [88335] = 0, -- Pool of Shadow (Skaafin Masquer),
    [88336] = 0, -- Pool of Shadow (Skaafin Masquer),
    [90778] = 1, -- Acid Pool (Nix-Ox),
    [90815] = 0, -- Acid Pool (Nix-Ox),
    [91094] = 1, -- Split Bolt (Dwemer Arquebus),
    [91095] = 0, -- Split Bolt (Dwemer Arquebus),
    [91096] = 0, -- Split Bolt (Dwemer Arquebus),
    [91938] = 1, -- Burst of Embers (Daedroth),
    [103862] = 1, -- Deluge (Yaghra Spewer),
    [103992] = 1, -- Luminescent Burn (Yaghra Spewer),
    [121644] = 1, -- Defiled Ground (Euraxian Necromancer),
}

--- @class (partial) aoeNPCNormal
CrowdControl.aoeNPCNormal = aoeNPCNormal
