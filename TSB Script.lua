-- ============================================
-- 💜 ПУРПУРНОЕ GUI МЕНЮ С ДОЖДЁМ
-- ============================================
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Пурпурные цвета
local PURPLE_DARK = Color3.fromRGB(25, 15, 40)
local PURPLE_MAIN = Color3.fromRGB(138, 43, 226)
local PURPLE_LIGHT = Color3.fromRGB(186, 85, 255)
local PURPLE_GLOW = Color3.fromRGB(218, 112, 255)
local PURPLE_DEEP = Color3.fromRGB(75, 0, 130)

-- Настройки анимаций
local TWEEN_INFO_SMOOTH = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_INFO_FAST   = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_INFO_BOUNCE = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_INFO_OPEN   = TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- ============================================
-- 🖼️ СОЗДАНИЕ SCREEN GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PurpleMenuGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- ============================================
-- 🌧️ СИСТЕМА ДОЖДЯ
-- ============================================
local rainContainer = Instance.new("Frame")
rainContainer.Name = "RainContainer"
rainContainer.Size = UDim2.new(1, 0, 1, 0)
rainContainer.BackgroundTransparency = 1
rainContainer.ClipsDescendants = true
rainContainer.ZIndex = 1
rainContainer.Parent = screenGui

local rainDrops = {}
local RAIN_COUNT = 80

-- Создание капель дождя
for i = 1, RAIN_COUNT do
	local drop = Instance.new("Frame")
	drop.Name = "RainDrop"
	drop.Size = UDim2.new(0, 2, 0, math.random(15, 35))
	drop.BackgroundColor3 = PURPLE_LIGHT
	drop.BackgroundTransparency = math.random(40, 70) / 100
	drop.BorderSizePixel = 0
	drop.Rotation = math.random(-5, 5)
	drop.ZIndex = 2
	
	local corner = Instance.new("UICorner", drop)
	corner.CornerRadius = UDim.new(1, 0)
	
	drop.Parent = rainContainer
	
	table.insert(rainDrops, {
		frame = drop,
		speed = math.random(8, 15),
		startX = math.random(0, 100),
		offset = math.random(0, 100) / 100
	})
end

-- Анимация дождя
task.spawn(function()
	while rainContainer.Parent do
		for _, dropData in ipairs(rainDrops) do
			local drop = dropData.frame
			local currentPos = drop.Position.Y.Scale
			
			-- Движение вниз
			currentPos = currentPos + (dropData.speed / 1000)
			
			-- Сброс позиции если вышла за экран
			if currentPos > 1.1 then
				currentPos = -0.1
				drop.Position = UDim2.new(
					dropData.startX / 100 + math.random(-10, 10) / 100,
					0,
					currentPos,
					0
				)
			else
				drop.Position = UDim2.new(
					drop.Position.X.Scale,
					0,
					currentPos,
					0
				)
			end
		end
		task.wait()
	end
end)

-- ============================================
-- 🎯 КНОПКА ОТКРЫТИЯ/ЗАКРЫТИЯ МЕНЮ
-- ============================================
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 70, 0, 70)
toggleButton.Position = UDim2.new(0, 30, 0.5, -35)
toggleButton.AnchorPoint = Vector2.new(0, 0.5)
toggleButton.BackgroundColor3 = PURPLE_DARK
toggleButton.BorderSizePixel = 0
toggleButton.Text = ""
toggleButton.AutoButtonColor = false
toggleButton.Parent = screenGui

local toggleCorner = Instance.new("UICorner", toggleButton)
toggleCorner.CornerRadius = UDim.new(0, 18)

local toggleStroke = Instance.new("UIStroke", toggleButton)
toggleStroke.Thickness = 2
toggleStroke.Color = PURPLE_MAIN
toggleStroke.Transparency = 0.3

local toggleGradient = Instance.new("UIGradient", toggleButton)
toggleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, PURPLE_DEEP),
	ColorSequenceKeypoint.new(1, PURPLE_MAIN)
})
toggleGradient.Rotation = 45

local toggleIcon = Instance.new("TextLabel", toggleButton)
toggleIcon.Size = UDim2.new(1, 0, 1, 0)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Text = "☰"
toggleIcon.TextSize = 34
toggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleIcon.Font = Enum.Font.GothamBold

-- Тень под кнопкой
local toggleShadow = Instance.new("ImageLabel", toggleButton)
toggleShadow.Name = "Shadow"
toggleShadow.Size = UDim2.new(1.4, 0, 1.4, 0)
toggleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
toggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
toggleShadow.BackgroundTransparency = 1
toggleShadow.Image = "rbxassetid://5554236805"
toggleShadow.ImageColor3 = PURPLE_MAIN
toggleShadow.ImageTransparency = 0.5
toggleShadow.ZIndex = -1

-- Пульсация кнопки
task.spawn(function()
	while toggleButton.Parent do
		TweenService:Create(toggleStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Transparency = 0.7
		}):Play()
		task.wait(1.5)
		TweenService:Create(toggleStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Transparency = 0.2
		}):Play()
		task.wait(1.5)
	end
end)

-- Hover эффект
toggleButton.MouseEnter:Connect(function()
	TweenService:Create(toggleButton, TWEEN_INFO_FAST, {Size = UDim2.new(0, 78, 0, 78)}):Play()
	TweenService:Create(toggleStroke, TWEEN_INFO_FAST, {Thickness = 3, Transparency = 0}):Play()
end)

toggleButton.MouseLeave:Connect(function()
	TweenService:Create(toggleButton, TWEEN_INFO_FAST, {Size = UDim2.new(0, 70, 0, 70)}):Play()
	TweenService:Create(toggleStroke, TWEEN_INFO_FAST, {Thickness = 2, Transparency = 0.3}):Play()
end)

-- ============================================
-- 🌫️ ЗАТЕМНЕНИЕ ФОНА
-- ============================================
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "MenuBlur"
blurEffect.Size = 0
blurEffect.Parent = game.Workspace.CurrentCamera

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = PURPLE_DARK
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
overlay.ZIndex = 5
overlay.Parent = screenGui

-- ============================================
-- 📦 ГЛАВНОЕ МЕНЮ (ШИРЕ, МЕНЬШЕ ВЫСОТА)
-- ============================================
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 540, 0, 480)  -- Шире (540), меньше высота (480)
menuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
menuFrame.BackgroundColor3 = PURPLE_DARK
menuFrame.BackgroundTransparency = 0.15
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.ZIndex = 10
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner", menuFrame)
menuCorner.CornerRadius = UDim.new(0, 24)

local menuStroke = Instance.new("UIStroke", menuFrame)
menuStroke.Thickness = 1.5
menuStroke.Color = PURPLE_MAIN
menuStroke.Transparency = 0.5

-- Градиентная рамка
local menuGradient = Instance.new("UIGradient", menuStroke)
menuGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, PURPLE_DEEP),
	ColorSequenceKeypoint.new(0.5, PURPLE_MAIN),
	ColorSequenceKeypoint.new(1, PURPLE_GLOW)
})

-- Тень меню
local menuShadow = Instance.new("ImageLabel", menuFrame)
menuShadow.Name = "Shadow"
menuShadow.Size = UDim2.new(1.2, 0, 1.2, 0)
menuShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
menuShadow.AnchorPoint = Vector2.new(0.5, 0.5)
menuShadow.BackgroundTransparency = 1
menuShadow.Image = "rbxassetid://5554236805"
menuShadow.ImageColor3 = PURPLE_MAIN
menuShadow.ImageTransparency = 0.4
menuShadow.ZIndex = -1

-- ============================================
-- 🎨 ШАПКА МЕНЮ
-- ============================================
local header = Instance.new("Frame", menuFrame)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 90)
header.BackgroundColor3 = PURPLE_DARK
header.BorderSizePixel = 0
header.ZIndex = 11

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 24)

-- Градиент шапки
local headerGradient = Instance.new("UIGradient", header)
headerGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, PURPLE_DEEP),
	ColorSequenceKeypoint.new(1, PURPLE_MAIN)
})
headerGradient.Rotation = 90

-- Заголовок
local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 30, 0, 0)
title.BackgroundTransparency = 1
title.Text = "💜 Пурпурное Меню"
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 12

-- Подзаголовок
local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(1, -40, 0, 20)
subtitle.Position = UDim2.new(0, 30, 1, -35)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Добро пожаловать, " .. player.Name
subtitle.TextSize = 14
subtitle.TextColor3 = PURPLE_LIGHT
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 12

-- ============================================
-- 📋 КОНТЕНТ МЕНЮ
-- ============================================
local content = Instance.new("ScrollingFrame", menuFrame)
content.Name = "Content"
content.Size = UDim2.new(1, -40, 1, -110)
content.Position = UDim2.new(0, 20, 0, 100)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = PURPLE_MAIN
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.ZIndex = 11

local listLayout = Instance.new("UIListLayout", content)
listLayout.Padding = UDim.new(0, 12)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Функция создания кнопки меню
local menuButtons = {}
local function createMenuButton(text, icon, order, color1, color2)
	local btn = Instance.new("TextButton")
	btn.Name = text
	btn.Size = UDim2.new(1, 0, 0, 60)
	btn.BackgroundColor3 = Color3.fromRGB(40, 25, 60)
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
	arrow.TextColor3 = PURPLE_LIGHT
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
		TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 55)}):Play()
		task.wait(0.1)
		TweenService:Create(btn, TWEEN_INFO_FAST, {Size = UDim2.new(1, 0, 0, 60)}):Play()
		print("💜 Нажата кнопка: " .. text)
	end)

	table.insert(menuButtons, btn)
	return btn
end

-- Пурпурные кнопки
createMenuButton("Игрок",      "👤", 1, PURPLE_DEEP,   PURPLE_MAIN)
createMenuButton("Настройки",  "⚙️", 2, PURPLE_MAIN,   PURPLE_LIGHT)
createMenuButton("Инвентарь",  "🎒", 3, PURPLE_LIGHT,  PURPLE_GLOW)
createMenuButton("Магазин",    "🛒", 4, Color3.fromRGB(100, 50, 150),  PURPLE_MAIN)
createMenuButton("Друзья",     "💬", 5, Color3.fromRGB(80, 40, 120),   PURPLE_DEEP)
createMenuButton("Достижения", "🏆", 6, Color3.fromRGB(120, 60, 180),  PURPLE_GLOW)

-- ============================================
-- 🎬 TOGGLE ЛОГИКА (ОТКРЫТИЕ/ЗАКРЫТИЕ)
-- ============================================
local isOpen = false

local function toggleMenu()
	if isOpen then
		closeMenu()
	else
		openMenu()
	end
end

local function openMenu()
	if isOpen then return end
	isOpen = true

	menuFrame.Visible = true
	menuFrame.Size = UDim2.new(0, 460, 0, 400)
	menuFrame.Position = UDim2.new(0.5, 0, 0.5, 30)
	menuFrame.BackgroundTransparency = 1

	for _, btn in ipairs(menuButtons) do
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.new(0.8, 0, 0, 0)
	end

	TweenService:Create(menuFrame, TWEEN_INFO_OPEN, {
		Size = UDim2.new(0, 540, 0, 480),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 0.15
	}):Play()

	TweenService:Create(blurEffect, TWEEN_INFO_SMOOTH, {Size = 20}):Play()
	TweenService:Create(overlay, TWEEN_INFO_SMOOTH, {BackgroundTransparency = 0.5}):Play()

	for i, btn in ipairs(menuButtons) do
		task.delay(0.15 + (i - 1) * 0.07, function()
			TweenService:Create(btn, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, 0, 0, 60)
			}):Play()
		end)
	end
end

local function closeMenu()
	if not isOpen then return end
	isOpen = false

	for i = #menuButtons, 1, -1 do
		local btn = menuButtons[i]
		task.delay((#menuButtons - i) * 0.04, function()
			TweenService:Create(btn, TWEEN_INFO_FAST, {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.8, 0, 0, 0)
			}):Play()
		end)
	end

	TweenService:Create(menuFrame, TWEEN_INFO_FAST, {
		Size = UDim2.new(0, 460, 0, 400),
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
toggleButton.MouseButton1Click:Connect(toggleMenu)

overlay.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		closeMenu()
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.M then
		toggleMenu()
	end
end)

-- ============================================
-- ✨ АНИМАЦИЯ ПОЯВЛЕНИЯ КНОПКИ
-- ============================================
task.spawn(function()
	toggleButton.Size = UDim2.new(0, 0, 0, 0)
	toggleButton.BackgroundTransparency = 1
	task.wait(0.5)
	TweenService:Create(toggleButton, TWEEN_INFO_BOUNCE, {
		Size = UDim2.new(0, 70, 0, 70),
		BackgroundTransparency = 0
	}):Play()
end)

print("💜 Пурпурное меню с дождём загружено! Нажми на кнопку слева или клавишу M")
