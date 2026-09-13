-- Death Ball | Auto Parry (Delta Mobile - v11)
-- Тайтинг-парирование + обход проблем с загрузкой

local ok, err = pcall(function()

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local GuiService = game:GetService("GuiService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

    -- ⚙️ НАСТРОЙКИ
    local Settings = {
        Enabled = true,
        ParryDistance = 45,      -- Радиус срабатывания (studs)
        MinETA = 0.20,           -- За сколько сек до удара парировать
        MinSpeed = 20,           -- Мин. скорость объекта (studs/s)
        MaxDist = 120,           -- Макс. дистанция поиска
        MaxPing = 0.7,
        OnlyFlyingToMe = true,   -- Только мячи летящие в нас
    }

    local Stats = {
        Attempts = 0,
        Ping = 0,
        Speed = 0,
        Dist = 0,
        Target = "—",
        LastTap = "—",
    }

    -- ═══════════ GUI (ПЕРВЫМ ДЕЛОМ) ═══════════
    local screenGui
    pcall(function()
        local old = game.CoreGui:FindFirstChild("AutoParry_v11")
        if old then old:Destroy() end

        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoParry_v11"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = game.CoreGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 150, 0, 115)
        frame.Position = UDim2.new(0, 10, 0, 10)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Draggable = true
        frame.Parent = screenGui

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(170, 0, 255)
        stroke.Thickness = 2
        stroke.Parent = frame

        local pc
        pc = RunService.Heartbeat:Connect(function()
            if not screenGui.Parent then pc:Disconnect() return end
            local p = (math.sin(tick() * 3) + 1) / 2
            stroke.Thickness = 2 + p * 1.5
            stroke.Color = Color3.fromRGB(170 + p * 40, 0, 255 - p * 30)
        end)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 18)
        title.BackgroundTransparency = 1
        title.Text = "⚔️ Auto Parry v11"
        title.TextColor3 = Color3.fromRGB(200, 150, 255)
        title.TextSize = 11
        title.Font = Enum.Font.GothamBold
        title.Parent = frame

        local function mkLbl(y, txt)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -10, 0, 14)
            l.Position = UDim2.new(0, 5, 0, y)
            l.BackgroundTransparency = 1
            l.Text = txt
            l.TextColor3 = Color3.fromRGB(180, 180, 190)
            l.TextSize = 10
            l.Font = Enum.Font.Gotham
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextTruncate = Enum.TextTruncate.AtEnd
            l.Parent = frame
            return l
        end

        local attemptsLbl = mkLbl(22, "Попытки: 0")
        local pingLbl     = mkLbl(37, "Пинг: 0ms")
        local speedLbl    = mkLbl(52, "Скорость: 0")
        local targetLbl   = mkLbl(67, "Цель: —")
        local methodLbl   = mkLbl(82, "Тап: —")
        local statusLbl   = mkLbl(97, "🟢 РАБОТАЕТ")
        statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
        statusLbl.Font = Enum.Font.GothamBold

        local uc
        uc = RunService.Heartbeat:Connect(function()
            if not screenGui.Parent then uc:Disconnect() return end
            attemptsLbl.Text = "Попытки: " .. Stats.Attempts
            pingLbl.Text = "Пинг: " .. math.floor(Stats.Ping * 1000) .. "ms"
            speedLbl.Text = "Скорость: " .. math.floor(Stats.Speed)
            targetLbl.Text = "Цель: " .. Stats.Target
            methodLbl.Text = "Тап: " .. Stats.LastTap

            if Settings.Enabled then
                statusLbl.Text = "🟢 РАБОТАЕТ"
                statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                statusLbl.Text = "🔴 ВЫКЛ"
                statusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    end)

    print("[v11] GUI OK")

    -- ═══════════ ОБХОД: 4 СПОСОБА ТАПА ═══════════
    -- Пробуем все подряд, какой-то сработает в Delta

    local function tap1_mouse()
        local r = GuiService:GetScreenResolution()
        VirtualInputManager:SendMouseButtonEvent(r.X/2, r.Y/2, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(r.X/2, r.Y/2, 0, false, game, 0)
    end

    local function tap2_touch()
        local r = GuiService:GetScreenResolution()
        VirtualInputManager:SendTouchEvent(1, 1, r.X/2, r.Y/2)
        task.wait(0.01)
        VirtualInputManager:SendTouchEvent(1, 2, r.X/2, r.Y/2)
    end

    local function tap3_virtualuser()
        local VU = game:GetService("VirtualUser")
        VU:CaptureController()
        VU:ClickButton1(Vector2.new(0, 0))
    end

    local function tap4_direct()
        -- Прямая эмуляция через InputObject
        local r = GuiService:GetScreenResolution()
        local mouse = LocalPlayer:GetMouse()
        if mouse and mouse.MoveMouse then
            pcall(function() mouse.MoveMouse(r.X/2, r.Y/2) end)
        end
    end

    local tapMethods = {
        {name="mouse", func=tap1_mouse},
        {name="touch", func=tap2_touch},
        {name="vuser", func=tap3_virtualuser},
        {name="direct", func=tap4_direct},
    }

    local preferredTap = nil

    local function doTap()
        -- Если уже есть рабочий метод — используем только его
        if preferredTap then
            pcall(preferredTap.func)
            Stats.LastTap = preferredTap.name
            return
        end

        -- Иначе пробуем все по очереди
        for _, m in ipairs(tapMethods) do
            local ok2 = pcall(m.func)
            if ok2 then
                Stats.LastTap = m.name
                preferredTap = m
                return
            end
        end
        Stats.LastTap = "ошибка"
    end

    -- ═══════════ ПОИСК ЦЕЛИ (тайтинг) ═══════════
    local function belongsToPlayer(part)
        local p = part.Parent
        local d = 0
        while p and p ~= workspace and d < 8 do
            if p:IsA("Tool") or p:IsA("Accessory") then return true end
            if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
            p = p.Parent
            d = d + 1
        end
        return false
    end

    -- Чёрный список декораций
    local BAD = {"rock","temple","tree","wall","floor","base","brick","stone",
                 "grass","ground","water","lava","sand","snow","cloud","map",
                 "spawn","door","gate","house","building"}

    local function isBad(part)
        local n = string.lower(part.Name)
        for _, w in ipairs(BAD) do
            if string.find(n, w) then return true end
        end
        if part.Size.Magnitude > 25 then return true end
        return false
    end

    local function findTarget()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local myPos = hrp.Position

        local best, bestDist, bestSpeed = nil, math.huge, 0

        -- Сканируем workspace
        local function scan(obj, depth)
            if depth > 4 then return end
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("BasePart") and not child.Anchored then
                    if not belongsToPlayer(child) and not isBad(child) then
                        local sp = child.Velocity.Magnitude
                        if sp >= Settings.MinSpeed then
                            local toMe = myPos - child.Position
                            local dist = toMe.Magnitude
                            if dist < Settings.MaxDist and dist < bestDist then
                                if Settings.OnlyFlyingToMe then
                                    local dot = child.Velocity.Unit:Dot(toMe.Unit)
                                    if dot > 0.25 then
                                        best = child
                                        bestDist = dist
                                        bestSpeed = sp
                                    end
                                else
                                    best = child
                                    bestDist = dist
                                    bestSpeed = sp
                                end
                            end
                        end
                    end
                elseif child:IsA("Model") or child:IsA("Folder") then
                    scan(child, depth + 1)
                end
            end
        end
        scan(workspace, 0)

        return best, bestDist, bestSpeed
    end

    -- ═══════════ ГЛАВНЫЙ ЦИКЛ (тайтинг) ═══════════
    local lastCheck = 0
    local RunService2 = RunService
    RunService2.Heartbeat:Connect(function()
        if not Settings.Enabled then return end

        Stats.Ping = LocalPlayer:GetNetworkPing()
        if Stats.Ping > Settings.MaxPing then return end

        local now = tick()
        if now - lastCheck < 0.05 then return end
        lastCheck = now

        local ball, dist, speed = findTarget()
        if ball then
            Stats.Target = ball.Name
            Stats.Speed = speed
            Stats.Dist = dist

            -- Учитываем пинг: сдвигаем дистанцию
            local adjusted = dist - (Stats.Ping * speed)

            if adjusted < Settings.ParryDistance then
                local eta = math.max(adjusted, 0) / math.max(speed, 1)
                if eta < Settings.MinETA or adjusted < 8 then
                    Stats.Attempts = Stats.Attempts + 1
                    doTap()
                end
            end
        else
            Stats.Target = "—"
            Stats.Speed = 0
            Stats.Dist = 0
        end
    end)

    print("[v11] Тайтинг-цикл запущен")
end)

if not ok then
    print("[AutoParry v11] ОШИБКА: " .. tostring(err))
end
