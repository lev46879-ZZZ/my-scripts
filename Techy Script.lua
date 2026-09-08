-- // TECHY ULTIMATE v4.0 — HOOD RIVALS EDITION // --
-- // Optimized for Delta Mobile | Full Hood Rivals Support // --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════
-- КОНФИГУРАЦИЯ (CONFIG)
-- ═══════════════════════════════════════════════════════
local Config = {
    -- COMBAT
    AimbotEnabled = false,
    SilentAim = false,
    AimbotFOV = 180,
    AimbotSmooth = 0.4,       -- 0.1 = моментально, 1.0 = плавно
    AimbotPrediction = true,  -- Учёт движения цели
    PredictionFactor = 0.15,
    AimbotTeamCheck = false,  -- В Hood Rivals обычно FFA
    AimbotWallCheck = false,
    AimbotPart = "Head",
    Triggerbot = false,
    TriggerDelay = 0.03,
    
    -- HITBOX
    HitboxExpander = false,
    HitboxSize = 6,
    HitboxTarget = "Head",
    
    -- GUN MODS
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    RapidFireDelay = 0.05,
    
    -- VISUALS
    ESPEnabled = false,
    ESPName = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPWeapon = true,
    ESPStatus = true,         -- Ragdoll/Alive
    ShowFOV = true,
    ShowTracers = false,
    
    -- MOVEMENT
    SpeedEnabled = false,
    WalkSpeed = 50,
    JumpPower = 100,
    InfiniteJump = false,
    FlyEnabled = false,
    FlySpeed = 60,
    Noclip = false,
    
    -- HOOD SPECIFIC
    AutoStomp = false,        -- Добивание лежачих
    StompRange = 15,
    AntiRagdoll = false,      -- Защита от оглушения
    AutoFarm = false,         -- Авто-фарм (если есть миссии)
    
    -- MISC
    AntiAFK = false,
    FPSBoost = false,
    MenuOpen = true
}

-- ═══════════════════════════════════════════════════════
-- UI LIBRARY (Mobile Optimized)
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TechyHR_V4"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local Colors = {
    BG = Color3.fromRGB(12, 12, 18),
    TopBar = Color3.fromRGB(22, 22, 32),
    Accent = Color3.fromRGB(255, 60, 120),      -- Pink/Red для Hood стиля
    Accent2 = Color3.fromRGB(120, 255, 180),    -- Green
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(140, 140, 155),
    ElementBG = Color3.fromRGB(28, 28, 40),
    ToggleOn = Color3.fromRGB(80, 255, 120),
    ToggleOff = Color3.fromRGB(55, 55, 70),
    Danger = Color3.fromRGB(255, 60, 60)
}

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 440, 0, 320)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -160)
MainFrame.BackgroundColor3 = Colors.BG
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(45, 45, 60)
Stroke.Thickness = 1.5
Stroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Colors.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local FixCorner = Instance.new("Frame")
FixCorner.Size = UDim2.new(1, 0, 0, 10)
FixCorner.Position = UDim2.new(0, 0, 1, -10)
FixCorner.BackgroundColor3 = Colors.TopBar
FixCorner.BorderSizePixel = 0
FixCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TECHY ULTIMATE  •  HOOD RIVALS"
Title.TextColor3 = Colors.Text
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Hide Button
local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(1, -38, 0, 4)
HideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
HideBtn.Text = "−"
HideBtn.TextColor3 = Color3.new(1,1,1)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 16
HideBtn.Parent = TopBar
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 6)
HideBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- Dragging
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

-- Tabs Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 95, 1, -38)
TabContainer.Position = UDim2.new(0, 0, 0, 38)
TabContainer.BackgroundColor3 = Colors.TopBar
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -105, 1, -48)
ContentContainer.Position = UDim2.new(0, 100, 0, 43)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.ScrollBarImageColor3 = Colors.Accent
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = ContentContainer

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollingFrame

-- Tab Logic
local currentTab = nil
local function createTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 38)
    TabBtn.BackgroundColor3 = Colors.TopBar
    TabBtn.Text = (icon and icon .. " " or "") .. name
    TabBtn.TextColor3 = Colors.SubText
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabContainer
    
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ScrollingFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContent
    
    TabBtn.MouseButton1Click:Connect(function()
        if currentTab then
            currentTab.Content.Visible = false
            currentTab.Btn.TextColor3 = Colors.SubText
            currentTab.Btn.BackgroundColor3 = Colors.TopBar
        end
        TabContent.Visible = true
        TabBtn.TextColor3 = Colors.Accent
        TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        currentTab = {Btn = TabBtn, Content = TabContent}
    end)
    
    return TabContent
end

-- UI Components
local function createLabel(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.Accent
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function createToggle(text, default, parent, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 32)
    Container.BackgroundColor3 = Colors.ElementBG
    Container.BorderSizePixel = 0
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 5)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -55, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local ToggleBG = Instance.new("Frame")
    ToggleBG.Size = UDim2.new(0, 36, 0, 18)
    ToggleBG.Position = UDim2.new(1, -44, 0.5, -9)
    ToggleBG.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
    ToggleBG.BorderSizePixel = 0
    ToggleBG.Parent = Container
    Instance.new("UICorner", ToggleBG).CornerRadius = UDim.new(1, 0)
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
    ToggleCircle.Position = default and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
    ToggleCircle.BackgroundColor3 = Color3.new(1,1,1)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleBG
    Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    local function toggle()
        state = not state
        TweenService:Create(ToggleBG, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff
        }):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
        }):Play()
        callback(state)
    end
    
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            toggle()
        end
    end)
end

local function createSlider(text, min, max, default, parent, callback, decimals)
    decimals = decimals or 0
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 42)
    Container.BackgroundColor3 = Colors.ElementBG
    Container.BorderSizePixel = 0
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 5)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    local dispVal = decimals > 0 and string.format("%.2f", default) or tostring(default)
    Label.Text = text .. ": " .. dispVal
    Label.TextColor3 = Colors.Text
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -20, 0, 6)
    SliderBG.Position = UDim2.new(0, 10, 1, -14)
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Container
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Colors.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    
    local draggingSlider = false
    
    local function round(val)
        if decimals > 0 then
            local mult = 10 ^ decimals
            return math.floor(val * mult + 0.5) / mult
        else
            return math.floor(val + 0.5)
        end
    end
    
    local function update(input)
        local relX = math.clamp(input.Position.X - SliderBG.AbsolutePosition.X, 0, SliderBG.AbsoluteSize.X)
        local raw = min + (relX / SliderBG.AbsoluteSize.X) * (max - min)
        local val = round(raw)
        SliderFill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        local disp = decimals > 0 and string.format("%." .. decimals .. "f", val) or tostring(val)
        Label.Text = text .. ": " .. disp
        callback(val)
    end
    
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- ПОСТРОЕНИЕ МЕНЮ
-- ═══════════════════════════════════════════════════════
local TabCombat = createTab("Combat", "⚔")
local TabHitbox = createTab("Hitbox", "🎯")
local TabVisuals = createTab("Visuals", "👁")
local TabMovement = createTab("Move", "🏃")
local TabHood = createTab("Hood", "💰")
local TabMisc = createTab("Misc", "⚙")

-- COMBAT TAB
createLabel("─── AIMBOT ───", TabCombat)
createToggle("Enable Aimbot", Config.AimbotEnabled, TabCombat, function(v) Config.AimbotEnabled = v end)
createToggle("Silent Aim", Config.SilentAim, TabCombat, function(v) Config.SilentAim = v end)
createToggle("Prediction", Config.AimbotPrediction, TabCombat, function(v) Config.AimbotPrediction = v end)
createToggle("Wall Check", Config.AimbotWallCheck, TabCombat, function(v) Config.AimbotWallCheck = v end)
createSlider("FOV Radius", 50, 500, Config.AimbotFOV, TabCombat, function(v) Config.AimbotFOV = v end, 0)
createSlider("Smoothness", 0.1, 1.0, Config.AimbotSmooth, TabCombat, function(v) Config.AimbotSmooth = v end, 1)
createSlider("Prediction", 0.05, 0.5, Config.PredictionFactor, TabCombat, function(v) Config.PredictionFactor = v end, 2)

createLabel("─── TRIGGERBOT ───", TabCombat)
createToggle("Enable Triggerbot", Config.Triggerbot, TabCombat, function(v) Config.Triggerbot = v end)

createLabel("─── GUN MODS ───", TabCombat)
createToggle("No Recoil", Config.NoRecoil, TabCombat, function(v) Config.NoRecoil = v end)
createToggle("No Spread", Config.NoSpread, TabCombat, function(v) Config.NoSpread = v end)
createToggle("Rapid Fire", Config.RapidFire, TabCombat, function(v) Config.RapidFire = v end)

-- HITBOX TAB
createLabel("─── HITBOX EXPANDER ───", TabHitbox)
createToggle("Enable Hitbox", Config.HitboxExpander, TabHitbox, function(v) 
    Config.HitboxExpander = v 
    if not v then resetHitboxes() end
end)
createSlider("Size", 2, 15, Config.HitboxSize, TabHitbox, function(v) 
    Config.HitboxSize = v 
    resetHitboxes()
end, 0)

-- VISUALS TAB
createLabel("─── ESP ───", TabVisuals)
createToggle("Enable ESP", Config.ESPEnabled, TabVisuals, function(v) 
    Config.ESPEnabled = v 
    if not v then clearESP() end 
end)
createToggle("Names", Config.ESPName, TabVisuals, function(v) Config.ESPName = v end)
createToggle("Distance", Config.ESPDistance, TabVisuals, function(v) Config.ESPDistance = v end)
createToggle("Health", Config.ESPHealth, TabVisuals, function(v) Config.ESPHealth = v end)
createToggle("Weapon", Config.ESPWeapon, TabVisuals, function(v) Config.ESPWeapon = v end)
createToggle("Status (Ragdoll)", Config.ESPStatus, TabVisuals, function(v) Config.ESPStatus = v end)

createLabel("─── OVERLAY ───", TabVisuals)
createToggle("Show FOV Circle", Config.ShowFOV, TabVisuals, function(v) Config.ShowFOV = v end)
createToggle("Show Tracers", Config.ShowTracers, TabVisuals, function(v) Config.ShowTracers = v end)

-- MOVEMENT TAB
createLabel("─── SPEED ───", TabMovement)
createToggle("Speed Hack", Config.SpeedEnabled, TabMovement, function(v) Config.SpeedEnabled = v end)
createSlider("Walk Speed", 16, 200, Config.WalkSpeed, TabMovement, function(v) Config.WalkSpeed = v end, 0)
createSlider("Jump Power", 50, 300, Config.JumpPower, TabMovement, function(v) Config.JumpPower = v end, 0)
createToggle("Infinite Jump", Config.InfiniteJump, TabMovement, function(v) Config.InfiniteJump = v end)

createLabel("─── FLY / NOCLIP ───", TabMovement)
createToggle("Fly", Config.FlyEnabled, TabMovement, function(v) Config.FlyEnabled = v end)
createSlider("Fly Speed", 20, 200, Config.FlySpeed, TabMovement, function(v) Config.FlySpeed = v end, 0)
createToggle("Noclip", Config.Noclip, TabMovement, function(v) Config.Noclip = v end)

-- HOOD SPECIFIC TAB
createLabel("─── HOOD FEATURES ───", TabHood)
createToggle("Auto Stomp (Kill Downed)", Config.AutoStomp, TabHood, function(v) Config.AutoStomp = v end)
createSlider("Stomp Range", 5, 30, Config.StompRange, TabHood, function(v) Config.StompRange = v end, 0)
createToggle("Anti-Ragdoll", Config.AntiRagdoll, TabHood, function(v) Config.AntiRagdoll = v end)
createToggle("Auto Farm", Config.AutoFarm, TabHood, function(v) Config.AutoFarm = v end)

-- MISC TAB
createLabel("─── MISC ───", TabMisc)
createToggle("Anti AFK", Config.AntiAFK, TabMisc, function(v) Config.AntiAFK = v end)
createToggle("FPS Boost", Config.FPSBoost, TabMisc, function(v) Config.FPSBoost = v end)
createLabel("Techy Ultimate v4.0", TabMisc)
createLabel("Hood Rivals Edition", TabMisc)
createLabel("Made for Delta Mobile", TabMisc)

-- Auto-select first tab
local firstBtn = TabContainer:FindFirstChildWhichIsA("TextButton")
if firstBtn then
    firstBtn.TextColor3 = Colors.Accent
    firstBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
end
local firstContent = ScrollingFrame:FindFirstChildWhichIsA("Frame")
if firstContent then firstContent.Visible = true end

-- ═══════════════════════════════════════════════════════
-- FOV CIRCLE (GUI-based, работает на Delta Mobile)
-- ═══════════════════════════════════════════════════════
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVCircle"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.BorderSizePixel = 0
FOVFrame.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Colors.Accent
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.2
FOVStroke.Parent = FOVFrame

Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

-- ═══════════════════════════════════════════════════════
-- ESP SYSTEM
-- ═══════════════════════════════════════════════════════
local espObjects = {}

function clearESP()
    for p, objs in pairs(espObjects) do
        if objs.Highlight then objs.Highlight:Destroy() end
        if objs.Billboard then objs.Billboard:Destroy() end
    end
    espObjects = {}
end

local function getPlayerWeapon(player)
    local char = player.Character
    if not char then return "None" end
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then return tool.Name end
    end
    return "Fists"
end

local function isRagdoll(player)
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return hum:GetState() == Enum.HumanoidStateType.Physics 
        or hum:GetState() == Enum.HumanoidStateType.Dead
        or hum.Health <= 0
end

local function setupESP(player)
    if player == LocalPlayer then return end
    
    local function onCharAdded(char)
        if espObjects[player] then
            if espObjects[player].Highlight then espObjects[player].Highlight:Destroy() end
            if espObjects[player].Billboard then espObjects[player].Billboard:Destroy() end
        end
        
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.7
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 140, 0, 60)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent = char:WaitForChild("Head", 5) or char
        
        local txt = Instance.new("TextLabel")
        txt.BackgroundTransparency = 1
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.TextColor3 = Color3.new(1,1,1)
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 13
        txt.Parent = bb
        
        espObjects[player] = {Highlight = hl, Billboard = bb, Text = txt, Char = char}
        
        task.spawn(function()
            while espObjects[player] and char.Parent do
                if not Config.ESPEnabled then 
                    task.wait(0.2)
                    continue 
                end
                
                hl.Enabled = true
                bb.Enabled = true
                
                local ragdoll = isRagdoll(player)
                
                if ragdoll then
                    hl.FillColor = Color3.fromRGB(150, 150, 150)
                    hl.OutlineColor = Color3.fromRGB(100, 100, 100)
                else
                    hl.FillColor = Color3.fromRGB(255, 60, 120)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                
                local head = char:FindFirstChild("Head")
                if not head then 
                    task.wait(0.1)
                    continue 
                end
                
                local dist = math.floor((head.Position - Camera.CFrame.Position).Magnitude)
                local info = ""
                if Config.ESPName then info = info .. player.Name .. "\n" end
                if Config.ESPStatus then 
                    info = info .. (ragdoll and "[DOWN]" or "[ALIVE]") .. "\n" 
                end
                if Config.ESPDistance then info = info .. dist .. "m  " end
                if Config.ESPWeapon then info = info .. getPlayerWeapon(player) .. "\n" end
                if Config.ESPHealth and char:FindFirstChildOfClass("Humanoid") then
                    info = info .. math.floor(char.Humanoid.Health) .. " HP"
                end
                txt.Text = info
                
                task.wait(0.1)
            end
        end)
    end
    
    if player.Character then onCharAdded(player.Character) end
    player.CharacterAdded:Connect(onCharAdded)
end

for _, p in pairs(Players:GetPlayers()) do setupESP(p) end
Players.PlayerAdded:Connect(setupESP)

-- ═══════════════════════════════════════════════════════
-- HITBOX EXPANDER
-- ═══════════════════════════════════════════════════════
local originalSizes = {}

function resetHitboxes()
    for player, data in pairs(originalSizes) do
        local char = player.Character
        if char then
            local part = char:FindFirstChild(Config.HitboxTarget)
            if part and data.Size then
                part.Size = data.Size
                part.Transparency = data.Transparency
            end
        end
    end
end

local function expandHitbox(player)
    if player == LocalPlayer then return end
    
    local function onChar(char)
        task.wait(0.5)
        local part = char:FindFirstChild(Config.HitboxTarget)
        if part then
            originalSizes[player] = {
                Size = part.Size,
                Transparency = part.Transparency
            }
            
            task.spawn(function()
                while char.Parent and Config.HitboxExpander do
                    if part and part.Parent then
                        part.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                        part.Transparency = 0.7  -- Полупрозрачный, чтобы видеть
                        part.CanCollide = false
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
    
    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end

for _, p in pairs(Players:GetPlayers()) do expandHitbox(p) end
Players.PlayerAdded:Connect(expandHitbox)

-- ═══════════════════════════════════════════════════════
-- AIMBOT + SILENT AIM
-- ═══════════════════════════════════════════════════════
local function getClosestPlayer()
    local closest = nil
    local minDist = Config.AimbotFOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = player.Character:FindFirstChild(Config.AimbotPart) 
                    or player.Character:FindFirstChild("Head")
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                        local dist = (mousePos - targetPos).Magnitude
                        
                        if dist < minDist then
                            if Config.AimbotWallCheck then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                                local ray = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), rayParams)
                                if not ray then
                                    minDist = dist
                                    closest = player
                                end
                            else
                                minDist = dist
                                closest = player
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Prediction: вычисляем будущую позицию цели
local function getPredictedPosition(targetPart, player)
    if not Config.AimbotPrediction then return targetPart.Position end
    
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return targetPart.Position end
    
    local velocity = hum.MoveDirection * hum.WalkSpeed
    local prediction = targetPart.Position + velocity * Config.PredictionFactor
    return prediction
end

-- Silent Aim Hook (через namecall)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Config.SilentAim and (method == "Raycast" or method == "FindPartOnRay") then
        local target = getClosestPlayer()
        if target then
            local part = target.Character:FindFirstChild(Config.AimbotPart) 
                or target.Character:FindFirstChild("Head")
            if part then
                local predictedPos = getPredictedPosition(part, target)
                
                if method == "Raycast" then
                    local rayParams = args[2]
                    if rayParams then
                        local newDirection = (predictedPos - self.Origin).Unit * 1000
                        args[1] = Ray.new(self.Origin, newDirection)
                        return oldNamecall(self, unpack(args))
                    end
                elseif method == "FindPartOnRay" then
                    local newRay = Ray.new(args[1].Origin, (predictedPos - args[1].Origin).Unit * 1000)
                    args[1] = newRay
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- ═══════════════════════════════════════════════════════
-- FLY SYSTEM
-- ═══════════════════════════════════════════════════════
local flyBV = nil
local flyBodyGyro = nil

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBodyGyro.P = 1e4
    flyBodyGyro.Parent = hrp
end

local function stopFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

-- ═══════════════════════════════════════════════════════
-- AUTO STOMP (добивание лежачих)
-- ═══════════════════════════════════════════════════════
local function findDownedPlayer()
    local closest = nil
    local minDist = Config.StompRange
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if isRagdoll(player) then
                local head = player.Character:FindFirstChild("Head")
                local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
                if head and myHead then
                    local dist = (head.Position - myHead.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- ═══════════════════════════════════════════════════════
-- MAIN LOOP
-- ═══════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- FOV Circle
    FOVFrame.Visible = Config.ShowFOV and (Config.AimbotEnabled or Config.SilentAim)
    if FOVFrame.Visible then
        local diameter = Config.AimbotFOV * 2
        FOVFrame.Size = UDim2.new(0, diameter, 0, diameter)
        FOVFrame.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
    end
    
    -- AIMBOT (Camera)
    if Config.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local target = getClosestPlayer()
        if target then
            local part = target.Character:FindFirstChild(Config.AimbotPart) 
                or target.Character:FindFirstChild("Head")
            if part then
                local predictedPos = getPredictedPosition(part, target)
                local targetCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
                local alpha = (1 - Config.AimbotSmooth) + 0.05
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
            end
        end
    end
    
    -- TRIGGERBOT
    if Config.Triggerbot then
        local target = getClosestPlayer()
        if target then
            task.wait(Config.TriggerDelay)
            if mouse1click then mouse1click() end
        end
    end
    
    -- SPEED
    if hum then
        if Config.SpeedEnabled then
            hum.WalkSpeed = Config.WalkSpeed
        else
            hum.WalkSpeed = 16
        end
        hum.JumpPower = Config.JumpPower
    end
    
    -- FLY
    if Config.FlyEnabled and hrp then
        if not flyBV then startFly() end
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        flyBV.Velocity = moveDir * Config.FlySpeed
        flyBodyGyro.CFrame = Camera.CFrame
    else
        if flyBV then stopFly() end
    end
    
    -- NOCLIP
    if Config.Noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- INFINITE JUMP
    if Config.InfiniteJump and hum then
        if UserInputService.JumpRequest then
            -- handled below
        end
    end
    
    -- AUTO STOMP
    if Config.AutoStomp then
        local downed = findDownedPlayer()
        if downed and downed.Character then
            local head = downed.Character:FindFirstChild("Head")
            if head then
                -- Телепорт к лежачему и клик
                if hrp then
                    hrp.CFrame = CFrame.new(head.Position + Vector3.new(0, 3, 0))
                end
                task.wait(0.1)
                if mouse1click then mouse1click() end
            end
        end
    end
    
    -- ANTI RAGDOLL
    if Config.AntiRagdoll and hum then
        if hum:GetState() == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
    
    -- FPS BOOST (отключаем лишние эффекты)
    if Config.FPSBoost then
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.WaterWaveSpeed = 0
        Workspace.Terrain.WaterReflectance = 0
        Workspace.Terrain.WaterTransparency = 0
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end
end)

-- Infinite Jump Handler
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ═══════════════════════════════════════════════════════
-- ANTI AFK
-- ═══════════════════════════════════════════════════════
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
    end
end)

-- ═══════════════════════════════════════════════════════
-- NO RECOIL / NO SPREAD / RAPID FIRE HOOKS
-- ═══════════════════════════════════════════════════════
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    local result = oldIndex(self, key)
    
    if Config.NoRecoil and self:IsA("ModuleScript") and string.find(self.Name:lower(), "recoil") then
        if key == "Recoil" or key == "Kick" then
            return function() return 0 end
        end
    end
    
    if Config.NoSpread and self:IsA("ModuleScript") and string.find(self.Name:lower(), "spread") then
        if key == "Spread" or key == "Accuracy" then
            return 0
        end
    end
    
    return result
end)

-- RAPID FIRE
task.spawn(function()
    while true do
        if Config.RapidFire and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            if mouse1click then mouse1click() end
            task.wait(Config.RapidFireDelay or 0.05)
        end
        task.wait()
    end
end)

-- ═══════════════════════════════════════════════════════
-- STARTUP
-- ═══════════════════════════════════════════════════════
print("╔════════════════════════════════════════╗")
print("║  TECHY ULTIMATE v4.0 - HOOD RIVALS     ║")
print("║  Optimized for Delta Mobile            ║")
print("║  Silent Aim + Prediction + Auto Stomp  ║")
print("╚════════════════════════════════════════╝")
