-- Death Ball | Auto Parry (Delta Mobile - v8)
-- GUI создаётся первым, всё в pcall, без continue

-- 1. ГЛАВНАЯ ЗАЩИТА - даже если ошибка, GUI покажется
local ok, err = pcall(function()

    -- СЕРВИСЫ
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local GuiService = game:GetService("GuiService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

    -- НАСТРОЙКИ
    local Settings = {
        AutoParryEnabled = true,
        ParryDistance = 60,
        MaxPing = 0.7,
        MinETA = 0.3,
        MinBallSpeed = 20,
        MaxDistance = 100,
    }

    local Stats = {
        Attempts = 0,
        Success = 0,
        Ping = 0,
        Speed = 0,
        Target = "Нет",
    }

    -- 🎨 GUI - СОЗДАЁТСЯ ПЕРВЫМ
    local screenGui
    pcall(function()
        local old = game.CoreGui:FindFirstChild("AutoParryGUI_v8")
        if old then old:Destroy() end

        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoParryGUI_v8"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = game.CoreGui

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

        -- Пульсация через Heartbeat
        local pulseConn
        pulseConn = RunService.Heartbeat:Connect(function()
            if not screenGui.Parent then pulseConn:Disconnect() return end
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
        local targetLbl = makeLabel(82, "Цель: Нет")
        local statusLbl = makeLabel(97, "🟢 АКТИВЕН")
        statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLbl.Font = Enum.Font.GothamBold

        -- Обновление текста
        local updateConn
        updateConn = RunService.Heartbeat:Connect(function()
            if not screenGui.Parent then updateConn:Disconnect() return end
            attemptsLbl.Text = "Попытки: " .. Stats.Attempts
            successLbl.Text = "Успех: " .. Stats.Success
            local pingMs = math.floor(Stats.Ping * 1000)
            pingLbl.Text = "Пинг: " .. pingMs .. "ms"
            speedLbl.Text = "Скорость: " .. math.floor(Stats.Speed)
            targetLbl.Text = "Цель: " .. Stats.Target
        end)
    end)

    print("[AutoParry v8] GUI создан!")

    -- 2. ФУНКЦИЯ ТАПА
    local function tapScreen()
        pcall(function()
            local res = GuiService:GetScreenResolution()
            local x, y = res.X / 2, res.Y / 2
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)
    end

    -- 3. ФИЛЬТР (простой)
    local BAD_WORDS = {"rock", "temple", "tree", "wall", "floor", "base", "player", 
                       "humanoid", "sword", "blade", "weapon", "tool", "handle"}

    local function shouldIgnore(part)
        -- Родитель - Tool?
        local p = part.Parent
        local depth = 0
        while p and p ~= workspace and depth < 8 do
            if p:IsA("Tool") then return true end
            if p:IsA("Accessory") then return true end
            if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
            p = p.Parent
            depth = depth + 1
        end
        
        -- Чёрный список имён
        local n = string.lower(part.Name)
        for _, w in ipairs(BAD_WORDS) do
            if string.find(n, w) then return true end
        end
        
        -- Слишком большой?
        if part.Size.Magnitude > 30 then return true end
        
        return false
    end

    -- 4. ПОИСК МЯЧА
    local function findBall()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        
        local myPos = hrp.Position
        local best, bestDist, bestSpeed = nil, math.huge, 0
        
        local children = workspace:GetChildren()
        for i = 1, #children do
            local obj = children[i]
            local part = nil
            if obj:IsA("BasePart") then
                part = obj
            elseif obj:IsA("Model") and obj.PrimaryPart then
                part = obj.PrimaryPart
            end
            
            if part and not part.Anchored and not shouldIgnore(part) then
                local speed = part.Velocity.Magnitude
                if speed >= Settings.MinBallSpeed then
                    local toMe = myPos - part.Position
                    local dist = toMe.Magnitude
                    if dist < Settings.MaxDistance and dist < bestDist then
                        local dot = part.Velocity.Unit:Dot(toMe.Unit)
                        if dot > 0.3 then
                            best = part
                            bestDist = dist
                            bestSpeed = speed
                        end
                    end
                end
            end
        end
        return best, bestDist, bestSpeed
    end

    -- 5. ОСНОВНОЙ ЦИКЛ (на Heartbeat, но поиск раз в 0.1 сек)
    local lastSearch = 0
    local mainConn
    mainConn = RunService.Heartbeat:Connect(function()
        if not Settings.AutoParryEnabled then return end
        
        Stats.Ping = LocalPlayer:GetNetworkPing()
        if Stats.Ping > Settings.MaxPing then return end
        
        local now = tick()
        if now - lastSearch < 0.1 then return end
        lastSearch = now
        
        local ball, dist, speed = findBall()
        if ball then
            Stats.Target = ball.Name
            Stats.Speed = speed
            
            local adjusted = dist - (Stats.Ping * speed)
            if adjusted < Settings.ParryDistance then
                local eta = math.max(adjusted, 0) / math.max(speed, 1)
                if eta < Settings.MinETA or adjusted < 10 then
                    Stats.Attempts = Stats.Attempts + 1
                    Stats.Success = Stats.Success + 1
                    tapScreen()
                end
            end
        else
            Stats.Target = "Нет"
            Stats.Speed = 0
        end
    end)

    print("[AutoParry v8] Полностью загружен!")
end)

if not ok then
    print("[AutoParry v8] ОШИБКА: " .. tostring(err))
end
