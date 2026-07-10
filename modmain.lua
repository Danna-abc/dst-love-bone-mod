PrefabFiles = {
    "wangsheng_bone",
    "benfu_bone"
}

local GLOBAL = GLOBAL
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local FindWalkableOffset = GLOBAL.FindWalkableOffset
local AllPlayers = GLOBAL.AllPlayers
local TheWorld = GLOBAL.TheWorld
local TheSim = GLOBAL.TheSim
local SpawnPrefab = GLOBAL.SpawnPrefab
local PI = GLOBAL.PI
local math = GLOBAL.math

GLOBAL.AddAction("USE_WANGSHENG_BONE", "Use Wangsheng Bone", function(act)
    if not TheWorld.ismastersim then return true end
    local user = act.doer
    local bone = act.invobject

    if not bone or not bone.death_x then
        if user.components.talker then
            user.components.talker:Say("This bone has no death coordinate record")
        end
        return false
    end

    local x, z = bone.death_x, bone.death_z
    if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        if user.components.talker then
            user.components.talker:Say("Target is at ocean, cannot teleport")
        end
        return false
    end

    local offset = FindWalkableOffset(Vector3(x,0,z), math.random()*PI*2, 10, 12, false, true)
    if offset then
        x = x + offset.x
        z = z + offset.z
    end

    if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        if user.components.talker then
            user.components.talker:Say("Landing point is ocean, teleport failed")
        end
        return false
    end

    user.Transform:SetPosition(x, 0, z)
    bone:Remove()
    return true
end)

GLOBAL.AddAction("USE_BENFU_BONE", "Use Benfu Bone", function(act)
    if not TheWorld.ismastersim then return true end
    local user = act.doer
    local bone = act.invobject

    if not bone or not bone.owner_userid then
        if user.components.talker then
            user.components.talker:Say("No bound player on this bone")
        end
        return false
    end

    local target = nil
    for _, p in ipairs(AllPlayers) do
        if p.userid == bone.owner_userid then
            target = p
            break
        end
    end

    if not target then
        if user.components.talker then
            user.components.talker:Say("Target player offline")
        end
        return false
    end

    local x, y, z = target.Transform:GetWorldPosition()
    if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        if user.components.talker then
            user.components.talker:Say("Target is ocean, cannot teleport")
        end
        return false
    end

    local offset = FindWalkableOffset(Vector3(x,0,z), math.random()*PI*2, 10, 12, false, true)
    if offset then
        x = x + offset.x
        z = z + offset.z
    end

    if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        if user.components.talker then
            user.components.talker:Say("Landing point ocean, failed")
        end
        return false
    end

    user.Transform:SetPosition(x, 0, z)
    return true
end)

GLOBAL.AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_WANGSHENG_BONE, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_BENFU_BONE, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_WANGSHENG_BONE, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_BENFU_BONE, "doshortaction"))

GLOBAL.AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
    if not right then return end
    if inst.prefab == "wangsheng_bone" then
        table.insert(actions, GLOBAL.ACTIONS.USE_WANGSHENG_BONE)
    elseif inst.prefab == "benfu_bone" then
        table.insert(actions, GLOBAL.ACTIONS.USE_BENFU_BONE)
    end
end)

if TheWorld.ismastersim then
    GLOBAL.AddPlayerPostInit(function(inst)
        local function OnGhost()
            inst:DoTaskInTime(0.5, function()
                local px, py, pz = inst.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(px, py, pz, 3, {"skeleton"}, {"skeleton_ruins"})
                local nearest = nil
                local min_dist = math.huge
                for _, e in ipairs(ents) do
                    if e.prefab == "skeleton" and not e.owner_userid then
                        local dx, dz = e.Transform:GetWorldXZ()
                        local dist_sq = (dx - px)*(dx - px) + (dz - pz)*(dz - pz)
                        if dist_sq < min_dist then
                            min_dist = dist_sq
                            nearest = e
                        end
                    end
                end
                if nearest then
                    nearest.owner_userid = inst.userid
                    nearest.player_name = inst:GetDisplayName()
                end
            end)
        end
        inst:ListenForEvent("ms_becameghost", OnGhost)
    end)

    GLOBAL.AddPrefabPostInit("skeleton", function(inst)
        inst:ListenForEvent("workfinished", function()
             if not inst.owner_userid then return end
             if inst:HasTag("skeleton_ruins") then return end
             local x, y, z = inst.Transform:GetWorldPosition()
             local uid = inst.owner_userid
             local name = inst.player_name or "Stranger"
             local bone1 = SpawnPrefab("wangsheng_bone")
             if bone1 then
                 bone1.Transform:SetPosition(x, y, z)
                 bone1.death_x = x
                 bone1.death_z = z
                 bone1.player_name = name
                 bone1.owner_userid = uid
             end
             if math.random() <= 0.52 then
                 local bone2 = SpawnPrefab("benfu_bone")
                 if bone2 then
                     bone2.Transform:SetPosition(x, y, z)
                     bone2.owner_userid = uid
                     bone2.player_name = name
                 end
             end
         end)
     end)
 end