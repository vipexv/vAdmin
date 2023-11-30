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

  local playerDetectedName = GetPlayerName(source)

  if type(playerDetectedName) ~= "string" then
    Debug("(Error) [eventHandler:playerJoining] Player name isn't a string, Player name type: ", type(playerDetectedName))
    return
  end

  for permissionIndex = 1, #Config.PermissionSystem do
    local permission = Config.PermissionSystem[permissionIndex]
    if IsPlayerAceAllowed(source, permission.AcePerm) then
      AdminData[tonumber(source)] = permission.AllowedPermissions
      AdminData[tonumber(source)].id = source
      Debug("Added joining player to the AdminData table: ", GetPlayerName(source), " AdminData Table: ",
        json.encode(AdminData))
    end
  end

  local playerData = CPlayer:new(source)

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

      for permissionsIndex = 1, #Config.PermissionSystem do
        local permission = Config.PermissionSystem[permissionsIndex]
        if IsPlayerAceAllowed(player, permission.AcePerm) then
          AdminData[tonumber(player)] = permission.AllowedPermissions
          AdminData[tonumber(player)].id = player
          Debug("Added player to the AdminData table: ", GetPlayerName(player), " AdminData Table: ",
            json.encode(AdminData))
        end
      end

      local playerData = CPlayer:new(player)

      Debug("[Thread] playerData variable: ", json.encode(playerData))

      PlayerList[tonumber(player)] = playerData
    end
  end)
end)

RegisterNetEvent("vadmin:plist", function()
  if not source then
    return Debug("(Error) [netEvent:vadmin:plist] source is nil/null")
  end


  -- Update it only for the player that called it.

  TriggerClientEvent("UIMessage", source, "nui:plist", PlayerList)

  -- Update it for everyone.

  -- TriggerClientEvent("UIMessage", -1, "nui:plist", PlayerList)

  -- Loop Through Admin's and update it for each one.

  -- for i = 1, #AdminData do
  --   local admin = AdminData[i]
  --   TriggerClientEvent("UIMessage", admin.id, "nui:plist", PlayerList)
  -- end
end)

RegisterNetEvent("vadmin:clist", function()
  if not source then
    return Debug("(Error) [netEvent:vadmin:clist] source is nil/null")
  end


  -- Update it only for the player that called it.
  TriggerClientEvent("UIMessage", source, "nui:clist", PlayerCache)

  -- Update it for everyone.
  -- TriggerClientEvent("UIMessage", -1, "nui:clist", PlayerCache)

  -- Loop Through Admin's and update it for each one.
  -- for i = 1, #AdminData do
  --   local admin = AdminData[i]
  --   TriggerClientEvent("UIMessage", admin.id, "nui:clist", PlayerCache)
  -- end
end)

RegisterNetEvent("vadmin:getPermissions", function()
  if not source then
    return Debug("(Error) [netEvent:vadmin:getPermissions] source is nil/null")
  end

  if not AdminData[tonumber(source)] then
    TriggerClientEvent("vadmin:cb:updatePermissions", source, Config.DefaultPermissions.AllowedPermissions)
    return
  end

  TriggerClientEvent("vadmin:cb:updatePermissions", source, AdminData[tonumber(source)])
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

RegisterNetEvent("VAdmin:Server:K", function(data)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  if not sourcePerms["Kick"] then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  local targetName = GetPlayerName(data.target_id) or "Error Getting Player name"
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
        value = ('%s (ID - [%s])'):format(GetPlayerName(source), source),
        inline = true
      },
      {
        name = 'Admin identifiers',
        value = organizeIdentifiers(source),
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
  if not Config.ChatMessages then return end

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
        value = ('%s (ID - [%s])'):format(GetPlayerName(source), source),
        inline = true
      },
      {
        name = 'Admin identifiers',
        value = organizeIdentifiers(source),
        inline = false
      },
    }
  })

  if data.clearChat then
    local sourcePerms = AdminData[tonumber(source)]

    if not sourcePerms then
      return DropPlayer(source, Lang:t("cheating_kick_message"))
    end

    if not sourcePerms["Clear Chat"] then
      return DropPlayer(source, Lang:t("cheating_kick_message"))
    end
    TriggerClientEvent("chat:clear", -1)
    return
  end

  if data.carWipe then
    local sourcePerms = AdminData[tonumber(source)]

    if not sourcePerms then
      return DropPlayer(source, Lang:t("cheating_kick_message"))
    end

    if not sourcePerms["Car Wipe"] then
      return DropPlayer(source, Lang:t("cheating_kick_message"))
    end

    if Config.ChatMessages then
      CreateThread(function()
        TriggerClientEvent('chat:addMessage', -1, {
          template = [[
                            <div style="
                                    padding: 0.45vw;
                                    margin: 0.55vw;
                                    padding: 10px;
                                    width: 92.50%;
                                    background: rgba(255, 0, 0, 1);
                                    box-shadow: 0px 4px 6px 1px rgba(0, 0, 0, 0.5);
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
                                    background: rgba(255, 0, 0, 1);
                                    box-shadow: 0px 4px 6px 1px rgba(0, 0, 0, 0.5);
                                    border-radius: 4px;
                            ">
                                <i class="fas fa-robot"></i> Car wipe in 10 seconds.
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
                                    background: rgba(255, 0, 0, 1);
                                    box-shadow: 0px 4px 6px 1px rgba(0, 0, 0, 0.5);
                                    border-radius: 4px; ">
                                <i class="fas fa-robot"></i> Car wipe Completed.
                            </div>
                        ]],
        })
      end)
    end

    Wait(30000)
    for _, v in pairs(GetAllVehicles()) do
      if (GetPedInVehicleSeat(v, -1) == 0) then
        DeleteEntity(v)
      end
    end
  end
end)

RegisterNetEvent("VAdmin:Server:B", function(data)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  if not sourcePerms["Ban"] then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end


  if not data.target_id then
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
    StaffMember = GetPlayerName(source) or "Unknown",
    playerName = GetPlayerName(data.target_id) or "Unknown",
    identifiers = GetPlayerIdentifiersWithoutIP(data.target_id),
    tokens = GetPlayerTokens(data.target_id),
    Length = os.time() + BanLengths[data.length],
    LengthString = data.length,
    UnbanDate = unbanDate,
    banDate = banDate,
    uuid = banID,
    Reason = data.reason
  }

  table.insert(banList, BanData)

  DropPlayer(data.target_id,
    Lang:t("drop_player_ban_message", {
      staff_member_name = GetPlayerName(source),
      staff_member_id = source,
      ban_reason = data.reason,
      ban_length = data.length,
      ban_id = banID
    }))

  SaveBanList(banList)

  discordLog({
    title = '[V] Admin Menu Logs',
    description = 'Player Banned',
    webhook = Webhooks.Ban,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(source), source),
        inline = true
      },
      {
        name = 'Admin identifiers',
        value = organizeIdentifiers(source),
        inline = false
      },
      {
        name = 'Target',
        value = ("%s - (ID - %s)"):format(targetName, targetId),
        inline = false
      },
      {
        name = 'Ban Info',
        value = ("Reason: %s \n Expires In: %s (%s) \n Ban id: %s"):format(data.reason, unbanDate, data.length, banID),
        inline = false
      },
    }
  })

  showNotification(source, "Successfully banned the player!")

  if not Config.ChatMessages then return end

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
                            PLAYER BANNED -
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
      ("Player: %s (ID - %s)"):format(targetName, targetId),
      ("Banned by: %s"):format(GetPlayerName(source) or "Error getting player name"),
      ("Length: %s"):format(data.length),
      ("Reason: %s"):format(data.reason),
      ("Ban date: %s"):format(banDate)
    }
  })
end)

RegisterNetEvent("vadmin:server:tp", function(info)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  if not sourcePerms["Teleport"] then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  local sourcePed = GetPlayerPed(source)
  local targetPed = GetPlayerPed(info.id)
  local sourcePedCoords = GetEntityCoords(sourcePed)
  local targetPedCoords = GetEntityCoords(targetPed)


  discordLog({
    title = '[V] Admin Menu Logs',
    description = ("> Option Triggered: %s"):format(info.Option),
    webhook = Webhooks.Teleport,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(source), source),
        inline = true
      },
      {
        name = 'Admin identifiers',
        value = organizeIdentifiers(source),
        inline = false
      },
      {
        name = 'Target',
        value = ("%s - (ID - %s)"):format(GetPlayerName(info.id) or "Error Getting Target name", info.id),
        inline = false
      },
    }
  })


  if info.Option == "Goto" then
    SetEntityCoords(sourcePed, targetPedCoords)
    return
  end

  if info.Option == "Bring" then
    SetEntityCoords(targetPed, sourcePedCoords)
    return
  end
end)

RegisterNetEvent("vadmin:server:rev", function(data)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  if not sourcePerms["Revive"] then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end
  exports["Legacy"]:RevivePlayer(data.id)
end)

RegisterNetEvent("vadmin:server:frz", function(data)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  if not sourcePerms["Freeze"] then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  discordLog({
    title = '[V] Admin Menu Logs',
    description = '> Option Triggered: Freeze Player',
    webhook = Webhooks.Freeze,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(source), source),
        inline = true
      },
      {
        name = 'Admin identifiers',
        value = organizeIdentifiers(source),
        inline = false
      },
      {
        name = 'Target',
        value = ("%s"):format(GetPlayerName(data.id) or "Error Getting Target name"),
        inline = false
      },
    }
  })

  if PlayerList[tonumber(data.id)] then
    local isFrozen = PlayerList[tonumber(data.id)].frozen
    if isFrozen then
      FreezeEntityPosition(GetPlayerPed(data.id), false)
      PlayerList[tonumber(data.id)].frozen = false
      Debug(("[netEvent:vadmin:server:frz] isFrozen var: %s \n player data: %s"):format(isFrozen,
        json.encode(PlayerList[data.id])))
      return
    end

    FreezeEntityPosition(GetPlayerPed(data.id), true)
    PlayerList[tonumber(data.id)].frozen = true
  else
    return Debug("(Error) [netEvent:vadmin:server:frz] Unable to locate player inside the PlayerList table.")
  end

  -- if FrozenPlayers[data.id] then
  --   FreezeEntityPosition(GetPlayerPed(data.id), false)
  --   FrozenPlayers[data.id] = nil
  --   return
  -- end

  -- FreezeEntityPosition(GetPlayerPed(data.id), true)
  -- FrozenPlayers[data.id] = {}
end)


RegisterNetEvent("vadmin:server:offlineban", function(data)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  if not sourcePerms["Freeze"] then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
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

  -- print(("(DEBUG) Ban id: %s"):format(banID))

  local banData = {
    StaffMember = GetPlayerName(source) or "Error grabbing the player name",
    identifiers = data.identifiers,
    playerName = data.playerName,
    tokens = data.tokens,
    Length = os.time() + BanLengths[data.length],
    LengthString = data.length,
    UnbanDate = unbanDate,
    banDate = banDate,
    uuid = banID,
    Reason = data.reason
  }

  table.insert(banList, banData)

  SaveBanList(banList)

  if Config.ChatMessages then
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
  end

  discordLog({
    title = '[V] Admin Menu Logs',
    description = 'Offline Ban',
    webhook = Webhooks.OfflineBan,
    fields = {
      {
        name = 'Admin',
        value = ('%s (ID - [%s])'):format(GetPlayerName(source), source),
        inline = true
      },
      {
        name = 'Admin identifiers',
        value = organizeIdentifiers(source),
        inline = false
      },
      {
        name = 'Target',
        value = ("%s"):format(data.playerName),
        inline = false
      },
      {
        name = 'Target identifiers',
        value = ("```%s```"):format(table.concat(data.identifiers, "\n")),
        inline = false
      },
      {
        name = 'Target HWIDs',
        value = ("```%s```"):format(table.concat(data.tokens, "\n")),
        inline = false
      },
      {
        name = 'Offline Ban Info',
        value = ("Reason: %s \n Expires in: %s (%s) \n Ban id: %s"):format(data.reason, unbanDate, data.length, banID),
        inline = false
      },
    }
  })
end)

RegisterNetEvent("vadmin:server:spectate", function(data)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  if not sourcePerms["Spectate"] then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  local targetPed = GetPlayerPed(data.id)
  if not targetPed then return print("Target Ped is null in vadmin:server:spectate") end
  local targetBucket = GetPlayerRoutingBucket(data.id)
  local srcBucket = GetPlayerRoutingBucket(source)
  local sourcePlayerStateBag = Player(source).state

  if srcBucket ~= targetBucket then
    print(('Target and source buckets differ | src: %s, bkt: %i | tgt: %s, bkt: %i'):format(source, srcBucket, data.id,
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
        value = ('%s (ID - [%s])'):format(GetPlayerName(source), source),
        inline = true
      },
      {
        name = 'Admin identifiers',
        value = organizeIdentifiers(source),
        inline = false
      },
      {
        name = "Target Info",
        value = ("Target name: %s (ID - %s)"):format(GetPlayerName(data.id) or "Error Grabbing Target name", data.id)
      }
    }
  })
  TriggerClientEvent("vadmin:spectate:start", source, data.id, GetEntityCoords(targetPed))
end)


RegisterNetEvent("vadmin:server:spectate:end", function()
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  if not sourcePerms["Spectate"] then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  local sourcePlayerStateBag = Player(source).state

  local prevRoutBucket = sourcePlayerStateBag.spectateReturnBucket
  if prevRoutBucket then
    SetPlayerRoutingBucket(source, prevRoutBucket)
    sourcePlayerStateBag.spectateReturnBucket = nil
  end
end)

RegisterNetEvent("vadmin:server:unban", function(banID)
  local sourcePerms = AdminData[tonumber(source)]

  if not sourcePerms then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  if not sourcePerms["Unban"] then
    return DropPlayer(source, Lang:t("cheating_kick_message"))
  end

  if not banID then
    return showNotification(source, "Ban ID cannot be null!")
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
      targetHwids = banData.tokens
      targetIdentifiers = banData.identifiers
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
          value = ('%s (ID - [%s])'):format(GetPlayerName(source), source),
          inline = true
        },
        {
          name = 'Admin identifiers',
          value = organizeIdentifiers(source),
          inline = false
        },
        {
          name = "Target Info",
          value = ("Target name: %s"):format(
            targetName or "Error Grabbing Target name"
          )
        },
        {
          name = "Target identifiers",
          value = ("```%s```"):format(table.concat(targetIdentifiers, "\n"))
        },
        {
          name = "Target HWIDs",
          value = ("```%s```"):format(table.concat(targetHwids, "\n"))
        }
      }
    })

    showNotification(source, "Player was found and unbanned!")
  else
    showNotification(source, "Error Player with the specified Ban ID was not found!")
  end
end)

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
