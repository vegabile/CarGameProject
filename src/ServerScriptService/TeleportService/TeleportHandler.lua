-- TeleportHandler Module
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")
--local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local TeleporterFactory = require(ServerScriptService.Server.TeleportService.TeleporterFactory)

local TeleportHandler = {}

function TeleportHandler.AddPlayer(tpID, player : Player)
    local TeleportService = Knit.GetService("TeleportService")

    if not (tpID) or (type(tpID) ~= "number") then
        return
    end

    local teleporter = TeleporterFactory.findTeleporter(tpID)
    local character = player.Character or player.CharacterAdded:Wait()

    if not (teleporter) then
        print("Not teleporter")
        return
    end

    if not (teleporter.Initialized) then
        warn("Not properly initialized")
        return
    end

    if (teleporter.MaxPlayers <= teleporter.PlayerCount) then
        return
    end

    if (teleporter.Players[player.UserId]) then
        return
    end

    character:PivotTo(teleporter.tpPart.CFrame)
    
    teleporter.Players[player.UserId] = player
    teleporter.PlayerCount += 1
    TeleportService.Client.JoinedQuene:Fire(player, tpID)

    if (teleporter.PlayerCount == 1) then
        TeleportService.StartTimer:Fire(teleporter)
    end
end

function TeleportHandler.RemovePlayer(tpID, player)
    local TeleportService = Knit.GetService("TeleportService")
    local teleporter = TeleporterFactory.findTeleporter(tpID)

    local character = player.Character

    if not (character) then
        return
    end

    if not (teleporter) then
        return
    end

    teleporter.Players[player.UserId] = nil
    teleporter.PlayerCount -= 1

    TeleportService.Client.LeftQuene:Fire(player, tpID)
    character:PivotTo(teleporter.ExitPart.CFrame)

    if (teleporter.PlayerCount == 0) then
        TeleportService.StopTimer:Fire(tpID)
        teleporter.Initialized = false
    end
end

function TeleportHandler.TeleportParty(partyMembers, targetID)
    local success, errorMessage = pcall(function()
        local reservedServerCode = TeleportService:ReserveServer(targetID)

        if (typeof(partyMembers) == "Instance" and partyMembers:IsA("Player")) then
            partyMembers = {partyMembers}
        end

        TeleportService:TeleportToPrivateServer(targetID, reservedServerCode, partyMembers)
    end)

    if not success then
        warn("Teleport failed: " .. errorMessage)
    end
end

return TeleportHandler
