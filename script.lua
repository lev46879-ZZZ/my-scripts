--[[
    APEX HUB | Redesigned GUI & Loader V3
    Modern UI, Animated Loader & Fully Working Particle Visuals
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("ApexHubUI_V3") then
    PlayerGui.ApexHubUI_V3:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexHubUI_V3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

---------------------------------------------------------
-- 1. MODERN ANIMATED LOADER
---------------------------------------------------------
local LoaderFrame = Instance.new("Frame")
LoaderFrame.Size = UDim2.new(0, 320, 0, 160)
LoaderFrame.Position = UDim2.new(0.5, -160, 0.5, -80)
LoaderFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
LoaderFrame.BorderSizePixel = 0
LoaderFrame.BackgroundTransparency = 1
LoaderFrame.Parent = ScreenGui

local LoaderCorner = Instance.new("UICorner")
LoaderCorner.CornerRadius = UDim.new(0, 14)
LoaderCorner.Parent = LoaderFrame

local LoaderStroke = Instance.new("UIStroke")
LoaderStroke.Color = Color3.fromRGB(0, 170, 255)
LoaderStroke.Transparency = 1
LoaderStroke.Thickness = 1.5
LoaderStroke.Parent = LoaderFrame

local LoaderTitle = Instance.new("TextLabel")
LoaderTitle.Size = UDim2.new(1, 0, 0, 35)
LoaderTitle.Position = UDim2.new(0, 0, 0.15, 0)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Text = "APEX HUB"
LoaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoaderTitle.TextSize = 24
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextTransparency = 1
LoaderTitle.Parent = LoaderFrame

local LoaderSub = Instance.new("TextLabel")
LoaderSub.Size = UDim2.new(1, 0, 0, 20)
LoaderSub.Position = UDim2.new(0, 0, 0.38, 0)
LoaderSub.BackgroundTransparency = 1
LoaderSub.Text = "Loading Assets..."
LoaderSub.TextColor3 = Color3.fromRGB(0, 170, 255)
LoaderSub.TextSize = 12
LoaderSub.Font = Enum.Font.GothamMedium
LoaderSub.TextTransparency = 1
LoaderSub.Parent = LoaderFrame

local ProgressBarBG = Instance.new("Frame")
ProgressBarBG.Size = UDim2.new(0.85, 0, 0, 6)
ProgressBarBG.Position = UDim2.new(0.075, 0, 0.7, 0)
ProgressBarBG.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
ProgressBarBG.BorderSizePixel = 0
ProgressBarBG.BackgroundTransparency = 1
ProgressBarBG.Parent = LoaderFrame

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 4)
ProgressCorner.Parent = ProgressBarBG

local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.BackgroundTransparency = 1
ProgressBarFill.Parent = ProgressBarBG

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = ProgressBarFill

---------------------------------------------------------
-- 2. MODERN REDESIGNED MAIN FRAME
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 560, 0, 360)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(30, 34, 48)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- TopBar (Draggable)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "APEX HUB <font color=\"#00AAFF\">v3.0</font>"
TitleLabel.RichText = true
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Drag Logic
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- SideBar
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 135, 1, -44)
SideBar.Position = UDim2.new(0, 0, 0, 44)
SideBar.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.Parent = SideBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 10)
TabPadding.PaddingLeft = UDim.new(0, 8)
TabPadding.PaddingRight = UDim.new(0, 8)
TabPadding.Parent = SideBar

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -147, 1, -54)
ContentContainer.Position = UDim2.new(0, 141, 0, 48)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

---------------------------------------------------------
-- 3. OPEN / CLOSE TOGGLE BUTTON
---------------------------------------------------------
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 20, 0.5, -25)
OpenButton.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
OpenButton.BorderSizePixel = 0
OpenButton.Text = ""
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(0, 170, 255)
OpenStroke.Thickness = 1.5
OpenStroke.Parent = OpenButton

local TextApex = Instance.new("TextLabel")
TextApex.Size = UDim2.new(1, 0, 1, 0)
TextApex.BackgroundTransparency = 1
TextApex.Text = "APEX"
TextApex.TextColor3 = Color3.fromRGB(0, 170, 255)
TextApex.TextSize = 13
TextApex.Font = Enum.Font.GothamBold
TextApex.Parent = OpenButton

---------------------------------------------------------
-- TAB CREATION
---------------------------------------------------------
local Tabs = {}
local ContentFrames = {}

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(150, 155, 170)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.Parent = SideBar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn
    
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, 0, 1, 0)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Visible = false
    ContentFrame.ScrollBarThickness = 2
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.Parent = ContentContainer
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, 8)
    ContentList.Parent = ContentFrame

    Tabs[name] = TabBtn
    ContentFrames[name] = ContentFrame
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, btn in pairs(Tabs) do
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(20, 22, 30),
                TextColor3 = Color3.fromRGB(150, 155, 170)
            }):Play()
        end
        for _, frame in pairs(ContentFrames) do
            frame.Visible = false
        end
        
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 170, 255),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        ContentFrame.Visible = true
    end)
    
    return ContentFrame
end

---------------------------------------------------------
-- UI CONTROLS
---------------------------------------------------------
local function CreateToggleWithSettings(parent, text, onToggle)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -6, 0, 38)
    Container.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Container.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Container
    
    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(1, 0, 0, 38)
    MainBtn.BackgroundTransparency = 1
    MainBtn.Text = "   " .. text
    MainBtn.TextColor3 = Color3.fromRGB(210, 215, 225)
    MainBtn.TextSize = 12
    MainBtn.Font = Enum.Font.GothamMedium
    MainBtn.TextXAlignment = Enum.TextXAlignment.Left
    MainBtn.Parent = Container
    
    local StatusDot = Instance.new("Frame")
    StatusDot.Size = UDim2.new(0, 8, 0, 8)
    StatusDot.Position = UDim2.new(1, -20, 0.5, -4)
    StatusDot.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
    StatusDot.BorderSizePixel = 0
    StatusDot.Parent = MainBtn
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = StatusDot
    
    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Size = UDim2.new(1, 0, 0, 90)
    SettingsFrame.Position = UDim2.new(0, 0, 0, 38)
    SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.Parent = Container
    
    local SettingsList = Instance.new("UIListLayout")
    SettingsList.SortOrder = Enum.SortOrder.LayoutOrder
    SettingsList.Padding = UDim.new(0, 4)
    SettingsList.Parent = SettingsFrame
    
    local enabled = false
    MainBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        StatusDot.BackgroundColor3 = enabled and Color3.fromRGB(50, 255, 130) or Color3.fromRGB(255, 65, 65)
        
        local targetSize = enabled and UDim2.new(1, -6, 0, 130) or UDim2.new(1, -6, 0, 38)
        TweenService:Create(Container, TweenInfo.new(0.25), {Size = targetSize}):Play()
        
        onToggle(enabled)
    end)
    
    return SettingsFrame
end

local function CreateOptionSelector(parent, labelText, options, defaultIndex, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -16, 0, 26)
    Frame.Position = UDim2.new(0, 8, 0, 0)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(150, 155, 165)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.45, 0, 0.85, 0)
    Btn.Position = UDim2.new(0.5, 0, 0.07, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
    Btn.BorderSizePixel = 0
    Btn.Text = options[defaultIndex]
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamMedium
    Btn.Parent = Frame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn
    
    local currentIndex = defaultIndex
    Btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        Btn.Text = options[currentIndex]
        callback(options[currentIndex])
    end)
end

---------------------------------------------------------
-- 4. WORKING VISUALS ENGINE (AURA & WINGS)
---------------------------------------------------------
local VisualsTab = CreateTab("Visuals")
local WorldTab = CreateTab("World")

local AuraEnabled, WingsEnabled = false, false
local AuraAttachment, WingsAttachment
local AuraColor = Color3.fromRGB(0, 170, 255)
local WingsColor = Color3.fromRGB(0, 255, 255)
local WingsType = "Angel"

local function BuildEmitter(parent, color, rate, speed, size)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://243661138"
    emitter.Color = ColorSequence.new(color)
    emitter.Size = size or NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)})
    emitter.Rate = rate or 50
    emitter.Lifetime = NumberRange.new(0.8, 1.2)
    emitter.Speed = speed or NumberRange.new(1, 3)
    emitter.LightEmission = 0.9
    emitter.Parent = parent
    return emitter
end

local function ApplyAura()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    
    if AuraAttachment then AuraAttachment:Destroy() end
    if AuraEnabled and hrp then
        AuraAttachment = Instance.new("Attachment")
        AuraAttachment.Name = "ApexAura"
        AuraAttachment.Position = Vector3.new(0, -2.5, 0)
        AuraAttachment.Parent = hrp
        
        BuildEmitter(AuraAttachment, AuraColor, 60, NumberRange.new(2, 4))
    end
end

local function ApplyWings()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local torso = char:WaitForChild("UpperTorso", 5) or char:WaitForChild("Torso", 5)
    
    if WingsAttachment then WingsAttachment:Destroy() end
    if WingsEnabled and torso then
        WingsAttachment = Instance.new("Attachment")
        WingsAttachment.Name = "ApexWings"
        WingsAttachment.Position = Vector3.new(0, 0.5, 0.5)
        WingsAttachment.Parent = torso
        
        local size = WingsType == "Angel" and NumberSequence.new({NumberSequenceKeypoint.new(0, 3.5), NumberSequenceKeypoint.new(1, 0.5)}) 
                     or NumberSequence.new({NumberSequenceKeypoint.new(0, 2.5), NumberSequenceKeypoint.new(1, 0.1)})
        
        BuildEmitter(WingsAttachment, WingsColor, 45, NumberRange.new(0.5, 1.5), size)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if AuraEnabled then ApplyAura() end
    if WingsEnabled then ApplyWings() end
end)

-- Visual Toggles
local AuraSettings = CreateToggleWithSettings(VisualsTab, "Aura Visual", function(enabled)
    AuraEnabled = enabled
    ApplyAura()
end)

CreateOptionSelector(AuraSettings, "Aura Color:", {"Blue", "Red", "Green", "Purple", "White"}, 1, function(selected)
    local colors = {
        ["Blue"] = Color3.fromRGB(0, 170, 255),
        ["Red"] = Color3.fromRGB(255, 50, 50),
        ["Green"] = Color3.fromRGB(50, 255, 100),
        ["Purple"] = Color3.fromRGB(170, 50, 255),
        ["White"] = Color3.fromRGB(255, 255, 255)
    }
    AuraColor = colors[selected]
    ApplyAura()
end)

local WingsSettings = CreateToggleWithSettings(VisualsTab, "Wings Effect", function(enabled)
    WingsEnabled = enabled
    ApplyWings()
end)

CreateOptionSelector(WingsSettings, "Wing Style:", {"Angel", "Demon"}, 1, function(selected)
    WingsType = selected
    ApplyWings()
end)

CreateOptionSelector(WingsSettings, "Wings Color:", {"Cyan", "Red", "Purple", "Gold"}, 1, function(selected)
    local colors = {
        ["Cyan"] = Color3.fromRGB(0, 255, 255),
        ["Red"] = Color3.fromRGB(255, 50, 50),
        ["Purple"] = Color3.fromRGB(160, 50, 255),
        ["Gold"] = Color3.fromRGB(255, 200, 40)
    }
    WingsColor = colors[selected]
    ApplyWings()
end)

-- World
CreateToggleWithSettings(WorldTab, "Fullbright", function(enabled)
    Lighting.Brightness = enabled and 3 or 1
    Lighting.ClockTime = enabled and 14 or 12
    Lighting.GlobalShadows = not enabled
end)

---------------------------------------------------------
-- 5. OPEN / CLOSE LOGIC
---------------------------------------------------------
local menuOpen = false

local function ToggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 560, 0, 360),
            Position = UDim2.new(0.5, -280, 0.5, -180)
        }):Play()
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            if not menuOpen then MainFrame.Visible = false end
        end)
    end
end

OpenButton.MouseButton1Click:Connect(ToggleMenu)

---------------------------------------------------------
-- 6. ANIMATED LOADER SEQUENCE
---------------------------------------------------------
task.spawn(function()
    TweenService:Create(LoaderFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    TweenService:Create(LoaderStroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
    TweenService:Create(LoaderTitle, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(LoaderSub, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    TweenService:Create(ProgressBarBG, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
    
    task.wait(0.4)
    
    -- Smooth Progress Fill with steps
    LoaderSub.Text = "Injecting Modules..."
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.45, 0, 1, 0)
    }):Play()
    task.wait(0.7)
    
    LoaderSub.Text = "Applying Visuals..."
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 1, 0)
    }):Play()
    task.wait(0.7)
    
    LoaderSub.Text = "Ready!"
    task.wait(0.3)
    
    -- Hide Loader smoothly
    TweenService:Create(LoaderFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoaderStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
    TweenService:Create(LoaderTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(LoaderSub, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(ProgressBarBG, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    
    task.wait(0.3)
    LoaderFrame:Destroy()
    
    -- Pop Open Toggle Button
    OpenButton.Visible = true
    OpenButton.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(OpenButton, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 50, 0, 50)
    }):Play()
    
    Tabs["Visuals"].MouseButton1Click:Fire()
end)
