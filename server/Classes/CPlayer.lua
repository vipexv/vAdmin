CPlayer = {}

---@param player string | number
---@return any
function CPlayer:new(player)
  if not player then
    return Debug("(Error) `CPlayer:new` function was called but the first param is null.")
  end

  local obj = {
    name = GetPlayerName(player),
    id = player,
    identifiers = GetPlayerIdentifiersWithoutIP(player),
    tokens = GetPlayerTokens(player),
  }

  setmetatable(obj, self)
  self.__index = self
  return obj
end

function CPlayer:displayInfo()
  Debug(("Data: %s"):format(json.encode(self)))
end
