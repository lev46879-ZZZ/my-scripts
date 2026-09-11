-- ==========================================================
--  APEX HUB | JJS | 3 МЕТОДА НЕВИДИМОСТИ
--  Попробуй каждый и посмотри какой работает!
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Drawing = drawing or Drawing

local Config = {
    AimbotEnabled = false,
    FOV = 200,
    Smoothness = 0.1,
    TargetPart = "Head",
    WallCheck = true,

    AuraEnabled = true,
    WingsEnabled = true,
    AuraColor = Color3.fromRGB(150, 0, 255),
    WingsColor = Color3.fromRGB(80, 0, 120),
    AuraSize = 6,
    AuraRate = 35,

    EspPlayers = false,
    EspColor = Color3.fromRGB(255, 50, 50),

    InvisMethod = 0, -- 0=выкл, 1, 2, 3
}

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- ==========================================================
--  МОДУЛЬ НЕВИДИМОСТИ (3 МЕТОДА)
-- ==========================================================
local Invis = {
    Method = 0,
    Clone = nil,
    Conn = nil,
    SavedParts = {},
    SavedCFrame = nil,
}

-- Вспомогательная: создать прозрачный клон для себя
function Invis:MakeClone()
    pcall(function()
        if self.Clone and self.Clone.Parent then self.Clone:Destroy() end

        self.Clone = Character:Clone()
        self.Clone.Name = "VisClone"
        self.Clone.Parent = workspace

        for _, obj in ipairs(self.Clone:GetDescendants()) do
            if obj:IsA("BaseScript") then obj:Destroy() end
            if obj:IsA("BasePart") then
                obj.Transparency = math.clamp(obj.Transparency + 0.65, 0, 0.9)
                obj.CanCollide = false
                obj.CanQuery = false
                obj.CastShadow = false
            end
        end

        local hum = self.Clone:FindFirstChildOfClass("Humanoid")
        if hum then hum:Destroy() end

        -- Синхронизация клона с оригиналом
        self.Conn = RunService.Heartbeat:Connect(function()
            if self.Method == 0 then return end
            if not self.Clone or not self.Clone.Parent then return end
            pcall(function()
                for _, orig in ipairs(Character:GetDescendants()) do
                    if orig:IsA("BasePart") then
                        local cl = self.Clone:FindFirstChild(orig.Name)
                        if cl and cl:IsA("BasePart") then
                            cl.CFrame = orig.CFrame
                        end
                    end
                end
            end)
        end)
    end)
end

function Invis:RemoveClone()
    if self.Conn then self.Conn:Disconnect() self.Conn = nil end
    if self.Clone and self.Clone.Parent then self.Clone:Destroy() self.Clone = nil end
end

-- ====================
--  МЕТОД 1: УДАЛЕНИЕ ЧАСТЕЙ
--  Самый мощный. Удаляет видимые части.
-- ====================
function Invis:Method1_Activate()
    print("[APEX] Метод 1: Удаление частей...")
    self.SavedParts = {}

    -- Сохраняем и удаляем все видимые части
    for _, part in ipairs(Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            table.insert(self.SavedParts, {Parent = part.Parent, Part = part})
            pcall(function() part:Destroy() end)
        end
        if part:IsA("Accessory") then
            table.insert(self.SavedParts, {Parent = part.Parent, Part = part})
            pcall(function() part:Destroy() end)
        end
    end

    -- Также удаляем из дочерних
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function() part.Transparency = 1 end)
        end
    end

    self:MakeClone()
    self.Method = 1
    print("[APEX] ✅ Метод 1 активирован!")
    print("[APEX] Части удалены. Сервер видит только хитбокс.")
    print("[APEX] ⚠ Для возврата нужно респавниться (умереть).")
end

-- ====================
--  МЕТОД 2: ПРОЗРАЧНОСТЬ
--  Безопасный. Можно выключить без респавна.
-- ====================
function Invis:Method2_Activate()
    print("[APEX] Метод 2: Прозрачность...")

    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function()
                part.Transparency = 1
                part.CanCollide = false
                part.CastShadow = false
            end)
        end
        if part:IsA("Accessory") then
            pcall(function()
                local handle = part:FindFirstChild("Handle")
                if handle then
                    handle.Transparency = 1
                    handle.CanCollide = false
                end
            end)
        end
    end

    self:MakeClone()
    self.Method = 2
    print("[APEX] ✅ Метод 2 активирован!")
    print("[APEX] Части прозрачны. Можно выключить.")
end

function Invis:Method2_Deactivate()
    print("[APEX] Метод 2: Деактивация...")

    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function()
                part.Transparency = 0
                part.CanCollide = true
                part.CastShadow = true
            end)
        end
        if part:IsA("Accessory") then
            pcall(function()
                local handle = part:FindFirstChild("Handle")
                if handle then
                    handle.Transparency = 0
                    handle.CanCollide = true
                end
            end)
        end
    end

    self:RemoveClone()
    self.Method = 0
    print("[APEX] ✅ Метод 2 деактивирован!")
end

-- ====================
--  МЕТОД 3: ТЕЛЕПОРТ В ПУСТОТУ
--  Персонаж уходит под карту.
-- ====================
function Invis:Method3_Activate()
    print("[APEX] Метод 3: Телепорт в пустоту...")

    self.SavedCFrame = Root.CFrame

    -- Ищем безопасное место под картой
    local targetPos = Vector3.new(0, -500, 0)

    -- Проверяем нет ли там киллбриков, пробуем разные позиции
    local testPositions = {
        Vector3.new(0, -500, 0),
        Vector3.new(1000, -500, 1000),
        Vector3.new(-1000, -500, -1000),
        Vector3.new(0, -1000, 0),
        Vector3.new(5000, 500, 5000),
    }

    for _, pos in ipairs(testPositions) do
        targetPos = pos
        break -- Берём первую позицию
    end

    pcall(function()
        Root.CFrame = CFrame.new(targetPos)
    end)

    -- Замораживаем чтобы не падать дальше
    pcall(function()
        local hum = Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true
        end
    end)

    self.Method = 3
    print("[APEX] ✅ Метод 3 активирован!")
    print("[APEX] Персонаж телепортирован далеко.")
    print("[APEX] Нажми кнопку чтобы вернуться.")
end

function Invis:Method3_Deactivate()
    print("[APEX] Метод 3: Возврат...")

    pcall(function()
        local hum = Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end)

    if self.SavedCFrame then
        pcall(function()
            Root.CFrame = self.SavedCFrame
        end)
    end

    self.Method = 0
    print("[APEX] ✅ Метод 3 деактивирован!")
end

-- Общая функция выключения
function Invis:Deactivate()
    if self.Method == 2 then
        self:Method2_Deactivate()
    elseif self.Method == 3 then
        self:Method3_Deactivate()
    elseif self.Method == 1 then
        print("[APEX] ⚠ Метод 1 нельзя выключить без респавна!")
        print("[APEX] Умри чтобы вернуть персонажа.")
        self:RemoveClone()
        self.Method = 0
    else
        self:RemoveClone()
        self.Method = 0
    end
end

-- ==========================================================
--  АУРА И КРЫЛЬЯ (из оригинала)
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
        Seg.Transparency = 0.2
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
        Beam.Transparency = NumberSequence.new(0.2)
        Beam.LightEmission = 1
        Beam.FaceCamera = true
        Beam.Parent = segments[i]
        table.insert(WingBeams, Beam)
    end
end

CreateWing(1)
CreateWing(-1)

RunService.Heartbeat:Connect(function()
    if not Root or not Root.Parent then return end
    local showVis = (Invis.Method == 0)
    if Config.AuraEnabled and showVis then
        AuraRing.CFrame = Root.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, math.rad(90))
    else
        AuraRing.CFrame = CFrame.new(0, -9999, 0)
    end
    if Config.WingsEnabled and showVis then
        for _, w in ipairs(WingParts) do w.Part.CFrame = Root.CFrame * w.BaseOffset end
    else
        for _, w in ipairs(WingParts) do w.Part.CFrame = CFrame.new(0, -9999, 0) end
    end
end)

-- ==========================================================
--  АИМБОТ
-- ==========================================================
local FovCircle = nil
if Drawing then
    pcall(function()
        FovCircle = Drawing.new("Circle")
        FovCircle.Thickness = 1.5
        FovCircle.NumSides = 80
        FovCircle.Radius = Config.FOV
        FovCircle.Filled = false
        FovCircle.Color = Color3.fromRGB(180, 50, 255)
        FovCircle.Transparency = 0.6
        FovCircle.Visible = false
    end)
end

if FovCircle then
    RunService.RenderStepped:Connect(function()
        FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FovCircle.Radius = Config.FOV
        FovCircle.Visible = Config.AimbotEnabled
    end)
end

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

local function PickTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestScore = nil, nil
    for _, info in ipairs(GetAlivePlayers()) do
        local part = info.Player.Character:FindFirstChild(Config.TargetPart) or info.Player.Character:FindFirstChild("Head")
        if part then
            local screenPos = Camera:WorldToViewportPoint(part.Position)
            local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if fovDist <= Config.FOV * 3 then
                if bestScore == nil or fovDist < bestScore then
                    best, bestScore = part, fovDist
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function(dt)
    if not Config.AimbotEnabled then return end
    local target = PickTarget()
    if target then
        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.lookAt(camPos, target.Position)
        local alpha = math.clamp(1 - Config.Smoothness, 0.01, 1)
        local smoothAlpha = 1 - (1 - alpha) ^ (dt * 60)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, smoothAlpha)
    end
end)

-- ==========================================================
--  GUI (ШИРОКИЙ, НИЗКИЙ, ВСЁ ТОГГЛЫ)
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexInvis"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 60, 0, 60)
FloatBtn.Position = UDim2.new(0, 12, 0.45, -30)
FloatBtn.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
FloatBtn.Text = "◈"
FloatBtn.TextColor3 = Color3.fromRGB(147, 30, 255)
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 26
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = Color3.fromRGB(147, 30, 255)
FloatStroke.Thickness = 2.5

-- Меню: широкое и низкое
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
MainFrame.BackgroundTransparency = 0.02
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(147, 30, 255)
MainStroke.Thickness = 2

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "◈ APEX HUB | НЕВИДИМОСТЬ"
Title.TextColor3 = Color3.fromRGB(225, 218, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 20, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local function ToggleMenu()
    MainFrame.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)

-- Утилита: кнопка
local function MakeBtn(parent, text, y, color, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -10, 0, 42)
    B.Position = UDim2.new(0, 5, 0, y)
    B.BackgroundColor3 = color
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    B.Parent = parent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 9)
    B.MouseButton1Click:Connect(function() pcall(callback, B) end)
    return B
end

-- Утилита: тоггл
local function MakeToggle(parent, text, y, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 40)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundColor3 = Color3.fromRGB(20, 16, 36)
    Container.BorderSizePixel = 0
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 9)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(225, 218, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local TBg = Instance.new("Frame")
    TBg.Size = UDim2.new(0, 42, 0, 22)
    TBg.Position = UDim2.new(1, -52, 0.5, -11)
    TBg.BackgroundColor3 = default and Color3.fromRGB(40, 230, 120) or Color3.fromRGB(60, 60, 70)
    TBg.BorderSizePixel = 0
    TBg.Parent = Container
    Instance.new("UICorner", TBg).CornerRadius = UDim.new(1, 0)

    local TK = Instance.new("Frame")
    TK.Size = UDim2.new(0, 18, 0, 18)
    TK.Position = default and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
    TK.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TK.BorderSizePixel = 0
    TK.Parent = TBg
    Instance.new("UICorner", TK).CornerRadius = UDim.new(1, 0)

    local state = default
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            if state then
                TweenService:Create(TBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 230, 120)}):Play()
                TweenService:Create(TK, TweenInfo.new(0.2), {Position = UDim2.new(0, 22, 0, 2)}):Play()
            else
                TweenService:Create(TBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
                TweenService:Create(TK, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
            end
            pcall(callback, state)
        end
    end)
end

-- Утилита: заголовок секции
local function MakeSection(parent, text, y)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -10, 0, 22)
    L.Position = UDim2.new(0, 5, 0, y)
    L.BackgroundTransparency = 1
    L.Text = "◈ " .. text
    L.TextColor3 = Color3.fromRGB(147, 30, 255)
    L.Font = Enum.Font.GothamBlack
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
end

-- Утилита: инфо текст
local function MakeInfo(parent, text, y)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -10, 0, 14)
    L.Position = UDim2.new(0, 5, 0, y)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(130, 120, 165)
    L.Font = Enum.Font.GothamBold
    L.TextSize = 10
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
end

-- Утилита: слайдер
local function MakeSlider(parent, text, y, min, max, default, isFloat, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 48)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(225, 218, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -10, 0, 8)
    Track.Position = UDim2.new(0, 5, 0, 28)
    Track.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
    Track.BorderSizePixel = 0
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(147, 30, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local function Update(inputX)
        local rel = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        if not isFloat then val = math.floor(val + 0.5) end
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, -10, 0.5, -10)
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

-- ==========================================================
--  КОНТЕНТ МЕНЮ
-- ==========================================================

-- Скролл
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -55)
Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(147, 30, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 750)
Scroll.Parent = MainFrame

local y = 0

-- === СЕКЦИЯ НЕВИДИМОСТИ ===
MakeSection(Scroll, "НЕВИДИМОСТЬ (3 МЕТОДА)", y); y = y + 26
MakeInfo(Scroll, "Попробуй каждый метод. Какой работает — тот и юзай!", y); y = y + 20

MakeBtn(Scroll, "1️⃣ МЕТОД 1: УДАЛЕНИЕ ЧАСТЕЙ", y, Color3.fromRGB(147, 30, 255), function(self)
    if Invis.Method == 1 then
        self.Text = "⚠ Метод 1 уже активен!"
        task.delay(1.5, function() self.Text = "1️⃣ МЕТОД 1: УДАЛЕНИЕ ЧАСТЕЙ" end)
        return
    end
    Invis:Deactivate()
    Invis:Method1_Activate()
    self.Text = "✅ МЕТОД 1 АКТИВЕН"
    self.BackgroundColor3 = Color3.fromRGB(40, 230, 120)
end); y = y + 48

MakeInfo(Scroll, "⚠ Метод 1: нельзя выключить без респавна", y); y = y + 20

MakeBtn(Scroll, "2️⃣ МЕТОД 2: ПРОЗРАЧНОСТЬ", y, Color3.fromRGB(90, 15, 180), function(self)
    if Invis.Method == 2 then
        Invis:Method2_Deactivate()
        self.Text = "2️⃣ МЕТОД 2: ПРОЗРАЧНОСТЬ"
        self.BackgroundColor3 = Color3.fromRGB(90, 15, 180)
    else
        Invis:Deactivate()
        Invis:Method2_Activate()
        self.Text = "✅ МЕТОД 2 АКТИВЕН (нажми = выкл)"
        self.BackgroundColor3 = Color3.fromRGB(40, 230, 120)
    end
end); y = y + 48

MakeInfo(Scroll, "✓ Метод 2: можно выключить без респавна", y); y = y + 20

MakeBtn(Scroll, "3️⃣ МЕТОД 3: ТЕЛЕПОРТ В ПУСТОТУ", y, Color3.fromRGB(40, 120, 255), function(self)
    if Invis.Method == 3 then
        Invis:Method3_Deactivate()
        self.Text = "3️⃣ МЕТОД 3: ТЕЛЕПОРТ В ПУСТОТУ"
        self.BackgroundColor3 = Color3.fromRGB(40, 120, 255)
    else
        Invis:Deactivate()
        Invis:Method3_Activate()
        self.Text = "✅ МЕТОД 3 АКТИВЕН (нажми = вернуть)"
        self.BackgroundColor3 = Color3.fromRGB(40, 230, 120)
    end
end); y = y + 48

MakeInfo(Scroll, "✓ Метод 3: персонаж уходит далеко, можно вернуть", y); y = y + 28

-- === СЕКЦИЯ АИМБОТА ===
MakeSection(Scroll, "АИМБОТ", y); y = y + 26

MakeToggle(Scroll, "Aimbot", y, false, function(v) Config.AimbotEnabled = v end); y = y + 46
MakeToggle(Scroll, "WallCheck", y, true, function(v) Config.WallCheck = v end); y = y + 50

MakeSlider(Scroll, "FOV", y, 50, 600, Config.FOV, false, function(v) Config.FOV = v end); y = y + 52
MakeSlider(Scroll, "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v) Config.Smoothness = v end); y = y + 56

-- === СЕКЦИЯ ВИЗУАЛОВ ===
MakeSection(Scroll, "ВИЗУАЛЫ", y); y = y + 26

MakeToggle(Scroll, "Аура", y, true, function(v)
    Config.AuraEnabled = v
    AuraRing.Transparency = v and 0.3 or 1
    AuraParticles.Enabled = v
end); y = y + 46

MakeToggle(Scroll, "Крылья", y, true, function(v)
    Config.WingsEnabled = v
    for _, w in ipairs(WingParts) do w.Part.Transparency = v and 0.2 or 1 end
    for _, b in ipairs(WingBeams) do b.Transparency = NumberSequence.new(v and 0.2 or 1) end
end); y = y + 50

MakeSlider(Scroll, "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v)
    Config.AuraSize = v
    AuraRing.Size = Vector3.new(0.15, v, v)
end); y = y + 52

-- === СЕКЦИЯ ESP ===
MakeSection(Scroll, "ESP", y); y = y + 26
MakeToggle(Scroll, "ESP Игроков", y, false, function(v) Config.EspPlayers = v end)

-- ==========================================================
--  ESP ЦИКЛ
-- ==========================================================
local EspTable = {}
if Drawing then
    RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and Config.EspPlayers then
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            if not EspTable[player] then
                                EspTable[player] = {
                                    Box = Drawing.new("Square"),
                                    Name = Drawing.new("Text"),
                                }
                                EspTable[player].Box.Thickness = 1.5
                                EspTable[player].Box.Filled = false
                                EspTable[player].Box.Color = Config.EspColor
                                EspTable[player].Name.Size = 13
                                EspTable[player].Name.Center = true
                                EspTable[player].Name.Outline = true
                                EspTable[player].Name.Color = Color3.fromRGB(255, 255, 255)
                            end
                            local d = EspTable[player]
                            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                            local scale = 1200 / dist
                            local boxSize = Vector2.new(scale * 1.5, scale * 2.5)
                            d.Box.Size = boxSize
                            d.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                            d.Box.Visible = true
                            d.Name.Text = player.Name
                            d.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 18)
                            d.Name.Visible = true
                        else
                            if EspTable[player] then
                                EspTable[player].Box.Visible = false
                                EspTable[player].Name.Visible = false
                            end
                        end
                    else
                        if EspTable[player] then
                            EspTable[player].Box.Visible = false
                            EspTable[player].Name.Visible = false
                        end
                    end
                end
            else
                if EspTable[player] then
                    EspTable[player].Box.Visible = false
                    EspTable[player].Name.Visible = false
                end
            end
        end
    end)
end

-- ==========================================================
print("═══════════════════════════════════════")
print("  ◈ APEX HUB ЗАГРУЖЕН! ◈")
print("  Нажми ⚡ для открытия меню")
print("  Попробуй все 3 метода невидимости!")
print("═══════════════════════════════════════")
