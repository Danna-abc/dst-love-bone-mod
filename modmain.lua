local GLOBAL = GLOBAL
local TUNING = GLOBAL.TUNING
local TheWorld = GLOBAL.TheWorld
local TheNet = GLOBAL.TheNet

AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
    if right then
        if inst.prefab == "wangsheng_bone" then
            table.insert(actions, GLOBAL.Action(inst, doer, "USE_WANGSHENG", nil, nil, nil))
        end
        if inst.prefab == "benfu_bone" then
            table.insert(actions, GLOBAL.Action(inst, doer, "USE_BENFU", nil, nil, nil))
        end
    end
end)

AddAction("USE_WANGSHENG", function(act)
    local bone = act.invobject
    local doer = act.doer
    if not bone.death_x or not bone.death_z then
        doer.components.talker:Say("This bone bears no memory of death.")
        return false
    end
    local px,py,pz = doer.Transform:GetWorldPosition()
    local target_x = bone.death_x
    local target_z = bone.death_z
    local ground_layer = TheWorld.Map:GetTileAtPoint(px,0,pz)
    local target_layer = TheWorld.Map:GetTileAtPoint(target_x,0,target_z)
    if ground_layer ~= target_layer then
        doer.components.talker:Say("The place of death lies in another realm.")
        return false
    end
    doer.Physics:Teleport(target_x,0,target_z)
    doer.components.talker:Say("You have reached the fallen one's resting place.")
    bone:Remove()
    return true
end)

AddAction("USE_BENFU", function(act)
    local bone = act.invobject
    local doer = act.doer
    local target_id = bone.owner_userid
    if not target_id or target_id == "" then
        doer.components.talker:Say("This bond has no one bound to it.")
        return false
    end
    local target_player = nil
    for _,v in ipairs(GLOBAL.AllPlayers) do
        if v.userid == target_id then
            target_player = v
            break
        end
    end
    if not target_player then
        doer.components.talker:Say(bone.player_name.." is not online.")
        return false
    end
    if target_player:HasTag("ghost") then
        doer.components.talker:Say(bone.player_name.." is a ghost now.")
        return false
    end
    local px,py,pz = doer.Transform:GetWorldPosition()
    local tx,ty,tz = target_player.Transform:GetWorldPosition()
    local ground_layer = TheWorld.Map:GetTileAtPoint(px,0,pz)
    local target_layer = TheWorld.Map:GetTileAtPoint(tx,0,tz)
    if ground_layer ~= target_layer then
        doer.components.talker:Say(bone.player_name.." is in another realm.")
        return false
    end
    doer.Physics:Teleport(tx,ty,tz)
    doer.components.talker:Say("You rush to "..bone.player_name.."'s side.")
    return true
end)

AddPrefabPostInit("skeleton", function(inst)
    inst:ListenForEvent("entitysleep", function()
        if not inst.claimed_wangbone then
            local bone = GLOBAL.SpawnPrefab("wangsheng_bone")
            local x,y,z = inst.Transform:GetWorldPosition()
            local owner = inst.record_userid
            local name = inst.record_name
            bone.death_x = x
            bone.death_z = z
            bone.owner_userid = owner
            bone.player_name = name
            inst.components.lootdropper:FlingItem(bone)
            inst.claimed_wangbone = true
        end
    end)
end)

AddPrefabPostInit("shallowgrave", function(inst)
    inst:ListenForEvent("entitysleep", function()
        if not inst.claimed_wangbone then
            local bone = GLOBAL.SpawnPrefab("wangsheng_bone")
            local x,y,z = inst.Transform:GetWorldPosition()
            local owner = inst.record_userid
            local name = inst.record_name
            bone.death_x = x
            bone.death_z = z
            bone.owner_userid = owner
            bone.player_name = name
            inst.components.lootdropper:FlingItem(bone)
            inst.claimed_wangbone = true
        end
    end)
end)

AddComponentAction("PLAYER", "playercontroller", function(inst, doer, actions, right)
    if right and inst.prefab ~= doer.prefab then
        local has_empty_slot = false
        for i=1,4 do
            local slot = doer.components.inventory:GetItemInSlot(i)
            if not slot then
                has_empty_slot = true
                break
            end
        end
        if has_empty_slot then
            table.insert(actions, GLOBAL.Action(inst, doer, "BIND_BENFU", nil, nil, nil))
        end
    end
end)

AddAction("BIND_BENFU", function(act)
    local target = act.target
    local doer = act.doer
    local id_a = doer.userid
    local name_a = doer:GetBasicDisplayName()
    local id_b = target.userid
    local name_b = target:GetBasicDisplayName()
    local bone_a = GLOBAL.SpawnPrefab("benfu_bone")
    bone_a.owner_userid = id_b
    bone_a.player_name = name_b
    local bone_b = GLOBAL.SpawnPrefab("benfu_bone")
    bone_b.owner_userid = id_a
    bone_b.player_name = name_a
    for i=1,4 do
        local slot = doer.components.inventory:GetItemInSlot(i)
        if not slot then
            doer.components.inventory:SetItemInSlot(i,bone_a)
            break
        end
    end
    for i=1,4 do
        local slot = target.components.inventory:GetItemInSlot(i)
        if not slot then
            target.components.inventory:SetItemInSlot(i,bone_b)
            break
        end
    end
    doer.components.talker:Say("You forged a bond with "..name_b)
    target.components.talker:Say(name_a.." formed a bond with you")
    return true
end)