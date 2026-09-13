-- Death Ball | Auto Parry (Delta Mobile - v6, стабильный)
-- Оптимизирован: поиск раз в 0.1 сек, фильтр персонажей, клик мышью

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AutoParryEnabled = true,
    ParryDistance = 50,
    PingCompensation = 0.5,
    MaxPing = 0.7,
    MinETA = 0.25,
    MinBallSpeed = 25,
    Debug = false
}

local Stats = {
    Attempts = 0,
    Success = 0,
    CurrentPing = 0,
    BallSpeed = 0,
    TargetName = "Нет"
}

-- ЭМУЛЯЦИЯ КЛИКА МЫШЬЮ
local function tapScreen()
    local screenSize = GuiService:GetScreenResolution()
    local tapX = screenSize.X / 2
    local tapY = screenSize.Y / 2

    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(tapX, tapY, 0, true, game, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(tapX, tapY, 0, false, game, 0)
    end)
    return true
end

local function performParry()
    Stats.Attempts = Stats.Attempts + 1
    tapScreen()
    return true
end

-- Проверка: часть принадлежит игроку?
local function isPlayerPart(part)
    -- Идём вверх по дереву, ищем Model с Humanoid
    local parent = part.Parent
    while parent and parent ~= workspace do
        if parent:IsA("Model") then
            local plr = Players:GetPlayerFromCharacter(parent)
            if plr then return true end
        end
        if parent:IsA("Tool") or parent:IsA("Accessory") then
            return true
        end
        parent = parent.Parent
    end
    return false
end

-- 🎯 ПОИСК МЯЧА
local function findTargetBall()
    local character = LocalPlayer.Character
    if not character then return nil, nil, 0 end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil, 0 end
    
    local myPos = hrp.Position
    local closestBall, closestDist, ballSpeed = nil, math.huge, 0
    
    -- Ищем только среди прямых детей workspace и папок первого уровня
    local folders = {workspace}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Folder") or obj:IsA("Model") then
            table.insert(folders, obj)
        end
    end
    
    for _, folder in ipairs(folders) do
        for _, part in ipairs(folder:GetChildren()) do
            local targetPart = nil
            if part:IsA("BasePart") then
                targetPart = part
            elseif part:IsA("Model") and part.PrimaryPart then
                targetPart = part.PrimaryPart
            end
            
            if targetPart and not targetPart.Anchored then
                -- Пропускаем части персонажей
                if not isPlayerPart(targetPart) then
                    local speed = targetPart.Velocity.Magnitude
                    
                    if speed >= Settings.MinBallSpeed then
                        local toMe = myPos - targetPart.Position
                        local dist = toMe.Magnitude
                        
                        if dist < 150 and dist < closestDist then
                            local dot = targetPart.Velocity.Unit:Dot(toMe.Unit)
                            if dot > 0.3 then
                                closestDist = dist
                                closestBall = targetPart
                                ballSpeed = speed
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestBall, closestDist, ballSpeed
end

-- ОСНОВНОЙ ЦИКЛ (поиск раз в 0.1 сек)
local searchConnection = RunService.Heartbeat:Connect(function()
    if not Settings.AutoParryEnabled then return end

    local ping = LocalPlayer:GetNetworkPing()
    Stats.CurrentPing = ping

    if ping > Settings.MaxPing then return end
end)

local searchThread = task.spawn(function()
    while task.wait(0.1) do
        if not Settings.AutoParryEnabled then continue end
        
        local ball, distance, ballSpeed = findTargetBall()
        
        if ball then
            Stats.TargetName = ball.Name
            Stats.BallSpeed = ballSpeed
        else
            Stats.TargetName = "Нет"
            Stats.BallSpeed = 0
        end

        if ball and distance then
            local ping = Stats.CurrentPing
            local adjustedDistance = distance - (ping * ballSpeed)
            
            if adjustedDistance < Settings.ParryDistance then
                local eta = math.max(adjustedDistance, 0) / math.max(ballSpeed, 1)
                
                if eta < Settings.MinETA or adjustedDistance < 10 then
                    performParry()
                    Stats.Success = Stats.Success + 1
                end
            end
        end
    end
end)

-- МИНИ-GUI
local function createMiniGUI()
    pcall(function()
        local oldGui = game.CoreGui:FindFirstChild("DeathBallAutoParryMini")
        if oldGui then oldGui:Destroy() end

        local guiParent = game.CoreGui
        pcall(function() if gethui then guiParent = gethui() end end)

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "DeathBallAutoParryMini"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = guiParent

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 140, 0, 110)
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

        -- Пульсация
        task.spawn(function()
            while screenGui.Parent do
                task.wait(0.03)
                local pulse = (math.sin(tick() * 3) + 1) / 2
                stroke.Thickness = 2 + pulse * 1.5
                stroke.Color = Color3.fromRGB(170 + pulse * 40, 0, 255 - pulse * 30)
            end
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
        local targetLbl = makeLabel(82, "Цель: Нет")
        local statusLbl = makeLabel(97, "🟢 АКТИВЕН")
        statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLbl.Font = Enum.Font.GothamBold

        task.spawn(function()
            while screenGui.Parent do
                task.wait(0.15)
                attemptsLbl.Text = "Попытки: " .. Stats.Attempts
                successLbl.Text = "Успех: " .. Stats.Success
                
                local pingMs = math.floor(Stats.CurrentPing * 1000)
                pingLbl.Text = "Пинг: " .. pingMs .. "ms"
                pingLbl.TextColor3 = pingMs < 150 and Color3.fromRGB(100, 255, 100) 
                    or (pingMs < 300 and Color3.fromRGB(255, 255, 100) or Color3.fromRGB(255, 100, 100))
                
                speedLbl.Text = "Скорость: " .. math.floor(Stats.BallSpeed)
                
                targetLbl.Text = "Цель: " .. Stats.TargetName
                targetLbl.TextColor3 = Stats.TargetName ~= "Нет" and Color3.fromRGB(100, 255, 255) or Color3.fromRGB(180, 180, 190)
            end
        end)
    end)
end

createMiniGUI()
print("[AutoParry] v6 загружен. Поиск раз в 0.1 сек.")

game:BindToClose(function()
    if searchConnection then searchConnection:Disconnect() end
end)
