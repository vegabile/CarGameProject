local ZoneService = {}
local Players = game:GetService("Players")

local function GetRegion3FromPart(part)
    local partCFrame = part.CFrame
    local partSize = part.Size
    local region = Region3.new(partCFrame.Position - partSize/2, partCFrame.Position + partSize/2)

    return region
end

function ZoneService.getPlayersInRegion(part)
    local players = Players:GetPlayers()
    local region3 : Region3 = GetRegion3FromPart(part)

    local touchingParts = workspace:GetPartsInPart(part)
    local players = {}

    for _, touchingPart in ipairs(touchingParts) do
        local player : Player = Players:GetPlayerFromCharacter(touchingPart.Parent)

        if not (player) then
            continue
        end
        
        if (players[player.UserId] ~= nil) then
            continue
        end

        players[player.UserId] = player
    end

    return players
end

return ZoneService