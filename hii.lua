-- services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- gui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedJumpHub"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(0.5, -110, 0.5, -65)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true -- needed for dragging
frame.Draggable = true

-- UICorner for smooth edges
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 25)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Speed & Jump Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = frame

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- speed input
local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.8, 0, 0, 25)
speedInput.Position = UDim2.new(0.1, 0, 0.3, 0)
speedInput.PlaceholderText = "Enter speed"
speedInput.Text = ""
speedInput.ClearTextOnFocus = false
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedInput.Font = Enum.Font.Gotham
speedInput.TextSize = 14
speedInput.Parent = frame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 5)
speedCorner.Parent = speedInput

-- jump input
local jumpInput = Instance.new("TextBox")
jumpInput.Size = UDim2.new(0.8, 0, 0, 25)
jumpInput.Position = UDim2.new(0.1, 0, 0.55, 0)
jumpInput.PlaceholderText = "Enter jump power"
jumpInput.Text = ""
jumpInput.ClearTextOnFocus = false
jumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpInput.Font = Enum.Font.Gotham
jumpInput.TextSize = 14
jumpInput.Parent = frame

local jumpCorner = Instance.new("UICorner")
jumpCorner.CornerRadius = UDim.new(0, 5)
jumpCorner.Parent = jumpInput

-- apply button
local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(0.8, 0, 0, 25)
applyButton.Position = UDim2.new(0.1, 0, 0.8, 0)
applyButton.Text = "Apply"
applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
applyButton.Font = Enum.Font.GothamBold
applyButton.TextSize = 14
applyButton.Parent = frame

local applyCorner = Instance.new("UICorner")
applyCorner.CornerRadius = UDim.new(0, 5)
applyCorner.Parent = applyButton

-- apply function
applyButton.MouseButton1Click:Connect(function()
    local speed = tonumber(speedInput.Text)
    local jump = tonumber(jumpInput.Text)
    if speed then
        humanoid.WalkSpeed = speed
    end
    if jump then
        humanoid.JumpPower = jump
    end
end)
