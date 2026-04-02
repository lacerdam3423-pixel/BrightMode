task.wait(0.1)

local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local settings = settings()
local Rendering = settings.Rendering

-- 1. CONFIGURAÇÕES DE GRÁFICOS NO MÁXIMO (Sem travar o processador)
local function aplicarGraficosMaximos()
    pcall(function()
        Rendering.QualityLevel = Enum.QualityLevel.Level21
        Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level21
        -- Ativa o modo de carregamento contínuo para não dar tela de carregamento longa
        workspace.StreamingEnabled = true 
    end)
end

-- 2. ILUMINAÇÃO SEM SOMBRAS E CLARA (Seu pedido original)
local function aplicarLuz()
    local hora = Lighting.ClockTime
    
    Lighting.FogEnd = 1000000
    Lighting.FogStart = 0
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0 -- Mantido em 0 conforme seu pedido anterior
    Lighting.EnvironmentDiffuseScale = 1
    Lighting.EnvironmentSpecularScale = 1
    
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

-- 3. REMOÇÃO DE TEXTURAS (Sem mexer nos players e rostos)
local function otimizarObjeto(obj)
    -- Ignora completamente se o objeto for parte de um jogador
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then
            return 
        end
    end

    -- Remove Luzes espalhadas
    if obj:IsA("Light") then
        obj.Enabled = false
    -- Remove Sombras e desliga o Neon do mapa
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
    -- Remove Texturas do mapa (Ignora rostos)
    elseif obj:IsA("Texture") or (obj:IsA("Decal") and obj.Name ~= "face" and obj.Name ~= "Face") then
        obj:Destroy()
    end
end

-- 4. EXECUÇÃO ÚNICA (Sem loops infinitos para não dar crash)
aplicarGraficosMaximos()
aplicarLuz()

-- Limpa o mapa atual
for _, item in ipairs(workspace:GetDescendants()) do
    otimizarObjeto(item)
end

-- Limpa itens novos que spawnarem
workspace.DescendantAdded:Connect(otimizarObjeto)

-- Atualiza a luz se o tempo passar (sem travar)
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)

-- 5. NOTIFICAÇÃO DE SUCESSO
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "By MigMax ;]",
        Text = "Híbrido Ultra + Anti-Lag Carregado!",
        Icon = "rbxassetid://6031075938",
        Duration = 6
    })
end)
