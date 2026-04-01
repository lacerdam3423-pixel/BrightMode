wait("0.01") -- Como você pediu no começo!

---------------------------------------------------------
-- CONFIGURAÇÕES (Edite aqui o Exposure e as cores)
---------------------------------------------------------
local BRIGHT = 0.01
local AMBIENT = Color3.fromRGB(255, 255, 255)
local OUTDOOR = Color3.fromRGB(255, 255, 255)
local FOG_COLOR = Color3.fromRGB(255, 255, 255)

-- Suas novas configurações de Exposição (Exposure)
local EXPOSURE_DAY = 0.01   -- Exposição durante o dia
local EXPOSURE_NIGHT = 0.37,5 -- Exposição durante a noite
---------------------------------------------------------

local Lighting = game:GetService("Lighting")

local BLOCKED_EFFECTS = {
	BloomEffect = true,
	SunRaysEffect = true,
	Atmosphere = true,
}

-- Função para calcular a exposição com base no horário
local function getExposure()
	local hour = Lighting:GetMinutesAfterMidnight() / 60
	return (hour >= 6 and hour < 18) and EXPOSURE_DAY or EXPOSURE_NIGHT
end

-- Aplica as configurações principais sem travar
local function applyLighting()
	Lighting.Brightness = BRIGHT
	Lighting.GeographicLatitude = 0
	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.Ambient = AMBIENT
	Lighting.OutdoorAmbient = OUTDOOR
	Lighting.ShadowSoftness = 0
	Lighting.FogEnd = 100000
	Lighting.FogStart = 0
	Lighting.FogColor = FOG_COLOR
	Lighting.ExposureCompensation = getExposure()
end

local function removeBlockedEffects()
	for _, effect in ipairs(Lighting:GetChildren()) do
		if BLOCKED_EFFECTS[effect.ClassName] then
			pcall(function() effect:Destroy() end)
		end
	end
end

-- Função para desativar luzes do mapa
local function disableLight(obj)
	pcall(function()
		obj.Brightness = 0
		obj.Enabled = false
		obj.Range = 0
	end)
end

-- Verifica se não é uma interface (UI) para não quebrar o jogo
local function isSafeObject(obj)
	local parent = obj.Parent
	while parent do
		local class = parent.ClassName
		if class == "ScreenGui" or class == "BillboardGui" or class == "SurfaceGui" or class == "LayerCollector" then
			return false
		end
		parent = parent.Parent
	end
	return true
end

-- Aplica o efeito visual nos blocos e luzes
local function applyBright(obj)
	if not obj or not obj.Parent then return end
	pcall(function()
		if obj:IsA("BasePart") then
			if not isSafeObject(obj) then return end
			obj.CastShadow = false
			if obj.Material == Enum.Material.Neon then
				obj.Material = Enum.Material.SmoothPlastic
			end
			for _, child in ipairs(obj:GetChildren()) do
				if child:IsA("PointLight") or child:IsA("SpotLight") or child:IsA("SurfaceLight") then
					disableLight(child)
				end
			end
		elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			disableLight(obj)
		end
	end)
end

-- Execução inicial
applyLighting()
removeBlockedEffects()

for _, obj in ipairs(workspace:GetDescendants()) do
	applyBright(obj)
end

---------------------------------------------------------
-- CONEXÕES EM TEMPO REAL (Sem loops pesados / Sem piscar)
---------------------------------------------------------

-- Monitora novos objetos que entram no jogo
workspace.DescendantAdded:Connect(function(obj)
	task.defer(function()
		applyBright(obj)
	end)
end)

-- Monitora se o jogo tentar recriar efeitos bloqueados
Lighting.ChildAdded:Connect(function(child)
	if BLOCKED_EFFECTS[child.ClassName] then
		pcall(function() child:Destroy() end)
	end
end)

-- O SEGREDO PARA NÃO PISCAR: Escuta as mudanças de propriedade instantaneamente!
local propertiesToLock = {
	"Brightness", "GlobalShadows", "Ambient", 
	"OutdoorAmbient", "EnvironmentDiffuseScale", "EnvironmentSpecularScale"
}

for _, prop in ipairs(propertiesToLock) do
	Lighting:GetPropertyChangedSignal(prop):Connect(function()
		applyLighting()
	end)
end

-- Atualiza a exposição de forma super suave quando o tempo (horas) passar
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
	local targetExposure = getExposure()
	if Lighting.ExposureCompensation ~= targetExposure then
		Lighting.ExposureCompensation = targetExposure
	end
end)
