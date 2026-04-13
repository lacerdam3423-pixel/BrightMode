local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local NetworkClient = game:GetService("NetworkClient")
local RunService = game:GetService("RunService")

setfpscap(200)

local function OptimizeMap()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Reflectance = 0
            if obj.Transparency == 1 then
                obj.Transparency = 0.8
            end
        end
        if obj:IsA("DataModelMesh") or obj:IsA("MeshPart") then
            if obj:IsA("MeshPart") then obj.Reflectance = 0 end
        end
    end
end

local function SystemBoost()
    settings().Network.IncomingReplicationLag = -1000
    NetworkClient:SetOutgoingKBPSLimit(0)
    
    if Workspace.StreamingEnabled then
        Workspace.StreamingMinRadius = 1e6
        Workspace.StreamingTargetRadius = 1e6
    end
    
    settings().Rendering.QualityLevel = 1
    Lighting.Technology = Enum.Technology.Compatibility
end

local function UpdateExposure()
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e9
    Lighting.FogStart = 1e9
    
    local time = Lighting.ClockTime
    if time >= 6 and time <= 18 then
        Lighting.ExposureCompensation = 0.1
    else
        Lighting.ExposureCompensation = 0.2
    end
end

SystemBoost()
OptimizeMap()

RunService.RenderStepped:Connect(function()
    UpdateExposure()
end)

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") then
        obj.Reflectance = 0
        if obj.Transparency == 1 then
            obj.Transparency = 0.8
        end
    end
end)
