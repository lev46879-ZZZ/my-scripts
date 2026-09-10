-- ==========================================================
--  JJS ULTIMATE v2.1 (WallCheck + Fixed ESP + Left Tabs)
--  Aimbot + AutoBlock + AutoCounter + Aura + Wings + ESP
-- ==========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================================
--  КОНФИГ
-- ==========================================================
local Config = {
    -- Aimbot
    AimbotEnabled = false,
    FOV = 200,
    Smoothness = 0.01,
    TargetMode = "FOV",
    TargetPart = "Head",
    WallCheck = true,
    
    -- Auto
    AutoBlock = false,
    AutoCounter = false,
    AutoBlockDistance = 15,
    
    -- Визуалы
    AuraEnabled = true,
    WingsEnabled = true,
    AuraColor = Color3.fromRGB(150, 0, 255),
    WingsColor = Color3.fromRGB(80, 0, 120),
    WingsTransparency = 0.2,
    AuraSize = 6,
    AuraRate = 35,
    
    -- ESP
    EspPlayers = false,
    EspCharms = false,
    EspColor = Color3.fromRGB(255, 50, 50),
    CharmColor = Color3.fromRGB(255, 215, 0),
}

-- ==========================================================
--  ЖДЁМ ПЕРСОНАЖА
-- ==========================================================
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- ==========================================================
--  АУРА ДЗЮДО
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
--  КРЫЛЬЯ ЧЁРНОЙ ЭНЕРГИИ
-- ==========================================================
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

RunService.Heartbeat:Connect(function()
    if not Root or not Root.Parent then return end
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
--  ESP ИГРОКОВ
-- ==========================================================
local EspTable = {}

local function GetEspDraw(player)
    if not EspTable[player] then
        EspTable[player] = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
            Hp = Drawing.new("Text"),
        }
        EspTable[player].Box.Thickness = 1
        EspTable[player].Box.Filled = false
        EspTable[player].Box.Color = Config.EspColor
        EspTable[player].Name.Size = 13
        EspTable[player].Name.Center = true
        EspTable[player].Name.Outline = true
        EspTable[player].Name.Color = Color3.fromRGB(255, 255, 255)
        EspTable[player].Hp.Size = 11
        EspTable[player].Hp.Center = true
        EspTable[player].Hp.Outline = true
        EspTable[player].Hp.Color = Color3.fromRGB(0, 255, 100)
    end
    return EspTable[player]
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        local draw = EspTable[player]
        if player ~= LocalPlayer and Config.EspPlayers then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and head and hum then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        draw = GetEspDraw(player)
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
                        draw.Hp.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 3)
                        draw.Hp.Visible = true
                    else
                        if draw then
                            draw.Box.Visible = false
                            draw.Name.Visible = false
                            draw.Hp.Visible = false
                        end
                    end
                else
                    if draw then
                        draw.Box.Visible = false
                        draw.Name.Visible = false
                        draw.Hp.Visible = false
                    end
                end
            else
                if draw then
                    draw.Box.Visible = false
                    draw.Name.Visible = false
                    draw.Hp.Visible = false
                end
            end
        else
            if draw then
                draw.Box.Visible = false
                draw.Name.Visible = false
                draw.Hp.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if EspTable[p] then
        for _, d in pairs(EspTable[p]) do
            if d.Remove then d:Remove() end
        end
        EspTable[p] = nil
    end
end)

-- ==========================================================
--  ESP CHARMS
-- ==========================================================
local CharmTable = {}

local function GetCharmDraw(model)
    if not CharmTable[model] then
        CharmTable[model] = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text"),
        }
        CharmTable[model].Box.Thickness = 1
        CharmTable[model].Box.Filled = false
        CharmTable[model].Box.Color = Config.CharmColor
        CharmTable[model].Name.Size = 12
        CharmTable[model].Name.Center = true
        CharmTable[model].Name.Outline = true
        CharmTable[model].Name.Color = Config.CharmColor
    end
    return CharmTable[model]
end

RunService.RenderStepped:Connect(function()
    if not Config.EspCharms then
        for m, d in pairs(CharmTable) do
            d.Box.Visible = false
            d.Name.Visible = false
        end
        return
    end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("charm") then
            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                local draw = CharmTable[obj]
                if onScreen then
                    draw = GetCharmDraw(obj)
                    local dist = (Camera.CFrame.Position - part.Position).Magnitude
                    local scale = 1200 / dist
                    local boxSize = Vector2.new(scale * 1.2, scale * 1.2)
                    draw.Box.Size = boxSize
                    draw.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                    draw.Box.Visible = true
                    draw.Name.Text = obj.Name
                    draw.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 14)
                    draw.Name.Visible = true
                else
                    if draw then
                        draw.Box.Visible = false
                        draw.Name.Visible = false
                    end
                end
            end
        end
    end
end)

-- ==========================================================
--  AIMBOT С WALLCHECK
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
        if result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
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
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if fovDist <= Config.FOV then
                        local score
                        if Config.TargetMode == "FOV" then
                            score = fovDist
                        elseif Config.TargetMode == "LowestHP" then
                            score = info.Hum.Health
                        elseif Config.TargetMode == "HighestHP" then
                            score = -info.Hum.Health
                        elseif Config.TargetMode == "Distance" then
                            score = (Camera.CFrame.Position - part.Position).Magnitude
                        elseif Config.TargetMode == "Name" then
                            score = info.Player.Name
                        end
                        
                        if bestScore == nil then
                            best, bestScore = { part = part, score = score }, score
                        else
                            if type(score) == "string" then
                                if score < bestScore then best, bestScore = { part = part, score = score }, score end
                            else
                                if score < bestScore then best, bestScore = { part = part, score = score }, score end
                            end
                        end
                    end
                end
            end
        end
    end
    return best and best.part
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
--  AUTO BLOCK / AUTO COUNTER
-- ==========================================================
RunService.Heartbeat:Connect(function()
    if Config.AutoBlock then
        for _, info in ipairs(GetAlivePlayers()) do
            local dist = (info.Root.Position - Root.Position).Magnitude
            if dist < Config.AutoBlockDistance then
                local tool = Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end
    if Config.AutoCounter then
        -- ВСТАВЬ СВОЙ RemoteEvent контры
    end
end)

-- ==========================================================
--  UI: ПЛАВАЮЩАЯ КНОПКА + ГЛАВНОЕ МЕНЮ
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJSv2.1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0, 20, 0, 200)
FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FloatBtn.Text = "⚡"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 26
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = Color3.fromRGB(150, 0, 255)
FloatStroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 310, 0, 480)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(120, 0, 200)
MainStroke.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundTransparency = 1
Title.Text = "⚡ JJS ULTIMATE v2.1 ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ВКЛАДКИ СЛЕВА
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 80, 1, -75)
TabBar.Position = UDim2.new(0, 5, 0, 70)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tabs = {}
local Pages = {}
local tabNames = { "Aimbot", "Visuals", "ESP", "Misc" }

for i, name in ipairs(tabNames) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.Position = UDim2.new(0, 0, 0, (i-1) * 40)
    TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    Tabs[name] = TabBtn
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -95, 1, -75)
    Page.Position = UDim2.new(0, 90, 0, 70)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 4
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 1000)
    Page.Parent = MainFrame
    Pages[name] = Page
end

Pages["Aimbot"].Visible = true
Tabs["Aimbot"].BackgroundColor3 = Color3.fromRGB(100, 30, 180)

for name, btn in pairs(Tabs) do
    btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do p.Visible = false end
        Pages[name].Visible = true
        for n, b in pairs(Tabs) do
            b.BackgroundColor3 = (n == name) and Color3.fromRGB(100, 30, 180) or Color3.fromRGB(40, 40, 55)
        end
    end)
end

-- ==========================================================
--  УТИЛИТЫ UI
-- ==========================================================
local function CreateButton(parent, text, y, color, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -10, 0, 32)
    B.Position = UDim2.new(0, 5, 0, y)
    B.BackgroundColor3 = color or Color3.fromRGB(60, 60, 75)
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 12
    B.Parent = parent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    B.MouseButton1Click:Connect(callback)
    return B
end

local function CreateLabel(parent, text, y, size)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -10, 0, size or 18)
    L.Position = UDim2.new(0, 5, 0, y)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(200, 200, 220)
    L.Font = Enum.Font.Gotham
    L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
    return L
end

local function CreateSlider(parent, text, y, min, max, default, isFloat, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 40)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(200, 200, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -10, 0, 8)
    Track.Position = UDim2.new(0, 5, 0, 24)
    Track.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    Track.BorderSizePixel = 0
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(130, 30, 220)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    
    local function Update(inputX)
        local rel = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        if not isFloat then val = math.floor(val + 0.5) end
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, -9, 0.5, -9)
        Label.Text = text .. ": " .. (isFloat and string.format("%.2f", val) or tostring(val))
        callback(val)
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
    
    return { Update = Update, Container = Container }
end

local function CreateSelector(parent, text, y, options, default, callback)
    local L = CreateLabel(parent, text, y, 16)
    local current = default
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 30)
    Btn.Position = UDim2.new(0, 5, 0, y + 18)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Btn.Text = "▶ " .. current
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, v in ipairs(options) do if v == current then idx = i break end end
        idx = idx + 1
        if idx > #options then idx = 1 end
        current = options[idx]
        Btn.Text = "▶ " .. current
        callback(current)
    end)
    return Btn
end

-- ==========================================================
--  СТРАНИЦА AIMBOT
-- ==========================================================
local AimbotPage = Pages["Aimbot"]
local y = 10

local AimBtn = CreateButton(AimbotPage, "Aimbot: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function()
    Config.AimbotEnabled = not Config.AimbotEnabled
    AimBtn.Text = "Aimbot: " .. (Config.AimbotEnabled and "ВКЛ" or "ВЫКЛ")
    AimBtn.BackgroundColor3 = Config.AimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end)
y = y + 38

local WallBtn = CreateButton(AimbotPage, "WallCheck: ВКЛ", y, Color3.fromRGB(0, 130, 0), function()
    Config.WallCheck = not Config.WallCheck
    WallBtn.Text = "WallCheck: " .. (Config.WallCheck and "ВКЛ" or "ВЫКЛ")
    WallBtn.BackgroundColor3 = Config.WallCheck and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
end)
y = y + 38

CreateSlider(AimbotPage, "FOV", y, 10, 600, Config.FOV, false, function(v)
    Config.FOV = v
end)
y = y + 45

CreateSlider(AimbotPage, "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v)
    Config.Smoothness = v
end)
y = y + 45

CreateSelector(AimbotPage, "Режим выбора цели", y,
    {"FOV", "LowestHP", "HighestHP", "Distance", "Name"},
    Config.TargetMode,
    function(v) Config.TargetMode = v end)
y = y + 55

CreateSelector(AimbotPage, "Часть тела", y,
    {"Head", "HumanoidRootPart", "UpperTorso"},
    Config.TargetPart,
    function(v) Config.TargetPart = v end)

-- ==========================================================
--  СТРАНИЦА VISUALS
-- ==========================================================
local VisPage = Pages["Visuals"]
y = 10

local AuraBtn = CreateButton(VisPage, "Аура: ВКЛ", y, Color3.fromRGB(0, 130, 0), function()
    Config.AuraEnabled = not Config.AuraEnabled
    AuraBtn.Text = "Аура: " .. (Config.AuraEnabled and "ВКЛ" or "ВЫКЛ")
    AuraBtn.BackgroundColor3 = Config.AuraEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
    AuraRing.Transparency = Config.AuraEnabled and 0.3 or 1
    AuraParticles.Enabled = Config.AuraEnabled
end)
y = y + 38

local WingBtn = CreateButton(VisPage, "Крылья: ВКЛ", y, Color3.fromRGB(0, 130, 0), function()
    Config.WingsEnabled = not Config.WingsEnabled
    WingBtn.Text = "Крылья: " .. (Config.WingsEnabled and "ВКЛ" or "ВЫКЛ")
    WingBtn.BackgroundColor3 = Config.WingsEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
    for _, w in ipairs(WingParts) do
        w.Part.Transparency = Config.WingsEnabled and Config.WingsTransparency or 1
    end
    for _, b in ipairs(WingBeams) do
        b.Transparency = NumberSequence.new(Config.WingsEnabled and Config.WingsTransparency or 1)
    end
end)
y = y + 45

CreateSlider(VisPage, "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v)
    Config.AuraSize = v
    AuraRing.Size = Vector3.new(0.15, v, v)
end)
y = y + 45

CreateSlider(VisPage, "Частиц ауры", y, 0, 100, Config.AuraRate, false, function(v)
    Config.AuraRate = v
    AuraParticles.Rate = v
end)
y = y + 45

CreateSlider(VisPage, "Чёткость крыльев", y, 0, 1.0, Config.WingsTransparency, true, function(v)
    Config.WingsTransparency = v
    for _, w in ipairs(WingParts) do
        if Config.WingsEnabled then w.Part.Transparency = v end
    end
    for _, b in ipairs(WingBeams) do
        if Config.WingsEnabled then b.Transparency = NumberSequence.new(v) end
    end
end)
y = y + 50

CreateLabel(VisPage, "Цвет ауры и крыльев (RGB)", y)
y = y + 20

CreateSlider(VisPage, "R", y, 0, 255, math.floor(Config.AuraColor.R * 255), false, function(v)
    Config.AuraColor = Color3.fromRGB(v, Config.AuraColor.G * 255, Config.AuraColor.B * 255)
    Config.WingsColor = Color3.fromRGB(v * 0.6, Config.AuraColor.G * 255 * 0.6, Config.AuraColor.B * 255 * 0.6)
    AuraRing.Color = Config.AuraColor
    AuraParticles.Color = ColorSequence.new(Config.AuraColor)
    for _, w in ipairs(WingParts) do w.Part.Color = Config.WingsColor end
    for _, b in ipairs(WingBeams) do b.Color = ColorSequence.new(Config.WingsColor) end
end)
y = y + 42

CreateSlider(VisPage, "G", y, 0, 255, math.floor(Config.AuraColor.G * 255), false, function(v)
    Config.AuraColor = Color3.fromRGB(Config.AuraColor.R * 255, v, Config.AuraColor.B * 255)
    Config.WingsColor = Color3.fromRGB(Config.AuraColor.R * 255 * 0.6, v * 0.6, Config.AuraColor.B * 255 * 0.6)
    AuraRing.Color = Config.AuraColor
    AuraParticles.Color = ColorSequence.new(Config.AuraColor)
    for _, w in ipairs(WingParts) do w.Part.Color = Config.WingsColor end
    for _, b in ipairs(WingBeams) do b.Color = ColorSequence.new(Config.WingsColor) end
end)
y = y + 42

CreateSlider(VisPage, "B", y, 0, 255, math.floor(Config.AuraColor.B * 255), false, function(v)
    Config.AuraColor = Color3.fromRGB(Config.AuraColor.R * 255, Config.AuraColor.G * 255, v)
    Config.WingsColor = Color3.fromRGB(Config.AuraColor.R * 255 * 0.6, Config.AuraColor.G * 255 * 0.6, v * 0.6)
    AuraRing.Color = Config.AuraColor
    AuraParticles.Color = ColorSequence.new(Config.AuraColor)
    for _, w in ipairs(WingParts) do w.Part.Color = Config.WingsColor end
    for _, b in ipairs(WingBeams) do b.Color = ColorSequence.new(Config.WingsColor) end
end)

-- ==========================================================
--  СТРАНИЦА ESP
-- ==========================================================
local EspPage = Pages["ESP"]
y = 10

local EspPBtn = CreateButton(EspPage, "ESP Игроков: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function()
    Config.EspPlayers = not Config.EspPlayers
    EspPBtn.Text = "ESP Игроков: " .. (Config.EspPlayers and "ВКЛ" or "ВЫКЛ")
    EspPBtn.BackgroundColor3 = Config.EspPlayers and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end)
y = y + 38

local EspCBtn = CreateButton(EspPage, "ESP Charms: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function()
    Config.EspCharms = not Config.EspCharms
    EspCBtn.Text = "ESP Charms: " .. (Config.EspCharms and "ВКЛ" or "ВЫКЛ")
    EspCBtn.BackgroundColor3 = Config.EspCharms and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end)
y = y + 45

CreateSlider(EspPage, "R игроков", y, 0, 255, Config.EspColor.R * 255, false, function(v)
    Config.EspColor = Color3.fromRGB(v, Config.EspColor.G * 255, Config.EspColor.B * 255)
end)
y = y + 42

CreateSlider(EspPage, "G игроков", y, 0, 255, Config.EspColor.G * 255, false, function(v)
    Config.EspColor = Color3.fromRGB(Config.EspColor.R * 255, v, Config.EspColor.B * 255)
end)
y = y + 42

CreateSlider(EspPage, "B игроков", y, 0, 255, Config.EspColor.B * 255, false, function(v)
    Config.EspColor = Color3.fromRGB(Config.EspColor.R * 255, Config.EspColor.G * 255, v)
end)
y = y + 50

CreateSlider(EspPage, "R charms", y, 0, 255, Config.CharmColor.R * 255, false, function(v)
    Config.CharmColor = Color3.fromRGB(v, Config.CharmColor.G * 255, Config.CharmColor.B * 255)
end)
y = y + 42

CreateSlider(EspPage, "G charms", y, 0, 255, Config.CharmColor.G * 255, false, function(v)
    Config.CharmColor = Color3.fromRGB(Config.CharmColor.R * 255, v, Config.CharmColor.B * 255)
end)
y = y + 42

CreateSlider(EspPage, "B charms", y, 0, 255, Config.CharmColor.B * 255, false, function(v)
    Config.CharmColor = Color3.fromRGB(Config.CharmColor.R * 255, Config.CharmColor.G * 255, v)
end)

-- ==========================================================
--  СТРАНИЦА MISC
-- ==========================================================
local MiscPage = Pages["Misc"]
y = 10

local BlockBtn = CreateButton(MiscPage, "Auto Block: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function()
    Config.AutoBlock = not Config.AutoBlock
    BlockBtn.Text = "Auto Block: " .. (Config.AutoBlock and "ВКЛ" or "ВЫКЛ")
    BlockBtn.BackgroundColor3 = Config.AutoBlock and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end)
y = y + 38

local CounterBtn = CreateButton(MiscPage, "Auto Counter: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function()
    Config.AutoCounter = not Config.AutoCounter
    CounterBtn.Text = "Auto Counter: " .. (Config.AutoCounter and "ВКЛ" or "ВЫКЛ")
    CounterBtn.BackgroundColor3 = Config.AutoCounter and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end)
y = y + 38

CreateSlider(MiscPage, "Дистанция блока", y, 5, 50, Config.AutoBlockDistance, false, function(v)
    Config.AutoBlockDistance = v
end)

print("[JJS Ultimate v2.1] Загружено! WallCheck + Fixed ESP + Left Tabs")
