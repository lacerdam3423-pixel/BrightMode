--// ULTRA BRIGHT MODE + ANTI LAG (Exposure Based)
--// Otimizado | Sem travar | Universal | Mobile Friendly

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

--// FPS CAP
pcall(function()
	setfpscap(CONFIG.FPSCap)
end)

--// FUNÇÃO: LIMPAR EFEITOS VISUAIS
local function cleanEffects()
	for _, v in ipairs(Lighting:GetDescendants()) do
		if v:IsA("BloomEffect")
		or v:IsA("SunRaysEffect")
		or v:IsA("ColorCorrectionEffect")
		or v:IsA("DepthOfFieldEffect")
		or v:IsA("BlurEffect") then
			v:Destroy()
		end
	end
end

--// FUNÇÃO: REMOVER LUZES DO MAPA
local function removeLights()
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("PointLight")
		or v:IsA("SpotLight")
		or v:IsA("SurfaceLight") then
			v.Enabled = false
		end
	end
end

--// FUNÇÃO: ANTI-LAG (SEM MEXER TEXTURAS)
local function optimize()
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 1e10 -- fog invisível (não remove)
	Lighting.FogStart = 0

	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
	Lighting.Ambient = Color3.fromRGB(255,255,255)

	Lighting.Technology = Enum.Technology.Compatibility
end

--// FUNÇÃO: EXPOSURE DINÂMICO
local function applyExposure()
	local brightness = Lighting.Brightness

	if brightness > 0.5 then
		Lighting.ExposureCompensation = CONFIG.ExposureDay
	else
		Lighting.ExposureCompensation = CONFIG.ExposureNight
	end
end

--// FUNÇÃO: FULL BRIGHT LIMPO
local function applyBright()
	Lighting.Brightness = 0.5
	Lighting.ClockTime = Lighting.ClockTime -- não fixa

	Lighting.ColorShift_Top = Color3.new(0,0,0)
	Lighting.ColorShift_Bottom = Color3.new(0,0,0)
end

--// FUNÇÃO: RENDER DISTANCE
local function renderBoost()
	pcall(function()
		Workspace.StreamingEnabled = true
		Workspace.StreamingTargetRadius = CONFIG.MaxDistance
	end)
end

--// AUTO REAPLICAR (ANTI RESET)
local function autoFix()
	cleanEffects()
	removeLights()
	optimize()
	applyBright()
	applyExposure()
	renderBoost()
end

--// LOOP PRINCIPAL (ULTRA LEVE)
RunService.RenderStepped:Connect(function()
	autoFix()
end)

--// EXECUÇÃO INSTANTÂNEA
autoFix()

print("✅ Ultra Bright Mode + AntiLag Ativado")
