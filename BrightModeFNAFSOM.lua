if not game:IsLoaded() then game.Loaded:Wait() end

local Lighting = game:GetService("Lighting")

-- Guardar valores originais (não mexe no ciclo)
local original = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart,
	GlobalShadows = Lighting.GlobalShadows,
	Technology = Lighting.Technology
}

-- FULLBRIGHT LIMPO
Lighting.Brightness = 3
Lighting.Ambient = Color3.fromRGB(255, 255, 255)
Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

-- Mantém o horário normal do jogo (sem travar ciclo)
Lighting.ClockTime = Lighting.ClockTime

-- Remove névoa completamente
Lighting.FogStart = 0
Lighting.FogEnd = 1000000

-- Remove sombras pesadas
Lighting.GlobalShadows = false

-- Iluminação suave (melhor tecnologia)
Lighting.Technology = Enum.Technology.Future

-- Remove efeitos que escurecem ou pesam
for _, v in pairs(Lighting:GetChildren()) do
	if v:IsA("BloomEffect") or
	   v:IsA("BlurEffect") or
	   v:IsA("SunRaysEffect") or
	   v:IsA("ColorCorrectionEffect") or
	   v:IsA("DepthOfFieldEffect") then
		v:Destroy()
	end
end

-- Remove névoa atmosférica
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if atmosphere then
	atmosphere.Density = 0
	atmosphere.Offset = 0
	atmosphere.Color = Color3.fromRGB(255,255,255)
	atmosphere.Decay = Color3.fromRGB(255,255,255)
end

-- Clarear tudo sem quebrar textura
for _, obj in pairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") then
		obj.CastShadow = false
		if obj.Material == Enum.Material.Neon then
			obj.Material = Enum.Material.SmoothPlastic
		end
	end
end
