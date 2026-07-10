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

    inst:SetPrefabNameWithoutChecking("benfu_bone")

    inst.AnimState:SetBank("boneshard")
    inst.AnimState:SetBuild("boneshard")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(1.2, 1.2, 1)

    inst:AddTag("TOOL")
    inst:AddTag("nosteal")
    inst:AddTag("personal_artifact")

    GLOBAL.MakeInventoryPhysics(inst)

    inst._net_player_name = GLOBAL.net_string(inst.GUID, "benfu_bone._net_player_name")

    inst.entity:SetPristine()

    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end

    inst.owner_userid = nil

    local mt = getmetatable(inst) or {}
    local old_newindex = mt.__newindex
    mt.__newindex = function(t, k, v)
        if k == "player_name" then
            inst._net_player_name:set(v or "")
        elseif old_newindex then
            old_newindex(t, k, v)
        else
            rawset(t, k, v)
        end
    end
    mt.__index = function(t, k)
        if k == "player_name" then
            local val = inst._net_player_name:value()
            return val ~= "" and val or nil
        end
        return rawget(t, k)
    end
    setmetatable(inst, mt)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "benfu_bone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/benfu_bone.xml"
    inst.components.inventoryitem:SetCanOnlyGoInPocket(true)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getspecialdescription = function(inst)
        local desc = "双人羁绊骨片，还未与任何人绑定。"
        if GLOBAL.STRINGS and GLOBAL.STRINGS.ITEM and GLOBAL.STRINGS.ITEM.BENFU_EMPTY then
            desc = GLOBAL.STRINGS.ITEM.BENFU_EMPTY
        end
        local p_name = inst.player_name
        if p_name then
            local fmt = "与%s绑定的羁绊骨片，右键可无限次奔赴对方身边。"
            if GLOBAL.STRINGS and GLOBAL.STRINGS.ITEM and GLOBAL.STRINGS.ITEM.BENFU_DESC then
                fmt = GLOBAL.STRINGS.ITEM.BENFU_DESC
            end
            return string.format(fmt, p_name)
        end
        return desc
    end

    inst:AddComponent("tradable")

    inst.OnSave = function(inst, data)
        data.player_name = inst.player_name
        data.owner_userid = inst.owner_userid
    end

    inst.OnLoad = function(inst, data)
        if data then
            inst.owner_userid = data.owner_userid
            if data.player_name then
                inst.player_name = data.player_name
                if inst._net_player_name then
                    inst._net_player_name:set(data.player_name)
                end
            end
        end
    end

    return inst
end

return GLOBAL.Prefab("benfu_bone", fn, assets)