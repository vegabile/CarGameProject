local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllers(StarterPlayer.StarterPlayerScripts.Client.Controllers)
local success, errormsg = Knit.Start()

if (success) then
    warn("Knit started on client")
else
    warn("failed to start Knit on client")

    if (errormsg) then
        print(errormsg)
    end
end