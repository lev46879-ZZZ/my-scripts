-- ==========================================
-- КОСМЕТИЧЕСКОЕ МЕНЮ ВИЗУАЛОВ (Для Roblox Studio)
-- Поместите этот скрипт в StarterPlayer -> StarterPlayerScripts
-- ==========================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Очистка старых эффектов (если есть)
local function clearEffects()
	for _, obj in pairs(player.Character and player.Character:GetChildren() or {}) do
		if obj.Name == "CosmeticEffect" then
			obj:Destroy()
		end
	end
end

-- ==========================================
-- СОЗДАНИЕ GUI
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CosmeticHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 380)
mainFrame.Position = UDim2.new(0, 20, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(80, 0, 255) -- Неоновый контур
mainStroke.Thickness = 2
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
title.BorderSizePixel = 0
title.Text = "⚡ VISUAL HUB"
title.TextColor3 = Color3.fromRGB(180, 130, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Контейнер для кнопок
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -20, 1, -60)
buttonContainer.Position = UDim2.new(0, 10, 0, 50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = buttonContainer

-- Функция создания стильной кнопки
local function createButton(text, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 16
	btn.Font = Enum.Font.GothamMedium
	btn.AutoButtonColor = false
	btn.Parent = buttonContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = 0.5
	stroke.Parent = btn

	-- Анимация при наведении и нажатии
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		-- Эффект нажатия
		TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = color}):Play()
		task.wait(0.1)
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play()
		
		if callback then callback() end
	end)
end

-- ==========================================
-- ЛОГИКА ВИЗУАЛОВ И ОСВЕЩЕНИЯ
-- ==========================================

-- 1. Переключатель освещения (Неон / Киберпанк)
local isNeon = false
createButton("🌆 Освещение: Неон", Color3.fromRGB(255, 0, 200), function()
	isNeon = not isNeon
	if isNeon then
		Lighting.ClockTime = 0
		Lighting.Brightness = 1
		Lighting.Ambient = Color3.fromRGB(50, 20, 80)
		Lighting.OutdoorAmbient = Color3.fromRGB(100, 50, 150)
		Lighting.FogEnd = 1000
		Lighting.FogColor = Color3.fromRGB(20, 10, 40)
		
		-- Добавляем Bloom и ColorCorrection для "шейдерного" эффекта
		if not Lighting:FindFirstChild("NeonBloom") then
			local bloom = Instance.new("BloomEffect")
			bloom.Name = "NeonBloom"
			bloom.Intensity = 1.5
			bloom.Size = 50
			bloom.Threshold = 0.8
			bloom.Parent = Lighting
		end
		if not Lighting:FindFirstChild("NeonCC") then
			local cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "NeonCC"
			cc.TintColor = Color3.fromRGB(255, 220, 255)
			cc.Contrast = 0.2
			cc.Saturation = 0.3
			cc.Parent = Lighting
		end
	else
		-- Возврат к стандартному освещению
		Lighting.ClockTime = 14
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(128, 128, 128)
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.FogEnd = 100000
		if Lighting:FindFirstChild("NeonBloom") then Lighting.NeonBloom:Destroy() end
		if Lighting:FindFirstChild("NeonCC") then Lighting.NeonCC:Destroy() end
	end
end)

-- 2. Визуал: Энергетические Крылья
createButton("🪽 Эффект: Крылья", Color3.fromRGB(0, 200, 255), function()
	clearEffects()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")

	local attachment = Instance.new("Attachment")
	attachment.Name = "CosmeticEffect"
	attachment.Position = Vector3.new(0, 1, -0.5)
	attachment.Parent = root

	-- Левое крыло
	local leftWing = Instance.new("ParticleEmitter")
	leftWing.Name = "CosmeticEffect"
	leftWing.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	leftWing.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 100, 255))
	leftWing.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.2, 3),
		NumberSequenceKeypoint.new(1, 0)
	})
	leftWing.Lifetime = NumberRange.new(0.5, 1)
	leftWing.Rate = 100
	leftWing.Speed = NumberRange.new(0, 0)
	leftWing.SpreadAngle = Vector2.new(-40, 10)
	leftWing.Rotation = NumberRange.new(-90, -90)
	leftWing.RotSpeed = NumberRange.new(0, 0)
	leftWing.Parent = attachment

	-- Правое крыло (зеркальное)
	local rightWing = leftWing:Clone()
	rightWing.SpreadAngle = Vector2.new(-10, 40)
	rightWing.Rotation = NumberRange.new(90, 90)
	rightWing.Parent = attachment
end)

-- 3. Визуал: Тентакли (Щупальца)
createButton("🐙 Эффект: Щупальца", Color3.fromRGB(150, 0, 255), function()
	clearEffects()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")

	local attachment = Instance.new("Attachment")
	attachment.Name = "CosmeticEffect"
	attachment.Position = Vector3.new(0, -2, 0)
	attachment.Parent = root

	-- Создаем "щупальца" из частиц, которые тянутся вниз и закручиваются
	for i = 1, 6 do
		local tentacle = Instance.new("ParticleEmitter")
		tentacle.Name = "CosmeticEffect"
		tentacle.Texture = "rbxasset://textures/particles/smoke_main.dds"
		tentacle.Color = ColorSequence.new(Color3.fromRGB(200, 0, 255), Color3.fromRGB(50, 0, 100))
		tentacle.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.5),
			NumberSequenceKeypoint.new(1, 0)
		})
		tentacle.Lifetime = NumberRange.new(1.5, 2)
		tentacle.Rate = 30
		tentacle.Speed = NumberRange.new(2, 4)
		tentacle.SpreadAngle = Vector2.new(10, 10)
		tentacle.Rotation = NumberRange.new(0, 360)
		tentacle.RotSpeed = NumberRange.new(-100, 100)
		tentacle.VelocityInheritance = 0
		
		-- Смещаем каждое щупальце по кругу
		local angle = (i / 6) * math.pi * 2
		tentacle.Position = UDim2.new(0, math.cos(angle) * 1.5, 0, math.sin(angle) * 1.5)
		tentacle.Parent = attachment
	end
end)

-- 4. Сброс всех эффектов
createButton("❌ Сбросить всё", Color3.fromRGB(255, 50, 50), function()
	clearEffects()
	-- Сброс освещения
	Lighting.ClockTime = 14
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(128, 128, 128)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	if Lighting:FindFirstChild("NeonBloom") then Lighting.NeonBloom:Destroy() end
	if Lighting:FindFirstChild("NeonCC") then Lighting.NeonCC:Destroy() end
	isNeon = false
end)

-- Анимация появления меню
mainFrame.Position = UDim2.new(0, -300, 0.5, -190)
local tweenIn = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Position = UDim2.new(0, 20, 0.5, -190)
})
tweenIn:Play()
