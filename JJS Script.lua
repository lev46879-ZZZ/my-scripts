-- ==========================================================
--     ◈ APEX HUB v9.0 | JJS EDITION ◈
--     Широкий интерфейс | Все переключатели | Фикс цветов
-- ==========================================================

print("═══════════════════════════════════════")
print("  ◈ APEX HUB v9.0 | JJS ◈")
print("═══════════════════════════════════════")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Drawing = drawing or Drawing or (getgenv and getgenv().drawing)
local Camera = workspace.CurrentCamera

-- Палитра
local C = {
    BG = Color3.fromRGB(10, 8, 18),
    BG2 = Color3.fromRGB(16, 12, 28),
    Panel = Color3.fromRGB(20, 16, 36),
    PanelHover = Color3.fromRGB(35, 28, 60),
    Accent = Color3.fromRGB(147, 30, 255),
    AccentDark = Color3.fromRGB(90, 15, 180),
    Red = Color3.fromRGB(255, 40, 70),
    Green = Color3.fromRGB(40, 230, 120),
    GreenDark = Color3.fromRGB(25, 140, 75),
    Gold = Color3.fromRGB(255, 200, 50),
    White = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(225, 218, 255),
    TextDim = Color3.fromRGB(130, 120, 165),
    Black = Color3.fromRGB(0, 0, 0),
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
    EspCharms = false,
    ShowTracers = true,
    EspColor = Color3.fromRGB(255, 50, 50),
    CharmColor = Color3.fromRGB(255, 215, 0),

    Invisibility = false,
    NoCooldown = false,
}

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ==========================================================
--  НЕВИДИМОСТЬ (максимум возможного с клиента)
--  Удаляем визуальные части, оставляем только хитбокс
-- ==========================================================
local InvisModule = {
    Active = false,
    Clone = nil,
    Conn = nil,
}

function InvisModule:Activate()
    if self.Active then return end
    self.Active = true

    -- Создаём полупрозрачный клон для себя
    pcall(function()
        self.Clone = Character:Clone()
        self.Clone.Name = "ApexVisClone"
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

    -- Делаем оригинал невидимым
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function()
                part.Transparency = 1
                part.CastShadow = false
            end)
        end
    end

    -- Синхронизация клона
    self.Conn = RunService.Heartbeat:Connect(function()
        if not self.Active or not self.Clone or not self.Clone.Parent then return end
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

    Config.Invisibility = true
    print("[APEX] Невидимость активирована (клиент)")
    print("[APEX] ⚠ Полная невидимость для сервера невозможна с клиента")
end

function InvisModule:Deactivate()
    if not self.Active then return end
    self.Active = false

    if self.Conn then self.Conn:Disconnect() self.Conn = nil end
    if self.Clone and self.Clone.Parent then self.Clone:Destroy() self.Clone = nil end

    -- Восстанавливаем прозрачность
    pcall(function()
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CastShadow = true
            end
        end
    end)

    Config.Invisibility = false
    print("[APEX] Невидимость деактивирована")
end

-- ==========================================================
--  NO COOLDOWN (ищем все возможные кулдауны)
-- ==========================================================
local function ApplyNoCooldown()
    pcall(function()
        -- В персонаже
        for _, desc in ipairs(Character:GetDescendants()) do
            if desc:IsA("NumberValue") or desc:IsA("IntValue") or desc:IsA("BoolValue") then
                local name = desc.Name:lower()
                if name:find("cool") or name:find("cd") or name:find("timer")
                   or name:find("wait") or name:find("delay") or name:find("ready")
                   or name:find("lock") or name:find("skill") or name:find("ability") then
                    if desc:IsA("BoolValue") then
                        desc.Value = true
                    else
                        desc.Value = 0
                    end
                end
            end
        end
        -- В PlayerScripts
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        if ps then
            for _, desc in ipairs(ps:GetDescendants()) do
                if desc:IsA("NumberValue") or desc:IsA("IntValue") then
                    local name = desc.Name:lower()
                    if name:find("cool") or name:find("cd") or name:find("timer")
                       or name:find("wait") or name:find("delay") then
                        desc.Value = 0
                    end
                end
            end
        end
        -- В Backpack
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, desc in ipairs(bp:GetDescendants()) do
                if desc:IsA("NumberValue") or desc:IsA("IntValue") then
                    local name = desc.Name:lower()
                    if name:find("cool") or name:find("cd") or name:find("timer") then
                        desc.Value = 0
                    end
                end
            end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if Config.NoCooldown then
        ApplyNoCooldown()
    end
end)

-- ==========================================================
--  FLING (максимум возможного с клиента)
-- ==========================================================
local FlingActive = false

local function FlingPlayer(targetPlayer)
    if FlingActive then return false end
    if not targetPlayer or targetPlayer == LocalPlayer then return false end

    local tChar = targetPlayer.Character
    if not tChar then return false end
    local tHrp = tChar:FindFirstChild("HumanoidRootPart") or tChar:FindFirstChild("Torso")
    if not tHrp then return false end

    local myHrp = Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false end

    FlingActive = true
    local oldCF = myHrp.CFrame

    task.spawn(function()
        -- Отключаем свою коллизию
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end

        -- Спин
        local spin = Instance.new("BodyAngularVelocity")
        spin.MaxTorque = Vector3.new(0, math.huge, 0)
        spin.AngularVelocity = Vector3.new(0, 200, 0)
        spin.Parent = myHrp

        -- Серия телепортов вокруг цели
        for i = 1, 20 do
            if not tHrp or not tHrp.Parent then break end
            local angle = (i / 20) * math.pi * 2
            pcall(function()
                myHrp.CFrame = tHrp.CFrame * CFrame.new(math.cos(angle) * 1.5, 0, math.sin(angle) * 1.5)
            end)
            task.wait(0.02)
        end

        -- Финальный толчок
        if tHrp and tHrp.Parent then
            pcall(function()
                myHrp.CFrame = tHrp.CFrame
                myHrp.AssemblyLinearVelocity = Vector3.new(math.random(-150, 150), 200, math.random(-150, 150))
            end)

            -- Пытаемся воздействовать на цель напрямую
            pcall(function()
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(math.random(-200, 200), 400, math.random(-200, 200))
                bv.Parent = tHrp
                task.delay(2, function() if bv and bv.Parent then bv:Destroy() end end)
            end)
        end

        -- Возврат
        task.delay(0.5, function()
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

-- ESP
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
        EspTable[player].Name.Color = C.White
        EspTable[player].Hp.Size = 12
        EspTable[player].Hp.Center = true
        EspTable[player].Hp.Outline = true
        EspTable[player].Hp.Color = C.Green
        EspTable[player].Tracer.Thickness = 2
        EspTable[player].Tracer.Color = Config.EspColor
        EspTable[player].Tracer.Transparency = 0.7
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

-- AIMBOT
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
            if fovDist <= Config.FOV * 5 then
                local score
                if Config.TargetMode == "FOV" then score = fovDist
                elseif Config.TargetMode == "LowestHP" then score = info.Hum.Health
                elseif Config.TargetMode == "HighestHP" then score = -info.Hum.Health
                elseif Config.TargetMode == "Distance" then score = (Camera.CFrame.Position - part.Position).Magnitude
                else score = fovDist end
                if bestScore == nil or score < bestScore then
                    best, bestScore = { part = part }, score
                end
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

-- AUTO BLOCK
RunService.Heartbeat:Connect(function()
    if Config.AutoBlock and not InvisModule.Active then
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
--  П Р Е М И У М   G U I   (ШИРОКИЙ + НИЗКИЙ)
-- ==========================================================
print("[APEX] Создание GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexV9"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Кнопка
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 65, 0, 65)
FloatBtn.Position = UDim2.new(0, 12, 0.45, -32)
FloatBtn.BackgroundColor3 = C.BG
FloatBtn.Text = "◈"
FloatBtn.TextColor3 = C.Accent
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 28
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = C.Accent
FloatStroke.Thickness = 2.5

task.spawn(function()
    while FloatBtn.Parent do
        TweenService:Create(FloatStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 4}):Play()
        task.wait(1.5)
        TweenService:Create(FloatStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 2.5}):Play()
        task.wait(1.5)
    end
end)

-- ГЛАВНОЕ МЕНЮ: ШИРОКОЕ И НИЗКОЕ
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 380)  -- Шире и ниже!
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = C.BG
MainFrame.BackgroundTransparency = 0.02
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = C.Accent
mainStroke.Thickness = 2

local mainGrad = Instance.new("UIGradient", MainFrame)
mainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 8, 30)),
    ColorSequenceKeypoint.new(1, C.BG),
})
mainGrad.Rotation = 135

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 45)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "◈ APEX HUB"
Title.TextColor3 = C.Text
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local titleGrad = Instance.new("UIGradient", Title)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.Accent),
    ColorSequenceKeypoint.new(0.5, C.Red),
    ColorSequenceKeypoint.new(1, C.Accent),
})

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -100, 0, 14)
SubTitle.Position = UDim2.new(0, 15, 0, 35)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "JUJUTSU SHENANIGANS"
SubTitle.TextColor3 = C.TextDim
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextSize = 9
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = MainFrame

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -42, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 20, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.White
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 9)

-- Линия
local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -30, 0, 2)
HeaderLine.Position = UDim2.new(0, 15, 0, 52)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = MainFrame
local hlGrad = Instance.new("UIGradient", HeaderLine)
hlGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.Accent),
    ColorSequenceKeypoint.new(0.5, C.Red),
    ColorSequenceKeypoint.new(1, C.Accent),
})

-- Функция открытия/закрытия
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
            MainFrame.Size = UDim2.new(0, 550, 0, 380)
            MainFrame.BackgroundTransparency = 0.02
        end)
    else
        MenuOpen = true
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.BackgroundTransparency = 1
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 550, 0, 380), BackgroundTransparency = 0.02
        }):Play()
    end
end

CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)

-- ВКЛАДКИ (горизонтально сверху, т.к. меню широкое)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -30, 0, 36)
TabBar.Position = UDim2.new(0, 15, 0, 58)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tabs = {}
local Pages = {}
local tabNames = { "Aimbot", "Fling", "Visuals", "ESP", "Misc" }
local tabIcons = { "⊕", "◎", "✦", "◉", "⚙" }

for i, name in ipairs(tabNames) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1/#tabNames, -6, 1, 0)
    TabBtn.Position = UDim2.new((i-1)/#tabNames, 3, 0, 0)
    TabBtn.BackgroundColor3 = C.Panel
    TabBtn.Text = tabIcons[i] .. " " .. name
    TabBtn.TextColor3 = C.TextDim
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    local tabStroke = Instance.new("UIStroke", TabBtn)
    tabStroke.Color = C.Accent
    tabStroke.Thickness = 0
    Tabs[name] = { Btn = TabBtn, Stroke = tabStroke }

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -30, 1, -105)
    Page.Position = UDim2.new(0, 15, 0, 100)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = C.Accent
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 800)
    Page.Parent = MainFrame
    Pages[name] = Page

    TabBtn.MouseEnter:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.PanelHover}):Play()
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.Panel}):Play()
        end
    end)
end

Pages["Aimbot"].Visible = true
Tabs["Aimbot"].Btn.BackgroundColor3 = C.AccentDark
Tabs["Aimbot"].Btn.TextColor3 = C.Text
Tabs["Aimbot"].Stroke.Thickness = 1.5

for name, data in pairs(Tabs) do
    data.Btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do
            p.Visible = false
            TweenService:Create(Tabs[n].Btn, TweenInfo.new(0.15), {BackgroundColor3 = C.Panel}):Play()
            Tabs[n].Btn.TextColor3 = C.TextDim
            Tabs[n].Stroke.Thickness = 0
        end
        Pages[name].Visible = true
        TweenService:Create(data.Btn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {BackgroundColor3 = C.AccentDark}):Play()
        data.Btn.TextColor3 = C.Text
        data.Stroke.Thickness = 1.5
    end)
end

-- ==========================================================
--  УТИЛИТЫ: ТОГГЛ + СЛАЙДЕР + СЕЛЕКТОР
-- ==========================================================

-- ПЕРЕКЛЮЧАТЕЛЬ (главный элемент теперь)
local function CreateToggle(parent, text, y, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 40)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundColor3 = C.Panel
    Container.BorderSizePixel = 0
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 9)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -65, 1, 0)
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
    ToggleBg.BackgroundColor3 = default and C.Green or Color3.fromRGB(60, 60, 70)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            if state then
                TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = C.Green}):Play()
                TweenService:Create(ToggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0, 24, 0, 2)}):Play()
            else
                TweenService:Create(ToggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
                TweenService:Create(ToggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0, 2, 0, 2)}):Play()
            end
            pcall(callback, state)
        end
    end)

    return Container
end

local function CreateSlider(parent, text, y, min, max, default, isFloat, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 50)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = C.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -10, 0, 8)
    Track.Position = UDim2.new(0, 5, 0, 30)
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

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    Knob.BackgroundColor3 = C.White
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local KnobStroke = Instance.new("UIStroke", Knob)
    KnobStroke.Color = C.Accent
    KnobStroke.Thickness = 2

    local function Update(inputX)
        local rel = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        if not isFloat then val = math.floor(val + 0.5) end
        TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(rel, 0, 1, 0)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.05), {Position = UDim2.new(rel, -10, 0.5, -10)}):Play()
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
    Container.Size = UDim2.new(1, -10, 0, 54)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 14)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = C.TextDim
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local current = default
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.Position = UDim2.new(0, 0, 0, 18)
    Btn.BackgroundColor3 = C.Panel
    Btn.Text = "▸ " .. current
    Btn.TextColor3 = C.Text
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
    B.Size = UDim2.new(1, -10, 0, 40)
    B.Position = UDim2.new(0, 5, 0, y)
    B.BackgroundColor3 = color or C.Panel
    B.Text = text
    B.TextColor3 = C.Text
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    B.Parent = parent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 9)
    B.MouseButton1Click:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.06), {Size = UDim2.new(1, -16, 0, 38)}):Play()
        task.wait(0.06)
        TweenService:Create(B, TweenInfo.new(0.1, Enum.EasingStyle.Back), {Size = UDim2.new(1, -10, 0, 40)}):Play()
        pcall(callback, B)
    end)
    return B
end

local function CreateSection(parent, text, y)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -10, 0, 24)
    L.Position = UDim2.new(0, 5, 0, y)
    L.BackgroundTransparency = 1
    L.Text = "◈ " .. text
    L.TextColor3 = C.Accent
    L.Font = Enum.Font.GothamBlack
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
end

-- ==========================================================
--  СТРАНИЦА: AIMBOT (все тогглы)
-- ==========================================================
local AimbotPage = Pages["Aimbot"]
local y = 0

CreateSection(AimbotPage, "AIMBOT", y); y = y + 28
CreateToggle(AimbotPage, "Aimbot", y, false, function(v) Config.AimbotEnabled = v end); y = y + 46
CreateToggle(AimbotPage, "WallCheck", y, true, function(v) Config.WallCheck = v end); y = y + 46
CreateToggle(AimbotPage, "Поворот персонажа", y, true, function(v) Config.RotateCharacter = v end); y = y + 46
CreateToggle(AimbotPage, "Показать FOV", y, true, function(v) Config.ShowFOV = v end); y = y + 50

CreateSlider(AimbotPage, "FOV", y, 50, 1000, Config.FOV, false, function(v) Config.FOV = v end); y = y + 54
CreateSlider(AimbotPage, "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v) Config.Smoothness = v end); y = y + 54

CreateSelector(AimbotPage, "Режим цели", y, {"FOV", "LowestHP", "HighestHP", "Distance"}, Config.TargetMode, function(v) Config.TargetMode = v end); y = y + 58
CreateSelector(AimbotPage, "Часть тела", y, {"Head", "HumanoidRootPart", "UpperTorso"}, Config.TargetPart, function(v) Config.TargetPart = v end)

-- ==========================================================
--  СТРАНИЦА: FLING
-- ==========================================================
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
            PB.Size = UDim2.new(1, -5, 0, 32)
            PB.BackgroundColor3 = C.Panel
            PB.Text = "  ⊕ " .. player.Name
            PB.TextColor3 = C.Text
            PB.Font = Enum.Font.GothamBold
            PB.TextSize = 12
            PB.TextXAlignment = Enum.TextXAlignment.Left
            PB.Parent = PlayerListFrame
            Instance.new("UICorner", PB).CornerRadius = UDim.new(0, 7)
            PB.MouseButton1Click:Connect(function()
                selectedFlingTarget = player
                for _, btn in ipairs(PlayerListFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = C.Panel}):Play()
                    end
                end
                TweenService:Create(PB, TweenInfo.new(0.12), {BackgroundColor3 = C.AccentDark}):Play()
            end)
        end
    end
    PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 8)
end

RefreshPlayerList()
Players.PlayerAdded:Connect(function() task.wait(1) RefreshPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(1) RefreshPlayerList() end)

y = y + 170

local FlingBtn = CreateButton(FlingPage, "◎ ЗАПУСТИТЬ В КОСМОС", y, Color3.fromRGB(160, 20, 40), function(self)
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
end); y = y + 48

CreateButton(FlingPage, "↻ ОБНОВИТЬ СПИСОК", y, C.Panel, function(self)
    RefreshPlayerList()
    self.Text = "✅ ОБНОВЛЕНО"
    task.delay(1, function() self.Text = "↻ ОБНОВИТЬ СПИСОК" end)
end)

-- ==========================================================
--  СТРАНИЦА: VISUALS
-- ==========================================================
local VisPage = Pages["Visuals"]
y = 0

CreateSection(VisPage, "VISUALS", y); y = y + 28
CreateToggle(VisPage, "Аура", y, true, function(v)
    Config.AuraEnabled = v
    AuraRing.Transparency = v and 0.3 or 1
    AuraParticles.Enabled = v
end); y = y + 46
CreateToggle(VisPage, "Крылья", y, true, function(v)
    Config.WingsEnabled = v
    for _, w in ipairs(WingParts) do w.Part.Transparency = v and Config.WingsTransparency or 1 end
    for _, b in ipairs(WingBeams) do b.Transparency = NumberSequence.new(v and Config.WingsTransparency or 1) end
end); y = y + 50

CreateSlider(VisPage, "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v) Config.AuraSize = v; AuraRing.Size = Vector3.new(0.15, v, v) end); y = y + 54
CreateSlider(VisPage, "Частицы ауры", y, 0, 100, Config.AuraRate, false, function(v) Config.AuraRate = v; AuraParticles.Rate = v end); y = y + 54
CreateSlider(VisPage, "Прозрачность крыльев", y, 0, 1.0, Config.WingsTransparency, true, function(v)
    Config.WingsTransparency = v
    if Config.WingsEnabled then
        for _, w in ipairs(WingParts) do w.Part.Transparency = v end
        for _, b in ipairs(WingBeams) do b.Transparency = NumberSequence.new(v) end
    end
end)

-- ==========================================================
--  СТРАНИЦА: ESP
-- ==========================================================
local EspPage = Pages["ESP"]
y = 0

CreateSection(EspPage, "ESP", y); y = y + 28
CreateToggle(EspPage, "ESP Игроков", y, false, function(v) Config.EspPlayers = v end); y = y + 46
CreateToggle(EspPage, "Tracers", y, true, function(v) Config.ShowTracers = v end)

-- ==========================================================
--  СТРАНИЦА: MISC
-- ==========================================================
local MiscPage = Pages["Misc"]
y = 0

CreateSection(MiscPage, "MISC", y); y = y + 28

CreateToggle(MiscPage, "Невидимость", y, false, function(v)
    if v then
        InvisModule:Activate()
    else
        InvisModule:Deactivate()
    end
end); y = y + 46

CreateToggle(MiscPage, "No Cooldown", y, false, function(v) Config.NoCooldown = v end); y = y + 46
CreateToggle(MiscPage, "Auto Block", y, false, function(v) Config.AutoBlock = v end); y = y + 50

CreateSlider(MiscPage, "Дистанция блока", y, 5, 50, Config.AutoBlockDistance, false, function(v) Config.AutoBlockDistance = v end)

-- ==========================================================
--  ГОТОВО
-- ==========================================================
print("═══════════════════════════════════════")
print("  ◈ APEX HUB v9.0 ЗАГРУЖЕН! ◈")
print("  ⚠ Невидимость: клиентская (не серверная)")
print("  ⚠ NoCD: ищет кулдауны но не гарантирует")
print("  ⚠ Fling: зависит от сервера")
print("═══════════════════════════════════════")
