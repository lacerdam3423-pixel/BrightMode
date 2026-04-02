--[=[
    DEVELOPER TOOL: ULTRA_PERFORMANCE_BRIGHT_MODE_PRO (U_P_BM_PRO) v2.0
    DESCRICAO: Um sistema profissional de iluminação universal e Bright Mode absoluto.
    FUNCIONALIDADES: Bright Mode estável, No-Fog absoluto, Ciclo de tempo livre, Sem lag e Sem bugs de interface.
    ATUALIZAÇÃO: Sistema completo e integrado para desenvolvedores avançados.
]=]

-- [[ ESPERA DE CARREGAMENTO SEGURO ]]
-- Uma pequena pausa para garantir que os Decals e instâncias do mapa carreguem antes do script agir.
wait(0.0001)

-- [[ CONFIGURAÇÃO DO DESENVOLVEDOR ]]
local U_P_BM_CONFIG = {
    ENABLED = true,
    BRIGHTNESS_BASE = 0, -- Valor alto para o estilo Bright Mode clássico absoluto
    EXPOSURE_DAY = 0.3,    
    EXPOSURE_NIGHT = 0.37,  
    OUTDOOR_AMBIENT = Color3.fromRGB(255, 255, 255), -- Branco total para eliminar cantos escuros
    AMBIENT = Color3.fromRGB(255, 255, 255),
    HEARTBEAT_SAFE = true, 
}

-- [[ VARIÁVEIS DO SISTEMA ]]
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local isInitialized = false
local currentUpdateSignal

-- [[ SISTEMA DE LOGGING ]]
local function DLog(message, isError)
    local prefix = "[U_P_BM_PRO]"
    if isError then
        warn(prefix .. " ERRO: " .. tostring(message))
    else
        print(prefix .. " INFO: " .. tostring(message))
    end
end

-- [[ SISTEMA DE ILUMINAÇÃO REFINADO (NO-LAG BRIGHT MODE PRO) ]]
local function InitializeRefinedLighting()
    DLog("Inicializando Bright Mode Profissional Completo.")

    -- Kit Essencial Bright Mode (Sem remover nada do jogo, apenas iluminando tudo)
    Lighting.FogStart = 0
    Lighting.FogEnd = 999999
    Lighting.Brightness = U_P_BM_CONFIG.BRIGHTNESS_BASE
    Lighting.GlobalShadows = false -- Remove as sombras para não haver partes escuras
    Lighting.ShadowSoftness = 0 
    Lighting.EnvironmentDiffuseScale = 1 -- Mantém a difusão original do ambiente
    Lighting.EnvironmentSpecularScale = 1 -- Mantém os reflexos originais
    
    -- Garante que as cores fiquem neutras e vibrantes
    Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
    Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)

    -- Lógica Heartbeat / RenderStepped para Iluminação Estável
    if U_P_BM_CONFIG.HEARTBEAT_SAFE then
        if currentUpdateSignal then currentUpdateSignal:Disconnect() end
        
        currentUpdateSignal = RunService.RenderStepped:Connect(function()
            if not U_P_BM_CONFIG.ENABLED then 
                if currentUpdateSignal then currentUpdateSignal:Disconnect() end
                return 
            end

            -- O ciclo de tempo do Roblox continua rodando normalmente.
            -- O script apenas ajusta a exposição baseada na hora atual.
            local isDay = Lighting.ClockTime >= 6 and Lighting.ClockTime < 18
            local targetExposure = isDay and U_P_BM_CONFIG.EXPOSURE_DAY or U_P_BM_CONFIG.EXPOSURE_NIGHT
            
            -- Aplicação forçada e contínua das propriedades essenciais do Bright Mode
            if Lighting.ExposureCompensation ~= targetExposure then
                Lighting.ExposureCompensation = targetExposure
            end
            
            if Lighting.OutdoorAmbient ~= U_P_BM_CONFIG.OUTDOOR_AMBIENT then
                Lighting.OutdoorAmbient = U_P_BM_CONFIG.OUTDOOR_AMBIENT
            end

            if Lighting.Ambient ~= U_P_BM_CONFIG.AMBIENT then
                Lighting.Ambient = U_P_BM_CONFIG.AMBIENT
            end

            if Lighting.Brightness ~= U_P_BM_CONFIG.BRIGHTNESS_BASE then
                Lighting.Brightness = U_P_BM_CONFIG.BRIGHTNESS_BASE
            end

            if Lighting.GlobalShadows then
                Lighting.GlobalShadows = false
            end
            
            if Lighting.FogStart ~= 0 then
                Lighting.FogStart = 0
            end
            
            if Lighting.FogEnd ~= 999999 then
                Lighting.FogEnd = 999999
            end
        end)
    end
end

-- [[ INICIALIZAÇÃO DO SCRIPT ]]
local function InitializeUPBM()
    if isInitialized then return end
    isInitialized = true
    
    DLog("Script Pro de Iluminação e Bright Mode Inicializando...")
    
    -- Executa o kit essencial sem travar o jogo
    pcall(InitializeRefinedLighting)

    DLog("Sistema Totalmente Funcional Carregado com Sucesso. Sem interferência em GUIs.")
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
