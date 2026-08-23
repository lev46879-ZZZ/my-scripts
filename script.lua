local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10) 
if not PlayerGui then return end

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Плавающая Кнопка
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingButton"
FloatingButton.Size = UDim2.new(0, 60, 0, 60)
FloatingButton.Position = UDim2.new(0.05, 0, 0.4, 0)
FloatingButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FloatingButton.Text = "MENU"
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.TextSize = 14
FloatingButton.Font = Enum.Font.SourceSansBold
FloatingButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = FloatingButton

-- Главное Меню
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 400, 0, 250)
MainMenu.Position = UDim2.new(0.5, -200, 0.5, -125)
MainMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 8)
MenuCorner.Parent = MainMenu

-- Шапка
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TopBar.Parent = MainMenu

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Панель вкладок
local TabPanel = Instance.new("Frame")
TabPanel.Name = "TabPanel"
TabPanel.Size = UDim2.new(0, 100, 1, -35)
TabPanel.Position = UDim2.new(0, 0, 0, 35)
TabPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabPanel.Parent = MainMenu

local TabLayout = Instance.new("UIListLayout")
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabPanel

-- Контейнер контента
local ContentPanel = Instance.new("Frame")
ContentPanel.Name = "ContentPanel"
ContentPanel.Size = UDim2.new(1, -110, 1, -45)
ContentPanel.Position = UDim2.new(0, 105, 0, 40)
ContentPanel.BackgroundTransparency = 1
ContentPanel.Parent = MainMenu

-- Функция Drag
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

FloatingButton.MouseButton1Click:Connect(function()
	MainMenu.Visible = not MainMenu.Visible
end)

-- Переменные системы вкладок
local tabs = {}
local contents = {}

local function createTab(tabName)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = tabName .. "Tab"
	tabBtn.Size = UDim2.new(1, 0, 0, 35)
	tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = tabName
	tabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
	tabBtn.TextSize = 14
	tabBtn.Font = Enum.Font.SourceSans
	tabBtn.Parent = TabPanel
	
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = tabName .. "Content"
	contentFrame.Size = UDim2.new(1, 0, 1, 0)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Visible = false
	contentFrame.Parent = ContentPanel

	tabs[tabName] = tabBtn
	contents[tabName] = contentFrame

	tabBtn.MouseButton1Click:Connect(function()
		for name, btn in pairs(tabs) do
			btn.BackgroundTransparency = 1
			btn.TextColor3 = Color3.fromRGB(150, 150, 150)
			contents[name].Visible = false
		end
		tabBtn.BackgroundTransparency = 0
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		contentFrame.Visible = true
	end)
	return contentFrame
end

-- Инициализация вкладок
local worldContent = createTab("World")
local visualContent = createTab("Visual")

----------------------------------------------------
-- КНОПКА СМЕНЫ НЕБА ВО ВКЛАДКЕ WORLD
----------------------------------------------------
local SkyButton = Instance.new("TextButton")
SkyButton.Name = "AnimeSkyButton"
SkyButton.Size = UDim2.new(1, 0, 0, 40)
SkyButton.Position = UDim2.new(0, 0, 0, 10)
SkyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SkyButton.Text = "Anime Sky: OFF"
SkyButton.TextColor3 = Color3.fromRGB(255, 100, 100)
SkyButton.TextSize = 14
SkyButton.Font = Enum.Font.SourceSansBold
SkyButton.Parent = worldContent

local SkyCorner = Instance.new("UICorner")
SkyCorner.CornerRadius = UDim.new(0, 6)
SkyCorner.Parent = SkyButton

local skyActive = false
local originalSkies = {}
local customSky = nil

-- ID аниме текстур для Skybox (вы можете вставить свои Asset ID, если загрузите свои кубмапы)
local animeSkyId = "rbxassetid://2703273105" 

SkyButton.MouseButton1Click:Connect(function()
	skyActive = not skyActive
	
	if skyActive then
		SkyButton.Text = "Anime Sky: ON"
		SkyButton.TextColor3 = Color3.fromRGB(100, 255, 100)
		SkyButton.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
		
		-- Прячем стандартное небо игры во временную таблицу
		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("Sky") then
				table.insert(originalSkies, child)
				child.Parent = nil
			end
		end
		
		-- Создаем наше аниме-небо
		customSky = Instance.new("Sky")
		customSky.Name = "AnimeSkybox"
		customSky.SkyboxBk = animeSkyId
		customSky.SkyboxDn = animeSkyId
		customSky.SkyboxFt = animeSkyId
		customSky.SkyboxLf = animeSkyId
		customSky.SkyboxRt = animeSkyId
		customSky.SkyboxUp = animeSkyId
		customSky.SunTextureId = "" -- убираем стандартное солнце, чтобы не портить арт
		customSky.MoonTextureId = ""
		customSky.Parent = Lighting
	else
		SkyButton.Text = "Anime Sky: OFF"
		SkyButton.TextColor3 = Color3.fromRGB(255, 100, 100)
		SkyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		
		-- Удаляем кастомное небо
		if customSky then
			customSky:Destroy()
			customSky = nil
		end
		
		-- Возвращаем старое небо игры назад
		for _, sky in ipairs(originalSkies) do
			sky.Parent = Lighting
		end
		originalSkies = {}
	end
end)

-- Дефолтное открытие первой вкладки
if tabs["World"] then
	tabs["World"].BackgroundTransparency = 0
	tabs["World"].TextColor3 = Color3.fromRGB(255, 255, 255)
	contents["World"].Visible = true
end
