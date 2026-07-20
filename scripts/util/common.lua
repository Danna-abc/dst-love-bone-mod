local GLOBAL = GLOBAL
local Config = modimport("scripts/util/config.lua")

local Teleport = {}

function Teleport.ApplyCost(user)
    local hunger = Config.GetHungerCost()
    if hunger > 0 and user.components.hunger then
        user.components.hunger:DoDelta(-hunger)
    end
    local sanity = Config.GetSanityCost()
    if sanity > 0 and user.components.sanity then
        user.components.sanity:DoDelta(-sanity)
    end
end

function Teleport.FindSafePosition(x, z)
    local offset = GLOBAL.FindWalkableOffset(
        GLOBAL.Vector3(x, 0, z),
        GLOBAL.math.random() * GLOBAL.math.pi * 2,
        10, 12, false, true
    )
    if offset then
        return x + offset.x, z + offset.z
    end
    return nil
end

function Teleport.IsOceanCheck(x, z)
    return GLOBAL.TheWorld.Map:IsOceanAtPoint(x, 0, z)
end

function Teleport.Execute(player, x, z)
    local safeX, safeZ = Teleport.FindSafePosition(x, z)
    if not safeX then return false end
    if Teleport.IsOceanCheck(safeX, safeZ) then return false end
    player.Transform:SetPosition(safeX, 0, safeZ)
    return true
end

return Teleport