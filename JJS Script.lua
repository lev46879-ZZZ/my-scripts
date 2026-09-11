-- ==========================================================
--  APEX HUB v7.0 | JJS CURSED ENERGY EDITION
--  Стиль Jujutsu Shenanigans | Фикс всех багов
-- ==========================================================

print("[APEX v7] Загрузка скрипта в стиле JJS...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Drawing = drawing or Drawing or (getgenv and getgenv().drawing)
local Camera = workspace.CurrentCamera

-- ==========================================================
--  КОНФИГ
-- ==========================================================
local Config = {
    AimbotEnabled = false,
    FOV = 300,
    ShowFOV = true,
    Smoothness = 0.08,
    TargetMode = "FOV",
    TargetPart = "Head",
    WallCheck = true,
    RotateCharacter = true, -- Поворачивать модельку персонажа
    
    AutoBlock = false,
    AutoBlockDistance = 15,
    
    AuraEnabled = true,
    WingsEnabled = true,
    AuraColor = Color3.fromRGB(150, 0, 255),
    WingsColor = Color3.fromRGB(80, 0, 120),
    WingsTransparency = 0.2,
    AuraSize = 6,
    AuraRate = 35,
    
    EspPlayers = false,
    ShowTracers = true,
    EspColor = Color3.fromRGB(255, 50, 50),
    
    Invisibility = false,
    NoCooldown = false,
    
    FlingSpeed = 0.03, -- Скорость телепортов при флинге
    FlingIterations = 15, -- Количество толчков
}

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Позиция для возврата из невидимости
local SavedCFrame = Root.CFrame
local IsInvisible = false

-- ==========================================================
--  НЕВИДИМОСТЬ (ПЕРЕДЕЛАНА - БЕЗОПАСНАЯ)
-- ==========================================================
local function FindSafeSpot()
    -- Ищем безопасное место далеко от карты
    -- Не вниз (киллбрики), а в сторону
    local mapCenter = Vector3.new(0, 50, 0)
    local directions = {
        Vector3.new(5000, 100, 0),
        Vector3.new(-5000, 100, 0),
        Vector3.new(0, 100, 5000),
        Vector3.new(0, 100, -5000),
        Vector3.new(3000, 500, 3000),
        Vector3.new(-3000, 500, -3000),
    }
    
    -- Проверяем каждое направление на наличие земли
    for _, dir in ipairs(directions) do
        local ray = workspace:Raycast(dir, Vector3.new(0, -1000, 0), RaycastParams.new())
        if ray then
            return ray.Position + Vector3.new(0, 5, 0)
        end
    end
    
    -- Запасной вариант - высоко в небе
    return Vector3.new(0, 2000, 0)
end

local function SetInvisibility(state)
    if not Character or not Root or not Root.Parent then return end
    
    local myHrp = Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    if state then
        -- Сохраняем текущую позицию
        SavedCFrame = myHrp.CFrame
        
        -- Находим безопасное место
        local safePos = FindSafeSpot()
        
        -- Телепортируем персонажа
        myHrp.CFrame = CFrame.new(safePos)
        
        -- Замораживаем чтобы не упасть
        pcall(function()
            Humanoid.PlatformStand = true
        end)
        
        -- Делаем прозрачным для себя
        pcall(function()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.LocalTransparencyModifier = 0.5
                end
            end
        end)
        
        IsInvisible = true
        print("[APEX] Невидимость ВКЛ! Ты телепортирован в безопасное место.")
        
    else
        -- Возвращаемся
        myHrp.CFrame = SavedCFrame
        
        -- Размораживаем
        pcall(function()
            Humanoid.PlatformStand = false
        end)
        
        -- Убираем прозрачность
        pcall(function()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.LocalTransparencyModifier = 0
                end
            end
        end)
        
        IsInvisible = false
        print("[APEX] Невидимость ВЫКЛ! Ты возвращён.")
    end
end

-- ==========================================================
--  FLING (ПЕРЕДЕЛАН ПО МЕТОДУ РАБОЧИХ СКРИПТОВ)
-- ==========================================================
local IsFlinging = false

local function FlingPlayer(targetPlayer)
    if IsFlinging then 
        print("[APEX] Флинг уже выполняется!")
        return false 
    end
    
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    
    local targetChar = targetPlayer.Character
    if not targetChar then return false end
    
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
    if not targetHrp then return false end
    
    local myHrp = Character:FindFirstChild("HumanoidRootPart")
    local myHumanoid = Character:FindFirstChildOfClass("Humanoid")
    if not myHrp then return false end
    
    IsFlinging = true
    local oldCFrame = myHrp.CFrame
    
    task.spawn(function()
        -- Шаг 1: Создаём мощное вращение (спин)
        local spin = Instance.new("BodyAngularVelocity")
        spin.Name = "FlingSpin"
        spin.MaxTorque = Vector3.new(0, math.huge, 0)
        spin.AngularVelocity = Vector3.new(0, 150, 0)
        spin.Parent = myHrp
        
        -- Шаг 2: Отключаем коллизию своего персонажа (чтобы не застрять)
        pcall(function()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        
        -- Шаг 3: Множественные телепорты к цели (накопление импульса)
        for i = 1, Config.FlingIterations do
            if not targetHrp or not targetHrp.Parent then break end
            
            -- Телепортируемся очень близко к цели с разных сторон
            local angle = (i / Config.FlingIterations) * math.pi * 2
            local offset = CFrame.new(math.cos(angle) * 2, 0, math.sin(angle) * 2)
            
            myHrp.CFrame = targetHrp.CFrame * offset
            task.wait(Config.FlingSpeed)
        end
        
        -- Шаг 4: Финальный мощный толчок
        if targetHrp and targetHrp.Parent then
            -- Пытаемся напрямую запустить цель
            pcall(function()
                local flingForce = Instance.new("BodyVelocity")
                flingForce.Name = "FlingForce"
                flingForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flingForce.Velocity = Vector3.new(
                    math.random(-300, 300),
                    500,
                    math.random(-300, 300)
                )
                flingForce.Parent = targetHrp
                
                local flingSpin = Instance.new("BodyAngularVelocity")
                flingSpin.Name = "FlingTargetSpin"
                flingSpin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                flingSpin.AngularVelocity = Vector3.new(100, 100, 100)
                flingSpin.Parent = targetHrp
                
                task.delay(2, function()
                    if flingForce and flingForce.Parent then flingForce:Destroy() end
                    if flingSpin and flingSpin.Parent then flingSpin:Destroy() end
                end)
            end)
            
            -- Также толкаем через свой персонаж
            myHrp.CFrame = targetHrp.CFrame
            myHrp.AssemblyLinearVelocity = Vector3.new(
                math.random(-200, 200),
                300,
                math.random(-200, 200)
            )
        end
        
        -- Шаг 5: Возвращаемся на место
        task.delay(0.5, function()
            if spin and spin.Parent then spin:Destroy() end
            
            -- Включаем коллизию обратно
            pcall(function()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end)
            
            if myHrp and myHrp.Parent then
                myHrp.CFrame = oldCFrame
                myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            
            IsFlinging = false
        end)
    end)
    
    return true
end

-- ==========================================================
--  АУРА И КРЫЛЬЯ
-- ==========================================================
local AuraRing = Instance.new("Part")
AuraRing.Shape = Enum.PartType.Cylinder
AuraRing.Size = Vector3.new(0.15, Config.AuraSize, Config.AuraSize)
AuraRing.Anchored = true
AuraRing.CanCollide = false
AuraRing.CanQuery = false
AuraRing.Massless = true
AuraRing.Color = Config.AuraColor
AuraRing.Material = Enum.Material.Neon
AuraRing.Transparency = 0.3
AuraRing.Parent = workspace

local AuraAttachment = Instance.new("Attachment")
AuraAttachment.Parent = Root

local AuraParticles = Instance.new("ParticleEmitter")
AuraParticles.Parent = AuraAttachment
AuraParticles.Texture = "rbxassetid://243098098"
AuraParticles.Rate = Config.AuraRate
AuraParticles.Lifetime = NumberRange.new(0.8, 1.5)
AuraParticles.Speed = NumberRange.new(2, 5)
AuraParticles.SpreadAngle = Vector2.new(15, 15)
AuraParticles.Color = ColorSequence.new(Config.AuraColor)
AuraParticles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
AuraParticles.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})
AuraParticles.LightEmission = 1

local WingParts = {}
local WingBeams = {}

local function CreateWing(side)
    local segments = {}
    for i = 1, 3 do
        local Seg = Instance.new("Part")
        Seg.Size = Vector3.new(0.2, 3 - i * 0.5, 1.2)
        Seg.Anchored = true
        Seg.CanCollide = false
        Seg.CanQuery = false
        Seg.Massless = true
        Seg.Color = Config.WingsColor
        Seg.Material = Enum.Material.Neon
        Seg.Transparency = Config.WingsTransparency
        Seg.Parent = workspace
        
        local offsetX = (i - 1) * 0.9 * side
        local offsetY = 1.5 + i * 0.3
        local baseOffset = CFrame.new(offsetX, offsetY, 0.8) * CFrame.Angles(0, math.rad(-30 * side), math.rad(20 * side))
        
        table.insert(WingParts, { Part = Seg, BaseOffset = baseOffset })
        table.insert(segments, Seg)
    end
    
    for i = 1, #segments - 1 do
        local A0 = Instance.new("Attachment", segments[i])
        local A1 = Instance.new("Attachment", segments[i + 1])
        local Beam = Instance.new("Beam")
        Beam.Attachment0 = A0
        Beam.Attachment1 = A1
        Beam.Width0 = 1.2
        Beam.Width1 = 1.2
        Beam.Color = ColorSequence.new(Config.WingsColor)
        Beam.Transparency = NumberSequence.new(Config.WingsTransparency)
        Beam.LightEmission = 1
        Beam.FaceCamera = true
        Beam.Parent = segments[i]
        table.insert(WingBeams, Beam)
    end
end

CreateWing(1)
CreateWing(-1)

RunService.Heartbeat:Connect(function()
    if not Root or not Root.Parent or IsInvisible then return end
    if Config.AuraEnabled then
        AuraRing.CFrame = Root.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, math.rad(90))
    end
    if Config.WingsEnabled then
        for _, w in ipairs(WingParts) do
            w.Part.CFrame = Root.CFrame * w.BaseOffset
        end
    end
end)

-- ==========================================================
--  FOV CIRCLE
-- ==========================================================
local FovCircle = nil
if Drawing then
    pcall(function()
        FovCircle = Drawing.new("Circle")
        FovCircle.Thickness = 2
        FovCircle.NumSides = 100
        FovCircle.Radius = Config.FOV
        FovCircle.Filled = false
        FovCircle.Color = Color3.fromRGB(180, 0, 255)
        FovCircle.Transparency = 0.7
        FovCircle.Visible = false
    end)
end

if FovCircle then
    RunService.RenderStepped:Connect(function()
        FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FovCircle.Radius = Config.FOV
        FovCircle.Visible = Config.AimbotEnabled and Config.ShowFOV
    end)
end

-- ==========================================================
--  ESP
-- ==========================================================
local EspTable = {}

local function GetEspDraw(player)
    if not Drawing then return nil end
    if not EspTable[player] then
        EspTable[player] = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Hp = Drawing.new("Text"),
            Tracer = Drawing.new("Line"),
        }
        EspTable[player].Box.Thickness = 1.5
        EspTable[player].Box.Filled = false
        EspTable[player].Box.Color = Config.EspColor
        EspTable[player].Name.Size = 14
        EspTable[player].Name.Center = true
        EspTable[player].Name.Outline = true
        EspTable[player].Name.Color = Color3.fromRGB(255, 255, 255)
        EspTable[player].Hp.Size = 12
        EspTable[player].Hp.Center = true
        EspTable[player].Hp.Outline = true
        EspTable[player].Hp.Color = Color3.fromRGB(0, 255, 100)
        EspTable[player].Tracer.Thickness = 2
        EspTable[player].Tracer.Color = Config.EspColor
        EspTable[player].Tracer.Transparency = 0.8
    end
    return EspTable[player]
end

if Drawing then
    RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            local draw = EspTable[player]
            if player ~= LocalPlayer and Config.EspPlayers then
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            draw = GetEspDraw(player)
                            if draw then
                                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                                local scale = 1200 / dist
                                local boxSize = Vector2.new(scale * 1.5, scale * 2.5)
                                
                                draw.Box.Size = boxSize
                                draw.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                                draw.Box.Color = Config.EspColor
                                draw.Box.Visible = true
                                
                                draw.Name.Text = player.Name
                                draw.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 20)
                                draw.Name.Visible = true
                                
                                draw.Hp.Text = math.floor(hum.Health) .. " HP"
                                draw.Hp.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 5)
                                draw.Hp.Visible = true
                                
                                if Config.ShowTracers then
                                    draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                    draw.Tracer.To = Vector2.new(pos.X, pos.Y)
                                    draw.Tracer.Visible = true
                                else
                                    draw.Tracer.Visible = false
                                end
                            end
                        else
                            if draw then draw.Box.Visible = false; draw.Name.Visible = false; draw.Hp.Visible = false; draw.Tracer.Visible = false end
                        end
                    else
                        if draw then draw.Box.Visible = false; draw.Name.Visible = false; draw.Hp.Visible = false; draw.Tracer.Visible = false end
                    end
                end
            else
                if draw then draw.Box.Visible = false; draw.Name.Visible = false; draw.Hp.Visible = false; draw.Tracer.Visible = false end
            end
        end
    end)
end

-- ==========================================================
--  AIMBOT (ПЕРЕДЕЛАН - ВСЕГДА ПРЕСЛЕДУЕТ ЦЕЛЬ)
-- ==========================================================
local function GetAlivePlayers()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                table.insert(list, { Player = p, Hum = hum, Root = hrp })
            end
        end
    end
    return list
end

local function IsVisible(targetPart)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local distance = direction.Magnitude
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction.Unit * distance, raycastParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function PickTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestScore = nil, nil
    
    for _, info in ipairs(GetAlivePlayers()) do
        local part = info.Player.Character:FindFirstChild(Config.TargetPart) or info.Player.Character:FindFirstChild("Head")
        if part then
            if IsVisible(part) then
                -- НЕ проверяем onScreen! Цель может быть за экраном
                local screenPos = Camera:WorldToViewportPoint(part.Position)
                local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                
                -- Увеличенный радиус поиска (в 3 раза больше FOV для преследования)
                if fovDist <= Config.FOV * 3 then
                    local score
                    if Config.TargetMode == "FOV" then score = fovDist
                    elseif Config.TargetMode == "LowestHP" then score = info.Hum.Health
                    elseif Config.TargetMode == "HighestHP" then score = -info.Hum.Health
                    elseif Config.TargetMode == "Distance" then score = (Camera.CFrame.Position - part.Position).Magnitude
                    end
                    
                    if bestScore == nil or score < bestScore then
                        best, bestScore = { part = part, info = info, score = score }, score
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function(dt)
    if not Config.AimbotEnabled or IsInvisible then return end
    
    local targetData = PickTarget()
    if targetData then
        local target = targetData.part
        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.lookAt(camPos, target.Position)
        
        -- Плавное наведение камеры (ВСЕГДА, даже за экраном)
        local alpha = math.clamp(1 - Config.Smoothness, 0.01, 1)
        local smoothAlpha = 1 - (1 - alpha) ^ (dt * 60)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, smoothAlpha)
        
        -- Поворачиваем модельку персонажа к цели (для ShiftLock)
        if Config.RotateCharacter and Root and Root.Parent then
            local rootCF = CFrame.lookAt(Root.Position, Vector3.new(target.Position.X, Root.Position.Y, target.Position.Z))
            Root.CFrame = Root.CFrame:Lerp(rootCF, smoothAlpha)
        end
    end
end)

-- ==========================================================
--  AUTO BLOCK / NO COOLDOWN
-- ==========================================================
RunService.Heartbeat:Connect(function()
    if Config.AutoBlock and not IsInvisible then
        local nearestDist = math.huge
        for _, info in ipairs(GetAlivePlayers()) do
            local dist = (info.Root.Position - Root.Position).Magnitude
            if dist < nearestDist then nearestDist = dist end
        end
        
        if nearestDist < Config.AutoBlockDistance then
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
        end
    end
    
    if Config.NoCooldown then
        pcall(function()
            for _, desc in ipairs(Character:GetDescendants()) do
                if desc:IsA("NumberValue") or desc:IsA("IntValue") then
                    local name = desc.Name:lower()
                    if name:find("cooldown") or name:find("cd") or name:find("timer") then
                        desc.Value = 0
                    end
                end
            end
        end)
    end
end)

-- ==========================================================
--  GUI В СТИЛЕ JJS (CURSED ENERGY THEME)
-- ==========================================================
print("[APEX v7] Создание GUI в стиле JJS...")

-- Цветовая палитра JJS
local JJSColors = {
    Background = Color3.fromRGB(10, 8, 18),
    BackgroundLight = Color3.fromRGB(18, 14, 30),
    Panel = Color3.fromRGB(15, 12, 25),
    Accent = Color3.fromRGB(139, 0, 255),      -- Проклятая энергия
    AccentDark = Color3.fromRGB(75, 0, 130),
    Red = Color3.fromRGB(255, 20, 60),          -- Красный домен
    Gold = Color3.fromRGB(255, 200, 50),        -- Золотой
    Text = Color3.fromRGB(220, 210, 255),
    TextDim = Color3.fromRGB(140, 130, 170),
    Green = Color3.fromRGB(50, 255, 130),
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexJJS"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ========== КНОПКА В СТИЛЕ JJS (КРУГ С ПРОКЛЯТОЙ ЭНЕРГИЕЙ) ==========
local FloatBtnContainer = Instance.new("Frame")
FloatBtnContainer.Size = UDim2.new(0, 75, 0, 75)
FloatBtnContainer.Position = UDim2.new(0, 12, 0.45, -37)
FloatBtnContainer.BackgroundTransparency = 1
FloatBtnContainer.Active = true
FloatBtnContainer.Draggable = true
FloatBtnContainer.Parent = ScreenGui

-- Внешнее свечение
local GlowFrame = Instance.new("Frame")
GlowFrame.Size = UDim2.new(1, 16, 1, 16)
GlowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
GlowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
GlowFrame.BackgroundColor3 = JJSColors.Accent
GlowFrame.BackgroundTransparency = 0.7
GlowFrame.BorderSizePixel = 0
GlowFrame.Parent = FloatBtnContainer
Instance.new("UICorner", GlowFrame).CornerRadius = UDim.new(1, 0)

-- Основная кнопка
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(1, 0, 1, 0)
FloatBtn.BackgroundColor3 = JJSColors.Background
FloatBtn.Text = ""
FloatBtn.BorderSizePixel = 0
FloatBtn.Parent = FloatBtnContainer
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

-- Градиент кнопки
local btnGradient = Instance.new("UIGradient", FloatBtn)
btnGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, JJSColors.AccentDark),
    ColorSequenceKeypoint.new(0.5, JJSColors.Background),
    ColorSequenceKeypoint.new(1, JJSColors.AccentDark)
})
btnGradient.Rotation = 45

-- Обводка
local btnStroke = Instance.new("UIStroke", FloatBtn)
btnStroke.Color = JJSColors.Accent
btnStroke.Thickness = 2.5

-- Символ дзюдзюцу
local btnSymbol = Instance.new("TextLabel")
btnSymbol.Size = UDim2.new(1, 0, 0, 30)
btnSymbol.Position = UDim2.new(0, 0, 0, 8)
btnSymbol.BackgroundTransparency = 1
btnSymbol.Text = "◈"
btnSymbol.TextColor3 = JJSColors.Accent
btnSymbol.Font = Enum.Font.GothamBlack
btnSymbol.TextSize = 28
btnSymbol.Parent = FloatBtnContainer

-- Название
local btnText = Instance.new("TextLabel")
btnText.Size = UDim2.new(1, 0, 0, 16)
btnText.Position = UDim2.new(0, 0, 0, 42)
btnText.BackgroundTransparency = 1
btnText.Text = "APEX"
btnText.TextColor3 = JJSColors.Text
btnText.Font = Enum.Font.GothamBlack
btnText.TextSize = 11
btnText.TextStrokeTransparency = 0
btnText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
btnText.Parent = FloatBtnContainer

-- Анимация пульсации свечения
task.spawn(function()
    while FloatBtnContainer.Parent do
        local pulse1 = TweenService:Create(GlowFrame, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 24, 1, 24)
        })
        local pulse2 = TweenService:Create(GlowFrame, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.7,
            Size = UDim2.new(1, 16, 1, 16)
        })
        pulse1:Play()
        pulse1.Completed:Wait()
        pulse2:Play()
        pulse2.Completed:Wait()
    end
end)

-- Вращение градиента
task.spawn(function()
    local rot = 45
    while FloatBtnContainer.Parent do
        rot = rot + 0.5
        btnGradient.Rotation = rot
        task.wait(0.03)
    end
end)

-- Hover
FloatBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatBtnContainer, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 85, 0, 85)
    }):Play()
end)

FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatBtnContainer, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 75, 0, 75)
    }):Play()
end)

-- ========== ГЛАВНОЕ МЕНЮ В СТИЛЕ JJS ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 440, 0, 600)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -300)
MainFrame.BackgroundColor3 = JJSColors.Background
MainFrame.BackgroundTransparency = 0.02
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = JJSColors.Accent
mainStroke.Thickness = 2

-- Декоративная линия сверху
local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, -40, 0, 3)
TopLine.Position = UDim2.new(0, 20, 0, 55)
TopLine.BorderSizePixel = 0
TopLine.Parent = MainFrame

local topLineGradient = Instance.new("UIGradient", TopLine)
topLineGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.2, JJSColors.Accent),
    ColorSequenceKeypoint.new(0.5, JJSColors.Red),
    ColorSequenceKeypoint.new(0.8, JJSColors.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
})

-- Заголовок
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 55)
TitleFrame.BackgroundTransparency = 1
TitleFrame.Parent = MainFrame

local TitleSymbol = Instance.new("TextLabel")
TitleSymbol.Size = UDim2.new(0, 40, 1, 0)
TitleSymbol.Position = UDim2.new(0, 15, 0, 0)
TitleSymbol.BackgroundTransparency = 1
TitleSymbol.Text = "◈"
TitleSymbol.TextColor3 = JJSColors.Accent
TitleSymbol.Font = Enum.Font.GothamBlack
TitleSymbol.TextSize = 32
TitleSymbol.Parent = TitleFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 60, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "APEX HUB"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = JJSColors.Text
Title.Parent = TitleFrame

local titleGradient = Instance.new("UIGradient", Title)
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, JJSColors.Accent),
    ColorSequenceKeypoint.new(0.5, JJSColors.Red),
    ColorSequenceKeypoint.new(1, JJSColors.Accent)
})

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -100, 0, 14)
SubTitle.Position = UDim2.new(0, 60, 0, 34)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "JUJUTSU SHENANIGANS"
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.TextColor3 = JJSColors.TextDim
SubTitle.Parent = TitleFrame

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -44, 0, 10)
CloseBtn.BackgroundColor3 = JJSColors.Red
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0, Size = UDim2.new(0, 40, 0, 40)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2, Size = UDim2.new(0, 36, 0, 36)}):Play()
end)

-- Функция открытия/закрытия
local function ToggleMenu()
    if MainFrame.Visible then
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            MainFrame.Visible = false
            MainFrame.Size = UDim2.new(0, 440, 0, 600)
            MainFrame.BackgroundTransparency = 0.02
        end)
    else
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 440, 0, 600)
        })
        tween:Play()
    end
end

CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)

-- ========== ВКЛАДКИ СЛЕВА В СТИЛЕ JJS ==========
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 105, 1, -110)
TabBar.Position = UDim2.new(0, 10, 0, 95)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tabs = {}
local Pages = {}
local tabNames = { "Aimbot", "Fling", "Visuals", "ESP", "Misc" }
local tabIcons = { "⊕", "◎", "✦", "◉", "⚙" }

for i, name in ipairs(tabNames) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 44)
    TabBtn.Position = UDim2.new(0, 0, 0, (i-1) * 50)
    TabBtn.BackgroundColor3 = JJSColors.Panel
    TabBtn.Text = tabIcons[i] .. "  " .. name
    TabBtn.TextColor3 = JJSColors.TextDim
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
    
    local tabStroke = Instance.new("UIStroke", TabBtn)
    tabStroke.Color = JJSColors.Accent
    tabStroke.Thickness = 0
    tabStroke.Transparency = 0.5
    
    -- Индикатор слева
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, 0, 0.2, 0)
    indicator.BackgroundColor3 = JJSColors.Accent
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = TabBtn
    
    Tabs[name] = {Btn = TabBtn, Stroke = tabStroke, Indicator = indicator}
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -130, 1, -110)
    Page.Position = UDim2.new(0, 120, 0, 95)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = JJSColors.Accent
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 1600)
    Page.BorderSizePixel = 0
    Page.Parent = MainFrame
    Pages[name] = Page
    
    TabBtn.MouseEnter:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = JJSColors.BackgroundLight}):Play()
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = JJSColors.Panel}):Play()
        end
    end)
end

Pages["Aimbot"].Visible = true
Tabs["Aimbot"].Btn.BackgroundColor3 = JJSColors.AccentDark
Tabs["Aimbot"].Btn.TextColor3 = JJSColors.Text
Tabs["Aimbot"].Stroke.Thickness = 1.5
Tabs["Aimbot"].Indicator.Visible = true

for name, data in pairs(Tabs) do
    data.Btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do 
            p.Visible = false
            TweenService:Create(Tabs[n].Btn, TweenInfo.new(0.2), {BackgroundColor3 = JJSColors.Panel}):Play()
            Tabs[n].Btn.TextColor3 = JJSColors.TextDim
            Tabs[n].Stroke.Thickness = 0
            Tabs[n].Indicator.Visible = false
        end
        Pages[name].Visible = true
        TweenService:Create(data.Btn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            BackgroundColor3 = JJSColors.AccentDark,
            Size = UDim2.new(1.05, 0, 0, 44)
        }):Play()
        data.Btn.TextColor3 = JJSColors.Text
        task.wait(0.15)
        TweenService:Create(data.Btn, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 44)}):Play()
        data.Stroke.Thickness = 1.5
        data.Indicator.Visible = true
    end)
end

-- ========== УТИЛИТЫ UI В СТИЛЕ JJS ==========
local function CreateButton(parent, text, y, color, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -10, 0, 40)
    B.Position = UDim2.new(0, 5, 0, y)
    B.BackgroundColor3 = color or JJSColors.Panel
    B.Text = text
    B.TextColor3 = JJSColors.Text
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    B.Parent = parent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)
    local bStroke = Instance.new("UIStroke", B)
    bStroke.Color = JJSColors.Accent
    bStroke.Thickness = 1
    bStroke.Transparency = 0.5
    
    B.MouseEnter:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {BackgroundColor3 = JJSColors.BackgroundLight}):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.15), {Thickness = 2, Transparency = 0}):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {BackgroundColor3 = color or JJSColors.Panel}):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.15), {Thickness = 1, Transparency = 0.5}):Play()
    end)
    
    B.MouseButton1Click:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.08), {Size = UDim2.new(1, -14, 0, 38)}):Play()
        task.wait(0.08)
        TweenService:Create(B, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Size = UDim2.new(1, -10, 0, 40)}):Play()
        pcall(callback, B)
    end)
    return B
end

local function CreateLabel(parent, text, y, size)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -10, 0, size or 18)
    L.Position = UDim2.new(0, 5, 0, y)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = JJSColors.TextDim
    L.Font = Enum.Font.GothamBold
    L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
    return L
end

local function CreateSectionLabel(parent, text, y)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 26)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, 0, 1, 0)
    L.BackgroundTransparency = 1
    L.Text = "◈ " .. text
    L.TextColor3 = JJSColors.Accent
    L.Font = Enum.Font.GothamBlack
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = Container
    
    return Container
end

local function CreateSlider(parent, text, y, min, max, default, isFloat, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 50)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = JJSColors.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -10, 0, 8)
    Track.Position = UDim2.new(0, 5, 0, 30)
    Track.BackgroundColor3 = JJSColors.BackgroundLight
    Track.BorderSizePixel = 0
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = JJSColors.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local fillGradient = Instance.new("UIGradient", Fill)
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, JJSColors.AccentDark),
        ColorSequenceKeypoint.new(1, JJSColors.Accent)
    })
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 22, 0, 22)
    Knob.Position = UDim2.new((default - min) / (max - min), -11, 0.5, -11)
    Knob.BackgroundColor3 = JJSColors.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local KnobStroke = Instance.new("UIStroke", Knob)
    KnobStroke.Color = JJSColors.Accent
    KnobStroke.Thickness = 2
    
    local function Update(inputX)
        local rel = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        if not isFloat then val = math.floor(val + 0.5) end
        TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(rel, 0, 1, 0)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.05), {Position = UDim2.new(rel, -11, 0.5, -11)}):Play()
        Label.Text = text .. ": " .. (isFloat and string.format("%.2f", val) or tostring(val))
        pcall(callback, val)
    end
    
    local dragging = false
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input.Position.X)
        end
    end)
    Track.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            Update(input.Position.X)
        end
    end)
    Track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function CreateSelector(parent, text, y, options, default, callback)
    CreateLabel(parent, text, y, 16)
    local current = default
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 36)
    Btn.Position = UDim2.new(0, 5, 0, y + 18)
    Btn.BackgroundColor3 = JJSColors.Panel
    Btn.Text = "▸ " .. current
    Btn.TextColor3 = JJSColors.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, v in ipairs(options) do if v == current then idx = i break end end
        idx = idx + 1
        if idx > #options then idx = 1 end
        current = options[idx]
        Btn.Text = "▸ " .. current
        pcall(callback, current)
    end)
    return Btn
end

-- ========== СТРАНИЦА FLING ==========
local FlingPage = Pages["Fling"]
local y = 10

CreateSectionLabel(FlingPage, "CURSED FLING", y); y = y + 30
CreateLabel(FlingPage, "Телепорт → Спин → Толчок → Космос", y, 16); y = y + 22
CreateLabel(FlingPage, "Выбери цель из списка:", y, 16); y = y + 25

local selectedFlingTarget = nil
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, -10, 0, 180)
playerListFrame.Position = UDim2.new(0, 5, 0, y)
playerListFrame.BackgroundTransparency = 1
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 3
playerListFrame.ScrollBarImageColor3 = JJSColors.Accent
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.Parent = FlingPage

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 5)
playerListLayout.Parent = playerListFrame

local function RefreshPlayerList()
    for _, child in ipairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerBtn = Instance.new("TextButton")
            PlayerBtn.Size = UDim2.new(1, -5, 0, 34)
            PlayerBtn.BackgroundColor3 = JJSColors.Panel
            PlayerBtn.Text = "  ⊕ " .. player.Name
            PlayerBtn.TextColor3 = JJSColors.Text
            PlayerBtn.Font = Enum.Font.GothamBold
            PlayerBtn.TextSize = 12
            PlayerBtn.TextXAlignment = Enum.TextXAlignment.Left
            PlayerBtn.Parent = playerListFrame
            Instance.new("UICorner", PlayerBtn).CornerRadius = UDim.new(0, 8)
            
            PlayerBtn.MouseButton1Click:Connect(function()
                selectedFlingTarget = player
                for _, btn in ipairs(playerListFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = JJSColors.Panel}):Play()
                    end
                end
                TweenService:Create(PlayerBtn, TweenInfo.new(0.15), {BackgroundColor3 = JJSColors.AccentDark}):Play()
            end)
        end
    end
    
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10)
end

RefreshPlayerList()
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

y = y + 190

local FlingBtn = CreateButton(FlingPage, "◎ ЗАПУСТИТЬ В КОСМОС", y, JJSColors.Red, function(self)
    if IsFlinging then
        self.Text = "⚠ ФЛИНГ УЖЕ ВЫПОЛНЯЕТСЯ..."
        task.delay(2, function() self.Text = "◎ ЗАПУСТИТЬ В КОСМОС" end)
        return
    end
    
    if selectedFlingTarget and selectedFlingTarget.Parent then
        self.Text = "⏳ ВЫПОЛНЯЕТСЯ..."
        self.BackgroundColor3 = JJSColors.Gold
        
        local success = pcall(function() FlingPlayer(selectedFlingTarget) end)
        
        if success then
            self.Text = "✅ ЦЕЛЬ ЗАПУЩЕНА!"
            self.BackgroundColor3 = JJSColors.Green
        else
            self.Text = "❌ ОШИБКА ФЛИНГА"
            self.BackgroundColor3 = JJSColors.Red
        end
        
        task.delay(2, function()
            self.Text = "◎ ЗАПУСТИТЬ В КОСМОС"
            self.BackgroundColor3 = JJSColors.Red
        end)
    else
        self.Text = "⚠ ВЫБЕРИ ИГРОКА ИЗ СПИСКА"
        self.BackgroundColor3 = JJSColors.Gold
        task.delay(2, function()
            self.Text = "◎ ЗАПУСТИТЬ В КОСМОС"
            self.BackgroundColor3 = JJSColors.Red
        end)
    end
end); y = y + 48

CreateButton(FlingPage, "↻ ОБНОВИТЬ СПИСОК", y, JJSColors.Panel, function(self)
    RefreshPlayerList()
    self.Text = "✅ ОБНОВЛЕНО"
    task.delay(1, function() self.Text = "↻ ОБНОВИТЬ СПИСОК" end)
end)

-- ========== СТРАНИЦА MISC ==========
local MiscPage = Pages["Misc"]
y = 10

CreateSectionLabel(MiscPage, "НЕВИДИМОСТЬ", y); y = y + 30
CreateLabel(MiscPage, "Телепортирует тебя в безопасное место.", y, 16); y = y + 18
CreateLabel(MiscPage, "Другие игроки тебя НЕ увидят!", y, 16); y = y + 25

CreateButton(MiscPage, "✦ СТАТЬ НЕВИДИМЫМ", y, JJSColors.Accent, function(self)
    Config.Invisibility = not Config.Invisibility
    if Config.Invisibility then
        self.Text = "✅ ТЫ НЕВИДИМ! (Нажми для возврата)"
        self.BackgroundColor3 = JJSColors.Green
        SetInvisibility(true)
    else
        self.Text = "✦ СТАТЬ НЕВИДИМЫМ"
        self.BackgroundColor3 = JJSColors.Accent
        SetInvisibility(false)
    end
end); y = y + 50

CreateSectionLabel(MiscPage, "AUTO", y); y = y + 30

CreateButton(MiscPage, "Auto Block: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.AutoBlock = not Config.AutoBlock
    self.Text = "Auto Block: " .. (Config.AutoBlock and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.AutoBlock and JJSColors.Green or Color3.fromRGB(140, 40, 40)
end); y = y + 44

CreateSlider(MiscPage, "Дистанция блока", y, 5, 50, Config.AutoBlockDistance, false, function(v) Config.AutoBlockDistance = v end); y = y + 54

CreateButton(MiscPage, "No Cooldown: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.NoCooldown = not Config.NoCooldown
    self.Text = "No Cooldown: " .. (Config.NoCooldown and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.NoCooldown and JJSColors.Green or Color3.fromRGB(140, 40, 40)
end)

-- ========== СТРАНИЦА AIMBOT ==========
local AimbotPage = Pages["Aimbot"]
y = 10

CreateSectionLabel(AimbotPage, "CURSED AIMBOT", y); y = y + 30
CreateLabel(AimbotPage, "Преследует цель даже за экраном!", y, 16); y = y + 25

CreateButton(AimbotPage, "Aimbot: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.AimbotEnabled = not Config.AimbotEnabled
    self.Text = "Aimbot: " .. (Config.AimbotEnabled and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.AimbotEnabled and JJSColors.Green or Color3.fromRGB(140, 40, 40)
end); y = y + 44

CreateButton(AimbotPage, "WallCheck: ВКЛ", y, JJSColors.Green, function(self)
    Config.WallCheck = not Config.WallCheck
    self.Text = "WallCheck: " .. (Config.WallCheck and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.WallCheck and JJSColors.Green or Color3.fromRGB(140, 40, 40)
end); y = y + 44

CreateButton(AimbotPage, "Поворот персонажа: ВКЛ", y, JJSColors.Green, function(self)
    Config.RotateCharacter = not Config.RotateCharacter
    self.Text = "Поворот персонажа: " .. (Config.RotateCharacter and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.RotateCharacter and JJSColors.Green or Color3.fromRGB(140, 40, 40)
end); y = y + 44

CreateButton(AimbotPage, "Показать FOV: ВКЛ", y, JJSColors.Green, function(self)
    Config.ShowFOV = not Config.ShowFOV
    self.Text = "Показать FOV: " .. (Config.ShowFOV and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.ShowFOV and JJSColors.Green or Color3.fromRGB(140, 40, 40)
end); y = y + 48

CreateSlider(AimbotPage, "FOV (радиус поиска)", y, 50, 1000, Config.FOV, false, function(v) Config.FOV = v end); y = y + 54
CreateSlider(AimbotPage, "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v) Config.Smoothness = v end); y = y + 54

CreateSelector(AimbotPage, "Режим цели", y, {"FOV", "LowestHP", "HighestHP", "Distance"}, Config.TargetMode, function(v) Config.TargetMode = v end); y = y + 60
CreateSelector(AimbotPage, "Часть тела", y, {"Head", "HumanoidRootPart", "UpperTorso"}, Config.TargetPart, function(v) Config.TargetPart = v end)

-- ========== СТРАНИЦА VISUALS ==========
local VisPage = Pages["Visuals"]
y = 10

CreateSectionLabel(VisPage, "CURSED VISUALS", y); y = y + 30

CreateButton(VisPage, "Аура: ВКЛ", y, JJSColors.Green, function(self)
    Config.AuraEnabled = not Config.AuraEnabled
    self.Text = "Аура: " .. (Config.AuraEnabled and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.AuraEnabled and JJSColors.Green or Color3.fromRGB(140, 40, 40)
    AuraRing.Transparency = Config.AuraEnabled and 0.3 or 1
    AuraParticles.Enabled = Config.AuraEnabled
end); y = y + 44

CreateButton(VisPage, "Крылья: ВКЛ", y, JJSColors.Green, function(self)
    Config.WingsEnabled = not Config.WingsEnabled
    self.Text = "Крылья: " .. (Config.WingsEnabled and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.WingsEnabled and JJSColors.Green or Color3.fromRGB(140, 40, 40)
    for _, w in ipairs(WingParts) do w.Part.Transparency = Config.WingsEnabled and Config.WingsTransparency or 1 end
    for _, b in ipairs(WingBeams) do b.Transparency = NumberSequence.new(Config.WingsEnabled and Config.WingsTransparency or 1) end
end); y = y + 48

CreateSlider(VisPage, "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v) Config.AuraSize = v; AuraRing.Size = Vector3.new(0.15, v, v) end); y = y + 54
CreateSlider(VisPage, "Чёткость крыльев", y, 0, 1.0, Config.WingsTransparency, true, function(v)
    Config.WingsTransparency = v
    for _, w in ipairs(WingParts) do if Config.WingsEnabled then w.Part.Transparency = v end end
    for _, b in ipairs(WingBeams) do if Config.WingsEnabled then b.Transparency = NumberSequence.new(v) end end
end)

-- ========== СТРАНИЦА ESP ==========
local EspPage = Pages["ESP"]
y = 10

CreateSectionLabel(EspPage, "CURSED ESP", y); y = y + 30

CreateButton(EspPage, "ESP Игроков: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.EspPlayers = not Config.EspPlayers
    self.Text = "ESP Игроков: " .. (Config.EspPlayers and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.EspPlayers and JJSColors.Green or Color3.fromRGB(140, 40, 40)
end); y = y + 44

CreateButton(EspPage, "Tracers: ВКЛ", y, JJSColors.Green, function(self)
    Config.ShowTracers = not Config.ShowTracers
    self.Text = "Tracers: " .. (Config.ShowTracers and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.ShowTracers and JJSColors.Green or Color3.fromRGB(140, 40, 40)
end)

print("[APEX v7] ✅ ЗАГРУЖЕНО!")
print("[APEX] ◈ GUI в стиле JJS (Cursed Energy Theme)")
print("[APEX] ⊕ Aimbot преследует цель даже за экраном")
print("[APEX] ✦ Невидимость: телепорт в безопасное место")
print("[APEX] ◎ Fling: телепорт → спин → толчок → космос")
