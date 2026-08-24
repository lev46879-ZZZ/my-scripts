-- Проверка на повторный запуск (удаляем старое меню, если есть)
if game.CoreGui:FindFirstChild("DeltaFlickGUI") then
    game.CoreGui.DeltaFlickGUI:Destroy()
end

-- Создание главного контейнера
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFlickGUI"
ScreenGui.Parent = game.CoreGui

-- Кнопка для открытия/закрытия меню
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 128)
ToggleButton.Text = "DF"
ToggleButton.TextSize = 20
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 12)
UICornerBtn.Parent = ToggleButton

-- Главное окно меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = " Delta Flick | Combat"
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Контейнер для вкладки Combat
local CombatTab = Instance.new("ScrollingFrame")
CombatTab.Size = UDim2.new(1, -20, 1, -60)
CombatTab.Position = UDim2.new(0, 10, 0, 50)
CombatTab.BackgroundTransparency = 1
CombatTab.CanvasSize = UDim2.new(0, 0, 0, 250)
CombatTab.Parent = MainFrame

-- Переключатель Aimbot (Toggle)
local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(1, 0, 0, 35)
AimbotToggle.Position = UDim2.new(0, 0, 0, 10)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
AimbotToggle.TextColor3 = Color3.fromRGB(255, 50, 50)
AimbotToggle.Text = "Aimbot: OFF"
AimbotToggle.TextSize = 14
AimbotToggle.Font = Enum.Font.Gotham
AimbotToggle.Parent = CombatTab

local UICornerAim = Instance.new("UICorner")
UICornerAim.CornerRadius = UDim.new(0, 6)
UICornerAim.Parent = AimbotToggle

-- Настройка скорости прицеливания (Smooth)
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0, 0, 0, 55)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Text = "Скорость (Smoothness): 5"
SpeedLabel.TextSize = 13
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = CombatTab

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, 0, 0, 30)
SpeedBox.Position = UDim2.new(0, 0, 0, 80)
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Text = "5"
SpeedBox.TextSize = 14
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.Parent = CombatTab

-- Настройка FOV (Radius)
local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(1, 0, 0, 25)
FovLabel.Position = UDim2.new(0, 0, 0, 120)
FovLabel.BackgroundTransparency = 1
FovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FovLabel.Text = "Радиус FOV: 100"
FovLabel.TextSize = 13
FovLabel.Font = Enum.Font.Gotham
FovLabel.TextXAlignment = Enum.TextXAlignment.Left
FovLabel.Parent = CombatTab

local FovBox = Instance.new("TextBox")
FovBox.Size = UDim2.new(1, 0, 0, 30)
FovBox.Position = UDim2.new(0, 0, 0, 145)
FovBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FovBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FovBox.Text = "100"
FovBox.TextSize = 14
FovBox.Font = Enum.Font.Gotham
FovBox.Parent = CombatTab

-- Логика кнопки открытия/закрытия
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Логика включения/выключения Aimbot
local aimbotEnabled = false
AimbotToggle.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        AimbotToggle.Text = "Aimbot: ON"
        AimbotToggle.TextColor3 = Color3.fromRGB(50, 255, 50)
    else
        AimbotToggle.Text = "Aimbot: OFF"
        AimbotToggle.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- Обновление значений настроек
SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then SpeedLabel.Text = "Скорость (Smoothness): " .. val end
end)

FovBox.FocusLost:Connect(function()
    local val = tonumber(FovBox.Text)
    if val then FovLabel.Text = "Радиус FOV: " .. val end
end)
