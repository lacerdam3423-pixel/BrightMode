wait("0.0001")
--[=[
    DEVELOPER TOOL: ULTRA_BRIGHT_EXPOSURE_SYSTEM v1.2
    DESCRICAO: Sistema de iluminação universal focado em brilho e visibilidade.
    FUNCIONALIDADES: Bright Mode estável, No-Fog, Exposição Automática Dinâmica, Mantém Nuvens e Céu.
    MODIFICAÇÕES: Anti-lag agressivo removido para manter a fidelidade visual do mapa.
]=]

-- [[ CONFIGURAÇÃO DO DESENVOLVEDOR ]]
local U_P_BM_CONFIG = {
    ENABLED = true,
    BRIGHTNESS_BASE = 0, -- Zerado para a exposição dominar perfeitamente
    EXPOSURE_DAY = 0.3,    
    EXPOSURE_NIGHT = 0.37,  
    OUTDOOR_AMBIENT = Color3.fromRGB(200, 200, 200), 
    HEARTBEAT_SAFE = true, 
}

-- [[ VARIÁVEIS DO SISTEMA ]]
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local isInitialized = false
local currentUpdateSignal

-- [[ SISTEMA DE LOGGING ]]
local function DLog(message, isError)
    local prefix = "[U_P_BM]"
    if isError then
        warn(prefix .. " ERRO: " .. tostring(message))
    else
        print(prefix .. " INFO: " .. tostring(message))
    end
end

-- [[ SISTEMA DE ILUMINAÇÃO REFINADO (NO-LAG BRIGHT MODE) ]]
local function InitializeRefinedLighting()
    DLog("Inicializando Bright Mode com Céu e Nuvens do Jogo.")

    -- Configuração Base de Limpeza
    Lighting.FogEnd = 9e9 -- Remove Neblina
    Lighting.FogStart = 9e9
    Lighting.Brightness = U_P_BM_CONFIG.BRIGHTNESS_BASE
    Lighting.GlobalShadows = false -- Remove Sombras de tudo
    Lighting.EnvironmentDiffuseScale = 0 
    Lighting.EnvironmentSpecularScale = 0 

    -- Lógica RenderStepped para Iluminação Estável
    if U_P_BM_CONFIG.HEARTBEAT_SAFE then
        if currentUpdateSignal then currentUpdateSignal:Disconnect() end
        
        currentUpdateSignal = RunService.RenderStepped:Connect(function()
            if not U_P_BM_CONFIG.ENABLED then 
                if currentUpdateSignal then currentUpdateSignal:Disconnect() end
                return 
            end

            -- Verifica se é dia ou noite baseado no relógio do jogo
            local isDay = Lighting.ClockTime >= 6 and Lighting.ClockTime < 18
            local targetExposure = isDay and U_P_BM_CONFIG.EXPOSURE_DAY or U_P_BM_CONFIG.EXPOSURE_NIGHT
            
            -- Força a exposição correta
            if Lighting.ExposureCompensation ~= targetExposure then
                Lighting.ExposureCompensation = targetExposure
            end
            
            -- Força o ambiente claro
            if Lighting.OutdoorAmbient ~= U_P_BM_CONFIG.OUTDOOR_AMBIENT then
                Lighting.OutdoorAmbient = U_P_BM_CONFIG.OUTDOOR_AMBIENT
            end

            -- Garante que as sombras fiquem sempre desligadas
            if Lighting.GlobalShadows then
                Lighting.GlobalShadows = false
            end
        end)
    end
end

-- [[ INICIALIZAÇÃO DO SCRIPT ]]
local function InitializeUPBM()
    if isInitialized then return end
    isInitialized = true
    
    DLog("Script de Iluminação Limpo Inicializando...")
    
    pcall(InitializeRefinedLighting)

    DLog("Sistema Totalmente Funcional Carregado com Sucesso.")
end

InitializeUPBM()

return {
    Disable = function()
        U_P_BM_CONFIG.ENABLED = false
        if currentUpdateSignal then currentUpdateSignal:Disconnect() end
        DLog("Sistema Desativado.")
    end,
    Enable = function()
        if not U_P_BM_CONFIG.ENABLED then
            U_P_BM_CONFIG.ENABLED = true
            InitializeUPBM()
        end
    end
    }        return
    end

    local level = U_P_BM_CONFIG.ANTI_LAG_LEVEL

    if obj:IsA("PostEffect") then
        obj.Enabled = false
    elseif obj:IsA("Light") and level >= 2 then
        obj.Shadows = false
    elseif (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke")) and level >= 3 then
        obj.Enabled = false
    elseif obj:IsA("Terrain") then
        obj.Decoration = false
        obj.WaterWaveSize = 0
        obj.WaterWaveSpeed = 0
        obj.WaterTransparency = 1
    elseif obj:IsA("BasePart") then
        if level >= 1 then
            obj.Material = Enum.Material.SmoothPlastic
            obj.CastShadow = false
            -- Aplica leve reflexão de forma harmonizada
            obj.Reflectance = (level >= 3) and 0 or 0.05 
        end
    end
end

-- [[ SISTEMA DE DESEMPENHO & ILUMINAÇÃO ]]
local function InitializeUPBM()
    if isInitialized then return end
    isInitialized = true
    
    DLog("Inicializando Bright Mode e Anti-Lag Otimizados...")

    -- 1. Otimização do mapa existente
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        pcall(OptimizeObject, descendant)
    end

    -- 2. Escuta para novos objetos (Otimiza APENAS o objeto novo, sem usar GetDescendants)
    Workspace.DescendantAdded:Connect(function(descendant)
        pcall(OptimizeObject, descendant)
    end)

    -- 3. Bloqueio de efeitos no Lighting
    local function cleanLighting(obj)
        if obj:IsA("PostEffect") then obj.Enabled = false end
    end
    for _, effect in ipairs(Lighting:GetChildren()) do cleanLighting(effect) end
    Lighting.ChildAdded:Connect(cleanLighting)

    -- 4. Configuração Base da Iluminação
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e5
    Lighting.Brightness = U_P_BM_CONFIG.BRIGHTNESS_BASE
    Lighting.GlobalShadows = false

    -- 5. Loop de Renderização Estável e Leve
    currentUpdateSignal = RunService.RenderStepped:Connect(function()
        if not U_P_BM_CONFIG.ENABLED then return end

        local isDay = Lighting.ClockTime >= 6 and Lighting.ClockTime < 18
        local targetExposure = isDay and U_P_BM_CONFIG.EXPOSURE_DAY or U_P_BM_CONFIG.EXPOSURE_NIGHT
        
        if Lighting.ExposureCompensation ~= targetExposure then
            Lighting.ExposureCompensation = targetExposure
        end
        
        if Lighting.OutdoorAmbient ~= U_P_BM_CONFIG.OUTDOOR_AMBIENT then
            Lighting.OutdoorAmbient = U_P_BM_CONFIG.OUTDOOR_AMBIENT
        end

        if Lighting.GlobalShadows then
            Lighting.GlobalShadows = false
        end
    end)

    DLog("Sistema Ativado e Totalmente Funcional (UIs Protegidas).")
end

InitializeUPBM()

return {
    Disable = function()
        U_P_BM_CONFIG.ENABLED = false
        if currentUpdateSignal then currentUpdateSignal:Disconnect() end
        DLog("Sistema Desativado.")
    end,
    Enable = function()
        if not U_P_BM_CONFIG.ENABLED then
            U_P_BM_CONFIG.ENABLED = true
            InitializeUPBM()
        end
    end
}
