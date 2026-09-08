--[[
    Скрипт для Roblox Delta Mobile - Hood Rivals
    Легитный скрипт с плавающим GUI, aimbot, visuals и настройками.
    Адаптирован под мобильные устройства.
]]

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ================== НАСТРОЙКИ ==================
local Settings = {
    Aimbot = {
        Enabled = false,
        FOV = 70,               -- 10-500
        Smooth = 0.3,           -- 0.1 - мгновенно, 1 - плавно
        WallCheck = true,
        TeamCheck = true,
        HitPart = "Head",       -- Head, Torso, Legs
    },
    Visuals = {
        Enabled = false,
        Mode = "Both",          -- Fill, Box, Both
    },
    NoSpread = {
        Enabled = false,
    }
}

-- ================== СОЗДАНИЕ GUI ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoodRivalsCheat"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Главная плавающая кнопка
local MainButton = Instance.new("TextButton")
MainButton.Name = "MainButton"
MainButton.Size = UDim2.new(0, 50, 0, 50)
MainButton.Position = UDim2.new(0.8, 0, 0.7, 0)
MainButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainButton.Text = "HR"
MainButton.TextColor3 = Color3.fromRGB(255, 0, 255)
MainButton.Font = Enum.Font.GothamBold
MainButton.TextSize = 20
MainButton.AutoButtonColor = false
MainButton.Parent = ScreenGui

-- Стиль кнопки (скругление, тень)
local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0.3, 0)
UICornerBtn.Parent = MainButton

local UIStrokeBtn = Instance.new("UIStroke")
UIStrokeBtn.Color = Color3.fromRGB(255, 0, 255)
UIStrokeBtn.Thickness = 2
UIStrokeBtn.Parent = MainButton

-- Перетаскивание кнопки
local buttonDrag = false
local buttonDragStart = nil
local buttonStartPos = nil

MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        buttonDrag = true
        buttonDragStart = input.Position
        buttonStartPos = MainButton.Position
        input.UserInputState = Enum.UserInputState.Begin
    end
end)

MainButton.InputChanged:Connect(function(input)
    if buttonDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - buttonDragStart
        local newPos = UDim2.new(
            buttonStartPos.X.Scale, 
            buttonStartPos.X.Offset + delta.X,
            buttonStartPos.Y.Scale,
            buttonStartPos.Y.Offset + delta.Y
        )
        MainButton.Position = newPos
    end
end)

MainButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        buttonDrag = false
    end
end)

-- Меню
local MenuFrame = Instance.new("Frame")
MenuFrame.Name = "MenuFrame"
MenuFrame.Size = UDim2.new(0, 260, 0, 350)
MenuFrame.Position = UDim2.new(0.5, -130, 0.5, -175)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.Parent = ScreenGui

local UICornerMenu = Instance.new("UICorner")
UICornerMenu.CornerRadius = UDim.new(0, 8)
UICornerMenu.Parent = MenuFrame

local UIStrokeMenu = Instance.new("UIStroke")
UIStrokeMenu.Color = Color3.fromRGB(255, 0, 255)
UIStrokeMenu.Thickness = 2
UIStrokeMenu.Parent = MenuFrame

-- Перетаскивание меню
local menuDrag = false
local menuDragStart = nil
local menuStartPos = nil

MenuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        menuDrag = true
        menuDragStart = input.Position
        menuStartPos = MenuFrame.Position
    end
end)

MenuFrame.InputChanged:Connect(function(input)
    if menuDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - menuDragStart
        MenuFrame.Position = UDim2.new(
            menuStartPos.X.Scale, 
            menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale,
            menuStartPos.Y.Offset + delta.Y
        )
    end
end)

MenuFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        menuDrag = false
    end
end)

-- Заголовок меню
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MenuFrame

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 8)
UICornerTitle.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HR Mobile"
TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Кнопка закрытия меню
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = TitleBar

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 6)
UICornerClose.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MenuFrame.Visible = false
end)

-- Вкладки
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 30)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MenuFrame

local Tabs = {}
local TabNames = {"Main", "Combat", "Visuals", "Settings"}
local CurrentTab = "Main"

for i, name in ipairs(TabNames) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.25, -4, 1, 0)
    tabBtn.Position = UDim2.new((i-1)*0.25, 2, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 12
    tabBtn.Parent = TabContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        CurrentTab = name
        UpdateTabHighlights()
    end)
    table.insert(Tabs, tabBtn)
end

function UpdateTabHighlights()
    for _, btn in ipairs(Tabs) do
        if btn.Text == CurrentTab then
            btn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    UpdateTabContent()
end

-- Контент вкладок
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, 0, 1, -60)
ContentArea.Position = UDim2.new(0, 0, 0, 60)
ContentArea.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.Parent = MenuFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ContentArea

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 8)
UIPadding.PaddingRight = UDim.new(0, 8)
UIPadding.PaddingTop = UDim.new(0, 8)
UIPadding.PaddingBottom = UDim.new(0, 8)
UIPadding.Parent = ContentArea

-- Функция очистки контента
local function ClearContent()
    for _, child in ipairs(ContentArea:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") or child:IsA("ScrollingFrame") then
            child:Destroy()
        end
    end
end

-- Функция создания элементов
local function CreateToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentArea

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(80, 80, 80)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleBtn

    local state = default
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(80, 80, 80)
        callback(state)
    end)
    return state
end

local function CreateSlider(name, min, max, default, decimals, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = ContentArea

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(1, 0, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.BorderSizePixel = 0
    slider.Text = tostring(default)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.Font = Enum.Font.Gotham
    slider.TextSize = 12
    slider.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = slider

    -- Используем фокус для обновления значения
    slider.FocusLost:Connect(function(enterPressed)
        local val = tonumber(slider.Text)
        if val then
            val = math.clamp(val, min, max)
            if decimals == 0 then
                val = math.floor(val)
            else
                val = math.floor(val * 10^decimals + 0.5) / 10^decimals
            end
            slider.Text = tostring(val)
            label.Text = name .. ": " .. tostring(val)
            callback(val)
        end
    end)
    return default
end

-- Обновление контента вкладок
function UpdateTabContent()
    ClearContent()
    if CurrentTab == "Main" then
        local welcome = Instance.new("TextLabel")
        welcome.Size = UDim2.new(1, 0, 0, 80)
        welcome.BackgroundTransparency = 1
        welcome.Text = "Hood Rivals Mobile\nСкрипт v1.0"
        welcome.TextColor3 = Color3.fromRGB(255, 0, 255)
        welcome.Font = Enum.Font.GothamBold
        welcome.TextSize = 16
        welcome.TextWrapped = true
        welcome.Parent = ContentArea

    elseif CurrentTab == "Combat" then
        -- Aimbot toggle
        Settings.Aimbot.Enabled = CreateToggle("Aimbot", Settings.Aimbot.Enabled, function(val)
            Settings.Aimbot.Enabled = val
        end)

        -- FOV slider
        Settings.Aimbot.FOV = CreateSlider("FOV", 10, 500, Settings.Aimbot.FOV, 0, function(val)
            Settings.Aimbot.FOV = val
        end)

        -- Smooth slider
        Settings.Aimbot.Smooth = CreateSlider("Smooth", 0.1, 1.0, Settings.Aimbot.Smooth, 1, function(val)
            Settings.Aimbot.Smooth = val
        end)

        -- WallCheck toggle
        Settings.Aimbot.WallCheck = CreateToggle("WallCheck", Settings.Aimbot.WallCheck, function(val)
            Settings.Aimbot.WallCheck = val
        end)

        -- TeamCheck toggle
        Settings.Aimbot.TeamCheck = CreateToggle("TeamCheck", Settings.Aimbot.TeamCheck, function(val)
            Settings.Aimbot.TeamCheck = val
        end)

        -- No Spread toggle
        Settings.NoSpread.Enabled = CreateToggle("No Spread", Settings.NoSpread.Enabled, function(val)
            Settings.NoSpread.Enabled = val
            ApplyNoSpread()
        end)

        -- HitPart selection
        local hitFrame = Instance.new("Frame")
        hitFrame.Size = UDim2.new(1, 0, 0, 70)
        hitFrame.BackgroundTransparency = 1
        hitFrame.Parent = ContentArea

        local hitLabel = Instance.new("TextLabel")
        hitLabel.Size = UDim2.new(1, 0, 0, 20)
        hitLabel.BackgroundTransparency = 1
        hitLabel.Text = "Hit Part: " .. Settings.Aimbot.HitPart
        hitLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        hitLabel.Font = Enum.Font.Gotham
        hitLabel.TextSize = 12
        hitLabel.TextXAlignment = Enum.TextXAlignment.Left
        hitLabel.Parent = hitFrame

        local hitParts = {"Head", "Torso", "Legs"}
        for i, part in ipairs(hitParts) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.3, -4, 0, 25)
            btn.Position = UDim2.new((i-1)*0.33, 0, 0, 25)
            btn.BackgroundColor3 = Settings.Aimbot.HitPart == part and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(60, 60, 60)
            btn.BorderSizePixel = 0
            btn.Text = part
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 10
            btn.Parent = hitFrame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                Settings.Aimbot.HitPart = part
                hitLabel.Text = "Hit Part: " .. part
                for _, b in ipairs(hitFrame:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = b.Text == part and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(60, 60, 60)
                    end
                end
            end)
        end

    elseif CurrentTab == "Visuals" then
        -- ESP toggle
        Settings.Visuals.Enabled = CreateToggle("ESP", Settings.Visuals.Enabled, function(val)
            Settings.Visuals.Enabled = val
            UpdateESP()
        end)

        -- Mode selection
        local modeFrame = Instance.new("Frame")
        modeFrame.Size = UDim2.new(1, 0, 0, 60)
        modeFrame.BackgroundTransparency = 1
        modeFrame.Parent = ContentArea

        local modeLabel = Instance.new("TextLabel")
        modeLabel.Size = UDim2.new(1, 0, 0, 20)
        modeLabel.BackgroundTransparency = 1
        modeLabel.Text = "Режим ESP: " .. Settings.Visuals.Mode
        modeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        modeLabel.Font = Enum.Font.Gotham
        modeLabel.TextSize = 12
        modeLabel.TextXAlignment = Enum.TextXAlignment.Left
        modeLabel.Parent = modeFrame

        local modes = {"Fill", "Box", "Both"}
        for i, mode in ipairs(modes) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.3, -4, 0, 25)
            btn.Position = UDim2.new((i-1)*0.33, 0, 0, 25)
            btn.BackgroundColor3 = Settings.Visuals.Mode == mode and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(60, 60, 60)
            btn.BorderSizePixel = 0
            btn.Text = mode
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 10
            btn.Parent = modeFrame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                Settings.Visuals.Mode = mode
                modeLabel.Text = "Режим ESP: " .. mode
                for _, b in ipairs(modeFrame:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = b.Text == mode and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(60, 60, 60)
                    end
                end
                UpdateESP()
            end)
        end

    elseif CurrentTab == "Settings" then
        local settingsLabel = Instance.new("TextLabel")
        settingsLabel.Size = UDim2.new(1, 0, 0, 80)
        settingsLabel.BackgroundTransparency = 1
        settingsLabel.Text = "Настройки:\n- Перетаскивайте кнопку HR\n- Перетаскивайте меню за заголовок\n- Все изменения применяются сразу"
        settingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        settingsLabel.Font = Enum.Font.Gotham
        settingsLabel.TextSize = 12
        settingsLabel.TextWrapped = true
        settingsLabel.Parent = ContentArea
    end
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

-- Обработчик кнопки открытия меню
MainButton.MouseButton1Click:Connect(function()
    MenuFrame.Visible = not MenuFrame.Visible
    if MenuFrame.Visible then
        UpdateTabHighlights()
    end
end)

-- Инициализация
UpdateTabHighlights()

-- ================== Aimbot ==================
local function GetClosestPlayerToCenter()
    if not Settings.Aimbot.Enabled then return nil end
    local localTeam = LocalPlayer.Team
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestTarget = nil
    local bestAngle = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.Aimbot.TeamCheck and player.Team == localTeam then continue end

        local character = player.Character
        if not character then continue end
        local humanoid = character:FindFirstChildOfType("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not rootPart then continue end

        -- Определяем точку прицеливания
        local aimPart = nil
        if Settings.Aimbot.HitPart == "Head" then
            aimPart = character:FindFirstChild("Head")
        elseif Settings.Aimbot.HitPart == "Torso" then
            aimPart = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        elseif Settings.Aimbot.HitPart == "Legs" then
            aimPart = character:FindFirstChild("LeftLeg") or character:FindFirstChild("RightLeg") or character:FindFirstChild("HumanoidRootPart")
        end
        if not aimPart then aimPart = rootPart end

        -- Wallcheck
        if Settings.Aimbot.WallCheck then
            local rayOrigin = Camera.CFrame.Position
            local rayDirection = (aimPart.Position - rayOrigin).Unit * 500
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
            local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            if rayResult and rayResult.Instance then
                -- Есть стена между нами и целью
                continue
            end
        end

        -- Проверка FOV
        local screenPos, onScreen = Camera:WorldToScreenPoint(aimPart.Position)
        if not onScreen then continue end
        local screenVector = Vector2.new(screenPos.X, screenPos.Y)
        local distance = (screenVector - center).Magnitude
        local fovRadius = Settings.Aimbot.FOV -- в пикселях? Обычно FOV в углах, но для простоты используем радиус в пикселях
        -- Приведём FOV к радиусу экрана: FOV 10-500, где 500 это почти весь экран
        -- Условно: 100 FOV = 100px от центра
        if distance > fovRadius then continue end

        -- Выбираем ближайшего по углу (или по расстоянию на экране)
        local angle = math.atan2(screenVector.Y - center.Y, screenVector.X - center.X)
        if angle < bestAngle then
            bestAngle = angle
            bestTarget = {Player = player, Character = character, AimPart = aimPart}
        end
    end
    return bestTarget
end

local function SmoothTurn(targetCFrame)
    if not targetCFrame then return end
    local currentCF = Camera.CFrame
    local smooth = Settings.Aimbot.Smooth
    if smooth <= 0.1 then
        Camera.CFrame = targetCFrame
    else
        local newCF = currentCF:Lerp(targetCFrame, 1 - smooth) -- чем больше smooth, тем медленнее
        Camera.CFrame = newCF
    end
end

-- Цикл aimbot
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled then
        local target = GetClosestPlayerToCenter()
        if target then
            local aimPart = target.AimPart
            local targetPos = aimPart.Position
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            SmoothTurn(lookAt)
        end
    end
end)

-- ================== ESP ==================
local espHighlights = {}

local function UpdateESP()
    -- Удаляем старые подсветки
    for _, highlight in pairs(espHighlights) do
        highlight:Destroy()
    end
    espHighlights = {}

    if not Settings.Visuals.Enabled then return end

    local function setupESP(player)
        local function onCharacterAdded(character)
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_" .. player.Name
            highlight.Adornee = character
            highlight.FillColor = Color3.fromRGB(255, 0, 255)
            highlight.OutlineColor = Color3.fromRGB(255, 0, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- сквозь стены
            highlight.Parent = character

            -- Применяем режим
            local mode = Settings.Visuals.Mode
            if mode == "Fill" then
                highlight.FillTransparency = 0.3
                highlight.OutlineTransparency = 1
            elseif mode == "Box" then
                highlight.FillTransparency = 1
                highlight.OutlineTransparency = 0
            elseif mode == "Both" then
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
            end

            espHighlights[player] = highlight

            -- Удаляем при смерти или выходе
            local function onCharacterRemoved()
                if espHighlights[player] then
                    espHighlights[player]:Destroy()
                    espHighlights[player] = nil
                end
                character:GetPropertyChangedSignal("Parent"):Disconnect()
            end
            character:GetPropertyChangedSignal("Parent"):Connect(function()
                if not character.Parent then
                    onCharacterRemoved()
                end
            end)
        end

        if player.Character then
            onCharacterAdded(player.Character)
        end
        player.CharacterAdded:Connect(onCharacterAdded)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            setupESP(player)
        end
    end
end

-- Слежение за новыми игроками
Players.PlayerAdded:Connect(function(player)
    if Settings.Visuals.Enabled then
        setupESP(player)
    end
end)

-- ================== No Spread ==================
local originalWeaponProps = {}

local function ApplyNoSpread()
    if not LocalCharacter then return end
    local tools = LocalCharacter:GetChildren()
    for _, tool in ipairs(tools) do
        if tool:IsA("Tool") then
            if Settings.NoSpread.Enabled then
                -- Сохраняем оригинальные значения
                local propsToModify = {"Spread", "MinSpread", "MaxSpread", "Recoil", "CameraRecoil", "Sway", "RecoilPunch"}
                for _, prop in ipairs(propsToModify) do
                    local value = tool:FindFirstChild(prop)
                    if value then
                        if not originalWeaponProps[tool] then originalWeaponProps[tool] = {} end
                        originalWeaponProps[tool][prop] = value.Value
                        value.Value = 0
                    end
                end
            else
                -- Восстанавливаем оригинальные значения
                if originalWeaponProps[tool] then
                    for prop, origVal in pairs(originalWeaponProps[tool]) do
                        local value = tool:FindFirstChild(prop)
                        if value then
                            value.Value = origVal
                        end
                    end
                    originalWeaponProps[tool] = nil
                end
            end
        end
    end
end

-- Следим за сменой оружия
LocalPlayer.CharacterAdded:Connect(function(char)
    LocalCharacter = char
    if Settings.NoSpread.Enabled then
        ApplyNoSpread()
    end
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and Settings.NoSpread.Enabled then
            ApplyNoSpread()
        end
    end)
end)

-- ================== Завершение ==================
-- Запускаем ESP при первом включении
UpdateESP()

print("Hood Rivals скрипт загружен!")
