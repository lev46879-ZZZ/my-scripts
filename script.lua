-- Apex Hub | Complete Script
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создание главного ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Звук открытия
local OpenSound = Instance.new("Sound")
OpenSound.Name = "ApexOpenSound"
OpenSound.SoundId = "rbxassetid://9114223193"
OpenSound.Volume = 1
OpenSound.Parent = ScreenGui

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

local ProgressBarCorner = Instance.new("UICorner")
ProgressBarCorner.CornerRadius = UDim.new(0, 4)
ProgressBarCorner.Parent = ProgressBarBackground

local ProgressBarFill = Instance.new("Frame")
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.Parent = ProgressBarBackground

local ProgressFillCorner = Instance.new("UICorner")
ProgressFillCorner.CornerRadius = UDim.new(0, 4)
ProgressFillCorner.Parent = ProgressBarFill

---------------------------------------------------------
-- 2. ГЛАВНОЕ МЕНЮ
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Шапка меню
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

-- Боковая панель вкладок
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

-- Контейнер для содержимого вкладок
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -140, 1, -50)
ContentContainer.Position = UDim2.new(0, 135, 0, 45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

---------------------------------------------------------
-- 3. КВАДРАТНАЯ КНОПКА ОТКРЫТИЯ (TOGGLE GUI)
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
-- МЕХАНИКА ВКЛАДОК И ПЕРЕЛИВАНИЯ (GLOW EFFECT)
---------------------------------------------------------
local Tabs = {}
local ContentFrames = {}
local ActiveTab = nil
local ActiveGlowMode = "Rainbow" -- По умолчанию

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

-- Анимация переливания (Gradient/Glow Loop)
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
-- 4. НАПОЛНЕНИЕ ВКЛАДОК
---------------------------------------------------------
local VisualsTab = CreateTab("Visuals")
local WorldTab = CreateTab("World")
local SettingsTab = CreateTab("Settings")

-- Элементы Визуалов (Аура & Крылья)
local AuraActive = false
local WingsActive = false
local AuraPart, WingsModel

local function ToggleButton(parent, text, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -10, 0, 40)
	Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	Btn.BorderSizePixel = 0
	Btn.Text = text .. ": OFF"
	Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
	Btn.TextSize = 14
	Btn.Font = Enum.Font.GothamBold
	Btn.Parent = parent
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = Btn
	
	local enabled = false
	Btn.MouseButton1Click:Connect(function()
		enabled = not enabled
		Btn.Text = text .. (enabled and ": ON" or ": OFF")
		Btn.TextColor3 = enabled and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(255, 80, 80)
		callback(enabled)
	end)
end

-- Переключатель Ауры
ToggleButton(VisualsTab, "Aura Visual", function(state)
	AuraActive = state
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	
	if state and hrp then
		AuraPart = Instance.new("Part")
		AuraPart.Name = "ApexAura"
		AuraPart.Size = Vector3.new(7, 0.1, 7)
		AuraPart.CanCollide = false
		AuraPart.Anchored = false
		AuraPart.Material = Enum.Material.Neon
		AuraPart.Color = Color3.fromRGB(0, 170, 255)
		AuraPart.Transparency = 0.4
		AuraPart.Parent = char
		
		local weld = Instance.new("Weld")
		weld.Part0 = hrp
		weld.Part1 = AuraPart
		weld.C0 = CFrame.new(0, -3, 0)
		weld.Parent = AuraPart
	elseif AuraPart then
		AuraPart:Destroy()
	end
end)

-- Переключатель Крыльев
ToggleButton(VisualsTab, "Angel Wings", function(state)
	WingsActive = state
	local char = LocalPlayer.Character
	if state and char and char:FindFirstChild("UpperTorso") then
		WingsModel = Instance.new("Part")
		WingsModel.Name = "ApexWings"
		WingsModel.Size = Vector3.new(5, 3, 0.2)
		WingsModel.Color = Color3.fromRGB(0, 255, 255)
		WingsModel.Material = Enum.Material.Neon
		WingsModel.CanCollide = false
		WingsModel.Parent = char
		
		local weld = Instance.new("Weld")
		weld.Part0 = char.UpperTorso
		weld.Part1 = WingsModel
		weld.C0 = CFrame.new(0, 0, 1)
		weld.Parent = WingsModel
	elseif WingsModel then
		WingsModel:Destroy()
	end
end)

-- Настройки World (World Tab)
ToggleButton(WorldTab, "Fullbright", function(state)
	if state then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.GlobalShadows = false
	else
		Lighting.Brightness = 1
		Lighting.GlobalShadows = true
	end
end)

-- Настройки Смены Цвета Перелива (Settings Tab)
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
		OpenSound:Play()
		MainFrame.Visible = true
		MainFrame.Size = UDim2.new(0, 0, 0, 0)
		MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 550, 0, 350),
			Position = UDim2.new(0.5, -275, 0.5, -175)
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
	-- Появление Loader
	TweenService:Create(LoaderFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
	TweenService:Create(LoaderTitle, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
	TweenService:Create(ProgressBarBackground, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
	task.wait(0.6)
	
	-- Имитация Загрузки
	TweenService:Create(ProgressBarFill, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	task.wait(1.7)
	
	-- Исчезновение Loader
	TweenService:Create(LoaderFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	TweenService:Create(LoaderTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
	TweenService:Create(ProgressBarBackground, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	TweenService:Create(ProgressBarFill, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
	task.wait(0.4)
	
	LoaderFrame:Destroy()
	
	-- Показ квадратной GUI кнопки открытия Apex Hub
	OpenButton.Visible = true
	OpenButton.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(OpenButton, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 65, 0, 65)
	}):Play()
	
	-- Открытие первой вкладки по умолчанию
	Tabs["Visuals"].Button.MouseButton1Click:Fire()
end)
