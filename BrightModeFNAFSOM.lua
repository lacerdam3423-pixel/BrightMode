local a = game:GetService("RunService")
local b = game:GetService("Lighting")
local c = game:GetService("Workspace")
local d = game:GetService("Terrain")

local function e(f)
    pcall(function()
        if f:IsA("BasePart") then
            f.Reflectance = 0
            f.CastShadow = false
            if f.Material == Enum.Material.Neon then
                f.Material = Enum.Material.Ice
            end
            if f.Transparency >= 0.98 then
                f.Transparency = 0.8
            end
        elseif f:IsA("MeshPart") then
            f.Reflectance = 0
            f.TextureID = ""
        elseif f:IsA("DataModelMesh") or f:IsA("CharacterMesh") then
            f.TextureId = ""
        elseif f:IsA("Texture") or f:IsA("Decal") then
            f.Transparency = 1
        elseif f:IsA("SpecialMesh") then
            f.TextureId = ""
        elseif f:IsA("Light") then
            f.Enabled = false
        end
    end)
end

local function h()
    b.Brightness = 0
    b.GlobalShadows = false
    b.Ambient = Color3.new(1, 1, 1)
    b.OutdoorAmbient = Color3.new(1, 1, 1)
    local i = b.ClockTime
    if i >= 6 and i <= 18 then
        b.ExposureCompensation = 0.1
    else
        b.ExposureCompensation = 0.2
    end
    b.FogEnd = 9e9
    b.FogStart = 0
    local j = b:FindFirstChildOfClass("Atmosphere")
    if j then j:Destroy() end
end

settings().Rendering.QualityLevel = 2
c.StreamingEnabled = true
c.StreamingMinRadius = 32
c.StreamingTargetRadius = 64

if d then
    d.WaterWaveSize = 0
    d.WaterWaveSpeed = 0
    d.WaterReflectance = 0
    d.WaterTransparency = 0
end

h()

task.spawn(function()
    local k = game:GetDescendants()
    for l = 1, #k do
        e(k[l])
        if l % 100 == 0 then task.wait() end
    end
end)

game.DescendantAdded:Connect(e)

task.spawn(function()
    while true do
        h()
        task.wait(1)
    end
end)

a.Heartbeat:Connect(function()
    pcall(function()
        sethiddenproperty(c, "StreamingPauseMode", 2)
    end)
    for m, n in pairs(b:GetChildren()) do
        if n:IsA("PostEffect") or n:IsA("BloomEffect") or n:IsA("BlurEffect") or n:IsA("SunRaysEffect") then
            n.Enabled = false
        end
    end
end)
