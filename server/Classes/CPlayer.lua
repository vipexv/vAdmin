CPlayer = {}

---@param player string | number
---@return any
function CPlayer:new(player)
  if not player then
    return Debug("(Error) `CPlayer:new` function was called but the first param is null.")
  end

  local isStaff = false

  local discordId = GetDiscordID(player)
  local playerName = GetPlayerName(player)

  if not Config.UseDiscordRestAPI then
    for i = 1, #Config.PermissionSystem do
      local permission = Config.PermissionSystem[i]
      if IsPlayerAceAllowed(player, permission.AcePerm) then
        isStaff = true
        AdminData[tonumber(player)] = permission.AllowedPermissions
        AdminData[tonumber(player)].id = player
        TriggerClientEvent("vadmin:cb:updatePermissions", player, permission.AllowedPermissions)
        Debug(("[func:CPlayer:new] (ACEPermissions) %s (ID - %s) was authenticated as staff."):format(
          playerName, player))
      end
    end
  else
    local discordRoles = GetDiscordRoles(discordId, player)

    if not discordRoles then return Debug("[func:CPlayer:new] discordRoles is somehow nil, what the flip :o") end

    for i = 1, #discordRoles do
      local discordRoleId = discordRoles[i]
      for u = 1, #Config.PermissionSystem do
        local permission = Config.PermissionSystem[u]
        if discordRoleId == permission.RoleID then
          isStaff = true
          AdminData[tonumber(player)] = permission.AllowedPermissions
          AdminData[tonumber(player)].id = player
          TriggerClientEvent("vadmin:cb:updatePermissions", player, permission.AllowedPermissions)
          Debug(("[func:CPlayer:new] (DiscordAPI) %s (ID - %s) was authenticated as staff."):format(
            playerName, player))
        end
      end
    end
  end

  local obj = {
    name = playerName,
    id = player,
    identifiers = GetPlayerIdentifiersWithoutIP(player),
    tokens = GetPlayerTokens(player),
    isStaff = isStaff,
  }

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function CPlayer:displayInfo()
  Debug(("Data: %s"):format(json.encode(self)))
end
