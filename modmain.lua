PrefabFiles = {
    "wangsheng_bone",
    "benfu_bone"
}

modimport("scripts/strings/en.lua")
if GLOBAL.LanguageTranslator and GLOBAL.LanguageTranslator.defaultlang == "zh" then
    modimport("scripts/strings/chs.lua")
end

modimport("scripts/util/language.lua")
modimport("scripts/util/config.lua")
modimport("scripts/util/common.lua")
modimport("scripts/util/teleport.lua")

modimport("scripts/actions/bone_actions.lua")

if GLOBAL.TheWorld.ismastersim then
    AddSimPostInit(function()
        modimport("scripts/postinit/player.lua")
        modimport("scripts/postinit/skeleton.lua")
        modimport("scripts/postinit/shallowgrave.lua")
    end)
end