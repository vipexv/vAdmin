LoadBanList = function()
  local banList = {}
  local banListJson = LoadResourceFile(GetCurrentResourceName(), "banlist.json")

  if banListJson then
    banList = json.decode(banListJson)
  end

  return banList
end


---@param playerId string | number
---@param message string
showNotification = function(playerId, message)
  if not playerId or not message then
    return Debug("(Error) showNotificiation function was called, but a param is missing.")
  end

  if tostring(playerId) == "-1" then
    print(
      "Prevented the function `showFunction` from continuing, the function was called but the playerId param was -1, intending to display this notification to everyone")

    if source then
      return DropPlayer(source, Lang:t("cheating_kick_message"))
    end

    return
  end

  TriggerClientEvent("UIMessage", playerId, "nui:notify", message)
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


SaveBanList = function(banData)
  SaveResourceFile(GetCurrentResourceName(), "banlist.json", json.encode(banData, { indent = false }), -1)
end

function GetDiscordID(source)
  local returnValue = nil
  for idIndex = 1, GetNumPlayerIdentifiers(source) do
    if GetPlayerIdentifier(source, idIndex) ~= nil and GetPlayerIdentifier(source, idIndex):sub(1, #("discord:")) == "discord:" then
      returnValue = GetPlayerIdentifier(source, idIndex):gsub("discord:", "")
    end
  end
  return returnValue
end

-- ---@param playerData PlayerData
-- function AddPlayerToList(playerData)
--   PlayerList[playerData.id] = playerData
-- end

-- function RemovePlayerFromList(playerID)
--   PlayerList[playerID] = nil
-- end

organizeIdentifiers = function(target)
  assert(target, 'Attempted to organaize an invalid targets identifiers.')
  local t = {}

  local identifiers = GetPlayerIdentifiersWithoutIP(target)

  for k, v in pairs(identifiers) do
    if k == 'steam' then
      t[#t + 1] = ('Steam: [%s](https://steamcommunity.com/profiles/%s)'):format(v, tonumber(v, 16))
    elseif k == 'discord' then
      t[#t + 1] = ('Discord: <@%s>'):format(v)
    elseif k == 'license' then
      t[#t + 1] = ('License: %s'):format(v)
    elseif k == 'license2' then
      t[#t + 1] = ('License 2: %s'):format(v)
    elseif k == 'fivem' then
      t[#t + 1] = ('FiveM: %s'):format(v)
    elseif k == 'xbl' then
      t[#t + 1] = ('Xbox: %s'):format(v)
    elseif k == 'live' then
      t[#t + 1] = ('Live: %s'):format(v)
    end
  end

  return table.concat(t, '\n')
end

discordLog = function(args)
  if (not args or type(args) ~= 'table') then
    return Debug(
      "[discordLog] func was called, but the first param is either null or not a table.")
  end

  local embed = {
    color = Config.Embed.color,
    type = 'rich',
    title = args.title or '',
    description = args.description or '',
    timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
    footer = Config.Embed.footer or {},
    image = { url = "https://i.imgur.com/XuuQq8V.png" } -- [V] Admin Menu Banner
  }

  if type(args.fields) == 'table' and #args.fields >= 1 then
    embed.fields = args.fields
  end


  PerformHttpRequest(args.webhook, function(err, text, headers)
    Debug(err, text, headers)
  end, 'POST', json.encode({
    username = Config.Embed.user.name,
    avatar_url = Config.Embed.user.icon_url,
    Embeds = { embed }
  }), { ['Content-Type'] = 'application/json' })
end

if not LoadResourceFile(GetCurrentResourceName(), 'web/dist/index.html') then
  local err =
  'Unable to load UI. Build vAdmin or download the latest release.\n https://github.com/vipexv/vAdmin/releases/latest'
  print(err)
end

versionCheck = function(repository)
  local resource = GetInvokingResource() or GetCurrentResourceName()

  local currentVersion = 'v1.1.2'

  if currentVersion then
    currentVersion = currentVersion:match('%d+%.%d+%.%d+')
  end

  if not currentVersion then
    return print(("^1Unable to determine current resource version for '%s' ^0"):format(
      resource))
  end

  SetTimeout(1000, function()
    PerformHttpRequest(('https://api.github.com/repos/%s/releases/latest'):format(repository),
      function(status, response)
        if status ~= 200 then return end

        response = json.decode(response)
        if response.prerelease then return end

        local latestVersion = response.tag_name:match('%d+%.%d+%.%d+')
        if not latestVersion or latestVersion == currentVersion then return end

        local cv = { string.strsplit('.', currentVersion) }
        local lv = { string.strsplit('.', latestVersion) }

        for i = 1, #cv do
          local current, minimum = tonumber(cv[i]), tonumber(lv[i])

          if current ~= minimum then
            if current < minimum then
              return print(('^3An update is available for %s (current version: %s)\r\n%s^0'):format(
                resource, currentVersion, response.html_url))
            else
              break
            end
          end
        end
      end, 'GET')
  end)
end

versionCheck("vipexv/vAdmin")
