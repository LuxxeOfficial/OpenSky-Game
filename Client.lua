local LocalizationService = game:GetService("LocalizationService")
local player = game.Players.LocalPlayer

game.ReplicatedStorage.OpenSky.SendLocale:FireServer(LocalizationService.SystemLocaleId)

game:GetService("TextChatService").OnIncomingMessage = function(Message)
	local sender = Message.TextSource
	local status = Message.Status
	local body = Message.Text

	if sender ~= nil and status == Enum.TextChatMessageStatus.Success and sender.UserId ~= player.UserId then
		local TRANSLATION = game.ReplicatedStorage.OpenSky.RequestTranslation:InvokeServer(Message.TextSource, Message.Text)
		local Properties = Instance.new("TextChatMessageProperties")
		Properties.Text = TRANSLATION
		print("TRANSLATION: "..TRANSLATION)
		return Properties
	end
end

return true
