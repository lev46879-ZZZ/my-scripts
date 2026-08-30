-- Delta Executor / Roblox Exploit Script
-- Flick Game Cheat Menu с Fly, Noclip, ESP, RageBot, AutoFarm, BHop

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCheatMenu"
ScreenGui.Parent = game.CoreGui

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

-- Main Menu
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 260, 0, 530)  -- увеличенная высота
MenuFrame.Position = UDim2.new(0, 100, 0, 200)
MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.Parent = ScreenGui

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
makeDraggable(TitleBar)

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

-- Функция для создания кнопки-переключателя
local function createToggleButton(parent, positionY, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, positionY)
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.AutoButtonColor = false
    btn.Parent = parent
    return btn
end

-- Переменные состояний
local aimbotEnabled = false
local wallCheckEnabled = true
local autoFarmEnabled = false
local rageBotEnabled = false
local fovEnabled = false
local autoShotEnabled = false
local bhopEnabled = false
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false

local antiAimOptions = {"None", "Spin", "Jitter", "Backward", "Sideways", "Random"}
local antiAimIndex = 1

-- --- Aimbot ---
local AimbotToggle = createToggleButton(MenuFrame, 40, "Aimbot: OFF")
AimbotToggle.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimbotToggle.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
    if aimbotEnabled and rageBotEnabled then
        rageBotEnabled = false
        RageBotToggle.Text = "RageBot: OFF"
        RageBotToggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
    end
end)

-- --- WallCheck ---
local WallCheckToggle = createToggleButton(MenuFrame, 80, "WallCheck: ON")
WallCheckToggle.MouseButton1Click:Connect(function()
    wallCheckEnabled = not wallCheckEnabled
    WallCheckToggle.Text = "WallCheck: " .. (wallCheckEnabled and "ON" or "OFF")
    WallCheckToggle.BackgroundColor3 = wallCheckEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
end)

-- --- AutoFarm ---
local AutoFarmToggle = createToggleButton(MenuFrame, 120, "AutoFarm: OFF")
AutoFarmToggle.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    AutoFarmToggle.Text = "AutoFarm: " .. (autoFarmEnabled and "ON" or "OFF")
    AutoFarmToggle.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
    if autoFarmEnabled then task.spawn(autoFarmLoop) end
end)

-- --- RageBot ---
local RageBotToggle = createToggleButton(MenuFrame, 160, "RageBot: OFF")
RageBotToggle.MouseButton1Click:Connect(function()
    rageBotEnabled = not rageBotEnabled
    RageBotToggle.Text = "RageBot: " .. (rageBotEnabled and "ON" or "OFF")
    RageBotToggle.BackgroundColor3 = rageBotEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
    RageSettingsFrame.Visible = rageBotEnabled
    if rageBotEnabled and aimbotEnabled then
        aimbotEnabled = false
        AimbotToggle.Text = "Aimbot: OFF"
        AimbotToggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
    end
end)

-- Настройки RageBot
local RageSettingsFrame = Instance.new("Frame")
RageSettingsFrame.Size = UDim2.new(1, -20, 0, 130)
RageSettingsFrame.Position = UDim2.new(0, 10, 0, 195)
RageSettingsFrame.BackgroundColor3 = Color3.fromRGB(45,45,45)
RageSettingsFrame.BorderSizePixel = 0
RageSettingsFrame.Visible = false
RageSettingsFrame.Parent = MenuFrame

local FOVToggle = createToggleButton(RageSettingsFrame, 10, "FOV: OFF (360)")
FOVToggle.MouseButton1Click:Connect(function()
    fovEnabled = not fovEnabled
    FOVToggle.Text = "FOV: " .. (fovEnabled and "ON" or "OFF (360)")
    FOVToggle.BackgroundColor3 = fovEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
end)

local AutoShotToggle = createToggleButton(RageSettingsFrame, 40, "AutoShot: OFF")
AutoShotToggle.MouseButton1Click:Connect(function()
    autoShotEnabled = not autoShotEnabled
    AutoShotToggle.Text = "AutoShot: " .. (autoShotEnabled and "ON" or "OFF")
    AutoShotToggle.BackgroundColor3 = autoShotEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
end)

local AntiAimButton = createToggleButton(RageSettingsFrame, 70, "AntiAim: None")
AntiAimButton.MouseButton1Click:Connect(function()
    antiAimIndex = antiAimIndex % #antiAimOptions + 1
    AntiAimButton.Text = "AntiAim: " .. antiAimOptions[antiAimIndex]
    AntiAimButton.BackgroundColor3 = antiAimIndex > 1 and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
end)

local RageInfoLabel = Instance.new("TextLabel")
RageInfoLabel.Size = UDim2.new(1, -20, 0, 20)
RageInfoLabel.Position = UDim2.new(0, 10, 0, 100)
RageInfoLabel.BackgroundTransparency = 1
RageInfoLabel.Text = "RageBot Settings"
RageInfoLabel.Font = Enum.Font.SourceSans
RageInfoLabel.TextSize = 12
RageInfoLabel.TextColor3 = Color3.new(1,1,1)
RageInfoLabel.Parent = RageSettingsFrame

-- --- BHop ---
local BHopToggle = createToggleButton(MenuFrame, 335, "BHop: OFF")
BHopToggle.MouseButton1Click:Connect(function()
    bhopEnabled = not bhopEnabled
    BHopToggle.Text = "BHop: " .. (bhopEnabled and "ON" or "OFF")
    BHopToggle.BackgroundColor3 = bhopEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
    if not bhopEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
    end
end)

-- --- Fly ---
local FlyToggle = createToggleButton(MenuFrame, 375, "Fly: OFF")
FlyToggle.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    FlyToggle.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
    FlyToggle.BackgroundColor3 = flyEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
    if flyEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
    end
end)

-- --- Noclip ---
local NoclipToggle = createToggleButton(MenuFrame, 415, "Noclip: OFF")
NoclipToggle.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    NoclipToggle.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
    NoclipToggle.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
    if not noclipEnabled then
        -- восстановить коллизии
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- --- ESP ---
local ESPToggle = createToggleButton(MenuFrame, 455, "ESP: OFF")
ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPToggle.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = espEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
    if not espEnabled then
        -- удалить все Highlight'ы
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("ESP_Highlight")
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

-- Главная кнопка
ToggleButton.MouseButton1Click:Connect(function()
    MenuFrame.Visible = not MenuFrame.Visible
    ToggleButton.Visible = not MenuFrame.Visible
end)

-- Вспомогательные функции
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
    return raycastResult ~= nil
end

local function findNearestTarget(useFOV, fovAngle)
    local localChar = LocalPlayer.Character
    if not localChar then return nil end
    local cameraPos = Camera.CFrame.Position
    local cameraLook = Camera.CFrame.LookVector
    local nearestTarget = nil
    local nearestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local targetHead = character:FindFirstChild("Head")
                if humanoid and humanoid.Health > 0 and targetHead then
                    local targetPos = targetHead.Position
                    local distance = (cameraPos - targetPos).Magnitude
                    if distance < nearestDistance then
                        local ignoreList = {localChar, character}
                        if wallCheckEnabled and isWallBetween(cameraPos, targetPos, ignoreList) then
                            continue
                        end
                        if useFOV then
                            local directionToTarget = (targetPos - cameraPos).Unit
                            local angle = math.acos(math.clamp(cameraLook:Dot(directionToTarget), -1, 1))
                            if math.deg(angle) > fovAngle then continue end
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

local function equipKnife()
    local character = LocalPlayer.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("меч") or tool.Name:lower():find("нож")) then
                humanoid:EquipTool(tool)
                return tool
            end
        end
    end
    return character:FindFirstChildOfClass("Tool")
end

local function attackWithKnife()
    local knife = equipKnife()
    if knife then
        knife:Activate()
        task.wait(0.1)
    end
end

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
                if otherHumanoid and otherHumanoid.Health > 0 then return true end
            end
        end
    end
    return false
end

local function autoJoinRound()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
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

local function applyAntiAim(character)
    local antiAimType = antiAimOptions[antiAimIndex]
    if antiAimType == "None" or not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local currentCF = rootPart.CFrame
    if antiAimType == "Spin" then
        rootPart.CFrame = currentCF * CFrame.Angles(0, math.rad(10), 0)
    elseif antiAimType == "Jitter" then
        local randomAngle = math.rad(math.random(-30, 30))
        rootPart.CFrame = currentCF * CFrame.Angles(0, randomAngle, 0)
    elseif antiAimType == "Backward" then
        rootPart.CFrame = CFrame.new(currentCF.Position, currentCF.Position - currentCF.LookVector)
    elseif antiAimType == "Sideways" then
        rootPart.CFrame = currentCF * CFrame.Angles(0, math.rad(90), 0)
    elseif antiAimType == "Random" then
        local randomYaw = math.rad(math.random(0, 360))
        rootPart.CFrame = CFrame.new(currentCF.Position) * CFrame.Angles(0, randomYaw, 0)
    end
end

local function handleBHop()
    if not bhopEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
        humanoid.WalkSpeed = 24  -- увеличенная скорость в воздухе
    else
        humanoid.WalkSpeed = 16
    end
end

local function handleFly()
    if not flyEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    humanoid.PlatformStand = true
    local speed = 50
    local direction = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.new(0, 1, 0) end
    if direction.Magnitude > 0 then
        rootPart.Velocity = direction.Unit * speed
    else
        rootPart.Velocity = Vector3.new(0, 0, 0)
    end
end

local function handleNoclip()
    if not noclipEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function handleESP()
    if not espEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local highlight = character:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.new(1, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = character
            end
            highlight.Enabled = true
        end
    end
end

-- Основной цикл
RunService.RenderStepped:Connect(function()
    if rageBotEnabled then
        local character = LocalPlayer.Character
        if character then applyAntiAim(character) end
    end

    if rageBotEnabled then
        local target = findNearestTarget(fovEnabled, 90)
        if target then
            local targetHead = target:FindFirstChild("Head")
            if targetHead then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
                if autoShotEnabled then attackWithKnife() end
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

    handleBHop()
    handleFly()
    handleNoclip()
    handleESP()
end)

-- Начальное состояние
MenuFrame.Visible = false
ToggleButton.Visible = true
