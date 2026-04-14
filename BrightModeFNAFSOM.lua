--// Ultra Bright Mode (Exposure Based) + AntiLag
--// LocalScript | Universal | Performance Safe

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

--// CONFIG
local CONFIG = {
	ExposureDay = 0.3,
	ExposureNight = 0.6,
	MaxDistance = 1000,
	FPSCap = 300
}

--// FPS CAP (200)
pcall(function()
	setfpscap(CONFIG.FPSCap)
end)

--// REMOVE LUZES DINÂMICAS
local function removeLights()
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
			v:Destroy()
		end
	end
end

--// REMOVE EFEITOS VISUAIS
local function cleanEffects()
	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("BloomEffect")
		or v:IsA("SunRaysEffect")
		or v:IsA("ColorCorrectionEffect")
		or v:IsA("DepthOfFieldEffect")
		or v:IsA("BlurEffect") then
			v:Destroy()
		end
	end
end

--// ANTI FOG
local function removeFog()
	Lighting.FogEnd = 1000000
	Lighting.FogStart = 0
	Lighting.FogColor = Color3.fromRGB(255,255,255)
end

--// BRIGHT MODE (Exposure automático)
local function applyExposure()
	local time = Lighting.ClockTime

	if time >= 6 and time <= 18 then
		Lighting.ExposureCompensation = CONFIG.ExposureDay
	else
		Lighting.ExposureCompensation = CONFIG.ExposureNight
	end
end

--// CONFIG GLOBAL (SEM SOMBRA)
local function applyLighting()
	Lighting.GlobalShadows = false
	Lighting.Brightness = 0.1
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
	Lighting.Ambient = Color3.fromRGB(255,255,255)
	Lighting.Technology = Enum.Technology.Compatibility
end

--// STREAMING OTIMIZADO (SEM QUEBRAR MAPA)
local function optimizeStreaming()
	pcall(function()
		Workspace.StreamingEnabled = true
		Workspace.StreamingMinRadius = CONFIG.MaxDistance
		Workspace.StreamingTargetRadius = CONFIG.MaxDistance
	end)
end

--// AUTO REAPLICAÇÃO (ANTI RESET / TROCA DE MAPA)
local function autoApply()
	removeLights()
	cleanEffects()
	removeFog()
	applyLighting()
	optimizeStreaming()
	applyExposure()
end

--// LOOP ULTRA LEVE (SEM LAG)
RunService.RenderStepped:Connect(function()
	applyExposure()
end)

--// PROTEÇÃO CONSTANTE (ANTI JOGO RECOLOCAR EFEITOS)
task.spawn(function()
	while true do
		autoApply()
		task.wait(2)
	end
end)

--// EXECUÇÃO INSTANTÂNEA
autoApply()

--// DETECTA NOVOS OBJETOS (ANTI LIGHT SPAWN)
Workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
		obj:Destroy()
	end
end)

--// PROTEÇÃO DE EFEITOS NOVOS
Lighting.ChildAdded:Connect(function(obj)
	if obj:IsA("BloomEffect")
	or obj:IsA("SunRaysEffect")
	or obj:IsA("ColorCorrectionEffect")
	or obj:IsA("DepthOfFieldEffect")
	or obj:IsA("BlurEffect") then
		obj:Destroy()
	end
end)
