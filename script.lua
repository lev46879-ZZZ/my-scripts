-- Сервисы и переменные
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

-- Удаляем старый GUI, если он есть
if CoreGui:FindFirstChild("DeltaFlickGUI") then
    CoreGui.DeltaFlickGUI:Destroy()
end

-- Создание интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFlickGUI"
ScreenGui.Parent = CoreGui

-- Кнопка открытия/закрытия
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

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 260)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "  Delta Flick | Combat"
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Вкладка Combat
local CombatTab = Instance.new("ScrollingFrame")
CombatTab.Size = UDim2.new(1, -20, 1, -50)
CombatTab.Position = UDim2.new(0, 10, 0, 45)
CombatTab.BackgroundTransparency = 1
CombatTab.CanvasSize = UDim2.new(0, 0, 0, 200)
CombatTab.Parent = MainFrame

-- Кнопка Aimbot
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

-- Кнопка WallCheck
local WallCheckToggle = Instance.new("TextButton")
WallCheckToggle.Size = UDim2.new(1, 0, 0, 35)
WallCheckToggle.Position = UDim2.new(0, 0, 0, 55)
WallCheckToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
WallCheckToggle.TextColor3 = Color3.fromRGB(50, 255, 50)
WallCheckToggle.Text = "WallCheck: ON"
WallCheckToggle.TextSize = 14
WallCheckToggle.Font = Enum.Font.Gotham
WallCheckToggle.Parent = CombatTab

local UICornerWall = Instance.new("UICorner")
UICornerWall.CornerRadius = UDim.new(0, 6)
UICornerWall.Parent = WallCheckToggle

-- Поле FOV
local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(1, 0, 0, 25)
FovLabel.Position = UDim2.new(0, 0, 0, 100)
FovLabel.BackgroundTransparency = 1
FovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FovLabel.Text = "Радиус FOV: 150"
FovLabel.TextSize = 13
FovLabel.Font = Enum.Font.Gotham
FovLabel.TextXAlignment = Enum.TextXAlignment.Left
FovLabel.Parent = CombatTab

local FovBox = Instance.new("TextBox")
FovBox.Size = UDim2.new(1, 0, 0, 30)
FovBox.Position = UDim2.new(0, 0, 0, 125)
FovBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FovBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FovBox.Text = "150"
FovBox.TextSize = 14
FovBox.Font = Enum.Font.Gotham
FovBox.Parent = CombatTab

-- Переменные состояний
local aimbotEnabled = false
local wallCheckEnabled = true
local fovRadius = 150

-- Управление интерфейсом
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

AimbotToggle.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimbotToggle.Text = aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
    AimbotToggle.TextColor3 = aimbotEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

WallCheckToggle.MouseButton1Click:Connect(function()
    wallCheckEnabled = not wallCheckEnabled
    WallCheckToggle.Text = wallCheckEnabled and "WallCheck: ON" or "WallCheck: OFF"
    WallCheckToggle.TextColor3 = wallCheckEnabled and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end)

FovBox.FocusLost:Connect(function()
    local val = tonumber(FovBox.Text)
    if val then
        fovRadius = val
        FovLabel.Text = "Радиус FOV: " .. val
    end
end)

-- Проверка видимости через стены (Raycast)
local function checkVisible(targetPart)
    if not wallCheckEnabled then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    local result = workspace:Raycast(origin, direction, rayParams)
    return result == nil
end

-- Поиск ближайшего цели в FOV
local function getClosestPlayer()
    local closest = nil
    local shortestDist = fovRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < shortestDist then
                        if checkVisible(rootPart) then
                            shortestDist = dist
                            closest = rootPart
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Основной цикл наведения (мгновенный лок)
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)
