--== FullBright + SEM LUZ FÍSICA + DETECTOR + SINO por hora real (LuaU) ==--

local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

--== Cores e valores de FullBright ==--
local AMBIENT_CLR    = Color3.fromRGB(200, 200, 200) -- 200
local OUTDOOR_CLR    = Color3.fromRGB(220, 220, 220)

local BRIGHTNESS_DAY  = 1
local BRIGHTNESS_NIGHT = 1
local EXPOSURE_DAY    = 1
local EXPOSURE_NIGHT  = 1

--== Procurador de Luz / Sombras (para Dex / Explorer) ==--

local function logLightFound(light)
    pcall(function()
        warn(("Luz detectada (Dex/Explorer): %s (%s)"):format(
            light.Name,
            light.ClassName
        ))
    end)
end

local function watchAllLights(parent)
    for _, child in parent:GetChildren() do
        if
            child:IsA("Light") or
            child:IsA("PointLight") or
            child:IsA("SurfaceLight") or
            child:IsA("SpotLight") or
            child:IsA("ArcLight")
        then
            logLightFound(child)
            child.Enabled = false
        end
        if child:IsA("Model") or child:IsA("BasePart") then
            watchAllLights(child)
        end
    end
end

local function startLightWatcher()
    Workspace.DescendantAdded:Connect(function(descendant)
        if
            descendant:IsA("Light") or
            descendant:IsA("PointLight") or
            descendant:IsA("SurfaceLight") or
            descendant:IsA("SpotLight") or
            descendant:IsA("ArcLight")
        then
            logLightFound(descendant)
            descendant.Enabled = false
        end
    end)
end

--== FullBright permanente SEM luz ==--

local function applyFullBright()
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

-- Antilag quase invisível + Decal reveal
local function applyAntilag()
    for _, part in Workspace:GetDescendants() do
        if
            part:IsA("BasePart") and
            not part:IsA("Seat") and
            not part:IsA("WedgePart") and
            part.Name:lower():find("decal") == nil and
            part:FindFirstAncestorWhichIsA("Model") == nil
        then
            part.LocalTransparencyModifier = 0.2 -- quase invisível
        end
    end

    for _, decal in Workspace:GetDescendants() do
        if
            decal:IsA("Decal") and
            decal.Transparency == 1 and
            decal.Texture ~= ""
        then
            decal.LocalTransparencyModifier = 0 -- revela
        end
    end
end

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

--== Sistema de Sino ao mudar a hora real ==--

local lastHour = -1

local function createSinoSound(parent)
    local sound = Instance.new("Sound")
    sound.Name           = "SinoHourNotify"
    sound.Parent         = parent
    sound.SoundId        = "rbxassetid://378977408" -- Sino bonito
    sound.Looped         = false
    sound.Volume         = 1.0
    return sound
end

local SinoSound = createSinoSound(game.Players.LocalPlayer:WaitForChild("PlayerGui"))

local function checkRealTime()
    local dt     = DateTime.now():ToLocalTime()
    local hour   = dt.Hour -- 0–23

    if hour ~= lastHour then
        lastHour = hour
        pcall(function()
            SinoSound:Stop()
            SinoSound:Play()
        end)
    end
end

--== Heartbeat infinito (full bright + checar hora real) ==--

RunService.Heartbeat:Connect(function()
    -- FullBright permanente (dia / noite)
    local isDay = Lighting.ClockTime >= 7 and Lighting.ClockTime <= 19
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

    -- Checa hora real e toca sino se mudar
    checkRealTime()
end)

--== Execução inicial ==--
applyFullBright()
watchAllLights(Workspace)
startLightWatcher()
applyAntilag()
trackTransparentDecals()
