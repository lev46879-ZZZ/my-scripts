local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Безопасные настройки ApexF
local Settings = {
    AimbotEnabled = false,
    AimbotFOVRadius = 80,
    ShowAimbotFOV = true,
    Smoothness = 0.2, -- Чем меньше число (0.05-0.3), тем плавнее и безопаснее наводка

    SilentAimEnabled = false,
    SilentFOVRadius = 60,
    ShowSilentFOV = true,
    AutoShoot = false,
    ShootDelay = 0.25,

    WallCheck = true, -- Обязательно включено для защиты от стеновых киков
    TargetPart = "Head"
}

local AimCircle = Drawing.new("Circle")
AimCircle.Thickness = 1.5
AimCircle.Color = Color3.fromRGB(255, 50, 50)
AimCircle.Filled = false
AimCircle.Transparency = 1

local SilentCircle = Drawing.new("Circle")
SilentCircle.Thickness = 1.5
SilentCircle.Color = Color3.fromRGB(0, 200, 255)
SilentCircle.Filled = false
SilentCircle.Transparency = 1

local function GetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

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

-- Безопасный Silent Aim (pcall от вылетов/киков)
pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and Settings.SilentAimEnabled and key == "Hit" then
            local target = GetClosestTarget(Settings.SilentFOVRadius)
            if target then
                return target.CFrame
            end
        end
        return oldIndex(self, key)
    end)
end)

local lastShootTime = 0
RunService.RenderStepped:Connect(function()
    local centerPos = GetScreenCenter()
    
    AimCircle.Position = centerPos
    AimCircle.Radius = Settings.AimbotFOVRadius
    AimCircle.Visible = Settings.ShowAimbotFOV and Settings.AimbotEnabled

    SilentCircle.Position = centerPos
    SilentCircle.Radius = Settings.SilentFOVRadius
    SilentCircle.Visible = Settings.ShowSilentFOV and Settings.SilentAimEnabled

    -- Плавный Aimbot без телепортации камеры
    if Settings.AimbotEnabled then
        local targetHead = GetClosestTarget(Settings.AimbotFOVRadius)
        if targetHead then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
        end
    end

    if Settings.SilentAimEnabled and Settings.AutoShoot then
        local silentTarget = GetClosestTarget(Settings.SilentFOVRadius)
        if silentTarget and (tick() - lastShootTime) >= Settings.ShootDelay then
            lastShootTime = tick()
            if mouse1click then mouse1click() end
        end
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexF_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleButton.TextColor3 = Color3.fromRGB(0, 200, 255)
ToggleButton.Text = "ApexF"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Title.Text = "ApexF — Safe Combat"
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
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 550)
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
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

CreateToggle("Aimbot", Settings.AimbotEnabled, function(s) Settings.AimbotEnabled = s end)
CreateInput("Smoothness (0.05-0.5):", Settings.Smoothness, function(i) 
    local v = tonumber(i.Text)
    if v then Settings.Smoothness = math.clamp(v, 0.05, 0.5) i.Text = tostring(Settings.Smoothness) end
end)
CreateInput("Aimbot FOV:", Settings.AimbotFOVRadius, function(i) 
    local v = tonumber(i.Text)
    if v then Settings.AimbotFOVRadius = math.clamp(v, 10, 300) i.Text = tostring(Settings.AimbotFOVRadius) end
end)
CreateToggle("Show Aim FOV", Settings.ShowAimbotFOV, function(s) Settings.ShowAimbotFOV = s end)

CreateToggle("Silent Aim (Выключи если кикает)", Settings.SilentAimEnabled, function(s) Settings.SilentAimEnabled = s end)
CreateInput("Silent FOV:", Settings.SilentFOVRadius, function(i) 
    local v = tonumber(i.Text)
    if v then Settings.SilentFOVRadius = math.clamp(v, 10, 300) i.Text = tostring(Settings.SilentFOVRadius) end
end)
CreateToggle("Silent Auto Shoot", Settings.AutoShoot, function(s) Settings.AutoShoot = s end)
CreateInput("Shoot Delay (sec):", Settings.ShootDelay, function(i) 
    local v = tonumber(i.Text)
    if v then Settings.ShootDelay = math.clamp(v, 0.1, 1.0) i.Text = tostring(Settings.ShootDelay) end
end)
CreateToggle("Wall Check (Обязательно)", Settings.WallCheck, function(s) Settings.WallCheck = s end)
