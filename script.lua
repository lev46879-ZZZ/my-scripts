-- LocalScript в StarterPlayerScripts

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "MyMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Кнопка открытия
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.fromOffset(55, 55)
openButton.Position = UDim2.new(0, 20, 0.5, -25)
openButton.Text = "☰"
openButton.TextSize = 25
openButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Parent = gui

local corner1 = Instance.new("UICorner")
corner1.CornerRadius = UDim.new(0, 12)
corner1.Parent = openButton

-- Само меню
local menu = Instance.new("Frame")
menu.Size = UDim2.fromOffset(320, 220)
menu.Position = UDim2.new(0.5, -160, 0.5, -110)
menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menu.Visible = false
menu.Parent = gui

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 14)
corner2.Parent = menu

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 45)
title.Position = UDim2.fromOffset(15, 5)
title.BackgroundTransparency = 1
title.Text = "Моё меню"
title.TextSize = 22
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = menu

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(35, 35)
closeButton.Position = UDim2.new(1, -45, 0, 10)
closeButton.Text = "×"
closeButton.TextSize = 25
closeButton.BackgroundTransparency = 1
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Parent = menu

-- Пример кнопки
local exampleButton = Instance.new("TextButton")
exampleButton.Size = UDim2.new(1, -30, 0, 45)
exampleButton.Position = UDim2.fromOffset(15, 60)
exampleButton.Text = "Кнопка"
exampleButton.TextSize = 18
exampleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
exampleButton.TextColor3 = Color3.new(1, 1, 1)
exampleButton.Parent = menu

local corner3 = Instance.new("UICorner")
corner3.CornerRadius = UDim.new(0, 8)
corner3.Parent = exampleButton

-- Открыть / закрыть
openButton.Activated:Connect(function()
    menu.Visible = not menu.Visible
end)

closeButton.Activated:Connect(function()
    menu.Visible = false
end)

exampleButton.Activated:Connect(function()
    print("Кнопка нажата")
end)
