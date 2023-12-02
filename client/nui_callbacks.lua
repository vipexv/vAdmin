RegisterNUICallback('hideFrame', function(_, cb)
  toggleNuiFrame(false)
  cb({})
end)

RegisterNuiCallback("vadmin:client:unban", function(banID)
  if not banID then
    return Debug("(Error) [nuiCallback:vadmin:client:unban] first param is nil/null, returning.")
  end

  TriggerServerEvent("vadmin:server:unban", banID)
end)


RegisterNUICallback("vadmin:client:offlineban", function(data, cb)
  if not next(data) then
    return Debug("(Error) [nuiCallback:vadmin:client:offlineban] first param is nil/null, returning.")
  end

  TriggerServerEvent("vadmin:server:offlineban", data)
  cb({})
end)

RegisterNuiCallback("vadmin:client:spectate", function(playerData, cb)
  if not next(playerData) then
    return Debug("(Error)  [nuiCallback:vadmin:client:spectate] first param is nil/null, returning.")
  end

  local sourceId = GetPlayerServerId(PlayerId())

  if tostring(sourceId) == tostring(playerData.id) then
    return Notify("What the fluff dude, you cannot spectate yourself.")
  end

  TriggerServerEvent("vadmin:server:spectate", playerData)
  cb({})
end)

RegisterNuiCallback("vadmin:client:tp", function(data, cb)
  if not next(data) then
    return Debug("(Error) [vadmin:client:tp] data param is null.")
  end

  if not Permissions.Teleport then return end

  TriggerServerEvent("vadmin:server:tp", data)

  cb({})
end)

RegisterNuiCallback("vadmin:client:options", function(data, cb)
  if not next(data) then
    return Debug("(Error) [vadmin:client:options] data param is null.")
  end

  local ped = PlayerPedId()

  -- print(json.encode(data))

  if data.health then
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    return
  end
  if data.armor then
    SetPedArmour(ped, 100)
    return
  end
  if data.playerNames then
    State.playerNames = not State.playerNames
    createGamerTagThread()
    return
  end

  TriggerServerEvent("vadmin:server:options", data)
  cb({})
end)


RegisterNuiCallback("vadmin:client:rev", function(data)
  if not next(data) then
    return Debug("(Error) [vadmin:nui_cb:rev] data param is null.")
  end

  TriggerServerEvent("vadmin:server:rev", data)
end)

RegisterNuiCallback("vadmin:client:frz", function(data)
  if not next(data) then
    return Debug("(Error) [vadmin:nui_cb:frz] data param is null.")
  end
  TriggerServerEvent("vadmin:server:frz", data)
end)

RegisterNuiCallback("vadmin:nui_cb:ban", function(data, cb)
  if not next(data) then
    return Debug("(Error) [vadmin:nui_cb:ban] data param is null.")
  end

  if tonumber(data.target_id) == GetPlayerServerId(PlayerId()) then
    return Notify("What the fluff dude, you can't ban yourself :o")
  end

  TriggerServerEvent("vadmin:server:ban", data)
  cb({})
end)


RegisterNuiCallback("vadmin:nui_cb:kick", function(data, cb)
  if not next(data) then
    return Debug("(Error) [vadmin:nui_cb:kick] data param is null.")
  end

  if tonumber(data.target_id) == GetPlayerServerId(PlayerId()) then
    return Notify("What the fluff dude, you can't kick yourself :o")
  end

  TriggerServerEvent("vadmin:server:kick", data)
  cb({})
end)
