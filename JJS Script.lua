--[[
    JJS BATTLEGROUND — CS:GO-style Cheat Menu (Delta / Mobile)
    Version: 2.0 (FFlag Invisibility)
    Tabs: MAIN only (по запросу)
--]]

--==== SERVICES ====--
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==== CLEANUP ====--
if _G.JJS_SCRIPT then
    pcall(function()
        if _G.JJS_SCRIPT.gui then _G.JJS_SCRIPT.gui:Destroy() end
        for _, c in ipairs(_G.JJS_SCRIPT.conns) do pcall(function() c:Disconnect() end) end
    end)
end

local S = {
    gui = nil, conns = {},
    fly = false, flySpeed = 60,
    invis = false, invisMode = 1,
}
_G.JJS_SCRIPT = S

--==== COLORS ====--
local C = {
    bg        = Color3.fromRGB(20,20,22),
    panel     = Color3.fromRGB(28,28,30),
    row       = Color3.fromRGB(32,32,35),
    section   = Color3.fromRGB(24,24,26),
    tabBar    = Color3.fromRGB(18,18,20),
    tabActive = Color3.fromRGB(45,45,48),
    stroke    = Color3.fromRGB(45,45,48),
    strokeDim = Color3.fromRGB(38,38,40),
    text      = Color3.fromRGB(210,210,215),
    textDim   = Color3.fromRGB(130,130,138),
    red       = Color3.fromRGB(210,45,45),
    toggleOn  = Color3.fromRGB(90,110,200),
    toggleOff = Color3.fromRGB(60,60,65),
    knob      = Color3.fromRGB(215,215,220),
    valueBox  = Color3.fromRGB(24,24,26),
    line      = Color3.fromRGB(55,55,58),
}

--==== HELPERS ====--
local function corner(p, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 2); c.Parent=p; return c end
local function stroke(p, col, th)
    local s=Instance.new("UIStroke"); s.Color=col or C.stroke; s.Thickness=th or 1
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s
end

--==== ROOT GUI ====--
local gui = Instance.new("ScreenGui")
gui.Name = "JJSMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")
S.gui = gui

-- Floating open button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,52,0,52)
ToggleBtn.Position = UDim2.new(0,16,0.4,0)
ToggleBtn.BackgroundColor3 = C.bg
ToggleBtn.Text = ""
ToggleBtn.AutoButtonColor = false
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = gui
corner(ToggleBtn, 4)
stroke(ToggleBtn, C.red, 1.5)

local TBLabel = Instance.new("TextLabel")
TBLabel.Size = UDim2.new(1,0,1,0)
TBLabel.BackgroundTransparency = 1
TBLabel.Text = "JJS"
TBLabel.TextColor3 = C.text
TBLabel.Font = Enum.Font.GothamBlack
TBLabel.TextSize = 15
TBLabel.Parent = ToggleBtn

local TBRed = Instance.new("Frame")
TBRed.Size = UDim2.new(0,8,0,3)
TBRed.Position = UDim2.new(0.5,-4,1,-6)
TBRed.BackgroundColor3 = C.red
TBRed.BorderSizePixel = 0
TBRed.Parent = ToggleBtn
corner(TBRed, 1)

-- Main window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,620,0,420)
Main.Position = UDim2.new(0.5,-310,0.5,-210)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = gui
corner(Main, 3)
stroke(Main, C.line, 1)

-- Tab bar (одна вкладка MAIN)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,34)
TabBar.BackgroundColor3 = C.tabBar
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
corner(TabBar, 3)
local TabBarFix = Instance.new("Frame")
TabBarFix.Size = UDim2.new(1,0,0,8)
TabBarFix.Position = UDim2.new(0,0,1,-8)
TabBarFix.BackgroundColor3 = C.tabBar
TabBarFix.BorderSizePixel = 0
TabBarFix.Parent = TabBar

local TabBarLine = Instance.new("Frame")
TabBarLine.Size = UDim2.new(1,0,0,1)
TabBarLine.Position = UDim2.new(0,0,1,-1)
TabBarLine.BackgroundColor3 = C.line
TabBarLine.BorderSizePixel = 0
TabBarLine.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0,4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

-- Кнопка MAIN (активная по умолчанию)
local MainTabBtn = Instance.new("TextButton")
MainTabBtn.Size = UDim2.new(0,70,0,26)
MainTabBtn.BackgroundColor3 = C.tabActive
MainTabBtn.Text = "MAIN"
MainTabBtn.TextColor3 = C.red
MainTabBtn.Font = Enum.Font.GothamBold
MainTabBtn.TextSize = 12
MainTabBtn.AutoButtonColor = false
MainTabBtn.LayoutOrder = 1
MainTabBtn.Parent = TabBar
corner(MainTabBtn, 2)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,26,0,22)
CloseBtn.Position = UDim2.new(1,-32,0,6)
CloseBtn.BackgroundColor3 = C.red
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TabBar
corner(CloseBtn, 2)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-12,1,-46)
Content.Position = UDim2.new(0,6,0,40)
Content.BackgroundColor3 = C.panel
Content.BorderSizePixel = 0
Content.Parent = Main
corner(Content, 3)

local function makeColumn(xScale, wScale)
    local col = Instance.new("Frame")
    col.Size = UDim2.new(wScale,-2,1,-8)
    col.Position = UDim2.new(xScale,2,0,4)
    col.BackgroundColor3 = C.panel
    col.BorderSizePixel = 0
    col.Parent = Content
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0,3)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = col
    return col
end

local Col1 = makeColumn(0,    0.30)
local Col2 = makeColumn(0.30, 0.35)
local Col3 = makeColumn(0.65, 0.35)

local function clearColumn(col)
    for _, ch in ipairs(col:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end
end
local function clearAll() clearColumn(Col1); clearColumn(Col2); clearColumn(Col3) end

--==== UI BUILDERS ====--
local globalOrder = 0
local function ord() globalOrder = globalOrder + 1; return globalOrder end

local function sectionHeader(col, title)
    local h = Instance.new("Frame")
    h.Size = UDim2.new(1,0,0,20)
    h.BackgroundColor3 = C.section
    h.BorderSizePixel = 0
    h.LayoutOrder = ord()
    h.Parent = col
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-10,1,0)
    l.Position = UDim2.new(0,8,0,0)
    l.BackgroundTransparency = 1
    l.Text = title
    l.TextColor3 = C.text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = h
end

local function toggleSwitch(parent, state, onChange)
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0,30,0,13)
    t.Position = UDim2.new(1,-38,0.5,-7)
    t.BackgroundColor3 = state and C.toggleOn or C.toggleOff
    t.Text = ""
    t.AutoButtonColor = false
    t.Parent = parent
    corner(t, 7)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,9,0,9)
    knob.Position = state and UDim2.new(1,-11,0.5,-4.5) or UDim2.new(0,2,0.5,-4.5)
    knob.BackgroundColor3 = C.knob
    knob.BorderSizePixel = 0
    knob.Parent = t
    corner(knob, 5)

    local on = state
    local function refresh()
        if on then
            t.BackgroundColor3 = C.toggleOn
            TweenService:Create(knob, TweenInfo.new(0.12), {Position = UDim2.new(1,-11,0.5,-4.5)}):Play()
        else
            t.BackgroundColor3 = C.toggleOff
            TweenService:Create(knob, TweenInfo.new(0.12), {Position = UDim2.new(0,2,0.5,-4.5)}):Play()
        end
    end

    t.MouseButton1Click:Connect(function()
        on = not on
        refresh()
        if onChange then onChange(on) end
    end)
    return t, function() return on end, function(v) on = v; refresh() end
end

local function toggleRow(col, label, default, onChange, red)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1,0,0,18)
    r.BackgroundColor3 = C.row
    r.BorderSizePixel = 0
    r.LayoutOrder = ord()
    r.Parent = col

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.6,0,1,0)
    l.Position = UDim2.new(0,8,0,0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = red and C.red or C.text
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = r

    return toggleSwitch(r, default, onChange)
end

local function valueRow(col, label, value, w, red)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1,0,0,17)
    r.BackgroundColor3 = C.row
    r.BorderSizePixel = 0
    r.LayoutOrder = ord()
    r.Parent = col

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55,0,1,0)
    l.Position = UDim2.new(0,8,0,0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = red and C.red or C.text
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = r

    local v = Instance.new("TextLabel")
    v.Size = UDim2.new(0,w or 62,0,13)
    v.Position = UDim2.new(1,-(w or 62)-6,0.5,-6.5)
    v.BackgroundColor3 = C.valueBox
    v.Text = tostring(value)
    v.TextColor3 = red and C.red or C.text
    v.Font = Enum.Font.Gotham
    v.TextSize = 10
    v.Parent = r
    corner(v, 2)
    stroke(v, C.strokeDim, 1)
    return v
end

local function buttonRow(col, label, onClick, red)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,20)
    b.BackgroundColor3 = C.row
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = ord()
    b.Parent = col

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-16,1,0)
    l.Position = UDim2.new(0,8,0,0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = red and C.red or C.text
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b

    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.tabActive}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.row}):Play() end)
    b.MouseButton1Click:Connect(onClick)
    return b
end

local function methodRow(col, label, onSelect)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,17)
    b.BackgroundColor3 = C.row
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = ord()
    b.Parent = col

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,5,0,5)
    dot.Position = UDim2.new(0,8,0.5,-2.5)
    dot.BackgroundColor3 = C.textDim
    dot.BorderSizePixel = 0
    dot.Parent = b
    corner(dot, 3)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-22,1,0)
    l.Position = UDim2.new(0,20,0,0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.textDim
    l.Font = Enum.Font.Gotham
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = b

    b.MouseButton1Click:Connect(function() onSelect(b, dot, l) end)
    b.MouseEnter:Connect(function()
        if dot.BackgroundColor3 ~= C.red then
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.tabActive}):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if dot.BackgroundColor3 ~= C.red then
            TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.row}):Play()
        end
    end)
end

--==== FLY (исправлено) ====--
local flyConn

local function stopFly()
    S.fly = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp then
            for _, n in ipairs({"JJSFlyBV","JJSFlyBG"}) do
                local o = hrp:FindFirstChild(n); if o then o:Destroy() end
            end
        end
        if hum then hum.PlatformStand = false end
    end
end

local function startFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    local bv = Instance.new("BodyVelocity")
    bv.Name = "JJSFlyBV"
    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
    bv.Velocity = Vector3.zero
    bv.P = 1e4
    bv.Parent = hrp

    local bg = Instance.new("BodyGyro")
    bg.Name = "JJSFlyBG"
    bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
    bg.P = 3e4; bg.D = 500
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    S.fly = true

    -- ФИКС: MoveDirection уже возвращает мировой вектор.
    -- Раньше мы умножали его на camCF.LookVector * md.Z, что давало инверсию.
    -- Теперь используем md напрямую для горизонтали, а вертикаль берём из наклона камеры.
    flyConn = RunService.RenderStepped:Connect(function()
        if not S.fly or not bv.Parent then return end

        local md    = hum.MoveDirection
        local camCF = Camera.CFrame

        -- Горизонталь: берём X и Z из MoveDirection как есть
        local horiz = Vector3.new(md.X, 0, md.Z)
        if horiz.Magnitude > 1 then horiz = horiz.Unit end

        -- Вертикаль: наклон камеры вверх/вниз (только когда движемся)
        local vert = 0
        if md.Magnitude > 0.1 then
            vert = camCF.LookVector.Y
        end

        local dir = Vector3.new(horiz.X, vert, horiz.Z)
        if dir.Magnitude > 1 then dir = dir.Unit end

        bv.Velocity = dir * S.flySpeed
        bg.CFrame = CFrame.new(hrp.Position, hrp.Position + camCF.LookVector)
    end)
end

--==== INVIS (FFlag + fallback) ====--
local invisConn

local function restoreChar()
    local char = LP.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = 0
            if v:FindFirstChild("JJSOldTrans") then
                v.Transparency = v.JJSOldTrans.Value
                v.JJSOldTrans:Destroy()
            end
        elseif v:IsA("Decal") or v:IsA("Texture") then
            if v:FindFirstChild("JJSOldTrans") then
                v.Transparency = v.JJSOldTrans.Value
                v.JJSOldTrans:Destroy()
            end
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        hum.HealthDisplayDistance = 100
        hum.NameDisplayDistance = 100
    end
end

local function applyInvis(mode)
    S.invisMode = mode
    pcall(restoreChar)

    local char = LP.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp then return end

    -- M1: WorldStepMax Desync (Bolong-style, самый рабочий)
    if mode == 1 then
        if setfflag then
            pcall(function()
                setfflag("WorldStepMax", "-99999999999999")
                task.wait(1)
                setfflag("WorldStepMax", "-1")
            end)
        end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                if not v:FindFirstChild("JJSOldTrans") then
                    local n = Instance.new("NumberValue")
                    n.Name = "JJSOldTrans"
                    n.Value = v.Transparency
                    n.Parent = v
                end
                v.Transparency = 1
                v.LocalTransparencyModifier = 1
            end
        end
        invisConn = RunService.RenderStepped:Connect(function()
            local c = LP.Character
            if not c then return end
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
            end
        end)

    -- M2: Physics sender rate
    elseif mode == 2 then
        if setfflag then
            pcall(function()
                setfflag("DFIntS2PhysicsSenderRate", "-1")
            end)
        end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                if not v:FindFirstChild("JJSOldTrans") then
                    local n = Instance.new("NumberValue")
                    n.Name = "JJSOldTrans"
                    n.Value = v.Transparency
                    n.Parent = v
                end
                v.Transparency = 1
                v.LocalTransparencyModifier = 1
            end
        end
        invisConn = RunService.RenderStepped:Connect(function()
            local c = LP.Character
            if not c then return end
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
            end
        end)

    -- M3: Local transparency only (fallback)
    elseif mode == 3 then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                if not v:FindFirstChild("JJSOldTrans") then
                    local n = Instance.new("NumberValue")
                    n.Name = "JJSOldTrans"
                    n.Value = v.Transparency
                    n.Parent = v
                end
                v.Transparency = 1
                v.CanCollide = false
                v.LocalTransparencyModifier = 1
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("Accessory") or v:IsA("Hat") then
                v:Destroy()
            end
        end
        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            hum.HealthDisplayDistance = 0
            hum.NameDisplayDistance = 0
        end
        invisConn = RunService.RenderStepped:Connect(function()
            local c = LP.Character
            if not c then return end
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
            end
        end)
    end

    local backup = RunService.Heartbeat:Connect(function()
        if not S.invis then return end
        local c = LP.Character
        if not c then return end
        for _, v in ipairs(c:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 1
                if mode ~= 3 and v.Transparency ~= 1 then v.Transparency = 1 end
            end
        end
    end)
    S.conns[#S.conns+1] = backup
end

local function stopInvis()
    S.invis = false
    if invisConn then invisConn:Disconnect(); invisConn = nil end
    if setfflag then
        pcall(function()
            setfflag("WorldStepMax", "-1")
            setfflag("DFIntS2PhysicsSenderRate", "15")
        end)
    end
    pcall(restoreChar)
end

--==== BUILD MAIN PAGE ====--
local FlyRefs = { setState = nil }
local InvisRefs = { setState = nil }
local methodRefs = {}

local function buildMainPage()
    clearAll(); globalOrder = 0
    methodRefs = {}

    ------------------------------------------------------------
    -- COLUMN 1: FLY
    ------------------------------------------------------------
    sectionHeader(Col1, "Fly")
    local _, _, setFlyState = toggleRow(Col1, "Enabled", S.fly, function(v)
        if v then startFly() else stopFly() end
    end)
    FlyRefs.setState = setFlyState

    sectionHeader(Col1, "Speed")
    local speedLbl = valueRow(Col1, "Current Speed", tostring(S.flySpeed), 56)
    buttonRow(Col1, "◄ − 10", function()
        S.flySpeed = math.max(10, S.flySpeed - 10)
        speedLbl.Text = tostring(S.flySpeed)
    end)
    buttonRow(Col1, "► + 10", function()
        S.flySpeed = math.min(500, S.flySpeed + 10)
        speedLbl.Text = tostring(S.flySpeed)
    end)

    sectionHeader(Col1, "Controls")
    valueRow(Col1, "Horizontal", "Joystick", 62)
    valueRow(Col1, "Vertical", "Cam Pitch", 62)

    ------------------------------------------------------------
    -- COLUMN 2: INVISIBILITY
    ------------------------------------------------------------
    sectionHeader(Col2, "Invisibility")
    local _, _, setInvisState = toggleRow(Col2, "Enabled", S.invis, function(v)
        if v then
            S.invis = true
            applyInvis(S.invisMode)
        else
            stopInvis()
        end
    end)
    InvisRefs.setState = setInvisState

    local activeLbl = valueRow(Col2, "Active Method", "M" .. S.invisMode, 40)

    sectionHeader(Col2, "Methods")
    local methods = {
        "M1 · WorldStepMax Desync",
        "M2 · Physics Sender Rate",
        "M3 · Local Transparency",
    }
    for i, name in ipairs(methods) do
        local btn, dot, lbl = methodRow(Col2, name, function(b, d, l)
            S.invisMode = i
            if activeLbl then activeLbl.Text = "M" .. i end
            if S.invis then applyInvis(i) end
            for _, ref in ipairs(methodRefs) do
                ref.dot.BackgroundColor3 = C.textDim
                ref.lbl.TextColor3 = C.textDim
                ref.btn.BackgroundColor3 = C.row
            end
            d.BackgroundColor3 = C.red
            l.TextColor3 = C.text
            b.BackgroundColor3 = C.tabActive
        end)
        methodRefs[i] = { btn = btn, dot = dot, lbl = lbl }
    end
    local act = methodRefs[S.invisMode]
    if act then
        act.dot.BackgroundColor3 = C.red
        act.lbl.TextColor3 = C.text
        act.btn.BackgroundColor3 = C.tabActive
    end

    ------------------------------------------------------------
    -- COLUMN 3: INFO + MISC
    ------------------------------------------------------------
    sectionHeader(Col3, "Info")
    valueRow(Col3, "Streaming", tostring(workspace.StreamingEnabled), 62)
    valueRow(Col3, "Status", S.invis and "Active" or "Idle", 62)
    valueRow(Col3, "Version", "2.0", 62)

    sectionHeader(Col3, "Actions")
    buttonRow(Col3, "Reset Character", function()
        local c = LP.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h.Health = 0 end
        end
    end)
    buttonRow(Col3, "Rejoin Server", function()
        pcall(function() TeleportService:Teleport(game.PlaceId) end)
    end)
    buttonRow(Col3, "Toggle Menu", function()
        Main.Visible = not Main.Visible
    end)

    sectionHeader(Col3, "Danger")
    buttonRow(Col3, "Disable All", function()
        stopFly(); stopInvis()
        if FlyRefs.setState then FlyRefs.setState(false) end
        if InvisRefs.setState then InvisRefs.setState(false) end
    end, true)
    buttonRow(Col3, "Destroy GUI", function()
        stopFly(); stopInvis()
        gui:Destroy()
    end, true)
end

--== BUILD ON START ==--
buildMainPage()

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

--==== AUTOCLEANUP ====--
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if S.fly then stopFly() end
    if S.invis then stopInvis() end
    buildMainPage()
end)

Main.Visible = false
print("[JJS] Menu loaded. Tap JJS button. FFlag invis ready.")
