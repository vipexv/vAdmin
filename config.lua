Config = {
  Debug = true,        -- Use only for development/debugging purposes, fills the client and server sided console with allot of debugging info which you wouldn't.
  KeyMapping = "F9",   -- The key to open the Admin Menu.
  ChatMessages = true, -- Messages that get sent to the chat once a player is banned, kicked, offline banned and car wipes.
  DefaultPermissions = {
    AllowedPermissions = {
      Menu = false,
      Kick = false,
      Ban = false,
      ["Clear Chat"] = false,
      ["Offline Ban"] = false,
      Unban = false,
      Freeze = false,
      Teleport = false,
      Spectate = false,
      Revive = false,
      NoClip = false,
      Heal = false,
      Armor = false,
      ["Player Names"] = false,
      ["Car Wipe"] = false
    }
  },
  PermissionSystem = {
    {
      AcePerm = "vadmin.all",
      AllowedPermissions = {
        Menu = true,
        Kick = true,
        Ban = true,
        ["Clear Chat"] = true,
        ["Offline Ban"] = true,
        Unban = true,
        Freeze = true,
        Teleport = true,
        Spectate = true,
        Revive = true,
        NoClip = true,
        Heal = true,
        Armor = true,
        ["Player Names"] = true,
        ["Car Wipe"] = true
      }
    }
  }
}
