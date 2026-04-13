-- Mayura Engine: Universal Performance & Visual Overhaul
-- Criado por MigMax ;]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- [ CONFIGURAÇÕES EDITÁVEIS ]
local SETTINGS = {
    DayExposure = 0.4,        -- Exposição durante o dia
    NightExposure = 0.7,      -- Exposição durante a noite
    TransparencyGoal = 0.7,   -- O que era 1 (invisível) vira isso
    FPS_Target = 200,         -- Alvo de frames por segundo
    WaterWaveSize = 0,      -- Tamanho das ondas da água
    WaterWaveSpeed = 0.1,      -- Velocidade das ondas
}

-- [ FUNÇÃO DE EDIÇÃO DE MATERIAIS E PARTES ]
local function OptimizePart(obj)
    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
        obj.Reflectance = 0 -- Sem reflexo
        obj.CastShadow = false -- Sem sombras para performance
        
        -- Ajuste de Transparência (1 vira 0.7)
        if obj.Transparency == 1 then
            obj.Transparency = SETTINGS.TransparencyGoal
        end
    end
    
    -- Ajuste de Água
    if obj:IsA("Terrain") then
        obj.WaterReflectance = 0
        obj.WaterTransparency = 0
        obj.WaterWaveSize = SETTINGS.WaterWaveSize
        obj.WaterWaveSpeed = SETTINGS.WaterWaveSpeed
    end
end

-- [ SIMULAÇÃO DE ADMIN ]
local function SimulateAdmin()
    local player = Players.LocalPlayer
    if player then
        -- Isso altera apenas visualmente/localmente para scripts que checam Rank
        player.UserId = 1 -- ID de Admin/Criador comum em testes
        print("Privilégios de Admin simulados para: " .. player.Name)
    end
end

-- [ LOOP PRINCIPAL (HEARTBEAT) ]
-- Roda a cada frame físico do jogo
RunService.Heartbeat:Connect(function()
    -- 1. Exposure Day & Night Dinâmico (Sem ClockTime fixo)
    local currentTime = Lighting.ClockTime
    if currentTime >= 6 and currentTime <= 18 then
        Lighting.ExposureCompensation = SETTINGS.DayExposure
    else
        Lighting.ExposureCompensation = SETTINGS.NightExposure
    end
    
    -- 2. Manter Bright Mode & Sem Névoa
    Lighting.Brightness = 0.1
    Lighting.FogEnd = 9e9
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    
    -- 3. Desbloqueio de FPS (Target 200)
    if setfpscap then
        setfpscap(SETTINGS.FPS_Target)
    end
    
    -- 4. Processar novas partes que entram no mapa (Universal)
    for _, item in pairs(Workspace:GetDescendants()) do
        OptimizePart(item)
    end
end)

-- Inicialização
SimulateAdmin()
Workspace.DescendantAdded:Connect(OptimizePart) -- Garante que itens novos sejam editados

print("Mayura Engine V2: Heartbeat Loop Ativado!")
