-- Настройки интерфейса
local Players = game:Service("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:Service("UserInputService")
local TweenService = game:Service("TweenService")

-- 1. Создание ScreenGui
local ScreenGui = script.Parent
if not ScreenGui:IsA("ScreenGui") then
	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Parent = PlayerGui
end
ScreenGui.ResetOnSpawn = false

-- 2. Создание Плавающей Кнопки (Floating Button)
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
ButtonCorner.CornerRadius = UDim.new(1, 0) -- Делает кнопку круглой
ButtonCorner.Parent = FloatingButton

-- 3. Создание Главного Меню (Main Menu Frame)
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

-- Шапка меню (За нее будем перетаскивать)
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
Title.Text = "Cheat Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Панель вкладок (Табы)
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

-- Контейнер для контента вкладок
local ContentPanel = Instance.new("Frame")
ContentPanel.Name = "ContentPanel"
ContentPanel.Size = UDim2.new(1, -110, 1, -45)
ContentPanel.Position = UDim2.new(0, 105, 0, 40)
ContentPanel.BackgroundTransparency = 1
ContentPanel.Parent = MainMenu

-- 4. Функция перетаскивания (Drag Function) для любого GUI элемента
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
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

-- Включаем перетаскивание для плавающей кнопки и для главного меню (за шапку)
makeDraggable(FloatingButton, FloatingButton)
makeDraggable(MainMenu, TopBar)

-- 5. Логика Открытия / Закрытия меню по нажатию на кнопку
FloatingButton.MouseButton1Click:Connect(function()
	MainMenu.Visible = not MainMenu.Visible
end)

-- 6. Создание системы вкладок (World и Visual)
local tabs = {}
local contents = {}

local function createTab(tabName)
	-- Кнопка вкладки
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
	
	-- Фрейм с контентом для этой вкладки
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = tabName .. "Content"
	contentFrame.Size = UDim2.new(1, 0, 1, 0)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Visible = false
	contentFrame.Parent = ContentPanel
	
	-- Добавляем тестовый текст, чтобы видеть, что вкладка переключилась
	local testText = Instance.new("TextLabel")
	testText.Size = UDim2.new(1, 0, 0, 30)
	testText.BackgroundTransparency = 1
	testText.Text = "Это вкладка: " .. tabName
	testText.TextColor3 = Color3.fromRGB(200, 200, 200)
	testText.TextSize = 16
	testText.Font = Enum.Font.SourceSans
	testText.Parent = contentFrame

	tabs[tabName] = tabBtn
	contents[tabName] = contentFrame

	-- Логика переключения
	tabBtn.MouseButton1Click:Connect(function()
		-- Сбрасываем все вкладки
		for name, btn in pairs(tabs) do
			btn.BackgroundTransparency = 1
			btn.TextColor3 = Color3.fromRGB(150, 150, 150)
			contents[name].Visible = false
		end
		-- Активируем выбранную
		tabBtn.BackgroundTransparency = 0
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		contentFrame.Visible = true
	end)
end

-- Создаем вкладки "World" и "Visual"
createTab("World")
createTab("Visual")

-- Открываем первую вкладку по умолчанию
if tabs["World"] then
	tabs["World"].BackgroundTransparency = 0
	tabs["World"].TextColor3 = Color3.fromRGB(255, 255, 255)
	contents["World"].Visible = true
end
