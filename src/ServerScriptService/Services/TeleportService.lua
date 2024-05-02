local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages._Index["sleitnick_signal@2.0.1"].signal)
local ZoneService = require(ServerScriptService.Server.TeleportService.ZoneService)

local TeleporterFactory = require(ServerScriptService.Server.TeleportService.TeleporterFactory)
local TeleporterHandler = require(ServerScriptService.Server.TeleportService.TeleportHandler)

local LastRecieved = {}


local TeleportService = Knit.CreateService {
    Name = "TeleportService",
    Client = {
        SetInitialization = Knit.CreateSignal();
        JoinedQuene = Knit.CreateSignal();
        LeftQuene = Knit.CreateSignal();
        LeaveQuene = Knit.CreateSignal();
    },
}

local function ValidateSettings(settings)
    local valid = true
    
    if not (settings.MaxPlayers) or not (type(settings.MaxPlayers) == "number") then
        valid = false
    end

    return valid
end

function TeleportService:KnitInit()
    self.StartTimer = Signal.new()
    self.TimerEnded = Signal.new()
    self.StopTimer = Signal.new()
end

function TeleportService:KnitStart()    
    local Timers = {}

    for _, model : Model in ipairs(game.Workspace.Teleporters:GetChildren()) do
        local TPer = TeleporterFactory.newTeleporter(0000, model, 30)
        model:WaitForChild("LinkedTeleporter").Value = TPer.ID

        for _, part in ipairs(model:GetChildren()) do
            if (part.Name == "TouchPart") then
                part.Touched:Connect(function(otherPart)
                    if otherPart.Parent:FindFirstChild("Humanoid") then
                       local Player = Players:GetPlayerFromCharacter(otherPart.Parent)
        
                       if (Player) then
                           if (TPer.Initialized == false) then
                                self.Client.SetInitialization:Fire(Player, TPer.ID)
                           else
                                TeleporterHandler.AddPlayer(TPer.ID, Player)
                           end
                       end
                    end
                end)
     
            
            elseif (part.Name == "") then

            end                
        end
    end

    self.Client.SetInitialization:Connect(function(Player, settings, ID)
        local TPer = TeleporterFactory.findTeleporter(ID)
        print(settings,'was recieved by the server.')

        if not (TPer) then
            return
        end

        if (TPer.Initialized == true) then
            return
        end

        if (LastRecieved[ID] and (os.time() - LastRecieved[ID]) < 3) then
            return
        end

        local valid = ValidateSettings(settings)
        LastRecieved[ID] = os.time()

        if (valid) then
            TeleporterFactory.Initialize(TPer.ID, settings)
            TeleporterHandler.AddPlayer(ID, Player)
            self.StartTimer:Fire(TPer)
        end
    end)

    self.TimerEnded:Connect(function(teleporterID)
        
    end)

    self.Client.LeaveQuene:Connect(function(Player, teleporterID)
        TeleporterHandler.RemovePlayer(teleporterID, Player)
    end)


    self.StartTimer:Connect(function(TPer)
        local teleporterID, time = TPer.ID, TPer.Timer
        if (Timers[teleporterID] ~= nil) then
            warn("Theres already an active timer")
            return
        end

        Timers[teleporterID] = time

        task.spawn(function()
            while task.wait(1) do
                if (Timers[teleporterID] == nil) then
                    print("It's nil, breaking.")
                    break
                end

                if (TPer.PlayerCount >= TPer.MaxPlayers) then
                    Timers[teleporterID] = math.min(Timers[teleporterID], 5)
                end

                Timers[teleporterID] -= 1
                TPer.TimerLabel.Text = tostring(Timers[teleporterID]).." seconds remaining."

                if (Timers[teleporterID] == 0) then
                    self.TimerEnded:Fire(teleporterID)
                    Timers[teleporterID] = nil            
                    break
                end
            end
        end)
    end)

    self.StopTimer:Connect(function(teleporterID)
        Timers[teleporterID] = nil
    end)

    while true do
        task.wait(1)
        TeleporterFactory.Tick()
    end
end

return TeleportService