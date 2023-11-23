local debugEnabled = Config.Debug

config = {
  embed = {
    color = '1',
    footer = {
      text = '[V] Admin Menu',
      icon_url = 'https://cdn.discordapp.com/attachments/839129248265666589/1154577728834654319/profile.jpg'
    },
    user = {
      name = '[V] Admin Menu',
      icon_url = 'https://cdn.discordapp.com/attachments/839129248265666589/1154577728834654319/profile.jpg'
    }
  }
}


EasySeconds = {
  ['Minute'] = 60,
  ['Hour'] = 60 * 60,
  ['Day'] = 24 * 60 * 60,
  ['Week'] = 7 * 24 * 60 * 60,
  ['Month'] = 30 * 24 * 60 * 60,
  ['Year'] = 365 * 24 * 60 * 60
}

BanLengths = {
  ['2 Minutes'] = 2 * EasySeconds['Minute'],
  ['6 Hours'] = 6 * EasySeconds['Hour'],
  ['12 Hours'] = 12 * EasySeconds['Hour'],
  ['1 Day'] = EasySeconds['Day'],
  ['3 Days'] = 3 * EasySeconds['Day'],
  ['1 Week'] = EasySeconds['Week'],
  ['1 Month'] = EasySeconds['Month'],
  ['3 Months'] = 3 * EasySeconds['Month'],
  ['6 Months'] = 6 * EasySeconds['Month'],
  ['1 Year'] = EasySeconds['Year'],
  ['Permanent'] = 5 * EasySeconds['Year']
}

getIdentifiers = function(player)
  local t = {}

  if player then
    local identifiers = GetPlayerIdentifiers(player)

    for i = 1, #identifiers do
      local prefix, identifier = string.strsplit(':', identifiers[i])
      t[prefix] = identifier
    end
  end

  return t
end


organizeIdentifiers = function(target)
  assert(target, 'Attempted to organaize an invalid targets identifiers.')
  local t = {}

  local identifiers = getIdentifiers(target)

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
  if (not args or type(args) ~= 'table') then return end

  local embed = {
    color = config?.embed?.color,
    type = 'rich',
    title = args?.title or '',
    description = args?.description or '',
    timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
    footer = config?.embed?.footer or {},
    image = { url = "https://i.imgur.com/XuuQq8V.png" } -- [V] Admin Menu Banner
  }

  if type(args?.fields) == 'table' and #args?.fields >= 1 then
    embed.fields = args?.fields
  end


  PerformHttpRequest(args?.webhook, function(err, text, headers) end, 'POST', json.encode({
    username = config?.embed?.user?.name,
    avatar_url = config?.embed?.user?.icon_url,
    embeds = { embed }
  }), { ['Content-Type'] = 'application/json'
  })
end

---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function UIMessage(action, data)
  SendNUIMessage({
    action = action,
    data = data
  })

  -- Debug(("(Debug) [vadmin:shared:uimessage] \n Action: %s \n Data: %s"):format(json.encode(action), json.encode(data)))
end

local currentResourceName = GetCurrentResourceName()

function GetPedHealthPercent(ped)
  return math.floor((GetEntityHealth(ped) / GetEntityMaxHealth(ped)) * 100)
end

function Debug(...)
  if not debugEnabled then return end
  local args <const> = { ... }

  local appendStr = ''
  for _, v in ipairs(args) do
    appendStr = appendStr .. ' ' .. tostring(v)
  end

  local msgTemplate = '^3[%s]^0%s'
  local finalMsg = msgTemplate:format(currentResourceName, appendStr)
  print(finalMsg)
end

--- Healthy, Happy, Successful.



-- Feel free to re-write this function to use your notification system if you don't like the current one built with the admin menu.
---@param message string
Notify = function(message)
  if not message then
    return Debug("(Error) Notify function was called, but the first param was null.")
  end
  UIMessage("nui:notify", message)
end
