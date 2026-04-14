--// FULL BRIGHT + NOFOG + ANTI LAG
--// LocalScript | Organized | Auto Reapply | No texture changes

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local CONFIG = {
	ExposureDay = 0.3,
	ExposureNight = 0.6,
	FPSCap = 200,
	RenderDistance = 1000,
	AntiLagInterval = 0.2
}

pcall(function()
	setfpscap(CONFIG.FPSCap)
end)

local function setLightingBase()
	Lighting.GlobalShadows = false
	Lighting.Brightness = 0
	Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	Lighting.ColorShift_Top = Color3.new(0, 0, 0)
	Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.Technology = Enum.Technology.Compatibility
end

local function setExposure()
	local clock = Lighting.ClockTime
	if clock >= 6 and clock < 18 then
		Lighting.ExposureCompensation = CONFIG.ExposureDay
	else
		Lighting.ExposureCompensation = CONFIG.ExposureNight
	end
end

local function setNoFog()
	Lighting.FogStart = 0
	Lighting.FogEnd = 1e10

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		atmosphere.Density = 0
		atmosphere.Offset = 0
		atmosphere.Glare = 0
		atmosphere.Haze = 0
	end
end

local function removePostEffects()
	for _, obj in ipairs(Lighting:GetDescendants()) do
		if obj:IsA("BloomEffect")
		or obj:IsA("BlurEffect")
		or obj:IsA("SunRaysEffect")
		or obj:IsA("ColorCorrectionEffect")
		or obj:IsA("DepthOfFieldEffect") then
			obj:Destroy()
		end
	end
end

local function disableWorldLights()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("PointLight")
		or obj:IsA("SpotLight")
		or obj:IsA("SurfaceLight") then
			obj.Enabled = false
		end
	end
end

local function removeReflections()
	pcall(function()
		Lighting.ReflectionIntensity = 0
		Lighting.ShadowSoftness = 0
	end)
end

local function boostStreaming()
	pcall(function()
		Workspace.StreamingEnabled = true
		Workspace.StreamingTargetRadius = CONFIG.RenderDistance
		Workspace.StreamingMinRadius = math.min(128, CONFIG.RenderDistance)
	end)
end

local function antiLag()
	setLightingBase()
	setExposure()
	setNoFog()
	removePostEffects()
	disableWorldLights()
	removeReflections()
	boostStreaming()
end

antiLag()

task.spawn(function()
	while true do
		task.wait(CONFIG.AntiLagInterval)
		antiLag()
	end
end)

RunService.RenderStepped:Connect(function()
	setExposure()
end)
