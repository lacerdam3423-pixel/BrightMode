--// Ultra Bright Mode (Exposure Only) + AntiLag
--// LocalScript | Permanente | Alto desempenho

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- CONFIG
local DAY_EXPOSURE = 0.35
local NIGHT_EXPOSURE = 0.25

-- Remove efeitos pesados
local function removeEffects()
	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("BloomEffect")
		or v:IsA("SunRaysEffect")
		or v:IsA("ColorCorrectionEffect")
		or v:IsA("DepthOfFieldEffect")
		or v:IsA("BlurEffect")
		then
			v:Destroy()
		end
	end
end

-- Anti-lag (sem mexer em textura/mapa)
local function applyPerformance()
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9999999
	Lighting.FogStart = 0
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
	Lighting.Ambient = Color3.fromRGB(255,255,255)
	Lighting.Brightness = 1
end

-- Sistema de Exposure automático (sem travar clock time)
local function applyExposure()
	local time = Lighting.ClockTime
	
	if time >= 6 and time <= 18 then
		Lighting.ExposureCompensation = DAY_EXPOSURE
	else
		Lighting.ExposureCompensation = NIGHT_EXPOSURE
	end
end

-- Mantém sempre ativo (anti reset de mapa/script)
local function enforce()
	removeEffects()
	applyPerformance()
	applyExposure()
end

-- Inicial
enforce()

-- Loop leve (alto desempenho)
RunService.RenderStepped:Connect(function()
	enforce()
end)

-- Reaplicar se algo for adicionado
Lighting.ChildAdded:Connect(function()
	task.wait(0.1)
	enforce()
end)
