-- =============================================
-- LOAD FAST + ANTILAG + STREAMING FORTE - MOBILE
-- Carrega mapa rápido (1000 studs), decals visíveis, ultra detalhes sem travar
-- =============================================

local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserSettings = game:GetService("UserSettings")

local player = Players.LocalPlayer

-- Só roda em mobile (conforme solicitado)
if not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled then return end

-- =============================================
-- 1. FORÇAR QUALIDADE MÁXIMA VISUAL + ANTILAG (parece gráfico 5, roda como 1)
-- =============================================
local function forceUltraQuality()
    pcall(function()
        local gameSettings = UserSettings:GetService("UserGameSettings")
        gameSettings.GraphicsMode = Enum.GraphicsMode.Manual
        gameSettings.QualityLevel = 21  -- Qualidade máxima permitida
    end)
end

-- Streaming forte e permanente (carrega tudo rápido em 1000 studs)
Workspace.StreamingEnabled = true

-- =============================================
-- 2. ILUMINAÇÃO OTIMIZADA (mantém o que você pediu + correções)
-- =============================================
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.Brightness = 0

-- Remove efeitos que causam lag
for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BlurEffect") or effect:IsA("Atmosphere") then
        effect:Destroy()
    end
end

local function aplicarLuz()
    local hora = Lighting.ClockTime
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0

    if hora >= 17.5 or hora <= 6.5 then
        -- Noite
        Lighting.ExposureCompensation = 0.55
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        -- Dia
        Lighting.ExposureCompensation = 0.25
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    end
end

Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)
aplicarLuz()

-- =============================================
-- 3. OTIMIZAÇÃO DE PARTES (sem quebrar players, rostos ou texturas)
-- =============================================
local function otimizarInstancia(obj)
    if obj:IsA("Player") or obj:FindFirstAncestorOfClass("Player") or obj:FindFirstAncestor("Humanoid") then
        return
    end

    if obj:IsA("Light") then
        obj.Enabled = false
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Plastic
        end
    end
end

-- Aplica em tudo que já existe
for _, item in ipairs(Workspace:GetDescendants()) do
    otimizarInstancia(item)
end

-- Monitora novos objetos (leve, sem lag)
Workspace.DescendantAdded:Connect(otimizarInstancia)

-- =============================================
-- 4. MOSTRAR DECALS E TEXTURAS ESCONDIDAS + CARREGAMENTO RÁPIDO
-- =============================================
local function showAllHiddenDecals()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0
                obj.Visible = true
            end
        end
    end)
end

local function preloadMapFast()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local assets = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            local pos = (obj:IsA("BasePart") and obj.Position) or 
                        (obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.Position) or 
                        root.Position

            if (pos - root.Position).Magnitude <= 1000 then
                table.insert(assets, obj)
            end
        end
    end

    pcall(function()
        ContentProvider:PreloadAsync(assets)
    end)
end

-- =============================================
-- 5. STREAMING FORTE PERMANENTE + HEARTBEAT LIMPO
-- =============================================
local function permanentStrongStreaming()
    task.spawn(function()
        while true do
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local root = character.HumanoidRootPart
                pcall(function()
                    player:RequestStreamAroundAsync(root.Position, 1000)
                end)
            end
            task.wait(3)  -- Intervalo seguro para não causar lag
        end
    end)
end

-- Heartbeat vazio e limpo (sem piscar ou travar)
RunService.Heartbeat:Connect(function() end)

-- =============================================
-- 6. FPS MÁXIMO + EXECUÇÃO INICIAL
-- =============================================
pcall(function()
    setfpscap(300)
end)

forceUltraQuality()
showAllHiddenDecals()
preloadMapFast()
permanentStrongStreaming()

-- Recarrega quando o personagem respawna
player.CharacterAdded:Connect(function()
    task.wait(1)
    preloadMapFast()
    showAllHiddenDecals()
end)

-- Boost final de performance
pcall(function()
    settings().Rendering.QualityLevel = 1  -- Base baixa para FPS, mas com overrides visuais acima
end)
