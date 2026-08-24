local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки
local Settings = {
    AimbotEnabled = false,
    WallCheck = false,
    FOVRadius = 100,
    ShowFOV = true,
    TargetPart = "Head"
}

-- Создание Круга FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Visible = Settings.ShowFOV

-- Расчет точного центра экрана
local function GetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- Проверка видимости (Wallcheck)
local function IsVisible(targetHead)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetHead.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local ignoreList = {Camera}
    if LocalPlayer.Character then
        table.insert(ignoreList, LocalPlayer.Character)
    end
    raycastParams.FilterDescendantsInstances = ignoreList

    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        return result.Instance:IsDescendantOf(targetHead.Parent)
    end
    return false
end

-- Поиск ближайшей цели относительно центра экрана
local function GetClosestTarget()
    local closestHead = nil
    local shortestDistance = Settings.FOVRadius
    local centerPos = GetScreenCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.TargetPart) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local head = player.Character[Settings.TargetPart]
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                    if dist <= shortestDistance then
                        if IsVisible(head) then
                            closestHead = head
                            shortestDistance = dist
                        end
                    end
                end
            end
        end
    end
    return closestHead
end

-- Главный цикл Aimbot и FOV
RunService.RenderStepped:Connect(function()
    local centerPos = GetScreenCenter()
    FOVCircle.Position = centerPos
    FOVCircle.Radius = Settings.FOVRadius
    FOVCircle.Visible = Settings.ShowFOV

    if Settings.AimbotEnabled then
        local targetHead = GetClosestTarget()
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)

-- GUI Интерфейс
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFlickGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Кнопка открытия/закрытия меню
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "OpenMenuButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "MENU"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

local OpenUICorner = Instance.new("UICorner")
OpenUICorner.CornerRadius = UDim.new(0, 8)
OpenUICorner.Parent = ToggleButton

-- Главная рамка
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 320)
MainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

-- Шапка Меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Title.Text = "Delta Flick — Combat"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = Container

local function CreateToggle(name, defaultState, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = defaultState and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(50, 50, 60)
    Button.Text = name .. ": " .. (defaultState and "ON" or "OFF")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local state = defaultState
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.BackgroundColor3 = state and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(50, 50, 60)
        Button.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

CreateToggle("Aimbot (Instant Head)", Settings.AimbotEnabled, function(state)
    Settings.AimbotEnabled = state
end)

CreateToggle("Wall Check", Settings.WallCheck, function(state)
    Settings.WallCheck = state
end)

CreateToggle("Show FOV Circle", Settings.ShowFOV, function(state)
    Settings.ShowFOV = state
end)

local FOVFrame = Instance.new("Frame")
FOVFrame.Size = UDim2.new(1, 0, 0, 50)
FOVFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
FOVFrame.Parent = Container

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(0, 6)
FOVCorner.Parent = FOVFrame

local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0.6, 0, 1, 0)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Text = " FOV Radius (10-300):"
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVLabel.Font = Enum.Font.SourceSans
FOVLabel.TextSize = 15
FOVLabel.Parent = FOVFrame

local FOVInput = Instance.new("TextBox")
FOVInput.Size = UDim2.new(0.35, -5, 0.7, 0)
FOVInput.Position = UDim2.new(0.62, 0, 0.15, 0)
FOVInput.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
FOVInput.Text = tostring(Settings.FOVRadius)
FOVInput.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVInput.Font = Enum.Font.SourceSansBold
FOVInput.TextSize = 16
FOVInput.Parent = FOVFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 4)
InputCorner.Parent = FOVInput

FOVInput.FocusLost:Connect(function()
    local val = tonumber(FOVInput.Text)
    if val then
        val = math.clamp(val, 10, 300)
        Settings.FOVRadius = val
        FOVInput.Text = tostring(val)
    else
        FOVInput.Text = tostring(Settings.FOVRadius)
    end
end)
