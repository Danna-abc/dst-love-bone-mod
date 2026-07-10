local GLOBAL = GLOBAL

local assets = {
    Asset("ATLAS", "images/inventoryimages/wangsheng_bone.xml"),
    Asset("IMAGE", "images/inventoryimages/wangsheng_bone.tex"),
}

local function fn()
    local inst = GLOBAL.CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:SetPrefabNameWithoutChecking("wangsheng_bone")

    inst.AnimState:SetBank("boneshard")
    inst.AnimState:SetBuild("boneshard")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(1.1, 1.1, 1)

    inst:AddTag("TOOL")
    inst:AddTag("nosteal")
    inst:AddTag("personal_artifact")

    GLOBAL.MakeInventoryPhysics(inst)

    inst._net_player_name = GLOBAL.net_string(inst.GUID, "wangsheng_bone._net_player_name")

    inst.entity:SetPristine()

    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end

    inst.death_x = nil
    inst.death_z = nil
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
    inst.components.inventoryitem.imagename = "wangsheng_bone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wangsheng_bone.xml"
    inst.components.inventoryitem:SetCanOnlyGoInPocket(true)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getspecialdescription = function(inst)
        local desc = "一枚记录亡者坐标的骨片，右键回到陨落之地。"
        if GLOBAL.STRINGS and GLOBAL.STRINGS.ITEM and GLOBAL.STRINGS.ITEM.WANG_EMPTY then
            desc = GLOBAL.STRINGS.ITEM.WANG_EMPTY
        end
        local p_name = inst.player_name
        if p_name then
            local fmt = "前往%s陨落的地点，使用后消散。"
            if GLOBAL.STRINGS and GLOBAL.STRINGS.ITEM and GLOBAL.STRINGS.ITEM.WANG_DESC then
                fmt = GLOBAL.STRINGS.ITEM.WANG_DESC
            end
            return string.format(fmt, p_name)
        end
        return desc
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

return GLOBAL.Prefab("wangsheng_bone", fn, assets)