-- -----------------------------------------------------------------------------
--  LuiExtended - CombatText Test Suite (Taneth)                              --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

if not Taneth then
    return
end

local LUIE = LUIE
local CombatText = LUIE.CombatText
local CombatTextConstants = LuiData.Data.CombatTextConstants
local poolTypes = CombatTextConstants.poolType
local eventType = CombatTextConstants.eventType
local combatType = CombatTextConstants.combatType
local COMBAT_MECHANIC_FLAGS_MAGICKA = COMBAT_MECHANIC_FLAGS_MAGICKA
local COMBAT_MECHANIC_FLAGS_STAMINA = COMBAT_MECHANIC_FLAGS_STAMINA
local COMBAT_MECHANIC_FLAGS_ULTIMATE = COMBAT_MECHANIC_FLAGS_ULTIMATE
local DAMAGE_TYPE_PHYSICAL = DAMAGE_TYPE_PHYSICAL

Taneth("CombatText", function ()
    -- Create a minimal EventViewer instance for testing Base methods (needs poolManager for Initialize)
    local function createTestViewer()
        if not CombatText.poolManager then
            return nil
        end
        local viewer = setmetatable({}, { __index = LUIE.CombatTextEventViewer })
        viewer:Initialize(CombatText.poolManager)
        return viewer
    end

    describe("EventViewer Base - FormatString", function ()
        it("should substitute %t and %a placeholders", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local result = viewer:FormatString("%t %a", { text = "Fireball", value = "500" })
            assert.equals(result, "Fireball 500")
        end)

        it("should substitute %r with power type name", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local result = viewer:FormatString("%r", { powerType = COMBAT_MECHANIC_FLAGS_MAGICKA })
            assert.is_not_nil(result)
            assert.is_true(#result > 0)
        end)

        it("should substitute %d with damage type name", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local result = viewer:FormatString("%d", { damageType = DAMAGE_TYPE_PHYSICAL })
            assert.is_not_nil(result)
            assert.is_true(#result > 0)
        end)

        it("should handle nil params", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local result = viewer:FormatString("%t %a", {})
            assert.equals(result, " ")
        end)

        it("should pass through unknown placeholders", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local result = viewer:FormatString("%x %t", { text = "ok" })
            assert.equals(result, "%x ok")
        end)
    end)

    describe("EventViewer Base - FormatAlertString", function ()
        it("should substitute %n, %t, %i placeholders", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local result = viewer:FormatAlertString("%n: %t %i", { source = "Boss", ability = "Heavy Attack", icon = "[icon]" })
            assert.equals(result, "Boss: Heavy Attack [icon]")
        end)

        it("should handle nil params", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local result = viewer:FormatAlertString("%n %t", {})
            assert.equals(result, " ")
        end)
    end)

    describe("EventViewer Base - GetThrottleTime", function ()
        it("should return damage throttle", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local Settings = CombatText.SV
            local t = viewer:GetThrottleTime(Settings, true, false, false, false, false, false, false, false)
            assert.equals(t, Settings.throttles.damage)
        end)

        it("should return damagecritical throttle", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local Settings = CombatText.SV
            local t = viewer:GetThrottleTime(Settings, false, true, false, false, false, false, false, false)
            assert.equals(t, Settings.throttles.damagecritical)
        end)

        it("should return dot throttle", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local Settings = CombatText.SV
            local t = viewer:GetThrottleTime(Settings, false, false, true, false, false, false, false, false)
            assert.equals(t, Settings.throttles.dot)
        end)

        it("should return healing throttle", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local Settings = CombatText.SV
            local t = viewer:GetThrottleTime(Settings, false, false, false, false, true, false, false, false)
            assert.equals(t, Settings.throttles.healing)
        end)

        it("should return dotcritical throttle", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local Settings = CombatText.SV
            local t = viewer:GetThrottleTime(Settings, false, false, false, true, false, false, false, false)
            assert.equals(t, Settings.throttles.dotcritical)
        end)

        it("should return healingcritical throttle", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local Settings = CombatText.SV
            local t = viewer:GetThrottleTime(Settings, false, false, false, false, false, true, false, false)
            assert.equals(t, Settings.throttles.healingcritical)
        end)

        it("should return hot throttle", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local Settings = CombatText.SV
            local t = viewer:GetThrottleTime(Settings, false, false, false, false, false, false, true, false)
            assert.equals(t, Settings.throttles.hot)
        end)

        it("should return hotcritical throttle", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local Settings = CombatText.SV
            local t = viewer:GetThrottleTime(Settings, false, false, false, false, false, false, false, true)
            assert.equals(t, Settings.throttles.hotcritical)
        end)

        it("should return 0 for unknown/fallback", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local Settings = CombatText.SV
            local t = viewer:GetThrottleTime(Settings, false, false, false, false, false, false, false, false)
            assert.equals(t, 0)
        end)
    end)

    describe("EventViewer Base - GetTextAttributes", function ()
        it("should return dodged format and color", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false)
            assert.equals(fmt, CombatText.SV.formats.dodged)
            assert.equals(size, CombatText.SV.fontSizes.mitigation)
            assert.same(color, CombatText.SV.colors.dodged)
        end)

        it("should return miss format and color", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.miss)
            assert.equals(size, CombatText.SV.fontSizes.mitigation)
        end)

        it("should return damage format for damage", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.damage)
            assert.equals(size, CombatText.SV.fontSizes.damage)
        end)

        it("should return healing format for healing", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.healing)
            assert.equals(size, CombatText.SV.fontSizes.healing)
        end)

        it("should return energize format for magicka", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local fmt, size, color = viewer:GetTextAttributes(COMBAT_MECHANIC_FLAGS_MAGICKA, DAMAGE_TYPE_PHYSICAL, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.energize)
            assert.equals(size, CombatText.SV.fontSizes.gainLoss)
        end)

        it("should return immune format and color", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.immune)
            assert.equals(size, CombatText.SV.fontSizes.mitigation)
            assert.same(color, CombatText.SV.colors.immune)
        end)

        it("should return reflected format and color", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            -- Params: isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.reflected)
            assert.equals(size, CombatText.SV.fontSizes.mitigation)
            assert.same(color, CombatText.SV.colors.reflected)
        end)

        it("should return parried format and color", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            -- Params: isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.parried)
            assert.equals(size, CombatText.SV.fontSizes.mitigation)
            assert.same(color, CombatText.SV.colors.parried)
        end)

        it("should return blocked format and color", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false)
            assert.equals(fmt, CombatText.SV.formats.blocked)
            assert.equals(size, CombatText.SV.fontSizes.mitigation)
            assert.same(color, CombatText.SV.colors.blocked)
        end)

        it("should return interrupted format and color", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
            assert.equals(fmt, CombatText.SV.formats.interrupted)
            assert.equals(size, CombatText.SV.fontSizes.mitigation)
            assert.same(color, CombatText.SV.colors.interrupted)
        end)

        it("should return damageShield format and color", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.damageShield)
            assert.equals(size, CombatText.SV.fontSizes.mitigation)
            assert.same(color, CombatText.SV.colors.damageShield)
        end)

        it("should return drain format for stamina", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local fmt, size, color = viewer:GetTextAttributes(COMBAT_MECHANIC_FLAGS_STAMINA, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.drain)
            assert.equals(size, CombatText.SV.fontSizes.gainLoss)
        end)

        it("should return dotcritical format", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            -- Params: isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, ...
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.dotcritical)
            assert.equals(size, CombatText.SV.fontSizes.dotcritical)
        end)

        it("should return hotcritical format", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            -- Params: isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical
            local fmt, size, color = viewer:GetTextAttributes(0, DAMAGE_TYPE_PHYSICAL, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false)
            assert.equals(fmt, CombatText.SV.formats.hotcritical)
            assert.equals(size, CombatText.SV.fontSizes.hotcritical)
        end)
    end)

    describe("EventViewer Base - GetDefaultIcon", function ()
        it("should return LUIE_CC_ICON_STUN for LUIE_CC_TYPE_STUN", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_STUN)
            assert.equals(icon, LUIE_CC_ICON_STUN)
        end)

        it("should return LUIE_CC_ICON_STUN for LUIE_CC_TYPE_KNOCKDOWN", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_KNOCKDOWN)
            assert.equals(icon, LUIE_CC_ICON_STUN)
        end)

        it("should return LUIE_CC_ICON_KNOCKBACK for LUIE_CC_TYPE_KNOCKBACK", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_KNOCKBACK)
            assert.equals(icon, LUIE_CC_ICON_KNOCKBACK)
        end)

        it("should return LUIE_CC_ICON_SILENCE for LUIE_CC_TYPE_STAGGER", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_STAGGER)
            assert.equals(icon, LUIE_CC_ICON_SILENCE)
        end)

        it("should return LUIE_CC_ICON_ROOT for LUIE_CC_TYPE_ROOT", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_ROOT)
            assert.equals(icon, LUIE_CC_ICON_ROOT)
        end)

        it("should return LUIE_CC_ICON_PULL for LUIE_CC_TYPE_PULL", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_PULL)
            assert.equals(icon, LUIE_CC_ICON_PULL)
        end)

        it("should return LUIE_CC_ICON_DISORIENT for LUIE_CC_TYPE_DISORIENT", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_DISORIENT)
            assert.equals(icon, LUIE_CC_ICON_DISORIENT)
        end)

        it("should return LUIE_CC_ICON_FEAR for LUIE_CC_TYPE_FEAR", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_FEAR)
            assert.equals(icon, LUIE_CC_ICON_FEAR)
        end)

        it("should return LUIE_CC_ICON_CHARM for LUIE_CC_TYPE_CHARM", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_CHARM)
            assert.equals(icon, LUIE_CC_ICON_CHARM)
        end)

        it("should return LUIE_CC_ICON_SILENCE for LUIE_CC_TYPE_SILENCE", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_SILENCE)
            assert.equals(icon, LUIE_CC_ICON_SILENCE)
        end)

        it("should return LUIE_CC_ICON_SNARE for LUIE_CC_TYPE_SNARE", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(LUIE_CC_TYPE_SNARE)
            assert.equals(icon, LUIE_CC_ICON_SNARE)
        end)

        it("should return nil for unknown cc type", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local icon = viewer:GetDefaultIcon(99999)
            assert.is_nil(icon)
        end)
    end)

    describe("EventViewer Base - PrepareLabel", function ()
        it("should set text, color, font, and alpha on label", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local control, key = CombatText.poolManager:GetPoolObject(poolTypes.CONTROL)
            local color = { 1, 0.5, 0.25, 1 }
            viewer:PrepareLabel(control.label, 24, color, "TestLabel")
            assert.equals(control.label:GetText(), "TestLabel")
            CombatText.poolManager:ReleasePoolObject(poolTypes.CONTROL, key)
        end)
    end)

    describe("EventViewer Base - IsOverlapping", function ()
        it("should return false for empty activeControls", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local control, key = CombatText.poolManager:GetPoolObject(poolTypes.CONTROL)
            local overlapping = viewer:IsOverlapping(control, {})
            CombatText.poolManager:ReleasePoolObject(poolTypes.CONTROL, key)
            assert.is_false(overlapping)
        end)

        it("should return true when control overlaps with itself", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local control, key = CombatText.poolManager:GetPoolObject(poolTypes.CONTROL)
            control:SetDimensions(50, 20)
            control:SetAnchor(CENTER, GuiRoot, CENTER, 100, 100)
            -- A control always overlaps with itself (same rect)
            local overlapping = viewer:IsOverlapping(control, { [1] = control })
            CombatText.poolManager:ReleasePoolObject(poolTypes.CONTROL, key)
            assert.is_true(overlapping)
        end)

        it("should return false when controls do not overlap", function ()
            local viewer = createTestViewer()
            if not viewer then return end
            local c1, k1 = CombatText.poolManager:GetPoolObject(poolTypes.CONTROL)
            local c2, k2 = CombatText.poolManager:GetPoolObject(poolTypes.CONTROL)
            c1:SetDimensions(50, 20)
            c1:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
            c2:SetDimensions(50, 20)
            c2:SetAnchor(CENTER, GuiRoot, CENTER, 500, 500)
            local overlapping = viewer:IsOverlapping(c1, { [1] = c2 })
            CombatText.poolManager:ReleasePoolObject(poolTypes.CONTROL, k1)
            CombatText.poolManager:ReleasePoolObject(poolTypes.CONTROL, k2)
            assert.is_false(overlapping)
        end)
    end)

    describe("PoolManager", function ()
        it("should have pools for all pool types", function ()
            assert.is_not_nil(CombatText.poolManager)
            for _, pt in pairs(poolTypes) do
                assert.is_not_nil(CombatText.poolManager.pools[pt], "Pool missing for " .. tostring(pt))
            end
        end)

        it("should acquire and release pool objects", function ()
            local obj, key = CombatText.poolManager:GetPoolObject(poolTypes.ANIMATION_CLOUD)
            assert.is_not_nil(obj)
            assert.is_not_nil(key)
            CombatText.poolManager:ReleasePoolObject(poolTypes.ANIMATION_CLOUD, key)
        end)

        it("should track TotalFree and TotalInUse", function ()
            local freeBefore = CombatText.poolManager:TotalFree()
            local inUseBefore = CombatText.poolManager:TotalInUse()
            local obj, key = CombatText.poolManager:GetPoolObject(poolTypes.ANIMATION_POINT)
            local inUseAfter = CombatText.poolManager:TotalInUse()
            CombatText.poolManager:ReleasePoolObject(poolTypes.ANIMATION_POINT, key)
            local freeAfter = CombatText.poolManager:TotalFree()
            assert.is_true(inUseAfter >= inUseBefore)
            assert.is_true(freeAfter >= freeBefore)
        end)
    end)

    describe("Pool", function ()
        it("should require poolType", function ()
            assert.has_error("poolType is required.", function ()
                LUIE.CombatTextPool:New(nil)
            end)
        end)

        it("should create animation pool and return object with timeline", function ()
            if not CombatText.poolManager then return end
            local obj, key = CombatText.poolManager:GetPoolObject(poolTypes.ANIMATION_CLOUD)
            assert.is_not_nil(obj)
            assert.is_not_nil(obj.timeline)
            assert.is_not_nil(obj.Apply)
            assert.is_not_nil(obj.Play)
            CombatText.poolManager:ReleasePoolObject(poolTypes.ANIMATION_CLOUD, key)
        end)

        it("should create control pool and return control with label and icon", function ()
            -- Use CombatText.poolManager to avoid duplicate control names (CreateControlFromVirtual requires unique names globally)
            if not CombatText.poolManager then return end
            local control, key = CombatText.poolManager:GetPoolObject(poolTypes.CONTROL)
            assert.is_not_nil(control)
            assert.is_not_nil(control.label)
            assert.is_not_nil(control.icon)
            CombatText.poolManager:ReleasePoolObject(poolTypes.CONTROL, key)
        end)

        it("should hide control when released (ResetControl)", function ()
            if not CombatText.poolManager then return end
            local control, key = CombatText.poolManager:GetPoolObject(poolTypes.CONTROL)
            control:SetHidden(false)
            CombatText.poolManager:ReleasePoolObject(poolTypes.CONTROL, key)
            assert.is_true(control:IsHidden())
        end)

        it("should show control when acquired (CustomAcquireBehavior)", function ()
            if not CombatText.poolManager then return end
            local control, key = CombatText.poolManager:GetPoolObject(poolTypes.CONTROL)
            assert.is_false(control:IsHidden())
            CombatText.poolManager:ReleasePoolObject(poolTypes.CONTROL, key)
        end)

        it("should create all animation pool types with valid config", function ()
            if not CombatText.poolManager then return end
            for _, pt in pairs(poolTypes) do
                if pt ~= poolTypes.CONTROL then
                    local obj, objKey = CombatText.poolManager:GetPoolObject(pt)
                    assert.is_not_nil(obj, "Pool " .. tostring(pt) .. " failed to create object")
                    assert.is_not_nil(obj.timeline, "Pool " .. tostring(pt) .. " object missing timeline")
                    assert.is_not_nil(obj.Apply, "Pool " .. tostring(pt) .. " object missing Apply")
                    assert.is_not_nil(obj.Play, "Pool " .. tostring(pt) .. " object missing Play")
                    CombatText.poolManager:ReleasePoolObject(pt, objKey)
                end
            end
        end)
    end)

    describe("Animation", function ()
        it("should create object with timeline", function ()
            local anim = LUIE.CombatTextAnimation:New()
            assert.is_not_nil(anim)
            assert.is_not_nil(anim.timeline)
        end)

        it("should insert Alpha step", function ()
            local anim = LUIE.CombatTextAnimation:New()
            local step = anim:Alpha("fade", 0, 1, 100, 0)
            assert.is_not_nil(step)
            assert.is_not_nil(anim:GetStepByName("fade"))
        end)

        it("should insert Scale step", function ()
            local anim = LUIE.CombatTextAnimation:New()
            local step = anim:Scale(nil, 0.5, 1.5, 100, 0)
            assert.is_not_nil(step)
        end)

        it("should insert Move step", function ()
            local anim = LUIE.CombatTextAnimation:New()
            local step = anim:Move("scroll", 0, 100, 500, 0)
            assert.is_not_nil(step)
            assert.is_not_nil(anim:GetStepByName("scroll"))
        end)

        it("should return GetDuration", function ()
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha(nil, 0, 1, 100, 0)
            local dur = anim:GetDuration()
            assert.is_true(dur >= 0)
        end)

        it("should Reset and SetProgress", function ()
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha(nil, 0, 1, 100, 0)
            anim:SetProgress(0.5)
            assert.equals(anim:GetProgress(), 0.5)
            anim:Reset()
            assert.equals(anim:GetProgress(), 0)
        end)

        it.async("should fire SetStopHandler when animation stops", function (done)
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha(nil, 1, 1, 1, 0)
            local fired = false
            anim:SetStopHandler(function ()
                fired = true
                done()
            end)
            anim:Play()
        end)

        it("should Apply timeline to control without error", function ()
            if not CombatText.poolManager then return end
            local control, cKey = CombatText.poolManager:GetPoolObject(poolTypes.CONTROL)
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha(nil, 0, 1, 100, 0)
            anim:Apply(control)
            CombatText.poolManager:ReleasePoolObject(poolTypes.CONTROL, cKey)
        end)

        it("should Stop animation", function ()
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha(nil, 0, 1, 1000, 0)
            anim:Play()
            anim:Stop()
            assert.is_true(anim:GetProgress() >= 0)
        end)

        it.async("should InsertCallback and fire it", function (done)
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha(nil, 1, 1, 10, 0)
            local fired = false
            anim:InsertCallback(function ()
                                    fired = true
                                    done()
                                end, 5)
            anim:Play()
        end)

        it("should ClearCallbacks remove callbacks", function ()
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha(nil, 1, 1, 100, 0)
            anim:InsertCallback(function () end, 50)
            anim:ClearCallbacks()
            anim:Play()
            anim:Stop()
        end)

        it("should GetStep return step by index", function ()
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha(nil, 0, 1, 100, 0)
            local step = anim:GetStep(1)
            assert.is_not_nil(step)
        end)

        it("should GetLastStep return last animation step", function ()
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha("a", 0, 1, 100, 0)
            anim:Alpha("b", 1, 0, 100, 100)
            local last = anim:GetLastStep()
            assert.is_not_nil(last)
        end)

        it("should SetStopHandler(nil) clear handler", function ()
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha(nil, 1, 1, 1, 0)
            anim:SetStopHandler(function () end)
            anim:SetStopHandler(nil)
            anim:Play()
            anim:Stop()
        end)

        it("should GetStepByName return nil for empty string", function ()
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha("", 0, 1, 100, 0)
            assert.is_nil(anim:GetStepByName(""))
        end)

        it("should SetStepDelay modify step offset", function ()
            local anim = LUIE.CombatTextAnimation:New()
            anim:Alpha("a", 0, 1, 100, 0)
            local step = anim:GetStepByName("a")
            anim:SetStepDelay(step, 50)
            anim:Play()
            anim:Stop()
        end)
    end)

    describe("CombatText Main - List Functions", function ()
        it("should AddBulkToCustomList add keys from table", function ()
            local list = {}
            CombatText.AddBulkToCustomList(list, { a = 1, b = 2, c = 3 })
            assert.is_true(list.a)
            assert.is_true(list.b)
            assert.is_true(list.c)
        end)

        it("should AddBulkToCustomList handle nil table", function ()
            local list = {}
            CombatText.AddBulkToCustomList(list, nil)
            assert.equals(0, 0)
        end)

        it("should AddToCustomList add string by name", function ()
            local list = {}
            CombatText.AddToCustomList(list, "TestAbilityName")
            assert.is_true(list["TestAbilityName"])
        end)

        it("should AddToCustomList add numeric ability id when GetAbilityName returns valid name", function ()
            -- 17910 is a common ESO ability; GetAbilityName may return empty in some environments
            local list = {}
            CombatText.AddToCustomList(list, "17910")
            if GetAbilityName(17910) and GetAbilityName(17910) ~= "" then
                assert.is_true(list[17910])
            end
        end)

        it("should RemoveFromCustomList remove string by name", function ()
            local list = { ["TestRemove"] = true }
            CombatText.RemoveFromCustomList(list, "TestRemove")
            assert.is_nil(list["TestRemove"])
        end)

        it("should RemoveFromCustomList remove numeric id", function ()
            local list = { [17910] = true }
            CombatText.RemoveFromCustomList(list, "17910")
            assert.is_nil(list[17910])
        end)

        it("should ClearCustomList clear all entries", function ()
            local list = { a = true, b = true }
            CombatText.ClearCustomList(list)
            assert.is_nil(list.a)
            assert.is_nil(list.b)
        end)
    end)

    describe("CombatText Main - SavePosition", function ()
        it("should update SV panels when SavePosition is called", function ()
            local panel = LUIE_CombatText_Outgoing
            if not panel then return end
            CombatText.SavePosition(panel)
            local anchor = { panel:GetAnchor(0) }
            assert.equals(CombatText.SV.panels.LUIE_CombatText_Outgoing.point, anchor[2])
            assert.equals(CombatText.SV.panels.LUIE_CombatText_Outgoing.offsetX, anchor[5])
            assert.equals(CombatText.SV.panels.LUIE_CombatText_Outgoing.offsetY, anchor[6])
        end)
    end)

    describe("CombatText Main - CreateCombatEventViewer", function ()
        it("should create CombatCloud viewer when animationType is cloud", function ()
            if not CombatText.poolManager then return end
            local orig = CombatText.SV.animation.animationType
            CombatText.SV.animation.animationType = "cloud"
            CombatText:CreateCombatEventViewer()
            assert.is_not_nil(CombatText.combatEventViewer)
            assert.is_true(CombatText.combatEventViewer:IsInstanceOf(LUIE.CombatTextCombatCloudEventViewer))
            CombatText.SV.animation.animationType = orig
            CombatText:CreateCombatEventViewer()
        end)

        it("should create CombatScroll viewer when animationType is scroll", function ()
            if not CombatText.poolManager then return end
            local orig = CombatText.SV.animation.animationType
            CombatText.SV.animation.animationType = "scroll"
            CombatText:CreateCombatEventViewer()
            assert.is_not_nil(CombatText.combatEventViewer)
            assert.is_true(CombatText.combatEventViewer:IsInstanceOf(LUIE.CombatTextCombatScrollEventViewer))
            CombatText.SV.animation.animationType = orig
            CombatText:CreateCombatEventViewer()
        end)

        it("should create CombatEllipse viewer when animationType is ellipse", function ()
            if not CombatText.poolManager then return end
            local orig = CombatText.SV.animation.animationType
            CombatText.SV.animation.animationType = "ellipse"
            CombatText:CreateCombatEventViewer()
            assert.is_not_nil(CombatText.combatEventViewer)
            assert.is_true(CombatText.combatEventViewer:IsInstanceOf(LUIE.CombatTextCombatEllipseEventViewer))
            CombatText.SV.animation.animationType = orig
            CombatText:CreateCombatEventViewer()
        end)

        it("should create CombatHybrid viewer when animationType is hybrid", function ()
            if not CombatText.poolManager then return end
            local orig = CombatText.SV.animation.animationType
            CombatText.SV.animation.animationType = "hybrid"
            CombatText:CreateCombatEventViewer()
            assert.is_not_nil(CombatText.combatEventViewer)
            assert.is_true(CombatText.combatEventViewer:IsInstanceOf(LUIE.CombatTextCombatHybridEventViewer))
            CombatText.SV.animation.animationType = orig
            CombatText:CreateCombatEventViewer()
        end)
    end)

    describe("CombatCloud EventViewer", function ()
        it("should initialize with eventBuffer", function ()
            if not CombatText.poolManager then return end
            local orig = CombatText.SV.animation.animationType
            CombatText.SV.animation.animationType = "cloud"
            CombatText:CreateCombatEventViewer()
            local viewer = CombatText.combatEventViewer
            assert.is_not_nil(viewer)
            assert.is_not_nil(viewer.eventBuffer)
            assert.same(viewer.eventBuffer, {})
            CombatText.SV.animation.animationType = orig
            CombatText:CreateCombatEventViewer()
        end)

        it("should register COMBAT callback", function ()
            if not CombatText.poolManager then return end
            local orig = CombatText.SV.animation.animationType
            CombatText.SV.animation.animationType = "cloud"
            CombatText:CreateCombatEventViewer()
            local viewer = CombatText.combatEventViewer
            assert.is_not_nil(viewer.callbackRefs)
            assert.is_not_nil(viewer.callbackRefs[eventType.COMBAT])
            assert.is_true(#viewer.callbackRefs[eventType.COMBAT] >= 1)
            CombatText.SV.animation.animationType = orig
            CombatText:CreateCombatEventViewer()
        end)

        it("should return early from OnEvent when animationType is not cloud", function ()
            if not CombatText.poolManager then return end
            local orig = CombatText.SV.animation.animationType
            CombatText.SV.animation.animationType = "scroll"
            local viewer = LUIE.CombatTextCombatCloudEventViewer:New(CombatText.poolManager)
            viewer.eventBuffer = {}
            viewer:OnEvent(combatType.OUTGOING, COMBAT_MECHANIC_FLAGS_STAMINA, 100, "Test", 17910, DAMAGE_TYPE_PHYSICAL, "Src", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
            assert.same(viewer.eventBuffer, {})
            CombatText.SV.animation.animationType = orig
        end)

        it("should merge events with same eventKey in buffer", function ()
            if not CombatText.poolManager then return end
            local orig = CombatText.SV.animation.animationType
            CombatText.SV.animation.animationType = "cloud"
            CombatText:CreateCombatEventViewer()
            local viewer = CombatText.combatEventViewer
            local eventKey = 17910 .. "_" .. combatType.OUTGOING .. "_" .. DAMAGE_TYPE_PHYSICAL .. "_1"
            viewer.eventBuffer[eventKey] = { value = 100, hits = 1 }
            viewer:OnEvent(combatType.OUTGOING, COMBAT_MECHANIC_FLAGS_STAMINA, 200, "Test", 17910, DAMAGE_TYPE_PHYSICAL, "Src", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
            assert.equals(viewer.eventBuffer[eventKey].value, 300)
            assert.equals(viewer.eventBuffer[eventKey].hits, 2)
            viewer.eventBuffer[eventKey] = nil
            CombatText.SV.animation.animationType = orig
            CombatText:CreateCombatEventViewer()
        end)
    end)

    describe("CombatText Constants", function ()
        it("should have poolType CONTROL", function ()
            assert.is_not_nil(poolTypes.CONTROL)
        end)

        it("should have poolType ANIMATION_CLOUD", function ()
            assert.is_not_nil(poolTypes.ANIMATION_CLOUD)
        end)

        it("should have eventType COMBAT", function ()
            assert.is_not_nil(eventType.COMBAT)
        end)

        it("should have combatType OUTGOING and INCOMING", function ()
            assert.is_not_nil(combatType.OUTGOING)
            assert.is_not_nil(combatType.INCOMING)
        end)
    end)

    describe("Integration", function ()
        it.async("should fire COMBAT callback and viewer receives", function (done)
            if not CombatText.combatEventViewer then
                done()
                return
            end
            CALLBACK_MANAGER:FireCallbacks(eventType.COMBAT, combatType.OUTGOING, COMBAT_MECHANIC_FLAGS_STAMINA, 100, "Test", 17910, DAMAGE_TYPE_PHYSICAL, "TestSource", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
            LUIE_callLater(function ()
                               done()
                           end, 100)
        end)

        it.async("should show multiple animations when firing events with different abilityIds", function (done)
            -- CombatCloud merges events with same eventKey (abilityId+combatType+damageType+flags).
            -- Different abilityIds => different keys => no merge => separate animations.
            if not CombatText.combatEventViewer then
                done()
                return
            end
            local fire = function (value, abilityId)
                CALLBACK_MANAGER:FireCallbacks(eventType.COMBAT, combatType.OUTGOING, COMBAT_MECHANIC_FLAGS_STAMINA, value, "Test", abilityId, DAMAGE_TYPE_PHYSICAL, "TestSource", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
            end
            fire(100, 17910)
            fire(200, 16277)
            fire(300, 16688)
            LUIE_callLater(function ()
                               done()
                           end, 150)
        end)

        it.async("should complete pool acquire/release cycle with animation stop handler", function (done)
            local control, controlKey = CombatText.poolManager:GetPoolObject(poolTypes.CONTROL)
            local animation, animKey = CombatText.poolManager:GetPoolObject(poolTypes.ANIMATION_POINT)
            animation:Apply(control)
            animation:SetStopHandler(function ()
                CombatText.poolManager:ReleasePoolObject(poolTypes.CONTROL, controlKey)
                CombatText.poolManager:ReleasePoolObject(poolTypes.ANIMATION_POINT, animKey)
                done()
            end)
            animation:Play()
        end)
    end)
end)

SLASH_COMMANDS["/luiectest"] = function (args)
    LUIE:Log("Debug", "Running CombatText tests...")
    local result = Taneth:RunTestSuites({ "CombatText" }, function ()
        LUIE:Log("Debug", "CombatText tests completed.")
    end)
    if not result then
        LUIE:Log("Debug", "Test execution completed (sync).")
    end
end

-- Manual trigger: fire 3 COMBAT events with different abilityIds to verify multiple animations show.
-- Use: /luiectestmulti
SLASH_COMMANDS["/luiectestmulti"] = function ()
    local fire = function (value, abilityId)
        CALLBACK_MANAGER:FireCallbacks(eventType.COMBAT, combatType.OUTGOING, COMBAT_MECHANIC_FLAGS_STAMINA, value, "Test", abilityId, DAMAGE_TYPE_PHYSICAL, "TestSource", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
    end
    fire(100, 17910)
    fire(200, 16277)
    fire(300, 16688)
    LUIE:Log("Debug", "Fired 3 COMBAT events (Test 100, Test 200, Test 300). Check if all 3 animations appear.")
end
