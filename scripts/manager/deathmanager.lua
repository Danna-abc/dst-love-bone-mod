local GLOBAL = GLOBAL
local Config = modimport("scripts/util/config.lua")
local Teleport = modimport("scripts/util/teleport.lua")

local DeathManager = {}

function DeathManager.MarkSkeleton(player, skeleton)
    if skeleton:IsValid() and not skeleton.owner_userid then
        skeleton.owner_userid = player.userid
        skeleton.player_name = player:GetDisplayName()
    end
end

function DeathManager.SpawnBones(inst)
    if inst._bones_spawned then return end
    if Config.BlockRuinsSkeleton() and inst:HasTag("skeleton_ruins") then return end
    if not inst.owner_userid then return end
    inst._bones_spawned = true

    local x, y, z = inst.Transform:GetWorldPosition()
    local uid = inst.owner_userid
    local name = inst.player_name or "旅人"

    local bone1 = GLOBAL.SpawnPrefab("wangsheng_bone")
    if bone1 then
        bone1.Transform:SetPosition(x, y + 1, z)
        bone1:SetDeathPos(x, z)
        bone1:SetPlayerName(name)
        bone1:SetOwner(uid)
        if bone1.Physics then
            local speed = 2 + GLOBAL.math.random() * 2
            local angle = GLOBAL.math.random() * GLOBAL.math.pi * 2
            bone1.Physics:SetVel(GLOBAL.math.cos(angle) * speed, 8, GLOBAL.math.sin(angle) * speed)
        end
    end

    if GLOBAL.math.random() <= 0.52 then
        local bone2 = GLOBAL.SpawnPrefab("benfu_bone")
        if bone2 then
            bone2.Transform:SetPosition(x, y + 1, z)
            if bone2.Physics then
                local speed = 2 + GLOBAL.math.random() * 2
                local angle = GLOBAL.math.random() * GLOBAL.math.pi * 2
                bone2.Physics:SetVel(GLOBAL.math.cos(angle) * speed, 8, GLOBAL.math.sin(angle) * speed)
            end
        end
    end
end

return DeathManager