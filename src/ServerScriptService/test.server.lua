local TeleportHandler = require(game.ServerScriptService.Server.TeleportHandler)
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    TeleportHandler:TeleportParty(game.PlaceId, player)
end)