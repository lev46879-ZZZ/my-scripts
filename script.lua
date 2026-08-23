local success, err = pcall(function()
    -- Сервисы
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")

    -- Очистка старого GUI
    if CoreGui:FindFirstChild("PulseHub_Flick") then
        CoreGui.PulseHub_Flick:Destroy()
    end

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
    NLFButton.Visible = false -- Скрыта до окончания загрузки

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
    -- 3. ГЛАВНОЕ ОКНО ПАНЕЛИ (Pulse Hub Style)
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
    MainFrame.Visible = false -- Скрыто до окончания загрузки

    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    MainStroke.Thickness = 1.5
    MainStroke.Color = Color3.fromRGB(80, 50, 150)
    MainStroke.Parent = MainFrame

    -- Шапка (Header)
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
        
        local PageLabel = Instance.new("TextLabel")
        PageLabel.Parent = Page
        PageLabel.Size = UDim2.new(1, 0, 0, 30)
        PageLabel.Text = tabName .. " Settings"
        PageLabel.Font = Enum.Font.GothamBold
        PageLabel.TextSize = 16
        PageLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        PageLabel.BackgroundTransparency = 1
        
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

    -- Логика кнопки NLF
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
    -- 5. АНИМАЦИЯ И ЛОГИКА ЗАГРУЗКИ
    -- =============================================================
    task.spawn(function()
        LoaderStatus.Text = "Checking Game Compatibility..."
        TweenService:Create(BarFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
        task.wait(0.7)

        LoaderStatus.Text = "Loading Modules..."
        TweenService:Create(BarFill, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {Size = UDim2.new(0.7, 0, 1, 0)}):Play()
        task.wait(0.9)

        LoaderStatus.Text = "Starting Pulse Hub..."
        TweenService:Create(BarFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(0.6)

        -- Исчезновение загрузчика и появление интерфейса
        local fadeTween = TweenService:Create(LoaderFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
        fadeTween:Play()
        
        fadeTween.Completed:Connect(function()
            LoaderFrame:Destroy()
            NLFButton.Visible = true
            MainFrame.Visible = true
        end)
    end)
end)

-- Проверка выполнения pcall
if not success then
    warn("Pulse Hub Error: " .. tostring(err))
end
