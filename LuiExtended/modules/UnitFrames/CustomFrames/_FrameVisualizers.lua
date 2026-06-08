-- -----------------------------------------------------------------------------
--  LuiExtended - Per custom-frame attribute visualizer setup (ZOS pattern)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

LUIE_CustomFrameVisualizers = LUIE_CustomFrameVisualizers or {}

local Visualizers = LUIE_CustomFrameVisualizers
--- @type UnitFrames.VisualizerModuleClasses
local ModuleClasses = UnitFrames.VisualizerModuleClasses

local function AddStandardCombatModules(visualizer)
    visualizer:AddModule(ModuleClasses.RegenerationModule:New())
    visualizer:AddModule(ModuleClasses.StatChangeModule:New())
    visualizer:AddModule(ModuleClasses.PowerShieldModule:New())
    visualizer:AddModule(ModuleClasses.UnwaveringModule:New())
    visualizer:AddModule(ModuleClasses.PossessionModule:New())
end

local function SetupFullCombatFrame(frame)
    local visualizer = frame:CreateAttributeVisualizer(nil)
    AddStandardCombatModules(visualizer)
end

function Visualizers.SetupPlayerFrame(frame)
    SetupFullCombatFrame(frame)
end

function Visualizers.SetupTargetFrame(frame)
    SetupFullCombatFrame(frame)
end

function Visualizers.SetupAvaTargetFrame(frame)
    SetupFullCombatFrame(frame)
end

function Visualizers.SetupGroupFrame(frame)
    SetupFullCombatFrame(frame)
end

function Visualizers.SetupRaidFrame(frame)
    SetupFullCombatFrame(frame)
end

function Visualizers.SetupBossFrame(frame)
    SetupFullCombatFrame(frame)
end

function Visualizers.SetupCompanionFrame(frame)
    SetupFullCombatFrame(frame)
end

function Visualizers.SetupPetFrame(frame)
    local visualizer = frame:CreateAttributeVisualizer(nil)
    visualizer:AddModule(ModuleClasses.RegenerationModule:New())
    visualizer:AddModule(ModuleClasses.PowerShieldModule:New())
end

function Visualizers.SetupControlledSiegeFrame(frame)
    local visualizer = frame:CreateAttributeVisualizer(nil)
    visualizer:AddModule(ModuleClasses.PowerShieldModule:New())
end

--- Default (non-custom) unit frames: one visualizer per game unitTag.
local function CreateDefaultUnitVisualizer(unitTag)
    if UnitFrames.defaultVisualizers[unitTag] then
        return UnitFrames.defaultVisualizers[unitTag]
    end

    local customFrame = UnitFrames.CustomFrames[unitTag]
    if customFrame and customFrame.attributeVisualizer then
        return customFrame.attributeVisualizer
    end

    local defaultFrameTable = UnitFrames.DefaultFrames[unitTag]
    if not defaultFrameTable then
        return nil
    end

    local visualizer = LUIE_UnitAttributeVisualizer:New(unitTag, nil, nil, nil, nil)
    visualizer.defaultFrameTable = defaultFrameTable
    AddStandardCombatModules(visualizer)
    UnitFrames.defaultVisualizers[unitTag] = visualizer
    UnitFrames.Visualizers[unitTag] = visualizer
    if DoesUnitExist(unitTag) then
        visualizer:OnUnitChanged()
    end
    return visualizer
end

function UnitFrames.InitializeDefaultVisualizersImpl()
    UnitFrames.defaultVisualizers = UnitFrames.defaultVisualizers or {}

    CreateDefaultUnitVisualizer("player")
    CreateDefaultUnitVisualizer("reticleover")
    CreateDefaultUnitVisualizer("companion")
    CreateDefaultUnitVisualizer("controlledsiege")

    for i = 1, 12 do
        CreateDefaultUnitVisualizer("group" .. i)
    end

    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        CreateDefaultUnitVisualizer("boss" .. i)
    end

    for i = 1, 7 do
        CreateDefaultUnitVisualizer("playerpet" .. i)
    end
end
