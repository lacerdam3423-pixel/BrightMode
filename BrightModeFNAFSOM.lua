--[[
    MIGMAX ULTIMATE OPTIMIZER 2026
    Integrado: 300 FPS, Antilag, Relógio Real e Materiais Otimizados
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local NetworkClient = game:GetService("NetworkClient")

local localPlayer = Players.LocalPlayer
local pGui = localPlayer:WaitForChild("PlayerGui")

-- == CONFIGURAÇÕES TÉCNICAS (CONSERTADO) == --
local BRIGHTNESS_DAY = 2.5
local BRIGHTNESS_NIGHT = 0.5
local EXPOSURE_DAY = 0.5
local EXPOSURE_NIGHT = 0.5

-- == 1. CRIAÇÃO DO RELÓGIO DO CELULAR (GUI) == --
local ScreenGui = Instance.new("ScreenGui")
local TimeLabel = Instance.new("TextLabel")

ScreenGui.Name = "MigMaxClock"
ScreenGui.Parent = pGui
ScreenGui.IgnoreGuiInset = true

TimeLabel.Name = "RelogioReal"
TimeLabel.Parent = ScreenGui
TimeLabel.Size = UDim2.new(0, 200, 0, 50)
TimeLabel.Position = UDim2.new(0.5, -100, 0, 10) -- Topo central
TimeLabel.BackgroundTransparency = 1
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.TextStrokeTransparency = 0
TimeLabel.Font = Enum.Font.RobotoMono
TimeLabel.TextSize = 24
TimeLabel.Text = "00:00:00"

-- == 2. ANTILAG INVISÍVEL E REGRAS DE TRANSPARÊNCIA == --
local function optimizeObject(obj)
    -- Transparência 1 vira 0.75 (Revelação sem lag)
    if obj:IsA("BasePart") or obj:IsA("Decal") then
        if obj.Transparency >= 0.95 then
            obj.Transparency = 0.75
        end
    end
    -- Material Neon vira Ice (Estabilidade de FPS)
    if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
        obj.Material = Enum.Material.Ice
    end
    -- Desativar sombras internas para Antilag
    if obj:IsA("BasePart") then
        obj.CastShadow = false
    end
    -- Desativar luzes físicas (FullBright Puro)
    if obj:IsA("Light") then
        obj.Enabled = false
    end
end

-- == 3. CORE ENGINE (FPS & INTERNET) == --
local function coreEngine()
    setfpscap(300) -- Desbloqueia 300 FPS Forçado
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level04
    settings().Network.IncomingReplicationLag = -1000
    
    for _, item in ipairs(Workspace:GetDescendants()) do
        optimizeObject(item)
    end
end

-- == 4. HEARTBEAT LOOP (ATUALIZAÇÃO CONSTANTE) == --
RunService.Heartbeat:Connect(function()
    -- Atualiza Relógio com horário do celular
    local timeData = DateTime.now():ToLocalTime()
    TimeLabel.Text = timeData:FormatLocalTime("LTS", "pt-br")
    
    -- Mantém FullBright e FPS
    local isDay = Lighting.ClockTime >= 7 and Lighting.ClockTime <= 19
    Lighting.Brightness = isDay and BRIGHTNESS_DAY or BRIGHTNESS_NIGHT
    Lighting.ExposureCompensation = isDay and EXPOSURE_DAY or EXPOSURE_NIGHT
    Lighting.GlobalShadows = false
    
    -- Antilag constante sem quebrar nada
    settings().Rendering.EditQualityLevel = Enum.QualityLevel.Level04
end)

-- == 5. EVENTOS E INICIALIZAÇÃO == --
Workspace.DescendantAdded:Connect(function(d)
    task.wait(0.1)
    optimizeObject(d)
end)

coreEngine()

-- Streaming Permanente
Workspace.StreamingEnabled = true
Workspace.StreamingMinRadius = 64
Workspace.StreamingTargetRadius = 1024

print("Tudo pronto! Relógio ativo, 300 FPS e Antilag operando.")
