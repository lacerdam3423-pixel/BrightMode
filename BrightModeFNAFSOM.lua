--== SUPER OTIMIZADOR: FULLBRIGHT + MAP LOADER + 300 FPS + CONVERSOR ==--

local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local Players    = game:GetService("Players")
local Settings   = settings()

--== Configurações de Performance e FPS ==--
setfpscap(300) -- Desbloqueia e trava em 300 FPS (Requer executor compatível)

-- Configurações de Renderização (Anti-Lag Invisível)
Settings.Network.IncomingReplicationLag = -1000
Settings.Rendering.QualityLevel = Enum.QualityLevel.Level01 -- Menor custo de render

--== Streaming Mode Permanente e Carregamento Rápido ==--
Workspace.StreamingEnabled = true
Workspace.StreamingMinRadius = 1000
Workspace.StreamingTargetRadius = 3000

--== Funções de Conversão e Detalhes ==--

local function optimizeObject(obj)
    -- Conversão de Transparência e Materiais
    if obj:IsA("BasePart") then
        if obj.Transparency == 1 then obj.Transparency = 0.75 end
        if obj.Material == Enum.Material.Neon then obj.Material = Enum.Material.Ice end
        
        -- Anti-Lag: Remove sombras projetadas por partes individuais para ganho de FPS
        obj.CastShadow = false
    
    -- Conversão de Decals (Transparent 1 -> 0)
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        if obj.Transparency == 1 then
            obj.Transparency = 0
        end
    
    -- Desativar Luzes
    elseif obj:IsA("Light") then
        obj.Enabled = false
    end
end

--== Sistema de Horário e Sino (Celular) ==--
local lastHour = -1
local sinoSound = Instance.new("Sound", Players.LocalPlayer:WaitForChild("PlayerGui"))
sinoSound.SoundId = "rbxassetid://378977408"
sinoSound.Volume = 1.0

local function syncClock()
    local date = os.date("*t")
    Lighting.TimeOfDay = string.format("%02d:%02d:%02d", date.hour, date.min, date.sec)
    
    if date.hour ~= lastHour then
        if lastHour ~= -1 then sinoSound:Play() end
        lastHour = date.hour
    end
end

--== Execução de Varredura Rápida (Mapa) ==--
for _, v in ipairs(Workspace:GetDescendants()) do
    optimizeObject(v)
end

Workspace.DescendantAdded:Connect(optimizeObject)

--== Heartbeat Loop (300 FPS Stable & FullBright) ==--
RunService.Heartbeat:Connect(function()
    -- FullBright e Visual Realista Limpo
    Lighting.Brightness = 0
    Lighting.ExposureCompensation = 0.4
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
    
    -- Sincronia de Horário
    syncClock()
end)

-- Limpeza de Atmosfera (Realismo de Claridade)
if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere:Destroy() end

warn("Sistema rodando: 300 FPS Lock | Decals 0 | Mapa Rápido | Sem Lag")
