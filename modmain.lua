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
local STRINGS = GLOBAL.STRINGS
local GetModConfigData = GLOBAL.GetModConfigData
local math = GLOBAL.math

local function GetHungerCost()
    return GetModConfigData("Teleport_Hunger_Cost") or 0.5
end
local function GetSanityCost()
    return GetModConfigData("Teleport_Sanity_Cost") or 0.5
end
local function OnlySelfSkeleton()
    return GetModConfigData("OnlySelfSkeleton")
end
local function BlockRuinsSkeleton()
    return GetModConfigData("BlockRuinsSkeleton")
end

local function ApplyTeleportCost(user)
    local hunger = GetHungerCost()
    if hunger > 0 and user.components.hunger then
        user.components.hunger:DoDelta(-hunger)
    end
    local sanity = GetSanityCost()
    if sanity > 0 and user.components.sanity then
        user.components.sanity:DoDelta(-sanity)
    end
end

local function GetTip(key, default_text)
    if not STRINGS or not STRINGS.BONE then
        return default_text
    end
    return STRINGS.BONE[key] or default_text
end

GLOBAL.AddAction("USE_WANGSHENG", "使用往生骨片", function(act)
    if not TheWorld.ismastersim then
        return true
    end
    local user = act.doer
    local bone = act.invobject

    if not bone or not bone.death_x or not bone.death_z then
        local tip = GetTip("NO_POS", "这块骨片没有记录死亡地点。")
        if user.components.talker then user.components.talker:Say(tip) end
        return false
    end

    if OnlySelfSkeleton() and bone.owner_userid ~= user.userid then
        local tip = GetTip("NOT_YOUR", "这不是你的骨片。")
        user.components.talker:Say(tip)
        return false
    end

    ApplyTeleportCost(user)
    local x, z = bone.death_x, bone.death_z
    local offset = FindWalkableOffset(Vector3(x, 0, z), math.random() * math.pi * 2, 10, 12, false, true)
    if offset then
        x = x + offset.x
        z = z + offset.z
    end

    if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        local tip = GetTip("OCEAN_FAIL", "目标地是海洋，无法传送。")
        user.components.talker:Say(tip)
        return false
    end

    user.Transform:SetPosition(x, 0, z)
    bone:Remove() 
    local tip = GetTip("TELE_SUCC", "传送成功。")
    user.components.talker:Say(tip)
    return true
end)

GLOBAL.AddAction("USE_BENFU", "使用奔赴羁绊骨片", function(act)
    if not TheWorld.ismastersim then
        return true
    end
    local user = act.doer
    local bone = act.invobject

    if not bone or not bone.owner_userid then
        local tip = GetTip("NO_BIND", "这块骨片没有绑定任何人。")
        user.components.talker:Say(tip)
        return false
    end

    local target = nil
    for _, p in ipairs(AllPlayers) do
        if p.userid == bone.owner_userid then
            target = p
            break
        end
    end

    local bone_name = bone.player_name or "未知玩家"
    if not target then
        local tip = GetTip("OFFLINE", " 不在线。")
        user.components.talker:Say(bone_name .. tip)
        return false
    end
    if target:HasTag("ghost") then
        local tip = GetTip("GHOST", " 是鬼魂。")
        user.components.talker:Say(bone_name .. tip)
        return false
    end

    local x, y, z = target.Transform:GetWorldPosition()
    local offset = FindWalkableOffset(Vector3(x, 0, z), math.random() * math.pi * 2, 10, 12, false, true)
    if offset then
        x = x + offset.x
        z = z + offset.z
    end

    if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        local tip = GetTip("OCEAN_BIND", "目标在海洋，无法传送。")
        user.components.talker:Say(tip)
        return false
    end

    user.Transform:SetPosition(x, 0, z)
    local tip = GetTip("BIND_SUCC", "奔赴成功。")
    user.components.talker:Say(tip)
    return true
end)

local function HasFullSpace(plr)
    local inv = plr.components.inventory
    for i = 1, 4 do
        if not inv:GetItemInSlot(i) then
            return true
        end
    end
    return inv:NumItems() < inv.maxslots
end

local function SafeGiveBone(plr, bone)
    local inv = plr.components.inventory
    for i = 1, 4 do
        if not inv:GetItemInSlot(i) then
            inv:SetItemInSlot(i, bone)
            return
        end
    end
    inv:GiveItem(bone)
end

GLOBAL.AddAction("BIND_BENFU", "与对方建立羁绊", function(act)
    if not TheWorld.ismastersim then
        return true
    end
    local target = act.target
    local doer = act.doer

    if not target or target == doer then
        return false
    end
    if not HasFullSpace(doer) or not HasFullSpace(target) then
        local tip = GetTip("BAG_FULL", "背包已满！")
        doer.components.talker:Say(tip)
        return false
    end

    local nameA = doer:GetDisplayName()
    local nameB = target:GetDisplayName()
    local boneA = SpawnPrefab("benfu_bone")
    local boneB = SpawnPrefab("benfu_bone")

    if boneA then
        boneA.owner_userid = target.userid
        boneA.player_name = nameB
    end
    if boneB then
        boneB.owner_userid = doer.userid
        boneB.player_name = nameA
    end

    SafeGiveBone(doer, boneA)
    SafeGiveBone(target, boneB)

    local create_tip = GetTip("BIND_CREATE", "你和%s建立了羁绊。")
    local you_tip = GetTip("BIND_YOU", "%s和你建立了羁绊。")
    doer.components.talker:Say(string.format(create_tip, nameB))
    target.components.talker:Say(string.format(you_tip, nameA))
    return true
end)

GLOBAL.AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_WANGSHENG, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_BENFU, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BIND_BENFU, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_WANGSHENG, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_BENFU, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BIND_BENFU))

GLOBAL.AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
    if right then
        if inst.prefab == "wangsheng_bone" then
            table.insert(actions, GLOBAL.ACTIONS.USE_WANGSHENG)
        elseif inst.prefab == "benfu_bone" then
            table.insert(actions, GLOBAL.ACTIONS.USE_BENFU)
        end
    end
end)

GLOBAL.AddComponentAction("PLAYER", "playercontroller", function(inst, doer, actions, right)
    if right and inst ~= doer then
        table.insert(actions, GLOBAL.ACTIONS.BIND_BENFU)
    end
end)

if TheWorld.ismastersim then
    GLOBAL.AddPlayerPostInit(function(inst)
        local task_handle = nil
        local function OnGhost()
            task_handle = inst:DoTaskInTime(0.5, function()
                local px, py, pz = inst.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(px, py, 3, {"skeleton"}, {"skeleton_ruins"})
                local nearest = nil
                local min_dist = math.huge
                for _, e in ipairs(ents) do
                    if e.prefab == "skeleton" and not e.owner_userid then
                        local dx, dz = e.Transform:GetWorldXZ()
                        local dist = (dx - px) * (dx - px) + (dz - pz) * (dz - pz)
                        if dist < min_dist then
                            min_dist = dist
                            nearest = e
                        end
                    end
                end
                if nearest then
                    nearest.owner_userid = inst.userid
                    nearest.player_name = inst:GetDisplayName()
                end
                task_handle = nil
            end)
        end
        inst:ListenForEvent("entityremove", function()
            if task_handle then
                inst:CancelTask(task_handle)
                task_handle = nil
            end
        end)
        inst:ListenForEvent("ms_becameghost", OnGhost)
    end)

    local function SpawnBones(inst)
        if inst._bones_spawned then
            return
        end
        if BlockRuinsSkeleton() and inst:HasTag("skeleton_ruins") then
            return
        end
        if not inst.owner_userid then
            return
        end
        inst._bones_spawned = true
        local x, y, z = inst.Transform:GetWorldPosition()
        local uid = inst.owner_userid
        local name = inst.player_name or "旅人"

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
    end

    GLOBAL.AddPrefabPostInit("skeleton", function(inst)
        inst:ListenForEvent("workfinished", SpawnBones)
        inst:ListenForEvent("entityremove", function()
            inst:RemoveEventCallback("workfinished", SpawnBones)
        end)
    end)
    GLOBAL.AddPrefabPostInit("shallowgrave", function(inst)
        inst:ListenForEvent("workfinished", SpawnBones)
        inst:ListenForEvent("entityremove", function()
            inst:RemoveEventCallback("workfinished", SpawnBones)
        end)
    end)
end