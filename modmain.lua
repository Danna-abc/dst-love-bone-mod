PrefabFiles = {
    "wangsheng_bone",
    "benfu_bone"
}

modimport("scripts/strings/en.lua")
if GLOBAL.LanguageTranslator and GLOBAL.LanguageTranslator.defaultlang == "zh" then
    modimport("scripts/strings/chs.lua")
end

modimport("scripts/actions/bone_actions.lua")

modimport("scripts/postinit/player.lua")
modimport("scripts/postinit/skeleton.lua")
modimport("scripts/postinit/shallowgrave.lua")