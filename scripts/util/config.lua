local GLOBAL = GLOBAL

local Config = {}

local function GetModConfigDataSafe(key, default)
    local val = GetModConfigData(key)
    return val ~= nil and val or default
end

function Config.GetHungerCost()
    return GetModConfigDataSafe("Teleport_Hunger_Cost", 0.5)
end

function Config.GetSanityCost()
    return GetModConfigDataSafe("Teleport_Sanity_Cost", 0.5)
end

function Config.IsOnlySelfSkeleton()
    return GetModConfigDataSafe("OnlySelfSkeleton", true)
end

function Config.BlockRuinsSkeleton()
    return GetModConfigDataSafe("BlockRuinsSkeleton", true)
end

return Config