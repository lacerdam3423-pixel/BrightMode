--// Bright Mode Exposure + AntiLag (Universal)

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- CONFIG
local DAY_EXPOSURE = 0.1
local NIGHT_EXPOSURE = 0.3
local MIDDAY_EXPOSURE = 0.2
local MIDNIGHT_EXPOSURE = 0.4

-- Função para limpar efeitos visuais
local function removeEffects()
	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") 
		or v:IsA("BloomEffect")
		or v:IsA("SunRaysEffect")
		or v:IsA("ColorCorrectionEffect")
		or v:IsA("BlurEffect")
		or v:IsA("DepthOfFieldEffect") then
			v:Destroy()
		end
	end
end

-- Função principal Bright Mode
local function applyBrightMode()
	-- Remove efeitos
	removeEffects()

	-- Iluminação leve e limpa
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 1000000
	Lighting.FogStart = 0
	Lighting.FogColor = Color3.new(1,1,1)

	Lighting.Brightness = 0.55
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.Ambient = Color3.fromRGB(200,200,200)
	Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)

	-- NÃO fixa horário
	-- Ajuste dinâmico por hora do jogo
	local time = Lighting.ClockTime

	if time >= 6 and time < 12 then
		Lighting.ExposureCompensation = DAY_EXPOSURE
	elseif time >= 12 and time < 18 then
		Lighting.ExposureCompensation = MIDDAY_EXPOSURE
	elseif time >= 18 and time < 24 then
		Lighting.ExposureCompensation = NIGHT_EXPOSURE
	else
		Lighting.ExposureCompensation = MIDNIGHT_EXPOSURE
	end
end

-- Auto reaplicar (anti reset / streaming)
task.spawn(function()
	while true do
		applyBrightMode()
		task.wait(2)
	end
end)

-- Atualiza conforme muda o horário
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
	applyBrightMode()
end)

-- Segurança extra (caso jogo tente recriar efeitos)
Lighting.ChildAdded:Connect(function(child)
	if child:IsA("PostEffect") then
		task.wait()
		child:Destroy()
	end
end)

-- Inicial
applyBrightMode()
