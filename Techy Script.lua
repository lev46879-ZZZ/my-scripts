-- // BLOXSTRIKE MOBILE SCRIPT v5 (с декоративной картинкой) // --
-- // Полный функционал + анимированный логотип // --

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")

-- // НАСТРОЙКИ ПО УМОЛЧАНИЮ // --
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

-- // СОЗДАНИЕ GUI // --
local gui = Instance.new("ScreenGui")
gui.Name = "BloxStrikeGUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local style = {
    Background = Color3.fromRGB(25, 25, 35),
    Border = Color3.fromRGB(80, 80, 120),
    Text = Color3.fromRGB(255, 255, 255),
    Button = Color3.fromRGB(60, 60, 90),
    ButtonHover = Color3.fromRGB(80, 80, 130),
    Accent = Color3.fromRGB(0, 180, 255),
    Green = Color3.fromRGB(0, 200, 100),
    Red = Color3.fromRGB(200, 50, 50)
}

-- Функция перетаскивания
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
toggleButton.Size = UDim2.new(0, 70, 0, 70)
toggleButton.Position = UDim2.new(0.9, -40, 0.05, 20)
toggleButton.BackgroundColor3 = style.Button
toggleButton.BorderSizePixel = 2
toggleButton.BorderColor3 = style.Border
toggleButton.Image = "rbxassetid://3926305904"
toggleButton.ImageColor3 = Color3.new(1,1,1)
toggleButton.ScaleType = Enum.ScaleType.Fit
toggleButton.Parent = gui
makeDraggable(toggleButton)

-- // ГЛАВНОЕ МЕНЮ // --
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 400, 0, 580) -- чуть выше, чтобы влезла картинка
menuFrame.Position = UDim2.new(0.5, -200, 0.3, -290)
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
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = style.Accent
title.BackgroundTransparency = 0.2
title.Text = "BLOXSTRIKE MENU v5"
title.TextColor3 = style.Text
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = menuFrame

-- // ДЕКОРАТИВНАЯ КАРТИНКА (с анимацией) // --
local decoContainer = Instance.new("Frame")
decoContainer.Size = UDim2.new(0, 70, 0, 70)
decoContainer.Position = UDim2.new(1, -85, 0, 5) -- справа от заголовка
decoContainer.BackgroundTransparency = 1
decoContainer.Parent = menuFrame

local decoImage = Instance.new("ImageLabel")
decoImage.Size = UDim2.new(1, 0, 1, 0)
decoImage.BackgroundColor3 = style.Border
decoImage.BorderSizePixel = 2
decoImage.BorderColor3 = style.Accent
decoImage.Image = "https://i.pinimg.com/originals/2d/32/eb/2d32eb18ea894362be2d8a83ba8af922.png" -- ★ ЗДЕСЬ ЗАМЕНИТЕ НА СВОЮ КАРТИНКУ ★
decoImage.ScaleType = Enum.ScaleType.Fit
decoImage.Parent = decoContainer

-- Скругление для картинки (круг)
local decoCorner = Instance.new("UICorner")
decoCorner.CornerRadius = UDim.new(1, 0)
decoCorner.Parent = decoImage

-- Анимация пульсации
local tweenService = game:GetService("TweenService")
local pulseInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local pulseUp = tweenService:Create(decoImage, pulseInfo, { Size = UDim2.new(1.1, 0, 1.1, 0) })
local pulseDown = tweenService:Create(decoImage, pulseInfo, { Size = UDim2.new(0.9, 0, 0.9, 0) })

-- Запускаем анимацию в цикле
local function startPulse()
    while menuFrame.Visible do
        pulseUp:Play()
        pulseUp.Completed:Wait()
        pulseDown:Play()
        pulseDown.Completed:Wait()
    end
end

-- Запускаем анимацию при открытии меню
menuFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if menuFrame.Visible then
        spawn(startPulse)
    else
        pulseUp:Cancel()
        pulseDown:Cancel()
        decoImage.Size = UDim2.new(1, 0, 1, 0) -- сброс размера
    end
end)

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = style.Red
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = menuFrame
closeBtn.MouseButton1Click:Connect(function() menuFrame.Visible = false end)
closeBtn.TouchTap:Connect(function() menuFrame.Visible = false end)

-- Скроллинг-контейнер (сдвинут вниз, чтобы не перекрывать картинку)
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -80) -- уменьшили высоту, чтобы освободить место для картинки
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = style.Border
scroll.Parent = menuFrame

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 0, 0)
content.BackgroundTransparency = 1
content.Parent = scroll
scroll.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteSize.Y)

-- Хелперы для GUI (те же самые)
local function createLabel(text, y, size)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.8, 0, 0, size or 25)
    lbl.Position = UDim2.new(0, 0, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = style.Text
    lbl.TextSize = 16
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = content
    return lbl
end

local function createToggle(labelText, defaultValue, y, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = style.Text
    label.TextSize = 17
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggle = Instance.new("ImageButton")
    toggle.Size = UDim2.new(0, 40, 0, 25)
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
    container.Size = UDim2.new(1, 0, 0, 40)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. tostring(default)
    label.TextColor3 = style.Text
    label.TextSize = 16
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.4, 0, 0.4, 0)
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
    container.Size = UDim2.new(1, 0, 0, 30 + #options * 25)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = style.Text
    label.TextSize = 17
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local selected = default
    local btns = {}
    for i, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.3, 0, 0, 25)
        btn.Position = UDim2.new(0, (i-1) * 95, 0, 25)
        btn.BackgroundColor3 = (opt == default) and style.Accent or style.Button
        btn.Text = opt
        btn.TextColor3 = style.Text
        btn.TextSize = 15
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
    container.Size = UDim2.new(1, 0, 0, 40)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = style.Text
    label.TextSize = 16
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.5, 0, 0.8, 0)
    dropdown.Position = UDim2.new(0.45, 0, 0.1, 0)
    dropdown.BackgroundColor3 = style.Button
    dropdown.Text = default or items[1] or "None"
    dropdown.TextColor3 = style.Text
    dropdown.TextSize = 15
    dropdown.Font = Enum.Font.GothamMedium
    dropdown.BorderSizePixel = 1
    dropdown.BorderColor3 = style.Border
    dropdown.Parent = container

    local isOpen = false
    local listFrame = nil

    local function createList()
        if listFrame then listFrame:Destroy() end
        listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(0.5, 0, 0, #items * 30)
        listFrame.Position = UDim2.new(0.45, 0, 0, 35)
        listFrame.BackgroundColor3 = style.Background
        listFrame.BorderSizePixel = 1
        listFrame.BorderColor3 = style.Border
        listFrame.Parent = container

        for i, item in ipairs(items) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*30)
            btn.BackgroundColor3 = style.Button
            btn.Text = item
            btn.TextColor3 = style.Text
            btn.TextSize = 15
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

-- // ПОСТРОЕНИЕ МЕНЮ // --
local yPos = 0

-- ===== Aimbot секция =====
yPos = yPos + 5
createLabel("=== Aimbot Settings ===", yPos, 25)
yPos = yPos + 30

local aimbotToggle = createToggle("Aimbot", Settings.Aimbot, yPos, function(v) Settings.Aimbot = v end)
yPos = yPos + 40

local wallToggle = createToggle("WallCheck", Settings.WallCheck, yPos, function(v) Settings.WallCheck = v end)
yPos = yPos + 40

local teamToggle = createToggle("TeamCheck", Settings.TeamCheck, yPos, function(v) Settings.TeamCheck = v end)
yPos = yPos + 40

local predToggle = createToggle("Prediction", Settings.Prediction, yPos, function(v) Settings.Prediction = v end)
yPos = yPos + 40

local fovSlider = createSlider("FOV", 0, 180, Settings.FOV, yPos, function(v) Settings.FOV = v end, function(v) return math.floor(v) .. "°" end)
yPos = yPos + 45

local smoothSlider = createSlider("Smoothing", 1, 10, Settings.Smoothing, yPos, function(v) Settings.Smoothing = v end)
yPos = yPos + 45

local aimPartBtns = createRadioGroup("Aim Part", {"Head", "Torso", "Legs"}, Settings.AimPart, yPos, function(v) Settings.AimPart = v end)
yPos = yPos + 30 + 3 * 25

local priorityBtns = createRadioGroup("Priority", {"Closest", "LowHealth", "LookingAtMe", "Score"}, Settings.TargetPriority, yPos, function(v) Settings.TargetPriority = v end)
yPos = yPos + 30 + 4 * 25

-- ===== Triggerbot секция =====
yPos = yPos + 10
createLabel("=== Triggerbot ===", yPos, 25)
yPos = yPos + 30

local triggerToggle = createToggle("Triggerbot", Settings.Triggerbot, yPos, function(v) Settings.Triggerbot = v end)
yPos = yPos + 40

local triggerDelaySlider = createSlider("Trigger Delay (ms)", 0, 2000, Settings.TriggerDelayMs, yPos, 
    function(v) Settings.TriggerDelayMs = v end,
    function(v) return math.floor(v) .. " ms" end
)
yPos = yPos + 45

-- ===== Auto-Crouch секция =====
yPos = yPos + 10
createLabel("=== Auto-Crouch ===", yPos, 25)
yPos = yPos + 30

local crouchToggle = createToggle("Auto-Crouch", Settings.AutoCrouch, yPos, function(v) Settings.AutoCrouch = v end)
yPos = yPos + 40

local crouchSlider = createSlider("Crouch Duration (s)", 0.1, 2, Settings.CrouchDuration, yPos, 
    function(v) Settings.CrouchDuration = v end,
    function(v) return string.format("%.2f", v) .. " s" end
)
yPos = yPos + 45

-- ===== ESP секция =====
yPos = yPos + 10
createLabel("=== Visuals ===", yPos, 25)
yPos = yPos + 30
local espToggle = createToggle("ESP (VH Charms)", Settings.ESP, yPos, function(v) 
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
yPos = yPos + 40

-- ===== Skin Changer секция =====
yPos = yPos + 10
createLabel("=== Skin Changer ===", yPos, 25)
yPos = yPos + 30

local skinToggle = createToggle("Enable Skin Changer", Settings.SkinChanger, yPos, function(v) 
    Settings.SkinChanger = v
    if v then applyAllSkins() end
end)
yPos = yPos + 40

local weaponList = {"AK47", "M4A1", "USP", "AWP", "Glock"}
for _, wepName in ipairs(weaponList) do
    local skinData = Settings.Skins[wepName]
    if skinData then
        local defaultSkin = Settings.CurrentWeaponSkin[wepName] or skinData.available[1]
        createDropdown(wepName .. " Skin", skinData.available, defaultSkin, yPos, function(selected)
            Settings.CurrentWeaponSkin[wepName] = selected
            if Settings.SkinChanger then
                applySkinToCurrentWeapon()
            end
        end)
        yPos = yPos + 45
    end
end

content.Size = UDim2.new(1, 0, 0, yPos + 30)
scroll.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteSize.Y)

-- Открытие/закрытие меню
toggleButton.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)
toggleButton.TouchTap:Connect(function() menuFrame.Visible = not menuFrame.Visible end)

-- // СКИН ЧЕНДЖЕР // --
local function getCurrentWeaponName()
    local char = player.Character
    if not char then return nil end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return nil end
    local name = tool.Name
    local weaponType = tool:GetAttribute("WeaponType") or name
    return weaponType
end

local function getSkinID(weapon, skinName)
    local fakeDB = {
        ["AK47"] = { ["Classic"] = "rbxassetid://1234567890", ["Red"] = "rbxassetid://1234567891", ["Blue"] = "rbxassetid://1234567892" },
        ["M4A1"] = { ["Classic"] = "rbxassetid://2234567890", ["Camo"] = "rbxassetid://2234567891" },
        ["USP"]  = { ["Default"] = "rbxassetid://3234567890", ["Silver"] = "rbxassetid://3234567891" },
        ["AWP"]  = { ["Sniper"] = "rbxassetid://4234567890", ["Dragon"] = "rbxassetid://4234567891" },
        ["Glock"]= { ["Standard"] = "rbxassetid://5234567890", ["Gold"] = "rbxassetid://5234567891" }
    }
    return fakeDB[weapon] and fakeDB[weapon][skinName] or "rbxassetid://1234567890"
end

local function applySkinToWeapon(weaponName)
    if not weaponName then return end
    local skinData = Settings.Skins[weaponName]
    if not skinData then return end
    local selectedSkin = Settings.CurrentWeaponSkin[weaponName]
    if not selectedSkin then
        selectedSkin = skinData.available[1]
        Settings.CurrentWeaponSkin[weaponName] = selectedSkin
    end
    local skinID = getSkinID(weaponName, selectedSkin)
    if not skinID then return end

    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return end
    local currentWeapon = getCurrentWeaponName()
    if currentWeapon ~= weaponName then return end

    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            local appearance = part:FindFirstChildWhichIsA("SurfaceAppearance")
            if appearance then
                appearance.ColorMap = skinID
            end
            for _, decal in ipairs(part:GetChildren()) do
                if decal:IsA("Decal") then
                    decal.Texture = skinID
                end
            end
        end
    end
end

local function applyAllSkins()
    for wepName, _ in pairs(Settings.Skins) do
        applySkinToWeapon(wepName)
    end
end

local function applySkinToCurrentWeapon()
    local wepName = getCurrentWeaponName()
    if wepName then
        applySkinToWeapon(wepName)
    end
end

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Settings.SkinChanger then
        applySkinToCurrentWeapon()
    end
end)

player:GetPropertyChangedSignal("Character"):Connect(function()
    if Settings.SkinChanger then
        task.wait(0.5)
        applySkinToCurrentWeapon()
    end
end)

local function onToolEquipped(tool)
    if Settings.SkinChanger then
        task.wait(0.1)
        applySkinToCurrentWeapon()
    end
end

player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            onToolEquipped(child)
        end
    end)
end)

-- // AIMBOT // --
local function getTarget()
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
        return nil
    end
    local camPos = camera.CFrame.Position
    local camLook = camera.CFrame.LookVector

    local candidates = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck then
                local myTeam = player.Team
                local theirTeam = plr.Team
                if myTeam and theirTeam and myTeam == theirTeam then
                    continue
                end
            end
            local targetChar = plr.Character
            local targetPart = targetChar:FindFirstChild(Settings.AimPart)
            if not targetPart then
                if Settings.AimPart == "Head" then targetPart = targetChar:FindFirstChild("Head") end
                if not targetPart then targetPart = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or targetChar.PrimaryPart end
            end
            if targetPart then
                local pos = targetPart.Position
                local dir = (pos - camPos).Unit
                local angle = math.acos(math.clamp(camLook:Dot(dir), -1, 1))
                if angle <= math.rad(Settings.FOV) then
                    if Settings.WallCheck then
                        local ray = Ray.new(camPos, (pos - camPos))
                        local hit = workspace:FindPartOnRay(ray, char, false, true)
                        if hit and not hit:IsDescendantOf(targetChar) then
                            continue
                        end
                    end
                    local dist = (pos - camPos).Magnitude
                    local health = targetChar.Humanoid.Health
                    local lookingAtMe = false
                    local head = targetChar:FindFirstChild("Head")
                    if head then
                        local lookDir = (head.CFrame.LookVector).Unit
                        local toUs = (camPos - head.Position).Unit
                        if lookDir:Dot(toUs) > 0.5 then
                            lookingAtMe = true
                        end
                    end
                    local score = 0
                    table.insert(candidates, {
                        Player = plr,
                        Part = targetPart,
                        Distance = dist,
                        Health = health,
                        LookingAtMe = lookingAtMe,
                        Score = score,
                        Angle = angle
                    })
                end
            end
        end
    end

    if #candidates == 0 then return nil end

    local priority = Settings.TargetPriority
    table.sort(candidates, function(a, b)
        if priority == "Closest" then
            return a.Distance < b.Distance
        elseif priority == "LowHealth" then
            return a.Health < b.Health
        elseif priority == "LookingAtMe" then
            if a.LookingAtMe and not b.LookingAtMe then return true end
            if not a.LookingAtMe and b.LookingAtMe then return false end
            return a.Distance < b.Distance
        elseif priority == "Score" then
            return a.Score > b.Score
        else
            return a.Distance < b.Distance
        end
    end)

    return candidates[1]
end

local function getPredictedPosition(targetPart, bulletSpeed)
    if not Settings.Prediction then
        return targetPart.Position
    end
    local char = player.Character
    if not char then return targetPart.Position end
    local root = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
    if not root then return targetPart.Position end
    local dist = (targetPart.Position - root.Position).Magnitude
    local time = dist / (bulletSpeed or 800)
    local velocity = targetPart.Velocity or Vector3.new(0,0,0)
    return targetPart.Position + velocity * time
end

runService.RenderStepped:Connect(function()
    if not Settings.Aimbot then return end

    local target = getTarget()
    if not target then return end

    local targetPart = target.Part
    local bulletSpeed = 800
    local aimPos = getPredictedPosition(targetPart, bulletSpeed)

    local camCF = camera.CFrame
    local direction = (aimPos - camCF.Position).Unit
    local targetCF = CFrame.lookAt(camCF.Position, camCF.Position + direction)

    local smoothing = Settings.Smoothing
    if smoothing > 1 then
        local alpha = 1 - (1 / (smoothing * 2))
        local lerpCF = camCF:Lerp(targetCF, alpha)
        camera.CFrame = lerpCF
    else
        camera.CFrame = targetCF
    end
end)

-- // TRIGGERBOT // --
local triggerCooldown = false

local function triggerShoot()
    if triggerCooldown then return end
    local target = getTarget()
    if not target then return end

    local camCF = camera.CFrame
    local dirToTarget = (target.Part.Position - camCF.Position).Unit
    local angle = math.acos(math.clamp(camCF.LookVector:Dot(dirToTarget), -1, 1))
    if angle > math.rad(5) then return end

    local delay = Settings.TriggerDelayMs / 1000
    triggerCooldown = true
    task.wait(delay)
    if Settings.Triggerbot then
        mouse1click()
    end
    triggerCooldown = false
end

game:GetService("RunService").Heartbeat:Connect(function()
    if Settings.Triggerbot and not triggerCooldown then
        triggerShoot()
    end
end)

-- // AUTO-CROUCH // --
local crouchActive = false
local crouchTimer = nil

local function setCrouch(state)
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid.Crouch = state
end

userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not Settings.AutoCrouch then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        setCrouch(true)
        crouchActive = true
        if crouchTimer then crouchTimer:Disconnect() end
        crouchTimer = nil
    end
end)

userInput.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not Settings.AutoCrouch then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if crouchActive then
            crouchTimer = task.wait(Settings.CrouchDuration)
            setCrouch(false)
            crouchActive = false
            crouchTimer = nil
        end
    end
end)

player.CharacterAdded:Connect(function()
    if crouchActive then
        setCrouch(false)
        crouchActive = false
        if crouchTimer then crouchTimer:Disconnect() end
        crouchTimer = nil
    end
end)

-- // ESP // --
local function updateESP()
    if not Settings.ESP then return end
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local highlight = char:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.FillTransparency = 0.4
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineTransparency = 0.3
                highlight.Parent = char
            end
        end
    end
end

runService.RenderStepped:Connect(function()
    if Settings.ESP then updateESP() end
end)

game.Players.PlayerAdded:Connect(function()
    if Settings.ESP then task.wait(0.5) updateESP() end
end)

print("BloxStrike Mobile v5 загружен! Добавлен декоративный логотип с анимацией.")
