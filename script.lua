-- [[ СЕРВИСЫ ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
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
    -- Новые настройки:
    InstantReload = false,
    FPSUnlocker = false,
    PerfMonitor = false
}

local ESP_Cache = {}
local fpsTable = {}
local NormalSpeed = 16
local CurrentBHopSpeed = NormalSpeed

-- [[ АВТОНОМНАЯ ЗАГРУЗКА ИНТЕРФЕЙСА ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlickTrueSafe"
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

-- Плавающая кнопка
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 170)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 13
ToggleButton.Parent = ScreenGui

local TBCorner = Instance.new("UICorner"); TBCorner.CornerRadius = UDim.new(0, 25); TBCorner.Parent = ToggleButton
local TBBorder = Instance.new("UIStroke"); TBBorder.Color = Color3.fromRGB(0, 255, 170); TBBorder.Thickness = 1.5; TBBorder.Parent = ToggleButton
makeDraggable(ToggleButton)

-- Главное меню
local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 260, 0, 460) -- Немного увеличили высоту под новые функции
MainMenu.Position = UDim2.new(0.5, -130, 0.5, -230)
MainMenu.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner"); MenuCorner.CornerRadius = UDim.new(0, 10); MenuCorner.Parent = MainMenu
local MenuBorder = Instance.new("UIStroke"); MenuBorder.Color = Color3.fromRGB(30, 30, 30); MenuBorder.Thickness = 1; MenuBorder.Parent = MainMenu
makeDraggable(MainMenu)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "  ⚡ LITE FLICK v10"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = MainMenu

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 170)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
}
TitleGradient.Parent = Title
local TitleCorner = Instance.new("UICorner"); TitleCorner.CornerRadius = UDim.new(0, 10); TitleCorner.Parent = Title

ToggleButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -45)
Scroll.Position = UDim2.new(0, 8, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 720) -- Увеличили размер прокрутки
Scroll.ScrollBarThickness = 2
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
Scroll.Parent = MainMenu
local ContentLayout = Instance.new("UIListLayout"); ContentLayout.Padding = UDim.new(0, 6); ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; ContentLayout.Parent = Scroll

-- [[ ОВЕРЛЕЙ PERFORMANCE MONITOR ]] --
local PerfFrame = Instance.new("Frame")
PerfFrame.Size = UDim2.new(0, 140, 0, 75)
PerfFrame.Position = UDim2.new(1, -150, 0, 10)
PerfFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PerfFrame.BackgroundTransparency = 0.2
PerfFrame.Visible = false
PerfFrame.Parent = ScreenGui

local PerfCorner = Instance.new("UICorner"); PerfCorner.CornerRadius = UDim.new(0, 5); PerfCorner.Parent = PerfFrame
local PerfStroke = Instance.new("UIStroke"); PerfStroke.Color = Color3.fromRGB(0, 255, 170); PerfStroke.Thickness = 1; PerfStroke.Parent = PerfFrame

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
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.Text = "  " .. text
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 6); btnCorner.Parent = btn
    local btnBorder = Instance.new("UIStroke"); btnBorder.Color = Color3.fromRGB(40, 40, 40); btnBorder.Thickness = 1; btnBorder.Parent = btn

    local statusIndicator = Instance.new("Frame")
    statusIndicator.Size = UDim2.new(0, 6, 0, 6)
    statusIndicator.Position = UDim2.new(1, -18, 0.5, -3)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    statusIndicator.Parent = btn
    local siCorner = Instance.new("UICorner"); siCorner.CornerRadius = UDim.new(0, 3); siCorner.Parent = statusIndicator

    local function updateVisuals()
        if Settings[settingName] then
            btn.BackgroundColor3 = Color3.fromRGB(26, 36, 32)
            btnBorder.Color = Color3.fromRGB(0, 255, 170)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
        else
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            btnBorder.Color = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
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
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 4)
    bg.Position = UDim2.new(0, 0, 0, 20)
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bg.Parent = container
    local bgCorner = Instance.new("UICorner"); bgCorner.CornerRadius = UDim.new(0, 2); bgCorner.Parent = bg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
    fill.Parent = bg
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(0, 2); fillCorner.Parent = fill

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 10, 0, 10)
    btn.Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = ""
    btn.Parent = bg
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 5); btnCorner.Parent = btn
    local btnStroke = Instance.new("UIStroke"); btnStroke.Color = Color3.fromRGB(0, 255, 170); btnStroke.Thickness = 1.2; btnStroke.Parent = btn

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

-- Добавление элементов в меню
createToggle(Scroll, "On-Shot Flickbot", "FlickMode")
createToggle(Scroll, "Combat Aimbot", "AimbotEnabled")
createToggle(Scroll, "Wallcheck Bypass", "WallCheck")

local SectionLabel = Instance.new("TextLabel")
SectionLabel.Size = UDim2.new(1, 0, 0, 16); SectionLabel.BackgroundTransparency = 1; SectionLabel.Text = "--- FOV VISIBILITY ---"; SectionLabel.TextColor3 = Color3.fromRGB(120, 120, 120); SectionLabel.Font = Enum.Font.GothamBold; SectionLabel.TextSize = 10; SectionLabel.Parent = Scroll

createToggle(Scroll, "Show Flick FOV (Red)", "ShowFlickFOV")
createToggle(Scroll, "Show Aim FOV (Green)", "ShowAimFOV")

local SectionLabel2 = Instance.new("TextLabel")
SectionLabel2.Size = UDim2.new(1, 0, 0, 16); SectionLabel2.BackgroundTransparency = 1; SectionLabel2.Text = "--- VISUALS & MISC ---"; SectionLabel2.TextColor3 = Color3.fromRGB(120, 120, 120); SectionLabel2.Font = Enum.Font.GothamBold; SectionLabel2.TextSize = 10; SectionLabel2.Parent = Scroll

createToggle(Scroll, "Lite Lines (WH)", "EspLines")
createToggle(Scroll, "Lite ESP Box", "EspBox")
createToggle(Scroll, "Lite Charms", "EspCharms")
createToggle(Scroll, "Smooth BunnyHop", "BHopEnabled")

-- НОВЫЕ ТУМБЛЕРЫ ДЛЯ ФУНКЦИЙ 24, 45, 50
local SectionLabel3 = Instance.new("TextLabel")
SectionLabel3.Size = UDim2.new(1, 0, 0, 16); SectionLabel3.BackgroundTransparency = 1; SectionLabel3.Text = "--- NEW UTILITIES ---"; SectionLabel3.TextColor3 = Color3.fromRGB(120, 120, 120); SectionLabel3.Font = Enum.Font.GothamBold; SectionLabel3.TextSize = 10; SectionLabel3.Parent = Scroll

createToggle(Scroll, "Instant Reload", "InstantReload")
createToggle(Scroll, "FPS Unlocker (999 FPS)", "FPSUnlocker", function(state)
if setfpscap then setfpscap(state and 999 or 60) end
end)
createToggle(Scroll, "Performance Monitor", "PerfMonitor", function(state)
PerfFrame.Visible = state
end)

createSlider(Scroll, "Aim FOV", 10, 900, Settings.AimFOV, false, function(v) Settings.AimFOV = v end)
createSlider(Scroll, "Flick FOV", 10, 900, Settings.FlickFOV, false, function(v) Settings.FlickFOV = v end)
createSlider(Scroll, "Flick Delay", 0.01, 1.00, Settings.FlickDelay, true, function(v) Settings.FlickDelay = v end)
createSlider(Scroll, "BHop Power", 1, 10, Settings.BHopPower, false, function(v) Settings.BHopPower = v end)

-- [[ БЕЗОПАСНАЯ ИНИЦИАЛИЗАЦИЯ КОЛЕЦ FOV ]] --
local Aim_Circle, Flick_Circle

local function initDrawingSafe()
local success = pcall(function()
Aim_Circle = Drawing.new("Circle")
Aim_Circle.Visible = false; Aim_Circle.Thickness = 1; Aim_Circle.NumSides = 32; Aim_Circle.Filled = false; Aim_Circle.Color = Color3.fromRGB(0, 255, 150)

Flick_Circle = Drawing.new("Circle")
Flick_Circle.Visible = false; Flick_Circle.Thickness = 1; Flick_Circle.NumSides = 32; Flick_Circle.Filled = false; Flick_Circle.Color = Color3.fromRGB(255, 50, 50)
end)
if not success then
local fakeCircle = {Visible = false, Position = Vector2.new(0,0), Radius = 0, Color = Color3.new(), Thickness = 0}
Aim_Circle, Flick_Circle = fakeCircle, fakeCircle
end
end
initDrawingSafe()

local function checkWallVisibility(targetPart, character)
if not Settings.WallCheck then return true end
local partsObscuring = Camera:GetPartsObscuringTarget({targetPart.Position}, {LocalPlayer.Character, character, Camera})
return #partsObscuring == 0
end

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
local target2D = Vector2.new(screenPos.X, screenPos.Y)
local distance = (target2D - screenCenter).Magnitude

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

-- ВЫСТРЕЛ СНАП
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

-- ЛОГИКА INSTANT RELOAD
local function handleInstantReload()
if not Settings.InstantReload then return end
local char = LocalPlayer.Character
local backpack = LocalPlayer:FindFirstChild("Backpack")

local function clearDelay(tool)
if tool:IsA("Tool") then
for _, obj in ipairs(tool:GetDescendants()) do
if obj:IsA("NumberValue") or obj:IsA("IntValue") then
if obj.Name:lower():find("reload") or obj.Name:lower():find("delay") then
obj.Value = 0
end
end
end
end
end

if char then for _, t in ipairs(char:GetChildren()) do clearDelay(t) end end
if backpack then for _, t in ipairs(backpack:GetChildren()) do clearDelay(t) end end
end

-- [[ ОСНОВНОЙ РЕНДЕР ЦИКЛ ]] --
local lastUpdate = 0
RunService.RenderStepped:Connect(function(dt)
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Обновление колец FOV
if Settings.ShowAimFOV and Aim_Circle then
Aim_Circle.Position = screenCenter; Aim_Circle.Radius = Settings.AimFOV; Aim_Circle.Visible = true
elseif Aim_Circle then Aim_Circle.Visible = false end

if Settings.ShowFlickFOV and Flick_Circle then
Flick_Circle.Position = screenCenter; Flick_Circle.Radius = Settings.FlickFOV; Flick_Circle.Visible = true
elseif Flick_Circle then Flick_Circle.Visible = false end

-- Обычный аимбот
if Settings.AimbotEnabled and not Settings.FlickMode then
local target = getClosestPlayer(Settings.AimFOV)
if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
end

handleSmoothBHop()
handleInstantReload()

-- Расчет данных для Performance Monitor (если включен)
if Settings.PerfMonitor then
local now = os.clock()
table.insert(fpsTable, now)
while fpsTable[1] and fpsTable[1] < now - 1 do
table.remove(fpsTable, 1)
end
local currentFps = #fpsTable
local currentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
local currentMem = string.format("%.1f", Stats:GetTotalMemoryUsageMb())

PerfText.Text = string.format(
"⚡ PERF MONITOR\n\nFPS: %d\nPING: %d ms\nMEM: %s MB",
currentFps, currentPing, currentMem
)
end

-- Лимитер для более тяжелого ESP (40 FPS / каждые 0.025 сек)
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
visual.Line.From = screenCenter; visual.Line.To = Vector2.new(hrpPos.X, hrpPos.Y); visual.Line.Visible = true
else visual.Line.Visible = false end

if Settings.EspCharms then visual.Charms.Parent = character; visual.Charms.Enabled = true
else visual.Charms.Enabled = false end
else
visual.Box.Visible = false; visual.Line.Visible = false; visual.Charms.Enabled = false
end
end
end)

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
if ESP_Cache[player].Charms then pcall(function() ESP_Cache[player].Charms:Destroy() end) end
ESP_Cache[player] = nil
end
end

Players.PlayerAdded:Connect(createESP); Players.PlayerRemoving:Connect(removeESP)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createESP(p) end end
