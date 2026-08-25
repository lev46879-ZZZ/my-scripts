-- Инициализация библиотеки интерфейса Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

-- Создание главного окна (с поддержкой перетаскивания)
local Window = Rayfield:CreateWindow({
    Name = "Rivals Mobile Aimbot (Delta)",
    LoadingTitle = "Загрузка мобильного скрипта...",
    LoadingSubtitle = "by AI Assistant",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RivalsDeltaMobile",
        FileName = "MobileConfig"
    }
})

-- Переменные для настроек
local AimbotEnabled = false
local TeamCheck = false
local WallCheck = true
local AimFOV = 100

-- Сервисы Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

---------------------------------------------------------
-- СОЗДАНИЕ ПЕРЕМЕЩАЕМОЙ КНОПКИ ДЛЯ ТЕЛЕФОНА (TOGGLE GUI)
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

-- Настройка контейнера GUI, чтобы работал в Delta на мобильных
ScreenGui.Name = "DeltaMobileAimbotButton"
ScreenGui.Parent = (CoreGui:FindFirstChild("RobloxGui") or CoreGui)
ScreenGui.ResetOnSpawn = false

-- Настройка самой кнопки
ToggleButton.Name = "MenuToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0) -- Начальная позиция на экране
ToggleButton.Size = UDim2.new(0, 60, 0, 60)        -- Размер кнопки
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "AIM"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 100)
ToggleButton.TextSize = 18.000
ToggleButton.Active = true
ToggleButton.Draggable = true -- Встроенное перемещение пальцем по экрану

UICorner.CornerRadius = UDim.new(0, 30) -- Округление кнопки в круг
UICorner.Parent = ToggleButton

-- Логика перетаскивания и нажатия на телефоне (защита от ложных нажатий при свайпе)
local dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos = ToggleButton.Position
    end
end)

ToggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local delta = input.Position - dragStart
        if delta.Magnitude < 5 then -- Если палец почти не двигался, это клик, а не свайп
            -- Открытие/закрытие меню Rayfield
            local rayfieldGui = CoreGui:FindFirstChild("Rayfield") or (LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Rayfield"))
            if rayfieldGui then
                rayfieldGui.Enabled = not rayfieldGui.Enabled
            end
        end
    end
end)

---------------------------------------------------------
-- ВИЗУАЛЬНЫЙ КРУГ FOV
---------------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Color = Color3.fromRGB(0, 255, 100)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = AimFOV
FOVCircle.Filled = false

game:GetService("RunService").RenderStepped:Connect(function()
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = mousePos
    FOVCircle.Radius = AimFOV
    FOVCircle.Visible = AimbotEnabled
end)

---------------------------------------------------------
-- СОЗДАНИЕ ВКЛАДОК И НАСТРОЕК В МЕНЮ
---------------------------------------------------------
local MainTab = Window:CreateTab("Aimbot Settings", 4483362458)

local ToggleAimbot = MainTab:CreateToggle({
    Name = "Включить Автонаводку (Aimbot)",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end,
})

local ToggleTeam = MainTab:CreateToggle({
    Name = "Проверка на Тимейтов (TeamCheck)",
    CurrentValue = false,
    Callback = function(Value)
        TeamCheck = Value
    end,
})

local ToggleWall = MainTab:CreateToggle({
    Name = "Проверка стен (WallCheck)",
    CurrentValue = true,
    Callback = function(Value)
        WallCheck = Value
    end,
})

local SliderFOV = MainTab:CreateSlider({
    Name = "Радиус FOV",
    Min = 10,
    Max = 900,
    CurrentValue = 100,
    Increment = 5,
    Callback = function(Value)
        AimFOV = Value
    end,
})

---------------------------------------------------------
-- ЛОГИКА AIMBOT И WALLCHECK (ГОЛОВА)
---------------------------------------------------------
local function isVisible(targetPart)
    if not WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local destination = targetPart.Position
    local direction = destination - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        if raycastResult.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    return true
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                if TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end

                local targetPart = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

                if onScreen then
                    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                    if distance < shortestDistance then
                        if isVisible(targetPart) then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Основной цикл моментального наведения на мобильных устройствах
game:GetService("RunService").RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
