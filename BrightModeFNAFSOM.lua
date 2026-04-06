--== FullBright (sem luz física) + Zero Sombras + Decal Reveal ==--
--> Ilumina tudo, sem nenhuma luz, mantendo ciclos

local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

local AMBIENT_CLR    = Color3.fromRGB(200, 200, 200) -- "200" ambiente
local OUTDOOR_CLR    = Color3.fromRGB(220, 220, 220)

-- Brightness e Exposure (sem luz, tudo via Lighting)
local BRIGHTNESS_DAY  = 0.55 -- seu valor
local BRIGHTNESS_NIGHT = 1.0
local EXPOSURE_DAY    = 0.55
local EXPOSURE_NIGHT  = 1.0

--== Funções ==--

-- FullBright + sem luz nenhuma
local function applyFullBrightNoLights()
    Lighting.Brightness               = BRIGHTNESS_DAY
    Lighting.ExposureCompensation     = EXPOSURE_DAY
    Lighting.GlobalShadows            = false      -- zero sombras
    Lighting.ShadowSoftness           = 0          -- sem suavização
    Lighting.Ambient                  = AMBIENT_CLR
    Lighting.OutdoorAmbient           = OUTDOOR_CLR
    Lighting.FogEnd                   = 999999
    Lighting.FogStart                 = 0
    Lighting.FogColor                 = Color3.new(0.9, 0.9, 0.9)

    -- remove Atmosphere se tiver
    if Lighting:FindFirstChild("Atmosphere") then
        Lighting.Atmosphere:Destroy()
    end
end

-- Desativa todas as luzes físicas (Point/Surface/Spot)
local function disableAllLights(parent)
    for _, child in parent:GetChildren() do
        if
            child:IsA("PointLight")    or
            child:IsA("SurfaceLight")  or
            child:IsA("SpotLight")
        then
            child.Enabled = false
        end
        if child:IsA("Model") or child:IsA("BasePart") then
            disableAllLights(child)
        end
    end
end

-- Monitora novas luzes
local function trackLights()
    Workspace.DescendantAdded:Connect(function(descendant)
        if
            descendant:IsA("PointLight")    or
            descendant:IsA("SurfaceLight")  or
            descendant:IsA("SpotLight")
        then
            descendant.Enabled = false
        end
    end)
end

-- Revealer de Decals transparentes (Antilag‑style)
local function revealTransparentDecals()
    for _, decal in Workspace:GetDescendants() do
        if
            decal:IsA("Decal") and
            decal.Transparency == 1 and
            decal.Texture ~= ""
        then
            decal.LocalTransparencyModifier = 0 -- mostra
        end
    end
end

-- Monitora novos Decals transparentes
local function trackTransparentDecals()
    Workspace.DescendantAdded:Connect(function(descendant)
        if
            descendant:IsA("Decal") and
            descendant.Transparency == 1 and
            descendant.Texture ~= ""
        then
            spawn(function()
                wait(0.1) -- espera carregar
                descendant.LocalTransparencyModifier = 0
            end)
        end
    end)
end

-- Mantém tudo iluminado, sem luz, dia e noite
RunService:BindToRenderStep("FullBrightUpdater", Enum.RenderPriority.Camera.Value, function()
    local hour = Lighting.ClockTime
    local isDay = hour >= 6 and hour <= 18

    local bright = isDay and BRIGHTNESS_DAY  or BRIGHTNESS_NIGHT
    local expo   = isDay and EXPOSURE_DAY    or EXPOSURE_NIGHT

    Lighting.Brightness             = bright
    Lighting.ExposureCompensation   = expo
    Lighting.GlobalShadows          = false
    Lighting.ShadowSoftness         = 0
    Lighting.Ambient                = AMBIENT_CLR
    Lighting.OutdoorAmbient         = OUTDOOR_CLR
    Lighting.FogEnd                 = 99999
    Lighting.FogStart               = 0
end)

--== Execução ==--
applyFullBrightNoLights()
disableAllLights(Workspace)
trackLights()
revealTransparentDecals()
trackTransparentDecals()
