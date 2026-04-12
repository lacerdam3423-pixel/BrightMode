--== SUPREMO OTIMIZADOR V3 (FUNCIONAL & SEM ERROS) ==--

local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local Players    = game:GetService("Players")

-- 1. DESBLOQUEIO DE FPS (Com proteção para não crashar)
pcall(function()
    if setfpscap then
        setfpscap(300)
    end
end)

-- 2. CONFIGURAÇÕES DE STREAMING & PERFORMANCE
if not Workspace.StreamingEnabled then
    pcall(function() Workspace.StreamingEnabled = true end)
end

-- 3. FUNÇÃO DE CONVERSÃO (TRANSPARENCY & MATERIAL)
local function transformObject(obj)
    -- Parts: Transparência 1 -> 0.75 | Neon -> Ice
    if obj:IsA("BasePart") then
        if obj.Transparency == 1 then
            obj.Transparency = 0.75
        end
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        end
        obj.CastShadow = false -- Anti-lag realista
    
    -- Decals: Transparência 1 -> 0 (Ficar visível conforme pedido)
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        if obj.Transparency == 1 then
            obj.Transparency = 0
        end
    
    -- Remover Luzes Físicas (FullBright limpo)
    elseif obj:IsA("Light") then
        obj.Enabled = false
    end
end

-- 4. SISTEMA DE HORÁRIO DO CELULAR & SINO
local lastHour = -1
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local sinoSound = Instance.new("Sound")
sinoSound.Name = "SinoNotificador"
sinoSound.SoundId = "rbxassetid://378977408"
sinoSound.Volume = 1.0
sinoSound.Parent = playerGui

local function updateRealTime()
    local date = os.date("*t")
    -- Aplica o horário do seu dispositivo no jogo
    local timeStr = string.format("%02d:%02d:%02d", date.hour, date.min, date.sec)
    Lighting.TimeOfDay = timeStr
    
    -- Toca o sino na virada da hora
    if date.hour ~= lastHour then
        if lastHour ~= -1 then
            sinoSound:Play()
        end
        lastHour = date.hour
    end
end

-- 5. VARREDURA INICIAL DO MAPA (CARREGAMENTO RÁPIDO)
local function startOptimization()
    for _, item in ipairs(Workspace:GetDescendants()) do
        transformObject(item)
    end
end

-- 6. LOOP CONSTANTE (HEARTBEAT - SEM LAG)
RunService.Heartbeat:Connect(function()
    -- Manutenção do FullBright
    Lighting.Brightness = 2.5
    Lighting.ExposureCompensation = 0.5
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
    Lighting.FogEnd = 999999
    
    -- Atualiza Horário
    updateRealTime()
end)

-- 7. MONITORAMENTO DE NOVOS OBJETOS
Workspace.DescendantAdded:Connect(function(newObj)
    task.spawn(function()
        transformObject(newObj)
    end)
end)

-- Limpeza de efeitos pesados
if Lighting:FindFirstChild("Atmosphere") then
    Lighting.Atmosphere:Destroy()
end

-- Execução inicial
startOptimization()

warn(">>> SCRIPT EXECUTADO COM SUCESSO: 300 FPS / SEM LAG / HORÁRIO REAL <<<")
