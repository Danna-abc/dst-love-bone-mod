local GLOBAL = _G

local assets = {
    Asset("ATLAS", "images/inventoryimages/benfu_bone.xml"),
    Asset("IMAGE", "images/inventoryimages/benfu_bone.tex"),
}

local function fn()
    local inst = GLOBAL.CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boneshard")
    inst.AnimState:SetBuild("boneshard")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(1.2, 1.2, 1)

    inst:AddTag("TOOL")
    inst:AddTag("nosteal")

    inst.entity:SetPristine()
    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end

    inst.owner_userid = nil
    inst.player_name = nil

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/benfu_bone.xml"
    inst.components.inventoryitem.imagename = "benfu_bone"
    inst.components.inventoryitem:SetCanOnlyGoInPocket(true)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getspecialdescription = function(inst)
        if inst.player_name then
            return string.format("A bond that lets you rush to %s's side, again and again.", inst.player_name)
        end
        return "An eternal keepsake, always leading you to your bond."
    end

    inst:AddComponent("tradable")

    inst.OnSave = function(inst, data)
        data.owner_userid = inst.owner_userid
        data.player_name = inst.player_name
    end
    inst.OnLoad = function(inst, data)
        if data then
            inst.owner_userid = data.owner_userid
            inst.player_name = data.player_name
        end
    end

    return inst
end

return GLOBAL.Prefab("benfu_bone", fn, assets)
