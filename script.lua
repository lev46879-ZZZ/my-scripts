-- [[ СЕРВИСЫ ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- [[ НАСТРОЙКИ ]] --
local Settings = {
    AimbotEnabled = false,
    FlickMode = false,
    WallCheck = false,
    AimFOV = 120,
    FlickFOV = 180,
    FlickDelay = 0.01,
    TargetPart = "Head",
    EspBox = false,
    EspCharms = false,
    EspLines = false,
    BHopEnabled = false,
    BHopPower = 1,
    ShowAimFOV = false,
    ShowFlickFOV = false,
    InstantReload = false,
    FPSUnlocker = false,
    PerfMonitor = false,
    TriggerbotEnabled = false,
    TriggerbotDelay = 0,
    TriggerbotHitchance = 100
}

local ESP_Cache = {}
local fpsTable = {}
local NormalSpeed = 16
local CurrentBHopSpeed = NormalSpeed

-- Переменные для контроля одиночного выстрела триггербота
local lastTargetCharacter = nil
local hasShotCurrentTarget = false

-- [[ ИНТЕРФЕЙС ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NL_Flick_V3_Final"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ToggleButton.Text = "NL"
ToggleButton.TextColor3 = Color3.fromRGB(0, 160, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 13
ToggleButton.Parent = ScreenGui

local TBCorner = Instance.new("UICorner"); TBCorner.CornerRadius = UDim.new(0, 25); TBCorner.Parent = ToggleButton
local TBBorder = Instance.new("UIStroke"); TBBorder.Color = Color3.fromRGB(0, 160, 255); TBBorder.Thickness = 1.5; TBBorder.Parent = ToggleButton
makeDraggable(ToggleButton)

local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 260, 0, 480)
MainMenu.Position = UDim2.new(0.5, -130, 0.5, -240)
MainMenu.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner"); MenuCorner.CornerRadius = UDim.new(0, 8); MenuCorner.Parent = MainMenu
local MenuBorder = Instance.new("UIStroke"); MenuBorder.Color = Color3.fromRGB(25, 30, 40); MenuBorder.Thickness = 1; MenuBorder.Parent = MainMenu
makeDraggable(MainMenu)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(14, 17, 23)
Title.Text = "  👑 NEVERLOSE.CC // FLICK"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.Parent = MainMenu

local TitleCorner = Instance.new("UICorner"); TitleCorner.CornerRadius = UDim.new(0, 8); TitleCorner.Parent = Title
ToggleButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -45)
Scroll.Position = UDim2.new(0, 8, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 850)
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 160, 255)
Scroll.Parent = MainMenu
local ContentLayout = Instance.new("UIListLayout"); ContentLayout.Padding = UDim.new(0, 6); ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; ContentLayout.Parent = Scroll

local PerfFrame = Instance.new("Frame")
PerfFrame.Size = UDim2.new(0, 140, 0, 75)
PerfFrame.Position = UDim2.new(1, -150, 0, 10)
PerfFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
PerfFrame.BackgroundTransparency = 0.2
PerfFrame.Visible = false
PerfFrame.Parent = ScreenGui

local PerfCorner = Instance.new("UICorner"); PerfCorner.CornerRadius = UDim.new(0, 5); PerfCorner.Parent = PerfFrame
local PerfStroke = Instance.new("UIStroke"); PerfStroke.Color = Color3.fromRGB(0, 160, 255); PerfStroke.Thickness = 1; PerfStroke.Parent = PerfFrame

local PerfText = Instance.new("TextLabel")
PerfText.Size = UDim2.new(1, -10, 1, -10)
PerfText.Position = UDim2.new(0, 5, 0, 5)
PerfText.BackgroundTransparency = 1
PerfText.TextColor3 = Color3.fromRGB(240, 240, 240)
PerfText.Font = Enum.Font.Code
PerfText.TextSize = 11
PerfText.TextXAlignment = Enum.TextXAlignment.Left
PerfText.TextYAlignment = Enum.TextYAlignment.Top
PerfText.Parent = PerfFrame

local function createToggle(parent, text, settingName, extraCallback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(16, 20, 26)
    btn.Text = "  " .. text
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextColor3 = Color3.fromRGB(160, 170, 185)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 4); btnCorner.Parent = btn
    local btnBorder = Instance.new("UIStroke"); btnBorder.Color = Color3.fromRGB(30, 36, 48); btnBorder.Thickness = 1; btnBorder.Parent = btn

    local statusIndicator = Instance.new("Frame")
    statusIndicator.Size = UDim2.new(0, 6, 0, 6)
    statusIndicator.Position = UDim2.new(1, -18, 0.5, -3)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    statusIndicator.Parent = btn

    local function updateVisuals()
        if Settings[settingName] then
            btn.BackgroundColor3 = Color3.fromRGB(18, 32, 45)
            btnBorder.Color = Color3.fromRGB(0, 160, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(16, 20, 26)
            btnBorder.Color = Color3.fromRGB(30, 36, 48)
            btn.TextColor3 = Color3.fromRGB(160, 170, 185)
            statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
        end
    end

    btn.MouseButton1Click:Connect(function() 
        Settings[settingName] = not Settings[settingName] 
        updateVisuals() 
        if extraCallback then extraCallback(Settings[settingName]) end
    end)
    updateVisuals()
end

local function createSlider(parent, text, min, max, default, isFloat, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -4, 0, 38)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 14)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. string.format(isFloat and "%.2f" or "%d", default)
    label.TextColor3 = Color3.fromRGB(180, 190, 200)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 4)
    bg.Position = UDim2.new(0, 0, 0, 20)
    bg.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    bg.Parent = container
    local bgCorner = Instance.new("UICorner"); bgCorner.CornerRadius = UDim.new(0, 2); bgCorner.Parent = bg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    fill.Parent = bg
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(0, 2); fillCorner.Parent = fill

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 10, 0, 10)
    btn.Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = ""
    btn.Parent = bg
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 5); btnCorner.Parent = btn

    local active = false
    bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local x = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            btn.Position = UDim2.new(x, -5, 0.5, -5)
            fill.Size = UDim2.new(x, 0, 1, 0)
            local val = min + (x * (max - min))
            if not isFloat then val = math.floor(val) end
            label.Text = text .. ": " .. string.format(isFloat and "%.2f" or "%d", val)
            callback(val)
        end
end)
end

-- Наполнение меню
createToggle(Scroll, "On-Shot Flickbot", "FlickMode")
createToggle(Scroll, "Combat Aimbot", "AimbotEnabled")
createToggle(Scroll, "Neverlose Triggerbot", "TriggerbotEnabled")
createSlider(Scroll, "Trigger Delay (ms)", 0, 500, Settings.TriggerbotDelay * 1000, false, function(v) Settings.TriggerbotDelay = v / 1000 end)
createSlider(Scroll, "Trigger Hitchance", 10, 100, Settings.TriggerbotHitchance, false, function(v) Settings.TriggerbotHitchance = v end)
createToggle(Scroll, "Wallcheck Bypass", "WallCheck")
createToggle(Scroll, "Show Flick FOV (Red)", "ShowFlickFOV")
createToggle(Scroll, "Show Aim FOV (Blue)", "ShowAimFOV")
createToggle(Scroll, "Lite Lines (WH)", "EspLines")
createToggle(Scroll, "Lite ESP Box", "EspBox")
createToggle(Scroll, "Lite Charms", "EspCharms")
createToggle(Scroll, "Smooth BunnyHop", "BHopEnabled")
createToggle(Scroll, "Instant Reload", "InstantReload")
createToggle(Scroll, "FPS Unlocker (999 FPS)", "FPSUnlocker", function(state) if setfpscap then setfpscap(state and 999 or 60) end end)
createToggle(Scroll, "Performance Monitor", "PerfMonitor", function(state) PerfFrame.Visible = state end)

createSlider(Scroll, "Aim FOV", 10, 900, Settings.AimFOV, false, function(v) Settings.AimFOV = v end)
createSlider(Scroll, "Flick FOV", 10, 900, Settings.FlickFOV, false, function(v) Settings.FlickFOV = v end)
createSlider(Scroll, "Flick Delay", 0.01, 1.00, Settings.FlickDelay, true, function(v) Settings.FlickDelay = v end)
createSlider(Scroll, "BHop Power", 1, 10, Settings.BHopPower, false, function(v) Settings.BHopPower = v end)

local Aim_Circle, Flick_Circle
pcall(function()
Aim_Circle = Drawing.new("Circle"); Aim_Circle.Visible = false; Aim_Circle.Color = Color3.fromRGB(0, 160, 255)
Flick_Circle = Drawing.new("Circle"); Flick_Circle.Visible = false; Flick_Circle.Color = Color3.fromRGB(255, 50, 50)
end)

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
minDistance = distance; closestTarget = targetPart
end
end
end
end
end
return closestTarget
end

-- ПРОВЕРКА ВАЛИДНОСТИ ЦЕЛИ (ЖИВОЙ, ВРАГ, НАСТОЯЩИЙ ИГРОК)
local function checkTarget(instance)
if not instance then return nil end

local char = instance.Parent
if char:IsA("Accessory") or char:IsA("Tool") then char = char.Parent end

local humanoid = char:FindFirstChildOfClass("Humanoid")
local player = Players:GetPlayerFromCharacter(char)

-- Жесткая проверка: здоровье > 0, персонаж не "мертв" по стейту, это не локальный игрок
if humanoid and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead and player and player ~= LocalPlayer then
-- Проверка на тимейтов
if player.Team ~= LocalPlayer.Team or player.Team == nil then
return char
end
end
return nil
end

-- ПРОДВИНУТЫЙ ТРИГГЕРБОТ (БЕЗ СТЕН, БЕЗ МЕРТВЫХ, С ОДИНОЧНЫМ КЛИКОМ)
local function runTriggerbot()
if not Settings.TriggerbotEnabled then return end

local targetCharacter = nil
local hitInstance = nil

-- 1. Сначала ищем цель через Mouse.Target
if Mouse.Target then
targetCharacter = checkTarget(Mouse.Target)
if targetCharacter then hitInstance = Mouse.Target end
end

-- 2. Если Mouse.Target пустой, страхуем через Raycast по направлению взгляда
if not targetCharacter then
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}

local res = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 1000, rayParams)
if res and res.Instance then
targetCharacter = checkTarget(res.Instance)
if targetCharacter then hitInstance = res.Instance end
end
end

-- ЛОГИКА ПРОВЕРКИ СТЕН И ОДИНОЧНОГО КЛИКА
if targetCharacter and hitInstance then
-- Проверка на стены (Wall Check): пускаем точечный луч ровно в хитбокс, в который навелись
local wallCheckParams = RaycastParams.new()
wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude
-- Игнорируем себя, камеру и САМОГО врага, чтобы проверить нет ли СТЕН между нами
wallCheckParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera, targetCharacter}

local directionToHit = (hitInstance.Position - Camera.CFrame.Position)
local wallCheckResult = workspace:Raycast(Camera.CFrame.Position, directionToHit, wallCheckParams)

-- Если луч встретил препятствие (стену) ДО игрока, отменяем выстрел
if wallCheckResult and wallCheckResult.Instance then
return
end

-- Если мы перевелись на НОВОГО врага, сбрасываем статус выстрела
if lastTargetCharacter ~= targetCharacter then
lastTargetCharacter = targetCharacter
hasShotCurrentTarget = false
end

-- Если на этого врага мы ЕЩЕ НЕ КЛИКАЛИ и прошел шанс Hitchance
if not hasShotCurrentTarget then
if math.random(1, 100) <= Settings.TriggerbotHitchance then
hasShotCurrentTarget = true -- Блокируем повторные клики, пока прицел на нем

if Settings.TriggerbotDelay > 0 then
task.delay(Settings.TriggerbotDelay, function()
-- Дополнительная проверка: мы все еще целимся в него после задержки?
if Mouse.Target and Mouse.Target:IsDescendantOf(targetCharacter) then
pcall(function() mouse1click() end)
end
end)
else
pcall(function() mouse1click() end) -- Мгновенный 1 клик
end
end
end
else
-- Если мы увели прицел с игрока, обнуляем цель. Теперь при следующем наведении скрипт сможет кликнуть снова.
lastTargetCharacter = nil
hasShotCurrentTarget = false
end
end

-- ВЫСТРЕЛ СНАП (FLICKBOT)
UserInputService.InputBegan:Connect(function(input, processed)
if processed then return end
if Settings.FlickMode and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
local target = getClosestPlayer(Settings.FlickFOV)
if target then
task.delay(Settings.FlickDelay, function()
if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") and target.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
end
end)
end
end
end)

-- РЕНДЕР ЦИКЛ
local lastUpdate = 0
RunService.RenderStepped:Connect(function()
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

if Settings.ShowAimFOV and Aim_Circle then Aim_Circle.Position = screenCenter; Aim_Circle.Radius = Settings.AimFOV; Aim_Circle.Visible = true elseif Aim_Circle then Aim_Circle.Visible = false end
if Settings.ShowFlickFOV and Flick_Circle then Flick_Circle.Position = screenCenter; Flick_Circle.Radius = Settings.FlickFOV; Flick_Circle.Visible = true elseif Flick_Circle then Flick_Circle.Visible = false end

if Settings.AimbotEnabled and not Settings.FlickMode then
local target = getClosestPlayer(Settings.AimFOV)
if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
end

-- Постоянный вызов триггербота
runTriggerbot()

if Settings.PerfMonitor then
local now = os.clock()
table.insert(fpsTable, now)
while #fpsTable > 0 and fpsTable < now - 1 do table.remove(fpsTable, 1) end
local curFps = #fpsTable
local curPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
local curMem = string.format("%.1f", Stats:GetTotalMemoryUsageMb())
PerfText.Text = string.format("⚡ PERF MONITOR\n\nFPS: %d\nPING: %d ms\nMEM: %s MB", curFps, curPing, curMem)
end

local nowTick = os.clock()
if nowTick - lastUpdate < 0.025 then return end
lastUpdate = nowTick

for player, visual in pairs(ESP_Cache) do
local char = player.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if char and hrp and hum and hum.Health > 0 then
local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
if Settings.EspLines and onScreen then
visual.Line.From = screenCenter; visual.Line.To = Vector2.new(pos.X, pos.Y); visual.Line.Visible = true
else visual.Line.Visible = false end
else
if visual.Line then visual.Line.Visible = false end
end
end
end)

local function createESP(player)
if ESP_Cache[player] then return end
local line = Drawing.new("Line"); line.Color = Color3.fromRGB(0, 160, 255); line.Thickness = 1; line.Visible = false
ESP_Cache[player] = {Line = line}
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(p) if ESP_Cache[p] then ESP_Cache[p].Line:Remove(); ESP_Cache[p] = nil end end)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end
