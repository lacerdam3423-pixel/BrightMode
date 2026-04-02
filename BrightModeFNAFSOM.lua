local Lighting = game:GetService("Lighting")

-- 1. CONFIGURAÇÕES FIXAS (Roda só uma vez ao ligar o script)
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
if Lighting:FindFirstChildOfClass("Atmosphere") then
    Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
end

-- 2. FUNÇÃO LEVE DE MUDANÇA (Sem loop de busca)
local function aplicarLuz()
    local hora = Lighting.ClockTime
    
    -- SEMPRE REMOVE SOMBRAS
    Lighting.GlobalShadows = false
    
    if hora >= 17.5 or hora <= 6.5 then
        -- NOITE (Modo Claro via Exposição)
        Lighting.ExposureCompensation = 0.55 -- Aumenta a exposição para clarear a noite
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    else
        -- DIA (Normal do jogo, apenas sem sombras)
        Lighting.ExposureCompensation = 0.25 -- Volta para a exposição padrão do jogo
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end
end

-- 3. DETECTOR DE MUDANÇA (Roda apenas quando o tempo muda)
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)

-- Executa uma vez no início
aplicarLuz()

-- 4. REMOÇÃO DE LUZES (Otimizada: Apenas quando algo novo aparece)
game.Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
    end
end)
