-- Обязательно используем LocalScript, чтобы изменения видел только ТЕКУЩИЙ игрок
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- 1. СОЗДАНИЕ МОБИЛЬНОЙ КНОПКИ И МЕНЮ
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VisualMenuGui"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Кнопка открытия/закрытия меню
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10) -- Левый верхний угол для телефона
toggleButton.Text = "Визуалы (Меню)"
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = screenGui

-- Основная панель настроек
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 250, 0, 300)
menuFrame.Position = UDim2.new(0, 10, 0, 60)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.Visible = false -- Изначально скрыто
menuFrame.Parent = screenGui

-- Переключение видимости меню при тапе на кнопку
toggleButton.MouseButton1Click:Connect(function()
	menuFrame.Visible = not menuFrame.Visible
end)

-- 2. СОЗДАНИЕ И НАСТРОЙКА ЛОКАЛЬНЫХ КРЫЛЬЕВ
local wingsAttached = false
local localWings = nil

-- Функция для создания визуального объекта (крыльев)
local function createLocalWings()
	-- Создаем базовую деталь для крыльев (в реальной игре здесь берется модель)
	localPart = Instance.new("Part")
	localPart.Name = "LocalAngelWings"
	localPart.Size = Vector3.new(4, 3, 0.2) -- Начальный размер
	localPart.Color = Color3.fromRGB(255, 255, 255) -- Начальный цвет (белый)
	localPart.CanCollide = false
	localPart.Massless = true
	
	-- Прикрепляем визуальный объект к спине персонажа (UpperTorso или Torso)
	local torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
	if torso then
		localPart.Parent = Character
		
		-- Создаем крепление, чтобы крылья двигались вместе со спиной
		local attachment = Instance.new("Attachment")
		attachment.Parent = torso
		
		local motor = Instance.new("Motor6D")
		motor.Part0 = torso
		motor.Part1 = localPart
		motor.C0 = CFrame.new(0, 0, 1) -- Смещение за спину
		motor.Parent = localPart
	end
	
	return localPart
end

-- 3. КНОПКИ УПРАВЛЕНИЯ ВНУТРИ МЕНЮ

-- Кнопка Вкл/Выкл крыльев
local wingsBtn = Instance.new("TextButton")
wingsBtn.Size = UDim2.new(0, 230, 0, 40)
wingsBtn.Position = UDim2.new(0, 10, 0, 10)
wingsBtn.Text = "Крылья: ВЫКЛ"
wingsBtn.Parent = menuFrame

wingsBtn.MouseButton1Click:Connect(function()
	if not wingsAttached then
		localWings = createLocalWings()
		wingsBtn.Text = "Крылья: ВКЛ"
		wingsAttached = true
	else
		if localWings then localWings:Destroy() end
		wingsBtn.Text = "Крылья: ВЫКЛ"
		wingsAttached = false
	end
end)

-- Кнопка изменения Цвета (Переключение между Белым, Синим и Красным)
local colorBtn = Instance.new("TextButton")
colorBtn.Size = UDim2.new(0, 230, 0, 40)
colorBtn.Position = UDim2.new(0, 10, 0, 60)
colorBtn.Text = "Изменить Цвет"
colorBtn.Parent = menuFrame

local colors = {Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 100, 255), Color3.fromRGB(255, 0, 0)}
local colorIndex = 1

colorBtn.MouseButton1Click:Connect(function()
	if localWings then
		colorIndex = colorIndex + 1
		if colorIndex > #colors then colorIndex = 1 end
		localWings.Color = colors[colorIndex]
	end
end)

-- Кнопка Четкости / Прозрачности (Прозрачный / Плотный)
local transparencyBtn = Instance.new("TextButton")
transparencyBtn.Size = UDim2.new(0, 230, 0, 40)
transparencyBtn.Position = UDim2.new(0, 10, 0, 110)
transparencyBtn.Text = "Четкость: 100%"
transparencyBtn.Parent = menuFrame

transparencyBtn.MouseButton1Click:Connect(function()
	if localWings then
		if localWings.Transparency == 0 then
			localWings.Transparency = 0.6 -- Делаем полупрозрачным (четкость ниже)
			transparencyBtn.Text = "Четкость: 40%"
		else
			localWings.Transparency = 0 -- Делаем плотным
			transparencyBtn.Text = "Четкость: 100%"
		end
	end
end)

-- Кнопка Изменения Размера (Маленькие / Большие)
local sizeBtn = Instance.new("TextButton")
sizeBtn.Size = UDim2.new(0, 230, 0, 40)
sizeBtn.Position = UDim2.new(0, 10, 0, 160)
sizeBtn.Text = "Размер: Обычный"
sizeBtn.Parent = menuFrame

sizeBtn.MouseButton1Click:Connect(function()
	if localWings then
		if localWings.Size.X == 4 then
			localWings.Size = Vector3.new(8, 6, 0.2) -- Увеличиваем в два раза
			sizeBtn.Text = "Размер: Большие"
		else
			localWings.Size = Vector3.new(4, 3, 0.2) -- Возвращаем исходный
			sizeBtn.Text = "Размер: Обычный"
		end
	end
end)
