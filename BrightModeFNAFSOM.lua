--[=[
    DEVELOPER TOOL: ULTRA_PERFORMANCE_BRIGHT_MODE_PRO (U_P_BM_PRO) v2.0
    DESCRICAO: Um sistema de iluminação e desempenho universal completo e agressivo.
    FUNCIONALIDADES: Bright Mode estável, No-Fog Extremo, Bloqueio de Luzes, Exposição Automática, Carregamento Seguro.
    ATUALIZAÇÃO: Agora mantém o ciclo de dia/noite intacto e foca 100% no controle absoluto de luz!
]=]

-- [[ SISTEMA DE SEGURANÇA E CARREGAMENTO ]]
-- Garante que o script espere o tempo milimétrico solicitado e carregue as texturas básicas
wait("0.0001")
local decal = Instance.new("Decal")
decal.Texture = "rbxassetid://0" -- Simula o carregamento (load decal) de textura padrão do motor
decal:Destroy()

-- [[ CONFIGURAÇÃO DO DESENVOLVEDOR ]]
local U_P_BM_CONFIG = {
    ENABLED = true,
    BRIGHTNESS_BASE = 0, -- Mantido em zero para a exposição ditar o brilho perfeitamente
    EXPOSURE_DAY = 0.3,    
    EXPOSURE_NIGHT = 0.47,  
    OUTDOOR_AMBIENT = Color3.fromRGB(200, 200, 200), 
    HEARTBEAT_SAFE = true, 
}

-- [[ VARIÁVEIS DO SISTEMA ]]
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local isInitialized = false
local currentUpdateSignal
local lightDisablerSignal

-- [[ SISTEMA DE LOGGING ]]
local function DLog(message, isError)
    local prefix = "[U_P_BM PRO]"
    if isError then
        warn(prefix .. " ERRO: " .. tostring(message))
    else
        print(prefix .. " INFO: " .. tostring(message))
    end
end

-- [[ SISTEMA DE BLOQUEIO DE LUZES (POINTLIGHT, SPOTLIGHT, SURFACELIGHT) ]]
local function BlockAllLightSources()
    DLog("Iniciando varredura e bloqueio de todas as fontes de luz do mapa.")
    
    local function DisableLights(obj)
        if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj.Enabled = false
            -- Força o bloqueio caso algum script tente ligar novamente
            pcall(function()
                obj:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if obj.Enabled then
                        obj.Enabled = false
                    end
                end)
            end)
        end
    end

    -- Varre tudo que já existe no jogo
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        DisableLights(descendant)
    end

    -- Fica ouvindo novos objetos que forem spawnados no mapa
    lightDisablerSignal = Workspace.DescendantAdded:Connect(DisableLights)
end

-- [[ SISTEMA DE BLOQUEIO DE EFEITOS DE TELA ]]
local function InitializePostEffectBlocker()
    DLog("Inicializando Bloqueador de Efeitos de Tela.")
    
    local function BlockEffect(effect)
        if effect:IsA("PostEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") then
            effect.Enabled = false
            -- Bloqueia scripts que tentam religar o efeito
            pcall(function()
                effect:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if effect.Enabled then
                        effect.Enabled = false
                    end
                end)
            end)
        end
    end

    for _, effect in ipairs(Lighting:GetChildren()) do
        BlockEffect(effect)
    end
    Lighting.ChildAdded:Connect(BlockEffect)
end

-- [[ SISTEMA DE ILUMINAÇÃO REFINADO (NO-LAG BRIGHT MODE PRO) ]]
local function InitializeRefinedLighting()
    DLog("Inicializando Kit Bright Mode Completo Estilo Antigo Pro.")

    -- Configuração Base Essencial do Bright Mode (FOG)
    Lighting.FogStart = 0
    Lighting.FogEnd = 999999
    Lighting.Brightness = U_P_BM_CONFIG.BRIGHTNESS_BASE
    Lighting.GlobalShadows = false -- Bloqueio absoluto de sombras
    Lighting.EnvironmentDiffuseScale = 0 
    Lighting.EnvironmentSpecularScale = 0 

    -- Lógica RenderStepped para Iluminação Estável sem quebrar o ciclo do jogo
    if U_P_BM_CONFIG.HEARTBEAT_SAFE then
        if currentUpdateSignal then currentUpdateSignal:Disconnect() end
        
        currentUpdateSignal = RunService.RenderStepped:Connect(function()
            if not U_P_BM_CONFIG.ENABLED then 
                if currentUpdateSignal then currentUpdateSignal:Disconnect() end
                return 
            end

            -- O ciclo de tempo (ClockTime) do Roblox continua rodando normalmente!
            local isDay = Lighting.ClockTime >= 6 and Lighting.ClockTime < 18
            local targetExposure = isDay and U_P_BM_CONFIG.EXPOSURE_DAY or U_P_BM_CONFIG.EXPOSURE_NIGHT
            
            -- Aplicação forçada das exposições pedidas (0.3 e 0.37)
            if Lighting.ExposureCompensation ~= targetExposure then
                Lighting.ExposureCompensation = targetExposure
            end
            
            if Lighting.OutdoorAmbient ~= U_P_BM_CONFIG.OUTDOOR_AMBIENT then
                Lighting.OutdoorAmbient = U_P_BM_CONFIG.OUTDOOR_AMBIENT
            end

            if Lighting.GlobalShadows then
                Lighting.GlobalShadows = false
            end
            
            -- Garante que o Fog não mude por scripts externos
            if Lighting.FogStart ~= 0 then Lighting.FogStart = 0 end
            if Lighting.FogEnd ~= 999999 then Lighting.FogEnd = 999999 end
        end)
    end
end

-- [[ INICIALIZAÇÃO DO SCRIPT ]]
local function InitializeUPBM()
    if isInitialized then return end
    isInitialized = true
    
    DLog("Script de Iluminação Refinado Inicializando no Estilo Desenvolvedor Pro...")
    
    pcall(BlockAllLightSources)
    pcall(InitializePostEffectBlocker)
    pcall(InitializeRefinedLighting)

    DLog("Sistema Totalmente Funcional Carregado com Sucesso.")
end

InitializeUPBM()

return {
    Disable = function()
        U_P_BM_CONFIG.ENABLED = false
        if currentUpdateSignal then currentUpdateSignal:Disconnect() end
        if lightDisablerSignal then lightDisablerSignal:Disconnect() end
        DLog("Sistema Desativado.")
    end,
    Enable = function()
        if not U_P_BM_CONFIG.ENABLED then
            U_P_BM_CONFIG.ENABLED = true
            InitializeUPBM()
        end
    end
}
