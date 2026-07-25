local GLOBAL = GLOBAL

local M = {}

function M.RegisterNetString(inst, guid, name)
    return GLOBAL.net_string(inst.GUID, name)
end

return M