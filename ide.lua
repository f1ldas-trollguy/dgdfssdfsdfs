--// full cheat hub + config UI
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- GUI setup
local gui = Instance.new("ScreenGui")
gui.Name = "CheatHubUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- main frame
local main = Instance.new("Frame")
main.Size = UDim2.fromScale(0.28,0.45)
main.Position = UDim2.fromScale(0.36,0.27)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

-- top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,42)
top.BackgroundColor3 = Color3.fromRGB(30,30,30)
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1,1)
title.BackgroundTransparency = 1
title.Text = "feature hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Parent = top

-- scrolling frame
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0,0,0,46)
scroll.Size = UDim2.new(1,0,1,-50)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageTransparency = 0.3
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Parent = main

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,8)

-- draggable main
do
	local dragging, dragStart, startPos
	top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			main.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- secondary config UI
local configUI = Instance.new("Frame")
configUI.Size = UDim2.fromScale(0.2,0.25)
configUI.Position = UDim2.fromScale(0.4,0.4)
configUI.BackgroundColor3 = Color3.fromRGB(25,25,25)
configUI.Visible = false
configUI.Parent = gui
Instance.new("UICorner", configUI).CornerRadius = UDim.new(0,14)

local configTitle = Instance.new("TextLabel")
configTitle.Size = UDim2.fromScale(1,0.2)
configTitle.BackgroundTransparency = 1
configTitle.Text = "Feature Config"
configTitle.Font = Enum.Font.GothamBold
configTitle.TextSize = 16
configTitle.TextColor3 = Color3.fromRGB(235,235,235)
configTitle.Parent = configUI

-- close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromScale(0.2,0.2)
closeBtn.Position = UDim2.fromScale(0.8,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextSize = 14
closeBtn.Parent = configUI
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)

closeBtn.MouseButton1Click:Connect(function()
	configUI.Visible = false
end)

-- features & configs
local featureValues = {
	["walk speed"] = 16,
	["jump power"] = 50,
	["gravity"] = workspace.Gravity
}

local activeFeatures = {}

-- function to show config UI
local function openConfig(feature)
	configUI.Visible = true
	configTitle.Text = feature.." config"
	-- remove old sliders
	for i,v in ipairs(configUI:GetChildren()) do
		if v:IsA("TextLabel") or v:IsA("TextBox") then
			if v ~= configTitle then v:Destroy() end
		end
	end

	-- create slider/input
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(0.9,0.2)
	lbl.Position = UDim2.fromScale(0.05,0.3)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(235,235,235)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
	lbl.Text = "Value: "..featureValues[feature]
	lbl.Parent = configUI

	local input = Instance.new("TextBox")
	input.Size = UDim2.fromScale(0.9,0.2)
	input.Position = UDim2.fromScale(0.05,0.55)
	input.BackgroundColor3 = Color3.fromRGB(35,35,35)
	input.TextColor3 = Color3.fromRGB(220,220,220)
	input.Text = tostring(featureValues[feature])
	input.ClearTextOnFocus = false
	input.Font = Enum.Font.Gotham
	input.TextSize = 14
	input.Parent = configUI
	Instance.new("UICorner", input).CornerRadius = UDim.new(0,8)

	input.FocusLost:Connect(function(enter)
		local val = tonumber(input.Text)
		if val then
			featureValues[feature] = val
			lbl.Text = "Value: "..val
			-- apply immediately
			if feature == "walk speed" then
				humanoid.WalkSpeed = val
			elseif feature == "jump power" then
				humanoid.JumpPower = val
			elseif feature == "gravity" then
				workspace.Gravity = val
			end
		end
	end)
end

-- create buttons
local featureList = {"walk speed","jump power","gravity","noclip","fly"}
for _,name in ipairs(featureList) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1,-14,0,36)
	button.BackgroundColor3 = Color3.fromRGB(35,35,35)
	button.Text = name
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.TextColor3 = Color3.fromRGB(220,220,220)
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	Instance.new("UICorner", button).CornerRadius = UDim.new(0,10)
	button.Parent = scroll

	local enabled = false

	button.MouseEnter:Connect(function()
		TweenService:Create(button,TweenInfo.new(0.15),{Size=UDim2.new(1,-10,0,40)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button,TweenInfo.new(0.15),{Size=UDim2.new(1,-14,0,36)}):Play()
	end)

	button.MouseButton1Click:Connect(function()
		-- if feature is configurable, open config UI
		if featureValues[name] then
			openConfig(name)
			return
		end

		enabled = not enabled
		TweenService:Create(button,TweenInfo.new(0.15),{
			BackgroundColor3 = enabled and Color3.fromRGB(60,120,255) or Color3.fromRGB(35,35,35)
		}):Play()

		-- implement feature logic
		if name == "noclip" then
			if enabled then
				RunService.Stepped:Connect(function()
					for _,p in pairs(char:GetDescendants()) do
						if p:IsA("BasePart") then p.CanCollide = false end
					end
				end)
			end
		elseif name == "fly" then
			if enabled then
				local bodyVel = Instance.new("BodyVelocity")
				bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
				bodyVel.Velocity = Vector3.new(0,0,0)
				bodyVel.Name = "FlyVel"
				bodyVel.Parent = hrp
				UIS.InputBegan:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.W then bodyVel.Velocity = hrp.CFrame.LookVector*50 end
					if input.KeyCode == Enum.KeyCode.S then bodyVel.Velocity = -hrp.CFrame.LookVector*50 end
					if input.KeyCode == Enum.KeyCode.A then bodyVel.Velocity = -hrp.CFrame.RightVector*50 end
					if input.KeyCode == Enum.KeyCode.D then bodyVel.Velocity = hrp.CFrame.RightVector*50 end
				end)
			else
				if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
			end
		end
	end)
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)
