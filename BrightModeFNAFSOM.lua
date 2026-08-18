--!strict

-- ==================== EDITABLE LIGHTING CONFIG ====================
local LIGHTING_SETTINGS = {
	Brightness = 0.3,
	Ambient = Color3.fromRGB(200, 200, 200),
	OutdoorAmbient = Color3.fromRGB(100, 100, 100),
	ExposureCompensation = 0.6,
	ColorShift_Top = Color3.fromRGB(0, 0, 0),
	ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
	GlobalShadows = false,
	Technology = Enum.Technology.Future,
	FogEnd = 0,
	FogStart = 1E10,
	FogColor = Color3.fromRGB(0, 0, 0),
	EnvironmentDiffuseScale = 0,
	EnvironmentSpecularScale = 0,
	ShadowSoftness = 0,
}
-- ==================== END CONFIG ====================

local RunService: RunService = game:GetService("RunService")
local Lighting: Lighting = game:GetService("Lighting")

local function applyLightingValues(): ()
	for property: string, value: any in pairs(LIGHTING_SETTINGS) do
		pcall(function(): ()
			Lighting[property] = value
		end)
	end
end

local function disableAllChildren(): ()
	for _, child: Instance in ipairs(Lighting:GetChildren()) do
		pcall(function(): ()
			(child :: any).Enabled = false
		end)
	end
end

local function fullApply(): ()
	applyLightingValues()
	disableAllChildren()
end

task.spawn(fullApply)

Lighting.Changed:Connect(function(property: string): ()
	if LIGHTING_SETTINGS[property] ~= nil then
		pcall(function(): ()
			Lighting[property] = LIGHTING_SETTINGS[property]
		end)
	end
end)

Lighting.ChildAdded:Connect(function(child: Instance): ()
	task.defer(function(): ()
		pcall(function(): ()
			(child :: any).Enabled = false
		end)
	end)
end)

RunService.Heartbeat:Connect(function(): ()
	applyLightingValues()
	disableAllChildren()
end)
