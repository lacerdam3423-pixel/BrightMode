--// SERVICES
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

--// CONFIG
local CONFIG = {
    ExposureDay = 0.2,
    ExposureNight = 0.55,
    Brightness = 0.0,
    MaxDistance = 1000,
    FPSCap = 200
}

--// ===== BRIGHT MODE (EXPOSURE ONLY) =====
local function applyBrightness()
    Lighting.GlobalShadows = false
    Lighting.Brightness = CONFIG.Brightness

    -- Remove fog
    Lighting.FogEnd = 999999999
    Lighting.FogStart = 0

    -- Exposure control
    Lighting.ExposureCompensation = CONFIG.ExposureDay

    -- Mantém ambiente neutro
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
end

--// ===== REMOVE EFFECTS =====
local function removeEffects()
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect")
        or v:IsA("BlurEffect")
        or v:IsA("ColorCorrectionEffect")
        or v:IsA("SunRaysEffect")
        or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end
end

--// ===== REMOVE LIGHT OBJECTS =====
local function removeLights(obj)
    if obj:IsA("PointLight")
    or obj:IsA("SpotLight")
    or obj:IsA("SurfaceLight") then
        obj:Destroy()
    end
end

local function cleanLights()
    for _, v in pairs(Workspace:GetDescendants()) do
        removeLights(v)
    end
end

-- Auto remover novos
Workspace.DescendantAdded:Connect(removeLights)

--// ===== ANTI LAG (SEM REMOVER TEXTURA) =====
local function applyAntiLag()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

    -- NÃO mexe em textura (mantém 4K)
    Lighting.Technology = Enum.Technology.Compatibility
end

--// ===== STREAMING BOOST =====
local function applyStreaming()
    if Workspace.StreamingEnabled then
        Workspace.StreamingTargetRadius = CONFIG.MaxDistance
        Workspace.StreamingMinRadius = CONFIG.MaxDistance
    end
end

--// ===== AUTO REAPPLY =====
local function fullApply()
    applyBrightness()
    removeEffects()
    cleanLights()
    applyAntiLag()
    applyStreaming()
end

-- Executa instantâneo
fullApply()

-- Reaplica constantemente (evita scripts do jogo resetarem)
RunService.RenderStepped:Connect(function()
    Lighting.ExposureCompensation = CONFIG.ExposureDay
end)

-- Respawn
player.CharacterAdded:Connect(function()
    task.wait(1)
    fullApply()
end)

--// ===== FPS UNLOCK + CAP =====
pcall(function()
    if setfpscap then
        setfpscap(CONFIG.FPSCap)
    end
end)

--// ===== SAFE LOOP (LOW COST) =====
task.spawn(function()
    while true do
        fullApply()
        task.wait(5)
    end
end)
