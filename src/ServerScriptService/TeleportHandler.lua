-- TeleportHandler Module
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local TeleportHandler = {}

function TeleportHandler.TeleportParty(partyMembers, placeId, teleportData)
    local success, errorMessage = pcall(function()
        local teleportOptions = Instance.new("TeleportOptions")
        teleportOptions:SetTeleportData(teleportData or {})

        if typeof(partyMembers) == "Instance" and partyMembers:IsA("Player") then
            partyMembers = {partyMembers}
        end

        local reservedServerCode = TeleportService:ReserveServer(placeId)

        for _, player in ipairs(partyMembers) do
            teleportOptions.ReservedServerAccessCode = reservedServerCode
            TeleportService:TeleportAsync(placeId, {player}, teleportOptions)
        end
    end)

    if not success then
        warn("Teleport failed: " .. errorMessage)
    end
end

return TeleportHandler
