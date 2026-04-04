-- =============================================
-- LOAD FAST + ANTILAG + STREAMING FORTE - MOBILE
-- Carrega mapa rápido (1000 studs) + Decals visíveis + Ultra detalhes
-- Sem interferir em nenhuma GUI ou tela do jogo
-- =============================================

local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserSettings = game:GetService("UserSettings")

local player = Players.LocalPlayer

-- Só roda em mobile
if not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled then return end

-- =============================================
-- 1. FORÇAR QUALIDADE VISUAL ALTA + ANTILAG (parece gráfico 5, roda leve)
-- =============================================
local function forceUltraQuality()
    pcall(function()
        local gameSettings = UserSettings:GetService("UserGameSettings")
        gameSettings.GraphicsMode = Enum.GraphicsMode.Manual
        gameSettings.QualityLevel = 21
    end)
end

Workspace.StreamingEnabled = true

-- =============================================
-- 2. ILUMINAÇÃO OTIMIZADA (sem quebrar nada)
-- =============================================
Lighting.GlobalShadows = false
Lighting.FogEnd = 100000
Lighting.Brightness = 0

-- Remove apenas efeitos de post-processing que causam lag
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
        Lighting.ExposureCompensation = 0.55
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.ExposureCompensation = 0.25
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
    end
end

Lighting:GetPropertyChangedSignal("ClockTime"):Connect(aplicarLuz)
aplicarLuz()

-- =============================================
-- 3. OTIMIZAÇÃO DO MAPA (ignora totalmente Players, Humanoid, GUIs e telas)
-- =============================================
local function otimizarInstancia(obj)
    -- Proteção total contra GUIs, telas e interfaces
    if obj:IsA("GuiObject") or obj:IsA("ScreenGui") or obj:IsA("SurfaceGui") or 
       obj:IsA("BillboardGui") or obj:FindFirstAncestorWhichIsA("GuiBase") or
       obj:FindFirstAncestorOfClass("Player") or obj:FindFirstAncestor("Humanoid") then
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

-- Aplica no que já existe
for _, item in ipairs(Workspace:GetDescendants()) do
    otimizarInstancia(item)
end

-- Monitora novos objetos sem lag
Workspace.DescendantAdded:Connect(otimizarInstancia)

-- =============================================
-- 4. MOSTRAR DECALS E TEXTURAS ESCONDIDAS + PRELOAD RÁPIDO (1000 studs)
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
    local character = player.Character
    if not character then return end
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
            task.wait(3)
        end
    end)
end

-- Heartbeat limpo (sem piscar ou travar)
RunService.Heartbeat:Connect(function() end)

-- =============================================
-- 6. FPS MÁXIMO + INICIALIZAÇÃO
-- =============================================
pcall(function()
    setfpscap(300)
end)

forceUltraQuality()
showAllHiddenDecals()
preloadMapFast()
permanentStrongStreaming()

-- Recarrega ao respawnar
player.CharacterAdded:Connect(function()
    task.wait(1)
    preloadMapFast()
    showAllHiddenDecals()
end)

-- Configuração final de performance
pcall(function()
    settings().Rendering.QualityLevel = 1
end)
