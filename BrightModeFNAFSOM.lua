--// ULTRA BRIGHT MODE + ANTILAG (EXPOSURE SYSTEM)
--// Coloque em StarterPlayerScripts

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Config principal
local CONFIG = {
	DayExposure = 0.35,
	NightExposure = 1.2,
	SmoothSpeed = 0.05
}

-- Remove efeitos pesados
local function cleanEffects()
	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") then
			v:Destroy()
		end
	end
end

-- Remove nevoa
local function removeFog()
	Lighting.FogEnd = 9999999
	Lighting.FogStart = 0
	Lighting.FogColor = Color3.new(1,1,1)
end

-- Remove luzes do mapa (sem afetar textura)
local function removeLights()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("PointLight") 
		or obj:IsA("SpotLight") 
		or obj:IsA("SurfaceLight") then
			obj.Enabled = false
		end
	end
end

-- Config iluminação leve
local function optimizeLighting()
	Lighting.GlobalShadows = false
	Lighting.Brightness = 1
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.OutdoorAmbient = Color3.fromRGB(150,150,150)
	Lighting.Ambient = Color3.fromRGB(120,120,120)
end

-- Sistema de exposição dinâmica (sem fixar hora)
local currentExposure = 0

local function updateExposure()
	local clock = Lighting.ClockTime
	
	-- Dia = 6 até 18
	local target = (clock >= 6 and clock <= 18) and CONFIG.DayExposure or CONFIG.NightExposure
	
	-- Suavização (não cega os olhos)
	currentExposure = currentExposure + (target - currentExposure) * CONFIG.SmoothSpeed
	
	Lighting.ExposureCompensation = currentExposure
end

-- Auto reaplicar (anti reset)
local function autoApply()
	cleanEffects()
	removeFog()
	optimizeLighting()
	removeLights()
end

-- Detecta novas luzes (mapa carregando / streaming)
Workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("PointLight") 
	or obj:IsA("SpotLight") 
	or obj:IsA("SurfaceLight") then
		obj.Enabled = false
	end
end)

-- Loop principal ultra leve
RunService.RenderStepped:Connect(function()
	updateExposure()
end)

-- Reaplicação automática leve
task.spawn(function()
	while true do
		autoApply()
		task.wait(5)
	end
end)

-- Inicialização instantânea
autoApply()
