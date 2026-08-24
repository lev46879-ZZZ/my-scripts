--[[
    APEX HUB | Horizontal GUI V5
    Features: Direct Image Download, Pulse Wave Animation, Fixed Draggable TopBar
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("ApexHubUI_V5") then
    PlayerGui.ApexHubUI_V5:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexHubUI_V5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

---------------------------------------------------------
-- 0. СКАЧИВАНИЕ И КЭШИРОВАНИЕ ИЗОБРАЖЕНИЯ (Asset Loader)
---------------------------------------------------------
local function GetDownloadedImage(fileName, url)
    if getcustomasset and writefile and isfile then
        if not isfile(fileName) then
            local success, content = pcall(function()
                return game:HttpGet(url)
            end)
            if success and content then
                writefile(fileName, content)
            end
        end
        if isfile(fileName) then
            return getcustomasset(fileName)
        end
    end
    -- Запасной fallback URL
    return url
end

-- Прямая ссылка на загрузку фото с глазами
local eyesImageUrl = GetDownloadedImage("apex_eyes.jpg", "https://i.ibb.co/6y4G1vR/anime-eyes.jpg")

---------------------------------------------------------
-- 1. LOADER FRAME (Центральный прямоугольник)
---------------------------------------------------------
local LoaderFrame = Instance.new("Frame")
LoaderFrame.Size = UDim2.new(0, 360, 0, 150)
LoaderFrame.Position = UDim2.new(0.5, -180, 0.5, -75)
LoaderFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
LoaderFrame.BorderSizePixel = 0
LoaderFrame.BackgroundTransparency = 1
LoaderFrame.Parent = ScreenGui

local LoaderCorner = Instance.new("UICorner")
LoaderCorner.CornerRadius = UDim.new(0, 10)
LoaderCorner.Parent = LoaderFrame

local LoaderStroke = Instance.new("UIStroke")
LoaderStroke.Color = Color3.fromRGB(0, 170, 255)
LoaderStroke.Transparency = 1
LoaderStroke.Thickness = 1.2
LoaderStroke.Parent = LoaderFrame

local LoaderTitle = Instance.new("TextLabel")
LoaderTitle.Size = UDim2.new(1, 0, 0, 30)
LoaderTitle.Position = UDim2.new(0, 0, 0.2, 0)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Text = "APEX HUB"
LoaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoaderTitle.TextSize = 20
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextTransparency = 1
LoaderTitle.Parent = LoaderFrame

local LoaderSub = Instance.new("TextLabel")
LoaderSub.Size = UDim2.new(1, 0, 0, 20)
LoaderSub.Position = UDim2.new(0, 0, 0.42, 0)
LoaderSub.BackgroundTransparency = 1
LoaderSub.Text = "Downloading Assets..."
LoaderSub.TextColor3 = Color3.fromRGB(0, 170, 255)
LoaderSub.TextSize = 11
LoaderSub.Font = Enum.Font.GothamMedium
LoaderSub.TextTransparency = 1
LoaderSub.Parent = LoaderFrame

local ProgressBarBG = Instance.new("Frame")
ProgressBarBG.Size = UDim2.new(0.8, 0, 0, 5)
ProgressBarBG.Position = UDim2.new(0.1, 0, 0.7, 0)
ProgressBarBG.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
ProgressBarBG.BorderSizePixel = 0
ProgressBarBG.BackgroundTransparency = 1
ProgressBarBG.Parent = LoaderFrame

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 3)
ProgressCorner.Parent = ProgressBarBG

local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.BackgroundTransparency = 1
ProgressBarFill.Parent = ProgressBarBG

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 3)
FillCorner.Parent = ProgressBarFill

---------------------------------------------------------
-- 2. MAIN FRAME (Лежачий прямоугольник строго по центру)
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 280)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(30, 33, 45)
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 17, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 160, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "APEX HUB <font color=\"#00AAFF\">v5.0</font>"
TitleLabel.RichText = true
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

---------------------------------------------------------
-- ИСПРАВЛЕННЫЙ DRAGGABLE (Свободное перетаскивание)
---------------------------------------------------------
local dragging = false
local dragInput, dragStart, startPos

local function UpdateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        UpdateInput(input)
    end
end)

-- Боковая панель (SideBar)
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 135, 1, -38)
SideBar.Position = UDim2.new(0, 0, 0, 38)
SideBar.BackgroundColor3 = Color3.fromRGB(14, 15, 21)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

---------------------------------------------------------
-- БАННЕР С ГЛАЗАМИ + АНИМИРОВАННАЯ ВОЛНА ПУЛЬСА
---------------------------------------------------------
local EyesBanner = Instance.new("ImageLabel")
EyesBanner.Size = UDim2.new(1, -16, 0, 52)
EyesBanner.Position = UDim2.new(0, 8, 0, 8)
EyesBanner.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
EyesBanner.BorderSizePixel = 0
EyesBanner.Image = eyesImageUrl
EyesBanner.ScaleType = Enum.ScaleType.Crop
EyesBanner.Parent = SideBar

local BannerCorner = Instance.new("UICorner")
BannerCorner.CornerRadius = UDim.new(0, 6)
BannerCorner.Parent = EyesBanner

local BannerStroke = Instance.new("UIStroke")
BannerStroke.Color = Color3.fromRGB(0, 170, 255)
BannerStroke.Transparency = 0.4
BannerStroke.Thickness = 1
BannerStroke.Parent = EyesBanner

-- Линия Пульса (Pulse Wave Container)
local PulseContainer = Instance.new("Frame")
PulseContainer.Size = UDim2.new(1, 0, 0, 10)
PulseContainer.Position = UDim2.new(0, 0, 1, -10)
PulseContainer.BackgroundTransparency = 1
PulseContainer.ClipsDescendants = true
PulseContainer.Parent = EyesBanner

local PulseLine = Instance.new("Frame")
PulseLine.Size = UDim2.new(0, 30, 0, 2)
PulseLine.Position = UDim2.new(-0.2, 0, 0.5, -1)
PulseLine.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
PulseLine.BorderSizePixel = 0
PulseLine.Parent = PulseContainer

local PulseGlow = Instance.new("UIStroke")
PulseGlow.Color = Color3.fromRGB(0, 170, 255)
PulseGlow.Thickness = 1.5
PulseGlow.Parent = PulseLine

-- Анимация бегущей волны пульса
local pulseTime = 0
RunService.RenderStepped:Connect(function(dt)
    if MainFrame.Visible then
        pulseTime = pulseTime + dt * 1.5
        local xPos = (pulseTime % 1.4) - 0.2
        PulseLine.Position = UDim2.new(xPos, 0, 0.5, math.sin(pulseTime * 10) * 2)
    end
end)

-- Контейнер для списка вкладок под фото
local TabListContainer = Instance.new("Frame")
TabListContainer.Size = UDim2.new(1, 0, 1, -68)
TabListContainer.Position = UDim2.new(0, 0, 0, 66)
TabListContainer.BackgroundTransparency = 1
TabListContainer.Parent = SideBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabListContainer

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingLeft = UDim.new(0, 8)
TabPadding.PaddingRight = UDim.new(0, 8)
TabPadding.Parent = TabListContainer

-- Основной контейнер
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -145, 1, -46)
ContentContainer.Position = UDim2.new(0, 140, 0, 42)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

---------------------------------------------------------
-- 3. КНОПКА ОТКРЫТИЯ (TOGGLE BUTTON)
---------------------------------------------------------
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 45, 0, 45)
OpenButton.Position = UDim2.new(0, 15, 0.5, -22)
OpenButton.BackgroundColor3 = Color3.fromRGB(16, 17, 24)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "APEX"
OpenButton.TextColor3 = Color3.fromRGB(0, 170, 255)
OpenButton.TextSize = 11
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(0, 170, 255)
OpenStroke.Thickness = 1.2
OpenStroke.Parent = OpenButton

---------------------------------------------------------
-- 4. ТАБ-СИСТЕМА
---------------------------------------------------------
local Tabs = {}
local ContentFrames = {}

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(18, 20, 27)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(140, 145, 160)
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.Parent = TabListContainer
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
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
    ContentList.Padding = UDim.new(0, 6)
    ContentList.Parent = ContentFrame

    Tabs[name] = TabBtn
    ContentFrames[name] = ContentFrame
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, btn in pairs(Tabs) do
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(18, 20, 27),
                TextColor3 = Color3.fromRGB(140, 145, 160)
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

local MainTab = CreateTab("Main")
local SettingsTab = CreateTab("Settings")

---------------------------------------------------------
-- 5. ОТКРЫТИЕ / ЗАКРЫТИЕ
---------------------------------------------------------
local menuOpen = false

local function ToggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 480, 0, 280),
            Position = UDim2.new(0.5, -240, 0.5, -140)
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
-- 6. ЗАГРУЗЧИК
---------------------------------------------------------
task.spawn(function()
    TweenService:Create(LoaderFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(LoaderStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    TweenService:Create(LoaderTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(LoaderSub, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(ProgressBarBG, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    
    task.wait(0.3)
    
    LoaderSub.Text = "Downloading Image Asset..."
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = UDim2.new(0.6, 0, 1, 0)}):Play()
    task.wait(0.5)
    
    LoaderSub.Text = "Initializing Interface..."
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(0.5)
    
    TweenService:Create(LoaderFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoaderStroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
    TweenService:Create(LoaderTitle, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
    TweenService:Create(LoaderSub, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
    TweenService:Create(ProgressBarBG, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    
    task.wait(0.25)
    LoaderFrame:Destroy()
    
    OpenButton.Visible = true
    OpenButton.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(OpenButton, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 45, 0, 45)
    }):Play()
    
    Tabs["Main"].MouseButton1Click:Fire()
end)
