-- [[ SERVIÇOS DO SISTEMA ]] --
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Terrain = game:GetService("Terrain")

-- [[ CONFIGURAÇÕES DE RENDERIZAÇÃO E STREAMING ]] --
settings().Rendering.QualityLevel = Enum.QualityLevel.Level02
Workspace.StreamingEnabled = true
Workspace.StreamingMinRadius = 32
Workspace.StreamingTargetRadius = 64

-- Ajuste de Comportamento Nível 2 (StreamingPauseMode)
pcall(function()
    sethiddenproperty(Workspace, "StreamingPauseMode", Enum.StreamingPauseMode.ClientPhysicsPause)
end)

-- [[ FUNÇÃO DE OTIMIZAÇÃO DE INSTÂNCIAS ]] --
local function OptimizarObjeto(instancia)
    if instancia:IsA("BasePart") then
        instancia.Reflectance = 0
        instancia.CastShadow = false
        
        -- Converte materiais pesados para básicos
        if instancia.Material == Enum.Material.Neon or instancia.Material == Enum.Material.Glass then
            instancia.Material = Enum.Material.Plastic
        end
        
        -- Mantém visibilidade mas remove detalhes
        if instancia.Transparency >= 0.98 then
            instancia.Transparency = 0.8
        end
        
    elseif instancia:IsA("MeshPart") then
        instancia.Reflectance = 0
        instancia.TextureID = ""
        instancia.CastShadow = false
        
    elseif instancia:IsA("DataModelMesh") or instancia:IsA("CharacterMesh") or instancia:IsA("SpecialMesh") then
        instancia.TextureId = ""
        
    elseif instancia:IsA("Texture") or instancia:IsA("Decal") then
        instancia.Transparency = 1
        
    elseif instancia:IsA("Light") then
        instancia.Enabled = false
        
    elseif instancia:IsA("PostEffect") or instancia:IsA("BloomEffect") or instancia:IsA("BlurEffect") or instancia:IsA("SunRaysEffect") then
        instancia.Enabled = false
    end
end

-- [[ CONTROLE DE ILUMINAÇÃO DE ALTA PERFORMANCE ]] --
local function ConfigurarIluminacao()
    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.ExposureCompensation = 0.2
    Lighting.FogEnd = 1000000-- Valor alto para evitar renderização de névoa
    
    -- Limpeza de Atmosfera
    local atmosfera = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmosfera then atmosfera:Destroy() end
    
    -- Cores sólidas para reduzir processamento de shader
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
end

-- [[ CONFIGURAÇÃO DE TERRENO (WATER) ]] --
local function OptimizarTerreno()
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
end

-- [[ EXECUÇÃO INICIAL E VARREDURA ]] --
ConfigurarIluminacao()
OptimizarTerreno()

-- Varredura assíncrona para não travar o carregamento inicial
task.spawn(function()
    local objetos = game:GetDescendants()
    for i, objeto in ipairs(objetos) do
        OptimizarObjeto(objeto)
        if i % 100 == 0 then task.wait() end -- Yield para manter FPS
    end
end)

-- [[ CONEXÕES EM TEMPO REAL (EVENTOS) ]] --
game.DescendantAdded:Connect(OptimizarObjeto)

-- Loop de manutenção de performance (Low Frequency)
task.spawn(function()
    while true do
        ConfigurarIluminacao()
        task.wait(5) -- Verifica a cada 5 segundos para economizar CPU
    end
end)

-- Estabilização de FPS via Heartbeat
RunService.Heartbeat:Connect(function()
    -- Garante que o Streaming Mode permaneça no Nível 2
    pcall(function()
        sethiddenproperty(Workspace, "StreamingPauseMode", 2)
    end)
end)
