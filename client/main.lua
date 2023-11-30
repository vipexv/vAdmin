Permissions = {}

State = {
  playerNames = false,
}

-- Player names logic is from txAdmin [https://github.com/tabarra/txAdmin/tree/master] because i think txAdmin is cool :0

local isPlayerIdsEnabled = false
local playerGamerTags = {}

---@param shouldShow boolean
local toggleNuiFrame = function(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  UIMessage('setVisible', shouldShow)
end

RegisterNetEvent("vadmin:cb:updatePermissions", function(perms)
  if not next(perms) then
    return Debug("(Error) [netEvent:vadmin:cb:updatePermissions] Expected a table at first param, got: ",
      type(perms))
  end

  Permissions = perms
end)

RegisterCommand('adminmenu', function()
  UIMessage("nui:adminperms", Permissions)
  if not next(Permissions) then
    -- Using ox_lib
    -- local srcPermissions = lib.callback.await('vadmin:getPermissions', false)


    Notify("[First Load] Checking player permissions...")
    TriggerServerEvent("vadmin:getPermissions")

    Wait(500)

    if not next(Permissions) then
      return Debug("(Error) (command:adminmenu) srcPermissions is null, returning.")
    end

    if not Permissions.Menu then
      return Notify("What the fluff dude, you don't have perms :o")
    end

    UIMessage("nui:adminperms", Permissions)
  end

  if not Permissions.Menu then
    return Notify("What the fluff dude, you don't have perms :o")
  end

  -- ox_lib Soltion
  -- local PlayerList = lib.callback.await('vadmin:plist', false)
  -- local PlayerCache = lib.callback.await("vadmin:clist", false)

  -- if #PlayerList then
  --   UIMessage("nui:plist", PlayerList)
  -- end

  -- if #PlayerCache then
  --   UIMessage("nui:clist", PlayerCache)
  -- end

  -- Standalone Solution for updating the player list and cache list.
  TriggerServerEvent("vadmin:plist")
  TriggerServerEvent("vadmin:clist")

  if Permissions.Menu then
    toggleNuiFrame(true)
  end
end, false)

RegisterNUICallback('hideFrame', function(_, cb)
  toggleNuiFrame(false)
  cb({})
end)

RegisterNetEvent("UIMessage", function(action, data)
  UIMessage(action, data)
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

local setGamerTagFunc = function(targetTag, pid)
  Debug("Settings gamer tag settings for pid:", pid)
  SetMpGamerTagVisibility(targetTag, 0, true)

  SetMpGamerTagHealthBarColour(targetTag, 129)
  SetMpGamerTagAlpha(targetTag, 2, 255)
  SetMpGamerTagVisibility(targetTag, 2, true)


  SetMpGamerTagAlpha(targetTag, 4, 255)
  if NetworkIsPlayerTalking(pid) then
    SetMpGamerTagVisibility(targetTag, 4, true)
    SetMpGamerTagColour(targetTag, 4, 12)
    SetMpGamerTagColour(targetTag, 0, 12)
  else
    SetMpGamerTagVisibility(targetTag, 4, false)
    SetMpGamerTagColour(targetTag, 4, 0)
    SetMpGamerTagColour(targetTag, 0, 0)
  end
end

local clearGamerTagFunc = function(targetTag)
  SetMpGamerTagVisibility(targetTag, 0, false)
  SetMpGamerTagVisibility(targetTag, 2, false)
  SetMpGamerTagVisibility(targetTag, 4, false)
end

local showGamerTags = function()
  local curCoords = GetEntityCoords(PlayerPedId())
  local allActivePlayers = GetActivePlayers()
  for _, pid in ipairs(allActivePlayers) do
    local targetPed = GetPlayerPed(pid)
    if not playerGamerTags[pid] or not IsMpGamerTagActive(playerGamerTags[pid].gamerTag) then
      local playerName = string.sub(GetPlayerName(pid) or "unknown", 1, 75)
      local playerStr = ("[%s] %s"):format(GetPlayerServerId(pid), playerName)
      playerGamerTags[pid] = {
        gamerTag = CreateFakeMpGamerTag(targetPed, playerStr, false, false, 0),
        ped = targetPed
      }

      Debug("Added player to the `playerGamerTags` table for PID: ", pid, "Data: ", json.encode(playerGamerTags[pid]))
    end

    local targetTag = playerGamerTags[pid].gamerTag
    local targetPedCoords = GetEntityCoords(targetPed)
    if #(targetPedCoords - curCoords) <= 300 then
      setGamerTagFunc(targetPed, pid)
    else
      clearGamerTagFunc(targetTag)
    end
  end
end

cleanAllGamerTags = function()
  Debug("Clearing up gamer tags table.")
  for _, v in pairs(playerGamerTags) do
    RemoveMpGamerTag(v.gamerTag)
  end
  playerGamerTags = {}
end

local createGamerTagThread = function()
  CreateThread(function()
    while State.playerNames do
      showGamerTags()
      Wait(150)
    end

    cleanAllGamerTags()
  end)
end


toggleShowPlayerIDs = function(enabled, showNotificiation)
  isPlayerIdsEnabled = enabled
  if isPlayerIdsEnabled then
    createGamerTagThread()
  end

  if not enabled then
    cleanAllGamerTags()
  end
end


local createInstitutionalThreads = function()
  CreateThread(function()
    local fivemScaleForm = makeFivemInstructionalScaleform({
      { 'Exit Spectate', 38 }
    })
    while isSpectateEnabled do
      DrawScaleformMovieFullscreen(fivemScaleForm, 255, 255, 255, 255, 0)
      Wait(0)
    end

    SetScaleformMovieAsNoLongerNeeded()
  end)

  CreateThread(function()
    while isSpectateEnabled do
      handleControls()
      Wait(5)
    end

    Debug('Finished buttons checker thread')
  end)
end




RegisterNetEvent("vadmin:spectate:start", function(targetServerId, targetCoords)
  if targetServerId == GetPlayerServerId(PlayerId()) then
    return Notify("Cannot spectate yourself dummy!")
  end

  storedTargetPed = nil
  storedTargetPlayerId = nil
  storedTargetServerId = nil

  if storedTargetPed == nil then
    local spectatorPed = PlayerPedId()
    spectatorReturnCoords = GetEntityCoords(spectatorPed)
  end

  prepareSpectatorPed(true)


  local coordsUnderTarget = calculateSpectatorCoords(targetCoords)
  collisionTpCoordTransition(coordsUnderTarget)
  local serverId = tonumber(targetServerId)

  local targetResolveAttempts = 0
  local resolvedPlayerId = -1
  local resolvedPed = 0

  while (resolvedPlayerId <= 0 or resolvedPed <= 0) and targetResolveAttempts < 300 do
    targetResolveAttempts = targetResolveAttempts + 1
    resolvedPlayerId = GetPlayerFromServerId(serverId)
    resolvedPed = GetPlayerPed(resolvedPlayerId)
    Debug(("Attempting to resolve ped. %s, %s"):format(resolvedPlayerId, resolvedPed))
    Wait(50)
  end

  if (resolvedPlayerId <= 0 or resolvedPed <= 0) then
    Debug('Failed to resolve target PlayerId or Ped')
    collisionTpCoordTransition(spectatorReturnCoords)
    prepareSpectatorPed(false)
    DoScreenFadeIn(500)
    while IsScreenFadedOut() do Wait(5) end

    spectatorReturnCoords = nil
    return Notify(
      "Spectate failed, press F8 and check for any debug/print statements in F8 console before reporting it to a developer.")
  end



  storedTargetPed = resolvedPed
  storedTargetPlayerId = resolvedPlayerId
  storedTargetServerId = targetServerId

  NetworkSetInSpectatorMode(true, resolvedPed)
  SetMinimapInSpectatorMode(true, resolvedPed)

  Debug(('Set spectate to true for resolvedPed (%s)'):format(resolvedPed))
  isSpectateEnabled = true
  -- toggleShowPlayerIDs(true, false)
  createSpectatorThreads()
  createInstitutionalThreads()
  DoScreenFadeIn(500)

  while IsScreenFadingOut() do Wait(5) end
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

  TriggerServerEvent("VAdmin:Server:B", data)
  cb({})
end)


RegisterNuiCallback("vadmin:nui_cb:kick", function(data, cb)
  if not next(data) then
    return Debug("(Error) [vadmin:nui_cb:kick] data param is null.")
  end

  if tonumber(data.target_id) == GetPlayerServerId(PlayerId()) then
    return Notify("What the fluff dude, you can't kick yourself :o")
  end

  TriggerServerEvent("VAdmin:Server:K", data)
  cb({})
end)

RegisterCommand("ban", function(source, args, rawCommand)
  -- Store the first value from the first index of the args table.
  local targetID = tonumber(args[1])

  -- Since we have already stored the first index (targetID) we can just remove it.
  table.remove(args, 1)

  -- The rest of the arguments are the reason for the ban.
  local reason = table.concat(args, " ")

  if not Permissions.Ban then
    return Notify(
      "Insufficient permissions, if you are staff, please go ahead and open and close the menu to see if that fixes it.")
  end

  if not targetID then return Notify("Target id is null.") end

  if tonumber(targetID) == tonumber(GetPlayerServerId(PlayerId())) then
    return Notify("What the fluff dude, you can't ban yourself!")
  end

  if not reason or #reason <= 1 then
    return Notify("Error: Reason is too short!")
  end

  local data = {
    target_id = targetID,
    reason = reason,
    length = "Permanent"
  }

  TriggerServerEvent("VAdmin:Server:B", data)
end, false)


RegisterKeyMapping('adminmenu', '[V] Admin Menu (Toggle)', 'keyboard', Config.KeyMapping)
