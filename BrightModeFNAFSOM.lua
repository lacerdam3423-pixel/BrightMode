--// SERVICES
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

--// CONFIG
local CONFIG = {
	ExposureDay = 0.3,
	ExposureNight = 0.6,
	Brightness = 2,
	FPSCap = 200,
	MaxDistance = 100
}

--// FPS UNLOCK (Simples)
pcall(function()
	if setfpscap then
		setfpscap(CONFIG.FPSCap)
	end
end)

--// REMOVE LUZES E EFEITOS
local function cleanEffects()
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("PointLight")
		or v:IsA("SpotLight")
		or v:IsA("SurfaceLight") then
			v:Destroy()
		end
	end
	
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("BloomEffect")
		or v:IsA("SunRaysEffect")
		or v:IsA("ColorCorrectionEffect")
		or v:IsA("DepthOfFieldEffect")
		or v:IsA("BlurEffect") then
			v:Destroy()
		end
	end
end

--// BRIGHT MODE (EXPOSURE)
local function applyExposure()
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 1e10
	Lighting.FogStart = 1e10
	Lighting.Brightness = CONFIG.Brightness

	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	-- Exposure automático sem travar horário
	local clock = Lighting.ClockTime

	if clock >= 6 and clock <= 18 then
		Lighting.ExposureCompensation = CONFIG.ExposureDay
	else
		Lighting.ExposureCompensation = CONFIG.ExposureNight
	end
end

--// ANTI LAG (SEM QUEBRAR TEXTURA)
local function antiLag()
	Workspace.StreamingEnabled = true

	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = false
		end
	end
end

--// AUTO REAPLICAR
local function applyAll()
	cleanEffects()
	applyExposure()
	antiLag()
end

--// LOOP LEVE (OTIMIZADO)
task.spawn(function()
	while true do
		applyExposure()
		task.wait(1)
	end
end)

--// REAPLICA EM MUDANÇAS
Workspace.DescendantAdded:Connect(function()
	task.delay(0.5, applyAll)
end)

Lighting.Changed:Connect(function()
	task.delay(0.2, applyExposure)
end)

player.CharacterAdded:Connect(function()
	task.wait(1)
	applyAll()
end)

--// INIT
applyAll()
