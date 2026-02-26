-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

-- Food Buff Ability IDs
Effects.IsFoodBuff =
{
    [17407]  = true, -- Increase Max Health
    [17577]  = true, -- Increase Max Magicka & Stamina
    [17581]  = true, -- Increase All Primary Stats
    [17608]  = true, -- Magicka & Stamina Recovery
    [17614]  = true, -- All Primary Stat Recovery
    [61218]  = true, -- Increase All Primary Stats
    [61255]  = true, -- Increase Max Health & Stamina
    [61257]  = true, -- Increase Max Health & Magicka
    [61259]  = true, -- Increase Max Health
    [61260]  = true, -- Increase Max Magicka
    [61261]  = true, -- Increase Max Stamina
    [61294]  = true, -- Increase Max Magicka & Stamina
    [66128]  = true, -- Increase Max Magicka
    [66130]  = true, -- Increase Max Stamina
    [66551]  = true, -- Garlic and Pepper Venison Steak
    [66568]  = true, -- Increase Max Magicka
    [66576]  = true, -- Increase Max Stamina
    [68411]  = true, -- Crown store
    [72819]  = true, -- Tripe Trifle Pocket
    [72822]  = true, -- Blood Price Pie
    [72824]  = true, -- Smoked Bear Haunch
    [72956]  = true, -- Max Health and Stamina (Cyrodilic Field Tack)
    [72959]  = true, -- Max Health and Magicka (Cyrodilic Field Treat)
    [72961]  = true, -- Max Stamina and Magicka (Cyrodilic Field Bar)
    [84678]  = true, -- Increase Max Magicka
    [84681]  = true, -- Pumpkin Snack Skewer
    [84709]  = true, -- Crunchy Spider Skewer
    [84725]  = true, -- The Brains!
    [84736]  = true, -- Increase Max Health
    [85484]  = true, -- Increase All Primary Stats
    [86749]  = true, -- Mud Ball
    [86787]  = true, -- Rajhin's Sugar Claws
    [86789]  = true, -- Alcaire Festival Sword-Pie
    [89955]  = true, -- Candied Jester's Coins
    [89971]  = true, -- Jewels of Misrule
    [92435]  = true, -- Increase Health & Magicka
    [92437]  = true, -- Increase Health (but descriptions says max magicka)
    [92474]  = true, -- Increase Health & Stamina
    [92477]  = true, -- Increase Health (but descriptions says max magicka)
    [100498] = true, -- Clockwork Citrus Filet
    [100502] = true, -- Deregulated Mushroom Stew
    [107748] = true, -- Lure Allure
    [107789] = true, -- Artaeum Takeaway Broth
    [127537] = true, -- Increase Health (but descriptions says max magicka)
    [127578] = true, -- Increase Health (but descriptions says max magicka)
    [127596] = true, -- Bewitched Sugar Skulls
    [127619] = true, -- Increase Health (but descriptions says max magicka)
    [127736] = true, -- Increase Health (but descriptions says max magicka)
}
