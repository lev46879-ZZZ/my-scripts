-- // TECHY ULTIMATE v5.2 - FIXED // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

print("[TECHY v5.2] Loading...")

-- ═══════════════════════════════════════════════════════
-- КОНФИГУРАЦИЯ
-- ═══════════════════════════════════════════════════════
local Config = {
    -- AIMBOT
    AimbotEnabled = false,
    AimbotFOV = 150,
    AimbotSmooth = 0.3,
    AimbotPrediction = true,
    PredictionFactor = 0.12,
    AimbotWallCheck = false,
    AimbotPart = "Head",
    AimbotTeamCheck = true,
    HoldToAim = false,
    
    -- SILENT AIM
    SilentAim = false,
    SilentFOV = 300,
    SilentHitchance = 100,
    SilentAutoShot = false,
    SilentTeamCheck = true,
    
    -- RAGEBOT
    RagebotEnabled = false,
    DoubleTap = false,
    SilentRage = false,
    RageNoSpread = false,
    AntiAim = false,
    AntiAimSpeed = 15,
    AntiAimType = "Spin",
    InstantHit = false,
    RageFOV = 9999,
    
    -- TRIGGERBOT
    Triggerbot = false,
    TriggerDelay = 0.05,
    
    -- HITBOX
    HitboxExpander = false,
    HitboxSize = 8,
    HitboxTarget = "Head",
    
    -- GUN MODS
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    RapidFireDelay = 0.03,
    
    -- VISUALS
    ESPEnabled = false,
    ESPName = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPWeapon = true,
    ESPStatus = true,
    ShowFOV = true,
    Fullbright = false,
    
    -- MOVEMENT
    SpeedEnabled = false,
    WalkSpeed = 60,
    JumpPower = 120,
    InfiniteJump = false,
    FlyEnabled = false,
    FlySpeed = 80,
    Noclip = false,
    
    -- HOOD
    AutoStomp = false,
    StompRange = 20,
    AntiRagdoll = false,
    
    -- MISC
    AntiAFK = false,
    FPSBoost = false,
    FovChanger = false,
    FovValue = 90
}

-- ═══════════════════════════════════════════════════════
-- ПРОВЕРКА EXECUTOR
-- ═══════════════════════════════════════════════════════
local hasHookmetamethod = hookmetamethod ~= nil
local hasNewcclosure = newcclosure ~= nil
local hasGetnamecallmethod = getnamecallmethod ~= nil

print("[TECHY] Hook support:", hasHookmetamethod and "YES" or "NO")

-- ═══════════════════════════════════════════════════════
-- UI КОД (оставляем как есть)
-- ═══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TechyV52"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

-- [ОСТАЛЬНОЙ UI КОД БЕЗ ИЗМЕНЕНИЙ - пропускаю для краткости]

-- ═══════════════════════════════════════════════════════
-- ✅ ИСПРАВЛЕННЫЙ SILENT AIM + RAGEBOT
-- ═══════════════════════════════════════════════════════
local oldNamecall = nil

if hasHookmetamethod and hasNewcclosure and hasGetnamecallmethod then
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        -- Защита от ошибок
        if not self or typeof(self) ~= "Instance" then
            return oldNamecall(self, ...)
        end
        
        -- Проверяем что это оружие
        local isFromWeapon = false
        pcall(function()
            local current = self
            while current do
                if current:IsA("Tool") then
                    isFromWeapon = true
                    break
                end
                current = current.Parent
            end
        end)
        
        if not isFromWeapon then
            return oldNamecall(self, ...)
        end
        
        -- SILENT AIM
        if Config.SilentAim and (method == "Raycast" or method == "FindPartOnRay") then
            pcall(function()
                local target = getClosestPlayer(Config.SilentFOV, Config.SilentTeamCheck)
                if target and target.Character then
                    local part = getTargetPart(target.Character)
                    if part then
                        local roll = math.random(1, 100)
                        if roll <= Config.SilentHitchance then
                            local targetPos = getPredictedPosition(part, target)
                            
                            -- Auto Shot
                            if Config.SilentAutoShot then
                                task.spawn(function()
                                    task.wait(0.016)
                                    if mouse1click then
                                        pcall(function() mouse1click() end)
                                    end
                                end)
                            end
                            
                            -- Перенаправляем raycast
                            if method == "Raycast" and args[1] and args[1].Origin then
                                local origin = args[1].Origin
                                local newDirection = (targetPos - origin).Unit * 1000
                                args[1] = Ray.new(origin, newDirection)
                            elseif method == "FindPartOnRay" and args[1] and args[1].Origin then
                                local ray = args[1]
                                args[1] = Ray.new(ray.Origin, (targetPos - ray.Origin).Unit * 1000)
                            end
                        end
                    end
                end
            end)
        end
        
        -- RAGEBOT
        if Config.RagebotEnabled then
            pcall(function()
                -- Double Tap
                if Config.DoubleTap and method == "FireServer" then
                    local result = oldNamecall(self, ...)
                    task.spawn(function()
                        pcall(function()
                            oldNamecall(self, ...)
                        end)
                    end)
                    return result
                end
                
                -- Silent Rage
                if (Config.SilentRage or Config.InstantHit) and (method == "Raycast" or method == "FindPartOnRay") then
                    local target = getClosestPlayer(Config.RageFOV, true)
                    if target and target.Character then
                        local part = getTargetPart(target.Character)
                        if part then
                            local targetPos = getPredictedPosition(part, target)
                            
                            if method == "Raycast" and args[1] and args[1].Origin then
                                local origin = args[1].Origin
                                args[1] = Ray.new(origin, (targetPos - origin).Unit * 1000)
                            elseif method == "FindPartOnRay" and args[1] and args[1].Origin then
                                local ray = args[1]
                                args[1] = Ray.new(ray.Origin, (targetPos - ray.Origin).Unit * 1000)
                            end
                        end
                    end
                end
            end)
        end
        
        return oldNamecall(self, unpack(args))
    end))
    
    print("[TECHY] ✅ Silent Aim hooks installed")
else
    print("[TECHY] ⚠️ Hook functions not available - Silent Aim disabled")
end

-- ═══════════════════════════════════════════════════════
-- ПОМОЩНИКИ (убедись что эти функции есть!)
-- ═══════════════════════════════════════════════════════
local function getTargetPart(character)
    if not character then return nil end
    if Config.AimbotPart == "Head" then
        return character:FindFirstChild("Head")
    elseif Config.AimbotPart == "Torso" then
        return character:FindFirstChild("HumanoidRootPart") 
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
    elseif Config.AimbotPart == "Legs" then
        return character:FindFirstChild("LowerTorso") 
            or character:FindFirstChild("HumanoidRootPart")
    end
    return character:FindFirstChild("Head")
end

local function getClosestPlayer(fov, teamCheck)
    local useFOV = fov or Config.AimbotFOV
    local checkTeam = teamCheck ~= nil and teamCheck or Config.AimbotTeamCheck
    local closest = nil
    local minDist = useFOV
    local viewport = Camera.ViewportSize
    local centerPos = Vector2.new(viewport.X / 2, viewport.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if checkTeam and player.Team == LocalPlayer.Team then continue end
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = getTargetPart(player.Character)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                        local dist = (centerPos - targetPos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = player
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function getPredictedPosition(targetPart, player)
    if not Config.AimbotPrediction then return targetPart.Position end
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return targetPart.Position end
    local velocity = hum.MoveDirection * hum.WalkSpeed
    return targetPart.Position + velocity * Config.PredictionFactor
end

print("╔══════════════════════════════════════════╗")
print("║  TECHY ULTIMATE v5.2 - FIXED             ║")
print("║  ✅ Добавлены проверки executor          ║")
print("║  ✅ Исправлены ошибки hookmetamethod     ║")
print("╚══════════════════════════════════════════╝")
