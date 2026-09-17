-- Version: 1.0.5
-- Delta Executor | PC + Mobile
-- X - toggle all menus
-- M / S - toggle individual menus
-- Drag buttons anywhere
-- UI Scale slider

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

local baseWidth = 200
local baseHeight = 300
local currentWidth = baseWidth
local currentHeight = baseHeight

local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local sizeTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)

local menus = {}

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

local function createMenu(side, name)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Menu"
    frame.Size = UDim2.new(0, currentWidth, 0, currentHeight)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1
    stroke.Parent = frame

    local closedPos, openPos
    if side == "left" then
        closedPos = UDim2.new(0, -(currentWidth + 10), 0.2, 0)
        openPos   = UDim2.new(0, 10, 0.2, 0)
    else
        closedPos = UDim2.new(1, 10, 0.2, 0)
        openPos   = UDim2.new(1, -(currentWidth + 10), 0.2, 0)
    end
    frame.Position = closedPos

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local titlePad = Instance.new("UIPadding")
    titlePad.PaddingLeft = UDim.new(0, 15)
    titlePad.Parent = title

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 5)
    list.Parent = frame

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 45)
    listPad.PaddingLeft = UDim.new(0, 10)
    listPad.PaddingRight = UDim.new(0, 10)
    listPad.PaddingBottom = UDim.new(0, 10)
    listPad.Parent = frame

    local menuData = {
        frame = frame,
        openPos = openPos,
        closedPos = closedPos,
        isOpen = false,
        title = title,
        list = list,
        side = side
    }
    table.insert(menus, menuData)

    return menuData
end

local function addButtonToMenu(menuData, btnText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = btnText
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = menuData.frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn

    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, 10)
    p.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

local mainMenu    = createMenu("left",  "main")
local sittingMenu = createMenu("right", "sitting")

addButtonToMenu(mainMenu, "Example Feature 1", function()
    print("Feature 1")
end)
addButtonToMenu(mainMenu, "Example Feature 2", function()
    print("Feature 2")
end)

addButtonToMenu(sittingMenu, "Example Feature 3", function()
    print("Feature 3")
end)

local sliderContainer = Instance.new("Frame")
sliderContainer.Size = UDim2.new(1, 0, 0, 50)
sliderContainer.BackgroundTransparency = 1
sliderContainer.Parent = sittingMenu.frame

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0, 20)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "UI Scale"
sliderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 12
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = sliderContainer

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, 0, 0, 10)
sliderBg.Position = UDim2.new(0, 0, 0, 25)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = sliderContainer

local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(1, 0)
sliderBgCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(1, 0)
sliderFillCorner.Parent = sliderFill

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBg

local sliderKnobCorner = Instance.new("UICorner")
sliderKnobCorner.CornerRadius = UDim.new(1, 0)
sliderKnobCorner.Parent = sliderKnob

local function createToggleButton(text, position, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = text
    btn.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    btn.TextSize = 24
    btn.Font = Enum.Font.GothamBold
    btn.Parent = screenGui

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(80, 80, 80)
    s.Thickness = 1
    s.Parent = btn

    return btn
end

local toggleMainBtn    = createToggleButton("M", UDim2.new(0, 20, 0, 20))
local toggleSittingBtn = createToggleButton("S", UDim2.new(1, -70, 0, 20))

local checkMainDrag    = makeDraggable(toggleMainBtn)
local checkSittingDrag = makeDraggable(toggleSittingBtn)

local function openMenu(menuData)
    if menuData.isOpen then return end
    TweenService:Create(menuData.frame, tweenInfo, {Position = menuData.openPos}):Play()
    menuData.isOpen = true
end

local function closeMenu(menuData)
    if not menuData.isOpen then return end
    TweenService:Create(menuData.frame, tweenInfo, {Position = menuData.closedPos}):Play()
    menuData.isOpen = false
end

local function toggleMenu(menuData)
    if menuData.isOpen then closeMenu(menuData) else openMenu(menuData) end
end

local function toggleAllMenus()
    local anyClosed = false
    for _, m in ipairs(menus) do
        if not m.isOpen then
            anyClosed = true
            break
        end
    end

    for _, m in ipairs(menus) do
        if anyClosed then
            openMenu(m)
        else
            closeMenu(m)
        end
    end

    toggleMainBtn.Text    = anyClosed and "X" or "M"
    toggleSittingBtn.Text = anyClosed and "X" or "S"
end

toggleMainBtn.MouseButton1Click:Connect(function()
    if not checkMainDrag() then
        toggleMenu(mainMenu)
        toggleMainBtn.Text = mainMenu.isOpen and "X" or "M"
    end
end)

toggleSittingBtn.MouseButton1Click:Connect(function()
    if not checkSittingDrag() then
        toggleMenu(sittingMenu)
        toggleSittingBtn.Text = sittingMenu.isOpen and "X" or "S"
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        toggleAllMenus()
    end
end)

local isDraggingSlider = false

local function updateSlider(input)
    local mouseX  = input.Position.X
    local bgPos   = sliderBg.AbsolutePosition.X
    local bgSize  = sliderBg.AbsoluteSize.X
    local percent = math.clamp((mouseX - bgPos) / bgSize, 0, 1)

    sliderFill.Size     = UDim2.new(percent, 0, 1, 0)
    sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)

    local scaleFactor = 0.7 + (percent * 0.8)
    currentWidth  = math.floor(baseWidth  * scaleFactor)
    currentHeight = math.floor(baseHeight * scaleFactor)

    for _, m in ipairs(menus) do
        TweenService:Create(m.frame, sizeTweenInfo, {
            Size = UDim2.new(0, currentWidth, 0, currentHeight)
        }):Play()

        if m.side == "left" then
            m.closedPos = UDim2.new(0, -(currentWidth + 10), 0.2, 0)
            m.openPos   = UDim2.new(0, 10, 0.2, 0)
        else
            m.closedPos = UDim2.new(1, 10, 0.2, 0)
            m.openPos   = UDim2.new(1, -(currentWidth + 10), 0.2, 0)
        end

        if m.isOpen then
            TweenService:Create(m.frame, sizeTweenInfo, {Position = m.openPos}):Play()
        end
    end
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
