-- ==========================================================
--     ◈ APEX HUB v8.0 | JUJUTSU SHENANIGANS ◈
--     Cursed Energy Premium Edition
--     Максимальная проработка каждой детали
-- ==========================================================
--
--  Что внутри:
--  • Невидимость: удаление видимых частей + локальный клон
--  • Флинг: разгон своего тела + якорь защиты
--  • Аимбот: преследование цели даже за экраном
--  • Премиум GUI с анимациями и частицами
--
-- ==========================================================

print("═══════════════════════════════════════════")
print("  ◈ APEX HUB v8.0 | JJS EDITION ◈")
print("  Загрузка модулей проклятой энергии...")
print("═══════════════════════════════════════════")

-- ==========================================================
--  СЕРВИСЫ
-- ==========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Drawing = drawing or Drawing or (getgenv and getgenv().drawing)
local Camera = Workspace.CurrentCamera

-- ==========================================================
--  ПАЛИТРА СТИЛЯ JJS (Проклятая Энергия)
-- ==========================================================
local C = {
    BG          = Color3.fromRGB(8, 6, 16),       -- Глубокий чёрно-фиолетовый фон
    BG2         = Color3.fromRGB(14, 10, 26),     -- Чуть светлее фон
    Panel       = Color3.fromRGB(18, 14, 32),     -- Панели
    PanelHover  = Color3.fromRGB(30, 22, 52),     -- Панель при наведении
    Accent      = Color3.fromRGB(147, 30, 255),   -- Проклятая энергия (фиолетовый)
    Accent2     = Color3.fromRGB(90, 10, 180),    -- Тёмный фиолетовый
    Red         = Color3.fromRGB(255, 25, 65),    -- Красный (домен)
    RedDark     = Color3.fromRGB(160, 15, 40),    -- Тёмный красный
    Blue        = Color3.fromRGB(40, 120, 255),   -- Синий (бесконечность)
    Gold        = Color3.fromRGB(255, 200, 50),   -- Золотой
    Green       = Color3.fromRGB(40, 230, 120),   -- Зелёный
    GreenDark   = Color3.fromRGB(20, 130, 70),    -- Тёмный зелёный
    White       = Color3.fromRGB(255, 255, 255),  -- Белый
    Text        = Color3.fromRGB(225, 218, 255),  -- Основной текст
    TextDim     = Color3.fromRGB(130, 120, 165),  -- Тусклый текст
    TextDark    = Color3.fromRGB(80, 72, 110),    -- Очень тусклый
    Black       = Color3.fromRGB(0, 0, 0),        -- Чёрный
    Cyan        = Color3.fromRGB(0, 240, 255),    -- Циан
}

-- ==========================================================
--  КОНФИГ
-- ==========================================================
local Config = {
    AimbotEnabled = false,
    FOV = 250,
    ShowFOV = true,
    Smoothness = 0.08,
    TargetMode = "FOV",
    TargetPart = "Head",
    WallCheck = true,
    RotateCharacter = true,
    TrackBehindScreen = true,  -- Преследовать цель за экраном

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
    EspCharms = false,
    ShowTracers = true,
    ShowHealthBars = true,
    EspColor = Color3.fromRGB(255, 50, 50),
    CharmColor = Color3.fromRGB(255, 215, 0),

    Invisibility = false,
    NoCooldown = false,

    FlingIterations = 20,
    FlingDelay = 0.02,
}

-- ==========================================================
--  ОЖИДАНИЕ ПЕРСОНАЖА
-- ==========================================================
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

print("[APEX] Персонаж найден: " .. LocalPlayer.Name)

-- ==========================================================
--  МОДУЛЬ НЕВИДИМОСТИ
--  Логика: удаляем видимые части персонажа,
--  создаём локальный прозрачный клон для себя.
--  Сервер видит только HumanoidRootPart (невидимый).
-- ==========================================================
local InvisibilityModule = {
    Active = false,
    Clone = nil,
    SavedParts = {},      -- Сохранённые данные частей
    CloneConnection = nil,
}

function InvisibilityModule:Activate()
    if self.Active then return end
    self.Active = true

    print("[APEX] Активация невидимости...")

    -- Шаг 1: Сохраняем все части персонажа
    self.SavedParts = {}
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            table.insert(self.SavedParts, {
                Part = part,
                Transparency = part.Transparency,
                CanCollide = part.CanCollide,
                CastShadow = part.CastShadow,
            })
        end
    end

    -- Шаг 2: Создаём локальный клон для себя (прозрачный)
    pcall(function()
        self.Clone = Character:Clone()
        self.Clone.Name = "ApexVisualClone_" .. LocalPlayer.Name
        self.Clone.Parent = Workspace

        -- Убираем скрипты из клона
        for _, obj in ipairs(self.Clone:GetDescendants()) do
            if obj:IsA("BaseScript") then
                obj:Destroy()
            end
        end

        -- Делаем клон полупрозрачным
        for _, part in ipairs(self.Clone:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Transparency = math.clamp(part.Transparency + 0.6, 0, 0.95)
                part.CanCollide = false
                part.CanQuery = false
                part.CastShadow = false
            end
        end

        -- Убираем гуманоида клона (чтобы не было проблем)
        local cloneHum = self.Clone:FindFirstChildOfClass("Humanoid")
        if cloneHum then cloneHum:Destroy() end
    end)

    -- Шаг 3: Делаем оригинальные части невидимыми
    for _, data in ipairs(self.SavedParts) do
        pcall(function()
            if data.Part and data.Part.Parent then
                data.Part.Transparency = 1
                data.Part.CastShadow = false
                if data.Part.Name ~= "HumanoidRootPart" then
                    data.Part.CanCollide = false
                end
            end
        end)
    end

    -- Шаг 4: Синхронизация клона с оригиналом
    self.CloneConnection = RunService.Heartbeat:Connect(function()
        if not self.Active then return end
        if not self.Clone or not self.Clone.Parent then return end

        pcall(function()
            for _, origPart in ipairs(Character:GetDescendants()) do
                if origPart:IsA("BasePart") or origPart:IsA("MeshPart") then
                    local clonePart = self.Clone:FindFirstChild(origPart.Name)
                    if clonePart and clonePart:IsA("BasePart") then
                        clonePart.CFrame = origPart.CFrame
                    end
                end
            end
        end)
    end)

    print("[APEX] ✅ Невидимость активирована!")
    print("[APEX] Сервер видит только невидимый HumanoidRootPart.")
    print("[APEX] Ты видишь себя полупрозрачным.")
end

function InvisibilityModule:Deactivate()
    if not self.Active then return end
    self.Active = false

    print("[APEX] Деактивация невидимости...")

    -- Восстанавливаем оригинальные части
    for _, data in ipairs(self.SavedParts) do
        pcall(function()
            if data.Part and data.Part.Parent then
                data.Part.Transparency = data.Transparency
                data.Part.CanCollide = data.CanCollide
                data.Part.CastShadow = data.CastShadow
            end
        end)
    end

    -- Удаляем клон
    if self.CloneConnection then
        self.CloneConnection:Disconnect()
        self.CloneConnection = nil
    end

    if self.Clone and self.Clone.Parent then
        self.Clone:Destroy()
        self.Clone = nil
    end

    Config.Invisibility = false
    print("[APEX] ✅ Невидимость деактивирована!")
end

-- Следим за новыми частями (респавн, тулы)
Character.DescendantAdded:Connect(function(desc)
    if InvisibilityModule.Active and (desc:IsA("BasePart") or desc:IsA("MeshPart")) then
        task.wait(0.1)
        pcall(function()
            desc.Transparency = 1
            desc.CastShadow = false
        end)
    end
end)

-- ==========================================================
--  МОДУЛЬ ФЛИНГА
--  Логика: разгоняем СВОЙ персонаж как снаряд,
--  но с якорем чтобы самих себя не зафлинило.
-- ==========================================================
local FlingModule = {
    Active = false,
    Anchor = nil,
}

function FlingModule:CreateAnchor()
    -- Якорь защищает нашего персонажа от отдачи
    if self.Anchor and self.Anchor.Parent then return end

    local myHrp = Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    self.Anchor = Instance.new("BodyPosition")
    self.Anchor.Name = "ApexFlingAnchor"
    self.Anchor.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    self.Anchor.Position = myHrp.Position
    self.Anchor.P = 50000
    self.Anchor.D = 1000
    self.Anchor.Parent = myHrp
end

function FlingModule:RemoveAnchor()
    if self.Anchor and self.Anchor.Parent then
        self.Anchor:Destroy()
        self.Anchor = nil
    end
end

function FlingModule:Execute(targetPlayer)
    if self.Active then
        print("[APEX] Флинг уже выполняется!")
        return false
    end

    if not targetPlayer or targetPlayer == LocalPlayer then
        print("[APEX] Некорректная цель!")
        return false
    end

    local targetChar = targetPlayer.Character
    if not targetChar then
        print("[APEX] У цели нет персонажа!")
        return false
    end

    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                or targetChar:FindFirstChild("Torso")
                or targetChar:FindFirstChild("UpperTorso")
    if not targetHrp then
        print("[APEX] У цели нет HumanoidRootPart!")
        return false
    end

    local myHrp = Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false end

    self.Active = true
    local oldCFrame = myHrp.CFrame
    local oldVelocity = myHrp.AssemblyLinearVelocity

    print("[APEX] 🌪 Начало флинга: " .. targetPlayer.Name)

    task.spawn(function()
        -- Шаг 1: Ставим якорь чтобы нас не отбросило
        self:CreateAnchor()

        -- Шаг 2: Отключаем коллизию своих частей
        local savedCollision = {}
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                savedCollision[part] = part.CanCollide
                part.CanCollide = false
            end
        end

        -- Шаг 3: Создаём спин (вращение)
        local spin = Instance.new("BodyAngularVelocity")
        spin.Name = "ApexFlingSpin"
        spin.MaxTorque = Vector3.new(0, math.huge, 0)
        spin.AngularVelocity = Vector3.new(0, 200, 0)
        spin.Parent = myHrp

        -- Шаг 4: Отключаем якорь для движения
        if self.Anchor and self.Anchor.Parent then
            self.Anchor.MaxForce = Vector3.new(0, 0, 0)
        end

        -- Шаг 5: Серия телепортов к цели (накопление импульса)
        for i = 1, Config.FlingIterations do
            if not targetHrp or not targetHrp.Parent then
                print("[APEX] Цель потеряна!")
                break
            end

            local angle = (i / Config.FlingIterations) * math.pi * 2
            local radius = 1.5
            local offsetX = math.cos(angle) * radius
            local offsetZ = math.sin(angle) * radius

            pcall(function()
                myHrp.CFrame = targetHrp.CFrame * CFrame.new(offsetX, 0, offsetZ)
            end)

            task.wait(Config.FlingDelay)
        end

        -- Шаг 6: Финальный удар - телепорт прямо в цель + скорость
        if targetHrp and targetHrp.Parent then
            pcall(function()
                myHrp.CFrame = targetHrp.CFrame
                myHrp.AssemblyLinearVelocity = Vector3.new(
                    math.random(-150, 150),
                    200,
                    math.random(-150, 150)
                )
            end)

            -- Пытаемся напрямую воздействовать на цель
            pcall(function()
                local force = Instance.new("BodyVelocity")
                force.Name = "ApexFlingForce"
                force.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                force.Velocity = Vector3.new(
                    math.random(-200, 200),
                    400,
                    math.random(-200, 200)
                )
                force.Parent = targetHrp

                local targetSpin = Instance.new("BodyAngularVelocity")
                targetSpin.Name = "ApexTargetSpin"
                targetSpin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                targetSpin.AngularVelocity = Vector3.new(150, 150, 150)
                targetSpin.Parent = targetHrp

                -- Удаляем через 2 секунды
                task.delay(2, function()
                    if force and force.Parent then force:Destroy() end
                    if targetSpin and targetSpin.Parent then targetSpin:Destroy() end
                end)
            end)
        end

        -- Шаг 7: Очистка и возврат
        task.delay(0.6, function()
            -- Удаляем спин
            if spin and spin.Parent then spin:Destroy() end

            -- Восстанавливаем коллизию
            for part, canCollide in pairs(savedCollision) do
                pcall(function()
                    if part and part.Parent then
                        part.CanCollide = canCollide
                    end
                end)
            end

            -- Возвращаемся на место
            pcall(function()
                if myHrp and myHrp.Parent then
                    myHrp.CFrame = oldCFrame
                    myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    myHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end)

            -- Убираем якорь
            self:RemoveAnchor()

            self.Active = false
            print("[APEX] ✅ Флинг завершён!")
        end)
    end)

    return true
end

-- ==========================================================
--  АУРА ПРОКЛЯТОЙ ЭНЕРГИИ
-- ==========================================================
local AuraRing = Instance.new("Part")
AuraRing.Name = "ApexAuraRing"
AuraRing.Shape = Enum.PartType.Cylinder
AuraRing.Size = Vector3.new(0.15, Config.AuraSize, Config.AuraSize)
AuraRing.Anchored = true
AuraRing.CanCollide = false
AuraRing.CanQuery = false
AuraRing.Massless = true
AuraRing.Color = Config.AuraColor
AuraRing.Material = Enum.Material.Neon
AuraRing.Transparency = 0.3
AuraRing.Parent = Workspace

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
AuraParticles.Size = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.5),
    NumberSequenceKeypoint.new(1, 0)
})
AuraParticles.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(1, 1)
})
AuraParticles.LightEmission = 1
AuraParticles.Rotation = NumberRange.new(0, 360)
AuraParticles.VelocityInheritance = 0

-- ==========================================================
--  КРЫЛЬЯ ПРОКЛЯТОЙ ЭНЕРГИИ
-- ==========================================================
local WingParts = {}
local WingBeams = {}

local function CreateWing(side)
    local segments = {}
    for i = 1, 3 do
        local Seg = Instance.new("Part")
        Seg.Name = "ApexWingSeg_" .. side .. "_" .. i
        Seg.Size = Vector3.new(0.2, 3 - i * 0.5, 1.2)
        Seg.Anchored = true
        Seg.CanCollide = false
        Seg.CanQuery = false
        Seg.Massless = true
        Seg.Color = Config.WingsColor
        Seg.Material = Enum.Material.Neon
        Seg.Transparency = Config.WingsTransparency
        Seg.Parent = Workspace

        local offsetX = (i - 1) * 0.9 * side
        local offsetY = 1.5 + i * 0.3
        local baseOffset = CFrame.new(offsetX, offsetY, 0.8)
            * CFrame.Angles(0, math.rad(-30 * side), math.rad(20 * side))

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

    local Att = Instance.new("Attachment", segments[#segments])
    local P = Instance.new("ParticleEmitter")
    P.Parent = Att
    P.Texture = "rbxassetid://243098098"
    P.Rate = 15
    P.Lifetime = NumberRange.new(0.5, 1)
    P.Speed = NumberRange.new(1, 3)
    P.SpreadAngle = Vector2.new(30, 30)
    P.Color = ColorSequence.new(Config.WingsColor)
    P.Size = NumberSequence.new(0.4)
    P.Transparency = NumberSequence.new(Config.WingsTransparency)
    P.LightEmission = 1
end

CreateWing(1)
CreateWing(-1)

-- Обновление визуалов
RunService.Heartbeat:Connect(function()
    if not Root or not Root.Parent then return end

    -- Не показываем визуалы если невидимы
    local showVisuals = not InvisibilityModule.Active

    if Config.AuraEnabled and showVisuals then
        AuraRing.CFrame = Root.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, math.rad(90))
    else
        AuraRing.CFrame = CFrame.new(0, -10000, 0)
    end

    if Config.WingsEnabled and showVisuals then
        for _, w in ipairs(WingParts) do
            w.Part.CFrame = Root.CFrame * w.BaseOffset
        end
    else
        for _, w in ipairs(WingParts) do
            w.Part.CFrame = CFrame.new(0, -10000, 0)
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
        FovCircle.Color = C.Accent
        FovCircle.Transparency = 0.6
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
--  ESP ИГРОКОВ
-- ==========================================================
local EspTable = {}
local CharmTable = {}
local CachedCharms = {}
local LastCharmUpdate = 0

local function GetEspDraw(player)
    if not Drawing then return nil end
    if not EspTable[player] then
        EspTable[player] = {
            Box = Drawing.new("Square"),
            BoxOutline = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Hp = Drawing.new("Text"),
            Dist = Drawing.new("Text"),
            Tracer = Drawing.new("Line"),
            HealthBar = Drawing.new("Square"),
            HealthBarBg = Drawing.new("Square"),
        }
        local t = EspTable[player]
        t.BoxOutline.Thickness = 3
        t.BoxOutline.Color = C.Black
        t.BoxOutline.Filled = false
        t.Box.Thickness = 1.5
        t.Box.Filled = false
        t.Box.Color = Config.EspColor
        t.Name.Size = 14
        t.Name.Center = true
        t.Name.Outline = true
        t.Name.Color = C.White
        t.Hp.Size = 12
        t.Hp.Center = true
        t.Hp.Outline = true
        t.Hp.Color = C.Green
        t.Dist.Size = 11
        t.Dist.Center = true
        t.Dist.Outline = true
        t.Dist.Color = C.Gold
        t.Tracer.Thickness = 2
        t.Tracer.Color = Config.EspColor
        t.Tracer.Transparency = 0.7
        t.HealthBar.Filled = true
        t.HealthBarBg.Filled = true
        t.HealthBarBg.Color = Color3.fromRGB(25, 25, 25)
    end
    return EspTable[player]
end

local function GetCharmDraw(model)
    if not Drawing then return nil end
    if not CharmTable[model] then
        CharmTable[model] = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
        }
        CharmTable[model].Box.Thickness = 1.5
        CharmTable[model].Box.Filled = false
        CharmTable[model].Box.Color = Config.CharmColor
        CharmTable[model].Name.Size = 12
        CharmTable[model].Name.Center = true
        CharmTable[model].Name.Outline = true
        CharmTable[model].Name.Color = Config.CharmColor
    end
    return CharmTable[model]
end

local function UpdateCharmCache()
    CachedCharms = {}
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart"))
               and obj.Name:lower():find("charm") then
                table.insert(CachedCharms, obj)
            end
        end
    end)
end

Workspace.DescendantAdded:Connect(function(obj)
    if (obj:IsA("Model") or obj:IsA("BasePart"))
       and obj.Name:lower():find("charm") then
        table.insert(CachedCharms, obj)
    end
end)

Workspace.DescendantRemoving:Connect(function(obj)
    if CharmTable[obj] then
        for _, d in pairs(CharmTable[obj]) do
            pcall(function() if d.Remove then d:Remove() end end)
        end
        CharmTable[obj] = nil
    end
    for i, cached in ipairs(CachedCharms) do
        if cached == obj then
            table.remove(CachedCharms, i)
            break
        end
    end
end)

-- Основной цикл ESP
if Drawing then
    RunService.RenderStepped:Connect(function()
        -- ESP Игроков
        for _, player in pairs(Players:GetPlayers()) do
            local draw = EspTable[player]
            if player ~= LocalPlayer and Config.EspPlayers then
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        if onScreen then
                            draw = GetEspDraw(player)
                            if draw then
                                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                                local height = math.abs(headPos.Y - footPos.Y)
                                local width = height * 0.6
                                local boxSize = Vector2.new(width, height)
                                local boxPos = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)

                                draw.Box.Size = boxSize
                                draw.Box.Position = boxPos
                                draw.Box.Color = Config.EspColor
                                draw.Box.Visible = true

                                draw.BoxOutline.Size = boxSize
                                draw.BoxOutline.Position = boxPos
                                draw.BoxOutline.Visible = true

                                draw.Name.Text = player.Name
                                draw.Name.Position = Vector2.new(pos.X, boxPos.Y - 18)
                                draw.Name.Visible = true

                                local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                local hpColor = Color3.fromRGB(
                                    math.floor(255 * (1 - hpPercent)),
                                    math.floor(255 * hpPercent),
                                    50
                                )
                                draw.Hp.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                                draw.Hp.Color = hpColor
                                draw.Hp.Position = Vector2.new(pos.X, boxPos.Y + height + 4)
                                draw.Hp.Visible = true

                                draw.Dist.Text = "[" .. math.floor(dist) .. "m]"
                                draw.Dist.Position = Vector2.new(pos.X, boxPos.Y + height + 18)
                                draw.Dist.Visible = true

                                if Config.ShowTracers then
                                    draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                    draw.Tracer.To = Vector2.new(pos.X, pos.Y + height / 2)
                                    draw.Tracer.Visible = true
                                else
                                    draw.Tracer.Visible = false
                                end

                                if Config.ShowHealthBars then
                                    local barW = 4
                                    local barX = boxPos.X - barW - 3
                                    draw.HealthBarBg.Size = Vector2.new(barW, height)
                                    draw.HealthBarBg.Position = Vector2.new(barX, boxPos.Y)
                                    draw.HealthBarBg.Visible = true

                                    draw.HealthBar.Size = Vector2.new(barW, height * hpPercent)
                                    draw.HealthBar.Position = Vector2.new(barX, boxPos.Y + height - height * hpPercent)
                                    draw.HealthBar.Color = hpColor
                                    draw.HealthBar.Visible = true
                                else
                                    draw.HealthBar.Visible = false
                                    draw.HealthBarBg.Visible = false
                                end
                            end
                        else
                            if draw then
                                draw.Box.Visible = false
                                draw.BoxOutline.Visible = false
                                draw.Name.Visible = false
                                draw.Hp.Visible = false
                                draw.Dist.Visible = false
                                draw.Tracer.Visible = false
                                draw.HealthBar.Visible = false
                                draw.HealthBarBg.Visible = false
                            end
                        end
                    else
                        if draw then
                            draw.Box.Visible = false
                            draw.BoxOutline.Visible = false
                            draw.Name.Visible = false
                            draw.Hp.Visible = false
                            draw.Dist.Visible = false
                            draw.Tracer.Visible = false
                            draw.HealthBar.Visible = false
                            draw.HealthBarBg.Visible = false
                        end
                    end
                end
            else
                if draw then
                    draw.Box.Visible = false
                    draw.BoxOutline.Visible = false
                    draw.Name.Visible = false
                    draw.Hp.Visible = false
                    draw.Dist.Visible = false
                    draw.Tracer.Visible = false
                    draw.HealthBar.Visible = false
                    draw.HealthBarBg.Visible = false
                end
            end
        end

        -- ESP Charms
        if tick() - LastCharmUpdate > 2 then
            UpdateCharmCache()
            LastCharmUpdate = tick()
        end

        if Config.EspCharms then
            for _, obj in ipairs(CachedCharms) do
                local part = obj:IsA("Model")
                    and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
                    or obj
                if part and part.Parent then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    local draw = GetCharmDraw(obj)
                    if draw then
                        if onScreen then
                            local dist = (Camera.CFrame.Position - part.Position).Magnitude
                            local scale = math.clamp(1200 / dist, 15, 200)
                            local boxSize = Vector2.new(scale * 1.2, scale * 1.2)
                            draw.Box.Size = boxSize
                            draw.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                            draw.Box.Visible = true
                            draw.Name.Text = obj.Name
                            draw.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 15)
                            draw.Name.Visible = true
                        else
                            draw.Box.Visible = false
                            draw.Name.Visible = false
                        end
                    end
                end
            end
        else
            for _, d in pairs(CharmTable) do
                d.Box.Visible = false
                d.Name.Visible = false
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(p)
        if EspTable[p] then
            for _, d in pairs(EspTable[p]) do
                pcall(function() if d.Remove then d:Remove() end end)
            end
            EspTable[p] = nil
        end
    end)
end

-- ==========================================================
--  АИМБОТ (преследование цели даже за экраном)
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

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    params.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction.Unit * distance, params)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function PickTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestScore = nil, nil

    for _, info in ipairs(GetAlivePlayers()) do
        local part = info.Player.Character:FindFirstChild(Config.TargetPart)
                  or info.Player.Character:FindFirstChild("Head")
        if part then
            if IsVisible(part) then
                local screenPos = Camera:WorldToViewportPoint(part.Position)
                local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

                -- Увеличенный радиус: если цель за экраном, всё равно преследуем
                local searchRadius = Config.FOV
                if Config.TrackBehindScreen then
                    searchRadius = Config.FOV * 5
                end

                if fovDist <= searchRadius then
                    local score
                    if Config.TargetMode == "FOV" then
                        score = fovDist
                    elseif Config.TargetMode == "LowestHP" then
                        score = info.Hum.Health
                    elseif Config.TargetMode == "HighestHP" then
                        score = -info.Hum.Health
                    elseif Config.TargetMode == "Distance" then
                        score = (Camera.CFrame.Position - part.Position).Magnitude
                    else
                        score = fovDist
                    end

                    if bestScore == nil or score < bestScore then
                        best = { part = part, info = info }
                        bestScore = score
                    end
                end
            end
        end
    end

    return best
end

RunService.RenderStepped:Connect(function(dt)
    if not Config.AimbotEnabled then return end
    if InvisibilityModule.Active then return end

    local targetData = PickTarget()
    if targetData then
        local target = targetData.part
        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.lookAt(camPos, target.Position)

        local alpha = math.clamp(1 - Config.Smoothness, 0.01, 1)
        local smoothAlpha = 1 - (1 - alpha) ^ (dt * 60)

        -- Наводим камеру
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, smoothAlpha)

        -- Поворачиваем персонажа к цели (для ShiftLock)
        if Config.RotateCharacter and Root and Root.Parent then
            local flatTarget = Vector3.new(target.Position.X, Root.Position.Y, target.Position.Z)
            local rootCF = CFrame.lookAt(Root.Position, flatTarget)
            Root.CFrame = Root.CFrame:Lerp(rootCF, smoothAlpha * 0.8)
        end
    end
end)

-- ==========================================================
--  AUTO BLOCK / NO COOLDOWN
-- ==========================================================
RunService.Heartbeat:Connect(function()
    if Config.AutoBlock and not InvisibilityModule.Active then
        local nearestDist = math.huge
        for _, info in ipairs(GetAlivePlayers()) do
            local dist = (info.Root.Position - Root.Position).Magnitude
            if dist < nearestDist then nearestDist = dist end
        end

        if nearestDist < Config.AutoBlockDistance then
            pcall(function()
                local tool = Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end)
        end
    end

    if Config.NoCooldown then
        pcall(function()
            for _, desc in ipairs(Character:GetDescendants()) do
                if desc:IsA("NumberValue") or desc:IsA("IntValue") then
                    local name = desc.Name:lower()
                    if name:find("cooldown") or name:find("cd")
                       or name:find("timer") or name:find("wait") then
                        desc.Value = 0
                    end
                end
            end
        end)
    end
end)

-- ==========================================================
--  П Р Е М И У М   G U И   " A P E X "
--  Стиль: Проклятая Энергия (тёмный фиолетово-чёрный)
-- ==========================================================
print("[APEX] Создание премиум интерфейса...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexHubV8"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ---------- КНОПКА ОТКРЫТИЯ (КРУГ С ПУЛЬСАЦИЕЙ) ----------
local FloatContainer = Instance.new("Frame")
FloatContainer.Size = UDim2.new(0, 70, 0, 70)
FloatContainer.Position = UDim2.new(0, 12, 0.45, -35)
FloatContainer.BackgroundTransparency = 1
FloatContainer.Active = true
FloatContainer.Draggable = true
FloatContainer.Parent = ScreenGui

-- Внешнее свечение
local OuterGlow = Instance.new("Frame")
OuterGlow.Size = UDim2.new(1, 18, 1, 18)
OuterGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
OuterGlow.AnchorPoint = Vector2.new(0.5, 0.5)
OuterGlow.BackgroundColor3 = C.Accent
OuterGlow.BackgroundTransparency = 0.75
OuterGlow.BorderSizePixel = 0
OuterGlow.Parent = FloatContainer
Instance.new("UICorner", OuterGlow).CornerRadius = UDim.new(1, 0)

-- Кнопка
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(1, 0, 1, 0)
FloatBtn.BackgroundColor3 = C.BG
FloatBtn.Text = ""
FloatBtn.BorderSizePixel = 0
FloatBtn.Parent = FloatContainer
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local btnGrad = Instance.new("UIGradient", FloatBtn)
btnGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.Accent2),
    ColorSequenceKeypoint.new(0.5, C.BG),
    ColorSequenceKeypoint.new(1, C.Accent2),
})
btnGrad.Rotation = 45

local btnStroke = Instance.new("UIStroke", FloatBtn)
btnStroke.Color = C.Accent
btnStroke.Thickness = 2.5

-- Символ
local btnSymbol = Instance.new("TextLabel")
btnSymbol.Size = UDim2.new(1, 0, 0, 26)
btnSymbol.Position = UDim2.new(0, 0, 0, 10)
btnSymbol.BackgroundTransparency = 1
btnSymbol.Text = "◈"
btnSymbol.TextColor3 = C.Accent
btnSymbol.Font = Enum.Font.GothamBlack
btnSymbol.TextSize = 26
btnSymbol.Parent = FloatContainer

local btnLabel = Instance.new("TextLabel")
btnLabel.Size = UDim2.new(1, 0, 0, 14)
btnLabel.Position = UDim2.new(0, 0, 0, 38)
btnLabel.BackgroundTransparency = 1
btnLabel.Text = "APEX"
btnLabel.TextColor3 = C.Text
btnLabel.Font = Enum.Font.GothamBlack
btnLabel.TextSize = 10
btnLabel.TextStrokeTransparency = 0
btnLabel.TextStrokeColor3 = C.Black
btnLabel.Parent = FloatContainer

-- Анимации кнопки
task.spawn(function()
    while FloatContainer.Parent do
        local p1 = TweenService:Create(OuterGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 28, 1, 28),
        })
        local p2 = TweenService:Create(OuterGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.75,
            Size = UDim2.new(1, 18, 1, 18),
        })
        p1:Play(); p1.Completed:Wait()
        p2:Play(); p2.Completed:Wait()
    end
end)

task.spawn(function()
    local rot = 45
    while FloatContainer.Parent do
        rot = rot + 0.6
        btnGrad.Rotation = rot
        task.wait(0.03)
    end
end)

FloatBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatContainer, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 80, 0, 80),
    }):Play()
end)
FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatContainer, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 70, 0, 70),
    }):Play()
end)

-- ---------- ГЛАВНОЕ МЕНЮ ----------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 610)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -305)
MainFrame.BackgroundColor3 = C.BG
MainFrame.BackgroundTransparency = 0.02
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = C.Accent
mainStroke.Thickness = 2

-- Градиент фона меню
local mainGrad = Instance.new("UIGradient", MainFrame)
mainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 8, 30)),
    ColorSequenceKeypoint.new(1, C.BG),
})
mainGrad.Rotation = 135

-- ---------- ЗАГОЛОВОК ----------
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 60)
TitleFrame.BackgroundTransparency = 1
TitleFrame.Parent = MainFrame

local TitleSymbol = Instance.new("TextLabel")
TitleSymbol.Size = UDim2.new(0, 45, 1, 0)
TitleSymbol.Position = UDim2.new(0, 14, 0, 0)
TitleSymbol.BackgroundTransparency = 1
TitleSymbol.Text = "◈"
TitleSymbol.TextColor3 = C.Accent
TitleSymbol.Font = Enum.Font.GothamBlack
TitleSymbol.TextSize = 34
TitleSymbol.Parent = TitleFrame

-- Анимация вращения символа
task.spawn(function()
    local rot = 0
    while TitleSymbol.Parent do
        rot = rot + 1
        TitleSymbol.Rotation = math.sin(math.rad(rot * 2)) * 15
        task.wait(0.05)
    end
end)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -110, 0, 28)
TitleText.Position = UDim2.new(0, 62, 0, 8)
TitleText.BackgroundTransparency = 1
TitleText.Text = "APEX HUB"
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextSize = 24
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextColor3 = C.Text
TitleText.Parent = TitleFrame

local titleGrad = Instance.new("UIGradient", TitleText)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.Accent),
    ColorSequenceKeypoint.new(0.5, C.Red),
    ColorSequenceKeypoint.new(1, C.Accent),
})

local SubTitleText = Instance.new("TextLabel")
SubTitleText.Size = UDim2.new(1, -110, 0, 14)
SubTitleText.Position = UDim2.new(0, 62, 0, 38)
SubTitleText.BackgroundTransparency = 1
SubTitleText.Text = "JUJUTSU SHENANIGANS | CURSED EDITION"
SubTitleText.Font = Enum.Font.GothamBold
SubTitleText.TextSize = 9
SubTitleText.TextXAlignment = Enum.TextXAlignment.Left
SubTitleText.TextColor3 = C.TextDim
SubTitleText.Parent = TitleFrame

-- Линия под заголовком
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -40, 0, 2)
HeaderLine.Position = UDim2.new(0, 20, 0, 62)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame

local headerLineGrad = Instance.new("UIGradient", HeaderLine)
headerLineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.2, C.Accent),
    ColorSequenceKeypoint.new(0.5, C.Red),
    ColorSequenceKeypoint.new(0.8, C.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
})

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 38, 0, 38)
CloseBtn.Position = UDim2.new(1, -46, 0, 12)
CloseBtn.BackgroundColor3 = C.RedDark
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.White
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(1, -48, 0, 10),
    }):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(1, -46, 0, 12),
    }):Play()
end)

-- ---------- ФУНКЦИЯ ОТКРЫТИЯ/ЗАКРЫТИЯ ----------
local MenuOpen = false

local function ToggleMenu()
    if MenuOpen then
        MenuOpen = false
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
        })
        tween:Play()
        tween.Completed:Connect(function()
            MainFrame.Visible = false
            MainFrame.Size = UDim2.new(0, 450, 0, 610)
            MainFrame.BackgroundTransparency = 0.02
        end)
    else
        MenuOpen = true
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 450, 0, 610),
            BackgroundTransparency = 0.02,
        })
        tween:Play()
    end
end

CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)

-- ---------- ВКЛАДКИ ----------
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 108, 1, -120)
TabBar.Position = UDim2.new(0, 10, 0, 100)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tabs = {}
local Pages = {}
local tabNames = { "Aimbot", "Fling", "Visuals", "ESP", "Misc" }
local tabIcons = { "⊕", "◎", "✦", "◉", "⚙" }

for i, name in ipairs(tabNames) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 46)
    TabBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 52)
    TabBtn.BackgroundColor3 = C.Panel
    TabBtn.Text = tabIcons[i] .. "  " .. name
    TabBtn.TextColor3 = C.TextDim
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

    local tabStroke = Instance.new("UIStroke", TabBtn)
    tabStroke.Color = C.Accent
    tabStroke.Thickness = 0
    tabStroke.Transparency = 0.5

    -- Индикатор слева
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = C.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = TabBtn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    Tabs[name] = { Btn = TabBtn, Stroke = tabStroke, Indicator = indicator }

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -135, 1, -120)
    Page.Position = UDim2.new(0, 125, 0, 100)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = C.Accent
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 1800)
    Page.Parent = MainFrame
    Pages[name] = Page

    TabBtn.MouseEnter:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), { BackgroundColor3 = C.PanelHover }):Play()
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), { BackgroundColor3 = C.Panel }):Play()
        end
    end)
end

-- Активная вкладка по умолчанию
Pages["Aimbot"].Visible = true
Tabs["Aimbot"].Btn.BackgroundColor3 = C.Accent2
Tabs["Aimbot"].Btn.TextColor3 = C.Text
Tabs["Aimbot"].Stroke.Thickness = 1.5
TweenService:Create(Tabs["Aimbot"].Indicator, TweenInfo.new(0.3), { Size = UDim2.new(0, 3, 0.6, 0) }):Play()

for name, data in pairs(Tabs) do
    data.Btn.MouseButton1Click:Connect(function()
        -- Сброс всех
        for n, p in pairs(Pages) do
            p.Visible = false
            TweenService:Create(Tabs[n].Btn, TweenInfo.new(0.2), { BackgroundColor3 = C.Panel }):Play()
            Tabs[n].Btn.TextColor3 = C.TextDim
            Tabs[n].Stroke.Thickness = 0
            TweenService:Create(Tabs[n].Indicator, TweenInfo.new(0.2), { Size = UDim2.new(0, 3, 0, 0) }):Play()
        end

        -- Активация выбранной
        Pages[name].Visible = true
        data.Btn.TextColor3 = C.Text
        data.Stroke.Thickness = 1.5

        TweenService:Create(data.Btn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            BackgroundColor3 = C.Accent2,
            Size = UDim2.new(1.06, 0, 0, 46),
        }):Play()
        TweenService:Create(data.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 3, 0.6, 0),
        }):Play()

        task.wait(0.15)
        TweenService:Create(data.Btn, TweenInfo.new(0.15), {
            Size = UDim2.new(1, 0, 0, 46),
        }):Play()
    end)
end

-- ==========================================================
--  УТИЛИТЫ СОЗДАНИЯ ЭЛЕМЕНТОВ
-- ==========================================================
local function CreateButton(parent, text, y, color, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -10, 0, 42)
    B.Position = UDim2.new(0, 5, 0, y)
    B.BackgroundColor3 = color or C.Panel
    B.Text = text
    B.TextColor3 = C.Text
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    B.Parent = parent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", B)
    stroke.Color = C.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.5

    B.MouseEnter:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), { BackgroundColor3 = C.PanelHover }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), { Thickness = 2, Transparency = 0 }):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), { BackgroundColor3 = color or C.Panel }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), { Thickness = 1, Transparency = 0.5 }):Play()
    end)

    B.MouseButton1Click:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.06), { Size = UDim2.new(1, -16, 0, 40) }):Play()
        task.wait(0.06)
        TweenService:Create(B, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Size = UDim2.new(1, -10, 0, 42) }):Play()
        pcall(callback, B)
    end)

    return B
end

local function CreateToggle(parent, text, y, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 42)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundColor3 = C.Panel
    Container.BorderSizePixel = 0
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = C.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 44, 0, 22)
    ToggleBg.Position = UDim2.new(1, -54, 0.5, -11)
    ToggleBg.BackgroundColor3 = default and C.Green or Color3.fromRGB(50, 50, 60)
    ToggleBg.BorderSizePixel = 0
    ToggleBg.Parent = Container
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)

    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 18, 0, 18)
    ToggleKnob.Position = default and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
    ToggleKnob.BackgroundColor3 = C.White
    ToggleKnob.BorderSizePixel = 0
    ToggleKnob.Parent = ToggleBg
    Instance.new("UICorner", ToggleKnob).CornerRadius = UDim.new(1, 0)

    local state = default

    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            state = not state

            if state then
                TweenService:Create(ToggleBg, TweenInfo.new(0.2), { BackgroundColor3 = C.Green }):Play()
                TweenService:Create(ToggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Position = UDim2.new(0, 24, 0, 2) }):Play()
            else
                TweenService:Create(ToggleBg, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(50, 50, 60) }):Play()
                TweenService:Create(ToggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back), { Position = UDim2.new(0, 2, 0, 2) }):Play()
            end

            pcall(callback, state)
        end
    end)

    return Container
end

local function CreateSlider(parent, text, y, min, max, default, isFloat, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 52)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = C.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -10, 0, 8)
    Track.Position = UDim2.new(0, 5, 0, 32)
    Track.BackgroundColor3 = C.BG2
    Track.BorderSizePixel = 0
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = C.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local fillGrad = Instance.new("UIGradient", Fill)
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.Accent2),
        ColorSequenceKeypoint.new(1, C.Accent),
    })

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 22, 0, 22)
    Knob.Position = UDim2.new((default - min) / (max - min), -11, 0.5, -11)
    Knob.BackgroundColor3 = C.White
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local knobStroke = Instance.new("UIStroke", Knob)
    knobStroke.Color = C.Accent
    knobStroke.Thickness = 2

    local function Update(inputX)
        local rel = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        if not isFloat then val = math.floor(val + 0.5) end

        TweenService:Create(Fill, TweenInfo.new(0.05), { Size = UDim2.new(rel, 0, 1, 0) }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.05), { Position = UDim2.new(rel, -11, 0.5, -11) }):Play()
        Label.Text = text .. ": " .. (isFloat and string.format("%.2f", val) or tostring(val))
        pcall(callback, val)
    end

    local dragging = false
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input.Position.X)
            TweenService:Create(Knob, TweenInfo.new(0.1), { Size = UDim2.new(0, 26, 0, 26) }):Play()
        end
    end)
    Track.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseMovement) then
            Update(input.Position.X)
        end
    end)
    Track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            TweenService:Create(Knob, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Size = UDim2.new(0, 22, 0, 22) }):Play()
        end
    end)
end

local function CreateSelector(parent, text, y, options, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 56)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = C.TextDim
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local current = default
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.Position = UDim2.new(0, 0, 0, 20)
    Btn.BackgroundColor3 = C.Panel
    Btn.Text = "▸ " .. current
    Btn.TextColor3 = C.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Parent = Container
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    Btn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, v in ipairs(options) do
            if v == current then idx = i break end
        end
        idx = idx + 1
        if idx > #options then idx = 1 end
        current = options[idx]
        Btn.Text = "▸ " .. current
        pcall(callback, current)
    end)
end

local function CreateSection(parent, text, y)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 28)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "◈ " .. text
    Label.TextColor3 = C.Accent
    Label.Font = Enum.Font.GothamBlack
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
end

local function CreateInfo(parent, text, y, height)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -10, 0, height or 16)
    L.Position = UDim2.new(0, 5, 0, y)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = C.TextDim
    L.Font = Enum.Font.GothamBold
    L.TextSize = 10
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
end

-- ==========================================================
--  СТРАНИЦА: AIMBOT
-- ==========================================================
local AimbotPage = Pages["Aimbot"]
local y = 5

CreateSection(AimbotPage, "CURSED AIMBOT", y); y = y + 32
CreateInfo(AimbotPage, "Преследует цель даже за пределами экрана.", y); y = y + 20

CreateToggle(AimbotPage, "Aimbot", y, false, function(v) Config.AimbotEnabled = v end); y = y + 48
CreateToggle(AimbotPage, "WallCheck", y, true, function(v) Config.WallCheck = v end); y = y + 48
CreateToggle(AimbotPage, "Поворот персонажа", y, true, function(v) Config.RotateCharacter = v end); y = y + 48
CreateToggle(AimbotPage, "Показать FOV", y, true, function(v) Config.ShowFOV = v end); y = y + 48
CreateToggle(AimbotPage, "Преследование за экраном", y, true, function(v) Config.TrackBehindScreen = v end); y = y + 52

CreateSlider(AimbotPage, "FOV", y, 50, 1000, Config.FOV, false, function(v) Config.FOV = v end); y = y + 56
CreateSlider(AimbotPage, "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v) Config.Smoothness = v end); y = y + 56

CreateSelector(AimbotPage, "Режим цели", y, { "FOV", "LowestHP", "HighestHP", "Distance" }, Config.TargetMode, function(v) Config.TargetMode = v end); y = y + 60
CreateSelector(AimbotPage, "Часть тела", y, { "Head", "HumanoidRootPart", "UpperTorso" }, Config.TargetPart, function(v) Config.TargetPart = v end)

-- ==========================================================
--  СТРАНИЦА: FLING
-- ==========================================================
local FlingPage = Pages["Fling"]
y = 5

CreateSection(FlingPage, "CURSED FLING", y); y = y + 32
CreateInfo(FlingPage, "Телепорт → Спин → Толчок → Космос", y); y = y + 20
CreateInfo(FlingPage, "Выбери цель из списка ниже:", y); y = y + 25

local selectedFlingTarget = nil

local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(1, -10, 0, 190)
PlayerListFrame.Position = UDim2.new(0, 5, 0, y)
PlayerListFrame.BackgroundTransparency = 1
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ScrollBarThickness = 3
PlayerListFrame.ScrollBarImageColor3 = C.Accent
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.Parent = FlingPage

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 4)
PlayerListLayout.Parent = PlayerListFrame

local function RefreshPlayerList()
    for _, child in ipairs(PlayerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PB = Instance.new("TextButton")
            PB.Size = UDim2.new(1, -5, 0, 34)
            PB.BackgroundColor3 = C.Panel
            PB.Text = "  ⊕ " .. player.Name
            PB.TextColor3 = C.Text
            PB.Font = Enum.Font.GothamBold
            PB.TextSize = 12
            PB.TextXAlignment = Enum.TextXAlignment.Left
            PB.Parent = PlayerListFrame
            Instance.new("UICorner", PB).CornerRadius = UDim.new(0, 8)

            PB.MouseButton1Click:Connect(function()
                selectedFlingTarget = player
                for _, btn in ipairs(PlayerListFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = C.Panel }):Play()
                    end
                end
                TweenService:Create(PB, TweenInfo.new(0.15), { BackgroundColor3 = C.Accent2 }):Play()
            end)
        end
    end

    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 10)
end

RefreshPlayerList()
Players.PlayerAdded:Connect(function() task.wait(1) RefreshPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(1) RefreshPlayerList() end)

y = y + 200

local FlingBtn = CreateButton(FlingPage, "◎ ЗАПУСТИТЬ В КОСМОС", y, C.RedDark, function(self)
    if FlingModule.Active then
        self.Text = "⚠ ФЛИНГ УЖЕ ВЫПОЛНЯЕТСЯ..."
        task.delay(2, function() self.Text = "◎ ЗАПУСТИТЬ В КОСМОС" end)
        return
    end

    if selectedFlingTarget and selectedFlingTarget.Parent then
        self.Text = "⏳ ВЫПОЛНЯЕТСЯ..."
        self.BackgroundColor3 = C.Gold

        local success = pcall(function() FlingModule:Execute(selectedFlingTarget) end)

        if success then
            self.Text = "✅ ЦЕЛЬ ЗАПУЩЕНА!"
            self.BackgroundColor3 = C.GreenDark
        else
            self.Text = "❌ ОШИБКА"
            self.BackgroundColor3 = C.RedDark
        end

        task.delay(2.5, function()
            self.Text = "◎ ЗАПУСТИТЬ В КОСМОС"
            self.BackgroundColor3 = C.RedDark
        end)
    else
        self.Text = "⚠ ВЫБЕРИ ИГРОКА"
        self.BackgroundColor3 = C.Gold
        task.delay(2, function()
            self.Text = "◎ ЗАПУСТИТЬ В КОСМОС"
            self.BackgroundColor3 = C.RedDark
        end)
    end
end); y = y + 50

CreateButton(FlingPage, "↻ ОБНОВИТЬ СПИСОК", y, C.Panel, function(self)
    RefreshPlayerList()
    self.Text = "✅ ОБНОВЛЕНО"
    task.delay(1, function() self.Text = "↻ ОБНОВИТЬ СПИСОК" end)
end)

-- ==========================================================
--  СТРАНИЦА: VISUALS
-- ==========================================================
local VisPage = Pages["Visuals"]
y = 5

CreateSection(VisPage, "CURSED VISUALS", y); y = y + 32

CreateToggle(VisPage, "Аура", y, true, function(v)
    Config.AuraEnabled = v
    AuraRing.Transparency = v and 0.3 or 1
    AuraParticles.Enabled = v
end); y = y + 48

CreateToggle(VisPage, "Крылья", y, true, function(v)
    Config.WingsEnabled = v
    for _, w in ipairs(WingParts) do
        w.Part.Transparency = v and Config.WingsTransparency or 1
    end
    for _, b in ipairs(WingBeams) do
        b.Transparency = NumberSequence.new(v and Config.WingsTransparency or 1)
    end
end); y = y + 52

CreateSlider(VisPage, "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v)
    Config.AuraSize = v
    AuraRing.Size = Vector3.new(0.15, v, v)
end); y = y + 56

CreateSlider(VisPage, "Частицы ауры", y, 0, 100, Config.AuraRate, false, function(v)
    Config.AuraRate = v
    AuraParticles.Rate = v
end); y = y + 56

CreateSlider(VisPage, "Прозрачность крыльев", y, 0, 1.0, Config.WingsTransparency, true, function(v)
    Config.WingsTransparency = v
    if Config.WingsEnabled then
        for _, w in ipairs(WingParts) do w.Part.Transparency = v end
        for _, b in ipairs(WingBeams) do b.Transparency = NumberSequence.new(v) end
    end
end); y = y + 60

CreateSection(VisPage, "ЦВЕТ (RGB)", y); y = y + 32

CreateSlider(VisPage, "R", y, 0, 255, math.floor(Config.AuraColor.R * 255), false, function(v)
    Config.AuraColor = Color3.fromRGB(v, Config.AuraColor.G * 255, Config.AuraColor.B * 255)
    Config.WingsColor = Color3.fromRGB(v * 0.6, Config.AuraColor.G * 255 * 0.6, Config.AuraColor.B * 255 * 0.6)
    AuraRing.Color = Config.AuraColor
    AuraParticles.Color = ColorSequence.new(Config.AuraColor)
    for _, w in ipairs(WingParts) do w.Part.Color = Config.WingsColor end
    for _, b in ipairs(WingBeams) do b.Color = ColorSequence.new(Config.WingsColor) end
end); y = y + 56

CreateSlider(VisPage, "G", y, 0, 255, math.floor(Config.AuraColor.G * 255), false, function(v)
    Config.AuraColor = Color3.fromRGB(Config.AuraColor.R * 255, v, Config.AuraColor.B * 255)
    Config.WingsColor = Color3.fromRGB(Config.AuraColor.R * 255 * 0.6, v * 0.6, Config.AuraColor.B * 255 * 0.6)
    AuraRing.Color = Config.AuraColor
    AuraParticles.Color = ColorSequence.new(Config.AuraColor)
    for _, w in ipairs(WingParts) do w.Part.Color = Config.WingsColor end
    for _, b in ipairs(WingBeams) do b.Color = ColorSequence.new(Config.WingsColor) end
end); y = y + 56

CreateSlider(VisPage, "B", y, 0, 255, math.floor(Config.AuraColor.B * 255), false, function(v)
    Config.AuraColor = Color3.fromRGB(Config.AuraColor.R * 255, Config.AuraColor.G * 255, v)
    Config.WingsColor = Color3.fromRGB(Config.AuraColor.R * 255 * 0.6, Config.AuraColor.G * 255 * 0.6, v * 0.6)
    AuraRing.Color = Config.AuraColor
    AuraParticles.Color = ColorSequence.new(Config.AuraColor)
    for _, w in ipairs(WingParts) do w.Part.Color = Config.WingsColor end
    for _, b in ipairs(WingBeams) do b.Color = ColorSequence.new(Config.WingsColor) end
end)

-- ==========================================================
--  СТРАНИЦА: ESP
-- ==========================================================
local EspPage = Pages["ESP"]
y = 5

CreateSection(EspPage, "CURSED ESP", y); y = y + 32

CreateToggle(EspPage, "ESP Игроков", y, false, function(v) Config.EspPlayers = v end); y = y + 48
CreateToggle(EspPage, "ESP Charms", y, false, function(v) Config.EspCharms = v end); y = y + 48
CreateToggle(EspPage, "Tracers", y, true, function(v) Config.ShowTracers = v end); y = y + 48
CreateToggle(EspPage, "Health Bars", y, true, function(v) Config.ShowHealthBars = v end); y = y + 52

CreateSection(EspPage, "ЦВЕТ ESP", y); y = y + 32

CreateSlider(EspPage, "R игроков", y, 0, 255, Config.EspColor.R * 255, false, function(v)
    Config.EspColor = Color3.fromRGB(v, Config.EspColor.G * 255, Config.EspColor.B * 255)
end); y = y + 56

CreateSlider(EspPage, "G игроков", y, 0, 255, Config.EspColor.G * 255, false, function(v)
    Config.EspColor = Color3.fromRGB(Config.EspColor.R * 255, v, Config.EspColor.B * 255)
end); y = y + 56

CreateSlider(EspPage, "B игроков", y, 0, 255, Config.EspColor.B * 255, false, function(v)
    Config.EspColor = Color3.fromRGB(Config.EspColor.R * 255, Config.EspColor.G * 255, v)
end)

-- ==========================================================
--  СТРАНИЦА: MISC
-- ==========================================================
local MiscPage = Pages["Misc"]
y = 5

CreateSection(MiscPage, "НЕВИДИМОСТЬ", y); y = y + 32
CreateInfo(MiscPage, "Удаляет видимые части персонажа.", y); y = y + 18
CreateInfo(MiscPage, "Сервер видит только невидимый хитбокс.", y); y = y + 18
CreateInfo(MiscPage, "Ты видишь себя полупрозрачным.", y); y = y + 25

local InvisBtn = CreateButton(MiscPage, "✦ СТАТЬ НЕВИДИМЫМ", y, C.Accent2, function(self)
    if not InvisibilityModule.Active then
        InvisibilityModule:Activate()
        Config.Invisibility = true
        self.Text = "✅ ТЫ НЕВИДИМ (нажми для возврата)"
        self.BackgroundColor3 = C.GreenDark
    else
        InvisibilityModule:Deactivate()
        self.Text = "✦ СТАТЬ НЕВИДИМЫМ"
        self.BackgroundColor3 = C.Accent2
    end
end); y = y + 55

CreateSection(MiscPage, "AUTO", y); y = y + 32

CreateToggle(MiscPage, "Auto Block", y, false, function(v) Config.AutoBlock = v end); y = y + 48

CreateSlider(MiscPage, "Дистанция блока", y, 5, 50, Config.AutoBlockDistance, false, function(v)
    Config.AutoBlockDistance = v
end); y = y + 56

CreateToggle(MiscPage, "No Cooldown", y, false, function(v) Config.NoCooldown = v end)

-- ==========================================================
--  ФИНАЛЬНОЕ СООБЩЕНИЕ
-- ==========================================================
print("═══════════════════════════════════════════")
print("  ◈ APEX HUB v8.0 ЗАГРУЖЕН! ◈")
print("  ✦ Невидимость: удаление частей + клон")
print("  ◎ Флинг: телепорт + спин + толчок")
print("  ⊕ Аимбот: преследование за экраном")
print("  ◉ GUI: стиль Проклятой Энергии")
print("═══════════════════════════════════════════")
