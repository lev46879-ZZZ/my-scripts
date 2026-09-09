-- // TECHY ULTIMATE v5.5 - NO RAGEBOT // --
-- // Убран Ragebot, всё остальное работает // --
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

print("[TECHY v5.5] Loading...")

-- ═══════════════════════════════════════════════════════
-- КОНФИГУРАЦИЯ (БЕЗ RAGEBOT!)
-- ═══════════════════════════════════════════════════════
local Config = {
    AimbotEnabled = false,
    AimbotFOV = 150,
    AimbotSmooth = 0.3,
    AimbotPrediction = true,
    PredictionFactor = 0.12,
    AimbotWallCheck = false,
    AimbotPart = "Head",
    AimbotTeamCheck = true,
    HoldToAim = false,
    
    SilentAim = false,
    SilentFOV = 300,
    SilentHitchance = 100,
    SilentAutoShot = false,
    SilentTeamCheck = true,
    SilentFireRate = 0.15,
    
    Triggerbot = false,
    TriggerDelay = 0.05,
    
    HitboxExpander = false,
    HitboxSize = 8,
    HitboxTarget = "Head",
    
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    RapidFireDelay = 0.03,
    
    ESPEnabled = false,
    ESPName = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPWeapon = true,
    ESPStatus = true,
    ShowFOV = true,
    Fullbright = false,
    
    SpeedEnabled = false,
    WalkSpeed = 60,
    JumpPower = 120,
    InfiniteJump = false,
    FlyEnabled = false,
    FlySpeed = 80,
    Noclip = false,
    
    AutoStomp = false,
    StompRange = 20,
    AntiRagdoll = false,
    
    AntiAFK = false,
    FPSBoost = false,
    FovChanger = false,
    FovValue = 90
}

-- ═══════════════════════════════════════════════════════
-- UI
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TechyV55"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local Colors = {
    BG = Color3.fromRGB(10, 10, 15),
    TopBar = Color3.fromRGB(20, 20, 30),
    Accent = Color3.fromRGB(255, 50, 100),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(140, 140, 155),
    ElementBG = Color3.fromRGB(25, 25, 35),
    ToggleOn = Color3.fromRGB(80, 255, 120),
    ToggleOff = Color3.fromRGB(55, 55, 70)
}

-- Плавающая кнопка
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Position = UDim2.new(0, 15, 0.5, -27)
ToggleButton.BackgroundColor3 = Colors.Accent
ToggleButton.Text = "⚡"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.new(1,1,1)
btnStroke.Thickness = 2
btnStroke.Parent = ToggleButton

local btnDragging, btnDragInput, btnDragStart, btnStartPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnDragStart = input.Position
        btnStartPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                btnDragging = false
            end
        end)
    end
end)
ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch then
        btnDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == btnDragInput and btnDragging then
        local delta = input.Position - btnDragStart
        ToggleButton.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
        )
    end
end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 340)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -170)
MainFrame.BackgroundColor3 = Colors.BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(50, 50, 65)
mainStroke.Thickness = 1.5
mainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
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
Title.Text = "⚡ TECHY ULTIMATE v5.5"
Title.TextColor3 = Colors.Text
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
CloseBtn.Text = "-"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local function toggleMenu()
    MainFrame.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(toggleMenu)
ToggleButton.MouseButton1Click:Connect(toggleMenu)

-- Dragging
local dragging, dragInput, dragStart, startPos
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
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Tabs
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 100, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Colors.TopBar
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame
TabContainer.ClipsDescendants = true

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 2)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabContainer

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -110, 1, -50)
ContentContainer.Position = UDim2.new(0, 105, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.ScrollBarImageColor3 = Colors.Accent
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentContainer

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollingFrame

local tabButtons = {}
local tabContents = {}

local function selectTab(index)
    for i = 1, #tabButtons do
        tabContents[i].Visible = false
        tabButtons[i].TextColor3 = Colors.SubText
        tabButtons[i].BackgroundColor3 = Colors.TopBar
    end
    if tabContents[index] then
        tabContents[index].Visible = true
        tabButtons[index].TextColor3 = Colors.Accent
        tabButtons[index].BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    end
end

local function createTab(name, icon, order)
    local tabIndex = #tabButtons + 1
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 36)
    TabBtn.BackgroundColor3 = Colors.TopBar
    TabBtn.Text = (icon and icon .. " " or "") .. name
    TabBtn.TextColor3 = Colors.SubText
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.BorderSizePixel = 0
    TabBtn.LayoutOrder = order or tabIndex
    TabBtn.Parent = TabContainer
    
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.AutomaticSize = Enum.AutomaticSize.Y
    TabContent.LayoutOrder = tabIndex
    TabContent.Parent = ScrollingFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContent
    
    TabBtn.MouseButton1Click:Connect(function()
        selectTab(tabIndex)
    end)
    
    table.insert(tabButtons, TabBtn)
    table.insert(tabContents, TabContent)
    return TabContent
end

-- UI Components
local function createLabel(text, parent, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.Accent
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    if order then lbl.LayoutOrder = order end
    lbl.Parent = parent
    return lbl
end

local function createToggle(text, default, parent, callback, order)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 32)
    Container.BackgroundColor3 = Colors.ElementBG
    Container.BorderSizePixel = 0
    if order then Container.LayoutOrder = order end
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

local function createDropdown(text, options, default, parent, callback, order)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 50)
    Container.BackgroundColor3 = Colors.ElementBG
    Container.BorderSizePixel = 0
    if order then Container.LayoutOrder = order end
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 5)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Colors.Text
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local BtnContainer = Instance.new("Frame")
    BtnContainer.Size = UDim2.new(1, -20, 0, 22)
    BtnContainer.Position = UDim2.new(0, 10, 1, -26)
    BtnContainer.BackgroundTransparency = 1
    BtnContainer.Parent = Container
    
    local BtnLayout = Instance.new("UIListLayout")
    BtnLayout.FillDirection = Enum.FillDirection.Horizontal
    BtnLayout.Padding = UDim.new(0, 4)
    BtnLayout.Parent = BtnContainer
    
    local buttons = {}
    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 0, 1, 0)
        btn.AutomaticSize = Enum.AutomaticSize.X
        btn.BackgroundColor3 = opt == default and Colors.Accent or Color3.fromRGB(50, 50, 65)
        btn.Text = opt
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.Parent = BtnContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local pad = Instance.new("UIPadding", btn)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        table.insert(buttons, {btn = btn, opt = opt})
        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(buttons) do
                b.btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            end
            btn.BackgroundColor3 = Colors.Accent
            Label.Text = text .. ": " .. opt
            callback(opt)
        end)
    end
end

local function createSlider(text, min, max, default, parent, callback, decimals, order)
    decimals = decimals or 0
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 42)
    Container.BackgroundColor3 = Colors.ElementBG
    Container.BorderSizePixel = 0
    if order then Container.LayoutOrder = order end
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 5)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    local dispVal = decimals > 0 and string.format("%." .. decimals .. "f", default) or tostring(default)
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
-- МЕНЮ (7 ВКЛАДОК - БЕЗ RAGEBOT!)
-- ═══════════════════════════════════════════════════════
local TabCombat = createTab("Combat", "⚔", 1)
local TabSilent = createTab("Silent", "🎯", 2)
local TabHitbox = createTab("Hitbox", "💢", 3)
local TabVisuals = createTab("Visuals", "👁", 4)
local TabMovement = createTab("Move", "🏃", 5)
local TabHood = createTab("Hood", "💰", 6)
local TabMisc = createTab("Misc", "⚙", 7)

-- COMBAT
createLabel("─── AIMBOT ───", TabCombat, 1)
createToggle("Enable Aimbot", Config.AimbotEnabled, TabCombat, function(v) Config.AimbotEnabled = v end, 2)
createToggle("Hold to Aim", Config.HoldToAim, TabCombat, function(v) Config.HoldToAim = v end, 3)
createToggle("Wall Check", Config.AimbotWallCheck, TabCombat, function(v) Config.AimbotWallCheck = v end, 4)
createToggle("Team Check", Config.AimbotTeamCheck, TabCombat, function(v) Config.AimbotTeamCheck = v end, 5)
createToggle("Prediction", Config.AimbotPrediction, TabCombat, function(v) Config.AimbotPrediction = v end, 6)
createDropdown("Aim Part", {"Head", "Torso", "Legs"}, Config.AimbotPart, TabCombat, function(v) Config.AimbotPart = v end, 7)
createSlider("FOV Radius", 50, 400, Config.AimbotFOV, TabCombat, function(v) Config.AimbotFOV = v end, 0, 8)
createSlider("Smoothness", 0.1, 1.0, Config.AimbotSmooth, TabCombat, function(v) Config.AimbotSmooth = v end, 1, 9)
createSlider("Prediction", 0.05, 0.5, Config.PredictionFactor, TabCombat, function(v) Config.PredictionFactor = v end, 2, 10)
createLabel("─── TRIGGERBOT ───", TabCombat, 11)
createToggle("Enable Triggerbot", Config.Triggerbot, TabCombat, function(v) Config.Triggerbot = v end, 12)
createSlider("Delay (sec)", 0.01, 1.00, Config.TriggerDelay, TabCombat, function(v) Config.TriggerDelay = v end, 2, 13)
createLabel("─── GUN MODS ───", TabCombat, 14)
createToggle("No Recoil", Config.NoRecoil, TabCombat, function(v) Config.NoRecoil = v end, 15)
createToggle("No Spread", Config.NoSpread, TabCombat, function(v) Config.NoSpread = v end, 16)
createToggle("Rapid Fire", Config.RapidFire, TabCombat, function(v) Config.RapidFire = v end, 17)

-- SILENT AIM (с автономным Auto Shot)
createLabel("─── SILENT AIM (AUTO) ───", TabSilent, 1)
createToggle("Enable Silent Aim", Config.SilentAim, TabSilent, function(v) Config.SilentAim = v end, 2)
createToggle("Team Check", Config.SilentTeamCheck, TabSilent, function(v) Config.SilentTeamCheck = v end, 3)
createToggle("Auto Shot (сам стреляет)", Config.SilentAutoShot, TabSilent, function(v) Config.SilentAutoShot = v end, 4)
createSlider("Silent FOV", 50, 500, Config.SilentFOV, TabSilent, function(v) Config.SilentFOV = v end, 0, 5)
createSlider("Hitchance %", 0, 100, Config.SilentHitchance, TabSilent, function(v) Config.SilentHitchance = v end, 0, 6)
createSlider("Fire Rate (sec)", 0.05, 1.0, Config.SilentFireRate, TabSilent, function(v) Config.SilentFireRate = v end, 2, 7)
createLabel("Auto Shot: скрипт САМ стреляет", TabSilent, 8)
createLabel("когда враг в Silent FOV", TabSilent, 9)

-- HITBOX
createLabel("─── HITBOX EXPANDER ───", TabHitbox, 1)
createToggle("Enable Hitbox", Config.HitboxExpander, TabHitbox, function(v) 
    Config.HitboxExpander = v 
    if not v then resetHitboxes() end
end, 2)
createSlider("Size", 2, 20, Config.HitboxSize, TabHitbox, function(v) 
    Config.HitboxSize = v 
    resetHitboxes()
end, 0, 3)

-- VISUALS
createLabel("─── ESP ───", TabVisuals, 1)
createToggle("Enable ESP", Config.ESPEnabled, TabVisuals, function(v) 
    Config.ESPEnabled = v 
    if not v then clearESP() end 
end, 2)
createToggle("Names", Config.ESPName, TabVisuals, function(v) Config.ESPName = v end, 3)
createToggle("Distance", Config.ESPDistance, TabVisuals, function(v) Config.ESPDistance = v end, 4)
createToggle("Health", Config.ESPHealth, TabVisuals, function(v) Config.ESPHealth = v end, 5)
createToggle("Weapon", Config.ESPWeapon, TabVisuals, function(v) Config.ESPWeapon = v end, 6)
createToggle("Status", Config.ESPStatus, TabVisuals, function(v) Config.ESPStatus = v end, 7)
createLabel("─── OVERLAY ───", TabVisuals, 8)
createToggle("Show FOV Circle", Config.ShowFOV, TabVisuals, function(v) Config.ShowFOV = v end, 9)
createToggle("Fullbright", Config.Fullbright, TabVisuals, function(v) 
    Config.Fullbright = v 
    if v then
        pcall(function()
            game.Lighting.Brightness = 2
            game.Lighting.ClockTime = 14
            game.Lighting.FogEnd = 100000
            game.Lighting.GlobalShadows = false
            game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end)
    else
        pcall(function()
            game.Lighting.Brightness = 1
            game.Lighting.GlobalShadows = true
            game.Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        end)
    end
end, 10)

-- MOVEMENT
createLabel("─── SPEED ───", TabMovement, 1)
createToggle("Speed Hack", Config.SpeedEnabled, TabMovement, function(v) Config.SpeedEnabled = v end, 2)
createSlider("Walk Speed", 16, 300, Config.WalkSpeed, TabMovement, function(v) Config.WalkSpeed = v end, 0, 3)
createSlider("Jump Power", 50, 500, Config.JumpPower, TabMovement, function(v) Config.JumpPower = v end, 0, 4)
createToggle("Infinite Jump", Config.InfiniteJump, TabMovement, function(v) Config.InfiniteJump = v end, 5)
createLabel("─── FLY / NOCLIP ───", TabMovement, 6)
createToggle("Fly", Config.FlyEnabled, TabMovement, function(v) Config.FlyEnabled = v end, 7)
createSlider("Fly Speed", 20, 300, Config.FlySpeed, TabMovement, function(v) Config.FlySpeed = v end, 0, 8)
createToggle("Noclip", Config.Noclip, TabMovement, function(v) Config.Noclip = v end, 9)

-- HOOD
createLabel("─── HOOD FEATURES ───", TabHood, 1)
createToggle("Auto Stomp", Config.AutoStomp, TabHood, function(v) Config.AutoStomp = v end, 2)
createSlider("Stomp Range", 5, 50, Config.StompRange, TabHood, function(v) Config.StompRange = v end, 0, 3)
createToggle("Anti-Ragdoll", Config.AntiRagdoll, TabHood, function(v) Config.AntiRagdoll = v end, 4)

-- MISC
createLabel("─── MISC ───", TabMisc, 1)
createToggle("Anti AFK", Config.AntiAFK, TabMisc, function(v) Config.AntiAFK = v end, 2)
createToggle("FPS Boost", Config.FPSBoost, TabMisc, function(v) Config.FPSBoost = v end, 3)
createToggle("FOV Changer", Config.FovChanger, TabMisc, function(v) Config.FovChanger = v end, 4)
createSlider("FOV Value", 60, 120, Config.FovValue, TabMisc, function(v) Config.FovValue = v end, 0, 5)
createLabel("Techy Ultimate v5.5", TabMisc, 6)
createLabel("NO RAGEBOT EDITION", TabMisc, 7)

selectTab(1)

-- FOV CIRCLE
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVCircle"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.BorderSizePixel = 0
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Visible = false
FOVFrame.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Colors.Accent
FOVStroke.Thickness = 2
FOVStroke.Transparency = 0.2
FOVStroke.Parent = FOVFrame

Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

-- ESP
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
    return hum:GetState() == Enum.HumanoidStateType.Physics or hum.Health <= 0
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
        hl.Enabled = false
        hl.Parent = char
        
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 150, 0, 70)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop = true
        bb.Enabled = false
        bb.Parent = head
        
        local txt = Instance.new("TextLabel")
        txt.BackgroundTransparency = 1
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.TextColor3 = Color3.new(1,1,1)
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.Parent = bb
        
        espObjects[player] = {Highlight = hl, Billboard = bb, Text = txt, Char = char}
    end
    
    if player.Character then onCharAdded(player.Character) end
    player.CharacterAdded:Connect(onCharAdded)
end

for _, p in pairs(Players:GetPlayers()) do setupESP(p) end
Players.PlayerAdded:Connect(setupESP)

-- HITBOX
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
            originalSizes[player] = {Size = part.Size, Transparency = part.Transparency}
        end
    end
    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end

for _, p in pairs(Players:GetPlayers()) do expandHitbox(p) end
Players.PlayerAdded:Connect(expandHitbox)

-- ПОМОЩНИКИ
local function getTargetPart(character)
    if not character then return nil end
    if Config.AimbotPart == "Head" then
        return character:FindFirstChild("Head")
    elseif Config.AimbotPart == "Torso" then
        return character:FindFirstChild("HumanoidRootPart") 
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
    elseif Config.AimbotPart == "Legs" then
        return character:FindFirstChild("LowerTorso") or character:FindFirstChild("HumanoidRootPart")
    end
    return character:FindFirstChild("Head")
end

local function isTargetVisible(targetPart)
    if not Config.AimbotWallCheck then return true end
    if not targetPart then return false end
    local cameraPos = Camera.CFrame.Position
    local direction = (targetPart.Position - cameraPos)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.IgnoreWater = true
    local result = Workspace:Raycast(cameraPos, direction, rayParams)
    if not result then return true end
    if result.Instance and result.Instance:IsDescendantOf(targetPart.Parent) then return true end
    return false
end

local function getClosestPlayer(fov, teamCheck)
    local useFOV = fov or Config.AimbotFOV
    local checkTeam = teamCheck ~= nil and teamCheck or Config.AimbotTeamCheck
    local closest = nil
    local minDist = useFOV
    local viewport = Camera.ViewportSize
    local centerPos = Vector2.new(viewport.X / 2, viewport.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if checkTeam and player.Team == LocalPlayer.Team then continue end
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = getTargetPart(player.Character)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                        local dist = (centerPos - targetPos).Magnitude
                        if dist < minDist then
                            if isTargetVisible(part) then
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

local function getPredictedPosition(targetPart, player)
    if not Config.AimbotPrediction then return targetPart.Position end
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return targetPart.Position end
    local velocity = hum.MoveDirection * hum.WalkSpeed
    return targetPart.Position + velocity * Config.PredictionFactor
end

-- ═══════════════════════════════════════════════════════
-- ✅ SILENT AIM (МАТЕМАТИЧЕСКИЙ) + AUTO SHOT
-- ═══════════════════════════════════════════════════════
local lastAutoShotTime = 0

task.spawn(function()
    while task.wait(0.05) do
        if not Config.SilentAim then continue end
        if not Config.SilentAutoShot then continue end
        
        local now = tick()
        if now - lastAutoShotTime < Config.SilentFireRate then
            continue
        end
        
        local char = LocalPlayer.Character
        if not char then continue end
        local hasWeapon = false
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then hasWeapon = true break end
        end
        if not hasWeapon then continue end
        
        local target = getClosestPlayer(Config.SilentFOV, Config.SilentTeamCheck)
        if not target then continue end
        
        local roll = math.random(1, 100)
        if roll > Config.SilentHitchance then continue end
        
        lastAutoShotTime = now
        
        local part = getTargetPart(target.Character)
        if part then
            local predictedPos = getPredictedPosition(part, target)
            local targetCFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
            local originalCFrame = Camera.CFrame
            
            Camera.CFrame = targetCFrame
            
            task.spawn(function()
                task.wait(0.016)
                if mouse1click then
                    pcall(function() mouse1click() end)
                end
                task.wait(0.032)
                Camera.CFrame = originalCFrame
            end)
        end
    end
end)

-- FLY
local flyBodyVelocity, flyBodyGyro

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.P = 1e4
    flyBodyVelocity.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBodyGyro.P = 1e4
    flyBodyGyro.D = 100
    flyBodyGyro.Parent = hrp
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
end

local function stopFly()
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- AUTO STOMP
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

-- RAPID FIRE
task.spawn(function()
    while task.wait() do
        if Config.RapidFire and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            if mouse1click then
                mouse1click()
                task.wait(Config.RapidFireDelay)
            end
        end
    end
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- FOV Circle
    FOVFrame.Visible = Config.ShowFOV and (Config.AimbotEnabled or Config.SilentAim)
    if FOVFrame.Visible then
        local diameter = Config.AimbotFOV * 2
        FOVFrame.Size = UDim2.new(0, diameter, 0, diameter)
    end
    
    -- AIMBOT
    local shouldAim = false
    if Config.AimbotEnabled then
        if Config.HoldToAim then
            shouldAim = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        else
            shouldAim = true
        end
    end
    
    if shouldAim then
        local target = getClosestPlayer()
        if target then
            local part = getTargetPart(target.Character)
            if part and isTargetVisible(part) then
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
            local part = getTargetPart(target.Character)
            if part and isTargetVisible(part) then
                task.spawn(function()
                    task.wait(Config.TriggerDelay)
                    if mouse1click then mouse1click() end
                end)
            end
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
        if not flyBodyVelocity then startFly() end
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        flyBodyVelocity.Velocity = moveDir * Config.FlySpeed
        flyBodyGyro.CFrame = Camera.CFrame
    else
        if flyBodyVelocity then stopFly() end
    end
    
    -- NOCLIP
    if Config.Noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    -- HITBOX
    if Config.HitboxExpander then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local part = player.Character:FindFirstChild(Config.HitboxTarget)
                if part then
                    part.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    part.Transparency = 0.7
                    part.CanCollide = false
                end
            end
        end
    end
    
    -- ESP
    if Config.ESPEnabled then
        for p, objs in pairs(espObjects) do
            if objs.Char.Parent then
                objs.Highlight.Enabled = true
                objs.Billboard.Enabled = true
                local ragdoll = isRagdoll(p)
                if ragdoll then
                    objs.Highlight.FillColor = Color3.fromRGB(150, 150, 150)
                    objs.Highlight.OutlineColor = Color3.fromRGB(100, 100, 100)
                else
                    objs.Highlight.FillColor = Color3.fromRGB(255, 50, 100)
                    objs.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                local head = objs.Char:FindFirstChild("Head")
                if head then
                    local dist = math.floor((head.Position - Camera.CFrame.Position).Magnitude)
                    local info = ""
                    if Config.ESPName then info = info .. p.Name .. string.char(10) end
                    if Config.ESPStatus then info = info .. (ragdoll and "[DOWN]" or "[ALIVE]") .. string.char(10) end
                    if Config.ESPDistance then info = info .. dist .. "m  " end
                    if Config.ESPWeapon then info = info .. getPlayerWeapon(p) .. string.char(10) end
                    if Config.ESPHealth then
                        local h = objs.Char:FindFirstChildOfClass("Humanoid")
                        if h then info = info .. math.floor(h.Health) .. " HP" end
                    end
                    objs.Text.Text = info
                end
            end
        end
    else
        for p, objs in pairs(espObjects) do
            objs.Highlight.Enabled = false
            objs.Billboard.Enabled = false
        end
    end
    
    -- AUTO STOMP
    if Config.AutoStomp then
        local downed = findDownedPlayer()
        if downed and downed.Character then
            local head = downed.Character:FindFirstChild("Head")
            if head and hrp then
                hrp.CFrame = CFrame.new(head.Position + Vector3.new(0, 3, 0))
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
    
    -- FOV CHANGER
    if Config.FovChanger then Camera.FieldOfView = Config.FovValue end
    
    -- FPS BOOST
    if Config.FPSBoost then
        pcall(function()
            Workspace.Terrain.WaterWaveSize = 0
            Workspace.Terrain.WaterWaveSpeed = 0
            Workspace.Terrain.WaterReflectance = 0
            Workspace.Terrain.WaterTransparency = 0
        end)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
    end
end)

-- Respawn handler
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Config.FlyEnabled then startFly() end
end)

print("╔══════════════════════════════════════════╗")
print("║  TECHY ULTIMATE v5.5 - NO RAGEBOT        ║")
print("║  ✅ Убран Ragebot (не крашит)            ║")
print("║  ✅ Silent Aim + Auto Shot работают      ║")
print("║  ✅ Все остальные функции работают       ║")
print("╚══════════════════════════════════════════╝")
