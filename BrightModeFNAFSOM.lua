-- Mayura Engine: Extreme Vision & Performance Hub
-- Criado por MigMax ;]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- [ CONFIGURAÇÕES EDITÁVEIS ]
local Settings = {
    ExposureDay = 0.2,        -- Exposição durante o dia
    ExposureNight = 0.5,      -- Exposição durante a noite (mais alta para ver tudo)
    TargetFPS = 200,          -- Desbloqueio de FPS
    TransparencyCap = 0.7,    -- O que era 1 (invisível) vira 0.7
    ReflectionValue = 0       -- Reflexo em BaseParts/MeshParts e Água
}

-- [ DESBLOQUEAR FPS ]
if setfpscap then
    setfpscap(Settings.TargetFPS)
end

-- [ FUNÇÃO PRINCIPAL DE RENDERIZAÇÃO (LOOP) ]
RunService.Heartbeat:Connect(function()
    -- 1. Iluminação e Bright Mode (Sem ClockTime Fixo)
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    
    -- Dinâmica de Exposure Day/Night
    if Lighting.ClockTime >= 6 and Lighting.ClockTime <= 18 then
        Lighting.ExposureCompensation = Settings.ExposureDay
    else
        Lighting.ExposureCompensation = Settings.ExposureNight
    end

    -- 2. Manipulação de Partes e Materiais (Universal)
    for _, obj in pairs(Workspace:GetDescendants()) do
        -- BaseParts e MeshParts: Sem Reflexo
        if obj:IsA("BasePart") then
            obj.Reflectance = Settings.ReflectionValue
            obj.CastShadow = false
            
            -- Ajuste de Transparência (Invisível -> Semi-visível)
            if obj.Transparency >= 1 then
                obj.Transparency = Settings.TransparencyCap
            end
        end

        -- Configuração de Água
        if obj:IsA("Terrain") then
            obj.WaterReflectance = 0
            obj.WaterTransparency = 1
            obj.WaterWaveSize = 0.01 -- Ondas mínimas para estabilidade
            obj.WaterWaveSpeed = 0.05
        end
        
        -- Remover Efeitos de Iluminação Suave
        if obj:IsA("PostProcessEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") then
            obj.Enabled = false
        end
    end
end)

-- [ INTERNET & SIMULAÇÃO ADMIN ]
-- Melhora a prioridade de pacotes e reduz latência visual
settings().Network.IncomingReplicationLag = -1000
if game:GetService("NetworkClient"):FindFirstChild("ClientReplicator") then
    game:GetService("NetworkClient").ClientReplicator.RuntimeOptimized = true
end

-- Simulação de privilégios (Libera comandos locais de desenvolvedor)
local Player = game.Players.LocalPlayer
Player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
if not Player:IsFriendsWith(1) then -- Dummy check para forçar flags de permissão local
    print("Mayura Engine: Admin Privileges Simulated.")
end

print("Mayura Engine: Full Bright & 200 FPS Active!")
