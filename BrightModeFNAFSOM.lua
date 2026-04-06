--== FullBright + TODOS Lights Bloqueados + Antilag quase invisível ==--

local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

local AMBIENT_CLR    = Color3.fromRGB(200, 200, 200) -- "200"
local OUTDOOR_CLR    = Color3.fromRGB(220, 220, 220)

-- Brightness dia 0.55 / noite 1
local BRIGHTNESS_DAY  = 0.01
local BRIGHTNESS_NIGHT = 0.01
local EXPOSURE_DAY    = 0.01
local EXPOSURE_NIGHT  = 1

--== Desativa TODOS os tipos de luz ==--
local function disableAllLights(parent)
    for _, child in parent:GetChildren() do
        -- Todos os tipos de Light
        if child:IsA("Light") or
           child:IsA("PointLight") or
           child:IsA("SurfaceLight") or
           child:IsA("SpotLight") or
           child:IsA("ArcLight")
        then
            child.Enabled = false
        end

        if child:IsA("Model") or child:IsA("BasePart") then
            disableAllLights(child) -- recursivo
        end
    end
end

-- Monitora novas luzes (todos os tipos)
local function trackAllLights()
    Workspace.DescendantAdded:Connect(function(descendant)
        if
            descendant:IsA("Light") or
            descendant:IsA("PointLight") or
            descendant:IsA("SurfaceLight") or
            descendant:IsA("SpotLight") or
            descendant:IsA("ArcLight")
        then
            descendant.Enabled = false
        end
    end)
end

--== FullBright sem luz física ==--
local function applyFullBrightNoLights()
    Lighting.Brightness               = BRIGHTNESS_DAY
    Lighting.ExposureCompensation     = EXPOSURE_DAY
    Lighting.GlobalShadows            = false      -- sem sombras
    Lighting.ShadowSoftness           = 0          -- sem suavização
    Lighting.Ambient                  = AMBIENT_CLR
    Lighting.OutdoorAmbient           = OUTDOOR_CLR
    Lighting.ClockTime                = Lighting.ClockTime
    Lighting.FogEnd                   = 999999
    Lighting.FogStart                 = 0
    Lighting.FogColor                 = Color3.new(0.9, 0.9, 0.9)

    if Lighting:FindFirstChild("Atmosphere") then
        Lighting.Atmosphere:Destroy()
    end
end

--== Antilag quase invisível + Decal reveal ==--
local function applyAntilag()
    for _, part in Workspace:GetDescendants() do
        if
            part:IsA("BasePart") and
            not part:IsA("Seat") and
            not part:IsA("WedgePart") and
            part.Name:lower():find("decal") == nil and
            part:FindFirstAncestorWhichIsA("Model") == nil -- não mexe em Model/character
        then
            part.LocalTransparencyModifier = 0.2 -- leve, quase invisível
        end
    end

    -- Revealer de Decals transparentes
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
                wait(0.1)
                descendant.LocalTransparencyModifier = 0
            end)
        end
    end)
end

--== Mantém FullBright + zero luz física dia/noite ==--
RunService:BindToRenderStep("FullBrightUpdater", Enum.RenderPriority.Camera.Value, function()
    local hour = Lighting.ClockTime
    local isDay = hour >= 7 and hour <= 19

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

--== Execução ==--
applyFullBrightNoLights()
disableAllLights(Workspace)
trackAllLights()
applyAntilag()
trackTransparentDecals()
