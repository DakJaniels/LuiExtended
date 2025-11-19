-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data

local GetCollectibleName = GetCollectibleName

--- @class (partial) CrownStoreCollectibles
local crownStoreCollectibles =
{
    [GetCollectibleName(3)] = 3,       -- Brown Paint Horse
    [GetCollectibleName(4)] = 4,       -- Bay Dun Horse
    [GetCollectibleName(5)] = 5,       -- Midnight Steed
    [GetCollectibleName(265)] = 265,   -- Pride-King Lion
    [GetCollectibleName(235)] = 235,   -- Black Camel of Ill Omen
    [GetCollectibleName(233)] = 233,   -- Hammerfell Camel
    [GetCollectibleName(4723)] = 4723, -- Tattooed Shorn Camel
    [GetCollectibleName(21)] = 21,     -- Tessellated Guar
    [GetCollectibleName(5066)] = 5066, -- Auroran Warhorse
    [GetCollectibleName(59)] = 59,     -- Nightmare Courser
    [GetCollectibleName(4722)] = 4722, -- Snow-Blanket Sorrel Horse
    [GetCollectibleName(290)] = 290,   -- Highland Wolf
    [GetCollectibleName(5075)] = 5075, -- Painted Wolf

    -- [GetCollectibleName(4673)] = 4673, -- Storage Coffer, Fortified (from level up rewards)
    [GetCollectibleName(4674)] = 4674, -- Storage Chest, Fortified (Tel Var / Writ Vouchers)
    [GetCollectibleName(4675)] = 4675, -- Storage Coffer, Oaken (Tel Var / Writ Vouchers)
    [GetCollectibleName(4676)] = 4676, -- Storage Coffer, Secure (Tel Var / Writ Vouchers)
    [GetCollectibleName(4677)] = 4677, -- Storage Coffer, Sturdy (Tel Var / Writ Vouchers)
    [GetCollectibleName(4678)] = 4678, -- Storage Chest, Oaken (Tel Var / Writ Vouchers)
    [GetCollectibleName(4679)] = 4679, -- Storage Chest, Secure (Tel Var / Writ Vouchers)
    [GetCollectibleName(4680)] = 4680, -- Storage Chest, Sturdy (Tel Var / Writ Vouchers)

    [GetCollectibleName(6706)] = 6706, -- Emerald Indrik Feather
    [GetCollectibleName(6707)] = 6707, -- Gilded Indrik Feather
    [GetCollectibleName(6708)] = 6708, -- Onyx Indrik Feather
    [GetCollectibleName(6709)] = 6709, -- Opaline Indrik Feather

    [GetCollectibleName(6659)] = 6659, -- Dawnwood Berries of Bloom
    [GetCollectibleName(6660)] = 6660, -- Dawnwood Berries of Budding
    [GetCollectibleName(6661)] = 6661, -- Dawnwood Berries of Growth
    [GetCollectibleName(6662)] = 6662, -- Dawnwood Berries of Ripeness

    [GetCollectibleName(6694)] = 6694, -- Luminous Berries of Bloom
    [GetCollectibleName(6695)] = 6695, -- Luminous Berries of Budding
    [GetCollectibleName(6696)] = 6696, -- Luminous Berries of Growth
    [GetCollectibleName(6697)] = 6697, -- Luminous Berries of Ripeness

    [GetCollectibleName(6698)] = 6698, -- Onyx Berries of Bloom
    [GetCollectibleName(6699)] = 6699, -- Onyx Berries of Budding
    [GetCollectibleName(6700)] = 6700, -- Onyx Berries of Growth
    [GetCollectibleName(6701)] = 6701, -- Onyx Berries of Ripeness

    [GetCollectibleName(6702)] = 6702, -- Pure-Snow Berries of Bloom
    [GetCollectibleName(6703)] = 6703, -- Pure-Snow Berries of Budding
    [GetCollectibleName(6704)] = 6704, -- Pure-Snow Berries of Growth
    [GetCollectibleName(6705)] = 6705, -- Pure-Snow Berries of Ripeness

    [GetCollectibleName(7021)] = 7021, -- Spectral Berries of Bloom
    [GetCollectibleName(7022)] = 7022, -- Spectral Berries of Budding
    [GetCollectibleName(7023)] = 7023, -- Spectral Berries of Growth
    [GetCollectibleName(7024)] = 7024, -- Spectral Berries of Ripeness

    [GetCollectibleName(7791)] = 7791, -- Icebreath Berries of Bloom
    [GetCollectibleName(7792)] = 7792, -- Icebreath Berries of Budding
    [GetCollectibleName(7793)] = 7793, -- Icebreath Berries of Growth
    [GetCollectibleName(7794)] = 7794, -- Icebreath Berries of Ripeness

    [GetCollectibleName(8126)] = 8126, -- Mossheart Berries of Bloom
    [GetCollectibleName(8127)] = 8127, -- Mossheart Berries of Budding
    [GetCollectibleName(8128)] = 8128, -- Mossheart Berries of Growth
    [GetCollectibleName(8129)] = 8129, -- Mossheart Berries of Ripeness

    [GetCollectibleName(8196)] = 8196, -- Pact Breton Terrier
    [GetCollectibleName(8197)] = 8197, -- Dominion Breton Terrier
    [GetCollectibleName(8198)] = 8198, -- Covenant Breton Terrier

    [GetCollectibleName(8866)] = 8866, -- Deadlands Flint (Unstable Morpholith)
    [GetCollectibleName(8867)] = 8867, -- Rune-Etched Striker (Unstable Morpholith)
    [GetCollectibleName(8868)] = 8868, -- Smoldering Bloodgrass Tinder (Unstable Morpholith)

    [GetCollectibleName(8869)] = 8869, -- Rune-Scribed Daedra Hide (Deadlands Scorcher)
    [GetCollectibleName(8870)] = 8870, -- Rune-Scribed Daedra Sleeve (Deadlands Scorcher)
    [GetCollectibleName(8871)] = 8871, -- Rune-Scribed Daedra Veil (Deadlands Scorcher)

    [GetCollectibleName(9085)] = 9085, -- Vial of Simmering Daedric Brew (Deadlands Firewalker)
    [GetCollectibleName(9086)] = 9086, -- Vial of Bubbling Daedric Brew (Deadlands Firewalker)
    [GetCollectibleName(9087)] = 9087, -- Vial of Scalding Daedric Brew (Deadlands Firewalker)

    [GetCollectibleName(9163)] = 9163, -- Black Iron Bit and Bridle (Dagonic Quasigriff)
    [GetCollectibleName(9164)] = 9164, -- Black Iron Stirrups (Dagonic Quasigriff)
    [GetCollectibleName(9162)] = 9162, -- Smoke-Wreathed Griffon Feather (Dagonic Quasigriff)
}

--- @class (partial) CrownStoreCollectibles
Data.CrownStoreCollectibles = crownStoreCollectibles
