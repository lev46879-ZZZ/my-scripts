-- КОД ДЛЯ ВАШЕГО ГИТХАБА (NekoV Menu under loadstring)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Автоматическое удаление старой копии меню перед перезапуском
if CoreGui:FindFirstChild("NekoVHubGui") then
	CoreGui.NekoVHubGui:Destroy()
end

-- 1. Создание ScreenGui напрямую в CoreGui (Защита от сброса при смерти/ресете в Каталоге)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NekoVHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ПАЛИТРА ЦВЕТОВ (Стиль Pulse Hub)
local MAIN_BG = Color3.fromRGB(15, 15, 20)
local TOPBAR_BG = Color3.fromRGB(20, 20, 28)
local PANEL_BG = Color3.fromRGB(11, 11, 16)
local PURPLE_NEON = Color3.fromRGB(140, 50, 255)
local PURPLE_HOVER = Color3.fromRGB(170, 90, 255)
local TEXT_WHITE = Color3.fromRGB(240, 240, 250)
local TEXT_DARK = Color3.fromRGB(120, 120, 140)

-- 2. Плавающая Кнопка открытия ("NV")
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

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = FloatingButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = PURPLE_NEON
ButtonStroke.Thickness = 2
ButtonStroke.Parent = FloatingButton

-- 3. Главное Меню
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 420, 0, 260)

-- Позиция: по центру, но приподнята чуть выше
MainMenu.Position = UDim2.new(0.5, -210, 0.35, -130)

MainMenu.BackgroundColor3 = MAIN_BG
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = MainMenu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = PURPLE_NEON
MenuStroke.Thickness = 1.5
MenuStroke.Parent = MainMenu

-- Шапка меню (TopBar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = TOPBAR_BG
TopBar.Parent = MainMenu

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarLine = Instance.new("Frame")
TopBarLine.Size = UDim2.new(1, 0, 0, 1)
TopBarLine.Position = UDim2.new(0, 0, 1, -1)
TopBarLine.BackgroundColor3 = PURPLE_NEON
TopBarLine.BorderSizePixel = 0
TopBarLine.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NekoV"
Title.TextColor3 = TEXT_WHITE
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local TitleAccent = Instance.new("TextLabel")
TitleAccent.Size = UDim2.new(1, 0, 1, 0)
TitleAccent.Position = UDim2.new(0, 75, 0, 0)
TitleAccent.BackgroundTransparency = 1
TitleAccent.Text = ".v1"
TitleAccent.TextColor3 = PURPLE_NEON
TitleAccent.TextSize = 16
TitleAccent.Font = Enum.Font.GothamBold
TitleAccent.TextXAlignment = Enum.TextXAlignment.Left
TitleAccent.Parent = TopBar

-- ЛЕВАЯ ПАНЕЛЬ ВКЛАДОК
local TabPanel = Instance.new("Frame")
TabPanel.Name = "TabPanel"
TabPanel.Size = UDim2.new(0, 110, 1, -40)
TabPanel.Position = UDim2.new(0, 0, 0, 40)
TabPanel.BackgroundColor3 = PANEL_BG
TabPanel.BorderSizePixel = 0
TabPanel.Parent = MainMenu

local TabPanelCorner = Instance.new("UICorner")
TabPanelCorner.CornerRadius = UDim.new(0, 10)
TabPanelCorner.Parent = TabPanel

local TabLayout = Instance.new("UIListLayout")
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabPanel

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 12)
TabPadding.PaddingLeft = UDim.new(0, 6)
TabPadding.PaddingRight = UDim.new(0, 6)
TabPadding.Parent = TabPanel

-- Разделитель панелей
local TabLine = Instance.new("Frame")
TabLine.Size = UDim2.new(0, 1, 1, -40)
TabLine.Position = UDim2.new(0, 110, 0, 40)
TabLine.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TabLine.BorderSizePixel = 0
TabLine.Parent = MainMenu

-- КОНТЕНТ-ПАНЕЛЬ
local ContentPanel = Instance.new("Frame")
ContentPanel.Name = "ContentPanel"
ContentPanel.Size = UDim2.new(1, -125, 1, -55)
ContentPanel.Position = UDim2.new(0, 120, 0, 50)
ContentPanel.BackgroundTransparency = 1
ContentPanel.Parent = MainMenu

-- Функция Drag (Исправлена для мобильных и ПК под лоадеры)
local function makeDraggable(guiElement, dragHandle)
	local dragging, dragInput, dragStart, startPosition
	local function update(input)
		local delta = input.Position - dragStart
		guiElement.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
	end
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = guiElement.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end

makeDraggable(FloatingButton, FloatingButton)
makeDraggable(MainMenu, TopBar)

-- Включение / Отключение меню
FloatingButton.MouseButton1Click:Connect(function()
	MainMenu.Visible = not MainMenu.Visible
end)

-- Исправленная система вкладок
local tabs = {}
local contents = {}
local activeTab = nil

local function createTab(tabName)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = tabName .. "Tab"
	tabBtn.Size = UDim2.new(1, 0, 0, 35)
	tabBtn.BackgroundColor3 = PURPLE_NEON
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = tabName
	tabBtn.TextColor3 = TEXT_DARK
	tabBtn.TextSize = 14
	tabBtn.Font = Enum.Font.GothamMedium
	tabBtn.Parent = TabPanel
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = tabBtn
	
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = tabName .. "Content"
	contentFrame.Size = UDim2.new(1, 0, 1, 0)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Visible = false
	contentFrame.Parent = ContentPanel

	tabs[tabName] = tabBtn
	contents[tabName] = contentFrame

	tabBtn.MouseEnter:Connect(function()
		if activeTab ~= tabName then
			TweenService:Create(tabBtn, TweenInfo.new(0.2), {TextColor3 = TEXT_WHITE}):Play()
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if activeTab ~= tabName then
			TweenService:Create(tabBtn, TweenInfo.new(0.2), {TextColor3 = TEXT_DARK}):Play()
		end
	end)

	tabBtn.MouseButton1Click:Connect(function()
		activeTab = tabName
		for name, btn in pairs(tabs) do
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = TEXT_DARK}):Play()
			contents[name].Visible = false
		end
		TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, TextColor3 = PURPLE_NEON}):Play()
		contentFrame.Visible = true
	end)
	
	return contentFrame
end

local worldContent = createTab("World")
local visualContent = createTab("Visual")

-- Заглушка во вкладке Visual
local visualText = Instance.new("TextLabel")
visualText.Size = UDim2.new(1, 0, 0, 30)
visualText.BackgroundTransparency = 1
visualText.Text = "Visual Settings"
visualText.TextColor3 = TEXT_WHITE
visualText.TextSize = 14
visualText.Font = Enum.Font.GothamMedium
visualText.TextXAlignment = Enum.TextXAlignment.Left
visualText.Parent = visualContent

----------------------------------------------------
-- ФУНКЦИОНАЛ: КНОПКА СМЕНЫ НЕБА ВО ВКАДКУ WORLD
----------------------------------------------------
local SkyButton = Instance.new("TextButton")
SkyButton.Name = "CustomSkyButton"
SkyButton.Size = UDim2.new(1, 0, 0, 38)
SkyButton.Position = UDim2.new(0, 0, 0, 5)
SkyButton.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
SkyButton.Text = "Purple Sky: OFF"
SkyButton.TextColor3 = Color3.fromRGB(230, 80, 80)
SkyButton.TextSize = 13
SkyButton.Font = Enum.Font.GothamBold
SkyButton.Parent = worldContent

local SkyCorner = Instance.new("UICorner")
SkyCorner.CornerRadius = UDim.new(0, 6)
SkyCorner.Parent = SkyButton

local SkyStroke = Instance.new("UIStroke")
SkyStroke.Color = Color3.fromRGB(45, 45, 60)
SkyStroke.Thickness = 1
SkyStroke.Parent = SkyButton

local skyActive = false
local originalLightingSettings = {}

SkyButton.MouseButton1Click:Connect(function()
	skyActive = not skyActive
	if skyActive then
		SkyButton.Text = "Purple Sky: ON"
		SkyButton.TextColor3 = PURPLE_NEON
		SkyStroke.Color = PURPLE_NEON
		
		originalLightingSettings.Ambient = Lighting.Ambient
		originalLightingSettings.OutdoorAmbient = Lighting.OutdoorAmbient
		originalLightingSettings.ClockTime = Lighting.ClockTime
		originalLightingSettings.FogColor = Lighting.FogColor
		originalLightingSettings.FogEnd = Lighting.FogEnd

		Lighting.ClockTime = 0
		Lighting.Ambient = Color3.fromRGB(40, 20, 70)
		Lighting.OutdoorAmbient = Color3.fromRGB(20, 10, 40)
		Lighting.FogColor = Color3.fromRGB(15, 5, 25)
		Lighting.FogEnd = 500
	else
		SkyButton.Text = "Purple Sky: OFF"
		SkyButton.TextColor3 = Color3.fromRGB(230, 80, 80)
		SkyStroke.Color = Color3.fromRGB(45, 45, 60)
		
		if originalLightingSettings.Ambient then
