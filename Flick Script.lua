-- Delta Executor / Roblox Exploit Script
-- Flick Game Cheat Menu with Draggable Button, Aimbot, WallCheck, AutoFarm, RageBot (FOV, AutoShot, AntiAim), BHop

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCheatMenu"
ScreenGui.Parent = game.CoreGui -- or game.Players.LocalPlayer.PlayerGui

-- Draggable Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0, 20, 0, 200)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Text = "F"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 24
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = ScreenGui

-- Make button draggable
local function makeDraggable(obj)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    obj.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(ToggleButton)

-- Main Menu Frame (initially hidden)
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 240, 0, 420) -- Increased height for new options
MenuFrame.Position = UDim2.new(0, 100, 0, 200)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.Parent = ScreenGui

-- Make menu draggable (using its title bar)
local TitleBar = Instance.new("TextButton")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Text = "Delta Menu"
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 16
TitleBar.TextColor3 = Color3.new(1, 1, 1)
TitleBar.AutoButtonColor = false
TitleBar.Parent = MenuFrame

makeDraggable(TitleBar) -- Dragging by title bar moves whole menu

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.AutoButtonColor = false
CloseButton.Parent = TitleBar

CloseButton.MouseButton1Click:Connect(function()
    MenuFrame.Visible = false
    ToggleButton.Visible = true
end)

-- Toggle Aimbot (simple)
local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(1, -20, 0, 30)
AimbotToggle.Position = UDim2.new(0, 10, 0, 40)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
AimbotToggle.BorderSizePixel = 0
AimbotToggle.Text = "Aimbot: OFF"
AimbotToggle.Font = Enum.Font.SourceSans
AimbotToggle.TextSize = 14
AimbotToggle.TextColor3 = Color3.new(1, 1, 1)
AimbotToggle.AutoButtonColor = false
AimbotToggle.Parent = MenuFrame

local aimbotEnabled = false
AimbotToggle.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimbotToggle.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    if aimbotEnabled and rageBotEnabled then
        rageBotEnabled = false
        RageBotToggle.Text = "RageBot: OFF"
        RageBotToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end)

-- Toggle WallCheck
local WallCheckToggle = Instance.new("TextButton")
WallCheckToggle.Size = UDim2.new(1, -20, 0, 30)
WallCheckToggle.Position = UDim2.new(0, 10, 0, 80)
WallCheckToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
WallCheckToggle.BorderSizePixel = 0
WallCheckToggle.Text = "WallCheck: ON"
WallCheckToggle.Font = Enum.Font.SourceSans
WallCheckToggle.TextSize = 14
WallCheckToggle.TextColor3 = Color3.new(1, 1, 1)
WallCheckToggle.AutoButtonColor = false
WallCheckToggle.Parent = MenuFrame

local wallCheckEnabled = true
WallCheckToggle.MouseButton1Click:Connect(function()
    wallCheckEnabled = not wallCheckEnabled
    WallCheckToggle.Text = "WallCheck: " .. (wallCheckEnabled and "ON" or "OFF")
    WallCheckToggle.BackgroundColor3 = wallCheckEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
end)

-- Toggle AutoFarm
local AutoFarmToggle = Instance.new("TextButton")
AutoFarmToggle.Size = UDim2.new(1, -20, 0, 30)
AutoFarmToggle.Position = UDim2.new(0, 10, 0, 120)
AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
AutoFarmToggle.BorderSizePixel = 0
AutoFarmToggle.Text = "AutoFarm: OFF"
AutoFarmToggle.Font = Enum.Font.SourceSans
AutoFarmToggle.TextSize = 14
AutoFarmToggle.TextColor3 = Color3.new(1, 1, 1)
AutoFarmToggle.AutoButtonColor = false
AutoFarmToggle.Parent = MenuFrame

local autoFarmEnabled = false
AutoFarmToggle.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    AutoFarmToggle.Text = "AutoFarm: " .. (autoFarmEnabled and "ON" or "OFF")
    AutoFarmToggle.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    if autoFarmEnabled then
        task.spawn(autoFarmLoop)
    end
end)

-- Toggle RageBot
local RageBotToggle = Instance.new("TextButton")
RageBotToggle.Size = UDim2.new(1, -20, 0, 30)
RageBotToggle.Position = UDim2.new(0, 10, 0, 160)
RageBotToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
RageBotToggle.BorderSizePixel = 0
RageBotToggle.Text = "RageBot: OFF"
RageBotToggle.Font = Enum.Font.SourceSans
RageBotToggle.TextSize = 14
RageBotToggle.TextColor3 = Color3.new(1, 1, 1)
RageBotToggle.AutoButtonColor = false
RageBotToggle.Parent = MenuFrame

local rageBotEnabled = false
local rageBotSettingsVisible = false

-- RageBot Settings Panel (initially hidden)
local RageSettingsFrame = Instance.new("Frame")
RageSettingsFrame.Size = UDim2.new(1, -20, 0, 130)
RageSettingsFrame.Position = UDim2.new(0, 10, 0, 195)
RageSettingsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RageSettingsFrame.BorderSizePixel = 0
RageSettingsFrame.Visible = false
RageSettingsFrame.Parent = MenuFrame

-- FOV Toggle inside RageBot settings
local FOVToggle = Instance.new("TextButton")
FOVToggle.Size = UDim2.new(1, -20, 0, 25)
FOVToggle.Position = UDim2.new(0, 10, 0, 10)
FOVToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FOVToggle.BorderSizePixel = 0
FOVToggle.Text = "FOV: OFF (360)"
FOVToggle.Font = Enum.Font.SourceSans
FOVToggle.TextSize = 12
FOVToggle.TextColor3 = Color3.new(1, 1, 1)
FOVToggle.AutoButtonColor = false
FOVToggle.Parent = RageSettingsFrame

local fovEnabled = false
FOVToggle.MouseButton1Click:Connect(function()
    fovEnabled = not fovEnabled
    FOVToggle.Text = "FOV: " .. (fovEnabled and "ON" or "OFF (360)")
    FOVToggle.BackgroundColor3 = fovEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
end)

-- AutoShot Toggle
local AutoShotToggle = Instance.new("TextButton")
AutoShotToggle.Size = UDim2.new(1, -20, 0, 25)
AutoShotToggle.Position = UDim2.new(0, 10, 0, 40)
AutoShotToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
AutoShotToggle.BorderSizePixel = 0
AutoShotToggle.Text = "AutoShot: OFF"
AutoShotToggle.Font = Enum.Font.SourceSans
AutoShotToggle.TextSize = 12
AutoShotToggle.TextColor3 = Color3.new(1, 1, 1)
AutoShotToggle.AutoButtonColor = false
AutoShotToggle.Parent = RageSettingsFrame

local autoShotEnabled = false
AutoShotToggle.MouseButton1Click:Connect(function()
    autoShotEnabled = not autoShotEnabled
    AutoShotToggle.Text = "AutoShot: " .. (autoShotEnabled and "ON" or "OFF")
    AutoShotToggle.BackgroundColor3 = autoShotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
end)

-- AntiAim Selection (Cycles through 5 options)
local AntiAimButton = Instance.new("TextButton")
AntiAimButton.Size = UDim2.new(1, -20, 0, 25)
AntiAimButton.Position = UDim2.new(0, 10, 0, 70)
AntiAimButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
AntiAimButton.BorderSizePixel = 0
AntiAimButton.Text = "AntiAim: None"
AntiAimButton.Font = Enum.Font.SourceSans
AntiAimButton.TextSize = 12
AntiAimButton.TextColor3 = Color3.new(1, 1, 1)
AntiAimButton.AutoButtonColor = false
AntiAimButton.Parent = RageSettingsFrame

local antiAimOptions = {"None", "Spin", "Jitter", "Backward", "Sideways", "Random"}
local antiAimIndex = 1 -- 1 = None
AntiAimButton.MouseButton1Click:Connect(function()
    antiAimIndex = antiAimIndex % #antiAimOptions + 1
    AntiAimButton.Text = "AntiAim: " .. antiAimOptions[antiAimIndex]
    AntiAimButton.BackgroundColor3 = antiAimIndex > 1 and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
end)

-- Info label for RageBot settings
local RageInfoLabel = Instance.new("TextLabel")
RageInfoLabel.Size = UDim2.new(1, -20, 0, 20)
RageInfoLabel.Position = UDim2.new(0, 10, 0, 100)
RageInfoLabel.BackgroundTransparency = 1
RageInfoLabel.Text = "RageBot Settings"
RageInfoLabel.Font = Enum.Font.SourceSans
RageInfoLabel.TextSize = 12
RageInfoLabel.TextColor3 = Color3.new(1, 1, 1)
RageInfoLabel.Parent = RageSettingsFrame

-- Toggle RageBot settings visibility when RageBot is toggled
RageBotToggle.MouseButton1Click:Connect(function()
    rageBotEnabled = not rageBotEnabled
    RageBotToggle.Text = "RageBot: " .. (rageBotEnabled and "ON" or "OFF")
    RageBotToggle.BackgroundColor3 = rageBotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    rageBotSettingsVisible = rageBotEnabled
    RageSettingsFrame.Visible = rageBotSettingsVisible
    if rageBotEnabled and aimbotEnabled then
        aimbotEnabled = false
        AimbotToggle.Text = "Aimbot: OFF"
        AimbotToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end
end)

-- BHop Toggle
local BHopToggle = Instance.new("TextButton")
BHopToggle.Size = UDim2.new(1, -20, 0, 30)
BHopToggle.Position = UDim2.new(0, 10, 0, 335) -- Adjust position after RageBot settings
BHopToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BHopToggle.BorderSizePixel = 0
BHopToggle.Text = "BHop: OFF"
BHopToggle.Font = Enum.Font.SourceSans
BHopToggle.TextSize = 14
BHopToggle.TextColor3 = Color3.new(1, 1, 1)
BHopToggle.AutoButtonColor = false
BHopToggle.Parent = MenuFrame

local bhopEnabled = false
local defaultWalkSpeed = 16 -- typical default
local bhopSpeedMultiplier = 1.5 -- speed boost when in air

BHopToggle.MouseButton1Click:Connect(function()
    bhopEnabled = not bhopEnabled
    BHopToggle.Text = "BHop: " .. (bhopEnabled and "ON" or "OFF")
    BHopToggle.BackgroundColor3 = bhopEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    if not bhopEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = defaultWalkSpeed
        end
    end
end)

-- Toggle button click
ToggleButton.MouseButton1Click:Connect(function()
    MenuFrame.Visible = not MenuFrame.Visible
    ToggleButton.Visible = not MenuFrame.Visible
end)

-- Helper: Raycast to check if wall between two points
local function isWallBetween(origin, targetPos, ignoreList)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.IgnoreWater = true

    local direction = (targetPos - origin)
    local distance = direction.Magnitude
    if distance == 0 then return false end
    direction = direction.Unit

    local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
    if raycastResult then
        return true
    end
    return false
end

-- Helper: Find nearest target with optional FOV check (for RageBot)
local function findNearestTarget(useFOV, fovAngle)
    local localChar = LocalPlayer.Character
    if not localChar then return nil end
    local localHumanoidRootPart = localChar:FindFirstChild("HumanoidRootPart")
    if not localHumanoidRootPart then return nil end

    local cameraPos = Camera.CFrame.Position
    local cameraLook = Camera.CFrame.LookVector
    local nearestTarget = nil
    local nearestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local targetRootPart = character:FindFirstChild("HumanoidRootPart")
                local targetHead = character:FindFirstChild("Head")
                if humanoid and humanoid.Health > 0 and targetRootPart and targetHead then
                    local targetPos = targetHead.Position
                    local distance = (cameraPos - targetPos).Magnitude
                    if distance < nearestDistance then
                        -- Wallcheck logic
                        local ignoreList = {localChar, character}
                        if wallCheckEnabled and isWallBetween(cameraPos, targetPos, ignoreList) then
                            continue
                        end
                        -- FOV check if enabled
                        if useFOV then
                            local directionToTarget = (targetPos - cameraPos).Unit
                            local angle = math.acos(math.clamp(cameraLook:Dot(directionToTarget), -1, 1))
                            if math.deg(angle) > fovAngle then
                                continue
                            end
                        end
                        nearestTarget = character
                        nearestDistance = distance
                    end
                end
            end
        end
    end
    return nearestTarget
end

-- Helper: Equip knife
local function equipKnife()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("меч") or tool.Name:lower():find("нож")) then
                humanoid:EquipTool(tool)
                return tool
            end
        end
    end
    local equipped = character:FindFirstChildOfClass("Tool")
    if equipped then return equipped end
    return nil
end

-- Helper: Attack with knife
local function attackWithKnife()
    local knife = equipKnife()
    if knife then
        knife:Activate()
        task.wait(0.1)
    end
end

-- Helper: Check if round is active
local function isRoundActive()
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local otherChar = player.Character
            if otherChar then
                local otherHumanoid = otherChar:FindFirstChild("Humanoid")
                if otherHumanoid and otherHumanoid.Health > 0 then
                    return true
                end
            end
        end
    end
    return false
end

-- Helper: Auto join round
local function autoJoinRound()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local possibleNames = {"Play", "Ready", "Start", "Играть", "Готов", "Join", "Continue", "Respawn"}
    for _, guiObj in ipairs(playerGui:GetDescendants()) do
        if guiObj:IsA("TextButton") or guiObj:IsA("ImageButton") then
            local text = guiObj.Text or ""
            for _, name in ipairs(possibleNames) do
                if text:lower():find(name:lower()) then
                    guiObj:InvokeClient()
                    local clickEvent = guiObj.MouseButton1Click
                    if clickEvent then clickEvent:Fire() end
                    return true
                end
            end
        end
    end
    return false
end

-- AutoFarm Loop
function autoFarmLoop()
    while autoFarmEnabled and LocalPlayer do
        if isRoundActive() then
            local target = findNearestTarget(false, 0)
            if target then
                local targetRoot = target:FindFirstChild("HumanoidRootPart")
                local localChar = LocalPlayer.Character
                local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
                if targetRoot and localRoot then
                    local behindOffset = targetRoot.CFrame.LookVector * -3
                    local newPos = targetRoot.Position + behindOffset
                    localRoot.CFrame = CFrame.new(newPos, targetRoot.Position)
                    task.wait(0.1)
                    attackWithKnife()
                end
            end
            task.wait(0.5)
        else
            autoJoinRound()
            task.wait(2)
        end
        task.wait()
    end
end

-- AntiAim function
local function applyAntiAim(character)
    local antiAimType = antiAimOptions[antiAimIndex]
    if antiAimType == "None" or not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local currentCF = rootPart.CFrame
    local newCF = currentCF

    if antiAimType == "Spin" then
        newCF = currentCF * CFrame.Angles(0, math.rad(10), 0) -- rotate 10 degrees each frame
    elseif antiAimType == "Jitter" then
        local randomAngle = math.rad(math.random(-30, 30))
        newCF = currentCF * CFrame.Angles(0, randomAngle, 0)
    elseif antiAimType == "Backward" then
        newCF = CFrame.new(currentCF.Position, currentCF.Position - currentCF.LookVector) -- face opposite
    elseif antiAimType == "Sideways" then
        newCF = currentCF * CFrame.Angles(0, math.rad(90), 0)
    elseif antiAimType == "Random" then
        local randomYaw = math.rad(math.random(0, 360))
        newCF = CFrame.new(currentCF.Position) * CFrame.Angles(0, randomYaw, 0)
    end
    rootPart.CFrame = newCF
end

-- BHop implementation
local function handleBHop()
    if not bhopEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
        humanoid.WalkSpeed = defaultWalkSpeed * bhopSpeedMultiplier
    else
        humanoid.WalkSpeed = defaultWalkSpeed
    end
end

-- Main RenderStepped loop for Aimbot, RageBot, AntiAim, BHop
RunService.RenderStepped:Connect(function()
    -- AntiAim (only if RageBot enabled and antiAim not None)
    if rageBotEnabled then
        local character = LocalPlayer.Character
        if character then
            applyAntiAim(character)
        end
    end

    -- Aimbot / RageBot aiming
    if rageBotEnabled then
        local target = findNearestTarget(fovEnabled, 90) -- default FOV angle 90 if enabled
        if target then
            local targetHead = target:FindFirstChild("Head")
            if targetHead then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
                if autoShotEnabled then
                    -- Auto attack
                    attackWithKnife()
                end
            end
        end
    elseif aimbotEnabled then
        local target = findNearestTarget(false, 0)
        if target then
            local targetHead = target:FindFirstChild("Head")
            if targetHead then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
            end
        end
    end

    -- BHop
    handleBHop()
end)

-- Initial visibility
MenuFrame.Visible = false
ToggleButton.Visible = true
