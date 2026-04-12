--== FullBright + SEM LUZ + SINCRONIA REAL + CONVERSOR (LuaU) ==--

local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")
local Players    = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

--== Configurações de FullBright ==--
local AMBIENT_CLR    = Color3.fromRGB(200, 200, 200)
local OUTDOOR_CLR    = Color3.fromRGB(200, 200, 200)
local BRIGHTNESS_VAL = 0 -- Valor corrigido para evitar erro de sintaxe
local EXPOSURE_VAL   = 0.4

--== Funções de Conversão (Materiais e Transparência) ==--

local function transformPart(part)
    if part:IsA("BasePart") then
        -- Tudo que era Transparency 1 vira 0.75
        if part.Transparency == 1 then
            part.Transparency = 0.75
        end
        -- Tudo que era Neon vira Ice
        if part.Material == Enum.Material.Neon then
            part.Material = Enum.Material.Ice
        end
    elseif part:IsA("Decal") or part:IsA("Texture") then
        if part.Transparency == 1 then
            part.Transparency = 0.75
        end
    end
end

--== Gerenciador de Luzes ==--

local function disableLight(light)
    if light:IsA("Light") or light:IsA("PointLight") or light:IsA("SurfaceLight") or light:IsA("SpotLight") then
        light.Enabled = false
    end
end

--== Sistema de Horário e Sino ==--

local lastHour = -1
local sinoSound = Instance.new("Sound")
sinoSound.Name = "SinoHourNotify"
sinoSound.SoundId = "rbxassetid://378977408"
sinoSound.Volume = 1.0
sinoSound.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function updateClock()
    local date = os.date("*t") -- Pega horário do sistema/celular
    local hour = date.hour
    local min  = date.min
    local sec  = date.sec

    -- Sincroniza o relógio do jogo com o real
    Lighting.TimeOfDay = string.format("%02d:%02d:%02d", hour, min, sec)

    -- Toca o sino se a hora mudou
    if hour ~= lastHour then
        if lastHour ~= -1 then -- Evita tocar assim que o script abre
            sinoSound:Play()
        end
        lastHour = hour
    end
end

--== Inicialização de Varredura ==--

for _, obj in ipairs(Workspace:GetDescendants()) do
    transformPart(obj)
    disableLight(obj)
end

Workspace.DescendantAdded:Connect(function(obj)
    transformPart(obj)
    disableLight(obj)
end)

--== Heartbeat Loop (Atualização Constante sem Lag) ==--

RunService.Heartbeat:Connect(function()
    -- Mantém FullBright
    Lighting.Brightness = BRIGHTNESS_VAL
    Lighting.ExposureCompensation = EXPOSURE_VAL
    Lighting.GlobalShadows = false
    Lighting.Ambient = AMBIENT_CLR
    Lighting.OutdoorAmbient = OUTDOOR_CLR
    Lighting.FogEnd = 999999
    
    -- Atualiza Horário do Celular no Jogo e verifica Sino
    updateClock()
end)

-- Remove Atmosfera para manter clareza total
if Lighting:FindFirstChild("Atmosphere") then
    Lighting.Atmosphere:Destroy()
end

warn("Script Ativo: FullBright, Conversão de Materiais e Horário Real Sincronizado.")
