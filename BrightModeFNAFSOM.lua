-- Mayura Engine: Pure Vision & FPS Boost
-- Criado por MigMax ;]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- [ CONFIGURAÇÕES EDITÁVEIS ]
local Settings = {
    ExposureDay = 0.2,        -- Brilho durante o dia
    ExposureNight = 0.5,      -- Brilho durante a noite
    TargetFPS = 200,          -- Limite de FPS
    TransparencyCap = 0.7,    -- Torna o invisível visível (1 -> 0.7)
    ReflectionValue = 0       -- Zero reflexos para performance
}

-- [ DESBLOQUEAR FPS ]
if setfpscap then
    setfpscap(Settings.TargetFPS)
end

-- [ LOOP DE OTIMIZAÇÃO (HEARTBEAT) ]
RunService.Heartbeat:Connect(function()
    -- 1. Controle de Iluminação (Bright Mode & No Fog)
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 999999
    Lighting.Brightness = 0
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    
    -- Exposure Day/Night dinâmico
    if Lighting.ClockTime >= 6 and Lighting.ClockTime <= 18 then
        Lighting.ExposureCompensation = Settings.ExposureDay
    else
        Lighting.ExposureCompensation = Settings.ExposureNight
    end

    -- 2. Limpeza de Materiais e Transparência
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- Remove reflexos e sombras de partes e meshes
        if obj:IsA("BasePart") then
            obj.Reflectance = Settings.ReflectionValue
            obj.CastShadow = false
            
            -- Revelar objetos ocultos/invisíveis
            if obj.Transparency >= 1 then
                obj.Transparency = Settings.TransparencyCap
            end
        end

        -- Otimização de Terreno e Água
        if obj:IsA("Terrain") then
            obj.WaterReflectance = 0
            obj.WaterTransparency = 1
            obj.WaterWaveSize = 0
            obj.WaterWaveSpeed = 0
        end
        
        -- Desativa efeitos pesados de pós-processamento
        if obj:IsA("PostProcessEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("Atmosphere") then
            obj.Enabled = false
        end
    end
end)

-- [ FORÇAR PERFORMANCE GRÁFICA ]
settings().Rendering.QualityLevel = Enum.QualityLevel.Level02
settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level02

print("Mayura Engine: Pure Performance & Full Bright Ativado!")
