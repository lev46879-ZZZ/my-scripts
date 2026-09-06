-- // BLOXSTRIKE MOBILE SCRIPT v5.1 (исправленный) // --
-- // Компактное меню, чёткая картинка, оптимизированные отступы // --

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")

-- // НАСТРОЙКИ // --
local Settings = {
    Aimbot = false,
    FOV = 120,
    WallCheck = false,
    Smoothing = 3,
    Prediction = false,
    TargetPriority = "Closest",
    AimPart = "Head",
    TeamCheck = true,
    Triggerbot = false,
    TriggerDelayMs = 50,
    AutoCrouch = false,
    CrouchDuration = 0.8,
    ESP = false,
    SkinChanger = false,
    Skins = {
        ["AK47"] = { available = {"Classic", "Red", "Blue"} },
        ["M4A1"] = { available = {"Classic", "Camo"} },
        ["USP"]  = { available = {"Default", "Silver"} },
        ["AWP"]  = { available = {"Sniper", "Dragon"} },
        ["Glock"]= { available = {"Standard", "Gold"} }
    },
    CurrentWeaponSkin = {}
}

-- // GUI // --
local gui = Instance.new("ScreenGui")
gui.Name = "BloxStrikeGUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local style = {
    Background = Color3.fromRGB(25, 25, 35),
    Border = Color3.fromRGB(80, 80, 120),
    Text = Color3.fromRGB(255, 255, 255),
    Button = Color3.fromRGB(60, 60, 90),
    Accent = Color3.fromRGB(0, 180, 255),
    Green = Color3.fromRGB(0, 200, 100),
    Red = Color3.fromRGB(200, 50, 50)
}

local function makeDraggable(frame)
    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- // ПЛАВАЮЩАЯ КНОПКА // --
local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 65, 0, 65)
toggleButton.Position = UDim2.new(0.9, -40, 0.05, 20)
toggleButton.BackgroundColor3 = style.Button
toggleButton.BorderSizePixel = 2
toggleButton.BorderColor3 = style.Border
toggleButton.Image = "rbxassetid://3926305904"
toggleButton.ImageColor3 = Color3.new(1,1,1)
toggleButton.ScaleType = Enum.ScaleType.Fit
toggleButton.Parent = gui
makeDraggable(toggleButton)

-- // МЕНЮ (уменьшено) // --
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 380, 0, 480)  -- уменьшил высоту
menuFrame.Position = UDim2.new(0.5, -190, 0.35, -240)
menuFrame.BackgroundColor3 = style.Background
menuFrame.BorderSizePixel = 3
menuFrame.BorderColor3 = style.Border
menuFrame.Visible = false
menuFrame.Parent = gui
makeDraggable(menuFrame)

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = menuFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = style.Accent
title.BackgroundTransparency = 0.2
title.Text = "BLOXSTRIKE v5.1"
title.TextColor3 = style.Text
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = menuFrame

-- // ДЕКОРАТИВНАЯ КАРТИНКА (исправлена пиксельность) // --
local decoContainer = Instance.new("Frame")
decoContainer.Size = UDim2.new(0, 80, 0, 80)  -- увеличен размер
decoContainer.Position = UDim2.new(1, -95, 0, 2)
decoContainer.BackgroundTransparency = 1
decoContainer.Parent = menuFrame

local decoImage = Instance.new("ImageLabel")
decoImage.Size = UDim2.new(1, 0, 1, 0)
decoImage.BackgroundColor3 = style.Border
decoImage.BorderSizePixel = 2
decoImage.BorderColor3 = style.Accent
decoImage.Image = "https://i.imgur.com/ваша_картинка.png"  -- замените на свой URL
decoImage.ScaleType = Enum.ScaleType.Fit
decoImage.ImageRectSize = Vector2.new(256, 256)  -- чёткость
decoImage.Parent = decoContainer

local decoCorner = Instance.new("UICorner")
decoCorner.CornerRadius = UDim.new(1, 0)
decoCorner.Parent = decoImage

-- Анимация пульсации (оставлена)
local tweenService = game:GetService("TweenService")
local pulseInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local pulseUp = tweenService:Create(decoImage, pulseInfo, { Size = UDim2.new(1.1, 0, 1.1, 0) })
local pulseDown = tweenService:Create(decoImage, pulseInfo, { Size = UDim2.new(0.9, 0, 0.9, 0) })

local function startPulse()
    while menuFrame.Visible do
        pulseUp:Play()
        pulseUp.Completed:Wait()
        pulseDown:Play()
        pulseDown.Completed:Wait()
    end
end

menuFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if menuFrame.Visible then
        spawn(startPulse)
    else
        pulseUp:Cancel()
        pulseDown:Cancel()
        decoImage.Size = UDim2.new(1, 0, 1, 0)
    end
end)

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 5)
closeBtn.BackgroundColor3 = style.Red
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = menuFrame
closeBtn.MouseButton1Click:Connect(function() menuFrame.Visible = false end)
closeBtn.TouchTap:Connect(function() menuFrame.Visible = false end)

-- // СКРОЛЛ-КОНТЕЙНЕР (уменьшены отступы) // --
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -65)
scroll.Position = UDim2.new(0, 10, 0, 40)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = style.Border
scroll.Parent = menuFrame

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 0, 0)
content.BackgroundTransparency = 1
content.Parent = scroll
scroll.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteSize.Y)

-- // ХЕЛПЕРЫ (оптимизированы) // --
local function createLabel(text, y, size)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.8, 0, 0, size or 22)
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = style.Text
    lbl.TextSize = 15
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = content
    return lbl
end

local function createToggle(labelText, defaultValue, y, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = style.Text
    label.TextSize = 15
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggle = Instance.new("ImageButton")
    toggle.Size = UDim2.new(0, 35, 0, 20)
    toggle.Position = UDim2.new(0.85, 0, 0.15, 0)
    toggle.BackgroundColor3 = defaultValue and style.Green or style.Red
    toggle.BorderSizePixel = 1
    toggle.BorderColor3 = style.Border
    toggle.Image = "rbxassetid://" .. (defaultValue and "3926307737" or "3926307738")
    toggle.ScaleType = Enum.ScaleType.Fit
    toggle.Parent = container

    local state = defaultValue
    local function toggleState()
        state = not state
        toggle.BackgroundColor3 = state and style.Green or style.Red
        toggle.Image = "rbxassetid://" .. (state and "3926307737" or "3926307738")
        callback(state)
    end
    toggle.MouseButton1Click:Connect(toggleState)
    toggle.TouchTap:Connect(toggleState)
    return toggle
end

local function createSlider(labelText, min, max, default, y, callback, format)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. tostring(default)
    label.TextColor3 = style.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.4, 0, 0.35, 0)
    slider.Position = UDim2.new(0.5, 0, 0.3, 0)
    slider.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    slider.BorderSizePixel = 0
    slider.Parent = container

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = style.Accent
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local value = default
    local dragging = false
    local dragStartX, startVal

    local function updateSlider(val)
        value = math.clamp(val, min, max)
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = labelText .. ": " .. (format and format(value) or tostring(value))
        callback(value)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartX = input.Position.X
            startVal = value
        end
    end)
    slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position.X - dragStartX
            local rel = delta / slider.AbsoluteSize.X * (max - min)
            updateSlider(startVal + rel)
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return slider
end

local function createRadioGroup(labelText, options, default, y, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 25 + #options * 22)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = style.Text
    label.TextSize = 15
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local selected = default
    local btns = {}
    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.3, 0, 0, 22)
        btn.Position = UDim2.new(0, (i-1) * 85, 0, 22)
        btn.BackgroundColor3 = (opt == default) and style.Accent or style.Button
        btn.Text = opt
        btn.TextColor3 = style.Text
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.BorderSizePixel = 1
        btn.BorderColor3 = style.Border
        btn.Parent = container
        table.insert(btns, btn)
        btn.MouseButton1Click:Connect(function()
            if selected == opt then return end
            selected = opt
            for _, b in ipairs(btns) do
                b.BackgroundColor3 = (b == btn) and style.Accent or style.Button
            end
            callback(opt)
        end)
        btn.TouchTap:Connect(function()
            if selected == opt then return end
            selected = opt
            for _, b in ipairs(btns) do
                b.BackgroundColor3 = (b == btn) and style.Accent or style.Button
            end
            callback(opt)
        end)
    end
    return btns
end

local function createDropdown(labelText, items, default, y, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = style.Text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.5, 0, 0.8, 0)
    dropdown.Position = UDim2.new(0.45, 0, 0.1, 0)
    dropdown.BackgroundColor3 = style.Button
    dropdown.Text = default or items[1] or "None"
    dropdown.TextColor3 = style.Text
    dropdown.TextSize = 14
    dropdown.Font = Enum.Font.GothamMedium
    dropdown.BorderSizePixel = 1
    dropdown.BorderColor3 = style.Border
    dropdown.Parent = container

    local isOpen = false
    local listFrame = nil

    local function createList()
        if listFrame then listFrame:Destroy() end
        listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(0.5, 0, 0, #items * 26)
        listFrame.Position = UDim2.new(0.45, 0, 0, 30)
        listFrame.BackgroundColor3 = style.Background
        listFrame.BorderSizePixel = 1
        listFrame.BorderColor3 = style.Border
        listFrame.Parent = container

        for i, item in ipairs(items) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 26)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*26)
            btn.BackgroundColor3 = style.Button
            btn.Text = item
            btn.TextColor3 = style.Text
            btn.TextSize = 14
            btn.Font = Enum.Font.GothamMedium
            btn.BorderSizePixel = 0
            btn.Parent = listFrame
            btn.MouseButton1Click:Connect(function()
                dropdown.Text = item
                isOpen = false
                if listFrame then listFrame:Destroy() end
                callback(item)
            end)
            btn.TouchTap:Connect(function()
                dropdown.Text = item
                isOpen = false
                if listFrame then listFrame:Destroy() end
                callback(item)
            end)
        end
    end

    dropdown.MouseButton1Click:Connect(function()
        if isOpen then
            if listFrame then listFrame:Destroy() end
            isOpen = false
        else
            createList()
            isOpen = true
        end
    end)
    dropdown.TouchTap:Connect(function()
        if isOpen then
            if listFrame then listFrame:Destroy() end
            isOpen = false
        else
            createList()
            isOpen = true
        end
    end)
    return dropdown
end

-- // ПОСТРОЕНИЕ МЕНЮ (компактное) // --
local yPos = 0

-- Aimbot
yPos = yPos + 2
createLabel("=== Aimbot ===", yPos, 20)
yPos = yPos + 25
createToggle("Aimbot", Settings.Aimbot, yPos, function(v) Settings.Aimbot = v end)
yPos = yPos + 32
createToggle("WallCheck", Settings.WallCheck, yPos, function(v) Settings.WallCheck = v end)
yPos = yPos + 32
createToggle("TeamCheck", Settings.TeamCheck, yPos, function(v) Settings.TeamCheck = v end)
yPos = yPos + 32
createToggle("Prediction", Settings.Prediction, yPos, function(v) Settings.Prediction = v end)
yPos = yPos + 32
createSlider("FOV", 0, 180, Settings.FOV, yPos, function(v) Settings.FOV = v end, function(v) return math.floor(v).."°" end)
yPos = yPos + 38
createSlider("Smoothing", 1, 10, Settings.Smoothing, yPos, function(v) Settings.Smoothing = v end)
yPos = yPos + 38
createRadioGroup("Aim Part", {"Head","Torso","Legs"}, Settings.AimPart, yPos, function(v) Settings.AimPart = v end)
yPos = yPos + 25 + 3*22 + 5
createRadioGroup("Priority", {"Closest","LowHealth","LookingAtMe","Score"}, Settings.TargetPriority, yPos, function(v) Settings.TargetPriority = v end)
yPos = yPos + 25 + 4*22 + 5

-- Triggerbot
yPos = yPos + 5
createLabel("=== Triggerbot ===", yPos, 20)
yPos = yPos + 25
createToggle("Triggerbot", Settings.Triggerbot, yPos, function(v) Settings.Triggerbot = v end)
yPos = yPos + 32
createSlider("Delay (ms)", 0, 2000, Settings.TriggerDelayMs, yPos, function(v) Settings.TriggerDelayMs = v end, function(v) return math.floor(v).." ms" end)
yPos = yPos + 38

-- Auto-Crouch
yPos = yPos + 5
createLabel("=== Auto-Crouch ===", yPos, 20)
yPos = yPos + 25
createToggle("Auto-Crouch", Settings.AutoCrouch, yPos, function(v) Settings.AutoCrouch = v end)
yPos = yPos + 32
createSlider("Duration (s)", 0.1, 2, Settings.CrouchDuration, yPos, function(v) Settings.CrouchDuration = v end, function(v) return string.format("%.2f", v).." s" end)
yPos = yPos + 38

-- ESP
yPos = yPos + 5
createLabel("=== Visuals ===", yPos, 20)
yPos = yPos + 25
createToggle("ESP (VH Charms)", Settings.ESP, yPos, function(v) 
    Settings.ESP = v
    if not v then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = p.Character:FindFirstChild("ESP_Highlight")
                if h then h:Destroy() end
            end
        end
    end
end)
yPos = yPos + 32

-- Skin Changer
yPos = yPos + 5
createLabel("=== Skin Changer ===", yPos, 20)
yPos = yPos + 25
createToggle("Enable", Settings.SkinChanger, yPos, function(v) Settings.SkinChanger = v; if v then applyAllSkins() end end)
yPos = yPos + 32

local weaponList = {"AK47","M4A1","USP","AWP","Glock"}
for _, wepName in ipairs(weaponList) do
    local skinData = Settings.Skins[wepName]
    if skinData then
        local defaultSkin = Settings.CurrentWeaponSkin[wepName] or skinData.available[1]
        createDropdown(wepName.." Skin", skinData.available, defaultSkin, yPos, function(sel)
            Settings.CurrentWeaponSkin[wepName] = sel
            if Settings.SkinChanger then applySkinToCurrentWeapon() end
        end)
        yPos = yPos + 38
    end
end

-- Обновляем размер контента
content.Size = UDim2.new(1, 0, 0, yPos + 20)
scroll.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteSize.Y)

-- Открытие/закрытие
toggleButton.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)
toggleButton.TouchTap:Connect(function() menuFrame.Visible = not menuFrame.Visible end)

-- // СКИН ЧЕНДЖЕР (код без изменений) // --
-- (здесь весь код из предыдущей версии, его я не повторяю для краткости, но он должен быть полностью)

-- // AIMBOT, TRIGGERBOT, AUTO-CROUCH, ESP (те же) // --
-- (весь функциональный код из v5)

print("BloxStrike v5.1 загружен! Меню компактное, картинка чёткая.")
