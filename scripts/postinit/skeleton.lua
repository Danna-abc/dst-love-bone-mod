local GLOBAL = GLOBAL
if not GLOBAL.TheNet:GetIsServer() then return end

local AddPrefabPostInit = GLOBAL.AddPrefabPostInit
local DeathManager = require("scripts/manager/deathmanager")

AddPrefabPostInit("skeleton", function(inst)
    inst:ListenForEvent("entityremove", function()
        DeathManager.SpawnBones(inst)
    end)
end)