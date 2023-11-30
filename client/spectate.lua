-- Spectate logic is from txAdmin [https://github.com/tabarra/txAdmin/tree/master] because i think txAdmin is cool :0

spectatorReturnCoords = nil
isSpectateEnabled = false
storedTargetPed = nil
storedTargetPlayerId = nil
storedTargetServerId = nil

calculateSpectatorCoords = function(coords)
  return vec3(coords.x, coords.y, coords.z - 15.0)
end

--- @param enabled boolean
prepareSpectatorPed = function(enabled)
  local playerPed = PlayerPedId()
  FreezeEntityPosition(playerPed, enabled)
  SetEntityAlpha(playerPed, (enabled and 0 or 255), false)

  if enabled then
    TaskLeaveAnyVehicle(playerPed, 0, 16)
  end
end


collisionTpCoordTransition = function(coords)
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
    Debug("Attempting")
    if attempts > 1000 then
      Debug("Failed to load collisions.")
    end
  end

  Debug("Collisions loaded, player teleported.")
end

stopSpectating = function()
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
function makeFivemInstructionalScaleform(keysTable)
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

createSpectatorThreads = function()
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


handleControls = function()
  if IsControlJustPressed(0, 38) then
    stopSpectating()
  end
end

createInstitutionalThreads = function()
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
