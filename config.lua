Config = {
  Debug = true,
  KeyMapping = "F9", -- The key to open the Admin Menu.
  DefaultPermissions = {
    AllowedPermissions = {}
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
