local Lighting = game:GetService("Lighting")

-- 1. CONFIGURAÇÕES FIXAS (Roda só uma vez para máxima performance)
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.Brightness = 0 -- Mantém o Brightness zerado como pedido

if Lighting:FindFirstChildOfClass("Atmosphere") then
    Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
end

-- 2. FUNÇÃO LEVE DE MUDANÇA (Baseada apenas em Exposure)
local function aplicarLuz()
    local hora = Lighting.ClockTime
    
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0 -- Garante que continue em zero
    
    if hora >= 17.5 or hora <= 6.5 then
        -- NOITE (Mais clara por Exposure)
        Lighting.ExposureCompensation = 0.75
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        -- DIA (Iluminado mas sem estourar)
        Lighting.ExposureCompensation = 0.37
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    end
end

-- 3. DETECTOR DE MUDANÇA (Super leve, não trava)
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)

-- Executa uma vez no início
aplicarLuz()

-- 4. REMOÇÃO DE LUZES, SOMBRAS E TEXTURAS (Otimização Extrema)
local function otimizarObjeto(obj)
    -- Remove Luzes
    if obj:IsA("Light") then
        obj.Enabled = false
    -- Remove Sombras e desliga o Neon
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
    -- Remove Texturas e Decals para dar muito mais FPS
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    end
end

-- Limpa o que já está no mapa ao ligar o script
for _, item in ipairs(game.Workspace:GetDescendants()) do
    otimizarObjeto(item)
end

-- Limpa tudo o que for adicionado depois (sem lag)
game.Workspace.DescendantAdded:Connect(otimizarObjeto)
