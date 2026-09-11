-- ==========================================================
--  JJS ULTIMATE v5.0 (Fling + Cosmetics Warning)
-- ==========================================================

print("[JJS v5.0] Запуск скрипта...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Drawing = drawing or Drawing or (getgenv and getgenv().drawing)

if not Drawing then
    warn("[JJS] ⚠️ Библиотека Drawing не найдена! Меню будет работать, но без ESP.")
end

local Camera = workspace.CurrentCamera

-- ==========================================================
--  КОНФИГ
-- ==========================================================
local Config = {
    AimbotEnabled = false,
    FOV = 200,
    ShowFOV = true,
    Smoothness = 0.15,
    TargetMode = "FOV",
    TargetPart = "Head",
    WallCheck = true,
    SmartWallCheck = true,
    
    AutoBlock = false,
    AutoParry = false,
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
    
    -- FLING
    FlingPower = 500,      -- Сила флинга
    FlingMethod = "Spin",  -- Spin | Launch | Collide
    AntiFling = false,     -- Защита от флинга себя
}

print("[JJS] Конфиг загружен. Ожидание персонажа...")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ==========================================================
--  FLING ENGINE (3 МЕТОДА)
-- ==========================================================

-- Метод 1: РАЗГОН ЧЕРЕЗ СТОЛКНОВЕНИЕ (самый рабочий)
local function FlingByCollision(targetPlayer, power)
    local targetChar = targetPlayer.Character
    if not targetChar then warn("[FLING] У игрока нет персонажа") return false end
    
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
    if not targetHrp then return false end
    
    local myHrp = Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false end
    
    local oldCFrame = myHrp.CFrame
    local oldVelocity = myHrp.Velocity
    
    -- Создаём невидимый мощный "снаряд" из своего тела
    task.spawn(function()
        -- Позиционируемся рядом с целью
        myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
        task.wait(0.05)
        
        -- Разгоняемся в сторону врага
        local direction = (targetHrp.Position - myHrp.Position).Unit
        myHrp.AssemblyLinearVelocity = direction * power
        
        -- Создаём BodyVelocity для усиления
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = direction * power
        bv.Parent = myHrp
        
        -- BodyAngularVelocity для вращения (усиливает эффект)
        local bav = Instance.new("BodyAngularVelocity")
        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bav.AngularVelocity = Vector3.new(0, power / 10, 0)
        bav.Parent = myHrp
        
        task.delay(0.3, function()
            if bv and bv.Parent then bv:Destroy() end
            if bav and bav.Parent then bav:Destroy() end
            -- Возвращаемся на место
            if myHrp and myHrp.Parent then
                myHrp.CFrame = oldCFrame
                myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end)
    
    return true
end

-- Метод 2: ПРЯМОЕ ВОЗДЕЙСТВИЕ (работает если сервер разрешает)
local function FlingDirect(targetPlayer, power)
    local targetChar = targetPlayer.Character
    if not targetChar then return false end
    
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
    if not targetHrp then return false end
    
    task.spawn(function()
        -- Пытаемся установить скорость напрямую
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(
            math.random(-power, power),
            power,
            math.random(-power, power)
        )
        bv.Parent = targetHrp
        
        task.delay(0.5, function()
            if bv and bv.Parent then bv:Destroy() end
        end)
    end)
    
    return true
end

-- Метод 3: ВРАЩЕНИЕ (классический спин-флинг)
local SpinFlingActive = false
local function ToggleSpinFling(state)
    SpinFlingActive = state
    
    if state then
        task.spawn(function()
            while SpinFlingActive and Character and Character.Parent do
                local myHrp = Character:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    -- Вращаем себя на огромной скорости
                    local bav = Instance.new("BodyAngularVelocity")
                    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bav.AngularVelocity = Vector3.new(0, 100, 0)
                    bav.Parent = myHrp
                    
                    task.wait(0.1)
                    
                    if bav and bav.Parent then bav:Destroy() end
                end
                task.wait()
            end
        end)
    end
end

-- Главная функция флинга
local function FlingPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return end
    
    local method = Config.FlingMethod
    local power = Config.FlingPower
    
    if method == "Collide" then
        FlingByCollision(targetPlayer, power)
    elseif method == "Launch" then
        FlingDirect(targetPlayer, power)
    elseif method == "Spin" then
        -- Спин требует близкого контакта
        ToggleSpinFling(true)
        task.delay(2, function()
            ToggleSpinFling(false)
        end)
        -- Подлетаем к врагу
        FlingByCollision(targetPlayer, power * 0.5)
    end
end

-- ==========================================================
--  АНТИ-ФЛИНГ (защита себя)
-- ==========================================================
local function EnableAntiFling(state)
    if state then
        local myHrp = Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            -- Создаём якорь
            local anchor = Instance.new("BodyPosition")
            anchor.Name = "AntiFlingAnchor"
            anchor.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            anchor.Position = myHrp.Position
            anchor.P = 10000
            anchor.D = 1000
            anchor.Parent = myHrp
            
            -- Обновляем позицию каждый кадр
            task.spawn(function()
                while Config.AntiFling and anchor.Parent do
                    anchor.Position = myHrp.Position
                    task.wait()
                end
            end)
        end
    else
        local anchor = Character:FindFirstChild("AntiFlingAnchor", true)
        if anchor then anchor:Destroy() end
    end
end

-- ==========================================================
--  КОСМЕТИКА (ЧЕСТНОЕ ПРЕДУПРЕЖДЕНИЕ)
-- ==========================================================
local function TryUnlockCosmetics()
    -- Пытаемся найти локальные значения косметики
    local found = 0
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    
    -- Ищем всё что похоже на инвентарь косметики
    local searchLocations = {
        LocalPlayer,
        LocalPlayer:FindFirstChild("PlayerScripts"),
        playerGui,
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"),
    }
    
    for _, location in pairs(searchLocations) do
        if location then
            pcall(function()
                for _, desc in ipairs(location:GetDescendants()) do
                    local name = desc.Name:lower()
                    if name:find("cosmetic") or name:find("skin") or name:find("emote") 
                       or name:find("unlock") or name:find("inventory") or name:find("owned") then
                        
                        if desc:IsA("BoolValue") then
                            desc.Value = true
                            found = found + 1
                        elseif desc:IsA("NumberValue") or desc:IsA("IntValue") then
                            desc.Value = 999
                            found = found + 1
                        elseif desc:IsA("RemoteEvent") then
                            -- Пытаемся вызвать удалённое событие разблокировки
                            pcall(function()
                                desc:FireServer("unlock_all")
                            end)
                        end
                    end
                end
            end)
        end
    end
    
    return found
end

-- ==========================================================
--  ОСТАЛЬНЫЕ СИСТЕМЫ (Аура, Крылья, Аимбот, ESP)
-- ==========================================================

-- Аура
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

-- Крылья
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
    if Config.AuraEnabled then
        AuraRing.CFrame = Root.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, math.rad(90))
    end
    if Config.WingsEnabled then
        for _, w in ipairs(WingParts) do
            w.Part.CFrame = Root.CFrame * w.BaseOffset
        end
    end
end)

-- FOV Circle
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

-- ESP Игроков
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
        EspTable[player].Tracer.Thickness = 1.5
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
                                draw.Name.Position = Vector2.new(pos.X, pos.Y - boxSize.Y / 2 - 18)
                                draw.Name.Visible = true
                                
                                draw.Hp.Text = math.floor(hum.Health) .. " HP"
                                draw.Hp.Position = Vector2.new(pos.X, pos.Y + boxSize.Y / 2 + 4)
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
        if Config.SmartWallCheck and hitPart:IsA("BasePart") then
            if hitPart.Transparency >= 0.8 then return true end
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

-- AUTO BLOCK / NO COOLDOWN / INVISIBILITY
RunService.Heartbeat:Connect(function()
    if Config.AutoBlock then
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

-- ==========================================================
--  GUI v5.0 (С НОВОЙ ВКЛАДКОЙ "FLING")
-- ==========================================================
print("[JJS] Создание GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJSv5"
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
MainFrame.Size = UDim2.new(0, 400, 0, 550)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -275)
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
Title.Text = "⚡ JJS ULTIMATE v5.0 ⚡"
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
                MainFrame.Size = UDim2.new(0, 400, 0, 550)
                MainFrame.BackgroundTransparency = 0.05
            end)
        else
            MainFrame.Visible = false
        end
    else
        MainFrame.Visible = true
        if TweenService then
            local tween = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 400, 0, 550)
            })
            tween:Play()
        end
    end
end

CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)

-- ВКЛАДКИ СЛЕВА (5 вкладок)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 95, 1, -80)
TabBar.Position = UDim2.new(0, 8, 0, 75)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tabs = {}
local Pages = {}
local tabNames = { "Aimbot", "Fling", "Visuals", "ESP", "Misc" }
local tabIcons = { "🎯", "🌪", "✨", "👁", "⚙" }

for i, name in ipairs(tabNames) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.Position = UDim2.new(0, 0, 0, (i-1) * 46)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TabBtn.Text = tabIcons[i] .. " " .. name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
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
                BackgroundColor3 = Color3.fromRGB(90, 20, 160), Size = UDim2.new(1.05, 0, 0, 40)
            }):Play()
            task.wait(0.15)
            TweenService:Create(data.Btn, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 40)}):Play()
        else
            data.Btn.BackgroundColor3 = Color3.fromRGB(90, 20, 160)
        end
        data.Stroke.Thickness = 1.5
    end)
end

-- УТИЛИТЫ
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
--  СТРАНИЦА FLING (НОВАЯ!)
-- ==========================================================
local FlingPage = Pages["Fling"]
local y = 10

CreateSectionLabel(FlingPage, "🌪 FLING ИГРОКОВ", y); y = y + 25

CreateLabel(FlingPage, "Выбери игрока из списка и нажми FLING", y, 30); y = y + 35

-- Список игроков для флинга
local selectedFlingTarget = nil
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, -10, 0, 150)
playerListFrame.Position = UDim2.new(0, 5, 0, y)
playerListFrame.BackgroundTransparency = 1
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 3
playerListFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 255)
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.Parent = FlingPage

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Padding = UDim.new(0, 4)
playerListLayout.Parent = playerListFrame

local function RefreshPlayerList()
    for _, child in ipairs(playerListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerBtn = Instance.new("TextButton")
            PlayerBtn.Size = UDim2.new(1, -5, 0, 28)
            PlayerBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            PlayerBtn.Text = player.Name
            PlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            PlayerBtn.Font = Enum.Font.GothamBold
            PlayerBtn.TextSize = 11
            PlayerBtn.Parent = playerListFrame
            Instance.new("UICorner", PlayerBtn).CornerRadius = UDim.new(0, 6)
            
            PlayerBtn.MouseButton1Click:Connect(function()
                selectedFlingTarget = player
                for _, btn in ipairs(playerListFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    end
                end
                PlayerBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
            end)
        end
    end
    
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10)
end

RefreshPlayerList()
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

y = y + 160

CreateSlider(FlingPage, "Сила флинга", y, 100, 2000, Config.FlingPower, false, function(v) Config.FlingPower = v end); y = y + 50

CreateSelector(FlingPage, "Метод флинга", y, {"Spin", "Launch", "Collide"}, Config.FlingMethod, function(v) Config.FlingMethod = v end); y = y + 55

local FlingBtn = CreateButton(FlingPage, "🌪 FLING ВЫБРАННОГО ИГРОКА", y, Color3.fromRGB(255, 100, 0), function(self)
    if selectedFlingTarget and selectedFlingTarget.Parent then
        local success = pcall(function() FlingPlayer(selectedFlingTarget) end)
        if success then
            self.Text = "✅ ФЛИНГ ОТПРАВЛЕН!"
            self.BackgroundColor3 = Color3.fromRGB(0, 160, 60)
            task.delay(1.5, function()
                self.Text = "🌪 FLING ВЫБРАННОГО ИГРОКА"
                self.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            end)
        else
            self.Text = "❌ ОШИБКА ФЛИНГА"
            self.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
            task.delay(1.5, function()
                self.Text = "🌪 FLING ВЫБРАННОГО ИГРОКА"
                self.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            end)
        end
    else
        self.Text = "⚠ ВЫБЕРИ ИГРОКА ИЗ СПИСКА"
        self.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        task.delay(1.5, function()
            self.Text = "🌪 FLING ВЫБРАННОГО ИГРОКА"
            self.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        end)
    end
end); y = y + 45

CreateButton(FlingPage, "🔄 ОБНОВИТЬ СПИСОК ИГРОКОВ", y, Color3.fromRGB(60, 60, 90), function(self)
    RefreshPlayerList()
    self.Text = "✅ СПИСОК ОБНОВЛЁН"
    task.delay(1, function()
        self.Text = "🔄 ОБНОВИТЬ СПИСОК ИГРОКОВ"
    end)
end); y = y + 45

CreateButton(FlingPage, "Anti-Fling (защита себя): ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.AntiFling = not Config.AntiFling
    self.Text = "Anti-Fling: " .. (Config.AntiFling and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.AntiFling and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(140, 40, 40)
    EnableAntiFling(Config.AntiFling)
end)

-- ==========================================================
--  СТРАНИЦА MISC (с кнопкой косметики)
-- ==========================================================
local MiscPage = Pages["Misc"]
y = 10

CreateSectionLabel(MiscPage, "⚙ AUTO", y); y = y + 25

CreateButton(MiscPage, "Auto Block: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.AutoBlock = not Config.AutoBlock
    self.Text = "Auto Block: " .. (Config.AutoBlock and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.AutoBlock and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end); y = y + 42

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
end); y = y + 55

CreateSectionLabel(MiscPage, "🎨 КОСМЕТИКА", y); y = y + 25

CreateLabel(MiscPage, "⚠ ВНИМАНИЕ: Косметика хранится на сервере.", y, 16); y = y + 18
CreateLabel(MiscPage, "Клиент НЕ МОЖЕТ разблокировать её.", y, 16); y = y + 18
CreateLabel(MiscPage, "Кнопка ниже попытается, но это не сработает.", y, 16); y = y + 25

CreateButton(MiscPage, "🔓 ПОПЫТКА РАЗБЛОКИРОВКИ ВСЕЙ КОСМЕТИКИ", y, Color3.fromRGB(255, 150, 0), function(self)
    self.Text = "⏳ ПОИСК КОСМЕТИКИ..."
    task.wait(0.5)
    
    local found = TryUnlockCosmetics()
    
    if found > 0 then
        self.Text = "⚠ НАЙДЕНО " .. found .. " ЛОКАЛЬНЫХ ЗНАЧЕНИЙ"
        self.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    else
        self.Text = "❌ КОСМЕТИКА НА СЕРВЕРЕ - НЕВОЗМОЖНО"
        self.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    end
    
    task.delay(3, function()
        self.Text = "🔓 ПОПЫТКА РАЗБЛОКИРОВКИ ВСЕЙ КОСМЕТИКИ"
        self.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    end)
end)

-- ==========================================================
--  ОСТАЛЬНЫЕ СТРАНИЦЫ (Aimbot, Visuals, ESP)
-- ==========================================================
local AimbotPage = Pages["Aimbot"]
y = 10
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
end); y = y + 45
CreateSlider(AimbotPage, "FOV", y, 10, 800, Config.FOV, false, function(v) Config.FOV = v end); y = y + 50
CreateSlider(AimbotPage, "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v) Config.Smoothness = v end); y = y + 50
CreateSelector(AimbotPage, "Режим цели", y, {"FOV", "LowestHP", "HighestHP", "Distance"}, Config.TargetMode, function(v) Config.TargetMode = v end); y = y + 55
CreateSelector(AimbotPage, "Часть тела", y, {"Head", "HumanoidRootPart", "UpperTorso"}, Config.TargetPart, function(v) Config.TargetPart = v end)

local VisPage = Pages["Visuals"]
y = 10
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
CreateSlider(VisPage, "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v) Config.AuraSize = v; AuraRing.Size = Vector3.new(0.15, v, v) end); y = y + 50
CreateSlider(VisPage, "Чёткость крыльев", y, 0, 1.0, Config.WingsTransparency, true, function(v)
    Config.WingsTransparency = v
    for _, w in ipairs(WingParts) do if Config.WingsEnabled then w.Part.Transparency = v end end
    for _, b in ipairs(WingBeams) do if Config.WingsEnabled then b.Transparency = NumberSequence.new(v) end end
end)

local EspPage = Pages["ESP"]
y = 10
CreateSectionLabel(EspPage, "👁 ВИДЫ ESP", y); y = y + 25
CreateButton(EspPage, "ESP Игроков: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.EspPlayers = not Config.EspPlayers
    self.Text = "ESP Игроков: " .. (Config.EspPlayers and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.EspPlayers and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end); y = y + 42
CreateButton(EspPage, "Tracers: ВКЛ", y, Color3.fromRGB(0, 130, 0), function(self)
    Config.ShowTracers = not Config.ShowTracers
    self.Text = "Tracers: " .. (Config.ShowTracers and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.ShowTracers and Color3.fromRGB(0, 130, 0) or Color3.fromRGB(130, 0, 0)
end)

print("[JJS v5.0] ✅ СКРИПТ ЗАГРУЖЕН! Меню должно появиться.")
print("[JJS] 🌪 FLING: Выбери игрока из списка и нажми кнопку")
print("[JJS] ⚠ Косметика: Хранится на сервере, разблокировка невозможна")
