-- // TECHY ULTIMATE V3 - DELTA MOBILE OPTIMIZED // --
-- // Modern UI, Touch-Friendly, No External Libs // --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // CONFIGURATION // --
local Config = {
    MenuKey = Enum.KeyCode.RightControl, -- Или кнопка на экране
    MenuOpen = true,
    
    -- Combat
    AimbotEnabled = false,
    AimbotFOV = 100,
    AimbotSmooth = 5,
    AimbotTeamCheck = true,
    AimbotWallCheck = false, -- Включать осторожно, может лагать на слабых телефонах
    AimbotPart = "Head",
    
    Triggerbot = false,
    TriggerDelay = 0.05,
    
    -- Visuals
    ESPEnabled = false,
    ESPBox = false,
    ESPName = true,
    ESPDistance = true,
    ESPHealth = true,
    ShowFOVCircle = true,
    
    -- Movement
    AutoCrouch = false,
    BunnyHop = false,
    
    -- Misc
    AntiAFK = false
}

-- // UI LIBRARY (Custom for Mobile) // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TechyUI_V3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Colors
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(0, 200, 255), -- Cyan
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 160),
    ToggleOn = Color3.fromRGB(0, 220, 100),
    ToggleOff = Color3.fromRGB(60, 60, 70),
    Stroke = Color3.fromRGB(50, 50, 60)
}

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 280)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -140)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Theme.Stroke

-- Top Bar (Draggable)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Surface
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TECHY ULTIMATE V3"
Title.TextColor3 = Theme.Accent
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 80, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Theme.Surface
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -90, 1, -50)
ContentArea.Position = UDim2.new(0, 90, 0, 45)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Theme.Accent
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = ContentArea

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollingFrame

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- UI Components
local currentTabContent = nil
local tabButtons = {}

local function createTab(name)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Theme.Surface
    Btn.Text = name
    Btn.TextColor3 = Theme.TextDim
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamSemibold
    Btn.BorderSizePixel = 0
    Btn.Parent = TabContainer
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.BackgroundTransparency = 1
    Content.Visible = false
    Content.Parent = ScrollingFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 6)
    Layout.Parent = Content

    Btn.MouseButton1Click:Connect(function()
        -- Reset others
        for _, b in pairs(tabButtons) do
            b.TextColor3 = Theme.TextDim
            b.BackgroundColor3 = Theme.Surface
        end
        if currentTabContent then currentTabContent.Visible = false end
        
        -- Activate this
        Btn.TextColor3 = Theme.Accent
        Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Content.Visible = true
        currentTabContent = Content
    end)
    
    table.insert(tabButtons, Btn)
    return Content
end

local function createLabel(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Accent
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function createToggle(text, default, parent, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundColor3 = Theme.Surface
    Container.BorderSizePixel = 0
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local ToggleBG = Instance.new("Frame")
    ToggleBG.Size = UDim2.new(0, 40, 0, 20)
    ToggleBG.Position = UDim2.new(1, -45, 0.5, -10)
    ToggleBG.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
    ToggleBG.BorderSizePixel = 0
    ToggleBG.Parent = Container
    Instance.new("UICorner", ToggleBG).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = default and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    Circle.BackgroundColor3 = Color3.new(1,1,1)
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBG
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    local function toggle()
        state = not state
        TweenService:Create(ToggleBG, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        callback(state)
    end
    
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggle()
        end
    end)
end

local function createSlider(text, min, max, default, parent, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 45)
    Container.BackgroundColor3 = Theme.Surface
    Container.BorderSizePixel = 0
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Theme.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -20, 0, 8)
    SliderBG.Position = UDim2.new(0, 10, 1, -15)
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Container
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderBG
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local draggingSlider = false
    local function update(input)
        local relX = math.clamp(input.Position.X - SliderBG.AbsolutePosition.X, 0, SliderBG.AbsoluteSize.X)
        local val = math.floor(min + (relX / SliderBG.AbsoluteSize.X) * (max - min))
        Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        Label.Text = text .. ": " .. val
        callback(val)
    end
    
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
end

-- // BUILD MENU // --
local TabCombat = createTab("Combat")
local TabVisuals = createTab("Visuals")
local TabMovement = createTab("Movement")
local TabMisc = createTab("Misc")

-- Combat
createLabel("--- AIMBOT ---", TabCombat)
createToggle("Enable Aimbot", Config.AimbotEnabled, TabCombat, function(v) Config.AimbotEnabled = v end)
createToggle("Team Check", Config.AimbotTeamCheck, TabCombat, function(v) Config.AimbotTeamCheck = v end)
createToggle("Wall Check", Config.AimbotWallCheck, TabCombat, function(v) Config.AimbotWallCheck = v end)
createSlider("FOV Radius", 10, 500, Config.AimbotFOV, TabCombat, function(v) Config.AimbotFOV = v end)
createSlider("Smoothness", 1, 20, Config.AimbotSmooth, TabCombat, function(v) Config.AimbotSmooth = v end)

createLabel("--- TRIGGERBOT ---", TabCombat)
createToggle("Enable Triggerbot", Config.Triggerbot, TabCombat, function(v) Config.Triggerbot = v end)

-- Visuals
createLabel("--- ESP ---", TabVisuals)
createToggle("Enable ESP", Config.ESPEnabled, TabVisuals, function(v) Config.ESPEnabled = v if not v then clearESP() end end)
createToggle("Show Names", Config.ESPName, TabVisuals, function(v) Config.ESPName = v end)
createToggle("Show Distance", Config.ESPDistance, TabVisuals, function(v) Config.ESPDistance = v end)
createToggle("Show Health", Config.ESPHealth, TabVisuals, function(v) Config.ESPHealth = v end)

createLabel("--- OVERLAY ---", TabVisuals)
createToggle("Show FOV Circle", Config.ShowFOVCircle, TabVisuals, function(v) Config.ShowFOVCircle = v updateFOVCircle() end)

-- Movement
createLabel("--- MOVEMENT ---", TabMovement)
createToggle("Auto Crouch", Config.AutoCrouch, TabMovement, function(v) Config.AutoCrouch = v end)
createToggle("Bunny Hop", Config.BunnyHop, TabMovement, function(v) Config.BunnyHop = v end)

-- Misc
createLabel("--- MISC ---", TabMisc)
createToggle("Anti AFK", Config.AntiAFK, TabMisc, function(v) Config.AntiAFK = v end)
createLabel("Techy Ultimate V3", TabMisc)
createLabel("Optimized for Delta Mobile", TabMisc)

-- Select first tab by default
if #tabButtons > 0 then
    tabButtons[1].MouseButton1Click:Connect(function() end) -- Trigger logic
    tabButtons[1].TextColor3 = Theme.Accent
    ScrollingFrame:FindFirstChildWhichIsA("Frame").Visible = true
end

-- // GAME LOGIC // --

-- 1. FOV Circle (GUI Based, works on Mobile)
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVCircle"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.BorderSizePixel = 0
FOVFrame.Size = UDim2.new(0, 0, 0, 0) -- Dynamic
FOVFrame.Parent = ScreenGui

local FOVBorder = Instance.new("UIStroke")
FOVBorder.Color = Theme.Accent
FOVBorder.Thickness = 2
FOVBorder.Transparency = 0.5
FOVBorder.Parent = FOVFrame

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

function updateFOVCircle()
    if Config.ShowFOVCircle and Config.AimbotEnabled then
        FOVFrame.Visible = true
        local diameter = Config.AimbotFOV * 2
        FOVFrame.Size = UDim2.new(0, diameter, 0, diameter)
        FOVFrame.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
    else
        FOVFrame.Visible = false
    end
end

-- Update FOV position every frame
RunService.RenderStepped:Connect(function()
    if FOVFrame.Visible then
        FOVFrame.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
    end
end)

-- 2. ESP System (Native Highlight)
local espCache = {}

function clearESP()
    for _, obj in pairs(espCache) do
        if obj.Highlight then obj.Highlight:Destroy() end
        if obj.Billboard then obj.Billboard:Destroy() end
    end
    espCache = {}
end

function setupESP(player)
    if player == LocalPlayer then return end
    
    local function onCharAdded(char)
        if espCache[player] then
            if espCache[player].Highlight then espCache[player].Highlight:Destroy() end
            if espCache[player].Billboard then espCache[player].Billboard:Destroy() end
        end
        
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.8
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 120, 0, 40)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Parent = char:WaitForChild("Head")
        
        local txt = Instance.new("TextLabel")
        txt.BackgroundTransparency = 1
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.TextColor3 = Color3.new(1,1,1)
        txt.TextStrokeTransparency = 0.5
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.Parent = bb
        
        espCache[player] = {Highlight = hl, Billboard = bb, Text = txt, Char = char}
        
        -- Update Loop for this player
        RunService.Heartbeat:Connect(function()
            if not Config.ESPEnabled or not espCache[player] then return end
            if not char.Parent then return end
            
            hl.Enabled = Config.ESPEnabled
            bb.Enabled = Config.ESPEnabled
            
            -- Color logic
            if Config.AimbotTeamCheck and player.Team == LocalPlayer.Team then
                hl.FillColor = Color3.fromRGB(0, 255, 0)
                hl.OutlineColor = Color3.fromRGB(0, 255, 0)
            else
                hl.FillColor = Color3.fromRGB(255, 50, 50)
                hl.OutlineColor = Color3.fromRGB(255, 50, 50)
            end
            
            -- Text Logic
            local dist = math.floor((char.Head.Position - Camera.CFrame.Position).Magnitude)
            local info = ""
            if Config.ESPName then info = player.Name end
            if Config.ESPDistance then info = info .. " [" .. dist .. "m]" end
            if Config.ESPHealth and char:FindFirstChild("Humanoid") then
                info = info .. " HP:" .. math.floor(char.Humanoid.Health)
            end
            txt.Text = info
        end)
    end
    
    if player.Character then onCharAdded(player.Character) end
    player.CharacterAdded:Connect(onCharAdded)
end

for _, p in pairs(Players:GetPlayers()) do setupESP(p) end
Players.PlayerAdded:Connect(setupESP)

-- 3. Aimbot & Triggerbot
local function getClosestPlayer()
    local closest = nil
    local minDist = Config.AimbotFOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Config.AimbotTeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local part = player.Character:FindFirstChild(Config.AimbotPart) or player.Character:FindFirstChild("Head")
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (mousePos - targetPos).Magnitude
                    
                    if dist < minDist then
                        if Config.AimbotWallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                            local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
                            if hit and hit:IsDescendantOf(player.Character) then
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
    return closest
end

RunService.RenderStepped:Connect(function()
    updateFOVCircle()
    
    -- Aimbot
    if Config.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local target = getClosestPlayer()
        if target then
            local part = target.Character:FindFirstChild(Config.AimbotPart) or target.Character:FindFirstChild("Head")
            if part then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / Config.AimbotSmooth)
            end
        end
    end
    
    -- Triggerbot
    if Config.Triggerbot then
        local target = getClosestPlayer()
        if target then
            task.wait(Config.TriggerDelay)
            fireclickdetector(LocalPlayer:GetMouse().Hit) -- Более надежный метод для мобильных
            -- Или mouse1click() если fireclickdetector не сработает
        end
    end
    
    -- Auto Crouch
    if Config.AutoCrouch and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
             hum:ChangeState(Enum.HumanoidStateType.Seated)
             task.wait(0.1)
             hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
    
    -- Bunny Hop
    if Config.BunnyHop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.FloorMaterial ~= Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum.Jump = true
        end
    end
end)

-- Anti AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
   if Config.AntiAFK then
      vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
      wait(1)
      vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   end
end)

print("[Techy Ultimate V3] Loaded successfully for Delta Mobile!")
