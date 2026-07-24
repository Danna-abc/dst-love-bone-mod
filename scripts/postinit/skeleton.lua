local GLOBAL = GLOBAL
local AddPrefabPostInit = GLOBAL.AddPrefabPostInit
local DeathManager = modimport("scripts/manager/deathmanager.lua")

AddPrefabPostInit("skeleton", function(inst)
    inst:ListenForEvent("entityremove", function()
        DeathManager.SpawnBones(inst)
    end)
end)