local assets = {
    Asset("ANIM", "anim/wangsheng_bone.zip"),
    Asset("ATLAS", "images/inventoryimages/wangsheng_bone.xml"),
    Asset("IMAGE", "images/inventoryimages/wangsheng_bone.tex"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:SetPrefabNameWithoutChecking("wangsheng_bone")

    inst.AnimState:SetBank("wangsheng_bone")
    inst.AnimState:SetBuild("wangsheng_bone")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(1.1, 1.1, 1)

    inst:AddTag("TOOL")
    inst:AddTag("nosteal")
    inst:AddTag("personal_artifact")

    MakeInventoryPhysics(inst)

    inst._net_x = net_string(inst.GUID, "wangsheng_bone._net_x")
    inst._net_z = net_string(inst.GUID, "wangsheng_bone._net_z")
    inst._net_player_name = net_string(inst.GUID, "wangsheng_bone._net_player_name")
    inst._net_owner = net_string(inst.GUID, "wangsheng_bone._net_owner")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.death_x = nil
    inst.death_z = nil
    inst.player_name = nil
    inst.owner_userid = nil

    function inst:SetDeathPos(x, z)
        self.death_x = x
        self.death_z = z
        self._net_x:set(tostring(x))
        self._net_z:set(tostring(z))
    end

    function inst:SetPlayerName(name)
        self.player_name = name
        self._net_player_name:set(name or "")
    end

    function inst:GetPlayerName()
        local val = self._net_player_name:value()
        return val ~= "" and val or nil
    end

    function inst:SetOwner(uid)
        self.owner_userid = uid
        self._net_owner:set(uid or "")
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wangsheng_bone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wangsheng_bone.xml"
    inst.components.inventoryitem:SetCanOnlyGoInPocket(true)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getspecialdescription = function(inst)
        local desc = "一枚记录亡者坐标的骨片，右键回到陨落之地。"
        if STRINGS and STRINGS.ITEM and STRINGS.ITEM.WANG_EMPTY then
            desc = STRINGS.ITEM.WANG_EMPTY
        end
        local p_name = inst:GetPlayerName()
        if p_name then
            local fmt = "前往%s陨落的地点，使用后消散。"
            if STRINGS and STRINGS.ITEM and STRINGS.ITEM.WANG_DESC then
                fmt = STRINGS.ITEM.WANG_DESC
            end
            return string.format(fmt, p_name)
        end
        return desc
    end

    inst:AddComponent("tradable")

    inst.OnSave = function(inst, data)
        data.x = inst.death_x
        data.z = inst.death_z
        data.name = inst.player_name
        data.uid = inst.owner_userid
    end

    inst.OnLoad = function(inst, data)
        if data then
            if data.x then inst:SetDeathPos(data.x, data.z) end
            if data.name then inst:SetPlayerName(data.name) end
            if data.uid then inst:SetOwner(data.uid) end
        end
    end

    return inst
end

return Prefab("wangsheng_bone", fn, assets)