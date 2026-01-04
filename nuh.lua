-- clean animation player ui (local only)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- gui
local gui = Instance.new("ScreenGui")
gui.Name = "AnimGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromScale(0, 0)
main.Position = UDim2.fromScale(0.4, 0.35)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.25)
title.BackgroundTransparency = 1
title.Text = "animation player"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = main

local input = Instance.new("TextBox")
input.Size = UDim2.fromScale(0.9, 0.25)
input.Position = UDim2.fromScale(0.05, 0.35)
input.PlaceholderText = "animation id"
input.Text = ""
input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.Font = Enum.Font.Gotham
input.TextScaled = true
input.ClearTextOnFocus = false
input.BorderSizePixel = 0
input.Parent = main

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = input

local playButton = Instance.new("TextButton")
playButton.Size = UDim2.fromScale(0.9, 0.25)
playButton.Position = UDim2.fromScale(0.05, 0.65)
playButton.Text = "play"
playButton.BackgroundColor3 = Color3.fromRGB(60, 130, 255)
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.Font = Enum.Font.GothamBold
playButton.TextScaled = true
playButton.BorderSizePixel = 0
playButton.Parent = main

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = playButton

-- open animation
TweenService:Create(
	main,
	TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	{Size = UDim2.fromScale(0.18, 0.22)}
):Play()

-- dragging
local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
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

-- animation logic
local currentTrack

playButton.MouseButton1Click:Connect(function()
	local id = tonumber(input.Text)
	if not id then return end

	if currentTrack then
		currentTrack:Stop()
		currentTrack:Destroy()
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. id

	currentTrack = humanoid:LoadAnimation(anim)
	currentTrack:Play()
end)
