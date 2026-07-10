PrefabFiles = {
    "wangsheng_bone",
    "benfu_bone"
}

local DEFAULT_TEXT = {
    BONE = {
        NO_POS = "This bone shard has no death coordinates recorded.",
        NOT_YOUR = "This is not your bone shard.",
        OCEAN_FAIL = "Target location is in the ocean, teleport failed.",
        TELE_SUCC = "Teleport successful.",
        NO_BIND = "This bone shard is not bound to anyone.",
        OFFLINE = " is offline.",
        GHOST = " is a ghost.",
        OCEAN_BIND = "Target is in the ocean, teleport failed.",
        BIND_SUCC = "Bond teleport successful.",
        BAG_FULL = "Inventory is full!",
        BIND_CREATE = "You have established a bond with %s.",
        BIND_YOU = "%s has established a bond with you.",
    },
    ITEM = {
        WANG_EMPTY = "A bone shard recording a deceased's coordinates. Right-click to return to their place of demise.",
        WANG_DESC = "Travel to the place where %s fell. Dissipates upon use.",
        BENFU_EMPTY = "A dual bond bone shard, not yet bound to anyone.",
        BENFU_DESC = "Bound to %s. Right-click to teleport to their side indefinitely.",
    }
}

local current_lang = GLOBAL.LanguageTranslation and GLOBAL.LanguageTranslation.default_language or "en"
local is_chinese = (current_lang == "zh" or current_lang == "zhr" or current_lang == "zht" or current_lang == "ch")

local final_text = DEFAULT_TEXT
if is_chinese then
    local status, chs_module = pcall(require, "scripts/languages/chs")
    if status and type(chs_module) == "table" then
        final_text = chs_module
    end
end

GLOBAL.STRINGS.BONE = GLOBAL.STRINGS.BONE or {}
GLOBAL.STRINGS.ITEM = GLOBAL.STRINGS.ITEM or {}

for k, v in pairs(final_text.BONE) do
    GLOBAL.STRINGS.BONE[k] = v
end
for k, v in pairs(final_text.ITEM) do
    GLOBAL.STRINGS.ITEM[k] = v
end

GLOBAL.STRINGS.ACTIONS.USE_WANGSHENG = is_chinese and "使用往生骨片" or "Use Rebirth Bone"
GLOBAL.STRINGS.ACTIONS.USE_BENFU = is_chinese and "使用奔赴羁绊骨片" or "Use Bond Bone"
GLOBAL.STRINGS.ACTIONS.BIND_BENFU = is_chinese and "与对方建立羁绊" or "Establish Bond"

local FindWalkableOffset = GLOBAL.FindWalkableOffset
local Vector3 = GLOBAL.Vector3

local function GetHungerCost()
    return GetModConfigData("Teleport_Hunger_Cost") or 0.5
end
local function GetSanityCost()
    return GetModConfigData("Teleport_Sanity_Cost") or 0.5
end
local function OnlySelfSkeleton()
    return GetModConfigData("OnlySelfSkeleton")
end
local function BlockRuinsSkeleton()
    return GetModConfigData("BlockRuinsSkeleton")
end

local function ApplyTeleportCost(user)
    local hunger = GetHungerCost()
    if hunger > 0 and user.components.hunger then
        user.components.hunger:DoDelta(-hunger)
    end
    local sanity = GetSanityCost()
    if sanity > 0 and user.components.sanity then
        user.components.sanity:DoDelta(-sanity)
    end
end

local function GetTip(key, default_text)
    if GLOBAL.STRINGS.BONE and GLOBAL.STRINGS.BONE[key] then
        return GLOBAL.STRINGS.BONE[key]
    end
    return default_text or ""
end

local USE_WANGSHENG = GLOBAL.Action({ priority = 1, rmb = true })
USE_WANGSHENG.id = "USE_WANGSHENG"
USE_WANGSHENG.str = GLOBAL.STRINGS.ACTIONS.USE_WANGSHENG or "Use Wangsheng Bone"
USE_WANGSHENG.fn = function(act)
    if not GLOBAL.TheWorld.ismastersim then return true end
    local user = act.doer
    local bone = act.invobject
    if not bone or not bone.death_x or not bone.death_z then
        local tip = GetTip("NO_POS")
        if user.components.talker then user.components.talker:Say(tip) end
        return false
    end
    if OnlySelfSkeleton() and bone.owner_userid ~= user.userid then
        local tip = GetTip("NOT_YOUR")
        if user.components.talker then user.components.talker:Say(tip) end
        return false
    end
    ApplyTeleportCost(user)
    local x, z = bone.death_x, bone.death_z
    local offset = FindWalkableOffset(Vector3(x,0,z), GLOBAL.math.random()*GLOBAL.math.pi*2, 10, 12, false, true)
    if offset then
        x = x + offset.x
        z = z + offset.z
    end
    if GLOBAL.TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        local tip = GetTip("OCEAN_FAIL")
        if user.components.talker then user.components.talker:Say(tip) end
        return false
    end
    user.Transform:SetPosition(x, 0, z)
    bone:Remove()
    local tip = GetTip("TELE_SUCC")
    if user.components.talker then user.components.talker:Say(tip) end
    return true
end
AddAction(USE_WANGSHENG)

local USE_BENFU = GLOBAL.Action({ priority = 1, rmb = true })
USE_BENFU.id = "USE_BENFU"
USE_BENFU.str = GLOBAL.STRINGS.ACTIONS.USE_BENFU or "Use Benfu Bone"
USE_BENFU.fn = function(act)
    if not GLOBAL.TheWorld.ismastersim then return true end
    local user = act.doer
    local bone = act.invobject
    if not bone or not bone.owner_userid then
        local tip = GetTip("NO_BIND")
        if user.components.talker then user.components.talker:Say(tip) end
        return false
    end
    local target = nil
    for _, p in ipairs(GLOBAL.AllPlayers) do
        if p.userid == bone.owner_userid then
            target = p
            break
        end
    end
    local bone_name = bone.player_name or "Unknown"
    if not target then
        local tip = GetTip("OFFLINE")
        if user.components.talker then user.components.talker:Say(bone_name .. tip) end
        return false
    end
    if target:HasTag("ghost") then
        local tip = GetTip("GHOST")
        if user.components.talker then user.components.talker:Say(bone_name .. tip) end
        return false
    end
    local x, y, z = target.Transform:GetWorldPosition()
    local offset = FindWalkableOffset(Vector3(x,0,z), GLOBAL.math.random()*GLOBAL.math.pi*2, 10, 12, false, true)
    if offset then
        x = x + offset.x
        z = z + offset.z
    end
    if GLOBAL.TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        local tip = GetTip("OCEAN_BIND")
        if user.components.talker then user.components.talker:Say(tip) end
        return false
    end
    user.Transform:SetPosition(x, 0, z)
    local tip = GetTip("BIND_SUCC")
    if user.components.talker then user.components.talker:Say(tip) end
    return true
end
AddAction(USE_BENFU)

local BIND_BENFU = GLOBAL.Action({ priority = 1, rmb = true, distance = 4 })
BIND_BENFU.id = "BIND_BENFU"
BIND_BENFU.str = GLOBAL.STRINGS.ACTIONS.BIND_BENFU or "Establish Bond"
BIND_BENFU.fn = function(act)
    if not GLOBAL.TheWorld.ismastersim then return true end
    local target = act.target
    local doer = act.doer
    if not target or target == doer then return false end

    local function HasFullSpace(plr)
        local inv = plr.components.inventory
        for i = 1, 4 do
            if not inv:GetItemInSlot(i) then return true end
        end
        return inv:NumItems() < inv.maxslots
    end

    if not HasFullSpace(doer) or not HasFullSpace(target) then
        local tip = GetTip("BAG_FULL")
        if doer.components.talker then doer.components.talker:Say(tip) end
        return false
    end

    local nameA = doer:GetDisplayName()
    local nameB = target:GetDisplayName()
    local boneA = GLOBAL.SpawnPrefab("benfu_bone")
    local boneB = GLOBAL.SpawnPrefab("benfu_bone")

    if boneA then
        boneA.owner_userid = target.userid
        boneA.player_name = nameB
    end
    if boneB then
        boneB.owner_userid = doer.userid
        boneB.player_name = nameA
    end

    local function SafeGiveBone(plr, bone)
        local inv = plr.components.inventory
        for i = 1, 4 do
            if not inv:GetItemInSlot(i) then
                inv:SetItemInSlot(i, bone)
                return
            end
        end
        inv:GiveItem(bone)
    end

    SafeGiveBone(doer, boneA)
    SafeGiveBone(target, boneB)
    local create_tip = GetTip("BIND_CREATE")
    local you_tip = GetTip("BIND_YOU")
    if doer.components.talker then doer.components.talker:Say(string.format(create_tip, nameB)) end
    if target.components.talker then target.components.talker:Say(string.format(you_tip, nameA)) end
    return true
end
AddAction(BIND_BENFU)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(USE_WANGSHENG, "doshortaction"))
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(USE_BENFU, "doshortaction"))
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(BIND_BENFU, "doshortaction"))

AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(USE_WANGSHENG, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(USE_BENFU, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(BIND_BENFU, "doshortaction"))

AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
    if right then
        if inst.prefab == "wangsheng_bone" then
            table.insert(actions, USE_WANGSHENG)
        elseif inst.prefab == "benfu_bone" then
            table.insert(actions, USE_BENFU)
        end
    end
end)

AddComponentAction("SCENE", "playercontroller", function(inst, doer, actions, right)
    if right and inst ~= doer and inst:HasTag("player") then
        table.insert(actions, BIND_BENFU)
    end
end)

local function SpawnBones(inst)
    if inst._bones_spawned then return end
    if BlockRuinsSkeleton() and inst:HasTag("skeleton_ruins") then return end
    if not inst.owner_userid then return end
    inst._bones_spawned = true
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
    if GLOBAL.math.random() <= 0.52 then
        local bone2 = GLOBAL.SpawnPrefab("benfu_bone")
        if bone2 then
            bone2.Transform:SetPosition(x, y, z)
            bone2.owner_userid = uid
            bone2.player_name = name
        end
    end
end

AddSimPostInit(function()
    if not GLOBAL.TheWorld.ismastersim then return end

    AddPlayerPostInit(function(inst)
        local function OnPlayerDied()
            inst:DoTaskInTime(1.0, function()
                if not inst:IsValid() then return end
                local px, py, pz = inst.Transform:GetWorldPosition()
                local ents = GLOBAL.TheSim:FindEntities(px, py, pz, 4, {"skeleton"}, {"skeleton_ruins"})
                local nearest = nil
                local min_dist = GLOBAL.math.huge
                for _, e in ipairs(ents) do
                    if e.prefab == "skeleton" and not e.owner_userid then
                        local dx, dz = e.Transform:GetWorldXZ()
                        local dist = (dx - px)*(dx - px) + (dz - pz)*(dz - pz)
                        if dist < min_dist then
                            min_dist = dist
                            nearest = e
                        end
                    end
                end
                if nearest then
                    nearest.owner_userid = inst.userid
                    nearest.player_name = inst:GetDisplayName()
                end
            end)
        end
        inst:ListenForEvent("ms_playerdied", OnPlayerDied)
    end)

    AddPrefabPostInit("skeleton", function(inst)
        inst:ListenForEvent("hammered", SpawnBones)
        inst:ListenForEvent("workfinished", SpawnBones)
        inst:ListenForEvent("entityremove", function()
            inst:RemoveEventCallback("hammered", SpawnBones)
            inst:RemoveEventCallback("workfinished", SpawnBones)
        end)
    end)

    AddPrefabPostInit("shallowgrave", function(inst)
        inst:ListenForEvent("workfinished", SpawnBones)
        inst:ListenForEvent("entityremove", function()
            inst:RemoveEventCallback("workfinished", SpawnBones)
        end)
    end)
end)