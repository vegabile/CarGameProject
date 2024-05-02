local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddServices(ServerScriptService.Server.Services)
local success, errormsg = Knit.Start()

if (success) then
    warn("Knit started on server")
else
    warn("failed to start Knit on server")

    if (errormsg) then
        print(errormsg)
    end
end