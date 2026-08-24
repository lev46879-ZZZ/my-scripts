local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- НАСТРОЙКИ
local Settings = {
    AimbotEnabled = false,
    AimbotFOVRadius = 100,
    ShowAimbotFOV = false,

    TriggerbotEnabled = false,
    TriggerbotDelay = 0.05,

    Wallshot = false,
    WallCheck = false,
    TargetPart = "Head"
}

-- FOV Круг
local AimCircle = Drawing.new("Circle")
AimCircle.Thickness = 1.5
AimCircle.Color = Color3.fromRGB(255, 50, 50)
AimCircle.Filled = false
AimCircle.Transparency = 1

local function GetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- Безопасная проверка живого игрока
local function IsAlive(player)
    if not player or player == LocalPlayer or not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if humanoid:GetState() == Enum.HumanoidStateType.Dead then return false end
    return true
end

-- Проверка видимости
local function IsVisible(targetHead)
    if Settings.Wallshot then return true end
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

-- Поиск цели для Aimbot
local function GetClosestTarget(maxRadius)
    local closestHead = nil
    local shortestDistance = maxRadius
    local centerPos = GetScreenCenter()

    for _, player in ipairs(Players:GetPlayers()) do
        if IsAlive(player) and player.Character:FindFirstChild(Settings.TargetPart) then
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
    return closestHead
end

-- Проверка Triggerbot
local function CheckTriggerbot()
    local centerPos = GetScreenCenter()

    if Settings.Wallshot then
        for _, player in ipairs(Players:GetPlayers()) do
            if IsAlive(player) then
                local head = player.Character:FindFirstChild(Settings.TargetPart)
                if head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                        if dist <= 25 then
                            return true
                        end
                    end
                end
            end
        end
        return false
    else
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        local ignoreList = {Camera}
        if LocalPlayer.Character then
            table.insert(ignoreList, LocalPlayer.Character)
        end
        raycastParams.FilterDescendantsInstances = ignoreList

        local centerRay = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local result = workspace:Raycast(centerRay.Origin, centerRay.Direction * 1000, raycastParams)

        if result and result.Instance then
            local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
            if hitModel then
                local player = Players:GetPlayerFromCharacter(hitModel)
                if IsAlive(player) then
                    return true
                end
            end
        end
        return false
    end
end

-- Безопасный клик без блокировки потока персонажа
local isShooting = false
local function SafeClick()
    if isShooting then return end
    isShooting = true
    
    task.spawn(function()
        if mouse1press and mouserelease then
            mouse1press()
            task.wait(0.01)
            mouserelease()
        elseif mouse1click then
            mouse1click()
        end
        task.wait(Settings.TriggerbotDelay)
        isShooting = false
    end)
end

-- Главный цикл
RunService.RenderStepped:Connect(function()
    local centerPos = GetScreenCenter()
    
    AimCircle.Position = centerPos
    AimCircle.Radius = Settings.AimbotFOVRadius
    AimCircle.Visible = Settings.ShowAimbotFOV and Settings.AimbotEnabled

    -- Aimbot
    if Settings.AimbotEnabled then
        local targetHead = GetClosestTarget(Settings.AimbotFOVRadius)
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end

    -- Triggerbot
    if Settings.TriggerbotEnabled then
        if CheckTriggerbot() then
            SafeClick()
        end
    end
end)

-- ================= GUI И ЛОЙДЕР =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexF_CleanGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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
LoaderTitle.Text = "ApexF | Loading..."
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

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 320)
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
Title.Text = "ApexF — Combat"
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
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 360)
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

CreateToggle("Aimbot (Instant Head)", Settings.AimbotEnabled, function(s) Settings.AimbotEnabled = s end)
CreateInput("Aimbot FOV (10-300):", Settings.AimbotFOVRadius, function(i)
    local v = tonumber(i.Text)
    if v then Settings.AimbotFOVRadius = math.clamp(v, 10, 300) i.Text = tostring(Settings.AimbotFOVRadius) end
end)
CreateToggle("Show Aimbot FOV", Settings.ShowAimbotFOV, function(s) Settings.ShowAimbotFOV = s end)

CreateToggle("Triggerbot", Settings.TriggerbotEnabled, function(s) Settings.TriggerbotEnabled = s end)
CreateInput("Trigger Delay (sec):", Settings.TriggerbotDelay, function(i)
    local v = tonumber(i.Text)
    if v then Settings.TriggerbotDelay = math.clamp(v, 0.01, 1.0) i.Text = tostring(Settings.TriggerbotDelay) end
end)

CreateToggle("Wallshot (Through Walls)", Settings.Wallshot, function(s) Settings.Wallshot = s end)
CreateToggle("Wall Check", Settings.WallCheck, function(s) Settings.WallCheck = s end)

local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(BarFill, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
tween:Play()

tween.Completed:Connect(function()
    LoaderTitle.Text = "Loaded!"
    task.wait(0.2)
    LoaderFrame:Destroy()
    ToggleButton.Visible = true
    MainFrame.Visible = true
end)
