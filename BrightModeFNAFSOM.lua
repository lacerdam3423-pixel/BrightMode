--// ULTRA BRIGHT MODE + ANTILAG (Exposure Only)
--// Coloque em StarterPlayerScripts

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// CONFIG
local TARGET_FPS = 200
local RENDER_DISTANCE = 1000

--// FUNÇÃO: LIMPAR EFEITOS
local function cleanEffects()
	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") then
			v:Destroy()
		end
	end

	-- Remover neblina
	Lighting.FogEnd = 9999999
	Lighting.FogStart = 0
	Lighting.FogColor = Color3.new(1,1,1)

	-- Remover sombras e suavização
	Lighting.GlobalShadows = false
	Lighting.Technology = Enum.Technology.Compatibility
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.ShadowSoftness = 0
end

--// FUNÇÃO: REMOVER LUZES PESADAS
local function removeLights()
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("PointLight") 
		or v:IsA("SpotLight") 
		or v:IsA("SurfaceLight") then
			v:Destroy()
		end
	end
end

--// FUNÇÃO: BRIGHT MODE (EXPOSURE BASED)
local function applyExposure()
	Lighting.ClockTime = Lighting.ClockTime -- não fixa o tempo
	
	-- Exposure natural (sem cegar)
	Lighting.ExposureCompensation = 0.35
	
	-- Ajuste dinâmico dia/noite
	local function updateExposure()
		local time = Lighting.ClockTime
		
		if time >= 6 and time <= 18 then
			-- Dia
			Lighting.ExposureCompensation = 0.23
		else
			-- Noite (mais visível)
			Lighting.ExposureCompensation = 0.6
		end
	end
	
	updateExposure()
	
	-- Atualizar automaticamente
	task.spawn(function()
		while true do
			updateExposure()
			task.wait(2)
		end
	end)
end

--// FUNÇÃO: ANTI-LAG SEM QUEBRAR TEXTURAS
local function optimizeWorld()
	Workspace.StreamingEnabled = true
	Workspace.StreamingTargetRadius = RENDER_DISTANCE
	
	-- Não mexe nas texturas (mantém qualidade)
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end

--// FUNÇÃO: REAPLICAR (ANTI RESET)
local function autoReapply()
	Lighting.ChildAdded:Connect(function()
		task.wait()
		cleanEffects()
	end)
end

--// FPS BOOST (limitador leve)
local RunService = game:GetService("RunService")
local last = tick()

RunService.RenderStepped:Connect(function()
	local now = tick()
	local delta = now - last
	
	if delta < (1 / TARGET_FPS) then
		task.wait((1 / TARGET_FPS) - delta)
	end
	
	last = tick()
end)

--// EXECUÇÃO INSTANTÂNEA
cleanEffects()
removeLights()
applyExposure()
optimizeWorld()
autoReapply()

print("✔ Bright Mode Ultra + AntiLag Ativado")
