
-- ==========================================================
--  💎 GUI — MODERN (графит + индиго/циан, плавные fade)
-- ==========================================================
print("[APEX] Создание Modern GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexModern"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function Gradient(parent, c1, c2, rot)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2),
    })
    if rot then g.Rotation = rot end
    return g
end

-- ===== УВЕДОМЛЕНИЯ =====
local NotifyCount = 0
local function Notify(text, color)
    task.spawn(function()
        NotifyCount = NotifyCount + 1
        local n = Instance.new("Frame")
        n.Size = UDim2.new(0, 250, 0, 44)
        n.Position = UDim2.new(1, 30, 1, -66 - (NotifyCount - 1) * 54)
        n.BackgroundColor3 = T.Panel
        n.BorderSizePixel = 0
        n.Parent = ScreenGui
        Instance.new("UICorner", n).CornerRadius = UDim.new(0, 12)
        local st = Instance.new("UIStroke", n)
        st.Color = color or T.Accent; st.Thickness = 1.5; st.Transparency = 0.4
        local bar = Instance.new("Frame", n)
        bar.Size = UDim2.new(0, 3, 0, 26); bar.Position = UDim2.new(0, 10, 0.5, -13)
        bar.BackgroundColor3 = color or T.Accent; bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        Gradient(bar, color or T.Accent, T.Accent2)
        local lb = Instance.new("TextLabel", n)
        lb.Size = UDim2.new(1, -32, 1, 0); lb.Position = UDim2.new(0, 22, 0, 0)
        lb.BackgroundTransparency = 1; lb.Text = text
        lb.TextColor3 = T.Text; lb.Font = Enum.Font.GothamSemibold; lb.TextSize = 12
        lb.TextXAlignment = Enum.TextXAlignment.Left
        TweenService:Create(n, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -16, 1, -66 - (NotifyCount - 1) * 54)
        }):Play()
        task.wait(2.6)
        TweenService:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 30, 1, -66 - (NotifyCount - 1) * 54)
        }):Play()
        task.wait(0.28)
        NotifyCount = NotifyCount - 1
        n:Destroy()
    end)
end

-- ===== ПЛАВАЮЩАЯ КНОПКА =====
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 56, 0, 56)
FloatBtn.Position = UDim2.new(0, 16, 0.5, -28)
FloatBtn.BackgroundColor3 = T.BG
FloatBtn.Text = "◆"
FloatBtn.TextColor3 = T.Text
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.TextSize = 22
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.AutoButtonColor = false
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local btnStroke = Instance.new("UIStroke", FloatBtn)
btnStroke.Thickness = 2; btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Gradient(btnStroke, T.Accent, T.Accent2)

task.spawn(function()
    local g = btnStroke:FindFirstChildOfClass("UIGradient")
    local rot = 0
    while FloatBtn.Parent do
        rot = (rot + 1.5) % 360
        g.Rotation = rot
        task.wait(0.03)
    end
end)

FloatBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 62, 0, 62)}):Play()
end)
FloatBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 56, 0, 56)}):Play()
end)

-- ===== ГЛАВНОЕ ОКНО (CanvasGroup = плавный fade всего) =====
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, 620, 0, 420)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
MainFrame.BackgroundColor3 = T.BG
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.GroupTransparency = 1
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = T.Stroke; mainStroke.Thickness = 1

-- Шапка
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = T.Panel
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)
local headerFix = Instance.new("Frame", Header)
headerFix.Size = UDim2.new(1, 0, 0, 16); headerFix.Position = UDim2.new(0, 0, 1, -16)
headerFix.BackgroundColor3 = T.Panel; headerFix.BorderSizePixel = 0

local LogoBg = Instance.new("Frame", Header)
LogoBg.Size = UDim2.new(0, 34, 0, 34); LogoBg.Position = UDim2.new(0, 14, 0.5, -17)
LogoBg.BackgroundColor3 = T.Accent; LogoBg.BorderSizePixel = 0
Instance.new("UICorner", LogoBg).CornerRadius = UDim.new(0, 10)
Gradient(LogoBg, T.Accent, T.Accent2, 35)
local logo = Instance.new("TextLabel", LogoBg)
logo.Size = UDim2.new(1, 0, 1, 0); logo.BackgroundTransparency = 1
logo.Text = "◆"; logo.TextColor3 = T.Text
logo.Font = Enum.Font.GothamBlack; logo.TextSize = 16

local titleLb = Instance.new("TextLabel", Header)
titleLb.Size = UDim2.new(1, -160, 0, 20); titleLb.Position = UDim2.new(0, 58, 0, 9)
titleLb.BackgroundTransparency = 1; titleLb.Text = "APEX HUB"
titleLb.Font = Enum.Font.GothamBold; titleLb.TextSize = 15
titleLb.TextXAlignment = Enum.TextXAlignment.Left; titleLb.TextColor3 = T.Text
Gradient(titleLb, T.Text, T.Accent2, 0)

local subLb = Instance.new("TextLabel", Header)
subLb.Size = UDim2.new(1, -160, 0, 13); subLb.Position = UDim2.new(0, 58, 0, 29)
subLb.BackgroundTransparency = 1; subLb.Text = "JUJUTSU SHENANIGANS  •  v12 MODERN"
subLb.Font = Enum.Font.Gotham; subLb.TextSize = 9
subLb.TextXAlignment = Enum.TextXAlignment.Left; subLb.TextColor3 = T.Mute

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 32, 0, 32); CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
CloseBtn.BackgroundColor3 = T.Panel2; CloseBtn.Text = "✕"
CloseBtn.TextColor3 = T.Mute; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 9)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Bad, TextColor3 = T.Text}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel2, TextColor3 = T.Mute}):Play()
end)

-- ===== САЙДБАР =====
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 128, 1, -68); Sidebar.Position = UDim2.new(0, 14, 0, 60)
Sidebar.BackgroundTransparency = 1

local tabIndicator = Instance.new("Frame", Sidebar)
tabIndicator.Size = UDim2.new(0, 3, 0, 22); tabIndicator.Position = UDim2.new(0, 0, 0, 10)
tabIndicator.BackgroundColor3 = T.Accent; tabIndicator.BorderSizePixel = 0
Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(1, 0)
Gradient(tabIndicator, T.Accent, T.Accent2, 90)

local Tabs = {}
local PageWraps = {}
local ScrollPages = {}
local tabNames = { "Aimbot", "Fling", "Visuals", "ESP", "Misc" }
local tabIcons = { "⊕", "◎", "✦", "◉", "⚙" }

for i, name in ipairs(tabNames) do
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -8, 0, 42)
    TabBtn.Position = UDim2.new(0, 8, 0, (i - 1) * 48)
    TabBtn.BackgroundColor3 = T.Panel
    TabBtn.Text = "   " .. tabIcons[i] .. "  " .. name
    TabBtn.TextColor3 = T.Mute
    TabBtn.Font = Enum.Font.GothamSemibold; TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.AutoButtonColor = false
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
    Tabs[name] = TabBtn

    -- Обёртка для плавного fade
    local Wrap = Instance.new("CanvasGroup", MainFrame)
    Wrap.Size = UDim2.new(1, -162, 1, -68)
    Wrap.Position = UDim2.new(0, 152, 0, 60)
    Wrap.BackgroundTransparency = 1
    Wrap.BorderSizePixel = 0
    Wrap.GroupTransparency = 1
    Wrap.Visible = false

    local Page = Instance.new("ScrollingFrame", Wrap)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1; Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3; Page.ScrollBarImageColor3 = T.Accent
    Page.CanvasSize = UDim2.new(0, 0, 0, 900)
    PageScrollPadding(Page)

    PageWraps[name] = Wrap
    ScrollPages[name] = Page

    TabBtn.MouseEnter:Connect(function()
        if not Wrap.Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel2, TextColor3 = T.Text}):Play()
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Wrap.Visible then
            TweenService:Create(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel, TextColor3 = T.Mute}):Play()
        end
    end)
end

-- ===== ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК =====
local ActiveTab = nil
local function SwitchTab(name)
    local idx = 1
    for i, n in ipairs(tabNames) do if n == name then idx = i end end
    for n, wrap in pairs(PageWraps) do
        if n == name then
            wrap.Visible = true
            wrap.GroupTransparency = 1
            TweenService:Create(wrap, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                GroupTransparency = 0
            }):Play()
        else
            wrap.Visible = false
        end
    end
    for n, btn in pairs(Tabs) do
        if n == name then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = T.Panel2, TextColor3 = T.Text}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = T.Panel, TextColor3 = T.Mute}):Play()
        end
    end
    TweenService:Create(tabIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, (idx - 1) * 48 + 10)
    }):Play()
    ActiveTab = name
end

for name, btn in pairs(Tabs) do
    btn.MouseButton1Click:Connect(function()
        if ActiveTab ~= name then SwitchTab(name) end
    end)
end

-- ===== ОТКРЫТИЕ / ЗАКРЫТИЕ =====
local MenuOpen = false
local FULL_SIZE = UDim2.new(0, 620, 0, 420)

local function ToggleMenu()
    if MenuOpen then
        MenuOpen = false
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 560, 0, 360), GroupTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function()
            MainFrame.Visible = false
            MainFrame.Size = FULL_SIZE
        end)
    else
        MenuOpen = true
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 560, 0, 360)
        MainFrame.GroupTransparency = 1
        TweenService:Create(MainFrame, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = FULL_SIZE, GroupTransparency = 0
        }):Play()
    end
end
CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then ToggleMenu() end
end)

-- ==========================================================
--  УТИЛИТЫ КОНТРОЛОВ
-- ==========================================================
local function Section(parent, text, y)
    local L = Instance.new("TextLabel", parent)
    L.Size = UDim2.new(1, -10, 0, 20); L.Position = UDim2.new(0, 4, 0, y)
    L.BackgroundTransparency = 1; L.Text = string.upper(text)
    L.TextColor3 = T.Mute; L.Font = Enum.Font.GothamBold; L.TextSize = 10
    L.TextXAlignment = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", parent)
    line.Size = UDim2.new(1, -10, 0, 1); line.Position = UDim2.new(0, 4, 0, y + 24)
    line.BackgroundColor3 = T.Stroke; line.BorderSizePixel = 0
    return y + 32
end

local function Toggle(parent, text, y, default, cb)
    local Box = Instance.new("Frame", parent)
    Box.Size = UDim2.new(1, -4, 0, 42); Box.Position = UDim2.new(0, 2, 0, y)
    Box.BackgroundColor3 = T.Panel; Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel", Box)
    L.Size = UDim2.new(1, -70, 1, 0); L.Position = UDim2.new(0, 14, 0, 0)
    L.BackgroundTransparency = 1; L.Text = text; L.TextColor3 = T.Text
    L.Font = Enum.Font.GothamSemibold; L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    local Pill = Instance.new("Frame", Box)
    Pill.Size = UDim2.new(0, 42, 0, 22); Pill.Position = UDim2.new(1, -54, 0.5, -11)
    Pill.BackgroundColor3 = default and T.Accent or Color3.fromRGB(42, 47, 62)
    Pill.BorderSizePixel = 0
    Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)
    local Knob = Instance.new("Frame", Pill)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = default and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
    Knob.BackgroundColor3 = T.Text; Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local state = default
    Box.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            state = not state
            if state then
                TweenService:Create(Pill, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = T.Accent}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -19, 0, 3)}):Play()
            else
                TweenService:Create(Pill, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(42, 47, 62)}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 3, 0, 3)}):Play()
            end
            pcall(cb, state)
        end
    end)
end

local function Slider(parent, text, y, min, max, def, isFloat, cb)
    local Box = Instance.new("Frame", parent)
    Box.Size = UDim2.new(1, -4, 0, 52); Box.Position = UDim2.new(0, 2, 0, y)
    Box.BackgroundColor3 = T.Panel; Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel", Box)
    L.Size = UDim2.new(1, -24, 0, 16); L.Position = UDim2.new(0, 14, 0, 8)
    L.BackgroundTransparency = 1; L.Text = text
    L.TextColor3 = T.Text; L.Font = Enum.Font.GothamSemibold; L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    local Val = Instance.new("TextLabel", Box)
    Val.Size = UDim2.new(0, 60, 0, 16); Val.Position = UDim2.new(1, -70, 0, 8)
    Val.BackgroundTransparency = 1
    Val.Text = isFloat and string.format("%.2f", def) or tostring(def)
    Val.TextColor3 = T.Accent2; Val.Font = Enum.Font.GothamBold; Val.TextSize = 12
    Val.TextXAlignment = Enum.TextXAlignment.Right
    local Track = Instance.new("Frame", Box)
    Track.Size = UDim2.new(1, -28, 0, 5); Track.Position = UDim2.new(0, 14, 0, 34)
    Track.BackgroundColor3 = Color3.fromRGB(38, 43, 58); Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    Gradient(Fill, T.Accent, T.Accent2)
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new((def - min) / (max - min), -7, 0.5, -7)
    Knob.BackgroundColor3 = T.Text; Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", Knob); ks.Color = T.Accent; ks.Thickness = 2
    local function Update(x)
        local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        if not isFloat then val = math.floor(val + 0.5) end
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, -7, 0.5, -7)
        Val.Text = isFloat and string.format("%.2f", val) or tostring(val)
        pcall(cb, val)
    end
    local drag = false
    Track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; Update(i.Position.X)
        end
    end)
    Track.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            Update(i.Position.X)
        end
    end)
    Track.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

local function Selector(parent, text, y, options, def, cb)
    local Box = Instance.new("Frame", parent)
    Box.Size = UDim2.new(1, -4, 0, 46); Box.Position = UDim2.new(0, 2, 0, y)
    Box.BackgroundColor3 = T.Panel; Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel", Box)
    L.Size = UDim2.new(0.42, -12, 1, 0); L.Position = UDim2.new(0, 14, 0, 0)
    L.BackgroundTransparency = 1; L.Text = text; L.TextColor3 = T.Mute
    L.Font = Enum.Font.GothamSemibold; L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    local current = def
    local Btn = Instance.new("TextButton", Box)
    Btn.Size = UDim2.new(0.52, -14, 0, 30); Btn.Position = UDim2.new(0.46, 0, 0.5, -15)
    Btn.BackgroundColor3 = T.Panel2; Btn.Text = "▸  " .. current
    Btn.TextColor3 = T.Text; Btn.Font = Enum.Font.GothamSemibold; Btn.TextSize = 12
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(34, 39, 54)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel2}):Play()
    end)
    Btn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, v in ipairs(options) do if v == current then idx = i break end end
        idx = idx + 1
        if idx > #options then idx = 1 end
        current = options[idx]
        Btn.Text = "▸  " .. current
        pcall(cb, current)
    end)
end

local function ActionBtn(parent, text, y, color, cb)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1, -4, 0, 42); B.Position = UDim2.new(0, 2, 0, y)
    B.BackgroundColor3 = color or T.Panel2; B.Text = text
    B.TextColor3 = T.Text; B.Font = Enum.Font.GothamBold; B.TextSize = 12
    B.AutoButtonColor = false
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", B); st.Color = T.Stroke; st.Thickness = 1
    B.MouseEnter:Connect(function()
        TweenService:Create(st, TweenInfo.new(0.15), {Color = T.Accent, Thickness = 1.5}):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(st, TweenInfo.new(0.15), {Color = T.Stroke, Thickness = 1}):Play()
    end)
    B.MouseButton1Click:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.06), {Size = UDim2.new(1, -10, 0, 40)}):Play()
        task.wait(0.06)
        TweenService:Create(B, TweenInfo.new(0.14, Enum.EasingStyle.Back), {Size = UDim2.new(1, -4, 0, 42)}):Play()
        pcall(
        
-- ===== ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК =====
local ActiveTab = nil
local function SwitchTab(name)
    local idx = 1
    for i, n in ipairs(tabNames) do if n == name then idx = i end end
    for n, wrap in pairs(PageWraps) do
        if n == name then
            wrap.Visible = true
            wrap.GroupTransparency = 1
            TweenService:Create(wrap, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                GroupTransparency = 0
            }):Play()
        else
            wrap.Visible = false
        end
    end
    for n, btn in pairs(Tabs) do
        if n == name then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = T.Panel2, TextColor3 = T.Text}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = T.Panel, TextColor3 = T.Mute}):Play()
        end
    end
    TweenService:Create(tabIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, (idx - 1) * 48 + 10)
    }):Play()
    ActiveTab = name
end

for name, btn in pairs(Tabs) do
    btn.MouseButton1Click:Connect(function()
        if ActiveTab ~= name then SwitchTab(name) end
    end)
end

-- ===== ОТКРЫТИЕ / ЗАКРЫТИЕ =====
local MenuOpen = false
local FULL_SIZE = UDim2.new(0, 620, 0, 420)

local function ToggleMenu()
    if MenuOpen then
        MenuOpen = false
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 560, 0, 360), GroupTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function()
            MainFrame.Visible = false
            MainFrame.Size = FULL_SIZE
        end)
    else
        MenuOpen = true
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 560, 0, 360)
        MainFrame.GroupTransparency = 1
        TweenService:Create(MainFrame, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = FULL_SIZE, GroupTransparency = 0
        }):Play()
    end
end
CloseBtn.MouseButton1Click:Connect(ToggleMenu)
FloatBtn.MouseButton1Click:Connect(ToggleMenu)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then ToggleMenu() end
end)

-- ==========================================================
--  УТИЛИТЫ КОНТРОЛОВ
-- ==========================================================
local function Section(parent, text, y)
    local L = Instance.new("TextLabel", parent)
    L.Size = UDim2.new(1, -10, 0, 20); L.Position = UDim2.new(0, 4, 0, y)
    L.BackgroundTransparency = 1; L.Text = string.upper(text)
    L.TextColor3 = T.Mute; L.Font = Enum.Font.GothamBold; L.TextSize = 10
    L.TextXAlignment = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", parent)
    line.Size = UDim2.new(1, -10, 0, 1); line.Position = UDim2.new(0, 4, 0, y + 24)
    line.BackgroundColor3 = T.Stroke; line.BorderSizePixel = 0
    return y + 32
end

local function Toggle(parent, text, y, default, cb)
    local Box = Instance.new("Frame", parent)
    Box.Size = UDim2.new(1, -4, 0, 42); Box.Position = UDim2.new(0, 2, 0, y)
    Box.BackgroundColor3 = T.Panel; Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel", Box)
    L.Size = UDim2.new(1, -70, 1, 0); L.Position = UDim2.new(0, 14, 0, 0)
    L.BackgroundTransparency = 1; L.Text = text; L.TextColor3 = T.Text
    L.Font = Enum.Font.GothamSemibold; L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    local Pill = Instance.new("Frame", Box)
    Pill.Size = UDim2.new(0, 42, 0, 22); Pill.Position = UDim2.new(1, -54, 0.5, -11)
    Pill.BackgroundColor3 = default and T.Accent or Color3.fromRGB(42, 47, 62)
    Pill.BorderSizePixel = 0
    Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)
    local Knob = Instance.new("Frame", Pill)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = default and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
    Knob.BackgroundColor3 = T.Text; Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local state = default
    Box.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            state = not state
            if state then
                TweenService:Create(Pill, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = T.Accent}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -19, 0, 3)}):Play()
            else
                TweenService:Create(Pill, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(42, 47, 62)}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 3, 0, 3)}):Play()
            end
            pcall(cb, state)
        end
    end)
end

local function Slider(parent, text, y, min, max, def, isFloat, cb)
    local Box = Instance.new("Frame", parent)
    Box.Size = UDim2.new(1, -4, 0, 52); Box.Position = UDim2.new(0, 2, 0, y)
    Box.BackgroundColor3 = T.Panel; Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel", Box)
    L.Size = UDim2.new(1, -24, 0, 16); L.Position = UDim2.new(0, 14, 0, 8)
    L.BackgroundTransparency = 1; L.Text = text
    L.TextColor3 = T.Text; L.Font = Enum.Font.GothamSemibold; L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    local Val = Instance.new("TextLabel", Box)
    Val.Size = UDim2.new(0, 60, 0, 16); Val.Position = UDim2.new(1, -70, 0, 8)
    Val.BackgroundTransparency = 1
    Val.Text = isFloat and string.format("%.2f", def) or tostring(def)
    Val.TextColor3 = T.Accent2; Val.Font = Enum.Font.GothamBold; Val.TextSize = 12
    Val.TextXAlignment = Enum.TextXAlignment.Right
    local Track = Instance.new("Frame", Box)
    Track.Size = UDim2.new(1, -28, 0, 5); Track.Position = UDim2.new(0, 14, 0, 34)
    Track.BackgroundColor3 = Color3.fromRGB(38, 43, 58); Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    Gradient(Fill, T.Accent, T.Accent2)
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new((def - min) / (max - min), -7, 0.5, -7)
    Knob.BackgroundColor3 = T.Text; Knob.BorderSizePixel = 0
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local ks = Instance.new("UIStroke", Knob); ks.Color = T.Accent; ks.Thickness = 2
    local function Update(x)
        local rel = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        if not isFloat then val = math.floor(val + 0.5) end
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, -7, 0.5, -7)
        Val.Text = isFloat and string.format("%.2f", val) or tostring(val)
        pcall(cb, val)
    end
    local drag = false
    Track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; Update(i.Position.X)
        end
    end)
    Track.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            Update(i.Position.X)
        end
    end)
    Track.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

local function Selector(parent, text, y, options, def, cb)
    local Box = Instance.new("Frame", parent)
    Box.Size = UDim2.new(1, -4, 0, 46); Box.Position = UDim2.new(0, 2, 0, y)
    Box.BackgroundColor3 = T.Panel; Box.BorderSizePixel = 0
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel", Box)
    L.Size = UDim2.new(0.42, -12, 1, 0); L.Position = UDim2.new(0, 14, 0, 0)
    L.BackgroundTransparency = 1; L.Text = text; L.TextColor3 = T.Mute
    L.Font = Enum.Font.GothamSemibold; L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    local current = def
    local Btn = Instance.new("TextButton", Box)
    Btn.Size = UDim2.new(0.52, -14, 0, 30); Btn.Position = UDim2.new(0.46, 0, 0.5, -15)
    Btn.BackgroundColor3 = T.Panel2; Btn.Text = "▸  " .. current
    Btn.TextColor3 = T.Text; Btn.Font = Enum.Font.GothamSemibold; Btn.TextSize = 12
    Btn.AutoButtonColor = false
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(34, 39, 54)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = T.Panel2}):Play()
    end)
    Btn.MouseButton1Click:Connect(function()
        local idx = 1
        for i, v in ipairs(options) do if v == current then idx = i break end end
        idx = idx + 1
        if idx > #options then idx = 1 end
        current = options[idx]
        Btn.Text = "▸  " .. current
        pcall(cb, current)
    end)
end

local function ActionBtn(parent, text, y, color, cb)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1, -4, 0, 42); B.Position = UDim2.new(0, 2, 0, y)
    B.BackgroundColor3 = color or T.Panel2; B.Text = text
    B.TextColor3 = T.Text; B.Font = Enum.Font.GothamBold; B.TextSize = 12
    B.AutoButtonColor = false
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", B); st.Color = T.Stroke; st.Thickness = 1
    B.MouseEnter:Connect(function()
        TweenService:Create(st, TweenInfo.new(0.15), {Color = T.Accent, Thickness = 1.5}):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(st, TweenInfo.new(0.15), {Color = T.Stroke, Thickness = 1}):Play()
    end)
    B.MouseButton1Click:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.06), {Size = UDim2.new(1, -10, 0, 40)}):Play()
        task.wait(0.06)
        TweenService:Create(B, TweenInfo.new(0.14, Enum.EasingStyle.Back), {Size = UDim2.new(1, -4, 0, 42)}):Play()
        pcall(cb, B)
    end)
    return B
end

-- ==========================================================
--  СТРАНИЦЫ
-- ==========================================================

-- AIMBOT
do
    local p = ScrollPages["Aimbot"]
    local y = 0
    y = Section(p, "Прицеливание", y)
    Toggle(p, "Aimbot", y, false, function(v) Config.AimbotEnabled = v end); y = y + 48
    Toggle(p, "WallCheck", y, true, function(v) Config.WallCheck = v end); y = y + 48
    Toggle(p, "Поворот персонажа", y, true, function(v) Config.RotateCharacter = v end); y = y + 48
    Toggle(p, "Показать FOV круг", y, true, function(v) Config.ShowFOV = v end); y = y + 52
    Slider(p, "FOV", y, 50, 1000, Config.FOV, false, function(v) Config.FOV = v end); y = y + 58
    Slider(p, "Плавность", y, 0.01, 1.0, Config.Smoothness, true, function(v) Config.Smoothness = v end); y = y + 58
    Selector(p, "Режим цели", y, {"FOV", "LowestHP", "HighestHP", "Distance"}, Config.TargetMode, function(v) Config.TargetMode = v end); y = y + 54
    Selector(p, "Часть тела", y, {"Head", "HumanoidRootPart", "UpperTorso"}, Config.TargetPart, function(v) Config.TargetPart = v end); y = y + 54
    p.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- FLING
local selectedFlingTarget = nil
do
    local p = ScrollPages["Fling"]
    local y = 0
    y = Section(p, "Цель", y)
    local ListFrame = Instance.new("ScrollingFrame", p)
    ListFrame.Size = UDim2.new(1, -4, 0, 180); ListFrame.Position = UDim2.new(0, 2, 0, y)
    ListFrame.BackgroundColor3 = T.Panel; ListFrame.BorderSizePixel = 0
    ListFrame.ScrollBarThickness = 3; ListFrame.ScrollBarImageColor3 = T.Accent
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 10)
    local ListLayout = Instance.new("UIListLayout", ListFrame)
    ListLayout.Padding = UDim.new(0, 5)
    local pad = Instance.new("UIPadding", ListFrame)
    pad.PaddingTop = UDim.new(0, 7); pad.PaddingBottom = UDim.new(0, 7)
    pad.PaddingLeft = UDim.new(0, 7); pad.PaddingRight = UDim.new(0, 7)

    local function RefreshPlayerList()
        for _, c in ipairs(ListFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local PB = Instance.new("TextButton", ListFrame)
                PB.Size = UDim2.new(1, 0, 0, 34)
                PB.BackgroundColor3 = T.Panel2; PB.Text = "  ⊕  " .. pl.Name
                PB.TextColor3 = T.Text; PB.Font = Enum.Font.GothamSemibold; PB.TextSize = 12
                PB.TextXAlignment = Enum.TextXAlignment.Left
                PB.AutoButtonColor = false
                Instance.new("UICorner", PB).CornerRadius = UDim.new(0, 8)
                PB.MouseEnter:Connect(function()
                    if selectedFlingTarget ~= pl then
                        TweenService:Create(PB, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(34, 39, 54)}):Play()
                    end
                end)
                PB.MouseLeave:Connect(function()
                    if selectedFlingTarget ~= pl then
                        TweenService:Create(PB, TweenInfo.new(0.12), {BackgroundColor3 = T.Panel2}):Play()
                    end
                end)
                PB.MouseButton1Click:Connect(function()
                    selectedFlingTarget = pl
                    for _, b in ipairs(ListFrame:GetChildren()) do
                        if b:IsA("TextButton") then
                            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = T.Panel2}):Play()
                        end
                    end
                    TweenService:Create(PB, TweenInfo.new(0.12), {BackgroundColor3 = T.Accent}):Play()
                    Notify("Цель: " .. pl.Name, T.Accent)
                end)
            end
        end
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 16)
    end
    RefreshPlayerList()
    Players.PlayerAdded:Connect(function() task.wait(1) RefreshPlayerList() end)
    Players.PlayerRemoving:Connect(function() task.wait(1) RefreshPlayerList() end)
    y = y + 192

    ActionBtn(p, "◎   ЗАПУСТИТЬ В КОСМОС", y, Color3.fromRGB(88, 28, 46), function()
        if FlingActive then Notify("Флинг уже выполняется!", T.Bad) return end
        if selectedFlingTarget and selectedFlingTarget.Parent then
            local ok = pcall(function() FlingPlayer(selectedFlingTarget) end)
            Notify(ok and "Цель в космосе!" or "Ошибка флинга", ok and T.Ok or T.Bad)
        else
            Notify("Сначала выбери игрока!", T.Bad)
        end
    end); y = y + 52
    ActionBtn(p, "↻   Обновить список", y, T.Panel2, function()
        RefreshPlayerList()
        Notify("Список обновлён", T.Accent)
    end); y = y + 52
    p.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- VISUALS
do
    local p = ScrollPages["Visuals"]
    local y = 0
    y = Section(p, "Аура и крылья", y)
    Toggle(p, "Аура проклятой энергии", y, true, function(v) Config.AuraEnabled = v end); y = y + 48
    Toggle(p, "Крылья тьмы", y, true, function(v) Config.WingsEnabled = v end); y = y + 48
    Toggle(p, "Радужный режим", y, false, function(v) Config.RainbowAura = v end); y = y + 52
    Slider(p, "Размер ауры", y, 2, 15, Config.AuraSize, false, function(v) Config.AuraSize = v end); y = y + 58
    Slider(p, "Частицы ауры", y, 0, 100, Config.AuraRate, false, function(v)
        Config.AuraRate = v
        if AuraParticles then AuraParticles.Rate = v end
    end); y = y + 58
    Slider(p, "Прозрачность крыльев", y, 0, 1.0, Config.WingsTransparency, true, function(v) Config.WingsTransparency = v end); y = y + 60

    y = Section(p, "Цвет ауры (RGB)", y)
    Slider(p, "R", y, 0, 255, math.floor(Config.AuraColor.R * 255), false, function(v)
        Config.AuraColor = Color3.fromRGB(v, Config.AuraColor.G * 255, Config.AuraColor.B * 255)
    end); y = y + 58
    Slider(p, "G", y, 0, 255, math.floor(Config.AuraColor.G * 255), false, function(v)
        Config.AuraColor = Color3.fromRGB(Config.AuraColor.R * 255, v, Config.AuraColor.B * 255)
    end); y = y + 58
    Slider(p, "B", y, 0, 255, math.floor(Config.AuraColor.B * 255), false, function(v)
        Config.AuraColor = Color3.fromRGB(Config.AuraColor.R * 255, Config.AuraColor.G * 255, v)
    end); y = y + 60

    y = Section(p, "Цвет крыльев (RGB)", y)
    Slider(p, "R", y, 0, 255, math.floor(Config.WingsColor.R * 255), false, function(v)
        Config.WingsColor = Color3.fromRGB(v, Config.WingsColor.G * 255, Config.WingsColor.B * 255)
    end); y = y + 58
    Slider(p, "G", y, 0, 255, math.floor(Config.WingsColor.G * 255), false, function(v)
        Config.WingsColor = Color3.fromRGB(Config.WingsColor.R * 255, v, Config.WingsColor.B * 255)
    end); y = y + 58
    Slider(p, "B", y, 0, 255, math.floor(Config.WingsColor.B * 255), false, function(v)
        Config.WingsColor = Color3.fromRGB(Config.WingsColor.R * 255, Config.WingsColor.G * 255, v)
    end); y = y + 56
    p.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- ESP
do
    local p = ScrollPages["ESP"]
    local y = 0
    y = Section(p, "Подсветка", y)
    Toggle(p, "ESP игроков", y, false, function(v) Config.EspPlayers = v end); y = y + 48
    Toggle(p, "ESP charms", y, false, function(v) Config.EspCharms = v end); y = y + 48
    Toggle(p, "Tracers (линии)", y, true, function(v) Config.ShowTracers = v end); y = y + 48
    p.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- MISC
do
    local p = ScrollPages["Misc"]
    local y = 0
    y = Section(p, "Специальное", y)
    Toggle(p, "Скрыть персонажа (только ты)", y, false, function(v)
        if v then InvisModule:Activate(); Notify("Скрыт локально", T.Ok)
        else InvisModule:Deactivate(); Notify("Персонаж виден", T.Bad) end
    end); y = y + 48
    Toggle(p, "No Cooldown", y, false, function(v) Config.NoCooldown = v end); y = y + 48
    Toggle(p, "Auto Block", y, false, function(v) Config.AutoBlock = v end); y = y + 52
    Slider(p, "Дистанция блока", y, 5, 50, Config.AutoBlockDistance, false, function(v) Config.AutoBlockDistance = v end); y = y + 56
    p.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- стартовая вкладка
SwitchTab("Aimbot")

-- ==========================================================
print("═══════════════════════════════════════")
print("  ◈ APEX HUB v12 MODERN ЗАГРУЖЕН! ◈")
print("  Меню: кнопка ◆  или  RightShift")
print("═══════════════════════════════════════")
Notify("APEX HUB v12 загружен!", T.Ok)
