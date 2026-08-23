-- Защищенный запуск, чтобы скрипт не падал при загрузке через loadstring
local success, err = pcall(function()
    print("[Flick UI]: Начинается загрузка интерфейса...")

    -- Сервисы Roblox
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")

    -- Удаление старой копии интерфейса перед перезапуском
    if CoreGui:FindFirstChild("FlickMenuGui") then
        CoreGui.FlickMenuGui:Destroy()
        print("[Flick UI]: Старая копия меню удалена.")
    end

    -- Создание главного контейнера
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FlickMenuGui"
    -- В некоторых версиях Delta CoreGui защищен, делаем альтернативный Parent
    ScreenGui.Parent = CoreGui or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    -- Главное окно меню
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 520, 0, 340)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = ScreenGui

    -- Скругление углов главного окна
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    -- АНИМАЦИЯ ОТКРЫТИЯ (Масштабирование)
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    local openTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local openTween = TweenService:Create(MainFrame, openTweenInfo, {
        Size = UDim2.new(0, 520, 0, 340)
    })
    openTween:Play()

    -- Система перетаскивания (Drag)
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Верхняя панель (Контейнер для разделов)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar

    -- Автоматическое выравнивание разделов по горизонтали
    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.FillDirection = Enum.FillDirection.Horizontal
    TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabsLayout.Padding = UDim.new(0, 8)
    TabsLayout.Parent = TopBar

    -- Общая рабочая область под контент страниц
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 1, -55)
    Container.Position = UDim2.new(0, 0, 0, 55)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local Pages = {}
    local Buttons = {}

    -- Функция создания вкладок
    local function createTab(tabName)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName .. "Btn"
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
        pageFrame.Name = tabName .. "Page"
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
        
        -- Логика переключения страниц
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
    end

    -- Инициализация разделов
    createTab("Main")
    createTab("Combat")
    createTab("Visual")
    createTab("Settings")

    -- Авто-активация вкладки "Main" при старте
    Buttons["Main"].BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Buttons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
    Pages["Main"].Visible = true

    print("[Flick UI]: Интерфейс успешно загружен и отображен!")
end)

-- Если при выполнении кода внутри loadstring произошла ошибка, она выведется в консоль игры
if not success then
    warn("[Flick UI Error]: Ошибка выполнения скрипта: " .. tostring(err))
end
