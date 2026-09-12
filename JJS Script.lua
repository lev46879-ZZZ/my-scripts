-- ==========================================================
--     ◈ APEX HUB v11 | JJS BEAUTY EDITION ◈
--     Живая аура + Машущие крылья + Премиум GUI
-- ==========================================================

print("[APEX] Загрузка Beauty версии...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Drawing = drawing or Drawing
if not Drawing then pcall(function() Drawing = getgenv().drawing end) end

-- Премиум палитра
local T = {
    BG = Color3.fromRGB(11, 7, 20),
    Panel = Color3.fromRGB(21, 16, 34),
    Panel2 = Color3.fromRGB(28, 22, 46),
    Accent = Color3.fromRGB(139, 92, 246),
    Accent2 = Color3.fromRGB(167, 139, 250),
    Glow = Color3.fromRGB(190, 120, 255),
    Ok = Color3.fromRGB(52, 211, 153),
    Bad = Color3.fromRGB(248, 113, 113),
    Text = Color3.fromRGB(240, 238, 255),
    Mute = Color3.fromRGB(140, 132, 168),
    Line = Color3.fromRGB(45, 36, 70),
}

local Config = {
    AimbotEnabled = false, FOV = 250, ShowFOV = true, Smoothness = 0.08,
    TargetMode = "FOV", TargetPart = "Head", WallCheck = true, RotateCharacter = true,
    AutoBlock = false, AutoBlockDistance = 15,
    AuraEnabled = true, WingsEnabled = true, RainbowAura = false,
    AuraColor = Color3.fromRGB(150, 0, 255), WingsColor = Color3.fromRGB(120, 40, 220),
    WingsTransparency = 0.15, AuraSize = 6, AuraRate = 40,
    EspPlayers = false, EspCharms = false, ShowTracers = true,
    EspColor = Color3.fromRGB(255, 50, 50), CharmColor = Color3.fromRGB(255, 215, 0),
    Invisibility = false, NoCooldown = false,
}

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- ==========================================================
--  🌟 КРАСИВАЯ АУРА (3 кольца + свечение земли + частицы)
-- ==========================================================
local AuraGroup = Instance.new("Folder")
AuraGroup.Name = "ApexAura"
AuraGroup.Parent = workspace

local function MakeRing(size, thick)
    local r = Instance.new("Part")
    r.Shape = Enum.PartType.Cylinder
    r.Size = Vector3.new(thick, size, size)
    r.Anchored = true; r.CanCollide = false; r.CanQuery = false; r.Massless = true
    r.Material = Enum.Material.Neon
    r.Color = Config.AuraColor
    r.Transparency = 0.25
    r.Parent = AuraGroup
    return r
end

local Ring1 = MakeRing(Config.AuraSize, 0.15)          -- нижнее кольцо
local Ring2 = MakeRing(Config.AuraSize * 0.75, 0.12)   -- среднее кольцо
local OrbitRing = MakeRing(Config.AuraSize * 0.9, 0.1) -- вертикальное орбит-кольцо

local GroundGlow = Instance.new("Part")
GroundGlow.Shape = Enum.PartType.Cylinder
GroundGlow.Size = Vector3.new(0.05, Config.AuraSize * 1.6, Config.AuraSize * 1.6)
GroundGlow.Anchored = true; GroundGlow.CanCollide = false; GroundGlow.CanQuery = false
GroundGlow.Material = Enum.Material.Neon
GroundGlow.Color = Config.AuraColor
GroundGlow.Transparency = 0.7
GroundGlow.Parent = AuraGroup

local AuraAtt = Instance.new("Attachment", Root)
local AuraParticles = Instance.new("ParticleEmitter", AuraAtt)
AuraParticles.Texture = "rbxassetid://243098098"
AuraParticles.Rate = Config.AuraRate
AuraParticles.Lifetime = NumberRange.new(0.8, 1.6)
AuraParticles.Speed = NumberRange.new(2, 6)
AuraParticles.SpreadAngle = Vector2.new(15, 15)
AuraParticles.Color = ColorSequence.new(Config.AuraColor)
AuraParticles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0)})
AuraParticles.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
AuraParticles.LightEmission = 1
AuraParticles.Rotation = NumberRange.new(0, 360)

-- Искры (второй слой частиц)
local SparkAtt = Instance.new("Attachment", Root)
SparkAtt.Position = Vector3.new(0, -2.5, 0)
local Sparks = Instance.new("ParticleEmitter", SparkAtt)
Sparks.Texture = "rbxassetid://243098098"
Sparks.Rate = 12
Sparks.Lifetime = NumberRange.new(1.2, 2.2)
Sparks.Speed = NumberRange.new(4, 8)
Sparks.SpreadAngle = Vector2.new(25, 25)
Sparks.Color = ColorSequence.new(Config.AuraColor)
Sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 0)})
Sparks.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
Sparks.LightEmission = 2

-- ==========================================================
--  🪽 КРАСИВЫЕ КРЫЛЬЯ (4 сегмента + машут + лучи + частицы)
-- ==========================================================
local WingGroup = Instance.new("Folder")
WingGroup.Name = "ApexWings"
WingGroup.Parent = workspace

local WingParts = {}
local WingBeams = {}

local function CreateWing(side)
    local segments = {}
    local rootAtt = Instance.new("Attachment", Root)
    rootAtt.Position = Vector3.new(0.7 * side, 1.2, 0.6)

    for i = 1, 4 do
        local Seg = Instance.new("Part")
        Seg.Size = Vector3.new(0.18, 3.2 - i * 0.55, 1.3 - i * 0.15)
        Seg.Anchored = true; Seg.CanCollide = false; Seg.CanQuery = false; Seg.Massless = true
        Seg.Material = Enum.Material.Neon
        Seg.Color = Config.WingsColor
        Seg.Transparency = Config.WingsTransparency
        Seg.Parent = WingGroup

        local baseOffset = CFrame.new((i - 1) * 0.85 * side, 1.5 + i * 0.38, 0.7 + i * 0.15)
            * CFrame.Angles(0, math.rad(-25 * side), math.rad(15 * side))

        table.insert(WingParts, { Part = Seg, BaseOffset = baseOffset, Side = side, Index = i })
        table.insert(segments, Seg)
    end

    -- Луч от тела к первому сегменту
    local firstAtt = Instance.new("Attachment", segments[1])
    local b0 = Instance.new("Beam")
    b0.Attachment0 = rootAtt; b0.Attachment1 = firstAtt
    b0.Width0 = 1.4; b0.Width1 = 1.2
    b0.Color = ColorSequence.new(Config.WingsColor)
    b0.Transparency = NumberSequence.new(Config.WingsTransparency + 0.1)
    b0.LightEmission = 1; b0.FaceCamera = true
    b0.Parent = segments[1]
    table.insert(WingBeams, b0)

    -- Лучи между сегментами
    for i = 1, #segments - 1 do
        local A0 = Instance.new("Attachment", segments[i])
        local A1 = Instance.new("Attachment", segments[i + 1])
        local Beam = Instance.new("Beam")
        Beam.Attachment0 = A0; Beam.Attachment1 = A1
        Beam.Width0 = 1.3 - i * 0.2; Beam.Width1 = 1.1 - i * 0.2
        Beam.Color = ColorSequence.new(Config.WingsColor)
        Beam.Transparency = NumberSequence.new(Config.WingsTransparency)
        Beam.LightEmission = 1; Beam.FaceCamera = true
        Beam.Parent = segments[i]
        table.insert(WingBeams, Beam)
    end

    -- Частицы на кончике
    local tipAtt = Instance.new("Attachment", segments[#segments])
    local P = Instance.new("ParticleEmitter", tipAtt)
    P.Texture = "rbxassetid://243098098"
    P.Rate = 20
    P.Lifetime = NumberRange.new(0.4, 0.9)
    P.Speed = NumberRange.new(1, 3)
    P.SpreadAngle = Vector2.new(40, 40)
    P.Color = ColorSequence.new(Config.WingsColor)
    P.Size = NumberSequence.new(0.35)
    P.Transparency = NumberSequence.new(Config.WingsTransparency)
    P.LightEmission = 2
end

CreateWing(1)
CreateWing(-1)

-- ========== ЖИВОЙ ЦИКЛ ВИЗУАЛОВ (вращение + взмахи + радуга) ==========
local visTime = 0
local InvisActive = false

RunService.Heartbeat:Connect(function(dt)
    if not Root or not Root.Parent then return end
    visTime = visTime + dt

    local show = not InvisActive
    local col = Config.AuraColor
    local wcol = Config.WingsColor

    -- Радужный режим
    if Config.RainbowAura then
        col = Color3.fromHSV((visTime * 0.12) % 1, 0.85, 1)
        wcol = Color3.fromHSV(((visTime * 0.12) + 0.5) % 1, 0.85, 1)
    end

    if Config.AuraEnabled and show then
        local pulse = 1 + math.sin(visTime * 3) * 0.06
        local s1 = Config.AuraSize * pulse

        Ring1.CFrame = Root.CFrame * CFrame.new(0, -2.9, 0) * CFrame.Angles(0, visTime * 1.6, 0) * CFrame.Angles(0, 0, math.rad(90))
        Ring1.Size = Vector3.new(0.15, s1, s1)
        Ring1.Color = col
        Ring1.Transparency = 0.25

        Ring2.CFrame = Root.CFrame * CFrame.new(0, -2.4, 0) * CFrame.Angles(0, -visTime * 2.2, 0) * CFrame.Angles(0, 0, math.rad(90))
        Ring2.Size = Vector3.new(0.12, s1 * 0.75, s1 * 0.75)
        Ring2.Color = col
        Ring2.Transparency = 0.35

        OrbitRing.CFrame = Root.CFrame * CFrame.new(0, -1.4, 0) * CFrame.Angles(0, visTime * 2.8, 0) * CFrame.Angles(math.rad(75), 0, 0)
        OrbitRing.Size = Vector3.new(0.1, s1 * 0.9, s1 * 0.9)
        OrbitRing.Color = col
        OrbitRing.Transparency = 0.45

        GroundGlow.CFrame = Root.CFrame * CFrame.new(0, -2.95, 0) * CFrame.Angles(0, 0, math.rad(90))
        GroundGlow.Size = Vector3.new(0.05, s1 * 1.6, s1 * 1.6)
        GroundGlow.Color = col
        GroundGlow.Transparency = 0.72 + math.sin(visTime * 3) * 0.08

        AuraParticles.Color = ColorSequence.new(col)
        Sparks.Color = ColorSequence.new(col)
        AuraParticles.Enabled = true; Sparks.Enabled = true
    else
        Ring1.Transparency = 1; Ring2.Transparency = 1
        OrbitRing.Transparency = 1; GroundGlow.Transparency = 1
        AuraParticles.Enabled = false; Sparks.Enabled = false
    end

    if Config.WingsEnabled and show then
        local flap = math.sin(visTime * 5.5) * 0.32          -- взмах
        local breathe = math.sin(visTime * 2.2) * 0.08       -- дыхание

        for _, w in ipairs(WingParts) do
            local target = Root.CFrame
                * w.BaseOffset
                * CFrame.Angles(flap * 0.6 * w.Side, 0, (flap + breathe) * w.Side)
            w.Part.CFrame = w.Part.CFrame:Lerp(target, 0.35)
            w.Part.Color = wcol
            w.Part.Transparency = Config.WingsTransparency
        end
        for _, b in ipairs(WingBeams) do
            b.Color = ColorSequence.new(wcol)
            b.Transparency = NumberSequence.new(Config.WingsTransparency)
        end
    else
        for _, w in ipairs(WingParts) do
            w.Part.CFrame = CFrame.new(0, -10000, 0)
        end
    end
end)

-- ==========================================================
--  ГЕЙМПЛЕЙ: NoCD / Невидимость / Fling / Aimbot / ESP
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

local InvisModule = { Clone = nil, Conn = nil }
function InvisModule:Activate()
    if InvisActive then return end
    InvisActive = true
    pcall(function()
        self.Clone = Character:Clone()
        self.Clone.Name = "VisClone"; self.Clone.Parent = workspace
        for _, o in ipairs(self.Clone:GetDescendants()) do
            if o:IsA("BaseScript") then o:Destroy() end
            if o:IsA("BasePart") then
                o.Transparency = math.clamp(o.Transparency + 0.65, 0, 0.95)
                o.CanCollide = false; o.CanQuery = false; o.CastShadow = false
            end
        end
        local h = self.Clone:FindFirstChildOfClass("Humanoid")
        if h then h:Destroy() end
    end)
    for _, p in ipairs(Character:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            pcall(function() p.Transparency = 1; p.CastShadow = false end)
        end
    end
    self.Conn = RunService.Heartbeat:Connect(function()
        if not InvisActive or not self.Clone or not self.Clone.Parent then return end
        pcall(function()
            for _, o in ipairs(Character:GetDescendants()) do
                if o:IsA("BasePart") then
                    local c = self.Clone:FindFirstChild(o.Name)
                    if c and c:IsA("BasePart") then c.CFrame = o.CFrame end
                end
            end
        end)
    end)
    Config.Invisibility = true
end
function InvisModule:Deactivate()
    if not InvisActive then return end
    InvisActive = false
    if self.Conn then self.Conn:Disconnect(); self.Conn = nil end
    if self.Clone and self.Clone.Parent then self.Clone:Destroy(); self.Clone = nil end
    pcall(function()
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency = 0; p.CastShadow = true end
        end
    end)
    Config.Invisibility = false
end

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
            local a = (i / 30) * math.pi * 4
            pcall(function()
                myHrp.CFrame = tHrp.CFrame * CFrame.new(math.cos(a) * 2, math.sin(i * 0.3) * 0.5, math.sin(a) * 2)
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

-- Aimbot
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

local function IsVisible(part)
    if not Config.WallCheck then return true end
    local o = Camera.CFrame.Position
    local d = part.Position - o
    local pr = RaycastParams.new()
    pr.FilterType = Enum.RaycastFilterType.Exclude
    pr.FilterDescendantsInstances = {LocalPlayer.Character}
    pr.IgnoreWater = true
    local r = workspace:Raycast(o, d.Unit * d.Magnitude, pr)
    if r then return r.Instance:IsDescendantOf(part.Parent) end
    return true
end

local function PickTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, bestScore = nil, nil
    for _, info in ipairs(GetAlivePlayers()) do
        local part = info.Player.Character:FindFirstChild(Config.TargetPart) or info.Player.Character:FindFirstChild("Head")
        if part and IsVisible(part) then
            local sp = Camera:WorldToViewportPoint(part.Position)
            local fd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
            if fd <= Config.FOV * 5 then
                local score
                if Config.TargetMode == "FOV" then score = fd
                elseif Config.TargetMode == "LowestHP" then score = info.Hum.Health
                elseif Config.TargetMode == "HighestHP" then score = -info.Hum.Health
                else score = (Camera.CFrame.Position - part.Position).Magnitude end
                if bestScore == nil or score < bestScore then best, bestScore = { part = part }, score end
            end
        end
    end
    return best
end

local FovCircle = nil
if Drawing then
    pcall(function()
        FovCircle = Drawing.new("Circle")
        FovCircle.Thickness = 2; FovCircle.NumSides = 100
        FovCircle.Filled = false; FovCircle.Color = T.Accent
        FovCircle.Transparency = 0.6; FovCircle.Visible = false
    end)
end

RunService.RenderStepped:Connect(function(dt)
    if FovCircle then
        FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FovCircle.Radius = Config.FOV
        FovCircle.Visible = Config.AimbotEnabled and Config.ShowFOV
    end
    if not Config.AimbotEnabled then return end
    local td = PickTarget()
    if td then
        local camPos = Camera.CFrame.Position
        local tCF = CFrame.lookAt(camPos, td.part.Position)
        local alpha = math.clamp(1 - Config.Smoothness, 0.01, 1)
        local sa = 1 - (1 - alpha) ^ (dt * 60)
        Camera.CFrame = Camera.CFrame:Lerp(tCF, sa)
        if Config.RotateCharacter and Root and Root.Parent then
            local ft = Vector3.new(td.part.Position.X, Root.Position.Y, td.part.Position.Z)
            Root.CFrame = Root.CFrame:Lerp(CFrame.lookAt(Root.Position, ft), sa * 0.8)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.AutoBlock then
        for _, info in ipairs(GetAlivePlayers()) do
            local d = (info.Root.Position - Root.Position).Magnitude
            if d < Config.AutoBlockDistance then
                pcall(function()
                    local tool = Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end)
            end
        end
    end
end)

-- ESP (игроки + charms с кэшем)
local EspTable = {}
local CharmTable = {}
local CachedCharms = {}
local LastCharmUpdate = 0

local function UpdateCharmCache()
    CachedCharms = {}
    pcall(function()
        for _, o in ipairs(workspace:GetDescendants()) do
            if (o:IsA("Model") or o:IsA("BasePart")) and o.Name:lower():find("charm") then
                table.insert(CachedCharms, o)
            end
        end
    end)
end

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
                                    Box = Drawing.new("Square"), Name = Drawing.new("Text"),
                                    Hp = Drawing.new("Text"), Tracer = Drawing.new("Line"),
                                }
                                EspTable[player].Box.Thickness = 1.5
                                EspTable[player].Box.Filled = false
                                EspTable[player].Name.Size = 14; EspTable[player].Name.Center = true; EspTable[player].Name.Outline = true
                                EspTable[player].Hp.Size = 12; EspTable[player].Hp.Center = true; EspTable[player].Hp.Outline = true
                                EspTable[player].Tracer.Thickness = 2; EspTable[player].Tracer.Transparency = 0.7
                            end
                            local d = EspTable[player]
                            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                            local sc = 1200 / dist
                            local bs = Vector2.new(sc * 1.5, sc * 2.5)
                            d.Box.Size = bs
                            d.Box.Position = Vector2.new(pos.X - bs.X / 2, pos.Y - bs.Y / 2)
                            d.Box.Color = Config.EspColor; d.Box.Visible = true
                            d.Name.Text = player.Name
                            d.Name.Position = Vector2.new(pos.X, pos.Y - bs.Y / 2 - 20)
                            d.Name.Color = T.Text; d.Name.Visible = true
                            d.Hp.Text = math.floor(hum.Health) .. " HP"
                            d.Hp.Position = Vector2.new(pos.X, pos.Y + bs.Y / 2 + 5)
                            d.Hp.Color = T.Ok; d.Hp.Visible = true
                            d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            d.Tracer.To = Vector2.new(pos.X, pos.Y)
                            d.Tracer.Color = Config.EspColor
                            d.Tracer.Visible = Config.ShowTracers
                        else
                            if EspTable[player] then
                                EspTable[player].Box.Visible = false; EspTable[player].Name.Visible = false
                                EspTable[player].Hp.Visible = false; EspTable[player].Tracer.Visible = false
                            end
                        end
                    else
                        if EspTable[player] then
                            EspTable[player].Box.Visible = false; EspTable[player].Name.Visible = false
                            EspTable[player].Hp.Visible = false; EspTable[player].Tracer.Visible = false
                        end
                    end
                end
            else
                if EspTable[player] then
                    EspTable[player].Box.Visible = false; EspTable[player].Name.Visible = false
                    EspTable[player].Hp.Visible = false; EspTable[player].Tracer.Visible = false
                end
            end
        end

        if tick() - LastCharmUpdate > 2 then UpdateCharmCache(); LastCharmUpdate = tick() end
        if Config.EspCharms then
            for _, o in ipairs(CachedCharms) do
                local part = o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")) or o
                if part and part.Parent then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        if not CharmTable[o] then
                            CharmTable[o] = { Box = Drawing.new("Square"), Name = Drawing.new("Text") }
                            CharmTable[o].Box.Thickness = 1.5; CharmTable[o].Box.Filled = false
                            CharmTable[o].Name.Size = 12; CharmTable[o].Name.Center = true; CharmTable[o].Name.Outline = true
                        end
                        local d = CharmTable[o]
                        local dist = (Camera.CFrame.Position - part.Position).Magnitude
                        local sc = math.clamp(1200 / dist, 15, 200)
                        local bs = Vector2.new(sc * 1.2, sc * 1.2)
                        d.Box.Size = bs
                        d.Box.Position = Vector2.new(pos.X - bs.X / 2, pos.Y - bs.Y / 2)
                        d.Box.Color = Config.CharmColor; d.Box.Visible = true
                        d.Name.Text = o.Name
                        d.Name.Position = Vector2.new(pos.X, pos.Y - bs.Y / 2 - 15)
                        d.Name.Color = Config.CharmColor; d.Name.Visible = true
                    else
                        if CharmTable[o] then CharmTable[o].Box.Visible = false; CharmTable[o].Name.Visible = false end
                    end
                end
            end
        else
            for _, d in pairs(CharmTable) do d.Box.Visible = false; d.Name.Visible = false end
        end
    end)
end

-- ==========================================================
--  💎 ПРЕМИУМ GUI
-- ==========================================================
print("[APEX] Создание премиум GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexBeauty"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ===== УВЕДОМЛЕНИЯ =====
local function Notify(text, color)
    task.spawn(function()
        local n = Instance.new("Frame")
        n.Size = UDim2.new(0, 240, 0, 44)
        n.Position = UDim2.new(1, -250, 1, -60)
        n.BackgroundColor3 = T.Panel
        n.BorderSizePixel = 0
        n.Parent = ScreenGui
        Instance.new("UICorner", n).CornerRadius = UDim.new(0, 10)
        local st = Instance.new("UIStroke", n)
        st.Color = color or T.Accent; st.Thickness = 1.5
        local bar = Instance.new("Frame", n)
        bar.Size = UDim2.new(0, 3, 1, -16); bar.Position = UDim2.new(0, 8, 0, 8)
        bar.BackgroundColor3 = color or T.Accent; bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local lb = Instance.new("TextLabel", n)
        lb.Size = UDim2.new(1, -30, 1, 0); lb.Position = UDim2.new(0, 20, 0, 0)
        lb.BackgroundTransparency = 1; lb.Text = text
        lb.TextColor3 = T.Text; lb.Font = Enum.Font.GothamBold; lb.TextSize = 12
        lb.TextXAlignment = Enum.TextXAlignment.Left
        n.BackgroundTransparency = 1
        n.Position = UDim2.new(1, -230, 1, -60)
        TweenService:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0, Position = UDim2.new(1, -250, 1, -60)
        }):Play()
        task.wait(2.5)
        TweenService:Create(n, TweenInfo.new(0.2), {BackgroundTransparency = 1, Position = UDim2.new(1, -230, 1, -60)}):Play()
        task.wait(0.25)
        n:Destroy()
    end)
end

-- ===== КНОПКА (анимированная рамка-градиент) =====
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 58, 0, 58)
FloatBtn.Position = UDim2.new(0, 14, 0.5, -29)
FloatBtn.BackgroundColor3 = T.BG
FloatBtn.Text = "◈"
FloatBtn.TextColor3 = T.Glow
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 26
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local btnStroke = Instance.new("UIStroke", FloatBtn)
btnStroke.Thickness = 2
local btnStrokeGrad = Instance.new("UIGradient", btnStroke)
btnStrokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.Accent),
    ColorSequenceKeypoint.new(0.5, T.Glow),
    ColorSequenceKeypoint.new(1, T.Accent),
})

-- Вращение градиента рамки + пульс символа
task.spawn(function()
    local rot = 0
    while FloatBtn.Parent do
        rot = rot + 1.2
        btnStrokeGrad.Rotation = rot
        task.wait(0.03)
    end
end)

task.spawn(function()
    while FloatBtn.Parent do
        TweenService:Create(FloatBtn, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 30}):Play()
        task.wait(1.4)
        TweenService:Create(FloatBtn, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 26}):Play()
        task.wait(1.4)
    end
end)

FloatBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0, 66, 0, 66)}):Play()
end)
FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0, 58, 0, 58)}):Play()
end)

-- ===== МЕНЮ =====
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 560, 0, 400)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
MainFrame.BackgroundColor3 = T.BG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = T.Line; mainStroke.Thickness = 1

-- Шапка
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = T.Panel
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)
local headerFix = Instance.new("Frame", Header)
headerFix.Size = UDim2.new(1, 0, 0, 20); headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = T.Panel; headerFix.BorderSizePixel = 0

local logo = Instance.new("TextLabel", Header)
logo.Size = UDim2.new(0, 34, 1, 0); logo.Position = UDim2.new(0, 14, 0, 0)
logo.BackgroundTransparency = 1; logo.Text = "◈"
logo.TextColor3 = T.Glow; logo.Font = Enum.Font.GothamBlack; logo.TextSize = 22

local titleLb = Instance.new("TextLabel", Header)
titleLb.Size = UDim2.new(1, -140, 0, 22); titleLb.Position = UDim2.new(0, 50, 0, 7)
titleLb.BackgroundTransparency = 1; titleLb.Text = "APEX HUB"
titleLb.Font = Enum.Font.GothamBlack; titleLb.TextSize = 16
titleLb.TextXAlignment = Enum.TextXAlignment.Left; titleLb.TextColor3 = T.Text
local titleGrad = Instance.new("UIGradient", titleLb)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, T.Accent2),
    ColorSequenceKeypoint.new(1, T.Glow),
})

local subLb = Instance.new("TextLabel", Header)
subLb.Size = UDim2.new(1, -140, 0, 13); subLb.Position = UDim2.new(0, 50, 0, 27)
subLb.BackgroundTransparency = 1; subLb.Text = "JUJUTSU SHENANIGANS • v11"
subLb.Font = Enum.Font.GothamBold; subLb.TextSize = 9
subLb.TextXAlignment = Enum.TextXAlignment.Left; subLb.TextColor3 = T.Mute

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = T.Panel2; CloseBtn.Text = "✕"
CloseBtn.TextColor3 = T.Bad; CloseBtn.Font = Enum.Font.GothamBlack; CloseBtn.TextSize = 13
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Bad, TextColor3 = T.Text}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel2, TextColor3 = T.Bad}):Play()
end)

-- Линия под шапкой
local headLine = Instance.new("Frame", MainFrame)
headLine.Size = UDim2.new(1, -28, 0, 2); headLine.Position = UDim2.new(0, 14, 0, 46)
headLine.BorderSizePixel = 0
local hlGrad = Instance.new("UIGradient", headLine)
hlGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.5, T.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
})

-- ===== БОКОВЫЕ ВКЛАДКИ + ИНДИКАТОР =====
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 96, 1, -66); Sidebar.Position = UDim2.new(0, 14, 0, 56)
Sidebar.BackgroundTransparency = 1

local tabIndicator = Instance.new("Frame", Sidebar)
tabIndicator.Size = UDim2.new(0, 3, 0, 26); tabIndicator.Position = UDim2.new(0, 0, 0, 7)
tabIndicator.BackgroundColor3 = T.Glow; tabIndicator.BorderSizePixel = 0
Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(1, 0)

local Tabs = {}
local Pages = {}
local tabNames = { "Aimbot", "Fling", "Visuals", "ESP", "Misc" }
local tabIcons = { "⊕", "◎", "✦", "◉", "⚙" }

for i, name in ipairs(tabNames) do
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -6, 0, 40)
    TabBtn.Position = UDim2.new(0, 6, 0, (i - 1) * 44)
    TabBtn.BackgroundColor3 = T.Panel
    TabBtn.Text = tabIcons[i] .. "  " .. name
    TabBtn.TextColor3 = T.Mute
    TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 11
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 9)
    Tabs[name] = TabBtn

    local Page = Instance.new("ScrollingFrame", MainFrame)
    Page.Size = UDim2.new(1, -126, 1, -66)
    Page.Position = UDim2.new(0, 116, 0, 56)
    Page.BackgroundTransparency = 1; Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3; Page.ScrollBarImageColor3 = T.Accent
    Page.Visible = false; Page.CanvasSize = UDim2.new(0, 0, 0, 900)
    Pages[name] = Page

    TabBtn.MouseEnter:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel2, TextColor3 = T.Text}):Play()
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel, TextColor3 = T.Mute}):Play()
        end
    end)
end

Pages["Aimbot"].Visible = true
Tabs["Aimbot"].BackgroundColor3 = T.Panel2
Tabs["Aimbot"].TextColor3 = T.Text

for name, btn in pairs(Tabs) do
    btn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, n in ipairs(tabNames) do if n == name then idx = i end end
        for n, p in pairs(Pages) do
            p.Visible = false
            TweenService:Create(Tabs[n], TweenInfo.new(0.15), {BackgroundColor3 = T.Panel, TextColor3 = T.Mute}):Play()
        end
        Pages[name].Visible = true
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = T.Panel2, TextColor3 = T.Text}):Play()
        TweenService:Create(tabIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, (idx - 1) * 44 + 7)
        }):Play()
    end)
end

-- ===== ОТКРЫТИЕ / ЗАКРЫТИЕ =====
local MenuOpen = false
local function ToggleMenu()
    if MenuOpen then
        MenuOpen = false
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function()
            MainFrame.Visible = false
            MainFrame.Size = UDim2.new(0, 560, 0, 400)
            MainFrame.BackgroundTransparency = 0
        end)
    else
        MenuOpen = true
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 560, 0, 400), BackgroundTransparency = 0
        }):Play()
    end
end
CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)

-- ===== УТИЛИТЫ UI =====
local function Section(parent, text, y)
    local L = Instance.new("TextLabel", parent)
    L.Size = UDim2.new(1, -10, 0, 22); L.Position = UDim2.new(0, 5, 0, y)
    L.BackgroundTransparency = 1; L.Text = "◆  " .. text
    L.TextColor3 = T.Accent2; L.Font = Enum.Font.GothamBlack; L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
end

local function Toggle(parent, text, y, default, cb)
    local Box = Instance.new("Frame", parent)
    Box.Size = UDim2.new(1, -10, 0, 40); Box.Position = UDim2.new(0, 5, 0, y)
    Box.BackgroundColor3 = T.Panel; Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel", Box)
    L.Size = UDim2.new(1, -64, 1, 0); L.Position = UDim2.new(0, 14, 0, 0)
    L.BackgroundTransparency = 1; L.Text = text; L.TextColor3 = T.Text
    L.Font = Enum.Font.GothamBold; L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    local Pill = Instance.new("Frame", Box)
    Pill.Size = UDim2.new(0, 44, 0, 22); Pill.Position = UDim2.new(1, -54, 0.5, -11)
    Pill.BackgroundColor3 = default and T.Ok or Color3.fromRGB(48, 42, 66)
    Pill.BorderSizePixel = 0
    Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)
    local Knob = Instance.new("Frame", Pill)
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = default and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
    Knob.BackgroundColor3 = T.Text; Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local state = default
    Box.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            state = not state
            if state then
                TweenService:Create(Pill, TweenInfo.new(0.2), {BackgroundColor3 = T.Ok}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = UDim2.new(0, 24, 0, 2)}):Play()
            else
                TweenService:Create(Pill, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(48, 42, 66)}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position = UDim2.new(0, 2, 0, 2)}):Play()
            end
            pcall(cb, state)
        end
    end)
end

local function Slider(parent, text, y, min, max, def, isFloat, cb)
    local Box = Instance.new("Frame", parent)
    Box.Size = UDim2.new(1, -10, 0, 48); Box.Position = UDim2.new(0, 5, 0, y)
    Box.BackgroundColor3 = T.Panel; Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel", Box)
    L.Size = UDim2.new(1, -20, 0, 16); L.Position = UDim2.new(0, 12, 0, 6)
    L.BackgroundTransparency = 1; L.Text = text .. ":  " .. tostring(def)
    L.TextColor3 = T.Text; L.Font = Enum.Font.GothamBold; L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    local Track = Instance.new("Frame", Box)
    Track.Size = UDim2.new(1, -24, 0, 6); Track.Position = UDim2.new(0, 12, 0, 30)
    Track.BackgroundColor3 = Color3.fromRGB(38, 32, 58); Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    local fg = Instance.new("UIGradient", Fill)
    fg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.Accent), ColorSequenceKeypoint.new(1, T.Glow)})
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new((def - min) / (max - min), -8, 0.5, -8)
    Knob.BackgroundColor3 = T.Text; Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", Knob); ks.Color = T.Glow; ks.Thickness = 2
    local function Update(x)
        local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        if not isFloat then val = math.floor(val + 0.5) end
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, -8, 0.5, -8)
        L.Text = text .. ":  " .. (isFloat and string.format("%.2f", val) or tostring(val))
        pcall(cb, val)
    end
    local drag = false
    Track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; Update(i.Position.X)
        end
    end)
    Track.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            Update(i.Position.X)
        end
    end)
    Track.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

local function Selector(parent, text, y, options, def, cb)
    local Box = Instance.new("Frame", parent)
    Box.Size = UDim2.new(1, -10, 0, 48); Box.Position = UDim2.new(0, 5, 0, y)
    Box.BackgroundColor3 = T.Panel; Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel", Box)
    L.Size = UDim2.new(0.45, -12, 1, 0); L.Position = UDim2.new(0, 12, 0, 0)
    L.BackgroundTransparency = 1; L.Text = text; L.TextColor3 = T.Mute
    L.Font = Enum.Font.GothamBold; L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    local current = def
    local Btn = Instance.new("TextButton", Box)
    Btn.Size = UDim2.new(0.5, -12, 0, 30); Btn.Position = UDim2.new(0.48, 0, 0.5, -15)
    Btn.BackgroundColor3 = T.Panel2; Btn.Text = "▸ " .. current
    Btn.TextColor3 = T.Text; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 11
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, v in ipairs(options) do if v == current then idx = i break end end
        idx = idx + 1
        if idx > #options then idx = 1 end
        current = options[idx]
        Btn.Text = "▸ " .. current
        pcall(cb, current)
    end)
end

local function ActionBtn(parent, text, y, color, cb)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1, -10, 0, 40); B.Position = UDim2.new(0, 5, 0, y)
    B.BackgroundColor3 = color or T.Panel2; B.Text = text
    B.TextColor3 = T.Text; B.Font = Enum.Font.GothamBlack; B.TextSize = 12
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", B); st.Color = T.Line; st.Thickness = 1
    B.MouseEnter:Connect(function()
        TweenService:Create(st, TweenInfo.new(0.15), {Color = T.Accent, Thickness = 1.5}):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(st, TweenInfo.new(0.15), {Color = T.Line, Thickness = 1}):Play()
    end)
    B.MouseButton1Click:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.06), {Size = UDim2.new(1, -16, 0, 38)}):Play()
        task.wait(0.06)
        TweenService:Create(B, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Size = UDim2.new(1, -10, 0, 40)}):Play()
        pcall(cb, B)
    end)
    return B
end

-- ==========================================================
--  СТРАНИЦЫ
-- ==========================================================

-- AIMBOT
local y = 0
Section(Pages["Aimbot"], "AIMBOT", y); y = y + 26
Toggle(Pages["Aimbot"], "Aimbot", y, false, function(v) Config.AimbotEnabled = v end); y = y + 46
Toggle(Pages["Aimbot"], "WallCheck", y, true, function(v) Config.WallCheck = v end); y = y + 46
Toggle(Pages["Aimbot"], "Поворот персонажа", y, true, function(v) Config.RotateCharacter = v end); y = y + 46
Toggle(Pages["Aimbot"], "Показать FOV", y, true, function(v) Config.ShowFOV = v end); y = y + 50
Slider(Pages["Aimbot"], "FOV", y, 50, 1000, Config.FOV, false, function(v) Config.FOV = v end); y = y + 54
Slider(Pages["Aimbot"], "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v) Config.Smoothness = v end); y = y + 54
Selector(Pages["Aimbot"], "Режим цели", y, {"FOV", "LowestHP", "HighestHP", "Distance"}, Config.TargetMode, function(v) Config.TargetMode = v end); y = y + 54
Selector(Pages["Aimbot"], "Часть тела", y, {"Head", "HumanoidRootPart", "UpperTorso"}, Config.TargetPart, function(v) Config.TargetPart = v end)

-- FLING
y = 0
Section(Pages["Fling"], "FLING", y); y = y + 26
local selectedFlingTarget = nil
local ListFrame = Instance.new("ScrollingFrame", Pages["Fling"])
ListFrame.Size = UDim2.new(1, -10, 0, 170); ListFrame.Position = UDim2.new(0, 5, 0, y)
ListFrame.BackgroundColor3 = T.Panel; ListFrame.BorderSizePixel = 0
ListFrame.ScrollBarThickness = 3; ListFrame.ScrollBarImageColor3 = T.Accent
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 10)
local ListLayout = Instance.new("UIListLayout", ListFrame)
ListLayout.Padding = UDim.new(0, 4)
local pad = Instance.new("UIPadding", ListFrame)
pad.PaddingTop = UDim.new(0, 6); pad.PaddingLeft = UDim.new(0, 6); pad.PaddingRight = UDim.new(0, 6)

local function RefreshPlayerList()
    for _, c in ipairs(ListFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local PB = Instance.new("TextButton", ListFrame)
            PB.Size = UDim2.new(1, 0, 0, 32)
            PB.BackgroundColor3 = T.Panel2; PB.Text = "  ⊕  " .. pl.Name
            PB.TextColor3 = T.Text; PB.Font = Enum.Font.GothamBold; PB.TextSize = 11
            PB.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", PB).CornerRadius = UDim.new(0, 8)
            PB.MouseButton1Click:Connect(function()
                selectedFlingTarget = pl
                for _, b in ipairs(ListFrame:GetChildren()) do
                    if b:IsA("TextButton") then
                        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = T.Panel2}):Play()
                    end
                end
                TweenService:Create(PB, TweenInfo.new(0.12), {BackgroundColor3 = T.Accent}):Play()
                Notify("Цель выбрана: " .. pl.Name, T.Accent)
            end)
        end
    end
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 12)
end
RefreshPlayerList()
Players.PlayerAdded:Connect(function() task.wait(1) RefreshPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(1) RefreshPlayerList() end)
y = y + 180

ActionBtn(Pages["Fling"], "◎  ЗАПУСТИТЬ В КОСМОС", y, Color3.fromRGB(90, 25, 40), function(self)
    if FlingActive then Notify("Флинг уже выполняется!", T.Bad) return end
    if selectedFlingTarget and selectedFlingTarget.Parent then
        local ok = pcall(function() FlingPlayer(selectedFlingTarget) end)
        Notify(ok and "Цель отправлена в космос!" or "Ошибка флинга", ok and T.Ok or T.Bad)
    else
        Notify("Сначала выбери игрока!", T.Bad)
    end
end); y = y + 48
ActionBtn(Pages["Fling"], "↻  ОБНОВИТЬ СПИСОК", y, T.Panel2, function()
    RefreshPlayerList()
    Notify("Список обновлён", T.Accent)
end)

-- VISUALS
y = 0
Section(Pages["Visuals"], "АУРА И КРЫЛЬЯ", y); y = y + 26
Toggle(Pages["Visuals"], "Аура проклятой энергии", y, true, function(v) Config.AuraEnabled = v end); y = y + 46
Toggle(Pages["Visuals"], "Крылья тьмы", y, true, function(v) Config.WingsEnabled = v end); y = y + 46
Toggle(Pages["Visuals"], "Радужный режим 🌈", y, false, function(v) Config.RainbowAura = v end); y = y + 50
Slider(Pages["Visuals"], "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v) Config.AuraSize = v end); y = y + 54
Slider(Pages["Visuals"], "Частицы ауры", y, 0, 100, Config.AuraRate, false, function(v)
    Config.AuraRate = v; AuraParticles.Rate = v
end); y = y + 54
Slider(Pages["Visuals"], "Прозрачность крыльев", y, 0, 1.0, Config.WingsTransparency, true, function(v) Config.WingsTransparency = v end); y = y + 58

Section(Pages["Visuals"], "ЦВЕТ АУРЫ (RGB)", y); y = y + 26
Slider(Pages["Visuals"], "R", y, 0, 255, math.floor(Config.AuraColor.R * 255), false, function(v)
    Config.AuraColor = Color3.fromRGB(v, Config.AuraColor.G * 255, Config.AuraColor.B * 255)
end); y = y + 54
Slider(Pages["Visuals"], "G", y, 0, 255, math.floor(Config.AuraColor.G * 255), false, function(v)
    Config.AuraColor = Color3.fromRGB(Config.AuraColor.R * 255, v, Config.AuraColor.B * 255)
end); y = y + 54
Slider(Pages["Visuals"], "B", y, 0, 255, math.floor(Config.AuraColor.B * 255), false, function(v)
    Config.AuraColor = Color3.fromRGB(Config.AuraColor.R * 255, Config.AuraColor.G * 255, v)
end); y = y + 58

Section(Pages["Visuals"], "ЦВЕТ КРЫЛЬЕВ (RGB)", y); y = y + 26
Slider(Pages["Visuals"], "R", y, 0, 255, math.floor(Config.WingsColor.R * 255), false, function(v)
    Config.WingsColor = Color3.fromRGB(v, Config.WingsColor.G * 255, Config.WingsColor.B * 255)
end); y = y + 54
Slider(Pages["Visuals"], "G", y, 0, 255, math.floor(Config.WingsColor.G * 255), false, function(v)
    Config.WingsColor = Color3.fromRGB(Config.WingsColor.R * 255, v, Config.WingsColor.B * 255)
end); y = y + 54
Slider(Pages["Visuals"], "B", y, 0, 255, math.floor(Config.WingsColor.B * 255), false, function(v)
    Config.WingsColor = Color3.fromRGB(Config.WingsColor.R * 255, Config.WingsColor.G * 255, v)
end)

-- ESP
y = 0
Section(Pages["ESP"], "ESP", y); y = y + 26
Toggle(Pages["ESP"], "ESP Игроков", y, false, function(v) Config.EspPlayers = v end); y = y + 46
Toggle(Pages["ESP"], "ESP Charms", y, false, function(v) Config.EspCharms = v end); y = y + 46
Toggle(Pages["ESP"], "Tracers (линии)", y, true, function(v) Config.ShowTracers = v end)

-- MISC
y = 0
Section(Pages["Misc"], "СПЕЦИАЛЬНОЕ", y); y = y + 26
Toggle(Pages["Misc"], "Невидимость", y, false, function(v)
    if v then InvisModule:Activate(); Notify("Невидимость включена", T.Ok)
    else InvisModule:Deactivate(); Notify("Невидимость выключена", T.Bad) end
end); y = y + 46
Toggle(Pages["Misc"], "No Cooldown", y, false, function(v) Config.NoCooldown = v end); y = y + 46
Toggle(Pages["Misc"], "Auto Block", y, false, function(v) Config.AutoBlock = v end); y = y + 50
Slider(Pages["Misc"], "Дистанция блока", y, 5, 50, Config.AutoBlockDistance, false, function(v) Config.AutoBlockDistance = v end)

-- ==========================================================
print("═══════════════════════════════════════")
print("  ◈ APEX HUB v11 BEAUTY ЗАГРУЖЕН! ◈")
print("  🌟 Живая аура: 3 кольца + свечение + искры")
print("  🪽 Крылья: 4 сегмента, машут, лучи, частицы")
print("  💎 Премиум GUI с анимациями")
print("═══════════════════════════════════════")
Notify("APEX HUB загружен! ✨", T.Ok)
