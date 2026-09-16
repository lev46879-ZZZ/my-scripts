--[[
    JJS BATTLEGROUND — Script for Delta (Mobile)
    Features: Fly, Invisibility (8 server-side attempts), JJS-style GUI
--]]

--==== SERVICES ====--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==== CLEANUP ====--
if _G.JJS_SCRIPT then
    pcall(function()
        if _G.JJS_SCRIPT.gui then _G.JJS_SCRIPT.gui:Destroy() end
        for _, c in ipairs(_G.JJS_SCRIPT.conns) do pcall(function() c:Disconnect() end) end
    end)
end

local S = { gui=nil, conns={}, fly=false, flySpeed=60, invis=false, invisMode=1 }
_G.JJS_SCRIPT = S

--==== GUI HELPERS ====--
local function corner(p, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c end
local function stroke(p, col, th)
    local s=Instance.new("UIStroke"); s.Color=col or Color3.fromRGB(180,40,50); s.Thickness=th or 1.5; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s
end
local function gradient(p, c1, c2)
    local g=Instance.new("UIGradient"); g.Color=ColorSequence.new(c1,c2); g.Parent=p; return g
end

local gui = Instance.new("ScreenGui")
gui.Name = "JJSMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")
S.gui = gui

-- Floating open button (draggable)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,64,0,64)
ToggleBtn.Position = UDim2.new(0,20,0.4,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(14,14,18)
ToggleBtn.Text = "JJS"
ToggleBtn.TextColor3 = Color3.fromRGB(230,60,70)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 20
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = gui
corner(ToggleBtn, 32)
stroke(ToggleBtn, Color3.fromRGB(230,60,70), 2)

-- Main panel
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,300,0,440)
Main.Position = UDim2.new(0.5,-150,0.5,-220)
Main.BackgroundColor3 = Color3.fromRGB(10,10,14)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = gui
corner(Main, 12)
stroke(Main, Color3.fromRGB(180,40,50), 1.5)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,44)
Header.BackgroundColor3 = Color3.fromRGB(18,18,24)
Header.BorderSizePixel = 0
Header.Parent = Main
corner(Header, 12)
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1,0,0,14)
HeaderFix.Position = UDim2.new(0,0,1,-14)
HeaderFix.BackgroundColor3 = Color3.fromRGB(18,18,24)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header
gradient(Header, Color3.fromRGB(28,28,36), Color3.fromRGB(14,14,18))

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1,-50,1,0)
TitleLabel.Position = UDim2.new(0,16,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "JJS • BATTLEGROUND"
TitleLabel.TextColor3 = Color3.fromRGB(235,235,240)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,28,0,28)
CloseBtn.Position = UDim2.new(1,-36,0,8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180,40,50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = Header
corner(CloseBtn, 6)

CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Content scroll
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1,-20,1,-60)
Content.Position = UDim2.new(0,10,0,52)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(180,40,50)
Content.CanvasSize = UDim2.new(0,0,0,800)
Content.Parent = Main

local function section(text, y)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,0,18); l.Position=UDim2.new(0,0,0,y)
    l.BackgroundTransparency=1; l.Text=text
    l.TextColor3=Color3.fromRGB(200,60,70); l.Font=Enum.Font.GothamBold
    l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=Content; return l
end

local function makeButton(text, y, cb)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,32); b.Position=UDim2.new(0,0,0,y)
    b.BackgroundColor3=Color3.fromRGB(22,22,28)
    b.Text=text; b.TextColor3=Color3.fromRGB(220,220,230)
    b.Font=Enum.Font.GothamMedium; b.TextSize=13
    b.AutoButtonColor=false
    b.Parent=Content; corner(b,6); stroke(b,Color3.fromRGB(45,45,55),1)
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(34,34,42)}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(22,22,28)}):Play() end)
    b.MouseButton1Click:Connect(function() cb(b) end)
    return b
end

--==== FLY ====--
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
    flyConn = RunService.RenderStepped:Connect(function()
        if not S.fly or not bv.Parent then return end
        local camCF = Camera.CFrame
        local md = hum.MoveDirection
        local dir = Vector3.zero

        if md.Magnitude > 0.05 then
            dir = (camCF.LookVector * md.Z + camCF.RightVector * md.X)
            if dir.Magnitude > 1 then dir = dir.Unit end
        end

        local vert = camCF.LookVector.Y * (md.Z ~= 0 and 1 or 0)
        dir = dir + Vector3.new(0, vert, 0)

        bv.Velocity = dir * S.flySpeed
        bg.CFrame = CFrame.new(hrp.Position, hrp.Position + camCF.LookVector)
    end)
end

--==== INVISIBILITY — SERVER-SIDE ATTEMPTS v2 ====--
local invisConn
local savedHRP

local function saveTrans(v)
    if v:FindFirstChild("JJSOldTrans") then return end
    local n = Instance.new("NumberValue")
    n.Name = "JJSOldTrans"
    n.Value = v.Transparency
    n.Parent = v
end

local function restoreChar()
    local char = LP.Character
    if not char then return end
    if savedHRP then
        pcall(function()
            savedHRP.Anchored = false
            savedHRP.CanCollide = true
            savedHRP.CanQuery = true
            savedHRP.CanTouch = true
            savedHRP.Transparency = 0
            savedHRP.LocalTransparencyModifier = 0
            savedHRP.Massless = false
        end)
        savedHRP = nil
    end
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
    char.Archivable = true

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp then return end
    savedHRP = hrp

    ------------------------------------------------------------
    -- МЕТОД 1: Character Reparent Desync (Bolong-style)
    ------------------------------------------------------------
    if mode == 1 then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                saveTrans(v)
                v.Transparency = 1
                v.CanCollide = false
                v.CanQuery = false
                v.CanTouch = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                saveTrans(v); v.Transparency = 1
            elseif v:IsA("Accessory") then
                v:Destroy()
            end
        end
        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            hum.HealthDisplayDistance = 0
            hum.NameDisplayDistance = 0
        end
        pcall(function() hrp:SetNetworkOwner(nil) end)
        task.spawn(function()
            local parent = char.Parent
            char.Parent = nil
            task.wait(0.05)
            char.Parent = parent
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 1 end
            end
        end)
        invisConn = RunService.RenderStepped:Connect(function()
            local c = LP.Character
            if not c then return end
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
            end
            if hum and hum.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
        end)

    ------------------------------------------------------------
    -- МЕТОД 2: Humanoid Destroy/Recreate Desync
    ------------------------------------------------------------
    elseif mode == 2 then
        if hum then
            local humParent = hum.Parent
            hum:Destroy()
            task.wait()
            local newHum = Instance.new("Humanoid")
            newHum.Name = "Humanoid"
            newHum.Parent = humParent
            newHum.MaxHealth = 100
            newHum.Health = 100
            newHum.WalkSpeed = 16
            newHum.JumpPower = 50
        end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                saveTrans(v)
                v.Transparency = 1
            end
        end
        invisConn = RunService.Heartbeat:Connect(function()
            local c = LP.Character
            if not c then return end
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 1 end
            end
        end)

    ------------------------------------------------------------
    -- МЕТОД 3: CFrame NaN Glitch
    ------------------------------------------------------------
    elseif mode == 3 then
        local nan = 0/0
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                saveTrans(v)
                v.Transparency = 1
                v.CanCollide = false
            end
        end
        pcall(function()
            hrp.CFrame = CFrame.new(Vector3.new(nan, nan, nan))
        end)
        task.wait(0.1)
        pcall(function()
            hrp.CFrame = CFrame.new(0, 500, 0)
        end)

    ------------------------------------------------------------
    -- МЕТОД 4: Humanoid Dead State
    ------------------------------------------------------------
    elseif mode == 4 then
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum:ChangeState(Enum.HumanoidStateType.Dead)
            hum.Health = math.huge
            hum.BreakJointsOnDeath = false
        end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                saveTrans(v); v.Transparency = 1
            end
        end

    ------------------------------------------------------------
    -- МЕТОД 5: Massless + Network Ownership Drop
    ------------------------------------------------------------
    elseif mode == 5 then
        pcall(function() hrp:SetNetworkOwner(nil) end)
        pcall(function()
            hrp.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0.001, 0.001, 0, 0)
        end)
        hrp.Massless = true
        hrp.Anchored = false
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                saveTrans(v); v.Transparency = 1
                v.Massless = true
            end
        end

    ------------------------------------------------------------
    -- МЕТОД 6: Anchor Under Map
    ------------------------------------------------------------
    elseif mode == 6 then
        hrp.Anchored = true
        local orig = hrp.CFrame
        hrp.CFrame = CFrame.new(0, -5000, 0)
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                saveTrans(v); v.Transparency = 1
                v.CanCollide = false
            end
        end
        task.spawn(function()
            task.wait(3)
            pcall(function()
                hrp.Anchored = false
                hrp.CFrame = orig
            end)
        end)

    ------------------------------------------------------------
    -- МЕТОД 7: Streaming ReplicationFocus
    ------------------------------------------------------------
    elseif mode == 7 then
        pcall(function()
            if workspace.StreamingEnabled then
                local newFocus = Instance.new("Part")
                newFocus.Anchored = true
                newFocus.CanCollide = false
                newFocus.Transparency = 1
                newFocus.Size = Vector3.new(1,1,1)
                newFocus.Position = Vector3.new(0, 100000, 0)
                newFocus.Parent = workspace
                task.wait(0.2)
                LP.ReplicationFocus = newFocus
                newFocus:Destroy()
            end
        end)
        pcall(function() hrp:SetNetworkOwner(nil) end)
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                saveTrans(v); v.Transparency = 1
            end
        end

    ------------------------------------------------------------
    -- МЕТОД 8: Accessories + LocalTransparency
    ------------------------------------------------------------
    elseif mode == 8 then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Accessory") or v:IsA("Hat") then
                v:Destroy()
            end
        end
        invisConn = RunService.RenderStepped:Connect(function()
            local c = LP.Character
            if not c then return end
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.LocalTransparencyModifier = 1
                end
            end
        end)
    end

    -- Backup loop
    local backup = RunService.Heartbeat:Connect(function()
        if not S.invis then return end
        local c = LP.Character
        if not c then return end
        for _, v in ipairs(c:GetDescendants()) do
            if v:IsA("BasePart") and v.Transparency ~= 1 then
                if mode ~= 8 then v.Transparency = 1 end
            end
        end
    end)
    S.conns[#S.conns+1] = backup
end

local function stopInvis()
    S.invis = false
    if invisConn then invisConn:Disconnect(); invisConn = nil end
    pcall(restoreChar)
end

--==== GUI CONTENT ====--
local y = 0
section("ПОЛЁТ", y); y = y + 22

local FlyBtn = makeButton("✈  Fly: ВЫКЛ", y, function(b)
    if S.fly then
        stopFly()
        b.Text = "✈  Fly: ВЫКЛ"
    else
        startFly()
        b.Text = "✈  Fly: ВКЛ"
    end
end)
y = y + 38

-- Speed control
local SpeedBg = Instance.new("Frame")
SpeedBg.Size = UDim2.new(1,0,0,40)
SpeedBg.Position = UDim2.new(0,0,0,y)
SpeedBg.BackgroundColor3 = Color3.fromRGB(22,22,28)
SpeedBg.Parent = Content
corner(SpeedBg, 6); stroke(SpeedBg, Color3.fromRGB(45,45,55), 1)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.5,0,0,20)
SpeedLabel.Position = UDim2.new(0,10,0,10)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Скорость: 60"
SpeedLabel.TextColor3 = Color3.fromRGB(220,220,230)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedBg

local Minus = Instance.new("TextButton")
Minus.Size = UDim2.new(0,32,0,32)
Minus.Position = UDim2.new(1,-80,0,4)
Minus.BackgroundColor3 = Color3.fromRGB(180,40,50)
Minus.Text = "−"; Minus.TextColor3 = Color3.new(1,1,1)
Minus.Font = Enum.Font.GothamBold; Minus.TextSize = 16
Minus.Parent = SpeedBg; corner(Minus, 6)

local Plus = Instance.new("TextButton")
Plus.Size = UDim2.new(0,32,0,32)
Plus.Position = UDim2.new(1,-44,0,4)
Plus.BackgroundColor3 = Color3.fromRGB(180,40,50)
Plus.Text = "+"; Plus.TextColor3 = Color3.new(1,1,1)
Plus.Font = Enum.Font.GothamBold; Plus.TextSize = 16
Plus.Parent = SpeedBg; corner(Plus, 6)

local function updSpeed()
    SpeedLabel.Text = "Скорость: " .. S.flySpeed
end
Minus.MouseButton1Click:Connect(function() S.flySpeed = math.max(10, S.flySpeed - 10); updSpeed() end)
Plus.MouseButton1Click:Connect(function() S.flySpeed = math.min(500, S.flySpeed + 10); updSpeed() end)

y = y + 50
section("НЕВИДИМОСТЬ (8 серверных методов)", y); y = y + 22

local InvisBtn = makeButton("👻  Invis: ВЫКЛ", y, function(b)
    if S.invis then
        stopInvis()
        b.Text = "👻  Invis: ВЫКЛ"
    else
        S.invis = true
        applyInvis(S.invisMode)
        b.Text = "👻  Invis: ВКЛ"
    end
end)
y = y + 38

local methods = {
    "M1: Char Reparent Desync",
    "M2: Humanoid Destroy/Recreate",
    "M3: NaN CFrame Glitch",
    "M4: Humanoid Dead State",
    "M5: Massless + NetDrop",
    "M6: Anchor Under Map",
    "M7: Streaming ReplicationFocus",
    "M8: Accessories + LocalTrans",
}

local methodButtons = {}
for i, name in ipairs(methods) do
    local b = makeButton("   " .. name, y, function(btn)
        S.invisMode = i
        if S.invis then applyInvis(i) end
        for _, c in ipairs(methodButtons) do
            c.TextColor3 = Color3.fromRGB(220,220,230)
        end
        btn.TextColor3 = Color3.fromRGB(230,60,70)
    end)
    methodButtons[i] = b
    if i == 1 then b.TextColor3 = Color3.fromRGB(230,60,70) end
    y = y + 36
end

y = y + 8
section("ПРОЧЕЕ", y); y = y + 22

makeButton("🔄  Сбросить персонажа", y, function()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)
y = y + 38

makeButton("🛑  Выключить всё", y, function()
    stopFly(); stopInvis()
    FlyBtn.Text = "✈  Fly: ВЫКЛ"
    InvisBtn.Text = "👻  Invis: ВЫКЛ"
end)
y = y + 44

Content.CanvasSize = UDim2.new(0,0,0,y+10)

--==== AUTOCLEANUP ====--
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if S.fly then stopFly(); FlyBtn.Text = "✈  Fly: ВЫКЛ" end
    if S.invis then stopInvis(); InvisBtn.Text = "👻  Invis: ВЫКЛ" end
end)

print("[JJS] Скрипт загружен. Нажми кнопку JJS слева.")
