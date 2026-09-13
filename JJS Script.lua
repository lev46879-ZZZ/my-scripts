-- Death Ball | Auto Parry (Delta Mobile - v4)
-- Фокус: поиск мяча по скорости, эмуляция тапа, адаптация под пинг

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AutoParryEnabled = true,
    ParryDistance = 20,
    PingCompensation = 0.5,
    MaxPing = 0.7,
    MinETA = 0.1,
    Debug = false
}

local Stats = {
    Attempts = 0,
    Success = 0,
    CurrentPing = 0,
    BallSpeed = 0,
    TargetName = "Нет"
}

-- ЭМУЛЯЦИЯ ТАПА (ДЛЯ DELTA)
local function tapScreen()
    local screenSize = GuiService:GetScreenResolution()
    local tapX = screenSize.X / 2
    local tapY = screenSize.Y / 2

    -- Способ 1: SendTouchEvent (основной для мобильных)
    pcall(function()
        VirtualInputManager:SendTouchEvent(99, 1, tapX, tapY)
        task.wait(0.02)
        VirtualInputManager:SendTouchEvent(99, 2, tapX, tapY)
    end)

    -- Способ 2: SendMouseButtonEvent (запасной)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(tapX, tapY, 0, true, game, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(tapX, tapY, 0, false, game, 0)
    end)
    return true
end

-- ФУНКЦИЯ ПАРИРОВАНИЯ
local function performParry()
    Stats.Attempts = Stats.Attempts + 1
    tapScreen()
    return true
end

-- 🎯 НОВЫЙ ПОИСК МЯЧА (Игнорирует имя, ищет по скорости)
local function findTargetBall()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil, nil, 0
    end
    
    local myPosition = character.HumanoidRootPart.Position
    local closestBall = nil
    local closestDistance = math.huge
    local ballSpeed = 0
    
    -- Ищем по всей рабочей области
    for _, obj in ipairs(workspace:GetDescendants()) do
        local part = nil
        -- Проверяем, это часть или модель
        if obj:IsA("BasePart") then
            part = obj
        elseif obj:IsA("Model") and obj.PrimaryPart then
            part = obj.PrimaryPart
        end
        
        if part then
            -- Пропускаем персонажа игрока и закрепленные объекты
            if not part:IsDescendantOf(character) and not part.Anchored then
                -- Если объект движется быстро (скорость > 10), это вероятно мяч
                if part.Velocity.Magnitude > 10 then
                    local distance = (part.Position - myPosition).Magnitude
                    -- Ограничиваем дистанцию 150 studs, чтобы не хватать мусор на карте
                    if distance < closestDistance and distance < 150 then
                        closestDistance = distance
                        closestBall = part
                        ballSpeed = part.Velocity.Magnitude
                    end
                end
            end
        end
    end
    
    return closestBall, closestDistance, ballSpeed
end

-- ОСНОВНОЙ ЦИКЛ
local heartbeatConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AutoParryEnabled then return end

    local ping = LocalPlayer:GetNetworkPing()
    Stats.CurrentPing = ping

    if ping > Settings.MaxPing then return end

    local ball, distance, ballSpeed = findTargetBall()
    
    if ball then
        Stats.TargetName = ball.Name
        Stats.BallSpeed = ballSpeed
    else
        Stats.TargetName = "Нет"
        Stats.BallSpeed = 0
    end

    if ball and distance then
        local adjustedDistance = distance - (ping * ballSpeed)
        if adjustedDistance < Settings.ParryDistance then
            local eta = adjustedDistance / math.max(ballSpeed, 1)
            if eta < Settings.MinETA or adjustedDistance < 5 then
                performParry()
                Stats.Success = Stats.Success + 1
            end
        end
    end
end)

-- МИНИ-GUI (Увеличен, чтобы влезла строчка "Цель")
local function createMiniGUI()
    local oldGui = game.CoreGui:FindFirstChild("DeathBallAutoParryMini")
    if oldGui then oldGui:Destroy() end

    local guiParent = game.CoreGui
    pcall(function() if gethui then guiParent = gethui() end end)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeathBallAutoParryMini"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = guiParent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 140, 0, 110) -- Сделал чуть выше
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(170, 0, 255)
    stroke.Thickness = 2
    stroke.Parent = frame

    -- Пульсация обводки
    local pulseConnection = RunService.RenderStepped:Connect(function()
        if not screenGui.Parent then pulseConnection:Disconnect() return end
        local pulse = (math.sin(tick() * 3) + 1) / 2
        stroke.Thickness = 2 + pulse * 1.5
        stroke.Color = Color3.fromRGB(170 + pulse * 40, 0, 255 - pulse * 30)
    end)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = "⚔️ Auto Parry"
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local function makeLabel(y, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 14)
        lbl.Position = UDim2.new(0, 5, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
        lbl.TextSize = 10
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        return lbl
    end

    local attemptsLbl = makeLabel(22, "Попытки: 0")
    local successLbl = makeLabel(37, "Успех: 0")
    local pingLbl = makeLabel(52, "Пинг: 0ms")
    local speedLbl = makeLabel(67, "Скорость: 0")
    local targetLbl = makeLabel(82, "Цель: Нет") -- Новая строчка
    local statusLbl = makeLabel(97, "🟢 АКТИВЕН")
    statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLbl.Font = Enum.Font.GothamBold

    local updateConn
    updateConn = RunService.Heartbeat:Connect(function()
        if not screenGui.Parent then updateConn:Disconnect() return end

        attemptsLbl.Text = "Попытки: " .. Stats.Attempts
        successLbl.Text = "Успех: " .. Stats.Success
        
        local pingMs = math.floor(Stats.CurrentPing * 1000)
        pingLbl.Text = "Пинг: " .. pingMs .. "ms"
        pingLbl.TextColor3 = pingMs < 150 and Color3.fromRGB(100, 255, 100) 
            or (pingMs < 300 and Color3.fromRGB(255, 255, 100) or Color3.fromRGB(255, 100, 100))
        
        speedLbl.Text = "Скорость: " .. math.floor(Stats.BallSpeed)
        
        -- Показываем имя цели (мяча)
        targetLbl.Text = "Цель: " .. Stats.TargetName
        targetLbl.TextColor3 = Stats.TargetName ~= "Нет" and Color3.fromRGB(100, 255, 255) or Color3.fromRGB(180, 180, 190)
    end)
end

-- ЗАПУСК
createMiniGUI()
print("[AutoParry] Скрипт загружен. Ожидание мяча...")

game:BindToClose(function()
    if heartbeatConnection then heartbeatConnection:Disconnect() end
end)
