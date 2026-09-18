-- // JJS MENU - DELTA // --
-- // Обновление: Плавающий UI, Исправлен Fly, Убрана нерабочая функция // --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Настройки темы //
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Sidebar = Color3.fromRGB(15, 15, 15),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(130, 130, 130),
    ElementBg = Color3.fromRGB(30, 30, 30),
    ToggleOff = Color3.fromRGB(60, 60, 60)
}

-- // Функция анимации //
local function Tween(obj, time, props)
    local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

-- // Создание GUI //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJS_Menu"
ScreenGui.Parent = game.CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

-- // Плавающая кнопка открытия //
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 60, 0, 60)
OpenButton.Position = UDim2.new(0.1, 0, 0.3, 0)
OpenButton.BackgroundColor3 = Theme.Background
OpenButton.TextColor3 = Theme.Accent
OpenButton.Text = "JJS"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 18
OpenButton.Active = true
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 15)
local stroke = Instance.new("UIStroke", OpenButton)
stroke.Color = Theme.Accent
stroke.Thickness = 2

-- // Анимация пульсации кнопки (Плавающий эффект) //
task.spawn(function()
    while ScreenGui.Parent do
        Tween(OpenButton, 1.5, {Size = UDim2.new(0, 65, 0, 65)})
        task.wait(1.5)
        Tween(OpenButton, 1.5, {Size = UDim2.new(0, 60, 0, 60)})
        task.wait(1.5)
    end
end)

-- // Перетаскивание кнопки //
local btnDragging, btnDragStart, btnStartPos
OpenButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnDragStart = input.Position
        btnStartPos = OpenButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - btnDragStart
        OpenButton.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = false
    end
end)

-- // Главное окно //
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 420, 0, 340)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -170)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Visible = false
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.ToggleOff
mainStroke.Thickness = 2

-- // Анимация открытия/закрытия (Плавающий эффект) //
local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
UIScale.Scale = 0

OpenButton.MouseButton1Click:Connect(function()
    if MainFrame.Visible and UIScale.Scale > 0.5 then
        local t = TweenService:Create(UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
        t:Play()
        t.Completed:Connect(function() MainFrame.Visible = false end)
    else
        MainFrame.Visible = true
        TweenService:Create(UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
end)

-- Заголовок меню (для перетаскивания)
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Theme.Sidebar
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "JJS Script | Delta"
TitleText.TextColor3 = Theme.Text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14

-- Перетаскивание меню
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Левая панель (Вкладки)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 110, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 5)

-- Контейнер для контента
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -110, 1, -40)
ContentArea.Position = UDim2.new(0, 110, 0, 40)
ContentArea.BackgroundTransparency = 1

-- // Создание вкладок //
local Tabs = {}
local ActiveTab = nil

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Parent = Sidebar
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local indicator = Instance.new("Frame")
    indicator.Parent = btn
    indicator.Size = UDim2.new(0, 4, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.BackgroundColor3 = Theme.Accent
    indicator.BorderSizePixel = 0
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    
    local content = Instance.new("ScrollingFrame")
    content.Parent = ContentArea
    content.Size = UDim2.new(1, -20, 1, -20)
    content.Position = UDim2.new(0, 10, 0, 10)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.ScrollBarThickness = 2
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIListLayout", content)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    
    table.insert(Tabs, {Button = btn, Content = content, Indicator = indicator})
    
    btn.MouseButton1Click:Connect(function()
        for _, tab in ipairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.TextColor3 = Theme.TextDim
            Tween(tab.Indicator, 0.2, {Size = UDim2.new(0, 4, 0, 0)})
        end
        content.Visible = true
        btn.TextColor3 = Theme.Text
        Tween(indicator, 0.2, {Size = UDim2.new(0, 4, 0, 25)})
        ActiveTab = name
    end)
    
    return content
end

local MainTab = CreateTab("Main", "🏠")
local TeleportTab = CreateTab("Teleport", "✈️")

Tabs[1].Button.TextColor3 = Theme.Text
Tabs[1].Content.Visible = true
Tween(Tabs[1].Indicator, 0.2, {Size = UDim2.new(0, 4, 0, 25)})
ActiveTab = "Main"


-- // UI КОМПОНЕНТЫ //
local function CreateToggle(parent, text, defaultState, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Theme.ElementBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Parent = frame
    toggleBg.Size = UDim2.new(0, 44, 0, 22)
    toggleBg.Position = UDim2.new(1, -54, 0.5, -11)
    toggleBg.BackgroundColor3 = defaultState and Theme.Accent or Theme.ToggleOff
    toggleBg.BorderSizePixel = 0
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Parent = toggleBg
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local state = defaultState
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        Tween(toggleBg, 0.2, {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff})
        Tween(knob, 0.2, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
        Tween(frame, 0.1, {BackgroundColor3 = state and Theme.Accent or Theme.ElementBg})
        callback(state)
    end)
    
    return frame
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = frame
    sliderBg.Size = UDim2.new(1, 0, 0, 12)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Theme.ToggleOff
    sliderBg.BorderSizePixel = 0
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderBg
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Parent = sliderBg
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local kStroke = Instance.new("UIStroke", knob)
    kStroke.Color = Theme.Accent
    kStroke.Thickness = 2
    
    local dragging = false
    local function update(input)
        local mouseX = input.Position.X
        local pos = sliderBg.AbsolutePosition.X
        local size = sliderBg.AbsoluteSize.X
        local pct = math.clamp((mouseX - pos) / size, 0, 1)
        local val = math.floor(min + (max - min) * pct)
        
        label.Text = text .. ": " .. val
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -10, 0.5, -10)
        callback(val)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Tween(knob, 0.1, {Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(knob.Position.X.Scale, -12, 0.5, -12)})
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Tween(knob, 0.1, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(knob.Position.X.Scale, -10, 0.5, -10)})
        end
    end)
    
    return frame
end


-- // ФУНКЦИИ MAIN (FLY) //
local FlyEnabled = false
local FlySpeed = 60
local bodyVelocity

-- Создаем тоггл для Fly
CreateToggle(MainTab, "Fly", false, function(state)
    FlyEnabled = state
    if not state and bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end)

-- Создаем слайдер скорости
CreateSlider(MainTab, "Speed", 10, 300, 60, function(val)
    FlySpeed = val
end)

-- Логика полета (Куда смотрит камера)
RunService.RenderStepped:Connect(function()
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Velocity = Vector3.new(0,0,0)
            bodyVelocity.Parent = hrp
        end
        
        local moveDir = humanoid.MoveDirection
        local camCFrame = Camera.CFrame
        
        local camForward = camCFrame.LookVector
        local camRight = camCFrame.RightVector
        
        local direction = Vector3.new(0,0,0)
        if moveDir.Magnitude > 0.1 then
            direction = (camForward * moveDir.Z + camRight * moveDir.X).Unit
        end
        
        local vertical = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = Vector3.new(0, -1, 0) end
        
        bodyVelocity.Velocity = (direction * FlySpeed) + (vertical * FlySpeed)
    else
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
end)


-- // ФУНКЦИИ TELEPORT //
local selectedPlayer = nil

local PlayerListLabel = Instance.new("TextLabel")
PlayerListLabel.Parent = TeleportTab
PlayerListLabel.Size = UDim2.new(1, 0, 0, 20)
PlayerListLabel.BackgroundTransparency = 1
PlayerListLabel.Text = "Select Player:"
PlayerListLabel.TextColor3 = Theme.Text
PlayerListLabel.Font = Enum.Font.GothamBold
PlayerListLabel.TextSize = 14
PlayerListLabel.TextXAlignment = Enum.TextXAlignment.Left

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Parent = TeleportTab
PlayerList.Size = UDim2.new(1, 0, 0, 100)
PlayerList.BackgroundColor3 = Theme.ElementBg
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 2
Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 6)
local ListLayout = Instance.new("UIListLayout", PlayerList)
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.Name

-- Оставляем только рабочую кнопку телепорта
local TpToPlayerBtn = Instance.new("TextButton")
TpToPlayerBtn.Parent = TeleportTab
TpToPlayerBtn.Size = UDim2.new(1, 0, 0, 40)
TpToPlayerBtn.BackgroundColor3 = Theme.Accent
TpToPlayerBtn.TextColor3 = Theme.Text
TpToPlayerBtn.Text = "Teleport Me to Player"
TpToPlayerBtn.Font = Enum.Font.GothamBold
TpToPlayerBtn.TextSize = 14
Instance.new("UICorner", TpToPlayerBtn).CornerRadius = UDim.new(0, 8)

-- Анимация нажатия
TpToPlayerBtn.MouseButton1Down:Connect(function()
    Tween(TpToPlayerBtn, 0.1, {Size = UDim2.new(0.95, 0, 0, 38)})
end)
TpToPlayerBtn.MouseButton1Up:Connect(function()
    Tween(TpToPlayerBtn, 0.1, {Size = UDim2.new(1, 0, 0, 40)})
end)

local function UpdatePlayerList()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Parent = PlayerList
            btn.Size = UDim2.new(1, -4, 0, 28)
            btn.BackgroundColor3 = Theme.Background
            btn.TextColor3 = Theme.TextDim
            btn.Text = plr.Name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                for _, otherBtn in ipairs(PlayerList:GetChildren()) do
                    if otherBtn:IsA("TextButton") then
                        otherBtn.BackgroundColor3 = Theme.Background
                        otherBtn.TextColor3 = Theme.TextDim
                    end
                end
                btn.BackgroundColor3 = Theme.Accent
                btn.TextColor3 = Theme.Text
            end)
        end
    end
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()

local function GetCharacter(plr)
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        return plr.Character.HumanoidRootPart
    end
    return nil
end

-- Оставляем только рабочий телепорт
TpToPlayerBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        local myHrp = GetCharacter(LocalPlayer)
        local targetHrp = GetCharacter(selectedPlayer)
        
        if myHrp and targetHrp then
            myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

-- Уведомление о загрузке
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "JJS Script",
    Text = "Меню обновлено и готово к работе!",
    Duration = 3
})
