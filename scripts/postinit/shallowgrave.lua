local GLOBAL = GLOBAL
local AddPrefabPostInit = GLOBAL.AddPrefabPostInit
local DeathManager = modimport("scripts/manager/deathmanager.lua")

AddPrefabPostInit("shallowgrave", function(inst)
    inst:ListenForEvent("workfinished", function()
        DeathManager.SpawnBones(inst)
    end)
end)