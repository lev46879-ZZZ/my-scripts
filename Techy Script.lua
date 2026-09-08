-- // TECHY ULTIMATE v4.2 - HOOD RIVALS (BUGFIXED) // --
-- // Fixed: Tabs, Aimbot Always-On, FOV 50-400 // --

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
-- КОНФИГУРАЦИЯ (ИСПРАВЛЕНО: FOV 50 по умолчанию)
-- ═══════════════════════════════════════════════════════
local Config = {
    -- COMBAT
    AimbotEnabled = false,
    SilentAim = false,
    AimbotFOV = 50,              -- ✅ По умолчанию 50
    AimbotSmooth = 0.4,
    AimbotPrediction = true,
    PredictionFactor = 0.15,
    AimbotTeamCheck = false,
    AimbotWallCheck = false,
    AimbotPart = "Head",
    HoldToAim = false,           -- ✅ НОВОЕ: если false — aimbot работает ВСЕГДА
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
    ESPStatus = true,
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
    AutoStomp = false,
    StompRange = 15,
    AntiRagdoll = false,
    AutoFarm = false,
    
    -- MISC
    AntiAFK = false,
    FPSBoost = false,
    MenuOpen = true
}

-- ═══════════════════════════════════════════════════════
-- UI SETUP
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TechyHR_V42"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local Colors = {
    BG = Color3.fromRGB(12, 12, 18),
    TopBar = Color3.fromRGB(22, 22, 32),
    Accent = Color3.fromRGB(255, 60, 120),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(140, 140, 155),
    ElementBG = Color3.fromRGB(28, 28, 40),
    ToggleOn = Color3.fromRGB(80, 255, 120),
    ToggleOff = Color3.fromRGB(55, 55, 70)
}

-- ═══════════════════════════════════════════════════════
-- ПЛАВАЮЩАЯ КНОПКА
-- ═══════════════════════════════════════════════════════
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.BackgroundColor3 = Colors.Accent
ToggleButton.Text = "T"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 20
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

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

-- ═══════════════════════════════════════════════════════
-- MAIN FRAME
-- ═══════════════════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 440, 0, 320)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -160)
MainFrame.BackgroundColor3 = Colors.BG
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
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

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
CloseBtn.Text = "−"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local function toggleMenu()
    MainFrame.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(toggleMenu)
ToggleButton.MouseButton1Click:Connect(toggleMenu)

-- Dragging MainFrame
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

-- ═══════════════════════════════════════════════════════
-- ВКЛАДКИ (ИСПРАВЛЕНО: UIListLayout + AutomaticSize)
-- ═══════════════════════════════════════════════════════
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 95, 1, -38)
TabContainer.Position = UDim2.new(0, 0, 0, 38)
TabContainer.BackgroundColor3 = Colors.TopBar
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame
TabContainer.ClipsDescendants = true

-- ✅ ДОБАВЛЕНО: UIListLayout для вертикального списка кнопок
local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 2)
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Parent = TabContainer

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
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = ContentContainer

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollingFrame

-- ✅ ИСПРАВЛЕННАЯ ЛОГИКА ВКЛАДОК
local tabButtons = {}
local tabContents = {}
local currentTabIndex = 0

local function selectTab(index)
    -- Скрыть все
    for i = 1, #tabButtons do
        tabContents[i].Visible = false
        tabButtons[i].TextColor3 = Colors.SubText
        tabButtons[i].BackgroundColor3 = Colors.TopBar
    end
    -- Показать выбранную
    if tabContents[index] then
        tabContents[index].Visible = true
        tabButtons[index].TextColor3 = Colors.Accent
        tabButtons[index].BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        currentTabIndex = index
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
    TabContent.Size = UDim2.new(1, 0, 0, 0)  -- Автоматический размер
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.AutomaticSize = Enum.AutomaticSize.Y  -- ✅ ВАЖНО!
    TabContent.LayoutOrder = tabIndex
    TabContent.Parent = ScrollingFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContent
    
    -- ✅ Клик по кнопке переключает вкладку
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
    lbl.Size = UDim2.new(1, 0, 0, 18)
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
-- ПОСТРОЕНИЕ МЕНЮ (ВСЕ ВКЛАДКИ С ORDER)
-- ═══════════════════════════════════════════════════════
local TabCombat = createTab("Combat", "⚔", 1)
local TabHitbox = createTab("Hitbox", "🎯", 2)
local TabVisuals = createTab("Visuals", "👁", 3)
local TabMovement = createTab("Move", "🏃", 4)
local TabHood = createTab("Hood", "💰", 5)
local TabMisc = createTab("Misc", "⚙", 6)

-- COMBAT TAB (order для элементов)
createLabel("─── AIMBOT ───", TabCombat, 1)
createToggle("Enable Aimbot", Config.AimbotEnabled, TabCombat, function(v) Config.AimbotEnabled = v end, 2)
createToggle("Silent Aim", Config.SilentAim, TabCombat, function(v) Config.SilentAim = v end, 3)
createToggle("Hold to Aim (иначе всегда)", Config.HoldToAim, TabCombat, function(v) Config.HoldToAim = v end, 4)
createToggle("Prediction", Config.AimbotPrediction, TabCombat, function(v) Config.AimbotPrediction = v end, 5)
createToggle("Wall Check", Config.AimbotWallCheck, TabCombat, function(v) Config.AimbotWallCheck = v end, 6)
createSlider("FOV Radius (50-400)", 50, 400, Config.AimbotFOV, TabCombat, function(v) Config.AimbotFOV = v end, 0, 7)
createSlider("Smoothness", 0.1, 1.0, Config.AimbotSmooth, TabCombat, function(v) Config.AimbotSmooth = v end, 1, 8)
createSlider("Prediction", 0.05, 0.5, Config.PredictionFactor, TabCombat, function(v) Config.PredictionFactor = v end, 2, 9)

createLabel("─── TRIGGERBOT ───", TabCombat, 10)
createToggle("Enable Triggerbot", Config.Triggerbot, TabCombat, function(v) Config.Triggerbot = v end, 11)

createLabel("─── GUN MODS ───", TabCombat, 12)
createToggle("No Recoil", Config.NoRecoil, TabCombat, function(v) Config.NoRecoil = v end, 13)
createToggle("No Spread", Config.NoSpread, TabCombat, function(v) Config.NoSpread = v end, 14)
createToggle("Rapid Fire", Config.RapidFire, TabCombat, function(v) Config.RapidFire = v end, 15)

-- HITBOX TAB
createLabel("─── HITBOX EXPANDER ───", TabHitbox, 1)
createToggle("Enable Hitbox", Config.HitboxExpander, TabHitbox, function(v) 
    Config.HitboxExpander = v 
    if not v then resetHitboxes() end
end, 2)
createSlider("Size", 2, 15, Config.HitboxSize, TabHitbox, function(v) 
    Config.HitboxSize = v 
    resetHitboxes()
end, 0, 3)

-- VISUALS TAB
createLabel("─── ESP ───", TabVisuals, 1)
createToggle("Enable ESP", Config.ESPEnabled, TabVisuals, function(v) 
    Config.ESPEnabled = v 
    if not v then clearESP() end 
end, 2)
createToggle("Names", Config.ESPName, TabVisuals, function(v) Config.ESPName = v end, 3)
createToggle("Distance", Config.ESPDistance, TabVisuals, function(v) Config.ESPDistance = v end, 4)
createToggle("Health", Config.ESPHealth, TabVisuals, function(v) Config.ESPHealth = v end, 5)
createToggle("Weapon", Config.ESPWeapon, TabVisuals, function(v) Config.ESPWeapon = v end, 6)
createToggle("Status (Ragdoll)", Config.ESPStatus, TabVisuals, function(v) Config.ESPStatus = v end, 7)

createLabel("─── OVERLAY ───", TabVisuals, 8)
createToggle("Show FOV Circle", Config.ShowFOV, TabVisuals, function(v) Config.ShowFOV = v end, 9)
createToggle("Show Tracers", Config.ShowTracers, TabVisuals, function(v) Config.ShowTracers = v end, 10)

-- MOVEMENT TAB
createLabel("─── SPEED ───", TabMovement, 1)
createToggle("Speed Hack", Config.SpeedEnabled, TabMovement, function(v) Config.SpeedEnabled = v end, 2)
createSlider("Walk Speed", 16, 200, Config.WalkSpeed, TabMovement, function(v) Config.WalkSpeed = v end, 0, 3)
createSlider("Jump Power", 50, 300, Config.JumpPower, TabMovement, function(v) Config.JumpPower = v end, 0, 4)
createToggle("Infinite Jump", Config.InfiniteJump, TabMovement, function(v) Config.InfiniteJump = v end, 5)

createLabel("─── FLY / NOCLIP ───", TabMovement, 6)
createToggle("Fly", Config.FlyEnabled, TabMovement, function(v) Config.FlyEnabled = v end, 7)
createSlider("Fly Speed", 20, 200, Config.FlySpeed, TabMovement, function(v) Config.FlySpeed = v end, 0, 8)
createToggle("Noclip", Config.Noclip, TabMovement, function(v) Config.Noclip = v end, 9)

-- HOOD TAB
createLabel("─── HOOD FEATURES ───", TabHood, 1)
createToggle("Auto Stomp", Config.AutoStomp, TabHood, function(v) Config.AutoStomp = v end, 2)
createSlider("Stomp Range", 5, 30, Config.StompRange, TabHood, function(v) Config.StompRange = v end, 0, 3)
createToggle("Anti-Ragdoll", Config.AntiRagdoll, TabHood, function(v) Config.AntiRagdoll = v end, 4)
createToggle("Auto Farm", Config.AutoFarm, TabHood, function(v) Config.AutoFarm = v end, 5)

-- MISC TAB
createLabel("─── MISC ───", TabMisc, 1)
createToggle("Anti AFK", Config.AntiAFK, TabMisc, function(v) Config.AntiAFK = v end, 2)
createToggle("FPS Boost", Config.FPSBoost, TabMisc, function(v) Config.FPSBoost = v end, 3)
createLabel("Techy Ultimate v4.2", TabMisc, 4)
createLabel("Hood Rivals Edition", TabMisc, 5)

-- ✅ АКТИВАЦИЯ ПЕРВОЙ ВКЛАДКИ
selectTab(1)

-- ═══════════════════════════════════════════════════════
-- FOV CIRCLE (В ЦЕНТРЕ ЭКРАНА)
-- ═══════════════════════════════════════════════════════
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
                        part.Transparency = 0.7
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
-- AIMBOT (ИСПРАВЛЕНО: работает на любом расстоянии, всегда)
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
                        -- ✅ Центр экрана вместо позиции мыши (для мобилок)
                        local viewport = Camera.ViewportSize
                        local centerPos = Vector2.new(viewport.X / 2, viewport.Y / 2)
                        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                        local dist = (centerPos - targetPos).Magnitude
                        
                        if dist < minDist then
                            if Config.AimbotWallCheck then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterDescendantsInstances = {LocalPlayer.Character, player.Character}
                                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                                local ray = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
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

local function getPredictedPosition(targetPart, player)
    if not Config.AimbotPrediction then return targetPart.Position end
    
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return targetPart.Position end
    
    local velocity = hum.MoveDirection * hum.WalkSpeed
    local prediction = targetPart.Position + velocity * Config.PredictionFactor
    return prediction
end

-- Silent Aim Hook
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
                    local newDirection = (predictedPos - self.Origin).Unit * 1000
                    args[1] = Ray.new(self.Origin, newDirection)
                    return oldNamecall(self, unpack(args))
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
local flyBV, flyBodyGyro

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
-- AUTO STOMP
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
    end
    
    -- ✅ AIMBOT: работает ПОСТОЯННО если HoldToAim = false
    -- Или только при зажатии если HoldToAim = true
    local shouldAim = false
    if Config.AimbotEnabled then
        if Config.HoldToAim then
            -- Режим "только при зажатии"
            shouldAim = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        else
            -- ✅ Режим "всегда работает" — для мобилок!
            shouldAim = true
        end
    end
    
    if shouldAim then
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
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
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

print("╔════════════════════════════════════════╗")
print("║  TECHY ULTIMATE v4.2 - BUGFIXED        ║")
print("║  ✅ Вкладки работают                   ║")
print("║  ✅ FOV 50-400                         ║")
print("║  ✅ Aimbot работает всегда             ║")
print("╚════════════════════════════════════════╝")
