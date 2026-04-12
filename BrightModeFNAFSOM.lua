local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local function applyGlobalSettings()
    Lighting.Brightness = 0.1
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.ExposureCompensation = 0
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
            effect.Enabled = false
        end
    end
end

local function dexScanner(obj)
    if obj:IsA("BasePart") then
        obj.CastShadow = false
        obj.Reflectance = 0
        
        if obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.Ice
        else
            obj.Material = Enum.Material.Plastic
        end
    end

    if obj:IsA("Texture") or obj:IsA("Decal") then
        if obj.Transparency == 1 then
            obj.Transparency = 0.7
        end
    end

    if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
        if obj:IsA("MeshPart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
        end
    end
end

local function updateEnvironment()
    local hour = Lighting.ClockTime
    if hour >= 6 and hour <= 18 then
        Lighting.ExposureCompensation = 0.2
        Lighting.Brightness = 0.01
    else
        Lighting.ExposureCompensation = 0.4
        Lighting.Brightness = 0.01
    end
end

RunService.Heartbeat:Connect(function()
    applyGlobalSettings()
    updateEnvironment()
    
    for _, item in pairs(game.Workspace:GetDescendants()) do
        dexScanner(item)
    end
end)

game.Workspace.DescendantAdded:Connect(function(newItem)
    dexScanner(newItem)
end)
