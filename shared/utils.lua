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

local currentResourceName = GetCurrentResourceName()

function GetPedHealthPercent(ped)
  return math.floor((GetEntityHealth(ped) / GetEntityMaxHealth(ped)) * 100)
end

function Debug(...)
  if not Config.Debug then return end
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
