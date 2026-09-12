-- ==========================================================
--     ◈ APEX HUB v10 | JJS PREMIUM EDITION ◈
--     Современный GUI + Клиентские визуалы + Все функции
-- ==========================================================

print("[APEX] Загрузка Premium версии...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Безопасный Drawing
local Drawing = drawing or Drawing
if not Drawing then pcall(function() Drawing = getgenv().drawing end) end

-- Современная палитра (как в топовых читах)
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Secondary = Color3.fromRGB(22, 22, 30),
    Accent = Color3.fromRGB(120, 80, 255),
    AccentGlow = Color3.fromRGB(150, 100, 255),
    Success = Color3.fromRGB(50, 220, 130),
    Danger = Color3.fromRGB(255, 70, 90),
    Warning = Color3.fromRGB(255, 180, 50),
    Text = Color3.fromRGB(240, 240, 250),
    TextMuted = Color3.fromRGB(140, 140, 160),
    Border = Color3.fromRGB(40, 40, 55),
}

local Config = {
    AimbotEnabled = false,
    FOV = 250,
    ShowFOV = true,
    Smoothness = 0.08,
    TargetMode = "FOV",
    TargetPart = "Head",
    WallCheck = true,
    RotateCharacter = true,

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
}

print("[APEX] Ожидание персонажа...")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ==========================================================
--  НЕВИДИМОСТЬ (простая клиентская)
-- ==========================================================
local InvisModule = { Active = false, Clone = nil, Conn = nil }

function InvisModule:Activate()
    if self.Active then return end
    self.Active = true
    
    pcall(function()
        self.Clone = Character:Clone()
        self.Clone.Name = "VisClone"
        self.Clone.Parent = workspace
        for _, obj in ipairs(self.Clone:GetDescendants()) do
            if obj:IsA("BaseScript") then obj:Destroy() end
            if obj:IsA("BasePart") then
                obj.Transparency = math.clamp(obj.Transparency + 0.65, 0, 0.95)
                obj.CanCollide = false
                obj.CanQuery = false
                obj.CastShadow = false
            end
        end
        local hum = self.Clone:FindFirstChildOfClass("Humanoid")
        if hum then hum:Destroy() end
    end)
    
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function() part.Transparency = 1; part.CastShadow = false end)
        end
    end
    
    self.Conn = RunService.Heartbeat:Connect(function()
        if not self.Active or not self.Clone or not self.Clone.Parent then return end
        pcall(function()
            for _, orig in ipairs(Character:GetDescendants()) do
                if orig:IsA("BasePart") then
                    local cl = self.Clone:FindFirstChild(orig.Name)
                    if cl and cl:IsA("BasePart") then cl.CFrame = orig.CFrame end
                end
            end
        end)
    end)
    
    Config.Invisibility = true
end

function InvisModule:Deactivate()
    if not self.Active then return end
    self.Active = false
    if self.Conn then self.Conn:Disconnect(); self.Conn = nil end
    if self.Clone and self.Clone.Parent then self.Clone:Destroy(); self.Clone = nil end
    pcall(function()
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 0; part.CastShadow = true end
        end
    end)
    Config.Invisibility = false
end

-- ==========================================================
--  NO COOLDOWN
-- ==========================================================
RunService.Heartbeat:Connect(function()
    if not Config.NoCooldown then return end
    pcall(function()
        for _, desc in ipairs(Character:GetDescendants()) do
            if desc:IsA("NumberValue") or desc:IsA("IntValue") then
                local n = desc.Name:lower()
                if n:find("cool") or n:find("cd") or n:find("timer") or n:find("wait") then
                    desc.Value = 0
                end
            end
        end
    end)
end)

-- ==========================================================
--  FLING (максимально мощный)
-- ==========================================================
local FlingActive = false

local function FlingPlayer(targetPlayer)
    if FlingActive then return false end
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    local tChar = targetPlayer.Character
    if not tChar then return false end
    local tHrp = tChar:FindFirstChild("HumanoidRootPart")
    if not tHrp then return false end
    local myHrp = Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false end
    
    FlingActive = true
    local oldCF = myHrp.CFrame
    
    task.spawn(function()
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
        
        local spin = Instance.new("BodyAngularVelocity")
        spin.MaxTorque = Vector3.new(0, math.huge, 0)
        spin.AngularVelocity = Vector3.new(0, 250, 0)
        spin.Parent = myHrp
        
        for i = 1, 30 do
            if not tHrp or not tHrp.Parent then break end
            local angle = (i / 30) * math.pi * 4
            pcall(function()
                myHrp.CFrame = tHrp.CFrame * CFrame.new(math.cos(angle) * 2, math.sin(i * 0.3) * 0.5, math.sin(angle) * 2)
            end)
            task.wait(0.015)
        end
        
        if tHrp and tHrp.Parent then
            pcall(function()
                myHrp.CFrame = tHrp.CFrame
                myHrp.AssemblyLinearVelocity = Vector3.new(math.random(-300, 300), 500, math.random(-300, 300))
            end)
            pcall(function()
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(math.random(-400, 400), 800, math.random(-400, 400))
                bv.Parent = tHrp
                task.delay(2.5, function() if bv and bv.Parent then bv:Destroy() end end)
            end)
        end
        
        task.delay(0.8, function()
            if spin and spin.Parent then spin:Destroy() end
            for _, p in ipairs(Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
            pcall(function()
                if myHrp and myHrp.Parent then
                    myHrp.CFrame = oldCF
                    myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end)
            FlingActive = false
        end)
    end)
    
    return true
end

-- ==========================================================
--  АУРА И КРЫЛЬЯ (КЛИЕНТСКИЕ - только для тебя)
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

-- Делаем ауру видимой только для себя
AuraRing.LocalTransparencyModifier = 0

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
AuraParticles.Rotation = NumberRange.new(0, 360)

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
        -- Клиентская видимость
        Seg.LocalTransparencyModifier = 0
        
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
    if not Root or not Root.Parent then return end
    local showVis = not InvisModule.Active
    if Config.AuraEnabled and showVis then
        AuraRing.CFrame = Root.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, math.rad(90))
    else
        AuraRing.CFrame = CFrame.new(0, -10000, 0)
    end
    if Config.WingsEnabled and showVis then
        for _, w in ipairs(WingParts) do w.Part.CFrame = Root.CFrame * w.BaseOffset end
    else
        for _, w in ipairs(WingParts) do w.Part.CFrame = CFrame.new(0, -10000, 0) end
    end
end)

-- ==========================================================
--  FOV + ESP + AIMBOT
-- ==========================================================
local FovCircle = nil
if Drawing then
    pcall(function()
        FovCircle = Drawing.new("Circle")
        FovCircle.Thickness = 2
        FovCircle.NumSides = 100
        FovCircle.Radius = Config.FOV
        FovCircle.Filled = false
        FovCircle.Color = Theme.Accent
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
                                    Hp = Drawing.new("Text"),
                                    Tracer = Drawing.new("Line"),
                                }
                                EspTable[player].Box.Thickness = 1.5
                                EspTable[player].Box.Filled = false
                                EspTable[player].Box.Color = Config.EspColor
                                EspTable[player].Name.Size = 14
                                EspTable[player].Name.Center = true
                                EspTable[player].Name.Outline = true
                                EspTable[player].Name.Color = Theme.Text
                                EspTable[player].Hp.Size = 12
                                EspTable[player].Hp.Center = true
                                EspTable[player].Hp.Outline = true
                                EspTable[player].Hp.Color = Theme.Success
                                EspTable[player].Tracer.Thickness = 2
                                EspTable[player].Tracer.Color = Config.EspColor
                                EspTable[player].Tracer.Transparency = 0.7
                            end
                            local d = EspTable[player]
                            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                            local scale = 1200 / dist
                            local boxSize = Vector2.new(scale * 1.5, scale * 2.5)
                            d.Box.Size = boxSize
                            d.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                            d.Box.Visible = true
                            d.Name.Text = player.Name
                            d.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 20)
                            d.Name.Visible = true
                            d.Hp.Text = math.floor(hum.Health) .. " HP"
                            d.Hp.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 5)
                            d.Hp.Visible = true
                            if Config.ShowTracers then
                                d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                d.Tracer.To = Vector2.new(pos.X, pos.Y)
                                d.Tracer.Visible = true
                            else
                                d.Tracer.Visible = false
                            end
                        else
                            if EspTable[player] then
                                EspTable[player].Box.Visible = false
                                EspTable[player].Name.Visible = false
                                EspTable[player].Hp.Visible = false
                                EspTable[player].Tracer.Visible = false
                            end
                        end
                    else
                        if EspTable[player] then
                            EspTable[player].Box.Visible = false
                            EspTable[player].Name.Visible = false
                            EspTable[player].Hp.Visible = false
                            EspTable[player].Tracer.Visible = false
                        end
                    end
                end
            else
                if EspTable[player] then
                    EspTable[player].Box.Visible = false
                    EspTable[player].Name.Visible = false
                    EspTable[player].Hp.Visible = false
                    EspTable[player].Tracer.Visible = false
                end
            end
        end
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

local function IsVisible(targetPart)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local distance = direction.Magnitude
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, direction.Unit * distance, params)
    if result then return result.Instance:IsDescendantOf(targetPart.Parent) end
    return true
end

local function PickTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestScore = nil, nil
    for _, info in ipairs(GetAlivePlayers()) do
        local part = info.Player.Character:FindFirstChild(Config.TargetPart) or info.Player.Character:FindFirstChild("Head")
        if part and IsVisible(part) then
            local screenPos = Camera:WorldToViewportPoint(part.Position)
            local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if fovDist <= Config.FOV * 5 then
                local score
                if Config.TargetMode == "FOV" then score = fovDist
                elseif Config.TargetMode == "LowestHP" then score = info.Hum.Health
                elseif Config.TargetMode == "HighestHP" then score = -info.Hum.Health
                elseif Config.TargetMode == "Distance" then score = (Camera.CFrame.Position - part.Position).Magnitude
                else score = fovDist end
                if bestScore == nil or score < bestScore then best, bestScore = { part = part }, score end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function(dt)
    if not Config.AimbotEnabled then return end
    local targetData = PickTarget()
    if targetData then
        local target = targetData.part
        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.lookAt(camPos, target.Position)
        local alpha = math.clamp(1 - Config.Smoothness, 0.01, 1)
        local smoothAlpha = 1 - (1 - alpha) ^ (dt * 60)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, smoothAlpha)
        if Config.RotateCharacter and Root and Root.Parent then
            local flatTarget = Vector3.new(target.Position.X, Root.Position.Y, target.Position.Z)
            local rootCF = CFrame.lookAt(Root.Position, flatTarget)
            Root.CFrame = Root.CFrame:Lerp(rootCF, smoothAlpha * 0.8)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.AutoBlock then
        for _, info in ipairs(GetAlivePlayers()) do
            local dist = (info.Root.Position - Root.Position).Magnitude
            if dist < Config.AutoBlockDistance then
                pcall(function()
                    local tool = Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end)
            end
        end
    end
end)

-- ==========================================================
--  СОВРЕМЕННЫЙ GUI (как в топовых читах 2024-2026)
-- ==========================================================
print("[APEX] Создание современного GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexPremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Современная кнопка (круглая с градиентом и свечением)
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 60, 0, 60)
FloatBtn.Position = UDim2.new(0, 15, 0.5, -30)
FloatBtn.BackgroundColor3 = Theme.Background
FloatBtn.Text = "◈"
FloatBtn.TextColor3 = Theme.Accent
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 26
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = Theme.Accent
FloatStroke.Thickness = 2

local FloatGrad = Instance.new("UIGradient", FloatBtn)
FloatGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.Background),
})
FloatGrad.Rotation = 45

-- Анимация пульсации
task.spawn(function()
    while FloatBtn.Parent do
        TweenService:Create(FloatStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 4}):Play()
        task.wait(1.5)
        TweenService:Create(FloatStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 2}):Play()
        task.wait(1.5)
    end
end)

-- Вращение градиента
task.spawn(function()
    local rot = 45
    while FloatBtn.Parent do
        rot = rot + 0.5
        FloatGrad.Rotation = rot
        task.wait(0.03)
    end
end)

-- Главное меню (современный стиль)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Border
MainStroke.Thickness = 1

-- Заголовок с градиентом
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Theme.Secondary
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

-- Исправляем углы снизу у заголовка
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 20)
TitleFix.Position = UDim2.new(0, 0, 0, 30)
TitleFix.BackgroundColor3 = Theme.Secondary
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "APEX HUB"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local TitleGrad = Instance.new("UIGradient", Title)
TitleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Accent),
    ColorSequenceKeypoint.new(1, Theme.AccentGlow),
})

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 9)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- Вкладки (современный стиль)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -40, 0, 38)
TabBar.Position = UDim2.new(0, 20, 0, 60)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tabs = {}
local Pages = {}
local tabNames = { "Aimbot", "Fling", "Visuals", "ESP", "Misc" }
local tabIcons = { "⊕", "◎", "✦", "◉", "" }

for i, name in ipairs(tabNames) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1/#tabNames, -8, 1, 0)
    TabBtn.Position = UDim2.new((i-1)/#tabNames, 4, 0, 0)
    TabBtn.BackgroundColor3 = Theme.Secondary
    TabBtn.Text = tabIcons[i] .. " " .. name
    TabBtn.TextColor3 = Theme.TextMuted
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    
    local tabStroke = Instance.new("UIStroke", TabBtn)
    tabStroke.Color = Theme.Border
    tabStroke.Thickness = 1
    Tabs[name] = { Btn = TabBtn, Stroke = tabStroke }
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -40, 1, -110)
    Page.Position = UDim2.new(0, 20, 0, 105)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 800)
    Page.Parent = MainFrame
    Pages[name] = Page
    
    TabBtn.MouseEnter:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 42)}):Play()
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Secondary}):Play()
        end
    end)
end

Pages["Aimbot"].Visible = true
Tabs["Aimbot"].Btn.BackgroundColor3 = Theme.Accent
Tabs["Aimbot"].Btn.TextColor3 = Theme.Text
Tabs["Aimbot"].Stroke.Color = Theme.Accent

for name, data in pairs(Tabs) do
    data.Btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do
            p.Visible = false
            TweenService:Create(Tabs[n].Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Secondary}):Play()
            Tabs[n].Btn.TextColor3 = Theme.TextMuted
            Tabs[n].Stroke.Color = Theme.Border
        end
        Pages[name].Visible = true
        TweenService:Create(data.Btn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {BackgroundColor3 = Theme.Accent}):Play()
        data.Btn.TextColor3 = Theme.Text
        data.Stroke.Color = Theme.Accent
    end)
end

-- Утилиты UI (современный стиль)
local function CreateToggle(parent, text, y, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 42)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundColor3 = Theme.Secondary
    Container.BorderSizePixel = 0
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(0, 46, 0, 24)
    ToggleBg.Position = UDim2.new(1, -56, 0.5, -12)
    ToggleBg.BackgroundColor3 = default and Theme.Success or Color3.fromRGB(50, 50, 65)
    ToggleBg.BorderSizePixel = 0
    ToggleBg.Parent = Container
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 20, 0, 20)
    ToggleKnob.Position = default and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
    ToggleKnob.BackgroundColor3 = Theme.Text
    ToggleKnob.BorderSizePixel = 0
    ToggleKnob.Parent = ToggleBg
    Instance.new("UICorner", ToggleKnob).CornerRadius = UDim.new(1, 0)
    
    local state = default
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            if state then
                TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Success}):Play()
                TweenService:Create(ToggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0, 24, 0, 2)}):Play()
            else
                TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}):Play()
                TweenService:Create(ToggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0, 2, 0, 2)}):Play()
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
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = Theme.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -10, 0, 8)
    Track.Position = UDim2.new(0, 5, 0, 32)
    Track.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Track.BorderSizePixel = 0
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 22, 0, 22)
    Knob.Position = UDim2.new((default - min) / (max - min), -11, 0.5, -11)
    Knob.BackgroundColor3 = Theme.Text
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    
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
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 56)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 14)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.TextMuted
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local current = default
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.Position = UDim2.new(0, 0, 0, 18)
    Btn.BackgroundColor3 = Theme.Secondary
    Btn.Text = "▸ " .. current
    Btn.TextColor3 = Theme.Text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Parent = Container
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
end

local function CreateButton(parent, text, y, color, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -10, 0, 42)
    B.Position = UDim2.new(0, 5, 0, y)
    B.BackgroundColor3 = color or Theme.Secondary
    B.Text = text
    B.TextColor3 = Theme.Text
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    B.Parent = parent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)
    B.MouseButton1Click:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.06), {Size = UDim2.new(1, -16, 0, 40)}):Play()
        task.wait(0.06)
        TweenService:Create(B, TweenInfo.new(0.1, Enum.EasingStyle.Back), {Size = UDim2.new(1, -10, 0, 42)}):Play()
        pcall(callback, B)
    end)
    return B
end

local function CreateSection(parent, text, y)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -10, 0, 24)
    L.Position = UDim2.new(0, 5, 0, y)
    L.BackgroundTransparency = 1
    L.Text = "◆ " .. text
    L.TextColor3 = Theme.Accent
    L.Font = Enum.Font.GothamBlack
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
end

-- Открытие/закрытие меню
local MenuOpen = false
local function ToggleMenu()
    if MenuOpen then
        MenuOpen = false
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function()
            MainFrame.Visible = false
            MainFrame.Size = UDim2.new(0, 520, 0, 360)
            MainFrame.BackgroundTransparency = 0
        end)
    else
        MenuOpen = true
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 520, 0, 360), BackgroundTransparency = 0
        }):Play()
    end
end

CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)

-- ==========================================================
--  СТРАНИЦЫ
-- ==========================================================

-- AIMBOT
local AimbotPage = Pages["Aimbot"]
local y = 0
CreateSection(AimbotPage, "AIMBOT", y); y = y + 28
CreateToggle(AimbotPage, "Aimbot", y, false, function(v) Config.AimbotEnabled = v end); y = y + 48
CreateToggle(AimbotPage, "WallCheck", y, true, function(v) Config.WallCheck = v end); y = y + 48
CreateToggle(AimbotPage, "Поворот персонажа", y, true, function(v) Config.RotateCharacter = v end); y = y + 48
CreateToggle(AimbotPage, "Показать FOV", y, true, function(v) Config.ShowFOV = v end); y = y + 52
CreateSlider(AimbotPage, "FOV", y, 50, 1000, Config.FOV, false, function(v) Config.FOV = v end); y = y + 56
CreateSlider(AimbotPage, "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v) Config.Smoothness = v end); y = y + 56
CreateSelector(AimbotPage, "Режим цели", y, {"FOV", "LowestHP", "HighestHP", "Distance"}, Config.TargetMode, function(v) Config.TargetMode = v end); y = y + 60
CreateSelector(AimbotPage, "Часть тела", y, {"Head", "HumanoidRootPart", "UpperTorso"}, Config.TargetPart, function(v) Config.TargetPart = v end)

-- FLING
local FlingPage = Pages["Fling"]
y = 0
CreateSection(FlingPage, "FLING", y); y = y + 28

local selectedFlingTarget = nil
local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(1, -10, 0, 160)
PlayerListFrame.Position = UDim2.new(0, 5, 0, y)
PlayerListFrame.BackgroundTransparency = 1
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ScrollBarThickness = 3
PlayerListFrame.ScrollBarImageColor3 = Theme.Accent
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
            PB.BackgroundColor3 = Theme.Secondary
            PB.Text = "  ⊕ " .. player.Name
            PB.TextColor3 = Theme.Text
            PB.Font = Enum.Font.GothamBold
            PB.TextSize = 12
            PB.TextXAlignment = Enum.TextXAlignment.Left
            PB.Parent = PlayerListFrame
            Instance.new("UICorner", PB).CornerRadius = UDim.new(0, 8)
            PB.MouseButton1Click:Connect(function()
                selectedFlingTarget = player
                for _, btn in ipairs(PlayerListFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Secondary}):Play()
                    end
                end
                TweenService:Create(PB, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Accent}):Play()
            end)
        end
    end
    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 8)
end

RefreshPlayerList()
Players.PlayerAdded:Connect(function() task.wait(1) RefreshPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(1) RefreshPlayerList() end)

y = y + 170

local FlingBtn = CreateButton(FlingPage, "◎ ЗАПУСТИТЬ В КОСМОС", y, Theme.Danger, function(self)
    if FlingActive then
        self.Text = "⚠ ВЫПОЛНЯЕТСЯ..."
        task.delay(2, function() self.Text = "◎ ЗАПУСТИТЬ В КОСМОС" end)
        return
    end
    if selectedFlingTarget and selectedFlingTarget.Parent then
        self.Text = "⏳ ВЫПОЛНЯЕТСЯ..."
        local success = pcall(function() FlingPlayer(selectedFlingTarget) end)
        if success then
            self.Text = "✅ ОТПРАВЛЕНО!"
        else
            self.Text = "❌ ОШИБКА"
        end
        task.delay(2, function() self.Text = "◎ ЗАПУСТИТЬ В КОСМОС" end)
    else
        self.Text = "⚠ ВЫБЕРИ ИГРОКА"
        task.delay(2, function() self.Text = "◎ ЗАПУСТИТЬ В КОСМОС" end)
    end
end); y = y + 50

CreateButton(FlingPage, "↻ ОБНОВИТЬ СПИСОК", y, Theme.Secondary, function(self)
    RefreshPlayerList()
    self.Text = "✅ ОБНОВЛЕНО"
    task.delay(1, function() self.Text = "↻ ОБНОВИТЬ СПИСОК" end)
end)

-- VISUALS
local VisPage = Pages["Visuals"]
y = 0
CreateSection(VisPage, "VISUALS", y); y = y + 28
CreateToggle(VisPage, "Аура (только для тебя)", y, true, function(v)
    Config.AuraEnabled = v
    AuraRing.Transparency = v and 0.3 or 1
    AuraParticles.Enabled = v
end); y = y + 48
CreateToggle(VisPage, "Крылья (только для тебя)", y, true, function(v)
    Config.WingsEnabled = v
    for _, w in ipairs(WingParts) do w.Part.Transparency = v and Config.WingsTransparency or 1 end
    for _, b in ipairs(WingBeams) do b.Transparency = NumberSequence.new(v and Config.WingsTransparency or 1) end
end); y = y + 52
CreateSlider(VisPage, "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v) Config.AuraSize = v; AuraRing.Size = Vector3.new(0.15, v, v) end); y = y + 56
CreateSlider(VisPage, "Частицы ауры", y, 0, 100, Config.AuraRate, false, function(v) Config.AuraRate = v; AuraParticles.Rate = v end); y = y + 56
CreateSlider(VisPage, "Прозрачность крыльев", y, 0, 1.0, Config.WingsTransparency, true, function(v)
    Config.WingsTransparency = v
    if Config.WingsEnabled then
        for _, w in ipairs(WingParts) do w.Part.Transparency = v end
        for _, b in ipairs(WingBeams) do b.Transparency = NumberSequence.new(v) end
    end
end)

-- ESP
local EspPage = Pages["ESP"]
y = 0
CreateSection(EspPage, "ESP", y); y = y + 28
CreateToggle(EspPage, "ESP Игроков", y, false, function(v) Config.EspPlayers = v end); y = y + 48
CreateToggle(EspPage, "Tracers", y, true, function(v) Config.ShowTracers = v end)

-- MISC
local MiscPage = Pages["Misc"]
y = 0
CreateSection(MiscPage, "MISC", y); y = y + 28
CreateToggle(MiscPage, "Невидимость", y, false, function(v)
    if v then InvisModule:Activate() else InvisModule:Deactivate() end
end); y = y + 48
CreateToggle(MiscPage, "No Cooldown", y, false, function(v) Config.NoCooldown = v end); y = y + 48
CreateToggle(MiscPage, "Auto Block", y, false, function(v) Config.AutoBlock = v end); y = y + 52
CreateSlider(MiscPage, "Дистанция блока", y, 5, 50, Config.AutoBlockDistance, false, function(v) Config.AutoBlockDistance = v end)

-- ==========================================================
print("═══════════════════════════════════════")
print("  ◈ APEX HUB v10 PREMIUM ЗАГРУЖЕН! ◈")
print("  Современный GUI + Клиентские визуалы")
print("  Нажми ◈ для открытия меню")
print("═══════════════════════════════════════")
