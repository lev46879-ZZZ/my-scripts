--// APEX HUB - VISUAL ONLY
--// LocalScript
--// Все элементы внутри меню декоративные.
--// Игровых функций ESP / Fly / Teleport / AutoFarm и т.д. НЕТ.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local MENU_SIZE = UDim2.fromOffset(650, 440)

local TWEEN_FAST = TweenInfo.new(
	0.16,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

local TWEEN_MENU = TweenInfo.new(
	0.28,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

--==================================================
-- GUI OPEN BUTTON
--==================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "ApexHubButton"
OpenButton.Size = UDim2.fromOffset(54, 54)

-- немного выше центра экрана
OpenButton.Position = UDim2.new(0.5, -27, 0.5, -95)

OpenButton.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
OpenButton.BackgroundTransparency = 0.05
OpenButton.BorderSizePixel = 0
OpenButton.Text = "A"
OpenButton.TextColor3 = Color3.fromRGB(235, 235, 235)
OpenButton.TextSize = 20
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 13)
ButtonCorner.Parent = OpenButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(70, 70, 75)
ButtonStroke.Thickness = 1
ButtonStroke.Transparency = 0.25
ButtonStroke.Parent = OpenButton

local ButtonScale = Instance.new("UIScale")
ButtonScale.Scale = 0.75
ButtonScale.Parent = OpenButton

-- Плавное появление кнопки
TweenService:Create(
	ButtonScale,
	TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{Scale = 1}
):Play()

--==================================================
-- BUTTON HOVER ANIMATION
--==================================================

OpenButton.MouseEnter:Connect(function()
	TweenService:Create(
		ButtonScale,
		TWEEN_FAST,
		{Scale = 1.08}
	):Play()

	TweenService:Create(
		ButtonStroke,
		TWEEN_FAST,
		{
			Transparency = 0,
			Thickness = 1.5
		}
	):Play()
end)

OpenButton.MouseLeave:Connect(function()
	TweenService:Create(
		ButtonScale,
		TWEEN_FAST,
		{Scale = 1}
	):Play()

	TweenService:Create(
		ButtonStroke,
		TWEEN_FAST,
		{
			Transparency = 0.25,
			Thickness = 1
		}
	):Play()
end)

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = MENU_SIZE
Main.Position = UDim2.new(0.5, -325, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 16)
Main.BackgroundTransparency = 0.02
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 48)
MainStroke.Transparency = 0.35
MainStroke.Thickness = 1
MainStroke.Parent = Main

local MainScale = Instance.new("UIScale")
MainScale.Scale = 0.94
MainScale.Parent = Main

--==================================================
-- HEADER
--==================================================

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(52, 14)
Title.Size = UDim2.fromOffset(250, 28)
Title.Text = "Apex Hub"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextSize = 17
Title.Font = Enum.Font.GothamMedium
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(53, 38)
Subtitle.Size = UDim2.fromOffset(250, 22)
Subtitle.Text = "Murder Mystery 2"
Subtitle.TextColor3 = Color3.fromRGB(105, 105, 108)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Main

-- маленький декоративный логотип
local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(30, 30)
Logo.Position = UDim2.fromOffset(17, 17)
Logo.BackgroundColor3 = Color3.fromRGB(22, 35, 48)
Logo.BorderSizePixel = 0
Logo.Parent = Main

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 8)
LogoCorner.Parent = Logo

local LogoText = Instance.new("TextLabel")
LogoText.BackgroundTransparency = 1
LogoText.Size = UDim2.fromScale(1, 1)
LogoText.Text = "A"
LogoText.TextColor3 = Color3.fromRGB(90, 150, 220)
LogoText.TextSize = 15
LogoText.Font = Enum.Font.GothamBold
LogoText.Parent = Logo

--==================================================
-- SEARCH
--==================================================

local Search = Instance.new("TextBox")
Search.Size = UDim2.fromOffset(165, 34)
Search.Position = UDim2.new(1, -214, 0, 16)
Search.BackgroundColor3 = Color3.fromRGB(9, 9, 10)
Search.BorderSizePixel = 0
Search.Text = ""
Search.PlaceholderText = "Search..."
Search.PlaceholderColor3 = Color3.fromRGB(90, 90, 93)
Search.TextColor3 = Color3.fromRGB(210, 210, 210)
Search.TextSize = 12
Search.Font = Enum.Font.Gotham
Search.Parent = Main

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = Search

--==================================================
-- CLOSE BUTTON
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(34, 34)
Close.Position = UDim2.new(1, -45, 0, 16)
Close.BackgroundColor3 = Color3.fromRGB(25, 25, 27)
Close.BorderSizePixel = 0
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(180, 180, 183)
Close.TextSize = 13
Close.Font = Enum.Font.GothamMedium
Close.AutoButtonColor = false
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

--==================================================
-- PANELS
--==================================================

local function createPanel(name, position)
	local panel = Instance.new("Frame")
	panel.Name = name
	panel.Size = UDim2.fromOffset(305, 345)
	panel.Position = position
	panel.BackgroundColor3 = Color3.fromRGB(10, 10, 11)
	panel.BorderSizePixel = 0
	panel.Parent = Main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = panel

	return panel
end

local ESPPanel = createPanel(
	"ESPPanel",
	UDim2.fromOffset(18, 79)
)

local MovementPanel = createPanel(
	"MovementPanel",
	UDim2.fromOffset(327, 79)
)

--==================================================
-- PANEL HEADERS
--==================================================

local function panelHeader(panel, text)
	local accent = Instance.new("Frame")
	accent.Size = UDim2.fromOffset(3, 17)
	accent.Position = UDim2.fromOffset(13, 12)
	accent.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	accent.BorderSizePixel = 0
	accent.Parent = panel

	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(1, 0)
	accentCorner.Parent = accent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(24, 7)
	label.Size = UDim2.fromOffset(220, 28)
	label.Text = text
	label.TextColor3 = Color3.fromRGB(215, 215, 215)
	label.TextSize = 13
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = panel

	local arrow = Instance.new("TextLabel")
	arrow.BackgroundTransparency = 1
	arrow.Position = UDim2.new(1, -31, 0, 9)
	arrow.Size = UDim2.fromOffset(20, 25)
	arrow.Text = "⌄"
	arrow.TextColor3 = Color3.fromRGB(100, 100, 103)
	arrow.TextSize = 15
	arrow.Font = Enum.Font.Gotham
	arrow.Parent = panel

	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, -28, 0, 1)
	line.Position = UDim2.fromOffset(14, 36)
	line.BackgroundColor3 = Color3.fromRGB(40, 40, 42)
	line.BorderSizePixel = 0
	line.Parent = panel
end

panelHeader(ESPPanel, "ESP")
panelHeader(MovementPanel, "Movement")

--==================================================
-- DECORATIVE TOGGLE
--==================================================

local function addVisualToggle(panel, text, y)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(15, y)
	label.Size = UDim2.fromOffset(190, 34)
	label.Text = text
	label.TextColor3 = Color3.fromRGB(190, 190, 192)
	label.TextSize = 12
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = panel

	local toggle = Instance.new("Frame")
	toggle.Size = UDim2.fromOffset(45, 24)
	toggle.Position = UDim2.new(1, -57, 0, y + 4)
	toggle.BackgroundColor3 = Color3.fromRGB(85, 85, 92)
	toggle.BorderSizePixel = 0
	toggle.Parent = panel

	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = toggle

	local circle = Instance.new("Frame")
	circle.Size = UDim2.fromOffset(18, 18)
	circle.Position = UDim2.fromOffset(3, 3)
	circle.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	circle.BorderSizePixel = 0
	circle.Parent = toggle

	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(1, 0)
	cc.Parent = circle

	-- намеренно НЕТ MouseButton1Click:
	-- переключатель полностью декоративный
end

-- Left panel
addVisualToggle(ESPPanel, "Role ESP", 50)
addVisualToggle(ESPPanel, "Enable Role ESP", 84)
addVisualToggle(ESPPanel, "Gun ESP", 118)
addVisualToggle(ESPPanel, "Tracers", 178)
addVisualToggle(ESPPanel, "Box ESP", 238)

-- Right panel
addVisualToggle(MovementPanel, "No Clip", 50)
addVisualToggle(MovementPanel, "Infinite Jumps", 88)
addVisualToggle(MovementPanel, "Anti-Fling", 126)
addVisualToggle(MovementPanel, "Bomb Jump", 164)
addVisualToggle(MovementPanel, "Fly", 224)
addVisualToggle(MovementPanel, "Fly Animation", 284)

--==================================================
-- DECORATIVE DROPDOWN
--==================================================

local function addDropdown(panel, text, value, y)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(15, y)
	label.Size = UDim2.fromOffset(150, 30)
	label.Text = text
	label.TextColor3 = Color3.fromRGB(175, 175, 178)
	label.TextSize = 12
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = panel

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Position = UDim2.new(1, -105, 0, y)
	valueLabel.Size = UDim2.fromOffset(75, 30)
	valueLabel.Text = value
	valueLabel.TextColor3 = Color3.fromRGB(165, 165, 168)
	valueLabel.TextSize = 11
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = panel
end

addDropdown(ESPPanel, "Role ESP Style", "Default", 145)
addDropdown(ESPPanel, "Origin", "Bottom", 205)
addDropdown(ESPPanel, "Style", "Full", 265)

addDropdown(MovementPanel, "Auto Bomb Jump", "None", 202)
addDropdown(MovementPanel, "Fly Speed", "60", 260)

--==================================================
-- MENU ANIMATION
--==================================================

local menuOpen = false

local function openMenu()
	if menuOpen then
		return
	end

	menuOpen = true
	Main.Visible = true
	MainScale.Scale = 0.94
	Main.BackgroundTransparency = 0.3

	TweenService:Create(
		MainScale,
		TWEEN_MENU,
		{Scale = 1}
	):Play()

	TweenService:Create(
		Main,
		TWEEN_MENU,
		{BackgroundTransparency = 0.02}
	):Play()
end

local function closeMenu()
	if not menuOpen then
		return
	end

	menuOpen = false

	local scaleTween = TweenService:Create(
		MainScale,
		TWEEN_MENU,
		{Scale = 0.94}
	)

	local fadeTween = TweenService:Create(
		Main,
		TWEEN_MENU,
		{BackgroundTransparency = 0.3}
	)

	scaleTween:Play()
	fadeTween:Play()

	scaleTween.Completed:Once(function()
		if not menuOpen then
			Main.Visible = false
		end
	end)
end

OpenButton.MouseButton1Click:Connect(function()
	if menuOpen then
		closeMenu()
	else
		openMenu()
	end
end)

Close.MouseButton1Click:Connect(function()
	closeMenu()
end)

--==================================================
-- DRAGGABLE GUI BUTTON
--==================================================

local dragging = false
local dragStart
local startPosition

OpenButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = OpenButton.Position
	end
end)

OpenButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - dragStart

	OpenButton.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

--==================================================
-- DRAGGABLE MAIN WINDOW
--==================================================

local windowDragging = false
local windowDragStart
local windowStartPosition

local function startWindowDrag(input)
	windowDragging = true
	windowDragStart = input.Position
	windowStartPosition = Main.Position
end

Main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		startWindowDrag(input)
	end
end)

Main.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		windowDragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not windowDragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local delta = input.Position - windowDragStart

	Main.Position = UDim2.new(
		windowStartPosition.X.Scale,
		windowStartPosition.X.Offset + delta.X,
		windowStartPosition.Y.Scale,
		windowStartPosition.Y.Offset + delta.Y
	)
end)
