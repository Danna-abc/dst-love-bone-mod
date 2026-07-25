local GLOBAL = GLOBAL

local M = {}

local function GetModConfigDataSafe(key, default)
    local val = GetModConfigData(key)
    return val ~= nil and val or default
end

function M.GetHungerCost()
    return GetModConfigDataSafe("Teleport_Hunger_Cost", 0.5)
end

function M.GetSanityCost()
    return GetModConfigDataSafe("Teleport_Sanity_Cost", 0.5)
end

function M.IsOnlySelfSkeleton()
    return GetModConfigDataSafe("OnlySelfSkeleton", true)
end

function M.BlockRuinsSkeleton()
    return GetModConfigDataSafe("BlockRuinsSkeleton", true)
end

return M