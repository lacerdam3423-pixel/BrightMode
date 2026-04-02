local Lighting = game:GetService("Lighting")

-- 1. STREAMING MODE E OTIMIZAÇÃO DE RENDER (Ativação leve e permanente)
settings().Rendering.QualityLevel = 1 -- Força gráficos no mínimo para ganhar FPS
workspace.StreamingEnabled = true -- Garante o Streaming habilitado para não pesar a memória RAM

-- 2. CONFIGURAÇÕES FIXAS DE ILUMINAÇÃO (Sem quebrar o script antigo)
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.Brightness = 0 -- Mantém o Brightness zerado conforme pedido anterior

if Lighting:FindFirstChildOfClass("Atmosphere") then
    Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
end

-- Bloqueia efeitos chatos de tela que dão lag (Blur, Bloom, etc.)
for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BlurEffect") then
        effect.Enabled = false
    end
end

-- 3. FUNÇÃO DE BRILHO POR EXPOSURE (Dia 0.25 / Noite 0.55)
local function aplicarLuz()
    local hora = Lighting.ClockTime
    
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0
    
    if hora >= 17.5 or hora <= 6.5 then
        -- NOITE (Claro por Exposure)
        Lighting.ExposureCompensation = 0.55
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        -- DIA (Iluminado sem estourar)
        Lighting.ExposureCompensation = 0.25
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    end
end

Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)
aplicarLuz()

-- 4. REMOÇÃO DE SOMBRAS E LUZES (Sem mexer em rostos, players ou texturas)
local function otimizarInstancia(obj)
    -- Ignora COMPLETAMENTE os Players para não quebrar animações ou rostos
    if obj:IsA("Player") or obj:FindFirstAncestorOfClass("Player") or obj:FindFirstAncestor("Humanoid") then
        return 
    end

    -- Desliga luzes do mapa (Evita lag de GPU no Granny)
    if obj:IsA("Light") then
        obj.Enabled = false
        
    -- Tira sombras dos blocos e remove o brilho do Neon sem quebrar a textura
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
    end
end

-- Aplica no que já existe
for _, item in ipairs(workspace:GetDescendants()) do
    otimizarInstancia(item)
end

-- Monitora novos objetos sem causar travamentos
workspace.DescendantAdded:Connect(otimizarInstancia)
