--// ULTRA BRIGHT MODE (EXPOSURE SYSTEM) + ANTILAG
--// FEITO PARA PERFORMANCE ALTA + VISUAL LIMPO

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--// CONFIG
local CONFIG = {
	ExposureDay = 0.3,
	ExposureNight = 0.6,
	MaxFPS = 200,
	StreamDistance = 1000
}

--// FPS UNLOCK (safe)
pcall(function()
	if setfpscap then
		setfpscap(CONFIG.MaxFPS)
	end
end)

--// STREAMING (não quebra mapa)
pcall(function()
	if player then
		player.MaximumSimulationRadius = CONFIG.StreamDistance
	end
end)

--// REMOVER LUZES DO MAPA (sem afetar textura)
local function removeLights(obj)
	if obj:IsA("PointLight") 
	or obj:IsA("SpotLight") 
	or obj:IsA("SurfaceLight") then
		obj:Destroy()
	end
end

--// REMOVER EFEITOS VISUAIS
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

--// REMOVER NEVOA
local function removeFog()
	Lighting.FogEnd = 1000000
	Lighting.FogStart = 0
	Lighting.FogColor = Color3.fromRGB(255,255,255)
end

--// DESATIVAR SOMBRAS E REFLEXOS PESADOS
local function optimizeLighting()
	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.ShadowSoftness = 0
end

--// SISTEMA DE EXPOSURE DINÂMICO
local function applyExposure()
	local time = Lighting.ClockTime
	
	if time >= 6 and time <= 18 then
		Lighting.ExposureCompensation = CONFIG.ExposureDay
	else
		Lighting.ExposureCompensation = CONFIG.ExposureNight
	end
end

--// ANTI-LAG SEM QUEBRAR TEXTURAS
local function antiLag()
	for _, v in pairs(workspace:GetDescendants()) do
		removeLights(v)
	end
end

--// AUTO REAPLICAR (ANTI RESET DO JOGO)
local function loopSystem()
	RunService.RenderStepped:Connect(function()
		applyExposure()
	end)

	task.spawn(function()
		while true do
			cleanEffects()
			removeFog()
			optimizeLighting()
			antiLag()
			task.wait(2)
		end
	end)
end

--// DETECTAR NOVOS OBJETOS
workspace.DescendantAdded:Connect(function(obj)
	removeLights(obj)
end)

--// EXECUÇÃO INSTANTÂNEA
cleanEffects()
removeFog()
optimizeLighting()
antiLag()
loopSystem()
