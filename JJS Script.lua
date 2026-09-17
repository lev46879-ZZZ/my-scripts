-- Version: 1.0.6

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("CustomModMenu") then
    playerGui.CustomModMenu:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomModMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local COL_BG = Color3.fromRGB(22, 22, 24)
local COL_SIDEBAR = Color3.fromRGB(16, 16, 18)
local COL_ELEM = Color3.fromRGB(34, 34, 38)
local COL_ELEM_HOVER = Color3.fromRGB(46, 46, 50)
local COL_ACCENT = Color3.fromRGB(0, 140, 255)
local COL_TEXT = Color3.fromRGB(230, 230, 232)
local COL_TEXT_DIM = Color3.fromRGB(130, 130, 138)
local COL_STROKE = Color3.fromRGB(48, 48, 52)

local baseMenuW = 400
local baseMenuH = 260
local menuW = baseMenuW
local menuH = baseMenuH

local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    local wasDragged = false

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            wasDragged = false
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if (input.Position - dragStart).Magnitude > 5 then
                        wasDragged = true
                    end
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    return function() return wasDragged end
end

local menu = Instance.new("Frame")
menu.Name = "Menu"
menu.AnchorPoint = Vector2.new(0.5, 0.5)
menu.Size = UDim2.new(0, menuW, 0, menuH)
menu.Position = UDim2.new(0.5, 0, -0.5, 0)
menu.BackgroundColor3 = COL_BG
menu.BorderSizePixel = 0
menu.ClipsDescendants = true
menu.Visible = false
menu.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 10)
menuCorner.Parent = menu

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = COL_STROKE
menuStroke.Thickness = 1
menuStroke.Parent = menu

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 46, 1, 0)
sidebar.BackgroundColor3 = COL_SIDEBAR
sidebar.BorderSizePixel = 0
sidebar.Parent = menu

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 10)
sidebarCorner.Parent = sidebar

local sidebarCover = Instance.new("Frame")
sidebarCover.Size = UDim2.new(0, 12, 1, 0)
sidebarCover.Position = UDim2.new(1, -12, 0, 0)
sidebarCover.BackgroundColor3 = COL_SIDEBAR
sidebarCover.BorderSizePixel = 0
sidebarCover.Parent = sidebar

local tabList = Instance.new("UIListLayout")
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Padding = UDim.new(0, 8)
tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabList.VerticalAlignment = Enum.VerticalAlignment.Center
tabList.Parent = sidebar

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -46, 1, 0)
content.Position = UDim2.new(0, 46, 0, 0)
content.BackgroundTransparency = 1
content.Parent = menu

local pages = {}

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 18)
    pad.PaddingBottom = UDim.new(0, 18)
    pad.PaddingLeft = UDim.new(0, 18)
    pad.PaddingRight = UDim.new(0, 18)
    pad.Parent = page

    pages[name] = page
    return page
end

local activeTab = nil
local tabButtons = {}

local function selectTab(name)
    if activeTab == name then return end
    for tabName, btn in pairs(tabButtons) do
        if tabName == name then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COL_ACCENT}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COL_ELEM}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = COL_TEXT_DIM}):Play()
        end
    end
    for pageName, page in pairs(pages) do
        page.Visible = (pageName == name)
    end
    activeTab = name
end

local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 34, 0, 34)
    btn.BackgroundColor3 = COL_ELEM
    btn.Text = icon
    btn.TextColor3 = COL_TEXT_DIM
    btn.TextSize = 18
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = sidebar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COL_ELEM_HOVER}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COL_ELEM}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        selectTab(name)
    end)

    tabButtons[name] = btn
    return btn
end

createTab("main", "⌂")
createTab("sitting", "⚙")

local mainPage = createPage("main")
local sittingPage = createPage("sitting")

local sliderHolder = Instance.new("Frame")
sliderHolder.Size = UDim2.new(1, 0, 0, 40)
sliderHolder.BackgroundTransparency = 1
sliderHolder.Parent = sittingPage

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0, 16)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "UI Scale"
sliderLabel.TextColor3 = COL_TEXT_DIM
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 13
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = sliderHolder

local sliderBg = Instance.new("Frame")
sliderBg.Name = "SliderBg"
sliderBg.Size = UDim2.new(1, 0, 0, 6)
sliderBg.Position = UDim2.new(0, 0, 0, 28)
sliderBg.BackgroundColor3 = COL_ELEM
sliderBg.BorderSizePixel = 0
sliderBg.Parent = sliderHolder

local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(1, 0)
sliderBgCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = COL_ACCENT
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill

local sliderKnob = Instance.new("Frame")
sliderKnob.Name = "SliderKnob"
sliderKnob.Size = UDim2.new(0, 14, 0, 14)
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 2
sliderKnob.Parent = sliderBg

local sliderKnobCorner = Instance.new("UICorner")
sliderKnobCorner.CornerRadius = UDim.new(1, 0)
sliderKnobCorner.Parent = sliderKnob

local isDraggingSlider = false

local function updateSlider(input)
    local mouseX = input.Position.X
    local bgPos = sliderBg.AbsolutePosition.X
    local bgSize = sliderBg.AbsoluteSize.X
    local percent = math.clamp((mouseX - bgPos) / bgSize, 0, 1)

    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)

    local scaleFactor = 0.7 + (percent * 0.6)
    menuW = math.floor(baseMenuW * scaleFactor)
    menuH = math.floor(baseMenuH * scaleFactor)

    TweenService:Create(menu, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, menuW, 0, menuH)
    }):Play()
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = true
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingSlider = false
    end
end)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 46, 0, 46)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.BackgroundColor3 = COL_BG
toggleBtn.Text = "≡"
toggleBtn.TextColor3 = COL_TEXT
toggleBtn.TextSize = 24
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 9)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = COL_STROKE
toggleStroke.Thickness = 1
toggleStroke.Parent = toggleBtn

local checkToggleDrag = makeDraggable(toggleBtn)

local isOpen = false
local openPos = UDim2.new(0.5, 0, 0.5, 0)
local closePos = UDim2.new(0.5, 0, -0.5, 0)

local openTween = TweenService:Create(menu, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Position = openPos
})

local closeTween = TweenService:Create(menu, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
    Position = closePos
})

local function openMenu()
    if isOpen then return end
    isOpen = true
    menu.Visible = true
    openTween:Play()
    toggleBtn.Text = "X"
end

local function closeMenu()
    if not isOpen then return end
    isOpen = false
    closeTween:Play()
    toggleBtn.Text = "≡"
    task.delay(0.35, function()
        if not isOpen then
            menu.Visible = false
        end
    end)
end

local function toggleMenu()
    if isOpen then closeMenu() else openMenu() end
end

toggleBtn.MouseButton1Click:Connect(function()
    if not checkToggleDrag() then
        toggleMenu()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        toggleMenu()
    end
end)

selectTab("main")
