--[[
    FINAL BUG-FIXED & OPTIMIZED HUB
    - 300 FPS Forçado (Uncapped)
    - Qualidade de Textura Nível 4 (Mobile/PC)
    - Transparência 1 -> 0.75 (Sem desaparecer itens)
    - Material Neon -> Ice
    - FullBright + Sino Real + Internet Boost
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local NetworkClient = game:GetService("NetworkClient")

local localPlayer = Players.LocalPlayer

-- == CORREÇÃO DE VALORES (BRIGHTNESS/EXPOSURE) == --
local AMBIENT_CLR = Color3.fromRGB(200, 200, 200)
local OUTDOOR_CLR = Color3.fromRGB(220, 220, 220)
local BRIGHTNESS_DAY = 2.5 -- Corrigido: ponto em vez de vírgula
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

-- == FUNÇÃO DE PROCESSAMENTO DE OBJETOS (ANTILAG INVISÍVEL) == --
local function fixObject(obj)
    -- Revelar Transparência (1 para 0.75) sem quebrar o mapa
    if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
        if obj.Transparency == 1 then
            obj.Transparency = 0.75
        end
    end
    
    -- Troca de Material solicitada
    if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
        obj.Material = Enum.Material.Ice
    end
    
    -- Desativar luzes físicas para Antilag
    if obj:IsA("Light") then
        obj.Enabled = false
    end
end

-- == OTIMIZAÇÃO DE PERFORMANCE (300 FPS & NETWORK) == --
local function initializeSystem()
    if not game:IsLoaded() then game.Loaded:Wait() end
    
    -- Forçar 300 FPS e Nível 4 de Textura
    setfpscap(300)
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level04
    
    -- Internet Boost (Mobile Optimization)
    settings().Network.IncomingReplicationLag = -1000
    if NetworkClient:FindFirstChild("ClientReplicator") then
        NetworkClient.ClientReplicator.PriorityMethod = Enum.PriorityMethod.AccumulatedPriority
    end

    -- Aplicar a todos os objetos já existentes
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        fixObject(descendant)
    end
end

-- == HEARTBEAT (LOOP CONSTANTE SEM LAG) == --
RunService.Heartbeat:Connect(function()
    -- Manter FullBright Estável
    local isDay = Lighting.ClockTime >= 7 and Lighting.ClockTime <= 19
    Lighting.Brightness = isDay and BRIGHTNESS_DAY or BRIGHTNESS_NIGHT
    Lighting.ExposureCompensation = isDay and EXPOSURE_DAY or EXPOSURE_NIGHT
    Lighting.GlobalShadows = false
    
    -- Trava de Qualidade
    settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level04
    
    -- Sino de Hora Real
    local dt = DateTime.now():ToLocalTime()
    if dt.Hour ~= lastHour then
        lastHour = dt.Hour
        SinoSound:Play()
    end
end)

-- Monitorar novos itens que entram no mapa
Workspace.DescendantAdded:Connect(fixObject)

-- Iniciar
initializeSystem()

print("Tudo consertado: 300 FPS Forçado, Texturas Nível 4 e Antilag Ativo.")
