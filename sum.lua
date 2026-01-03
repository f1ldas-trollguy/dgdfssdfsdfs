--// cheat hub ui (ui only, feature logic is placeholder)
--// drop as a LocalScript

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- gui
local gui = Instance.new("ScreenGui")
gui.Name = "CheatHubUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- main frame
local main = Instance.new("Frame")
main.Size = UDim2.fromScale(0.28, 0.45)
main.Position = UDim2.fromScale(0.36, 0.27)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 42)
top.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 1)
title.BackgroundTransparency = 1
title.Text = "feature hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.Parent = top

-- scrolling area
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0, 0, 0, 46)
scroll.Size = UDim2.new(1, 0, 1, -50)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarImageTransparency = 0.3
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Parent = main

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)

-- draggable
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

-- feature list (101 entries)
local features = {
	-- movement
	"fly","noclip","walk speed","jump power","infinite jump","air dash","wall climb","wall jump","gravity changer","ladder teleport",
	-- teleport
	"tp to mouse","tp to player","tp random","save position","load position","return last","respawn tp","waypoint tp","loop tp","safe tp",
	-- player
	"god mode","no fall dmg","invisible","ragdoll","freeze","sit anywhere","fake death","revive self","revive others","clone",
	-- combat
	"kill aura","reach","hitbox expand","inf stamina","inf ammo","no recoil","no spread","rapid fire","one hit","damage multi",
	-- physics
	"fling","anti fling","velocity launch","force jump","slip mode","big head","tiny body","ragdoll touch","pause physics","time scale",
	-- visuals
	"esp boxes","esp names","esp distance","health bars","tracers","chams","xray","fullbright","fov","camera shake",
	-- utility
	"anti afk","auto respawn","auto collect","auto use","fast interact","inf zoom","chat spam","fake lag","rejoin","server hop",
	-- ui
	"keybinds","draggable ui","themes","animations","search","save config","load config","panic button","perf mode","fps unlock",
	-- extra
	"fake admin","client explosions","sound spam","resize","spin bot","orbit","auto emote","random loop","self crash","sandbox",
	-- 101
	"aimbot"
}

-- placeholder functions for each feature
local featureFunctions = {}
for _, name in ipairs(features) do
	featureFunctions[name] = function(enabled)
		-- placeholder logic for each feature
		if enabled then
			print(name.." activated")
		else
			print(name.." deactivated")
		end
	end
end

-- button creator
local function createButton(text)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -14, 0, 36)
	button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	button.Text = text
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.TextColor3 = Color3.fromRGB(220, 220, 220)
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

	local enabled = false

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {Size = UDim2.new(1, -10, 0, 40)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), {Size = UDim2.new(1, -14, 0, 36)}):Play()
	end)

	button.MouseButton1Click:Connect(function()
		enabled = not enabled
		-- change button color
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = enabled and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(35, 35, 35)
		}):Play()

		-- call feature function
		if featureFunctions[text] then
			featureFunctions[text](enabled)
		end
	end)

	return button
end

-- populate
for _, name in ipairs(features) do
	createButton(name).Parent = scroll
end

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)
