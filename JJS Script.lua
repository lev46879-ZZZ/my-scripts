-- // MERCEDES STYLE MENU // --
-- // Финальная сборка v1.2 // --

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")
local LocalPlayer       = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

-- ============================== //
-- // ТЕМА //
-- ============================== //
local Theme = {
    Background  = Color3.fromRGB(20, 20, 20),
    Sidebar     = Color3.fromRGB(14, 14, 14),
    Panel       = Color3.fromRGB(32, 32, 32),
    PanelHover  = Color3.fromRGB(42, 42, 42),
    Accent      = Color3.fromRGB(200, 45, 55),
    Text        = Color3.fromRGB(240, 240, 240),
    TextDim     = Color3.fromRGB(140, 140, 140),
    ToggleOff   = Color3.fromRGB(60, 60, 60),
    Border      = Color3.fromRGB(48, 48, 48),
    Input       = Color3.fromRGB(38, 38, 38)
}

-- ============================== //
-- // ХЕЛПЕРЫ //
-- ============================== //
local function Tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function Corner(r)
    return function(parent)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = parent
        return c
    end
end

local function Stroke(color, thick, transp)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thick or 1
    s.Transparency = transp or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

-- ============================== //
-- // SCREEN GUI //
-- ============================== //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MercedesMenu"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- ============================== //
-- // ПЛАВАЮЩАЯ КНОПКА //
-- ============================== //
local OpenButton = Instance.new("TextButton")
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 56, 0, 56)
OpenButton.Position = UDim2.new(0.08, 0, 0.28, 0)
OpenButton.BackgroundColor3 = Theme.Background
OpenButton.Text = ""
OpenButton.AutoButtonColor = false
OpenButton.Active = true
OpenButton.ZIndex = 10
Corner(28)(OpenButton)
local btnStroke = Stroke(Theme.Accent, 2, 0)
btnStroke.Parent = OpenButton

local IconImage = Instance.new("ImageLabel")
IconImage.Parent = OpenButton
IconImage.Size = UDim2.new(1, -6, 1, -6)
IconImage.Position = UDim2.new(0, 3, 0, 3)
IconImage.BackgroundTransparency = 1
IconImage.Image = "rbxthumb://type=AvatarHeadShot&id=4526684446&w=420&h=420"
IconImage.ScaleType = Enum.ScaleType.Crop
IconImage.ZIndex = 11
IconImage.Active = false

task.spawn(function()
    while ScreenGui.Parent do
        Tween(btnStroke, 1.4, {Transparency = 0.7}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.4)
        Tween(btnStroke, 1.4, {Transparency = 0}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.4)
    end
end)

-- ============================== //
-- // ГЛАВНОЕ ОКНО //
-- ============================== //
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 720, 0, 520)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -260)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 5
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

local btnDragging, btnDragStart, btnStartPos, btnMoved = false, nil, nil, false
OpenButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true; btnMoved = false
        btnDragStart = input.Position; btnStartPos = OpenButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - btnDragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then btnMoved = true end
        OpenButton.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if btnDragging and not btnMoved then ToggleMenu() end
        btnDragging = false
    end
end)

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

-- ============================== //
-- // ВЕРХНЯЯ ПАНЕЛЬ //
-- ============================== //
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
VersionText.Text = "v1.2"
VersionText.TextColor3 = Theme.TextDim
VersionText.Font = Enum.Font.Gotham
VersionText.TextSize = 12
VersionText.TextXAlignment = Enum.TextXAlignment.Right

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

-- ============================== //
-- // ЛЕВАЯ ПАНЕЛЬ //
-- ============================== //
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
sp.PaddingTop = UDim.new(0, 8); sp.PaddingLeft = UDim.new(0, 8); sp.PaddingRight = UDim.new(0, 8)

local SideLayout = Instance.new("UIListLayout", SideScroll)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 3)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Size = UDim2.new(1, -170, 1, -62)
ContentArea.Position = UDim2.new(0, 160, 0, 52)
ContentArea.BackgroundTransparency = 1

-- ============================== //
-- // СИСТЕМА ВКЛАДОК //
-- ============================== //
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
    cp.PaddingTop = UDim.new(0, 4); cp.PaddingBottom = UDim.new(0, 20)
    cp.PaddingLeft = UDim.new(0, 4); cp.PaddingRight = UDim.new(0, 4)

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

    return {Frame = box, Get = function() return state end}
end

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

    return {Frame = box, Get = function() return math.floor(min + (max - min) * knob.Position.X.Scale + 0.5) end}
end

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
    list.ZIndex = 20
    Corner(8)(list)
    Stroke(Theme.Border, 1, 0).Parent = list

    local ll = Instance.new("UIListLayout", list)
    ll.Padding = UDim.new(0, 2)
    local lp = Instance.new("UIPadding", list)
    lp.PaddingTop = UDim.new(0, 4); lp.PaddingBottom = UDim.new(0, 4)

    local isOpen2 = false
    local btn = Instance.new("TextButton")
    btn.Parent = box
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local function close()
        isOpen2 = false
        Tween(list, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
        task.wait(0.2)
        list.Visible = false
    end

    local selectedValue = default
    local api = {}

    local function rebuildItems()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, opt in ipairs(api.Options) do
            local oBtn = Instance.new("TextButton")
            oBtn.Parent = list
            oBtn.Size = UDim2.new(1, -8, 0, 26)
            oBtn.BackgroundColor3 = Theme.Panel
            oBtn.Text = opt
            oBtn.TextColor3 = Theme.Text
            oBtn.Font = Enum.Font.Gotham
            oBtn.TextSize = 11
            oBtn.AutoButtonColor = false
            oBtn.ZIndex = 21
            Corner(5)(oBtn)
            oBtn.MouseEnter:Connect(function() Tween(oBtn, 0.1, {BackgroundColor3 = Theme.Accent}) end)
            oBtn.MouseLeave:Connect(function() Tween(oBtn, 0.1, {BackgroundColor3 = Theme.Panel}) end)
            oBtn.MouseButton1Click:Connect(function()
                selectedValue = opt
                current.Text = opt .. "  ▾"
                callback(opt)
                close()
            end)
        end
    end

    api.Options = options
    api.Rebuild = function(newOptions)
        api.Options = newOptions
        rebuildItems()
    end
    api.Get = function() return selectedValue end

    rebuildItems()

    btn.MouseButton1Click:Connect(function()
        if isOpen2 then close() else
            isOpen2 = true
            list.Visible = true
            Tween(list, 0.25, {Size = UDim2.new(1, 0, 0, #api.Options * 28 + 8)})
        end
    end)

    return api
end


-- ============================== //
-- // РАБОЧАЯ ЛОГИКА //
-- ============================== //

-- // FLY //
local FlyEnabled = false
local FlySpeed = 60
local flyBodyVelocity = nil
local flyBodyGyro = nil

RunService.RenderStepped:Connect(function()
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        if not flyBodyVelocity or not flyBodyVelocity.Parent then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVelocity.Parent = hrp
        end
        if not flyBodyGyro or not flyBodyGyro.Parent then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.P = 10000
            flyBodyGyro.D = 500
            flyBodyGyro.Parent = hrp
        end

        local camCF = Camera.CFrame
        local camLook = camCF.LookVector
        local camRight = camCF.RightVector

        local moveVector = humanoid.MoveDirection

        local direction = Vector3.new(0, 0, 0)
        if moveVector.Magnitude > 0.05 then
            direction = (camLook * moveVector.Z + camRight * moveVector.X)
            if direction.Magnitude > 1 then direction = direction.Unit end
        end

        local vertical = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vertical = Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vertical = Vector3.new(0, -1, 0)
        end

        flyBodyVelocity.Velocity = (direction * FlySpeed) + (vertical * FlySpeed)
        flyBodyGyro.CFrame = camCF
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
    end
end)

-- // INFINITE JUMPS //
local InfiniteJumps = false
local lastJumpTime = 0
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumps and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and tick() - lastJumpTime > 0.1 then
            lastJumpTime = tick()
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- // ANTI-RAGDOLL //
local AntiRagdollEnabled = false
RunService.Heartbeat:Connect(function()
    if AntiRagdollEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local state = humanoid:GetState()
            if state == Enum.HumanoidStateType.Physics 
               or state == Enum.HumanoidStateType.FallingDown 
               or state == Enum.HumanoidStateType.PlatformStanding then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local rot = hrp.CFrame - hrp.Position
            local _, y, _ = rot:ToEulerAnglesYXZ()
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, y, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- // ANTI-FLING //
local AntiFlingEnabled = false
RunService.Heartbeat:Connect(function()
    if AntiFlingEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            if vel.Magnitude > 150 then
                hrp.AssemblyLinearVelocity = vel.Unit * 50
            end
        end
    end
end)

-- // TP TO PLAYER //
local selectedPlayer = nil

local function GetHRP(plr)
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        return plr.Character.HumanoidRootPart
    end
end

-- // AUTO COMBO UTILS //
local function SimulateKey(keyCode)
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.03)
        vim:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function SimulateM1()
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.03)
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
end


-- ============================== //
-- // ВКЛАДКА: MAIN //
-- ============================== //
Section(TabMain, "Movement")

Toggle(TabMain, "Fly", false, function(v)
    FlyEnabled = v
end)
Slider(TabMain, "Fly Speed", 10, 300, 60, function(v)
    FlySpeed = v
end)
Toggle(TabMain, "Infinite Jumps", false, function(v)
    InfiniteJumps = v
end)

Section(TabMain, "Protection")
Toggle(TabMain, "Anti-Ragdoll", false, function(v)
    AntiRagdollEnabled = v
end)
Toggle(TabMain, "Anti-Fling", false, function(v)
    AntiFlingEnabled = v
end)

Section(TabMain, "Teleport")

local playerDropdown
playerDropdown = Dropdown(TabMain, "Select Player", {"..."}, "...", function(v)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == v then selectedPlayer = p; break end
    end
end)

local function refreshPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    if #list == 0 then list = {"(нет игроков)"} end
    playerDropdown.Rebuild(list)
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(p)
    if selectedPlayer == p then selectedPlayer = nil end
    refreshPlayerList()
end)
task.spawn(function()
    task.wait(1)
    refreshPlayerList()
end)

Button(TabMain, "TP to Selected Player", function()
    if selectedPlayer then
        local myHRP = GetHRP(LocalPlayer)
        local targetHRP = GetHRP(selectedPlayer)
        if myHRP and targetHRP then
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)


-- ============================== //
-- // ВКЛАДКА: COMBAT //
-- ============================== //
Section(TabCombat, "Auto Actions")
Toggle(TabCombat, "Auto Attack",   false, function(v) end)
Toggle(TabCombat, "Auto Block",    false, function(v) end)
Toggle(TabCombat, "Auto Counter",  false, function(v) end)

Section(TabCombat, "Yuji Combo")

local AutoComboEnabled = false
local ComboDelay = 100
local ComboVariant = "Variant 1 (Safe)"

Toggle(TabCombat, "Auto Combo (Yuji)", false, function(v)
    AutoComboEnabled = v
end)
Slider(TabCombat, "Combo Delay (ms)", 1, 500, 100, function(v)
    ComboDelay = v
end)
Dropdown(TabCombat, "Combo Variant", {"Variant 1 (Safe)", "Variant 2 (Black Flash)", "Variant 3 (Full)"}, "Variant 1 (Safe)", function(v)
    ComboVariant = v
end)

-- Логика Auto Combo с тремя вариантами
task.spawn(function()
    while task.wait(0.05) do
        if not AutoComboEnabled then continue end
        if not LocalPlayer.Character then continue end
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local variant = tonumber(ComboVariant:match("Variant%s+(%d+)")) or 1

        if variant == 1 then
            for i = 1, 3 do
                SimulateM1()
                task.wait(ComboDelay / 1000)
            end
            SimulateKey(Enum.KeyCode.Three)
            task.wait(ComboDelay / 1000)
            SimulateKey(Enum.KeyCode.Q)
            task.wait(ComboDelay / 1000)
            for i = 1, 3 do
                SimulateM1()
                task.wait(ComboDelay / 1000)
            end
        elseif variant == 2 then
            for i = 1, 3 do
                SimulateM1()
                task.wait(ComboDelay / 1000)
            end
            SimulateKey(Enum.KeyCode.Two)
            task.wait(ComboDelay / 1000)
            for i = 1, 3 do
                SimulateM1()
                task.wait(ComboDelay / 1000)
            end
            SimulateKey(Enum.KeyCode.Three)
            task.wait(ComboDelay / 1000)
            SimulateKey(Enum.KeyCode.R)
            task.wait(ComboDelay / 1000)
        elseif variant == 3 then
            for i = 1, 3 do
                SimulateM1()
                task.wait(ComboDelay / 1000)
            end
            SimulateKey(Enum.KeyCode.Two)
            task.wait(ComboDelay / 1000)
            for i = 1, 3 do
                SimulateM1()
                task.wait(ComboDelay / 1000)
            end
            SimulateKey(Enum.KeyCode.One)
            task.wait(ComboDelay / 1000)
            SimulateKey(Enum.KeyCode.Three)
            task.wait(ComboDelay / 1000)
            SimulateKey(Enum.KeyCode.R)
            task.wait(ComboDelay / 1000)
        end

        task.wait(0.5)
    end
end)

Section(TabCombat, "Black Flash")
Toggle(TabCombat, "Auto Black Flash", false, function(v) end)

Section(TabCombat, "Aura")
Toggle(TabCombat, "Aura Attack", false, function(v) end)


-- ============================== //
-- // ВКЛАДКА: SCRIPT //
-- ============================== //
Section(TabScript, "Skills")
Toggle(TabScript, "No Cooldown Skills", false, function(v) end)
Toggle(TabScript, "Instant M1 Attack",  false, function(v) end)
Toggle(TabScript, "No Cooldown Dash",   false, function(v) end)

Section(TabScript, "Awakening & Domain")
Toggle(TabScript, "Infinite Awakening",       false, function(v) end)
Toggle(TabScript, "Infinite Domain Duration", false, function(v) end)
Toggle(TabScript, "Instant Domain Expansion", false, function(v) end)

Section(TabScript, "Combat Tweaks")
Toggle(TabScript, "No Knockback M1", false, function(v) end)


-- ============================== //
-- // VISUALS / SETTINGS / CFG — пустые //
-- ============================== //


-- // УВЕДОМЛЕНИЕ //
StarterGui:SetCore("SendNotification", {
    Title = "Mercedes Menu",
    Text = "Скрипт v1.2 загружен.",
    Duration = 3
})
