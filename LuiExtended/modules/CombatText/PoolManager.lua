-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

local pairs = pairs


--- @class (partial) LuiExtended.CombatTextPoolManager : ZO_InitializingObject
local CombatTextPoolManager = ZO_InitializingObject:Subclass()

--- @class (partial) LuiExtended.CombatTextPoolManager
LUIE.CombatTextPoolManager = CombatTextPoolManager

function CombatTextPoolManager:Initialize(poolTypes)
    self.pools = {}
    -- Create a pool for each type
    for _, poolType in pairs(poolTypes) do
        self:RegisterPool(poolType, LUIE.CombatTextPool:New(poolType))
    end
end

function CombatTextPoolManager:RegisterPool(poolType, pool)
    self.pools[poolType] = pool
end

function CombatTextPoolManager:GetPoolObject(poolType)
    return self.pools[poolType]:AcquireObject()
end

function CombatTextPoolManager:ReleasePoolObject(poolType, objectKey)
    self.pools[poolType]:ReleaseObject(objectKey)
end

function CombatTextPoolManager:TotalFree()
    local count = 0
    for k, _ in pairs(self.pools) do
        count = count + self.pools[k]:GetFreeObjectCount()
    end
    return count
end

function CombatTextPoolManager:TotalInUse()
    local count = 0
    for k, _ in pairs(self.pools) do
        count = count + self.pools[k]:GetActiveObjectCount()
    end
    return count
end
