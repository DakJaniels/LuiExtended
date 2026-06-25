-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

-- -----------------------------------------------------------------------------
-- MiniMap-local cooperative coroutine scheduler.
--
-- The minimap reuses the real ZO_WorldMap, and several ZOS pin refreshes still
-- run synchronously in one pass (POIs, wayshrines, forward camps, kill
-- locations, location pins, custom pins, map-size relayout). Running those on
-- every minimap map change would hitch the frame, so we spread the work across
-- frames with coroutines under a per-frame time budget.
--
-- This is intentionally NOT a general LibAsync clone: it is scoped to the
-- minimap and exposes only the operations the pin tweaks need, with our own
-- descriptive naming.
-- -----------------------------------------------------------------------------

local EVENT_MANAGER = GetEventManager()
local GetGameTimeMilliseconds = GetGameTimeMilliseconds

--- Cooperative per-frame time budget. A heavy iteration yields once this is
--- exceeded and resumes on a later frame so it never blocks rendering.
local FRAME_BUDGET_MILLISECONDS = 4

local TASK_STATE_IDLE = "idle"
local TASK_STATE_RUNNING = "running"
local TASK_STATE_SUSPENDED = "suspended"
local TASK_STATE_DONE = "done"

-- Reasons passed through coroutine.yield so the scheduler knows how to reschedule.
local YIELD_BUDGET = "budget" -- cooperative: may resume again this frame if budget remains.
local YIELD_WAIT = "wait"     -- waiting on time or a predicate: resume no earlier than next frame.

-- -----------------------------------------------------------------------------
-- Task
-- -----------------------------------------------------------------------------

--- A single unit of deferred work. Operations are queued with the builder
--- methods below and run in order inside one coroutine. Builder calls are
--- chainable and (re)activate the task automatically.
--- @class MiniMapAsyncTask
--- @field scheduler MiniMapAsyncScheduler
--- @field taskName string
--- @field operations function[]
--- @field operationIndex integer
--- @field state string
--- @field coroutine thread|nil
--- @field resumeAtMilliseconds integer
--- @field onCompleteCallback fun(task: MiniMapAsyncTask)|nil
--- @field onErrorCallback fun(task: MiniMapAsyncTask, errorMessage: string)|nil
local MiniMapAsyncTask = ZO_Object:Subclass()

--- @param scheduler MiniMapAsyncScheduler
--- @param taskName string
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:New(scheduler, taskName)
    local task = ZO_Object.New(self)
    task:Initialize(scheduler, taskName)
    return task
end

--- @param scheduler MiniMapAsyncScheduler
--- @param taskName string
function MiniMapAsyncTask:Initialize(scheduler, taskName)
    self.scheduler = scheduler
    self.taskName = taskName
    self.operations = {}
    self.operationIndex = 0
    self.state = TASK_STATE_IDLE
    self.coroutine = nil
    self.resumeAtMilliseconds = 0
    self.onCompleteCallback = nil
    self.onErrorCallback = nil
end

--- Coroutine body: run every queued operation in order. New operations appended
--- while running (or after a Cancel/rebuild) are picked up by this loop.
function MiniMapAsyncTask:RunOperations()
    while self.operationIndex < #self.operations do
        self.operationIndex = self.operationIndex + 1
        local operation = self.operations[self.operationIndex]
        operation(self)
    end
end

--- @param operation fun(task: MiniMapAsyncTask)
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:AddOperation(operation)
    self.operations[#self.operations + 1] = operation
    if self.state ~= TASK_STATE_RUNNING then
        self:Activate()
    end
    return self
end

--- Build (or rebuild) the coroutine and hand the task to the scheduler.
function MiniMapAsyncTask:Activate()
    if not self.coroutine or coroutine.status(self.coroutine) == "dead" then
        self.coroutine = coroutine.create(function ()
            self:RunOperations()
        end)
    end
    self.state = TASK_STATE_RUNNING
    self.scheduler:AddActiveTask(self)
end

--- Queue an immediate step.
--- @param stepFunction fun(task: MiniMapAsyncTask)
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:QueueStep(stepFunction)
    return self:AddOperation(function (task)
        stepFunction(task)
    end)
end

--- Queue a step that runs after a delay (in milliseconds).
--- @param delayMilliseconds integer
--- @param stepFunction fun(task: MiniMapAsyncTask)
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:QueueDelayedStep(delayMilliseconds, stepFunction)
    return self:AddOperation(function (task)
        task.resumeAtMilliseconds = GetGameTimeMilliseconds() + delayMilliseconds
        while GetGameTimeMilliseconds() < task.resumeAtMilliseconds do
            coroutine.yield(YIELD_WAIT)
        end
        task.resumeAtMilliseconds = 0
        stepFunction(task)
    end)
end

--- Block the task until a predicate returns true.
--- @param predicateFunction fun(task: MiniMapAsyncTask):boolean
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:WaitUntil(predicateFunction)
    return self:AddOperation(function (task)
        while not predicateFunction(task) do
            coroutine.yield(YIELD_WAIT)
        end
    end)
end

--- Iterate an inclusive numeric range, yielding across frames when the budget runs out.
--- @param startIndex integer
--- @param stopIndex integer
--- @param elementFunction fun(index: integer, task: MiniMapAsyncTask)
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:IterateRange(startIndex, stopIndex, elementFunction)
    return self:AddOperation(function (task)
        for index = startIndex, stopIndex do
            elementFunction(index, task)
            if not task.scheduler:HasFrameBudget() then
                coroutine.yield(YIELD_BUDGET)
            end
        end
    end)
end

--- Iterate a table with pairs(), yielding across frames when the budget runs out.
--- @param targetTable table
--- @param elementFunction fun(key: any, value: any, task: MiniMapAsyncTask)
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:IterateTable(targetTable, elementFunction)
    return self:AddOperation(function (task)
        for key, value in pairs(targetTable) do
            elementFunction(key, value, task)
            if not task.scheduler:HasFrameBudget() then
                coroutine.yield(YIELD_BUDGET)
            end
        end
    end)
end

--- @param callback fun(task: MiniMapAsyncTask)
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:OnComplete(callback)
    self.onCompleteCallback = callback
    return self
end

--- @param callback fun(task: MiniMapAsyncTask, errorMessage: string)
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:OnError(callback)
    self.onErrorCallback = callback
    return self
end

--- Stop the task and discard all queued operations. The same task object can be
--- rebuilt afterwards by chaining new builder calls.
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:Cancel()
    self.scheduler:RemoveActiveTask(self)
    self.operations = {}
    self.operationIndex = 0
    self.coroutine = nil
    self.resumeAtMilliseconds = 0
    self.state = TASK_STATE_IDLE
    return self
end

--- Skip any pending delayed-step wait so it resumes immediately.
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:StopTimer()
    self.resumeAtMilliseconds = 0
    return self
end

--- Temporarily stop scheduling this task without discarding its work.
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:Suspend()
    if self.state == TASK_STATE_RUNNING then
        self.state = TASK_STATE_SUSPENDED
        self.scheduler:RemoveActiveTask(self)
    end
    return self
end

--- Resume a suspended task.
--- @return MiniMapAsyncTask
function MiniMapAsyncTask:Resume()
    if self.state == TASK_STATE_SUSPENDED then
        self.state = TASK_STATE_RUNNING
        self.scheduler:AddActiveTask(self)
    end
    return self
end

--- @return boolean
function MiniMapAsyncTask:IsRunning()
    return self.state == TASK_STATE_RUNNING
end

-- -----------------------------------------------------------------------------
-- Scheduler
-- -----------------------------------------------------------------------------

--- Owns the single RegisterForUpdate pump and advances every active task under a
--- shared per-frame time budget. The pump is registered when the first task
--- becomes active and unregistered when the last task finishes, so it costs
--- nothing while idle.
--- @class MiniMapAsyncScheduler
--- @field updateName string
--- @field activeTasks MiniMapAsyncTask[]
--- @field isPumpRegistered boolean
--- @field frameDeadlineMilliseconds integer
local MiniMapAsyncScheduler = ZO_Object:Subclass()

--- @param updateName string
--- @return MiniMapAsyncScheduler
function MiniMapAsyncScheduler:New(updateName)
    local scheduler = ZO_Object.New(self)
    scheduler:Initialize(updateName)
    return scheduler
end

--- @param updateName string
function MiniMapAsyncScheduler:Initialize(updateName)
    self.updateName = updateName
    self.activeTasks = {}
    self.isPumpRegistered = false
    self.frameDeadlineMilliseconds = 0
end

--- @param taskName string
--- @return MiniMapAsyncTask
function MiniMapAsyncScheduler:CreateTask(taskName)
    return MiniMapAsyncTask:New(self, taskName)
end

--- @return boolean
function MiniMapAsyncScheduler:HasFrameBudget()
    return GetGameTimeMilliseconds() < self.frameDeadlineMilliseconds
end

--- @param task MiniMapAsyncTask
function MiniMapAsyncScheduler:AddActiveTask(task)
    for index = 1, #self.activeTasks do
        if self.activeTasks[index] == task then
            return
        end
    end
    self.activeTasks[#self.activeTasks + 1] = task
    self:RegisterPump()
end

--- @param task MiniMapAsyncTask
function MiniMapAsyncScheduler:RemoveActiveTask(task)
    for index = 1, #self.activeTasks do
        if self.activeTasks[index] == task then
            table.remove(self.activeTasks, index)
            break
        end
    end
    if #self.activeTasks == 0 then
        self:UnregisterPump()
    end
end

function MiniMapAsyncScheduler:RegisterPump()
    if self.isPumpRegistered then
        return
    end
    self.isPumpRegistered = true
    EVENT_MANAGER:RegisterForUpdate(self.updateName, 0, function ()
        self:OnUpdate()
    end)
end

function MiniMapAsyncScheduler:UnregisterPump()
    if not self.isPumpRegistered then
        return
    end
    self.isPumpRegistered = false
    EVENT_MANAGER:UnregisterForUpdate(self.updateName)
end

function MiniMapAsyncScheduler:OnUpdate()
    self.frameDeadlineMilliseconds = GetGameTimeMilliseconds() + FRAME_BUDGET_MILLISECONDS

    -- Snapshot because a task may cancel itself or others while advancing.
    local tasksThisFrame = {}
    for index = 1, #self.activeTasks do
        tasksThisFrame[index] = self.activeTasks[index]
    end

    for index = 1, #tasksThisFrame do
        local task = tasksThisFrame[index]
        if task.state == TASK_STATE_RUNNING then
            self:AdvanceTask(task)
        end
    end
end

--- @param task MiniMapAsyncTask
function MiniMapAsyncScheduler:AdvanceTask(task)
    local taskCoroutine = task.coroutine
    if not taskCoroutine then
        self:RemoveActiveTask(task)
        return
    end

    while true do
        if coroutine.status(taskCoroutine) == "dead" then
            self:CompleteTask(task)
            return
        end

        local resumeSucceeded, yieldReasonOrError = coroutine.resume(taskCoroutine)
        if not resumeSucceeded then
            self:FailTask(task, yieldReasonOrError)
            return
        end

        if coroutine.status(taskCoroutine) == "dead" then
            self:CompleteTask(task)
            return
        end

        -- Only a cooperative budget yield is allowed to resume again this frame.
        if yieldReasonOrError ~= YIELD_BUDGET or not self:HasFrameBudget() then
            return
        end
    end
end

--- @param task MiniMapAsyncTask
function MiniMapAsyncScheduler:CompleteTask(task)
    task.state = TASK_STATE_DONE
    self:RemoveActiveTask(task)
    if task.onCompleteCallback then
        task.onCompleteCallback(task)
    end
end

--- @param task MiniMapAsyncTask
--- @param errorMessage string
function MiniMapAsyncScheduler:FailTask(task, errorMessage)
    task.state = TASK_STATE_DONE
    self:RemoveActiveTask(task)
    if task.onErrorCallback then
        task.onErrorCallback(task, errorMessage)
    end
end

-- -----------------------------------------------------------------------------

--- Shared minimap scheduler instance.
--- @type MiniMapAsyncScheduler
MiniMap.async = MiniMapAsyncScheduler:New(MiniMap.moduleName .. "_Async")
