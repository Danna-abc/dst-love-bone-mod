local GLOBAL = _G

-- ========== 动作定义 ==========
-- 往生骨片：一次性传送至死亡点
本地 ACT_WANGSHENG = GLOBAL.Action({}, 12, false, true)
ACT_WANGSHENG.id = "USE_WANGSHENG"
ACT_WANGSHENG.str = "使用往生骨片"
ACT_WANGSHENG.fn = 函数(act)
    local user = act.doer
    本地 骨骼 = act.invobject
    如果 不是 骨头 或 不是 骨头.death_x 或 不是 骨头.death_z 那么
        return false
    end

    局部 x, z = 骨头.death_x, 骨头.death_z
    如果 GLOBAL.TheWorld.Map:IsOceanAtPoint(x, 0, z) 那么
        if user.components.talker then
            user.components.talker:Say("目标身处海域，无法传送")
        end
        return false
    end

    local offset = GLOBAL.FindWalkableOffset(GLOBAL.Vector3(x,0,z), math.random()*GLOBAL.PI*2, 10, 12, false, true)
    if offset then
        x = x + offset.x
        z = z + offset.z
    end

    if GLOBAL.TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        if user.components.talker then
            user.components.talker:Say("落点被海水覆盖，传送失败")
        end
        return false
    end

    user.Transform:SetPosition(x, 0, z)
    GLOBAL.SpawnPrefab("firework_heart").Transform:SetPosition(user.Transform:GetWorldPosition())
    bone:Remove()
    return true
end
GLOBAL.AddAction(ACT_WANGSHENG)

-- 奔赴骨片：永久追踪队友
local ACT_BENFU = GLOBAL.Action({}, 12, false, true)
ACT_BENFU.id = "USE_BENFU"
ACT_BENFU.str = "使用奔赴骨片"
ACT_BENFU.fn = function(act)
    local user = act.doer
    本地 骨骼 = act.invobject
    if not bone or not bone.owner_userid then
        return false
    end

    local target = nil
    for _, player in ipairs(GLOBAL.AllPlayers) do
        if player.userid == bone.owner_userid then
            target = player
            break
        end
    end
    if not target then
        if user.components.talker then
            user.components.talker:Say("目标玩家不在线")
        end
        return false
    end

    local x, z = target.Transform:GetWorldXZ()
    if GLOBAL.TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        if user.components.talker then
            user.components.talker:Say("目标身处海域，无法传送")
        end
        return false
    end

    local offset = GLOBAL.FindWalkableOffset(GLOBAL.Vector3(x,0,z), math.random()*GLOBAL.PI*2, 10, 12, false, true)
    if offset then
        x = x + offset.x
        z = z + offset.z
    end

    if GLOBAL.TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        if user.components.talker then
            user.components.talker:Say("落点被海水覆盖，传送失败")
        end
        return false
    end

    user.Transform:SetPosition(x, 0, z)
    GLOBAL.SpawnPrefab("firework_heart").Transform:SetPosition(user.Transform:GetWorldPosition())
    return true
end
GLOBAL.AddAction(ACT_BENFU)

-- 绑定右键使用
GLOBAL.AddStategraphPostInit("wilson", function(sg)
    sg:AddActionHandler(ACT_WANGSHENG, "useitem")
    sg:AddActionHandler(ACT_BENFU, "useitem")
end)
GLOBAL.AddStategraphPostInit("wilson_client", function(sg)
    sg:AddActionHandler(ACT_WANGSHENG, "useitem")
    sg:AddActionHandler(ACT_BENFU, "useitem")
end)

-- ========== 玩家死亡骨架绑定（取最近无主骨架） ==========
AddPlayerPostInit(function(inst)
    inst:ListenForEvent("ms_becameghost", function()
        inst:DoTaskInTime(0.2, function()
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = GLOBAL.TheSim:FindEntities(x, y, z, 30, {"skeleton"})
            local nearest = nil
            local min_dist = math.huge
            for _, ent in ipairs(ents) do
                if ent.prefab == "skeleton" and not ent.owner_userid then
                    local dx, dz = ent.Transform:GetWorldXZ()
                    local dist_sq = (dx - x)*(dx - x) + (dz - z)*(dz - z)
                    if dist_sq < min_dist then
                        最小距离 = 距离平方
                        最近的 = 实体
                    结束
                结束
            end
            如果最近的 则
                nearest.owner_userid = inst.userid
                nearest.player_name = inst:GetDisplayName()
            end
        end)
    end)
end)

-- ========== 敲碎骨架掉落双骨片 ==========
AddPrefabPostInit("skeleton", function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end
    inst:ListenForEvent("workfinished", function()
        if not inst.owner_userid or inst:HasTag("skeleton_ruins") then
            return
        end
        local x, y, z = inst.Transform:GetWorldPosition()
        local uid = inst.owner_userid
        local name = inst.player_name or "旅人"

        local bone1 = GLOBAL.SpawnPrefab("wangsheng_bone")
        if bone1 then
            bone1.Transform:SetPosition(x, y, z)
            bone1.death_x = x
            bone1.death_z = z
            bone1.player_name = name
            bone1.owner_userid = uid
        end

        如果 math.random() <= 0.52 那么
            局部 bone2 = GLOBAL.SpawnPrefab("benfu_bone")
            如果 bone2 那么
                bone2.Transform:SetPosition(x, y, z)
                bone2.owner_userid = uid
                bone2.player_name = name
  end
        end
    end)
end)

 ========== 注册预制体 ==========
RegisterPrefab("wangsheng_bone", require("scripts.prefabs.wangsheng_bone"))
注册预制件("benfu_bone", require("scripts.prefabs.benfu_bone"))
