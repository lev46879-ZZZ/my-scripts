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
    AimFOV = 100,      -- Отдельный FOV для обычного аима
    FlickFOV = 150,    -- Отдельный FOV для Flick Shot
    TargetPart = "Head"
}

-- [[ СОЗДАНИЕ GUI ДЛЯ СМАРТФОНОВ ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAdvancedHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Функция для реализации перетаскивания (Drag) на сенсорных экранах
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

-- 1. ПЛАВАЮЩАЯ КНОПКА (Открыть/Закрыть Меню)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = ScreenGui

local TBCorner = Instance.new("UICorner")
TBCorner.CornerRadius = UDim.new(0, 28)
TBCorner.Parent = ToggleButton
makeDraggable(ToggleButton)

-- ПЛАВАЮЩАЯ КНОПКА ДЛЯ FLICK (Кнопка выстрела/флика)
local FlickButton = Instance.new("TextButton")
FlickButton.Size = UDim2.new(0, 70, 0, 70)
FlickButton.Position = UDim2.new(0.75, 0, 0.5, 0)
FlickButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
FlickButton.Text = "FLICK"
FlickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlickButton.TextSize = 16
FlickButton.Font = Enum.Font.SourceSansBold
FlickButton.Visible = false
FlickButton.Parent = ScreenGui

local FlickCorner = Instance.new("UICorner")
FlickCorner.CornerRadius = UDim.new(0, 35)
FlickCorner.Parent = FlickButton
makeDraggable(FlickButton)

-- 2. ПЛАВАЮЩЕЕ МЕНЮ (Loader UI)
local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 280, 0, 420) -- Увеличили размер под второй слайдер
MainMenu.Position = UDim2.new(0.5, -140, 0.5, -210)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = MainMenu
makeDraggable(MainMenu)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "FLICK & AIM LAUNCHER"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainMenu

ToggleButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- КОНТЕНТ МЕНЮ
local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 260, 0, 360)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.Parent = MainMenu

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.Parent = Container

-- Функция для создания слайдеров (Оптимизация кода)
local function createSlider(parent, text, min, max, default, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.Parent = parent

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 12)
    bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    bg.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 16, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
    btn.Text = ""
    btn.Parent = bg

    -- Установка дефолтной позиции ползунка
    local initPercent = (default - min) / (max - min)
    btn.Position = UDim2.new(initPercent, -8, 0, 0)

    local active = false
    local function update(input)
        local sizeX = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        btn.Position = UDim2.new(sizeX, -8, 0, 0)
        local value = math.floor(min + (sizeX * (max - min)))
        label.Text = text .. ": " .. value
        callback(value)
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then active = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then active = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
end

-- Кнопка: Aimbot
local AimToggle = Instance.new("TextButton")
AimToggle.Size = UDim2.new(1, 0, 0, 38)
AimToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AimToggle.Text = "Aimbot: OFF"
AimToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
AimToggle.TextSize = 14
AimToggle.Font = Enum.Font.SourceSansBold
AimToggle.Parent = Container

AimToggle.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    AimToggle.Text = Settings.AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
    AimToggle.TextColor3 = Settings.AimbotEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
end)

-- Кнопка: Режим Flick
local FlickToggle = Instance.new("TextButton")
FlickToggle.Size = UDim2.new(1, 0, 0, 38)
FlickToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FlickToggle.Text = "Flick Mode: OFF"
FlickToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
FlickToggle.TextSize = 14
FlickToggle.Font = Enum.Font.SourceSansBold
FlickToggle.Parent = Container

FlickToggle.MouseButton1Click:Connect(function()
    Settings.FlickMode = not Settings.FlickMode
    FlickToggle.Text = Settings.FlickMode and "Flick Mode: ON" or "Flick Mode: OFF"
    FlickToggle.TextColor3 = Settings.FlickMode and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    FlickButton.Visible = Settings.FlickMode
end)

-- Кнопка: Wallcheck
local WallToggle = Instance.new("TextButton")
WallToggle.Size = UDim2.new(1, 0, 0, 38)
WallToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
WallToggle.Text = "Wallcheck: OFF"
WallToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
WallToggle.TextSize = 14
WallToggle.Font = Enum.Font.SourceSansBold
WallToggle.Parent = Container

WallToggle.MouseButton1Click:Connect(function()
    Settings.WallCheck = not Settings.WallCheck
    WallToggle.Text = Settings.WallCheck and "Wallcheck: ON" or "Wallcheck: OFF"
    WallToggle.TextColor3 = Settings.WallCheck and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
end)

-- СЛАЙДЕР 1: Обычный FOV Аимбота (10 - 900)
createSlider(Container, "Aim FOV", 10, 900, Settings.AimFOV, function(value)
    Settings.AimFOV = value
end)

-- СЛАЙДЕР 2: Раздельный FOV для Flick Shot (10 - 900)
createSlider(Container, "Flick FOV", 10, 900, Settings.FlickFOV, function(value)
    Settings.FlickFOV = value
end)


-- [[ КОРРЕКТНЫЙ ЦЕНТР ЭКРАНА ДЛЯ FOV ]] --
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = true
FOV_Circle.Color = Color3.fromRGB(0, 220, 255)
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

-- [[ ПОИСК БЛИЖАЙШЕЙ ЦЕЛИ К ЦЕНТРУ ЭКРАНА ]] --
-- Параметр currentFOV динамически меняется в зависимости от активного режима
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

if distance < maxDistance then
if isVisible(targetPart, player.Character) then
maxDistance = distance
closestTarget = targetPart
end
end
end
end
end
end
return closestTarget
end

-- Функция выполнения моментального Флика (использует FlickFOV)
local function doFlickShot()
local target = getClosestPlayer(Settings.FlickFOV)
if target then
Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
end
end

-- Клик по кнопке FLICK
FlickButton.MouseButton1Click:Connect(function()
if Settings.FlickMode then
doFlickShot()
end
end)

-- [[ ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ ]] --
RunService.RenderStepped:Connect(function()
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOV_Circle.Position = screenCenter

-- Кольцо FOV меняет свой визуальный радиус в зависимости от того, включен ли Flick Mode
if Settings.FlickMode then
FOV_Circle.Radius = Settings.FlickFOV
FOV_Circle.Color = Color3.fromRGB(255, 50, 50) -- Красный цвет круга для фликов
else
FOV_Circle.Radius = Settings.AimFOV
FOV_Circle.Color = Color3.fromRGB(0, 220, 255) -- Голубой цвет круга для обычного аима
end

-- Обычный аимбот работает (используя AimFOV), только если FlickMode отключен
if Settings.AimbotEnabled and not Settings.FlickMode then
local target = getClosestPlayer(Settings.AimFOV)
if target then
Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
end
end
end)
