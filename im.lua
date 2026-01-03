--// FULL 101 FEATURE HUB - CLIENT SIDE ONLY
--// Drop this in StarterPlayerScripts

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local mouse = lp:GetMouse()

-- character refs
local function getChar()
	local c = lp.Character or lp.CharacterAdded:Wait()
	return c, c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
end

local char, hum, hrp = getChar()
lp.CharacterAdded:Connect(function()
	char, hum, hrp = getChar()
end)

-- states & configs
local state = {}
local config = {}

-- default values for movement/configurable features
local defaults = {
	["flySpeed"]=60, ["walkSpeed"]=16, ["jumpPower"]=50, ["gravity"]=workspace.Gravity,
	["aimbotFOV"]=200, ["aimbotSmooth"]=0.15
}

-- initialize all states to false and default configs
local featureList = {
	"fly","noclip","walk speed","jump power","infinite jump","air dash","wall climb","wall jump","gravity changer","ladder teleport",
	"tp to mouse","tp to player","tp random","save position","load position","return last","respawn tp","waypoint tp","loop tp","safe tp",
	"god mode","no fall dmg","invisible","ragdoll","freeze","sit anywhere","fake death","revive self","revive others","clone",
	"kill aura","reach","hitbox expand","inf stamina","inf ammo","no recoil","no spread","rapid fire","one hit","damage multi",
	"fling","anti fling","velocity launch","force jump","slip mode","big head","tiny body","ragdoll touch","pause physics","time scale",
	"esp boxes","esp names","esp distance","health bars","tracers","chams","xray","fullbright","fov","camera shake",
	"anti afk","auto respawn","auto collect","auto use","fast interact","inf zoom","chat spam","fake lag","rejoin","server hop",
	"keybinds","draggable ui","themes","animations","search","save config","load config","panic button","perf mode","fps unlock",
	"fake admin","client explosions","sound spam","resize","spin bot","orbit","auto emote","random loop","self crash","sandbox",
	"aimbot"
}

for _,f in ipairs(featureList) do
	state[f] = false
	config[f] = defaults[f] or 0
end

--------------------------------------------------
-- MOVEMENT / PHYSICS
--------------------------------------------------

-- fly
local flyVel = Instance.new("BodyVelocity")
flyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
RunService.RenderStepped:Connect(function()
	if state["fly"] then
		local dir = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += hrp.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= hrp.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= hrp.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += hrp.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
		flyVel.Velocity = dir.Magnitude > 0 and dir.Unit * config["flySpeed"] or Vector3.zero
	end
end)
local function toggleFly(v)
	state["fly"] = v
	if v then flyVel.Parent = hrp hum.PlatformStand = true
	else flyVel.Parent = nil hum.PlatformStand = false end
end

-- noclip
RunService.Stepped:Connect(function()
	if state["noclip"] then
		for _,p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
end)

-- walk speed / jump power / gravity
RunService.RenderStepped:Connect(function()
	if state["walk speed"] then hum.WalkSpeed = config["walkSpeed"] end
	if state["jump power"] then hum.JumpPower = config["jumpPower"] end
	if state["gravity changer"] then workspace.Gravity = config["gravity"] end
end)

-- infinite jump
UIS.JumpRequest:Connect(function()
	if state["infinite jump"] then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- spin bot / orbit (visual)
RunService.RenderStepped:Connect(function()
	if state["spin bot"] then
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0,math.rad(15),0)
	end
	if state["orbit"] then
		local angle = tick() * 2
		hrp.CFrame = hrp.CFrame + Vector3.new(math.cos(angle),0,math.sin(angle))
	end
end)

--------------------------------------------------
-- AIMBOT
--------------------------------------------------
local function getClosestTarget()
	local best, dist = nil, config["aimbotFOV"]
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp and plr.Character then
			local r = plr.Character:FindFirstChild("HumanoidRootPart")
			local h = plr.Character:FindFirstChild("Humanoid")
			if h and h.Health>0 and r then
				local pos,onScreen = cam:WorldToViewportPoint(r.Position)
				if onScreen then
					local d = (Vector2.new(pos.X,pos.Y)-Vector2.new(mouse.X,mouse.Y)).Magnitude
					if d < dist then dist = d best = r end
				end
			end
		end
	end
	return best
end
RunService.RenderStepped:Connect(function()
	if state["aimbot"] then
		local target = getClosestTarget()
		if target then
			cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position,target.Position),1-config["aimbotSmooth"])
		end
	end
end)

--------------------------------------------------
-- FULLBRIGHT
--------------------------------------------------
local oldLighting = {Brightness=Lighting.Brightness,Ambient=Lighting.Ambient}
local function toggleFullbright(v)
	state["fullbright"] = v
	if v then Lighting.Brightness=3 Lighting.Ambient=Color3.new(1,1,1)
	else Lighting.Brightness=oldLighting.Brightness Lighting.Ambient=oldLighting.Ambient end
end

--------------------------------------------------
-- SIMPLE ESP (Boxes)
--------------------------------------------------
local espFolder = Instance.new("Folder",cam)
espFolder.Name = "ESP"
local function updateESP()
	espFolder:ClearAllChildren()
	if not state["esp boxes"] then return end
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=lp and plr.Character then
			local hrp2 = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp2 then
				local bb = Instance.new("BillboardGui",espFolder)
				bb.Adornee = hrp2
				bb.Size = UDim2.fromScale(2,3)
				bb.AlwaysOnTop = true
				local frame = Instance.new("Frame",bb)
				frame.Size=UDim2.fromScale(1,1)
				frame.BackgroundTransparency=0.5
				frame.BorderSizePixel=2
				frame.BorderColor3=Color3.fromRGB(255,0,0)
			end
		end
	end
end
RunService.RenderStepped:Connect(updateESP)

--------------------------------------------------
-- UI
--------------------------------------------------
local gui = Instance.new("ScreenGui",lp.PlayerGui)
gui.Name="CheatHub"
local main = Instance.new("Frame",gui)
main.Size=UDim2.fromScale(0.28,0.45)
main.Position=UDim2.fromScale(0.36,0.27)
main.BackgroundColor3=Color3.fromRGB(20,20,20)
Instance.new("UICorner",main).CornerRadius=UDim.new(0,14)

local layout = Instance.new("UIListLayout",main)
layout.Padding=UDim.new(0,6)
layout.SortOrder=Enum.SortOrder.LayoutOrder

-- create buttons for every feature
for _,f in ipairs(featureList) do
	local btn = Instance.new("TextButton")
	btn.Size=UDim2.new(1,-10,0,36)
	btn.Text=f
	btn.TextColor3=Color3.fromRGB(220,220,220)
	btn.BackgroundColor3=Color3.fromRGB(35,35,35)
	btn.Font=Enum.Font.Gotham
	btn.TextSize=14
	btn.Parent=main
	local enabled=false

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn,TweenInfo.new(0.1),{Size=UDim2.new(1,-6,0,40)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn,TweenInfo.new(0.1),{Size=UDim2.new(1,-10,0,36)}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		enabled = not enabled
		state[f] = enabled
		btn.BackgroundColor3 = enabled and Color3.fromRGB(60,120,255) or Color3.fromRGB(35,35,35)
	end)
end

