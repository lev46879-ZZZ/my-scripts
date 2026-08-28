-- Flick Mode для Delta (мгновенный аимбот + перетаскиваемая кнопка + анимация меню)
-- ВНИМАНИЕ: использование читов нарушает правила Roblox.

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- Настройки
local settings = {
    BHop = false,
    Aimbot = false,
    WallCheck = true,
    TeamCheck = true,
    BHopPower = 5,
    FOV = 100,
}

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Перетаскиваемая кнопка
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0, 100)  -- начальная позиция
toggleButton.Text = "⚡"
toggleButton.TextSize = 30
toggleButton.BackgroundColor3 = Color3.new(0.15, 0.15, 0.25)
toggleButton.TextColor3 = Color3.new(1, 1, 0)
toggleButton.Parent = screenGui

-- Перетаскивание кнопки
local dragging = false
local dragStartPos, dragStartMouse

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = toggleButton.Position
        dragStartMouse = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartMouse
        toggleButton.Position = UDim2.new(
            dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X,
            dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y
        )
    end
end)

-- Меню с анимацией появления
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 320, 0, 420)
menuFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
menuFrame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.12)
menuFrame.BackgroundTransparency = 1  -- сначала прозрачное
menuFrame.Visible = false
menuFrame.Parent = screenGui

-- Эффект "загрузчика" – плавное появление
local function showMenu(show)
    menuFrame.Visible = true
    menuFrame.BackgroundTransparency = 1
    menuFrame.Size = UDim2.new(0, 0, 0, 0)
    menuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goal = {
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 320, 0, 420),
        Position = UDim2.new(0.5, -160, 0.5, -210)
    }
    local tween = tweenService:Create(menuFrame, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
    if not show then
        menuFrame.Visible = false
    end
end

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "Flick Mode Settings"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = menuFrame

-- Вспомогательные функции для элементов
local function createToggle(labelText, initial, callback, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = menuFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = labelText
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 1, -4)
    toggle.Position = UDim2.new(0.7, 0, 0, 2)
    toggle.Text = initial and "ON" or "OFF"
    toggle.BackgroundColor3 = initial and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Parent = frame

    toggle.MouseButton1Click:Connect(function()
        local newState = not (toggle.Text == "ON")
        toggle.Text = newState and "ON" or "OFF"
        toggle.BackgroundColor3 = newState and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
        callback(newState)
    end)
end

local function createSlider(labelText, min, max, default, callback, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = menuFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = labelText .. ": " .. tostring(default)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(0.3, 0, 1, -4)
    slider.Position = UDim2.new(0.65, 0, 0, 2)
    slider.Text = tostring(default)
    slider.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
    slider.TextColor3 = Color3.new(1,1,1)
    slider.Parent = frame

    slider.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(slider.Text)
            if num then
                num = math.clamp(num, min, max)
                slider.Text = tostring(num)
                callback(num)
                label.Text = labelText .. ": " .. tostring(num)
            else
                slider.Text = tostring(default)
            end
        end
    end)
end

-- Создаём элементы
local yPos = 40
createToggle("BHop", settings.BHop, function(v) settings.BHop = v end, yPos)
yPos = yPos + 35
createToggle("Aimbot", settings.Aimbot, function(v) settings.Aimbot = v end, yPos)
yPos = yPos + 35
createToggle("WallCheck", settings.WallCheck, function(v) settings.WallCheck = v end, yPos)
yPos = yPos + 35
createToggle("TeamCheck", settings.TeamCheck, function(v) settings.TeamCheck = v end, yPos)
yPos = yPos + 35
createSlider("BHop Power", 1, 10, settings.BHopPower, function(v) settings.BHopPower = v end, yPos)
yPos = yPos + 35
-- Можно добавить FOV слайдер, но для простоты опустим

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 60, 0, 30)
closeButton.Position = UDim2.new(1, -70, 0, 5)
closeButton.Text = "Закрыть"
closeButton.BackgroundColor3 = Color3.new(0.5,0,0)
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.Parent = menuFrame
closeButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
end)

-- Открытие меню по кнопке (с анимацией)
toggleButton.MouseButton1Click:Connect(function()
    if menuFrame.Visible then
        menuFrame.Visible = false
    else
        showMenu(true)
    end
end)

-- Также открытие по Insert
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if menuFrame.Visible then
            menuFrame.Visible = false
        else
            showMenu(true)
        end
    end
end)

-- ===== BHop (без изменений) =====
local originalWalkSpeed = humanoid.WalkSpeed
local isJumping = false

humanoid.StateChanged:Connect(function(oldState, newState)
    if newState == Enum.HumanoidStateType.Jumping then
        isJumping = true
        if settings.BHop then
            humanoid.WalkSpeed = originalWalkSpeed + settings.BHopPower * 2
        end
    elseif newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Freefall then
        isJumping = false
        if settings.BHop then
            humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    originalWalkSpeed = humanoid.WalkSpeed
    isJumping = false
end)

-- ===== Мгновенный Aimbot (без Lerp) =====
local function getClosestPlayer()
    local closest = nil
    local closestDist = math.huge
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if settings.TeamCheck and p.Team == player.Team then continue end
            local headPos = p.Character.Head.Position
            local vector, onScreen = camera:WorldToScreenPoint(headPos)
            if onScreen then
                local dist = (headPos - camera.CFrame.Position).Magnitude
                local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                local screenPos = Vector2.new(vector.X, vector.Y)
                if (screenPos - screenCenter).Magnitude < settings.FOV then
                    if dist < closestDist then
                        closestDist = dist
                        closest = p
                    end
                end
            end
        end
    end
    return closest
end

local function isWallBetween(origin, target)
    if not settings.WallCheck then return false end
    local direction = (target - origin).Unit
    local distance = (target - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {character}
    return workspace:Raycast(origin, direction * distance, params) ~= nil
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not settings.Aimbot then return end
    local target = getClosestPlayer()
    if target then
        local headPos = target.Character.Head.Position
        if not isWallBetween(camera.CFrame.Position, headPos) then
            -- Мгновенное наведение
            camera.CFrame = CFrame.new(camera.CFrame.Position, headPos)
        end
    end
end)
