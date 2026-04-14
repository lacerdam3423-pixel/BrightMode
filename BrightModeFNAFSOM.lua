--// ULTRA BRIGHT MODE (Exposure Only) + ANTI LAG
--// Feito para performance alta, sem destruir texturas

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- CONFIG
local DAY_EXPOSURE = 0.3
local NIGHT_EXPOSURE = 0.6

-- CONTROLE
local lastApply = 0
local APPLY_DELAY = 0.5 -- evita lag (não usar loop pesado)

-- REMOVER EFEITOS
local function removeEffects()
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("BloomEffect") 
		or v:IsA("SunRaysEffect")
		or v:IsA("ColorCorrectionEffect")
		or v:IsA("BlurEffect")
		or v:IsA("DepthOfFieldEffect") then
			v:Destroy()
		end
	end
end

-- REMOVER LUZES DO MAPA
local function removeLights()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("PointLight") 
		or obj:IsA("SpotLight") 
		or obj:IsA("SurfaceLight") then
			obj:Destroy()
		end
	end
end

-- REMOVER FOG
local function removeFog()
	Lighting.FogEnd = 1e10
	Lighting.FogStart = 1e10
	Lighting.FogColor = Color3.fromRGB(255,255,255)
end

-- CONFIGURAÇÃO PRINCIPAL
local function applyBright()
	-- SEM SOMBRAS
	Lighting.GlobalShadows = false
	
	-- TECNOLOGIA MAIS LEVE
	Lighting.Technology = Enum.Technology.Compatibility
	
	-- EXPOSURE DINÂMICO
	if Lighting.ClockTime >= 6 and Lighting.ClockTime <= 18 then
		Lighting.ExposureCompensation = DAY_EXPOSURE
	else
		Lighting.ExposureCompensation = NIGHT_EXPOSURE
	end
	
	-- COR NEUTRA
	Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
	Lighting.Ambient = Color3.fromRGB(255,255,255)
	
	-- SEM REFLEXOS PESADOS
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	
	-- REMOVE FOG
	removeFog()
	
	-- REMOVE EFEITOS
	removeEffects()
end

-- AUTO REAPLICAR (SEM LAG)
RunService.RenderStepped:Connect(function()
	if tick() - lastApply > APPLY_DELAY then
		lastApply = tick()
		
		applyBright()
	end
end)

-- REMOVER LUZES UMA VEZ (evita lag)
task.spawn(function()
	removeLights()
end)

-- REAPLICAR SE ALGO FOR ADICIONADO
Lighting.ChildAdded:Connect(function()
	task.wait(0.2)
	removeEffects()
end)

workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("PointLight") 
	or obj:IsA("SpotLight") 
	or obj:IsA("SurfaceLight") then
		obj:Destroy()
	end
end)

-- FPS CAP (200)
pcall(function()
	setfpscap(200)
end)

print("✔ Ultra Bright Mode Ativado (Exposure System)")
