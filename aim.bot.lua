-- aim assist + esp for NPCs (LOCAL ONLY)
-- toggle with E

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
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

local function createESP(npc)
	local hrp = npc:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.FillColor = Color3.fromRGB(255, 80, 80)
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.Parent = npc

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

	highlights[npc] = highlight
	billboards[npc] = billboard
end

local function hasLineOfSight(origin, targetPos, ignore)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = ignore
	params.IgnoreWater = true

	local result = Workspace:Raycast(origin, targetPos - origin, params)
	return result == nil
end

local function getClosestVisibleNPC()
	local character = player.Character
	if not character then return nil end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local closest
	local closestDist = MAX_DISTANCE

	for _, obj in pairs(Workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
			local npc = obj
			if npc.Humanoid.Health > 0 then
				local npcHrp = npc.HumanoidRootPart
				local dist = (npcHrp.Position - hrp.Position).Magnitude

				if dist <= MAX_DISTANCE then
					local visible = hasLineOfSight(
						camera.CFrame.Position,
						npcHrp.Position,
						{character, npc}
					)

					if visible and dist < closestDist then
						closestDist = dist
						closest = npc
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

	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	for _, obj in pairs(Workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
			local npc = obj
			if not highlights[npc] then
				createESP(npc)
			end

			local dist = (npc.HumanoidRootPart.Position - hrp.Position).Magnitude
			if billboards[npc] then
				billboards[npc].TextLabel.Text =
					npc.Name .. " | " .. math.floor(dist) .. " studs"
			end
		end
	end

	local target = getClosestVisibleNPC()
	if not target then return end

	local targetPos = target.HumanoidRootPart.Position
	local camPos = camera.CFrame.Position

	local desired = CFrame.new(camPos, targetPos)
	camera.CFrame = camera.CFrame:Lerp(desired, SMOOTHNESS)
end)
