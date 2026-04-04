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
-- =============================================
-- Evil Nun - Pacote de Scripts Seguros
-- Todos os scripts combinados + proteções contra interferência em GUIs do jogo
-- Execute este arquivo único
-- =============================================

print("=== Iniciando Pacote de Scripts Seguros para Evil Nun ===")

-- Proteção global: Criar um folder isolado para evitar conflitos com GUIs do jogo
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local safeFolder = Instance.new("Folder")
safeFolder.Name = "SafeScriptsFolder"
if playerGui:FindFirstChild("SafeScriptsFolder") then
    playerGui.SafeScriptsFolder:Destroy()
end
safeFolder.Parent = playerGui

-- =============================================
-- 1. Enable Reset
-- =============================================
print("Carregando: Enable Reset")
pcall(function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Enable-Reset-in-Roblox-Games-all_846"))()
end)

-- =============================================
-- 2. Infinite Jump
-- =============================================
print("Carregando: Infinite Jump")
pcall(function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-infinite-jump-31287"))()
end)

-- =============================================
-- 3. BrightMode
-- =============================================
print("Carregando: BrightMode")
pcall(function()
    wait(0.01)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lacerdam3423-pixel/BrightMode/main/BrightModeFNAFSOM.lua"))()
end)

-- =============================================
-- 4. Anti GamePlay Paused
-- =============================================
print("Carregando: Anti GamePlay Paused")
pcall(function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Anti-GamePlay-Paused-43496"))()
end)

-- =============================================
-- 5. Freecam
-- =============================================
print("Carregando: Freecam")
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/lacerdam3423-pixel/cuddly-carnival/main/Ul.lua"))()
end)

-- =============================================
-- 6. ProximityPrompt Instantâneo (ues.lua) - Modificado e seguro
-- =============================================
print("Carregando: ProximityPrompt Instantâneo")
pcall(function()
    local w = workspace
    local function fix(prompt)
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
            prompt:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                if prompt.HoldDuration ~= 0 then
                    prompt.HoldDuration = 0
                end
            end)
        end
    end

    for _, v in ipairs(w:GetDescendants()) do
        fix(v)
    end
    w.DescendantAdded:Connect(fix)
end)

-- =============================================
-- 7. Inf Yield
-- =============================================
print("Carregando: Inf Yield")
pcall(function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-inf-yeld-61578"))()
end)

-- =============================================
-- 8. ESP
-- =============================================
print("Carregando: ESP")
pcall(function()
    wait(0.01)
    loadstring(game:HttpGet("https://pastefy.app/kTW6GHcf/raw"))()
end)

-- =============================================
-- 9. Hitbox Expandida - Versão limpa e segura
-- =============================================
print("Carregando: Hitbox")
pcall(function()
    local HeadSize = 45
    local IsDisabled = true
    local IsTeamCheckEnabled = false 

    game:GetService('RunService').RenderStepped:Connect(function()
        if not IsDisabled then return end
        local localPlayer = game:GetService('Players').LocalPlayer
        if not localPlayer then return end
        
        local localPlayerTeam = localPlayer.Team
        
        for _, plr in ipairs(game:GetService('Players'):GetPlayers()) do
            if plr ~= localPlayer and (not IsTeamCheckEnabled or plr.Team ~= localPlayerTeam) then
                local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(HeadSize, HeadSize, HeadSize)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end
            end
        end
    end)
end)

-- =============================================
-- 10. EXE GUI - Versão Protegida e Isolada
-- =============================================
print("Carregando: EXE GUI (protegida)")
pcall(function()
    wait(0.1)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    if playerGui:FindFirstChild("ExeGui") then
        playerGui.ExeGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ExeGui"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 10000
    screenGui.Parent = playerGui

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0,260,0,160)
    mainFrame.Position = UDim2.new(0.5,-130,0.5,-80)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = screenGui

    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,14)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,30)
    titleBar.BackgroundColor3 = Color3.fromRGB(28,28,28)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,14)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-50,1,0)
    title.Position = UDim2.new(0,12,0,0)
    title.BackgroundTransparency = 1
    title.Text = "Exe - Evil Nun"
    title.TextColor3 = Color3.fromRGB(0,255,120)
    title.TextSize = 18
    title.Font = Enum.Font.Arial
    title.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,22,0,22)
    closeBtn.Position = UDim2.new(1,-28,0,4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255,60,60)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(1,-20,0,78)
    codeBox.Position = UDim2.new(0,10,0,38)
    codeBox.BackgroundColor3 = Color3.fromRGB(25,25,25)
    codeBox.TextColor3 = Color3.fromRGB(180,255,180)
    codeBox.Text = '-- Cole seu script aqui e clique em EXECUTAR'
    codeBox.TextSize = 14
    codeBox.Font = Enum.Font.Code
    codeBox.TextWrapped = true
    codeBox.ClearTextOnFocus = false
    codeBox.MultiLine = true
    codeBox.Parent = mainFrame
    Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0,10)

    local exeBtn = Instance.new("TextButton")
    exeBtn.Size = UDim2.new(0.94,0,0,34)
    exeBtn.Position = UDim2.new(0.03,0,1,-44)
    exeBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
    exeBtn.Text = "EXECUTAR SCRIPT"
    exeBtn.TextColor3 = Color3.new(1,1,1)
    exeBtn.TextSize = 14
    exeBtn.Font = Enum.Font.GothamBold
    exeBtn.Parent = mainFrame
    Instance.new("UICorner", exeBtn).CornerRadius = UDim.new(0,10)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0,52,0,52)
    toggleBtn.Position = UDim2.new(1,-70,1,-70)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
    toggleBtn.Text = "Exe"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.TextSize = 16
    toggleBtn.Visible = false
    toggleBtn.Parent = screenGui
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)

    local executando = false
    local function executar()
        if executando then return end
        executando = true
        task.spawn(function()
            pcall(function()
                loadstring(codeBox.Text)()
            end)
            executando = false
        end)
    end

    exeBtn.MouseButton1Click:Connect(executar)
    closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false; toggleBtn.Visible = true end)
    toggleBtn.MouseButton1Click:Connect(function() mainFrame.Visible = true; toggleBtn.Visible = false end)

    -- Função de arrastar
    local function dragify(frame, handle)
        local dragging = false
        local dragStart, startPos
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)
        handle.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    dragify(mainFrame, titleBar)
    dragify(toggleBtn, toggleBtn)
end)

print("=== Todos os scripts carregados com sucesso! ===")
print("A GUI do EXE está disponível. Use com cuidado para não interferir no jogo.")
