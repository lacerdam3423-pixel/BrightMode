--// ULTRA BRIGHT MODE + ANTI LAG (EXPOSURE BASED)
--// LocalScript | Funciona em jogos grandes | Sem travar FPS

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- CONFIG
local CONFIG = {
    ExposureDay = 0.3,
    ExposureNight = 0.6,
    MaxDistance = 1000,
    FPSCap = 200
}

-- FPS UNLOCK (limitado a 200)
pcall(function()
    setfpscap(CONFIG.FPSCap)
end)

-- REMOVER FOG TOTAL
local function removeFog()
    Lighting.FogEnd = 1e10
    Lighting.FogStart = 1e10
    Lighting.FogColor = Color3.fromRGB(255,255,255)
end

-- REMOVER EFEITOS VISUAIS
local function removeEffects()
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect")
        or v:IsA("SunRaysEffect")
        or v:IsA("ColorCorrectionEffect")
        or v:IsA("BlurEffect")
        or v:IsA("DepthOfFieldEffect")
        then
            v:Destroy()
        end
    end
end

-- REMOVER TODAS AS LUZES DO MAPA (SEM QUEBRAR TEXTURAS)
local function removeLights()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("PointLight")
        or v:IsA("SpotLight")
        or v:IsA("SurfaceLight") then
            v:Destroy()
        end
    end
end

-- BRIGHT MODE BASEADO EM EXPOSURE
local function applyExposure()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2

    -- Exposure dinâmico (sem travar hora)
    local hour = Lighting.ClockTime

    if hour >= 6 and hour <= 18 then
        Lighting.ExposureCompensation = CONFIG.ExposureDay
    else
        Lighting.ExposureCompensation = CONFIG.ExposureNight
    end
end

-- ANTI LAG (SEM REMOVER TEXTURA)
local function optimize()
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.Technology = Enum.Technology.Compatibility

    -- Streaming modo leve
    pcall(function()
        Workspace.StreamingEnabled = true
    end)
end

-- VISIBILIDADE MÁXIMA
local function visibility()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CastShadow = false
        end
    end
end

-- APLICAR TUDO
local function applyAll()
    removeFog()
    removeEffects()
    removeLights()
    optimize()
    visibility()
    applyExposure()
end

-- AUTO REAPLICAR (ANTI RESET / MAPA GRANDE)
RunService.RenderStepped:Connect(function()
    applyExposure()
end)

-- REFORÇO A CADA 3 SEGUNDOS
task.spawn(function()
    while true do
        task.wait(3)
        applyAll()
    end
end)

-- EXECUÇÃO INSTANTÂNEA
applyAll()
