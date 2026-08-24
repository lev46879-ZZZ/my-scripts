-- ======================================================================
-- [1] ROBLOX VISUAL HUB & LOADER SYSTEM (Combined & Fixed)
-- ======================================================================
local Loader = {}
Loader.Version = "2.5.0"
Loader.Loaded = false

function Loader:Init()
    print("[LOADER] Initializing Visual Hub v" .. self.Version)
    
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    if not LocalPlayer then
        warn("[LOADER ERROR] LocalPlayer not found, waiting...")
        LocalPlayer = Players.PlayerAdded:Wait()
    end
    
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not PlayerGui then
        warn("[LOADER ERROR] PlayerGui not accessible!")
        return false
    end
    
    -- Очистка старых копий GUI при повторном запуске, чтобы не было дублей
    if PlayerGui:FindFirstChild("VisualCustomizerGui") then
        PlayerGui.VisualCustomizerGui:Destroy()
    end
    
    self.Loaded = true
    print("[LOADER SUCCESS] Initialization complete. Building UI...")
    return true
end

if not Loader:Init() then return end

--------------------------------------------------------------------------------
-- [2] SERVICES & VARIABLES
--------------------------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- [3] GUI CREATION & STYLING
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VisualCustomizerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 440)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 120)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Title.Text = "✨ VISUAL HUB v" .. Loader.Version
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = Title

-- Кнопка закрытия интерфейса
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Title

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--------------------------------------------------------------------------------
-- [4] HELPER FUNCTIONS (Создание элементов управления)
--------------------------------------------------------------------------------
local function CreateButton(text, positionY, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.88, 0, 0, 42)
    Btn.Position = UDim2.new(0.06, 0, 0, positionY)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(220, 220, 240)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = MainFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        callback(Btn)
    end)
    return Btn
end

--------------------------------------------------------------------------------
-- [5] РЕАЛИЗАЦИЯ ВИЗУАЛЬНЫХ ЭФФЕКТОВ
--------------------------------------------------------------------------------

-- 1. Анимированная Аура
local auraActive = false
local auraConnection = nil
local auraHighlight = nil

local function ToggleAura(btn)
    auraActive = not auraActive
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    if auraActive then
        btn.BackgroundColor3 = Color3.fromRGB(50, 160, 90)
        
        auraHighlight = Instance.new("Highlight")
        auraHighlight.Name = "VisualAura"
        auraHighlight.FillColor = Color3.fromRGB(120, 180, 255)
        auraHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        auraHighlight.FillTransparency = 0.5
        auraHighlight.Parent = character
        
        -- Плавная смена цветов ауры через цикл
        local hue = 0
        auraConnection = RunService.RenderStepped:Connect(function(dt)
            if auraHighlight and auraHighlight.Parent then
                hue = (hue + dt * 0.2) % 1
                auraHighlight.FillColor = Color3.fromHSV(hue, 0.8, 1)
            end
        end)
        print("[Visuals] Animated Aura enabled.")
    else
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        if auraConnection then auraConnection:Disconnect() end
        if auraHighlight then auraHighlight:Destroy() end
        print("[Visuals] Animated Aura disabled.")
    end
end

CreateButton("✨ Toggle Animated Aura", 70, ToggleAura)


-- 2. Крылья (Ангел / Демон)
local wingsActive = false
local wingsModel = nil

local function ToggleWings(btn)
    wingsActive = not wingsActive
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    
    if wingsActive then
        btn.BackgroundColor3 = Color3.fromRGB(50, 160, 90)
        if torso then
            wingsModel = Instance.new("Model")
            wingsModel.Name = "CustomWings"
            
            -- Левое крыло
            local leftWing = Instance.new("Part")
            leftWing.Size = Vector3.new(0.5, 3, 1.5)
            leftWing.Color = Color3.fromRGB(240, 240, 255)
            leftWing.Material = Enum.Material.Neon
            leftWing.CFrame = torso.CFrame * CFrame.new(-1, 1, 0.5) * CFrame.Angles(0, 0, math.rad(-15))
            leftWing.Parent = wingsModel
            
            local w1 = Instance.new("WeldConstraint")
            w1.Part0 = torso
            w1.Part1 = leftWing
            w1.Parent = leftWing
            
            -- Правое крыло
            local rightWing = Instance.new("Part")
            rightWing.Size = Vector3.new(0.5, 3, 1.5)
            rightWing.Color = Color3.fromRGB(240, 240, 255)
            rightWing.Material = Enum.Material.Neon
            rightWing.CFrame = torso.CFrame * CFrame.new(1, 1, 0.5) * CFrame.Angles(0, 0, math.rad(15))
            rightWing.Parent = wingsModel
            
            local w2 = Instance.new("WeldConstraint")
            w2.Part0 = torso
            w2.Part1 = rightWing
            w2.Parent = rightWing
            
            wingsModel.Parent = character
        end
        print("[Visuals] Wings attached.")
    else
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        if wingsModel then wingsModel:Destroy() end
        print("[Visuals] Wings removed.")
    end
end

CreateButton("🦅 Toggle Angel/Demon Wings", 125, ToggleWings)


-- 3. Кастомная Погода / Окружение
local weatherActive = false
local originalBrightness = Lighting.Brightness

local function ToggleWeather(btn)
    weatherActive = not weatherActive
    
    if weatherActive then
        btn.BackgroundColor3 = Color3.fromRGB(50, 160, 90)
        Lighting.ClockTime = 0 -- Ночь
        Lighting.Brightness = 0.5
        Lighting.OutdoorAmbient = Color3.fromRGB(40, 40, 80)
        print("[Visuals] Custom Atmosphere applied.")
    else
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
        Lighting.ClockTime = 14
        Lighting.Brightness = originalBrightness
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        print("[Visuals] Atmosphere reset.")
    end
end

CreateButton("🌙 Toggle Custom Weather", 180, ToggleWeather)


-- Информационная строка состояния внизу
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 1, -35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Ready & Active"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamItalic
StatusLabel.Parent = MainFrame

print("[Visual Hub] Successfully loaded and ready for use!")
