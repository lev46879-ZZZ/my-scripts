-- NEKOV HUB .v1 (FULLY REWRITTEN FOR LOADSTRING)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
-- Самый безопасный способ получить контейнер интерфейса, который работает везде
local BaseGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")

-- Защита от дубликатов (удаляем старое меню перед запуском)
if BaseGui:FindFirstChild("NekoVMenu_Official") then
	BaseGui["NekoVMenu_Official"]:Destroy()
end

-- 1. Главный контейнер
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NekoVMenu_Official"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = BaseGui

-- Палитра дизайна (Pulse Hub Style)
local MAIN_BG = Color3.fromRGB(15, 15, 20)
local TOPBAR_BG = Color3.fromRGB(20, 20, 28)
local PANEL_BG = Color3.fromRGB(11, 11, 16)
local PURPLE_NEON = Color3.fromRGB(140, 50, 255)
local TEXT_WHITE = Color3.fromRGB(240, 240, 250)
local TEXT_DARK = Color3.fromRGB(120, 120, 140)

-- 2. Плавающая Кнопка "NV"
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Size = UDim2.new(0, 50, 0, 50)
FloatingButton.Position = UDim2.new(0.05, 0, 0.4, 0)
FloatingButton.BackgroundColor3 = MAIN_BG
FloatingButton.Text = "NV"
FloatingButton.TextColor3 = PURPLE_NEON
FloatingButton.TextSize = 16
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = FloatingButton

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = PURPLE_NEON
BtnStroke.Thickness = 2
BtnStroke.Parent = FloatingButton

-- 3. Главное Окно Меню (Центр, чуть приподнято)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.35, -130)
MainFrame.BackgroundColor3 = MAIN_BG
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = PURPLE_NEON
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Шапка (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = TOPBAR_BG
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 1)
TopLine.Position = UDim2.new(0, 0, 1, -1)
TopLine.BackgroundColor3 = PURPLE_NEON
TopLine.BorderSizePixel = 0
TopLine.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NekoV"
Title.TextColor3 = TEXT_WHITE
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local TitleAccent = Instance.new("TextLabel")
TitleAccent.Size = UDim2.new(0, 50, 1, 0)
TitleAccent.Position = UDim2.new(0, 72, 0, 0)
TitleAccent.BackgroundTransparency = 1
TitleAccent.Text = ".v1"
TitleAccent.TextColor3 = PURPLE_NEON
TitleAccent.TextSize = 16
TitleAccent.Font = Enum.Font.GothamBold
TitleAccent.TextXAlignment = Enum.TextXAlignment.Left
TitleAccent.Parent = TopBar

-- Левая Панель Вкладок
local TabPanel = Instance.new("Frame")
TabPanel.Size = UDim2.new(0, 110, 1, -40)
TabPanel.Position = UDim2.new(0, 0, 0, 40)
TabPanel.BackgroundColor3 = PANEL_BG
TabPanel.BorderSizePixel = 0
TabPanel.Parent = MainFrame

local TabPanelCorner = Instance.new("UICorner")
TabPanelCorner.CornerRadius = UDim.new(0, 10)
TabPanelCorner.Parent = TabPanel

local TabLine = Instance.new("Frame")
TabLine.Size = UDim2.new(0, 1, 1, -40)
TabLine.Position = UDim2.new(0, 110, 0, 40)
TabLine.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TabLine.BorderSizePixel = 0
TabLine.Parent = MainFrame

-- Кнопка World
local WorldTab = Instance.new("TextButton")
WorldTab.Size = UDim2.new(1, -12, 0, 35)
WorldTab.Position = UDim2.new(0, 6, 0, 12)
WorldTab.BackgroundColor3 = PURPLE_NEON
WorldTab.BackgroundTransparency = 0.8
WorldTab.Text = "World"
WorldTab.TextColor3 = PURPLE_NEON
WorldTab.TextSize = 14
WorldTab.Font = Enum.Font.GothamMedium
WorldTab.Parent = TabPanel
Instance.new("UICorner", WorldTab).CornerRadius = UDim.new(0, 6)

-- Кнопка Visual
local VisualTab = Instance.new("TextButton")
VisualTab.Size = UDim2.new(1, -12, 0, 35)
VisualTab.Position = UDim2.new(0, 6, 0, 53)
VisualTab.BackgroundTransparency = 1
VisualTab.Text = "Visual"
VisualTab.TextColor3 = TEXT_DARK
VisualTab.TextSize = 14
VisualTab.Font = Enum.Font.GothamMedium
VisualTab.Parent = TabPanel
Instance.new("UICorner", VisualTab).CornerRadius = UDim.new(0, 6)

-- Контейнер для контента страниц
local ContentPanel = Instance.new("Frame")
ContentPanel.Size = UDim2.new(1, -125, 1, -55)
ContentPanel.Position = UDim2.new(0, 120, 0, 50)
ContentPanel.BackgroundTransparency = 1
ContentPanel.Parent = MainFrame

-- Страница World
local WorldPage = Instance.new("Frame")
WorldPage.Size = UDim2.new(1, 0, 1, 0)
WorldPage.BackgroundTransparency = 1
WorldPage.Visible = true
WorldPage.Parent = ContentPanel

-- Страница Visual
local VisualPage = Instance.new("Frame")
VisualPage.Size = UDim2.new(1, 0, 1, 0)
VisualPage.BackgroundTransparency = 1
VisualPage.Visible = false
VisualPage.Parent = ContentPanel

local visualText = Instance.new("TextLabel")
visualText.Size = UDim2.new(1, 0, 0, 30)
visualText.BackgroundTransparency = 1
visualText.Text = "Visual Settings Active"
visualText.TextColor3 = TEXT_DARK
visualText.TextSize = 14
visualText.Font = Enum.Font.GothamMedium
visualText.TextXAlignment = Enum.TextXAlignment.Left
visualText.Parent = VisualPage

-- Функция переключения вкладок (Без багов наложения)
WorldTab.MouseButton1Click:Connect(function()
	WorldTab.BackgroundTransparency = 0.8
	WorldTab.TextColor3 = PURPLE_NEON
	VisualTab.BackgroundTransparency = 1
	VisualTab.TextColor3 = TEXT_DARK
	WorldPage.Visible = true
	VisualPage.Visible = false
end)

VisualTab.MouseButton1Click:Connect(function()
	VisualTab.BackgroundTransparency = 0.8
	VisualTab.TextColor3 = PURPLE_NEON
	WorldTab.BackgroundTransparency = 1
	WorldTab.TextColor3 = TEXT_DARK
	VisualPage.Visible = true
	WorldPage.Visible = false
end)

-- 4. Рабочая кнопка смены скорости (WalkSpeed) во вкладке World
local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(1, 0, 0, 38)
SpeedButton.Position = UDim2.new(0, 0, 0, 5)
SpeedButton.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
SpeedButton.Text = "Fast Speed: OFF"
SpeedButton.TextColor3 = Color3.fromRGB(230, 80, 80)
SpeedButton.TextSize = 13
SpeedButton.Font = Enum.Font.GothamBold
SpeedButton.Parent = WorldPage

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedButton

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Color = Color3.fromRGB(45, 45, 60)
SpeedStroke.Parent = SpeedButton

local speedActive = false
SpeedButton.MouseButton1Click:Connect(function()
	speedActive = not speedActive
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	
	if hum then
		if speedActive then
			SpeedButton.Text = "Fast Speed: ON"
			SpeedButton.TextColor3 = PURPLE_NEON
			SpeedStroke.Color = PURPLE_NEON
			hum.WalkSpeed = 60 -- Увеличиваем скорость
		else
			SpeedButton.Text = "Fast Speed: OFF"
			SpeedButton.TextColor3 = Color3.fromRGB(230, 80, 80)
			SpeedStroke.Color = Color3.fromRGB(45, 45, 60)
			hum.WalkSpeed = 16 -- Возвращаем стандартную
		end
	end
end)

-- 5. Открытие / Закрытие меню
FloatingButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

-- 6. Безопасный скрипт перетаскивания (Drag)
local function makeDraggable(frame, handle)
	local dragging, dragInput, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

makeDraggable(FloatingButton, FloatingButton)
makeDraggable(MainFrame, TopBar)
