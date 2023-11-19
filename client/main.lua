Permissions = {
  -- ["Set Job"] = true,
  -- ["Car Wipe"] = true,
  -- ["Player Names"] = true,
  -- ["Community Service"] = true,
  -- Ban = true,
  -- Kick = true,
  -- Report = true,
  -- ["Delete Car"] = true,
  -- Teleport = true,
  -- Spectate = true,
  -- ["Give Car"] = true,
  -- ["Clear Chat"] = true,
  -- ["Give Account Money"] = true,
  -- Revive = true,
  -- Announce = true,
  -- Unban = true,
  -- Frozen = true,
  -- ["Offline Ban"] = true,
  -- ["Give Item"] = true,
  -- Skin = true,
  -- Armor = true,
  -- ["Set Gang"] = true,
  -- ["Clear Loadout"] = true,
  -- ["Copy Coords"] = true,
  -- Menu = true,
  -- ["Set Account Money"] = true,
  -- ["Go Back"] = true,
  -- ["Flip Car"] = true,
  -- Health = true,
  -- ["Clear Inventory"] = true,
  -- NoClip = true,
  -- ["Give Weapon"] = true,
  -- ["Spawn Car"] = true,
}

State = {
  playerNames = false,
}

local spectatorReturnCoords
local isSpectateEnabled = false
local storedTargetPed
local storedTargetPlayerId
local storedTargetServerId
local isPlayerIdsEnabled = false
local playerGamerTags = {}

local function toggleNuiFrame(shouldShow)
  SetNuiFocus(shouldShow, shouldShow)
  UIMessage('setVisible', shouldShow)
end


RegisterCommand('adminmenu', function()
  UIMessage("nui:adminperms", Permissions)
  if not next(Permissions) then
    local srcPermissions = lib.callback.await('vadmin:getPermissions', false)

    if not next(srcPermissions) then
      return Debug("(Error) (command:adminmenu) srcPermissions is null, returning.")
    end


    Permissions = srcPermissions


    if not Permissions.Menu then
      return Notify("What the fluff dude, you don't have perms :o")
    end

    UIMessage("nui:adminperms", Permissions)
  end

  if not Permissions.Menu then
    return Notify("What the fluff dude, you don't have perms :o")
  end

  local PlayerList = lib.callback.await('vadmin:plist', false)
  local PlayerCache = lib.callback.await("vadmin:clist", false)


  if #PlayerList then
    UIMessage("nui:plist", PlayerList)
  end

  if #PlayerCache then
    UIMessage("nui:clist", PlayerCache)
  end

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

  if tostring(sourceId) == tostring(playerData.ID) then
    return Notify("What the fluff dude, you cannot spectate yourself.")
  end

  TriggerServerEvent("vadmin:server:spectate", playerData)
  cb({})
end)


local calculateSpectatorCoords = function(coords)
  return vec3(coords.x, coords.y, coords.z - 15.0)
end

--- @param enabled boolean
local prepareSpectatorPed = function(enabled)
  local playerPed = PlayerPedId()
  FreezeEntityPosition(playerPed, enabled)
  SetEntityAlpha(playerPed, (enabled and 0 or 255), false)

  if enabled then
    TaskLeaveAnyVehicle(playerPed, 0, 16)
  end
end

-- local testFunction = function(param1, param2, param3, param4)

-- end

local collisionTpCoordTransition = function(coords)
  -- if not IsScreenFadingOut() then DoScreenFadeIn(500) end
  -- while not IsScreenFadedOut() do Wait(5) end

  local playerPed = PlayerPedId()
  RequestCollisionAtCoord(coords.x, coords.y, coords.z)
  ---@diagnostic disable-next-line: missing-parameter
  SetEntityCoords(playerPed, coords.x, coords.y, coords.z)

  local attempts = 0

  while not HasCollisionLoadedAroundEntity(playerPed) do
    Wait(5)
    attempts = attempts + 1
    print("Attempting")
    if attempts > 1000 then
      print("Failed to load collisions.")
    end
  end

  print("Collisions loaded, player teleported.")
end

local stopSpectating = function()
  isSpectateEnabled = false
  isPlayerIdsEnabled = false
  DoScreenFadeOut(500)
  while not IsScreenFadingOut() do Wait(5) end

  NetworkSetInSpectatorMode(false, PlayerPedId())
  SetMinimapInSpectatorMode(false, PlayerPedId())
  if spectatorReturnCoords then
    if not pcall(collisionTpCoordTransition, spectatorReturnCoords) then
      print('collisionTpCoordTransition failed!')
    end
  else
    print("No spectatorReturnCoords saved.")
  end

  prepareSpectatorPed(false)
  -- toggleShowPlayerIDs(false, false)

  storedTargetPed = nil
  storedTargetPlayerId = nil
  storedTargetServerId = nil
  spectatorReturnCoords = nil

  DoScreenFadeIn(500)
  while IsScreenFadingIn() do Wait(5) end
  TriggerServerEvent("vadmin:server:spectate:end")
end
---@param keysTable table
---@return integer scaleform
local function makeFivemInstructionalScaleform(keysTable)
  local scaleform = RequestScaleformMovie("instructional_buttons")
  while not HasScaleformMovieLoaded(scaleform) do
    Wait(10)
  end
  BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
  EndScaleformMovieMethod()

  BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
  ScaleformMovieMethodAddParamInt(200)
  EndScaleformMovieMethod()

  for btnIndex, keyData in ipairs(keysTable) do
    local btn = GetControlInstructionalButton(0, keyData[2], true)

    BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(btnIndex - 1)
    ScaleformMovieMethodAddParamPlayerNameString(btn)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringKeyboardDisplay(keyData[1])
    EndTextCommandScaleformString()
    EndScaleformMovieMethod()
  end

  BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
  EndScaleformMovieMethod()

  BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
  ScaleformMovieMethodAddParamInt(0)
  ScaleformMovieMethodAddParamInt(0)
  ScaleformMovieMethodAddParamInt(0)
  ScaleformMovieMethodAddParamInt(80)
  EndScaleformMovieMethod()

  return scaleform
end

local createSpectatorThreads = function()
  CreateThread(function()
    local initialTargetServerId = storedTargetServerId
    while isSpectateEnabled and storedTargetServerId == initialTargetServerId do
      if not DoesEntityExist(storedTargetPed) then
        local newPed = GetPlayerPed(storedTargetPlayerId)
        if newPed > 0 then
          if newPed ~= storedTargetPed then
            Debug(("Spectated target ped (%s) updated to %s"):format(storedTargetPlayerId, newPed))
          end
          storedTargetPed = newPed
        else
          Debug(("Spectated player (%s) no longer exists, ending spectate..."):format(
            storedTargetPlayerId))
          stopSpectating()
        end
      end


      local newSpectatorCoords = calculateSpectatorCoords(GetEntityCoords(storedTargetPed))
      SetEntityCoords(PlayerPedId(), newSpectatorCoords.x, newSpectatorCoords.y, newSpectatorCoords.z, 0, 0, 0, false)
      Wait(500)
    end
  end)
end

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

local handleControls = function()
  if IsControlJustPressed(0, 38) then
    stopSpectating()
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

-- RegisterNetEvent("vadmin:client:plist", function(id, playerData, initial)
--   -- if not playerData then
--   --   CPlayerList[id] = nil
--   --   return
--   -- end
--   -- print(("[VAdmin] (PlayerData): %s"):format(json.encode(playerData)))
--   print("Executed")
--   if initial then
--     CPlayerList = playerData
--     UIMessage("nui:plist", playerData)
--     return
--   end


--   CPlayerList[id] = playerData

--   print(("[VAdmin] (CPlayerList): %s"):format(json.encode(CPlayerList)))


--   -- for pids, pData in pairs(CPlayerList) do
--   --   uploadData[#uploadData + 1] = {
--   --     Name = pData.Name or "[Error] Unknown",
--   --     ID = pData.ID,
--   --     Health = pData.Health,
--   --     Identifiers = pData.Identifiers,
--   --     HWIDS = pData.HWIDS
--   --   }
--   -- end
--   UIMessage("nui:plist", CPlayerList)
-- end)

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

  if not targetID then return Notify("Target ID is null.") end

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
