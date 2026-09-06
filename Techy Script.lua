-- // BLOXSTRIKE MOBILE SCRIPT // --
-- // Работает на телефоне: плавающая кнопка и меню // --
-- // Функции: Aimbot, Wallcheck, ESP (VH Charms), Skin Changer // --

-- // Настройки по умолчанию // --
local Settings = {
    Aimbot = false,
    FOV = 120,                 -- градусы
    WallCheck = false,
    ESP = false,
    SkinChanger = false,
    SkinID = "rbxassetid://1234567890" -- замените на ID вашего скина
}

-- // Создание GUI // --
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Глобальный ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "BloxStrikeGUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

-- Стили
local function createStyle()
    local styles = {
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BorderColor3 = Color3.fromRGB(80, 80, 120),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        ButtonColor = Color3.fromRGB(60, 60, 90),
        ButtonHover = Color3.fromRGB(80, 80, 130),
        AccentColor = Color3.fromRGB(0, 180, 255)
    }
    return styles
end
local style = createStyle()

-- // Плавающая кнопка (открытие/закрытие меню) // --
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 70, 0, 70)
toggleButton.Position = UDim2.new(0.9, -40, 0.05, 20) -- справа вверху
toggleButton.BackgroundColor3 = style.ButtonColor
toggleButton.BorderSizePixel = 2
toggleButton.BorderColor3 = style.BorderColor3
toggleButton.Image = "rbxassetid://3926305904" -- иконка шестерёнки
toggleButton.ImageColor3 = Color3.new(1,1,1)
toggleButton.ScaleType = Enum.ScaleType.Fit
toggleButton.Parent = gui

-- Перетаскивание кнопки (для телефона через Touch)
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end

    local function onInputChanged(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            local pos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            frame.Position = pos
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end

    frame.InputBegan:Connect(onInputBegan)
    frame.InputChanged:Connect(onInputChanged)
    frame.InputEnded:Connect(onInputEnded)
end

makeDraggable(toggleButton)

-- // Главное меню // --
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 360, 0, 400)
menuFrame.Position = UDim2.new(0.5, -180, 0.4, -200) -- центр
menuFrame.BackgroundColor3 = style.BackgroundColor3
menuFrame.BorderSizePixel = 3
menuFrame.BorderColor3 = style.BorderColor3
menuFrame.Visible = false
menuFrame.Parent = gui
makeDraggable(menuFrame) -- меню тоже можно перетаскивать

-- Скругление углов (для красоты)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = menuFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = style.AccentColor
title.BackgroundTransparency = 0.2
title.Text = "BLOXSTRIKE MENU"
title.TextColor3 = style.TextColor3
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = menuFrame

-- Контейнер для элементов (скроллинг не нужен, все помещается)
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -60)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundTransparency = 1
content.Parent = menuFrame

-- Функция для создания переключателя
local function createToggle(labelText, defaultValue, yPos, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = style.TextColor3
    label.TextSize = 18
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggle = Instance.new("ImageButton")
    toggle.Size = UDim2.new(0, 40, 0, 25)
    toggle.Position = UDim2.new(0.85, 0, 0.15, 0)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(150, 50, 50)
    toggle.BorderSizePixel = 1
    toggle.BorderColor3 = style.BorderColor3
    toggle.Image = "rbxassetid://" .. (defaultValue and "3926307737" or "3926307738") -- переключатель вкл/выкл
    toggle.ScaleType = Enum.ScaleType.Fit
    toggle.Parent = container

    local state = defaultValue
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(150, 50, 50)
        toggle.Image = "rbxassetid://" .. (state and "3926307737" or "3926307738")
        callback(state)
    end)
    -- для телефона
    toggle.TouchTap:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(150, 50, 50)
        toggle.Image = "rbxassetid://" .. (state and "3926307737" or "3926307738")
        callback(state)
    end)
    return toggle
end

-- Aimbot
local aimbotToggle = createToggle("Aimbot", Settings.Aimbot, 0, function(val)
    Settings.Aimbot = val
end)

-- WallCheck
local wallToggle = createToggle("WallCheck", Settings.WallCheck, 40, function(val)
    Settings.WallCheck = val
end)

-- ESP (VH Charms)
local espToggle = createToggle("VH Charms", Settings.ESP, 80, function(val)
    Settings.ESP = val
    if not val then
        -- убираем все Highlights
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character then
                local highlight = v.Character:FindFirstChild("ESP_Highlight")
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

-- Skin Changer
local skinToggle = createToggle("Skin Changer", Settings.SkinChanger, 120, function(val)
    Settings.SkinChanger = val
    if val then
        applySkinToWeapon()
    else
        -- сброс скина (возврат к оригиналу) - сложно, оставим как есть, или перезагрузить оружие
        -- Можно попробовать удалить оружие и дать заново, но это небезопасно. 
        -- Для простоты просто не применяем скин.
    end
end)

-- Ползунок FOV
local fovContainer = Instance.new("Frame")
fovContainer.Size = UDim2.new(1, 0, 0, 45)
fovContainer.Position = UDim2.new(0, 0, 0, 165)
fovContainer.BackgroundTransparency = 1
fovContainer.Parent = content

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0.5, 0, 1, 0)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: " .. Settings.FOV
fovLabel.TextColor3 = style.TextColor3
fovLabel.TextSize = 18
fovLabel.Font = Enum.Font.GothamMedium
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = fovContainer

local fovSlider = Instance.new("Frame")
fovSlider.Size = UDim2.new(0.4, 0, 0.4, 0)
fovSlider.Position = UDim2.new(0.5, 0, 0.3, 0)
fovSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
fovSlider.BorderSizePixel = 0
fovSlider.Parent = fovContainer

local fovFill = Instance.new("Frame")
fovFill.Size = UDim2.new(Settings.FOV / 180, 0, 1, 0) -- 180 максимум
fovFill.BackgroundColor3 = style.AccentColor
fovFill.BorderSizePixel = 0
fovFill.Parent = fovSlider

local function updateFOV(value)
    value = math.clamp(value, 0, 180)
    Settings.FOV = value
    fovLabel.Text = "FOV: " .. math.floor(value)
    fovFill.Size = UDim2.new(value / 180, 0, 1, 0)
end

-- Перетаскивание ползунка (для телефона)
local draggingFOV = false
local dragStartX = 0
local sliderPos = 0

fovSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        draggingFOV = true
        dragStartX = input.Position.X
        sliderPos = fovFill.Size.X.Scale * 180
    end
end)

fovSlider.InputChanged:Connect(function(input)
    if draggingFOV and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position.X - dragStartX
        local newVal = math.clamp(sliderPos + delta / fovSlider.AbsoluteSize.X * 180, 0, 180)
        updateFOV(newVal)
    end
end)

fovSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        draggingFOV = false
    end
end)

-- Кнопка закрытия меню
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = menuFrame
closeBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
end)
closeBtn.TouchTap:Connect(function()
    menuFrame.Visible = false
end)

-- Открытие/закрытие меню по кнопке
toggleButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)
toggleButton.TouchTap:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

-- // СКИН ЧЕНДЖЕР // --
local function applySkinToWeapon()
    -- Ищем оружие в руках игрока
    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then return end
    -- Пытаемся изменить текстуру или MeshId, в зависимости от структуры
    -- Часто оружие состоит из Parts с SurfaceAppearance
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Меняем TextureID у SurfaceAppearance если есть
            local appearance = part:FindFirstChildWhichIsA("SurfaceAppearance")
            if appearance and appearance:IsA("SurfaceAppearance") then
                appearance.ColorMap = Settings.SkinID
            end
            -- или меняем у Texture
            if part:IsA("Part") and part.Material == Enum.Material.SmoothPlastic then
                -- некоторые используют TextureId в свойствах
                -- например, если есть Decal
                for _, decal in ipairs(part:GetChildren()) do
                    if decal:IsA("Decal") then
                        decal.Texture = Settings.SkinID
                    end
                end
            end
        end
    end
end

-- Вызываем при активации скинченджера или при смене оружия
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Settings.SkinChanger then
        applySkinToWeapon()
    end
end)

-- Обработка смены инструмента
player:GetPropertyChangedSignal("Character"):Connect(function()
    if Settings.SkinChanger then
        task.wait(0.5)
        applySkinToWeapon()
    end
end)

-- // ОСНОВНЫЕ ФУНКЦИИ: AIMBOT + WALLCHECK + ESP // --

-- Функция получения ближайшего врага в FOV
local function getClosestEnemy()
    local char = player.Character
    if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
        return nil
    end
    local cameraPos = camera.CFrame.Position
    local cameraLook = camera.CFrame.LookVector

    local closest = nil
    local closestAngle = math.rad(Settings.FOV) -- в радианах

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local targetChar = plr.Character
            -- голова или торс
            local head = targetChar:FindFirstChild("Head")
            local torso = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
            local targetPart = head or torso or targetChar.PrimaryPart
            if targetPart then
                local targetPos = targetPart.Position
                local dirToTarget = (targetPos - cameraPos).Unit
                local angle = math.acos(math.clamp(cameraLook:Dot(dirToTarget), -1, 1))

                -- WallCheck
                if Settings.WallCheck then
                    local ray = Ray.new(cameraPos, (targetPos - cameraPos))
                    local hit, position = workspace:FindPartOnRay(ray, char, false, true)
                    if hit and hit:IsDescendantOf(targetChar) then
                        -- видим, нет стены
                    else
                        -- стена закрывает
                        continue
                    end
                end

                if angle <= closestAngle then
                    closestAngle = angle
                    closest = {Player = plr, Part = targetPart}
                end
            end
        end
    end
    return closest
end

-- Aimbot: наводим камеру на цель
local function aimbot()
    if not Settings.Aimbot then return end
    local target = getClosestEnemy()
    if target then
        local targetPos = target.Part.Position
        -- вычисляем направление от камеры к цели
        local camCF = camera.CFrame
        local direction = (targetPos - camCF.Position).Unit
        local newCF = CFrame.lookAt(camCF.Position, camCF.Position + direction)
        camera.CFrame = newCF
    end
end

-- ESP (VH Charms) - добавляем Highlight всем игрокам
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
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineTransparency = 0.3
                highlight.Parent = char
            end
        end
    end
end

-- Цикл обновления (каждый кадр)
game:GetService("RunService").RenderStepped:Connect(function()
    -- Aimbot
    if Settings.Aimbot then
        aimbot()
    end
    -- ESP
    if Settings.ESP then
        updateESP()
    else
        -- удаляем старые, если отключено (уже удаляем при отключении)
    end
end)

-- Дополнительно: обновление ESP при добавлении/удалении игроков
game.Players.PlayerAdded:Connect(function()
    if Settings.ESP then updateESP() end
end)
game.Players.PlayerRemoving:Connect(function()
    -- ничего не делаем
end)

-- // ИНИЦИАЛИЗАЦИЯ // --
print("BloxStrike Mobile Script loaded successfully!")
