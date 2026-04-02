local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- 1. CONFIGURAÇÕES DE ILUMINAÇÃO (Conforme seu pedido)
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.Brightness = 0 -- Brilho sempre em 0

if Lighting:FindFirstChildOfClass("Atmosphere") then
    Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
end

-- 2. FUNÇÃO LEVE DE MUDANÇA DE HORÁRIO (Apenas Exposure)
local function aplicarLuz()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0
    
    local hora = Lighting.ClockTime
    if hora >= 17.5 or hora <= 6.5 then
        -- NOITE
        Lighting.ExposureCompensation = 0.55
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        -- DIA
        Lighting.ExposureCompensation = 0.25
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    end
end

-- Detector de mudança de hora
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)
aplicarLuz() -- Roda uma vez no início

-- 3. FUNÇÃO DE OTIMIZAÇÃO DE OBJETOS (Filtra Players e Rostos)
local function otimizarObjeto(obj)
    -- IGNORA TUDO QUE FOR DO PLAYER (Rostos, roupas, etc.)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then
            return
        end
    end
    
    -- Ignora rostos/decals que pareçam ser de personagens ou imagens importantes
    if obj:IsA("Decal") and (obj.Name == "face" or obj.Parent:IsA("Accessory")) then
        return
    end

    -- DESLIGA LUZES E SHADERS MANUAIS
    if obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("Highlight") then
        obj:Destroy() -- Remove shaders/contornos pesados
    -- REMOVE SOMBRAS E TRATA O NEON
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
    end
end

-- 4. VARREDURA INICIAL SEGURA (Não dá crash no carregamento)
-- Processa em blocos para celulares fracos não congelarem
local itens = game.Workspace:GetDescendants()
local contador = 0

for i = 1, #itens do
    local item = itens[i]
    pcall(function()
        otimizarObjeto(item)
    end)
    
    contador = contador + 1
    if contador >= 300 then -- A cada 300 objetos ele pausa um pouquinho
        task.wait()
        contador = 0
    end
end

-- 5. STREAMING MODE E ADIÇÕES FUTURAS
-- Mantém a limpeza ativa sem travar para o que carregar depois
game.Workspace.DescendantAdded:Connect(function(obj)
    pcall(function()
        otimizarObjeto(obj)
    end)
end)
