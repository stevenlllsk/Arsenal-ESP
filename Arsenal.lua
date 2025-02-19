local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Rayfield Example Window",
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "by Sirius",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Big Hub"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})

local VisualTab = Window:CreateTab("ESP", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)

local existingHighlights = {}
local connections = {}
local cleanupList = {}

local function cleanupHighlight(player)
    if existingHighlights[player] then
        existingHighlights[player]:Remove()
        existingHighlights[player] = nil
    end
    if connections[player] then
        connections[player]:Disconnect()
        connections[player] = nil
    end
end

local function createHighlight(player)
    if existingHighlights[player] then return end

    local highlight = Drawing.new("Square")
    highlight.Visible = false
    highlight.Thickness = 2
    highlight.Color = Color3.fromRGB(255, 0, 0)
    highlight.Filled = true
    highlight.Transparency = 0.5
    existingHighlights[player] = highlight

    local updateConnection
    updateConnection = game:GetService("RunService").RenderStepped:Connect(function()
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

                highlight.Position = Vector2.new(viewportPos.X - 19 / 2, viewportPos.Y - 23 / 2)
                highlight.Size = Vector2.new(19, 23)
                highlight.Visible = true
            else
                highlight.Visible = false
            end
        else
            highlight.Visible = false
        end
    end)

    connections[player] = updateConnection
end

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if player ~= game.Players.LocalPlayer and player.Team ~= game.Players.LocalPlayer.Team then
            if not existingHighlights[player] then
                createHighlight(player)
            end
        end
    end)

    player.CharacterRemoving:Connect(function()
        cleanupHighlight(player)
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    cleanupHighlight(player)
end)

VisualTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Team ~= game.Players.LocalPlayer.Team then
                    if not existingHighlights[player] then
                        createHighlight(player)
                    end
                end
            end
        else
            for player, highlight in pairs(existingHighlights) do
                highlight.Visible = false
            end
        end
    end,
})

local function getNearestPlayerWithHitbox()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local localPlayerPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position

    for _, v in pairs(game.Players:GetPlayers()) do
        if v.Name ~= game.Players.LocalPlayer.Name and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hitboxPart = v.Character.HumanoidRootPart
            local distance = (hitboxPart.Position - localPlayerPos).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = v
            end
        end
    end

    return closestPlayer
end

local function expandHitboxes()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v.Name ~= game.Players.LocalPlayer.Name and v.Character then
            local partsToExpand = {
                "RightUpperLeg",
                "LeftUpperLeg",
                "Head",
                "HumanoidRootPart"
            }

            for _, partName in pairs(partsToExpand) do
                local part = v.Character:FindFirstChild(partName)
                if part then
                    part.CanCollide = false
                    part.Transparency = 1
                    part.Size = Vector3.new(27, 27, 27)
                end
            end
        end
    end
end

local function performRaycast(origin, direction, targetPlayer)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {targetPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

    local result = workspace:Raycast(origin, direction, raycastParams)
    if result and result.Instance and result.Instance:IsDescendantOf(targetPlayer.Character) then
        return true
    end

    return false
end

local function shootAtNearestTarget()
    local target = getNearestPlayerWithHitbox()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hitboxPart = target.Character.HumanoidRootPart
        local origin = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
        local direction = (hitboxPart.Position - origin).unit * 500

        if performRaycast(origin, direction, target) then
        end
    end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Weapons = ReplicatedStorage:WaitForChild("Weapons")

local function modifyWeaponStats()
    for _, weapon in pairs(Weapons:GetChildren()) do
        if weapon:IsA("Folder") then
            for _, v in pairs(weapon:GetChildren()) do
                if v.ClassName == "IntValue" or v.ClassName == "NumberValue" then
                    if v.Name == "RecoilControl" then
                        v.Value = 0.05
                    elseif v.Name == "Spread" then
                        v.Value = 0.01
                    elseif v.Name == "MaxSpread" then
                        v.Value = 0.01
                    elseif v.Name == "SpreadRecovery" then
                        v.Value = 0.01
                    elseif v.Name == "FireRate" then
                        v.Value = 0.05
                    elseif v.Name == "Ammo" then
                        v.Value = 999
                    elseif v.Name == "ReloadTime" then
                        v.Value = 0.01
                    elseif v.Name == "Falloff" then
                        v.Value = 3000
                    elseif v.Name == "Speed%" then
                        v.Value = 1
                    elseif v.Name == "Range" then
                        v.Value = 2000
                    elseif v.Name == "Auto" then
                        v.Value = true
                    elseif v.Name == "EquipTime" then
                        v.Value = 0
                    elseif v.Name == "SelfDamage" then
                        v.Value = 0
                    elseif v.Name == "ChargeTime" then
                        v.Value = 0.01
                    elseif v.Name == "SFireRate" then
                        v.Value = 0.05
                    elseif v.Name == "BlastRadius" then
                        v.Value = 125
                    elseif v.Name == "BulletSpeed" then
                        v.Value = 7500
                    elseif v.Name == "Bullet" then
                        v.Value = 6
                    end
                end
            end
        end
    end
end

modifyWeaponStats()

while wait(1) do
    expandHitboxes()
    shootAtNearestTarget()
end

setfpscap(999)
game:GetService("RunService").Stepped:Connect(function()
    setfpscap(999)
end)

-- Removed the Server Hop button and its functionality
