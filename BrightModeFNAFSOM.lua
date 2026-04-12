--[[
    MIGMAX ULTIMATE OPTIMIZER v3 - 2026
    SISTEMA: Estabilidade 300 FPS | Texturas Nível 4 | FullBright | Conversão Neon-Ice
    DISPOSITIVOS: Otimizado para Mobile (Moto e20/e40) e PC
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local NetworkClient = game:GetService("NetworkClient")

local localPlayer = Players.LocalPlayer

-- == AJUSTES DE ILUMINAÇÃO (CORRIGIDOS) == --
local AMBIENT_CLR = Color3.fromRGB(255, 255, 255)
local OUTDOOR_CLR = Color3.fromRGB(255, 255, 255)
local BRIGHTNESS_VALUE = 0
local EXPOSURE_VALUE = 0.3

-- == SISTEMA DE SINO (HORA REAL) == --
local lastHour = -1
local function setupSino()
    local sound = Instance.new("Sound")
    sound.Name = "SinoHourNotify"
    sound.Parent = localPlayer:WaitForChild("PlayerGui")
    sound.SoundId = "rbxassetid://378977408"
    sound.Volume = 1.0
    return sound
end
local SinoSound = setupSino()

-- == FUNÇÃO DE PROCESSAMENTO DE OBJETOS (SEM DESTRUIR NADA) == --
local function processObject(obj)
    pcall(function()
        -- 1. Regra de Transparência: 1 vira 0.75 (Visibilidade total)
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            if obj.Transparency >= 1 then
                obj.Transparency = 0.7
            end
        end
        
        -- 2. Regra de Material: Neon vira Ice (Reduz brilho excessivo/lag)
        if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        end
        
        -- 3. Desativar Luzes Físicas (FullBright limpo)
        if obj:IsA("Light") then
            obj.Enabled = false
        end
    end)
end

-- == OTIMIZAÇÃO DE MOTOR E REDE == --
local function engineBoost()
    setfpscap(300) -- Forçar 300 FPS
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level04
    
    -- Internet Boost Mobile
    pcall(function()
        settings().Network.IncomingReplicationLag = -1000
        if NetworkClient:FindFirstChild("ClientReplicator") then
            NetworkClient.ClientReplicator.PriorityMethod = Enum.PriorityMethod.AccumulatedPriority
        end
    end)
end

-- == INICIALIZAÇÃO GERAL == --
local function applyAll()
    -- Carregamento Rápido
    if not game:IsLoaded() then game.Loaded:Wait() end
    
    engineBoost()
    
    -- FullBright Inicial
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Ambient = AMBIENT_CLR
    Lighting.OutdoorAmbient = OUTDOOR_CLR
    Lighting.FogEnd = 999999
    
    if Lighting:FindFirstChild("Atmosphere") then
        Lighting.Atmosphere:Destroy()
    end

    -- Processar Mapa Atual
    for _, obj in ipairs(Workspace:GetDescendants()) do
        processObject(obj)
    end
end

-- == MONITORAMENTO CONSTANTE (HEARTBEAT) == --
RunService.Heartbeat:Connect(function()
    -- Mantém FullBright e FPS sempre ativos sem oscilação
    Lighting.Brightness = BRIGHTNESS_VALUE
    Lighting.ExposureCompensation = EXPOSURE_VALUE
    Lighting.GlobalShadows = false
    
    -- Forçar comportamento de textura nível 4 constante
    settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level04
    
    -- Verificação de Hora Real para o Sino
    local dt = DateTime.now():ToLocalTime()
    if dt.Hour ~= lastHour then
        lastHour = dt.Hour
        if SinoSound then SinoSound:Play() end
    end
end)

-- == AUTO-RECOLOCAR (PERSISTÊNCIA) == --
Workspace.DescendantAdded:Connect(function(descendant)
    processObject(descendant)
end)

localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applyAll()
end)

-- Execução de Entrada
applyAll()

-- Streaming Permanente
Workspace.StreamingEnabled = true
Workspace.StreamingMinRadius = 64
Workspace.StreamingTargetRadius = 1024

print("SISTEMA MIGMAX CONCLUÍDO: Otimização 300 FPS e Texturas Ativas.")
