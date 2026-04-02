local Lighting = game:GetService("Lighting")

-- 1. CONFIGURAÇÕES FIXAS (Roda só uma vez ao ligar o script)
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.Brightness = 0 -- Como solicitado: Brightness zerado

if Lighting:FindFirstChildOfClass("Atmosphere") then
    Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
end

-- 2. FUNÇÃO LEVE DE MUDANÇA
local function aplicarLuz()
    local hora = Lighting.ClockTime
    
    -- Sempre garante que as sombras fiquem desligadas
    Lighting.GlobalShadows = false
    
    -- Ilumina tudo sempre usando Ambient alto
    Lighting.Ambient = Color3.fromRGB(220, 220, 220)
    Lighting.OutdoorAmbient = Color3.fromRGB(220, 220, 220)
    
    if hora >= 17.5 or hora <= 6.5 then
        -- NOITE: Exposure em 0.55
        Lighting.ExposureCompensation = 0.55
    else
        -- DIA: Exposure em 0.25
        Lighting.ExposureCompensation = 0.25
    end
end

-- 3. DETECTOR DE MUDANÇA DE HORA
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)
aplicarLuz() -- Executa uma vez no início

-- 4. REMOÇÃO DE LUZES, SOMBRAS E TEXTURAS (Otimizado para novos objetos)
game.Workspace.DescendantAdded:Connect(function(obj)
    -- Remove Luzes
    if obj:IsA("Light") then
        obj.Enabled = false
        
    -- Remove Sombras de blocos e materiais brilhantes
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
        
    -- Remove Texturas e Decals para evitar lag e melhorar a visão
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    end
end)

-- 5. VARREDURA INICIAL (Aplica a regra de texturas/luzes no que já existe no jogo)
for _, obj in ipairs(game.Workspace:GetDescendants()) do
    if obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    end
end
