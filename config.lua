Config = {
  Debug = true,
  KeyMapping = "F9", -- The key to open the Admin Menu.
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
