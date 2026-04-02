local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- 1. CONFIGURAÇÕES FIXAS (Roda só uma vez ao ligar o script)
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.Brightness = 0 -- Conforme pedido: Brightness zerado

if Lighting:FindFirstChildOfClass("Atmosphere") then
    Lighting:FindFirstChildOfClass("Atmosphere"):Destroy()
end

-- Configuração inicial do Tween (Transição de 2 segundos)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

-- 2. FUNÇÃO COM TRANSIÇÃO (Sem loop pesado)
local function aplicarLuz()
    local hora = Lighting.ClockTime
    Lighting.GlobalShadows = false
    
    local targetExposure = 0.25
    local targetAmbient = Color3.fromRGB(200, 200, 200)
    
    if hora >= 17.5 or hora <= 6.5 then
        -- NOITE
        targetExposure = 0.55
        targetAmbient = Color3.fromRGB(220, 220, 220) -- Um pouco mais claro para a noite
    else
        -- DIA
        targetExposure = 0.25
        targetAmbient = Color3.fromRGB(150, 150, 150)
    end
    
    -- Cria a transição suave de 2 segundos para as propriedades
    local goal = {
        ExposureCompensation = targetExposure,
        Ambient = targetAmbient,
        OutdoorAmbient = targetAmbient
    }
    
    local tween = TweenService:Create(Lighting, tweenInfo, goal)
    tween:Play()
end

-- 3. DETECTOR DE MUDANÇA
-- Roda o código suavemente quando a hora do jogo muda
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)

-- Executa uma vez no início para definir o estado atual
aplicarLuz()

-- 4. REMOÇÃO DE LUZES, SOMBRAS E TEXTURAS (Otimizada)
local function limparObjeto(obj)
    if obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy() -- Remove texturas e decais conectados
    end
end

-- Limpa o que já existe no jogo
for _, item in ipairs(workspace:GetDescendants()) do
    limparObjeto(item)
end

-- Limpa o que for adicionado depois
workspace.DescendantAdded:Connect(limparObjeto)
