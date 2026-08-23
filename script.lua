local success, err = pcall(function()
    print("[Flick UI]: Запуск UI с полным функционалом Combat и Visual...")

    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    -- Удаление старой копии меню
    if CoreGui:FindFirstChild("FlickMenuGui") then
        CoreGui.FlickMenuGui:Destroy()
    end

    -- Главный контейнер
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FlickMenuGui"
    ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    -- ГЛОБАЛЬНЫЕ НАСТРОЙКИ (КОМБАТ И ВИЗУАЛ)
    _G.Aimbot_Enabled = false
    _G.SilentAim_Enabled = false
    _G.FOV_Enabled = false
    _G.WallCheck_Enabled = false
    _G.WallShot_Enabled = false
    _G.FOV_Radius = 120

    _G.ESP_Boxes_Enabled = false
    _G.Chams_Enabled = false

    -- Создание круга FOV (Drawing API)
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(0, 150, 255)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.8
    FOVCircle.Visible = false

    -- ГЛАВНОЕ ОКНО МЕНЮ
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    -- Анимация появления меню
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 520, 0, 340)
    }):Play()

    -- ПЛАВАЮЩАЯ КНОПКА "NLF"
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 65, 0, 65)
    ToggleButton.Position = UDim2.new(0, 20, 0.15, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    ToggleButton.Text = "NLF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 16
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
    ToggleButton.Parent = ScreenGui

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = ToggleButton
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(0, 150, 255)
    ButtonStroke.Thickness = 1.5
    ButtonStroke.Parent = ToggleButton

    -- Функция перетаскивания (Drag)
    local function makeDraggable(frame)
        local dragging, dragInput, dragStart, startPos
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    makeDraggable(MainFrame)
    makeDraggable(ToggleButton)

    -- Анимация клика по плавающей кнопке
    local menuOpen = true
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(ToggleButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 55, 0, 55),
                BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            }):Play()
        end
    end)

    ToggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(ToggleButton, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 65, 0, 65),
                BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            }):Play()
        end
    end)

    -- Открытие/Закрытие меню
    ToggleButton.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        local targetSize = menuOpen and UDim2.new(0, 520, 0, 340) or UDim2.new(0, 0, 0, 0)
        local targetStyle = menuOpen and Enum.EasingStyle.Back or Enum.EasingStyle.Quad
        
        TweenService:Create(MainFrame, TweenInfo.new(0.4, targetStyle, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
    end)

    -- Верхняя панель вкладок
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar

    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.FillDirection = Enum.FillDirection.Horizontal
    TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabsLayout.Padding = UDim.new(0, 8)
    TabsLayout.Parent = TopBar

    -- Контейнер для страниц
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, -55)
    Container.Position = UDim2.new(0, 0, 0, 55)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local Pages = {}
    local Buttons = {}

    local function createTab(tabName)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 110, 0, 34)
        tabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.fromRGB(140, 140, 160)
        tabBtn.TextSize = 14
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.Parent = TopBar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = tabBtn
        
        local pageFrame = Instance.new("ScrollingFrame")
        pageFrame.Size = UDim2.new(1, -24, 1, -24)
        pageFrame.Position = UDim2.new(0, 12, 0, 12)
        pageFrame.BackgroundTransparency = 1
        pageFrame.Visible = false
        pageFrame.ScrollBarThickness = 2
        pageFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
        pageFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        pageFrame.Parent = Container
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.Parent = pageFrame
        
        Buttons[tabName] = tabBtn
        Pages[tabName] = pageFrame
        
        tabBtn.MouseButton1Click:Connect(function()
            for pName, pObj in pairs(Pages) do
                pObj.Visible = (pName == tabName)
            end
            for bName, bObj in pairs(Buttons) do
                local isSelected = (bName == tabName)
                TweenService:Create(bObj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = isSelected and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(28, 28, 38),
                    TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 160)
                }):Play()
            end
        end)
        return pageFrame
    end

    local pMain = createTab("Main")
    local pCombat = createTab("Combat")
    local pVisual = createTab("Visual")
    local pSettings = createTab("Settings")

    Buttons["Main"].BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Buttons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
    Pages["Main"].Visible = true

    -- Функция добавления переключателей (Toggle)
    local function addToggle(page, text, callback)
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(1, 0, 0, 40)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        toggleBtn.Text = "   " .. text
        toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
        toggleBtn.TextSize = 14
        toggleBtn.Font = Enum.Font.GothamMedium
        toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
        toggleBtn.Parent = page
        
        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 8)
        tCorner.Parent = toggleBtn
        
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 22, 0, 22)
        indicator.Position = UDim2.new(1, -32, 0.5, -11)
        indicator.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        indicator.Parent = toggleBtn
        
        local iCorner = Instance.new("UICorner")
        iCorner.CornerRadius = UDim.new(0, 6)
        iCorner.Parent = indicator
        
        local toggled = false
toggleBtn.MouseButton1Click:Connect(function()
toggled = not toggled
TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
BackgroundColor3 = toggled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 55)
}):Play()
callback(toggled)
end)
end

-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ДЛЯ COMBAT (AIMBOT / SILENT AIM)
local function isVisible(targetPart, character)
if not _G.WallCheck_Enabled then return true end
if _G.WallShot_Enabled then return true end -- WallShot игнорирует стены

local castPoints = {Camera.CFrame.Position, targetPart.Position}
local ignoreList = {LocalPlayer.Character, character, Camera}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = ignoreList
raycastParams.IgnoreWater = true

local direction = targetPart.Position - Camera.CFrame.Position
local raycastResult = Workspace:Raycast(Camera.CFrame.Position, direction, raycastParams)

return raycastResult == nil
end

local function getClosestPlayer()
local closestPlayer = nil
local shortestDistance = math.huge
local mousePos = UserInputService:GetMouseLocation()

for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
local char = player.Character
local head = char:FindFirstChild("Head") or char.HumanoidRootPart
local humanoid = char.Humanoid

if humanoid.Health > 0 then
local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

if onScreen then
local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

-- Проверка на нахождение в радиусе FOV
if distance < _G.FOV_Radius and distance < shortestDistance then
if isVisible(head, char) then
shortestDistance = distance
closestPlayer = char
end
end
end
end
end
end
return closestPlayer
end

