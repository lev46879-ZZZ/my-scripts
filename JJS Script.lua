-- Death Ball | Auto Parry (v3 - Перебор вариантов + Адаптация)
-- Фокус: работа при высоком пинге и разной скорости мяча

-- 1. СЕРВИСЫ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- 2. НАСТРОЙКИ
local Settings = {
    AutoParryEnabled = true,
    ParryDistance = 18,          -- Дистанция срабатывания (studs)
    PingCompensation = 0.5,     -- Компенсация пинга (0.5 = 500мс)
    MaxPing = 0.7,              -- Макс. пинг для работы скрипта (700мс)
    MinETA = 0.08,              -- Мин. время до удара для срабатывания (сек)
    Debug = false               -- Показывать отладочные сообщения
}

-- 3. СТАТИСТИКА
local Stats = {
    Attempts = 0,
    Success = 0,
    CurrentPing = 0,
    BallSpeed = 0,
    LastParryMethod = "none"
}

-- 4. ПЕРЕМЕННЫЕ ДЛЯ ПЕРЕБОРА
local parryRemotes = {}         -- Найденные ремоуты
local workingMethod = nil       -- Рабочий метод (например, "remote:Parry")
local keyPressMethods = {       -- Способы эмуляции нажатия клавиш
    function() 
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end,
    function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:KeyPress(Enum.KeyCode.F)
    end,
    function()
        -- Прямая эмуляция через UserInputService
        local input = Instance.new("InputObject")
        -- В большинстве executor'ов это не сработает, но попробуем
    end
}

-- 5. ПОИСК ВСЕХ ВОЗМОЖНЫХ РЕМОУТОВ
local function findParryRemotes()
    parryRemotes = {}
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") 
        or ReplicatedStorage:FindFirstChild("RemoteEvents")
    
    if remotesFolder then
        for _, remote in ipairs(remotesFolder:GetChildren()) do
            if remote:IsA("RemoteEvent") then
                local nameLower = string.lower(remote.Name)
                if string.find(nameLower, "parry") or 
                   string.find(nameLower, "deflect") or 
                   string.find(nameLower, "block") then
                    table.insert(parryRemotes, remote)
                    if Settings.Debug then
                        print("[AutoParry] Найден ремоут:", remote:GetFullName())
                    end
                end
            end
        end
    end
    
    -- Если не нашли в Remotes, ищем по всему ReplicatedStorage
    if #parryRemotes == 0 then
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "parry") or 
                   string.find(nameLower, "deflect") then
                    table.insert(parryRemotes, obj)
                end
            end
        end
    end
    
    if Settings.Debug then
        print("[AutoParry] Всего найдено ремоутов для парирования:", #parryRemotes)
    end
end

-- 6. ФУНКЦИЯ ПАРИРОВАНИЯ (ПЕРЕБОР ВАРИАНТОВ)
local function performParry()
    Stats.Attempts = Stats.Attempts + 1
    
    -- Если уже есть рабочий метод, используем его
    if workingMethod then
        if workingMethod.type == "remote" then
            workingMethod.remote:FireServer()
            return true
        elseif workingMethod.type == "key" then
            workingMethod.func()
            return true
        end
    end
    
    -- Перебираем ремоуты
    for _, remote in ipairs(parryRemotes) do
        pcall(function()
            remote:FireServer()
        end)
        -- Проверяем, сработало ли (по изменению статистики или визуально)
        -- В реальности нужно проверить, изменилось ли состояние игрока
        -- Пока просто запоминаем как возможный вариант
        workingMethod = {type = "remote", remote = remote}
        if Settings.Debug then
            print("[AutoParry] Пробуем ремоут:", remote.Name)
        end
        return true
    end
    
    -- Перебираем способы нажатия клавиш
    for i, keyFunc in ipairs(keyPressMethods) do
        pcall(keyFunc)
        workingMethod = {type = "key", func = keyFunc, index = i}
        if Settings.Debug then
            print("[AutoParry] Пробуем способ нажатия #" .. i)
        end
        return true
    end
    
    return false
end

-- 7. ПОИСК МЯЧА
local function findTargetBall()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil, nil, 0
    end
    
    local myPosition = character.HumanoidRootPart.Position
    local closestBall = nil
    local closestDistance = math.huge
    local ballSpeed = 0
    
    -- Ищем мячи (расширенный список имен)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "ball") or 
               string.find(nameLower, "projectile") or
               string.find(nameLower, "orb") or
               string.find(nameLower, "sphere") then
                local distance = (obj.Position - myPosition).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestBall = obj
                    ballSpeed = obj.Velocity.Magnitude
                end
            end
        end
    end
    
    return closestBall, closestDistance, ballSpeed
end

-- 8. ОСНОВНОЙ ЦИКЛ
local heartbeatConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AutoParryEnabled then return end
    
    -- Получаем пинг
    local ping = LocalPlayer:GetNetworkPing()
    Stats.CurrentPing = ping
    
    if ping > Settings.MaxPing then
        return
    end
    
    -- Ищем мяч
    local ball, distance, ballSpeed = findTargetBall()
    Stats.BallSpeed = ballSpeed
    
    if ball and distance then
        -- Рассчитываем ETA (время до прибытия) с учетом пинга
        local adjustedDistance = distance - (ping * ballSpeed)
        
        -- Если мяч уже в зоне поражения с учетом пинга
        if adjustedDistance < Settings.ParryDistance then
            -- Рассчитываем время до удара
            local eta = adjustedDistance / math.max(ballSpeed, 1)
            
            -- Если время до удара меньше порога, парируем
            if eta < Settings.MinETA or adjustedDistance < 5 then
                local success = performParry()
                if success then
                    Stats.Success = Stats.Success + 1
                end
            end
        end
    end
end)

-- 9. МИНИ-GUI (130x90)
local function createMiniGUI()
    local oldGui = game.CoreGui:FindFirstChild("DeathBallAutoParryMini")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeathBallAutoParryMini"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 130, 0, 90)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    title.BackgroundTransparency = 0.3
    title.Text = "⚔️ Auto Parry"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 11
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Статистика
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, -8, 1, -25)
    statsFrame.Position = UDim2.new(0, 4, 0, 22)
    statsFrame.BackgroundTransparency = 1
    statsFrame.Parent = frame
    
    local function makeLabel(y, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 15)
        lbl.Position = UDim2.new(0, 0, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
        lbl.TextSize = 10
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = statsFrame
        return lbl
    end
    
    local attemptsLbl = makeLabel(0, "Попытки: 0")
    local successLbl = makeLabel(15, "Успех: 0")
    local pingLbl = makeLabel(30, "Пинг: 0ms")
    local speedLbl = makeLabel(45, "Скорость: 0")
    local statusLbl = makeLabel(60, "🟢 АКТИВЕН")
    
    -- Обновление
    local updateConn
    updateConn = RunService.Heartbeat:Connect(function()
        if not screenGui.Parent then
            updateConn:Disconnect()
            return
        end
        
        attemptsLbl.Text = "Попытки: " .. Stats.Attempts
        successLbl.Text = "Успех: " .. Stats.Success
        successLbl.TextColor3 = Stats.Success > 0 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(180, 180, 190)
        
        local pingMs = math.floor(Stats.CurrentPing * 1000)
        pingLbl.Text = "Пинг: " .. pingMs .. "ms"
        pingLbl.TextColor3 = pingMs < 150 and Color3.fromRGB(100, 255, 100) 
            or (pingMs < 300 and Color3.fromRGB(255, 255, 100) 
            or Color3.fromRGB(255, 100, 100))
        
        speedLbl.Text = "Скорость: " .. math.floor(Stats.BallSpeed)
        
        if Settings.AutoParryEnabled then
            statusLbl.Text = "🟢 АКТИВЕН"
            statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            statusLbl.Text = "🔴 ВЫКЛ"
            statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    return screenGui
end

-- 10. ЗАПУСК
findParryRemotes()
createMiniGUI()

print("[AutoParry] Скрипт загружен.")
print("[AutoParry] Найдено ремоутов:", #parryRemotes)
print("[AutoParry] Auto Parry включён.")

game:BindToClose(function()
    if heartbeatConnection then heartbeatConnection:Disconnect() end
    print("[AutoParry] Скрипт остановлен.")
end)
