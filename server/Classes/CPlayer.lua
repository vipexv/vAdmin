CPlayer = {}

---@param player string | number
---@return any
function CPlayer:new(player)
  if not player then
    return Debug("(Error) `CPlayer:new` function was called but the first param is null.")
  end

  local isStaff = false

  for i = 1, #Config.PermissionSystem do
    local permission = Config.PermissionSystem[i]
    if IsPlayerAceAllowed(source, permission.AcePerm) then
      isStaff = true
      AdminData[tonumber(player)] = permission.AllowedPermissions
      AdminData[tonumber(player)].id = player
      TriggerClientEvent("vadmin:cb:updatePermissions", player, permission.AllowedPermissions)
      Debug("Added " .. GetPlayerName(source) .. "to the AdminData table.")
    end
  end

  local obj = {
    name = GetPlayerName(player),
    id = player,
    identifiers = GetPlayerIdentifiersWithoutIP(player),
    tokens = GetPlayerTokens(player),
    isStaff = isStaff
  }

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function CPlayer:displayInfo()
  Debug(("Data: %s"):format(json.encode(self)))
end
