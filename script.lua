-- [[ СИСТЕМА АНТИ-КРАША И ГЕНЕРАЦИИ ]] --
local MathRandom = math.random
local function generateRandomName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    local name = ""
    for i = 1, MathRandom(12, 18) do
        local randIdx = MathRandom(1, #chars)
        name = name .. string.sub(chars, randIdx, randIdx)
    end
    return name
end

-- [[ СЕРВИСЫ ROBLOX ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- [[ ГЛОБАЛЬНЫЕ НАСТРОЙКИ ]] --
local Settings = {
    AimbotEnabled = false,
    FlickMode = false,
    WallCheck = false,
    AimFOV = 120,
    FlickFOV = 180,
    FlickDelay = 0.01,
    TargetPart = "Head",
    EspLines = false,
    EspCharms = false,
    BHopEnabled = false,
    BHopPower = 1.0,
    ShowAimFOV = false,
    ShowFlickFOV = false,
    InstantReload = false,
    FPSUnlocker = false,
    PerfMonitor = false,
    TriggerbotEnabled = false,
    TriggerbotDelay = 0,
    TriggerbotHitchance = 100
}

-- [[ КЭШ И СЛУЖЕБНЫЕ ПЕРЕМЕННЫЕ ]] --
local ESP_Cache = {}
local fpsTable = {}
local lastShotTime = 0
local triggerShotCooldown = 0.05
local defaultWalkSpeed = 0

-- [[ ГЛОБАЛЬНЫЙ GUI ДЛЯ ESP ]] --
local EspGui = Instance.new("ScreenGui")
EspGui.Name = "EspGui_" .. generateRandomName()
EspGui.ResetOnSpawn = false
EspGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
EspGui.Parent = getSecureContainer()  -- используем ту же функцию, что и для главного меню

-- [[ БЕЗОПАСНАЯ ИНЖЕКЦИЯ GUI ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = generateRandomName()
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function getSecureContainer()
    local target = nil
    pcall(function()
        if game:GetService("CoreGui") then
            target = game:GetService("CoreGui"):FindFirstChildOfClass("Folder") or game:GetService("CoreGui")
        end
    end)
    return target or LocalPlayer:WaitForChild("PlayerGui", 15)
end
ScreenGui.Parent = getSecureContainer()
EspGui.Parent = getSecureContainer()  -- гарантируем, что ESP GUI тоже в безопасном месте

-- ... (остальной код GUI (кнопка, меню, скролл) без изменений, он уже есть в предыдущих версиях) ...

-- [[ ФУНКЦИОНАЛ: ПРОВЕРКА СТЕН ]] --
local function checkWallVisibility(targetPart, enemyCharacter)
    if not Settings.WallCheck then return true end
    if not targetPart or not enemyCharacter then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local distance = direction.Magnitude
    if distance < 1 then return true end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result and result.Instance then
        return result.Instance:IsDescendantOf(enemyCharacter)
    end
    return true
end

-- Безопасный клик
local function secureDeltaClick()
    pcall(function()
        if mouse1click then
            mouse1click()
        elseif mouse1press and mouse1release then
            mouse1press()
            task.wait(0.005)
            mouse1release()
        end
    end)
end

-- Поиск ближайшего игрока к прицелу
local function getClosestPlayer(currentFOV)
    local closestTarget = nil
    local minDistance = currentFOV + 1
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local players = Players:GetPlayers()
    for i = 1, #players do
        local player = players[i]
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local targetPart = char:FindFirstChild(Settings.TargetPart) or char:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distance <= currentFOV and distance < minDistance then
                        if checkWallVisibility(targetPart, char) then
                            minDistance = distance
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- [[ ФУНКЦИОНАЛ: ТРИГГЕРБОТ ]] --
local function runTriggerbot()
    if not Settings.TriggerbotEnabled then return end
    if not Mouse or not Mouse.Target then return end
    pcall(function()
        local instance = Mouse.Target
        local char = instance.Parent
        while char and not char:IsA("Model") do
            char = char.Parent
            if not char then break end
        end
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local player = Players:GetPlayerFromCharacter(char)
        if humanoid and humanoid.Health > 0 and player and player ~= LocalPlayer then
            if player.Team ~= LocalPlayer.Team or player.Team == nil then
                if checkWallVisibility(instance, char) then
                    local currentTime = os.clock()
                    if currentTime - lastShotTime >= triggerShotCooldown then
                        if MathRandom(1, 100) <= Settings.TriggerbotHitchance then
                            lastShotTime = currentTime
                            if Settings.TriggerbotDelay > 0 then
                                task.delay(Settings.TriggerbotDelay, function()
                                    if Mouse.Target and Mouse.Target:IsDescendantOf(char) then 
                                        secureDeltaClick() 
                                    end
                                end)
                            else
                                secureDeltaClick()
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- [[ ФУНКЦИОНАЛ: МГНОВЕННАЯ ПЕРЕЗАРЯДКА ]] --
local function handleInstantReload()
    if not Settings.InstantReload then return end
    pcall(function()
        local char = LocalPlayer.Character
        local targetTools = {}
        if char then 
            for _, v in ipairs(char:GetChildren()) do 
                if v:IsA("Tool") then 
                    table.insert(targetTools, v) 
                end 
            end 
        end
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, v in ipairs(backpack:GetChildren()) do 
                if v:IsA("Tool") then 
                    table.insert(targetTools, v) 
                end 
            end
        end
        for _, tool in ipairs(targetTools) do
            for _, obj in ipairs(tool:GetDescendants()) do
                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    local name = obj.Name:lower()
                    if name:find("reload") or name:find("delay") or name:find("cooldown") or name:find("time") or name:find("duration") then
                        obj.Value = 0
                    elseif name:find("ammo") or name:find("clip") or name:find("mag") then
                        if obj.Value < 30 then 
                            obj.Value = 999
                        end
                    end
                end
            end
        end
    end)
end

-- ==============================================
--  НОВАЯ ЛОГИКА BHop (через WalkSpeed)
-- ==============================================
local function handleBunnyHop()
    if not Settings.BHopEnabled then 
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= defaultWalkSpeed then
                humanoid.WalkSpeed = defaultWalkSpeed
            end
        end
        return 
    end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    if defaultWalkSpeed == 0 then
        defaultWalkSpeed = humanoid.WalkSpeed
        if defaultWalkSpeed == 0 then defaultWalkSpeed = 16 end
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) and humanoid.FloorMaterial == Enum.Material.Air then
        local add = (Settings.BHopPower - 1) * (20 / 14)
        local boost = defaultWalkSpeed + add
        if humanoid.WalkSpeed ~= boost then
            humanoid.WalkSpeed = boost
        end
    else
        if humanoid.WalkSpeed ~= defaultWalkSpeed then
            humanoid.WalkSpeed = defaultWalkSpeed
        end
    end
end

-- ==============================================
--  НОВАЯ ESP: ПОЛНОСТЬЮ НА GUI (Frame)
-- ==============================================

-- Создание GUI-элементов для игрока
local function createESPObjects(player)
    if player == LocalPlayer then return end
    -- Удаляем старые, если есть
    if ESP_Cache[player] then
        pcall(function()
            if ESP_Cache[player].Line then ESP_Cache[player].Line:Destroy() end
            if ESP_Cache[player].Box then ESP_Cache[player].Box:Destroy() end
        end)
        ESP_Cache[player] = nil
    end

    local espData = {}

    -- Линия (Frame, который будет растягиваться и поворачиваться)
    local lineFrame = Instance.new("Frame")
    lineFrame.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    lineFrame.BorderSizePixel = 0
    lineFrame.BackgroundTransparency = 0.5
    lineFrame.Visible = false
    lineFrame.ZIndex = 10
    lineFrame.Parent = EspGui

    -- Бокс (прямоугольник с рамкой)
    local boxFrame = Instance.new("Frame")
    boxFrame.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    boxFrame.BackgroundTransparency = 0.6
    boxFrame.BorderSizePixel = 2
    boxFrame.BorderColor3 = Color3.fromRGB(0, 162, 255)
    boxFrame.Visible = false
    boxFrame.ZIndex = 10
    boxFrame.Parent = EspGui

    espData.Line = lineFrame
    espData.Box = boxFrame
    ESP_Cache[player] = espData
end

-- Очистка ESP для игрока
local function clearESPData(player)
    if ESP_Cache[player] then
        pcall(function()
            if ESP_Cache[player].Line then ESP_Cache[player].Line:Destroy() end
            if ESP_Cache[player].Box then ESP_Cache[player].Box:Destroy() end
        end)
        ESP_Cache[player] = nil
    end
end

-- Обновление позиций и видимости ESP (вызывается каждый кадр)
local function updateESP()
    local screenSize = Camera.ViewportSize
    local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)

    for player, data in pairs(ESP_Cache) do
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if char and humanoid and hrp and humanoid.Health > 0 and player ~= LocalPlayer then
            local isEnemy = (player.Team ~= LocalPlayer.Team or player.Team == nil)
            local showLine = Settings.EspLines and isEnemy
            local showBox = Settings.EspCharms and isEnemy

            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local screenPos = Vector2.new(vector.X, vector.Y)

            -- --- Линия ---
            if showLine and data.Line then
                data.Line.Visible = true
                -- Рассчитываем длину и угол
                local delta = screenPos - center
                local length = delta.Magnitude
                local angle = math.atan2(delta.Y, delta.X)  -- в радианах

                -- Помещаем Frame в центр экрана
                data.Line.Position = UDim2.new(0, center.X, 0, center.Y)
                data.Line.Size = UDim2.new(0, length, 0, 2)  -- толщина 2 пикселя
                data.Line.Rotation = math.deg(angle)  -- поворот в градусах
                -- Смещаем точку вращения в начало (левый край)
                data.Line.AnchorPoint = Vector2.new(0, 0.5)
            elseif data.Line then
                data.Line.Visible = false
            end

            -- --- Бокс ---
            if showBox and data.Box and onScreen then
                data.Box.Visible = true
                -- Размер бокса зависит от расстояния
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                local size = math.clamp(120 / (dist / 10 + 1), 20, 150)
                data.Box.Size = UDim2.new(0, size, 0, size)
                data.Box.Position = UDim2.new(0, screenPos.X - size/2, 0, screenPos.Y - size/2)
                data.Box.AnchorPoint = Vector2.new(0, 0)
            elseif data.Box then
                data.Box.Visible = false
            end
        else
            -- Игрок мёртв или отсутствует – скрываем
            if data.Line then data.Line.Visible = false end
            if data.Box then data.Box.Visible = false end
        end
    end
end

-- Подписка на появление/исчезновение игроков
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(char)
        -- Создаём ESP для нового персонажа
        createESPObjects(player)
    end)
    player.CharacterRemoving:Connect(function()
        clearESPData(player)
    end)
    -- Если персонаж уже есть – создаём сразу
    if player.Character then
        createESPObjects(player)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(clearESPData)
for _, p in ipairs(Players:GetPlayers()) do
    onPlayerAdded(p)
end

-- Flick-Snap
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not Settings.FlickMode then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = getClosestPlayer(Settings.FlickFOV)
        if target then
            task.delay(Settings.FlickDelay, function()
                pcall(function()
                    if target and target.Parent then
                        local humanoid = target.Parent:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                        end
                    end
                end)
            end)
        end
    end
end)

-- [[ ГЛАВНЫЙ ИСПОЛНИТЕЛЬНЫЙ ЦИКЛ ]] --
RunService.RenderStepped:Connect(function()
    local nowClock = os.clock()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- FOV круги (если нужны) – оставляем через Drawing, они не обязательны
    pcall(function()
        if Settings.ShowAimFOV and Aim_Circle then
            Aim_Circle.Position = screenCenter
            Aim_Circle.Radius = Settings.AimFOV
            Aim_Circle.Visible = true
        elseif Aim_Circle then
            Aim_Circle.Visible = false
        end
        if Settings.ShowFlickFOV and Flick_Circle then
            Flick_Circle.Position = screenCenter
            Flick_Circle.Radius = Settings.FlickFOV
            Flick_Circle.Visible = true
        elseif Flick_Circle then
            Flick_Circle.Visible = false
        end
    end)

    -- Аимбот
    if Settings.AimbotEnabled and not Settings.FlickMode then
        local target = getClosestPlayer(Settings.AimFOV)
        if target then
            pcall(function()
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end)
        end
    end

    -- Запуск триггербота, релоада и бхопа
    runTriggerbot()
    handleInstantReload()
    handleBunnyHop()

    -- ОБНОВЛЕНИЕ ESP (GUI)
    updateESP()

    -- Монитор производительности
    if Settings.PerfMonitor then
        table.insert(fpsTable, nowClock)
        while #fpsTable > 0 and fpsTable[1] < nowClock - 1 do 
            table.remove(fpsTable, 1) 
        end
        local curFps = #fpsTable
        local curPing = 0
        pcall(function() 
            local pingStat = Stats.Network.ServerStatsItem["Data Ping"]
            if pingStat then
                curPing = math.floor(pingStat:GetValue()) 
            end
        end)
        local curMem = "0.0"
        pcall(function() 
            curMem = string.format("%.1f", Stats:GetTotalMemoryUsageMb()) 
        end)
        PerfText.Text = string.format("⚡ PERFORMANCE\n\nFPS: %d\nPING: %d ms\nMEM: %s MB", curFps, curPing, curMem)
    end
end)
