-- [[ СИСТЕМА АНТИ-КРАША И ГЕНЕРАЦИИ ]] --
local MathRandom = math.random
local function generateRandomName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    local name = ""
    for i = 1, MathRandom(12, 18) do
        local randIdx = MathRandom(1, #chars)
        name = name .. string.sub(chars, randIdx, randIdx)
    end
    return name
end

-- [[ СЕРВИСЫ ROBLOX ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- [[ ГЛОБАЛЬНЫЕ НАСТРОЙКИ ]] --
local Settings = {
    AimbotEnabled = false,
    FlickMode = false,
    WallCheck = false,
    AimFOV = 120,
    FlickFOV = 180,
    FlickDelay = 0.01,
    TargetPart = "Head",
    EspLines = false,
    EspCharms = false,
    BHopEnabled = false,
    BHopPower = 1.0, -- От 1 до 15 (шаг 0.5 контролируется слайдером)
    ShowAimFOV = false,
    ShowFlickFOV = false,
    InstantReload = false,
    FPSUnlocker = false,
    PerfMonitor = false,
    TriggerbotEnabled = false,
    TriggerbotDelay = 0,
    TriggerbotHitchance = 100
}

-- [[ КЭШ И СЛУЖЕБНЫЕ ПЕРЕМЕННЫЕ ]] --
local ESP_Cache = {}
local fpsTable = {}
local lastShotTime = 0
local triggerShotCooldown = 0.01 -- Максимально быстрый отклик

-- [[ БЕЗОПАСНАЯ ИНЖЕКЦИЯ GUI ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = generateRandomName()
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function getSecureContainer()
    local target = nil
    pcall(function()
        if game:GetService("CoreGui") then
            target = game:GetService("CoreGui"):FindFirstChildOfClass("Folder") or game:GetService("CoreGui")
        end
    end)
    return target or LocalPlayer:WaitForChild("PlayerGui", 15)
end
ScreenGui.Parent = getSecureContainer()

-- Функция плавного перетаскивания (Draggable)
local function makeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            TweenService:Create(gui, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Плавающая кнопка
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
ToggleButton.Text = "NL"
ToggleButton.TextColor3 = Color3.fromRGB(0, 180, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 28)
local TBBorder = Instance.new("UIStroke", ToggleButton)
TBBorder.Color = Color3.fromRGB(0, 162, 255)
TBBorder.Thickness = 2
makeDraggable(ToggleButton)

-- Главное меню
local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 320, 0, 450)
MainMenu.Position = UDim2.new(0.5, -160, 0.5, -225)
MainMenu.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

Instance.new("UICorner", MainMenu).CornerRadius = UDim.new(0, 12)
local MenuBorder = Instance.new("UIStroke", MainMenu)
MenuBorder.Color = Color3.fromRGB(25, 30, 45)
MenuBorder.Thickness = 1.5
makeDraggable(MainMenu)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
Title.Text = "   NEVERLOSE.CC // Premium Custom v16"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = MainMenu
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

ToggleButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -50)
Scroll.Position = UDim2.new(0, 8, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
Scroll.Parent = MainMenu

local ContentLayout = Instance.new("UIListLayout", Scroll)
ContentLayout.Padding = UDim.new(0, 6)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Монитор производительности
local PerfFrame = Instance.new("Frame")
PerfFrame.Size = UDim2.new(0, 150, 0, 80)
PerfFrame.Position = UDim2.new(1, -165, 0, 15)
PerfFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
PerfFrame.Visible = false
PerfFrame.Parent = ScreenGui

Instance.new("UICorner", PerfFrame).CornerRadius = UDim.new(0, 6)
local PerfStroke = Instance.new("UIStroke", PerfFrame)
PerfStroke.Color = Color3.fromRGB(0, 162, 255)

local PerfText = Instance.new("TextLabel")
PerfText.Size = UDim2.new(1, -12, 1, -12)
PerfText.Position = UDim2.new(0, 6, 0, 6)
PerfText.BackgroundTransparency = 1
PerfText.TextColor3 = Color3.fromRGB(255, 255, 255)
PerfText.Font = Enum.Font.Code
PerfText.TextSize = 11
PerfText.TextXAlignment = Enum.TextXAlignment.Left
PerfText.TextYAlignment = Enum.TextYAlignment.Top
PerfText.Parent = PerfFrame

-- [[ КОНСТРУКТОРЫ ЭЛЕМЕНТОВ ]] --
local function createToggle(parent, text, settingName, extraCallback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(14, 18, 26)
    btn.Text = "   " .. text
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextColor3 = Color3.fromRGB(150, 160, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = parent
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local btnBorder = Instance.new("UIStroke", btn)
    btnBorder.Color = Color3.fromRGB(28, 34, 46)
    btnBorder.Thickness = 1

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 8, 0, 8)
    indicator.Position = UDim2.new(1, -22, 0.5, -4)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 4)

    local function updateVisuals(animate)
        local targetBg = Settings[settingName] and Color3.fromRGB(16, 36, 54) or Color3.fromRGB(14, 18, 26)
        local targetBorder = Settings[settingName] and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(28, 34, 46)
        local targetInd = Settings[settingName] and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(255, 60, 60)
        local targetText = Settings[settingName] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 160, 180)

        if animate then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = targetBg, TextColor3 = targetText}):Play()
            TweenService:Create(btnBorder, TweenInfo.new(0.12), {Color = targetBorder}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.12), {BackgroundColor3 = targetInd}):Play()
        else
            btn.BackgroundColor3 = targetBg
            btn.TextColor3 = targetText
            btnBorder.Color = targetBorder
            indicator.BackgroundColor3 = targetInd
        end
    end

    btn.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        updateVisuals(true)
        if extraCallback then pcall(extraCallback, Settings[settingName]) end
    end)
    updateVisuals(false)
end

local function createSlider(parent, text, min, max, default, isFloat, step, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -4, 0, 44)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = "   " .. text .. ": " .. string.format(isFloat and "%.2f" or "%d", default)
    label.TextColor3 = Color3.fromRGB(180, 190, 205)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -20, 0, 6)
    bg.Position = UDim2.new(0, 10, 0, 24)
    bg.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    bg.Parent = container
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local sliderBtn = Instance.new("TextButton", bg)
    sliderBtn.Size = UDim2.new(0, 12, 0, 12)
    sliderBtn.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderBtn.Text = ""
    Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(0, 6)

    local active = false
    local function updateSlider(inputPosition)
local x = math.clamp((inputPosition.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
local rawVal = min + (x * (max - min))

if step then
rawVal = math.round(rawVal / step) * step
elseif not isFloat then
rawVal = math.floor(rawVal)
end
rawVal = math.clamp(rawVal, min, max)

local visualX = (rawVal - min) / (max - min)
sliderBtn.Position = UDim2.new(visualX, -6, 0.5, -6)
fill.Size = UDim2.new(visualX, 0, 1, 0)

label.Text = " " .. text .. ": " .. string.format(isFloat and "%.1f" or "%d", rawVal)
pcall(callback, rawVal)
end

bg.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true; updateSlider(i.Position) end
end)
UserInputService.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end
end)
UserInputService.InputChanged:Connect(function(i)
if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSlider(i.Position) end
end)
end

-- [[ НАПОЛНЕНИЕ МЕНЮ (БЕЗ КОСМЕТИКИ) ]] --
createToggle(Scroll, "On-Shot Flickbot", "FlickMode")
createToggle(Scroll, "Combat Aimbot", "AimbotEnabled")
createToggle(Scroll, "Triggerbot", "TriggerbotEnabled")
createSlider(Scroll, "Trigger Delay (ms)", 0, 500, Settings.TriggerbotDelay * 1000, false, nil, function(v) Settings.TriggerbotDelay = v / 1000 end)
createSlider(Scroll, "Trigger Hitchance", 10, 100, Settings.TriggerbotHitchance, false, nil, function(v) Settings.TriggerbotHitchance = v end)
createToggle(Scroll, "Aim/Flick Wallcheck", "WallCheck")
createToggle(Scroll, "Show Flick FOV (Red)", "ShowFlickFOV")
createToggle(Scroll, "Show Aim FOV (Blue)", "ShowAimFOV")

createToggle(Scroll, "Esp line(v)", "EspLines")
createToggle(Scroll, "ESP Charms", "EspCharms")

createToggle(Scroll, "BunnyHop", "BHopEnabled")
createSlider(Scroll, "BHop Power Strength", 1, 15, Settings.BHopPower, true, 0.5, function(v) Settings.BHopPower = v end)

createToggle(Scroll, "Instant Reload (Universal)", "InstantReload")
createToggle(Scroll, "FPS Unlocker (999 FPS)", "FPSUnlocker", function(state) if setfpscap then setfpscap(state and 999 or 60) end end)
createToggle(Scroll, "Performance Monitor", "PerfMonitor", function(state) PerfFrame.Visible = state end)

createSlider(Scroll, "Aim FOV", 10, 900, Settings.AimFOV, false, nil, function(v) Settings.AimFOV = v end)
createSlider(Scroll, "Flick FOV", 10, 900, Settings.FlickFOV, false, nil, function(v) Settings.FlickFOV = v end)
createSlider(Scroll, "Flick Delay", 0.01, 1.00, Settings.FlickDelay, true, nil, function(v) Settings.FlickDelay = v end)

-- FOV Кольца
local Aim_Circle, Flick_Circle
pcall(function()
Aim_Circle = Drawing.new("Circle"); Aim_Circle.Visible = false; Aim_Circle.Color = Color3.fromRGB(0, 162, 255); Aim_Circle.Thickness = 1.5
Flick_Circle = Drawing.new("Circle"); Flick_Circle.Visible = false; Flick_Circle.Color = Color3.fromRGB(255, 50, 50); Flick_Circle.Thickness = 1.5
end)

-- [[ ФУНКЦИОНАЛ: ПРОВЕРКА СТЕН ]] --
local function checkWallVisibility(targetPart, enemyCharacter)
if not Settings.WallCheck then return true end
if not targetPart or not enemyCharacter then return false end
local origin = Camera.CFrame.Position
local direction = (targetPart.Position - origin)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
raycastParams.IgnoreWater = true
local result = workspace:Raycast(origin, direction, raycastParams)
if result and result.Instance then
return result.Instance:IsDescendantOf(enemyCharacter)
end
return true
end

-- Улучшенный симулятор клика / выстрела
local function secureDeltaClick()
pcall(function()
if mouse1click then
mouse1click()
elseif mouse1press and mouse1release then
mouse1press(); task.wait(0.001); mouse1release()
end
end)
end

-- Поиск ближайшего игрока к прицелу
local function getClosestPlayer(currentFOV)
local closestTarget = nil
local minDistance = currentFOV + 1
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
local targetPart = player.Character:FindFirstChild(Settings.TargetPart)

if humanoid and humanoid.Health > 0 and targetPart then
local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
if onScreen then
local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
if distance <= currentFOV and distance < minDistance then
if checkWallVisibility(targetPart, player.Character) then
minDistance = distance
closestTarget = targetPart
end
end
end
end
end
end
return closestTarget
end

-- [[ ФУНКЦИОНАЛ: ТРИГГЕРБОТ ]] --
local function runTriggerbot()
if not Settings.TriggerbotEnabled or not Mouse.Target then return end
pcall(function()
local instance = Mouse.Target
local char = instance.Parent
if char:IsA("Accessory") or char:IsA("Tool") then char = char.Parent end

local humanoid = char:FindFirstChildOfClass("Humanoid")
local player = Players:GetPlayerFromCharacter(char)

if humanoid and humanoid.Health > 0 and player and player ~= LocalPlayer then
if player.Team ~= LocalPlayer.Team or player.Team == nil then
if checkWallVisibility(instance, char) then
local currentTime = os.clock()
if currentTime - lastShotTime >= triggerShotCooldown then
if MathRandom(1, 100) <= Settings.TriggerbotHitchance then
lastShotTime = currentTime
if Settings.TriggerbotDelay > 0 then
task.delay(Settings.TriggerbotDelay, function()
if Mouse.Target and Mouse.Target:IsDescendantOf(char) then secureDeltaClick() end
end)
else
secureDeltaClick()
end
end
end
end
end
end
end)
end

-- [[ ФУНКЦИОНАЛ: МГНОВЕННАЯ ПЕРЕЗАРЯДКА ]] --
local function handleInstantReload()
if not Settings.InstantReload then return end
pcall(function()
local char = LocalPlayer.Character
local targetTools = {}
if char then for _, v in ipairs(char:GetChildren()) do if v:IsA("Tool") then table.insert(targetTools, v) end end end
if LocalPlayer:FindFirstChild("Backpack") then
for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do if v:IsA("Tool") then table.insert(targetTools, v) end end
end

for _, tool in ipairs(targetTools) do
for _, obj in ipairs(tool:GetDescendants()) do
if obj:IsA("NumberValue") or obj:IsA("IntValue") then
local name = obj.Name:lower()
if name:find("reload") or name:find("delay") or name:find("cooldown") or name:find("time") or name:find("duration") then
obj.Value = 0.0001
elseif name:find("ammo") or name:find("clip") or name:find("mag") then
if obj.Value < 30 then obj.Value = 250 end
end
end
end
end
end)
end

-- [[ ФУНКЦИОНАЛ: ПРАВИЛЬНЫЙ BHOP ]] --
local function handleBunnyHop()
if not Settings.BHopEnabled then return end
pcall(function()
local char = LocalPlayer.Character
local humanoid = char and char:FindFirstChildOfClass("Humanoid")
local hrp = char and char:FindFirstChild("HumanoidRootPart")

if humanoid and hrp and humanoid.Health > 0 then
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
if humanoid.FloorMaterial ~= Enum.Material.Air then
-- Прыжок с ускорением в зависимости от слайдера (сила 1 = дефолт, 15 = максимум)
local basePower = 14 * Settings.BHopPower
hrp.Velocity = Vector3.new(hrp.Velocity.X, 32 + (Settings.BHopPower * 2.5), hrp.Velocity.Z)

if humanoid.MoveDirection.Magnitude > 0 then
hrp.Velocity = hrp.Velocity + (humanoid.MoveDirection * basePower)
end
end
else
-- Если пробел отпущен и игрок приземлился — моментальный сброс скорости до обычной
if humanoid.FloorMaterial ~= Enum.Material.Air then
local currentVel = hrp.Velocity
hrp.Velocity = Vector3.new(currentVel.X * 0.5, currentVel.Y, currentVel.Z * 0.5)
end
end
end
end)
end

-- [[ СИСТЕМА ФИЛЬТРАЦИИ И ОЧИСТКИ КЭША ESP ]] --
local function clearESPData(player)
if ESP_Cache[player] then
pcall(function() ESP_Cache[player].Line:Destroy() end)
pcall(function() ESP_Cache[player].Highlight:Destroy() end)
ESP_Cache[player] = nil
end
end

-- [[ ИНИЦИАЛИЗАЦИЯ 2D ЛИНИЙ И СУПЕР CHARMS ]] --
local function createEngineESP(player)
if player == LocalPlayer then return end
clearESPData(player)

local function setupVisuals(character)
pcall(function()
local hrp = character:WaitForChild("HumanoidRootPart", 10)
if not hrp then return end

-- Инициализация 2D Линии (Drawing API)
local line = Drawing.new("Line")
line.Visible = false
line.Color = Color3.fromRGB(0, 162, 255)
line.Thickness = 1.5

-- Инициализация Настоящих Charms (Highlight)
local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.fromRGB(0, 162, 255)
highlight.FillTransparency = 0.4
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.OutlineTransparency = 0.1
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Adornee = character
highlight.Enabled = false
highlight.Parent = ScreenGui

ESP_Cache[player] = {Line = line, Highlight = highlight}
end)
end

if player.Character then setupVisuals(player.Character) end
player.CharacterAdded:Connect(setupVisuals)
end

Players.PlayerAdded:Connect(createEngineESP)
Players.PlayerRemoving:Connect(clearESPData)
for _, p in ipairs(Players:GetPlayers()) do createEngineESP(p) end

-- Flick-Snap при нажатии
UserInputService.InputBegan:Connect(function(input, processed)
if processed or not Settings.FlickMode then return end
if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
local target = getClosestPlayer(Settings.FlickFOV)
if target then
task.delay(Settings.FlickDelay, function()
pcall(function()
if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
end
end)
end)
end
end
end)

-- [[ ГЛАВНЫЙ ИСПОЛНИТЕЛЬНЫЙ ЦИКЛ (БЕЗ ЗАДЕРЖЕК КАДРОВ) ]] --
RunService.RenderStepped:Connect(function()
local nowClock = os.clock()
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Рендер FOV кругов
pcall(function()
if Settings.ShowAimFOV and Aim_Circle then
Aim_Circle.Position = screenCenter; Aim_Circle.Radius = Settings.AimFOV; Aim_Circle.Visible = true
else Aim_Circle.Visible = false end

if Settings.ShowFlickFOV and Flick_Circle then
Flick_Circle.Position = screenCenter; Flick_Circle.Radius = Settings.FlickFOV; Flick_Circle.Visible = true
else Flick_Circle.Visible = false end
end)

-- Работа аимбота и триггера
if Settings.AimbotEnabled and not Settings.FlickMode then
local target = getClosestPlayer(Settings.AimFOV)
if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
end

runTriggerbot()
handleInstantReload()
handleBunnyHop()

-- ДИНАМИЧЕСКИЙ ОБСЧЕТ 2D ЛИНИЙ ОТ ЦЕНТРА ЭКРАНА И CHARMS
for player, visual in pairs(ESP_Cache) do
pcall(function()
local char = player.Character
local humanoid = char and char:FindFirstChildOfClass("Humanoid")
local hrp = char and char:FindFirstChild("HumanoidRootPart")

if char and humanoid and hrp and humanoid.Health > 0 then
local isEnemy = (player.Team ~= LocalPlayer.Team or player.Team == nil)

-- Логика Charms (Chams)
if Settings.EspCharms and isEnemy then
visual.Highlight.Enabled = true
visual.Highlight.Adornee = char
else
visual.Highlight.Enabled = false
end

-- Логика Линий от центра экрана
if Settings.EspLines and isEnemy then
local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
if onScreen then
visual.Line.From = screenCenter
visual.Line.To = Vector2.new(vector.X, vector.Y)
visual.Line.Visible = true
else
visual.Line.Visible = false
end
else
visual.Line.Visible = false
end
else
visual.Line.Visible = false
visual.Highlight.Enabled = false
end
end)
end

-- Монитор производительности
if Settings.PerfMonitor then
table.insert(fpsTable, nowClock)
while #fpsTable > 0 and fpsTable < nowClock - 1 do table.remove(fpsTable, 1) end
local curFps = #fpsTable
local curPing = 0
pcall(function() curPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
local curMem = string.format("%.1f", Stats:GetTotalMemoryUsageMb())
PerfText.Text = string.format("⚡ PERFORMANCE\n\nFPS: %d\nPING: %d ms\nMEM: %s MB", curFps, curPing, curMem)
end
end)
