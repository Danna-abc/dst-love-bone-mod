local assets = {
    Asset("ANIM", "anim/benfu_bone.zip"),
    Asset("ATLAS", "images/inventoryimages/benfu_bone.xml"),
    Asset("IMAGE", "images/inventoryimages/benfu_bone.tex"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:SetPrefabNameWithoutChecking("benfu_bone")

    inst.AnimState:SetBank("benfu_bone")
    inst.AnimState:SetBuild("benfu_bone")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(1.2, 1.2, 1)

    inst:AddTag("TOOL")
    inst:AddTag("nosteal")
    inst:AddTag("personal_artifact")

    MakeInventoryPhysics(inst)

    inst._net_player_name = net_string(inst.GUID, "benfu_bone._net_player_name")
    inst._net_owner = net_string(inst.GUID, "benfu_bone._net_owner")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.player_name = nil
    inst.owner_userid = nil

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
    inst.components.inventoryitem.imagename = "benfu_bone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/benfu_bone.xml"
    inst.components.inventoryitem:SetCanOnlyGoInPocket(true)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getspecialdescription = function(inst)
        local desc = "双人羁绊骨片，还未与任何人绑定。"
        if STRINGS and STRINGS.ITEM and STRINGS.ITEM.BENFU_EMPTY then
            desc = STRINGS.ITEM.BENFU_EMPTY
        end
        local p_name = inst:GetPlayerName()
        if p_name then
            local fmt = "与%s绑定的羁绊骨片，右键可无限次奔赴对方身边。"
            if STRINGS and STRINGS.ITEM and STRINGS.ITEM.BENFU_DESC then
                fmt = STRINGS.ITEM.BENFU_DESC
            end
            return string.format(fmt, p_name)
        end
        return desc
    end

    inst:AddComponent("tradable")

    inst.OnSave = function(inst, data)
        data.name = inst.player_name
        data.uid = inst.owner_userid
    end

    inst.OnLoad = function(inst, data)
        if data then
            if data.name then inst:SetPlayerName(data.name) end
            if data.uid then inst:SetOwner(data.uid) end
        end
    end

    return inst
end

return Prefab("benfu_bone", fn, assets)