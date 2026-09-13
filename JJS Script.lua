--[[
    Death Ball | Auto Parry + Ping Compensation + GUI Stats
    Сделано для: [твой ник]
    Фокус: Auto Parry, работающий даже при высоком пинге
--]]

-- 1. СЕРВИСЫ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 2. НАСТРОЙКИ
local Settings = {
    AutoParryEnabled = true,      -- Auto Parry включён при загрузке
    PingCompensation = 0.5,       -- Компенсация пинга (0.5 = 500мс). Настраивай экспериментально!
    ParryDistance = 15,           -- Дистанция срабатывания (в studs)
    SpamThreshold = 0.7,          -- Запас времени для упреждающего спама при высоком пинге
    MaxPing = 0.6,                -- Максимальный пинг, при котором скрипт активен (0.6 = 600мс)
}

-- 3. СТАТИСТИКА
local Stats = {
    ParryAttempts = 0,
    ParrySuccess = 0,
    ParryMissed = 0,
    CurrentPing = 0,
    AveragePing = 0,
}

-- 4. ФУНКЦИЯ ПАРИРОВАНИЯ (ЗАГЛУШКА)
-- ВАЖНО: Здесь нужно указать правильный RemoteEvent для парирования в Death Ball
local function performParry()
    -- Попытка найти ремоут для парирования
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    
    if remotes then
        -- Ищем ремоут, связанный с парированием
        -- Возможные варианты: "Parry", "Deflect", "ParryEvent", "Ability"
        for _, remote in ipairs(remotes:GetChildren()) do
            if remote:IsA("RemoteEvent") then
                local nameLower = string.lower(remote.Name)
                if string.find(nameLower, "parry") or string.find(nameLower, "deflect") then
                    -- Отправляем запрос на парирование
                    remote:FireServer()
                    Stats.ParryAttempts = Stats.ParryAttempts + 1
                    return true
                end
            end
        end
    end
    
    -- Если ремоут не найден, пробуем эмулировать нажатие клавиши (запасной вариант)
    -- В Death Ball парирование может быть на клавише F или E
    local VirtualUser = game:GetService("VirtualUser")
    -- VirtualUser:CaptureController() -- Раскомментировать, если нужно
    -- VirtualUser:KeyPress(Enum.KeyCode.F) -- Раскомментировать и попробовать
    
    Stats.ParryAttempts = Stats.ParryAttempts + 1
    return false
end

-- 5. ПОИСК МЯЧА, ЛЕТЯЩЕГО В ИГРОКА
local function findTargetBall()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local myPosition = character.HumanoidRootPart.Position
    local closestBall = nil
    local closestDistance = math.huge
    
    -- Ищем все мячи в рабочей области
    -- В Death Ball мячи могут называться "Ball", "DeathBall", "Projectile" и т.д.
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "ball") or string.find(nameLower, "projectile") then
                local distance = (obj.Position - myPosition).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestBall = obj
                end
            end
        end
    end
    
    return closestBall, closestDistance
end

-- 6. ОСНОВНОЙ ЦИКЛ AUTO PARRY
local heartbeatConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AutoParryEnabled then return end
    
    -- Получаем текущий пинг
    local ping = LocalPlayer:GetNetworkPing()
    Stats.CurrentPing = ping
    
    -- Скользящее среднее для пинга
    Stats.AveragePing = (Stats.AveragePing * 0.95) + (ping * 0.05)
    
    -- Если пинг слишком высокий, возможно, стоит временно отключить парирование
    if ping > Settings.MaxPing then
        return
    end
    
    -- Ищем мяч, летящий в нас
    local ball, distance = findTargetBall()
    
    if ball and distance then
        -- Рассчитываем скорректированную дистанцию с учётом пинга
        -- Если мяч летит в нас, он приближается. Учитываем задержку сети.
        local ballVelocity = ball.Velocity.Magnitude
        local adjustedDistance = distance - (ping * ballVelocity)
        
        -- Проверяем, находится ли мяч в зоне поражения
        if adjustedDistance < Settings.ParryDistance then
            -- Если пинг высокий, используем упреждающий спам
            if ping > 0.2 and (adjustedDistance / ballVelocity) < Settings.SpamThreshold then
                -- Упреждающий спам при высоком пинге
                performParry()
            elseif adjustedDistance <= 5 then
                -- Идеальное срабатывание
                local success = performParry()
                if success then
                    Stats.ParrySuccess = Stats.ParrySuccess + 1
                else
                    Stats.ParryMissed = Stats.ParryMissed + 1
                end
            end
        end
    end
end)

-- 7. СОЗДАНИЕ GUI (СТАТИСТИКА)
local function createStatsGUI()
    -- Удаляем старый GUI, если есть
    local oldGui = game.CoreGui:FindFirstChild("DeathBallAutoParryGUI")
    if oldGui then
        oldGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeathBallAutoParryGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game.CoreGui
    
    -- Основной фрейм
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 140)
    mainFrame.Position = UDim2.new(0, 15, 0, 15)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Закругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    title.BackgroundTransparency = 0.5
    title.BorderSizePixel = 0
    title.Text = "⚔️ Death Ball | Auto Parry"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Статистика
    local statsContainer = Instance.new("Frame")
    statsContainer.Name = "Stats"
    statsContainer.Size = UDim2.new(1, -20, 1, -45)
    statsContainer.Position = UDim2.new(0, 10, 0, 35)
    statsContainer.BackgroundTransparency = 1
    statsContainer.Parent = mainFrame
    
    -- Функция создания строки статистики
    local function createStatLabel(name, yOffset)
        local label = Instance.new("TextLabel")
        label.Name = name .. "Label"
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, yOffset)
        label.BackgroundTransparency = 1
        label.Text = name .. ": 0"
        label.TextColor3 = Color3.fromRGB(200, 200, 210)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = statsContainer
        return label
    end
    
    local attemptsLabel = createStatLabel("Попытки", 0)
    local successLabel = createStatLabel("Успешно", 22)
    local missedLabel = createStatLabel("Пропущено", 44)
    local pingLabel = createStatLabel("Пинг", 66)
    
    -- Индикатор статуса
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 90)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "🟢 ACTIVE"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.TextSize = 13
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Parent = statsContainer
    
    -- Обновление GUI
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if not screenGui.Parent then
            updateConnection:Disconnect()
            return
        end
        
        attemptsLabel.Text = "Попытки: " .. Stats.ParryAttempts
        successLabel.Text = "Успешно: " .. Stats.ParrySuccess
        missedLabel.Text = "Пропущено: " .. Stats.ParryMissed
        
        local pingMs = math.floor(Stats.CurrentPing * 1000)
        pingLabel.Text = "Пинг: " .. pingMs .. " ms"
        
        -- Цвет пинга
        if pingMs < 150 then
            pingLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        elseif pingMs < 300 then
            pingLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        else
            pingLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        -- Статус
        if Settings.AutoParryEnabled then
            statusLabel.Text = "🟢 ACTIVE"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            statusLabel.Text = "🔴 DISABLED"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    return screenGui
end

-- 8. ЗАПУСК
print("[AutoParry] Скрипт загружен. Auto Parry активен.")
print("[AutoParry] Пинг: " .. math.floor(Stats.CurrentPing * 1000) .. " ms")

createStatsGUI()

-- Обработка отключения
game:BindToClose(function()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
    end
    print("[AutoParry] Скрипт остановлен.")
end)
