-- services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- gui
local gui = Instance.new("ScreenGui")
gui.Name = "SpinGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 180)
frame.Position = UDim2.fromScale(0.4, 0.35)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "spin (studs/sec)"
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.fromOffset(220, 35)
input.Position = UDim2.fromOffset(20, 55)
input.PlaceholderText = "studs per second"
input.ClearTextOnFocus = false
input.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.Parent = frame
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

local runButton = Instance.new("TextButton")
runButton.Size = UDim2.fromOffset(220, 35)
runButton.Position = UDim2.fromOffset(20, 100)
runButton.Text = "run"
runButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
runButton.TextColor3 = Color3.fromRGB(255, 255, 255)
runButton.Font = Enum.Font.GothamBold
runButton.TextSize = 15
runButton.Parent = frame
Instance.new("UICorner", runButton).CornerRadius = UDim.new(0, 8)

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.fromOffset(220, 30)
stopButton.Position = UDim2.fromOffset(20, 140)
stopButton.Text = "stop"
stopButton.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.Parent = frame
Instance.new("UICorner", stopButton).CornerRadius = UDim.new(0, 8)

-- draggable
local dragging = false
local dragStart
local startPos

frame.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = frame.Position
	end
end)

frame.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- spinning with real sps meaning
local spinConnection
local RADIUS = 2 -- studs, fake but reasonable

runButton.MouseButton1Click:Connect(function()
	local studsPerSecond = tonumber(input.Text)
	if not studsPerSecond then
		return
	end

	if spinConnection then
		spinConnection:Disconnect()
	end

	-- radians per second
	local angularSpeed = studsPerSecond / RADIUS

	spinConnection = RunService.Heartbeat:Connect(function(dt)
		if hrp and hrp.Parent then
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, angularSpeed * dt, 0)
		end
	end)
end)

stopButton.MouseButton1Click:Connect(function()
	if spinConnection then
		spinConnection:Disconnect()
		spinConnection = nil
	end
end)
