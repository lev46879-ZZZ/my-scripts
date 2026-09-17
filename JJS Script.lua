-- Delta UI Script for Mobile & PC (v2 — с масштабированием и drag кнопкой)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("DeltaMenu") then
	playerGui.DeltaMenu:Destroy()
end

-- ==========================================
-- 1. ОСНОВНЫЕ ЭЛЕМЕНТЫ + UIScale
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

-- UIScale — через него будет работать ползунок масштабирования всего меню
local GlobalScale = Instance.new("UIScale")
GlobalScale.Name = "GlobalScale"
GlobalScale.Scale = 1 -- 100% по умолчанию
GlobalScale.Parent = ScreenGui

-- ==========================================
-- 2. КНОПКА С DRAG ФУНКЦИОНАЛОМ
-- ==========================================

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "☰"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = false

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(60, 60, 60)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

ToggleButton.Parent = ScreenGui

-- === Drag логика кнопки (с поддержкой ПК и телефона) ===
local draggingBtn = false
local dragStartPos = nil
local btnStartPos = nil
local movedDistance = 0
local DRAG_THRESHOLD = 6 -- пикселей — порог, чтобы отличать клик от перетаскивания

local function beginDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		draggingBtn = true
		movedDistance = 0
		dragStartPos = input.Position
		btnStartPos = ToggleButton.AbsolutePosition
	end
end

local function moveDrag(input)
	if not draggingBtn then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then return end

	local delta = input.Position - dragStartPos
	movedDistance = delta.Magnitude

	local newPos = UDim2.fromOffset(
		btnStartPos.X + delta.X,
		btnStartPos.Y + delta.Y
	)
	-- Ограничиваем пределами экрана
	local vp = workspace.CurrentCamera.ViewportSize
	local bx = math.clamp(btnStartPos.X + delta.X, 0, vp.X - ToggleButton.AbsoluteSize.X)
	local by = math.clamp(btnStartPos.Y + delta.Y, 0, vp.Y - ToggleButton.AbsoluteSize.Y)
	ToggleButton.Position = UDim2.fromOffset(bx, by)
end

local function endDrag(input)
	if not draggingBtn then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		draggingBtn = false
		-- Если палец/мышь почти не двигались — считаем это кликом и открываем меню
		if movedDistance < DRAG_THRESHOLD then
			toggleMenu()
		end
	end
end

ToggleButton.InputBegan:Connect(beginDrag)
UserInputService.InputChanged:Connect(moveDrag)
UserInputService.InputEnded:Connect(endDrag)

-- ==========================================
-- 3. ГЛАВНОЕ ОКНО МЕНЮ
-- ==========================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 650, 0, 420)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

MainFrame.Parent = ScreenGui

-- Левая панель навигации
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 60, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideBarCorner = Instance.new("UICorner")
SideBarCorner.CornerRadius = UDim.new(0, 10)
SideBarCorner.Parent = SideBar

local SideBarMask = Instance.new("Frame")
SideBarMask.Size = UDim2.new(0, 20, 1, 0)
SideBarMask.Position = UDim2.new(1, -20, 0, 0)
SideBarMask.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SideBarMask.BorderSizePixel = 0
SideBarMask.Parent = SideBar

local TabList = Instance.new("ScrollingFrame")
TabList.Name = "TabList"
TabList.Size = UDim2.new(1, 0, 1, -60)
TabList.Position = UDim2.new(0, 0, 0, 60)
TabList.BackgroundTransparency = 1
TabList.BorderSizePixel = 0
TabList.ScrollBarThickness = 0
TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
TabList.Parent = SideBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 15)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabList

-- Верхняя панель с заголовком
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -60, 0, 60)
TopBar.Position = UDim2.new(0, 60, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Поку"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Контейнер страниц
local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -60, 1, -60)
PagesContainer.Position = UDim2.new(0, 60, 0, 60)
PagesContainer.BackgroundTransparency = 1
PagesContainer.ClipsDescendants = true
PagesContainer.Parent = MainFrame

-- ==========================================
-- 4. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ==========================================

local function createTabButton(iconText, tabName, pageFrame)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.BorderSizePixel = 0
	btn.Text = iconText
	btn.TextColor3 = Color3.fromRGB(150, 150, 150)
	btn.TextSize = 20
	btn.Font = Enum.Font.Gotham
	btn.AutoButtonColor = false

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 4, 0, 20)
	indicator.Position = UDim2.new(0, -10, 0.5, -10)
	indicator.BackgroundColor3 = Color3.fromRGB(74, 144, 226)
	indicator.BorderSizePixel = 0
	indicator.Visible = false
	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(0, 2)
	indCorner.Parent = indicator
	indicator.Parent = btn

	btn.Parent = TabList

	btn.MouseButton1Click:Connect(function()
		for _, page in pairs(PagesContainer:GetChildren()) do
			if page:IsA("Frame") then page.Visible = false end
		end
		pageFrame.Visible = true
		TitleLabel.Text = tabName

		for _, otherBtn in pairs(TabList:GetChildren()) do
			if otherBtn:IsA("TextButton") then
				otherBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				otherBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
				local ind = otherBtn:FindFirstChildOfClass("Frame")
				if ind then ind.Visible = false end
			end
		end
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		indicator.Visible = true
	end)

	return btn
end

local function createSection(parent, title, size, position)
	local section = Instance.new("Frame")
	section.Name = title
	section.Size = size
	section.Position = position
	section.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	section.BorderSizePixel = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = section

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 30)
	titleLabel.Position = UDim2.new(0, 15, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
	titleLabel.TextSize = 12
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = section

	return section
end

-- Универсальная функция слайдера
local function createSlider(parent, text, min, max, default, position, suffix, callback)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Size = UDim2.new(1, -30, 0, 40)
	sliderFrame.Position = position
	sliderFrame.BackgroundTransparency = 1
	sliderFrame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 100, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = sliderFrame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -180, 0, 6)
	track.Position = UDim2.new(0, 110, 0.5, -3)
	track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	track.BorderSizePixel = 0
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(74, 144, 226)
	fill.BorderSizePixel = 0
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(74, 144, 226)
	knob.BorderSizePixel = 0
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local valueBox = Instance.new("Frame")
	valueBox.Size = UDim2.new(0, 55, 0, 24)
	valueBox.Position = UDim2.new(1, -55, 0.5, -12)
	valueBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	valueBox.BorderSizePixel = 0
	local valCorner = Instance.new("UICorner")
	valCorner.CornerRadius = UDim.new(0, 4)
	valCorner.Parent = valueBox

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(1, 0, 1, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default) .. (suffix or "")
	valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	valueLabel.TextSize = 12
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.Parent = valueBox

	fill.Parent = track
	knob.Parent = track
	valueBox.Parent = sliderFrame
	track.Parent = sliderFrame

	local dragging = false

	local function update(input)
		local relPos = math.clamp(
			(input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
			0, 1
		)
		local val = math.floor(min + (max - min) * relPos)
		fill.Size = UDim2.new(relPos, 0, 1, 0)
		knob.Position = UDim2.new(relPos, -7, 0.5, -7)
		valueLabel.Text = tostring(val) .. (suffix or "")
		if callback then callback(val) end
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	knob.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			update(input)
			dragging = true
		end
	end)
end

-- ==========================================
-- 5. СОЗДАНИЕ ВКЛАДОК
-- ==========================================

-- Поку — пустая, открывается по умолчанию
local Page_Poku = Instance.new("Frame")
Page_Poku.Name = "Page_Poku"
Page_Poku.Size = UDim2.new(1, 0, 1, 0)
Page_Poku.BackgroundTransparency = 1
Page_Poku.Visible = true
Page_Poku.Parent = PagesContainer

-- Main — пустая
local Page_Main = Instance.new("Frame")
Page_Main.Name = "Page_Main"
Page_Main.Size = UDim2.new(1, 0, 1, 0)
Page_Main.BackgroundTransparency = 1
Page_Main.Visible = false
Page_Main.Parent = PagesContainer

-- Sitting — с ползунком масштаба всего меню
local Page_Sitting = Instance.new("Frame")
Page_Sitting.Name = "Page_Sitting"
Page_Sitting.Size = UDim2.new(1, 0, 1, 0)
Page_Sitting.BackgroundTransparency = 1
Page_Sitting.Visible = false
Page_Sitting.Parent = PagesContainer

local sittingSection = createSection(
	Page_Sitting,
	"SITTING SETTINGS",
	UDim2.new(1, -30, 0, 120),
	UDim2.new(0, 15, 0, 15)
)

-- Ползунок масштаба: 1% - 200%, по умолчанию 100%
createSlider(
	sittingSection,
	"Масштаб",
	1, 200, 100,
	UDim2.new(0, 0, 0, 45),
	"%",
	function(value)
		-- Применяем масштаб ко всему меню (включая кнопку)
		GlobalScale.Scale = value / 100
	end
)

-- ==========================================
-- 6. КНОПКИ ВКЛАДОК В САЙДБАРЕ
-- ==========================================

local btnMain = createTabButton("🏠", "Main", Page_Main)
local btnPoku = createTabButton("🛒", "Поку", Page_Poku)
local btnSitting = createTabButton("🪑", "Sitting", Page_Sitting)

-- Подсвечиваем "Поку" как активную по умолчанию
btnPoku.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
btnPoku.TextColor3 = Color3.fromRGB(255, 255, 255)
btnPoku:FindFirstChildOfClass("Frame").Visible = true

TabList.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)

-- ==========================================
-- 7. АНИМАЦИЯ ОТКРЫТИЯ / ЗАКРЫТИЯ
-- ==========================================

local isMenuOpen = false

-- Начальная "скрытая" позиция
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -190)
MainFrame.BackgroundTransparency = 1

function toggleMenu()
	isMenuOpen = not isMenuOpen
	if isMenuOpen then
		MainFrame.Visible = true
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, -325, 0.5, -210),
			BackgroundTransparency = 0
		}):Play()
		TweenService:Create(ToggleButton, TweenInfo.new(0.3), {Rotation = 90}):Play()
	else
		local t = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, -325, 0.5, -190),
			BackgroundTransparency = 1
		})
		t:Play()
		t.Completed:Wait()
		MainFrame.Visible = false
		TweenService:Create(ToggleButton, TweenInfo.new(0.3), {Rotation = 0}):Play()
	end
end

-- ==========================================
-- 8. АДАПТАЦИЯ ПОД ТЕЛЕФОН (при первой загрузке)
-- ==========================================

local function applyInitialAdaptation()
	local vp = workspace.CurrentCamera.ViewportSize
	if vp.X < 700 then
		-- На маленьких экранах делаем меню компактнее и по центру
		MainFrame.Size = UDim2.new(0.95, 0, 0.75, 0)
		MainFrame.Position = UDim2.new(0.025, 0, 0.12, 0)
	end
end

applyInitialAdaptation()

print("Delta Menu v2 Loaded! (Масштаб + Drag кнопка)")
