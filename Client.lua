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

-- Get the LocalizationService and LocalPlayer
local LocalizationService = game:GetService("LocalizationService")
local player = game.Players.LocalPlayer

-- Set the player's locale to the system locale using the SendLocale remote event
game.ReplicatedStorage.OpenSky.SendLocale:FireServer(LocalizationService.SystemLocaleId)

-- Listen for incoming chat messages using the TextChatService OnIncomingMessage event
game:GetService("TextChatService").OnIncomingMessage = function(Message)
	-- Extract the sender, status, and body of the chat message
	local sender = Message.TextSource
	local status = Message.Status
	local body = Message.Text
	
	-- Only translate chat messages that are successfully sent by someone else
	if sender ~= nil and status == Enum.TextChatMessageStatus.Success and sender.UserId ~= player.UserId then
		-- Invoke the RequestTranslation remote function to translate the message
		local TRANSLATION = game.ReplicatedStorage.OpenSky.RequestTranslation:InvokeServer(Message.TextSource, Message.Text)
		
		-- Return the new properties to display the translated message in the chat
		local Properties = Instance.new("TextChatMessageProperties")
		Properties.Text = TRANSLATION
		return Properties
	end
end

return true
