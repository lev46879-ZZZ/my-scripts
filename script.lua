-- ==============================================
-- [FPS] FLICK ULTIMATE v3 (Mobile/Delta)
-- Aimbot, Flickbot, Triggerbot, ESP, BHop
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
    Aimbot = false,        -- включить аимбот
    AimbotFOV = 150,       -- поле зрения
    WallCheck = false,     -- проверка стен
    Triggerbot = false,
    Flickbot = false,      -- флик при нажатии
    FlickFOV = 200,
    EspLine = false,
    EspBox = false,
    BHop = false,
    BHopPower = 1,         -- 1..15 (добавка к скорости)
    SilentAim = false,     -- бесшумный аим (быстрое наведение)
}

-- [[ ПЕРЕМЕННЫЕ ]] --
local ESP_Objects = {}     -- { [player] = {Line, Box} }
local defaultWalkSpeed = 0
local bhopActive = false
local lastShotTime = 0
local triggerCooldown = 0.05
local screenCenter = Vector2.new()
local targetPart = "HumanoidRootPart"  -- можно "Head" для хедшотов

-- ==============================================
--  СОЗДАНИЕ ГРАФИЧЕСКОГО ИНТЕРФЕЙСА
-- ==============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlickUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Кнопка-переключатель меню
local MenuButton = Instance.new("ImageButton")
MenuButton.Size = UDim2.new(0, 60, 0, 60)
MenuButton.Position = UDim2.new(0.03, 0, 0.3, 0)
MenuButton.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
MenuButton.Image = "rbxassetid://6031091211"  -- крутая иконка
MenuButton.ImageColor3 = Color3.fromRGB(0, 200, 255)
MenuButton.Parent = ScreenGui
Instance.new("UICorner", MenuButton).CornerRadius = UDim.new(1, 0)

-- Панель меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 420)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
Title.Text = "  ⚡ FLICK ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

-- Скроллинг-контейнер
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
Scroll.ScrollBarThickness = 3
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Функция создания переключателя (Toggle)
local function createToggle(text, setting, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(20, 26, 42)
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.fromRGB(180, 190, 210)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.Parent = Scroll
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
        if callback then callback(on) end
    end)
end

-- Функция создания ползунка (Slider)
local function createSlider(text, setting, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 48)
    container.BackgroundTransparency = 1
    container.Parent = Scroll

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

-- Создаём элементы меню
createToggle("Aimbot", "Aimbot")
createSlider("Aim FOV", "AimbotFOV", 30, 300, 150)
createToggle("Wall Check", "WallCheck")
createToggle("Silent Aim", "SilentAim")

createToggle("Triggerbot", "Triggerbot")
createToggle("Flickbot (on shoot)", "Flickbot")
createSlider("Flick FOV", "FlickFOV", 30, 300, 200)

createToggle("ESP Line", "EspLine")
createToggle("ESP Box (Chams)", "EspBox")

createToggle("Bunny Hop", "BHop")
createSlider("BHOP Power", "BHopPower", 1, 15, 1)

-- Открытие/закрытие меню
MenuButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ==============================================
--  ОСНОВНАЯ ЛОГИКА
-- ==============================================

-- Проверка видимости (WallCheck)
local function isVisible(targetPart, enemyChar)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(origin, direction, ray)
    if result and result.Instance then
        return result.Instance:IsDescendantOf(enemyChar)
    end
    return true
end

-- Получение ближайшего врага в FOV
local function getClosestEnemy(fov)
    local bestTarget = nil
    local bestDist = fov + 1
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(targetPart) or char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist <= fov and dist < bestDist then
                        if isVisible(part, char) then
                            bestDist = dist
                            bestTarget = part
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Симуляция выстрела (для триггербота)
local function shoot()
    pcall(function()
        if mouse1click then mouse1click() end
    end)
end

-- ==============================================
--  BHOP (WalkSpeed)
-- ==============================================
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

-- ==============================================
--  ESP (Line + Box) через GUI (стабильно на телефоне)
-- ==============================================

-- Создание объектов ESP для игрока
local function createESP(player)
    if player == LocalPlayer then return end
    if ESP_Objects[player] then
        pcall(function()
            ESP_Objects[player].Line:Destroy()
            ESP_Objects[player].Box:Destroy()
        end)
        ESP_Objects[player] = nil
    end

    local line = Instance.new("Frame")
    line.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    line.BorderSizePixel = 0
    line.BackgroundTransparency = 0.3
    line.Visible = false
    line.ZIndex = 5
    line.Parent = ScreenGui

    local box = Instance.new("Frame")
    box.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    box.BackgroundTransparency = 0.7
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(0, 200, 255)
    box.Visible = false
    box.ZIndex = 5
    box.Parent = ScreenGui

    ESP_Objects[player] = {Line = line, Box = box}
end

-- Очистка ESP
local function clearESP(player)
    if ESP_Objects[player] then
        pcall(function()
            ESP_Objects[player].Line:Destroy()
            ESP_Objects[player].Box:Destroy()
        end)
        ESP_Objects[player] = nil
    end
end

-- Обновление ESP (каждый кадр)
local function updateESP()
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    for player, data in pairs(ESP_Objects) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and hrp and hum.Health > 0 and player ~= LocalPlayer then
            local isEnemy = (player.Team ~= LocalPlayer.Team or player.Team == nil)
            local showLine = Settings.EspLine and isEnemy
            local showBox = Settings.EspBox and isEnemy

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local screenPos = Vector2.new(pos.X, pos.Y)

            -- Линия
            if showLine and data.Line then
                data.Line.Visible = true
                local delta = screenPos - center
                local length = delta.Magnitude
                local angle = math.atan2(delta.Y, delta.X)
                data.Line.Position = UDim2.new(0, center.X, 0, center.Y)
                data.Line.Size = UDim2.new(0, length, 0, 2)
                data.Line.Rotation = math.deg(angle)
                data.Line.AnchorPoint = Vector2.new(0, 0.5)
            elseif data.Line then
                data.Line.Visible = false
            end

            -- Бокс
            if showBox and data.Box and onScreen then
                data.Box.Visible = true
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                local size = math.clamp(120 / (dist / 10 + 1), 20, 150)
                data.Box.Size = UDim2.new(0, size, 0, size)
                data.Box.Position = UDim2.new(0, screenPos.X - size/2, 0, screenPos.Y - size/2)
                data.Box.AnchorPoint = Vector2.new(0, 0)
            elseif data.Box then
                data.Box.Visible = false
            end
        else
            if data.Line then data.Line.Visible = false end
            if data.Box then data.Box.Visible = false end
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
--  AIMBOT + FLICKBOT + TRIGGERBOT + SILENT AIM
-- ==============================================

-- Основная функция наведения (используется для аимбота и флика)
local function aimAt(targetPart)
    if not targetPart then return end
    pcall(function()
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    end)
end

-- Обработчик нажатия для фликбота (вызывается при выстреле)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    -- Для мобильных: касание экрана (кнопка стрельбы)
    if input.UserInputType == Enum.UserInputType.Touch then
        if Settings.Flickbot then
            local target = getClosestEnemy(Settings.FlickFOV)
            if target then aimAt(target) end
        end
        -- Triggerbot при касании (если наведён на врага)
        if Settings.Triggerbot then
            task.wait(0.05) -- небольшая задержка для стабильности
            triggerbot()
        end
    end
    -- Для ПК: клик мыши
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Settings.Flickbot then
            local target = getClosestEnemy(Settings.FlickFOV)
            if target then aimAt(target) end
        end
        if Settings.Triggerbot then
            task.wait(0.05)
            triggerbot()
        end
    end
end)

-- Triggerbot (автовыстрел при наведении)
function triggerbot()
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
                local now = os.clock()
                if now - lastShotTime >= triggerCooldown then
                    lastShotTime = now
                    shoot()
                end
            end
        end
    end)
end

-- ==============================================
--  ГЛАВНЫЙ ЦИКЛ (RenderStepped)
-- ==============================================
RunService.RenderStepped:Connect(function()
    -- Обновляем центр экрана
    screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- BHop
    handleBHop()

    -- ESP
    updateESP()

    -- Aimbot (постоянное наведение, если включён)
    if Settings.Aimbot then
        local target = getClosestEnemy(Settings.AimbotFOV)
        if target then
            if Settings.SilentAim then
                -- Silent aim: мгновенный флик без задержки
                aimAt(target)
            else
                -- Плавный аим (можно через Tween или просто мгновенно)
                aimAt(target)
            end
        end
    end

    -- Triggerbot (если не обработан в InputBegan, продублируем для надёжности)
    if Settings.Triggerbot then
        triggerbot()
    end
end)

print("✅ FLICK ULTIMATE LOADED! (Mobile/Delta)")
