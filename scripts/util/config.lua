function GetHungerCost()
    return GetModConfigData("Teleport_Hunger_Cost") or 0.5
end

function GetSanityCost()
    return GetModConfigData("Teleport_Sanity_Cost") or 0.5
end

function OnlySelfSkeleton()
    return GetModConfigData("OnlySelfSkeleton")
end

function BlockRuinsSkeleton()
    return GetModConfigData("BlockRuinsSkeleton") and true or false
end