--[[
    ENGINE INTEGRADA: MigMax Ultimate Performance & Visuals
    Recursos: 300 FPS, Texturas Nível 4, FullBright, Anti-Lag e Sino Real-Time.
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PlayerService = game:GetService("Players")
local NetworkClient = game:GetService("NetworkClient")

local localPlayer = PlayerService.LocalPlayer

-- ==========================================
-- 1. CONFIGURAÇÕES DE ILUMINAÇÃO & FULLBRIGHT
-- ==========================================
local AMBIENT_CLR = Color3.fromRGB(200, 200, 200)
local OUTDOOR_CLR = Color3.fromRGB(220, 220, 220)

local BRIGHTNESS_DAY = 0.25 -- Corrigido de 0.2,5 para 0.25
local BRIGHTNESS_NIGHT = 0.5
local EXPOSURE_DAY = 0.25
local EXPOSURE_NIGHT = 0.5

-- ==========================================
-- 2. SISTEMA DE PERFORMANCE (300 FPS / TEXTURA L4)
-- ==========================================
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function applyPerformanceSettings()
    setfpscap(300) -- Desbloqueio forçado de 300 FPS
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level04 -- Textura nível 4
    settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level04
    
    -- Internet Boost Mobile
    settings().Network.IncomingReplicationLag = -1000
    if NetworkClient:FindFirstChild("ClientReplicator") then
        NetworkClient.ClientReplicator.PriorityMethod = Enum.PriorityMethod.AccumulatedPriority
    end
end

-- ==========================================
-- 3. DETECTOR E DESATIVADOR DE LUZES
-- ==========================================
local function logLightFound(light)
    pcall(function()
        warn(("Luz detectada (Dex/Explorer): %s (%s)"):format(light.Name, light.ClassName))
    end)
end

local function watchAllLights(parent)
    for _, child in ipairs(parent:GetDescendants()) do
        if child:IsA("Light") then
            logLightFound(child)
            child.Enabled = false
        end
    end
end

-- ==========================================
-- 4. REVELAÇÃO DE MAPA & ANTI-LAG INVISÍVEL
-- ==========================================
local function applyVisualOptimization()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- Revelar Transparência 1 -> 0 (Decais e Partes)
        if (obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture")) then
            if obj.Transparency == 1 then
                obj.Transparency = 0
            end
        end
        
        -- Anti-Lag Silencioso (sem destruir nada)
        if obj:IsA("BasePart") and not obj:IsA("Seat") and not obj:IsA("WedgePart") then
            if obj.Name:lower():find("decal") == nil and obj:FindFirstAncestorWhichIsA("Model") == nil then
                obj.LocalTransparencyModifier = 0.2
            end
        end
    end
end

-- ==========================================
-- 5. SISTEMA DE SINO (HORA REAL)
-- ==========================================
local lastHour = -1
local function createSinoSound()
    local playerGui = localPlayer:WaitForChild("PlayerGui")
    local sound = Instance.new("Sound")
    sound.Name = "SinoHourNotify"
    sound.Parent = playerGui
    sound.SoundId = "rbxassetid://378977408"
    sound.Volume = 1.0
    return sound
end

local SinoSound = createSinoSound()

local function checkRealTime()
    local dt = DateTime.now():ToLocalTime()
    local hour = dt.Hour
    if hour ~= lastHour then
        lastHour = hour
        pcall(function()
            SinoSound:Stop()
            SinoSound:Play()
        end)
    end
end

-- ==========================================
-- 6. HEARTBEAT CONSTANTE (ATUALIZAÇÃO 3D & LIGHT)
-- ==========================================
RunService.Heartbeat:Connect(function()
    -- Manter FullBright sem sombras
    local isDay = Lighting.ClockTime >= 7 and Lighting.ClockTime <= 19
    local bright = isDay and BRIGHTNESS_DAY or BRIGHTNESS_NIGHT
    local expo = isDay and EXPOSURE_DAY or EXPOSURE_NIGHT

    Lighting.Brightness = bright
    Lighting.ExposureCompensation = expo
    Lighting.GlobalShadows = false
    Lighting.Ambient = AMBIENT_CLR
    Lighting.OutdoorAmbient = OUTDOOR_CLR
    Lighting.FogEnd = 999999
    
    -- Forçar Textura Nível 4 em tempo real
    settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level04
    
    checkRealTime()
end)

-- ==========================================
-- 7. EVENTOS DE MONITORAMENTO (STREAMING/ADDIÇÃO)
-- ==========================================
Workspace.DescendantAdded:Connect(function(descendant)
    -- Desativar luzes novas
    if descendant:IsA("Light") then
        logLightFound(descendant)
        descendant.Enabled = false
    end
    
    -- Revelar itens novos que entram no Streaming
    if (descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Transparency == 1 then
        task.wait(0.1)
        descendant.Transparency = 0
    end
end)

-- Auto-Recolocar ao carregar personagem
local function Initialize()
    applyPerformanceSettings()
    watchAllLights(Workspace)
    applyVisualOptimization()
    
    -- Streaming Mode Permanente (Simulação)
    Workspace.StreamingEnabled = true
    Workspace.StreamingMinRadius = 64
    Workspace.StreamingTargetRadius = 1024
end

localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    Initialize()
end)

-- Execução inicial
Initialize()
if Lighting:FindFirstChild("Atmosphere") then
    Lighting.Atmosphere:Destroy()
end

print("MigMax Engine: Scripts Integrados com Sucesso. (300 FPS / Sino Ativo)")
