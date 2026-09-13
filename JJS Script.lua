-- Death Ball | Auto Parry (Delta Mobile Edition)
-- Перебор вариантов парирования (тап/кнопка), адаптация под пинг и скорость мяча

-- 1. СЕРВИСЫ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- 2. НАСТРОЙКИ
local Settings = {
    AutoParryEnabled = true,
    ParryDistance = 18,
    PingCompensation = 0.5,
    MaxPing = 0.7,
    MinETA = 0.08,
    Debug = false
}

-- 3. СТАТИСТИКА
local Stats = {
    Attempts = 0,
    Success = 0,
    CurrentPing = 0,
    BallSpeed = 0,
    LastParryMethod = "none"
}

-- 4. ПЕРЕБОР ВАРИАНТОВ ПАРИРОВАНИЯ
local parryRemotes = {}
local workingMethod = nil

-- Эмуляция тапа по экрану (ДЛЯ DELTA)
local function tapScreen()
    local screenSize = GuiService:GetScreenResolution()
    local tapX = screenSize.X / 2
    local tapY = screenSize.Y / 2
    
    -- Delta: используем VirtualInputManager (основной способ)
    local vim = game:GetService("VirtualInputManager")
    pcall(function()
        vim:SendMouseButtonEvent(tapX, tapY, 0, true, game, 0)
        task.wait(0.03)
        vim:SendMouseButtonEvent(tapX, tapY, 0, false, game, 0)
    end)
    
    -- Дополнительно пробуем syn.tap / fluxus.tap, если Delta их поддерживает
    if syn and syn.tap then
        pcall(function() syn.tap(tapX, tapY) end)
    elseif fluxus and fluxus.tap then
        pcall(function() fluxus.tap(tapX, tapY) end)
    end
    
    return true
end

-- Поиск всех ремоутов, связанных с парированием
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
                end
            end
        end
    end
    
    if #parryRemotes == 0 then
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "parry") or string.find(nameLower, "deflect") then
                    table.insert(parryRemotes, obj)
                end
            end
        end
    end
end

-- Функция парирования (перебор: тап -> ремоуты -> кнопка)
local function performParry()
    Stats.Attempts = Stats.Attempts + 1
    
    if workingMethod then
        if workingMethod.type == "tap" then
            tapScreen()
            return true
        elseif workingMethod.type == "remote" then
            workingMethod.remote:FireServer()
            return true
        elseif workingMethod.type == "button" then
            workingMethod.button:Activate()
            return true
        end
    end
    
    -- 1. Тап по экрану
    tapScreen()
    workingMethod = {type = "tap"}
    Stats.LastParryMethod = "tap"
    return true
end

-- 5. ПОИСК МЯЧА
local function findTargetBall()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return nil, nil, 0
    end
    
    local myPosition = character.HumanoidRootPart.Position
    local closestBall = nil
    local closestDistance = math.huge
    local ballSpeed = 0
    
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "ball") or 
               string.find(nameLower, "projectile") or
               string.find(nameLower, "orb") then
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

-- 6. ОСНОВНОЙ ЦИКЛ
local heartbeatConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AutoParryEnabled then return end
    
    local ping = LocalPlayer:GetNetworkPing()
    Stats.CurrentPing = ping
    
    if ping > Settings.MaxPing then return end
    
    local ball, distance, ballSpeed = findTargetBall()
    Stats.BallSpeed = ballSpeed
    
    if ball and distance then
        local adjustedDistance = distance - (ping * ballSpeed)
        
        if adjustedDistance < Settings.ParryDistance then
            local eta = adjustedDistance / math.max(ballSpeed, 1)
            
            if eta < Settings.MinETA or adjustedDistance < 5 then
                local success = performParry()
                if success then
                    Stats.Success = Stats.Success + 1
                end
            end
        end
    end
end)

-- 7. МИНИ-GUI (130x95, чёрный фон, пульсирующая фиолетовая обводка)
local function createMiniGUI()
    local oldGui = game.CoreGui:FindFirstChild("DeathBallAutoParryMini")
    if oldGui then oldGui:Destroy() end
    
    -- Поддержка gethui() для Delta и других исполнителей
    local guiParent = game.CoreGui
    pcall(function()
        if gethui then
            guiParent = gethui()
        end
    end)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeathBallAutoParryMini"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = guiParent
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 130, 0, 95)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0
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
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame
    
    local pulseConnection = RunService.RenderStepped:Connect(function()
        if not screenGui.Parent then
            pulseConnection:Disconnect()
            return
        end
        local t = tick()
        local pulse = (math.sin(t * 3) + 1) / 2
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
    local statusLbl = makeLabel(82, "🟢 АКТИВЕН")
    statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLbl.Font = Enum.Font.GothamBold
    
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

-- 8. ЗАПУСК
findParryRemotes()
createMiniGUI()

print("[AutoParry] Скрипт загружен. Auto Parry активен.")
print("[AutoParry] Найдено ремоутов:", #parryRemotes)
print("[AutoParry] Метод: VirtualInputManager (Delta)")

game:BindToClose(function()
    if heartbeatConnection then heartbeatConnection:Disconnect() end
    print("[AutoParry] Скрипт остановлен.")
end)
