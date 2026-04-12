-- BRIGHT MODE SUPREMO (FPS BOOST & ZERO DARKNESS)
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- 1. EXTIRPAR ESCURIDÃO E SOMBRAS (ZERO ÁREA PRETA)
local function ArrumarIluminacao()
    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.ShadowSoftness = 0
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    
    -- Limpeza de Fog e Atmosfera
    Lighting.FogEnd = 999999
    Lighting.FogStart = 0
    local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmos then atmos:Destroy() end
end

-- 2. OTIMIZAÇÃO DE FPS E REFLEXOS (MESA, MESHPART, ETC)
local function OtimizarObjeto(obj)
    -- Bloqueia Luzes (PointLight, etc)
    if obj:IsA("Light") then
        obj.Enabled = false
    end
    
    -- Ajuste Geral de Partes (MeshPart, Part, Union)
    if obj:IsA("BasePart") then
        obj.CastShadow = false -- REMOVE SOMBRA INDIVIDUAL
        obj.Reflectance = 0    -- REMOVE REFLEXO (FPS BOOST)
        
        -- Materiais
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        end
        
        -- Transparência (Invisível 1 -> 0.7)
        if obj.Transparency >= 0.99 then
            obj.Transparency = 0.8
        end
    end
end

-- 3. TRANSIÇÃO DE CLIMA (DIA 0.5 / NOITE 0.8)
local function Suavizar(alvo)
    TweenService:Create(Lighting, TweenInfo.new(2), {ExposureCompensation = alvo}):Play()
end

local function Ciclo()
    if Lighting.ClockTime >= 6 and Lighting.ClockTime <= 18 then
        Suavizar(0.5)
    else
        Suavizar(0.8)
    end
end

-- 4. EXECUÇÃO INSTANTÂNEA E MONITORAMENTO
ArrumarIluminacao()

-- Varredura Inicial
for _, v in pairs(workspace:GetDescendants()) do
    OtimizarObjeto(v)
end

-- Monitora novos itens (Otimiza instantaneamente ao carregar)
workspace.DescendantAdded:Connect(OtimizarObjeto)

-- 5. LOOP DE MANUTENÇÃO (FPS OTIMIZADO)
task.spawn(function()
    while true do
        ArrumarIluminacao()
        Ciclo()
        -- Forçar FPS: Desativa sombras globais caso o jogo tente ligar
        sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility)
        task.wait(1)
    end
end)

print("Full Bright Ativo: Zero Sombras | Reflection 0 | FPS Max")
