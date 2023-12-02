Config = {
  Debug = true,        -- Use only for development/debugging purposes, fills the client and server sided console with allot of debugging info.
  KeyMapping = "F9",   -- The key to open the Admin Menu.
  ChatMessages = true, -- Messages that get sent to the chat once an action is triggered, such as a player is banned, kicked, offline banned and car wipes.
  DefaultPermissions = {
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
  },
  PermissionSystem = {
    -- Revive isn't really a thing since this script is standalone,the back end logic for it is there but i removed the front-end option for it, could be re-added in the future if i decide to add optional support for frameworks.
    {
      AcePerm = "vadmin.owner",
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
    },
    {
      AcePerm = "vadmin.moderator",
      AllowedPermissions = {
        Menu = true,
        Kick = true,
        Ban = false,
        ["Clear Chat"] = true,
        ["Offline Ban"] = false,
        Unban = false,
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
    },
  },
  Embed = {
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
