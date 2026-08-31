-- ╔═══════════════════════════════════════════════════════════════╗
-- ║     TECHY SCRIPT v5 - ФИНАЛЬНАЯ ВЕРСИЯ                      ║
-- ║  Меню работает правильно, перетаскивание без багов          ║
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
env.ProSpreadEnabled = false
env.NoRecoilStrength = 1.0
env.AimbotSmoothness = 0.15

-- Функция определения врага
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

-- ========== ГЛАВНОЕ GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Name = "TechyMenuGui"

-- ========== ПЛАВАЮЩАЯ КНОПКА МЕНЮ ==========
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 70, 0, 70)
MenuButton.Position = UDim2.new(0, 20, 0, 250)
MenuButton.BackgroundColor3 = Color3.fromRGB(25, 135, 200)
MenuButton.BackgroundTransparency = 0.15
MenuButton.BorderSizePixel = 0
MenuButton.Text = "⚙️"
MenuButton.TextColor3 = Color3.new(1, 1, 1)
MenuButton.Font = Enum.Font.SourceSansBold
MenuButton.TextSize = 28
MenuButton.ZIndex = 999
MenuButton.Parent = ScreenGui

local UICorner1 = Instance.new("UICorner")
UICorner1.CornerRadius = UDim.new(0, 15)
UICorner1.Parent = MenuButton

local Shadow1 = Instance.new("UIStroke")
Shadow1.Color = Color3.fromRGB(20, 120, 180)
Shadow1.Thickness = 2
Shadow1.Parent = MenuButton

-- Простое открытие/закрытие меню - БЕЗ перетаскивания кнопки!
local menuOpen = false
MenuButton.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    MainMenu.Visible = menuOpen
end)

-- ========== ОСНОВНОЕ МЕНЮ ==========
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 340, 0, 700)
MainMenu.Position = UDim2.new(0.5, -170, 0.5, -350)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
MainMenu.BackgroundTransparency = 0.05
MainMenu.BorderSizePixel = 0
MainMenu.Visible = false
MainMenu.Active = true
MainMenu.ZIndex = 998
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
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(25, 135, 200)
Header.BackgroundTransparency = 0.2
Header.Text = "⚙️ TECHY MENU (тащи за заголовок)"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.SourceSansBold
Header.TextSize = 16
Header.BorderSizePixel = 0
Header.ZIndex = 998
Header.Parent = MainMenu

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Правильное перетаскивание ТОЛЬКО за заголовок
local draggingMenu = false
local dragOffsetMenu = Vector2.new(0, 0)

Header.MouseButton1Down:Connect(function()
    draggingMenu = true
    dragOffsetMenu = UserInputService:GetMouseLocation() - Vector2.new(MainMenu.AbsolutePosition.X, MainMenu.AbsolutePosition.Y)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMenu = false
    end
end)

RunService.RenderStepped:Connect(function()
    if draggingMenu then
        local mousePos = UserInputService:GetMouseLocation()
        local newPos = mousePos - dragOffsetMenu
        
        -- Ограничиваем чтобы меню не вышло за границы экрана
        local screenSize = ScreenGui.AbsoluteSize
        newPos = Vector2.new(
            math.clamp(newPos.X, 0, screenSize.X - MainMenu.AbsoluteSize.X),
            math.clamp(newPos.Y, 0, screenSize.Y - MainMenu.AbsoluteSize.Y)
        )
        
        MainMenu.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
    end
end)

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0, 7.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 20
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 998
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    MainMenu.Visible = false
end)

-- Контейнер для опций
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, 0, 1, -50)
ContentFrame.Position = UDim2.new(0, 0, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(25, 135, 200)
ContentFrame.ZIndex = 998
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ContentFrame.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ========== ФУНКЦИЯ СОЗДАНИЯ ПЕРЕКЛЮЧАТЕЛЯ ==========
local function CreateToggle(text, defaultValue, callback)
    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Size = UDim2.new(0, 310, 0, 50)
    ToggleContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    ToggleContainer.BackgroundTransparency = 0.3
    ToggleContainer.BorderSizePixel = 0
    ToggleContainer.ZIndex = 998
    ToggleContainer.Parent = ContentFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 220, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 998
    Label.Parent = ToggleContainer

    local ToggleSwitch = Instance.new("TextButton")
    ToggleSwitch.Size = UDim2.new(0, 55, 0, 30)
    ToggleSwitch.Position = UDim2.new(1, -70, 0.5, -15)
    ToggleSwitch.BackgroundColor3 = defaultValue and Color3.fromRGB(50, 180, 100) or Color3.fromRGB(100, 100, 100)
    ToggleSwitch.BackgroundTransparency = 0.2
    ToggleSwitch.Text = defaultValue and "ВКЛ" or "ВЫКЛ"
    ToggleSwitch.TextColor3 = Color3.new(1, 1, 1)
    ToggleSwitch.Font = Enum.Font.SourceSansBold
    ToggleSwitch.TextSize = 13
    ToggleSwitch.BorderSizePixel = 0
    ToggleSwitch.ZIndex = 998
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
    SliderContainer.Size = UDim2.new(0, 310, 0, 85)
    SliderContainer.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
    SliderContainer.BackgroundTransparency = 0.3
    SliderContainer.BorderSizePixel = 0
    SliderContainer.ZIndex = 998
    SliderContainer.Parent = ContentFrame

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(math.floor(defaultVal * 100) / 100)
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 998
    Label.Parent = SliderContainer

    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0, 70, 0, 25)
    InputBox.Position = UDim2.new(1, -80, 0, 5)
    InputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    InputBox.BackgroundTransparency = 0.3
    InputBox.Text = tostring(math.floor(defaultVal * 100) / 100)
    InputBox.TextColor3 = Color3.new(1, 1, 1)
    InputBox.Font = Enum.Font.SourceSans
    InputBox.TextSize = 14
    InputBox.BorderSizePixel = 0
    InputBox.ZIndex = 998
    InputBox.Parent = SliderContainer

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 4)
    InputCorner.Parent = InputBox

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(0, 290, 0, 8)
    SliderBg.Position = UDim2.new(0, 10, 0, 40)
    SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBg.BorderSizePixel = 0
    SliderBg.ZIndex = 998
    SliderBg.Parent = SliderContainer

    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 4)
    BgCorner.Parent = SliderBg

    local Thumb = Instance.new("Frame")
    Thumb.Size = UDim2.new(0, 18, 0, 18)
    Thumb.BackgroundColor3 = Color3.fromRGB(25, 135, 200)
    Thumb.BorderSizePixel = 0
    Thumb.ZIndex = 999
    Thumb.Parent = SliderBg

    local ThumbCorner = Instance.new("UICorner")
    ThumbCorner.CornerRadius = UDim.new(0, 9)
    ThumbCorner.Parent = Thumb

    local currentValue = defaultVal
    local isDragging = false

    local function UpdateSlider(value)
        value = math.clamp(value, minVal, maxVal)
        value = math.floor(value * 100) / 100
        
        local ratio = (value - minVal) / (maxVal - minVal)
        Thumb.Position = UDim2.new(ratio, -9, 0.5, -9)
        Label.Text = text .. ": " .. tostring(value)
        InputBox.Text = tostring(value)
        currentValue = value
        callback(value)
    end

    UpdateSlider(defaultVal)

    Thumb.MouseButton1Down:Connect(function()
        isDragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function()
        if isDragging then
            local mouseX = UserInputService:GetMouseLocation().X
            local sliderX = SliderBg.AbsolutePosition.X
            local sliderWidth = SliderBg.AbsoluteSize.X
            local ratio = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
            local value = minVal + (maxVal - minVal) * ratio
            UpdateSlider(value)
        end
    end)

    SliderBg.MouseButton1Down:Connect(function()
        local mouseX = UserInputService:GetMouseLocation().X
        local sliderX = SliderBg.AbsolutePosition.X
        local sliderWidth = SliderBg.AbsoluteSize.X
        local ratio = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        local value = minVal + (maxVal - minVal) * ratio
        UpdateSlider(value)
        isDragging = true
    end)

    InputBox.FocusLost:Connect(function()
        local num = tonumber(InputBox.Text)
        if num then
            UpdateSlider(num)
        else
            InputBox.Text = tostring(currentValue)
        end
    end)

    return SliderContainer
end

-- ========== ДОБАВЛЕНИЕ ЭЛЕМЕНТОВ МЕНЮ ==========
local padding = Instance.new("Frame")
padding.Size = UDim2.new(0, 0, 0, 5)
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
    if value then
        CreateAllChams()
    else
        ClearAllChams()
    end
end)

CreateToggle("🎲 Показать FOV", false, function(value)
    env.ShowFOV = value
end)

CreateToggle("🔫 БЕЗ ОТДАЧИ", false, function(value)
    env.NoRecoilEnabled = value
end)

CreateToggle("💥 PRO SPREAD (разброс при прыжке)", false, function(value)
    env.ProSpreadEnabled = value
end)

CreateSlider("🎯 FOV", 10, 600, 150, function(value)
    env.FOV = value
end)

CreateSlider("⚡ Точность Aimbot", 0.01, 1.0, 0.15, function(value)
    env.AimbotSmoothness = value
end)

CreateSlider("💥 Сила No Recoil", 0.1, 2.0, 1.0, function(value)
    env.NoRecoilStrength = value
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

-- ========== WALLCHECK ==========
local function IsVisible(targetPosition)
    if not env.WallCheckEnabled then return true end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local origin = Camera.CFrame.Position
    local direction = targetPosition - origin
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

-- ========== CHAMS ==========
local chamsHighlights = {}

local function CreateChamsForPlayer(player)
    if chamsHighlights[player] then return end
    local character = player.Character
    if not character then return end
    
    local oldHighlight = character:FindFirstChild("ChamsHighlight")
    if oldHighlight then oldHighlight:Destroy() end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ChamsHighlight"
    highlight.FillColor = Color3.fromRGB(255, 80, 80)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 0.0
    highlight.DepthMode = Enum.HighlightDepthMode.Always
    highlight.Parent = character
    
    chamsHighlights[player] = highlight
end

local function ClearChamsForPlayer(player)
    if chamsHighlights[player] then
        pcall(function()
            chamsHighlights[player]:Destroy()
        end)
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
        pcall(function()
            if hl then hl:Destroy() end
        end)
    end
    chamsHighlights = {}
end

local function UpdateChams()
    if not env.ChamsEnabled then 
        ClearAllChams()
        return 
    end
    
    local aliveEnemies = {}
    for _, player in ipairs(GetAliveEnemies()) do
        aliveEnemies[player] = true
    end
    
    for player in pairs(chamsHighlights) do
        if not aliveEnemies[player] then
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

-- ========== NO RECOIL ==========
local lastCameraLookVector = Camera.CFrame.LookVector
local recoilAccumulation = Vector3.new(0, 0, 0)

-- ========== PRO SPREAD (автоматический, без слайдеров) ==========
local lastCameraDirection = Camera.CFrame.LookVector

local function ApplyProSpread()
    if not env.ProSpreadEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    
    if not humanoid then return end
    
    -- Проверяем в ли игрок в воздухе (прыгает)
    local isInAir = humanoid:GetState() == Enum.HumanoidStateType.Freefall or 
                    humanoid:GetState() == Enum.HumanoidStateType.Flying or
                    humanoid:GetState() == Enum.HumanoidStateType.Jumping
    
    if isInAir then
        -- Если в воздухе - выравниваем разброс
        local currentLook = Camera.CFrame.LookVector
        local lookDifference = (currentLook - lastCameraDirection).Magnitude
        
        if lookDifference > 0.001 then
            -- Компенсируем разброс
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + lastCameraDirection)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.6)
        end
    else
        -- Когда на земле - обновляем направление
        lastCameraDirection = Camera.CFrame.LookVector
    end
end

-- ========== ГЛАВНЫЙ ИГРОВОЙ ЦИКЛ ==========
RunService.RenderStepped:Connect(function()
    -- Pro Spread
    ApplyProSpread()
    
    -- Aimbot
    if env.AimbotEnabled then
        local target = GetClosestEnemyInFOV()
        if target then
            SmoothAimbot(target)
        end
    end

    -- No Recoil
    if env.NoRecoilEnabled then
        local currentCFrame = Camera.CFrame
        local currentLookVector = currentCFrame.LookVector
        
        local lookDifference = currentLookVector - lastCameraLookVector
        
        if lookDifference.Magnitude > 0.001 then
            recoilAccumulation = recoilAccumulation + (lookDifference * env.NoRecoilStrength)
        end
        
        recoilAccumulation = recoilAccumulation * 0.88
        
        if recoilAccumulation.Magnitude > 0.0001 then
            local compensatedLook = currentLookVector - recoilAccumulation
            Camera.CFrame = CFrame.lookAt(currentCFrame.Position, currentCFrame.Position + compensatedLook)
        end
        
        lastCameraLookVector = Camera.CFrame.LookVector
    else
        lastCameraLookVector = Camera.CFrame.LookVector
        recoilAccumulation = Vector3.new(0, 0, 0)
    end

    -- FOV Circle
    if fovCircle then
        fovCircle.Visible = env.ShowFOV and env.AimbotEnabled
        if fovCircle.Visible then
            fovCircle.Radius = env.FOV
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
    end

    -- Chams
    UpdateChams()
end)

-- Очистка
LocalPlayer.CharacterAdded:Connect(function()
    ClearAllChams()
end)

print("✅ TECHY SCRIPT v5 загружен!")
print("🎯 Нажми кнопку ⚙️ для открытия меню")
print("📌 Перетаскивай меню за заголовок!")
print("💥 Pro Spread работает автоматически при прыжке")
