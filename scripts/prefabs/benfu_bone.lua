local GLOBAL = GLOBAL
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
    GLOBAL.MakeInventoryPhysics(inst)
    inst.entity:SetPristine()

    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end

    inst.owner_userid = nil
    inst.player_name = nil

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "benfu_bone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/benfu_bone.xml"
    inst.components.inventoryitem:SetCanOnlyGoInPocket(true)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getspecialdescription = function(inst)
        local desc = "羁绊之骨，无限奔赴绑定之人身旁。"
        if GLOBAL.STRINGS and GLOBAL.STRINGS.ITEM and GLOBAL.STRINGS.ITEM.BENFU_EMPTY then
            desc = GLOBAL.STRINGS.ITEM.BENFU_EMPTY
        end
        if inst.player_name then
            local fmt = "可无限奔赴%s身边的羁绊信物。"
            if GLOBAL.STRINGS and GLOBAL.STRINGS.ITEM and GLOBAL.STRINGS.ITEM.BENFU_DESC then
                fmt = GLOBAL.STRINGS.ITEM.BENFU_DESC
            end
            return string.format(fmt, inst.player_name)
        end
        return desc
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