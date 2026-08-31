-- ╔═══════════════════════════════════════════════════════════════╗
-- ║     TECHY SCRIPT - УЛУЧШЕННАЯ ВЕРСИЯ С НОВЫМ МЕНЮ           ║
-- ║  Исправлено: Aimbot, No Recoil, красивый UI на русском      ║
-- ╚═══════════════════════════════════════════════════════════════╝

local env = getgenv() or shared
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== НАСТРОЙКИ ==========
env.AimbotEnabled = false
env.FOV = 150
env.WallCheckEnabled = true
env.ChamsEnabled = false
env.ShowFOV = false
env.NoRecoilEnabled = false
env.NoRecoilStrength = 1.0
env.AimbotSmoothness = 0.1

-- Функция определения врага
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

-- ========== ГЛАВНОЕ МЕНЮ UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Name = "TechyMenuGui"

-- Плавающая кнопка меню
local MenuButton = Instance.new("TextButton")
MenuButton.Size = UDim2.new(0, 70, 0, 70)
MenuButton.Position = UDim2.new(0, 20, 0, 250)
MenuButton.BackgroundColor3 = Color3.fromRGB(25, 135, 200)
MenuButton.BackgroundTransparency = 0.15
MenuButton.BorderSizePixel = 0
MenuButton.Text = "⚙️"
MenuButton.TextColor3 = Color3.new(1, 1, 1)
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.TextSize = 28
MenuButton.Parent = ScreenGui

-- Скругление кнопки
local UICorner1 = Instance.new("UICorner")
UICorner1.CornerRadius = UDim.new(0, 15)
UICorner1.Parent = MenuButton

-- Тень кнопки
local Shadow1 = Instance.new("UIStroke")
Shadow1.Color = Color3.fromRGB(20, 120, 180)
Shadow1.Thickness = 2
Shadow1.Parent = MenuButton

-- Перетаскивание кнопки
local dragging = false
local dragOffset = nil

MenuButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragOffset = input.Position - MenuButton.AbsolutePosition
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local size = MenuButton.Parent.AbsoluteSize
        local newX = math.clamp(input.Position.X - dragOffset.X, 0, size.X - MenuButton.AbsoluteSize.X)
        local newY = math.clamp(input.Position.Y - dragOffset.Y, 0, size.Y - MenuButton.AbsoluteSize.Y)
        MenuButton.Position = UDim2.new(0, newX, 0, newY)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ========== ОСНОВНОЕ МЕНЮ ==========
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 300, 0, 600)
MainMenu.Position = UDim2.new(0.5, -150, 0.5, -300)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
MainMenu.BackgroundTransparency = 0.05
MainMenu.BorderSizePixel = 0
MainMenu.Visible = false
MainMenu.Active = true
MainMenu.Draggable = true
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = MainMenu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = Color3.fromRGB(25, 135, 200)
MenuStroke.Thickness = 1.5
MenuStroke.Parent = MainMenu

-- Заголовок меню
local Header = Instance.new("TextLabel")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(25, 135, 200)
Header.BackgroundTransparency = 0.2
Header.Text = "⚙️ TECHY MENU"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.SourceSansBold
Header.TextSize = 20
Header.BorderSizePixel = 0
Header.Parent = MainMenu

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 20
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainMenu.Visible = false
end)

-- Контейнер для опций
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, 0, 1, -45)
ContentFrame.Position = UDim2.new(0, 0, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(25, 135, 200)
ContentFrame.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ========== ФУНКЦИЯ СОЗДАНИЯ ПЕРЕКЛЮЧАТЕЛЯ ==========
local function CreateToggle(text, defaultValue, callback)
    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Size = UDim2.new(0, 280, 0, 45)
    ToggleContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    ToggleContainer.BackgroundTransparency = 0.3
    ToggleContainer.BorderSizePixel = 0
    ToggleContainer.Parent = ContentFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 180, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleContainer

    local ToggleSwitch = Instance.new("TextButton")
    ToggleSwitch.Size = UDim2.new(0, 50, 0, 28)
    ToggleSwitch.Position = UDim2.new(1, -65, 0.5, -14)
    ToggleSwitch.BackgroundColor3 = defaultValue and Color3.fromRGB(50, 180, 100) or Color3.fromRGB(100, 100, 100)
    ToggleSwitch.BackgroundTransparency = 0.2
    ToggleSwitch.Text = defaultValue and "ВКЛ" or "ВЫКЛ"
    ToggleSwitch.TextColor3 = Color3.new(1, 1, 1)
    ToggleSwitch.Font = Enum.Font.SourceSansBold
    ToggleSwitch.TextSize = 12
    ToggleSwitch.BorderSizePixel = 0
    ToggleSwitch.Parent = ToggleContainer

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(0, 6)
    SwitchCorner.Parent = ToggleSwitch

    local state = defaultValue
    ToggleSwitch.MouseButton1Click:Connect(function()
        state = not state
        ToggleSwitch.BackgroundColor3 = state and Color3.fromRGB(50, 180, 100) or Color3.fromRGB(100, 100, 100)
        ToggleSwitch.Text = state and "ВКЛ" or "ВЫКЛ"
        callback(state)
    end)

    return ToggleContainer
end

-- ========== ФУНКЦИЯ СОЗДАНИЯ СЛАЙДЕРА ==========
local function CreateSlider(text, minVal, maxVal, defaultVal, callback)
    local SliderContainer = Instance.new("Frame")
    SliderContainer.Size = UDim2.new(0, 280, 0, 70)
    SliderContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    SliderContainer.BackgroundTransparency = 0.3
    SliderContainer.BorderSizePixel = 0
    SliderContainer.Parent = ContentFrame

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(math.floor(defaultVal * 100) / 100)
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderContainer

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(0, 260, 0, 6)
    SliderBg.Position = UDim2.new(0, 10, 0, 35)
    SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBg.BorderSizePixel = 0
    SliderBg.Parent = SliderContainer

    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 3)
    BgCorner.Parent = SliderBg

    local Thumb = Instance.new("Frame")
    Thumb.Size = UDim2.new(0, 16, 0, 16)
    Thumb.BackgroundColor3 = Color3.fromRGB(25, 135, 200)
    Thumb.BorderSizePixel = 0
    Thumb.Parent = SliderBg

    local ThumbCorner = Instance.new("UICorner")
    ThumbCorner.CornerRadius = UDim.new(0, 8)
    ThumbCorner.Parent = Thumb

    local function UpdateSlider(input)
        local mouse = UserInputService:GetMouseLocation()
        local relPos = math.clamp(mouse.X - SliderBg.AbsolutePosition.X, 0, SliderBg.AbsoluteSize.X)
        local ratio = relPos / SliderBg.AbsoluteSize.X
        local value = minVal + (maxVal - minVal) * ratio
        value = math.floor(value * 100) / 100
        Thumb.Position = UDim2.new(ratio, -8, 0.5, -8)
        Label.Text = text .. ": " .. tostring(value)
        callback(value)
    end

    local draggingSlider = false
    Thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)

    UserInputService.InputChanged:Connect(function()
        if draggingSlider then
            UpdateSlider()
        end
    end)

    -- Установка начальной позиции
    local initialRatio = (defaultVal - minVal) / (maxVal - minVal)
    Thumb.Position = UDim2.new(initialRatio, -8, 0.5, -8)

    return SliderContainer
end

-- ========== ДОБАВЛЕНИЕ ЭЛЕМЕНТОВ МЕНЮ ==========
local padding = Instance.new("Frame")
padding.Size = UDim2.new(0, 0, 0, 10)
padding.BackgroundTransparency = 1
padding.Parent = ContentFrame

CreateToggle("🎯 Aimbot", false, function(value)
    env.AimbotEnabled = value
end)

CreateToggle("👁️ Проверка стен", true, function(value)
    env.WallCheckEnabled = value
end)

CreateToggle("✨ Chams (свечение)", false, function(value)
    env.ChamsEnabled = value
    if value then CreateAllChams() else ClearAllChams() end
end)

CreateToggle("🎲 Показать FOV", false, function(value)
    env.ShowFOV = value
end)

CreateToggle("🔫 БЕЗ ОТДАЧИ", false, function(value)
    env.NoRecoilEnabled = value
end)

CreateSlider("🎯 FOV", 10, 600, 150, function(value)
    env.FOV = value
end)

CreateSlider("⚡ Точность Aimbot", 0.01, 1.0, 0.1, function(value)
    env.AimbotSmoothness = value
end)

CreateSlider("💥 Сила No Recoil", 0.1, 2.0, 1.0, function(value)
    env.NoRecoilStrength = value
end)

-- Статус внизу
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 40)
StatusLabel.Position = UDim2.new(0, 0, 1, -40)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 135, 200)
StatusLabel.BackgroundTransparency = 0.2
StatusLabel.Text = "✓ Скрипт загружен"
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 12
StatusLabel.BorderSizePixel = 0
StatusLabel.Parent = MainMenu

-- Открытие/закрытие меню
MenuButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- ========== ПОЛУЧЕНИЕ ВРАГОВ ==========
local function GetAliveEnemies()
    local enemies = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp and humanoid.Health > 0 then
                table.insert(enemies, player)
            end
        end
    end
    return enemies
end

-- ========== WALLCHECK ПРОВЕРКА ==========
local function IsVisible(targetPosition)
    if not env.WallCheckEnabled then return true end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPosition - origin)
    local distance = direction.Magnitude
    
    if distance == 0 then return true end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local result = workspace:Raycast(origin, direction.Unit * (distance + 5), raycastParams)
    
    if not result then return true end
    
    local hitInstance = result.Instance
    if not hitInstance then return true end
    
    local hitPlayer = Players:GetPlayerFromCharacter(hitInstance:FindFirstAncestorOfClass("Model"))
    return hitPlayer and IsEnemy(hitPlayer)
end

-- ========== AIMBOT ==========
local function GetClosestEnemyInFOV()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest = nil
    local minDist = env.FOV

    for _, player in ipairs(GetAliveEnemies()) do
        local part = player.Character:FindFirstChild("Head")
        if not part then part = player.Character:FindFirstChild("HumanoidRootPart") end
        
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

local lastAimbotCFrame = Camera.CFrame
local function SmoothAimbot(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetPart = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end
    
    local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
    lastAimbotCFrame = Camera.CFrame:Lerp(targetCFrame, env.AimbotSmoothness)
    Camera.CFrame = lastAimbotCFrame
end

-- ========== CHAMS (Highlight) ==========
local chamsHighlights = {}

local function CreateChamsForPlayer(player)
    if chamsHighlights[player] then return end
    local character = player.Character
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ChamsHighlight"
    highlight.FillColor = Color3.fromRGB(255, 100, 100)
    highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0.0
    highlight.DepthMode = Enum.HighlightDepthMode.Always
    highlight.Parent = character
    chamsHighlights[player] = highlight
end

local function ClearChamsForPlayer(player)
    if chamsHighlights[player] then
        chamsHighlights[player]:Destroy()
        chamsHighlights[player] = nil
    end
end

local function CreateAllChams()
    for _, player in ipairs(GetAliveEnemies()) do
        CreateChamsForPlayer(player)
    end
end

local function ClearAllChams()
    for player, hl in pairs(chamsHighlights) do
        if hl then hl:Destroy() end
    end
    chamsHighlights = {}
end

local function UpdateChams()
    if not env.ChamsEnabled then return end
    
    for player, hl in pairs(chamsHighlights) do
        if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
            ClearChamsForPlayer(player)
        end
    end
    
    for _, player in ipairs(GetAliveEnemies()) do
        CreateChamsForPlayer(player)
    end
end

-- ========== FOV CIRCLE ==========
local fovCircle
pcall(function()
    if Drawing then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.Color = Color3.fromRGB(0, 200, 255)
        fovCircle.Filled = false
        fovCircle.Transparency = 0.7
        fovCircle.Visible = false
    end
end)

-- ========== NO RECOIL (ИСПРАВЛЕННАЯ ВЕРСИЯ) ==========
local lastCameraPos = Camera.CFrame.Position
local lastCameraLookVector = Camera.CFrame.LookVector
local compensationOffset = Vector3.new(0, 0, 0)

-- Таблица для хранения истории движений камеры
local cameraHistory = {}
local maxHistoryLength = 5

RunService.RenderStepped:Connect(function()
    if env.NoRecoilEnabled then
        local currentCFrame = Camera.CFrame
        local currentPos = currentCFrame.Position
        local currentLook = currentCFrame.LookVector
        
        -- Вычисляем изменение углов
        local posChange = currentPos - lastCameraPos
        local lookChange = currentLook - lastCameraLookVector
        local changeMagnitude = lookChange.Magnitude
        
        -- Если камера резко изменилась - это отдача
        if changeMagnitude > 0.02 then
            compensationOffset = compensationOffset - (lookChange * env.NoRecoilStrength)
        end
        
        -- Плавно уменьшаем компенсацию
        compensationOffset = compensationOffset * 0.92
        
        -- Применяем компенсацию
        if compensationOffset.Magnitude > 0.001 then
            local newCFrame = CFrame.lookAt(
                currentPos,
                currentPos + currentLook + compensationOffset
            )
            Camera.CFrame = newCFrame
        end
        
        lastCameraPos = Camera.CFrame.Position
        lastCameraLookVector = Camera.CFrame.LookVector
    else
        lastCameraPos = Camera.CFrame.Position
        lastCameraLookVector = Camera.CFrame.LookVector
        compensationOffset = Vector3.new(0, 0, 0)
    end
end)

-- ========== ГЛАВНЫЙ ИГРОВОЙ ЦИКЛ ==========
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if env.AimbotEnabled then
        local target = GetClosestEnemyInFOV()
        if target then
            SmoothAimbot(target)
        end
    end

    -- Показ FOV круга
    if fovCircle then
        fovCircle.Visible = env.ShowFOV and env.AimbotEnabled
        if fovCircle.Visible then
            fovCircle.Radius = env.FOV
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
    end

    -- Обновление Chams
    UpdateChams()
end)

-- Уничтожение Chams при выходе
LocalPlayer.CharacterAdded:Connect(function()
    ClearAllChams()
end)

print("🎮 TECHY SCRIPT загружен! Нажми на кнопку ⚙️ чтобы открыть меню")
print("✨ Исправлено: Aimbot, No Recoil, красивое меню на русском")
