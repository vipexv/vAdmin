Config = {
  Debug = true,              -- Use only for development/debugging purposes, fills the client and server sided console with allot of debugging info.
  KeyMapping = "F9",         -- The key to open the Admin Menu.
  ChatMessages = true,       -- Messages that get sent to the chat once an action is triggered, such as a player is banned, kicked, offline banned and car wipes.
  UseDiscordRestAPI = false, -- Replaces the ACE PermissionSystem with one relying on the Discord REST API where players get their permissions based on their roles, make sure to configure the bot token and guild id in sv_config.lua
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
      AcePerm = "vadmin.owner", -- Will only utilize this if you don't have the UseDiscordRestAPI bool enabled
      RoleID = "",              -- Only works if you have UseDiscordRestAPI bool enabled and you have your Bot Token and Guild ID configured in sv_config.lua .
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
      AcePerm = "vadmin.moderator", -- Will only utilize this if you don't have the UseDiscordRestAPI bool enabled
      RoleID = "",                  -- Only works if you have UseDiscordRestAPI bool enabled and you have your Bot Token and Guild ID configured in sv_config.lua .
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
      text = 'vAdmin | Logs',
      icon_url = ''
    },
    user = {
      name = 'vAdmin',
      icon_url =
      'https://cdn.discordapp.com/attachments/839129248265666589/1178613078653415475/image2_1.jpg?ex=6576c7f7&is=656452f7&hm=41595ca2d7be4dc07895fabb7b04b9725f45c282292930c97e5ab5ebe4e5e89a&'
    }
  }
}
