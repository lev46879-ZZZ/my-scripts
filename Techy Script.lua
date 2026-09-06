-- // BLOXSTRIKE MOBILE SCRIPT v2 (Улучшенный Aimbot) // --
-- // Полный набор функций с гибкой настройкой // --

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")

-- // НАСТРОЙКИ ПО УМОЛЧАНИЮ // --
local Settings = {
    -- Aimbot основные
    Aimbot = false,
    FOV = 120,                 -- градусы
    WallCheck = false,
    Smoothing = 3,             -- 1..10 (1 - резко, 10 - плавно)
    Prediction = false,
    TargetPriority = "Closest", -- Closest, LowHealth, LookingAtMe, Score
    AimPart = "Head",          -- Head, Torso, Legs
    AutoShoot = false,
    RecoilCompensation = false, -- (пока декоративно)
    -- ESP
    ESP = false,
    -- Skin Changer
    SkinChanger = false,
    SkinID = "rbxassetid://1234567890"
}

-- // СОЗДАНИЕ GUI // --
local gui = Instance.new("ScreenGui")
gui.Name = "BloxStrikeGUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- Стили
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

-- Функция для создания плавающего элемента (перетаскивание)
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

-- // ПЛАВАЮЩАЯ КНОПКА ОТКРЫТИЯ МЕНЮ // --
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

-- // ГЛАВНОЕ МЕНЮ (с прокруткой) // --
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 380, 0, 500)
menuFrame.Position = UDim2.new(0.5, -190, 0.3, -250)
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
title.Text = "BLOXSTRIKE MENU v2"
title.TextColor3 = style.Text
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = menuFrame

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

-- Скроллинг-контейнер для элементов
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0) -- будет расширяться
scroll.ScrollBarThickness = 8
scroll.ScrollBarImageColor3 = style.Border
scroll.Parent = menuFrame

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 0, 0)
content.BackgroundTransparency = 1
content.Parent = scroll
scroll.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteSize.Y)

-- Хелперы для построения интерфейса
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
        btn.Position = UDim2.new(0, i * 95, 0, 25)
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

-- Строим меню
local yPos = 0

-- Секция Aimbot
yPos = yPos + 5
createLabel("=== Aimbot Settings ===", yPos, 25)
yPos = yPos + 30

local aimbotToggle = createToggle("Aimbot", Settings.Aimbot, yPos, function(v) Settings.Aimbot = v end)
yPos = yPos + 40

local wallToggle = createToggle("WallCheck", Settings.WallCheck, yPos, function(v) Settings.WallCheck = v end)
yPos = yPos + 40

local autoShootToggle = createToggle("Auto-Shoot", Settings.AutoShoot, yPos, function(v) Settings.AutoShoot = v end)
yPos = yPos + 40

local predToggle = createToggle("Prediction", Settings.Prediction, yPos, function(v) Settings.Prediction = v end)
yPos = yPos + 40

-- Ползунок FOV
local fovSlider = createSlider("FOV", 0, 180, Settings.FOV, yPos, function(v) Settings.FOV = v end, function(v) return math.floor(v) .. "°" end)
yPos = yPos + 45

-- Ползунок Smoothing
local smoothSlider = createSlider("Smoothing", 1, 10, Settings.Smoothing, yPos, function(v) Settings.Smoothing = v end)
yPos = yPos + 45

-- Радио-группа AimPart
local aimPartBtns = createRadioGroup("Aim Part", {"Head", "Torso", "Legs"}, Settings.AimPart, yPos, function(v) Settings.AimPart = v end)
yPos = yPos + 30 + 3 * 25

-- Радио-группа Priority
local priorityBtns = createRadioGroup("Priority", {"Closest", "LowHealth", "LookingAtMe", "Score"}, Settings.TargetPriority, yPos, function(v) Settings.TargetPriority = v end)
yPos = yPos + 30 + 4 * 25

-- Секция ESP
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

-- Секция Skin Changer
yPos = yPos + 10
createLabel("=== Skins ===", yPos, 25)
yPos = yPos + 30
local skinToggle = createToggle("Skin Changer", Settings.SkinChanger, yPos, function(v) Settings.SkinChanger = v end)
yPos = yPos + 40

-- Обновляем размер контента
content.Size = UDim2.new(1, 0, 0, yPos + 30)
scroll.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteSize.Y)

-- Открытие/закрытие меню
toggleButton.MouseButton1Click:Connect(function() menuFrame.Visible = not menuFrame.Visible end)
toggleButton.TouchTap:Connect(function() menuFrame.Visible = not menuFrame.Visible end)

-- // СКИН ЧЕНДЖЕР // --
local function applySkinToWeapon()
    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return end
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            local appearance = part:FindFirstChildWhichIsA("SurfaceAppearance")
            if appearance and appearance:IsA("SurfaceAppearance") then
                appearance.ColorMap = Settings.SkinID
            end
            for _, decal in ipairs(part:GetChildren()) do
                if decal:IsA("Decal") then
                    decal.Texture = Settings.SkinID
                end
            end
        end
    end
end

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Settings.SkinChanger then applySkinToWeapon() end
end)
player:GetPropertyChangedSignal("Character"):Connect(function()
    if Settings.SkinChanger then
        task.wait(0.5)
        applySkinToWeapon()
    end
end)

-- // УЛУЧШЕННЫЙ AIMBOT // --
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
                    -- WallCheck
                    if Settings.WallCheck then
                        local ray = Ray.new(camPos, (pos - camPos))
                        local hit = workspace:FindPartOnRay(ray, char, false, true)
                        if hit and not hit:IsDescendantOf(targetChar) then
                            continue
                        end
                    end
                    -- Собираем данные
                    local dist = (pos - camPos).Magnitude
                    local health = targetChar.Humanoid.Health
                    local lookingAtMe = false
                    -- проверяем, смотрит ли враг на нас
                    local head = targetChar:FindFirstChild("Head")
                    if head then
                        local lookDir = (head.CFrame.LookVector).Unit
                        local toUs = (camPos - head.Position).Unit
                        if lookDir:Dot(toUs) > 0.5 then
                            lookingAtMe = true
                        end
                    end
                    local score = 0 -- можно взять из лидерстатов
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

    -- Выбор по приоритету
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

-- Предсказание
local function getPredictedPosition(targetPart, bulletSpeed)
    if not Settings.Prediction then
        return targetPart.Position
    end
    local char = player.Character
    if not char then return targetPart.Position end
    local root = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
    if not root then return targetPart.Position end
    local dist = (targetPart.Position - root.Position).Magnitude
    local time = dist / (bulletSpeed or 800) -- скорость пули по умолчанию
    local velocity = targetPart.Velocity or Vector3.new(0,0,0)
    return targetPart.Position + velocity * time
end

-- Компенсация отдачи (упрощённо: сдвиг вниз на 0.3 градуса)
local recoilOffset = 0
local function applyRecoil()
    if Settings.RecoilCompensation then
        recoilOffset = recoilOffset - 0.3
    end
end

-- Автострельба
local function shoot()
    -- Эмулируем нажатие левой кнопки мыши
    mouse1click()
    -- или используем InputService для эмуляции
end

-- Основной цикл аимбота
runService.RenderStepped:Connect(function()
    if not Settings.Aimbot then return end

    local target = getTarget()
    if not target then return end

    local targetPart = target.Part
    local bulletSpeed = 800 -- можно получать из оружия, но для простоты константа
    local aimPos = getPredictedPosition(targetPart, bulletSpeed)

    local camCF = camera.CFrame
    local direction = (aimPos - camCF.Position).Unit
    local targetCF = CFrame.lookAt(camCF.Position, camCF.Position + direction)

    -- Сглаживание
    local smoothing = Settings.Smoothing
    if smoothing > 1 then
        local alpha = 1 - (1 / (smoothing * 2))
        local lerpCF = camCF:Lerp(targetCF, alpha)
        camera.CFrame = lerpCF
    else
        camera.CFrame = targetCF
    end

    -- Автострельба
    if Settings.AutoShoot then
        local angle = math.acos(math.clamp(camCF.LookVector:Dot(direction), -1, 1))
        if angle <= math.rad(5) then -- если почти наведён
            shoot()
        end
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

print("BloxStrike Mobile v2 загружен! Наслаждайтесь улучшенным аимботом.")
