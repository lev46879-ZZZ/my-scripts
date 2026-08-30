-- // Roblox Delta Script: Floating GUI + Aimbot + WallCheck + ESP + FOV Circle
-- // Для мобильных устройств

-- Создаём глобальное окружение, чтобы переменные были доступны в разных потоках
local env = getgenv() or shared
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Библиотека Drawing (доступна в большинстве эксплойтов)
local Drawing = Drawing or loadstring(game:HttpGet("https://raw.githubusercontent.com/Blissful4992/ESPs/main/Drawing.lua"))()

-- ========== НАСТРОЙКИ (по умолчанию) ==========
env.AimbotEnabled = false
env.FOV = 100                -- радиус FOV в пикселях (10-600)
env.WallCheckEnabled = true  -- проверять стены
env.ESPEnabled = true        -- показывать ESP
env.ShowFOV = false          -- отображать круг FOV

-- Функция определения врага (переопределите под свою игру при необходимости)
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

-- ========== СОЗДАНИЕ ПЛАВАЮЩЕЙ КНОПКИ ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 60, 0, 60)
Button.Position = UDim2.new(0, 20, 0, 300)
Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Button.BackgroundTransparency = 0.2
Button.BorderSizePixel = 0
Button.Text = "Menu"
Button.TextColor3 = Color3.new(1,1,1)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 14
Button.Parent = ScreenGui

-- Перетаскивание кнопки
local UIS = game:GetService("UserInputService")
local dragging = false
local dragStart = nil
local startPos = nil

Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Button.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Button.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        Button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ========== СОЗДАНИЕ ПЛАВАЮЩЕГО МЕНЮ ==========
local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 220, 0, 300)  -- увеличена высота для нового тумблера
Menu.Position = UDim2.new(0.5, -110, 0.5, -150)
Menu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Menu.BackgroundTransparency = 0.1
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Active = true
Menu.Draggable = true
Menu.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Techy Menu"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Menu

-- Функция создания тумблера
local function CreateToggle(text, default, yOffset, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 35)
    ToggleFrame.Position = UDim2.new(0, 10, 0, yOffset)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = Menu

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 25)
    ToggleButton.Position = UDim2.new(0.7, 0, 0.5, -12.5)
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    ToggleButton.Text = default and "ON" or "OFF"
    ToggleButton.TextColor3 = Color3.new(1,1,1)
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.TextSize = 12
    ToggleButton.Parent = ToggleFrame

    local state = default
    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        ToggleButton.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        ToggleButton.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return ToggleFrame
end

-- Слайдер FOV
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(1, 0, 0, 20)
FOVLabel.Position = UDim2.new(0, 10, 0, 200)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = "FOV: " .. env.FOV
FOVLabel.TextColor3 = Color3.new(1,1,1)
FOVLabel.Font = Enum.Font.SourceSans
FOVLabel.TextSize = 14
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Parent = Menu

local FOVSlider = Instance.new("TextBox")
FOVSlider.Size = UDim2.new(0, 180, 0, 30)
FOVSlider.Position = UDim2.new(0, 20, 0, 225)
FOVSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
FOVSlider.Text = tostring(env.FOV)
FOVSlider.TextColor3 = Color3.new(1,1,1)
FOVSlider.Font = Enum.Font.SourceSans
FOVSlider.TextSize = 14
FOVSlider.Parent = Menu

FOVSlider.FocusLost:Connect(function(enterPressed)
    local num = tonumber(FOVSlider.Text)
    if num then
        env.FOV = math.clamp(num, 10, 600)
        FOVLabel.Text = "FOV: " .. env.FOV
        FOVSlider.Text = tostring(env.FOV)
    else
        FOVSlider.Text = tostring(env.FOV)
    end
end)

-- Тумблеры
CreateToggle("Aimbot", false, 40, function(value) env.AimbotEnabled = value end)
CreateToggle("WallCheck", true, 80, function(value) env.WallCheckEnabled = value end)
CreateToggle("ESP", true, 120, function(value)
    env.ESPEnabled = value
    if value then
        CreateESP()
    else
        ClearESP()
    end
end)
CreateToggle("Show FOV", false, 160, function(value) env.ShowFOV = value end)

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 60, 0, 25)
CloseButton.Position = UDim2.new(1, -70, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(170,0,0)
CloseButton.Text = "Close"
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 12
CloseButton.Parent = Menu
CloseButton.MouseButton1Click:Connect(function() Menu.Visible = false end)

Button.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
end)

-- ========== ФУНКЦИИ ДЛЯ ПОЛУЧЕНИЯ ВРАГОВ ==========
local function GetAliveEnemies()
    local enemies = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            table.insert(enemies, player)
        end
    end
    return enemies
end

-- ========== WALLCHECK (RAYCAST) ==========
local function IsVisible(targetPosition)
    if not env.WallCheckEnabled then return true end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPosition - origin).Unit * 500
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        local hitInstance = result.Instance
        local hitPlayer = Players:GetPlayerFromCharacter(hitInstance:FindFirstAncestorOfClass("Model"))
        if hitPlayer and IsEnemy(hitPlayer) then
            return true
        else
            return false
        end
    end
    return false
end

-- ========== АИМБОТ ==========
local function GetClosestEnemyInFOV()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest = nil
    local minDist = env.FOV

    for _, player in ipairs(GetAliveEnemies()) do
        local part = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
        if part then
            local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if dist <= minDist and IsVisible(part.Position) then
                    minDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

local function InstantAimbot(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetPart = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
end

-- ========== ESP ==========
local espObjects = {}
local function ClearESP()
    for _, obj in pairs(espObjects) do
        if obj.Remove then obj:Remove() end
    end
    espObjects = {}
end

local function CreateESP()
    ClearESP()
    if not env.ESPEnabled then return end

    for _, player in ipairs(GetAliveEnemies()) do
        local character = player.Character
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if rootPart and head and humanoid then
            -- Box
            local box = Drawing.new("Square")
            box.Thickness = 2
            box.Color = Color3.fromRGB(255,0,0)
            box.Filled = false
            box.Transparency = 1
            box.Visible = true
            table.insert(espObjects, box)

            -- Name
            local nameTag = Drawing.new("Text")
            nameTag.Text = player.Name
            nameTag.Size = 14
            nameTag.Color = Color3.fromRGB(255,255,255)
            nameTag.Center = true
            nameTag.Outline = true
            nameTag.OutlineColor = Color3.new(0,0,0)
            nameTag.Visible = true
            table.insert(espObjects, nameTag)

            -- Health background
            local healthBg = Drawing.new("Square")
            healthBg.Thickness = 1
            healthBg.Color = Color3.fromRGB(0,0,0)
            healthBg.Filled = true
            healthBg.Transparency = 0.7
            healthBg.Visible = true
            table.insert(espObjects, healthBg)

            -- Health bar
            local healthBar = Drawing.new("Square")
            healthBar.Thickness = 1
            healthBar.Color = Color3.fromRGB(0,255,0)
            healthBar.Filled = true
            healthBar.Visible = true
            table.insert(espObjects, healthBar)
        end
    end
end

-- ========== КРУГ FOV ==========
local fovCircle = nil
if Drawing.new then
    pcall(function()
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.Color = Color3.fromRGB(0, 255, 255)
        fovCircle.Filled = false
        fovCircle.Transparency = 1
        fovCircle.Visible = false
    end)
end

-- ========== ГЛАВНЫЙ ЦИКЛ ==========
RunService.RenderStepped:Connect(function()
    -- Аимбот
    if env.AimbotEnabled then
        local target = GetClosestEnemyInFOV()
        if target then
            InstantAimbot(target)
        end
    end

    -- Отображение круга FOV
    if fovCircle then
        if env.ShowFOV and env.AimbotEnabled then
            fovCircle.Visible = true
            fovCircle.Radius = env.FOV
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else
            fovCircle.Visible = false
        end
    end

    -- Обновление ESP позиций
    if env.ESPEnabled and #espObjects > 0 then
        local enemies = GetAliveEnemies()
        -- Простое обновление для существующих объектов (без динамического добавления/удаления)
        -- Индексы сохраняются, если игроки не меняются. При изменении списка вызовите CreateESP()
        local index = 1
        for _, player in ipairs(enemies) do
            local character = player.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if rootPart and head and humanoid then
                -- Исправление: нижняя точка = rootPart.Position - 3 (приблизительно ноги)
                local footPos = rootPart.Position - Vector3.new(0, 3, 0)  -- подстройте под рост модели
                local footScreenPos, footVisible = Camera:WorldToScreenPoint(footPos)
                local headScreenPos, headVisible = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.3, 0))

                if footVisible and headVisible then
                    local baseIndex = (index - 1) * 4 + 1
                    if espObjects[baseIndex] then
                        local box = espObjects[baseIndex]
                        local nameTag = espObjects[baseIndex + 1]
                        local healthBg = espObjects[baseIndex + 2]
                        local healthBar = espObjects[baseIndex + 3]

                        local height = math.abs(footScreenPos.Y - headScreenPos.Y)
                        local width = height * 0.6

                        box.Position = Vector2.new(footScreenPos.X - width/2, footScreenPos.Y - height)
                        box.Size = Vector2.new(width, height)

                        nameTag.Position = Vector2.new(footScreenPos.X, footScreenPos.Y - height - 15)
                        nameTag.Text = player.Name

                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        healthBg.Position = Vector2.new(footScreenPos.X - width/2 - 5, footScreenPos.Y - height)
                        healthBg.Size = Vector2.new(3, height)

                        healthBar.Position = Vector2.new(footScreenPos.X - width/2 - 5, footScreenPos.Y - height + height * (1 - healthPercent))
                        healthBar.Size = Vector2.new(3, height * healthPercent)
                        healthBar.Color = Color3.fromHSV(healthPercent * 0.33, 1, 1)
                    end
                end
                index = index + 1
            end
        end
    end
end)

-- Начальное создание ESP
CreateESP()

-- Уведомление
print("Script loaded! Press Menu button to open settings.")
