local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- CONFIG
local TARGET_FPS = 200
local RENDER_DISTANCE = 1000

-- BRIGHT MODE VIA EXPOSURE
local function applyBrightMode()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9999999
    Lighting.FogStart = 0
    Lighting.FogColor = Color3.new(1,1,1)

    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    -- Exposure (principal)
    Lighting.ExposureCompensation = 0.6 -- equilibrado (não cega)
end

-- REMOVE EFEITOS PESADOS
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

-- REMOVE LUZES DO MAPA
local function removeLights()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("PointLight")
        or v:IsA("SpotLight")
        or v:IsA("SurfaceLight") then
            v:Destroy()
        end
    end
end

-- ANTI LAG SEM QUEBRAR TEXTURA
local function optimize()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end

-- CARREGAMENTO DE MAPA (SIMULA 1000 STUDS)
local function preloadMap()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if (v.Position - root.Position).Magnitude < RENDER_DISTANCE then
                v.LocalTransparencyModifier = v.LocalTransparencyModifier
            end
        end
    end
end

-- DESBLOQUEIO DE FPS (loop estável)
local function fpsUnlock()
    local frameTime = 1 / TARGET_FPS
    while true do
        local start = tick()

        RunService.RenderStepped:Wait()

        local elapsed = tick() - start
        if elapsed < frameTime then
            task.wait(frameTime - elapsed)
        end
    end
end

-- AUTO REAPLICAR (ANTI RESET)
local function autoReapply()
    RunService.RenderStepped:Connect(function()
        applyBrightMode()
    end)

    Lighting.ChildAdded:Connect(function()
        removeEffects()
    end)

    Workspace.DescendantAdded:Connect(function(v)
        if v:IsA("PointLight")
        or v:IsA("SpotLight")
        or v:IsA("SurfaceLight") then
            v:Destroy()
        end
    end)
end

-- EXECUÇÃO INSTANTÂNEA
applyBrightMode()
removeEffects()
removeLights()
optimize()
preloadMap()
autoReapply()

task.spawn(fpsUnlock)
