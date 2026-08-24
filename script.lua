--// ApexVHub
--// VISUAL UI ONLY

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local MENU_WIDTH = 760
local MENU_HEIGHT = 470

local DARK = Color3.fromRGB(14, 14, 15)
local DARKER = Color3.fromRGB(10, 10, 11)
local SIDEBAR = Color3.fromRGB(13, 13, 14)
local BUTTON = Color3.fromRGB(25, 25, 27)
local BUTTON_HOVER = Color3.fromRGB(31, 31, 34)
local TEXT = Color3.fromRGB(225, 225, 228)
local SUBTEXT = Color3.fromRGB(115, 115, 120)

local FAST = TweenInfo.new(
	0.15,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

local MENU_TWEEN = TweenInfo.new(
	0.28,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

--==================================================
-- SCREEN GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "ApexVHub"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = playerGui

--==================================================
-- FLOATING GUI BUTTON
--==================================================

local HubButton = Instance.new("TextButton")
HubButton.Name = "ApexVHubButton"
HubButton.Size = UDim2.fromOffset(62, 62)

-- Изначально немного выше центра экрана
HubButton.Position = UDim2.new(0.5, -31, 0.5, -125)

HubButton.BackgroundColor3 = DARK
HubButton.BorderSizePixel = 0
HubButton.Text = "ApexVHub"
HubButton.TextColor3 = TEXT
HubButton.TextSize = 10
HubButton.Font = Enum.Font.GothamMedium
HubButton.AutoButtonColor = false
HubButton.ZIndex = 100
HubButton.Parent = Gui

local HubCorner = Instance.new("UICorner")
HubCorner.CornerRadius = UDim.new(0, 14)
HubCorner.Parent = HubButton

local HubStroke = Instance.new("UIStroke")
HubStroke.Color = Color3.fromRGB(70, 70, 75)
HubStroke.Thickness = 1
HubStroke.Transparency = 0.25
HubStroke.Parent = HubButton

local HubScale = Instance.new("UIScale")
HubScale.Scale = 0.75
HubScale.Parent = HubButton

-- Появление кнопки
TweenService:Create(
	HubScale,
	TweenInfo.new(
		0.45,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out
	),
	{Scale = 1}
):Play()

--==================================================
-- BUTTON HOVER
--==================================================

HubButton.MouseEnter:Connect(function()

	TweenService:Create(
		HubScale,
		FAST,
		{Scale = 1.08}
	):Play()

	TweenService:Create(
		HubStroke,
		FAST,
		{
			Transparency = 0,
			Thickness = 1.5
		}
	):Play()

end)

HubButton.MouseLeave:Connect(function()

	TweenService:Create(
		HubScale,
		FAST,
		{Scale = 1}
	):Play()

	TweenService:Create(
		HubStroke,
		FAST,
		{
			Transparency = 0.25,
			Thickness = 1
		}
	):Play()

end)

--==================================================
-- MAIN MENU
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(MENU_WIDTH, MENU_HEIGHT)
Main.Position = UDim2.new(
	0.5,
	-MENU_WIDTH / 2,
	0.5,
	-MENU_HEIGHT / 2
)

Main.BackgroundColor3 = DARK
Main.BorderSizePixel = 0
Main.Visible = false
Main.ZIndex = 10
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 13)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(47, 47, 50)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.35
MainStroke.Parent = Main

local MainScale = Instance.new("UIScale")
MainScale.Scale = 0.94
MainScale.Parent = Main

--==================================================
-- HEADER
--==================================================

local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(34, 34)
Logo.Position = UDim2.fromOffset(18, 17)
Logo.BackgroundColor3 = Color3.fromRGB(24, 31, 43)
Logo.BorderSizePixel = 0
Logo.Parent = Main

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 9)
LogoCorner.Parent = Logo

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.fromScale(1, 1)
LogoText.BackgroundTransparency = 1
LogoText.Text = "A"
LogoText.TextColor3 = Color3.fromRGB(135, 150, 255)
LogoText.TextSize = 18
LogoText.Font = Enum.Font.GothamBold
LogoText.Parent = Logo

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(300, 27)
Title.Position = UDim2.fromOffset(62, 14)
Title.BackgroundTransparency = 1
Title.Text = "ApexVHub"
Title.TextColor3 = TEXT
Title.TextSize = 18
Title.Font = Enum.Font.GothamMedium
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.fromOffset(300, 22)
Subtitle.Position = UDim2.fromOffset(63, 37)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Murder Mystery 2"
Subtitle.TextColor3 = SUBTEXT
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Main

--==================================================
-- CLOSE BUTTON
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(38, 38)
Close.Position = UDim2.new(1, -54, 0, 16)
Close.BackgroundColor3 = BUTTON
Close.BorderSizePixel = 0
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(190, 190, 194)
Close.TextSize = 14
Close.Font = Enum.Font.GothamMedium
Close.AutoButtonColor = false
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 9)
CloseCorner.Parent = Close

Close.MouseEnter:Connect(function()

	TweenService:Create(
		Close,
		FAST,
		{
			BackgroundColor3 = BUTTON_HOVER,
			TextColor3 = Color3.fromRGB(245, 245, 245)
		}
	):Play()

end)

Close.MouseLeave:Connect(function()

	TweenService:Create(
		Close,
		FAST,
		{
			BackgroundColor3 = BUTTON,
			TextColor3 = Color3.fromRGB(190, 190, 194)
		}
	):Play()

end)

--==================================================
-- CONTENT BACKGROUND
--==================================================

local ContentBackground = Instance.new("Frame")
ContentBackground.Name = "ContentBackground"
ContentBackground.Size = UDim2.new(1, -36, 1, -93)
ContentBackground.Position = UDim2.fromOffset(18, 76)
ContentBackground.BackgroundTransparency = 1
ContentBackground.Parent = Main

--==================================================
-- LEFT SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.fromOffset(178, 375)
Sidebar.Position = UDim2.fromOffset(0, 0)
Sidebar.BackgroundColor3 = SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.Parent = ContentBackground

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 9)
SidebarCorner.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 9)
SidebarPadding.PaddingRight = UDim.new(0, 9)
SidebarPadding.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 7)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = Sidebar

--==================================================
-- EMPTY TABS
--==================================================

local function createEmptyTab(name, order, selected)

	local Tab = Instance.new("TextButton")
	Tab.Name = name
	Tab.Size = UDim2.new(1, 0, 0, 36)
	Tab.LayoutOrder = order
	Tab.BackgroundColor3 = selected
		and Color3.fromRGB(29, 29, 31)
		or Color3.fromRGB(18, 18, 19)

	Tab.BorderSizePixel = 0

	-- Вкладки пустые: никаких функций внутри
	Tab.Text = ""
	Tab.AutoButtonColor = false

	Tab.Parent = Sidebar

	local TabCorner = Instance.new("UICorner")
	TabCorner.CornerRadius = UDim.new(0, 7)
	TabCorner.Parent = Tab

	-- Левая полоска активной вкладки
	if selected then

		local Accent = Instance.new("Frame")
		Accent.Size = UDim2.fromOffset(3, 28)
		Accent.Position = UDim2.fromOffset(0, 4)
		Accent.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
		Accent.BorderSizePixel = 0
		Accent.Parent = Tab

		local AccentCorner = Instance.new("UICorner")
		AccentCorner.CornerRadius = UDim.new(1, 0)
		AccentCorner.Parent = Accent

	end

	-- Только визуальная hover-анимация
	Tab.MouseEnter:Connect(function()

		if not selected then

			TweenService:Create(
				Tab,
				FAST,
				{
					BackgroundColor3 = Color3.fromRGB(23, 23, 25)
				}
			):Play()

		end

	end)

	Tab.MouseLeave:Connect(function()

		if not selected then

			TweenService:Create(
				Tab,
				FAST,
				{
					BackgroundColor3 = Color3.fromRGB(18, 18, 19)
				}
			):Play()

		end

	end)

	return Tab
end

-- Пустые вкладки
createEmptyTab("Tab1", 1, true)
createEmptyTab("Tab2", 2, false)
createEmptyTab("Tab3", 3, false)
createEmptyTab("Tab4", 4, false)
createEmptyTab("Tab5", 5, false)
createEmptyTab("Tab6", 6, false)
createEmptyTab("Tab7", 7, false)
createEmptyTab("Tab8", 8, false)
createEmptyTab("Tab9", 9, false)

--==================================================
-- EMPTY MAIN CONTENT
--==================================================

local EmptyContent = Instance.new("Frame")
EmptyContent.Name = "EmptyContent"
EmptyContent.Size = UDim2.new(
	1,
	-193,
	1,
	0
)

EmptyContent.Position = UDim2.fromOffset(193, 0)

EmptyContent.BackgroundColor3 = DARKER
EmptyContent.BorderSizePixel = 0
EmptyContent.Parent = ContentBackground

local EmptyCorner = Instance.new("UICorner")
EmptyCorner.CornerRadius = UDim.new(0, 9)
EmptyCorner.Parent = EmptyContent

-- Никаких кнопок, ESP, переключателей,
-- настроек или функций внутри.
-- Область намеренно полностью пустая.

--==================================================
-- MENU OPEN / CLOSE
--==================================================

local MenuOpen = false

local function OpenMenu()

	if MenuOpen then
		return
	end

	MenuOpen = true

	Main.Visible = true
	MainScale.Scale = 0.94
	Main.BackgroundTransparency = 0.2

	-- Кнопка находится поверх меню
	HubButton.ZIndex = 100

	TweenService:Create(
		MainScale,
		MENU_TWEEN,
		{Scale = 1}
	):Play()

	TweenService:Create(
		Main,
		MENU_TWEEN,
		{BackgroundTransparency = 0}
	):Play()

end

local function CloseMenu()

	if not MenuOpen then
		return
	end

	MenuOpen = false

	TweenService:Create(
		MainScale,
		MENU_TWEEN,
		{Scale = 0.94}
	):Play()

	local fade = TweenService:Create(
		Main,
		MENU_TWEEN,
		{BackgroundTransparency = 0.25}
	)

	fade:Play()

	fade.Completed:Once(function()

		if not MenuOpen then
			Main.Visible = false
		end

	end)

end

HubButton.MouseButton1Click:Connect(function()

	if MenuOpen then
		CloseMenu()
	else
		OpenMenu()
	end

end)

Close.MouseButton1Click:Connect(function()
	CloseMenu()
end)

--==================================================
-- DRAG GUI BUTTON
--==================================================

local ButtonDragging = false
local ButtonDragStart
local ButtonStartPosition

HubButton.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		ButtonDragging = true
		ButtonDragStart = input.Position
		ButtonStartPosition = HubButton.Position

	end

end)

HubButton.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		ButtonDragging = false

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not ButtonDragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local Delta = input.Position - ButtonDragStart

	HubButton.Position = UDim2.new(
		ButtonStartPosition.X.Scale,
		ButtonStartPosition.X.Offset + Delta.X,
		ButtonStartPosition.Y.Scale,
		ButtonStartPosition.Y.Offset + Delta.Y
	)

end)

--==================================================
-- DRAG MAIN MENU
--==================================================

local MenuDragging = false
local MenuDragStart
local MenuStartPosition

Main.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		MenuDragging = true
		MenuDragStart = input.Position
		MenuStartPosition = Main.Position

	end

end)

Main.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuDragging = false
	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not MenuDragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local Delta = input.Position - MenuDragStart

	Main.Position = UDim2.new(
		MenuStartPosition.X.Scale,
		MenuStartPosition.X.Offset + Delta.X,
		MenuStartPosition.Y.Scale,
		MenuStartPosition.Y.Offset + Delta.Y
	)

end)
