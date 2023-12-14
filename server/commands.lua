RegisterCommand("unban", function(source, args, _rawCommand)
  -- Only the console can execute this command for now, admins use the unban logic in the NUI.
  if tonumber(source) ~= 0 then
    return print("This command can only be executed by the console!")
  end

  local banID = args[1]

  if not banID then
    return print("Ban ID cannot be null!")
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
    print("Player was found and unbanned!")
  else
    print("(Error) Player with that Ban ID not found!")
  end
end)

