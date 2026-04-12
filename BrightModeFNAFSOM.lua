--[[
    ENGINE INTEGRADA: PERFORMANCE + FULLBRIGHT + SINCRONIZAÇÃO
    Usuário: MigMax
    Configurações: 300 FPS, Texturas Nv4, Transparência 0.75, Sem Lag
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local NetworkClient = game:GetService("NetworkClient")

local localPlayer = Players.LocalPlayer
if not game:IsLoaded() then game.Loaded:Wait() end

-- == CONFIGURAÇÕES DE ILUMINAÇÃO (FULLBRIGHT) == --
local AMBIENT_CLR = Color3.fromRGB(200, 200, 200)
local OUTDOOR_CLR = Color3.fromRGB(220, 220, 220)
local BRIGHTNESS_DAY, BRIGHTNESS_NIGHT = 0.5, 0.5
local EXPOSURE_DAY, EXPOSURE_NIGHT = 0.5, 0.5

-- == SISTEMA DE SOM (SINO) == --
local lastHour = -1
local SinoSound = Instance.new("Sound")
SinoSound.Name = "SinoHourNotify"
SinoSound.Parent = localPlayer:WaitForChild("PlayerGui")
SinoSound.SoundId = "rbxassetid://378977408"
SinoSound.Volume = 1.0

-- == FUNÇÕES DE OTIMIZAÇÃO E VISIBILIDADE == --

local function OptimizeAndReveal()
    -- Desbloqueio de FPS e Qualidade de Textura (Simulação Nível 4)
    setfpscap(300)
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level04
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- Revelar itens invisíveis para 0.75 (Parts e Decals)
        if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
            if obj.Transparency == 1 then
                obj.Transparency = 0.75
            end
        end
        
        -- Desativar Luzes Físicas (Detector)
        if obj:IsA("Light") then
            obj.Enabled = false
        end
    end
end

local function CheckRealTime()
    local dt = DateTime.now():ToLocalTime()
    local hour = dt.Hour
    if hour ~= lastHour then
        lastHour = hour
        SinoSound:Play()
    end
end

local function ApplyLightingSettings()
    local isDay = Lighting.ClockTime >= 7 and Lighting.ClockTime <= 19
    Lighting.Brightness = isDay and BRIGHTNESS_DAY or BRIGHTNESS_NIGHT
    Lighting.ExposureCompensation = isDay and EXPOSURE_DAY or EXPOSURE_NIGHT
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.Ambient = AMBIENT_CLR
    Lighting.OutdoorAmbient = OUTDOOR_CLR
    Lighting.FogEnd = 999999
    
    if Lighting:FindFirstChild("Atmosphere") then
        Lighting.Atmosphere:Destroy()
    end
end

-- == LOOP CONSTANTE (HEARTBEAT) == --
-- Tudo integrado aqui para rodar a cada quadro do jogo
RunService.Heartbeat:Connect(function()
    ApplyLightingSettings()
    CheckRealTime()
    
    -- Mantém a força do 3D e texturas sempre ativa
    settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level04
    
    -- Internet Boost / Network Optimization
    settings().Network.IncomingReplicationLag = -1000
end)

-- == MONITORAMENTO DE NOVOS OBJETOS (ANTILAG E REVELAÇÃO) == --
Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    if (obj:IsA("BasePart") or obj:IsA("Decal")) and obj.Transparency == 1 then
        obj.Transparency = 0.75
    end
    if obj:IsA("Light") then
        obj.Enabled = false
    end
end)

-- == INICIALIZAÇÃO == --
local function Start()
    OptimizeAndReveal()
    ApplyLightingSettings()
end

Start()

-- Auto-recolocar ao spawnar
localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    Start()
end)

print("Script Integrado MigMax: Performance 300 FPS + FullBright + Transparência 0.75 Ativos.")
