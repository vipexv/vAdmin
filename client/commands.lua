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
