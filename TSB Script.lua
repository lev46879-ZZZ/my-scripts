-- ============================================
-- 🎨 КРАСИВОЕ GUI МЕНЮ С ПЛАВНЫМИ АНИМАЦИЯМИ
-- ============================================
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Настройки анимаций
local TWEEN_INFO_SMOOTH = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_INFO_FAST   = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_INFO_BOUNCE = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_INFO_OPEN   = TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- ============================================
-- 🖼️ СОЗДАНИЕ SCREEN GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BeautifulMenuGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- ============================================
-- 🎯 КНОПКА ОТКРЫТИЯ МЕНЮ
-- ============================================
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 70, 0, 70)
openButton.Position = UDim2.new(0, 30, 0.5, -35)
openButton.AnchorPoint = Vector2.new(0, 0.5)
openButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
openButton.BorderSizePixel = 0
openButton.Text = ""
openButton.AutoButtonColor = false
openButton.Parent = screenGui

local openCorner = Instance.new("UICorner", openButton)
openCorner.CornerRadius = UDim.new(0, 18)

local openStroke = Instance.new("UIStroke", openButton)
openStroke.Thickness = 2
openStroke.Color = Color3.fromRGB(138, 92, 246)
openStroke.Transparency = 0.3

local openGradient = Instance.new("UIGradient", openButton)
openGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 102, 241)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 85, 247))
})
openGradient.Rotation = 45

local openIcon = Instance.new("TextLabel", openButton)
openIcon.Size = UDim2.new(1, 0, 1, 0)
openIcon.BackgroundTransparency = 1
openIcon.Text = "☰"
openIcon.TextSize = 34
openIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
openIcon.Font = Enum.Font.GothamBold

-- Тень под кнопкой
local openShadow = Instance.new("ImageLabel", openButton)
openShadow.Name = "Shadow"
openShadow.Size = UDim2.new(1.4, 0, 1.4, 0)
openShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
openShadow.AnchorPoint = Vector2.new(0.5, 0.5)
openShadow.BackgroundTransparency = 1
openShadow.Image = "rbxassetid://5554236805"
openShadow.ImageColor3 = Color3.fromRGB(99, 102, 241)
openShadow.ImageTransparency = 0.5
openShadow.ZIndex = -1

-- Пульсация кнопки
task.spawn(function()
	while openButton.Parent do
		TweenService:Create(openStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Transparency = 0.7
		}):Play()
		task.wait(1.5)
		TweenService:Create(openStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Transparency = 0.2
		}):Play()
		task.wait(1.5)
	end
end)

-- Hover эффект
openButton.MouseEnter:Connect(function()
	TweenService:Create(openButton, TWEEN_INFO_FAST, {Size = UDim2.new(0, 78, 0, 78)}):Play()
	TweenService:Create(openStroke, TWEEN_INFO_FAST, {Thickness = 3, Transparency = 0}):Play()
end)

openButton.MouseLeave:Connect(function()
	TweenService:Create(openButton, TWEEN_INFO_FAST, {Size = UDim2.new(0, 70, 0, 70)}):Play()
	TweenService:Create(openStroke, TWEEN_INFO_FAST, {Thickness = 2, Transparency = 0.3}):Play()
end)

-- ============================================
-- 🌫️ ЗАТЕМНЕНИЕ ФОНА (BLUR + OVERLAY)
-- ============================================
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "MenuBlur"
blurEffect.Size = 0
blurEffect.Parent = game.Workspace.CurrentCamera

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.ZIndex = 5
overlay.Parent = screenGui

-- ============================================
-- 📦 ГЛАВНОЕ МЕНЮ
-- ============================================
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 480, 0, 540)
menuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
menuFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
menuFrame.BackgroundTransparency = 0.15
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ZIndex = 10
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner", menuFrame)
menuCorner.CornerRadius = UDim.new(0, 24)

local menuStroke = Instance.new("UIStroke", menuFrame)
menuStroke.Thickness = 1.5
menuStroke.Color = Color3.fromRGB(138, 92, 246)
menuStroke.Transparency = 0.5

-- Градиентная рамка
local menuGradient = Instance.new("UIGradient", menuStroke)
menuGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 102, 241)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(168, 85, 247)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(236, 72, 153))
})

-- Тень меню
local menuShadow = Instance.new("ImageLabel", menuFrame)
menuShadow.Name = "Shadow"
menuShadow.Size = UDim2.new(1.2, 0, 1.2, 0)
menuShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
menuShadow.AnchorPoint = Vector2.new(0.5, 0.5)
menuShadow.BackgroundTransparency = 1
menuShadow.Image = "rbxassetid://5554236805"
menuShadow.ImageColor3 = Color3.fromRGB(99, 102, 241)
menuShadow.ImageTransparency = 0.4
menuShadow.ZIndex = -1

-- ============================================
-- 🎨 ШАПКА МЕНЮ
-- ============================================
local header = Instance.new("Frame", menuFrame)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 90)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
header.BorderSizePixel = 0
header.ZIndex = 11

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 24)

-- Градиент шапки
local headerGradient = Instance.new("UIGradient", header)
headerGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 102, 241)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 85, 247))
})
headerGradient.Rotation = 90

-- Заголовок
local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 30, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✨ Главное Меню"
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12

-- Подзаголовок
local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(1, -80, 0, 20)
subtitle.Position = UDim2.new(0, 30, 1, -35)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Добро пожаловать, " .. player.Name
subtitle.TextSize = 14
subtitle.TextColor3 = Color3.fromRGB(200, 200, 220)
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 12

-- Кнопка закрытия (X)
local closeButton = Instance.new("TextButton", header)
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -55, 0.5, -20)
closeButton.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
closeButton.BackgroundTransparency = 0.2
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextSize = 20
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.AutoButtonColor = false
closeButton.ZIndex = 12

local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0, 12)

closeButton.MouseEnter:Connect(function()
	TweenService:Create(closeButton, TWEEN_INFO_FAST, {BackgroundTransparency = 0, Rotation = 90}):Play()
end)
closeButton.MouseLeave:Connect(function()
	TweenService:Create(closeButton, TWEEN_INFO_FAST, {BackgroundTransparency = 0.2, Rotation = 0}):Play()
end)

-- ============================================
-- 📋 КОНТЕНТ МЕНЮ (КНОПКИ)
-- ============================================
local content = Instance.new("ScrollingFrame", menuFrame)
content.Name = "Content"
content.Size = UDim2.new(1, -40, 1, -110)
content.Position = UDim2.new(0, 20, 0, 100)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Color3.fromRGB(138, 92, 246)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ZIndex = 11

local listLayout = Instance.new("UIListLayout", content)
listLayout.Padding = UDim.new(0, 12)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Функция создания красивой кнопки меню
local menuButtons = {}
local function createMenuButton(text, icon, order, color1, color2)
	local btn = Instance.new("TextButton")
	btn.Name = text
	btn.Size = UDim2.new(1, 0, 0, 60)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	btn.BackgroundTransparency = 0.3
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.LayoutOrder = order
	btn.ZIndex = 11
	btn.Parent = content

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 14)

	local stroke = Instance.new("UIStroke", btn)
	stroke.Thickness = 1.5
	stroke.Color = color1
	stroke.Transparency = 0.7

	local gradient = Instance.new("UIGradient", btn)
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(1, color2)
	})
	gradient.Rotation = 90
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.85),
		NumberSequenceKeypoint.new(1, 0.95)
	})

	-- Иконка
	local iconLabel = Instance.new("TextLabel", btn)
	iconLabel.Size = UDim2.new(0, 50, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = icon
	iconLabel.TextSize = 26
	iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.ZIndex = 12

	-- Текст
	local textLabel = Instance.new("TextLabel", btn)
	textLabel.Size = UDim2.new(1, -70, 1, 0)
	textLabel.Position = UDim2.new(0, 60, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextSize = 18
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Font = Enum.Font.GothamSemibold
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 12

	-- Стрелка справа
	local arrow = Instance.new("TextLabel", btn)
	arrow.Size = UDim2.new(0, 30, 1, 0)
	arrow.Position = UDim2.new(1, -40, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "›"
	arrow.TextSize = 28
	arrow.TextColor3 = Color3.fromRGB(200, 200, 220)
	arrow.Font = Enum.Font.GothamBold
	arrow.ZIndex = 12

	-- Hover анимация
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TWEEN_INFO_FAST, {BackgroundTransparency = 0.1}):Play()
		TweenService:Create(stroke, TWEEN_INFO_FAST, {Transparency = 0.2, Thickness = 2}):Play()
		TweenService:Create(arrow, TWEEN_INFO_FAST, {Position = UDim2.new(1, -30, 0, 0)}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TWEEN_INFO_FAST, {BackgroundTransparency = 0.3}):Play()
		TweenService:Create(stroke, TWEEN_INFO_FAST, {Transparency = 0.7, Thickness = 1.5}):Play()
		TweenService:Create(arrow, TWEEN_INFO_FAST, {Position = UDim2.new(1, -40, 0, 0)}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		-- Анимация нажатия
		TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 55)}):Play()
		task.wait(0.1)
		TweenService:Create(btn, TWEEN_INFO_FAST, {Size = UDim2.new(1, 0, 0, 60)}):Play()
		print("🎯 Нажата кнопка: " .. text)
	end)

	table.insert(menuButtons, btn)
	return btn
end

-- Создаём красивые кнопки
createMenuButton("Игрок",      "👤", 1, Color3.fromRGB(99, 102, 241),  Color3.fromRGB(139, 92, 246))
createMenuButton("Настройки",  "⚙️", 2, Color3.fromRGB(168, 85, 247),  Color3.fromRGB(219, 39, 119))
createMenuButton("Инвентарь",  "🎒", 3, Color3.fromRGB(236, 72, 153),  Color3.fromRGB(244, 114, 182))
createMenuButton("Магазин",    "🛒", 4, Color3.fromRGB(34, 197, 94),   Color3.fromRGB(16, 185, 129))
createMenuButton("Друзья",     "💬", 5, Color3.fromRGB(59, 130, 246),  Color3.fromRGB(37, 99, 235))
createMenuButton("Достижения", "🏆", 6, Color3.fromRGB(245, 158, 11),  Color3.fromRGB(234, 88, 12))

-- ============================================
-- 🎬 АНИМАЦИЯ ОТКРЫТИЯ
-- ============================================
local isOpen = false

local function openMenu()
	if isOpen then return end
	isOpen = true

	menuFrame.Visible = true
	menuFrame.Size = UDim2.new(0, 400, 0, 450)
	menuFrame.Position = UDim2.new(0.5, 0, 0.5, 30)
	menuFrame.BackgroundTransparency = 1

	-- Сбрасываем прозрачность кнопок
	for _, btn in ipairs(menuButtons) do
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.new(0.8, 0, 0, 0)
	end

	-- Плавное появление меню
	TweenService:Create(menuFrame, TWEEN_INFO_OPEN, {
		Size = UDim2.new(0, 480, 0, 540),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 0.15
	}):Play()

	-- Blur
	TweenService:Create(blurEffect, TWEEN_INFO_SMOOTH, {Size = 20}):Play()

	-- Затемнение
	TweenService:Create(overlay, TWEEN_INFO_SMOOTH, {BackgroundTransparency = 0.5}):Play()

	-- Stagger анимация кнопок (появляются по очереди)
	for i, btn in ipairs(menuButtons) do
		task.delay(0.15 + (i - 1) * 0.07, function()
			TweenService:Create(btn, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, 0, 0, 60)
			}):Play()
		end)
	end
end

-- ============================================
-- 🎬 АНИМАЦИЯ ЗАКРЫТИЯ
-- ============================================
local function closeMenu()
	if not isOpen then return end
	isOpen = false

	-- Обратный stagger кнопок
	for i = #menuButtons, 1, -1 do
		local btn = menuButtons[i]
		task.delay((#menuButtons - i) * 0.04, function()
			TweenService:Create(btn, TWEEN_INFO_FAST, {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.8, 0, 0, 0)
			}):Play()
		end)
	end

	-- Закрытие меню
	TweenService:Create(menuFrame, TWEEN_INFO_FAST, {
		Size = UDim2.new(0, 400, 0, 450),
		Position = UDim2.new(0.5, 0, 0.5, 30),
		BackgroundTransparency = 1
	}):Play()

	TweenService:Create(blurEffect, TWEEN_INFO_FAST, {Size = 0}):Play()
	TweenService:Create(overlay, TWEEN_INFO_FAST, {BackgroundTransparency = 1}):Play()

	task.delay(0.5, function()
		menuFrame.Visible = false
	end)
end

-- ============================================
-- 🔘 ОБРАБОТЧИКИ СОБЫТИЙ
-- ============================================
openButton.MouseButton1Click:Connect(openMenu)
closeButton.MouseButton1Click:Connect(closeMenu)

-- Закрытие по клику на оверлей
overlay.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		closeMenu()
	end
end)

-- Закрытие по клавише ESC или M
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.M then
		if isOpen then closeMenu() else openMenu() end
	end
end)

-- ============================================
-- ✨ АНИМАЦИЯ ПОЯВЛЕНИЯ КНОПКИ ПРИ СТАРТЕ
-- ============================================
task.spawn(function()
	openButton.Size = UDim2.new(0, 0, 0, 0)
	openButton.BackgroundTransparency = 1
	task.wait(0.5)
	TweenService:Create(openButton, TWEEN_INFO_BOUNCE, {
		Size = UDim2.new(0, 70, 0, 70),
		BackgroundTransparency = 0
	}):Play()
end)

print("✅ Красивое GUI меню загружено! Нажми на кнопку слева или клавишу M")
