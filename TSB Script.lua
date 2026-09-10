-- ==========================================================
--  JJS ULTIMATE SCRIPT (Mobile)
--  Aimbot + AutoBlock + AutoCounter + Aura + Black Wings
--  Автор: собран по твоему запросу
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================================
--  ГЛАВНЫЕ НАСТРОЙКИ
-- ==========================================================
local Config = {
    -- Aimbot
    AimbotEnabled = false,
    FOV = 200,                -- 10..600
    Smoothness = 0.15,        -- 0.01..1 (меньше = быстрее)
    TargetPart = "Head",

    -- Auto Block / Counter
    AutoBlock = false,
    AutoCounter = false,
    AutoBlockDistance = 15,

    -- Визуалы
    AuraEnabled = true,
    WingsEnabled = true,
    AuraColor = Color3.fromRGB(150, 0, 255),
    WingsColor = Color3.fromRGB(80, 0, 120),
    WingsTransparency = 0.2,  -- 0 = ярко, 1 = еле видно
    AuraSize = 6,
    AuraRate = 35,
}

-- ==========================================================
--  ПЕРСОНАЖ
-- ==========================================================
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")

-- ==========================================================
--  БЛОК 1: АУРА ДЗЮДО
-- ==========================================================
local AuraRing = Instance.new("Part")
AuraRing.Shape = Enum.PartType.Cylinder
AuraRing.Size = Vector3.new(0.15, Config.AuraSize, Config.AuraSize)
AuraRing.Anchored = false
AuraRing.CanCollide = false
AuraRing.Massless = true
AuraRing.Color = Config.AuraColor
AuraRing.Material = Enum.Material.Neon
AuraRing.Transparency = 0.3
AuraRing.Parent = Character

local RingWeld = Instance.new("WeldConstraint")
RingWeld.Part0 = AuraRing
RingWeld.Part1 = Root
RingWeld.Parent = AuraRing
AuraRing.CFrame = Root.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, math.rad(90))

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
--  БЛОК 2: КРЫЛЬЯ ЧЁРНОЙ ЭНЕРГИИ
-- ==========================================================
local Wings = {}

local function CreateWing(side)
    local WingModel = Instance.new("Model")
    WingModel.Name = "EnergyWing" .. side
    WingModel.Parent = Character

    local segments = {}
    for i = 1, 3 do
        local Seg = Instance.new("Part")
        Seg.Size = Vector3.new(0.2, 3 - i * 0.5, 1.2)
        Seg.Anchored = false
        Seg.CanCollide = false
        Seg.Massless = true
        Seg.Color = Config.WingsColor
        Seg.Material = Enum.Material.Neon
        Seg.Transparency = Config.WingsTransparency
        Seg.Parent = WingModel

        local W = Instance.new("WeldConstraint")
        W.Part0 = Seg
        W.Part1 = Torso
        W.Parent = Seg

        local offsetX = (i - 1) * 0.9 * side
        local offsetY = 1.5 + i * 0.3
        Seg.CFrame = Torso.CFrame * CFrame.new(offsetX, offsetY, 0.8)
            * CFrame.Angles(0, math.rad(-30 * side), math.rad(20 * side))

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
    end

    local Att = Instance.new("Attachment", segments[#segments])
    local Part = Instance.new("ParticleEmitter")
    Part.Parent = Att
    Part.Texture = "rbxassetid://243098098"
    Part.Rate = 15
    Part.Lifetime = NumberRange.new(0.5, 1)
    Part.Speed = NumberRange.new(1, 3)
    Part.SpreadAngle = Vector2.new(30, 30)
    Part.Color = ColorSequence.new(Config.WingsColor)
    Part.Size = NumberSequence.new(0.4)
    Part.Transparency = NumberSequence.new(Config.WingsTransparency)
    Part.LightEmission = 1

    return WingModel
end

Wings.Right = CreateWing(1)
Wings.Left = CreateWing(-1)

-- ==========================================================
--  БЛОК 3: FOV CIRCLE (визуальный круг аимбота)
-- ==========================================================
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.NumSides = 60
FovCircle.Radius = Config.FOV
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Transparency = 1
FovCircle.Visible = false

RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Radius = Config.FOV
    FovCircle.Visible = Config.AimbotEnabled
end)

-- ==========================================================
--  БЛОК 4: AIMBOT
-- ==========================================================
local function GetClosestPlayer()
    local closestDist = Config.FOV
    local target = nil
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(Config.TargetPart)
                or player.Character:FindFirstChild("Head")
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        target = part
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if Config.AimbotEnabled then
        local targetPart = GetClosestPlayer()
        if targetPart then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
        end
    end
end)

-- ==========================================================
--  БЛОК 5: AUTO BLOCK / AUTO COUNTER
--  ЗАМЕНИ имена RemoteEvent'ов на реальные из своей игры!
-- ==========================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Примеры (проверь через Dex Explorer!):
-- local BlockRemote = ReplicatedStorage:FindFirstChild("BlockRemote")
-- local CounterRemote = ReplicatedStorage:FindFirstChild("CounterRemote")

RunService.Heartbeat:Connect(function()
    if Config.AutoBlock then
        -- Логика: если враг близко — активируем блок
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                if dist < Config.AutoBlockDistance then
                    -- Вставь сюда свой RemoteEvent:
                    -- if BlockRemote then BlockRemote:FireServer() end
                    -- Либо активируй инструмент:
                    -- local tool = Character:FindFirstChildOfClass("Tool")
                    -- if tool then tool:Activate() end
                end
            end
        end
    end

    if Config.AutoCounter then
        -- Логика авто-контры (паррирования). Аналогично — свой RemoteEvent.
        -- if CounterRemote then CounterRemote:FireServer() end
    end
end)

-- ==========================================================
--  БЛОК 6: МОБИЛЬНОЕ МЕНЮ (UI)
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJS_Ultimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 500)
Frame.Position = UDim2.new(0, 15, 0, 60)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BackgroundTransparency = 0.15
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundTransparency = 1
Title.Text = "⚡ JJS ULTIMATE ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

-- Утилита для кнопок
local function MakeButton(text, x, y, w, h, color)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(w, 0, 0, h)
    B.Position = UDim2.new(x, 0, 0, y)
    B.BackgroundColor3 = color or Color3.fromRGB(60, 60, 70)
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.Gotham
    B.TextSize = 11
    B.Parent = Frame
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    return B
end

-- ===== Кнопки Aimbot / FOV / Smooth =====
local AimBtn = MakeButton("Aimbot: ВЫКЛ", 0.05, 35, 0.9, 30, Color3.fromRGB(150, 40, 40))
AimBtn.Font = Enum.Font.GothamBold

local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(0.9, 0, 0, 18)
FovLabel.Position = UDim2.new(0.05, 0, 0, 70)
FovLabel.BackgroundTransparency = 1
FovLabel.Text = "FOV: " .. Config.FOV
FovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FovLabel.Font = Enum.Font.Gotham
FovLabel.TextSize = 11
FovLabel.TextXAlignment = Enum.TextXAlignment.Left
FovLabel.Parent = Frame

local FovBtn = MakeButton("+50 FOV (10..600)", 0.05, 90, 0.9, 26)

local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(0.9, 0, 0, 18)
SmoothLabel.Position = UDim2.new(0.05, 0, 0, 120)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.Text = "Плавность: " .. Config.Smoothness
SmoothLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SmoothLabel.Font = Enum.Font.Gotham
SmoothLabel.TextSize = 11
SmoothLabel.TextXAlignment = Enum.TextXAlignment.Left
SmoothLabel.Parent = Frame

local SmoothBtn = MakeButton("+0.05 (0.01..1)", 0.05, 140, 0.9, 26)

-- ===== Auto Block / Counter =====
local BlockBtn = MakeButton("Auto Block: ВЫКЛ", 0.05, 175, 0.9, 30, Color3.fromRGB(40, 60, 150))
BlockBtn.Font = Enum.Font.GothamBold

local CounterBtn = MakeButton("Auto Counter: ВЫКЛ", 0.05, 210, 0.9, 30, Color3.fromRGB(150, 110, 40))
CounterBtn.Font = Enum.Font.GothamBold

-- ===== Аура / Крылья вкл-выкл =====
local AuraBtn = MakeButton("Аура: ВКЛ", 0.05, 250, 0.43, 28, Color3.fromRGB(0, 130, 0))
local WingBtn = MakeButton("Крылья: ВКЛ", 0.52, 250, 0.43, 28, Color3.fromRGB(0, 130, 0))

-- ===== Палитра RGB =====
local function MakeColorRow(name, y)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.15, 0, 0, 24)
    L.Position = UDim2.new(0.05, 0, 0, y)
    L.BackgroundTransparency = 1
    L.Text = name
    L.TextColor3 = Color3.fromRGB(200, 200, 200)
    L.Font = Enum.Font.Gotham
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = Frame

    local S = MakeButton("0", 0.22, y, 0.73, 24)
    return S
end

local RSlider = MakeColorRow("R", 290)
local GSlider = MakeColorRow("G", 318)
local BSlider = MakeColorRow("B", 346)

local Preview = Instance.new("Frame")
Preview.Size = UDim2.new(0.9, 0, 0, 18)
Preview.Position = UDim2.new(0.05, 0, 0, 376)
Preview.BackgroundColor3 = Config.AuraColor
Preview.BorderSizePixel = 0
Preview.Parent = Frame
Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

-- Заполняем текущие значения
RSlider.Text = tostring(math.floor(Config.AuraColor.R * 255))
GSlider.Text = tostring(math.floor(Config.AuraColor.G * 255))
BSlider.Text = tostring(math.floor(Config.AuraColor.B * 255))

-- ===== Чёткость крыльев =====
local ClearLabel = Instance.new("TextLabel")
ClearLabel.Size = UDim2.new(0.9, 0, 0, 18)
ClearLabel.Position = UDim2.new(0.05, 0, 0, 400)
ClearLabel.BackgroundTransparency = 1
ClearLabel.Text = "Чёткость: " .. Config.WingsTransparency
ClearLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ClearLabel.Font = Enum.Font.Gotham
ClearLabel.TextSize = 11
ClearLabel.TextXAlignment = Enum.TextXAlignment.Left
ClearLabel.Parent = Frame

local ClearBtn = MakeButton("Изменить чёткость", 0.05, 420, 0.9, 26)

-- ==========================================================
--  ЛОГИКА UI
-- ==========================================================

-- Aimbot
AimBtn.MouseButton1Click:Connect(function()
    Config.AimbotEnabled = not Config.AimbotEnabled
    AimBtn.Text = "Aimbot: " .. (Config.AimbotEnabled and "ВКЛ" or "ВЫКЛ")
    AimBtn.BackgroundColor3 = Config.AimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 40, 40)
end)

FovBtn.MouseButton1Click:Connect(function()
    Config.FOV = Config.FOV + 50
    if Config.FOV > 600 then Config.FOV = 10 end
    FovLabel.Text = "FOV: " .. Config.FOV
end)

SmoothBtn.MouseButton1Click:Connect(function()
    Config.Smoothness = Config.Smoothness + 0.05
    if Config.Smoothness > 1 then Config.Smoothness = 0.01 end
    SmoothLabel.Text = string.format("Плавность: %.2f", Config.Smoothness)
end)

-- Auto Block / Counter
BlockBtn.MouseButton1Click:Connect(function()
    Config.AutoBlock = not Config.AutoBlock
    BlockBtn.Text = "Auto Block: " .. (Config.AutoBlock and "ВКЛ" or "ВЫКЛ")
    BlockBtn.BackgroundColor3 = Config.AutoBlock and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 60, 150)
end)

CounterBtn.MouseButton1Click:Connect(function()
    Config.AutoCounter = not Config.AutoCounter
    CounterBtn.Text = "Auto Counter: " .. (Config.AutoCounter and "ВКЛ" or "ВЫКЛ")
    CounterBtn.BackgroundColor3 = Config.AutoCounter and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 110, 40)
end)

-- Аура
AuraBtn.MouseButton1Click:Connect(function()
    Config.AuraEnabled = not Config.AuraEnabled
    AuraBtn.Text = "Аура: " .. (Config.AuraEnabled and "ВКЛ" or "ВЫКЛ")
    AuraBtn.BackgroundColor3 = Config.AuraEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
    AuraRing.Transparency = Config.AuraEnabled and 0.3 or 1
    AuraParticles.Enabled = Config.AuraEnabled
end)

-- Крылья
WingBtn.MouseButton1Click:Connect(function()
    Config.WingsEnabled = not Config.WingsEnabled
    WingBtn.Text = "Крылья: " .. (Config.WingsEnabled and "ВКЛ" or "ВЫКЛ")
    WingBtn.BackgroundColor3 = Config.WingsEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
    for _, wing in pairs(Wings) do
        for _, p in pairs(wing:GetDescendants()) do
            if p:IsA("Part") then
                p.Transparency = Config.WingsEnabled and Config.WingsTransparency or 1
            elseif p:IsA("Beam") then
                p.Transparency = NumberSequence.new(Config.WingsEnabled and Config.WingsTransparency or 1)
            elseif p:IsA("ParticleEmitter") then
                p.Enabled = Config.WingsEnabled
            end
        end
    end
end)

-- Палитра RGB
local function UpdateColors()
    local r = math.clamp(tonumber(RSlider.Text) or 0, 0, 255)
    local g = math.clamp(tonumber(GSlider.Text) or 0, 0, 255)
    local b = math.clamp(tonumber(BSlider.Text) or 0, 0, 255)

    Config.AuraColor = Color3.fromRGB(r, g, b)
    Config.WingsColor = Color3.fromRGB(r * 0.6, g * 0.6, b * 0.6)
    Preview.BackgroundColor3 = Config.AuraColor

    AuraRing.Color = Config.AuraColor
    AuraParticles.Color = ColorSequence.new(Config.AuraColor)

    for _, wing in pairs(Wings) do
        for _, p in pairs(wing:GetDescendants()) do
            if p:IsA("Part") then
                p.Color = Config.WingsColor
            elseif p:IsA("Beam") then
                p.Color = ColorSequence.new(Config.WingsColor)
            elseif p:IsA("ParticleEmitter") then
                p.Color = ColorSequence.new(Config.WingsColor)
            end
        end
    end
end

RSlider.MouseButton1Click:Connect(function()
    local v = (tonumber(RSlider.Text) or 0) + 25
    if v > 255 then v = 0 end
    RSlider.Text = tostring(v)
    UpdateColors()
end)
GSlider.MouseButton1Click:Connect(function()
    local v = (tonumber(GSlider.Text) or 0) + 25
    if v > 255 then v = 0 end
    GSlider.Text = tostring(v)
    UpdateColors()
end)
BSlider.MouseButton1Click:Connect(function()
    local v = (tonumber(BSlider.Text) or 0) + 25
    if v > 255 then v = 0 end
    BSlider.Text = tostring(v)
    UpdateColors()
end)

-- Чёткость
ClearBtn.MouseButton1Click:Connect(function()
    Config.WingsTransparency = Config.WingsTransparency + 0.1
    if Config.WingsTransparency > 1 then Config.WingsTransparency = 0 end
    ClearLabel.Text = string.format("Чёткость: %.2f", Config.WingsTransparency)

    for _, wing in pairs(Wings) do
        for _, p in pairs(wing:GetDescendants()) do
            if p:IsA("Part") then
                p.Transparency = Config.WingsTransparency
            elseif p:IsA("Beam") then
                p.Transparency = NumberSequence.new(Config.WingsTransparency)
            elseif p:IsA("ParticleEmitter") then
                p.Transparency = NumberSequence.new(Config.WingsTransparency)
            end
        end
    end
end)

-- ==========================================================
--  РЕСПАВН: перезапусти скрипт заново
-- ==========================================================
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    print("[JJS Ultimate] Ты умер. Перезапусти скрипт через экзекутор.")
end)

print("[JJS Ultimate] Загружено! Меню слева.")
