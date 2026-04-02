local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- 1. CONFIGURAÇÕES FIXAS (Roda só uma vez ao ligar o script)
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.Brightness = 0 -- Mantém o Brightness zerado como pedido

if Lighting:FindFirstChildOfClass("Atmosphere") then
    Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
end

-- STREAMING MODE PERMANENTE (Simulação via script para forçar foco de memória)
if not workspace.StreamingEnabled then
    workspace.StreamingEnabled = true
end

-- 2. FUNÇÃO LEVE DE MUDANÇA (Baseada apenas em Exposure)
local function aplicarLuz()
    local hora = Lighting.ClockTime
    
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0 -- Garante que continue em zero
    
    if hora >= 17.5 or hora <= 6.5 then
        -- NOITE (Mais clara por Exposure)
        Lighting.ExposureCompensation = 0.55
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        -- DIA (Iluminado mas sem estourar)
        Lighting.ExposureCompensation = 0.25
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    end
end

-- 3. DETECTOR DE MUDANÇA
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)
aplicarLuz() -- Executa uma vez no início

-- 4. FUNÇÃO DE OTIMIZAÇÃO SEM MEXER EM JOGADORES OU ROSTOS
local function otimizarObjeto(obj)
    -- Se o objeto for (ou estiver dentro de) um jogador, o script ignora totalmente
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and (obj == player.Character or obj:IsDescendantOf(player.Character)) then
            return
        end
    end

    -- Remove Luzes extras do mapa
    if obj:IsA("Light") then
        obj.Enabled = false
        
    -- Tira sombras dos blocos e desliga o brilho Neon (sem sumir com o bloco)
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
        
    -- NÃO mexe em texturas ou Decals para evitar quebrar o mapa ou sumir com rostos!
    end
end

-- Limpa o que já está no mapa ao ligar o script (Sem causar lag ou crash)
local descendants = workspace:GetDescendants()
for i = 1, #descendants do
    otimizarObjeto(descendants[i])
    -- Pequena pausa a cada 500 itens para o celular respirar e não dar crash
    if i % 500 == 0 then
        task.wait()
    end
end

-- Limpa tudo o que for adicionado depois
workspace.DescendantAdded:Connect(otimizarObjeto)
