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
    EspBox = false,
    BHopEnabled = false,
    BHopPower = 5,
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

-- [[ КЭШ И СЛУЖЕБНЫЕ ПЕРЕМЕННЫЕ ]] --
local ESP_Cache = {}
local fpsTable = {}
local lastTargetCharacter = nil
local lastShotTime = 0
local triggerShotCooldown = 0.05
local CurrentWingsPart = nil
local CurrentHatPart = nil

-- Создание стабильного источника для ESP линий (пересоздается при удалении)
local LineOriginPart = workspace:FindFirstChild("NL_Stealth_Origin")
if not LineOriginPart then
    LineOriginPart = Instance.new("Part")
    LineOriginPart.Name = "NL_Stealth_Origin"
    LineOriginPart.Transparency = 1
    LineOriginPart.CanCollide = false
    LineOriginPart.Anchored = true
    LineOriginPart.Size = Vector3.new(0.1, 0.1, 0.1)
    LineOriginPart.Parent = workspace
end

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
            TweenService:Create(gui, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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

-- [[ ЛЮКСОВЫЙ ИНТЕРФЕЙС NEVERLOSE ]] --
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

-- Шапка меню с градиентом
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
Title.Text = "   NEVERLOSE.CC // Premium Stealth v15"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = MainMenu

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 12)

ToggleButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
    local targetTrans = MainMenu.Visible and 0 or 1
end)

-- Скролл-контейнер для элементов
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -50)
Scroll.Position = UDim2.new(0, 8, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1100)
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

-- [[ КОНСТРУКТОРЫ ЭЛЕМЕНТОВ С ПЛАВНОЙ АНИМАЦИЕЙ ]] --
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
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = targetBg, TextColor3 = targetText}):Play()
            TweenService:Create(btnBorder, TweenInfo.new(0.15), {Color = targetBorder}):Play()
            TweenService:Create(indicator, TweenInfo.new(0.15), {BackgroundColor3 = targetInd}):Play()
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

local function createSlider(parent, text, min, max, default, isFloat, callback)
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
sliderBtn.Position = UDim2.new(x, -6, 0.5, -6)
fill.Size = UDim2.new(x, 0, 1, 0)
local val = min + (x * (max - min))
if not isFloat then val = math.floor(val) end
label.Text = " " .. text .. ": " .. string.format(isFloat and "%.2f" or "%d", val)
pcall(callback, val)
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

-- [[ НАПОЛНЕНИЕ МЕНЮ ФУНКЦИЯМИ ]] --
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

createToggle(Scroll, "Legit BunnyHop", "BHopEnabled")
createToggle(Scroll, "Instant Reload (Universal)", "InstantReload")
createToggle(Scroll, "FPS Unlocker (999 FPS)", "FPSUnlocker", function(state) if setfpscap then setfpscap(state and 999 or 60) end end)
createToggle(Scroll, "Performance Monitor", "PerfMonitor", function(state) PerfFrame.Visible = state end)

createSlider(Scroll, "Aim FOV", 10, 900, Settings.AimFOV, false, function(v) Settings.AimFOV = v end)
createSlider(Scroll, "Flick FOV", 10, 900, Settings.FlickFOV, false, function(v) Settings.FlickFOV = v end)
createSlider(Scroll, "Flick Delay", 0.01, 1.00, Settings.FlickDelay, true, function(v) Settings.FlickDelay = v end)
createSlider(Scroll, "BHop Power Boost", 1, 50, Settings.BHopPower, false, function(v) Settings.BHopPower = v end)

-- Кольца FOV
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

-- Безопасный эмулятор клика под Delta
local function secureDeltaClick()
pcall(function()
if mouse1click then
task.wait(MathRandom(1, 3) / 1000)
mouse1click()
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

-- [[ ФУНКЦИОНАЛ: МГНОВЕННАЯ ПЕРЕЗАРЯДКА (ПЕРЕПИСАНА С НУЛЯ) ]] --
local function handleInstantReload()
if not Settings.InstantReload then return end
pcall(function()
local char = LocalPlayer.Character
local items = {}
if char then for _, v in ipairs(char:GetChildren()) do table.insert(items, v) end end
if LocalPlayer:FindFirstChild("Backpack") then
for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do table.insert(items, v) end
end

for _, tool in ipairs(items) do
if tool:IsA("Tool") then
-- Полностью удаляем задержки между выстрелами и анимации перезарядки в конфигурациях оружия
for _, obj in ipairs(tool:GetDescendants()) do
if obj:IsA("NumberValue") or obj:IsA("IntValue") then
local n = obj.Name:lower()
if n:find("reload") or n:find("delay") or n:find("cooldown") or n:find("recovery") then
-- Ставим минимальное рабочее значение, чтобы скрипт оружия не ломался в 0
obj.Value = 0.001
elseif n:find("ammo") or n:find("clip") or n:find("mag") then
if obj.Value < 50 then obj.Value = 999 end -- Бесконечные патроны, если поддерживается игрой
end
end
end
end
end
end)
end

-- [[ ФУНКЦИОНАЛ: ПРАВИЛЬНЫЙ BUNNYHOP ]] --
local function handleBunnyHop()
if not Settings.BHopEnabled then return end
pcall(function()
local char = LocalPlayer.Character
local humanoid = char and char:FindFirstChildOfClass("Humanoid")
local hrp = char and char:FindFirstChild("HumanoidRootPart")

if humanoid and hrp and humanoid.Health > 0 then
-- Проверяем, держит ли игрок зажатым пробел и находится ли на земле
if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
if humanoid.FloorMaterial ~= Enum.Material.Air then
hrp.Velocity = Vector3.new(hrp.Velocity.X, 35 + Settings.BHopPower, hrp.Velocity.Z)
-- Дополнительный пинок вперед по направлению движения игрока
if humanoid.MoveDirection.Magnitude > 0 then
hrp.Velocity = hrp.Velocity + (humanoid.MoveDirection * Settings.BHopPower)
end
end
end
end
end)
end

-- [[ ФУНКЦИОНАЛ: СТАБИЛЬНАЯ КОСМЕТИКА ]] --
local function applyLocalCosmetics()
local char = LocalPlayer.Character
if not char then return end
pcall(function()
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

local mesh = Instance.new("SpecialMesh", CurrentWingsPart)
mesh.MeshId = "rbxassetid://15535311025"
mesh.TextureId = "rbxassetid://15535310860"
mesh.Scale = Vector3.new(4, 4, 4)

local weld = Instance.new("Weld", CurrentWingsPart)
weld.Part0 = CurrentWingsPart; weld.Part1 = torso
weld.C0 = CFrame.new(0, -0.5, 1.1) * CFrame.Angles(0, math.rad(180), 0)
end

if Settings.LocalHat then
CurrentHatPart = Instance.new("Part")
CurrentHatPart.Name = generateRandomName()
CurrentHatPart.CanCollide = false
CurrentHatPart.Massless = true
CurrentHatPart.Size = Vector3.new(0.1, 0.1, 0.1)
CurrentHatPart.Transparency = 1
CurrentHatPart.Parent = char

local mesh = Instance.new("SpecialMesh", CurrentHatPart)
mesh.MeshId = "rbxassetid://11413813978"
mesh.TextureId = "rbxassetid://11413812836"
mesh.Scale = Vector3.new(2.5, 2.5, 2.5)

local weld = Instance.new("Weld", CurrentHatPart)
weld.Part0 = CurrentHatPart; weld.Part1 = head
weld.C0 = CFrame.new(0, -1.2, 0)
end
end)
end

LocalPlayer.CharacterAdded:Connect(function()
task.wait(1.5)
applyLocalCosmetics()
end)

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

-- [[ ПОЛНОСТЬЮ ПЕРЕРАБОТАННЫЙ ENGINE ESP ]] --
local function createEngineESP(player)
if player == LocalPlayer then return end

local function setupVisuals(character)
pcall(function()
-- Сначала очищаем старый ESP если он был
if ESP_Cache[player] then
pcall(function() ESP_Cache[player].Box:Destroy() end)
pcall(function() ESP_Cache[player].Beam:Destroy() end)
end

local hrp = character:WaitForChild("HumanoidRootPart", 10)
if not hrp then return end

local targetAttachment = Instance.new("Attachment", hrp)
local localAttachment = Instance.new("Attachment", LineOriginPart)

local beam = Instance.new("Beam", hrp)
beam.Attachment0 = localAttachment
beam.Attachment1 = targetAttachment
beam.Width0 = 0.05; beam.Width1 = 0.05
beam.Color = ColorSequence.new(Color3.fromRGB(0, 162, 255))
beam.FaceCamera = true
beam.Enabled = Settings.EspLines

local boxAdornment = Instance.new("BoxHandleAdornment")
boxAdornment.Size = Vector3.new(3.8, 5.2, 2.5)
boxAdornment.Color3 = Color3.fromRGB(0, 162, 255)
boxAdornment.Transparency = 0.7
boxAdornment.AlwaysOnTop = true
boxAdornment.ZIndex = 10
boxAdornment.Adornee = hrp
boxAdornment.Parent = ScreenGui
boxAdornment.Visible = Settings.EspBox

ESP_Cache[player] = {Beam = beam, Box = boxAdornment, AttL = localAttachment, AttT = targetAttachment}
end)
end

if player.Character then setupVisuals(player.Character) end
player.CharacterAdded:Connect(setupVisuals)
end

local function removeEngineESP(player)
if ESP_Cache[player] then
pcall(function() ESP_Cache[player].Beam:Destroy() end)
pcall(function() ESP_Cache[player].Box:Destroy() end)
pcall(function() ESP_Cache[player].AttL:Destroy() end)
pcall(function() ESP_Cache[player].AttT:Destroy() end)
ESP_Cache[player] = nil
end
end

Players.PlayerAdded:Connect(createEngineESP)
Players.PlayerRemoving:Connect(removeEngineESP)
for _, p in ipairs(Players:GetPlayers()) do createEngineESP(p) end

-- [[ ГЛАВНЫЙ БЕСКОНЕЧНЫЙ ЦИКЛ (МАКСИМАЛЬНЫЙ ПРИОРИТЕТ) ]] --
RunService.RenderStepped:Connect(function()
local nowClock = os.clock()

-- Центрируем скрытую точку линий ESP перед камерой
if LineOriginPart then LineOriginPart.CFrame = Camera.CFrame * CFrame.new(0, -3, -2) end

-- Отрисовка FOV колец кругов
local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
pcall(function()
if Settings.ShowAimFOV and Aim_Circle then
Aim_Circle.Position = screenCenter; Aim_Circle.Radius = Settings.AimFOV; Aim_Circle.Visible = true
else Aim_Circle.Visible = false end

if Settings.ShowFlickFOV and Flick_Circle then
Flick_Circle.Position = screenCenter; Flick_Circle.Radius = Settings.FlickFOV; Flick_Circle.Visible = true
else Flick_Circle.Visible = false end
end)

-- ВЫПОЛНЕНИЕ ВСЕХ БОЕВЫХ И ДВИГАТЕЛЬНЫХ ФУНКЦИЙ НА КАЖДОМ КАДРЕ (БЕЗ ОГРАНИЧЕНИЙ)
if Settings.AimbotEnabled and not Settings.FlickMode then
local target = getClosestPlayer(Settings.AimFOV)
if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
end

runTriggerbot()
handleInstantReload()
handleBunnyHop()

-- Динамическое обновление состояний ESP для живых врагов
for player, visual in pairs(ESP_Cache) do
pcall(function()
local char = player.Character
local humanoid = char and char:FindFirstChildOfClass("Humanoid")
if char and humanoid and humanoid.Health > 0 and player.Character:FindFirstChild("HumanoidRootPart") then
local isEnemy = (player.Team ~= LocalPlayer.Team or player.Team == nil)
visual.Beam.Enabled = Settings.EspLines and isEnemy
visual.Box.Visible = Settings.EspBox and isEnemy
visual.Box.Adornee = player.Character.HumanoidRootPart
else
visual.Beam.Enabled = false
visual.Box.Visible = false
end
end)
end

-- Оверлей производительности
if Settings.PerfMonitor then
table.insert(fpsTable, nowClock)
while #fpsTable > 0 and fpsTable[1] < nowClock - 1 do table.remove(fpsTable, 1) end
local curFps = #fpsTable
local curPing = 0
pcall(function() curPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
local curMem = string.format("%.1f", Stats:GetTotalMemoryUsageMb())
PerfText.Text = string.format("⚡ PERFORMANCE\n\nFPS: %d\nPING: %d ms\nMEM: %s MB", curFps, curPing, curMem)
end
end)
