-- -----------------------------------------------------------------------------
-- Developer slash: micro-benchmark GetCachedTable / RecycleTable
-- -----------------------------------------------------------------------------
if LUIE.IsDevDebugEnabled() then
    SLASH_COMMANDS["/luietablecache"] = function ()
        local N = 100000

        local function benchLog(msg)
            LUIE:Log("Debug", msg)
        end

        --- @param label string
        --- @param work fun()
        local function runBench(label, work)
            collectgarbage("collect")
            local mem0 = collectgarbage("count")
            local t0 = GetGameTimeMilliseconds()
            work()
            benchLog(string.format("[LUIE] bench %-30s %+9.2f KiB %5d ms cache=%d", label, collectgarbage("count") - mem0, GetGameTimeMilliseconds() - t0, LUIE.GetTableCacheStats()))
        end

        --- Same as runBench but no collectgarbage before (for back-to-back pool passes)
        --- @param label string
        --- @param work fun()
        local function runBenchHot(label, work)
            local mem0 = collectgarbage("count")
            local t0 = GetGameTimeMilliseconds()
            work()
            benchLog(string.format("[LUIE] bench %-30s %+9.2f KiB %5d ms cache=%d", label, collectgarbage("count") - mem0, GetGameTimeMilliseconds() - t0, LUIE.GetTableCacheStats()))
        end

        local zo_min = zo_min

        benchLog(string.format("[LUIE] table_cache bench n=%d cache=%d", N, LUIE.GetTableCacheStats()))
        benchLog("[LUIE] cache= is pool size after that line; serial get/recycle reuses one identity (cache=1). Batched simulates many live flag tables.")

        runBench("alloc array of {i}", function ()
            local a = {}
            for i = 1, N do
                table.insert(a, { i })
            end
        end)

        runBench("alloc array of tostring(i)", function ()
            local a = {}
            for i = 1, N do
                table.insert(a, tostring(i))
            end
        end)

        runBench("alloc array of numbers", function ()
            local a = {}
            for i = 1, N do
                table.insert(a, i)
            end
        end)

        runBench("alloc short-lived {} t[1]=i", function ()
            for i = 1, N do
                local t = {}
                t[1] = i
            end
        end)

        local function poolSingleKeyLoop()
            for i = 1, N do
                local t = LUIE.GetCachedTable()
                t[1] = i
                LUIE.RecycleTable(t)
            end
        end

        runBench("pool get t[1] recycle", poolSingleKeyLoop)
        runBenchHot("pool same (no GC between)", poolSingleKeyLoop)

        local function poolSparseFlagsLoop()
            for i = 1, N do
                local t = LUIE.GetCachedTable()
                t.isDamage = true
                t.isDamageCritical = false
                t.isDot = (i % 2 == 0)
                t.isDotCritical = false
                t.isHealing = false
                t.isHealingCritical = false
                t.isHot = false
                t.isHotCritical = false
                LUIE.RecycleTable(t)
            end
        end

        runBench("pool 8 sparse booleans", poolSparseFlagsLoop)
        runBenchHot("pool 8 sparse (no GC between)", poolSparseFlagsLoop)

        -- Same key set as CombatTextCombatCloudEventViewer:View (GetTextAttributes path)
        local function fillCombatTextViewFlags(t, i)
            t.isDamage = (i % 2 == 1)
            t.isDamageCritical = (i % 5 == 0)
            t.isDot = (i % 3 == 0)
            t.isDotCritical = (i % 17 == 0)
            t.isHealing = (i % 7 == 0)
            t.isHealingCritical = false
            t.isHot = (i % 11 == 0)
            t.isHotCritical = false
            t.isEnergize = (i % 13 == 0)
            t.isDrain = false
            t.isMiss = false
            t.isImmune = (i % 19 == 0)
            t.isParried = false
            t.isReflected = false
            t.isDamageShield = false
            t.isDodged = false
            t.isBlocked = (i % 23 == 0)
            t.isInterrupted = false
        end

        -- Same keys as CombatTextCombatCloudEventViewer:OnEvent throttle branch (GetThrottleTime path)
        local function fillCombatTextThrottleFlags(t, i)
            t.isDamage = true
            t.isDamageCritical = (i % 2 == 0)
            t.isDot = (i % 3 == 0)
            t.isDotCritical = false
            t.isHealing = false
            t.isHealingCritical = false
            t.isHot = false
            t.isHotCritical = false
        end

        --- Hold `depth` pooled tables at once; total get/recycle ops still N
        --- @param depth integer
        --- @param fillFn fun(t: table, i: integer)
        local function makePoolBatchWorker(depth, fillFn)
            return function ()
                local batch = {}
                local done = 0
                while done < N do
                    local nThis = zo_min(depth, N - done)
                    for j = 1, nThis do
                        batch[j] = LUIE.GetCachedTable()
                        fillFn(batch[j], done + j)
                    end
                    for j = 1, nThis do
                        LUIE.RecycleTable(batch[j])
                    end
                    done = done + nThis
                end
            end
        end

        local BATCH = 24
        runBench(string.format("pool b=%d CT View 17f", BATCH), makePoolBatchWorker(BATCH, fillCombatTextViewFlags))
        runBenchHot(string.format("pool b=%d View hot", BATCH), makePoolBatchWorker(BATCH, fillCombatTextViewFlags))
        runBench(string.format("pool b=%d CT throt 8f", BATCH), makePoolBatchWorker(BATCH, fillCombatTextThrottleFlags))
        runBenchHot(string.format("pool b=%d throt hot", BATCH), makePoolBatchWorker(BATCH, fillCombatTextThrottleFlags))

        collectgarbage("collect")
        benchLog(string.format("[LUIE] table_cache bench done cache=%d", LUIE.GetTableCacheStats()))
    end
end
