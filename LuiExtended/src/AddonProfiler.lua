--- @class (partial) AddonProfiler
--- @field isRunning boolean Whether the profiler is currently running
--- @field results table<string, any> Results storage
--- @field addonName string Name of the addon being profiled
--- @field memoryStates table<string, MemoryState> Memory states for each profiling section
--- @field currentSection string? Currently active profiling section

--- @class MemoryState
--- @field before number Memory usage before section (in KB)
--- @field after number Memory usage after section (in KB)
--- @field children table<string, number> Nested measurements
--- @field cpuTime number CPU time when measurement started

-- -----------------------------------------------------------------------------
local zo_strformat = zo_strformat
local collectgarbage = collectgarbage
local os_rawclock = os.rawclock
-- -----------------------------------------------------------------------------

--- @class (partial) AddonProfiler
local AddonProfiler =
{
    isRunning = false,
    results = {},
    addonName = "",
    memoryStates = {},
    currentSection = nil,
}

-- bullet constant for reusability
local BULLET = "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t"

--- Starts memory profiling for a specific section
--- @param tag string The section identifier
--- @param state "before"|"after" Whether this is the start or end of the section
function AddonProfiler:CaptureMemoryState(tag, state)
    self.memoryStates[tag] = self.memoryStates[tag] or
        {
            before = 0,
            after = 0,
            children = {},
            cpuTime = os.rawclock(),
        }

    -- Force garbage collection to get accurate memory usage
    for i = 1, 2 do collectgarbage("collect") end
    local memoryKB = collectgarbage("count")

    if state == "before" then
        self.memoryStates[tag].before = memoryKB
        self.memoryStates[tag].cpuTime = os.rawclock()
        self.currentSection = tag
    elseif state == "after" then
        -- Ensure memory usage doesn't decrease
        if self.memoryStates[tag].after == 0 or memoryKB > self.memoryStates[tag].before then
            self.memoryStates[tag].after = memoryKB
        else
            self.memoryStates[tag].after = self.memoryStates[tag].before
        end

        local delta = self.memoryStates[tag].after - self.memoryStates[tag].before
        local cpuElapsed = os.rawclock() - self.memoryStates[tag].cpuTime

        self:OutputMemoryProfileResult(tag, self.memoryStates[tag].before, self.memoryStates[tag].after, delta, cpuElapsed)
    end
end

--- Outputs the memory profile result for a section
--- @param tag string The section identifier
--- @param before number Memory usage before section (in KB)
--- @param after number Memory usage after section (in KB)
--- @param delta number Memory usage change (in KB)
--- @param cpuElapsed number Elapsed CPU time (in ms)
function AddonProfiler:OutputMemoryProfileResult(tag, before, after, delta, cpuElapsed)
    d(string.format("[%s] Memory profile '%s':", self.addonName, tag))
    d(string.format("  Before: %.3f KB", before))
    d(string.format("  After:  %.3f KB", after))
    d(string.format("  Delta:  %.3f KB (CPU: %.2f ms)", delta, cpuElapsed))
end

--- Starts profiling for the specified addon
--- @param addonName string The name of the addon to profile
function AddonProfiler:Start(addonName)
    if self.isRunning then return end

    self.addonName = addonName
    self.isRunning = true
    self.memoryStates = {}

    StartScriptProfiler()
    self:CaptureMemoryState("Total", "before")
end

--- Records a profiling event
--- @param eventName string The name of the event to record
function AddonProfiler:MarkEvent(eventName)
    if not self.isRunning then return end

    RecordScriptProfilerUserEvent(eventName)

    if eventName:match("Start$") then
        local section = eventName:gsub(" Start$", "")
        self:CaptureMemoryState(section, "before")
    elseif eventName:match("End$") then
        local section = eventName:gsub(" End$", "")
        self:CaptureMemoryState(section, "after")
    end
end

--- Stops profiling and generates the report
function AddonProfiler:Stop()
    if not self.isRunning then return end

    self:CaptureMemoryState("Total", "after")
    self:GenerateReport()
    StopScriptProfiler()
    self.isRunning = false
end

--- Generates and displays the profiling report
function AddonProfiler:GenerateReport()
    --- @type {functions: table<string, number>, totalTime: number, gcTime: number}
    local results =
    {
        functions = {},
        totalTime = 0,
        gcTime = 0,
    }

    -- Process profiling data
    for frameIndex = 1, GetScriptProfilerNumFrames() do
        for recordIndex = 1, GetScriptProfilerFrameNumRecords(frameIndex) do
            local recordDataIndex, startTimeNS, endTimeNS, _, recordDataType = GetScriptProfilerRecordInfo(frameIndex, recordIndex)
            local timeMS = (endTimeNS - startTimeNS) / (1000 * 1000)

            if recordDataType == SCRIPT_PROFILER_RECORD_DATA_TYPE_CLOSURE then
                local name, filename, lineDefined = GetScriptProfilerClosureInfo(recordDataIndex)
                if filename:find(self.addonName) then
                    results.functions[name] = (results.functions[name] or 0) + timeMS
                    results.totalTime = results.totalTime + timeMS
                end
            elseif recordDataType == SCRIPT_PROFILER_RECORD_DATA_TYPE_GARBAGE_COLLECTION then
                results.gcTime = results.gcTime + timeMS
            end
        end
    end

    -- Output results
    self:OutputResults(results)
end

--- Outputs the formatted results
--- @param results {functions: table<string, number>, totalTime: number, gcTime: number}
function AddonProfiler:OutputResults(results)
    -- Initial memory profile output (keeping existing format)
    if self.memoryStates["Total"] then
        local totalDelta = self.memoryStates["Total"].after - self.memoryStates["Total"].before
        local cpuElapsed = os_rawclock() - self.memoryStates["Total"].cpuTime
        self:OutputMemoryProfileResult("Total", self.memoryStates["Total"].before, self.memoryStates["Total"].after, totalDelta, cpuElapsed)
    end

    -- Detailed Profiling Results
    self:OutputDetailedProfilingResults(results)
end

--- Outputs the detailed profiling results
--- @param results {functions: table<string, number>, totalTime: number, gcTime: number}
function AddonProfiler:OutputDetailedProfilingResults(results)
    d(string.format("|cFFA500%s Profile Results|r", self.addonName))
    d("\n")

    -- Performance Summary
    d("|cFFFF00Performance:|r")
    d(string.format("%s Runtime: %.2fms", BULLET, results.totalTime))
    d(string.format("%s GC Time: %.2fms", BULLET, results.gcTime))
    if self.memoryStates["Total"] then
        local totalDelta = self.memoryStates["Total"].after - self.memoryStates["Total"].before
        d(string.format("%s Memory Delta: %.2fKB", BULLET, totalDelta))
    end
    d("\n")

    -- Function HotSpots
    d("|cFFFF00Function HotSpots:|r")
    local sorted = {}
    for name, time in pairs(results.functions) do
        table.insert(sorted, { name = name, time = time })
    end
    table.sort(sorted, function (a, b) return a.time > b.time end)

    for i = 1, math.min(5, #sorted) do
        local func = sorted[i]
        local name = func.name
        if #name > 40 then
            name = "..." .. name:sub(-37)
        end
        d(string.format("%s %s: %.2fms", BULLET, name, func.time))
    end
    d("\n")

    -- Memory Impact
    d("|cFFFF00Memory Impact:|r")
    local memSorted = {}
    for tag, data in pairs(self.memoryStates) do
        if tag ~= "Total" then
            local delta = data.after - data.before
            if math.abs(delta) > 0.001 then
                table.insert(memSorted,
                    {
                        tag = tag,
                        delta = delta,
                        cpuTime = os_rawclock() - data.cpuTime
                    })
            end
        end
    end
    table.sort(memSorted, function (a, b) return math.abs(a.delta) > math.abs(b.delta) end)

    for i = 1, math.min(6, #memSorted) do
        local entry = memSorted[i]
        local indicator = self:FormatMemoryChangeIndicator(entry.delta)
        d(string.format("%s %s: %s %.2f KB", BULLET, entry.tag, indicator, math.abs(entry.delta)))
    end
end

--- Formats the memory change indicator based on the delta value
--- @param delta number The memory usage change (in KB)
--- @return string The formatted memory change indicator
function AddonProfiler:FormatMemoryChangeIndicator(delta)
    local indicator = delta > 0 and "|c00FF00[+++]|r" or "|cFF0000[-]|r"
    if math.abs(delta) < 10 then
        indicator = delta > 0 and "|c00FF00[+]|r" or "|cFF0000[-]|r"
    elseif math.abs(delta) < 100 then
        indicator = delta > 0 and "|c00FF00[++]|r" or "|cFF0000[--]|r"
    end
    return indicator
end

--- Outputs the memory profiling breakdown
function AddonProfiler:OutputMemoryBreakdown()
    d("\nDetailed Memory Breakdown (sorted by impact):")

    local sortedChanges = {}
    for tag, data in pairs(self.memoryStates) do
        local delta = data.after - data.before
        if data.after > 0 and math.abs(delta) > 0.001 then
            table.insert(sortedChanges,
                {
                    tag = tag,
                    data = data,
                    delta = delta
                })
        end
    end

    table.sort(sortedChanges, function (a, b) return math.abs(a.delta) > math.abs(b.delta) end)

    for _, entry in ipairs(sortedChanges) do
        local tag, data, delta = entry.tag, entry.data, entry.delta
        local cpuElapsed = os.rawclock() - data.cpuTime

        d(string.format("\n%s (CPU: %.2f ms):", tag, cpuElapsed))
        d(string.format("  Initial State: %.3f KB", data.before))
        d(string.format("  Final State:   %.3f KB", data.after))
        d(string.format("  Total Change:  %.3f KB", delta))

        if next(data.children) then
            d("  Nested measurements:")
            for childTag, childDelta in pairs(data.children) do
                d(string.format("    %s: %.3f KB", childTag, childDelta))
            end
        end
    end
end

-- AddonProfiler Global
rawset(_G, "AddonProfiler", AddonProfiler)
