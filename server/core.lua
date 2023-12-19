-- Online Players
---@type PlayerData[]
PlayerList = {}
-- Offline Players
---@type PlayerData[]
PlayerCache = {}
-- Online Staff and Their Permissions.
AdminData = {}

AddEventHandler("playerJoining", function(_srcString, _oldID)
	if source <= 0 then
		Debug("(Error) [eventHandler:playerJoining] source is nil, returning.")
		return
	end

	local playerName = GetPlayerName(source)

	if type(playerName) ~= "string" then
		return Debug("(Error) [eventHandler:playerJoining] Player name isn't a string, Player name type: ", type(playerName))
	end

	local playerData = CPlayer:new(source)

	if PlayerList[source] then
		return Debug("(Error) [eventHandler:playerJoining] Player is already in the [PlayerList] table.")
	end

	PlayerList[tonumber(playerData.id)] = playerData
end)

AddEventHandler("playerDropped", function(reason)
	if source <= 0 then
		return Debug("(Error) [eventHandler:playerDropped] Source is nil.")
	end

	if PlayerList[source] then
		PlayerCache[source] = PlayerList[source]
		PlayerList[tonumber(source)] = nil
	else
		Debug("(Error) [eventHandler:playerDropped] Player isn't in the [PlayerList] table, error removing the player.")
	end
end)

SetTimeout(5000, function()
	CreateThread(function()
		local Players = GetPlayers()
		for i = 1, #Players do
			local player = Players[i]
			if PlayerList[player] then
				Debug("(Error) [Thread:InitPlayerList] Player is already in the PlayerList table.")
				return
			end

			local playerData = CPlayer:new(player)

			Debug("[Thread] playerData variable: ", json.encode(playerData))

			PlayerList[tonumber(player)] = playerData
		end
	end)
end)


-- Only run this if you plan on using ox_lib with it.
-- lib.callback.register('vadmin:plist', function(source)
--   return PlayerList
-- end)

-- lib.callback.register("vadmin:clist", function(source)
--   return PlayerCache
-- end)

-- lib.callback.register("vadmin:getPermissions", function(source)
--   if not AdminData[tonumber(source)] then
--     return Config.DefaultPermissions
--   end

--   return AdminData[tonumber(source)]
-- end)

---@param banIdentifiers {}
---@param sourceIdentifiers {}
---@return boolean
local loopThroughIdentifiers = function(banIdentifiers, sourceIdentifiers)
	if not next(banIdentifiers) or not next(sourceIdentifiers) then
		return false
	end

	for banIndex = 1, #banIdentifiers do
		local bannedIdentifier = banIdentifiers[banIndex]
		for sourceIndex = 1, #sourceIdentifiers do
			local sourceIdentifier = sourceIdentifiers[sourceIndex]
			if string.find(bannedIdentifier, sourceIdentifier) then
				Debug("Banned identifier found: ", bannedIdentifier)
				return true
			end
		end
	end

	return false
end

---@param banTokens {}
---@param sourceTokens {}
---@return boolean
local loopThroughTokens = function(banTokens, sourceTokens)
	if not next(banTokens) or not next(sourceTokens) then
		return false
	end

	for banIndex = 1, #banTokens do
		local bannedToken = banTokens[banIndex]
		for sourceIndex = 1, #sourceTokens do
			local sourceToken = sourceTokens[sourceIndex]
			if bannedToken == sourceToken then
				Debug("Banned token found: ", bannedToken)
				return true
			end
		end
	end

	return false
end

AddEventHandler("playerConnecting", function(_name, _setKickReason, deferrals)
	local source = tonumber(source)
	local identifiers = GetPlayerIdentifiersWithoutIP(source)
	local tokens = GetPlayerTokens(source)
	local banlist = LoadBanList()

	deferrals.defer()
	Wait(50)
	deferrals.update("Checking if the user is banned...")

	for banIndex, banEntry in pairs(banlist) do
		local identifierCheck = loopThroughIdentifiers(banEntry.identifiers, identifiers)
		local tokenCheck = loopThroughTokens(banEntry.tokens, tokens)

		if identifierCheck or tokenCheck then
			local remainingTime = banEntry.Length - os.time()

			if remainingTime <= 0 then
				table.remove(banlist, banIndex)
				deferrals.update("Ban has expired, unbanning user.")
			else
				local kickReason = (
					Lang:t("ban_info", {
						staffMember = banEntry.StaffMember,
						banReason = banEntry.Reason,
						banDate = banEntry.banDate,
						expirationDate = os.date("%x", banEntry.Length),
						expirationTime = os.date("%X", banEntry.Length),
						banId = banEntry.uuid,
					})
				)
				deferrals.done(kickReason)
				return
			end
		end
	end

	SaveBanList(banlist)
	Wait(500)
	deferrals.done()
end)
