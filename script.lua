local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    AimbotEnabled = false,
    AimbotFOVRadius = 100,
    ShowAimbotFOV = false,
    FlickbotEnabled = false,
    FlickFOVRadius = 120,
    ShowFlickFOV = false,
    RagebotEnabled = false,
    ReloadMultiplier = 1, -- Множитель скорости перезарядки
    WallCheck = true,
    ChamsEnabled = false,
    TargetPart = "Head"
}

local AimCircle = Drawing.new("Circle")
AimCircle.Thickness = 1.5
AimCircle.Color = Color3.fromRGB(255, 50, 50)
AimCircle.Filled = false
AimCircle.Transparency = 1

local FlickCircle = Drawing.new("Circle")
FlickCircle.Thickness = 1.5
FlickCircle.Color = Color3.fromRGB(180, 50, 255)
FlickCircle.Filled = false
FlickCircle.Transparency = 1

local function GetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function IsAlive(p)
    if not p or p == LocalPlayer or not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return hum:GetState() ~= Enum.HumanoidStateType.Dead
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

local function ApplyChams(p)
    if not IsAlive(p) then return end
    local char = p.Character
    local highlight = char:FindFirstChild("Apex_RedChams")

    if Settings.ChamsEnabled then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "Apex_RedChams"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = char
        end
    else
        if highlight then highlight:Destroy() end
    end
end

local function GetClosestTargetInFOV(maxRadius)
    local closestHead = nil
    local shortestDistance = maxRadius
    local centerPos = GetScreenCenter()

    for _, p in ipairs(Players:GetPlayers()) do
        if IsAlive(p) and p.Character:FindFirstChild(Settings.TargetPart) then
            local head = p.Character[Settings.TargetPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local headPos2D = Vector2.new(screenPos.X, screenPos.Y)
                local dist = (headPos2D - centerPos).Magnitude
                if dist <= shortestDistance and IsVisible(head) then
                    closestHead = head
                    shortestDistance = dist
                end
            end
        end
    end
    return closestHead
end

local function GetAnyVisibleTarget()
    local closestHead = nil
    local shortestDistance = math.huge
    local myPosition = Camera.CFrame.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if IsAlive(p) and p.Character:FindFirstChild(Settings.TargetPart) then
            local head = p.Character[Settings.TargetPart]
            local dist = (head.Position - myPosition).Magnitude
            
            if dist < shortestDistance and IsVisible(head) then
                closestHead = head
                shortestDistance = dist
            end
        end
    end
    return closestHead
end

-- Стрельба без блокировки тачскрина
local function ForceToolShoot()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

-- Логика ускорения анимации перезарядки
local function AdjustReloadSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local name = string.lower(track.Animation.Name or "")
                if string.find(name, "reload") or string.find(name, "reload") then
                    track:AdjustSpeed(Settings.ReloadMultiplier)
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not Settings.FlickbotEnabled then return end
    local inputType = input.UserInputType
    local isClick = (inputType == Enum.UserInputType.MouseButton1)
    local isTouch = (inputType == Enum.UserInputType.Touch)

    if isClick or isTouch then
        local targetHead = GetClosestTargetInFOV(Settings.FlickFOVRadius)
        if targetHead then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local centerPos = GetScreenCenter()
    
    AimCircle.Position = centerPos
    AimCircle.Radius = Settings.AimbotFOVRadius
    AimCircle.Visible = Settings.ShowAimbotFOV and Settings.AimbotEnabled

    FlickCircle.Position = centerPos
    FlickCircle.Radius = Settings.FlickFOVRadius
    FlickCircle.Visible = Settings.ShowFlickFOV and Settings.FlickbotEnabled

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then ApplyChams(p) end
    end

    if Settings.ReloadMultiplier > 1 then
        AdjustReloadSpeed()
    end

    if Settings.RagebotEnabled then
        local rageTarget = GetAnyVisibleTarget()
        if rageTarget then
            local originalCFrame = Camera.CFrame
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, rageTarget.Position)
            ForceToolShoot()
            task.wait()
            Camera.CFrame = originalCFrame
        end
    elseif Settings.AimbotEnabled then
        local targetHead = GetClosestTargetInFOV(Settings.AimbotFOVRadius)
        if targetHead then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)

local ParentContainer = (gethui and gethui()) 
    or game:GetService("CoreGui") 
    or LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexF_CleanGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentContainer

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
MainFrame.Size = UDim2.new(0, 320, 0, 390)
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
Title.Text = "ApexF — Touch Fix Update"
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
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 510)
ScrollContainer.Parent = MainFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollContainer

local function CreateToggle(name, defaultState, callback)
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -5, 0, 36)
local activeColor = Color3.fromRGB(40, 160, 80)
local inactiveColor = Color3.fromRGB(40, 40, 50)
Button.BackgroundColor3 = defaultState and activeColor or inactiveColor
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
Button.BackgroundColor3 = state and activeColor or inactiveColor
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

CreateToggle("Constant Aimbot", Settings.AimbotEnabled, function(s) Settings.AimbotEnabled = s end)
CreateInput("Aimbot FOV (10-800):", Settings.AimbotFOVRadius, function(i)
local v = tonumber(i.Text)
if v then
Settings.AimbotFOVRadius = math.clamp(v, 10, 800)
i.Text = tostring(Settings.AimbotFOVRadius)
end
end)
CreateToggle("Show Aimbot FOV", Settings.ShowAimbotFOV, function(s) Settings.ShowAimbotFOV = s end)

CreateToggle("AimFlickBot (Touch/Click)", Settings.FlickbotEnabled, function(s) Settings.FlickbotEnabled = s end)
CreateInput("Flick FOV (10-800):", Settings.FlickFOVRadius, function(i)
local v = tonumber(i.Text)
if v then
Settings.FlickFOVRadius = math.clamp(v, 10, 800)
i.Text = tostring(Settings.FlickFOVRadius)
end
end)
CreateToggle("Show Flick FOV", Settings.ShowFlickFOV, function(s) Settings.ShowFlickFOV = s end)

CreateToggle("Ragebot (No Mouse Block)", Settings.RagebotEnabled, function(s) Settings.RagebotEnabled = s end)
CreateInput("Reload Speed Mult (1-10):", Settings.ReloadMultiplier, function(i)
local v = tonumber(i.Text)
if v then
Settings.ReloadMultiplier = math.clamp(v, 1, 10)
i.Text = tostring(Settings.ReloadMultiplier)
end
end)

CreateToggle("Wall Check (Global)", Settings.WallCheck, function(s) Settings.WallCheck = s end)
CreateToggle("Red Chams (ESP)", Settings.ChamsEnabled, function(s) Settings.ChamsEnabled = s end)

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
