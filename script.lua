-- Загрузка библиотеки интерфейса Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

-- Создание главного окна
local Window = Rayfield:CreateWindow({
    Name = "Rivals Silent/Instant Headshot",
    LoadingTitle = "Загрузка скрипта...",
    LoadingSubtitle = "by AI Assistant",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RivalsAimbotConfig",
        FileName = "RivalsConfig"
    }
})

-- Переменные для хранения настроек
local AimbotEnabled = false
local TeamCheck = false
local WallCheck = false
local AimFOV = 100

-- Сервисы Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Создание визуального круга FOV (Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Color = Color3.fromRGB(0, 255, 100) -- Зеленый цвет
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = AimFOV
FOVCircle.Filled = false

-- Обновление позиции круга FOV под центр экрана
game:GetService("RunService").RenderStepped:Connect(function()
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = mousePos
    FOVCircle.Radius = AimFOV
    FOVCircle.Visible = AimbotEnabled -- Круг виден только когда аимбот активен
end)

-- Создание вкладки в меню
local MainTab = Window:CreateTab("Aimbot Settings", 4483362458)

-- Кнопка переключения Аимбота
local ToggleAimbot = MainTab:CreateToggle({
    Name = "Включить Headshot Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end,
})

-- Кнопка проверки на тимейтов
local ToggleTeam = MainTab:CreateToggle({
    Name = "Проверка на Тимейтов (TeamCheck)",
    CurrentValue = false,
    Callback = function(Value)
        TeamCheck = Value
    end,
})

-- Кнопка проверки стен
local ToggleWall = MainTab:CreateToggle({
    Name = "Проверка стен (WallCheck)",
    CurrentValue = false,
    Callback = function(Value)
        WallCheck = Value
    end,
})

-- Ползунок FOV от 10 до 900
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

-- Функция проверки видимости головы за стеной
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

-- Поиск ближайшего игрока (ориентир на Голову)
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimFOV

    for _, player in pairs(Players:GetPlayers()) do
        -- Теперь проверяем наличие детали "Head" (Голова)
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            
            if player.Character.Humanoid.Health > 0 then
                if TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end

                local targetPart = player.Character.Head -- Целимся строго в голову
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

-- Основной цикл моментального наведения в голову
game:GetService("RunService").RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- Моментальный разворот камеры точно на объект Head
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
