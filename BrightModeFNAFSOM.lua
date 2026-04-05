if not game:IsLoaded() then game.Loaded:Wait() end

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- CONFIG (suave para não cegar)
local SETTINGS = {
    Exposure = 1.5,
    Brightness = 1,
    Reflection = 0.25, -- intensidade do "espelho"
    Smooth = true
}

-- FULLBRIGHT SUAVE
local function applyFullBright()
    Lighting.GlobalShadows = false

    Lighting.Brightness = SETTINGS.Brightness
    Lighting.ExposureCompensation = SETTINGS.Exposure

    Lighting.Ambient = Color3.fromRGB(255,255,255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)

    Lighting.FogStart = 0
    Lighting.FogEnd = 1000000
    Lighting.FogColor = Color3.fromRGB(255,255,255)
end

-- REMOVER EFEITOS PESADOS
local function removeEffects()
    for _,v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect")
        or v:IsA("BlurEffect")
        or v:IsA("SunRaysEffect")
        or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end
end

-- DESATIVAR LUZES DO MAPA
local function disableLights()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v.Enabled = false
        end
    end
end

-- REFLEXO LEVE (SEM LAG)
local function applyReflection()
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Reflectance = SETTINGS.Reflection

            if SETTINGS.Smooth then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
    end
end

-- FAST LOAD / STREAMING FORÇADO
local function fastLoad()
    Workspace.StreamingEnabled = true
    Workspace.StreamingMinRadius = 64
    Workspace.StreamingTargetRadius = 512
end

-- ATUALIZAÇÃO CONTÍNUA (ANTI RESET DO JOGO)
RunService.RenderStepped:Connect(function()
    applyFullBright()
    removeEffects()
    disableLights()
    fastLoad()
end)

-- LOOP MAIS PESADO (menos frequente)
task.spawn(function()
    while true do
        applyReflection()
        task.wait(2) -- evita travar celular
    end
end)
