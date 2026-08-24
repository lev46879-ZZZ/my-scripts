-- Apex Hub — visual-only UI
-- LocalScript → StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "ApexHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Main window
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(650, 440)
main.Position = UDim2.new(0.5, -325, 0.5, -220)
main.BackgroundColor3 = Color3.fromRGB(16, 16, 17)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

-- Header
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -180, 0, 42)
title.Position = UDim2.fromOffset(24, 14)
title.BackgroundTransparency = 1
title.Text = "Apex Hub"
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.TextSize = 21
title.Font = Enum.Font.GothamMedium
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -180, 0, 25)
subtitle.Position = UDim2.fromOffset(25, 39)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Murder Mystery 2"
subtitle.TextColor3 = Color3.fromRGB(125, 125, 125)
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

-- Search
local search = Instance.new("TextBox")
search.Size = UDim2.fromOffset(165, 36)
search.Position = UDim2.new(1, -215, 0, 15)
search.BackgroundColor3 = Color3.fromRGB(10, 10, 11)
search.BorderSizePixel = 0
search.PlaceholderText = "Search..."
search.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
search.Text = ""
search.TextColor3 = Color3.fromRGB(220, 220, 220)
search.TextSize = 13
search.Font = Enum.Font.Gotham
search.Parent = main

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = search

-- Close button
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(34, 34)
close.Position = UDim2.new(1, -48, 0, 16)
close.BackgroundColor3 = Color3.fromRGB(28, 28, 29)
close.BorderSizePixel = 0
close.Text = "X"
close.TextColor3 = Color3.fromRGB(210, 210, 210)
close.TextSize = 14
close.Font = Enum.Font.GothamMedium
close.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = close

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Content panels
local function createPanel(name, x)
	local panel = Instance.new("Frame")
	panel.Name = name
	panel.Size = UDim2.fromOffset(305, 340)
	panel.Position = UDim2.fromOffset(x, 80)
	panel.BackgroundColor3 = Color3.fromRGB(11, 11, 12)
	panel.BorderSizePixel = 0
	panel.Parent = main

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = panel

	return panel
end

local left = createPanel("VisualPanel", 18)
local right = createPanel("SettingsPanel", 327)

-- Panel title
local function panelTitle(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -30, 0, 35)
	label.Position = UDim2.fromOffset(15, 10)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(225, 225, 225)
	label.TextSize = 15
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, -30, 0, 1)
	line.Position = UDim2.fromOffset(15, 46)
	line.BackgroundColor3 = Color3.fromRGB(45, 45, 46)
	line.BorderSizePixel = 0
	line.Parent = parent
end

panelTitle(left, "Visuals")
panelTitle(right, "Interface")

-- Visual-only rows
local function addRow(parent, text, y)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -30, 0, 38)
	label.Position = UDim2.fromOffset(15, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(195, 195, 195)
	label.TextSize = 13
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	local toggle = Instance.new("Frame")
	toggle.Size = UDim2.fromOffset(52, 28)
	toggle.Position = UDim2.new(1, -67, 0, y + 5)
	toggle.BackgroundColor3 = Color3.fromRGB(85, 85, 92)
	toggle.BorderSizePixel = 0
	toggle.Parent = parent

	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = toggle

	local circle = Instance.new("Frame")
	circle.Size = UDim2.fromOffset(20, 20)
	circle.Position = UDim2.fromOffset(4, 4)
	circle.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	circle.BorderSizePixel = 0
	circle.Parent = toggle

	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(1, 0)
	cc.Parent = circle
end

addRow(left, "Role ESP", 65)
addRow(left, "Gun ESP", 115)
addRow(left, "Tracers", 165)
addRow(left, "Box ESP", 215)

addRow(right, "Dark Interface", 65)
addRow(right, "Smooth Animation", 115)
addRow(right, "Rounded Corners", 165)
addRow(right, "Visual Effects", 215)

-- Dragging
local dragging = false
local dragStart
local startPos

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

main.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)
