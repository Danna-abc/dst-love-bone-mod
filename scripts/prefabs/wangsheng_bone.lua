local GLOBAL = _G

local assets = {
    资源("ATLAS", "images/inventoryimages/wangsheng_bone.xml"),
    资源("IMAGE", "images/inventoryimages/wangsheng_bone.tex"),
}

本地函数 fn()
    本地实例 = GLOBAL.CreateEntity()
    实例.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boneshard")
    inst.AnimState:SetBuild("boneshard")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(1.1, 1.1, 1)

    inst:AddTag("TOOL")
    inst:AddTag("NOCLICK")
    inst:AddTag("nosteal")

    inst.entity:SetPristine()
    如果 not GLOBAL.TheWorld.ismastersim 那么
        返回 实例
    结束

    inst.death_x = nil
    inst.death_z = nil
    inst.player_name = nil
    inst.owner_userid = nil

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wangsheng_bone.xml"
    inst.components.inventoryitem.imagename = "wangsheng_bone"
    inst.components.inventoryitem:SetCanOnlyGoInPocket(true)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getspecialdescription = 函数(inst)
        如果 inst.player_name 那么
            返回 字符串.format("前往%s陨落的地点，使用后将会消散", inst.player_name)
        结束
        返回 "往生信物"
    结束

    inst.AddComponent("可交易")

    inst.OnSave = 函数(inst, 数据)
        数据.death_x = inst.death_x
        数据.death_z = inst.death_z
        data.player_name = inst.player_name
    结束
    inst.OnLoad = 函数(inst, data)
        如果 data 那么
            inst.death_x = data.death_x
            inst.death_z = data.death_z
            inst.player_name = data.player_name
        结束
    结束

    返回 实例
结束

返回 GLOBAL.Prefab("wangsheng_bone", fn, assets)
