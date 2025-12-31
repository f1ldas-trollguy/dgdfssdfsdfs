-- StarterPlayerScripts LocalScript
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local musicFolder = Workspace:WaitForChild("Music")

local POPUP_WIDTH = 280
local POPUP_HEIGHT = 150 -- taller to fit length
local SHOW_TIME = 10
local POLL_INTERVAL = 1

-- helpers
local function trimText(text, max)
	if #text <= max then return text end
	return string.sub(text, 1, max) .. "..."
end

local function formatTime(seconds)
	local m = math.floor(seconds / 60)
	local s = math.floor(seconds % 60)
	return string.format("%d:%02d", m, s)
end

local function getSoundCreator(sound)
	local id = tonumber(sound.SoundId:match("%d+"))
	if not id then return "unknown" end
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(id)
	end)
	if success and info and info.Creator then
		return info.Creator.Name
	end
	return "unknown"
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MusicPopup"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(POPUP_WIDTH, POPUP_HEIGHT)
frame.Position = UDim2.new(0, -POPUP_WIDTH, 0.5, -POPUP_HEIGHT / 2)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 14)
padding.PaddingRight = UDim.new(0, 14)
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "Now Playing"
title.Font = Enum.Font.GothamMedium
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Size = UDim2.new(1, 0, 0, 18)
title.Parent = frame

local nameLabel = Instance.new("TextLabel")
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 16
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.BackgroundTransparency = 1
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Size = UDim2.new(1, 0, 0, 20)
nameLabel.Parent = frame

local creatorLabel = Instance.new("TextLabel")
creatorLabel.Font = Enum.Font.Gotham
creatorLabel.TextSize = 13
creatorLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
creatorLabel.BackgroundTransparency = 1
creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
creatorLabel.Size = UDim2.new(1, 0, 0, 18)
creatorLabel.Parent = frame

local idLabel = Instance.new("TextLabel")
idLabel.Font = Enum.Font.Gotham
idLabel.TextSize = 12
idLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
idLabel.BackgroundTransparency = 1
idLabel.TextXAlignment = Enum.TextXAlignment.Left
idLabel.Size = UDim2.new(1, 0, 0, 18)
idLabel.Parent = frame

local lengthLabel = Instance.new("TextLabel")
lengthLabel.Font = Enum.Font.Gotham
lengthLabel.TextSize = 12
lengthLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
lengthLabel.BackgroundTransparency = 1
lengthLabel.TextXAlignment = Enum.TextXAlignment.Left
lengthLabel.Size = UDim2.new(1, 0, 0, 18)
lengthLabel.Parent = frame

-- tweens
local tweenIn = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0, 12, 0.5, -POPUP_HEIGHT / 2) }
)
local tweenOut = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	{ Position = UDim2.new(0, -POPUP_WIDTH, 0.5, -POPUP_HEIGHT / 2) }
)

local showing = false
local lastPlayTimes = {}

local function showPopup(sound)
	if showing then return end
	showing = true

	local soundId = sound.SoundId:gsub("%D", "")
	local creator = getSoundCreator(sound)

	nameLabel.Text = sound.Name
	creatorLabel.Text = "By: " .. creator
	idLabel.Text = "ID: " .. soundId
	lengthLabel.Text = "Length: " .. formatTime(sound.TimeLength)

	tweenIn:Play()
	task.wait(SHOW_TIME)
	tweenOut:Play()
	task.wait(0.4)

	showing = false
end

task.spawn(function()
	while true do
		for _, s in ipairs(musicFolder:GetChildren()) do
			if s:IsA("Sound") and s.IsPlaying then
				local lastTime = lastPlayTimes[s] or -1
				if s.TimePosition < lastTime then
					showPopup(s)
				elseif lastTime == -1 then
					showPopup(s)
				end
				lastPlayTimes[s] = s.TimePosition
			end
		end
		task.wait(POLL_INTERVAL)
	end
end)
