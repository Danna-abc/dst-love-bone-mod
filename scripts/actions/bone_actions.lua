local GLOBAL = GLOBAL
local Action = GLOBAL.Action
local ActionHandler = GLOBAL.ActionHandler
local AddAction = GLOBAL.AddAction
local AddComponentAction = GLOBAL.AddComponentAction
local AddStategraphActionHandler = GLOBAL.AddStategraphActionHandler

local Config = modimport("scripts/util/config.lua")
local Teleport = modimport("scripts/util/teleport.lua")
local BondManager = modimport("scripts/manager/bondmanager.lua")

local USE_WANGSHENG = Action({ priority = 1, rmb = true })
USE_WANGSHENG.id = "USE_WANGSHENG"
USE_WANGSHENG.str = GLOBAL.STRINGS.ACTIONS.USE_WANGSHENG
USE_WANGSHENG.fn = function(act)
    if not GLOBAL.TheWorld.ismastersim then return true end
    local user = act.doer
    local bone = act.invobject
    if not bone or not bone.death_x or not bone.death_z then
        if user.components.talker then
            user.components.talker:Say(GLOBAL.STRINGS.BONE.NO_POS)
        end
        return false
    end
    if Config.IsOnlySelfSkeleton() and bone.owner_userid ~= user.userid then
        if user.components.talker then
            user.components.talker:Say(GLOBAL.STRINGS.BONE.NOT_YOUR)
        end
        return false
    end
    Teleport.ApplyCost(user)
    local x, z = bone.death_x, bone.death_z
    if not Teleport.Execute(user, x, z) then
        if user.components.talker then
            user.components.talker:Say(GLOBAL.STRINGS.BONE.OCEAN_FAIL)
        end
        return false
    end
    bone:Remove()
    if user.components.talker then
        user.components.talker:Say(GLOBAL.STRINGS.BONE.TELE_SUCC)
    end
    return true
end
AddAction(USE_WANGSHENG)

local USE_BENFU = Action({ priority = 1, rmb = true })
USE_BENFU.id = "USE_BENFU"
USE_BENFU.str = GLOBAL.STRINGS.ACTIONS.USE_BENFU
USE_BENFU.fn = function(act)
    if not GLOBAL.TheWorld.ismastersim then return true end
    local user = act.doer
    local bone = act.invobject
    local target, err = BondManager.ValidateTarget(bone)
    if not target then
        if user.components.talker then
            user.components.talker:Say(err)
        end
        return false
    end
    local x, y, z = target.Transform:GetWorldPosition()
    if not Teleport.Execute(user, x, z) then
        if user.components.talker then
            user.components.talker:Say(GLOBAL.STRINGS.BONE.OCEAN_BIND)
        end
        return false
    end
    if user.components.talker then
        user.components.talker:Say(GLOBAL.STRINGS.BONE.BIND_SUCC)
    end
    return true
end
AddAction(USE_BENFU)

local BIND_BENFU = Action({ priority = 1, rmb = true, distance = 4 })
BIND_BENFU.id = "BIND_BENFU"
BIND_BENFU.str = GLOBAL.STRINGS.ACTIONS.BIND_BENFU
BIND_BENFU.fn = function(act)
    if not GLOBAL.TheWorld.ismastersim then return true end
    local target = act.target
    local doer = act.doer
    if not target or target == doer then return false end
    return BondManager.Bind(doer, target)
end
AddAction(BIND_BENFU)

AddStategraphActionHandler("wilson", ActionHandler(GLOBAL.ACTIONS.USE_WANGSHENG, "doshortaction"))
AddStategraphActionHandler("wilson", ActionHandler(GLOBAL.ACTIONS.USE_BENFU, "doshortaction"))
AddStategraphActionHandler("wilson", ActionHandler(GLOBAL.ACTIONS.BIND_BENFU, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(GLOBAL.ACTIONS.USE_WANGSHENG, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(GLOBAL.ACTIONS.USE_BENFU, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(GLOBAL.ACTIONS.BIND_BENFU, "doshortaction"))

AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
    if right then
        if inst.prefab == "wangsheng_bone" then
            table.insert(actions, GLOBAL.ACTIONS.USE_WANGSHENG)
        elseif inst.prefab == "benfu_bone" then
            table.insert(actions, GLOBAL.ACTIONS.USE_BENFU)
        end
    end
end)

AddComponentAction("SCENE", "playeractionpicker", function(inst, doer, actions, right)
    if right and inst ~= doer and inst:HasTag("player") then
        table.insert(actions, GLOBAL.ACTIONS.BIND_BENFU)
    end
end)