local GLOBAL = GLOBAL
if not GLOBAL.TheNet:GetIsServer() then return end

local AddPrefabPostInit = GLOBAL.AddPrefabPostInit
local DeathManager = require("scripts/manager/deathmanager")

AddPrefabPostInit("shallowgrave", function(inst)
    inst:ListenForEvent("workfinished", function()
        DeathManager.SpawnBones(inst)
    end)
end)