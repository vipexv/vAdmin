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

    if discordRoles then
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
  end

  local obj = {
    name = playerName,
    id = player,
    identifiers = GetPlayerIdentifiersWithoutIP(player),
    tokens = GetPlayerTokens(player),
    isStaff = isStaff,
    roles = Config.UseDiscordRestAPI and GetDiscordRoles(discordId, player) or nil,
    avatar = Config.UseDiscordRestAPI and GetDiscordAvatar(discordId, player) or nil
  }

  Player(player).state.playerData = obj

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function CPlayer:displayInfo()
  Debug(("Data: %s"):format(json.encode(self)))
end
