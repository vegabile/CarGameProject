local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TeleporterFactory = {}

local Teleporters = {}

function TeleporterFactory.newTeleporter(destination, model, time)
    local id = #Teleporters + 1

    local teleporter = setmetatable({}, TeleporterFactory)
    teleporter.ID = id
    teleporter.DestinationID = destination
    teleporter.Players = {}
    teleporter.PlayerCount = 0
    teleporter.tpPart = model.TeleportPart
    teleporter.Initialized = false
    teleporter.MaxPlayers = 1
    teleporter.Timer = time
    teleporter.Teleporting = false
    teleporter.ExitPart = model.ExitPart
    teleporter.PopulationLabel = model.PopulationUI.PopulationLabel
    teleporter.TimerLabel = model.PopulationUI.TimerLabel

    table.insert(Teleporters, teleporter)

    return teleporter
end

function TeleporterFactory.Initialize(teleporterID, settings)
    local Teleporter = TeleporterFactory.findTeleporter(teleporterID)
    local MaxPlayers = settings.MaxPlayers

    if not (Teleporter) then
        return
    end

    Teleporter.MaxPlayers = MaxPlayers
    Teleporter.Initialized = true
end

function TeleporterFactory.Deinitialize(teleporterID)
    local Teleporter = TeleporterFactory.findTeleporter(teleporterID)
    
    if not (Teleporter) then
        return
    end

    Teleporter.MaxPlayers = 1
    Teleporter.Initialized = false
end

function TeleporterFactory.findTeleporter(teleporterID)
    local teleporter = Teleporters[teleporterID]

    if (teleporter) then
        return teleporter
    else
        warn("There is no teleporter with ID "..tostring(teleporterID))
        return
    end
end

function TeleporterFactory.Tick()
    for _, teleporter in ipairs(Teleporters) do
        if (teleporter.Initialized) then
            teleporter.TimerLabel.Visible = true
            teleporter.PopulationLabel.Text = tostring(teleporter.PlayerCount).."/"..tostring(teleporter.MaxPlayers)
        else
           teleporter.PopulationLabel.Text = "0/1"
           teleporter.TimerLabel.Text = "30 seconds remaining"
           teleporter.TimerLabel.Visible = false
           teleporter.MaxPlayers = 1
        end
    end
end

return TeleporterFactory