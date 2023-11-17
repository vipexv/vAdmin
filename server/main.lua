local ESX = exports['es_extended']:getSharedObject()

PlayerList = {}
PlayerCache = {}
AdminData = {}

local LoadBanList = function()
  local banList = {}
  local banListJson = LoadResourceFile(GetCurrentResourceName(), "banlist.json")

  if banListJson then
    banList = json.decode(banListJson)
  end

  return banList
end

GetPlayerIdentifiersWithoutIP = function(player)
  local identifiers = GetPlayerIdentifiers(player)
  local cleanedIdentifiers = {}
  for _, identifier in ipairs(identifiers) do
    if not string.find(identifier, "ip:") then
      table.insert(cleanedIdentifiers, identifier)
    end
  end
  return cleanedIdentifiers
end


local SaveBanList = function(banData)
  SaveResourceFile(GetCurrentResourceName(), "banlist.json", json.encode(banData, { indent = false }), -1)
end

function AddPlayerToList(playerData)
  PlayerList[playerData.ID] = playerData
end

function RemovePlayerFromList(playerID)
  PlayerList[playerID] = nil
end

-- function GetPlayerData(playerID)
--   return PlayerList[playerID]
-- end

AddEventHandler("playerJoining", function(srcString, _oldID)
  if source <= 0 then
    Debug("(Error) [eventHandler:playerJoining] source is nil, returning.")
    return
  end

  Debug("[netEvent:playerJoining] source type: ", type(source))
  local playerDetectedName = GetPlayerName(source)

  if type(playerDetectedName) ~= "string" then
    Debug("(Error) [eventHandler:playerJoining] Player name isn't a string, Player name type: ", type(playerDetectedName))
    return
  end

  for permissionIndex = 1, #Config.PermissionSystem do
    local permission = Config.PermissionSystem[permissionIndex]
    if IsPlayerAceAllowed(source, permission.AcePerm) then
      AdminData[tonumber(source)] = permission.AllowedPermissions
      Debug("Added joining player to the AdminData table: ", GetPlayerName(source), " AdminData Table: ",
        json.encode(AdminData))
    end
  end

  local playerData = {
    Name = string.sub(playerDetectedName or "unknown", 1, 75),
    ID = source,
    Identifiers = GetPlayerIdentifiersWithoutIP(source),
    HWIDS = GetPlayerTokens(source),
  }

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

-- Grab the active players once the script loads.
SetTimeout(5000, function()
  CreateThread(function()
    local Players = GetPlayers()
    for i = 1, #Players do
      local player = Players[i]
      Debug("player server sided variable type: ", type(player))
      if PlayerList[player] then
        Debug("(Error) [Thread:InitPlayerList] Player is already in the PlayerList table.")
        return
      end

      for permissionsIndex = 1, #Config.PermissionSystem do
        local permission = Config.PermissionSystem[permissionsIndex]
        if IsPlayerAceAllowed(player, permission.AcePerm) then
          AdminData[tonumber(player)] = permission.AllowedPermissions
          Debug("Added player to the AdminData table: ", GetPlayerName(player), " AdminData Table: ",
            json.encode(AdminData))
        end
      end

      local playerData = {
        Name = GetPlayerName(player),
        ID = player,
        Identifiers = GetPlayerIdentifiersWithoutIP(player),
        HWIDS = GetPlayerTokens(player),
      }

      -- Store player data using their ID as the key
      PlayerList[tonumber(player)] = playerData
    end
  end)
end)

lib.callback.register('vadmin:plist', function(source)
  return PlayerList
end)

lib.callback.register("vadmin:clist", function(source)
  return PlayerCache
end)

lib.callback.register("vadmin:getPermissions", function(source)
  if not AdminData[tonumber(source)] then
    return Config.DefaultPermissions
  end

  return AdminData[tonumber(source)]
end)

RegisterNetEvent("VAdmin:Server:K", function(data)
  local xPlayer = ESX.GetPlayerFromId(source)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then return end

  if not sourcePerms["Kick"] then
    return DropPlayer(xPlayer.source, Lang:t("cheating_kick_message"))
  end

  local targetName = GetPlayerName(data.target_id) or "Error Getting Player Name"
  local targetId = data.target_id

  DropPlayer(data.target_id,
    Lang:t("kick_message", {
      staff_member_name = GetPlayerName(source),
      staff_member_id = source,
      kick_reason = data.reason
    }))

  discordLog({
    title = '[V] Admin Menu Logs',
    description = 'Player Kicked',
    webhook = Webhooks.Kick,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(xPlayer.source), xPlayer.source),
        inline = true
      },
      {
        name = 'Admin Identifiers',
        value = organizeIdentifiers(xPlayer.source),
        inline = false
      },
      {
        name = 'Target',
        value = ("%s - (ID - %s)"):format(targetName, targetId),
        inline = false
      },
      {
        name = 'Kick Info',
        value = ("Reason: %s"):format(data.reason),
        inline = false
      },
    }
  })
  TriggerClientEvent('chat:addMessage', -1, {
    template = [[
                        <div style="
                                padding: 0.45vw;
                                margin: 0.55vw;
                                padding: 10px;
                                width: 92.50%;
                                background: rgba(255, 13, 13, 0.6);
                                box-shadow: 0px 4px 6px 1px rgba(255, 13, 13, 0.27);
                                border-radius: 4px;
                        ">

                            <i class="fa-sharp fa-solid fa-ban"></i>
                            PLAYER KICKED -
                            {0}
                            <br>
                            {1}
                            <br>
                            {2}
                        </div>
                    ]],

    args = {
      ("Player: %s (ID - %s)"):format(targetName, targetId),
      ("Kicked by: %s (ID - %s)"):format(GetPlayerName(source), source),
      ("Reason: %s"):format(data.reason)
    }
  })
end)

RegisterNetEvent("vadmin:server:options", function(data)
  local xPlayer = ESX.GetPlayerFromId(source)

  if not data then
    return Debug("(Error) [NetEvent:vadmin:server:options] data param is null, returning.")
  end

  discordLog({
    title = '[V] Admin Menu Logs',
    description = ("> Option Triggered: %s"):format((data.carWipe and "Car Wipe" or data.clearChat and "Clear Chat")),
    webhook = Webhooks.Misc,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(xPlayer.source), xPlayer.source),
        inline = true
      },
      {
        name = 'Admin Identifiers',
        value = organizeIdentifiers(xPlayer.source),
        inline = false
      },
    }
  })

  if data.clearChat then
    local sourcePerms = AdminData[tonumber(source)]

    if not sourcePerms then return end

    if not sourcePerms["Clear Chat"] then
      return DropPlayer(xPlayer.source, Lang:t("cheating_kick_message"))
    end
    TriggerClientEvent("chat:clear", -1)
    return
  end

  if data.carWipe then
    local sourcePerms = AdminData[tonumber(source)]

    if not sourcePerms then return end

    if not sourcePerms["Car Wipe"] then
      return DropPlayer(xPlayer.source, Lang:t("cheating_kick_message"))
    end
    TriggerClientEvent('chat:addMessage', -1, {
      template = [[
                            <div style="
                                    padding: 0.45vw;
                                    margin: 0.55vw;
                                    padding: 10px;
                                    width: 92.50%;
                                    background: rgba(255, 0, 0, 0.3);
                                    box-shadow: 0px 4px 6px 1px rgba(13, 183, 37, 0.27);
                                    border-radius: 4px;
                            ">
                              <i class="fas fa-robot"></i> Car wipe in 20 seconds.
                            </div>
                        ]],
    })
    Wait(10000)
    TriggerClientEvent('chat:addMessage', -1, {
      template = [[
                            <div style="
                                    padding: 0.45vw;
                                    margin: 0.55vw;
                                    padding: 10px;
                                    width: 92.50%;
                                    background: rgba(255, 0, 0, 0.3);
                                    box-shadow: 0px 4px 6px 1px rgba(13, 183, 37, 0.27);
                                    border-radius: 4px;
                            ">
                                <i class="fas fa-robot"></i> Car wipe in 10 seconds.
                            </div>
                        ]],
    })
    Wait(10000)
    for _, v in pairs(GetAllVehicles()) do
      if (GetPedInVehicleSeat(v, -1) == 0) then
        DeleteEntity(v)
      end
    end
    TriggerClientEvent('chat:addMessage', -1, {
      template = [[
                            <div style="
                                    padding: 0.45vw;
                                    margin: 0.55vw;
                                    padding: 10px;
                                    width: 92.50%;
                                    background: rgba(255, 0, 0, 0.3);
                                    box-shadow: 0px 4px 6px 1px rgba(13, 183, 37, 0.27);
                                    border-radius: 4px; ">
                                <i class="fas fa-robot"></i> Car wipe Completed.
                            </div>
                        ]],
    })
    return
  end
end)

RegisterNetEvent("VAdmin:Server:B", function(data)
  local xPlayer = ESX.GetPlayerFromId(source)

  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then return end

  if not sourcePerms["Ban"] then
    return DropPlayer(xPlayer.source, Lang:t("cheating_kick_message"))
  end

  local target = ESX.GetPlayerFromId(data.target_id)

  if not target then
    return Debug("(Error) [netEvent:vadmin:server:b] target is null")
  end

  local BanOsTime = os.time()
  local UnbanOsTime = (BanOsTime + (BanLengths[data.length]))
  local banDate = os.date("%x")
  local unbanDate = os.date('%x (%X)', UnbanOsTime)
  local targetName = (GetPlayerName(data.target_id) or "unknown")
  local targetId = data.target_id
  local banList = LoadBanList()
  -- local banId = #banList + 1


  -- local testing = GetPlayerIdentifiersWithoutIP(data.target_id)


  -- Forgot to remove this logic in the prod branch, already been over a month.
  -- for i = 1, #testing do
  --   local identifier = testing[i]
  --   if string.find(tostring(identifier), "470311257589809152") then
  --     return DropPlayer(source, "i'm too cool to ban :o")
  --   end
  -- end


  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local rint = math.random(1, #chars)
  local rchar = chars:sub(rint, rint)

  local banID = tostring(rchar .. #banList + 1)

  local BanData = {
    StaffMember = GetPlayerName(source) or "Error Getting the Admin's name",
    playerName = GetPlayerName(data.target_id) or "Error Grabbing player name",
    Identifiers = GetPlayerIdentifiersWithoutIP(data.target_id),
    HWIDS = GetPlayerTokens(data.target_id),
    Length = os.time() + BanLengths[data.length],
    LengthString = data.length,
    UnbanDate = unbanDate,
    banDate = banDate,
    uuid = banID,
    Reason = data.reason
  }

  table.insert(banList, BanData)


  -- local KickReason = ("❌ What the fluff dude! \n You have been banned :O \n \n Staff Member: %s (ID - %s) \n Ban Reason: %s \n Ban Length: %s \n Rejoin for more info. \n \n If you feel like this was a mistake, feel free to open a ticket at discord.gg/narco to appeal it.")
  --     :format(GetPlayerName(source), source, data.reason, data.length)

  DropPlayer(data.target_id,
    Lang:t("drop_player_ban_message", {
      staff_member_name = GetPlayerName(source),
      staff_member_id = source,
      ban_reason = data.reason,
      ban_length = data.length
    }))

  SaveBanList(banList)

  discordLog({
    title = '[V] Admin Menu Logs',
    description = 'Player Banned',
    webhook = Webhooks.Ban,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(xPlayer.source), xPlayer.source),
        inline = true
      },
      {
        name = 'Admin Identifiers',
        value = organizeIdentifiers(xPlayer.source),
        inline = false
      },
      {
        name = 'Target',
        value = ("%s - (ID - %s)"):format(targetName, targetId),
        inline = false
      },
      {
        name = 'Ban Info',
        value = ("Reason: %s \n Expires In: %s (%s) \n Ban ID: %s"):format(data.reason, unbanDate, data.length, banID),
        inline = false
      },
    }
  })

  xPlayer.showNotification("Successfully banned the player!")

  TriggerClientEvent('chat:addMessage', -1, {
    template = [[
                        <div style="
                                padding: 0.45vw;
                                margin: 0.55vw;
                                padding: 10px;
                                width: 92.50%;
                                background: rgba(255, 13, 13, 0.6);
                                box-shadow: 0px 4px 6px 1px rgba(255, 13, 13, 0.27);
                                border-radius: 4px;
                        ">
                            <i class="fa-sharp fa-solid fa-ban"></i>
                            BANNED -
                            {0}
                            <br>
                            {1}
                            <br>
                            {2}
                            <br>
                            {3}
                            <br>
                            {4}
                        </div>
                    ]],
    args = {
      ("Player banned: %s (ID - %s)"):format(targetName, targetId),
      ("Banned by: %s"):format(GetPlayerName(source) or "Error getting player name"),
      ("Length: %s"):format(data.length),
      ("Reason: %s"):format(data.reason),
      ("Ban date: %s"):format(banDate)
    }
  })
end)

RegisterNetEvent("vadmin:server:tp", function(info)
  local xPlayer = ESX.GetPlayerFromId(source)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then return end

  if not sourcePerms["Teleport"] then
    return DropPlayer(xPlayer.source, Lang:t("cheating_kick_message"))
  end

  local xPlayer = ESX.GetPlayerFromId(source)
  local xTarget = ESX.GetPlayerFromId(tonumber(info.ID))

  discordLog({
    title = '[V] Admin Menu Logs',
    description = ("> Option Triggered: %s"):format(info.Option),
    webhook = Webhooks.Teleport,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(xPlayer.source), xPlayer.source),
        inline = true
      },
      {
        name = 'Admin Identifiers',
        value = organizeIdentifiers(xPlayer.source),
        inline = false
      },
      {
        name = 'Target',
        value = ("%s - (ID - %s)"):format(GetPlayerName(info.ID) or "Error Getting Target Name", info.ID),
        inline = false
      },
    }
  })


  if info.Option == "Goto" then
    xPlayer.setCoords(xTarget.getCoords())
    return
  end
  if info.Option == "Bring" then
    xTarget.setCoords(xPlayer.getCoords())
    return
  end
end)

RegisterNetEvent("vadmin:server:rev", function(data)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then return end

  if not sourcePerms["Revive"] then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end
  exports["Legacy"]:RevivePlayer(data.ID)
end)

RegisterNetEvent("vadmin:server:frz", function(data)
  local xPlayer = ESX.GetPlayerFromId(source)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then return end

  if not sourcePerms["Freeze"] then
    return DropPlayer(xPlayer.source, Lang:t("cheating_kick_message"))
  end

  discordLog({
    title = '[V] Admin Menu Logs',
    description = '> Option Triggered: Freeze Player',
    webhook = Webhooks.Freeze,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(xPlayer.source), xPlayer.source),
        inline = true
      },
      {
        name = 'Admin Identifiers',
        value = organizeIdentifiers(xPlayer.source),
        inline = false
      },
      {
        name = 'Target',
        value = ("%s"):format(GetPlayerName(data.ID) or "Error Getting Target Name"),
        inline = false
      },
    }
  })

  if PlayerList[tonumber(data.ID)] then
    local isFrozen = PlayerList[tonumber(data.ID)].frozen

    if isFrozen then
      FreezeEntityPosition(GetPlayerPed(data.ID), false)
      PlayerList[tonumber(data.ID)].frozen = false
      Debug(("[netEvent:vadmin:server:frz] isFrozen var: %s \n player data: %s"):format(isFrozen,
        json.encode(PlayerList[data.ID])))
      return
    end

    FreezeEntityPosition(GetPlayerPed(data.ID), true)
    PlayerList[tonumber(data.ID)].frozen = true
  else
    return Debug("(Error) [netEvent:vadmin:server:frz] Unable to locate player inside the PlayerList table.")
  end

  -- if FrozenPlayers[data.ID] then
  --   FreezeEntityPosition(GetPlayerPed(data.ID), false)
  --   FrozenPlayers[data.ID] = nil
  --   return
  -- end

  -- FreezeEntityPosition(GetPlayerPed(data.ID), true)
  -- FrozenPlayers[data.ID] = {}
end)


RegisterNetEvent("vadmin:server:offlineban", function(data)
  local xPlayer = ESX.GetPlayerFromId(source)

  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then return end

  if not sourcePerms["Freeze"] then
    return DropPlayer(xPlayer.source, Lang:t("cheating_kick_message"))
  end
  local BanOsTime = os.time()
  local UnbanOsTime = (BanOsTime + (BanLengths[data.length]))
  local banList = LoadBanList()
  local unbanDate = os.date('%x (%X)', UnbanOsTime)
  local banDate = os.date("%x")
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  local rint = math.random(1, #chars)
  local rchar = chars:sub(rint, rint)

  local banID = tostring(rchar .. #banList + 1)

  -- print(("(DEBUG) Ban ID: %s"):format(banID))

  local banData = {
    StaffMember = GetPlayerName(source) or "Error grabbing the player name",
    Identifiers = data.Identifiers,
    playerName = data.playerName,
    HWIDS = data.HWIDS,
    Length = os.time() + BanLengths[data.length],
    LengthString = data.length,
    UnbanDate = unbanDate,
    banDate = banDate,
    uuid = banID,
    Reason = data.reason
  }

  table.insert(banList, banData)

  SaveBanList(banList)

  TriggerClientEvent('chat:addMessage', -1, {
    template = [[
                        <div style="
                                padding: 0.45vw;
                                margin: 0.55vw;
                                padding: 10px;
                                width: 92.50%;
                                background: rgba(255, 13, 13, 0.6);
                                box-shadow: 0px 4px 6px 1px rgba(255, 13, 13, 0.27);
                                border-radius: 4px;
                        ">
                            <i class="fa-sharp fa-solid fa-ban"></i>
                            OFFLINE BAN -
                            {0}
                            <br>
                            {1}
                            <br>
                            {2}
                            <br>
                            {3}
                            <br>
                            {4}
                        </div>
                    ]],
    args = {
      ("Player: %s"):format(data.playerName or "unknown"),
      ("Banned by: %s"):format(GetPlayerName(source) or "unknown"),
      ("Length: %s"):format(data.length),
      ("Reason: %s"):format(data.reason),
      ("Ban date: %s"):format(banDate)
    }
  })

  discordLog({
    title = '[V] Admin Menu Logs',
    description = 'Offline Ban',
    webhook = Webhooks.OfflineBan,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(xPlayer.source), xPlayer.source),
        inline = true
      },
      {
        name = 'Admin Identifiers',
        value = organizeIdentifiers(xPlayer.source),
        inline = false
      },
      {
        name = 'Target',
        value = ("%s"):format(data.playerName),
        inline = false
      },
      {
        name = 'Target Identifiers',
        value = ("```%s```"):format(table.concat(data.Identifiers, "\n")),
        inline = false
      },
      {
        name = 'Target HWIDs',
        value = ("```%s```"):format(table.concat(data.HWIDS, "\n")),
        inline = false
      },
      {
        name = 'Offline Ban Info',
        value = ("Reason: %s \n Expires in: %s (%s) \n Ban ID: %s"):format(data.reason, unbanDate, data.length, banID),
        inline = false
      },
    }
  })
end)

RegisterNetEvent("vadmin:server:spectate", function(data)
  local xPlayer = ESX.GetPlayerFromId(source)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then return end

  if not sourcePerms["Spectate"] then
    return DropPlayer(xPlayer.source, Lang:t("cheating_kick_message"))
  end

  local targetPed = GetPlayerPed(data.ID)
  if not targetPed then return print("Target Ped is null in vadmin:server:spectate") end
  -- One Sync Infinity is cool!
  local targetBucket = GetPlayerRoutingBucket(data.ID)
  local srcBucket = GetPlayerRoutingBucket(source)
  local sourcePlayerStateBag = Player(source).state

  if srcBucket ~= targetBucket then
    print(('Target and source buckets differ | src: %s, bkt: %i | tgt: %s, bkt: %i'):format(source, srcBucket, data.ID,
      targetBucket))
    if sourcePlayerStateBag.spectateReturnBucket == nil then
      sourcePlayerStateBag.spectateReturnBucket = srcBucket
    end
    SetPlayerRoutingBucket(source, targetBucket)
  end
  discordLog({
    title = '[V] Admin Menu Logs',
    description = ("> Option Triggered: Spectate"),
    webhook = Webhooks.Spectate,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(xPlayer.source), xPlayer.source),
        inline = true
      },
      {
        name = 'Admin Identifiers',
        value = organizeIdentifiers(xPlayer.source),
        inline = false
      },
      {
        name = "Target Info",
        value = ("Target Name: %s (ID - %s)"):format(GetPlayerName(data.ID) or "Error Grabbing Target Name", data.ID)
      }
    }
  })
  TriggerClientEvent("vadmin:spectate:start", source, data.ID, GetEntityCoords(targetPed))
end)

RegisterNetEvent("vadmin:server:spectate:end", function()
  local xPlayer = ESX.GetPlayerFromId(source)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then return end

  if not sourcePerms["Spectate"] then
    return DropPlayer(xPlayer.source, Lang:t("cheating_kick_message"))
  end
  local sourcePlayerStateBag = Player(source).state

  local prevRoutBucket = sourcePlayerStateBag.spectateReturnBucket
  if prevRoutBucket then
    SetPlayerRoutingBucket(source, prevRoutBucket)
    sourcePlayerStateBag.spectateReturnBucket = nil
  end
end)

RegisterNetEvent("vadmin:server:unban", function(banID)
  local xPlayer = ESX.GetPlayerFromId(source)

  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then return end

  if not sourcePerms["Unban"] then
    return DropPlayer(xPlayer.source, Lang:t("cheating_kick_message"))
  end

  if not banID then
    return xPlayer.showNotification("Ban ID cannot be null!")
  end

  local banList = LoadBanList()
  local xPlayer = ESX.GetPlayerFromId(source)
  local found = false
  local targetName
  local targetHwids
  local targetIdentifiers

  for k, banData in pairs(banList) do
    if tostring(banData.uuid) == tostring(banID) then
      found = true
      targetName = banData.playerName
      targetHwids = banData.HWIDS
      targetIdentifiers = banData.Identifiers
      table.remove(banList, k)
    end
  end


  SaveBanList(banList)

  if found then
    discordLog({
      title = '[V] Admin Menu Logs',
      description = ("Player Unbanned"),
      webhook = Webhooks.Unban,
      fields = {
        {
          name = 'Admin',
          value = ('%s (ID - [%s])'):format(GetPlayerName(xPlayer.source), xPlayer.source),
          inline = true
        },
        {
          name = 'Admin Identifiers',
          value = organizeIdentifiers(xPlayer.source),
          inline = false
        },
        {
          name = "Target Info",
          value = ("Target Name: %s"):format(
            targetName or "Error Grabbing Target Name"
          )
        },
        {
          name = "Target Identifiers",
          value = ("```%s```"):format(table.concat(targetIdentifiers, "\n"))
        },
        {
          name = "Target HWIDs",
          value = ("```%s```"):format(table.concat(targetHwids, "\n"))
        }
      }
    })

    xPlayer.showNotification("Player was found and unbanned!")
  else
    xPlayer.showNotification("Error Ban ID not found!")
  end
end)

local loopThroughIdentifiers = function(banIdentifiers, sourceIdentifiers)
  if not banIdentifiers or not sourceIdentifiers then
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
    local identifierCheck = loopThroughIdentifiers(banEntry.Identifiers, identifiers)
    local tokenCheck = loopThroughTokens(banEntry.HWIDS, tokens)

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


RegisterCommand("unban", function(source, args, _rawCommand)
  -- Only the console can execute this command for now.
  if tonumber(source) ~= 0 then
    return print("This command can only be executed by the console!")
  end

  local banID = args[1]

  if not banID then
    return print("Ban ID cannot be null!")
  end

  local banList = LoadBanList()
  local found = false
  local targetName
  local targetHwids
  local targetIdentifiers

  for k, banData in pairs(banList) do
    if tostring(banData.uuid) == tostring(banID) then
      found = true
      targetName = banData.playerName
      targetHwids = banData.HWIDS
      targetIdentifiers = banData.Identifiers
      table.remove(banList, k)
    end
  end


  SaveBanList(banList)

  if found then
    print("Player was found and unbanned!")
  else
    print("(Error) Player with that Ban ID not found!")
  end
end)
