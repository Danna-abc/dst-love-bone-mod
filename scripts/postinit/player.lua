local GLOBAL = GLOBAL
local AddPlayerPostInit = GLOBAL.AddPlayerPostInit
local DeathManager = modimport("scripts/manager/deathmanager.lua")

AddPlayerPostInit(function(inst)
    inst:ListenForEvent("ms_playerdied", function()
        inst:DoTaskInTime(1.0, function()
            if not inst:IsValid() then return end
            local px, py, pz = inst.Transform:GetWorldPosition()
            local ents = GLOBAL.TheSim:FindEntities(px, py, pz, 4, {"skeleton"}, {"skeleton_ruins"})
            local nearest = nil
            local min_dist = GLOBAL.math.huge
            for _, e in ipairs(ents) do
                if e.prefab == "skeleton" and not e.owner_userid then
                    local dx, dz = e.Transform:GetWorldXZ()
                    local dist = (dx - px)*(dx - px) + (dz - pz)*(dz - pz)
                    if dist < min_dist then
                        min_dist = dist
                        nearest = e
                    end
                end
            end
            if nearest then
                DeathManager.MarkSkeleton(inst, nearest)
            end
        end)
    end)
end)