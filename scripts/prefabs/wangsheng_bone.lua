local GLOBAL = _G

local assets = {
    Asset("ATLAS", "images/inventoryimages/wangsheng_bone.xml"),
    Asset("IMAGE", "images/inventoryimages/wangsheng_bone.tex"),
}

local function fn()
    local inst = GLOBAL.CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boneshard")
    inst.AnimState:SetBuild("boneshard")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(1.1, 1.1, 1)

    inst:AddTag("TOOL")
    inst:AddTag("nosteal")

    inst.entity:SetPristine()
    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end

    inst.death_x = nil
    inst.death_z = nil
    inst.player_name = nil
    inst.owner_userid = nil

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wangsheng_bone.xml"
    inst.components.inventoryitem.imagename = "wangsheng_bone"
    inst.components.inventoryitem:SetCanOnlyGoInPocket(true)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getspecialdescription = function(inst)
        if inst.player_name then
            return string.format("Travel to the place where %s fell. It will vanish after use.", inst.player_name)
        end
        return "A keepsake that guides you to a lost one's final place."
    end

    inst:AddComponent("tradable")

    inst.OnSave = function(inst, data)
        data.death_x = inst.death_x
        data.death_z = inst.death_z
        data.player_name = inst.player_name
        data.owner_userid = inst.owner_userid
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.death_x = data.death_x
            inst.death_z = data.death_z
            inst.player_name = data.player_name
            inst.owner_userid = data.owner_userid
        end
    end

    return inst
end

return GLOBAL.Prefab("wangsheng_bone", fn, assets)
