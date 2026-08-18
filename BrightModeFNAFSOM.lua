--!strict

-- ==================== EDITABLE LIGHTING CONFIG ====================
local LIGHTING_SETTINGS = {
	Brightness = 0.3, 
	Ambient = Color3.fromRGB(200, 200, 200),
	OutdoorAmbient = Color3.fromRGB(0, 0, 0),
	ExposureCompensation = 0.6,
	ColorShift_Top = Color3.fromRGB(0, 0, 0),
	ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
	GlobalShadows = false,
	Technology = Enum.Technology.Compatibility,
	FogEnd = 0,
	FogStart = math.huge,
	FogColor = Color3.fromRGB(0, 0, 0),
	EnvironmentDiffuseScale = 0,
	EnvironmentSpecularScale = 0,
	ShadowSoftness = 0,
}
-- ==================== END CONFIG ====================

local RunService: RunService = game:GetService("RunService")
local Lighting: Lighting = game:GetService("Lighting")
local Players: Players = game:GetService("Players")
local TextChatService: TextChatService = game:GetService("TextChatService")

local LocalPlayer: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local isLightingEnabled: boolean = true
local defaultLighting: {[string]: any} = {}

local connection: RBXScriptConnection? = nil

for prop: string, _ in pairs(LIGHTING_SETTINGS) do
	local success: boolean, val: any = pcall(function(): any
		return Lighting[prop]
	end)
	if success then
		defaultLighting[prop] = val
	end
end

local function applyLightingValues(): ()
	for property: string, value
