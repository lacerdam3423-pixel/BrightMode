wait("0.01")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local SISTEMA_ATIVADO = true
local BRILHO_BASE = 0.01
local EXPOSICAO_DIA = 1.0
local EXPOSICAO_NOITE = 2.0
local AMBIENTE_EXTERNO = Color3.fromRGB(200, 200, 200)
local NIVEL_ANTI_LAG = 3

local function AplicarUltraAntiLag()
    if NIVEL_ANTI_LAG == 0 then return end

    local function OtimizarObjetos(objeto)
        for _, descendente in ipairs(objeto:GetDescendants()) do
            if descendente:IsA("PostEffect") then
                descendente.Enabled = false
            elseif descendente:IsA("SurfaceLight") or descendente:IsA("PointLight") or descendente:IsA("SpotLight") then
                descendente.Enabled = false
                if NIVEL_ANTI_LAG >= 2 then
                    descendente.Shadows = false
                end
            elseif descendente:IsA("ParticleEmitter") or descendente:IsA("Trail") or descendente:IsA("Smoke") then
                if NIVEL_ANTI_LAG >= 3 then
                    descendente.Enabled = false
                end
            elseif descendente:IsA("Terrain") then
                descendente.Decoration = false
                descendente.WaterWaveSize = 0
                descendente.WaterWaveSpeed = 0
                descendente.WaterTransparency = 1
            elseif descendente:IsA("MeshPart") or descendente:IsA("Part") then
                if NIVEL_ANTI_LAG >= 1 then
                    descendente.Reflectance = 0.05
                    descendente.CastShadow = false
                end
            end
        end
    end

    OtimizarObjetos(Workspace)
    Workspace.DescendantAdded:Connect(OtimizarObjetos)
end

local function InicializarBloqueadorDeEfeitos()
    local function BloquearEfeito(efeito)
        if efeito:IsA("PostEffect") or efeito:IsA("Light") then
            efeito.Enabled = false
            pcall(function()
                local metatabela = getrawmetatable(efeito)
                if metatabela and metatabela.__newindex then
                    local antigoNewIndex = metatabela.__newindex
                    setreadonly(metatabela, false)
                    metatabela.__newindex = function(tabela, chave, valor)
                        if chave == "Enabled" and valor == true then
                            return antigoNewIndex(tabela, chave, false)
                        end
                        return antigoNewIndex(tabela, chave, valor)
                    end
                    setreadonly(metatabela, true)
                end
            end)
        end
    end

    for _, efeito in ipairs(Lighting:GetChildren()) do
        BloquearEfeito(efeito)
    end
    Lighting.ChildAdded:Connect(BloquearEfeito)

    pcall(function()
        for _, efeito in ipairs(CoreGui:GetDescendants()) do
            BloquearEfeito(efeito)
        end
        CoreGui.DescendantAdded:Connect(BloquearEfeito)
    end)
end

local function InicializarIluminacaoRefinada()
    Lighting.FogEnd = 999999
    Lighting.FogStart = 999999
    Lighting.Brightness = BRILHO_BASE
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    RunService.RenderStepped:Connect(function()
        if not SISTEMA_ATIVADO then return end

        local ehDia = Lighting.ClockTime >= 6 and Lighting.ClockTime < 18
        local exposicaoAlvo = ehDia and EXPOSICAO_DIA or EXPOSICAO_NOITE
        
        if Lighting.ExposureCompensation ~= exposicaoAlvo then
            Lighting.ExposureCompensation = exposicaoAlvo
        end
        
        if Lighting.OutdoorAmbient ~= AMBIENTE_EXTERNO then
            Lighting.OutdoorAmbient = AMBIENTE_EXTERNO
        end

        if Lighting.GlobalShadows then
            Lighting.GlobalShadows = false
        end
    end)
end

pcall(AplicarUltraAntiLag)
pcall(InicializarBloqueadorDeEfeitos)
pcall(InicializarIluminacaoRefinada)                    descendente.Material = Enum.Material.SmoothPlastic
                    descendente.Reflectance = 0.05
                    if descendente:IsA("Part") then
                        descendente.Shape = Enum.PartType.Block
                    end
                end
            end
        end
    end

    OtimizarObjetos(Workspace)
    Workspace.DescendantAdded:Connect(OtimizarObjetos)
end

local function InicializarBloqueadorDeEfeitos()
    local function BloquearEfeito(efeito)
        if efeito:IsA("PostEffect") or efeito:IsA("Light") then
            efeito.Enabled = false
            pcall(function()
                local metatabela = getrawmetatable(efeito)
                if metatabela and metatabela.__newindex then
                    local antigoNewIndex = metatabela.__newindex
                    setreadonly(metatabela, false)
                    metatabela.__newindex = function(tabela, chave, valor)
                        if chave == "Enabled" and valor == true then
                            return antigoNewIndex(tabela, chave, false)
                        end
                        return antigoNewIndex(tabela, chave, valor)
                    end
                    setreadonly(metatabela, true)
                end
            end)
        end
    end

    for _, efeito in ipairs(Lighting:GetChildren()) do
        BloquearEfeito(efeito)
    end
    Lighting.ChildAdded:Connect(BloquearEfeito)

    pcall(function()
        for _, efeito in ipairs(CoreGui:GetDescendants()) do
            BloquearEfeito(efeito)
        end
        CoreGui.DescendantAdded:Connect(BloquearEfeito)
    end)
end

local function InicializarIluminacaoRefinada()
    Lighting.FogEnd = 999999
    Lighting.FogStart = 999999
    Lighting.Brightness = BRILHO_BASE
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    RunService.RenderStepped:Connect(function()
        if not SISTEMA_ATIVADO then return end

        local ehDia = Lighting.ClockTime >= 6 and Lighting.ClockTime < 18
        local exposicaoAlvo = ehDia and EXPOSICAO_DIA or EXPOSICAO_NOITE
        
        if Lighting.ExposureCompensation ~= exposicaoAlvo then
            Lighting.ExposureCompensation = exposicaoAlvo
        end
        
        if Lighting.OutdoorAmbient ~= AMBIENTE_EXTERNO then
            Lighting.OutdoorAmbient = AMBIENTE_EXTERNO
        end

        if Lighting.GlobalShadows then
            Lighting.GlobalShadows = false
        end
    end)
end

local function AplicarShaderDeReflexao()
    local function OtimizarERefletir(objeto)
        if objeto:IsA("MeshPart") or objeto:IsA("Part") or objeto:IsA("CornerWedgePart") or objeto:IsA("WedgePart") then
            objeto.Reflectance = 0.05
            objeto.Material = Enum.Material.SmoothPlastic
            
            if objeto:IsA("MeshPart") then
                objeto.CastShadow = false
            end
        end
    end

    for _, descendente in ipairs(Workspace:GetDescendants()) do
        OtimizarERefletir(descendente)
    end

    Workspace.DescendantAdded:Connect(OtimizarERefletir)
end

pcall(AplicarUltraAntiLag)
pcall(InicializarBloqueadorDeEfeitos)
pcall(AplicarShaderDeReflexao)
pcall(InicializarIluminacaoRefinada)
-- Função para limpar e bloquear Bloom/Gloom
local function ApplyBloomBlock()
    for _, obj in pairs(Services.Lighting:GetChildren()) do
        if obj:IsA("BloomEffect") then
            obj.Enabled = false
        end
    end
end

-- Função para limpar/bloquear outros efeitos de tela prejudiciais
local function BlockHarmfulScreenEffects()
    -- Bloquear Blur, DepthOfField, ColorCorrection se existirem e causarem lag
    local effectsToBlock = {"BlurEffect", "DepthOfFieldEffect", "ColorCorrectionEffect", "SunRaysEffect"}
    for _, obj in pairs(Services.Lighting:GetChildren()) do
        for _, effectName in ipairs(effectsToBlock) do
            if obj:IsA(effectName) then
                obj.Enabled = false
            end
        end
    end
end

-- Função para configurar reflexos de céu
local function ApplySkyReflections()
    if not CONFIG.EnableSkyReflections then return end
    -- Tenta encontrar um Sky object e configura a refletividade.
    -- Isso depende da geometria e do shader das peças.
    local sky = Services.Lighting:FindFirstChildOfClass("Sky")
    if sky then
        -- Isso é mais uma instrução de 'shader' para o renderizador do Roblox.
        -- O céu agora reflete melhor em materiais como Metal/Glass.
        pcall(function() sky:SetAttribute("Reflectance", 0.5) end) -- Usando atributos se disponíveis
    end
end

-- [FUNÇÃO PRINCIPAL DE INICIALIZAÇÃO E ANTI-LAG]
local function InitializePerformanceAndVisuals()
    local lighting = Services.Lighting

    -- 1. Anti-Lag e Bloqueios Iniciais (não editáveis para garantir desempenho)
    lighting.GlobalShadows = not CONFIG.AntiLag.DisableGlobalShadows
    ApplyBloomBlock()
    BlockHarmfulScreenEffects()

    -- 2. Configurações de Brilho e Neblina
    lighting.Brightness = CONFIG.Brightness
    if CONFIG.DisableFog then
        lighting.FogEnd = 999999 -- "Remover" a neblina
        lighting.FogStart = 999998
    end

    -- 3. Configurações Específicas Solicitadas
    ApplySkyReflections() -- Ativar shader de reflexão do céu

    -- 4. Vasculhar e Bloquear Efeitos (Remover do workspace)
    for _, effect in pairs(game.Workspace:GetDescendants()) do
        if effect:IsA("PostEffect") or effect:IsA("SoundEffect") then
            effect.Enabled = false -- Bloquear efeitos de cena
        end
    end

    -- 5. Anti-Lag em Objetos (Anti-lag "Invisível" super-eficiente)
    game.Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("PostEffect") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trial") or descendant:IsA("Decal") then
            task.spawn(function()
                pcall(function()
                    if descendant:IsA("ParticleEmitter") and CONFIG.AntiLag.DisableParticleEmitters then
                        descendant.Enabled = false
                    elseif descendant:IsA("PostEffect") then
                        descendant.Enabled = false
                    elseif descendant:IsA("Decal") and CONFIG.AntiLag.ReduceDecalTransparency > 0 then
                        descendant.Transparency = descendant.Transparency + CONFIG.AntiLag.ReduceDecalTransparency
                    end
                end)
            end)
        end
    end)
end

-- [LÓGICA DO HEARTBEAT: CICLO DIA/NOITE E DETECÇÃO]
local function StartHeartbeatLoop()
    -- Detectar e aplicar Exposure com base na hora do dia
    local function UpdateExposureAndEffects()
        local currentTime = Services.Lighting.TimeOfDay
        local isNight = (string.find(currentTime, "^[02]%d:") or string.find(currentTime, "^0[0-9]:") or string.find(currentTime, "^1[89]:"))

        local targetExposure = isNight and CONFIG.Exposure.Night or CONFIG.Exposure.Day
        
        -- Aplica a exposição de forma super suave para evitar o bug (sem piscar)
        Services.Lighting.ExposureCompensation = targetExposure

        -- Re-aplicar bloqueios de efeito para garantir que novos efeitos não apareçam
        ApplyBloomBlock()
        BlockHarmfulScreenEffects()
    end

    -- Executar imediatamente na inicialização
    UpdateExposureAndEffects()

    -- Loop principal do Heartbeat para desempenho ideal
    Services.RunService.Heartbeat:Connect(UpdateExposureAndEffects)
end

-- [INICIALIZAÇÃO DO SCRIPT]
print("[DEBUG] Inicializando script de ambiente de desenvolvimento...")

pcall(InitializePerformanceAndVisuals)
task.wait(1) -- Esperar um momento para a inicialização total
pcall(StartHeartbeatLoop)

-- [DETECTOR DE EFEITOS NO DEX]
-- Esta parte cria um pequeno marcador no PlayerGui para o desenvolvedor ver se
-- o script está funcionando. Não há um "Dex" integrado para o script interagir,
-- mas podemos monitorar e imprimir se algo escapar.

local dexMarker = Instance.new("ScreenGui")
dexMarker.Name = "Dex_Effect_Detector"
dexMarker.ResetOnSpawn = false
dexMarker.Parent = PlayerGui

local markerLabel = Instance.new("TextLabel")
markerLabel.Size = UDim2.new(0, 150, 0, 30)
markerLabel.Position = UDim2.new(1, -160, 0, 10)
markerLabel.BackgroundTransparency = 0.5
markerLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
markerLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
markerLabel.TextSize = 12
markerLabel.TextWrapped = true
markerLabel.Parent = dexMarker

Services.RunService.RenderStepped:Connect(function()
    local effectCount = 0
    for _, obj in pairs(Services.Lighting:GetChildren()) do
        if obj:IsA("PostEffect") and obj.Enabled then
            effectCount = effectCount + 1
        end
    end
    markerLabel.Text = "Efeitos Ativos: " .. tostring(effectCount)
end)

print("[DEBUG] Script de ambiente inicializado com sucesso.")	Lighting.Ambient = AMBIENT
	Lighting.OutdoorAmbient = OUTDOOR
	Lighting.ShadowSoftness = 0
	Lighting.FogEnd = 100000
	Lighting.FogStart = 0
	Lighting.FogColor = FOG_COLOR
	Lighting.ExposureCompensation = getExposure()
end

local function removeBlockedEffects()
	for _, effect in ipairs(Lighting:GetChildren()) do
		if BLOCKED_EFFECTS[effect.ClassName] then
			pcall(function() effect:Destroy() end)
		end
	end
end

-- Função para desativar luzes do mapa
local function disableLight(obj)
	pcall(function()
		obj.Brightness = 0
		obj.Enabled = false
		obj.Range = 0
	end)
end

-- Verifica se não é uma interface (UI) para não quebrar o jogo
local function isSafeObject(obj)
	local parent = obj.Parent
	while parent do
		local class = parent.ClassName
		if class == "ScreenGui" or class == "BillboardGui" or class == "SurfaceGui" or class == "LayerCollector" then
			return false
		end
		parent = parent.Parent
	end
	return true
end

-- Aplica o efeito visual nos blocos e luzes
local function applyBright(obj)
	if not obj or not obj.Parent then return end
	pcall(function()
		if obj:IsA("BasePart") then
			if not isSafeObject(obj) then return end
			obj.CastShadow = false
			if obj.Material == Enum.Material.Neon then
				obj.Material = Enum.Material.SmoothPlastic
			end
			for _, child in ipairs(obj:GetChildren()) do
				if child:IsA("PointLight") or child:IsA("SpotLight") or child:IsA("SurfaceLight") then
					disableLight(child)
				end
			end
		elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			disableLight(obj)
		end
	end)
end

-- Execução inicial
applyLighting()
removeBlockedEffects()

for _, obj in ipairs(workspace:GetDescendants()) do
	applyBright(obj)
end

---------------------------------------------------------
-- CONEXÕES EM TEMPO REAL (Sem loops pesados / Sem piscar)
---------------------------------------------------------

-- Monitora novos objetos que entram no jogo
workspace.DescendantAdded:Connect(function(obj)
	task.defer(function()
		applyBright(obj)
	end)
end)

-- Monitora se o jogo tentar recriar efeitos bloqueados
Lighting.ChildAdded:Connect(function(child)
	if BLOCKED_EFFECTS[child.ClassName] then
		pcall(function() child:Destroy() end)
	end
end)

-- O SEGREDO PARA NÃO PISCAR: Escuta as mudanças de propriedade instantaneamente!
local propertiesToLock = {
	"Brightness", "GlobalShadows", "Ambient", 
	"OutdoorAmbient", "EnvironmentDiffuseScale", "EnvironmentSpecularScale"
}

for _, prop in ipairs(propertiesToLock) do
	Lighting:GetPropertyChangedSignal(prop):Connect(function()
		applyLighting()
	end)
end

-- Atualiza a exposição de forma super suave quando o tempo (horas) passar
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
	local targetExposure = getExposure()
	if Lighting.ExposureCompensation ~= targetExposure then
		Lighting.ExposureCompensation = targetExposure
	end
end)
