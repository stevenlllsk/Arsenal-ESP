local existingHighlights = {}

local function createHighlight(player)
    if existingHighlights[player] then return end

    local highlight = Drawing.new("Square")
    highlight.Visible = false
    highlight.Thickness = 2
    highlight.Color = Color3.fromRGB(255, 0, 0)
    highlight.Filled = false
    existingHighlights[player] = highlight

    game:GetService("RunService").RenderStepped:Connect(function()
        if player == game.Players.LocalPlayer then
            highlight.Visible = false
            return
        end

        if player.Team == game.Players.LocalPlayer.Team then
            highlight.Visible = false
            return
        end

        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local viewportPos = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)

            if viewportPos.Z > 0 then
                local camera = workspace.CurrentCamera
                local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
                local sizeFactor = 0.1

                local boxSize = math.clamp(200 / distance * sizeFactor, 50, 200)

                highlight.Position = Vector2.new(viewportPos.X - boxSize / 2, viewportPos.Y - boxSize / 2)
                highlight.Size = Vector2.new(boxSize, boxSize)
                highlight.Visible = true
            else
                highlight.Visible = false
            end
        else
            highlight.Visible = false
        end
    end)

    return highlight
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if player ~= game.Players.LocalPlayer then
            if player.Team ~= game.Players.LocalPlayer.Team then
                createHighlight(player)
            end
        end
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    local highlight = existingHighlights[player]
    if highlight then
        highlight:Remove()
        existingHighlights[player] = nil
    end
end)

while true do
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            if player.Team ~= game.Players.LocalPlayer.Team then
                if not existingHighlights[player] then
                    createHighlight(player)
                end
            end
        end
    end
    wait(0.5)  -- You can adjust the interval for the loop if needed
end
