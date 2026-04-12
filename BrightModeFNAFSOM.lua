wait("0.001")
-- BRIGHT MODE ULTRA-LEVE (ESPECIAL MOTO E20 / E40)
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- 1. CONFIGURAÇÃO GLOBAL (ZERO IMPACTO NO FPS)
local function AjustarClima()
    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(255, 255, 255
    Lighting.OutdoorAmbient = Color3.new(255, 255, 255)
    Lighting.FogEnd = 999999
    
    -- Deleta atmosfera para limpar a visão e ganhar FPS
    local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmos then atmos:Destroy() end
end

-- 2. TRANSIÇÃO SUAVE DE 2 SEGUNDOS
local function MudarExposicao(alvo)
    local tween = TweenService:Create(Lighting, TweenInfo.new(2), {ExposureCompensation = alvo})
    tween:Play()
end

local function AtualizarCiclo()
    if Lighting.ClockTime >= 6 and Lighting.ClockTime <= 18 then
        MudarExposicao(0.0) -- Dia
    else
        MudarExposicao(0.3) -- Noite
    end
end

-- 3. AJUSTE DE OBJETOS COM "FILTRO DE SEGURANÇA" (ANTI-LAG)
local function AjustarObjeto(obj)
    -- Desliga apenas luzes (essencial para o visual e performance)
    if obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        
        -- Neon para Ice (sem brilho pesado)
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        end
        
        -- Invisíveis 0.8
        if obj.Transparency >= 0.99 then
            obj.Transparency = 0.8
        end
    end
end

-- 4. VARREDURA SUPER LENTA (PARA NÃO CONGELAR O CELULAR)
AjustarClima()

task.spawn(function()
    local itens = workspace:GetDescendants()
    for i = 1, #itens do
        AjustarObjeto(itens[i])
        -- Pausa a cada 30 itens (Muito seguro para Moto E20)
        if i % 30 == 0 then 
            task.wait(0.1) 
        end
    end
end)

-- Monitora novos objetos de forma leve
workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.5) -- Espera o objeto carregar antes de mexer
    AjustarObjeto(obj)
end)

-- 5. MANUTENÇÃO (A CADA 5 SEGUNDOS PARA ECONOMIZAR CPU)
task.spawn(function()
    while true do
        AjustarClima()
        AtualizarCiclo()
        task.wait(5) -- Descanso longo para o processador Motorola
    end
end)

print("Bright Mode Moto E20/E40: Rodando com segurança!")
