--== FullBright Day/Night Balance (LuaU) ==--
--> Mantém o ciclo, mas faz tudo sempre muito visível

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local AMBIENT_CLR = Color3.fromRGB(200, 200, 200) -- 200 como "branco suave"
local OUTDOOR_CLR = Color3.fromRGB(220, 220, 220)

--// Brightness por dia e noite
local BRIGHTNESS_DAY = 0.25
local BRIGHTNESS_NIGHT = 0.57 -- igual ao dia se quiser "sempre dia"

--// Exposure por dia e noite
local EXPOSURE_DAY = 0.25
local EXPOSURE_NIGHT = 0.57

--// Aplica FullBright + correção por dia/noite
local function applyFullBright()
    Lighting.Brightness               = BRIGHTNESS_DAY
    Lighting.ExposureCompensation     = EXPOSURE_DAY
    Lighting.GlobalShadows            = false
    Lighting.Ambient                  = AMBIENT_CLR
    Lighting.OutdoorAmbient           = OUTDOOR_CLR
    Lighting.ClockTime                = Lighting.ClockTime -- mantém o ciclo
    Lighting.FogEnd                   = 999999
    Lighting.FogStart                 = 0
    Lighting.FogColor                 = Color3.new(0.9, 0.9, 0.9)
end

--// Desativa fog/atmosfera
local function removeFog()
    if Lighting:FindFirstChild("Atmosphere") then
        Lighting.Atmosphere:Destroy()
    end
end

--// Desliga todos os tipos de luz (Point / Surface / Spot)
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

--// Monitora novas luzes
local function trackNewLights()
    game.Workspace.DescendantAdded:Connect(function(descendant)
        if
            descendant:IsA("PointLight")    or
            descendant:IsA("SurfaceLight")  or
            descendant:IsA("SpotLight")
        then
            descendant.Enabled = false
        end
    end)
end

--// Mantém tudo sempre claro, dia e noite
RunService:BindToRenderStep("FullBrightUpdater", Enum.RenderPriority.Camera.Value, function()
    local hour = Lighting.ClockTime

    -- Define se é dia (ex: 6h–18h) ou noite (restante)
    local isDay = hour >= 6 and hour <= 18

    local bright = isDay and BRIGHTNESS_DAY  or BRIGHTNESS_NIGHT
    local expo   = isDay and EXPOSURE_DAY    or EXPOSURE_NIGHT

    Lighting.Brightness             = bright
    Lighting.ExposureCompensation   = expo
    Lighting.Ambient                = AMBIENT_CLR
    Lighting.OutdoorAmbient         = OUTDOOR_CLR
    Lighting.GlobalShadows          = false
    Lighting.FogEnd                 = 999999
    Lighting.FogStart               = 0
end)

--== Executa na inicialização ==--
applyFullBright()
removeFog()
disableAllLights(game.Workspace)
trackNewLights()
