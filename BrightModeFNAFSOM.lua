local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local NetworkClient = game:GetService("NetworkClient")
local RunService = game:GetService("RunService")

setfpscap(200)

local function OptimizeObject(obj)
    if obj:IsA("BasePart") then
        obj.Reflectance = 0
        if obj.Transparency == 1 then
            obj.Transparency = 0.8
        end
    elseif obj:IsA("DataModelMesh") or obj:IsA("SpecialMesh") then
        obj.VertexColor = Vector3.new(1, 1, 1)
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 0.5
    end
end

local function ApplyWorldSettings()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        OptimizeObject(obj)
    end
    
    if Workspace.StreamingEnabled then
        Workspace.StreamingMinRadius = 10000
        Workspace.StreamingTargetRadius = 10000
    end
    
    settings().Network.IncomingReplicationLag = -1000
    NetworkClient:SetOutgoingKBPSLimit(0)
end

local function UpdateLighting()
    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e6
    Lighting.FogStart = 0
    
    if Lighting.ClockTime >= 6 and Lighting.ClockTime <= 18 then
        Lighting.ExposureCompensation = 0.1
    else
        Lighting.ExposureCompensation = 0.2
    end
end

ApplyWorldSettings()
UpdateLighting()

Lighting:GetPropertyChangedSignal("ClockTime"):Connect(UpdateLighting)
Workspace.DescendantAdded:Connect(OptimizeObject)

if Lighting:FindFirstChildOfClass("PostProcessEffect") then
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostProcessEffect") then
            effect.Enabled = false
        end
    end
end
