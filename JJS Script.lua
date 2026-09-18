-- // JJS MENU - DELTA // --
-- // Запрос #8: Client Invisibility (как в Bolong) // --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(15, 15, 15),
    Red = Color3.fromRGB(200, 40, 40),
    Text = Color3.fromRGB(230, 230, 230),
    TextDim = Color3.fromRGB(140, 140, 140),
    ElementBg = Color3.fromRGB(35, 35, 35),
    ToggleOff = Color3.fromRGB(60, 60, 60),
    Border = Color3.fromRGB(45, 45, 45)
}

local function Tween(obj, time, props)
    TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJS_Mercedes"
ScreenGui.Parent = game.CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local OpenButton = Instance.new("TextButton")
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0.1, 0, 0.3, 0)
OpenButton.BackgroundColor3 = Theme.Background
OpenButton.TextColor3 = Theme.Red
OpenButton.Text = "JJS"
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 16
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", OpenButton)
stroke.Color = Theme.Red
stroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 480, 0, 380)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Visible = false
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Theme.Border
mainStroke.Thickness = 1

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

local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "JJS | Delta"
TitleText.TextColor3 = Theme.Red
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

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

local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 130, 1, -55)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundColor3 = Theme.Sidebar
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SideScroll = Instance.new("ScrollingFrame")
SideScroll.Parent = Sidebar
SideScroll.Size = UDim2.new(1, 0, 1, 0)
SideScroll.BackgroundTransparency = 1
SideScroll.ScrollBarThickness = 2
SideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local SideLayout = Instance.new("UIListLayout", SideScroll)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -150, 1, -55)
ContentArea.Position = UDim2.new(0, 145, 0, 45)
ContentArea.BackgroundTransparency = 1

local Tabs = {}
local ActiveTab = nil

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Parent = SideScroll
    btn.Size = UDim2.new(1, -4, 0, 35)
    btn.BackgroundColor3 = Theme.Background
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local indicator = Instance.new("Frame")
    indicator.Parent = btn
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.BackgroundColor3 = Theme.Red
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    
    local content = Instance.new("ScrollingFrame")
    content.Parent = ContentArea
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.ScrollBarThickness = 2
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local padding = Instance.new("UIPadding", content)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    
    local layout = Instance.new("UIListLayout", content)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    
    table.insert(Tabs, {Button = btn, Content = content, Indicator = indicator})
    
    btn.MouseButton1Click:Connect(function()
        for _, tab in ipairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.TextColor3 = Theme.TextDim
            tab.Button.BackgroundColor3 = Theme.Background
            Tween(tab.Indicator, 0.2, {Size = UDim2.new(0, 3, 0, 0)})
        end
        content.Visible = true
        btn.TextColor3 = Theme.Text
        btn.BackgroundColor3 = Theme.ElementBg
        Tween(indicator, 0.2, {Size = UDim2.new(0, 3, 0, 20)})
        ActiveTab = name
    end)
    
    return content
end

local MainTab = CreateTab("Main", "🏠")
local TeleportTab = CreateTab("Teleport", "✈️")
local VisualsTab = CreateTab("Visuals", "👁")

Tabs[1].Button.TextColor3 = Theme.Text
Tabs[1].Button.BackgroundColor3 = Theme.ElementBg
Tabs[1].Content.Visible = true
Tween(Tabs[1].Indicator, 0.2, {Size = UDim2.new(0, 3, 0, 20)})
ActiveTab = "Main"

-- // UI Компоненты //
local function CreateToggle(parent, text, defaultState, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Parent = frame
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBg.BackgroundColor3 = defaultState and Theme.Red or Theme.ToggleOff
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Parent = toggleBg
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Theme.Text
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local state = defaultState
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        Tween(toggleBg, 0.2, {BackgroundColor3 = state and Theme.Red or Theme.ToggleOff})
        Tween(knob, 0.2, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
        callback(state)
    end)
    
    return frame
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.5, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.Size = UDim2.new(0.5, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.TextDim
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = frame
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = Theme.ToggleOff
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderBg
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Red
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Parent = sliderBg
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Theme.Text
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function update(input)
        local mouseX = input.Position.X
        local pos = sliderBg.AbsolutePosition.X
        local size = sliderBg.AbsoluteSize.X
        local pct = math.clamp((mouseX - pos) / size, 0, 1)
        local val = math.floor(min + (max - min) * pct)
        valueLabel.Text = tostring(val)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -7, 0.5, -7)
        callback(val)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
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
        end
    end)
    
    return frame
end


-- // MAIN: FLY //
local FlyEnabled = false
local FlySpeed = 60
local bodyVelocity

CreateToggle(MainTab, "Fly", false, function(state)
    FlyEnabled = state
    if not state and bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end)

CreateSlider(MainTab, "Fly Speed", 10, 300, 60, function(val)
    FlySpeed = val
end)

RunService.RenderStepped:Connect(function()
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Parent = hrp
        end
        local moveDir = humanoid.MoveDirection
        local camCFrame = Camera.CFrame
        local direction = Vector3.new(0,0,0)
        if moveDir.Magnitude > 0.1 then
            direction = (camCFrame.LookVector * moveDir.Z + camCFrame.RightVector * moveDir.X).Unit
        end
        local vertical = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = Vector3.new(0, -1, 0) end
        bodyVelocity.Velocity = (direction * FlySpeed) + (vertical * FlySpeed)
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    end
end)


-- // MAIN: AUTO ATTACK + AUTO JUMP COMBO //
local AutoAttackEnabled = false
local AutoJumpComboEnabled = false
local attackCount = 0

local function FindAttackButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local names = {"Attack", "Combat", "Punch", "M1", "Strike", "Hit", "ActionButton"}
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            for _, name in ipairs(names) do
                if gui.Name:lower():find(name:lower()) then return gui end
            end
        end
    end
    local mobileGui = playerGui:FindFirstChild("MobileGui") or playerGui:FindFirstChild("TouchGui")
    if mobileGui then
        for _, gui in ipairs(mobileGui:GetDescendants()) do
            if gui:IsA("ImageButton") or gui:IsA("TextButton") then return gui end
        end
    end
    return nil
end

local function ClickButton(button)
    if not button then return end
    pcall(function()
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            button.MouseButton1Click:Fire()
            button.MouseButton1Down:Fire()
            task.wait(0.05)
            button.MouseButton1Up:Fire()
        end
    end)
end

task.spawn(function()
    while task.wait(0.15) do
        if not AutoAttackEnabled then continue end
        if not LocalPlayer.Character then continue end
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        local attackBtn = FindAttackButton()
        if not attackBtn then continue end
        if AutoJumpComboEnabled then
            attackCount = attackCount + 1
            if attackCount >= 4 then
                humanoid.Jump = true
                task.wait(0.15)
                ClickButton(attackBtn)
                attackCount = 0
            else
                ClickButton(attackBtn)
            end
        else
            ClickButton(attackBtn)
        end
    end
end)

CreateToggle(MainTab, "Auto Attack", false, function(state)
    AutoAttackEnabled = state
    if not state then attackCount = 0 end
end)

CreateToggle(MainTab, "Auto Jump Combo (4th hit)", false, function(state)
    AutoJumpComboEnabled = state
    attackCount = 0
    if state and not AutoAttackEnabled then AutoAttackEnabled = true end
end)


-- // VISUALS: CLIENT INVISIBILITY (как в Bolong) //
local InvisEnabled = false

-- Функция, которая прячет все части персонажа
local function ApplyInvisibility(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Уровень 1: локальная прозрачность
            part.LocalTransparencyModifier = 1
            -- Уровень 2: общая прозрачность (если сервер не проверяет)
            part.Transparency = 1
            part.CastShadow = false
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
            -- Скрываем UI над головой (ники, HP)
            part.Enabled = false
        end
    end
end

-- Функция, которая возвращает всё обратно
local function RemoveInvisibility(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 0
            part.Transparency = 0
            part.CastShadow = true
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 0
        elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
            part.Enabled = true
        end
    end
end

-- Цикл, который держит невидимость (каждый кадр), чтобы анти-чит не вернул прозрачность
task.spawn(function()
    while task.wait() do
        if InvisEnabled and LocalPlayer.Character then
            ApplyInvisibility(LocalPlayer.Character)
        end
    end
end)

CreateToggle(VisualsTab, "Invisibility", false, function(state)
    InvisEnabled = state
    if state then
        if LocalPlayer.Character then ApplyInvisibility(LocalPlayer.Character) end
    else
        if LocalPlayer.Character then RemoveInvisibility(LocalPlayer.Character) end
    end
end)

-- Автоприменение инвиза при респавне, если он был включён
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(1)
    if InvisEnabled then
        ApplyInvisibility(char)
    end
end)


-- // TELEPORT //
local selectedPlayer = nil
local SkillTpEnabled = false

local PlayerListLabel = Instance.new("TextLabel")
PlayerListLabel.Parent = TeleportTab
PlayerListLabel.Size = UDim2.new(1, 0, 0, 20)
PlayerListLabel.BackgroundTransparency = 1
PlayerListLabel.Text = "Select Player:"
PlayerListLabel.TextColor3 = Theme.Text
PlayerListLabel.Font = Enum.Font.GothamBold
PlayerListLabel.TextSize = 13
PlayerListLabel.TextXAlignment = Enum.TextXAlignment.Left

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Parent = TeleportTab
PlayerList.Size = UDim2.new(1, 0, 0, 80)
PlayerList.BackgroundColor3 = Theme.ElementBg
PlayerList.ScrollBarThickness = 2
Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 6)
local ListLayout = Instance.new("UIListLayout", PlayerList)
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.Name

local TpToPlayerBtn = Instance.new("TextButton")
TpToPlayerBtn.Parent = TeleportTab
TpToPlayerBtn.Size = UDim2.new(1, 0, 0, 35)
TpToPlayerBtn.BackgroundColor3 = Theme.Red
TpToPlayerBtn.TextColor3 = Theme.Text
TpToPlayerBtn.Text = "Teleport Me to Player"
TpToPlayerBtn.Font = Enum.Font.GothamBold
TpToPlayerBtn.TextSize = 13
Instance.new("UICorner", TpToPlayerBtn).CornerRadius = UDim.new(0, 6)

local TpToMeBtn = Instance.new("TextButton")
TpToMeBtn.Parent = TeleportTab
TpToMeBtn.Size = UDim2.new(1, 0, 0, 35)
TpToMeBtn.BackgroundColor3 = Theme.ElementBg
TpToMeBtn.TextColor3 = Theme.Text
TpToMeBtn.Text = "Teleport Player to Me"
TpToMeBtn.Font = Enum.Font.GothamBold
TpToMeBtn.TextSize = 13
Instance.new("UICorner", TpToMeBtn).CornerRadius = UDim.new(0, 6)

CreateToggle(TeleportTab, "Skill Teleport", false, function(state)
    SkillTpEnabled = state
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
                btn.BackgroundColor3 = Theme.Red
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

local function SafeTeleport(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    char:PivotTo(targetCFrame)
    local startTime = tick()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if tick() - startTime > 0.3 then
            connection:Disconnect()
            return
        end
        if char and char.Parent and char:FindFirstChild("HumanoidRootPart") then
            char:PivotTo(targetCFrame)
        end
    end)
end

TpToPlayerBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        local targetHrp = GetCharacter(selectedPlayer)
        if targetHrp then SafeTeleport(targetHrp.CFrame * CFrame.new(0, 0, 3)) end
    end
end)

TpToMeBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        local myHrp = GetCharacter(LocalPlayer)
        local targetChar = selectedPlayer.Character
        if myHrp and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            for i = 1, 15 do
                targetChar:PivotTo(myHrp.CFrame * CFrame.new(0, 0, 3))
                task.wait()
            end
        end
    end
end)

local function OnAnimationPlayed(animTrack)
    if not SkillTpEnabled or not selectedPlayer then return end
    local animName = animTrack.Animation.Name
    local coreAnims = {"Idle", "Walk", "Run", "Jump", "Fall", "Climb", "Swim"}
    for _, core in ipairs(coreAnims) do
        if animName == core then return end
    end
    local myChar = LocalPlayer.Character
    local targetHrp = GetCharacter(selectedPlayer)
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") or not targetHrp then return end
    local originalCFrame = myChar:GetPivot()
    myChar:PivotTo(targetHrp.CFrame * CFrame.new(0, 0, 3))
    animTrack.Stopped:Wait()
    myChar:PivotTo(originalCFrame)
end

local function SetupCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    animator.AnimationPlayed:Connect(OnAnimationPlayed)
end

LocalPlayer.CharacterAdded:Connect(SetupCharacter)
if LocalPlayer.Character then SetupCharacter(LocalPlayer.Character) end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "JJS Script",
    Text = "Запрос #8: Client Invisibility добавлен!",
    Duration = 3
})
