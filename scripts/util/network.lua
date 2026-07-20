local GLOBAL = GLOBAL

local Network = {}

function Network.RegisterNetString(inst, guid, name)
    return GLOBAL.net_string(inst.GUID, name)
end

return Network