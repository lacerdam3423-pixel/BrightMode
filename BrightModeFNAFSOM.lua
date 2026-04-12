-- BRIGHT MODE FINAL (INVISÍVEL 0.8 | ANTI-LAG)
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- 1. CONFIGURAÇÃO DE LUZ GLOBAL (SEM SOMBRAS)
local function AjustarLuz()
    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.FogEnd = 999999
    
    local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmos then atmos:Destroy() end
end

-- 2. TRANSIÇÃO SUAVE DE 2 SEGUNDOS
local function Suavizar(alvo)
    TweenService:Create(Lighting, TweenInfo.new(2), {ExposureCompensation = alvo}):Play()
end

local function Ciclo()
    if Lighting.ClockTime >= 6 and Lighting.ClockTime <= 18 then
        Suavizar(0.5) -- Dia
    else
        Suavizar(0.8) -- Noite
    end
end

-- 3. AJUSTE DE OBJETOS (PRESERVANDO TEXTURAS)
local function AplicarAjuste(obj)
    -- Desliga luzes que criam sombras
    if obj:IsA("Light") then
        obj.Enabled = false
    end
    
    if obj:IsA("BasePart") then
        obj.CastShadow = false -- Remove sombra sem mexer na textura
        
        -- Neon vira Ice
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        end
        
        -- OBJETOS INVISÍVEIS AGORA FICAM EM 0.8
        if obj.Transparency >= 0.98 then
            obj.Transparency = 0.8
        end
    end
end

-- 4. EXECUÇÃO OTIMIZADA PARA DELTA (SEM TRAVAR)
AjustarLuz()

task.spawn(function()
    local itens = workspace:GetDescendants()
    for i = 1, #itens do
        AplicarAjuste(itens[i])
        -- Pausa a cada 200 itens para o FPS não cair
        if i % 200 == 0 then task.wait() end
    end
end)

-- Monitora novos objetos
workspace.DescendantAdded:Connect(AplicarAjuste)

-- 5. LOOP DE MANUTENÇÃO (A CADA 2 SEGUNDOS)
task.spawn(function()
    while true do
        AjustarLuz()
        Ciclo()
        task.wait(2)
    end
end)

print("Bright Mode: Invisível em 0.8 | Texturas Originais | Sem Lag")
