local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Хранилище объектов эффектов
local VisualObjects = {
	Aura = nil,
	Wings = nil,
	Weather = nil,
	Blur = nil
}

-- Глобальные настройки визуализации
local Config = {
	PrimaryColor = Color3.fromRGB(170, 0, 255), -- Фиолетовый по умолчанию
	AuraActive = false,
	WingsActive = false,
	WeatherMode = "None", -- "None", "Rain", "Snow"
	BlurAmount = 0
}

----------------------------------------------------
-- 1. СИСТЕМА ВИЗУАЛЬНЫХ ЭФФЕКТОВ
----------------------------------------------------

-- Создание/Удаление Ауры
local function UpdateAura(state)
	if VisualObjects.Aura then 
		VisualObjects.Aura:Destroy() 
		VisualObjects.Aura = nil
	end
	if not state then return end

	local att = Instance.new("Attachment")
	att.Name = "UniversalAuraAtt"
	att.Parent = HumanoidRootPart

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxassetid://258122325"
	emitter.Color = ColorSequence.new(Config.PrimaryColor)
	emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)})
	emitter.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})
	emitter.Lifetime = NumberRange.new(0.8, 1.2)
	emitter.Rate = 50
	emitter.Speed = NumberRange.new(2, 5)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Parent = att

	VisualObjects.Aura = att
end

-- Создание/Удаление Крыльев
local function UpdateWings(state)
	if VisualObjects.Wings then 
		VisualObjects.Wings:Destroy() 
		VisualObjects.Wings = nil
	end
	if not state then return end

	local att = Instance.new("Attachment")
	att.Name = "UniversalWingsAtt"
	att.Position = Vector3.new(0, 0.5, 0.6)
	att.Parent = HumanoidRootPart

	local wingParticles = Instance.new("ParticleEmitter")
	wingParticles.Texture = "rbxassetid://258122325"
	wingParticles.Color = ColorSequence.new(Config.PrimaryColor)
	wingParticles.Size = NumberSequence.new(4)
	wingParticles.Lifetime = NumberRange.new(0.05, 0.05)
	wingParticles.Rate = 80
	wingParticles.Speed = NumberRange.new(0)
	wingParticles.Parent = att

	VisualObjects.Wings = att
end

-- Эффекты Погоды (Снег / Дождь)
local function SetWeather(mode)
	if VisualObjects.Weather then
		VisualObjects.Weather:Destroy()
		VisualObjects.Weather = nil
	end
	Config.WeatherMode = mode
	if mode == "None" then return end

	local part = Instance.new("Part")
	part.Name = "WeatherPart"
	part.Size = Vector3.new(120, 1, 120)
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Parent = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Parent = part

	if mode == "Rain" then
		emitter.Texture = "rbxassetid://241837157"
		emitter.Size = NumberSequence.new(0.4, 1.5)
		emitter.Rate = 250
		emitter.Speed = NumberRange.new(50, 70)
		emitter.Lifetime = NumberRange.new(1, 1.5)
	elseif mode == "Snow" then
		emitter.Texture = "rbxassetid://258122325"
		emitter.Size = NumberSequence.new(0.2, 0.5)
		emitter.Rate = 120
		emitter.Speed = NumberRange.new(5, 12)
		emitter.Lifetime = NumberRange.new(3, 5)
	end

	VisualObjects.Weather = part
end

-- Постобработка: Четкость и Четкое Размытие (Blur)
local function SetBlur(intensity)
	if not VisualObjects.Blur then
		VisualObjects.Blur = Instance.new("BlurEffect")
		VisualObjects.Blur.Parent = Lighting
	end
	VisualObjects.Blur.Size = intensity
end

-- Отслеживание положения игрока для погоды
RunService.RenderStepped:Connect(function()
	if VisualObjects.Weather and HumanoidRootPart then
		VisualObjects.Weather.Position = HumanoidRootPart.Position + Vector3.new(0, 45, 0)
	end
end)

----------------------------------------------------
-- 2. УНИВЕРСАЛЬНЫЙ СТИЛЬНЫЙ GUI (HUB)
----------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalVisualsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 420)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "VISUAL ENGINE"
Title.TextColor3 = Config.PrimaryColor
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = MainFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 50)
Padding.Parent = MainFrame

local function CreateButton(text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 13
	btn.Parent = MainFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		callback(btn)
	end)
	return btn
end

-- Кнопки управления
CreateButton("Аура Персонажа", function(btn)
	Config.AuraActive = not Config.AuraActive
	btn.BackgroundColor3 = Config.AuraActive and Config.PrimaryColor or Color3.fromRGB(25, 25, 35)
	UpdateAura(Config.AuraActive)
end)

CreateButton("Ангельские Крылья", function(btn)
	Config.WingsActive = not Config.WingsActive
	btn.BackgroundColor3 = Config.WingsActive and Config.PrimaryColor or Color3.fromRGB(25, 25, 35)
	UpdateWings(Config.WingsActive)
end)

CreateButton("Сменить Цвет (Neon / Aura)", function()
	-- Циклическая смена палитры
	if Config.PrimaryColor == Color3.fromRGB(170, 0, 255) then
		Config.PrimaryColor = Color3.fromRGB(0, 255, 170) -- Изумрудный
	elseif Config.PrimaryColor == Color3.fromRGB(0, 255, 170) then
		Config.PrimaryColor = Color3.fromRGB(255, 50, 50) -- Алый
	else
		Config.PrimaryColor = Color3.fromRGB(170, 0, 255) -- Фиолетовый
	end
	Title.TextColor3 = Config.PrimaryColor
	if Config.AuraActive then UpdateAura(true) end
	if Config.WingsActive then UpdateWings(true) end
end)

CreateButton("Погода: Дождь", function(btn)
	local mode = Config.WeatherMode == "Rain" and "None" or "Rain"
	SetWeather(mode)
end)

CreateButton("Погода: Снег", function(btn)
	local mode = Config.WeatherMode == "Snow" and "None" or "Snow"
	SetWeather(mode)
end)

CreateButton("Переключить Размытие (Blur)", function(btn)
	Config.BlurAmount = Config.BlurAmount == 0 and 12 or 0
	SetBlur(Config.BlurAmount)
	btn.BackgroundColor3 = Config.BlurAmount > 0 and Config.PrimaryColor or Color3.fromRGB(25, 25, 35)
end)

-- Автообновление эффектов при смерти или возрождении
LocalPlayer.CharacterAdded:Connect(function(newChar)
	Character = newChar
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	task.wait(0.5)
	if Config.AuraActive then UpdateAura(true) end
	if Config.WingsActive then UpdateWings(true) end
end)
