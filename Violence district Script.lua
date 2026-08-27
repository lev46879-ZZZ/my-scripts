-- ==============================================
--  [VIOLENCE DISTRICT] ULTIMATE HUB v2.0
--  45+ функций для мобильного Delta
-- ==============================================

-- [[ СЕРВИСЫ ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- [[ НАСТРОЙКИ ПО УМОЛЧАНИЮ ]] --
local Settings = {
    -- COMBAT
    Aimbot = false,
    AimbotFOV = 150,
    WallCheck = false,
    SilentAim = false,
    Triggerbot = false,
    AutoParry = false,
    GodMode = false,
    NoStun = false,
    NoSlowdown = false,
    AntiBlind = false,
    AntiKnock = false,
    AutoArm = false,
    InfiniteLunge = false,
    AutoKillerFarm = false,
    -- MOVEMENT
    BHop = false,
    BHopPower = 1,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    Speed = false,
    SpeedValue = 32,
    AutoMoonwalk = false,
    MoonwalkSway = false,
    VaultSpeed = false,
    -- ESP
    EspPlayer = false,
    EspKiller = false,
    EspSurvivor = false,
    EspGenerator = false,
    EspHook = false,
    EspPallet = false,
    EspVault = false,
    EspBlood = false,
    EspTracer = false,
    EspDistance = false,
    EspHealth = false,
    -- VISUALS
    Crosshair = false,
    FullBright = false,
    NoFog = false,
    KillerAlert = false,
    ChasedIndicator = false,
    -- MISC
    AutoFarm = false,
    AutoGenerator = false,
    TeleportGenerator = false,
    TeleportHook = false,
    TeleportPallet = false,
    InstantHeal = false,
    NoSkillcheck = false,
    ServerHop = false,
    AntiWiggle = false,
    InstantEscape = false,
    CancelGen = false,
    FlowstatePerk = false,
}

-- [[ ПЕРЕМЕННЫЕ ]] --
local ESP_Objects = {}
local defaultWalkSpeed = 0
local lastShotTime = 0
local triggerCooldown = 0.05
local screenCenter = Vector2.new()
local flyConnection = nil
local noclipConnection = nil
local fullBrightConnection = nil
local killerAlertConnection = nil
local bhopActive = false

-- ==============================================
--  СОЗДАНИЕ GUI (МЕНЮ)
-- ==============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Кнопка открытия меню
local MenuButton = Instance.new("ImageButton")
MenuButton.Size = UDim2.new(0, 60, 0, 60)
MenuButton.Position = UDim2.new(0.03, 0, 0.3, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
MenuButton.Image = "rbxassetid://6031091211"
MenuButton.ImageColor3 = Color3.fromRGB(0, 200, 255)
MenuButton.Parent = ScreenGui
Instance.new("UICorner", MenuButton).CornerRadius = UDim.new(1, 0)

-- Главное окно меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 520)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
Title.Text = "  ⚡ ULTIMATE HUB [VD v2.0]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

-- Вкладки
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
TabContainer.BackgroundTransparency = 0.5
TabContainer.Parent = MainFrame

local tabs = {"Combat", "Movement", "ESP", "Visuals", "Misc"}
local currentTab = "Combat"

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.2, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(180, 190, 210)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = TabContainer
    btn.MouseButton1Click:Connect(function()
        currentTab = tabName
        updateScroll()
    end)
end

-- Скроллинг-контейнер для функций
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -85)
Scroll.Position = UDim2.new(0, 5, 0, 75)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1200)
Scroll.ScrollBarThickness = 3
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ==============================================
--  ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ МЕНЮ
-- ==============================================

local function clearScroll()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child ~= UIList then
            child:Destroy()
        end
    end
end

-- Создание переключателя (Toggle)
local function createToggle(text, setting, parent)
    parent = parent or Scroll
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(20, 26, 42)
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.fromRGB(180, 190, 210)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 14, 0, 14)
    indicator.Position = UDim2.new(1, -22, 0.5, -7)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 7)

    btn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        local on = Settings[setting]
        indicator.BackgroundColor3 = on and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(255, 60, 60)
        btn.BackgroundColor3 = on and Color3.fromRGB(30, 50, 80) or Color3.fromRGB(20, 26, 42)
        btn.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 190, 210)
    end)
end

-- Создание ползунка (Slider)
local function createSlider(text, setting, min, max, default, callback, parent)
    parent = parent or Scroll
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 48)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(180, 190, 210)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -20, 0, 6)
    bg.Position = UDim2.new(0, 10, 0, 28)
    bg.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    bg.Parent = container
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local thumb = Instance.new("TextButton", bg)
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Text = ""
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)

    local active = false
    local function update(inputPos)
        local x = math.clamp((inputPos.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local val = min + (x * (max - min))
        val = math.round(val)
        fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        thumb.Position = UDim2.new((val - min) / (max - min), -8, 0.5, -8)
        label.Text = text .. ": " .. tostring(val)
        Settings[setting] = val
        if callback then callback(val) end
    end

    bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = true
            update(i.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position)
        end
    end)
end

-- Создание заголовка категории
local function createCategory(text, parent)
    parent = parent or Scroll
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 28)
    label.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
    label.Text = "  " .. text
    label.TextColor3 = Color3.fromRGB(0, 200, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = parent
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 4)
end

-- ==============================================
--  ОБНОВЛЕНИЕ МЕНЮ ПО ВКЛАДКАМ
-- ==============================================

function updateScroll()
    clearScroll()

    if currentTab == "Combat" then
        createCategory("⚔️ COMBAT", Scroll)
        createToggle("Aimbot", "Aimbot", Scroll)
        createSlider("Aim FOV", "AimbotFOV", 30, 300, 150, nil, Scroll)
        createToggle("Wall Check", "WallCheck", Scroll)
        createToggle("Silent Aim", "SilentAim", Scroll)
        createToggle("Triggerbot", "Triggerbot", Scroll)
        createToggle("Auto Parry", "AutoParry", Scroll)
        createToggle("God Mode", "GodMode", Scroll)
        createToggle("No Stun", "NoStun", Scroll)
        createToggle("No Slowdown", "NoSlowdown", Scroll)
        createToggle("Anti Blind", "AntiBlind", Scroll)
        createToggle("Anti Knock", "AntiKnock", Scroll)
        createToggle("Auto Arm", "AutoArm", Scroll)
        createToggle("Infinite Lunge", "InfiniteLunge", Scroll)
        createToggle("Auto Killer Farm", "AutoKillerFarm", Scroll)

    elseif currentTab == "Movement" then
        createCategory("🏃 MOVEMENT", Scroll)
        createToggle("Bunny Hop", "BHop", Scroll)
        createSlider("BHOP Power", "BHopPower", 1, 15, 1, nil, Scroll)
        createToggle("Fly", "Fly", Scroll)
        createSlider("Fly Speed", "FlySpeed", 10, 200, 50, nil, Scroll)
        createToggle("Noclip", "Noclip", Scroll)
        createToggle("Speed", "Speed", Scroll)
        createSlider("Speed Value", "SpeedValue", 16, 120, 32, nil, Scroll)
        createToggle("Auto Moonwalk", "AutoMoonwalk", Scroll)
        createToggle("Moonwalk Sway", "MoonwalkSway", Scroll)
        createToggle("Vault Speed", "VaultSpeed", Scroll)

    elseif currentTab == "ESP" then
        createCategory("👁️ ESP", Scroll)
        createToggle("ESP Player", "EspPlayer", Scroll)
        createToggle("ESP Killer", "EspKiller", Scroll)
        createToggle("ESP Survivor", "EspSurvivor", Scroll)
        createToggle("ESP Generator", "EspGenerator", Scroll)
        createToggle("ESP Hook", "EspHook", Scroll)
        createToggle("ESP Pallet", "EspPallet", Scroll)
        createToggle("ESP Vault", "EspVault", Scroll)
        createToggle("ESP Blood", "EspBlood", Scroll)
        createToggle("ESP Tracer", "EspTracer", Scroll)
        createToggle("ESP Distance", "EspDistance", Scroll)
        createToggle("ESP Health", "EspHealth", Scroll)

    elseif currentTab == "Visuals" then
        createCategory("🎨 VISUALS", Scroll)
        createToggle("Crosshair", "Crosshair", Scroll)
        createToggle("Full Bright", "FullBright", Scroll)
        createToggle("No Fog", "NoFog", Scroll)
        createToggle("Killer Alert", "KillerAlert", Scroll)
        createToggle("Chased Indicator", "ChasedIndicator", Scroll)

    elseif currentTab == "Misc" then
        createCategory("🔧 MISC", Scroll)
        createToggle("Auto Farm", "AutoFarm", Scroll)
        createToggle("Auto Generator", "AutoGenerator", Scroll)
        createToggle("Teleport to Generator", "TeleportGenerator", Scroll)
        createToggle("Teleport to Hook", "TeleportHook", Scroll)
        createToggle("Teleport to Pallet", "TeleportPallet", Scroll)
        createToggle("Instant Heal", "InstantHeal", Scroll)
        createToggle("No Skillcheck", "NoSkillcheck", Scroll)
        createToggle("Server Hop", "ServerHop", Scroll)
        createToggle("Anti Wiggle", "AntiWiggle", Scroll)
        createToggle("Instant Escape", "InstantEscape", Scroll)
        createToggle("Cancel Gen", "CancelGen", Scroll)
        createToggle("Flowstate Perk", "FlowstatePerk", Scroll)
    end
end

updateScroll()

-- Открытие/закрытие меню
MenuButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ==============================================
--  ОСНОВНАЯ ЛОГИКА (ВСЕ ФУНКЦИИ)
-- ==============================================

-- Получение всех объектов в игре
local function getGameObjects()
    local objects = {
        players = {},
        killers = {},
        survivors = {},
        generators = {},
        hooks = {},
        pallets = {},
        vaults = {},
        blood = {},
    }

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                table.insert(objects.players, player)
                -- Определяем роль (упрощённо)
                if player.Team and player.Team.Name == "Killer" then
                    table.insert(objects.killers, player)
                else
                    table.insert(objects.survivors, player)
                end
            end
        end
    end

    -- Поиск объектов в Workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("generator") then
                table.insert(objects.generators, obj)
            elseif name:find("hook") then
                table.insert(objects.hooks, obj)
            elseif name:find("pallet") then
                table.insert(objects.pallets, obj)
            elseif name:find("vault") then
                table.insert(objects.vaults, obj)
            elseif name:find("blood") then
                table.insert(objects.blood, obj)
            end
        end
    end

    return objects
end

-- Получение ближайшего врага
local function getClosestEnemy(fov)
    local bestTarget = nil
    local bestDist = fov + 1
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
            if hum and hum.Health > 0 and part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist <= fov and dist < bestDist then
                        bestDist = dist
                        bestTarget = part
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Проверка видимости (WallCheck)
local function isVisible(targetPart)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(origin, direction, ray)
    if result and result.Instance then
        return false
    end
    return true
end

-- Симуляция выстрела
local function shoot()
    pcall(function()
        if mouse1click then mouse1click() end
    end)
end

-- ==============================================
--  COMBAT ФУНКЦИИ
-- ==============================================

-- Aimbot
local function handleAimbot()
    if not Settings.Aimbot then return end
    local target = getClosestEnemy(Settings.AimbotFOV)
    if target and isVisible(target) then
        pcall(function()
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end)
    end
end

-- Triggerbot
local function handleTriggerbot()
    if not Settings.Triggerbot then return end
    if not Mouse or not Mouse.Target then return end
    pcall(function()
        local target = Mouse.Target
        local char = target.Parent
        while char and not char:IsA("Model") do char = char.Parent end
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local player = Players:GetPlayerFromCharacter(char)
        if hum and hum.Health > 0 and player and player ~= LocalPlayer then
            if player.Team ~= LocalPlayer.Team or player.Team == nil then
                if isVisible(target) then
                    local now = os.clock()
                    if now - lastShotTime >= triggerCooldown then
                        lastShotTime = now
                        shoot()
                    end
                end
            end
        end
    end)
end

-- Auto Parry
local function handleAutoParry()
    if not Settings.AutoParry then return end
    -- Имитация нажатия клавиши парирования (если есть)
    pcall(function()
        -- Поиск кнопки парирования в игре
        local parryButton = LocalPlayer.PlayerGui:FindFirstChild("ParryButton")
        if parryButton and parryButton:IsA("ImageButton") then
            parryButton:Fire()
        end
    end)
end

-- God Mode
local function handleGodMode()
    if not Settings.GodMode then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end
end

-- No Stun
local function handleNoStun()
    if not Settings.NoStun then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            -- Отключаем эффект оглушения
            hum.PlatformStand = false
        end
    end
end

-- No Slowdown
local function handleNoSlowdown()
    if not Settings.NoSlowdown then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = math.max(hum.WalkSpeed, 16)
        end
    end
end

-- Anti Blind
local function handleAntiBlind()
    if not Settings.AntiBlind then return end
    -- Отключаем эффект ослепления
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 1
    lighting.ClockTime = 12
end

-- Anti Knock
local function handleAntiKnock()
    if not Settings.AntiKnock then return end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        end
    end
end

-- Auto Arm
local function handleAutoArm()
    if not Settings.AutoArm then return end
    -- Автоматическое использование оружия
    pcall(function()
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end)
end

-- Infinite Lunge
local function handleInfiniteLunge()
    if not Settings.InfiniteLunge then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            hum.WalkSpeed = 50
        end
    end
end

-- Auto Killer Farm
local function handleAutoKillerFarm()
    if not Settings.AutoKillerFarm then return end
    -- Автоматическая атака ближайшего киллера
    local target = getClosestEnemy(300)
    if target then
        shoot()
    end
end

-- ==============================================
--  MOVEMENT ФУНКЦИИ
-- ==============================================

-- BHOP
local function handleBHop()
    if not Settings.BHop then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and defaultWalkSpeed > 0 and hum.WalkSpeed ~= defaultWalkSpeed then
                hum.WalkSpeed = defaultWalkSpeed
            end
        end
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    if defaultWalkSpeed == 0 then
        defaultWalkSpeed = hum.WalkSpeed
        if defaultWalkSpeed == 0 then defaultWalkSpeed = 16 end
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial == Enum.Material.Air then
        local add = (Settings.BHopPower - 1) * (20 / 14)
        local boost = defaultWalkSpeed + add
        if hum.WalkSpeed ~= boost then hum.WalkSpeed = boost end
    else
        if hum.WalkSpeed ~= defaultWalkSpeed then hum.WalkSpeed = defaultWalkSpeed end
    end
end

-- Fly
local function handleFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if Settings.Fly then
        if not flyConnection then
            flyConnection = RunService.RenderStepped:Connect(function()
                local speed = Settings.FlySpeed
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir + Vector3.new(0, -1, 0) end
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * speed
                end
                hrp.Velocity = moveDir
                if char:FindFirstChildOfClass("Humanoid") then
                    char:FindFirstChildOfClass("Humanoid").PlatformStand = true
                end
            end)
        end
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
            if char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").PlatformStand = false
            end
        end
    end
end

-- Noclip
local function handleNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    if Settings.Noclip then
        if not noclipConnection then
            noclipConnection = RunService.RenderStepped:Connect(function()
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Speed
local function handleSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Settings.Speed then
        hum.WalkSpeed = Settings.SpeedValue
    else
        if defaultWalkSpeed > 0 then
            hum.WalkSpeed = defaultWalkSpeed
        end
    end
end

-- Auto Moonwalk
local function handleAutoMoonwalk()
    if not Settings.AutoMoonwalk then return end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Имитация лунной походки
            local moveDir = hrp.CFrame.LookVector * -1
            hrp.Velocity = Vector3.new(moveDir.X * 10, hrp.Velocity.Y, moveDir.Z * 10)
        end
    end
end

-- Moonwalk Sway
local function handleMoonwalkSway()
    if not Settings.MoonwalkSway then return end
    -- Эффект покачивания при лунной походке
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local sway = math.sin(os.clock() * 3) * 0.5
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, sway)
        end
    end
end

-- Vault Speed
local function handleVaultSpeed()
    if not Settings.VaultSpeed then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = hum.WalkSpeed + 5
        end
    end
end

-- ==============================================
--  ESP ФУНКЦИИ (GUI)
-- ==============================================

local function createESP(player)
    if player == LocalPlayer then return end
    if ESP_Objects[player] then
        pcall(function()
            ESP_Objects[player].Box:Destroy()
            ESP_Objects[player].Name:Destroy()
            ESP_Objects[player].Health:Destroy()
            ESP_Objects[player].Tracer:Destroy()
        end)
        ESP_Objects[player] = nil
    end

    local box = Instance.new("Frame")
    box.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    box.BackgroundTransparency = 0.7
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(0, 200, 255)
    box.Visible = false
    box.ZIndex = 5
    box.Parent = ScreenGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.Text = player.Name
    nameLabel.Visible = false
    nameLabel.ZIndex = 5
    nameLabel.Parent = ScreenGui

    local healthLabel = Instance.new("TextLabel")
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.TextSize = 10
    healthLabel.Visible = false
    healthLabel.ZIndex = 5
    healthLabel.Parent = ScreenGui

    local tracer = Instance.new("Frame")
    tracer.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    tracer.BorderSizePixel = 0
    tracer.BackgroundTransparency = 0.3
    tracer.Visible = false
    tracer.ZIndex = 5
    tracer.Parent = ScreenGui

    ESP_Objects[player] = {Box = box, Name = nameLabel, Health = healthLabel, Tracer = tracer}
end

local function clearESP(player)
    if ESP_Objects[player] then
        pcall(function()
            ESP_Objects[player].Box:Destroy()
            ESP_Objects[player].Name:Destroy()
            ESP_Objects[player].Health:Destroy()
            ESP_Objects[player].Tracer:Destroy()
        end)
        ESP_Objects[player] = nil
    end
end

local function updateESP()
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    for player, data in pairs(ESP_Objects) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and hrp and hum.Health > 0 and player ~= LocalPlayer then
            local isEnemy = (player.Team ~= LocalPlayer.Team or player.Team == nil)
            local showESP = false

            if Settings.EspPlayer and isEnemy then showESP = true end
            if Settings.EspKiller and player.Team and player.Team.Name == "Killer" then showESP = true end
            if Settings.EspSurvivor and player.Team and player.Team.Name ~= "Killer" then showESP = true end

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local screenPos = Vector2.new(pos.X, pos.Y)

            -- Box
            if showESP and data.Box and onScreen then
                data.Box.Visible = true
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                local size = math.clamp(120 / (dist / 10 + 1), 20, 150)
                data.Box.Size = UDim2.new(0, size, 0, size)
                data.Box.Position = UDim2.new(0, screenPos.X - size/2, 0, screenPos.Y - size/2)
                data.Box.AnchorPoint = Vector2.new(0, 0)
                -- Цвет в зависимости от роли
                if player.Team and player.Team.Name == "Killer" then
                    data.Box.BorderColor3 = Color3.fromRGB(255, 0, 0)
                else
                    data.Box.BorderColor3 = Color3.fromRGB(0, 200, 255)
                end
            elseif data.Box then
                data.Box.Visible = false
            end

            -- Name
            if Settings.EspPlayer and showESP and data.Name and onScreen then
                data.Name.Visible = true
                data.Name.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - 30)
                data.Name.AnchorPoint = Vector2.new(0.5, 0)
            elseif data.Name then
                data.Name.Visible = false
            end

            -- Health
            if Settings.EspHealth and showESP and data.Health and onScreen then
                data.Health.Visible = true
                data.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                data.Health.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y + 20)
                data.Health.AnchorPoint = Vector2.new(0.5, 0)
                -- Цвет здоровья
                local healthPercent = hum.Health / hum.MaxHealth
                if healthPercent > 0.5 then
                    data.Health.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 0.25 then
                    data.Health.TextColor3 = Color3.fromRGB(255, 255, 0)
                else
                    data.Health.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            elseif data.Health then
                data.Health.Visible = false
            end

            -- Tracer
            if Settings.EspTracer and showESP and data.Tracer then
                data.Tracer.Visible = true
                local delta = screenPos - center
                local length = delta.Magnitude
                local angle = math.atan2(delta.Y, delta.X)
                data.Tracer.Position = UDim2.new(0, center.X, 0, center.Y)
                data.Tracer.Size = UDim2.new(0, length, 0, 1)
                data.Tracer.Rotation = math.deg(angle)
                data.Tracer.AnchorPoint = Vector2.new(0, 0.5)
            elseif data.Tracer then
                data.Tracer.Visible = false
            end
        else
            if data.Box then data.Box.Visible = false end
            if data.Name then data.Name.Visible = false end
            if data.Health then data.Health.Visible = false end
            if data.Tracer then data.Tracer.Visible = false end
        end
    end
end

-- Подписка на игроков
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
    player.CharacterRemoving:Connect(function()
        clearESP(player)
    end)
    if player.Character then createESP(player) end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(clearESP)
for _, p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end

-- ==============================================
--  VISUALS ФУНКЦИИ
-- ==============================================

-- Crosshair
local function handleCrosshair()
    if not Settings.Crosshair then return end
    -- Создаём прицел (если его нет)
    local crosshair = ScreenGui:FindFirstChild("Crosshair")
    if not crosshair then
        crosshair = Instance.new("Frame")
        crosshair.Name = "Crosshair"
        crosshair.Size = UDim2.new(0, 20, 0, 20)
        crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
        crosshair.BackgroundTransparency = 1
        crosshair.ZIndex = 10
        crosshair.Parent = ScreenGui

        local line1 = Instance.new("Frame")
        line1.Size = UDim2.new(0, 2, 0, 10)
        line1.Position = UDim2.new(0.5, -1, 0, 0)
        line1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line1.Parent = crosshair

        local line2 = Instance.new("Frame")
        line2.Size = UDim2.new(0, 2, 0, 10)
        line2.Position = UDim2.new(0.5, -1, 0, 10)
        line2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line2.Parent = crosshair

        local line3 = Instance.new("Frame")
        line3.Size = UDim2.new(0, 10, 0, 2)
        line3.Position = UDim2.new(0, 0, 0.5, -1)
        line3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line3.Parent = crosshair

        local line4 = Instance.new("Frame")
        line4.Size = UDim2.new(0, 10, 0, 2)
        line4.Position = UDim2.new(0, 10, 0.5, -1)
        line4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line4.Parent = crosshair
    end
end

-- Full Bright
local function handleFullBright()
    local lighting = game:GetService("Lighting")
    if Settings.FullBright then
        if not fullBrightConnection then
            fullBrightConnection = RunService.RenderStepped:Connect(function()
                lighting.Brightness = 1
                lighting.ClockTime = 12
                lighting.FogEnd = 1000
            end)
        end
    else
        if fullBrightConnection then
            fullBrightConnection:Disconnect()
            fullBrightConnection = nil
            lighting.Brightness = 0.5
            lighting.ClockTime = 6
        end
    end
end

-- No Fog
local function handleNoFog()
    if Settings.NoFog then
        game:GetService("Lighting").FogEnd = 1000
    else
        game:GetService("Lighting").FogEnd = 200
    end
end

-- Killer Alert
local function handleKillerAlert()
    if not Settings.KillerAlert then return end
    -- Поиск киллера и оповещение
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team and player.Team.Name == "Killer" then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 50 then
                        -- Оповещение (звук или визуал)
                        print("⚠️ KILLER NEARBY: " .. player.Name .. " (" .. math.floor(dist) .. " studs)")
                    end
                end
            end
        end
    end
end

-- Chased Indicator
local function handleChasedIndicator()
    if not Settings.ChasedIndicator then return end
    -- Индикатор погони
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Team and player.Team.Name == "Killer" then
                    local killerChar = player.Character
                    if killerChar then
                        local killerHrp = killerChar:FindFirstChild("HumanoidRootPart")
                        if killerHrp then
                            local dist = (killerHrp.Position - hrp.Position).Magnitude
                            if dist < 30 then
                                -- Показываем индикатор погони
                                local indicator = ScreenGui:FindFirstChild("ChasedIndicator")
                                if not indicator then
                                    indicator = Instance.new("TextLabel")
                                    indicator.Name = "ChasedIndicator"
                                    indicator.Size = UDim2.new(0, 200, 0, 30)
                                    indicator.Position = UDim2.new(0.5, -100, 0.8, 0)
                                    indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                                    indicator.BackgroundTransparency = 0.5
                                    indicator.Text = "⚠️ CHASED! ⚠️"
                                    indicator.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    indicator.Font = Enum.Font.GothamBold
                                    indicator.TextSize = 20
                                    indicator.ZIndex = 10
                                    indicator.Parent = ScreenGui
                                    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 8)
                                end
                                indicator.Visible = true
                                return
                            end
                        end
                    end
                end
            end
            -- Скрываем индикатор, если киллер далеко
            local indicator = ScreenGui:FindFirstChild("ChasedIndicator")
            if indicator then indicator.Visible = false end
        end
    end
end

-- ==============================================
--  MISC ФУНКЦИИ
-- ==============================================

-- Auto Farm
local function handleAutoFarm()
    if not Settings.AutoFarm then return end
    -- Автоматический фарм (упрощённо)
    local objects = getGameObjects()
    for _, generator in ipairs(objects.generators) do
        if generator and generator:FindFirstChild("HumanoidRootPart") then
            local hrp = generator:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < 20 then
                    -- Имитация взаимодействия с генератором
                    pcall(function()
                        local clickDetector = generator:FindFirstChildOfClass("ClickDetector")
                        if clickDetector then
                            clickDetector:Fire(LocalPlayer)
                        end
                    end)
                end
            end
        end
    end
end

-- Auto Generator
local function handleAutoGenerator()
    if not Settings.AutoGenerator then return end
    -- Автоматическое взаимодействие с генераторами
    local objects = getGameObjects()
    for _, generator in ipairs(objects.generators) do
        if generator and generator:FindFirstChild("HumanoidRootPart") then
            local hrp = generator:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < 15 then
                    pcall(function()
                        local clickDetector = generator:FindFirstChildOfClass("ClickDetector")
                        if clickDetector then
                            clickDetector:Fire(LocalPlayer)
                        end
                    end)
                end
            end
        end
    end
end

-- Teleport to Generator
local function handleTeleportGenerator()
    if not Settings.TeleportGenerator then return end
    local objects = getGameObjects()
    if #objects.generators > 0 then
        local generator = objects.generators[1]
        if generator and generator:FindFirstChild("HumanoidRootPart") then
            local hrp = generator:FindFirstChild("HumanoidRootPart")
            if hrp then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end

-- Teleport to Hook
local function handleTeleportHook()
    if not Settings.TeleportHook then return end
    local objects = getGameObjects()
    if #objects.hooks > 0 then
        local hook = objects.hooks[1]
        if hook and hook:FindFirstChild("HumanoidRootPart") then
            local hrp = hook:FindFirstChild("HumanoidRootPart")
            if hrp then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end

-- Teleport to Pallet
local function handleTeleportPallet()
    if not Settings.TeleportPallet then return end
    local objects = getGameObjects()
    if #objects.pallets > 0 then
        local pallet = objects.pallets[1]
        if pallet and pallet:FindFirstChild("HumanoidRootPart") then
            local hrp = pallet:FindFirstChild("HumanoidRootPart")
            if hrp then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end

-- Instant Heal
local function handleInstantHeal()
    if not Settings.InstantHeal then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
        end
    end
end

-- No Skillcheck
local function handleNoSkillcheck()
    if not Settings.NoSkillcheck then return end
    -- Пропуск проверки навыков
    pcall(function()
        local skillcheck = LocalPlayer.PlayerGui:FindFirstChild("Skillcheck")
        if skillcheck then
            skillcheck:Destroy()
        end
    end)
end

-- Server Hop
local function handleServerHop()
    if not Settings.ServerHop then return end
    -- Переход на другой сервер
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end)
end

-- Anti Wiggle
local function handleAntiWiggle()
    if not Settings.AntiWiggle then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end
end

-- Instant Escape
local function handleInstantEscape()
    if not Settings.InstantEscape then return end
    -- Мгновенный побег (телепорт в безопасное место)
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local spawns = workspace:FindFirstChild("Spawns") or workspace:FindFirstChild("SpawnLocations")
            if spawns then
                local spawn = spawns:GetChildren()[1]
                if spawn then
                    hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end
    end
end

-- Cancel Gen
local function handleCancelGen()
    if not Settings.CancelGen then return end
    -- Отмена взаимодействия с генератором
    pcall(function()
        local gen = LocalPlayer.Character:FindFirstChild("Generator")
        if gen then
            gen:Destroy()
        end
    end)
end

-- Flowstate Perk
local function handleFlowstatePerk()
    if not Settings.FlowstatePerk then return end
    -- Ускорение после взаимодействия
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = hum.WalkSpeed + 10
        end
    end
end

-- ==============================================
--  ГЛАВНЫЙ ЦИКЛ
-- ==============================================
RunService.RenderStepped:Connect(function()
    screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Combat
    handleAimbot()
    handleTriggerbot()
    handleAutoParry()
    handleGodMode()
    handleNoStun()
    handleNoSlowdown()
    handleAntiBlind()
    handleAntiKnock()
    handleAutoArm()
    handleInfiniteLunge()
    handleAutoKillerFarm()

    -- Movement
    handleBHop()
    handleFly()
    handleNoclip()
    handleSpeed()
    handleAutoMoonwalk()
    handleMoonwalkSway()
    handleVaultSpeed()

    -- ESP
    updateESP()

    -- Visuals
    handleCrosshair()
    handleFullBright()
    handleNoFog()
    handleKillerAlert()
    handleChasedIndicator()

    -- Misc
    handleAutoFarm()
    handleAutoGenerator()
    handleTeleportGenerator()
    handleTeleportHook()
    handleTeleportPallet()
    handleInstantHeal()
    handleNoSkillcheck()
    handleServerHop()
    handleAntiWiggle()
    handleInstantEscape()
    handleCancelGen()
    handleFlowstatePerk()
end)
