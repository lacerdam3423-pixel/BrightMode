local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local NetworkClient = game:GetService("NetworkClient")
local RunService = game:GetService("RunService")

if setfpscap then
    setfpscap(200)
end

local function ProcessPart(obj)
    if obj:IsA("BasePart") then
        obj.Reflectance = 0
        if obj.Transparency > 0.95 then
            obj.Transparency = 0.8
        end
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    ProcessPart(obj)
end

Workspace.DescendantAdded:Connect(ProcessPart)

settings().Network.IncomingReplicationLag = -1000
NetworkClient:SetOutgoingKBPSLimit(0)

if Workspace.StreamingEnabled then
    Workspace.StreamingMinRadius = 1e6
    Workspace.StreamingTargetRadius = 1e6
end

local function UpdateEnv()
    Lighting.Brightness = 0.1
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    
    local time = Lighting.ClockTime
    if time >= 6 and time <= 18 then
        Lighting.ExposureCompensation = 0.1
    else
        Lighting.ExposureCompensation = 0.2
    end
end

UpdateEnv()
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(UpdateEnv)

for _, effect in ipairs(Lighting:GetDescendants()) do
    if effect:IsA("PostProcessEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") then
        effect.Enabled = false
    end
end
