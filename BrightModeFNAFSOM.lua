task.wait(0.1)
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local settings = settings()
local Rendering = settings.Rendering

-- 1. CONFIGURAÇÕES FIXAS (Roda só uma vez para não travar o celular)
Lighting.FogEnd = 1000000
Lighting.FogStart = 0
Lighting.Brightness = 0 -- Mantido em 0 como você pediu no anterior
Lighting.GlobalShadows = false -- Sombras desligadas para evitar lag extremo
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1

-- Força o motor gráfico a renderizar melhor sem precisar de loop infinito
pcall(function()
    Rendering.QualityLevel = Enum.QualityLevel.Level21
    Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level21
end)

if Lighting:FindFirstChildOfClass("Atmosphere") then
    Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
end

-- 2. FUNÇÃO DE ILUMINAÇÃO (Exposure control)
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
        -- DIA (Iluminado)
        Lighting.ExposureCompensation = 0.25
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    end
end

-- Detecta mudança de horário
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)
aplicarLuz()

-- 3. REMOÇÃO DE TEXTURAS E SOMBRAS (Para rodar liso)
local function otimizarObjeto(obj)
    if obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy() -- Remove as texturas pesadas conectadas
    end
end

-- Varredura inicial limpa
for _, item in ipairs(game.Workspace:GetDescendants()) do
    otimizarObjeto(item)
end

-- Monitora novos objetos sem causar lag
game.Workspace.DescendantAdded:Connect(otimizarObjeto)

-- 4. NOTIFICAÇÃO DE SUCESSO
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Script Carregado!",
        Text = "Iluminação e otimização aplicadas com sucesso.",
        Icon = "rbxassetid://6031075938",
        Duration = 6
    })
end)
