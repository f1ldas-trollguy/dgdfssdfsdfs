local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local inf = 99999999999999999

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local TOGGLE_KEY = Enum.KeyCode.E
local MAX_DISTANCE = inf
local SMOOTHNESS = 0.15

local enabled = false
local highlights = {}
local billboards = {}

-- wait for character
local function getCharacter()
	local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	return char, hrp
end

local function clearVisuals()
	for _, h in pairs(highlights) do h:Destroy() end
	for _, b in pairs(billboards) do b:Destroy() end
	table.clear(highlights)
	table.clear(billboards)
end

local function createESP(player)
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.FillColor = Color3.fromRGB(80, 120, 255)
	highlight.OutlineColor = Color3.new(1,1,1)
	highlight.Parent = char

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromScale(4,1)
	billboard.StudsOffset = Vector3.new(0,3,0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1,1)
	label.TextColor3 = Color3.new(1,1,1)
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
	local char, hrp = getCharacter()
	if not char or not hrp then return end

	local closest, closestDist = nil, MAX_DISTANCE
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
			local targetHrp = p.Character.HumanoidRootPart
			local humanoid = p.Character.Humanoid
			if humanoid.Health > 0 then
				local dist = (targetHrp.Position - hrp.Position).Magnitude
				if dist <= MAX_DISTANCE and hasLineOfSight(camera.CFrame.Position, targetHrp.Position, {char, p.Character}) then
					if dist < closestDist then
						closestDist = dist
						closest = p
					end
				end
			end
		end
	end
	return closest
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == TOGGLE_KEY then
		enabled = not enabled
		if not enabled then clearVisuals() end
	end
end)

RunService.RenderStepped:Connect(function()
	if not enabled then return end
	local char, hrp = getCharacter()
	if not char or not hrp then return end

	-- ESP loop
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			if not highlights[p] then createESP(p) end
			local dist = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
			if billboards[p] then
				local humanoid = p.Character:FindFirstChild("Humanoid")
				local health = humanoid and humanoid.Health or 0
				billboards[p].TextLabel.Text = string.format("%s | %d studs | HP: %d", p.DisplayName, math.floor(dist), health)
			end
		end
	end

	local target = getClosestVisiblePlayer()
	if target and target.Character then
		local targetPos = target.Character.HumanoidRootPart.Position
		camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPos), SMOOTHNESS)
	end
end)
