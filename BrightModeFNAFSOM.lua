-- Espera o jogo carregar um pouco para evitar falhas na execução
task.wait(0.1)

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

-- 1. NOTIFICAÇÃO DE SUCESSO
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "MigMax Fullbright",
        Text = "Script carregado com sucesso! Sem sombras e com FPS otimizado.",
        Icon = "rbxassetid://6031075938",
        Duration = 6
    })
end)

-- 2. CONFIGURAÇÕES FIXAS (Roda só uma vez para não dar lag)
Lighting.FogEnd = 1000000
Lighting.FogStart = 0
Lighting.Brightness = 0 -- Mantido em 0 conforme seu pedido anterior
Lighting.GlobalShadows = false -- Desativado para não travar celulares fracos

if Lighting:FindFirstChildOfClass("Atmosphere") then
    Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
end

-- Tenta forçar a qualidade de renderização no motor do Roblox de forma segura
pcall(function()
    UserGameSettings.SavedQualityLevel = Enum.SavedQualityLevel.QualityLevel10
end)

-- 3. FUNÇÃO DE ILUMINAÇÃO (Baseada em Exposure)
local function aplicarLuz()
    local hora = Lighting.ClockTime
    
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0
    
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

-- Detector de mudança de horário (Super leve)
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)
aplicarLuz()

-- 4. REMOÇÃO DE LUZES, SOMBRAS E TEXTURAS (Para garantir o FPS)
local function otimizarObjeto(obj)
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

-- Limpa o mapa atual
for _, item in ipairs(game.Workspace:GetDescendants()) do
    otimizarObjeto(item)
end

-- Limpa o que for adicionado depois
game.Workspace.DescendantAdded:Connect(otimizarObjeto)
