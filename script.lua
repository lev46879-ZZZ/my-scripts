-- Проверяем, загружена ли игра
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- Настройки внешнего вида крыльев
local WING_COLOR = Color3.fromRGB(0, 255, 255) -- Бирюзовый неон (можно изменить)
local WING_MATERIAL = Enum.Material.Neon
local WING_SIZE = Vector3.new(0.2, 5, 2)       -- Размер одного крыла

-- Очистка старых крыльев, если скрипт запущен повторно
if _G.WingsConnection then _G.WingsConnection:Disconnect() end
if localPlayer.Character and localPlayer.Character:FindFirstChild("LocalWingsFolder") then
    localPlayer.Character.LocalWingsFolder:Destroy()
end

local function createLocalWings(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not root then return end

    -- Создаем локальную папку для крыльев (все внутри нее будет невидимо для сервера)
    local folder = Instance.new("Folder")
    folder.Name = "LocalWingsFolder"
    folder.Parent = character

    -- Функция создания одного крыла
    local function makeWing(side)
        local wing = Instance.new("Part")
        wing.Name = side .. "Wing"
        wing.Size = WING_SIZE
        wing.Color = WING_COLOR
        wing.Material = WING_MATERIAL
        wing.CanCollide = false
        wing.Massless = true
        wing.Parent = folder

        local motor = Instance.new("Motor6D")
        motor.Name = side .. "Motor"
        motor.Part0 = root
        motor.Part1 = wing
        motor.Parent = root

        return motor
    end

    local leftMotor = makeWing("Left")
    local rightMotor = makeWing("Right")

    -- Переменная для анимации махов
    local counter = 0

    -- Плавная анимация на стороне клиента
    local connection
    connection = RunService.RenderStepped:Connect(function(dt)
        -- Проверка, жив ли персонаж и существуют ли крылья
        if not character or not character:Parent() or not folder or not folder:Parent() then
            connection:Disconnect()
            return
        end

        counter = counter + (dt * 4) -- Скорость махов крыльев

        -- Базовое смещение крыльев за спину
        local baseLeftC0 = CFrame.new(-0.8, 1, 0.6) * CFrame.Angles(0, math.rad(-20), math.rad(-15))
        local baseRightC0 = CFrame.new(0.8, 1, 0.6) * CFrame.Angles(0, math.rad(20), math.rad(15))

        -- Математический просчет махов (синусоида)
        local swing = math.sin(counter) * 0.3

        leftMotor.C0 = baseLeftC0 * CFrame.Angles(0, swing, 0)
        rightMotor.C0 = baseRightC0 * CFrame.Angles(0, -swing, 0)
    end)

    _G.WingsConnection = connection

    -- Автоочистка при смерти
    humanoid.Died:Connect(function()
        if connection then connection:Disconnect() end
        folder:Destroy()
    end)
end

-- Запуск при выполнении скрипта
if localPlayer.Character then
    createLocalWings(localPlayer.Character)
end

-- Перезапуск при респавне персонажа
localPlayer.CharacterAdded:Connect(createLocalWings)
