-- SCRIPT UNIFICADO: BRIGHT MODE + FOV CONTROL (MOTO E20/E40)
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera

-- --- CONFIGURAÇÕES DE FOV ---
local targetFOV = 67.5
local transitionTime = 4
local checkInterval = 0.6

-- 1. Transição Inicial do FOV
local fovTweenInfo = TweenInfo.new(transitionTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local fovTween = TweenService:Create(camera, fovTweenInfo, {FieldOfView = targetFOV})
fovTween:Play()

-- Loop para manter o FOV rígido
task.spawn(function()
    fovTween.Completed:Wait()
    while true do
        if camera.FieldOfView ~= targetFOV then
            camera.FieldOfView = targetFOV
        end
        task.wait(checkInterval)
    end
end)

-- --- CONFIGURAÇÕES DE BRIGHT MODE ---
local function IluminarTudo()
    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    
    -- Exposição Instantânea (Dia 0.5 / Noite 0.8)
    local hora = Lighting.ClockTime
    if hora >= 6 and hora <= 18 then
        Lighting.ExposureCompensation = 0.5
    else
        Lighting.ExposureCompensation = 0.8
    end

    -- Limpeza de Fog e Atmosfera
    Lighting.FogEnd = 999999
    Lighting.FogStart = 0
    local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmos then atmos:Destroy() end
end

-- Ajuste de Partes e Materiais (Sem mexer em texturas)
local function AjustarObjeto(obj)
    if obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        
        -- Neon vira Ice
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        end
        
        -- Invisível vira 0.8
        if obj.Transparency >= 0.98 then
            obj.Transparency = 0.8
        end
    end
end

-- --- EXECUÇÃO OTIMIZADA ---
IluminarTudo()

-- Varredura segura para Motorola E20/E40 (Anti-Lag)
task.spawn(function()
    local descendants = workspace:GetDescendants()
    for i = 1, #descendants do
        AjustarObjeto(descendants[i])
        if i % 40 == 0 then task.wait(0.1) end
    end
end)

workspace.DescendantAdded:Connect(AjustarObjeto)

-- Loop de manutenção do clima (1 segundo)
task.spawn(function()
    while true do
        IluminarTudo()
        task.wait(1)
    end
end)

print("Script Unificado: FOV 67.5 e Bright Mode Ativos!")
