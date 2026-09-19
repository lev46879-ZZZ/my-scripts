
-- // Полный каркас: 6 вкладок, 17+ функций каждая // --

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local LocalPlayer       = Players.LocalPlayer

-- // ТЕМА (Mercedes-style dark + red) //
local Theme = {
    Background  = Color3.fromRGB(20, 20, 20),
    Sidebar     = Color3.fromRGB(14, 14, 14),
    Panel       = Color3.fromRGB(32, 32, 32),
    PanelHover  = Color3.fromRGB(42, 42, 42),
    Accent      = Color3.fromRGB(200, 45, 55),
    AccentDark  = Color3.fromRGB(150, 30, 40),
    Text        = Color3.fromRGB(240, 240, 240),
    TextDim     = Color3.fromRGB(140, 140, 140),
    ToggleOff   = Color3.fromRGB(60, 60, 60),
    Border      = Color3.fromRGB(48, 48, 48),
    Success     = Color3.fromRGB(80, 180, 100),
    Input       = Color3.fromRGB(38, 38, 38)
}

-- // ХЕЛПЕРЫ //
local function Tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function Corner(r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function Stroke(color, thick, transp)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thick or 1
    s.Transparency = transp or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

-- // SCREEN GUI //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MercedesMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- // ПЛАВАЮЩАЯ КНОПКА С КАРТИНКОЙ //
local OpenButton = Instance.new("ImageButton")
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 52, 0, 52)
OpenButton.Position = UDim2.new(0.08, 0, 0.28, 0)
OpenButton.BackgroundColor3 = Theme.Background
OpenButton.Image = "rbxassetid://70778639689171"  -- Твоя аватарка
OpenButton.ImageColor3 = Color3.fromRGB(255, 255, 255)  -- Без искажения цвета
OpenButton.ScaleType = Enum.ScaleType.Crop  -- Crop = заполнить всё, Fit = вписать целиком
OpenButton.AutoButtonColor = false
OpenButton.Active = true
OpenButton.Text = ""  -- Текст убран
Corner(14)(OpenButton)
local btnStroke = Stroke(Theme.Accent, 2, 0)
btnStroke.Parent = OpenButton

-- Пульсация обводки
task.spawn(function()
    while ScreenGui.Parent do
        Tween(btnStroke, 1.4, {Transparency = 0.7}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.4)
        Tween(btnStroke, 1.4, {Transparency = 0}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.4)
    end
end)

-- // ГЛАВНОЕ ОКНО (размер как на референсе) //
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 720, 0, 520)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Corner(12)(MainFrame)
Stroke(Theme.Border, 1, 0).Parent = MainFrame

local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
UIScale.Scale = 0

local isOpen = false
local function ToggleMenu()
    if isOpen then
        isOpen = false
        local t = Tween(UIScale, 0.2, {Scale = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        t.Completed:Connect(function() MainFrame.Visible = false end)
    else
        isOpen = true
        MainFrame.Visible = true
        Tween(UIScale, 0.35, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end
OpenButton.MouseButton1Click:Connect(ToggleMenu)

-- // ПЕРЕТАСКИВАНИЕ //
local function Drag(frame, handle)
    local drag, startP, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; startP = i.Position; startPos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startP
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end
Drag(OpenButton, OpenButton)

-- // ВЕРХНЯЯ ПАНЕЛЬ //
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.Sidebar
TopBar.BorderSizePixel = 0
Corner(12)(TopBar)
local TopBarFix = Instance.new("Frame")
TopBarFix.Parent = TopBar
TopBarFix.Size = UDim2.new(1, 0, 0, 14)
TopBarFix.Position = UDim2.new(0, 0, 1, -14)
TopBarFix.BackgroundColor3 = Theme.Sidebar
TopBarFix.BorderSizePixel = 0

-- Логотип Mercedes (звёздочка)
local Logo = Instance.new("TextLabel")
Logo.Parent = TopBar
Logo.Position = UDim2.new(0, 16, 0, 0)
Logo.Size = UDim2.new(0, 24, 1, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "✦"
Logo.TextColor3 = Theme.Accent
Logo.Font = Enum.Font.GothamBold
Logo.TextSize = 16

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TopBar
TitleText.Position = UDim2.new(0, 42, 0, 0)
TitleText.Size = UDim2.new(1, -100, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Mercedes"
TitleText.TextColor3 = Theme.Text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local VersionText = Instance.new("TextLabel")
VersionText.Parent = TopBar
VersionText.Position = UDim2.new(1, -130, 0, 0)
VersionText.Size = UDim2.new(0, 80, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v1.0.0"
VersionText.TextColor3 = Theme.TextDim
VersionText.Font = Enum.Font.Gotham
VersionText.TextSize = 12
VersionText.TextXAlignment = Enum.TextXAlignment.Right

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Theme.Panel
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.TextDim
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
Corner(8)(CloseBtn)
CloseBtn.MouseButton1Click:Connect(ToggleMenu)
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, 0.15, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, 0.15, {BackgroundColor3 = Theme.Panel, TextColor3 = Theme.TextDim}) end)

Drag(MainFrame, TopBar)

-- // ЛЕВАЯ ПАНЕЛЬ //
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Size = UDim2.new(0, 150, 1, -62)
Sidebar.Position = UDim2.new(0, 10, 0, 52)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Corner(10)(Sidebar)

local SideScroll = Instance.new("ScrollingFrame")
SideScroll.Parent = Sidebar
SideScroll.Size = UDim2.new(1, 0, 1, 0)
SideScroll.BackgroundTransparency = 1
SideScroll.BorderSizePixel = 0
SideScroll.ScrollBarThickness = 0
SideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local sp = Instance.new("UIPadding", SideScroll)
sp.PaddingTop = UDim.new(0, 8)
sp.PaddingLeft = UDim.new(0, 8)
sp.PaddingRight = UDim.new(0, 8)

local SideLayout = Instance.new("UIListLayout", SideScroll)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 3)

-- // КОНТЕНТ //
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -170, 1, -62)
ContentArea.Position = UDim2.new(0, 160, 0, 52)
ContentArea.BackgroundTransparency = 1

-- // ВКЛАДКИ //
local Tabs = {}
local ActiveTab = nil

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Parent = SideScroll
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Theme.Background
    btn.Text = "   " .. icon .. "   " .. name
    btn.TextColor3 = Theme.TextDim
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    Corner(7)(btn)

    local ind = Instance.new("Frame")
    ind.Parent = btn
    ind.Size = UDim2.new(0, 3, 0, 0)
    ind.Position = UDim2.new(0, 0, 0.5, 0)
    ind.BackgroundColor3 = Theme.Accent
    ind.BorderSizePixel = 0
    Corner(2)(ind)

    local content = Instance.new("ScrollingFrame")
    content.Parent = ContentArea
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = false
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Theme.Accent
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local cp = Instance.new("UIPadding", content)
    cp.PaddingTop = UDim.new(0, 4)
    cp.PaddingBottom = UDim.new(0, 20)
    cp.PaddingLeft = UDim.new(0, 4)
    cp.PaddingRight = UDim.new(0, 4)

    local layout = Instance.new("UIListLayout", content)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    table.insert(Tabs, {Button = btn, Content = content, Indicator = ind, Name = name})

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(Tabs) do
            t.Content.Visible = false
            Tween(t.Button, 0.15, {BackgroundColor3 = Theme.Background, TextColor3 = Theme.TextDim})
            Tween(t.Indicator, 0.2, {Size = UDim2.new(0, 3, 0, 0)})
        end
        content.Visible = true
        Tween(btn, 0.15, {BackgroundColor3 = Theme.Panel, TextColor3 = Theme.Text})
        Tween(ind, 0.2, {Size = UDim2.new(0, 3, 0, 18)})
        ActiveTab = name
    end)

    btn.MouseEnter:Connect(function()
        if ActiveTab ~= name then Tween(btn, 0.15, {BackgroundColor3 = Theme.Panel, TextColor3 = Theme.Text}) end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= name then Tween(btn, 0.15, {BackgroundColor3 = Theme.Background, TextColor3 = Theme.TextDim}) end
    end)

    return content
end

-- Создаём 6 вкладок
local TabMain     = CreateTab("main",     "⌂")
local TabCombat   = CreateTab("combat",   "⚔")
local TabScript   = CreateTab("script",   "⌘")
local TabVisuals  = CreateTab("visuals",  "◉")
local TabSetting  = CreateTab("settings", "⚙")
local TabConfig   = CreateTab("cfg",      "❒")

Tabs[1].Content.Visible = true
Tabs[1].Button.BackgroundColor3 = Theme.Panel
Tabs[1].Button.TextColor3 = Theme.Text
ActiveTab = "main"
Tween(Tabs[1].Indicator, 0.3, {Size = UDim2.new(0, 3, 0, 18)})


-- ============================== //
-- // UI КОМПОНЕНТЫ //
-- ============================== //

-- // SECTION HEADER //
local function Section(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = parent
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = Theme.Accent
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

-- // TOGGLE //
local function Toggle(parent, text, default, callback)
    default = default or false
    callback = callback or function() end

    local box = Instance.new("Frame")
    box.Parent = parent
    box.Size = UDim2.new(1, 0, 0, 36)
    box.BackgroundColor3 = Theme.Panel
    box.BorderSizePixel = 0
    Corner(8)(box)

    local lbl = Instance.new("TextLabel")
    lbl.Parent = box
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local bg = Instance.new("Frame")
    bg.Parent = box
    bg.Size = UDim2.new(0, 36, 0, 20)
    bg.Position = UDim2.new(1, -48, 0.5, -10)
    bg.BackgroundColor3 = default and Theme.Accent or Theme.ToggleOff
    bg.BorderSizePixel = 0
    Corner(10)(bg)

    local knob = Instance.new("Frame")
    knob.Parent = bg
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    Corner(7)(knob)

    local btn = Instance.new("TextButton")
    btn.Parent = box
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        Tween(bg, 0.22, {BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff}, Enum.EasingStyle.Quart)
        Tween(knob, 0.22, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, Enum.EasingStyle.Quart)
        callback(state)
    end)
    btn.MouseEnter:Connect(function() Tween(box, 0.15, {BackgroundColor3 = Theme.PanelHover}) end)
    btn.MouseLeave:Connect(function() Tween(box, 0.15, {BackgroundColor3 = Theme.Panel}) end)

    return {
        Frame = box,
        Set = function(v)
            state = v
            Tween(bg, 0.2, {BackgroundColor3 = v and Theme.Accent or Theme.ToggleOff})
            Tween(knob, 0.2, {Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
        end
    }
end

-- // SLIDER //
local function Slider(parent, text, min, max, default, callback)
    min, max = min or 0, max or 100
    default = default or min
    callback = callback or function() end

    local box = Instance.new("Frame")
    box.Parent = parent
    box.Size = UDim2.new(1, 0, 0, 52)
    box.BackgroundColor3 = Theme.Panel
    box.BorderSizePixel = 0
    Corner(8)(box)

    local lbl = Instance.new("TextLabel")
    lbl.Parent = box
    lbl.Position = UDim2.new(0, 12, 0, 6)
    lbl.Size = UDim2.new(0.6, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel")
    val.Parent = box
    val.Position = UDim2.new(0.6, 0, 0, 6)
    val.Size = UDim2.new(0.4, -12, 0, 18)
    val.BackgroundTransparency = 1
    val.Text = tostring(default)
    val.TextColor3 = Theme.Accent
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame")
    track.Parent = box
    track.Position = UDim2.new(0, 12, 1, -20)
    track.Size = UDim2.new(1, -24, 0, 5)
    track.BackgroundColor3 = Theme.ToggleOff
    track.BorderSizePixel = 0
    Corner(3)(track)

    local fill = Instance.new("Frame")
    fill.Parent = track
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    Corner(3)(fill)

    local knob = Instance.new("Frame")
    knob.Parent = track
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    Corner(7)(knob)
    Stroke(Theme.Accent, 2, 0).Parent = knob

    local drag = false
    local function update(i)
        local mx = i.Position.X
        local pos = track.AbsolutePosition.X
        local size = track.AbsoluteSize.X
        local pct = math.clamp((mx - pos) / size, 0, 1)
        local v = math.floor(min + (max - min) * pct + 0.5)
        val.Text = tostring(v)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -7, 0.5, -7)
        callback(v)
    end

    local area = Instance.new("TextButton")
    area.Parent = box
    area.Size = UDim2.new(1, 0, 0, 22)
    area.Position = UDim2.new(0, 0, 1, -22)
    area.BackgroundTransparency = 1
    area.Text = ""

    area.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            Tween(knob, 0.1, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(knob.Position.X.Scale, -9, 0.5, -9)})
            update(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
            Tween(knob, 0.15, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(knob.Position.X.Scale, -7, 0.5, -7)})
        end
    end)

    return {
        Frame = box,
        Set = function(v)
            local pct = math.clamp((v - min) / (max - min), 0, 1)
            val.Text = tostring(v)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -7, 0.5, -7)
        end
    }
end

-- // BUTTON //
local function Button(parent, text, callback)
    callback = callback or function() end

    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Theme.Panel
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.AutoButtonColor = false
    Corner(8)(btn)

    btn.MouseEnter:Connect(function() Tween(btn, 0.15, {BackgroundColor3 = Theme.Accent}) end)
    btn.MouseLeave:Connect(function() Tween(btn, 0.15, {BackgroundColor3 = Theme.Panel}) end)
    btn.MouseButton1Click:Connect(function()
        Tween(btn, 0.08, {Size = UDim2.new(0.97, 0, 0, 32)})
        task.wait(0.08)
        Tween(btn, 0.12, {Size = UDim2.new(1, 0, 0, 34)})
        callback()
    end)

    return btn
end

-- // DROPDOWN //
local function Dropdown(parent, text, options, default, callback)
    options = options or {}
    default = default or (options[1] or "None")
    callback = callback or function() end

    local box = Instance.new("Frame")
    box.Parent = parent
    box.Size = UDim2.new(1, 0, 0, 36)
    box.BackgroundColor3 = Theme.Panel
    box.BorderSizePixel = 0
    box.ClipsDescendants = false
    Corner(8)(box)

    local lbl = Instance.new("TextLabel")
    lbl.Parent = box
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local current = Instance.new("TextLabel")
    current.Parent = box
    current.Position = UDim2.new(0.5, 0, 0, 0)
    current.Size = UDim2.new(0.5, -30, 1, 0)
    current.BackgroundTransparency = 1
    current.Text = default .. "  ▾"
    current.TextColor3 = Theme.Accent
    current.Font = Enum.Font.Gotham
    current.TextSize = 12
    current.TextXAlignment = Enum.TextXAlignment.Right

    local list = Instance.new("Frame")
    list.Parent = box
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 1, 4)
    list.BackgroundColor3 = Theme.Input
    list.BorderSizePixel = 0
    list.Visible = false
    list.ClipsDescendants = true
    Corner(8)(list)
    Stroke(Theme.Border, 1, 0).Parent = list

    local ll = Instance.new("UIListLayout", list)
    ll.Padding = UDim.new(0, 2)
    local lp = Instance.new("UIPadding", list)
    lp.PaddingTop = UDim.new(0, 4)
    lp.PaddingBottom = UDim.new(0, 4)

    local isOpen = false
    local btn = Instance.new("TextButton")
    btn.Parent = box
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local function close()
        isOpen = false
        Tween(list, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
        task.wait(0.2)
        list.Visible = false
    end

    for _, opt in ipairs(options) do
        local oBtn = Instance.new("TextButton")
        oBtn.Parent = list
        oBtn.Size = UDim2.new(1, -8, 0, 26)
        oBtn.BackgroundColor3 = Theme.Panel
        oBtn.Text = opt
        oBtn.TextColor3 = Theme.Text
        oBtn.Font = Enum.Font.Gotham
        oBtn.TextSize = 11
        oBtn.AutoButtonColor = false
        Corner(5)(oBtn)
        oBtn.MouseEnter:Connect(function() Tween(oBtn, 0.1, {BackgroundColor3 = Theme.Accent}) end)
        oBtn.MouseLeave:Connect(function() Tween(oBtn, 0.1, {BackgroundColor3 = Theme.Panel}) end)
        oBtn.MouseButton1Click:Connect(function()
            current.Text = opt .. "  ▾"
            callback(opt)
            close()
        end)
    end

    btn.MouseButton1Click:Connect(function()
        if isOpen then close() else
            isOpen = true
            list.Visible = true
            Tween(list, 0.25, {Size = UDim2.new(1, 0, 0, #options * 28 + 8)})
        end
    end)

    return box
end

-- // KEYBIND //
local function Keybind(parent, text, default, callback)
    default = default or "None"
    callback = callback or function() end

    local box = Instance.new("Frame")
    box.Parent = parent
    box.Size = UDim2.new(1, 0, 0, 36)
    box.BackgroundColor3 = Theme.Panel
    box.BorderSizePixel = 0
    Corner(8)(box)

    local lbl = Instance.new("TextLabel")
    lbl.Parent = box
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local keyBox = Instance.new("TextButton")
    keyBox.Parent = box
    keyBox.Size = UDim2.new(0, 80, 0, 24)
    keyBox.Position = UDim2.new(1, -92, 0.5, -12)
    keyBox.BackgroundColor3 = Theme.Input
    keyBox.Text = default
    keyBox.TextColor3 = Theme.Accent
    keyBox.Font = Enum.Font.GothamBold
    keyBox.TextSize = 11
    keyBox.AutoButtonColor = false
    Corner(6)(keyBox)

    local listening = false
    local currentKey = default

    keyBox.MouseButton1Click:Connect(function()
        listening = true
        keyBox.Text = "..."
        keyBox.TextColor3 = Theme.TextDim
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and not gpe then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode.Name
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                currentKey = "Mouse1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                currentKey = "Mouse2"
            end
            keyBox.Text = currentKey
            keyBox.TextColor3 = Theme.Accent
            listening = false
            callback(currentKey)
        end
    end)

    return box
end

-- // TEXTBOX //
local function Textbox(parent, placeholder, callback)
    callback = callback or function() end

    local box = Instance.new("Frame")
    box.Parent = parent
    box.Size = UDim2.new(1, 0, 0, 36)
    box.BackgroundColor3 = Theme.Panel
    box.BorderSizePixel = 0
    Corner(8)(box)

    local input = Instance.new("TextBox")
    input.Parent = box
    input.Size = UDim2.new(1, -24, 1, 0)
    input.Position = UDim2.new(0, 12, 0, 0)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.PlaceholderText = placeholder
    input.PlaceholderColor3 = Theme.TextDim
    input.TextColor3 = Theme.Text
    input.Font = Enum.Font.Gotham
    input.TextSize = 12
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false

    input.FocusLost:Connect(function()
        callback(input.Text)
    end)

    return {Frame = box, Get = function() return input.Text end, Set = function(v) input.Text = v end}
end

-- // COLOR PICKER (визуальный) //
local function ColorPicker(parent, text, defaultColor, callback)
    defaultColor = defaultColor or Theme.Accent
    callback = callback or function() end

    local box = Instance.new("Frame")
    box.Parent = parent
    box.Size = UDim2.new(1, 0, 0, 36)
    box.BackgroundColor3 = Theme.Panel
    box.BorderSizePixel = 0
    Corner(8)(box)

    local lbl = Instance.new("TextLabel")
    lbl.Parent = box
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local swatch = Instance.new("Frame")
    swatch.Parent = box
    swatch.Size = UDim2.new(0, 60, 0, 22)
    swatch.Position = UDim2.new(1, -72, 0.5, -11)
    swatch.BackgroundColor3 = defaultColor
    swatch.BorderSizePixel = 0
    Corner(6)(swatch)
    Stroke(Theme.Border, 1, 0).Parent = swatch

    local btn = Instance.new("TextButton")
    btn.Parent = box
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local palette = {
        Color3.fromRGB(200, 45, 55),
        Color3.fromRGB(220, 120, 40),
        Color3.fromRGB(230, 200, 60),
        Color3.fromRGB(90, 200, 90),
        Color3.fromRGB(60, 150, 240),
        Color3.fromRGB(150, 90, 220),
        Color3.fromRGB(240, 240, 240),
        Color3.fromRGB(0, 0, 0)
    }
    local idx = 1

    btn.MouseButton1Click:Connect(function()
        idx = idx % #palette + 1
        swatch.BackgroundColor3 = palette[idx]
        callback(palette[idx])
    end)

    return box
end


-- ============================== //
-- // ВКЛАДКА: MAIN (17+) //
-- ============================== //
Section(TabMain, "Movement")
Toggle(TabMain, "Enabled", false, function(v) print("Main.Enabled:", v) end)
Toggle(TabMain, "Sprint", true, function(v) end)
Toggle(TabMain, "Speed Boost", false, function(v) end)
Slider(TabMain, "Walk Speed", 16, 200, 16, function(v) end)
Toggle(TabMain, "Jump Boost", false, function(v) end)
Slider(TabMain, "Jump Power", 50, 500, 50, function(v) end)
Toggle(TabMain, "Infinite Jump", false, function(v) end)
Toggle(TabMain, "Double Jump", false, function(v) end)
Toggle(TabMain, "Wall Run", false, function(v) end)
Toggle(TabMain, "Slide", false, function(v) end)

Section(TabMain, "Flight")
Toggle(TabMain, "Fly", false, function(v) end)
Slider(TabMain, "Fly Speed", 10, 300, 60, function(v) end)
Toggle(TabMain, "Fly Smooth", true, function(v) end)
Dropdown(TabMain, "Fly Mode", {"Default", "Camera", "Directional", "Velocity"}, "Camera", function(v) end)

Section(TabMain, "Physics")
Slider(TabMain, "Gravity", 0, 300, 196, function(v) end)
Slider(TabMain, "Friction", 0, 100, 50, function(v) end)

Section(TabMain, "Controls")
Keybind(TabMain, "Toggle Main", "RightShift", function(k) end)
Keybind(TabMain, "Fly Keybind", "F", function(k) end)
Button(TabMain, "Reset All Movement", function() print("Reset main") end)


-- ============================== //
-- // ВКЛАДКА: COMBAT (17+) //
-- ============================== //
Section(TabCombat, "Auto Actions")
Toggle(TabCombat, "Auto Attack", false, function(v) end)
Toggle(TabCombat, "Auto Block", false, function(v) end)
Toggle(TabCombat, "Auto Parry", false, function(v) end)
Toggle(TabCombat, "Auto Dodge", false, function(v) end)
Toggle(TabCombat, "Auto Combo", false, function(v) end)
Slider(TabCombat, "Combo Delay (ms)", 0, 500, 100, function(v) end)

Section(TabCombat, "Aim Settings")
Toggle(TabCombat, "Aim Assist", false, function(v) end)
Toggle(TabCombat, "Silent Aim", false, function(v) end)
Slider(TabCombat, "Aim Smoothness", 0, 100, 50, function(v) end)
Slider(TabCombat, "Aim FOV", 0, 360, 90, function(v) end)
Dropdown(TabCombat, "Aim Bone", {"Head", "Torso", "Legs", "Nearest"}, "Head", function(v) end)

Section(TabCombat, "Trigger Bot")
Toggle(TabCombat, "Trigger Bot", false, function(v) end)
Slider(TabCombat, "Trigger Delay (ms)", 0, 500, 50, function(v) end)
Keybind(TabCombat, "Trigger Key", "E", function(k) end)

Section(TabCombat, "Attack Range")
Slider(TabCombat, "Hit Range", 5, 50, 10, function(v) end)
Slider(TabCombat, "Attack Speed", 1, 10, 5, function(v) end)
Toggle(TabCombat, "Instant Hit", false, function(v) end)
Button(TabCombat, "Reset Combat Settings", function() end)


-- ============================== //
-- // ВКЛАДКА: SCRIPT (17+) //
-- ============================== //
Section(TabScript, "Executor")
Textbox(TabScript, "Вставь ссылку или код...", function(v) print("Script:", v) end)
Button(TabScript, "Execute Script", function() print("Executed") end)
Toggle(TabScript, "Auto Execute on Load", false, function(v) end)
Toggle(TabScript, "Sandbox Mode", true, function(v) end)
Dropdown(TabScript, "Engine", {"Delta", "Krnl", "Synapse", "Custom"}, "Delta", function(v) end)

Section(TabScript, "Saved Scripts")
Button(TabScript, "Script Slot 1", function() end)
Button(TabScript, "Script Slot 2", function() end)
Button(TabScript, "Script Slot 3", function() end)
Button(TabScript, "Script Slot 4", function() end)

Section(TabScript, "Local Scripts")
Textbox(TabScript, "Название скрипта...", function(v) end)
Button(TabScript, "Save Current Script", function() end)
Button(TabScript, "Open Scripts Folder", function() end)
Button(TabScript, "Reload Scripts", function() end)

Section(TabScript, "Advanced")
Keybind(TabScript, "Quick Execute", "X", function(k) end)
Toggle(TabScript, "Log Output", true, function(v) end)
Toggle(TabScript, "Error Notify", true, function(v) end)
Slider(TabScript, "Timeout (сек)", 1, 30, 10, function(v) end)
Button(TabScript, "Clear Console", function() end)


-- ============================== //
-- // ВКЛАДКА: VISUALS (17+) //
-- ============================== //
Section(TabVisuals, "ESP Options")
Toggle(TabVisuals, "Player ESP", false, function(v) end)
Toggle(TabVisuals, "Box ESP", false, function(v) end)
Toggle(TabVisuals, "Name ESP", true, function(v) end)
Toggle(TabVisuals, "Health ESP", true, function(v) end)
Toggle(TabVisuals, "Distance ESP", true, function(v) end)
Toggle(TabVisuals, "Skeleton ESP", false, function(v) end)
Toggle(TabVisuals, "Tracer ESP", false, function(v) end)

Section(TabVisuals, "Colors")
ColorPicker(TabVisuals, "Box Color", Color3.fromRGB(200, 45, 55), function(c) end)
ColorPicker(TabVisuals, "Name Color", Color3.fromRGB(240, 240, 240), function(c) end)
ColorPicker(TabVisuals, "Tracer Color", Color3.fromRGB(90, 200, 90), function(c) end)

Section(TabVisuals, "World")
Toggle(TabVisuals, "Fullbright", false, function(v) end)
Slider(TabVisuals, "Brightness", 1, 10, 2, function(v) end)
Toggle(TabVisuals, "Remove Fog", false, function(v) end)
Toggle(TabVisuals, "Remove Effects", false, function(v) end)
Slider(TabVisuals, "Camera FOV", 70, 140, 70, function(v) end)
Toggle(TabVisuals, "Custom Skybox", false, function(v) end)
Slider(TabVisuals, "Max Render Distance", 100, 5000, 1000, function(v) end)


-- ============================== //
-- // ВКЛАДКА: SETTINGS (17+) //
-- ============================== //
Section(TabSetting, "Menu Appearance")
Toggle(TabSetting, "Show Keybind List", true, function(v) end)
Toggle(TabSetting, "Blur Background", false, function(v) end)
Slider(TabSetting, "Menu Opacity", 0, 100, 100, function(v) end)
Slider(TabSetting, "UI Scale", 50, 150, 100, function(v) end)
Dropdown(TabSetting, "Theme", {"Mercedes Red", "Midnight Blue", "Purple Haze", "Mono"}, "Mercedes Red", function(v) end)
Toggle(TabSetting, "Animations Enabled", true, function(v) end)
Slider(TabSetting, "Animation Speed", 1, 10, 5, function(v) end)
Toggle(TabSetting, "Sound Effects", false, function(v) end)
Slider(TabSetting, "Sound Volume", 0, 100, 50, function(v) end)

Section(TabSetting, "Safety")
Toggle(TabSetting, "Stream-Proof", false, function(v) end)
Toggle(TabSetting, "HWID Spoof", false, function(v) end)
Toggle(TabSetting, "Auto Disconnect on Detect", false, function(v) end)
Keybind(TabSetting, "Panic Key", "End", function(k) end)
Slider(TabSetting, "Detect Delay", 0, 5000, 500, function(v) end)

Section(TabSetting, "Info")
Slider(TabSetting, "Notification Duration", 1, 10, 3, function(v) end)
Toggle(TabSetting, "Save Settings on Exit", true, function(v) end)
Toggle(TabSetting, "Load Settings on Start", true, function(v) end)
Button(TabSetting, "Reset UI Position", function()
    Tween(MainFrame, 0.3, {Position = UDim2.new(0.5, -360, 0.5, -260)}, Enum.EasingStyle.Back)
end)


-- ============================== //
-- // ВКЛАДКА: CONFIG (только сохранение) //
-- ============================== //
Section(TabConfig, "Configuration")
Textbox(TabConfig, "Название конфига...", function(v) end)
Dropdown(TabConfig, "Select Config", {"default", "legit", "rage", "custom"}, "default", function(v) end)
Button(TabConfig, "Save Config", function() print("Saved") end)
Button(TabConfig, "Load Config", function() print("Loaded") end)
Button(TabConfig, "Delete Config", function() print("Deleted") end)

Section(TabConfig, "Import / Export")
Button(TabConfig, "Export to Clipboard", function() end)
Button(TabConfig, "Import from Clipboard", function() end)
Textbox(TabConfig, "Вставь JSON конфига...", function(v) end)

Section(TabConfig, "Danger Zone")
Button(TabConfig, "Reset All Settings", function() end)
Button(TabConfig, "Delete All Configs", function() end)


-- // УВЕДОМЛЕНИЕ //
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "
