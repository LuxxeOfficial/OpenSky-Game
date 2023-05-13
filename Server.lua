--[[
MIT License

Copyright (c) 2023 Luxxe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

-- Define the endpoint URL for translation API
local url = "https://opensky-api.onrender.com/translate"

-- Get required game services
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

-- Create a function to be called when a player joins the game
game.Players.PlayerAdded:Connect(function(plr)
	-- Create a new StringValue instance to store the player's selected locale
	local localeID = Instance.new("StringValue")
	localeID.Name = "OPENSKY_LOCALE_ID"
	localeID.Parent = plr
end)

-- Define a function to get the locale (language) of a player
function getLocale(player)
	-- Check if the player has a locale stored in their player object
	if player:FindFirstChild("OPENSKY_LOCALE_ID") then
		-- Return the locale value if found
		return player.OPENSKY_LOCALE_ID.Value
	else
		-- Return a default locale value of "en" if no locale is found
		return "en"
	end
end

-- Connect a function to be called when the client sends a locale update to the server
game.ReplicatedStorage.OpenSky.SendLocale.OnServerEvent:Connect(function(plr, locale)
	-- Check that the locale parameter is a string
	if type(locale) == "string" then
		-- Update the player's stored locale value
		plr.OPENSKY_LOCALE_ID.Value = locale
	end
end)

-- Define a function to be called when the client requests a translation from one player to another
game.ReplicatedStorage.OpenSky.RequestTranslation.OnServerInvoke = function(plr, plr2SRC, body)
	-- Get the player object for the player who is being translated to
	local plr2 = game.Players:GetPlayerByUserId(plr2SRC.UserId)
	-- Get the locale values for the two players involved in the translation
	local toLang = getLocale(plr)
	local fromLang = getLocale(plr2)
	-- Check that both locale values are not nil
	if toLang ~= nil and fromLang ~= nil then
		-- Encode the request body in JSON format
		local requestBody = HttpService:JSONEncode({
			target_lang = toLang,
			from_lang = fromLang,
			text = body
		})
		-- Define options for the HTTP request to the translation API
		local options = {
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json"
			},
			Body = requestBody
		}
		-- Attempt to make the HTTP request and decode the response
		local success, result = pcall(function()
			return HttpService:RequestAsync(options)
		end)
		
		-- If the request was successful and the response was valid, filter and return the translated text
		if success and result.Success then
			local response = HttpService:JSONDecode(result.Body)
			local translation = response.translation
			
			local filtered = ""
			local success, errorMessage = pcall(function()
				filtered = TextService:FilterStringAsync(translation, plr2.UserId, Enum.TextFilterContext.PublicChat)
			end)
			if not success then
				warn("Error filtering translation! ".. translation .. " -> "..errorMessage)
				return body
			end
			
			return filtered
		else
			warn("Request failed: " .. tostring(result.StatusCode))
		end
	end
end
