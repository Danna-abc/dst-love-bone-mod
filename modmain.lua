local GLOBAL = _G
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local FindWalkableOffset = GLOBAL.FindWalkableOffset
local AllPlayers = GLOBAL.AllPlayers
local TheWorld = GLOBAL.TheWorld
local TheSim = GLOBAL.TheSim
local SpawnPrefab = GLOBAL.SpawnPrefab
local PI = GLOBAL.PI
local math = GLOBAL.math
local Action = GLOBAL.Action

local ACT_WANGSHENG = Action({}, 12, false, true)
ACT_WANGSHENG.id = "USE_WANGSHENG"
ACT_WANGSHENG.str = "Use Wangsheng Bone"
ACT_WANGSHENG.fn = function(act)
    if not TheWorld.ismastersim then return true end

    local user = act.doer
    local bone = act.invobject
    if not bone or not bone.death_x or not bone.death_z then
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
            user.components.talker:Say("Landing point is at ocean, teleport failed")
        end
        return false
    end

    user.Transform:SetPosition(x, 0, z)
    bone:Remove()
    return true
end
GLOBAL.AddAction(ACT_WANGSHENG)

local ACT_BENFU = Action({}, 12, false, true)
ACT_BENFU.id = "USE_BENFU"
ACT_BENFU.str = "Use Benfu Bone"
ACT_BENFU.fn = function(act)
    if not TheWorld.ismastersim then return true end

    local user = act.doer
    local bone = act.invobject
    if not bone or not bone.owner_userid then
        return false
    end

    local target = nil
    for _, player in ipairs(AllPlayers) do
        if player.userid == bone.owner_userid then
            target = player
            break
        end
    end
    if not target then
        if user.components.talker then
            user.components.talker:Say("Target player is offline")
        end
        return false
    end

    local x, z = target.Transform:GetWorldXZ()
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
            user.components.talker:Say("Landing point is at ocean, teleport failed")
        end
        return false
    end

    user.Transform:SetPosition(x, 0, z)
    return true
end
GLOBAL.AddAction(ACT_BENFU)

local function HookStateGraph(sg)
    sg:AddActionHandler(ACT_WANGSHENG, "doshortaction")
    sg:AddActionHandler(ACT_BENFU, "doshortaction")
end
GLOBAL.AddStategraphPostInit("wilson", HookStateGraph)
GLOBAL.AddStategraphPostInit("wilson_client", HookStateGraph)

AddPlayerPostInit(function(inst)
    local function OnBecameGhost()
        if not TheWorld.ismastersim then return end
        inst:DoTaskInTime(0.2, function()
            local px, py, pz = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(px, py, pz, 30, {"skeleton"})
            local nearest = nil
            local min_dist = math.huge
            for _, ent in ipairs(ents) do
                if ent.prefab == "skeleton" and not ent.owner_userid then
                    local dx, dz = ent.Transform:GetWorldXZ()
                    local dist_sq = (dx - px)*(dx - px) + (dz - pz)*(dz - pz)
                    if dist_sq < min_dist then
                        min_dist = dist_sq
                        nearest = ent
                    end
                end
            end
            if nearest then
                nearest.owner_userid = inst.userid
                nearest.player_name = inst:GetDisplayName()
            end
        end)
    end
    inst:ListenForEvent("ms_becameghost", OnBecameGhost)
end)

AddPrefabPostInit("skeleton", function(inst)
    if not TheWorld.ismastersim then return end
    inst:ListenForEvent("workfinished", function()
        if not inst.owner_userid or inst:HasTag("skeleton_ruins") then
            return
        end
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

AddPrefabPostInit("wangsheng_bone", function(inst)
    inst:DoTaskInTime(0, function()
        if inst.components.inventoryitem then
            inst.components.inventoryitem:AddAction(ACT_WANGSHENG)
        end
    end)
end)
AddPrefabPostInit("benfu_bone", function(inst)
    inst:DoTaskInTime(0, function()
        if inst.components.inventoryitem then
            inst.components.inventoryitem:AddAction(ACT_BENFU)
        end
    end)
end)

local function SafeRegisterPrefab(name, path)
    local ok, prefab_data = pcall(require, path)
    if ok then
        RegisterPrefab(name, prefab_data)
    else
        print("[love_bone_mod ERROR] Missing prefab file: " .. path)
    end
end
SafeRegisterPrefab("wangsheng_bone", "scripts/prefabs/wangsheng_bone")
SafeRegisterPrefab("benfu_bone", "scripts/prefabs/benfu_bone")
