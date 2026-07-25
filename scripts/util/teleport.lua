local GLOBAL = GLOBAL
local Config = require("scripts/util/config")

local M = {}

function M.ApplyCost(user)
    local hunger = Config.GetHungerCost()
    if hunger > 0 and user.components.hunger then
        user.components.hunger:DoDelta(-hunger)
    end
    local sanity = Config.GetSanityCost()
    if sanity > 0 and user.components.sanity then
        user.components.sanity:DoDelta(-sanity)
    end
end

function M.FindSafePosition(x, z)
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

function M.IsOceanCheck(x, z)
    return GLOBAL.TheWorld.Map:IsOceanAtPoint(x, 0, z)
end

function M.Execute(player, x, z)
    local safeX, safeZ = M.FindSafePosition(x, z)
    if not safeX then return false end
    if M.IsOceanCheck(safeX, safeZ) then return false end
    player.Transform:SetPosition(safeX, 0, safeZ)
    return true
end

return M