-- SCRIPT SUPREMO UNIFICADO (MOTO E20/E40 - ZERO LAG)
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local camera = workspace.CurrentCamera

-- --- CONFIGURAÇÕES DE FOV ---
local targetFOV = 67.5
local transitionTime = 4
local checkInterval = 0.6

local fovTween = TweenService:Create(camera, TweenInfo.new(transitionTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {FieldOfView = targetFOV})
fovTween:Play()

task.spawn(function()
    fovTween.Completed:Wait()
    while true do
        if camera.FieldOfView ~= targetFOV then camera.FieldOfView = targetFOV end
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

-- --- SISTEMA DE MATERIAIS E BLOQUEIO (SEM MODIFICAR TEXTURAS) ---
local function AjustarObjeto(obj)
    if obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        
        -- TRANSFORMA NEON EM ICE (CORRIGIDO)
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        end
        
        -- INVISÍVEL FICA 0.8
        if obj.Transparency >= 0.98 then
            obj.Transparency = 0.8
        end
    end
end

-- --- EXECUÇÃO SEGURA PARA MOTOROLA (ANTI-TRAVAMENTO) ---
IluminarTudo()

task.spawn(function()
    local descendants = workspace:GetDescendants()
    for i = 1, #descendants do
        AjustarObjeto(descendants[i])
        -- Pausa a cada 25 itens para o Moto E20/E40 não congelar
        if i % 25 == 0 then 
            task.wait(0.1) 
        end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1) -- Espera carregar para não dar pico de lag
    AjustarObjeto(obj)
end)

-- --- ATUALIZAÇÃO AUTOMÁTICA (CADA 0.5 SEGUNDOS) ---
task.spawn(function()
    while true do
        IluminarTudo()
        task.wait(0.5) -- ATUALIZAÇÃO RÁPIDA DE 0.5s CONFORME PEDIDO
    end
end)

print("Script Recriado: Neon->Ice | 0.5s Refresh | FOV 67.5 | Anti-Lag")
