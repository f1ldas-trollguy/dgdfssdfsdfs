--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local screenGuiCredits = Instance.new("ScreenGui")
screenGuiCredits.Name = "CreditsGUI"
screenGuiCredits.ResetOnSpawn = false
screenGuiCredits.Parent = player:WaitForChild("PlayerGui")

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 800, 0, 100)
title.Position = UDim2.new(0.5, -400, 0.4, 0)
title.BackgroundTransparency = 1
title.Text = "Made by yourunclelarry96"
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 60
title.TextScaled = true
title.TextStrokeTransparency = 0.5
title.TextWrapped = true
title.Parent = screenGuiCredits

local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenGoal = {TextTransparency = 1, TextStrokeTransparency = 1}
local tween = TweenService:Create(title, tweenInfo, tweenGoal)
tween:Play()
tween.Completed:Connect(function()
	title:Destroy()
	screenGuiCredits:Destroy()
end)

local teleportEnabled = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportToggleUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 140, 0, 45)
toggleButton.Position = UDim2.new(0.5, -70, 0.85, 0)
toggleButton.Text = "Teleport: OFF"
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.BackgroundColor3 = Color3.fromRGB(255,50,50)
toggleButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 20)
uiCorner.Parent = toggleButton

local dragging = false
local dragInput, mousePos, framePos

local function updateButton()
	if teleportEnabled then
		toggleButton.Text = "Teleport: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50,255,50)
	else
		toggleButton.Text = "Teleport: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(255,50,50)
	end
end

local function makeMarker(pos)
	local marker = Instance.new("Part")
	marker.Anchored = true
	marker.CanCollide = false
	marker.Size = Vector3.new(1,0.2,1)
	marker.Color = Color3.fromRGB(0,255,0)
	marker.Material = Enum.Material.Neon
	marker.CFrame = CFrame.new(pos)
	marker.Transparency = 0.3
	marker.Parent = workspace
	game:GetService("Debris"):AddItem(marker,0.4)
end

toggleButton.MouseButton1Click:Connect(function()
	teleportEnabled = not teleportEnabled
	updateButton()
end)

toggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		mousePos = input.Position
		framePos = toggleButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

toggleButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		toggleButton.Position = UDim2.new(
			framePos.X.Scale,
			framePos.X.Offset + delta.X,
			framePos.Y.Scale,
			framePos.Y.Offset + delta.Y
		)
	end
end)

mouse.Button1Down:Connect(function()
	if not teleportEnabled then return end
	local target = mouse.Hit
	if not target then return end
	local pos = target.Position

	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.CFrame = CFrame.new(pos)
	makeMarker(pos)
end)

updateButton()
