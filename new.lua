-- ctrl + click teleport local script

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local holdingCtrl = false

-- track ctrl key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		holdingCtrl = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		holdingCtrl = false
	end
end)

-- mouse click teleport
mouse.Button1Down:Connect(function()
	if not holdingCtrl then return end

	local character = player.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local hitPosition = mouse.Hit.Position

	-- small upward offset so you don't clip into the ground like an idiot
	humanoidRootPart.CFrame = CFrame.new(hitPosition + Vector3.new(0, 3, 0))
end)
