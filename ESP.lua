local function createHighlight(player)
    local highlight = Drawing.new("Square")
    highlight.Visible = false
    highlight.Thickness = 2
    highlight.Color = Color3.fromRGB(255, 0, 0)
    highlight.Filled = false

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

local function highlightAllPlayers()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if player.Team ~= game.Players.LocalPlayer.Team then
                    createHighlight(player)
                end
            end
        end
    end
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
    if player.Character then
        local highlight = player:FindFirstChild("Highlight")
        if highlight then
            highlight:Remove()
        end
    end
end)

highlightAllPlayers()
