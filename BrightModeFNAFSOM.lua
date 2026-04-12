--[[
    Performance, Visual & Lighting Integrated Hub - FINAL FIX
    Versão: Integrada para MigMax
    Regras: Sem quebras, Transparência 0.75, Neon para Ice, 300 FPS, Heartbeat Constante.
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local NetworkClient = game:GetService("NetworkClient")

local localPlayer = Players.LocalPlayer

-- == CORES E VALORES DE FULLBRIGHT (CORRIGIDOS) == --
local AMBIENT_CLR = Color3.fromRGB(200, 200, 200)
local OUTDOOR_CLR = Color3.fromRGB(220, 220, 220)

-- Ajustado para formato decimal numérico correto para o Luau
local BRIGHTNESS_DAY = 0
local BRIGHTNESS_NIGHT = 0
local EXPOSURE_DAY = 0.2,5
local EXPOSURE_NIGHT = 0.5

-- == SISTEMA DE SINO (HORA REAL) == --
local lastHour = -1
local function createSinoSound(parent)
    local sound = Instance.new("Sound")
    sound.Name = "SinoHourNotify"
    sound.Parent = parent
    sound.SoundId = "rbxassetid://378977408"
    sound.Looped = false
    sound.Volume = 1.0
    return sound
end

local SinoSound = createSinoSound(localPlayer:WaitForChild("PlayerGui"))

-- == FUNÇÕES DE PROCESSAMENTO (MIGMAX PROTOCOL) == --

local function processObject(obj)
    pcall(function()
        -- 1. Regra de Transparência: 1 vira 0.75 (Não desaparece nada)
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            if obj.Transparency == 1 then
                obj.Transparency = 0.75
            end
        end
        
        -- 2. Regra de Material: Neon vira Ice
        if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        end
        
        -- 3. Desativar Luzes Físicas (Detector de Luz)
        if obj:IsA("Light") or obj:IsA("PointLight") or obj:IsA("SurfaceLight") or obj:IsA("SpotLight") then
            obj.Enabled = false
        end
    end)
end

-- == SISTEMA DE PERFORMANCE E INTERNET BOOST == --
local function fastLoadAndBoost()
    if not game:IsLoaded() then game.Loaded:Wait() end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level04
    setfpscap(300) -- Desbloqueio forçado 300 FPS
    
    -- Internet Boost Mobile
    settings().Network.IncomingReplicationLag = -1000
    if NetworkClient:FindFirstChild("ClientReplicator") then
        NetworkClient.ClientReplicator.PriorityMethod = Enum.PriorityMethod.AccumulatedPriority
    end
end

-- == FULLBRIGHT E RENDERIZAÇÃO 3D == --
local function applyFullBright()
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Ambient = AMBIENT_CLR
    Lighting.OutdoorAmbient = OUTDOOR_CLR
    Lighting.FogEnd = 999999
    Lighting.FogStart = 0
    
    if Lighting:FindFirstChild("Atmosphere") then
        Lighting.Atmosphere:Destroy()
    end
end

local function applyAntilagInvisivel()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        processObject(obj)
    end
end

-- == HEARTBEAT LOOP CONSTANTE == --
RunService.Heartbeat:Connect(function()
    -- FullBright Permanente
    local isDay = Lighting.ClockTime >= 7 and Lighting.ClockTime <= 19
    local bright = isDay and BRIGHTNESS_DAY or BRIGHTNESS_NIGHT
    local expo = isDay and EXPOSURE_DAY or EXPOSURE_NIGHT

    Lighting.Brightness = bright
    Lighting.ExposureCompensation = expo
    Lighting.GlobalShadows = false
    
    -- Forçar Textura Nível 4 e FPS
    settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level04
    
    -- Checar Hora Real para o Sino
    local dt = DateTime.now():ToLocalTime()
    if dt.Hour ~= lastHour then
        lastHour = dt.Hour
        SinoSound:Play()
    end
end)

-- == MONITORAMENTO EM TEMPO REAL == --
Workspace.DescendantAdded:Connect(function(descendant)
    processObject(descendant)
end)

-- == EXECUÇÃO INICIAL == --
fastLoadAndBoost()
applyFullBright()
applyAntilagInvisivel()

-- Streaming Mode Permanente
Workspace.StreamingEnabled = true
Workspace.StreamingMinRadius = 64
Workspace.StreamingTargetRadius = 1024

print("Script Integrado MigMax: Tudo Ok. 300 FPS / Textura Lvl 4 / FullBright")
