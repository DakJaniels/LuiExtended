-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------
-- CC tracker suppressions (merged into IgnoreList).

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
local IgnoreList = Data.CrowdControl.IgnoreList

local ignoreListSupplement =
{

    [20930] = true,
    [58864] = true,
    [103492] = true,
    [103652] = true,
    [103665] = true,
    [103706] = true,
    [107579] = true,
    [107630] = true,
    [107637] = true,
    [113195] = true,
    [114797] = true,
    [115721] = true,
    [116584] = true,
    [118851] = true,
    [118914] = true,
    [158363] = true,
    [158365] = true,
    [163335] = true,
    [183122] = true,
    [183537] = true,
    [185805] = true,
    [186193] = true,
    [186200] = true,
    [186366] = true,
    [193331] = true,
    [193397] = true,
    [193398] = true,
    [198309] = true,
    [198330] = true,
    [198537] = true,
    [229256] = true,
    [241678] = true,

}

for abilityId in pairs(ignoreListSupplement) do
    IgnoreList[abilityId] = true
end


