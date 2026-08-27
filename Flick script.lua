-- ==============================================
--  FLICK ULTIMATE | NEVERLOSE STYLE
--  Оптимизирован для Delta Mobile
--  Функций: 40+
-- ==============================================

-- [[ СЕРВИСЫ ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- [[ НАСТРОЙКИ ]] --
local Settings = {
    -- Aimbot
    Aimbot = false,
    AimbotFOV = 150,
    AimbotSmooth = 0.1,
    WallCheck = false,
    SilentAim = false,
    Triggerbot = false,
    Flickbot = false,
    FlickFOV = 200,
    AutoShoot = false,
    NoRecoil = false,
    -- Visuals
    ESP_Box = false,
    ESP_Line = false,
    ESP_Name = false,
    ESP_Health = false,
    ESP_Distance = false,
    ESP_Tracer = false,
    Crosshair = false,
    FullBright = false,
    NoFog = false,
    Chams = false,
    -- Movement
    BHop = false,
    BHopPower = 1,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    Speed = false,
    SpeedValue = 32,
    JumpPower = false,
    JumpPowerValue = 50,
    -- Misc
    InfiniteAmmo = false,
    NoReload = false,
    InstantHeal = false,
    AntiKnock = false,
    NoSlowdown = false,
}

-- [[ ПЕРЕМЕННЫЕ ]] --
local ESP_Objects = {}
local defaultWalkSpeed = 0
local defaultJumpPower = 50
local lastShotTime = 0
local triggerCooldown = 0.05
local screenCenter = Vector2.new()
local flyConnection = nil
local noclipConnection = nil
local fullBrightConnection = nil

-- ==============================================
--  GUI (NEVERLOSE STYLE)
-- ==============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Neverlose"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Кнопка открытия
local MenuButton = Instance.new("ImageButton")
MenuButton.Size = UDim2.new(0, 55, 0, 55)
MenuButton.Position = UDim2.new(0.02, 0, 0.3, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
MenuButton.Image = "rbxassetid://6031091211"
MenuButton.ImageColor3 = Color3.fromRGB(0, 170, 255)
MenuButton.Parent = ScreenGui
Instance.new("UICorner", MenuButton).CornerRadius = UDim.new(1, 0)

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 480)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
Title.Text = "  NEVERLOSE // FLICK"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

-- Вкладки
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 30)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
TabContainer.Parent = MainFrame

local tabs = {"Aimbot", "Visuals", "Movement", "Misc"}
local currentTab = "Aimbot"

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(150, 160, 180)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = TabContainer
    btn.MouseButton1Click:Connect(function()
        currentTab = tabName
        updateScroll()
    end)
end

-- Скролл
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -80)
Scroll.Position = UDim2.new(0, 5, 0, 70)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
Scroll.ScrollBarThickness = 3
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Функции элементов
local function clearScroll()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child ~= UIList then child:Destroy() end
    end
end

local function createToggle(text, setting, parent)
    parent = parent or Scroll
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.fromRGB(180, 190, 210)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 14, 0, 14)
    indicator.Position = UDim2.new(1, -22, 0.5, -7)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 7)

    btn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        local on = Settings[setting]
        indicator.BackgroundColor3 = on and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(255, 60, 60)
        btn.BackgroundColor3 = on and Color3.fromRGB(25, 40, 60) or Color3.fromRGB(18, 22, 34)
        btn.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 190, 210)
    end)
end

local function createSlider(text, setting, min, max, default, callback, parent)
    parent = parent or Scroll
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 46)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(180, 190, 210)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -20, 0, 4)
    bg.Position = UDim2.new(0, 10, 0, 26)
    bg.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    bg.Parent = container
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 2)

    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)

    local thumb = Instance.new("TextButton", bg)
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Text = ""
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 7)

    local active = false
    local function update(inputPos)
        local x = math.clamp((inputPos.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local val = min + (x * (max - min))
        val = math.round(val)
        fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        thumb.Position = UDim2.new((val - min) / (max - min), -7, 0.5, -7)
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

local function createCategory(text, parent)
    parent = parent or Scroll
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 26)
    label.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
    label.Text = "  " .. text
    label.TextColor3 = Color3.fromRGB(0, 180, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = parent
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 4)
end

function updateScroll()
    clearScroll()
    if currentTab == "Aimbot" then
        createCategory("🔫 AIMBOT", Scroll)
        createToggle("Aimbot", "Aimbot", Scroll)
        createSlider("FOV", "AimbotFOV", 30, 300, 150, nil, Scroll)
        createSlider("Smooth", "AimbotSmooth", 0, 1, 0.1, nil, Scroll)
        createToggle("Wall Check", "WallCheck", Scroll)
        createToggle("Silent Aim", "SilentAim", Scroll)
        createToggle("Triggerbot", "Triggerbot", Scroll)
        createToggle("Flickbot", "Flickbot", Scroll)
        createSlider("Flick FOV", "FlickFOV", 30, 300, 200, nil, Scroll)
        createToggle("Auto Shoot", "AutoShoot", Scroll)
        createToggle("No Recoil", "NoRecoil", Scroll)

    elseif currentTab == "Visuals" then
        createCategory("👁️ VISUALS", Scroll)
        createToggle("ESP Box", "ESP_Box", Scroll)
        createToggle("ESP Line", "ESP_Line", Scroll)
        createToggle("ESP Name", "ESP_Name", Scroll)
        createToggle("ESP Health", "ESP_Health", Scroll)
        createToggle("ESP Distance", "ESP_Distance", Scroll)
        createToggle("ESP Tracer", "ESP_Tracer", Scroll)
        createToggle("Crosshair", "Crosshair", Scroll)
        createToggle("Full Bright", "FullBright", Scroll)
        createToggle("No Fog", "NoFog", Scroll)
        createToggle("Chams (Highlight)", "Chams", Scroll)

    elseif currentTab == "Movement" then
        createCategory("🏃 MOVEMENT", Scroll)
        createToggle("Bunny Hop", "BHop", Scroll)
        createSlider("BHOP Power", "BHopPower", 1, 15, 1, nil, Scroll)
        createToggle("Fly", "Fly", Scroll)
        createSlider("Fly Speed", "FlySpeed", 10, 200, 50, nil, Scroll)
        createToggle("Noclip", "Noclip", Scroll)
        createToggle("Speed", "Speed", Scroll)
        createSlider("Speed Value", "SpeedValue", 16, 120, 32, nil, Scroll)
        createToggle("Jump Power", "JumpPower", Scroll)
        createSlider("Jump Power", "JumpPowerValue", 30, 150, 50, nil, Scroll)

    elseif currentTab == "Misc" then
        createCategory("🔧 MISC", Scroll)
        createToggle("Infinite Ammo", "InfiniteAmmo", Scroll)
        createToggle("No Reload", "NoReload", Scroll)
        createToggle("Instant Heal", "InstantHeal", Scroll)
        createToggle("Anti Knock", "AntiKnock", Scroll)
        createToggle("No Slowdown", "NoSlowdown", Scroll)
    end
end

updateScroll()
MenuButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ==============================================
--  ОСНОВНАЯ ЛОГИКА (ВСЕ ФУНКЦИИ)
-- ==============================================

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
                        if Settings.WallCheck then
                            local origin = Camera.CFrame.Position
                            local dir = part.Position - origin
                            local ray = RaycastParams.new()
                            ray.FilterType = Enum.RaycastFilterType.Exclude
                            ray.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                            local result = workspace:Raycast(origin, dir, ray)
                            if result and result.Instance then
                                if not result.Instance:IsDescendantOf(char) then
                                    continue
                                end
                            end
                        end
                        bestDist = dist
                        bestTarget = part
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Симуляция выстрела
local function shoot()
    pcall(function()
        if mouse1click then mouse1click() end
    end)
end

-- Aimbot + Silent Aim
local function handleAimbot()
    if not Settings.Aimbot then return end
    local target = getClosestEnemy(Settings.AimbotFOV)
    if target then
        local smooth = Settings.AimbotSmooth
        if Settings.SilentAim then smooth = 0 end
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, target.Position)
        if smooth > 0 then
            Camera.CFrame = currentCF:Lerp(targetCF, smooth)
        else
            Camera.CFrame = targetCF
        end
        if Settings.AutoShoot then shoot() end
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
                if Settings.WallCheck then
                    local origin = Camera.CFrame.Position
                    local dir = target.Position - origin
                    local ray = RaycastParams.new()
                    ray.FilterType = Enum.RaycastFilterType.Exclude
                    ray.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                    local result = workspace:Raycast(origin, dir, ray)
                    if result and result.Instance and not result.Instance:IsDescendantOf(char) then
                        return
                    end
                end
                local now = os.clock()
                if now - lastShotTime >= triggerCooldown then
                    lastShotTime = now
                    shoot()
                end
            end
        end
    end)
end

-- Flickbot
local function handleFlickbot()
    if not Settings.Flickbot then return end
    local target = getClosestEnemy(Settings.FlickFOV)
    if target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        shoot()
    end
end

-- No Recoil (просто сбрасываем смещение камеры)
local function handleNoRecoil()
    if not Settings.NoRecoil then return end
    local cameraPart = workspace.CurrentCamera
    if cameraPart then
        cameraPart.CFrame = CFrame.new(cameraPart.CFrame.Position, cameraPart.CFrame.LookVector)
    end
end

-- ==============================================
--  ESP (ВСЕ ВИДЫ)
-- ==============================================

local function createESP(player)
    if player == LocalPlayer then return end
    if ESP_Objects[player] then
        pcall(function()
            ESP_Objects[player].Box:Destroy()
            ESP_Objects[player].Line:Destroy()
            ESP_Objects[player].Name:Destroy()
            ESP_Objects[player].Health:Destroy()
            ESP_Objects[player].Distance:Destroy()
            ESP_Objects[player].Tracer:Destroy()
        end)
        ESP_Objects[player] = nil
    end

    local box = Instance.new("Frame")
    box.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    box.BackgroundTransparency = 0.7
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(0, 180, 255)
    box.Visible = false
    box.ZIndex = 5
    box.Parent = ScreenGui

    local line = Instance.new("Frame")
    line.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    line.BorderSizePixel = 0
    line.BackgroundTransparency = 0.3
    line.Visible = false
    line.ZIndex = 5
    line.Parent = ScreenGui

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

    local distLabel = Instance.new("TextLabel")
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.Font = Enum.Font.GothamMedium
    distLabel.TextSize = 10
    distLabel.Visible = false
    distLabel.ZIndex = 5
    distLabel.Parent = ScreenGui

    local tracer = Instance.new("Frame")
    tracer.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    tracer.BorderSizePixel = 0
    tracer.BackgroundTransparency = 0.3
    tracer.Visible = false
    tracer.ZIndex = 5
    tracer.Parent = ScreenGui

    ESP_Objects[player] = {Box = box, Line = line, Name = nameLabel, Health = healthLabel, Distance = distLabel, Tracer = tracer}
end

local function clearESP(player)
    if ESP_Objects[player] then
        pcall(function()
            ESP_Objects[player].Box:Destroy()
            ESP_Objects[player].Line:Destroy()
            ESP_Objects[player].Name:Destroy()
            ESP_Objects[player].Health:Destroy()
            ESP_Objects[player].Distance:Destroy()
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
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local screenPos = Vector2.new(pos.X, pos.Y)
            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            local isEnemy = (player.Team ~= LocalPlayer.Team or player.Team == nil)

            -- Box
            if Settings.ESP_Box and data.Box and onScreen then
                data.Box.Visible = true
                local size = math.clamp(120 / (dist / 10 + 1), 20, 150)
                data.Box.Size = UDim2.new(0, size, 0, size)
                data.Box.Position = UDim2.new(0, screenPos.X - size/2, 0, screenPos.Y - size/2)
                data.Box.AnchorPoint = Vector2.new(0, 0)
                data.Box.BorderColor3 = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 180, 255)
                data.Box.BackgroundColor3 = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 180, 255)
            elseif data.Box then
                data.Box.Visible = false
            end

            -- Line (от центра к игроку)
            if Settings.ESP_Line and data.Line then
                data.Line.Visible = true
                local delta = screenPos - center
                local length = delta.Magnitude
                local angle = math.atan2(delta.Y, delta.X)
                data.Line.Position = UDim2.new(0, center.X, 0, center.Y)
                data.Line.Size = UDim2.new(0, length, 0, 1.5)
                data.Line.Rotation = math.deg(angle)
                data.Line.AnchorPoint = Vector2.new(0, 0.5)
                data.Line.BackgroundColor3 = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 180, 255)
            elseif data.Line then
                data.Line.Visible = false
            end

            -- Name
            if Settings.ESP_Name and data.Name and onScreen then
                data.Name.Visible = true
                data.Name.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - 30)
                data.Name.AnchorPoint = Vector2.new(0.5, 0)
                data.Name.TextColor3 = isEnemy and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 80)
            elseif data.Name then
                data.Name.Visible = false
            end

            -- Health
            if Settings.ESP_Health and data.Health and onScreen then
                data.Health.Visible = true
                data.Health.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                data.Health.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y + 20)
                data.Health.AnchorPoint = Vector2.new(0.5, 0)
                local hpPercent = hum.Health / hum.MaxHealth
                data.Health.TextColor3 = hpPercent > 0.5 and Color3.fromRGB(0, 255, 0) or hpPercent > 0.25 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0)
            elseif data.Health then
                data.Health.Visible = false
            end

            -- Distance
            if Settings.ESP_Distance and data.Distance and onScreen then
                data.Distance.Visible = true
                data.Distance.Text = math.floor(dist) .. " studs"
                data.Distance.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y + 35)
                data.Distance.AnchorPoint = Vector2.new(0.5, 0)
            elseif data.Distance then
                data.Distance.Visible = false
            end

            -- Tracer
            if Settings.ESP_Tracer and data.Tracer then
                data.Tracer.Visible = true
                local delta = screenPos - center
                local length = delta.Magnitude
                local angle = math.atan2(delta.Y, delta.X)
                data.Tracer.Position = UDim2.new(0, center.X, 0, center.Y)
                data.Tracer.Size = UDim2.new(0, length, 0, 1)
                data.Tracer.Rotation = math.deg(angle)
                data.Tracer.AnchorPoint = Vector2.new(0, 0.5)
                data.Tracer.BackgroundColor3 = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 180, 255)
            elseif data.Tracer then
                data.Tracer.Visible = false
            end

        else
            -- Скрываем всё
            if data.Box then data.Box.Visible = false end
            if data.Line then data.Line.Visible = false end
            if data.Name then data.Name.Visible = false end
            if data.Health then data.Health.Visible = false end
            if data.Distance then data.Distance.Visible = false end
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
--  ДВИЖЕНИЕ (BHop, Fly, Noclip, Speed, Jump)
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

-- Jump Power
local function handleJumpPower()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Settings.JumpPower then
        hum.JumpPower = Settings.JumpPowerValue
    else
        hum.JumpPower = defaultJumpPower
    end
end

-- ==============================================
--  ВИЗУАЛЬНЫЕ ЭФФЕКТЫ (Crosshair, FullBright, NoFog)
-- ==============================================

-- Crosshair
local function handleCrosshair()
    if not Settings.Crosshair then
        local ch = ScreenGui:FindFirstChild("Crosshair")
        if ch then ch:Destroy() end
        return
    end
    local crosshair = ScreenGui:FindFirstChild("Crosshair")
    if not crosshair then
        crosshair = Instance.new("Frame")
        crosshair.Name = "Crosshair"
        crosshair.Size = UDim2.new(0, 20, 0, 20)
        crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
        crosshair.BackgroundTransparency = 1
        crosshair.ZIndex = 10
        crosshair.Parent = ScreenGui

        for _, data in ipairs({
            {Size = UDim2.new(0, 2, 0, 10), Pos = UDim2.new(0.5, -1, 0, 0)},
            {Size = UDim2.new(0, 2, 0, 10), Pos = UDim2.new(0.5, -1, 0, 10)},
            {Size = UDim2.new(0, 10, 0, 2), Pos = UDim2.new(0, 0, 0.5, -1)},
            {Size = UDim2.new(0, 10, 0, 2), Pos = UDim2.new(0, 10, 0.5, -1)},
        }) do
            local part = Instance.new("Frame")
            part.Size = data.Size
            part.Position = data.Pos
            part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            part.BorderSizePixel = 0
            part.Parent = crosshair
        end
    end
end

-- FullBright
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
            lighting.FogEnd = 200
        end
    end
end

-- NoFog
local function handleNoFog()
    if Settings.NoFog then
        game:GetService("Lighting").FogEnd = 1000
    else
        game:GetService("Lighting").FogEnd = 200
    end
end

-- Chams (Highlight)
local function handleChams()
    local char = LocalPlayer.Character
    if not char then return end
    local highlight = char:FindFirstChild("Highlight")
    if Settings.Chams then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(0, 180, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = char
        end
    else
        if highlight then highlight:Destroy() end
    end
end

-- ==============================================
--  MISC (Infinite Ammo, No Reload, etc.)
-- ==============================================

-- Infinite Ammo & No Reload (ищем оружие и меняем значения)
local function handleWeaponMods()
    if not Settings.InfiniteAmmo and not Settings.NoReload then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            for _, obj in ipairs(tool:GetDescendants()) do
                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    local name = obj.Name:lower()
                    if Settings.InfiniteAmmo and (name:find("ammo") or name:find("clip") or name:find("mag")) then
                        obj.Value = 999
                    end
                    if Settings.NoReload and (name:find("reload") or name:find("cooldown") or name:find("delay")) then
                        obj.Value = 0
                    end
                end
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
        if hum then hum.Health = hum.MaxHealth end
    end
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

-- No Slowdown
local function handleNoSlowdown()
    if not Settings.NoSlowdown then return end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed < 16 then
            hum.WalkSpeed = 16
        end
    end
end

-- ==============================================
--  ГЛАВНЫЙ ЦИКЛ
-- ==============================================
RunService.RenderStepped:Connect(function()
    screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Aimbot
    handleAimbot()
    handleTriggerbot()
    handleFlickbot()
    handleNoRecoil()

    -- ESP
    updateESP()

    -- Movement
    handleBHop()
    handleFly()
    handleNoclip()
    handleSpeed()
    handleJumpPower()

    -- Visuals
    handleCrosshair()
    handleFullBright()
    handleNoFog()
    handleChams()

    -- Misc
    handleWeaponMods()
    handleInstantHeal()
    handleAntiKnock()
    handleNoSlowdown()
end)

-- Обработчик выстрела для Flickbot
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if Settings.Flickbot then
            handleFlickbot()
        end
    end
end)

print("✅ NEVERLOSE // FLICK LOADED (40+ functions)")
print("📱 Optimized for Delta Mobile | Style by Neverlose CS2")
