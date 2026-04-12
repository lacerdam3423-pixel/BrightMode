-- BRIGHT MODE ULTRA OTIMIZADO (ANTI-LAG)
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- 1. CONFIGURAÇÃO DE ILUMINAÇÃO (SEM ÁREAS PRETAS)
local function AjustarGlobal()
    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.FogEnd = 999999
    
    -- Remove atmosfera para manter a clareza da imagem
    local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmos then atmos:Destroy() end
end

-- 2. AJUSTE DE OBJETOS COM CONTROLE DE LAG
local function AplicarEfeitos(obj)
    -- Bloqueia luzes dinâmicas que criam sombras
    if obj:IsA("Light") then
        obj.Enabled = false
    end
    
    if obj:IsA("BasePart") then
        obj.CastShadow = false -- Remove sombras sem mudar a textura
        obj.Reflectance = 0    -- Melhora FPS
        
        -- Neon vira Ice (conforme pedido)
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        end
        
        -- Invisível vira 0.7
        if obj.Transparency >= 0.98 then
            obj.Transparency = 0.7
        end
    end
end

-- Varredura segura (Processa 100 itens e descansa um pouco para não travar)
local function VarreduraSegura()
    local count = 0
    for _, v in pairs(workspace:GetDescendants()) do
        AplicarEfeitos(v)
        count = count + 1
        if count >= 100 then
            count = 0
            task.wait() -- Pausa curta para o processador respirar
        end
    end
end

-- 3. TRANSIÇÃO DE BRILHO (2 SEGUNDOS)
local function SuavizarExposicao(alvo)
    TweenService:Create(Lighting, TweenInfo.new(2), {ExposureCompensation = alvo}):Play()
end

local function ChecarHorario()
    if Lighting.ClockTime >= 6 and Lighting.ClockTime <= 18 then
        SuavizarExposicao(0.5) -- Dia
    else
        SuavizarExposicao(0.8) -- Noite
    end
end

-- 4. EXECUÇÃO
AjustarGlobal()
task.spawn(VarreduraSegura) -- Executa a varredura em segundo plano

-- Monitora novos objetos sem causar lag
workspace.DescendantAdded:Connect(AplicarEfeitos)

-- Loop de manutenção leve (1 vez por segundo)
task.spawn(function()
    while true do
        AjustarGlobal()
        ChecarHorario()
        task.wait(1)
    end
end)

print("Bright Mode: Ativado sem Lag no Dead Rails!")
