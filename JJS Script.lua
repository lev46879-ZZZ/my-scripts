-- // СКРИПТ ДЛЯ DELTA (JJS) //
-- // Строго по ТЗ //

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки UI (Цвета как на референсе)
local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(150, 150, 150),
    ElementBg = Color3.fromRGB(35, 35, 35),
    ToggleOff = Color3.fromRGB(60, 60, 60)
}

-- // Создание GUI //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJS_Menu"
ScreenGui.Parent = game.CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

-- Главная кнопка открытия (Маленькая иконка)
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0.1, 0, 0.3, 0)
OpenButton.BackgroundColor3 = Theme.Background
OpenButton.TextColor3 = Theme.Accent
OpenButton.Text = "JJS"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 16
OpenButton.Visible = true
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", OpenButton).Color = Theme.Accent

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 320, 0, 240) -- Компактно для телефона
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Visible = false
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Левая панель (Вкладки, там где красный круг)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 50, 1, 0)
Sidebar.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

-- Контейнер для контента
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -50, 1, 0)
ContentArea.Position = UDim2.new(0, 50, 0, 0)
ContentArea.BackgroundTransparency = 1

-- // Логика перетаскивания окна (для телефона) //
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

-- Открытие/Закрытие меню
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- // Создание вкладок (Строго 2 штуки) //
local Tabs = {}
local ActiveTab = nil

local function CreateTab(name, iconText)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Parent = Sidebar
    TabButton.Size = UDim2.new(0, 40, 0, 40)
    TabButton.Position = UDim2.new(0, 5, 0, 10 + (#Tabs * 45)) -- Автоматическое позиционирование
    TabButton.BackgroundColor3 = Theme.Background
    TabButton.TextColor3 = Theme.TextDim
    TabButton.Text = iconText
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 18
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = name .. "Content"
    TabContent.Parent = ContentArea
    TabContent.Size = UDim2.new(1, -20, 1, -20)
    TabContent.Position = UDim2.new(0, 10, 0, 10)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.ScrollBarThickness = 2
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local Layout = Instance.new("UIListLayout", TabContent)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 10)
    
    table.insert(Tabs, {Button = TabButton, Content = TabContent})
    
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in ipairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Theme.Background
            tab.Button.TextColor3 = Theme.TextDim
        end
        TabContent.Visible = true
        TabButton.BackgroundColor3 = Theme.Accent
        TabButton.TextColor3 = Theme.Text
        ActiveTab = name
    end)
    
    return TabContent
end

-- Создаем вкладки: Main и Teleport
local MainTab = CreateTab("Main", "M")
local TeleportTab = CreateTab("Teleport", "T")

-- Активируем Main по умолчанию
Tabs[1].Button.BackgroundColor3 = Theme.Accent
Tabs[1].Button.TextColor3 = Theme.Text
Tabs[1].Content.Visible = true
ActiveTab = "Main"


-- // ФУНКЦИИ MAIN (FLY) //
local FlyEnabled = false
local FlySpeed = 60 -- По умолчанию 60

-- Создание элементов для Main
local FlyToggleBtn = Instance.new("TextButton")
FlyToggleBtn.Parent = MainTab
FlyToggleBtn.Size = UDim2.new(1, 0, 0, 35)
FlyToggleBtn.BackgroundColor3 = Theme.ElementBg
FlyToggleBtn.TextColor3 = Theme.Text
FlyToggleBtn.Text = "Fly: OFF"
FlyToggleBtn.Font = Enum.Font.Gotham
FlyToggleBtn.TextSize = 14
Instance.new("UICorner", FlyToggleBtn).CornerRadius = UDim.new(0, 6)

-- Ползунок скорости
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Parent = MainTab
SpeedFrame.Size = UDim2.new(1, 0, 0, 40)
SpeedFrame.BackgroundColor3 = Theme.ElementBg
SpeedFrame.BackgroundTransparency = 1
Instance.new("UICorner", SpeedFrame).CornerRadius = UDim.new(0, 6)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = SpeedFrame
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: " .. FlySpeed
SpeedLabel.TextColor3 = Theme.Text
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local SliderBg = Instance.new("Frame")
SliderBg.Parent = SpeedFrame
SliderBg.Size = UDim2.new(1, 0, 0, 8)
SliderBg.Position = UDim2.new(0, 0, 0, 25)
SliderBg.BackgroundColor3 = Theme.ToggleOff
SliderBg.BorderSizePixel = 0
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

local SliderFill = Instance.new("Frame")
SliderFill.Parent = SliderBg
SliderFill.Size = UDim2.new((FlySpeed - 10) / 290, 0, 1, 0) -- 10 to 300 range
SliderFill.BackgroundColor3 = Theme.Accent
SliderFill.BorderSizePixel = 0
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

local SliderKnob = Instance.new("Frame")
SliderKnob.Parent = SliderBg
SliderKnob.Size = UDim2.new(0, 16, 0, 16)
SliderKnob.Position = UDim2.new((FlySpeed - 10) / 290, -8, 0.5, -8)
SliderKnob.BackgroundColor3 = Theme.Text
SliderKnob.BorderSizePixel = 0
Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

-- Логика ползунка (Mobile friendly)
local draggingSlider = false
local function updateSlider(input)
    local mouseX = input.Position.X
    local sliderPos = SliderBg.AbsolutePosition.X
    local sliderSize = SliderBg.AbsoluteSize.X
    
    local percentage = math.clamp((mouseX - sliderPos) / sliderSize, 0, 1)
    local value = math.floor(10 + (290 * percentage))
    
    FlySpeed = value
    SpeedLabel.Text = "Speed: " .. FlySpeed
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderKnob.Position = UDim2.new(percentage, -8, 0.5, -8)
end

SliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        updateSlider(input)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

-- Логика Fly (Delta / Mobile)
local bodyVelocity
FlyToggleBtn.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        FlyToggleBtn.Text = "Fly: ON"
        FlyToggleBtn.BackgroundColor3 = Theme.Accent
    else
        FlyToggleBtn.Text = "Fly: OFF"
        FlyToggleBtn.BackgroundColor3 = Theme.ElementBg
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    end
end)

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
        
        -- Управление на мобилке через джойстик (MoveDirection)
        local moveDir = humanoid.MoveDirection
        local camCFrame = Camera.CFrame
        
        local direction = (camCFrame.LookVector * moveDir.Z + camCFrame.RightVector * moveDir.X).Unit
        if moveDir.Magnitude < 0.1 then direction = Vector3.new(0,0,0) end
        
        -- Подъем и спуск (используем кнопки прыжка/приседа, если джойстик не двигает вверх/вниз)
        local vertical = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = Vector3.new(0, -1, 0) end
        
        bodyVelocity.Velocity = (direction * FlySpeed) + (vertical * FlySpeed)
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
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
PlayerListLabel.Font = Enum.Font.Gotham
PlayerListLabel.TextSize = 12
PlayerListLabel.TextXAlignment = Enum.TextXAlignment.Left

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Parent = TeleportTab
PlayerList.Size = UDim2.new(1, 0, 0, 80)
PlayerList.BackgroundColor3 = Theme.ElementBg
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 2
Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 6)
local ListLayout = Instance.new("UIListLayout", PlayerList)
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.Name

-- Кнопки действий
local TpToMeBtn = Instance.new("TextButton")
TpToMeBtn.Parent = TeleportTab
TpToMeBtn.Size = UDim2.new(1, 0, 0, 30)
TpToMeBtn.BackgroundColor3 = Theme.Accent
TpToMeBtn.TextColor3 = Theme.Text
TpToMeBtn.Text = "Teleport Player to Me"
TpToMeBtn.Font = Enum.Font.Gotham
TpToMeBtn.TextSize = 12
Instance.new("UICorner", TpToMeBtn).CornerRadius = UDim.new(0, 6)

local TpToPlayerBtn = Instance.new("TextButton")
TpToPlayerBtn.Parent = TeleportTab
TpToPlayerBtn.Size = UDim2.new(1, 0, 0, 30)
TpToPlayerBtn.BackgroundColor3 = Theme.Accent
TpToPlayerBtn.TextColor3 = Theme.Text
TpToPlayerBtn.Text = "Teleport Me to Player"
TpToPlayerBtn.Font = Enum.Font.Gotham
TpToPlayerBtn.TextSize = 12
Instance.new("UICorner", TpToPlayerBtn).CornerRadius = UDim.new(0, 6)

-- Обновление списка игроков
local function UpdatePlayerList()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Parent = PlayerList
            btn.Size = UDim2.new(1, -4, 0, 25)
            btn.BackgroundColor3 = Theme.Background
            btn.TextColor3 = Theme.TextDim
            btn.Text = plr.Name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 11
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                -- Визуальное выделение
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
UpdatePlayerList() -- Первичная загрузка

-- Логика телепортов
local function GetCharacter(plr)
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        return plr.Character.HumanoidRootPart
    end
    return nil
end

TpToMeBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        local myHrp = GetCharacter(LocalPlayer)
        local targetHrp = GetCharacter(selectedPlayer)
        
        if myHrp and targetHrp then
            -- Телепорт игрока ко мне (может не работать в некоторых играх из-за анти-чита)
            targetHrp.CFrame = myHrp.CFrame * CFrame.new(0, 0, 2) -- Смещаем немного, чтобы не застрять
        end
    end
end)

TpToPlayerBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        local myHrp = GetCharacter(LocalPlayer)
        local targetHrp = GetCharacter(selectedPlayer)
        
        if myHrp and targetHrp then
            -- Телепорт меня к игроку
            myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2)
        end
    end
end)

-- Уведомление о загрузке
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "JJS Script",
    Text = "Delta UI Loaded!",
    Duration = 3
})
