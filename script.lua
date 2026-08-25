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
    SilentAimEnabled = false, -- Мгновенный безопасный снап
    WallCheck = false,
    AimFOV = 120,
    FlickFOV = 180,
    SilentFOV = 100,
    FlickDelay = 0.01,
    TargetPart = "Head",
    EspBox = false,
    EspCharms = false,
    EspLines = false,
    BHopEnabled = false,
    BHopPower = 1
}

local ESP_Cache = {}
local NormalSpeed = 16
local CurrentBHopSpeed = NormalSpeed

-- [[ СОЗДАНИЕ GUI ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlickUltimateHubSafe"
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

task.wait(0.1)

-- [[ КНОПКА МЕНЮ ]] --
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ToggleButton.Text = "MENU"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 170)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 13
ToggleButton.Parent = ScreenGui

local TBCorner = Instance.new("UICorner"); TBCorner.CornerRadius = UDim.new(0, 28); TBCorner.Parent = ToggleButton
local TBBorder = Instance.new("UIStroke"); TBBorder.Color = Color3.fromRGB(0, 255, 170); TBBorder.Thickness = 1.5; TBBorder.Parent = ToggleButton
makeDraggable(ToggleButton)

-- [[ ГЛАВНОЕ МЕНЮ ]] --
local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 270, 0, 440)
MainMenu.Position = UDim2.new(0.5, -135, 0.5, -220)
MainMenu.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner"); MenuCorner.CornerRadius = UDim.new(0, 10); MenuCorner.Parent = MainMenu
local MenuBorder = Instance.new("UIStroke"); MenuBorder.Color = Color3.fromRGB(30, 30, 30); MenuBorder.Thickness = 1; MenuBorder.Parent = MainMenu
makeDraggable(MainMenu)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "  ⚡ FLICK SAFE v5"
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
Scroll.Size = UDim2.new(1, -16, 1, -55)
Scroll.Position = UDim2.new(0, 8, 0, 48)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 660)
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 170)
Scroll.Parent = MainMenu
local ContentLayout = Instance.new("UIListLayout"); ContentLayout.Padding = UDim.new(0, 8); ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; ContentLayout.Parent = Scroll

local function createToggle(parent, text, settingName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 36)
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
    statusIndicator.Size = UDim2.new(0, 8, 0, 8)
    statusIndicator.Position = UDim2.new(1, -20, 0.5, -4)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    statusIndicator.Parent = btn
    local siCorner = Instance.new("UICorner"); siCorner.CornerRadius = UDim.new(0, 4); siCorner.Parent = statusIndicator

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
    end)
    updateVisuals()
end

local function createSlider(parent, text, min, max, default, isFloat, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -4, 0, 42)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. string.format(isFloat and "%.2f" or "%d", default)
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 6)
    bg.Position = UDim2.new(0, 0, 0, 24)
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bg.Parent = container
    local bgCorner = Instance.new("UICorner"); bgCorner.CornerRadius = UDim.new(0, 3); bgCorner.Parent = bg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
    fill.Parent = bg
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(0, 3); fillCorner.Parent = fill

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 12, 0, 12)
    btn.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = ""
    btn.Parent = bg
    local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 6); btnCorner.Parent = btn
    local btnStroke = Instance.new("UIStroke"); btnStroke.Color = Color3.fromRGB(0, 255, 170); btnStroke.Thickness = 1.5; btnStroke.Parent = btn

    local active = false
    bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local x = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            btn.Position = UDim2.new(x, -6, 0.5, -6)
            fill.Size = UDim2.new(x, 0, 1, 0)
            local val = min + (x * (max - min))
            if not isFloat then val = math.floor(val) end
            label.Text = text .. ": " .. string.format(isFloat and "%.2f" or "%d", val)
            callback(val)
        end
    end)
end

createToggle(Scroll, "Instant Snap (Safe Silent)", "SilentAimEnabled")
createToggle(Scroll, "On-Shot Flickbot", "FlickMode")
createToggle(Scroll, "Combat Aimbot", "AimbotEnabled")
createToggle(Scroll, "Wallcheck Bypass", "WallCheck")
createToggle(Scroll, "Lite Lines (WH)", "EspLines")
createToggle(Scroll, "Lite ESP Box", "EspBox")
createToggle(Scroll, "Lite Charms", "EspCharms")
createToggle(Scroll, "Smooth BunnyHop", "BHopEnabled")

createSlider(Scroll, "Snap FOV", 10, 900, Settings.SilentFOV, false, function(v) Settings.SilentFOV = v end)
createSlider(Scroll, "Aim FOV", 10, 900, Settings.AimFOV, false, function(v) Settings.AimFOV = v end)
createSlider(Scroll, "Flick FOV", 10, 900, Settings.FlickFOV, false, function(v) Settings.FlickFOV = v end)
createSlider(Scroll, "Flick Delay", 0.01, 1.00, Settings.FlickDelay, true, function(v) Settings.FlickDelay = v end)
createSlider(Scroll, "BHop Power", 1, 10, Settings.BHopPower, false, function(v) Settings.BHopPower = v end)

local FOV_Circle = Drawing.new("Circle")
local Silent_Circle = Drawing.new("Circle")
FOV_Circle.Visible = true; FOV_Circle.Thickness = 1; FOV_Circle.NumSides = 32; FOV_Circle.Filled = false
Silent_Circle.Visible = false; Silent_Circle.Thickness = 1; Silent_Circle.NumSides = 32; Silent_Circle.Filled = false; Silent_Circle.Color = Color3.fromRGB(0, 150, 255)

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

-- [[ БЕЗОПАСНЫЙ СНАП ПРИ КЛИКЕ / СТРЕЛЬБЕ ]] --
UserInputService.InputBegan:Connect(function(input, processed)
if processed then return end
if Settings.SilentAimEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
local target = getClosestPlayer(Settings.SilentFOV)
if target then
Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
end
end

if Settings.FlickMode and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
local target = getClosestPlayer(Settings.FlickFOV)
if target then
task.delay(Settings.FlickDelay, function()
Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
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

local lastUpdate = 0
RunService.RenderStepped:Connect(function()
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

FOV_Circle.Position = screenCenter
FOV_Circle.Radius = Settings.FlickMode and Settings.FlickFOV or Settings.AimFOV
FOV_Circle.Color = Settings.FlickMode and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 150)

if Settings.SilentAimEnabled then
Silent_Circle.Position = screenCenter
Silent_Circle.Radius = Settings.SilentFOV
Silent_Circle.Visible = true
else
Silent_Circle.Visible = false
end

handleSmoothBHop()

if Settings.AimbotEnabled and not Settings.FlickMode and not Settings.SilentAimEnabled then
local target = getClosestPlayer(Settings.AimFOV)
if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
end

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
