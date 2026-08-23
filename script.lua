local success, err = pcall(function()
    print("[Flick UI]: Полный запуск интерфейса и визуалов...")

    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Удаление старой копии меню перед перезапуском
    if CoreGui:FindFirstChild("FlickMenuGui") then
        CoreGui.FlickMenuGui:Destroy()
    end

    -- Главный контейнер интерфейса
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FlickMenuGui"
    ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    -- Глобальные переменные для мгновенного включения функций
    _G.ESP_Boxes_Enabled = false
    _G.Chams_Enabled = false

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

    -- Анимация плавного появления меню при запуске
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

    -- Функция перетаскивания (Drag) для меню и плавающей кнопки
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

    -- Анимация физического отклика кнопки NLF при касании/клике
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

    -- Сворачивание и разворачивание меню при клике на NLF
    ToggleButton.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        local targetSize = menuOpen and UDim2.new(0, 520, 0, 340) or UDim2.new(0, 0, 0, 0)
        local targetStyle = menuOpen and Enum.EasingStyle.Back or Enum.EasingStyle.Quad
        
        TweenService:Create(MainFrame, TweenInfo.new(0.4, targetStyle, Enum.EasingDirection.Out), {
            Size = targetSize
        }):Play()
    end)

    -- Верхняя панель (Таб-бар)
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

    -- Главный контейнер для страниц контента
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, -55)
    Container.Position = UDim2.new(0, 0, 0, 55)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local Pages = {}
    local Buttons = {}

    -- Функция автоматического создания разделов меню
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

    -- Инициализация запрашиваемых разделов
    local pMain = createTab("Main")
    local pCombat = createTab("Combat")
    local pVisual = createTab("Visual")
    local pSettings = createTab("Settings")

    -- Выбор вкладки Main по умолчанию при запуске
    Buttons["Main"].BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Buttons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
    Pages["Main"].Visible = true

    -- Функция добавления красивых переключателей (Toggle)
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

-- ПОСТОЯННЫЙ ЦИКЛ ОБНОВЛЕНИЯ ВИЗУАЛОВ (ESP И CHAMS) сквозь стены
RunService.RenderStepped:Connect(function()
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character then
local char = player.Character
local root = char:FindFirstChild("HumanoidRootPart")

if root then
-- Создание изолированной папки внутри игрока для эффектов читов
local visualFolder = root:FindFirstChild("NLF_Visuals")
if not visualFolder then
visualFolder = Instance.new("Folder")
visualFolder.Name = "NLF_Visuals"
visualFolder.Parent = root
end

-- 1. РАБОТА С ESP BOX
local box = visualFolder:FindFirstChild("ESPBox")
if _G.ESP_Boxes_Enabled then
if not box then
box = Instance.new("BillboardGui")
box.Name = "ESPBox"
box.AlwaysOnTop = true
box.Size = UDim2.new(4.5, 0, 6, 0)
box.ClipsDescendants = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1
frame.Parent = box

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 0, 50)
stroke.Thickness = 2
stroke.Parent = frame

box.Parent = visualFolder
end
else
if box then box:Destroy() end
end

-- 2. РАБОТА С CHAMS (Силуэты сквозь стены)
local highlight = visualFolder:FindFirstChild("ChamsEffect")
if _G.Chams_Enabled then
if not highlight then
highlight = Instance.new("Highlight")
highlight.Name = "ChamsEffect"
highlight.FillColor = Color3.fromRGB(0, 255, 150)
highlight.FillTransparency = 0.4
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.OutlineTransparency = 0
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Adornee = char
highlight.Parent = visualFolder
end
else
if highlight then highlight:Destroy() end
end
end
end
end
end)

-- Добавление кнопок управления функциями во вкладку Visual
addToggle(pVisual, "Enable ESP Boxes", function(state)
_G.ESP_Boxes_Enabled = state
end)

addToggle(pVisual, "Enable Chams", function(state)
_G.Chams_Enabled = state
end)

print("[Flick UI]: Скрипт полностью готов к использованию в игре.")
end)

if not success then
warn("[Flick UI Error]: Критическая ошибка выполнения: " .. tostring(err))
end
