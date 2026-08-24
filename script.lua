task.wait(4)

local Fluent = loadstring(game:HttpGet("https://github.com"))()
local SaveManager = loadstring(game:HttpGet("https://githubusercontent.com"))()
local InterfaceManager = loadstring(game:HttpGet("https://githubusercontent.com"))()

local Window = Fluent:CreateWindow({
    Title = "Delta Premium Mobile",
    SubTitle = "Flick Mobile Edition",
    TabWidth = 140,
    Size = UDim2.fromOffset(500, 320),
    Acrylic = false,
    Theme = "Dark"
})

local ToggleButton = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ToggleButton.Name = "DeltaGuiToggleButton"
ToggleButton.Parent = game:GetService("CoreGui")
ToggleButton.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Button.Name = "Button"
Button.Parent = ToggleButton
Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Button.Position = UDim2.new(0, 15, 0, 15)
Button.Size = UDim2.new(0, 50, 0, 50)
Button.Font = Enum.Font.GothamBold
Button.Text = "D"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 22.000
Button.Active = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Button

UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.Parent = Button

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    Button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Button.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

Button.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

local Tabs = {
    Combat = Window:AddTab({ Title = "Бой", Icon = "swords" }),
    Visuals = Window:AddTab({ Title = "Визуалы", Icon = "scan" }),
    Main = Window:AddTab({ Title = "Настройки", Icon = "sliders" })
}

local Options = Fluent.Options
local AimbotEnabled = false
local FlickEnabled = false
local SilentAimEnabled = false
local WallCheckEnabled = false
local EspEnabled = false
local CharmsEnabled = false

local AimbotFOV = 100
local FlickFOV = 100
local SilentAimFOV = 100
local EspColor = Color3.fromRGB(255, 255, 255)
local CharmsColor = Color3.fromRGB(255, 255, 255)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local EspObjects = {}

local function IsPlayerVisible(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then 
        return false 
    end
    
    local targetHead = targetPlayer.Character.Head
    local origin = Camera.CFrame.Position
    local direction = targetHead.Position - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if not raycastResult then
        return true
    end
    
    if raycastResult.Instance:IsDescendantOf(targetPlayer.Character) then
        return true
    end
    
    return false
end

local function GetClosestPlayerForFOV(maxFov)
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health > 0 then
            
            if WallCheckEnabled and not IsPlayerVisible(player) then
                continue
            end

            local headPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            
            if onScreen then
                local distanceToMouse = (Vector2.new(headPos.X, headPos.Y) - mousePosition).Magnitude
                
                if distanceToMouse < maxFov and distanceToMouse < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distanceToMouse
                end
            end
        end
    end
    return closestPlayer
end

local function CreateEsp(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = EspColor
    box.Thickness = 1
    box.Filled = false

    EspObjects[player] = box
end

local function RemoveEsp(player)
    if EspObjects[player] then
        EspObjects[player]:Remove()
        EspObjects[player] = nil
    end
end

local function UpdateCharms(player)
    local char = player.Character
    if not char then return end

    local highlight = char:FindFirstChild("CharmsHighlight")
    if CharmsEnabled then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "CharmsHighlight"
            highlight.Parent = char
        end
        highlight.FillColor = CharmsColor
        highlight.OutlineColor = CharmsColor
        highlight.FillOpacity = 0.5
        highlight.OutlineOpacity = 1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    else
        if highlight then
            highlight:Destroy()
        end
    end
end

Tabs.Combat:AddToggle("AimbotToggle", {
    Title = "Включить Аимбот (Постоянный)",
    Default = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end
})

Tabs.Combat:AddSlider("FOVSlider", {
    Title = "Радиус FOV для Аимбота",
    Description = "Зона захвата обычного аимбота",
    Default = 100,
    Min = 10,
    Max = 900,
    Rounding = 0,
    Callback = function(Value)
        AimbotFOV = Value
    end
})

Tabs.Combat:AddToggle("FlickToggle", {
    Title = "Включить Флик Аимбот (При тапе)",
    Default = false,
    Callback = function(Value)
        FlickEnabled = Value
    end
})

Tabs.Combat:AddSlider("FlickFOVSlider", {
    Title = "Радиус FOV для Фликов",
    Description = "Зона захвата флик-аимбота",
    Default = 100,
    Min = 10,
    Max = 900,
    Rounding = 0,
    Callback = function(Value)
        FlickFOV = Value
    end
})

Tabs.Combat:AddToggle("SilentAimToggle", {
    Title = "Включить Сайлент Аим",
    Default = false,
    Callback = function(Value)
        SilentAimEnabled = Value
    end
})

Tabs.Combat:AddSlider("SilentAimFOVSlider", {
    Title = "Радиус FOV для Сайлент Аима",
    Description = "Зона доводки пуль без поворота камеры",
    Default = 100,
    Min = 10,
    Max = 900,
    Rounding = 0,
    Callback = function(Value)
        SilentAimFOV = Value
    end
})

Tabs.Visuals:AddToggle("EspToggle", {
    Title = "Включить ESP Квадрат",
    Default = false,
    Callback = function(Value)
        EspEnabled = Value
        if not Value then
            for _, box in pairs(EspObjects) do
                box.Visible = false
            end
        end
    end
})

Tabs.Visuals:AddColorpicker("EspColorPicker", {
    Title = "Цвет ESP Квадрата",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        EspColor = Value
        for _, box in pairs(EspObjects) do
            box.Color = Value
        end
    end
})

Tabs.Visuals:AddToggle("CharmsToggle", {
    Title = "Включить Charms обводку",
    Default = false,
    Callback = function(Value)
        CharmsEnabled = Value
        for _, player in ipairs(Players:GetPlayers()) do
            UpdateCharms(player)
        end
    end
})

Tabs.Visuals:AddColorpicker("CharmsColorPicker", {
    Title = "Цвет Charms обводки",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        CharmsColor = Value
        for _, player in ipairs(Players:GetPlayers()) do
            UpdateCharms(player)
        end
    end
})

Tabs.Main:AddToggle("WallCheckToggle", {
    Title = "Включить Проверку Стен",
    Description = "Фильтр видимости целей",
    Default = false,
    Callback = function(Value)
        WallCheckEnabled = Value
    end
})

local OldIndex
OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
    if SilentAimEnabled and self == Mouse and not checkcaller() then
        local target = GetClosestPlayerForFOV(SilentAimFOV)
        if target and target.Character and target.Character:FindFirstChild("Head") then
            if index == "Hit" then
                return target.Character.Head.CFrame
            elseif index == "Target" then
                return target.Character.Head
            end
        end
    end
    return OldIndex(self, index)
end))

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateEsp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateEsp(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
RemoveEsp(player)
end)

RunService.RenderStepped:Connect(function()
if AimbotEnabled then
local target = GetClosestPlayerForFOV(AimbotFOV)
if target and target.Character and target.Character:FindFirstChild("Head") then
Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
end
end

for player, box in pairs(EspObjects) do
if EspEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health > 0 then
local hrp = player.Character.HumanoidRootPart
local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

if onScreen then
local sizeX = 2000 / hrpPos.Z
local sizeY = 3000 / hrpPos.Z

box.Size = Vector2.new(sizeX, sizeY)
box.Position = Vector2.new(hrpPos.X - sizeX / 2, hrpPos.Y - sizeY / 2)
box.Visible = true
else
box.Visible = false
end
else
box.Visible = false
end

if CharmsEnabled and player.Character then
UpdateCharms(player)
end
end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
if gameProcessed then return end

if FlickEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
local target = GetClosestPlayerForFOV(FlickFOV)
if target and target.Character and target.Character:FindFirstChild("Head") then
Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
end
end
end)

Fluent:Notify({
Title = "Система",
Content = "Скрипт успешно загружен после 4-секундного ожидания.",
Duration = 5
})

Window:SelectTab(1)

