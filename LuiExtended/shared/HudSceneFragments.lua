-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- HUD gameplay scenes for LUIE chrome (ZOS HUD_FRAGMENT_GROUP + siege + loot).
--- @class LUIE.HudScene
--- @field IsHudGameplayScene fun(scene: ZO_Scene|nil): boolean
--- @field GetGameplayScenes fun(): ZO_Scene[]
--- @field GetGameplayScenesExcludingLoot fun(): ZO_Scene[]
--- @field AddFragmentToScenes fun(fragment: ZO_SceneFragment, scenes: ZO_Scene[])
--- @field RemoveFragmentFromScenes fun(fragment: ZO_SceneFragment, scenes: ZO_Scene[])
--- @field RegisterHudFadeFragmentOnGameplayScenes fun(topLevelControl: Control): ZO_HUDFadeSceneFragment
local HudScene = {}

--- @type LUIE.HudScene
LUIE.HudScene = HudScene

--- @type ZO_Scene[]|nil Built on first GetGameplayScenes() (after ZOS scene globals exist).
HudScene.GAMEPLAY_SCENES = nil

HudScene.GAMEPLAY_SCENES =
{
    HUD_SCENE,
    HUD_UI_SCENE,
    LOOT_SCENE,
    SIEGE_BAR_SCENE,
    SIEGE_BAR_UI_SCENE,
}

--- @return ZO_Scene[]
function HudScene.GetGameplayScenes()
    if HudScene.GAMEPLAY_SCENES then
        return HudScene.GAMEPLAY_SCENES
    end
    local customFramesShared = LUIE.CustomFramesShared
    if customFramesShared then
        customFramesShared.CUSTOM_FRAME_HUD_SCENES = HudScene.GAMEPLAY_SCENES
    end
    return HudScene.GAMEPLAY_SCENES
end

--- @param scene ZO_Scene|nil
--- @return boolean
function HudScene.IsHudGameplayScene(scene)
    if not scene then
        return false
    end
    local gameplayScenes = HudScene.GetGameplayScenes()
    for sceneIndex = 1, #gameplayScenes do
        if gameplayScenes[sceneIndex] == scene then
            return true
        end
    end
    return false
end

--- @return ZO_Scene[]
function HudScene.GetGameplayScenesExcludingLoot()
    local scenes = {}
    local gameplayScenes = HudScene.GetGameplayScenes()
    for sceneIndex = 1, #gameplayScenes do
        local scene = gameplayScenes[sceneIndex]
        if scene ~= LOOT_SCENE then
            scenes[#scenes + 1] = scene
        end
    end
    return scenes
end

--- @param fragment ZO_SceneFragment
--- @param scenes ZO_Scene[]
function HudScene.AddFragmentToScenes(fragment, scenes)
    if not fragment then
        return
    end
    for sceneIndex = 1, #scenes do
        local scene = scenes[sceneIndex]
        if not scene:HasFragment(fragment) then
            scene:AddFragment(fragment)
        end
    end
end

--- @param fragment ZO_SceneFragment
--- @param scenes ZO_Scene[]
function HudScene.RemoveFragmentFromScenes(fragment, scenes)
    if not fragment then
        return
    end
    for sceneIndex = 1, #scenes do
        local scene = scenes[sceneIndex]
        if scene:HasFragment(fragment) then
            scene:RemoveFragment(fragment)
        end
    end
end

--- @param topLevelControl Control
--- @return ZO_HUDFadeSceneFragment|ZO_SceneFragment|nil
function HudScene.RegisterHudFadeFragmentOnGameplayScenes(topLevelControl)
    local fragment = ZO_HUDFadeSceneFragment:New(topLevelControl, 0, 0)
    HudScene.AddFragmentToScenes(fragment, HudScene.GetGameplayScenes())
    topLevelControl.hudSceneFragment = fragment
    return fragment
end
