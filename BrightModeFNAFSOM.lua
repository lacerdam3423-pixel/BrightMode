local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local NetworkClient = game:GetService("NetworkClient")

setfpscap(200)

local function OptimizeObject(obj)
    if obj:IsA("BasePart") then
        obj.Reflectance = 0
        if obj.Transparency == 1 then
            obj.Transparency = 0.8
        end
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    OptimizeObject(obj)
end

Workspace.DescendantAdded:Connect(OptimizeObject)

settings().Network.IncomingReplicationLag = -1000
NetworkClient:SetOutgoingKBPSLimit(0)

if Workspace.StreamingEnabled then
    Workspace.StreamingMinRadius = 1e6
    Workspace.StreamingTargetRadius = 1e6
end

local function UpdateLighting()
    Lighting.Brightness = 0
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e6
    Lighting.FogStart = 0
    
    local isDay = Lighting.ClockTime >= 6 and Lighting.ClockTime <= 18
    Lighting.ExposureCompensation = isDay and 0.2 or 0.4
end

UpdateLighting()
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(UpdateLighting)

for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("PostProcessEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") then
        effect.Enabled = false
    end
end
