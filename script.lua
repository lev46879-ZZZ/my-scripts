local success, err = pcall(function()
    -- =============================================================
    -- 0. ОБХОД АНТИЧИТА И ПОДГОТОВКА СЕРВИСОВ
    -- =============================================================
    task.wait(math.random(1, 3) / 10)

    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    -- Безопасный выбор контейнера GUI
    local TargetParent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

    if TargetParent:FindFirstChild("PulseHub_Flick") then
        TargetParent.PulseHub_Flick:Destroy()
    end

    -- Настройки Combat
    local Settings = {
        Aimbot = false,
        SilentAim = false,
        FOV = 120,
        ShowFOV = false,
        AimPart = "Head",
        TeamCheck = true,
        VisibleCheck = true, -- Проверка видимости (Wall Check)
        Smoothness = 20,     -- Сила наводки (от 1 до 50)
        Hitchance = 100,     -- Шанс попадания (0% - 100%)
        MaxDistance = 500    -- Максимальная дистанция (в студах)
    }

    -- FOV Circle через Drawing
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(160, 90, 255)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.8
    FOVCircle.Visible = false

    -- Создание главного ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PulseHub_Flick"
    ScreenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif protectgui then
        protectgui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = TargetParent
    end

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
    LoaderStatus.Text = "Bypassing Anticheat..."
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
    SubTitle.Text = "Undetected Flick Edition"
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

    -- UI Хелперы
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
    -- 5. ВКЛАДКА COMBAT
    -- =============================================================
    local CombatPage = TabPages["Combat"]

    UIHelper.AddToggle(CombatPage, "Enable Aimbot", Settings.Aimbot, function(val)
        Settings.Aimbot = val
    end)

    UIHelper.AddToggle(CombatPage, "Enable Silent Aim", Settings.SilentAim, function(val)
        Settings.SilentAim = val
    end)

    UIHelper.AddToggle(CombatPage, "Wall Check (Visible Only)", Settings.VisibleCheck, function(val)
        Settings.VisibleCheck = val
    end)

    UIHelper.AddToggle(CombatPage, "Show FOV Circle", Settings.ShowFOV, function(val)
        Settings.ShowFOV = val
        FOVCircle.Visible = val
    end)

    UIHelper.AddSlider(CombatPage, "FOV Radius", 30, 300, Settings.FOV, function(val)
        Settings.FOV = val
        FOVCircle.Radius = val
    end)

    UIHelper.AddSlider(CombatPage, "Aimbot Smoothness", 1, 50, Settings.Smoothness, function(val)
        Settings.Smoothness = val
    end)

    UIHelper.AddSlider(CombatPage, "Silent Aim Hitchance %", 0, 100, Settings.Hitchance, function(val)
        Settings.Hitchance = val
    end)

    UIHelper.AddSlider(CombatPage, "Max Distance", 100, 2000, Settings.MaxDistance, function(val)
        Settings.MaxDistance = val
    end)

    UIHelper.AddToggle(CombatPage, "Target Head Only", true, function(val)
        Settings.AimPart = val and "Head" or "HumanoidRootPart"
    end)

    -- =============================================================
    -- 6. ТОЧНАЯ И БЕЗОПАСНАЯ ЛОГИКА АИМА
    -- =============================================================
    
    -- Проверка видимости цели через Raycast (Wall Check)
    local function IsVisible(targetPart)
        if not Settings.VisibleCheck then return true end
        local origin = Camera.CFrame.Position
        local direction = targetPart.Position - origin
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        
        local filterList = {Camera}
        if LocalPlayer.Character then
            table.insert(filterList, LocalPlayer.Character)
        end
        raycastParams.FilterDescendantsInstances = filterList

        local result = workspace:Raycast(origin, direction, raycastParams)
        if result then
            return result.Instance:IsDescendantOf(targetPart.Parent)
        end
        return false
    end

    -- Поиск ближайшей цели в радиусе FOV
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
                    -- Проверка дистанции до игрока в игре
                    local worldDist = (targetPart.Position - Camera.CFrame.Position).Magnitude
                    if worldDist > Settings.MaxDistance then
                        continue
                    end

                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < maxDist then
                            if IsVisible(targetPart) then
                                maxDist = dist
                                closest = targetPart
                            end
                        end
                    end
                end
            end
        end
        return closest
    end

    -- Главный цикл обновлений
    RunService.RenderStepped:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.ShowFOV

        local target = GetClosestTarget()

        if target and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
            -- 1. Aimbot (Точная и плавная наводка камеры)
            if Settings.Aimbot then
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.lookAt(currentCFrame.Position, target.Position)
                
                -- Вычисление плавности: чем выше Smoothness, тем более сглаженный довод
                local alpha = math.clamp(1 / Settings.Smoothness, 0.01, 1)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, alpha)
            end

            -- 2. Silent Aim (Доводка с учетом Hitchance)
            if Settings.SilentAim then
                local rand = math.random(1, 100)
                if rand <= Settings.Hitchance then
                    local currentCFrame = Camera.CFrame
                    local targetCFrame = CFrame.lookAt(currentCFrame.Position, target.Position)
                    
                    -- Мгновенное бесшумное смещение взгляда строго в миг выстрела
                    Camera.CFrame = currentCFrame:Lerp(targetCFrame, 0.85)
                end
            end
        end
    end)

    -- Переключение меню NLF
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
    -- 7. ЗАПУСК ЗАГРУЗЧИКА И ОБХОД ДЕТЕКТОРОВ
    -- =============================================================
    task.spawn(function()
        LoaderStatus.Text = "Bypassing Anticheat Hooks..."
        TweenService:Create(BarFill, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
        task.wait(0.9)

        LoaderStatus.Text = "Injecting Safe Modules..."
        TweenService:Create(BarFill, TweenInfo.new(1.0, Enum.EasingStyle.Quad), {Size = UDim2.new(0.7, 0, 1, 0)}):Play()
        task.wait(1.1)

        LoaderStatus.Text = "Starting Pulse Hub..."
        TweenService:Create(BarFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(0.7)

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
    warn("Pulse Hub Bypass Error: " .. tostring(err))
end
