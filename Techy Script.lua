-- // TECHY ULTIMATE SCRIPT v2.0 (Delta Mobile Optimized) // --
-- // Modern UI, Tabbed, Touch-Friendly, Fully Functional // --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // НАСТРОЙКИ (SETTINGS) // --
local Config = {
    -- Aimbot
    AimbotEnabled = false,
    AimbotFOV = 150,
    AimbotSmooth = 5,
    AimbotTeamCheck = true,
    AimbotWallCheck = true,
    AimbotPart = "Head",
    ShowFOV = true,
    
    -- Visuals
    ESPEnabled = false,
    ESPName = true,
    ESPDistance = true,
    ESPHealth = true,
    
    -- Combat
    Triggerbot = false,
    TriggerDelay = 0.05,
    
    -- Movement
    AutoCrouch = false,
    CrouchSpeed = 0.1,
    
    -- Skins (Local)
    SkinChanger = false,
    WeaponColor = Color3.fromRGB(255, 0, 0),
    WeaponMaterial = Enum.Material.Neon,
    
    -- Menu
    MenuKey = Enum.KeyCode.RightControl,
    MenuOpen = true
}

-- // UI LIBRARY (Custom, Mobile Optimized) // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TechyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Colors
local Colors = {
    BG = Color3.fromRGB(15, 15, 20),
    TopBar = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(0, 200, 255),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(150, 150, 160),
    ElementBG = Color3.fromRGB(30, 30, 40),
    ToggleOn = Color3.fromRGB(0, 220, 100),
    ToggleOff = Color3.fromRGB(60, 60, 70)
}

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 300)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -150)
MainFrame.BackgroundColor3 = Colors.BG
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 40, 50)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Dragging (Fixed for Mobile Touch & Mouse)
local dragging, dragInput, dragStart, startPos
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Colors.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local FixCorner = Instance.new("Frame")
FixCorner.Size = UDim2.new(1, 0, 0, 8)
FixCorner.Position = UDim2.new(0, 0, 1, -8)
FixCorner.BackgroundColor3 = Colors.TopBar
FixCorner.BorderSizePixel = 0
FixCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TECHY ULTIMATE"
Title.TextColor3 = Colors.Text
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
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

-- Tabs Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 90, 1, -35)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundColor3 = Colors.TopBar
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -100, 1, -45)
ContentContainer.Position = UDim2.new(0, 95, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 3
ScrollingFrame.ScrollBarImageColor3 = Colors.Accent
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = ContentContainer

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ScrollingFrame

-- Tab Logic
local currentTab = nil
local function createTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Colors.TopBar
    TabBtn.Text = name
    TabBtn.TextColor3 = Colors.SubText
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabContainer
    
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ScrollingFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabContent
    
    TabBtn.MouseButton1Click:Connect(function()
        if currentTab then currentTab.Content.Visible = false currentTab.Btn.TextColor3 = Colors.SubText end
        TabContent.Visible = true
        TabBtn.TextColor3 = Colors.Accent
        currentTab = {Btn = TabBtn, Content = TabContent}
    end)
    
    return TabContent
end

-- UI Elements
local function createLabel(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.Accent
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createToggle(text, default, parent, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 30)
    Container.BackgroundColor3 = Colors.ElementBG
    Container.BorderSizePixel = 0
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local ToggleBG = Instance.new("Frame")
    ToggleBG.Size = UDim2.new(0, 34, 0, 18)
    ToggleBG.Position = UDim2.new(1, -42, 0.5, -9)
    ToggleBG.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
    ToggleBG.BorderSizePixel = 0
    ToggleBG.Parent = Container
    Instance.new("UICorner", ToggleBG).CornerRadius = UDim.new(1, 0)
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
    ToggleCircle.Position = default and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleBG
    Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    local function toggle()
        state = not state
        TweenService:Create(ToggleBG, TweenInfo.new(0.2), {BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff}):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
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
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = Colors.ElementBG
    Container.BorderSizePixel = 0
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 4)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Colors.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -20, 0, 6)
    SliderBG.Position = UDim2.new(0, 10, 1, -14)
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Container
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Colors.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function update(input)
        local relX = math.clamp(input.Position.X - SliderBG.AbsolutePosition.X, 0, SliderBG.AbsoluteSize.X)
        local val = math.floor(min + (relX / SliderBG.AbsoluteSize.X) * (max - min))
        SliderFill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        Label.Text = text .. ": " .. val
        callback(val)
    end
    
    SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- // ПОСТРОЕНИЕ МЕНЮ // --
local Tab1 = createTab("Combat")
local Tab2 = createTab("Visuals")
local Tab3 = createTab("Movement")
local Tab4 = createTab("Skins")
local Tab5 = createTab("Settings")

-- Tab 1: Combat
createLabel("--- AIMBOT ---", Tab1)
createToggle("Enable Aimbot", Config.AimbotEnabled, Tab1, function(v) Config.AimbotEnabled = v end)
createToggle("Wall Check", Config.AimbotWallCheck, Tab1, function(v) Config.AimbotWallCheck = v end)
createToggle("Team Check", Config.AimbotTeamCheck, Tab1, function(v) Config.AimbotTeamCheck = v end)
createSlider("FOV Radius", 50, 500, Config.AimbotFOV, Tab1, function(v) Config.AimbotFOV = v if FOVCircle then FOVCircle.Radius = v end end)
createSlider("Smoothness", 1, 20, Config.AimbotSmooth, Tab1, function(v) Config.AimbotSmooth = v end)

createLabel("--- TRIGGERBOT ---", Tab1)
createToggle("Enable Triggerbot", Config.Triggerbot, Tab1, function(v) Config.Triggerbot = v end)

-- Tab 2: Visuals
createLabel("--- ESP ---", Tab2)
createToggle("Enable ESP", Config.ESPEnabled, Tab2, function(v) Config.ESPEnabled = v if not v then clearESP() end end)
createToggle("Show Names", Config.ESPName, Tab2, function(v) Config.ESPName = v end)
createToggle("Show Distance", Config.ESPDistance, Tab2, function(v) Config.ESPDistance = v end)
createToggle("Show Health", Config.ESPHealth, Tab2, function(v) Config.ESPHealth = v end)

createLabel("--- FOV CIRCLE ---", Tab2)
createToggle("Show FOV Circle", Config.ShowFOV, Tab2, function(v) Config.ShowFOV = v if FOVCircle then FOVCircle.Visible = v end end)

-- Tab 3: Movement
createLabel("--- MOVEMENT ---", Tab3)
createToggle("Auto Crouch (Slide)", Config.AutoCrouch, Tab3, function(v) Config.AutoCrouch = v end)

-- Tab 4: Skins
createLabel("--- LOCAL SKIN CHANGER ---", Tab4)
createToggle("Enable Skin Changer", Config.SkinChanger, Tab4, function(v) Config.SkinChanger = v applySkins() end)
-- Note: Color picker is hard in raw lua, using a simple toggle for neon material as a demo
createToggle("Neon Material", false, Tab4, function(v) Config.WeaponMaterial = v and Enum.Material.Neon or Enum.Material.SmoothPlastic applySkins() end)

-- Tab 5: Settings
createLabel("--- MENU ---", Tab5)
createLabel("Drag top bar to move", Tab5)
createLabel("Script by: Techy Ultimate", Tab5)

-- Auto-select first tab
TabContainer:FindFirstChildWhichIsA("TextButton").MouseButton1Click:Connect(function() end) -- Just to trigger
local firstBtn = TabContainer:FindFirstChildWhichIsA("TextButton")
if firstBtn then firstBtn.MouseButton1Click:Connect(function() firstBtn.TextColor3 = Colors.Accent end) firstBtn.TextColor3 = Colors.Accent end
local firstContent = ScrollingFrame:FindFirstChildWhichIsA("Frame")
if firstContent then firstContent.Visible = true end


-- // GAME LOGIC (WORKING FUNCTIONS) // --

-- 1. FOV Circle (Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 50
FOVCircle.Radius = Config.AimbotFOV
FOVCircle.Filled = false
FOVCircle.Color = Colors.Accent
FOVCircle.Visible = Config.ShowFOV
FOVCircle.Transparency = 0.8

-- 2. ESP Logic
local espObjects = {}
local function clearESP()
    for p, objs in pairs(espObjects) do
        if objs.Highlight then objs.Highlight:Destroy() end
        if objs.Billboard then objs.Billboard:Destroy() end
    end
    espObjects = {}
end

local function setupESP(player)
    if player == LocalPlayer then return end
    local function onCharacterAdded(character)
        if espObjects[player] then
            if espObjects[player].Highlight then espObjects[player].Highlight:Destroy() end
            if espObjects[player].Billboard then espObjects[player].Billboard:Destroy() end
        end
        
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.7
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = character
        
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 100, 0, 40)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Parent = character:WaitForChild("Head")
        
        local txt = Instance.new("TextLabel")
        txt.BackgroundTransparency = 1
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.Parent = bb
        
        espObjects[player] = {Highlight = hl, Billboard = bb, Text = txt, Character = character}
        
        RunService.Heartbeat:Connect(function()
            if not espObjects[player] or not Config.ESPEnabled then return end
            if not character.Parent then return end
            
            hl.Enabled = Config.ESPEnabled
            bb.Enabled = Config.ESPEnabled
            
            if Config.ESPTeamCheck and player.Team == LocalPlayer.Team then
                hl.FillColor = Color3.fromRGB(0, 255, 0)
                hl.OutlineColor = Color3.fromRGB(0, 255, 0)
            else
                hl.FillColor = Color3.fromRGB(255, 50, 50)
                hl.OutlineColor = Color3.fromRGB(255, 50, 50)
            end
            
            local dist = math.floor((character.Head.Position - Camera.CFrame.Position).Magnitude)
            local info = ""
            if Config.ESPName then info = info .. player.Name .. "\n" end
            if Config.ESPDistance then info = info .. dist .. "m\n" end
            if Config.ESPHealth and character:FindFirstChild("Humanoid") then
                info = info .. math.floor(character.Humanoid.Health) .. " HP"
            end
            txt.Text = info
        end)
    end
    if player.Character then onCharacterAdded(player.Character) end
    player.CharacterAdded:Connect(onCharacterAdded)
end

for _, p in pairs(Players:GetPlayers()) do setupESP(p) end
Players.PlayerAdded:Connect(setupESP)

-- 3. Aimbot Logic
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
    -- Update FOV Circle
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Visible = Config.ShowFOV and Config.AimbotEnabled
        FOVCircle.Radius = Config.AimbotFOV
    end
    
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
            mouse1click()
        end
    end
    
    -- Auto Crouch (Slide mechanic)
    if Config.AutoCrouch and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 and not hum:IsDescendantOf(game:GetService("Workspace").FallenPartsDestroyHeight) then
            -- Simulating slide/crouch while moving
            if not UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                -- Basic auto crouch logic (depends on game mechanics, this is a generic one)
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Seated)
                task.wait(Config.CrouchSpeed)
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end
end)

-- 4. Skin Changer Logic (Local Visual)
function applySkins()
    if not LocalPlayer.Character then return end
    for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            if Config.SkinChanger then
                for _, desc in pairs(tool.Handle:GetDescendants()) do
                    if desc:IsA("MeshPart") or desc:IsA("Part") then
                        desc.Color = Config.WeaponColor
                        desc.Material = Config.WeaponMaterial
                    end
                end
            else
                -- Reset (basic reset, might need game specific IDs)
                for _, desc in pairs(tool.Handle:GetDescendants()) do
                    if desc:IsA("MeshPart") or desc:IsA("Part") then
                        desc.Material = Enum.Material.SmoothPlastic
                    end
                end
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applySkins()
end)

print("[Techy Ultimate] Script loaded successfully! UI is optimized for Delta Mobile.")
