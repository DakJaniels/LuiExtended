-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

-- Drink Buff Ability IDs
Effects.IsDrinkBuff =
{
    [61322]  = true, -- Health Recovery
    [61325]  = true, -- Magicka Recovery
    [61328]  = true, -- Health & Magicka Recovery
    [61335]  = true, -- Health & Magicka Recovery
    [61340]  = true, -- Health & Stamina Recovery
    [61345]  = true, -- Magicka & Stamina Recovery
    [61350]  = true, -- All Primary Stat Recovery
    [66125]  = true, -- Increase Max Health
    [66132]  = true, -- Health Recovery (Alcoholic Drinks)
    [66137]  = true, -- Magicka Recovery (Tea)
    [66141]  = true, -- Stamina Recovery (Tonics)
    [66586]  = true, -- Health Recovery
    [66590]  = true, -- Magicka Recovery
    [66594]  = true, -- Stamina Recovery
    [68416]  = true, -- All Primary Stat Recovery (Crown Refreshing Drink)
    [72816]  = true, -- Red Frothgar
    [72965]  = true, -- Health and Stamina Recovery (Cyrodilic Field Brew)
    [72968]  = true, -- Health and Magicka Recovery (Cyrodilic Field Tea)
    [72971]  = true, -- Magicka and Stamina Recovery (Cyrodilic Field Tonic)
    [84700]  = true, -- 2h Witches event: Eyeballs
    [84704]  = true, -- 2h Witches event: Witchmother's Party Punch
    [84720]  = true, -- 2h Witches event: Eye Scream
    [84731]  = true, -- 2h Witches event: Witchmother's Potent Brew
    [84732]  = true, -- Increase Health Regen
    [84733]  = true, -- Increase Health Regen
    [84735]  = true, -- 2h Witches event: Double Bloody Mara
    [85497]  = true, -- All Primary Stat Recovery
    [86559]  = true, -- Hissmir Fish Eye Rye
    [86560]  = true, -- Stamina Recovery
    [86673]  = true, -- Lava Foot Soup & Saltrice
    [86674]  = true, -- Stamina Recovery
    [86677]  = true, -- Warning Fire (Bergama Warning Fire)
    [86678]  = true, -- Health Recovery
    [86746]  = true, -- Betnikh Spiked Ale (Betnikh Twice-Spiked Ale)
    [86747]  = true, -- Health Recovery
    [86791]  = true, -- Increase Stamina Recovery (Ice Bear Glow-Wine)
    [89957]  = true, -- Dubious Camoran Throne
    [92433]  = true, -- Health & Magicka Recovery
    [92476]  = true, -- Health & Stamina Recovery
    [100488] = true, -- Spring-Loaded Infusion
    [127531] = true, -- Disastrously Bloody Mara
    [127572] = true, -- Pack Leader's Bone Broth
    [148633] = true, -- Sparkling Mudcrab Apple Cider
}
