-- services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- gui setup
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

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "spin controller"
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.fromOffset(220, 35)
input.Position = UDim2.fromOffset(20, 55)
input.PlaceholderText = "spin speed (number)"
input.Text = ""
input.ClearTextOnFocus = false
input.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.Parent = frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = input

local runButton = Instance.new("TextButton")
runButton.Size = UDim2.fromOffset(220, 35)
runButton.Position = UDim2.fromOffset(20, 100)
runButton.Text = "run"
runButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
runButton.TextColor3 = Color3.fromRGB(255, 255, 255)
runButton.Font = Enum.Font.GothamBold
runButton.TextSize = 15
runButton.Parent = frame

local runCorner = Instance.new("UICorner")
runCorner.CornerRadius = UDim.new(0, 8)
runCorner.Parent = runButton

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.fromOffset(220, 30)
stopButton.Position = UDim2.fromOffset(20, 140)
stopButton.Text = "stop"
stopButton.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.Parent = frame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 8)
stopCorner.Parent = stopButton

-- draggable logic
local dragging = false
local dragStart
local startPos

frame.InputBegan:Connect(function(inputObj)
	if inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = inputObj.Position
		startPos = frame.Position
	end
end)

frame.InputEnded:Connect(function(inputObj)
	if inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(inputObj)
	if dragging and inputObj.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = inputObj.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- spinning logic
local spinConnection = nil

runButton.MouseButton1Click:Connect(function()
	local value = tonumber(input.Text)
	if not value then
		return
	end

	if spinConnection then
		spinConnection:Disconnect()
	end

	spinConnection = RunService.Heartbeat:Connect(function(dt)
		if hrp and hrp.Parent then
			-- value is treated as spin speed
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(value) * dt, 0)
		end
	end)
end)

stopButton.MouseButton1Click:Connect(function()
	if spinConnection then
		spinConnection:Disconnect()
		spinConnection = nil
	end
end)
