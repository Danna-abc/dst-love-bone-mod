local GLOBAL = GLOBAL
local Common = modimport("scripts/util/common.lua")

local BondManager = {}

function BondManager.Bind(doer, target)
    if not Common.HasFullSpace(doer) or not Common.HasFullSpace(target) then
        if doer.components.talker then
            doer.components.talker:Say(GLOBAL.STRINGS.BONE.BAG_FULL)
        end
        return false
    end

    local nameA = doer:GetDisplayName()
    local nameB = target:GetDisplayName()
    local boneA = GLOBAL.SpawnPrefab("benfu_bone")
    local boneB = GLOBAL.SpawnPrefab("benfu_bone")

    if boneA then
        boneA:SetOwner(target.userid)
        boneA:SetPlayerName(nameB)
    end
    if boneB then
        boneB:SetOwner(doer.userid)
        boneB:SetPlayerName(nameA)
    end

    Common.SafeGiveBone(doer, boneA)
    Common.SafeGiveBone(target, boneB)

    if doer.components.talker then
        doer.components.talker:Say(string.format(GLOBAL.STRINGS.BONE.BIND_CREATE, nameB))
    end
    if target.components.talker then
        target.components.talker:Say(string.format(GLOBAL.STRINGS.BONE.BIND_YOU, nameA))
    end
    return true
end

function BondManager.ValidateTarget(bone)
    if not bone or not bone.owner_userid then
        return nil, GLOBAL.STRINGS.BONE.NO_BIND
    end
    local target = Common.GetPlayerByUserid(bone.owner_userid)
    if not target then
        return nil, (bone:GetPlayerName() or "Unknown") .. GLOBAL.STRINGS.BONE.OFFLINE
    end
    if Common.IsGhost(target) then
        return nil, (bone:GetPlayerName() or "Unknown") .. GLOBAL.STRINGS.BONE.GHOST
    end
    return target, nil
end

return BondManager