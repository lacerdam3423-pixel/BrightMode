--[[
    Performance, Visual & Lighting Integrated Hub
    Versão: Integrada para MigMax
    Funcionalidades: 300 FPS, Texturas Nível 4, FullBright, Sino Real, Anti-Lag & Transparência 0.75
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local NetworkClient = game:GetService("NetworkClient")

local localPlayer = Players.LocalPlayer

-- == CONFIGURAÇÕES DE ILUMINAÇÃO == --
local AMBIENT_CLR = Color3.fromRGB(200, 200, 200)
local OUTDOOR_CLR = Color3.fromRGB(220, 220, 220)
local BRIGHTNESS_DAY = 2.5
local BRIGHTNESS_NIGHT = 0.5
local EXPOSURE_DAY = 0.5
local EXPOSURE_NIGHT = 0.5

-- == SISTEMA DE SINO (HORA REAL) == --
local lastHour = -1
local SinoSound = Instance.new("Sound")
SinoSound.Name = "SinoHourNotify"
SinoSound.Parent = localPlayer:WaitForChild("PlayerGui")
SinoSound.SoundId = "rbxassetid://378977408"
SinoSound.Volume = 1.0

-- == FUNÇÕES DE OTIMIZAÇÃO E RENDERIZAÇÃO (ESTILO MIGMAX) == --

local function fastLoadAndBoost()
    if not game:IsLoaded() then game.Loaded:Wait() end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level04 -- Força comportamento Nível 4
    setfpscap(300) -- Desbloqueia 300 FPS
    
    -- Internet Boost
    settings().Network.IncomingReplicationLag = -1000
    if NetworkClient:FindFirstChild("ClientReplicator") then
        NetworkClient.ClientReplicator.PriorityMethod = Enum.PriorityMethod.AccumulatedPriority
    end
end

local function processObject(obj)
    -- Regra de Transparência: 1 vira 0.75
    if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
        if obj.Transparency == 1 then
            obj.Transparency = 0.75
        end
    end
    
    -- Regra de Material: Neon vira Ice
    if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
        obj.Material = Enum.Material.Ice
    end
    
    -- Desativar Luzes Físicas
    if obj:IsA("Light") then
        obj.Enabled = false
    end
end

local function applyGlobalChanges()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        processObject(obj)
    end
end

-- == FULLBRIGHT PERMANENTE == --
local function applyFullBright()
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Ambient = AMBIENT_CLR
    Lighting.OutdoorAmbient = OUTDOOR_CLR
    Lighting.FogEnd = 999999
    Lighting.FogStart = 0
    Lighting.FogColor = Color3.new(0.9, 0.9, 0.9)
    
    if Lighting:FindFirstChild("Atmosphere") then
        Lighting.Atmosphere:Destroy()
    end
end

-- == LOOP CONSTANTE (HEARTBEAT) == --
RunService.Heartbeat:Connect(function()
    -- 1. Controle de Iluminação Dinâmica
    local isDay = Lighting.ClockTime >= 7 and Lighting.ClockTime <= 19
    Lighting.Brightness = isDay and BRIGHTNESS_DAY or BRIGHTNESS_NIGHT
    Lighting.ExposureCompensation = isDay and EXPOSURE_DAY or EXPOSURE_NIGHT
    
    -- 2. Garantia de Performance e Qualidade
    settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level04
    
    -- 3. Checagem de Hora Real (Sino)
    local dt = DateTime.now():ToLocalTime()
    if dt.Hour ~= lastHour then
        lastHour = dt.Hour
        SinoSound:Play()
    end
end)

-- == MONITORAMENTO DE NOVOS OBJETOS (MAPA) == --
Workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.1) -- Pequeno delay para o motor carregar a propriedade
    processObject(descendant)
end)

-- == INICIALIZAÇÃO == --
fastLoadAndBoost()
applyFullBright()
applyGlobalChanges()

-- Streaming Mode Permanente (Simulação)
Workspace.StreamingEnabled = true
Workspace.StreamingMinRadius = 64
Workspace.StreamingTargetRadius = 1024

print("MigMax Hub: FullBright, 300 FPS e Conversão de Materiais Ativada.")
