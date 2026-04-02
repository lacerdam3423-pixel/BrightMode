local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local SISTEMA_ATIVADO = true
local BRILHO_BASE = 0.01
local EXPOSICAO_DIA = 0.3
local EXPOSICAO_NOITE = 0.37
local AMBIENTE_EXTERNO = Color3.fromRGB(200, 200, 200)
local NIVEL_ANTI_LAG = 3

local function AplicarUltraAntiLag()
    if NIVEL_ANTI_LAG == 0 then return end

    local function OtimizarObjetos(objeto)
        for _, descendente in ipairs(objeto:GetDescendants()) do
            if descendente:IsA("PostEffect") then
                descendente.Enabled = false
            elseif descendente:IsA("SurfaceLight") or descendente:IsA("PointLight") or descendente:IsA("SpotLight") then
                descendente.Enabled = false
                if NIVEL_ANTI_LAG >= 2 then
                    descendente.Shadows = false
                end
            elseif descendente:IsA("ParticleEmitter") or descendente:IsA("Trail") or descendente:IsA("Smoke") then
                if NIVEL_ANTI_LAG >= 3 then
                    descendente.Enabled = false
                end
            elseif descendente:IsA("Terrain") then
                descendente.Decoration = false
                descendente.WaterWaveSize = 0
                descendente.WaterWaveSpeed = 0
                descendente.WaterTransparency = 1
            elseif descendente:IsA("MeshPart") or descendente:IsA("Part") then
                if NIVEL_ANTI_LAG >= 1 then
                    descendente.Reflectance = 0.05
                    descendente.CastShadow = false
                end
            end
        end
    end

    OtimizarObjetos(Workspace)
    Workspace.DescendantAdded:Connect(OtimizarObjetos)
end

local function InicializarBloqueadorDeEfeitos()
    local function BloquearEfeito(efeito)
        if efeito:IsA("PostEffect") or efeito:IsA("Light") then
            efeito.Enabled = false
            pcall(function()
                local metatabela = getrawmetatable(efeito)
                if metatabela and metatabela.__newindex then
                    local antigoNewIndex = metatabela.__newindex
                    setreadonly(metatabela, false)
                    metatabela.__newindex = function(tabela, chave, valor)
                        if chave == "Enabled" and valor == true then
                            return antigoNewIndex(tabela, chave, false)
                        end
                        return antigoNewIndex(tabela, chave, valor)
                    end
                    setreadonly(metatabela, true)
                end
            end)
        end
    end

    for _, efeito in ipairs(Lighting:GetChildren()) do
        BloquearEfeito(efeito)
    end
    Lighting.ChildAdded:Connect(BloquearEfeito)
end

local function InicializarIluminacaoRefinada()
    Lighting.FogEnd = 999999
    Lighting.FogStart = 999999
    Lighting.Brightness = BRILHO_BASE
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    RunService.RenderStepped:Connect(function()
        if not SISTEMA_ATIVADO then return end

        local ehDia = Lighting.ClockTime >= 6 and Lighting.ClockTime < 18
        local exposicaoAlvo = ehDia and EXPOSICAO_DIA or EXPOSICAO_NOITE
        
        if Lighting.ExposureCompensation ~= exposicaoAlvo then
            Lighting.ExposureCompensation = exposicaoAlvo
        end
        
        if Lighting.OutdoorAmbient ~= AMBIENTE_EXTERNO then
            Lighting.OutdoorAmbient = AMBIENTE_EXTERNO
        end

        if Lighting.GlobalShadows then
            Lighting.GlobalShadows = false
        end

        if Lighting.FogEnd ~= 999999 then
            Lighting.FogEnd = 999999
            Lighting.FogStart = 0
        end

        for _, objeto in ipairs(Workspace:GetDescendants()) do
            if objeto:IsA("Light") and objeto.Shadows == true then
                objeto.Shadows = false
            end
            if objeto:IsA("BasePart") and objeto.CastShadow == true then
                objeto.CastShadow = false
            end
        end
    end)
end

pcall(AplicarUltraAntiLag)
pcall(InicializarBloqueadorDeEfeitos)
pcall(InicializarIluminacaoRefinada)
