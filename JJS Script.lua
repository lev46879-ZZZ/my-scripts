-- ==========================================================
--  APEX HUB v6.0 | JJS ULTIMATE
--  Fling (Cosmos) + True Invisibility + Premium GUI
-- ==========================================================

print("[APEX] Запуск...")

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
    FOV = 200,
    ShowFOV = true,
    Smoothness = 0.15,
    TargetMode = "FOV",
    TargetPart = "Head",
    WallCheck = true,
    SmartWallCheck = true,
    
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
    
    FlingPower = 3000,
    FlingHeight = 5000,
}

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Сохраняем позицию для возврата
local SavedPosition = Root.CFrame
local IsInvisible = false

-- ==========================================================
--  FLING В КОСМОС (ОДИН МОЩНЫЙ МЕТОД)
-- ==========================================================
local function FlingToCosmos(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    
    local targetChar = targetPlayer.Character
    if not targetChar then return false end
    
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
    if not targetHrp then return false end
    
    local myHrp = Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false end
    
    -- Сохраняем свою позицию
    local myOldCFrame = myHrp.CFrame
    
    task.spawn(function()
        -- Подлетаем к врагу
        local direction = (targetHrp.Position - myHrp.Position).Unit
        myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2)
        task.wait(0.05)
        
        -- Создаём мощнейший импульс
        local flingVelocity = Vector3.new(
            math.random(-Config.FlingPower, Config.FlingPower),
            Config.FlingHeight,
            math.random(-Config.FlingPower, Config.FlingPower)
        )
        
        -- Разгоняем себя в сторону врага
        myHrp.AssemblyLinearVelocity = direction * Config.FlingPower
        
        -- BodyVelocity для максимальной силы
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = direction * Config.FlingPower
        bv.Parent = myHrp
        
        -- BodyAngularVelocity для вращения (усиливает эффект)
        local bav = Instance.new("BodyAngularVelocity")
        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bav.AngularVelocity = Vector3.new(100, 100, 100)
        bav.Parent = myHrp
        
        -- Пытаемся напрямую воздействовать на врага
        pcall(function()
            local enemyBv = Instance.new("BodyVelocity")
            enemyBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            enemyBv.Velocity = flingVelocity
            enemyBv.Parent = targetHrp
            
            local enemyBav = Instance.new("BodyAngularVelocity")
            enemyBav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            enemyBav.AngularVelocity = Vector3.new(200, 200, 200)
            enemyBav.Parent = targetHrp
            
            task.delay(1, function()
                if enemyBv and enemyBv.Parent then enemyBv:Destroy() end
                if enemyBav and enemyBav.Parent then enemyBav:Destroy() end
            end)
        end)
        
        -- Возвращаемся на место
        task.delay(0.4, function()
            if bv and bv.Parent then bv:Destroy() end
            if bav and bav.Parent then bav:Destroy() end
            if myHrp and myHrp.Parent then
                myHrp.CFrame = myOldCFrame
                myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end)
    
    return true
end

-- ==========================================================
--  НАСТОЯЩАЯ НЕВИДИМОСТЬ (ДЛЯ ВСЕХ)
-- ==========================================================
local function SetTrueInvisibility(state)
    if not Character or not Root then return end
    
    local myHrp = Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    if state then
        -- Сохраняем текущую позицию
        SavedPosition = myHrp.CFrame
        
        -- Делаем себя прозрачным локально (чтобы видеть себя)
        pcall(function()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.LocalTransparencyModifier = 0.7
                end
            end
        end)
        
        -- Телепортируем персонажа далеко под карту (другие нас не увидят)
        task.wait(0.1)
        myHrp.CFrame = CFrame.new(0, -5000, 0)
        
        IsInvisible = true
        print("[APEX] Невидимость включена! Персонаж телепортирован далеко.")
    else
        -- Возвращаемся на сохранённую позицию
        myHrp.CFrame = SavedPosition
        
        -- Убираем прозрачность
        pcall(function()
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.LocalTransparencyModifier = 0
                end
            end
        end)
        
        IsInvisible = false
        print("[APEX] Невидимость выключена! Персонаж возвращён.")
    end
end

-- Следим за новыми частями персонажа
Character.DescendantAdded:Connect(function(desc)
    if IsInvisible and (desc:IsA("BasePart") or desc:IsA("MeshPart")) then
        task.wait()
        pcall(function() desc.LocalTransparencyModifier = 0.7 end)
    end
end)

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
    if not Root or not Root.Parent then return end
    if Config.AuraEnabled and not IsInvisible then
        AuraRing.CFrame = Root.CFrame * CFrame.new(0, -2.5, 0) * CFrame.Angles(0, 0, math.rad(90))
    end
    if Config.WingsEnabled and not IsInvisible then
        for _, w in ipairs(WingParts) do
            w.Part.CFrame = Root.CFrame * w.BaseOffset
        end
    end
end)

-- ==========================================================
--  FOV + ESP + AIMBOT (как раньше)
-- ==========================================================
local FovCircle = nil
if Drawing then
    pcall(function()
        FovCircle = Drawing.new("Circle")
        FovCircle.Thickness = 2
        FovCircle.NumSides = 100
        FovCircle.Radius = Config.FOV
        FovCircle.Filled = false
        FovCircle.Color = Color3.fromRGB(0, 255, 200)
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

-- AUTO BLOCK / NO COOLDOWN
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
--  ПРЕМИУМ GUI "APEX"
-- ==========================================================
print("[APEX] Создание премиум GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ========== КНОПКА APEX (ФОРМА РОМБА) ==========
local FloatBtnContainer = Instance.new("Frame")
FloatBtnContainer.Size = UDim2.new(0, 80, 0, 80)
FloatBtnContainer.Position = UDim2.new(0, 15, 0.5, -40)
FloatBtnContainer.BackgroundTransparency = 1
FloatBtnContainer.Active = true
FloatBtnContainer.Draggable = true
FloatBtnContainer.Parent = ScreenGui

-- Ромбовидная кнопка (повёрнутый квадрат)
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 60, 0, 60)
FloatBtn.Position = UDim2.new(0.5, -30, 0.5, -30)
FloatBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
FloatBtn.Text = ""
FloatBtn.Rotation = 45 -- Поворот на 45 градусов = ромб
FloatBtn.BorderSizePixel = 0
FloatBtn.Parent = FloatBtnContainer
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 8)

-- Градиент для кнопки
local btnGradient = Instance.new("UIGradient", FloatBtn)
btnGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150))
})
btnGradient.Rotation = 45

-- Обводка
local btnStroke = Instance.new("UIStroke", FloatBtn)
btnStroke.Color = Color3.fromRGB(0, 255, 200)
btnStroke.Thickness = 2

-- Текст "APEX" (не повёрнут)
local btnText = Instance.new("TextLabel")
btnText.Size = UDim2.new(1, 0, 1, 0)
btnText.Position = UDim2.new(0, 0, 0, 0)
btnText.BackgroundTransparency = 1
btnText.Text = "APEX"
btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
btnText.Font = Enum.Font.GothamBlack
btnText.TextSize = 14
btnText.TextStrokeTransparency = 0
btnText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
btnText.Rotation = -45 -- Компенсируем поворот родителя
btnText.Parent = FloatBtnContainer

-- Анимация пульсации
task.spawn(function()
    while FloatBtnContainer.Parent do
        local pulse1 = TweenService:Create(btnStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Thickness = 4,
            Color = Color3.fromRGB(255, 0, 150)
        })
        local pulse2 = TweenService:Create(btnStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Thickness = 2,
            Color = Color3.fromRGB(0, 255, 200)
        })
        pulse1:Play()
        pulse1.Completed:Wait()
        pulse2:Play()
        pulse2.Completed:Wait()
    end
end)

-- Вращение градиента
task.spawn(function()
    local rot = 0
    while FloatBtnContainer.Parent do
        rot = rot + 1
        btnGradient.Rotation = rot
        task.wait(0.05)
    end
end)

-- Hover эффекты
FloatBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 70, 0, 70),
        Position = UDim2.new(0.5, -35, 0.5, -35)
    }):Play()
end)

FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0.5, -30, 0.5, -30)
    }):Play()
end)

-- ========== ГЛАВНОЕ МЕНЮ ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 580)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
MainFrame.BackgroundTransparency = 0.03
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(0, 255, 200)
mainStroke.Thickness = 2

local mainGradient = Instance.new("UIGradient", MainFrame)
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 5, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 15))
})
mainGradient.Rotation = 135

-- Заголовок
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 50)
TitleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleFrame.BackgroundTransparency = 0.5
TitleFrame.BorderSizePixel = 0
TitleFrame.Parent = MainFrame
Instance.new("UICorner", TitleFrame).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "◆ APEX HUB ◆"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleFrame

local titleGradient = Instance.new("UIGradient", Title)
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 150))
})

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -42, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 22
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 100, 120)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 50, 80)}):Play()
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
            MainFrame.Size = UDim2.new(0, 420, 0, 580)
            MainFrame.BackgroundTransparency = 0.03
        end)
    else
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 420, 0, 580)
        })
        tween:Play()
    end
end

CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)

-- ========== ВКЛАДКИ СЛЕВА ==========
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 100, 1, -100)
TabBar.Position = UDim2.new(0, 10, 0, 90)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Tabs = {}
local Pages = {}
local tabNames = { "Aimbot", "Fling", "Visuals", "ESP", "Misc" }
local tabIcons = { "🎯", "🌪", "✨", "👁", "⚙" }

for i, name in ipairs(tabNames) do
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 42)
    TabBtn.Position = UDim2.new(0, 0, 0, (i-1) * 48)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    TabBtn.Text = tabIcons[i] .. " " .. name
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
    local tabStroke = Instance.new("UIStroke", TabBtn)
    tabStroke.Color = Color3.fromRGB(0, 255, 200)
    tabStroke.Thickness = 0
    Tabs[name] = {Btn = TabBtn, Stroke = tabStroke}
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -125, 1, -100)
    Page.Position = UDim2.new(0, 115, 0, 90)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 1500)
    Page.Parent = MainFrame
    Pages[name] = Page
    
    TabBtn.MouseEnter:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 20, 80)}):Play()
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Pages[name].Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 35)}):Play()
        end
    end)
end

Pages["Aimbot"].Visible = true
Tabs["Aimbot"].Btn.BackgroundColor3 = Color3.fromRGB(60, 0, 120)
Tabs["Aimbot"].Stroke.Thickness = 2

for name, data in pairs(Tabs) do
    data.Btn.MouseButton1Click:Connect(function()
        for n, p in pairs(Pages) do 
            p.Visible = false 
            TweenService:Create(Tabs[n].Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 35)}):Play()
            Tabs[n].Stroke.Thickness = 0
        end
        Pages[name].Visible = true
        TweenService:Create(data.Btn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            BackgroundColor3 = Color3.fromRGB(60, 0, 120),
            Size = UDim2.new(1.08, 0, 0, 42)
        }):Play()
        task.wait(0.15)
        TweenService:Create(data.Btn, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, 42)}):Play()
        data.Stroke.Thickness = 2
    end)
end

-- ========== УТИЛИТЫ UI ==========
local function CreateButton(parent, text, y, color, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -10, 0, 38)
    B.Position = UDim2.new(0, 5, 0, y)
    B.BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    B.Parent = parent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)
    local bStroke = Instance.new("UIStroke", B)
    bStroke.Color = Color3.fromRGB(0, 255, 200)
    bStroke.Thickness = 1
    
    B.MouseEnter:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 30, 90)}):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.15), {Thickness = 2}):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.15), {BackgroundColor3 = color or Color3.fromRGB(30, 30, 50)}):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.15), {Thickness = 1}):Play()
    end)
    
    B.MouseButton1Click:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.08), {Size = UDim2.new(1, -14, 0, 36)}):Play()
        task.wait(0.08)
        TweenService:Create(B, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Size = UDim2.new(1, -10, 0, 38)}):Play()
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
    L.TextColor3 = Color3.fromRGB(180, 180, 200)
    L.Font = Enum.Font.GothamBold
    L.TextSize = 11
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
    return L
end

local function CreateSectionLabel(parent, text, y)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -10, 0, 24)
    L.Position = UDim2.new(0, 5, 0, y)
    L.BackgroundTransparency = 1
    L.Text = "◆ " .. text
    L.TextColor3 = Color3.fromRGB(0, 255, 200)
    L.Font = Enum.Font.GothamBlack
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = parent
    return L
end

local function CreateSlider(parent, text, y, min, max, default, isFloat, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -10, 0, 48)
    Container.Position = UDim2.new(0, 5, 0, y)
    Container.BackgroundTransparency = 1
    Container.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(200, 200, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -10, 0, 8)
    Track.Position = UDim2.new(0, 5, 0, 28)
    Track.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Track.BorderSizePixel = 0
    Track.Parent = Container
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 22, 0, 22)
    Knob.Position = UDim2.new((default - min) / (max - min), -11, 0.5, -11)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local KnobStroke = Instance.new("UIStroke", Knob)
    KnobStroke.Color = Color3.fromRGB(0, 255, 200)
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
    Btn.Size = UDim2.new(1, -10, 0, 34)
    Btn.Position = UDim2.new(0, 5, 0, y + 18)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
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

-- ========== СТРАНИЦА FLING ==========
local FlingPage = Pages["Fling"]
local y = 10

CreateSectionLabel(FlingPage, "🌪 FLING В КОСМОС", y); y = y + 28
CreateLabel(FlingPage, "Выбери игрока и отправь его в космос!", y, 35); y = y + 40

local selectedFlingTarget = nil
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, -10, 0, 180)
playerListFrame.Position = UDim2.new(0, 5, 0, y)
playerListFrame.BackgroundTransparency = 1
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 3
playerListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
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
            PlayerBtn.Size = UDim2.new(1, -5, 0, 32)
            PlayerBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
            PlayerBtn.Text = "  " .. player.Name
            PlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            PlayerBtn.Font = Enum.Font.GothamBold
            PlayerBtn.TextSize = 12
            PlayerBtn.TextXAlignment = Enum.TextXAlignment.Left
            PlayerBtn.Parent = playerListFrame
            Instance.new("UICorner", PlayerBtn).CornerRadius = UDim.new(0, 8)
            
            PlayerBtn.MouseButton1Click:Connect(function()
                selectedFlingTarget = player
                for _, btn in ipairs(playerListFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 40)}):Play()
                    end
                end
                TweenService:Create(PlayerBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 200, 150)}):Play()
            end)
        end
    end
    
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y + 10)
end

RefreshPlayerList()
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

y = y + 190

CreateSlider(FlingPage, "Сила флинга", y, 1000, 10000, Config.FlingPower, false, function(v) Config.FlingPower = v end); y = y + 52
CreateSlider(FlingPage, "Высота запуска", y, 1000, 20000, Config.FlingHeight, false, function(v) Config.FlingHeight = v end); y = y + 55

local FlingBtn = CreateButton(FlingPage, "🌪 ОТПРАВИТЬ В КОСМОС", y, Color3.fromRGB(255, 100, 0), function(self)
    if selectedFlingTarget and selectedFlingTarget.Parent then
        local success = pcall(function() FlingToCosmos(selectedFlingTarget) end)
        if success then
            self.Text = "✅ ОТПРАВЛЕН В КОСМОС!"
            self.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            task.delay(2, function()
                self.Text = "🌪 ОТПРАВИТЬ В КОСМОС"
                self.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            end)
        else
            self.Text = "❌ ОШИБКА"
            self.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            task.delay(2, function()
                self.Text = "🌪 ОТПРАВИТЬ В КОСМОС"
                self.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            end)
        end
    else
        self.Text = "⚠ ВЫБЕРИ ИГРОКА ИЗ СПИСКА"
        self.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        task.delay(2, function()
            self.Text = "🌪 ОТПРАВИТЬ В КОСМОС"
            self.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        end)
    end
end); y = y + 45

CreateButton(FlingPage, "🔄 ОБНОВИТЬ СПИСОК", y, Color3.fromRGB(40, 40, 70), function(self)
    RefreshPlayerList()
    self.Text = "✅ ОБНОВЛЕНО"
    task.delay(1, function() self.Text = "🔄 ОБНОВИТЬ СПИСОК" end)
end)

-- ========== СТРАНИЦA MISC ==========
local MiscPage = Pages["Misc"]
y = 10

CreateSectionLabel(MiscPage, "👻 НЕВИДИМОСТЬ", y); y = y + 28
CreateLabel(MiscPage, "Телепортирует тебя далеко под карту.", y, 16); y = y + 18
CreateLabel(MiscPage, "Другие игроки тебя НЕ УВИДЯТ!", y, 16); y = y + 25

CreateButton(MiscPage, "👻 СТАТЬ НЕВИДИМЫМ", y, Color3.fromRGB(150, 0, 255), function(self)
    Config.Invisibility = not Config.Invisibility
    if Config.Invisibility then
        self.Text = "✅ ТЫ НЕВИДИМ! (Нажми чтобы вернуться)"
        self.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        SetTrueInvisibility(true)
    else
        self.Text = "👻 СТАТЬ НЕВИДИМЫМ"
        self.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        SetTrueInvisibility(false)
    end
end); y = y + 50

CreateSectionLabel(MiscPage, "⚙ AUTO", y); y = y + 28

CreateButton(MiscPage, "Auto Block: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.AutoBlock = not Config.AutoBlock
    self.Text = "Auto Block: " .. (Config.AutoBlock and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.AutoBlock and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end); y = y + 42

CreateSlider(MiscPage, "Дистанция блока", y, 5, 50, Config.AutoBlockDistance, false, function(v) Config.AutoBlockDistance = v end); y = y + 52

CreateButton(MiscPage, "No Cooldown: ВЫКЛ", y, Color3.fromRGB(140, 40, 40), function(self)
    Config.NoCooldown = not Config.NoCooldown
    self.Text = "No Cooldown: " .. (Config.NoCooldown and "ВКЛ ✓" or "ВЫКЛ")
    self.BackgroundColor3 = Config.NoCooldown and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(140, 40, 40)
end)

-- ========== ОСТАЛЬНЫЕ СТРАНИЦЫ ==========
local AimbotPage = Pages["Aimbot"]
y = 10
CreateSectionLabel(AimbotPage, "🎯 AIMBOT", y); y = y + 28
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
CreateSlider(AimbotPage, "FOV", y, 10, 800, Config.FOV, false, function(v) Config.FOV = v end); y = y + 52
CreateSlider(AimbotPage, "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v) Config.Smoothness = v end); y = y + 52
CreateSelector(AimbotPage, "Режим цели", y, {"FOV", "LowestHP", "HighestHP", "Distance"}, Config.TargetMode, function(v) Config.TargetMode = v end); y = y + 58
CreateSelector(AimbotPage, "Часть тела", y, {"Head", "HumanoidRootPart", "UpperTorso"}, Config.TargetPart, function(v) Config.TargetPart = v end)

local VisPage = Pages["Visuals"]
y = 10
CreateSectionLabel(VisPage, "✨ АУРА И КРЫЛЬЯ", y); y = y + 28
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
CreateSlider(VisPage, "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v) Config.AuraSize = v; AuraRing.Size = Vector3.new(0.15, v, v) end); y = y + 52
CreateSlider(VisPage, "Чёткость крыльев", y, 0, 1.0, Config.WingsTransparency, true, function(v)
    Config.WingsTransparency = v
    for _, w in ipairs(WingParts) do if Config.WingsEnabled then w.Part.Transparency = v end end
    for _, b in ipairs(WingBeams) do if Config.WingsEnabled then b.Transparency = NumberSequence.new(v) end end
end)

local EspPage = Pages["ESP"]
y = 10
CreateSectionLabel(EspPage, "👁 ESP", y); y = y + 28
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

print("[APEX HUB v6.0] ✅ ЗАГРУЖЕНО!")
print("[APEX] 🌪 Fling: Выбери игрока и отправь в космос")
print("[APEX] 👻 Невидимость: Телепортирует тебя далеко, другие не увидят")
print("[APEX] ◆ Красивая кнопка APEX в форме ромба")
