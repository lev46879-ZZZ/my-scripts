-- [[ СИСТЕМА НЕВИДИМОГО НАИМЕНОВАНИЯ ]] --
local MathRandom = math.random
local function generateRandomName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local name = ""
    for i = 1, MathRandom(10, 16) do
        local randIdx = MathRandom(1, #chars)
        name = name .. string.sub(chars, randIdx, randIdx)
    end
    return name
end

-- [[ СЕРВИСЫ ROBLOX ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
    EspBox = false,
    BHopEnabled = false,
    BHopPower = 1,
    ShowAimFOV = false,
    ShowFlickFOV = false,
    InstantReload = false,
    FPSUnlocker = false,
    PerfMonitor = false,
    TriggerbotEnabled = false,
    TriggerbotDelay = 0,
    TriggerbotHitchance = 100,
    LocalWings = false,
    LocalHat = false
}

-- [[ КЭШ И ПЕРЕМЕННЫЕ ХРАНЕНИЯ ]] --
local ESP_Cache = {}
local fpsTable = {}
local NormalSpeed = 16
local CurrentBHopSpeed = NormalSpeed

local lastTargetCharacter = nil
local lastShotTime = 0
local triggerShotCooldown = 0.12

local lastCombatUpdate = 0
local lastEspUpdate = 0
local lastMemoryClean = 0

local CurrentWingsPart = nil
local CurrentHatPart = nil

-- Создание скрытой точки-источника для 3D линий
local LineOriginPart = Instance.new("Part")
LineOriginPart.Name = generateRandomName()
LineOriginPart.Transparency = 1
LineOriginPart.CanCollide = false
LineOriginPart.Anchored = true
LineOriginPart.Size = Vector3.new(0.1, 0.1, 0.1)
LineOriginPart.Parent = workspace

-- [[ СКРЫТАЯ ЗАГРУЗКА ИНТЕРФЕЙСА БЕЗ ХУКОВ ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = generateRandomName()
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Защита: обходим Byfron, маскируя UI под легитную часть PlayerGui
local uiParent = LocalPlayer:WaitForChild("PlayerGui", 5)
if uiParent then
    ScreenGui.Parent = uiParent
else
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
end

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
ToggleButton.Name = generateRandomName()
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
ToggleButton.Text = "NL"
ToggleButton.TextColor3 = Color3.fromRGB(0, 162, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = ScreenGui

local TBCorner = Instance.new("UICorner"); TBCorner.CornerRadius = UDim.new(0, 25); TBCorner.Parent = ToggleButton
local TBBorder = Instance.new("UIStroke"); TBBorder.Color = Color3.fromRGB(0, 162, 255); TBBorder.Thickness = 2; TBBorder.Parent = ToggleButton
makeDraggable(ToggleButton)

-- Главное Меню
local MainMenu = Instance.new("Frame")
MainMenu.Name = generateRandomName()
MainMenu.Size = UDim2.new(0, 260, 0, 480)
MainMenu.Position = UDim2.new(0.5, -130, 0.5, -240)
MainMenu.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner"); MenuCorner.CornerRadius = UDim.new(0, 8); MenuCorner.Parent = MainMenu
local MenuBorder = Instance.new("UIStroke"); MenuBorder.Color = Color3.fromRGB(28, 32, 42); MenuBorder.Thickness = 1; MenuBorder.Parent = MainMenu
makeDraggable(MainMenu)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(14, 18, 24)
Title.Text = "  👑 NEVERLOSE.CC // NoLag v13"
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
Scroll.CanvasSize = UDim2.new(0, 0, 0, 960)
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
Scroll.Parent = MainMenu
local ContentLayout = Instance.new("UIListLayout"); ContentLayout.Padding = UDim.new(0, 6); ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; ContentLayout.Parent = Scroll

local PerfFrame = Instance.new("Frame")
PerfFrame.Name = generateRandomName()
PerfFrame.Size = UDim2.new(0, 140, 0, 75)
PerfFrame.Position = UDim2.new(1, -150, 0, 10)
PerfFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
PerfFrame.BackgroundTransparency = 0.1
PerfFrame.Visible = false
PerfFrame.Parent = ScreenGui

local PerfCorner = Instance.new("UICorner"); PerfCorner.CornerRadius = UDim.new(0, 5); PerfCorner.Parent = PerfFrame
local PerfStroke = Instance.new("UIStroke"); PerfStroke.Color = Color3.fromRGB(0, 162, 255); PerfStroke.Thickness = 1; PerfStroke.Parent = PerfFrame

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

-- [[ КОНСТРУКТОРЫ ИНТЕРФЕЙСА ]] --
local function createToggle(parent, text, settingName, extraCallback)
    local btn = Instance.new("TextButton")
    btn.Name = generateRandomName()
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
            btnBorder.Color = Color3.fromRGB(0, 162, 255)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
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
    container.Name = generateRandomName()
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
    fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    fill.Parent = bg
    local fillCorner = Instance.new("UICorner"); fillCorner.CornerRadius = UDim.new(0, 2); fillCorner.Parent = fill

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 10, 0, 10)
btn.Position = UDim2.new((default - min) / (max - min), -5, 0.5, -5)
btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
btn.Text = ""
btn.Parent = bg

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

-- Сборка меню
createToggle(Scroll, "On-Shot Flickbot", "FlickMode")
createToggle(Scroll, "Combat Aimbot", "AimbotEnabled")
createToggle(Scroll, "Neverlose Triggerbot", "TriggerbotEnabled")
createSlider(Scroll, "Trigger Delay (ms)", 0, 500, Settings.TriggerbotDelay * 1000, false, function(v) Settings.TriggerbotDelay = v / 1000 end)
createSlider(Scroll, "Trigger Hitchance", 10, 100, Settings.TriggerbotHitchance, false, function(v) Settings.TriggerbotHitchance = v end)
createToggle(Scroll, "Aim/Flick Wallcheck", "WallCheck")
createToggle(Scroll, "Show Flick FOV (Red)", "ShowFlickFOV")
createToggle(Scroll, "Show Aim FOV (Blue)", "ShowAimFOV")

createToggle(Scroll, "Engine ESP Lines", "EspLines", function(state)
for _, visual in pairs(ESP_Cache) do if visual.Beam then visual.Beam.Enabled = state end end
end)
createToggle(Scroll, "Engine ESP Box", "EspBox", function(state)
for _, visual in pairs(ESP_Cache) do if visual.Box then visual.Box.Visible = state end end
end)

createToggle(Scroll, "Local Angel Wings (Back)", "LocalWings", function(s) if not s and CurrentWingsPart then CurrentWingsPart:Destroy(); CurrentWingsPart = nil end end)
createToggle(Scroll, "Local Golden Halo (Head)", "LocalHat", function(s) if not s and CurrentHatPart then CurrentHatPart:Destroy(); CurrentHatPart = nil end end)

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
Aim_Circle = Drawing.new("Circle"); Aim_Circle.Visible = false; Aim_Circle.Color = Color3.fromRGB(0, 162, 255); Aim_Circle.Thickness = 1
Flick_Circle = Drawing.new("Circle"); Flick_Circle.Visible = false; Flick_Circle.Color = Color3.fromRGB(255, 50, 50); Flick_Circle.Thickness = 1
end)

-- [[ КЕШИРОВАННАЯ ОПТИМИЗИРОВАННАЯ ПРОВЕРКА СТЕН ]] --
local function checkWallVisibility(targetPart, enemyCharacter, forceCheck)
if not Settings.WallCheck and not forceCheck then return true end
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

-- Безопасный кликер
local function secureDeltaClick()
pcall(function()
if mouse1click then
task.wait(MathRandom(1, 3) / 1000)
mouse1click()
end
end)
end

-- Поиск цели
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
if checkWallVisibility(targetPart, player.Character, false) then
minDistance = distance; closestTarget = targetPart
end
end
end
end
end
end
return closestTarget
end

local function checkTriggerTarget(instance)
if not instance then return nil, nil, nil end
local char = instance.Parent
if char:IsA("Accessory") or char:IsA("Tool") then char = char.Parent end

local humanoid = char:FindFirstChildOfClass("Humanoid")
local player = Players:GetPlayerFromCharacter(char)

if humanoid and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead and player and player ~= LocalPlayer then
if player.Team ~= LocalPlayer.Team or player.Team == nil then
return char, instance, humanoid
end
end
return nil, nil, nil
end

-- [[ ЧИСТЫЙ ТРИГГЕРБОТ ]] --
local function runTriggerbot()
if not Settings.TriggerbotEnabled then return end

local targetCharacter = nil
local detectedPart = nil
local enemyHumanoid = nil

if Mouse.Target then
targetCharacter, detectedPart, enemyHumanoid = checkTriggerTarget(Mouse.Target)
end

if targetCharacter and detectedPart and enemyHumanoid then
if not checkWallVisibility(detectedPart, targetCharacter, true) then
lastTargetCharacter = nil
return
end

local currentTime = os.clock()

if lastTargetCharacter ~= targetCharacter then
lastTargetCharacter = targetCharacter
lastShotTime = 0
end

if enemyHumanoid.Health > 0 and (currentTime - lastShotTime >= triggerShotCooldown) then
if MathRandom(1, 100) <= Settings.TriggerbotHitchance then
lastShotTime = currentTime

if Settings.TriggerbotDelay > 0 then
task.delay(Settings.TriggerbotDelay, function()
if Mouse.Target and Mouse.Target:IsDescendantOf(targetCharacter) then
if checkWallVisibility(Mouse.Target, targetCharacter, true) and enemyHumanoid.Health > 0 then
secureDeltaClick()
end
end
end)
else
secureDeltaClick()
end
end
end
else
lastTargetCharacter = nil
end
end

-- [[ СТАБИЛЬНАЯ КОСМЕТИКА ]] --
local function applyLocalCosmetics()
local char = LocalPlayer.Character
if not char then return end

if CurrentWingsPart then CurrentWingsPart:Destroy(); CurrentWingsPart = nil end
if CurrentHatPart then CurrentHatPart:Destroy(); CurrentHatPart = nil end

local torso = char:WaitForChild("UpperTorso", 2) or char:WaitForChild("Torso", 2)
local head = char:WaitForChild("Head", 2)
if not torso or not head then return end

if Settings.LocalWings then
CurrentWingsPart = Instance.new("Part")
CurrentWingsPart.Name = generateRandomName()
CurrentWingsPart.CanCollide = false
CurrentWingsPart.Massless = true
CurrentWingsPart.Size = Vector3.new(0.1, 0.1, 0.1)
CurrentWingsPart.Transparency = 1
CurrentWingsPart.Parent = char

local mesh = Instance.new("SpecialMesh")
mesh.MeshId = "rbxassetid://15535311025"
mesh.TextureId = "rbxassetid://15535310860"
mesh.Scale = Vector3.new(4, 4, 4)
mesh.Parent = CurrentWingsPart

local weld = Instance.new("Weld")
weld.Part0 = CurrentWingsPart; weld.Part1 = torso
weld.C0 = CFrame.new(0, -0.5, 1.1) * CFrame.Angles(0, math.rad(180), 0)
weld.Parent = CurrentWingsPart
end

if Settings.LocalHat then
CurrentHatPart = Instance.new("Part")
CurrentHatPart.Name = generateRandomName()
CurrentHatPart.CanCollide = false
CurrentHatPart.Massless = true
CurrentHatPart.Size = Vector3.new(0.1, 0.1, 0.1)
CurrentHatPart.Transparency = 1
CurrentHatPart.Parent = char

local mesh = Instance.new("SpecialMesh")
mesh.MeshId = "rbxassetid://11413813978"
mesh.TextureId = "rbxassetid://11413812836"
mesh.Scale = Vector3.new(2.5, 2.5, 2.5)
mesh.Parent = CurrentHatPart

local weld = Instance.new("Weld")
weld.Part0 = CurrentHatPart; weld.Part1 = head
weld.C0 = CFrame.new(0, -1.2, 0)
weld.Parent = CurrentHatPart
end
end

LocalPlayer.CharacterAdded:Connect(function()
task.wait(1)
if Settings.LocalWings or Settings.LocalHat then applyLocalCosmetics() end
end)

Scroll.ChildAdded:Connect(function()
task.wait(0.1)
applyLocalCosmetics()
end)

-- Flick-Snap
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

-- [[ СТАБИЛЬНЫЙ BEAM ESP ]] --
local function createEngineESP(player)
if ESP_Cache[player] then return end
local function setupVisuals(character)
local hrp = character:WaitForChild("HumanoidRootPart", 5)
if not hrp then return end

local targetAttachment = Instance.new("Attachment")
targetAttachment.Name = generateRandomName()
targetAttachment.Parent = hrp

local localAttachment = Instance.new("Attachment")
localAttachment.Name = generateRandomName()
localAttachment.Parent = LineOriginPart

local beam = Instance.new("Beam")
beam.Name = generateRandomName()
beam.Attachment0 = localAttachment
beam.Attachment1 = targetAttachment
beam.Width0 = 0.04; beam.Width1 = 0.04
beam.Color = ColorSequence.new(Color3.fromRGB(0, 162, 255))
beam.FaceCamera = true; beam.LightEmission = 1; beam.LightInfluence = 0
beam.Enabled = Settings.EspLines
beam.Parent = hrp

local boxAdornment = Instance.new("BoxHandleAdornment")
boxAdornment.Name = generateRandomName()
boxAdornment.Size = Vector3.new(4, 5.5, 3.5)
boxAdornment.Color3 = Color3.fromRGB(0, 162, 255)
boxAdornment.Transparency = 0.75; boxAdornment.AlwaysOnTop = true; boxAdornment.ZIndex = 5
boxAdornment.Adornee = hrp; boxAdornment.Visible = Settings.EspBox
boxAdornment.Parent = ScreenGui

ESP_Cache[player] = {Beam = beam, AttL = localAttachment, AttT = targetAttachment, Box = boxAdornment}
end
if player.Character then task.spawn(setupVisuals, player.Character) end
player.CharacterAdded:Connect(function(char) task.spawn(setupVisuals, char) end)
end

local function removeEngineESP(player)
if ESP_Cache[player] then
pcall(function()
if ESP_Cache[player].Beam then ESP_Cache[player].Beam:Destroy() end
if ESP_Cache[player].AttL then ESP_Cache[player].AttL:Destroy() end
if ESP_Cache[player].AttT then ESP_Cache[player].AttT:Destroy() end
if ESP_Cache[player].Box then ESP_Cache[player].Box:Destroy() end
end)
ESP_Cache[player] = nil
end
end

local function handleInstantReload()
if not Settings.InstantReload then return end
local char = LocalPlayer.Character
local backpack = LocalPlayer:FindFirstChild("Backpack")
local function clearDelay(tool)
if tool:IsA("Tool") then
for _, obj in ipairs(tool:GetDescendants()) do
if obj:IsA("NumberValue") or obj:IsA("IntValue") then
if obj.Name:lower():find("reload") or obj.Name:lower():find("delay") then obj.Value = 0 end
end
end
end
end
if char then for _, t in ipairs(char:GetChildren()) do clearDelay(t) end end
if backpack then for _, t in ipairs(backpack:GetChildren()) do clearDelay(t) end end
end

Players.PlayerAdded:Connect(createEngineESP)
Players.PlayerRemoving:Connect(removeEngineESP)
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createEngineESP(p) end end

-- [[ ГЛАВНЫЙ ОПТИМИЗИРОВАННЫЙ ЦИКЛ РЕНДЕРА ]] --
RunService.RenderStepped:Connect(function()
local nowClock = os.clock()

if LineOriginPart then LineOriginPart.CFrame = Camera.CFrame * CFrame.new(0, -2, -2) end

local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
pcall(function()
if Settings.ShowAimFOV and Aim_Circle then Aim_Circle.Position = screenCenter; Aim_Circle.Radius = Settings.AimFOV; Aim_Circle.Visible = true else Aim_Circle.Visible = false end
if Settings.ShowFlickFOV and Flick_Circle then Flick_Circle.Position = screenCenter; Flick_Circle.Radius = Settings.FlickFOV; Flick_Circle.Visible = true else Flick_Circle.Visible = false end
end)

-- ОГРАНИЧИТЕЛЬ (30 FPS): Боевой блок
if nowClock - lastCombatUpdate >= 0.033 then
lastCombatUpdate = nowClock

if Settings.AimbotEnabled and not Settings.FlickMode then
local target = getClosestPlayer(Settings.AimFOV)
if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
end

runTriggerbot()
handleInstantReload()
end

-- ОГРАНИЧИТЕЛЬ (15 FPS): Обновление ESP
if nowClock - lastEspUpdate >= 0.066 then
lastEspUpdate = nowClock

for player, visual in pairs(ESP_Cache) do
local char = player.Character
local humanoid = char and char:FindFirstChildOfClass("Humanoid")
if char and humanoid and humanoid.Health > 0 then
local isEnemy = (player.Team ~= LocalPlayer.Team or player.Team == nil)
if visual.Beam then visual.Beam.Enabled = Settings.EspLines and isEnemy end
if visual.Box then visual.Box.Visible = Settings.EspBox and isEnemy end
else
if visual.Beam then visual.Beam.Enabled = false end
if visual.Box then visual.Box.Visible = false end
end
end
end

-- ОГРАНИЧИТЕЛЬ (Каждые 3 секунды): Глубокая очистка кэша памяти
if nowClock - lastMemoryClean >= 3.0 then
lastMemoryClean = nowClock
pcall(function() collectgarbage("step", 100) end)
end

-- Оверлей производительности
if Settings.PerfMonitor then
table.insert(fpsTable, nowClock)
while #fpsTable > 0 and fpsTable < nowClock - 1 do table.remove(fpsTable, 1) end
local curFps = #fpsTable
local curPing = 0
pcall(function() curPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
local curMem = string.format("%.1f", Stats:GetTotalMemoryUsageMb())
PerfText.Text = string.format("⚡ PERF MONITOR\n\nFPS: %d\nPING: %d ms\nMEM: %s MB", curFps, curPing, curMem)
end
end)
