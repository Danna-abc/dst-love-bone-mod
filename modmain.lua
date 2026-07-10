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

local TeleportHungerCost = GetModConfigData("Teleport_Hunger_Cost")
local TeleportSanityCost = GetModConfigData("Teleport_Sanity_Cost")
local OnlySelfSkeleton = GetModConfigData("OnlySelfSkeleton")
local BlockRuinsSkeleton = GetModConfigData("BlockRuinsSkeleton")

local function ApplyTeleportCost(user)
    if user.components.hunger and TeleportHungerCost > 0 then
        user.components.hunger:DoDelta(-TeleportHungerCost)
    end
    if user.components.sanity and TeleportSanityCost > 0 then
        user.components.sanity:DoDelta(-TeleportSanityCost)
    end
end

AddAction("USE_WANGSHENG", "使用往生骨片", function(act)
    if not TheWorld.ismastersim then return true end
    local user = act.doer
    local bone = act.invobject
    if not bone or not bone.death_x then
        if user.components.talker then
            user.components.talker:Say("This bone has no death coordinate record")
        end
        return false
    end
    ApplyTeleportCost(user)
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

AddAction("USE_BENFU", "使用奔赴骨片", function(act)
    if not TheWorld.ismastersim then return true end
    local user = act.doer
    local bone = act.invobject
    if not bone or not bone.owner_userid then
        if user.components.talker then
            user.components.talker:Say("This bond has no one bound to it")
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
            user.components.talker:Say(bone.player_name .. " is not online")
        end
        return false
    end
    if target:HasTag("ghost") then
        if user.components.talker then
            user.components.talker:Say(bone.player_name .. " is a ghost now")
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

AddAction("BIND_BENFU", "建立羁绊", function(act)
    if not TheWorld.ismastersim then return true end
    local target = act.target
    local doer = act.doer
    if not target or not doer then return false end

    local idA, nameA = doer.userid, doer:GetDisplayName()
    local idB, nameB = target.userid, target:GetDisplayName()

    local boneA = SpawnPrefab("benfu_bone")
    if boneA then
        boneA.owner_userid = idB
        boneA.player_name = nameB
    end
    local boneB = SpawnPrefab("benfu_bone")
    if boneB then
        boneB.owner_userid = idA
        boneB.player_name = nameA
    end

    if boneA then

        local given = false
        for i = 1, 4 do
            if not doer.components.inventory:GetItemInSlot(i) then
                doer.components.inventory:SetItemInSlot(i, boneA)
                given = true
                break
            end
        end
        if not given then
            doer.components.inventory:GiveItem(boneA) -- 若口袋全满则进背包（兜底）
        end
    end
    if boneB then
        local given = false
        for i = 1, 4 do
            if not target.components.inventory:GetItemInSlot(i) then
                target.components.inventory:SetItemInSlot(i, boneB)
                given = true
                break
            end
        end
        if not given then
            target.components.inventory:GiveItem(boneB)
        end
    end

    if doer.components.talker then
        doer.components.talker:Say("You forged a bond with " .. nameB)
    end
    if target.components.talker then
        target.components.talker:Say(nameA .. " formed a bond with you")
    end
    return true
end)

GLOBAL.AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_WANGSHENG, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_BENFU, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BIND_BENFU, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_WANGSHENG, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.USE_BENFU, "doshortaction"))
GLOBAL.AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.BIND_BENFU, "doshortaction"))

AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
    if not right then return end
    if inst.prefab == "wangsheng_bone" then
        table.insert(actions, GLOBAL.ACTIONS.USE_WANGSHENG)
    elseif inst.prefab == "benfu_bone" then
        table.insert(actions, GLOBAL.ACTIONS.USE_BENFU)
    end
end)

AddComponentAction("PLAYER", "playercontroller", function(inst, doer, actions, right)
    if not right or inst == doer then return end
    local hasEmptySlot = false
    for i = 1, 4 do
        if not doer.components.inventory:GetItemInSlot(i) then
            hasEmptySlot = true
            break
        end
    end
    if hasEmptySlot then
        table.insert(actions, GLOBAL.ACTIONS.BIND_BENFU)
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
                        if OnlySelfSkeleton then

                            local dx, dz = e.Transform:GetWorldXZ()
                            local dist_sq = (dx - px)*(dx - px) + (dz - pz)*(dz - pz)
                            if dist_sq < min_dist then
                                min_dist = dist_sq
                                nearest = e
                            end
                        else
                            local dx, dz = e.Transform:GetWorldXZ()
                            local dist_sq = (dx - px)*(dx - px) + (dz - pz)*(dz - pz)
                            if dist_sq < min_dist then
                                min_dist = dist_sq
                                nearest = e
                            end
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
            if BlockRuinsSkeleton and inst:HasTag("skeleton_ruins") then return end
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

    GLOBAL.AddPrefabPostInit("shallowgrave", function(inst)
        inst:ListenForEvent("workfinished", function()
            if not inst.owner_userid then return end
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