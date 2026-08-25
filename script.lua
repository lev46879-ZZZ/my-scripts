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
    AimFOV = 120,
    FlickFOV = 180,
    FlickDelay = 0.01,
    TargetPart = "Head",
    -- Визуалы
    EspBox = false,
    EspCharms = false,
    EspLines = false,
    -- Плавный BHOp
    BHopEnabled = false,
    BHopPower = 1,
    -- Отдельная независимая функция для [FPS] Flick
    UnlockCosmetics = false
}

local ESP_Cache = {}
local NormalSpeed = 16
local CurrentBHopSpeed = NormalSpeed

-- [[ СОЗДАНИЕ GUI ДЛЯ СМАРТФОНОВ ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlickGameUltimateHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Плавный Drag для мобилок
local function makeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

task.wait(0.1)

-- Плавающая кнопка
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.Parent = ScreenGui
local TBCorner = Instance.new("UICorner"); TBCorner.CornerRadius = UDim.new(0, 25); TBCorner.Parent = ToggleButton
makeDraggable(ToggleButton)

-- Главное меню
local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 260, 0, 440)
MainMenu.Position = UDim2.new(0.5, -130, 0.5, -220)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui
local MenuCorner = Instance.new("UICorner"); MenuCorner.CornerRadius = UDim.new(0, 8); MenuCorner.Parent = MainMenu
makeDraggable(MainMenu)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Title.Text = "[FPS] FLICK EXCLUSIVE"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = MainMenu

ToggleButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -45)
Scroll.Position = UDim2.new(0, 8, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 680)
Scroll.ScrollBarThickness = 2
Scroll.Parent = MainMenu
local ContentLayout = Instance.new("UIListLayout"); ContentLayout.Padding = UDim.new(0, 5); ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; ContentLayout.Parent = Scroll

local function createToggle(parent, text, settingName, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = parent
    btn.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        btn.Text = text .. (Settings[settingName] and ": ON" or ": OFF")
        btn.TextColor3 = Settings[settingName] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        if callback then callback(Settings[settingName]) end
    end)
end

local function createSlider(parent, text, min, max, default, isFloat, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18); label.BackgroundTransparency = 1; label.Text = text .. ": " .. string.format(isFloat and "%.2f" or "%d", default); label.TextColor3 = Color3.fromRGB(255,255,255); label.TextSize = 12; label.Parent = parent
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 8); bg.BackgroundColor3 = Color3.fromRGB(45, 45, 45); bg.Parent = parent
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 12, 1, 0); btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150); btn.Text = ""; btn.Parent = bg
    btn.Position = UDim2.new((default - min) / (max - min), -6, 0, 0)
    local active = false
    bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local x = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            btn.Position = UDim2.new(x, -6, 0, 0)
            local val = min + (x * (max - min))
            if not isFloat then val = math.floor(val) end
            label.Text = text .. ": " .. string.format(isFloat and "%.2f" or "%d", val)
            callback(val)
        end
    end)
end

-- [[ ОТДЕЛЬНЫЙ АНЛОКЕР КОСМЕТИКИ ДЛЯ [FPS] FLICK ]] --
local function initFlickCosmeticsUnlocker(enabled)
    if not enabled then return end
    
    -- Высокоуровневый перехват для [FPS] Flick через подмену метатаблиц
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if Settings.UnlockCosmetics and not checkcaller() then
            -- Перехватываем стандартные ключи проверки инвентаря снайперок и ножей в плейсе
            if key == "OwnsSkin" or key == "HasItem" or key == "Unlocked" or key == "SkinsData" or key == "Skins" then
                return true
            end
        end
        return oldIndex(self, key)
    end)
    
    -- Попытка локального взлома папки репликации данных игрока, если она используется в [FPS] Flick
    task.spawn(function()
        while Settings.UnlockCosmetics and task.wait(5) do
            pcall(function()
                local playerData = LocalPlayer:FindFirstChild("PlayerData") or LocalPlayer:FindFirstChild("Inventory")
                if playerData then
                    for _, child in ipairs(playerData:GetDescendants()) do
                        if child:IsA("BoolValue") or child:IsA("Value") then
                            child.Value = true
                        end
                    end
                end
            end)
        end
    end)
end

-- Рендер элементов (Каждая функция работает сама по себе!)
createToggle(Scroll, "Unlock All Cosmetics", "UnlockCosmetics", function(v) initFlickCosmeticsUnlocker(v) end)
createToggle(Scroll, "On-Shot Flickbot", "FlickMode")
createToggle(Scroll, "Combat Aimbot", "AimbotEnabled")
createToggle(Scroll, "Wallcheck Bypass", "WallCheck")
createToggle(Scroll, "Lite Lines (WH)", "EspLines")
createToggle(Scroll, "Lite ESP Box", "EspBox")
createToggle(Scroll, "Lite Charms", "EspCharms")
createToggle(Scroll, "Smooth BunnyHop", "BHopEnabled")

createSlider(Scroll, "Aim FOV", 10, 900, Settings.AimFOV, false, function(v) Settings.AimFOV = v end)
createSlider(Scroll, "Flick FOV", 10, 900, Settings.FlickFOV, false, function(v) Settings.FlickFOV = v end)
createSlider(Scroll, "Flick Delay", 0.01, 1.00, Settings.FlickDelay, true, function(v) Settings.FlickDelay = v end)
createSlider(Scroll, "BHop Power", 1, 10, Settings.BHopPower, false, function(v) Settings.BHopPower = v end)

-- Кольцо FOV
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = true; FOV_Circle.Thickness = 1; FOV_Circle.NumSides = 32; FOV_Circle.Filled = false

-- Легкая проверка стен
local function isVisible(targetPart, character)
    if not Settings.WallCheck then return true end
    local ignore = {LocalPlayer.Character, character, Camera}
    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = ignore
    local res = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, params)
    return res == nil
end

-- Поиск цели строго по Viewport-координатам центра
local function getClosestPlayer(currentFOV)
    local closestTarget, maxDistance = nil, currentFOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character:FindFirstChild(Settings.TargetPart)
            
            if humanoid and humanoid.Health > 0 and targetPart then
local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
if onScreen then
local target2D = Vector2.new(screenPos.X, screenPos.Y)
local distance = (target2D - screenCenter).Magnitude

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

-- Жесткий моментальный Флик по координатам без промахов
local function doPerfectFlick()
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
doPerfectFlick()
end
end)

-- [[ КЭШ ДЛЯ ОПТИМИЗИРОВАННОГО ESP ]] --
local function createESP(player)
if ESP_Cache[player] then return end
local box = Drawing.new("Square"); box.Color = Color3.fromRGB(0, 255, 150); box.Thickness = 1; box.Filled = false; box.Visible = false
local line = Drawing.new("Line"); line.Color = Color3.fromRGB(0, 255, 150); line.Thickness = 1; line.Visible = false
local charms = Instance.new("Highlight"); charms.FillColor = Color3.fromRGB(0, 255, 150); charms.FillTransparency = 0.6; charms.OutlineTransparency = 0.5; charms.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; charms.Enabled = false
ESP_Cache[player] = {Box = box, Line = line, Charms = charms}
end

local function removeESP(player)
if ESP_Cache[player] then
ESP_Cache[player].Box:Remove(); ESP_Cache[player].Line:Remove()
if ESP_Cache[player].Charms then ESP_Cache[player].Charms:Destroy() end
ESP_Cache[player] = nil
end
end

Players.PlayerAdded:Connect(createESP); Players.PlayerRemoving:Connect(removeESP)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end

-- Плавный BHOp
local function handleSmoothBHop()
if not Settings.BHopEnabled then return end
local character = LocalPlayer.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if humanoid then
local currentState = humanoid:GetState()
if (currentState == Enum.HumanoidStateType.Freefall or currentState == Enum.HumanoidStateType.Jumping) and humanoid.MoveDirection.Magnitude > 0 then
CurrentBHopSpeed = math.clamp(CurrentBHopSpeed + (Settings.BHopPower * 0.3), NormalSpeed, NormalSpeed + (Settings.BHopPower * 5))
humanoid.WalkSpeed = CurrentBHopSpeed
else
CurrentBHopSpeed = NormalSpeed; humanoid.WalkSpeed = NormalSpeed
end
end
end

-- [[ ОПТИМИЗИРОВАННЫЙ ЦИКЛ ОБНОВЛЕНИЯ ВИЗУАЛОВ ]] --
local lastUpdate = 0
RunService.RenderStepped:Connect(function()
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOV_Circle.Position = screenCenter
FOV_Circle.Radius = Settings.FlickMode and Settings.FlickFOV or Settings.AimFOV
FOV_Circle.Color = Settings.FlickMode and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 150)

handleSmoothBHop()

-- Обычный Аимбот
if Settings.AimbotEnabled and not Settings.FlickMode then
local target = getClosestPlayer(Settings.AimFOV)
if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
end

-- Ограничение фреймрейта для рендера визуалов на телефонах (фикс лагов)
local now = os.clock()
if now - lastUpdate < 0.025 then return end
lastUpdate = now

for player, visual in pairs(ESP_Cache) do
local character = player.Character
local hrp = character and character:FindFirstChild("HumanoidRootPart")
local head = character and character:FindFirstChild("Head")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")

if character and hrp and head and humanoid and humanoid.Health > 0 then
local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

if Settings.EspBox and onScreen then
local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
local height = math.abs(headPos.Y - legPos.Y)
visual.Box.Size = Vector2.new(height / 1.5, height)
visual.Box.Position = Vector2.new(hrpPos.X - (height / 1.5) / 2, hrpPos.Y - height / 2)
visual.Box.Visible = true
else visual.Box.Visible = false end

if Settings.EspLines and onScreen then
visual.Line.From = screenCenter
visual.Line.To = Vector2.new(hrpPos.X, hrpPos.Y)
visual.Line.Visible = true
else visual.Line.Visible = false end

if Settings.EspCharms then
visual.Charms.Parent = character
visual.Charms.Enabled = true
else visual.Charms.Enabled = false end
else
visual.Box.Visible = false; visual.Line.Visible = false; visual.Charms.Enabled = false
end
end
end)
