-- aim assist + esp for PLAYERS (LOCAL ONLY) --
-- toggle with E

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- CONFIG
local TOGGLE_KEY = Enum.KeyCode.E
local MAX_DISTANCE = 250
local SMOOTHNESS = 0.15

-- STATE
local enabled = false
local highlights = {}
local billboards = {}

-- utility
local function clearVisuals()
	for _, h in pairs(highlights) do
		h:Destroy()
	end
	for _, b in pairs(billboards) do
		b:Destroy()
	end
	table.clear(highlights)
	table.clear(billboards)
end

local function createESP(player)
	local character = player.Character
	if not character then return end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.FillColor = Color3.fromRGB(80, 120, 255) -- Changed color to blue for players
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.Parent = character

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromScale(4, 1)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	highlights[player] = highlight
	billboards[player] = billboard
end

local function hasLineOfSight(origin, targetPos, ignore)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = ignore
	params.IgnoreWater = true
	local result = Workspace:Raycast(origin, targetPos - origin, params)
	return result == nil
end

local function getClosestVisiblePlayer()
	local character = localPlayer.Character
	if not character then return nil end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local closest
	local closestDist = MAX_DISTANCE

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local targetCharacter = player.Character
			if targetCharacter then
				local targetHrp = targetCharacter:FindFirstChild("HumanoidRootPart")
				local humanoid = targetCharacter:FindFirstChild("Humanoid")
				if targetHrp and humanoid and humanoid.Health > 0 then
					local dist = (targetHrp.Position - hrp.Position).Magnitude
					if dist <= MAX_DISTANCE then
						local visible = hasLineOfSight(camera.CFrame.Position, targetHrp.Position, {character, targetCharacter})
						if visible and dist < closestDist then
							closestDist = dist
							closest = player
						end
					end
				end
			end
		end
	end
	return closest
end

-- INPUT
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == TOGGLE_KEY then
		enabled = not enabled
		if not enabled then
			clearVisuals()
		end
	end
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
	if not enabled then return end

	local character = localPlayer.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- ESP Loop
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local targetCharacter = player.Character
			if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") and targetCharacter:FindFirstChild("Humanoid") then
				if not highlights[player] then
					createESP(player)
				end
				
				local dist = (targetCharacter.HumanoidRootPart.Position - hrp.Position).Magnitude
				if billboards[player] and billboards[player]:FindFirstChild("TextLabel") then
					local humanoid = targetCharacter:FindFirstChild("Humanoid")
					local health = humanoid and humanoid.Health or 0
					billboards[player].TextLabel.Text = string.format("%s | %d studs | HP: %d", player.DisplayName, math.floor(dist), health)
				end
			end
		end
	end

	local targetPlayer = getClosestVisiblePlayer()
	if not targetPlayer then return end

	local targetCharacter = targetPlayer.Character
	if not targetCharacter then return end
	
	local targetPos = targetCharacter.HumanoidRootPart.Position
	local camPos = camera.CFrame.Position
	local desired = CFrame.new(camPos, targetPos)
	camera.CFrame = camera.CFrame:Lerp(desired, SMOOTHNESS)
end)
