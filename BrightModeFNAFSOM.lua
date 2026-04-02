--[=[
    DEVELOPER TOOL: ULTRA_BRIGHT_MODE_PRO_EDITION
    DESCRICAO: Sistema de iluminação universal focado em brilho máximo e remoção de sombras/luzes.
    ESTILO: Desenvolvedor Pro - Sem abreviações, sem travas, e execução direta.
]=]

-- [[ ESPERA DE SEGURANÇA PARA CARREGAMENTO ]]
-- Garante que o jogo não trave ao injetar o script logo na entrada
wait(0.0001)

-- [[ CONFIGURAÇÃO DO DESENVOLVEDOR ]]
local U_P_BM_CONFIG = {
    ENABLED = true,
    BRIGHTNESS_BASE = 0, 
    EXPOSURE_DAY = 0.3,    
    EXPOSURE_NIGHT = 0.37,  
    OUTDOOR_AMBIENT = Color3.fromRGB(200, 200, 200), 
    HEARTBEAT_SAFE = true, 
}

-- [[ VARIÁVEIS DO SISTEMA ]]
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
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

-- [[ SISTEMA DE BLOQUEIO DE PONTOS DE LUZ ]]
-- Esta função desliga qualquer luz criada por criadores de mapas para não dar conflito com o brilho
local function BloquearPontosDeLuz(objeto)
    if objeto:IsA("PointLight") or objeto:IsA("SpotLight") or objeto:IsA("SurfaceLight") then
        objeto.Enabled = false
        -- Proteção extra para garantir que a luz não seja reativada por scripts do jogo
        pcall(function()
            objeto:GetPropertyChangedSignal("Enabled"):Connect(function()
                if objeto.Enabled == true then
                    objeto.Enabled = false
                end
            end)
        end)
    end
end

-- [[ SISTEMA DE ILUMINAÇÃO REFINADO (NO-LAG BRIGHT MODE COMPLETO) ]]
local function InitializeRefinedLighting()
    DLog("Inicializando Bright Mode Profissional.")

    -- Configuração Clássica de Neblina solicitada
    Lighting.FogStart = 0
    Lighting.FogEnd = 999999
    
    Lighting.Brightness = U_P_BM_CONFIG.BRIGHTNESS_BASE
    Lighting.GlobalShadows = false -- Bloqueia todas as sombras do Roblox
    Lighting.EnvironmentDiffuseScale = 0 
    Lighting.EnvironmentSpecularScale = 0 

    -- NOTA: O céu e as nuvens originais não estão sendo alterados aqui.

    -- Lógica Heartbeat (RenderStepped) para Iluminação Estável sem travamentos
    if U_P_BM_CONFIG.HEARTBEAT_SAFE then
        if currentUpdateSignal then currentUpdateSignal:Disconnect() end
        
        currentUpdateSignal = RunService.RenderStepped:Connect(function()
            if not U_P_BM_CONFIG.ENABLED then 
                if currentUpdateSignal then currentUpdateSignal:Disconnect() end
                return 
            end

            -- Verifica o ciclo do Roblox sem interferir nele
            local isDay = Lighting.ClockTime >= 6 and Lighting.ClockTime < 18
            local targetExposure = isDay and U_P_BM_CONFIG.EXPOSURE_DAY or U_P_BM_CONFIG.EXPOSURE_NIGHT
            
            -- Aplica a exposição perfeita solicitada (0.3 e 0.37)
            if Lighting.ExposureCompensation ~= targetExposure then
                Lighting.ExposureCompensation = targetExposure
            end
            
            -- Força a iluminação do ambiente a ficar clara
            if Lighting.OutdoorAmbient ~= U_P_BM_CONFIG.OUTDOOR_AMBIENT then
                Lighting.OutdoorAmbient = U_P_BM_CONFIG.OUTDOOR_AMBIENT
            end

            -- Garante que as sombras continuem desligadas
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
    
    DLog("Iniciando varredura de iluminação no mapa...")
    
    -- Varre o mapa inteiro procurando por luzes artificiais para apagar
    for _, objeto in ipairs(Workspace:GetDescendants()) do
        BloquearPontosDeLuz(objeto)
    end
    
    -- Fica monitorando se novas luzes forem adicionadas enquanto você joga
    Workspace.DescendantAdded:Connect(function(novoObjeto)
        BloquearPontosDeLuz(novoObjeto)
    end)
    
    -- Inicializa o controle de ambiente
    pcall(InitializeRefinedLighting)

    DLog("Sistema Bright Mode Pro ativado com sucesso.")
end

-- Executa o sistema diretamente
InitializeUPBM()
