--== FullBright + Zero Shadows + Decal Reveal (LuaU) ==--

local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

local AMBIENT_CLR    = Color3.fromRGB(200, 200, 200) -- seu "200"
local OUTDOOR_CLR    = Color3.fromRGB(220, 220, 220)

-- Brightness e Exposure por dia/noite
local BRIGHTNESS_DAY  = 0.27
local BRIGHTNESS_NIGHT = 0.55-- igual ao dia se quiser sempre "claro"
local EXPOSURE_DAY    = 0.27
local EXPOSURE_NIGHT  = 0.55

--== Funções ==--

-- FullBright + limpeza
local function applyFullBright()
    Lighting.Brightness               = BRIGHTNESS_DAY
    Lighting.ExposureCompensation     = EXPOSURE_DAY
    Lighting.GlobalShadows            = false      -- zero sombras
    Lighting.ShadowSoftness           = 0          -- sem suavização
    Lighting.Ambient                  = AMBIENT_CLR
    Lighting.OutdoorAmbient           = OUTDOOR_CLR
    Lighting.ClockTime                = Lighting.ClockTime
    Lighting.FogEnd                   = 999999
    Lighting.FogStart                 = 0
    Lighting.FogColor                 = Color3.new(0.9, 0.9, 0.9)

    -- remove Atmosphere se existir
    if Lighting:FindFirstChild("Atmosphere") then
        Lighting.Atmosphere:Destroy()
    end
end

-- Desativa todas as Point/Surface/SpotLight
local function disableLights(parent)
    for _, child in parent:GetChildren() do
        if
            child:IsA("PointLight")    or
            child:IsA("SurfaceLight")  or
            child:IsA("SpotLight")
        then
            child.Enabled = false
        end
        if child:IsA("Model") or child:IsA("BasePart") then
            disableLights(child)
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

-- Reveal Decal transparente (Antilag-style, só para o cliente)
local function revealTransparentDecals()
    for _, decal in Workspace:GetDescendants() do
        if
            decal:IsA("Decal") and
            decal.Transparency == 1 and
            decal.Texture ~= ""
        then
            decal.LocalTransparencyModifier = 0 -- força visibilidade
            decal.Texture = decal.Texture -- atualiza a render
        end
    end
end

-- Monitora novos Decals para revelar
local function trackTransparentDecals()
    Workspace.DescendantAdded:Connect(function(descendant)
        if
            descendant:IsA("Decal") and
            descendant.Transparency == 1 and
            descendant.Texture ~= ""
        then
            spawn(function()
                wait(0.1) -- pequeno delay para garantir carga
                descendant.LocalTransparencyModifier = 0
            end)
        end
    end)
end

-- Mantém o FullBright sempre ativo, mesmo com ciclos
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
    Lighting.FogEnd                 = 999999
    Lighting.FogStart               = 0
end)

--== Executa na inicialização ==--
applyFullBright()
disableLights(Workspace)
trackLights()
revealTransparentDecals()
trackTransparentDecals()
