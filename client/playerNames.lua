State = {
  playerNames = false,
}

-- Player names logic is from txAdmin [https://github.com/tabarra/txAdmin/tree/master] because i think txAdmin is cool :0

local isPlayerIdsEnabled = false
local playerGamerTags = {}


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

createGamerTagThread = function()
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
