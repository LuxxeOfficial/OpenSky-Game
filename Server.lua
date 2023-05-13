local url = "https://opensky-api.onrender.com/translate"
local HttpService = game:GetService("HttpService")


game.Players.PlayerAdded:Connect(function(plr)
	local lastReq = Instance.new("NumberValue")
	lastReq.Name = "TranslationCooldown"
	lastReq.Parent = plr
	local localeID = Instance.new("StringValue")
	localeID.Name = "OPENSKY_LOCALE_ID"
	localeID.Parent = plr
end)

function getLocale(player)
	if player:FindFirstChild("OPENSKY_LOCALE_ID") then
		return player.OPENSKY_LOCALE_ID.Value
	else
		return "en"
	end
		
end

game.ReplicatedStorage.OpenSky.SendLocale.OnServerEvent:Connect(function(plr, locale)
	if type(locale) == "string" then
		plr.OPENSKY_LOCALE_ID.Value = locale
	end
end)

-- Create an empty translation queue table
local translationQueue = {}

-- Create an empty translation queue table
local translationQueue = {}

-- Function to add a translation request to the queue
function addToTranslationQueue(player, fromLanguage, toLanguage, body)
	table.insert(translationQueue, {player, fromLanguage, toLanguage, body})
end

-- Function to process the translation queue
function processTranslationQueue()
	-- Get the current time
	local currentTime = os.time()

	for i = #translationQueue, 1, -1 do
		-- Get the next translation request from the queue
		local translationRequest = translationQueue[i]
		local player = translationRequest[1]
		local fromLanguage = translationRequest[2]
		local toLanguage = translationRequest[3]
		local body = translationRequest[4]

		-- Check if the player is allowed to process another translation yet
		if player.TranslationCooldown.Value == nil or currentTime >= player.TranslationCooldown.Value then
			-- Translate the message
			local translatedMessage = translateMessage(fromLanguage, toLanguage, body)

			-- Display the translated message to the player
			displayTranslatedMessage(player, fromLanguage, toLanguage, body, translatedMessage)

			-- Set the cooldown for the player
			player.TranslationCooldown.Value = currentTime + 1 -- Only process 1 per second per player

			-- Remove the translation request from the queue
			table.remove(translationQueue, i)
		end
	end
end

-- Function to translate a message
function translateMessage(fromLanguage, toLanguage, body)
	-- Code to translate the message goes here
	-- This is just a placeholder for now
	return "This is a translated message"
end

-- Function to display the translated message to the player
function displayTranslatedMessage(player, fromLanguage, toLanguage, originalMessage, translatedMessage)
	-- Code to display the translated message to the player goes here
	print(string.format("%s: [%s] %s -> [%s] %s", player.Name, fromLanguage, originalMessage, toLanguage, translatedMessage))
end

game.ReplicatedStorage.OpenSky.RequestTranslation.OnServerInvoke = function(plr, plr2SRC, body)
	local plr2 = game.Players:GetPlayerByUserId(plr2SRC.UserId)
	local toLang = getLocale(plr)
	local fromLang = getLocale(plr2)
	print("TRANSLATION: "..fromLang.."->"..toLang)
	if toLang ~= nil and fromLang ~= nil then
		local requestBody = HttpService:JSONEncode({
			target_lang = toLang,
			from_lang = fromLang,
			text = body
		})
		
		local options = {
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = requestBody
		}
		
		local success, result = pcall(function()
			return HttpService:RequestAsync(options)
		end)
		
		if success and result.Success then
			local response = HttpService:JSONDecode(result.Body)
			local translation = response.translation
			return translation
		else
			warn("Request failed: " .. tostring(result.StatusCode))
		end
	end
end



-- Main loop to process the translation queue
while true do
	processTranslationQueue()
	wait(0.1)
end
