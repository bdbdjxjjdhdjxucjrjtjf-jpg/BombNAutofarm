 -- LocalScript: Teleport + Reset loop with ON/OFF GUI button (Mobile)
-- Plus Bomb Spam button
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")

-- CONFIG
local TARGET_POS = Vector3.new(249, -4, -13)
local RESET_DELAY = 0.05

-- State
local tpEnabled = false
local bombEnabled = false
local bombConn

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Teleport button
local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(0, 100, 0, 40)
tpButton.Position = UDim2.new(0.05, 0, 0.75, 0) -- slightly higher
tpButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.TextScaled = true
tpButton.Text = "TP OFF"
tpButton.Parent = screenGui

-- Bomb button
local bombButton = Instance.new("TextButton")
bombButton.Size = UDim2.new(0, 100, 0, 40)
bombButton.Position = UDim2.new(0.05, 0, 0.85, 0) -- just below
bombButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
bombButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bombButton.TextScaled = true
bombButton.Text = "BOMB OFF"
bombButton.Parent = screenGui

-- Teleport to target
local function teleport(character)
	local hrp = character:WaitForChild("HumanoidRootPart", 10)
	if hrp then
		hrp.CFrame = CFrame.new(TARGET_POS)
	end
end

-- Teleport + reset cycle
local function doCycle(character)
	if not tpEnabled then return end

	teleport(character)
	task.wait(RESET_DELAY)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and tpEnabled then
		humanoid.Health = 0
	end
end

-- Run cycle every spawn
lp.CharacterAdded:Connect(function(char)
	task.defer(function()
		doCycle(char)
	end)
end)

if lp.Character then
	task.defer(function()
		doCycle(lp.Character)
	end)
end

-- Toggle teleport button
tpButton.MouseButton1Click:Connect(function()
	tpEnabled = not tpEnabled
	if tpEnabled then
		tpButton.Text = "TP ON"
		tpButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

		-- Reset immediately when turning ON
		if lp.Character then
			doCycle(lp.Character)
		end
	else
		tpButton.Text = "TP OFF"
		tpButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	end
end)

-- Bomb spam function
local function startBombSpam()
	if bombConn then bombConn:Disconnect() end
	local remote = ReplicatedStorage:WaitForChild("PlantBomb")
	bombConn = RunService.Heartbeat:Connect(function()
		if bombEnabled then
			remote:FireServer()
		end
	end)
end

local function stopBombSpam()
	if bombConn then bombConn:Disconnect() end
	bombConn = nil
end

-- Toggle bomb button
bombButton.MouseButton1Click:Connect(function()
	bombEnabled = not bombEnabled
	if bombEnabled then
		bombButton.Text = "BOMB ON"
		bombButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		startBombSpam()
	else
		bombButton.Text = "BOMB OFF"
		bombButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
		stopBombSpam()
	end
end)
