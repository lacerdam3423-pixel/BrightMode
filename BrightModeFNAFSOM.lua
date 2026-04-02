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
        -- NOITE (Bright Mode)
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    else
        -- DIA (Normal do jogo, apenas sem sombras)
        -- Resetamos para o padrão para não estourar o brilho
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end
end

-- 3. DETECTOR DE MUDANÇA (Sem loop de 1s para não travar)
-- Ele só roda o código quando a hora do jogo realmente muda
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)

-- Executa uma vez no início
aplicarLuz()

-- 4. REMOÇÃO DE LUZES (Otimizada: Apenas quando algo novo aparece)
-- Isso evita o loop que causa o lag do vídeo
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
