local success, err = pcall(function()
    -- Сервисы
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    -- Очистка старого GUI
    if CoreGui:FindFirstChild("PulseHub_Flick") then
        CoreGui.PulseHub_Flick:Destroy()
    end

    -- Настройки Combat
    local Settings = {
        Aimbot = false,
        SilentAim = false,
        FOV = 120,
        ShowFOV = false,
        AimPart = "Head", -- "Head" или "HumanoidRootPart"
        TeamCheck = true
    }

    -- Visual FOV Circle
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(160, 90, 255)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Visible = false

    -- Создание главного ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PulseHub_Flick"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false

    -- =============================================================
    -- 1. ЗАГРУЗЧИК ИНТЕРФЕЙСА (LOADER)
    -- =============================================================
    local LoaderFrame = Instance.new("Frame")
    local LoaderCorner = Instance.new("UICorner")
    local LoaderStroke = Instance.new("UIStroke")
    local LoaderTitle = Instance.new("TextLabel")
    local LoaderStatus = Instance.new("TextLabel")
    local BarBackground = Instance.new("Frame")
    local BarCorner = Instance.new("UICorner")
    local BarFill = Instance.new("Frame")
    local FillCorner = Instance.new("UICorner")
    local FillGradient = Instance.new("UIGradient")

    LoaderFrame.Name = "LoaderFrame"
    LoaderFrame.Parent = ScreenGui
    LoaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LoaderFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoaderFrame.Size = UDim2.new(0, 320, 0, 150)
    LoaderFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    LoaderFrame.ClipsDescendants = true

    LoaderCorner.CornerRadius = UDim.new(0, 12)
    LoaderCorner.Parent = LoaderFrame

    LoaderStroke.Thickness = 1.5
    LoaderStroke.Color = Color3.fromRGB(110, 50, 210)
    LoaderStroke.Parent = LoaderFrame

    LoaderTitle.Parent = LoaderFrame
    LoaderTitle.Position = UDim2.new(0, 0, 0, 20)
    LoaderTitle.Size = UDim2.new(1, 0, 0, 25)
    LoaderTitle.Text = "PULSE HUB"
    LoaderTitle.Font = Enum.Font.GothamBold
    LoaderTitle.TextSize = 20
    LoaderTitle.TextColor3 = Color3.fromRGB(160, 90, 255)

    LoaderStatus.Parent = LoaderFrame
    LoaderStatus.Position = UDim2.new(0, 0, 0, 50)
    LoaderStatus.Size = UDim2.new(1, 0, 0, 20)
    LoaderStatus.Text = "Initializing..."
    LoaderStatus.Font = Enum.Font.Gotham
    LoaderStatus.TextSize = 12
    LoaderStatus.TextColor3 = Color3.fromRGB(150, 150, 170)

    BarBackground.Parent = LoaderFrame
    BarBackground.Position = UDim2.new(0.1, 0, 0.65, 0)
    BarBackground.Size = UDim2.new(0.8, 0, 0, 10)
    BarBackground.BackgroundColor3 = Color3.fromRGB(28, 28, 36)

    BarCorner.CornerRadius = UDim.new(0, 5)
    BarCorner.Parent = BarBackground

    BarFill.Parent = BarBackground
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    FillCorner.CornerRadius = UDim.new(0, 5)
    FillCorner.Parent = BarFill

    FillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 60, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 120, 255))
    }
    FillGradient.Parent = BarFill

    -- =============================================================
    -- 2. КНОПКА ОТКРЫТИЯ/ЗАКРЫТИЯ (NLF)
    -- =============================================================
    local NLFButton = Instance.new("TextButton")
    local NLFCorner = Instance.new("UICorner")
    local NLFGradient = Instance.new("UIGradient")
    local NLFStroke = Instance.new("UIStroke")

    NLFButton.Name = "NLFButton"
    NLFButton.Parent = ScreenGui
    NLFButton.Position = UDim2.new(0.02, 0, 0.2, 0)
    NLFButton.Size = UDim2.new(0, 65, 0, 65)
    NLFButton.Text = "NLF"
    NLFButton.Font = Enum.Font.GothamBold
    NLFButton.TextSize = 22
    NLFButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    NLFButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    NLFButton.Active = true
    NLFButton.Draggable = true
    NLFButton.Visible = false

    NLFCorner.CornerRadius = UDim.new(0, 16)
    NLFCorner.Parent = NLFButton

    NLFGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 60, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 120, 255))
    }
    NLFGradient.Parent = NLFButton

    NLFStroke.Thickness = 2
    NLFStroke.Color = Color3.fromRGB(255, 255, 255)
    NLFStroke.Transparency = 0.6
    NLFStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    NLFStroke.Parent = NLFButton

    -- =============================================================
    -- 3. ГЛАВНОЕ ОКНО ПАНЕЛИ
    -- =============================================================
    local MainFrame = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local MainStroke = Instance.new("UIStroke")

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false

    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    MainStroke.Thickness = 1.5
    MainStroke.Color = Color3.fromRGB(80, 50, 150)
    MainStroke.Parent = MainFrame

    local Header = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local SubTitle = Instance.new("TextLabel")

    Header.Parent = MainFrame
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    Header.BorderSizePixel = 0

    Title.Parent = Header
    Title.Position = UDim2.new(0, 15, 0, 5)
    Title.Size = UDim2.new(0, 200, 0, 20)
    Title.Text = "PULSE HUB"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.fromRGB(160, 90, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left

    SubTitle.Parent = Header
    SubTitle.Position = UDim2.new(0, 15, 0, 25)
    SubTitle.Size = UDim2.new(0, 200, 0, 15)
    SubTitle.Text = "Flick Game Version"
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 11
    SubTitle.TextColor3 = Color3.fromRGB(120, 120, 140)
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- =============================================================
    -- 4. БОКОВАЯ ПАНЕЛЬ И ВКЛАДКИ
    -- =============================================================
    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.Size = UDim2.new(0, 130, 1, -45)
    Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Sidebar.BorderSizePixel = 0

    local Container = Instance.new("Frame")
    Container.Parent = MainFrame
    Container.Position = UDim2.new(0, 135, 0, 50)
    Container.Size = UDim2.new(1, -140, 1, -55)
    Container.BackgroundTransparency = 1

    local Tabs = {"Main", "Combat", "Visuals", "World", "Sitting", "Config"}
    local TabButtons = {}
    local TabPages = {}

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Sidebar
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)

    for i, tabName in ipairs(Tabs) do
        local TabBtn = Instance.new("TextButton")
        local BtnCorner = Instance.new("UICorner")
        
        TabBtn.Name = tabName .. "Tab"
        TabBtn.Parent = Sidebar
        TabBtn.Size = UDim2.new(0.9, 0, 0, 32)
        TabBtn.Text = "  " .. tabName
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 130, 150)
        TabBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(110, 50, 210) or Color3.fromRGB(28, 28, 36)
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = TabBtn
        
        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "Page"
        Page.Parent = Container
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = (i == 1)
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Color3.fromRGB(110, 50, 210)
        
        local PageList = Instance.new("UIListLayout")
        PageList.Parent = Page
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 8)

        TabButtons[tabName] = TabBtn
        TabPages[tabName] = Page
        
        TabBtn.MouseButton1Click:Connect(function()
            for name, btn in pairs(TabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(28, 28, 36),
                    TextColor3 = Color3.fromRGB(130, 130, 150)
                }):Play()
            end
            for name, page in pairs(TabPages) do
                page.Visible = false
            end
            
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(110, 50, 210),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            Page.Visible = true
        end)
    end

    -- Хелперы UI Элементов для быстрого создания интерфейсов
    local UIHelper = {}
    
    function UIHelper.AddToggle(parent, text, default, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0.95, 0, 0, 35)
        Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        Frame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Frame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 13
        Label.TextColor3 = Color3.fromRGB(220, 220, 230)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.Parent = Frame

        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 40, 0, 20)
        Btn.Position = UDim2.new(1, -50, 0.5, -10)
        Btn.Text = ""
        Btn.BackgroundColor3 = default and Color3.fromRGB(110, 50, 210) or Color3.fromRGB(40, 40, 50)
        Btn.Parent = Frame

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(1, 0)
        BtnCorner.Parent = Btn

        local state = default
        Btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(Btn, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Color3.fromRGB(110, 50, 210) or Color3.fromRGB(40, 40, 50)
            }):Play()
            callback(state)
        end)
    end

    function UIHelper.AddSlider(parent, text, min, max, default, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0.95, 0, 0, 45)
        Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        Frame.Parent = parent

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Frame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 20)
        Label.Position = UDim2.new(0, 10, 0, 5)
        Label.Text = text .. ": " .. tostring(default)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 12
        Label.TextColor3 = Color3.fromRGB(220, 220, 230)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.Parent = Frame

        local SliderBar = Instance.new("TextButton")
        SliderBar.Size = UDim2.new(0.9, 0, 0, 6)
        SliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
        SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        SliderBar.Text = ""
        SliderBar.Parent = Frame

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(110, 50, 210)
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBar

        local dragging = false
        local function update(input)
            local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            Label.Text = text .. ": " .. tostring(val)
            callback(val)
        end

        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
    end

    -- =============================================================
    -- 5. НАПОЛНЕНИЕ ВКЛАДКИ COMBAT (Aimbot & Silent Aim)
    -- =============================================================
    local CombatPage = TabPages["Combat"]

    UIHelper.AddToggle(CombatPage, "Enable Aimbot (Camera)", Settings.Aimbot, function(val)
        Settings.Aimbot = val
    end)

    UIHelper.AddToggle(CombatPage, "Enable Silent Aim", Settings.SilentAim, function(val)
        Settings.SilentAim = val
    end)

    UIHelper.AddToggle(CombatPage, "Show FOV Circle", Settings.ShowFOV, function(val)
        Settings.ShowFOV = val
        FOVCircle.Visible = val
    end)

    UIHelper.AddSlider(CombatPage, "FOV Radius", 30, 300, Settings.FOV, function(val)
        Settings.FOV = val
        FOVCircle.Radius = val
    end)

    UIHelper.AddToggle(CombatPage, "Target Head Only", true, function(val)
        Settings.AimPart = val and "Head" or "HumanoidRootPart"
    end)

    -- =============================================================
    -- 6. ЛОГИКА АИМБОТА И SILENT AIM
    -- =============================================================
    local function GetClosestTarget()
        local closest = nil
        local maxDist = Settings.FOV
        local mousePos = UserInputService:GetMouseLocation()

        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                if Settings.TeamCheck and plr.Team == LocalPlayer.Team then
                    continue
                end

                local targetPart = plr.Character:FindFirstChild(Settings.AimPart)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < maxDist then
                            maxDist = dist
                            closest = targetPart
                        end
                    end
                end
            end
        end
        return closest
    end

    -- Цикл Aimbot & FOV Circle
    RunService.RenderStepped:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.ShowFOV

        if Settings.Aimbot then
            local target = GetClosestTarget()
            if target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end
    end)

    -- Silent Aim Hook через __namecall (перехват выстрелов)
    local rawMeta = getrawmetatable(game)
    local oldNamecall = rawMeta.__namecall
    setreadonly(rawMeta, false)

    rawMeta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if Settings.SilentAim and (method == "FindPartOnRayWithIgnoreList" or method == "Raycast" or method == "FireServer") then
            local target = GetClosestTarget()
            if target then
                -- Меняем траекторию/позицию клика под ближайшую цель
                if method == "Raycast" and args[2] then
                    args[2] = (target.Position - args[1]).Unit * 1000
                end
            end
        end

        return oldNamecall(self, unpack(args))
    end)
    setreadonly(rawMeta, true)

    -- NLF Button Toggle
    local isOpen = true
    NLFButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 550, 0, 350)
            }):Play()
        else
            local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 550, 0, 0)
            })
            tween:Play()
            tween.Completed:Connect(function()
                if not isOpen then MainFrame.Visible = false end
            end)
        end
    end)

    -- =============================================================
    -- 7. ЗАПУСК ЗАГРУЗЧИКА
    -- =============================================================
    task.spawn(function()
        LoaderStatus.Text = "Checking Game Compatibility..."
        TweenService:Create(BarFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
        task.wait(0.7)

        LoaderStatus.Text = "Loading Combat Modules..."
        TweenService:Create(BarFill, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Size = UDim2.new(0.7, 0, 1, 0)}):Play()
        task.wait(0.9)

        LoaderStatus.Text = "Starting Pulse Hub..."
        TweenService:Create(BarFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(0.6)

        local fadeTween = TweenService:Create(LoaderFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
        fadeTween:Play()
        
        fadeTween.Completed:Connect(function()
            LoaderFrame:Destroy()
            NLFButton.Visible = true
            MainFrame.Visible = true
        end)
    end)
end)

if not success then
    warn("Pulse Hub Error: " .. tostring(err))
end
