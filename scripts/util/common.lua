function HasFullSpace(plr)
    local inv = plr.components.inventory
    if not inv then return false end
    for i = 1, 4 do
        if not inv:GetItemInSlot(i) then return true end
    end
    return inv:NumItems() < inv.maxslots
end

function SafeGiveBone(plr, bone)
    if not bone then return end
    local inv = plr.components.inventory
    if not inv then return end
    for i = 1, 4 do
        if not inv:GetItemInSlot(i) then
            inv:SetItemInSlot(i, bone)
            return
        end
    end
    inv:GiveItem(bone)
end

function GetPlayerByUserid(uid)
    for _, p in ipairs(GLOBAL.AllPlayers) do
        if p.userid == uid then return p end
    end
    return nil
end

function IsGhost(player)
    return player:HasTag("ghost")
end

function IsOceanAtPoint(x, z)
    return GLOBAL.TheWorld.Map:IsOceanAtPoint(x, 0, z)
end