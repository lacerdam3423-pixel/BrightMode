--== SCRIPT HÍBRIDO: SUPREMO OTIMIZADOR + FULLBRIGHT + SINCRONIA REAL ==--

local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local Players    = game:GetService("Players")

--== 1. CONFIGURAÇÕES DE FRAMErate E PERFORMANCE ==--
pcall(function()
    if setfpscap then
        setfpscap(100)
    end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

-- Configuração de Terreno (do seu script de FPS)
local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
end

--== 2. FUNÇÃO DE CONVERSÃO HÍBRIDA (MATERIAIS E TRANSPARÊNCIA) ==--

local function transformObject(v)
    -- Lógica de Partes e Materiais
    if v:IsA("BasePart") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
        -- Se for Neon vira Ice, se não, vira Plastic (conforme o segundo script)
        if v.Material == Enum.Material.Neon then
            v.Material = Enum.Material.Ice
        else
            v.Material = Enum.Material.Plastic
        end
        
        v.Reflectance = 0
        v.CastShadow = false
        
        -- Tudo que era Transparency 1 vira 0.75
        if v.Transparency == 1 then
            v.Transparency = 0.45
        end

    -- Lógica de Decals (Transparent 1 vira 0 e mantém os outros visíveis)
    elseif v:IsA("Decal") or v:IsA("Texture") then
        if v.Transparency == 1 then
            v.Transparency = 0 -- Mostra o que estava escondido
        end

    -- Efeitos de Partícula e Explosão (Anti-Lag)
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
        
    -- Desativar Luzes Físicas
    elseif v:IsA("Light") then
        v.Enabled = false
    end
end

--== 3. SISTEMA DE HORÁRIO DO CELULAR & SINO ==--
local lastHour = -1
local sinoSound = Instance.new("Sound", Players.LocalPlayer:WaitForChild("PlayerGui"))
sinoSound.SoundId = "rbxassetid://378977408"
sinoSound.Volume = 1.0

local function updateClockAndSino()
    local date = os.date("*t")
    Lighting.TimeOfDay = string.format("%02d:%02d:%02d", date.hour, date.min, date.sec)
    
    if date.hour ~= lastHour then
        if lastHour ~= -1 then sinoSound:Play() end
        lastHour = date.hour
    end
end

--== 4. LOOP HEARTBEAT (ATUALIZAÇÃO CONSTANTE SEM LAG) ==--

RunService.Heartbeat:Connect(function()
    -- Lógica de Brightness/Exposure Day & Night conforme pedido
    local hour = os.date("*t").hour
    local isDay = hour >= 6 and hour < 18
    
    if isDay then
        Lighting.Brightness = 0.3
        Lighting.ExposureCompensation = 0.3
    else
        Lighting.Brightness = 0.5
        Lighting.ExposureCompensation = 0.5
    end
    
    -- Configurações permanentes de iluminação
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 999999
    Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
    
    updateClockAndSino()
end)

--== 5. VARREDURA INICIAL E MONITORAMENTO ==--

-- Desativar efeitos de tela (Blur, Bloom, etc)
for _, e in ipairs(Lighting:GetChildren()) do
    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
        e.Enabled = false
    end
end

-- Processar todo o mapa
for _, v in ipairs(game:GetDescendants()) do
    transformObject(v)
end

-- Monitorar novos itens que entrarem no jogo
Workspace.DescendantAdded:Connect(function(obj)
    task.spawn(function()
        transformObject(obj)
    end)
end)

if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere:Destroy() end

warn(">>> SCRIPT HÍBRIDO ATIVO: 300 FPS | MATERIAIS OTIMIZADOS | HORÁRIO REAL <<<")
