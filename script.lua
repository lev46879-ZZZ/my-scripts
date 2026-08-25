-- [[ СЕРВИСЫ ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ НАСТРОЙКИ ХАБА ]] --
local Settings = {
    AimbotEnabled = false,
    WallCheck = false,
    FOV = 100,
    TargetPart = "Head"
}

-- [[ СОЗДАНИЕ GUI ДЛЯ СМАРТФОНОВ ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileScriptHub"
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

-- 1. ПЛАВАЮЩАЯ КНОПКА (Toggle Button)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.Text = "HUB"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = ScreenGui

local TBCorner = Instance.new("UICorner")
TBCorner.CornerRadius = UDim.new(0, 30) -- Круглая форма
TBCorner.Parent = ToggleButton
makeDraggable(ToggleButton)

-- 2. ПЛАВАЮЩЕЕ МЕНЮ (Main Hub UI)
local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 280, 0, 320)
MainMenu.Position = UDim2.new(0.5, -140, 0.5, -160)
MainMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = MainMenu
makeDraggable(MainMenu)

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "MOBILE LOADER HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Логика переключения видимости меню
ToggleButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- 3. КОНТЕНТ МЕНЮ (Элементы управления)
local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Container = Instance.new("Frame")
Container.Size = UDim2.new(0, 260, 0, 260)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.Parent = MainMenu
ContentLayout.Parent = Container

-- Кнопка переключения Aimbot
local AimToggle = Instance.new("TextButton")
AimToggle.Size = UDim2.new(1, 0, 0, 40)
AimToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimToggle.Text = "Aimbot: OFF"
AimToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
AimToggle.TextSize = 16
AimToggle.Font = Enum.Font.SourceSansBold
AimToggle.Parent = Container

AimToggle.MouseButton1Click:Connect(function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    if Settings.AimbotEnabled then
        AimToggle.Text = "Aimbot: ON"
        AimToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        AimToggle.Text = "Aimbot: OFF"
        AimToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Кнопка переключения Wallcheck
local WallToggle = Instance.new("TextButton")
WallToggle.Size = UDim2.new(1, 0, 0, 40)
WallToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
WallToggle.Text = "Wallcheck: OFF"
WallToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
WallToggle.TextSize = 16
WallToggle.Font = Enum.Font.SourceSansBold
WallToggle.Parent = Container

WallToggle.MouseButton1Click:Connect(function()
    Settings.WallCheck = not Settings.WallCheck
    if Settings.WallCheck then
        WallToggle.Text = "Wallcheck: ON"
        WallToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        WallToggle.Text = "Wallcheck: OFF"
        WallToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Слайдер FOV (Настройка радиуса)
local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(1, 0, 0, 30)
FovLabel.BackgroundTransparency = 1
FovLabel.Text = "FOV Radius: " .. Settings.FOV
FovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FovLabel.TextSize = 14
FovLabel.Font = Enum.Font.SourceSans
FovLabel.Parent = Container

local SliderBg = Instance.new("Frame")
SliderBg.Size = UDim2.new(1, 0, 0, 15)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SliderBg.Parent = Container

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(0, 20, 1, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBg

local function updateSlider(input)
    local sizeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
    SliderBtn.Position = UDim2.new(sizeX, -10, 0, 0)
    -- Конвертируем позицию ползунка в диапазон FOV от 10 до 900
    Settings.FOV = math.floor(10 + (sizeX * 890))
    FovLabel.Text = "FOV Radius: " .. Settings.FOV
end

local sliderActive = false
SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderActive = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderActive = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- Визуальное кольцо FOV на экране
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = true
FOV_Circle.Color = Color3.fromRGB(0, 255, 150)
FOV_Circle.Thickness = 1
FOV_Circle.NumSides = 64
FOV_Circle.Radius = Settings.FOV
FOV_Circle.Filled = false

-- [[ ЛОГИКА AIMBOT И WALLCHECK ]] --

-- Функция проверки препятствий между камерой и головой противника
local function isVisible(targetPart, character)
    if not Settings.WallCheck then return true end
    
    local castPoints = {Camera.CFrame.Position, targetPart.Position}
    local ignoreList = {LocalPlayer.Character, character, Camera}
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = ignoreList
    
    local direction = targetPart.Position - Camera.CFrame.Position
    local raycastResult = workspace:Raycast(Camera.CFrame.Position, direction, raycastParams)
    
    -- Если луч ни обо что не ударился по пути, значит противник виден
    return raycastResult == nil
end

-- Поиск ближайшей цели в радиусе FOV
local function getClosestPlayer()
    local closestTarget = nil
    local maxDistance = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
            
            -- Проверяем, что игрок жив
            if humanoid and humanoid.Health > 0 and targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    -- Расстояние от центра экрана (прицела) до игрока
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
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

-- Постоянный цикл обновления аима и FOV
RunService.RenderStepped:Connect(function()
    -- Обновляем позицию и радиус кольца прицела
    local mousePos = UserInputService:GetMouseLocation()
    FOV_Circle.Position = mousePos
    FOV_Circle.Radius = Settings.FOV
    
    if Settings.AimbotEnabled then
        local target = getClosestPlayer()
        if target then
            -- Моментальное и плавное наведение камеры строго на выбранную часть (Head)
Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
end
end
end)
