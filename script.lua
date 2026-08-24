local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ВСЕ НАСТРОЙКИ ОТКЛЮЧЕНЫ ПО УМОЛЧАНИЮ
local Settings = {
    AimbotEnabled = false,
    AimbotFOVRadius = 100,
    ShowAimbotFOV = false,

    SilentAimEnabled = false,
    SilentFOVRadius = 100,
    ShowSilentFOV = false,
    AutoShoot = false,
    ShootDelay = 0.2,

    WallCheck = false,
    TargetPart = "Head"
}

-- FOV Круг для Aimbot (Красный)
local AimCircle = Drawing.new("Circle")
AimCircle.Thickness = 1.5
AimCircle.Color = Color3.fromRGB(255, 50, 50)
AimCircle.Filled = false
AimCircle.Transparency = 1

-- FOV Круг для Silent Aim (Голубой)
local SilentCircle = Drawing.new("Circle")
SilentCircle.Thickness = 1.5
SilentCircle.Color = Color3.fromRGB(0, 200, 255)
SilentCircle.Filled = false
SilentCircle.Transparency = 1

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

-- Поиск ближайшей цели
local function GetClosestTarget(maxRadius)
    local closestHead = nil
    local shortestDistance = maxRadius
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

-- Безопасный Silent Flick (Без использования hookmetamethod)
local function TriggerSilentFlick(target)
    if not target then return end
    local oldCFrame = Camera.CFrame
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    if mouse1click then
        mouse1click()
    end
    task.defer(function()
        Camera.CFrame = oldCFrame
    end)
end

-- Обработка нажатия ручной стрельбы для Silent Aim
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if Settings.SilentAimEnabled and not Settings.AutoShoot then
            local target = GetClosestTarget(Settings.SilentFOVRadius)
            if target then
                TriggerSilentFlick(target)
            end
        end
    end
end)

-- Главный цикл
local lastShootTime = 0
RunService.RenderStepped:Connect(function()
    local centerPos = GetScreenCenter()
    
    -- Видимость FOV
    AimCircle.Position = centerPos
    AimCircle.Radius = Settings.AimbotFOVRadius
    AimCircle.Visible = Settings.ShowAimbotFOV and Settings.AimbotEnabled

    SilentCircle.Position = centerPos
    SilentCircle.Radius = Settings.SilentFOVRadius
    SilentCircle.Visible = Settings.ShowSilentFOV and Settings.SilentAimEnabled

    -- Классический Aimbot
    if Settings.AimbotEnabled then
        local targetHead = GetClosestTarget(Settings.AimbotFOVRadius)
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end

    -- Silent Aim (Автострельба)
    if Settings.SilentAimEnabled and Settings.AutoShoot then
        local silentTarget = GetClosestTarget(Settings.SilentFOVRadius)
        if silentTarget and (tick() - lastShootTime) >= Settings.ShootDelay then
            lastShootTime = tick()
            TriggerSilentFlick(silentTarget)
        end
    end
end)

-- ================= GUI И ЛОЙДЕР =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexF_SafeGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Окно Лойдера
local LoaderFrame = Instance.new("Frame")
LoaderFrame.Size = UDim2.new(0, 260, 0, 100)
LoaderFrame.Position = UDim2.new(0.5, -130, 0.4, 0)
LoaderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
LoaderFrame.Parent = ScreenGui

local LoaderCorner = Instance.new("UICorner")
LoaderCorner.CornerRadius = UDim.new(0, 8)
LoaderCorner.Parent = LoaderFrame

local LoaderTitle = Instance.new("TextLabel")
LoaderTitle.Size = UDim2.new(1, 0, 0, 40)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Text = "ApexF | Safe Initializing..."
LoaderTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
LoaderTitle.Font = Enum.Font.SourceSansBold
LoaderTitle.TextSize = 16
LoaderTitle.Parent = LoaderFrame

local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(0.85, 0, 0, 10)
BarBackground.Position = UDim2.new(0.075, 0, 0.6, 0)
BarBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
BarBackground.Parent = LoaderFrame

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
BarFill.Parent = BarBackground

-- Кнопка Открытия
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "OpenMenuButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleButton.TextColor3 = Color3.fromRGB(0, 200, 255)
ToggleButton.Text = "ApexF"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.Visible = false
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

local OpenUICorner = Instance.new("UICorner")
OpenUICorner.CornerRadius = UDim.new(0, 8)
OpenUICorner.Parent = ToggleButton

-- Главное Меню
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Title.Text = "ApexF — Combat (Undetected)"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -20, 1, -50)
ScrollContainer.Position = UDim2.new(0, 10, 0, 45)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 520)
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollContainer

local function CreateToggle(name, defaultState, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -5, 0, 36)
    Button.BackgroundColor3 = defaultState and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(40, 40, 50)
    Button.Text = name .. ": " .. (defaultState and "ON" or "OFF")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 15
    Button.Parent = ScrollContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local state = defaultState
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.BackgroundColor3 = state and Color3.fromRGB(40, 160, 80) or Color3.fromRGB(40, 40, 50)
        Button.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

local function CreateInput(labelText, defaultValue, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -5, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Frame.Parent = ScrollContainer

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = " " .. labelText
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.Parent = Frame

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(0.3, 0, 0.7, 0)
    Input.Position = UDim2.new(0.67, 0, 0.15, 0)
    Input.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Input.Text = tostring(defaultValue)
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.Font = Enum.Font.SourceSansBold
    Input.TextSize = 14
    Input.Parent = Frame

    Input.FocusLost:Connect(function() callback(Input) end)
end

-- Переключатели
CreateToggle("Aimbot (Instant Head)", Settings.AimbotEnabled, function(s) Settings.AimbotEnabled = s end)
CreateInput("Aimbot FOV (10-300):", Settings.AimbotFOVRadius, function(i)
    local v = tonumber(i.Text)
    if v then Settings.AimbotFOVRadius = math.clamp(v, 10, 300) i.Text = tostring(Settings.AimbotFOVRadius) end
end)
CreateToggle("Show Aimbot FOV", Settings.ShowAimbotFOV, function(s) Settings.ShowAimbotFOV = s end)

CreateToggle("Silent Aim (Micro-Flick)", Settings.SilentAimEnabled, function(s) Settings.SilentAimEnabled = s end)
CreateInput("Silent FOV (10-300):", Settings.SilentFOVRadius, function(i)
    local v = tonumber(i.Text)
    if v then Settings.SilentFOVRadius = math.clamp(v, 10, 300) i.Text = tostring(Settings.SilentFOVRadius) end
end)
CreateToggle("Show Silent FOV", Settings.ShowSilentFOV, function(s) Settings.ShowSilentFOV = s end)

CreateToggle("Silent Auto Shoot", Settings.AutoShoot, function(s) Settings.AutoShoot = s end)
CreateInput("Silent Delay (0.1-1.0):", Settings.ShootDelay, function(i)
    local v = tonumber(i.Text)
    if v then Settings.ShootDelay = math.clamp(v, 0.1, 1.0) i.Text = tostring(Settings.ShootDelay) end
end)

CreateToggle("Wall Check", Settings.WallCheck, function(s) Settings.WallCheck = s end)

-- Анимация загрузки
local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(BarFill, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
tween:Play()

tween.Completed:Connect(function()
    LoaderTitle.Text = "Loaded Successfully!"
    task.wait(0.3)
    LoaderFrame:Destroy()
    ToggleButton.Visible = true
    MainFrame.Visible = true
end)
