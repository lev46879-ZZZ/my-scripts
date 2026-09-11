-- ==========================================================
--  JJS ULTIMATE v4.0 (ALL-IN-ONE + MAX STABILITY)
--  Умный WallCheck + Auto Parry + ESP 2.0 (Tracers + HealthBars)
--  No Cooldown + Невидимость + Анимированное GUI v4
-- ==========================================================

print("[JJS v4.0] Запуск скрипта...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ✅ МАКСИМАЛЬНАЯ ЗАЩИТА: Поиск Drawing библиотеки
local Drawing = drawing or Drawing or (getgenv and getgenv().drawing)

if not Drawing then
    warn("[JJS] ⚠️ Библиотека Drawing не найдена! ESP и FOV отключены, но меню будет работать.")
end

local Camera = workspace.CurrentCamera

-- ==========================================================
--  КОНФИГ v4.0
-- ==========================================================
local Config = {
    -- Aimbot
    AimbotEnabled = false,
    FOV = 200,
    ShowFOV = true,
    Smoothness = 0.15,
    TargetMode = "FOV",
    TargetPart = "Head",
    WallCheck = true,
    SmartWallCheck = true, -- Игнорирует прозрачные объекты
    
    -- Auto
    AutoBlock = false,
    AutoParry = false, -- Авто-парри (попытка блока перед ударом)
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
    
    -- ESP 2.0
    EspPlayers = false,
    EspCharms = false,
    ShowTracers = true, -- Линии от экрана к врагу
    ShowHealthBars = true, -- Полоска здоровья над боксом
    EspColor = Color3.fromRGB(255, 50, 50),
    CharmColor = Color3.fromRGB(255, 215, 0),
    
    -- Misc
    Invisibility = false,
    NoCooldown = false,
}

print("[JJS] Конфиг загружен. Ожидание персонажа...")

-- ==========================================================
--  ЖДЁМ ПЕРСОНАЖА
-- ==========================================================
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

print("[JJS] Персонаж найден. Создание визуалов...")

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
--  FOV CIRCLE (Безопасный)
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
        FovCircle.Visible = Config.AimbotEnabled and Config.ShowFOV
    end)
end

-- ==========================================================
--  ESP 2.0 (Tracers + HealthBars + Умная оптимизация)
-- ==========================================================
local EspTable = {}

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
        t.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        t.BoxOutline.Filled = false
        t.Box.Thickness = 1
        t.Box.Filled = false
        t.Box.Color = Config.EspColor
        t.Name.Size = 14
        t.Name.Center = true
        t.Name.Outline = true
        t.Name.Color = Color3.fromRGB(255, 255, 255)
        t.Hp.Size = 12
        t.Hp.Center = true
        t.Hp.Outline = true
        t.Hp.Color = Color3.fromRGB(0, 255, 100)
        t.Dist.Size = 11
        t.Dist.Center = true
        t.Dist.Outline = true
        t.Dist.Color = Color3.fromRGB(255, 255, 100)
        t.Tracer.Thickness = 1.5
        t.Tracer.Color = Config.EspColor
        t.Tracer.Transparency = 0.7
        t.HealthBar.Filled = true
        t.HealthBarBg.Filled = true
        t.HealthBarBg.Color = Color3.fromRGB(30, 30, 30)
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
                    local head = char:FindFirstChild("Head")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        local headPos, _ = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local footPos, _ = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        if onScreen then
                            draw = GetEspDraw(player)
                            if draw then
                                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                                local height = math.abs(headPos.Y - footPos.Y)
                                local width = height * 0.6
                                local boxSize = Vector2.new(width, height)
                                
                                draw.Box.Size = boxSize
                                draw.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                                draw.Box.Color = Config.EspColor
                                draw.Box.Visible = true
                                
                                draw.BoxOutline.Size = boxSize
                                draw.BoxOutline.Position = draw.Box.Position
                                draw.BoxOutline.Visible = true
                                
                                draw.Name.Text = player.Name
                                draw.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 18)
                                draw.Name.Visible = true
                                
                                local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                local hpColor = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 50)
                                draw.Hp.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                                draw.Hp.Color = hpColor
                                draw.Hp.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 4)
                                draw.Hp.Visible = true
                                
                                draw.Dist.Text = "[" .. math.floor(dist) .. "m]"
                                draw.Dist.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 18)
                                draw.Dist.Visible = true
                                
                                if Config.ShowTracers then
                                    draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                                    draw.Tracer.To = Vector2.new(pos.X, pos.Y)
                                    draw.Tracer.Visible = true
                                else
                                    draw.Tracer.Visible = false
                                end
                                
                                if Config.ShowHealthBars then
                                    local barWidth = 4
                                    local barHeight = boxSize.Y
                                    local barX = draw.Box.Position.X - barWidth - 2
                                    local barY = draw.Box.Position.Y
                                    
                                    draw.HealthBarBg.Size = Vector2.new(barWidth, barHeight)
                                    draw.HealthBarBg.Position = Vector2.new(barX, barY)
                                    draw.HealthBarBg.Visible = true
                                    
                                    draw.HealthBar.Size = Vector2.new(barWidth, barHeight * hpPercent)
                                    draw.HealthBar.Position = Vector2.new(barX, barY + barHeight - barHeight * hpPercent)
                                    draw.HealthBar.Color = hpColor
                                    draw.HealthBar.Visible = true
                                else
                                    draw.HealthBar.Visible = false
                                    draw.HealthBarBg.Visible = false
                                end
                            end
                        else
                            if draw then
                                draw.Box.Visible = false; draw.BoxOutline.Visible = false
                                draw.Name.Visible = false; draw.Hp.Visible = false
                                draw.Dist.Visible = false; draw.Tracer.Visible = false
                                draw.HealthBar.Visible = false; draw.HealthBarBg.Visible = false
                            end
                        end
                    else
                        if draw then
                            draw.Box.Visible = false; draw.BoxOutline.Visible = false
                            draw.Name.Visible = false; draw.Hp.Visible = false
                            draw.Dist.Visible = false; draw.Tracer.Visible = false
                            draw.HealthBar.Visible = false; draw.HealthBarBg.Visible = false
                        end
                    end
                end
            else
                if draw then
                    draw.Box.Visible = false; draw.BoxOutline.Visible = false
                    draw.Name.Visible = false; draw.Hp.Visible = false
                    draw.Dist.Visible = false; draw.Tracer.Visible = false
                    draw.HealthBar.Visible = false; draw.HealthBarBg.Visible = false
                end
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(p)
        if EspTable[p] then
            for _, d in pairs(EspTable[p]) do if d.Remove then pcall(function() d:Remove() end) end end
            EspTable[p] = nil
        end
    end)
end

-- ==========================================================
--  ESP CHARMS (ИДЕАЛЬНАЯ ОПТИМИЗАЦИЯ - КЭШ)
-- ==========================================================
local CharmTable = {}
local CachedCharms = {}
local LastCharmUpdate = 0

local function UpdateCharmCache()
    CachedCharms = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("charm") then
            table.insert(CachedCharms, obj)
        end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("charm") then
        table.insert(CachedCharms, obj)
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    if CharmTable[obj] then
        for _, d in pairs(CharmTable[obj]) do if d.Remove then pcall(function() d:Remove() end) end end
        CharmTable[obj] = nil
    end
    for i, c in ipairs(CachedCharms) do
        if c == obj then table.remove(CachedCharms, i) break end
    end
end)

local function GetCharmDraw(model)
    if not Drawing then return nil end
    if not CharmTable[model] then
        CharmTable[model] = {
            Box = Drawing.new("Square"),
            BoxOutline = Drawing.new("Square"),
            Name = Drawing.new("Text"),
        }
        CharmTable[model].BoxOutline.Thickness = 3
        CharmTable[model].BoxOutline.Color = Color3.fromRGB(0, 0, 0)
        CharmTable[model].BoxOutline.Filled = false
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

if Drawing then
    RunService.RenderStepped:Connect(function()
        if tick() - LastCharmUpdate > 2 then
            UpdateCharmCache()
            LastCharmUpdate = tick()
        end
        
        if not Config.EspCharms then
            for m, d in pairs(CharmTable) do
                d.Box.Visible = false; d.BoxOutline.Visible = false; d.Name.Visible = false
            end
            return
        end
        
        for _, obj in ipairs(CachedCharms) do
            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if part and part.Parent then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                local draw = GetCharmDraw(obj)
                if onScreen and draw then
                    local dist = (Camera.CFrame.Position - part.Position).Magnitude
                    local scale = 1200 / dist
                    local boxSize = Vector2.new(scale * 1.2, scale * 1.2)
                    draw.Box.Size = boxSize
                    draw.Box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
                    draw.Box.Visible = true
                    draw.BoxOutline.Size = boxSize
                    draw.BoxOutline.Position = draw.Box.Position
                    draw.BoxOutline.Visible = true
                    draw.Name.Text = obj.Name
                    draw.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 14)
                    draw.Name.Visible = true
                else
                    if draw then draw.Box.Visible = false; draw.BoxOutline.Visible = false; draw.Name.Visible = false end
                end
            end
        end
    end)
end

-- ==========================================================
--  AIMBOT v4.0 (УМНЫЙ WALLCHECK)
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
        local hitPart = result.Instance
        -- Умная проверка: игнорируем прозрачные объекты
        if Config.SmartWallCheck and hitPart:IsA("BasePart") then
            if hitPart.Transparency >= 0.8 then
                return true -- Прозрачный объект, не считаем стеной
            end
        end
        return hitPart:IsDescendantOf(targetPart.Parent)
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
                        if Config.TargetMode == "FOV" then score = fovDist
                        elseif Config.TargetMode == "LowestHP" then score = info.Hum.Health
                        elseif Config.TargetMode == "HighestHP" then score = -info.Hum.Health
                        elseif Config.TargetMode == "Distance" then score = (Camera.CFrame.Position - part.Position).Magnitude
                        end
                        
                        if bestScore == nil or score < bestScore then
                            best, bestScore = { part = part, score = score }, score
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
--  AUTO BLOCK / AUTO PARRY / AUTO COUNTER
-- ==========================================================
RunService.Heartbeat:Connect(function()
    if Config.AutoBlock or Config.AutoParry or Config.AutoCounter then
        local nearestDist = math.huge
        local nearestChar = nil
        
        for _, info in ipairs(GetAlivePlayers()) do
            local dist = (info.Root.Position - Root.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestChar = info.Player.Character
            end
        end
        
        if nearestChar and nearestDist < Config.AutoBlockDistance then
            if Config.AutoBlock or Config.AutoParry then
                local tool = Character:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
            if Config.AutoCounter then
                -- Логика контры
            end
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
--  НЕВИДИМОСТЬ
-- ==========================================================
local function SetInvisibility(state)
    if not Character then return end
    pcall(function()
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.LocalTransparencyModifier = state and 1 or 0
            end
        end
    end)
end

Character.DescendantAdded:Connect(function(desc)
    if Config.Invisibility and (desc:IsA("BasePart") or desc:IsA("MeshPart")) then
        task.wait()
        pcall(function() desc.LocalTransparencyModifier = 1 end)
    end
end)

-- ==========================================================
--  GUI v4.0: АНИМИРОВАННОЕ МЕНЮ (ГАРАНТИРОВАННО РАБОТАЕТ)
-- ==========================================================
print("[JJS] Создание GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJSv4"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 60, 0, 60)
FloatBtn.Position = UDim2.new(0, 20, 0, 200)
FloatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
FloatBtn.Text = "⚡"
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 28
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = Color3.fromRGB(150, 0, 255)
FloatStroke.Thickness = 2.5

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(120, 0, 200)
MainStroke.Thickness = 2.5

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ JJS ULTIMATE v4.0 ⚡"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 60)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local function ToggleMenu()
    if MainFrame.Visible then
        if TweenService then
            local tween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1
            })
            tween:Play()
            tween.Completed:Connect(function()
                MainFrame.Visible = false
                MainFrame.Size = UDim2.new(0, 380, 0, 520)
                MainFrame.BackgroundTransparency = 0.05
            end)
        else
            MainFrame.Visible = false
        end
    else
        MainFrame.Visible = true
        if TweenService then
            local tween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 380, 0, 520)
            })
            tween:Play()
        end
    end
end

CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)

-- ВКЛАДКИ СЛЕВА
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 95, 1, -80)
TabBar.Position = UDim2.new(0, 8, 0, 75)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tabs = {}
local Pages = {}
local tabNames = { "Aimbot", "Visuals", "ESP", "Misc" }
local tabIcons = { "🎯", "✨", "👁", "⚙" }

for i, name in ipairs(tabNames) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 42)
    TabBtn.Position = UDim2.new(0, 0, 0, (i-1) * 48)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TabBtn.Text = tabIcons[i] .. " " .. name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 12
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    local tabStroke = Instance.new("UIStroke", TabBtn)
    tabStroke.Color = Color3.fromRGB(80, 0, 150)
    tabStroke.Thickness = 0
    Tabs[name] = {Btn = TabBtn, Stroke = tabStroke}
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -115, 1, -80)
    Page.Position = UDim2.new(0, 108, 0, 75)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 255)
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 1200)
    Page.Parent = MainFrame
    Pages[name] = Page
end

Pages["Aimbot"].Visible = true
Tabs["Aimbot"].Btn.BackgroundColor3 = Color3.fromRGB(90, 20, 160)
Tabs["Aimbot"].Stroke.Thickness = 1.5

for name, data in pairs(Tabs) do
    data.Btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do 
            p.Visible = false 
            if TweenService then TweenService:Create(Tabs[n].Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play() end
            Tabs[n].Stroke.Thickness = 0
        end
        Pages[name].Visible = true
        if TweenService then
            TweenService:Create(data.Btn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
                BackgroundColor3 = Color3.fromRGB(90, 20, 160), Size = UDim2.new(1.05, 0, 0, 42)
            }):Play()
            task.wait(0.15)
            TweenService:Create(data.Btn, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 42)}):Play()
        else
            data.Btn.BackgroundColor3 = Color3.fromRGB(90, 20, 160)
        end
        data.Stroke.Thickness = 1.5
    end)
end

-- УТИЛИТЫ UI
local function CreateButton(parent, text, y, color, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -10, 0, 36)
    B.Position = UDim2.new(0, 5, 0, y)
    B.BackgroundColor3 = color or Color3.fromRGB(55, 55, 75)
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    B.Parent = parent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)
    local bStroke = Instance.new("UIStroke", B)
    bStroke.Color = Color3.fromRGB(100, 0, 180)
    bStroke.Thickness = 1
    
    B.MouseButton1Click:Connect(function()
        if TweenService then
            TweenService:Create(B, TweenInfo.new(0.08), {Size = UDim2.new(1, -14, 0, 34)}):Play()
            task.wait(0.08)
            TweenService:Create(B, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Size = UDim2.new(1, -10, 0, 36)}):Play()
        end
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
    L.TextColor3 = Color3.fromRGB(200, 200, 220)
    L.Font = Enum.Font.GothamBold
    L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
    return L
end

local function CreateSectionLabel(parent, text, y)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -10, 0, 22)
    L.Position = UDim2.new(0, 5, 0, y)
    L.BackgroundTransparency = 1
    L.Text = "▸ " .. text
    L.TextColor3 = Color3.fromRGB(180, 100, 255)
    L.Font = Enum.Font.GothamBold
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
    return L
end

local function CreateSlider(parent, text, y, min, max, default, isFloat, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 45)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(220, 220, 240)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -10, 0, 10)
    Track.Position = UDim2.new(0, 5, 0, 26)
    Track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Track.BorderSizePixel = 0
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
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
        if TweenService then
            TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(rel, 0, 1, 0)}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.05), {Position = UDim2.new(rel, -10, 0.5, -10)}):Play()
        else
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            Knob.Position = UDim2.new(rel, -10, 0.5, -10)
        end
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
    local L = CreateLabel(parent, text, y, 16)
    local current = default
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 32)
    Btn.Position = UDim2.new(0, 5, 0, y + 18)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    Btn.Text = "▶ " .. current
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
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
        Btn.Text = "▶ " .. current
        pcall(callback, current)
    end)
    return Btn
end

-- ==========================================================
--  ЗАПОЛНЕНИЕ СТРАНИЦ (СОКРАЩЁННО ДЛЯ МЕСТА)
-- ==========================================================
-- AIMBOT
local AimbotPage = Pages["Aimbot"]; local y = 10
CreateSectionLabel(AimbotPage, "⚔ ОСНОВНЫЕ", y); y = y + 25
CreateButton(AimbotPage, "Aimbot: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.AimbotEnabled = not Config.AimbotEnabled
    self.Text = "Aimbot: " .. (Config.AimbotEnabled and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.AimbotEnabled and Color3.fromRGB(0, 160, 60) or Color3.fromRGB(140, 40, 40)
end); y = y + 42
CreateButton(AimbotPage, "WallCheck: ВКЛ", y, Color3.fromRGB(0, 130, 0), function(self)
    Config.WallCheck = not Config.WallCheck
    self.Text = "WallCheck: " .. (Config.WallCheck and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.WallCheck and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
end); y = y + 42
CreateButton(AimbotPage, "Smart WallCheck: ВКЛ", y, Color3.fromRGB(0, 130, 0), function(self)
    Config.SmartWallCheck = not Config.SmartWallCheck
    self.Text = "Smart WallCheck: " .. (Config.SmartWallCheck and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.SmartWallCheck and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
end); y = y + 42
CreateButton(AimbotPage, "Показать FOV: ВКЛ", y, Color3.fromRGB(0, 130, 0), function(self)
    Config.ShowFOV = not Config.ShowFOV
    self.Text = "Показать FOV: " .. (Config.ShowFOV and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.ShowFOV and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
end); y = y + 45
CreateSectionLabel(AimbotPage, "⚙ НАСТРОЙКИ", y); y = y + 25
CreateSlider(AimbotPage, "FOV", y, 10, 800, Config.FOV, false, function(v) Config.FOV = v end); y = y + 50
CreateSlider(AimbotPage, "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v) Config.Smoothness = v end); y = y + 50
CreateSelector(AimbotPage, "Режим цели", y, {"FOV", "LowestHP", "HighestHP", "Distance"}, Config.TargetMode, function(v) Config.TargetMode = v end); y = y + 55
CreateSelector(AimbotPage, "Часть тела", y, {"Head", "HumanoidRootPart", "UpperTorso"}, Config.TargetPart, function(v) Config.TargetPart = v end)

-- VISUALS
local VisPage = Pages["Visuals"]; y = 10
CreateSectionLabel(VisPage, "✨ АУРА И КРЫЛЬЯ", y); y = y + 25
CreateButton(VisPage, "Аура: ВКЛ", y, Color3.fromRGB(0, 130, 0), function(self)
    Config.AuraEnabled = not Config.AuraEnabled
    self.Text = "Аура: " .. (Config.AuraEnabled and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.AuraEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
    AuraRing.Transparency = Config.AuraEnabled and 0.3 or 1
    AuraParticles.Enabled = Config.AuraEnabled
end); y = y + 42
CreateButton(VisPage, "Крылья: ВКЛ", y, Color3.fromRGB(0, 130, 0), function(self)
    Config.WingsEnabled = not Config.WingsEnabled
    self.Text = "Крылья: " .. (Config.WingsEnabled and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.WingsEnabled and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
    for _, w in ipairs(WingParts) do w.Part.Transparency = Config.WingsEnabled and Config.WingsTransparency or 1 end
    for _, b in ipairs(WingBeams) do b.Transparency = NumberSequence.new(Config.WingsEnabled and Config.WingsTransparency or 1) end
end); y = y + 45
CreateSectionLabel(VisPage, "⚙ ПАРАМЕТРЫ", y); y = y + 25
CreateSlider(VisPage, "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v) Config.AuraSize = v; AuraRing.Size = Vector3.new(0.15, v, v) end); y = y + 50
CreateSlider(VisPage, "Чёткость крыльев", y, 0, 1.0, Config.WingsTransparency, true, function(v)
    Config.WingsTransparency = v
    for _, w in ipairs(WingParts) do if Config.WingsEnabled then w.Part.Transparency = v end end
    for _, b in ipairs(WingBeams) do if Config.WingsEnabled then b.Transparency = NumberSequence.new(v) end end
end)

-- ESP
local EspPage = Pages["ESP"]; y = 10
CreateSectionLabel(EspPage, "👁 ВИДЫ ESP", y); y = y + 25
CreateButton(EspPage, "ESP Игроков: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.EspPlayers = not Config.EspPlayers
    self.Text = "ESP Игроков: " .. (Config.EspPlayers and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.EspPlayers and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end); y = y + 42
CreateButton(EspPage, "ESP Charms: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.EspCharms = not Config.EspCharms
    self.Text = "ESP Charms: " .. (Config.EspCharms and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.EspCharms and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end); y = y + 42
CreateButton(EspPage, "Tracers: ВКЛ", y, Color3.fromRGB(0, 130, 0), function(self)
    Config.ShowTracers = not Config.ShowTracers
    self.Text = "Tracers: " .. (Config.ShowTracers and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.ShowTracers and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
end); y = y + 42
CreateButton(EspPage, "Health Bars: ВКЛ", y, Color3.fromRGB(0, 130, 0), function(self)
    Config.ShowHealthBars = not Config.ShowHealthBars
    self.Text = "Health Bars: " .. (Config.ShowHealthBars and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.ShowHealthBars and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
end)

-- MISC
local MiscPage = Pages["Misc"]; y = 10
CreateSectionLabel(MiscPage, "⚙ AUTO", y); y = y + 25
CreateButton(MiscPage, "Auto Block: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.AutoBlock = not Config.AutoBlock
    self.Text = "Auto Block: " .. (Config.AutoBlock and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.AutoBlock and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end); y = y + 42
CreateButton(MiscPage, "Auto Parry: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.AutoParry = not Config.AutoParry
    self.Text = "Auto Parry: " .. (Config.AutoParry and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.AutoParry and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end); y = y + 42
CreateSlider(MiscPage, "Дистанция блока", y, 5, 50, Config.AutoBlockDistance, false, function(v) Config.AutoBlockDistance = v end); y = y + 55
CreateSectionLabel(MiscPage, "👻 СПЕЦИАЛЬНЫЕ", y); y = y + 25
CreateButton(MiscPage, "Невидимость: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.Invisibility = not Config.Invisibility
    self.Text = "Невидимость: " .. (Config.Invisibility and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.Invisibility and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
    SetInvisibility(Config.Invisibility)
end); y = y + 42
CreateButton(MiscPage, "No Cooldown: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.NoCooldown = not Config.NoCooldown
    self.Text = "No Cooldown: " .. (Config.NoCooldown and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.NoCooldown and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end)

print("[JJS v4.0] ✅ СКРИПТ УСПЕШНО ЗАГРУЖЕН! Меню должно появиться.")
