-- [[ СЕРВИСЫ ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ НАСТРОЙКИ ХАБА ]] --
local Settings = {
    AimbotEnabled = false,
    FlickMode = false,
    WallCheck = false,
    AimFOV = 100,
    FlickFOV = 150,
    FlickDelay = 0.01,
    TargetPart = "Head",
    -- Визуалы
    EspBox = false,
    EspCharms = false,
    EspLines = false,
    -- Плавный BHOp
    BHopEnabled = false,
    BHopPower = 1
}

local ESP_Cache = {}
local NormalSpeed = 16
local CurrentBHopSpeed = NormalSpeed

-- [[ GUI ХАБА ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobilePredictionHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = ScreenGui
local TBCorner = Instance.new("UICorner"); TBCorner.CornerRadius = UDim.new(0, 28); TBCorner.Parent = ToggleButton
makeDraggable(ToggleButton)

local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 280, 0, 500)
MainMenu.Position = UDim2.new(0.5, -140, 0.5, -250)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui
local MenuCorner = Instance.new("UICorner"); MenuCorner.CornerRadius = UDim.new(0, 10); MenuCorner.Parent = MainMenu
makeDraggable(MainMenu)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "PREDICTION & ESP HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainMenu

ToggleButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 720)
Scroll.ScrollBarThickness = 4
Scroll.Parent = MainMenu
local ContentLayout = Instance.new("UIListLayout"); ContentLayout.Padding = UDim.new(0, 6); ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; ContentLayout.Parent = Scroll

local function createToggle(parent, text, settingName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = parent
    btn.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        btn.Text = text .. (Settings[settingName] and ": ON" or ": OFF")
        btn.TextColor3 = Settings[settingName] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end)
end

local function createSlider(parent, text, min, max, default, isFloat, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20); label.BackgroundTransparency = 1
    label.Text = text .. ": " .. string.format(isFloat and "%.2f" or "%d", default)
    label.TextColor3 = Color3.fromRGB(255, 255, 255); label.TextSize = 13; label.Parent = parent

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 10); bg.BackgroundColor3 = Color3.fromRGB(45, 45, 45); bg.Parent = parent
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 14, 1, 0); btn.BackgroundColor3 = Color3.fromRGB(0, 255, 200); btn.Text = ""; btn.Parent = bg

    local initPercent = (default - min) / (max - min)
    btn.Position = UDim2.new(initPercent, -7, 0, 0)

    local active = false
    bg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then active = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then active = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local sizeX = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            btn.Position = UDim2.new(sizeX, -7, 0, 0)
            local value = min + (sizeX * (max - min))
            if not isFloat then value = math.floor(value) end
            label.Text = text .. ": " .. string.format(isFloat and "%.2f" or "%d", value)
            callback(value)
        end
    end)
end

createToggle(Scroll, "On-Shot Flick", "FlickMode")
createToggle(Scroll, "Combat Aimbot", "AimbotEnabled")
createToggle(Scroll, "Wallcheck Bypass", "WallCheck")
createToggle(Scroll, "Beautiful Lines", "EspLines")
createToggle(Scroll, "Visual ESP Box", "EspBox")
createToggle(Scroll, "Visual Charms", "EspCharms")
createToggle(Scroll, "Smooth BunnyHop", "BHopEnabled")

createSlider(Scroll, "Aim FOV", 10, 900, Settings.AimFOV, false, function(v) Settings.AimFOV = v v end)
createSlider(Scroll, "Flick FOV", 10, 900, Settings.FlickFOV, false, function(v) Settings.FlickFOV = v end)
createSlider(Scroll, "Flick Delay", 0.01, 1.00, Settings.FlickDelay, true, function(v) Settings.FlickDelay = v end)
createSlider(Scroll, "BHop Power", 1, 10, Settings.BHopPower, false, function(v) Settings.BHopPower = v end)

-- [[ КОРРЕКТНЫЙ ЦЕНТР ЭКРАНА ДЛЯ FOV ]] --
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = true; FOV_Circle.Thickness = 1; FOV_Circle.NumSides = 64; FOV_Circle.Filled = false

-- [[ ЛОГИКА WALLCHECK ]] --
local function isVisible(targetPart, character)
    if not Settings.WallCheck then return true end
    local ignore = {LocalPlayer.Character, character, Camera}
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = ignore
    local res = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, params)
    return res == nil
end

-- [[ АЛГОРИТМ УПРЕЖДЕНИЯ (AIM PREDICTION) ]] --
local function getPredictedPosition(targetPart, targetCharacter)
    local hrp = targetCharacter:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- Считываем физическую скорость движения врага в 3D пространстве
        local velocity = hrp.AssemblyLinearVelocity
        -- Рассчитываем дистанцию между нами и врагом
        local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
        
        -- Динамический коэффицент времени полета пули/доводки (Пинг + Дистанция/Скорость + Ручная задержка)
        local pingComp = 0.03 
        local timeToTarget = (distance / 300) + Settings.FlickDelay + pingComp
        
        -- Прогнозируем точку нахождения головы
        return targetPart.Position + (velocity * timeToTarget)
    end
    return targetPart.Position
end

-- Поиск цели к центру
local function getClosestPlayer(currentFOV)
    local closestTarget, closestChar, maxDistance = nil, nil, currentFOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
            if humanoid and humanoid.Health > 0 and targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distance < maxDistance and isVisible(targetPart, player.Character) then
                        maxDistance = distance; closestTarget = targetPart; closestChar = player.Character
                    end
                end
            end
        end
    end
    return closestTarget, closestChar
end

-- Выполнение Flick-шота с упреждением
local function doFlickShot()
    local targetPart, targetChar = getClosestPlayer(Settings.FlickFOV)
    if targetPart and targetChar then
        task.delay(Settings.FlickDelay, function()
if targetPart and targetPart.Parent and targetChar:FindFirstChildOfClass("Humanoid") and targetChar:FindFirstChildOfClass("Humanoid").Health > 0 then
-- Наводимся не в текущую позицию, а в рассчитанную точку упреждения
local predictedPos = getPredictedPosition(targetPart, targetChar)
Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
end
end)
end
end

UserInputService.InputBegan:Connect(function(input, processed)
if processed then return end
if Settings.FlickMode and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
doFlickShot()
end
end)

-- [[ СОЗДАНИЕ КРАСИВЫХ ЛИНИЙ И ESP ]] --
local function createESP(player)
if ESP_Cache[player] then return end

local box = Drawing.new("Square"); box.Color = Color3.fromRGB(0, 255, 200); box.Thickness = 1.5; box.Filled = false; box.Visible = false

-- Основная неоновая линия
local mainLine = Drawing.new("Line")
mainLine.Color = Color3.fromRGB(0, 255, 200)
mainLine.Thickness = 2 -- Сделали толще для красоты
mainLine.Visible = false

-- Линия тени (создает красивый неоновый 3D объем на экране)
local shadowLine = Drawing.new("Line")
shadowLine.Color = Color3.fromRGB(0, 0, 0)
shadowLine.Thickness = 4 -- Шире основной, ложится под низ
shadowLine.Transparency = 0.5
shadowLine.Visible = false

local charms = Instance.new("Highlight"); charms.FillColor = Color3.fromRGB(0, 255, 200); charms.FillTransparency = 0.5; charms.OutlineColor = Color3.fromRGB(255, 255, 255); charms.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; charms.Enabled = false

ESP_Cache[player] = {Box = box, MainLine = mainLine, ShadowLine = shadowLine, Charms = charms}
end

local function removeESP(player)
if ESP_Cache[player] then
ESP_Cache[player].Box:Remove()
ESP_Cache[player].MainLine:Remove()
ESP_Cache[player].ShadowLine:Remove()
if ESP_Cache[player].Charms then ESP_Cache[player].Charms:Destroy() end
ESP_Cache[player] = nil
end
end

Players.PlayerAdded:Connect(createESP); Players.PlayerRemoving:Connect(removeESP)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end

-- [[ ЛОГИКА BHOP ]] --
local function handleSmoothBHop()
if not Settings.BHopEnabled then return end
local character = LocalPlayer.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if humanoid then
local currentState = humanoid:GetState()
local isInAir = (currentState == Enum.HumanoidStateType.Freefall or currentState == Enum.HumanoidStateType.Jumping)
if isInAir and humanoid.MoveDirection.Magnitude > 0 then
local accelerationStep = Settings.BHopPower * 0.4
local maxAllowedSpeed = NormalSpeed + (Settings.BHopPower * 6)
CurrentBHopSpeed = math.clamp(CurrentBHopSpeed + accelerationStep, NormalSpeed, maxAllowedSpeed)
humanoid.WalkSpeed = CurrentBHopSpeed
else
CurrentBHopSpeed = NormalSpeed; humanoid.WalkSpeed = NormalSpeed
end
end
end
-- [[ ЦИКЛ ОБНОВЛЕНИЯ (RENDERSTEPPED) ]] --
RunService.RenderStepped:Connect(function()
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOV_Circle.Position = screenCenter
FOV_Circle.Radius = Settings.FlickMode and Settings.FlickFOV or Settings.AimFOV
FOV_Circle.Color = Settings.FlickMode and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(0, 255, 200)

handleSmoothBHop()

-- Логика обычного Аимбота с упреждением
if Settings.AimbotEnabled and not Settings.FlickMode then
local targetPart, targetChar = getClosestPlayer(Settings.AimFOV)
if targetPart and targetChar then
local predictedPos = getPredictedPosition(targetPart, targetChar)
Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
end
end

-- Рендер красивого ESP и Линий
for player, visual in pairs(ESP_Cache) do
local character = player.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local hrp = character and character:FindFirstChild("HumanoidRootPart")
local head = character and character:FindFirstChild("Head")

if character and humanoid and hrp and head and humanoid.Health > 0 then
local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

-- Отрезаем Z координату для отрисовки линий 2D
local target2D = Vector2.new(hrpPos.X, hrpPos.Y)
-- Считаем дистанцию для кастомизации прозрачности
local distance = (Camera.CFrame.Position - hrp.Position).Magnitude

if Settings.EspBox and onScreen then
local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
local height = math.abs(headPos.Y - legPos.Y); local width = height / 1.5
visual.Box.Size = Vector2.new(width, height); visual.Box.Position = Vector2.new(hrpPos.X - width / 2, hrpPos.Y - height / 2); visual.Box.Visible = true
else visual.Box.Visible = false end

-- КРАСИВЫЕ КАСКАДНЫЕ ЛИНИИ СКВОЗЬ СТЕНЫ
if Settings.EspLines and onScreen then
-- Динамическое угасание линии в зависимости от дальности до игрока
local dynamicTransparency = math.clamp(1 - (distance / 500), 0.3, 1)

-- 1. Отрисовка подложки-тени
visual.ShadowLine.From = screenCenter
visual.ShadowLine.To = target2D
visual.ShadowLine.Transparency = dynamicTransparency * 0.4
visual.ShadowLine.Visible = true

-- 2. Отрисовка основной неоновой линии поверх тени
visual.MainLine.From = screenCenter
visual.MainLine.To = target2D
visual.MainLine.Transparency = dynamicTransparency
-- Цвет плавно переходит от бирюзового к красному, если враг подошел вплотную
visual.MainLine.Color = distance < 40 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 200)
visual.MainLine.Visible = true
else
visual.MainLine.Visible = false
visual.ShadowLine.Visible = false
end

if Settings.EspCharms then visual.Charms.Parent = character; visual.Charms.Enabled = true
else visual.Charms.Enabled = false end
else
visual.Box.Visible = false; visual.MainLine.Visible = false; visual.ShadowLine.Visible = false; visual.Charms.Enabled = false
end
end
end)
