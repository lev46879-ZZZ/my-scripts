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
    -- Настройки визуалов (ESP)
    EspBox = false,
    EspCharms = false,
    EspLines = false
}

-- [[ ТАБЛИЦЫ ДЛЯ ХРАНЕНИЯ VISUALS ]] --
local ESP_Cache = {}

-- [[ СОЗДАНИЕ GUI ДЛЯ СМАРТФОНОВ ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileUltimateHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ПЛАВАЮЩАЯ КНОПКА (Открыть/Закрыть Меню)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = ScreenGui

local TBCorner = Instance.new("UICorner")
TBCorner.CornerRadius = UDim.new(0, 28)
TBCorner.Parent = ToggleButton
makeDraggable(ToggleButton)

-- ПЛАВАЮЩЕЕ МЕНЮ
local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 280, 0, 500) -- Увеличили размер под ESP кнопки
MainMenu.Position = UDim2.new(0.5, -140, 0.5, -250)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = MainMenu
makeDraggable(MainMenu)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "ULTIMATE LUA HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainMenu

ToggleButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- СКРОЛЛ КОНТЕНТА (Чтобы на маленьких экранах все влезало)
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
Scroll.ScrollBarThickness = 4
Scroll.Parent = MainMenu

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.Parent = Scroll

-- Функция создания кнопок-переключателей
local function createToggle(parent, text, settingName, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = parent

    local function updateText()
        btn.Text = text .. (Settings[settingName] and ": ON" or ": OFF")
        btn.TextColor3 = Settings[settingName] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end

    btn.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        updateText()
        if callback then callback(Settings[settingName]) end
    end)
end

-- Функция создания слайдеров
local function createSlider(parent, text, min, max, default, isFloat, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. string.format(isFloat and "%.2f" or "%d", default)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.SourceSans
    label.Parent = parent

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 10)
    bg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    bg.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 14, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    btn.Text = ""
    btn.Parent = bg

    local initPercent = (default - min) / (max - min)
    btn.Position = UDim2.new(initPercent, -7, 0, 0)

    local active = false
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then active = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then active = false end
    end)
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

-- Рендер элементов управления
createToggle(Scroll, "Combat Aimbot", "AimbotEnabled")
createToggle(Scroll, "On-Shot Flick", "FlickMode")
createToggle(Scroll, "Wallcheck Bypass", "WallCheck")
createToggle(Scroll, "Visual ESP Box", "EspBox")
createToggle(Scroll, "Visual Charms (WH)", "EspCharms")
createToggle(Scroll, "Visual Center Lines", "EspLines")

createSlider(Scroll, "Aim FOV", 10, 900, Settings.AimFOV, false, function(v) Settings.AimFOV = v end)
createSlider(Scroll, "Flick FOV", 10, 900, Settings.FlickFOV, false, function(v) Settings.FlickFOV = v end)
createSlider(Scroll, "Flick Delay", 0.01, 1.00, Settings.FlickDelay, true, function(v) Settings.FlickDelay = v end)

-- [[ КОРРЕКТНЫЙ ЦЕНТР ЭКРАНА ДЛЯ FOV ]] --
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = true
FOV_Circle.Color = Color3.fromRGB(0, 255, 200)
FOV_Circle.Thickness = 1
FOV_Circle.NumSides = 64
FOV_Circle.Filled = false

-- [[ ЛОГИКА WALLCHECK ]] --
local function isVisible(targetPart, character)
    if not Settings.WallCheck then return true end
    local ignoreList = {LocalPlayer.Character, character, Camera}
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = ignoreList
    local direction = targetPart.Position - Camera.CFrame.Position
    local raycastResult = workspace:Raycast(Camera.CFrame.Position, direction, raycastParams)
    return raycastResult == nil
end

-- [[ ПОИСК БЛИЖАЙШЕЙ ЦЕЛИ К ЦЕНТРУ ]] --
local function getClosestPlayer(currentFOV)
    local closestTarget = nil
    local maxDistance = currentFOV
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
                        maxDistance = distance
                        closestTarget = targetPart
                    end
                end
            end
        end
    end
    return closestTarget
end

local function doFlickShot()
    local target = getClosestPlayer(Settings.FlickFOV)
    if target then
        task.delay(Settings.FlickDelay, function()
            if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") and target.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
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

-- [[ СИСТЕМА ESP И CHARMS (ОТРИСОВКА СТРОГО СКВОЗЬ СТЕНЫ) ]] --
local function createESP(player)
if ESP_Cache[player] then return end

local box = Drawing.new("Square")
box.Color = Color3.fromRGB(255, 0, 80)
box.Thickness = 1.5
box.Filled = false
box.Visible = false

local line = Drawing.new("Line")
line.Color = Color3.fromRGB(255, 255, 255)
line.Thickness = 1
line.Visible = false

local charms = Instance.new("Highlight")
charms.FillColor = Color3.fromRGB(255, 0, 80)
charms.FillTransparency = 0.5
charms.OutlineColor = Color3.fromRGB(255, 255, 255)
charms.OutlineTransparency = 0
-- AlwaysOnTop заставляет чармсы рендериться ПОВЕРХ стен
charms.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
charms.Enabled = false

ESP_Cache[player] = {Box = box, Line = line, Charms = charms}
end

local function removeESP(player)
if ESP_Cache[player] then
ESP_Cache[player].Box:Remove()
ESP_Cache[player].Line:Remove()
if ESP_Cache[player].Charms then ESP_Cache[player].Charms:Destroy() end
ESP_Cache[player] = nil
end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end

-- [[ ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ (RENDERSTEPPED) ]] --
RunService.RenderStepped:Connect(function()
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Обновление круга FOV
FOV_Circle.Position = screenCenter
if Settings.FlickMode then
FOV_Circle.Radius = Settings.FlickFOV
FOV_Circle.Color = Color3.fromRGB(255, 80, 80)
else
FOV_Circle.Radius = Settings.AimFOV
FOV_Circle.Color = Color3.fromRGB(0, 255, 200)
end

-- Логика обычного Аимбота
if Settings.AimbotEnabled and not Settings.FlickMode then
local target = getClosestPlayer(Settings.AimFOV)
if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
end

-- Обновление всей ESP системы
for player, visual in pairs(ESP_Cache) do
local character = player.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local hrp = character and character:FindFirstChild("HumanoidRootPart")
local head = character and character:FindFirstChild("Head")

if character and humanoid and hrp and head and humanoid.Health > 0 then
local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

-- 1. ЛОГИКА ESP BOX
if Settings.EspBox and onScreen then
local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

local height = math.abs(headPos.Y - legPos.Y)
local width = height / 1.5

visual.Box.Size = Vector2.new(width, height)
visual.Box.Position = Vector2.new(hrpPos.X - width / 2, hrpPos.Y - height / 2)
visual.Box.Visible = true
else
visual.Box.Visible = false
end

-- 2. ЛОГИКА СТРОГИХ ЛИНИЙ ИЗ ЦЕНТРА ЭКРАНА СВОЗЬ СТЕНЫ
if Settings.EspLines then
-- Линии работают ВСЕГДА, даже если противник за спиной/стеной
visual.Line.From = screenCenter
visual.Line.To = Vector2.new(hrpPos.X, hrpPos.Y)
visual.Line.Visible = onScreen -- Скроет линию, только если враг физически сзади камеры
else
visual.Line.Visible = false
end

-- 3. ЛОГИКА CHARMS (WALLHACK ЦВЕТОМ СВОЗЬ СТЕНЫ)
if Settings.EspCharms then
visual.Charms.Parent = character
visual.Charms.Enabled = true
else
visual.Charms.Enabled = false
end
else
-- Если игрок мертв или вышел — скрываем элементы
visual.Box.Visible = false
visual.Line.Visible = false
visual.Charms.Enabled = false
end
end
end)
