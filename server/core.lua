-- Online Players
PlayerList = {}
-- Offline Players
PlayerCache = {}
-- Online Staff and Their Permissions.
AdminData = {}

AddEventHandler("playerJoining", function(_srcString, _oldID)
  if source <= 0 then
    Debug("(Error) [eventHandler:playerJoining] source is nil, returning.")
    return
  end

  local playerName = GetPlayerName(source)

  if type(playerName) ~= "string" then
    Debug("(Error) [eventHandler:playerJoining] Player name isn't a string, Player name type: ", type(playerName))
    return
  end

  local isStaff = false

  for permissionIndex = 1, #Config.PermissionSystem do
    local permission = Config.PermissionSystem[permissionIndex]
    if IsPlayerAceAllowed(source, permission.AcePerm) then
      isStaff = true
      AdminData[tonumber(source)] = permission.AllowedPermissions

      TriggerClientEvent("vadmin:cb:updatePermissions", source, permission.AllowedPermissions)

      AdminData[tonumber(source)].id = source
      Debug("Added joining player to the AdminData table: ", GetPlayerName(source), " AdminData Table: ",
        json.encode(AdminData))
    end
  end

  local playerData = CPlayer:new(source, isStaff)

  Debug("[eventHandler:playerJoining] playerData variable: ", json.encode(playerData))

  if PlayerList[source] then
    Debug("(Error) [eventHandler:playerJoining] Player is already in the [PlayerList] table.")
  end

  AddPlayerToList(playerData)
end)

AddEventHandler("playerDropped", function(reason)
  if source <= 0 then
    Debug("(Error) [eventHandler:playerDropped] Source is nil.")
    return
  end


  if PlayerList[source] then
    PlayerCache[source] = PlayerList[source]
    RemovePlayerFromList(source)
  else
    Debug("(Error) [eventHandler:playerDropped] Player isn't in the [PlayerList] table, error removing the player.")
  end
end)

SetTimeout(5000, function()
  CreateThread(function()
    local Players = GetPlayers()
    for i = 1, #Players do
      local player = Players[i]
      if PlayerList[player] then
        Debug("(Error) [Thread:InitPlayerList] Player is already in the PlayerList table.")
        return
      end

      local isStaff = false

      for permissionsIndex = 1, #Config.PermissionSystem do
        local permission = Config.PermissionSystem[permissionsIndex]
        if IsPlayerAceAllowed(player, permission.AcePerm) then
          isStaff = true
          AdminData[tonumber(player)] = permission.AllowedPermissions
          TriggerClientEvent("vadmin:cb:updatePermissions", player, permission.AllowedPermissions)
          AdminData[tonumber(player)].id = player
          Debug("Added player to the AdminData table: ", GetPlayerName(player), " AdminData Table: ",
            json.encode(AdminData))
        end
      end

      local playerData = CPlayer:new(player, isStaff)

      Debug("[Thread] playerData variable: ", json.encode(playerData))

      PlayerList[tonumber(player)] = playerData
    end
  end)
end)


-- Only run this if you plan on using ox_lib with it.
-- lib.callback.register('vadmin:plist', function(source)
--   return PlayerList
-- end)

-- lib.callback.register("vadmin:clist", function(source)
--   return PlayerCache
-- end)

-- lib.callback.register("vadmin:getPermissions", function(source)
--   if not AdminData[tonumber(source)] then
--     return Config.DefaultPermissions
--   end

--   return AdminData[tonumber(source)]
-- end)

---@param banIdentifiers {}
---@param sourceIdentifiers {}
---@return boolean
local loopThroughIdentifiers = function(banIdentifiers, sourceIdentifiers)
  if not next(banIdentifiers) or not next(sourceIdentifiers) then
    return false
  end

  for banIndex = 1, #banIdentifiers do
    local bannedIdentifier = banIdentifiers[banIndex]
    for sourceIndex = 1, #sourceIdentifiers do
      local sourceIdentifier = sourceIdentifiers[sourceIndex]
      if string.find(bannedIdentifier, sourceIdentifier) then
        Debug("Banned identifier found: ", bannedIdentifier)
        return true
      end
    end
  end

  return false
end

---@param banTokens {}
---@param sourceTokens {}
---@return boolean
local loopThroughTokens = function(banTokens, sourceTokens)
  if not next(banTokens) or not next(sourceTokens) then
    return false
  end

  for banIndex = 1, #banTokens do
    local bannedToken = banTokens[banIndex]
    for sourceIndex = 1, #sourceTokens do
      local sourceToken = sourceTokens[sourceIndex]
      if bannedToken == sourceToken then
        Debug("Banned token found: ", bannedToken)
        return true
      end
    end
  end

  return false
end


AddEventHandler("playerConnecting", function(_name, _setKickReason, deferrals)
  local source = tonumber(source)
  local identifiers = GetPlayerIdentifiersWithoutIP(source)
  local tokens = GetPlayerTokens(source)
  local banlist = LoadBanList()

  deferrals.defer()
  Wait(50)
  deferrals.update("Checking if the user is banned...")

  for banIndex, banEntry in pairs(banlist) do
    local identifierCheck = loopThroughIdentifiers(banEntry.identifiers, identifiers)
    local tokenCheck = loopThroughTokens(banEntry.tokens, tokens)

    if identifierCheck or tokenCheck then
      local remainingTime = banEntry.Length - os.time()

      if remainingTime <= 0 then
        table.remove(banlist, banIndex)
        deferrals.update("Ban has expired, unbanning user.")
      else
        local kickReason = (Lang:t("ban_info", {
          staffMember = banEntry.StaffMember,
          banReason = banEntry.Reason,
          banDate = banEntry.banDate,
          expirationDate = os.date("%x", banEntry.Length),
          expirationTime = os.date("%X", banEntry.Length),
          banId = banEntry.uuid
        }))
        deferrals.done(kickReason)
        return
      end
    end
  end

  SaveBanList(banlist)
  Wait(500)
  deferrals.done()
end)
