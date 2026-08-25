
--// ApexVHub - Полная реализация с функционалом
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- НАСТРОЙКИ ФУНКЦИОНАЛА (CONFIG)
--==================================================
local Settings = {
    Combat = {
        Aimbot = false,
        FlickBot = false,
        Fov = 150,
        WallCheck = false,
    },
    Visuals = {
        ESP = false,
        Charms = false,
    }
}

local MENU_WIDTH = 760
local MENU_HEIGHT = 470

local DARK = Color3.fromRGB(14, 14, 15)
local DARKER = Color3.fromRGB(10, 10, 11)
local SIDEBAR = Color3.fromRGB(13, 13, 14)
local BUTTON = Color3.fromRGB(25, 25, 27)
local BUTTON_HOVER = Color3.fromRGB(31, 31, 34)
local TEXT = Color3.fromRGB(225, 225, 228)
local SUBTEXT = Color3.fromRGB(115, 115, 120)

local FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local MENU_TWEEN = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

--==================================================
-- SCREEN GUI
--==================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "ApexVHub"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = playerGui

-- FOV Окружность для визуализации радиуса Аимбота
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Color = Color3.fromRGB(255, 0, 0)
FovCircle.Thickness = 1
FovCircle.NumSides = 64
FovCircle.Radius = Settings.Combat.Fov
FovCircle.Filled = false

--==================================================
-- FLOATING GUI BUTTON
--==================================================
local HubButton = Instance.new("TextButton")
HubButton.Name = "ApexVHubButton"
HubButton.Size = UDim2.fromOffset(62, 62)
HubButton.Position = UDim2.new(0.5, -31, 0.5, -125)
HubButton.BackgroundColor3 = DARK
HubButton.BorderSizePixel = 0
HubButton.Text = "ApexVHub"
HubButton.TextColor3 = TEXT
HubButton.TextSize = 10
HubButton.Font = Enum.Font.GothamMedium
HubButton.AutoButtonColor = false
HubButton.ZIndex = 100
HubButton.Parent = Gui

local HubCorner = Instance.new("UICorner")
HubCorner.CornerRadius = UDim.new(0, 14)
HubCorner.Parent = HubButton

local HubStroke = Instance.new("UIStroke")
HubStroke.Color = Color3.fromRGB(70, 70, 75)
HubStroke.Thickness = 1
HubStroke.Transparency = 0.25
HubStroke.Parent = HubButton

local HubScale = Instance.new("UIScale")
HubScale.Scale = 0.75
HubScale.Parent = HubButton

TweenService:Create(HubScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

HubButton.MouseEnter:Connect(function()
    TweenService:Create(HubScale, FAST, {Scale = 1.08}):Play()
    TweenService:Create(HubStroke, FAST, {Transparency = 0, Thickness = 1.5}):Play()
end)

HubButton.MouseLeave:Connect(function()
    TweenService:Create(HubScale, FAST, {Scale = 1}):Play()
    TweenService:Create(HubStroke, FAST, {Transparency = 0.25, Thickness = 1}):Play()
end)

--==================================================
-- MAIN MENU
--==================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(MENU_WIDTH, MENU_HEIGHT)
Main.Position = UDim2.new(0.5, -MENU_WIDTH / 2, 0.5, -MENU_HEIGHT / 2)
Main.BackgroundColor3 = DARK
Main.BorderSizePixel = 0
Main.Visible = false
Main.ZIndex = 10
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 13)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(47, 47, 50)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.35
MainStroke.Parent = Main

local MainScale = Instance.new("UIScale")
MainScale.Scale = 0.94
MainScale.Parent = Main

--==================================================
-- HEADER
--==================================================
local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(34, 34)
Logo.Position = UDim2.fromOffset(18, 17)
Logo.BackgroundColor3 = Color3.fromRGB(24, 31, 43)
Logo.BorderSizePixel = 0
Logo.Parent = Main

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 9)
LogoCorner.Parent = Logo

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.fromScale(1, 1)
LogoText.BackgroundTransparency = 1
LogoText.Text = "A"
LogoText.TextColor3 = Color3.fromRGB(135, 150, 255)
LogoText.TextSize = 18
LogoText.Font = Enum.Font.GothamBold
LogoText.Parent = Logo

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(300, 27)
Title.Position = UDim2.fromOffset(62, 14)
Title.BackgroundTransparency = 1
Title.Text = "ApexVHub"
Title.TextColor3 = TEXT
Title.TextSize = 18
Title.Font = Enum.Font.GothamMedium
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.fromOffset(300, 22)
Subtitle.Position = UDim2.fromOffset(63, 37)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Universal Edition"
Subtitle.TextColor3 = SUBTEXT
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Main

--==================================================
-- CLOSE BUTTON
--==================================================
local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(38, 38)
Close.Position = UDim2.new(1, -54, 0, 16)
Close.BackgroundColor3 = BUTTON
Close.BorderSizePixel = 0
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(190, 190, 194)
Close.TextSize = 14
Close.Font = Enum.Font.GothamMedium
Close.AutoButtonColor = false
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 9)
CloseCorner.Parent = Close

Close.MouseEnter:Connect(function()
    TweenService:Create(Close, FAST, {BackgroundColor3 = BUTTON_HOVER, TextColor3 = Color3.fromRGB(245, 245, 245)}):Play()
end)

Close.MouseLeave:Connect(function()
    TweenService:Create(Close, FAST, {BackgroundColor3 = BUTTON, TextColor3 = Color3.fromRGB(190, 190, 194)}):Play()
end)

--==================================================
-- CONTENT BACKGROUND & SIDEBAR
--==================================================
local ContentBackground = Instance.new("Frame")
ContentBackground.Name = "ContentBackground"
ContentBackground.Size = UDim2.new(1, -36, 1, -93)
ContentBackground.Position = UDim2.fromOffset(18, 76)
ContentBackground.BackgroundTransparency = 1
ContentBackground.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.fromOffset(178, 375)
Sidebar.BackgroundColor3 = SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.Parent = ContentBackground

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 9)
SidebarCorner.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 9)
SidebarPadding.PaddingRight = UDim.new(0, 9)
SidebarPadding.Parent = Sidebar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 7)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = Sidebar

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -193, 1, 0)
Container.Position = UDim2.fromOffset(193, 0)
Container.BackgroundColor3 = DARKER
Container.BorderSizePixel = 0
Container.Parent = ContentBackground

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 9)
ContainerCorner.Parent = Container

-- Системные контейнеры страниц
local Pages = {}
local Tabs = {}

local function createPage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.fromOffset(10, 10)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.Visible = false
    Page.Parent = Container

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 8)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = Page

    Pages[name] = Page
    return Page
end

-- Вспомогательные элементы GUI конструктора
local function createCheckbox(page, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = BUTTON
    Button.BorderSizePixel = 0
    Button.Text = "  " .. text
    Button.TextColor3 = TEXT
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.AutoButtonColor = false
    Button.Parent = page

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.fromOffset(16, 16)
    Indicator.Position = UDim2.new(1, -26, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(40, 40, 43)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Button

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(0, 4)
    IndCorner.Parent = Indicator

    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Indicator, FAST, {BackgroundColor3 = state and Color3.fromRGB(135, 150, 255) or Color3.fromRGB(40, 40, 43)}):Play()
        callback(state)
    end)
end

local function createSlider(page, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 55)
Frame.BackgroundColor3 = BUTTONFrame.BorderSizePixel = 0Frame.Parent = pagelocal Corner = Instance.new("UICorner")Corner.CornerRadius = UDim.new(0, 6)Corner.Parent = Framelocal Label = Instance.new("TextLabel")Label.Size = UDim2.new(1, -20, 0, 25)Label.Position = UDim2.fromOffset(10, 2)Label.BackgroundTransparency = 1Label.Text = text .. ": " .. tostring(default)Label.TextColor3 = TEXTLabel.TextSize = 13Label.Font = Enum.Font.GothamLabel.TextXAlignment = Enum.TextXAlignment.LeftLabel.Parent = Framelocal SliderBg = Instance.new("TextButton")SliderBg.Size = UDim2.new(1, -20, 0, 6)SliderBg.Position = UDim2.fromOffset(10, 35)SliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 48)SliderBg.BorderSizePixel = 0SliderBg.Text = ""SliderBg.AutoButtonColor = falseSliderBg.Parent = Framelocal SliderBar = Instance.new("Frame")SliderBar.Size = UDim2.fromScale((default - min) / (max - min), 1)SliderBar.BackgroundColor3 = Color3.fromRGB(135, 150, 255)SliderBar.BorderSizePixel = 0SliderBar.Parent = SliderBglocal function updateSlider(input)local percentage = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)SliderBar.Size = UDim2.fromScale(percentage, 1)local value = math.round(min + (percentage * (max - min)))Label.Text = text .. ": " .. tostring(value)callback(value)endlocal dragging = falseSliderBg.InputBegan:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thendragging = trueupdateSlider(input)endend)UserInputService.InputChanged:Connect(function(input)if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) thenupdateSlider(input)endend)UserInputService.InputEnded:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thendragging = falseendend)end--==================================================-- СОЗДАНИЕ ВКЛАДОК И СВЯЗЫВАНИЕ ИНТЕРФЕЙСА--==================================================local function registerTab(name, order)local Tab = Instance.new("TextButton")Tab.Name = name .. "Tab"Tab.Size = UDim2.new(1, 0, 0, 36)Tab.LayoutOrder = orderTab.BackgroundColor3 = Color3.fromRGB(18, 18, 19)Tab.BorderSizePixel = 0Tab.Text = nameTab.TextColor3 = SUBTEXTTab.TextSize = 13Tab.Font = Enum.Font.GothamMediumTab.AutoButtonColor = falseTab.Parent = Sidebarlocal TabCorner = Instance.new("UICorner")TabCorner.CornerRadius = UDim.new(0, 7)TabCorner.Parent = Tablocal Accent = Instance.new("Frame")Accent.Size = UDim2.fromOffset(3, 24)Accent.Position = UDim2.fromOffset(0, 6)Accent.BackgroundColor3 = Color3.fromRGB(135, 150, 255)Accent.BorderSizePixel = 0Accent.Visible = falseAccent.Parent = TabTabs[name] = {Button = Tab, Accent = Accent}endlocal function selectTab(name)for tName, tObj in pairs(Tabs) doif tName == name thentObj.Button.BackgroundColor3 = Color3.fromRGB(29, 29, 31)tObj.Button.TextColor3 = TEXTtObj.Accent.Visible = truePages[tName].Visible = trueelsetObj.Button.BackgroundColor3 = Color3.fromRGB(18, 18, 19)tObj.Button.TextColor3 = SUBTEXTtObj.Accent.Visible = falsePages[tName].Visible = falseendendend-- Регистрация Combat и VisualsregisterTab("Combat", 1)registerTab("Visuals", 2)local combatPage = createPage("Combat")local visualsPage = createPage("Visuals")-- Инициализируем вкладку по умолчаниюTabs["Combat"].Button.MouseButton1Click:Connect(function() selectTab("Combat") end)Tabs["Visuals"].Button.MouseButton1Click:Connect(function() selectTab("Visuals") end)selectTab("Combat")--==================================================-- НАПОЛНЕНИЕ НАСТРОЙКАМИ (UI CONTROLS)--==================================================-- CombatcreateCheckbox(combatPage, "Включить Aimbot (Instant Snap)", function(v)Settings.Combat.Aimbot = vFovCircle.Visible = (v or Settings.Combat.FlickBot)end)createCheckbox(combatPage, "Включить AimFlickBot (При нажатии выстрела)", function(v)Settings.Combat.FlickBot = vFovCircle.Visible = (v or Settings.Combat.Aimbot)end)createSlider(combatPage, "Радиус прицеливания (FOV)", 10, 900, Settings.Combat.Fov, function(v)Settings.Combat.Fov = vFovCircle.Radius = vend)createCheckbox(combatPage, "Глобальный WallCheck (Стены)", function(v)Settings.Combat.WallCheck = vend)-- VisualscreateCheckbox(visualsPage, "Включить 2D ESP", function(v) Settings.Visuals.ESP = v end)createCheckbox(visualsPage, "Включить Модели (Charms)", function(v) Settings.Visuals.Charms = v end)--==================================================-- ЛОГИКА ХАКОВ (WALLCHECK, AIMBOT, ESP, CHARMS)--==================================================-- Функция проверки препятствий между камерой и головой противникаlocal function IsVisible(targetPart)if not Settings.Combat.WallCheck then return true endif not targetPart then return false endlocal castRay = Ray.new(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 1000)local hit, position = Workspace:FindPartOnRayWithIgnoreList(castRay, {player.Character, targetPart.Parent})return hit == nilend-- Поиск ближайшей валидной цели в радиусе FOVlocal function GetClosestTarget()local closestTarget = nillocal shortestDistance = math.hugefor _, v in pairs(Players:GetPlayers()) doif v ~= player and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChildOfClass("Humanoid") and v.Character.Humanoid.Health > 0 thenlocal head = v.Character.Head-- Проверка WallCheck для аимаif IsVisible(head) thenlocal screenPos, onScreen = camera:WorldToViewportPoint(head.Position)if onScreen thenlocal mousePos = UserInputService:GetMouseLocation()local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitudeif distance < Settings.Combat.Fov and distance < shortestDistance thenclosestTarget = headshortestDistance = distanceendendendendendreturn closestTargetend-- Логика постоянного обновления кадровlocal isShooting = false-- Проверка нажатия выстрела/касания для FlickBotUserInputService.InputBegan:Connect(function(input, processed)if processed then return endif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenisShooting = trueendend)UserInputService.InputEnded:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenisShooting = falseendend)-- Рендер ESP и обновление FOV кольца в реальном времениlocal espObjects = {}RunService.RenderStepped:Connect(function()-- Обновление позиции круга FOV за мышкойlocal mouseLocation = UserInputService:GetMouseLocation()FovCircle.Position = mouseLocation-- Обработка Аимботовlocal target = GetClosestTarget()if target then-- 1. Стандартный моментальный аимботif Settings.Combat.Aimbot thencamera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)-- 2. AimFlickBot (только в момент удержания выстрела)elseif Settings.Combat.FlickBot and isShooting thencamera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)endend-- Визуальная отрисовка ESP и Charmsfor _, v in pairs(Players:GetPlayers()) doif v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChildOfClass("Humanoid") and v.Character.Humanoid.Health > 0 thenlocal hrp = v.Character.HumanoidRootPartlocal head = v.Character:FindFirstChild("Head")-- Проверка глобального WallCheck для отображения визуаловlocal visibleByWall = IsVisible(head)-- Чамсы (Charms)local highlight = v.Character:FindFirstChildOfClass("Highlight")if Settings.Visuals.Charms and visibleByWall thenif not highlight thenhighlight = Instance.new("Highlight")highlight.Parent = v.Characterhighlight.FillColor = Color3.fromRGB(255, 0, 100)highlight.OutlineColor = Color3.fromRGB(255, 255, 255)highlight.FillTransparency = 0.4endelseif highlight then highlight:Destroy() endend-- 2D ESP Блок и Линииlocal screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)if Settings.Visuals.ESP and onScreen and visibleByWall thenif not espObjects[v] thenespObjects[v] = {Box = Drawing.new("Square"),Line = Drawing.new("Line")}endlocal box = espObjects[v].Boxbox.Visible = truebox.Color = Color3.fromRGB(0, 255, 150)box.Thickness = 1.5box.Size = Vector2.new(2000 / screenPos.Z, 3000 / screenPos.Z)box.Position = Vector2.new(screenPos.X - box.Size.X / 2, screenPos.Y - box.Size.Y / 2)local line = espObjects[v].Lineline.Visible = trueline.Color = Color3.fromRGB(255, 255, 255)line.Thickness = 1line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)line.To = Vector2.new(screenPos.X, screenPos.Y)elseif espObjects[v] thenespObjects[v].Box.Visible = falseespObjects[v].Line.Visible = falseendendelseif espObjects[v] thenespObjects[v].Box.Visible = falseespObjects[v].Line.Visible = falseendif v.Character and v.Character:FindFirstChildOfClass("Highlight") thenv.Character:FindFirstChildOfClass("Highlight"):Destroy()endendendend)-- Очистка ресурсов при выходе игроковPlayers.PlayerRemoving:Connect(function(v)if espObjects[v] thenespObjects[v].Box:Remove()espObjects[v].Line:Remove()espObjects[v] = nilendend)--==================================================-- MENU OPEN / CLOSE & DRAG LOGIC (ОРИГИНАЛЬНАЯ ИЗ КОДА)--==================================================local MenuOpen = falselocal function OpenMenu()if MenuOpen then return endMenuOpen = trueMain.Visible = trueMainScale.Scale = 0.94Main.BackgroundTransparency = 0.2HubButton.ZIndex = 100TweenService:Create(MainScale, MENU_TWEEN, {Scale = 1}):Play()TweenService:Create(Main, MENU_TWEEN, {BackgroundTransparency = 0}):Play()endlocal function CloseMenu()if not MenuOpen then return endMenuOpen = falseTweenService:Create(MainScale, MENU_TWEEN, {Scale = 0.94}):Play()local fade = TweenService:Create(Main, MENU_TWEEN, {BackgroundTransparency = 0.25})fade:Play()fade.Completed:Once(function()if not MenuOpen then Main.Visible = false endend)endHubButton.MouseButton1Click:Connect(function()if MenuOpen then CloseMenu() else OpenMenu() endend)Close.MouseButton1Click:Connect(function() CloseMenu() end)-- Перетаскивание (Drag) кнопки и менюlocal ButtonDragging, ButtonDragStart, ButtonStartPositionHubButton.InputBegan:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenButtonDragging = trueButtonDragStart = input.PositionButtonStartPosition = HubButton.Positionendend)HubButton.InputEnded:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenButtonDragging = falseendend)local MenuDragging, MenuDragStart, MenuStartPositionMain.InputBegan:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenMenuDragging = trueMenuDragStart = input.PositionMenuStartPosition = Main.Positionendend)Main.InputEnded:Connect(function(input)if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch thenMenuDragging = falseendend)UserInputService.InputChanged:Connect(function(input)if ButtonDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) thenlocal Delta = input.Position - ButtonDragStartHubButton.Position = UDim2.new(ButtonStartPosition.X.Scale, ButtonStartPosition.X.Offset + Delta.X, ButtonStartPosition.Y.Scale, ButtonStartPosition.Y.Offset + Delta.Y)endif MenuDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) thenlocal Delta = input.Position - MenuDragStartMain.Position = UDim2.new(MenuStartPosition.X.Scale, MenuStartPosition.X.Offset + Delta.X, MenuStartPosition.Y.Scale, MenuStartPosition.Y.Offset + Delta.Y)endend)
