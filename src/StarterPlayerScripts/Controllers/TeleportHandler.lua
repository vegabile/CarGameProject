local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")

local TeleportConfig = PlayerGui:WaitForChild("TeleportConfig")
local TeleporterUI = PlayerGui:WaitForChild("TeleporterUI")

local Frame = TeleportConfig:WaitForChild("Frame")

local PlusButton : TextButton = Frame:WaitForChild("PlusButton")
local SubtractButton : TextButton = Frame:WaitForChild("SubtractButton")
local SubmitButton : TextButton = Frame:WaitForChild("SubmitButton")
local TextDisplay : TextLabel = Frame:WaitForChild("AmountLabel")
local LeaveButton : TextButton = TeleporterUI:WaitForChild("LeaveButton")

local Knit = require(ReplicatedStorage.Packages.Knit)

local buttondb = false

local CurrentQuene = 1273
local Configs = {MaxPlayers = 1}

local maxPlayersLimit = {min = 1, max = 9}

local TeleportController = Knit.CreateController{
    Name = "TeleportController";
    Server = {};
}
local function updatePlayerCount(delta)
    Configs.MaxPlayers = math.clamp(Configs.MaxPlayers + delta, maxPlayersLimit.min, maxPlayersLimit.max)
    TextDisplay.Text = tostring(Configs.MaxPlayers)
end

local function buttonDebounce(time)
    buttondb = true
    task.wait(time)
    buttondb = false
end

function TeleportController:KnitInit()
    
end

function TeleportController:KnitStart()
    local TeleportService = Knit.GetService("TeleportService")

    TeleportService.JoinedQuene:Connect(function(queneID)
        TeleporterUI.Enabled = true
        CurrentQuene = queneID
    end)

    TeleportService.LeftQuene:Connect(function(queneID)
        TeleporterUI.Enabled = false
        CurrentQuene = nil
    end)

    TeleportService.SetInitialization:Connect(function(ID)
        TeleportConfig.Enabled = true

        SubtractButton.MouseButton1Click:Connect(function()
            if (Configs.MaxPlayers == 1) then
                return
            end
            
            if (buttondb) then
                return
            end

            updatePlayerCount(-1)
            buttonDebounce(.2)
        end)

        PlusButton.MouseButton1Click:Connect(function()
            if (Configs.MaxPlayers == 9) then
                return
            end

            if (buttondb) then
                return
            end

            updatePlayerCount(1)
            buttonDebounce(.2)
        end)

        SubmitButton.MouseButton1Click:Connect(function()
            if (buttondb) then
                return
            end
            
            print(Configs,'being passed.')
            TeleportService.SetInitialization:Fire(Configs, ID)
            TeleportConfig.Enabled = false
            --Configs.MaxPlayers = 1
            --TextDisplay.Text = "1"

            buttonDebounce(.2)
        end)
    end)

    LeaveButton.MouseButton1Click:Connect(function()
        TeleportService.LeaveQuene:Fire(CurrentQuene)
        CurrentQuene = nil
    end)
end

return TeleportController