-- Apex Hub V2 | Improved for MM2 & Full Customization
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создание главного ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexHubUI_V2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Исправленный звук открытия в SoundService
local OpenSound = Instance.new("Sound")
OpenSound.Name = "ApexOpenSound"
OpenSound.SoundId = "rbxassetid://9114223193"
OpenSound.Volume = 2
OpenSound.Parent = SoundService

---------------------------------------------------------
-- 1. LOADER (Загрузчик)
---------------------------------------------------------
local LoaderFrame = Instance.new("Frame")
LoaderFrame.Size = UDim2.new(0, 300, 0, 150)
LoaderFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
LoaderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
LoaderFrame.BorderSizePixel = 0
LoaderFrame.BackgroundTransparency = 1
LoaderFrame.Parent = ScreenGui

local LoaderCorner = Instance.new("UICorner")
LoaderCorner.CornerRadius = UDim.new(0, 12)
LoaderCorner.Parent = LoaderFrame

local LoaderTitle = Instance.new("TextLabel")
LoaderTitle.Size = UDim2.new(1, 0, 0, 40)
LoaderTitle.Position = UDim2.new(0, 0, 0.2, 0)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Text = "APEX HUB"
LoaderTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
LoaderTitle.TextSize = 24
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextTransparency = 1
LoaderTitle.Parent = LoaderFrame

local ProgressBarBackground = Instance.new("Frame")
ProgressBarBackground.Size = UDim2.new(0.8, 0, 0, 8)
ProgressBarBackground.Position = UDim2.new(0.1, 0, 0.65, 0)
ProgressBarBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ProgressBarBackground.BorderSizePixel = 0
ProgressBarBackground.BackgroundTransparency = 1
ProgressBarBackground.Parent = LoaderFrame

local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.Parent = ProgressBarBackground

---------------------------------------------------------
-- 2. ГЛАВНОЕ МЕНЮ
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 560, 0, 380)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Шапка
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "APEX HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Боковая панель
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 130, 1, -40)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = SideBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 10)
TabPadding.PaddingLeft = UDim.new(0, 5)
TabPadding.PaddingRight = UDim.new(0, 5)
TabPadding.Parent = SideBar

-- Контейнер контента
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -145, 1, -50)
ContentContainer.Position = UDim2.new(0, 138, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

---------------------------------------------------------
-- 3. КВАДРАТНАЯ КНОПКА (TOGGLE GUI)
---------------------------------------------------------
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 65, 0, 65)
OpenButton.Position = UDim2.new(0, 20, 0.5, -32)
OpenButton.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
OpenButton.BorderSizePixel = 0
OpenButton.Text = ""
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(0, 170, 255)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

local TextApex = Instance.new("TextLabel")
TextApex.Size = UDim2.new(1, 0, 0.5, 0)
TextApex.Position = UDim2.new(0, 0, 0, 3)
TextApex.BackgroundTransparency = 1
TextApex.Text = "Apex"
TextApex.TextColor3 = Color3.fromRGB(0, 170, 255)
TextApex.TextSize = 16
TextApex.Font = Enum.Font.GothamBold
TextApex.Parent = OpenButton

local TextHub = Instance.new("TextLabel")
TextHub.Size = UDim2.new(1, 0, 0.5, 0)
TextHub.Position = UDim2.new(0, 0, 0.5, -3)
TextHub.BackgroundTransparency = 1
TextHub.Text = "Hub"
TextHub.TextColor3 = Color3.fromRGB(255, 255, 255)
TextHub.TextSize = 14
TextHub.Font = Enum.Font.GothamBold
TextHub.Parent = OpenButton

---------------------------------------------------------
-- ВКЛАДКИ И ЭФФЕКТ ПЕРЕЛИВА
---------------------------------------------------------
local Tabs = {}
local ContentFrames = {}
local ActiveTab = nil
local ActiveGlowMode = "Rainbow"

local GlowColors = {
	["Rainbow"] = nil,
	["Blue"] = Color3.fromRGB(0, 170, 255),
	["Red"] = Color3.fromRGB(255, 50, 50),
	["Neon Green"] = Color3.fromRGB(50, 255, 100),
	["Purple"] = Color3.fromRGB(170, 50, 255)
}

local function CreateTab(name)
	local TabBtn = Instance.new("TextButton")
	TabBtn.Size = UDim2.new(1, 0, 0, 35)
	TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	TabBtn.BorderSizePixel = 0
	TabBtn.Text = name
	TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
	TabBtn.TextSize = 13
	TabBtn.Font = Enum.Font.GothamMedium
	TabBtn.Parent = SideBar
	
	local BtnCorner = Instance.new("UICorner")
	BtnCorner.CornerRadius = UDim.new(0, 6)
	BtnCorner.Parent = TabBtn
	
	local GlowStroke = Instance.new("UIStroke")
	GlowStroke.Thickness = 2
	GlowStroke.Enabled = false
	GlowStroke.Parent = TabBtn
	
	local ContentFrame = Instance.new("ScrollingFrame")
	ContentFrame.Size = UDim2.new(1, 0, 1, 0)
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.BorderSizePixel = 0
	ContentFrame.Visible = false
	ContentFrame.ScrollBarThickness = 4
	ContentFrame.Parent = ContentContainer
	
	local ContentList = Instance.new("UIListLayout")
	ContentList.SortOrder = Enum.SortOrder.LayoutOrder
	ContentList.Padding = UDim.new(0, 8)
	ContentList.Parent = ContentFrame

	Tabs[name] = {Button = TabBtn, Stroke = GlowStroke}
	ContentFrames[name] = ContentFrame
	
	TabBtn.MouseButton1Click:Connect(function()
		for _, data in pairs(Tabs) do
			data.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
			data.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
			data.Stroke.Enabled = false
		end
		for _, frame in pairs(ContentFrames) do
			frame.Visible = false
		end
		
		ActiveTab = name
		TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
		TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		GlowStroke.Enabled = true
		ContentFrame.Visible = true
	end)
	
	return ContentFrame
end

RunService.RenderStepped:Connect(function()
	if ActiveTab and Tabs[ActiveTab] then
		local stroke = Tabs[ActiveTab].Stroke
		if ActiveGlowMode == "Rainbow" then
			local hue = (tick() % 3) / 3
			stroke.Color = Color3.fromHSV(hue, 0.8, 1)
		else
			stroke.Color = GlowColors[ActiveGlowMode] or Color3.fromRGB(0, 170, 255)
		end
	end
end)

---------------------------------------------------------
-- ХЕЛПЕРЫ ДЛЯ ЭЛЕМЕНТОВ ИНТЕРФЕЙСА
---------------------------------------------------------
local function CreateToggleWithSettings(parent, text, onToggle)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -10, 0, 40)
	Container.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	Container.BorderSizePixel = 0
	Container.ClipsDescendants = true
	Container.Parent = parent
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = Container
	
	local MainBtn = Instance.new("TextButton")
	MainBtn.Size = UDim2.new(1, 0, 0, 40)
	MainBtn.BackgroundTransparency = 1
	MainBtn.Text = "  " .. text .. ": OFF"
	MainBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
	MainBtn.TextSize = 14
	MainBtn.Font = Enum.Font.GothamBold
	MainBtn.TextXAlignment = Enum.TextXAlignment.Left
	MainBtn.Parent = Container
	
	local SettingsFrame = Instance.new("Frame")
	SettingsFrame.Size = UDim2.new(1, 0, 0, 120)
	SettingsFrame.Position = UDim2.new(0, 0, 0, 40)
	SettingsFrame.BackgroundTransparency = 1
	SettingsFrame.Parent = Container
	
	local SettingsList = Instance.new("UIListLayout")
	SettingsList.SortOrder = Enum.SortOrder.LayoutOrder
	SettingsList.Padding = UDim.new(0, 5)
	SettingsList.Parent = SettingsFrame
	
	local enabled = false
	MainBtn.MouseButton1Click:Connect(function()
		enabled = not enabled
		MainBtn.Text = "  " .. text .. (enabled and ": ON" or ": OFF")
		MainBtn.TextColor3 = enabled and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(255, 80, 80)
		
		local targetSize = enabled and UDim2.new(1, -10, 0, 160) or UDim2.new(1, -10, 0, 40)
		TweenService:Create(Container, TweenInfo.new(0.3), {Size = targetSize}):Play()
		
		onToggle(enabled)
	end)
	
	return SettingsFrame
end

local function CreateOptionSelector(parent, labelText, options, defaultIndex, callback)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -20, 0, 30)
	Frame.Position = UDim2.new(0, 10, 0, 0)
	Frame.BackgroundTransparency = 1
	Frame.Parent = parent
	
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.5, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = labelText
	Label.TextColor3 = Color3.fromRGB(200, 200, 200)
	Label.TextSize = 12
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Frame
	
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0.45, 0, 0.8, 0)
	Btn.Position = UDim2.new(0.5, 0, 0.1, 0)
	Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
	Btn.BorderSizePixel = 0
	Btn.Text = options[defaultIndex]
	Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	Btn.TextSize = 12
	Btn.Font = Enum.Font.GothamMedium
	Btn.Parent = Frame
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 4)
	Corner.Parent = Btn
	
	local currentIndex = defaultIndex
	Btn.MouseButton1Click:Connect(function()
		currentIndex = currentIndex % #options + 1
		Btn.Text = options[currentIndex]
		callback(options[currentIndex])
	end)
end

---------------------------------------------------------
-- 4. НАПОЛНЕНИЕ ВКЛАДОК И ЛОГИКА ЭФФЕКТОВ
---------------------------------------------------------
local VisualsTab = CreateTab("Visuals")
local WorldTab = CreateTab("World")
local SettingsTab = CreateTab("Settings")

-- Переменные визуалов
local AuraEmitter, WingsEmitter
local AuraAttachment, WingsAttachment
local AuraColor = Color3.fromRGB(0, 170, 255)
local AuraBrightness = 1
local AuraDensity = 50

local WingsColor = Color3.fromRGB(0, 255, 255)
local WingsSize = 2

-- Вкладка VISUALS: Аура
local AuraSettings = CreateToggleWithSettings(VisualsTab, "Aura Visual", function(enabled)
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	
	if enabled and hrp then
		AuraAttachment = Instance.new("Attachment")
		AuraAttachment.Name = "ApexAuraAttach"
		AuraAttachment.Position = Vector3.new(0, -2.5, 0)
		AuraAttachment.Parent = hrp
		
		AuraEmitter = Instance.new("ParticleEmitter")
		AuraEmitter.Texture = "rbxassetid://243661138" -- Мягкое свечение
		AuraEmitter.Color = ColorSequence.new(AuraColor)
		AuraEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)})
		AuraEmitter.Rate = AuraDensity
		AuraEmitter.Lifetime = NumberRange.new(1, 1.5)
		AuraEmitter.Speed = NumberRange.new(2, 4)
		AuraEmitter.VelocitySpread = 360
		AuraEmitter.LightEmission = AuraBrightness
		AuraEmitter.Parent = AuraAttachment
	else
		if AuraAttachment then AuraAttachment:Destroy() end
	end
end)

CreateOptionSelector(AuraSettings, "Aura Color:", {"Blue", "Red", "Green", "Purple", "White"}, 1, function(selected)
	local colors = {
		["Blue"] = Color3.fromRGB(0, 170, 255),
		["Red"] = Color3.fromRGB(255, 50, 50),
		["Green"] = Color3.fromRGB(50, 255, 100),
		["Purple"] = Color3.fromRGB(170, 50, 255),
		["White"] = Color3.fromRGB(255, 255, 255)
	}
	AuraColor = colors[selected]
	if AuraEmitter then AuraEmitter.Color = ColorSequence.new(AuraColor) end
end)

CreateOptionSelector(AuraSettings, "Brightness:", {"Low", "Medium", "High"}, 2, function(selected)
	local brights = {["Low"] = 0.4, ["Medium"] = 0.8, ["High"] = 1}
	AuraBrightness = brights[selected]
	if AuraEmitter then AuraEmitter.LightEmission = AuraBrightness end
end)

CreateOptionSelector(AuraSettings, "Density:", {"Low", "Medium", "High"}, 2, function(selected)
	local rates = {["Low"] = 20, ["Medium"] = 50, ["High"] = 100}
	AuraDensity = rates[selected]
	if AuraEmitter then AuraEmitter.Rate = AuraDensity end
end)

-- Вкладка VISUALS: Крылья
local WingsSettings = CreateToggleWithSettings(VisualsTab, "Angel Wings", function(enabled)
	local char = LocalPlayer.Character
	local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
	
	if enabled and torso then
		WingsAttachment = Instance.new("Attachment")
		WingsAttachment.Name = "ApexWingsAttach"
		WingsAttachment.Position = Vector3.new(0, 0, 0.5)
		WingsAttachment.Parent = torso
		
		WingsEmitter = Instance.new("ParticleEmitter")
		WingsEmitter.Texture = "rbxassetid://258122325" -- Крылья / Искры
		WingsEmitter.Color = ColorSequence.new(WingsColor)
		WingsEmitter.Size = NumberSequence.new(WingsSize)
		WingsEmitter.Rate = 30
		WingsEmitter.Lifetime = NumberRange.new(0.8, 1.2)
		WingsEmitter.Speed = NumberRange.new(0.5, 1)
		WingsEmitter.LightEmission = 0.9
		WingsEmitter.Parent = WingsAttachment
	else
		if WingsAttachment then WingsAttachment:Destroy() end
	end
end)

CreateOptionSelector(WingsSettings, "Wings Color:", {"Cyan", "Pink", "Gold", "Red"}, 1, function(selected)
	local colors = {
		["Cyan"] = Color3.fromRGB(0, 255, 255),
		["Pink"] = Color3.fromRGB(255, 100, 200),
		["Gold"] = Color3.fromRGB(255, 200, 50),
		["Red"] = Color3.fromRGB(255, 50, 50)
	}
	WingsColor = colors[selected]
	if WingsEmitter then WingsEmitter.Color = ColorSequence.new(WingsColor) end
end)

CreateOptionSelector(WingsSettings, "Wings Size:", {"Small", "Medium", "Large"}, 2, function(selected)
	local sizes = {["Small"] = 1.5, ["Medium"] = 2.5, ["Large"] = 4}
	WingsSize = sizes[selected]
	if WingsEmitter then WingsEmitter.Size = NumberSequence.new(WingsSize) end
end)

-- Вкладка WORLD: Fullbright
local FullbrightValue = 2
local FullbrightSettings = CreateToggleWithSettings(WorldTab, "Fullbright", function(enabled)
	if enabled then
		Lighting.Brightness = FullbrightValue
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
	else
		Lighting.Brightness = 1
		Lighting.GlobalShadows = true
	end
end)

CreateOptionSelector(FullbrightSettings, "Brightness Level:", {"Normal (2)", "High (4)", "Ultra (8)"}, 1, function(selected)
	local levels = {["Normal (2)"] = 2, ["High (4)"] = 4, ["Ultra (8)"] = 8}
	FullbrightValue = levels[selected]
	if Lighting.GlobalShadows == false then
		Lighting.Brightness = FullbrightValue
	end
end)

-- Вкладка SETTINGS: Выбор цвета перелива
local GlowTitle = Instance.new("TextLabel")
GlowTitle.Size = UDim2.new(1, 0, 0, 25)
GlowTitle.BackgroundTransparency = 1
GlowTitle.Text = "  Active Tab Glow Color:"
GlowTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
GlowTitle.TextSize = 13
GlowTitle.Font = Enum.Font.GothamMedium
GlowTitle.TextXAlignment = Enum.TextXAlignment.Left
GlowTitle.Parent = SettingsTab

for colorName, _ in pairs(GlowColors) do
	local ColorBtn = Instance.new("TextButton")
	ColorBtn.Size = UDim2.new(1, -10, 0, 30)
	ColorBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
	ColorBtn.BorderSizePixel = 0
	ColorBtn.Text = colorName
	ColorBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
	ColorBtn.TextSize = 12
	ColorBtn.Font = Enum.Font.Gotham
	ColorBtn.Parent = SettingsTab
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 4)
	Corner.Parent = ColorBtn
	
	ColorBtn.MouseButton1Click:Connect(function()
		ActiveGlowMode = colorName
	end)
end

---------------------------------------------------------
-- 5. ЛОГИКА ОТКРЫТИЯ / ЗАКРЫТИЯ С ЗВУКОМ
---------------------------------------------------------
local menuOpen = false

local function ToggleMenu()
	menuOpen = not menuOpen
	if menuOpen then
		OpenSound:Play() -- Воспроизведение звука
		MainFrame.Visible = true
		MainFrame.Size = UDim2.new(0, 0, 0, 0)
		MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 560, 0, 380),
			Position = UDim2.new(0.5, -280, 0.5, -190)
		}):Play()
	else
		local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		})
		tween:Play()
		tween.Completed:Connect(function()
			if not menuOpen then MainFrame.Visible = false end
		end)
	end
end

OpenButton.MouseButton1Click:Connect(ToggleMenu)

---------------------------------------------------------
-- 6. ЗАПУСК АНИМАЦИИ LOADER
---------------------------------------------------------
task.spawn(function()
	-- Анимация появления Loader
	TweenService:Create(LoaderFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
	TweenService:Create(LoaderTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
	TweenService:Create(ProgressBarBackground, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
	task.wait(0.6)
	
	-- Полоса загрузки
	TweenService:Create(ProgressBarFill, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	task.wait(1.4)
	
	-- Анимация исчезновения Loader
	TweenService:Create(LoaderFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	TweenService:Create(LoaderTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
	TweenService:Create(ProgressBarBackground, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	TweenService:Create(ProgressBarFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	task.wait(0.4)
	
	LoaderFrame:Destroy()
	
	-- Показ квадратной GUI кнопки
	OpenButton.Visible = true
	OpenButton.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(OpenButton, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 65, 0, 65)
	}):Play()
	
	-- Выбор первой вкладки по умолчанию
	Tabs["Visuals"].Button.MouseButton1Click:Fire()
end)
