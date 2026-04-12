-- BRIGHT MODE DEFINITIVO (MOTO E20/E40 & DELTA)
local Lighting = game:GetService("Lighting")

-- 1. ILUMINAÇÃO TOTAL E REMOÇÃO DE ESCURIDÃO
local function IluminarTudo()
    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    
    -- Ajuste de Exposição Instantâneo (Sem transição suave)
    local hora = Lighting.ClockTime
    if hora >= 6 and hora <= 18 then
        Lighting.ExposureCompensation = 0.5 -- Dia
    else
        Lighting.ExposureCompensation = 0.8 -- Noite
    end

    -- Remove Fog e Atmosfera que causam sombras/lag
    Lighting.FogEnd = 999999
    Lighting.FogStart = 0
    local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmos then atmos:Destroy() end
end

-- 2. AJUSTE DE MATERIAIS (PRESERVANDO TEXTURAS)
local function AjustarObjeto(obj)
    -- Bloqueia luzes (PointLight, SpotLight, etc)
    if obj:IsA("Light") then
        obj.Enabled = false
    end
    
    if obj:IsA("BasePart") then
        -- Remove sombras projetadas sem mexer na textura original
        obj.CastShadow = false
        
        -- Materiais específicos
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        end
        
        -- Objetos invisíveis ficam 0.8 (Como pedido)
        if obj.Transparency >= 0.98 then
            obj.Transparency = 0.8
        end
    end
end

-- 3. EXECUÇÃO INSTANTÂNEA E OTIMIZADA
IluminarTudo()

-- Varredura segura para não travar o celular
task.spawn(function()
    local descendants = workspace:GetDescendants()
    for i = 1, #descendants do
        AjustarObjeto(descendants[i])
        -- Pausa pequena a cada 40 itens para manter o FPS estável
        if i % 40 == 0 then task.wait(0.1) end
    end
end)

-- Monitora novos objetos que entrarem no mapa
workspace.DescendantAdded:Connect(AjustarObjeto)

-- 4. MANUTENÇÃO AUTOMÁTICA (RECOLOCA CADA 1 SEGUNDO)
task.spawn(function()
    while true do
        IluminarTudo()
        task.wait(1)
    end
end)

print("Bright Mode Recriado: Tudo Iluminado!")
