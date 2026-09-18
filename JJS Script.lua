-- ═══════════════════════════════════════════
--   JJS HUB | Delta Executor (Mobile)
-- ═══════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Удаление старого GUI при повторном запуске
if game.CoreGui:FindFirstChild("JJS_Delta") then
    game.CoreGui.JJS_Delta:Destroy()
end

-- ═══════════════ ПЕРЕМЕННЫЕ ═══════════════
local flyEnabled = false
local flySpeed = 60
local flyBV = nil
local flyBG = nil
local currentTab = "Main"

-- ═══════════════ ЦВЕТА ═══════════════
local C = {
    bg       = Color3.fromRGB(18, 18, 24),
    bg2      = Color3.fromRGB(26, 26, 34),
    bg3      = Color3.fromRGB(34, 34, 44),
    accent   = Color3.fromRGB(130, 80, 255),
    accent2  = Color3.fromRGB(160, 110, 255),
    text     = Color3.fromRGB(235, 235, 240),
    textDim  = Color3.fromRGB(140, 140, 155),
    white    = Color3.fromRGB(255, 255, 255),
    red      = Color3.fromRGB(255, 70, 70),
    green    = Color3.fromRGB(70, 220, 120),
}

-- ═══════════════ SCREEN GUI ═══════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JJS_Delta"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- ═══════════════ КНОПКА ОТКРЫТИЯ ═══════════════
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 52, 0, 52)
ToggleBtn.Position = UDim2.new(0, 12, 0.5, -26)
ToggleBtn.BackgroundColor3 = C.bg
ToggleBtn.Text = "JJS"
ToggleBtn.TextColor3 = C.accent
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = ScreenGui

local corner1 = Instance.new("UICorner", ToggleBtn)
corner1.CornerRadius = UDim.new(0, 14)

local stroke1 = Instance.new("UIStroke", ToggleBtn)
stroke1.Color = C.accent
stroke1.Thickness = 1.5
stroke1.Transparency = 0.4

-- ═══════════════ ГЛАВНОЕ ОКНО ═══════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 420)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
MainFrame.BackgroundColor3 = C.bg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local corner2 = Instance.new("UICorner", MainFrame)
corner2.CornerRadius = UDim.new(0, 16)

local stroke2 = Instance.new("UIStroke", MainFrame)
stroke2.Color = Color3.fromRGB(50, 50, 65)
stroke2.Thickness = 1

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 44)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "JJS HUB"
Title.TextColor3 = C.white
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -20, 0, 16)
SubTitle.Position = UDim2.new(0, 10, 0, 40)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Delta Executor • Mobile"
SubTitle.TextColor3 = C.textDim
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = MainFrame

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = C.bg3
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.red
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = MainFrame

local corner3 = Instance.new("UICorner", CloseBtn)
corner3.CornerRadius = UDim.new(0, 8)

-- ═══════════════ ВКЛАДКИ ═══════════════
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 36)
TabContainer.Position = UDim2.new(0, 10, 0, 62)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local function createTab(name, posX, sizeX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, sizeX, 1, 0)
    btn.Position = UDim2.new(0, posX, 0, 0)
    btn.BackgroundColor3 = C.bg3
    btn.Text = name
    btn.TextColor3 = C.textDim
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = TabContainer
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 10)
    return btn
end

local TabMain = createTab("Main", 0, 155)
local TabTp   = createTab("Teleport", 165, 155)

-- ═══════════════ КОНТЕНТ ═══════════════
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -110)
ContentFrame.Position = UDim2.new(0, 10, 0, 106)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Страница Main
local PageMain = Instance.new("ScrollingFrame")
PageMain.Size = UDim2.new(1, 0, 1, 0)
PageMain.BackgroundTransparency = 1
PageMain.BorderSizePixel = 0
PageMain.ScrollBarThickness = 3
PageMain.ScrollBarImageColor3 = C.accent
PageMain.CanvasSize = UDim2.new(0, 0, 0, 200)
PageMain.Visible = true
PageMain.Parent = ContentFrame

-- Страница Teleport
local PageTp = Instance.new("ScrollingFrame")
PageTp.Size = UDim2.new(1, 0, 1, 0)
PageTp.BackgroundTransparency = 1
PageTp.BorderSizePixel = 0
PageTp.ScrollBarThickness = 3
PageTp.ScrollBarImageColor3 = C.accent
PageTp.CanvasSize = UDim2.new(0, 0, 0, 260)
PageTp.Visible = false
PageTp.Parent = ContentFrame

-- ═══════════════ UI HELPERS ═══════════════
local function makeSection(parent, text, posY)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Position = UDim2.new(0, 0, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.accent2
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function makeCard(parent, posY, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height)
    card.Position = UDim2.new(0, 0, 0, posY)
    card.BackgroundColor3 = C.bg2
    card.BorderSizePixel = 0
    card.Parent = parent
    local c = Instance.new("UICorner", card)
    c.CornerRadius = UDim.new(0, 10)
    return card
end

-- ═══════════════ MAIN: FLY ═══════════════
makeSection(PageMain, "⚡ ПЕРЕМЕЩЕНИЕ", 0)

local flyCard = makeCard(PageMain, 24, 110)

local flyLabel = Instance.new("TextLabel")
flyLabel.Size = UDim2.new(0.5, 0, 0, 30)
flyLabel.Position = UDim2.new(0, 12, 0, 6)
flyLabel.BackgroundTransparency = 1
flyLabel.Text = "Fly (Полёт)"
flyLabel.TextColor3 = C.text
flyLabel.TextSize = 14
flyLabel.Font = Enum.Font.GothamSemibold
flyLabel.TextXAlignment = Enum.TextXAlignment.Left
flyLabel.Parent = flyCard

-- Тумблер Fly
local flyToggleBg = Instance.new("Frame")
flyToggleBg.Size = UDim2.new(0, 48, 0, 26)
flyToggleBg.Position = UDim2.new(1, -60, 0, 8)
flyToggleBg.BackgroundColor3 = C.bg3
flyToggleBg.BorderSizePixel = 0
flyToggleBg.Parent = flyCard

local ftCorner = Instance.new("UICorner", flyToggleBg)
ftCorner.CornerRadius = UDim.new(1, 0)

local flyCircle = Instance.new("Frame")
flyCircle.Size = UDim2.new(0, 20, 0, 20)
flyCircle.Position = UDim2.new(0, 3, 0, 3)
flyCircle.BackgroundColor3 = C.textDim
flyCircle.BorderSizePixel = 0
flyCircle.Parent = flyToggleBg

local fcCorner = Instance.new("UICorner", flyCircle)
fcCorner.CornerRadius = UDim.new(1, 0)

local flyToggleBtn = Instance.new("TextButton")
flyToggleBtn.Size = UDim2.new(1, 0, 1, 0)
flyToggleBtn.BackgroundTransparency = 1
flyToggleBtn.Text = ""
flyToggleBtn.Parent = flyToggleBg

-- Ползунок скорости
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.5, 0, 0, 18)
speedLabel.Position = UDim2.new(0, 12, 0, 42)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: 60"
speedLabel.TextColor3 = C.textDim
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = flyCard

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -24, 0, 6)
sliderBg.Position = UDim2.new(0, 12, 0, 68)
sliderBg.BackgroundColor3 = C.bg3
sliderBg.BorderSizePixel = 0
sliderBg.Parent = flyCard

local slCorner = Instance.new("UICorner", sliderBg)
slCorner.CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((60 - 10) / (300 - 10), 0, 1, 0)
sliderFill.BackgroundColor3 = C.accent
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sfCorner = Instance.new("UICorner", sliderFill)
sfCorner.CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.Position = UDim2.new((60 - 10) / (300 - 10), -8, 0.5, -8)
sliderKnob.BackgroundColor3 = C.white
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 5
sliderKnob.Parent = sliderBg

local skCorner = Instance.new("UICorner", sliderKnob)
skCorner.CornerRadius = UDim.new(1, 0)

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(1, 0, 0, 30)
sliderBtn.Position = UDim2.new(0, 0, 0, -12)
sliderBtn.BackgroundTransparency = 1
sliderBtn.Text = ""
sliderBtn.ZIndex = 6
sliderBtn.Parent = sliderBg

-- Логика ползунка
local dragging = false
sliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        flySpeed = math.floor(10 + rel * 290)
        sliderFill.Size = UDim2.new(rel, 0, 1, 0)
        sliderKnob.Position = UDim2.new(rel, -8, 0.5, -8)
        speedLabel.Text = "Скорость: " .. flySpeed
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Логика тумблера Fly
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.D = 200
    flyBG.Parent = hrp
end

local function stopFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
end

RunService.RenderStepped:Connect(function()
    if flyEnabled and flyBV and flyBG then
        local cam = workspace.CurrentCamera
        flyBV.Velocity = cam.CFrame.LookVector * flySpeed
        flyBG.CFrame = cam.CFrame
    end
end)

flyToggleBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    if flyEnabled then
        flyCircle.Position = UDim2.new(0, 25, 0, 3)
        flyCircle.BackgroundColor3 = C.accent
        flyToggleBg.BackgroundColor3 = Color3.fromRGB(60, 40, 120)
        startFly()
    else
        flyCircle.Position = UDim2.new(0, 3, 0, 3)
        flyCircle.BackgroundColor3 = C.textDim
        flyToggleBg.BackgroundColor3 = C.bg3
        stopFly()
    end
end)

-- ═══════════════ TELEPORT ═══════════════
makeSection(PageTp, "🌀 ТЕЛЕПОРТАЦИЯ", 0)

-- Выпадающий список игроков
local tpCard = makeCard(PageTp, 24, 170)

local tpLabel = Instance.new("TextLabel")
tpLabel.Size = UDim2.new(1, -24, 0, 22)
tpLabel.Position = UDim2.new(0, 12, 0, 8)
tpLabel.BackgroundTransparency = 1
tpLabel.Text = "Выберите игрока:"
tpLabel.TextColor3 = C.text
tpLabel.TextSize = 13
tpLabel.Font = Enum.Font.GothamSemibold
tpLabel.TextXAlignment = Enum.TextXAlignment.Left
tpLabel.Parent = tpCard

-- Список игроков (кнопка-дропдаун)
local selectedPlayer = nil

local dropBtn = Instance.new("TextButton")
dropBtn.Size = UDim2.new(1, -24, 0, 32)
dropBtn.Position = UDim2.new(0, 12, 0, 34)
dropBtn.BackgroundColor3 = C.bg3
dropBtn.Text = "  — выберите игрока —"
dropBtn.TextColor3 = C.textDim
dropBtn.TextSize = 12
dropBtn.Font = Enum.Font.Gotham
dropBtn.TextXAlignment = Enum.TextXAlignment.Left
dropBtn.BorderSizePixel = 0
dropBtn.Parent = tpCard

local dbCorner = Instance.new("UICorner", dropBtn)
dbCorner.CornerRadius = UDim.new(0, 8)

local dropList = Instance.new("ScrollingFrame")
dropList.Size = UDim2.new(1, -24, 0, 0)
dropList.Position = UDim2.new(0, 12, 0, 68)
dropList.BackgroundColor3 = C.bg3
dropList.BorderSizePixel = 0
dropList.ScrollBarThickness = 2
dropList.ScrollBarImageColor3 = C.accent
dropList.Visible = false
dropList.ZIndex = 10
dropList.Parent = tpCard

local dlCorner = Instance.new("UICorner", dropList)
dlCorner.CornerRadius = UDim.new(0, 8)

local dlLayout = Instance.new("UIListLayout", dropList)
dlLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshPlayerList()
    for _, child in ipairs(dropList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            count = count + 1
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = C.bg2
            btn.Text = "  " .. plr.Name
            btn.TextColor3 = C.text
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            btn.ZIndex = 11
            btn.LayoutOrder = count
            btn.Parent = dropList

            btn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                dropBtn.Text = "  " .. plr.Name
                dropBtn.TextColor3 = C.text
                dropList.Visible = false
            end)
        end
    end
    dropList.CanvasSize = UDim2.new(0, 0, 0, count * 28)
    dropList.Size = UDim2.new(1, -24, 0, math.min(count * 28, 100))
end

dropBtn.MouseButton1Click:Connect(function()
    dropList.Visible = not dropList.Visible
    if dropList.Visible then
        refreshPlayerList()
    end
end)

-- Кнопка: ТП игрока к себе
local tpToMeBtn = Instance.new("TextButton")
tpToMeBtn.Size = UDim2.new(1, -24, 0, 34)
tp
